import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import '../models/g1_device.dart';
import 'g1_log_parser.dart';

class SerialDeviceManager {
  static const int _baudRate = 115200;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final Map<String, G1Device> _devices = {};
  final Map<String, SerialPort> _ports = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, StringBuffer> _buffers = {};
  
  Timer? _scanTimer;
  final StreamController<List<G1Device>> _devicesController = StreamController.broadcast();
  final StreamController<G1Device> _deviceUpdateController = StreamController.broadcast();

  Stream<List<G1Device>> get devicesStream => _devicesController.stream;
  Stream<G1Device> get deviceUpdateStream => _deviceUpdateController.stream;
  List<G1Device> get devices => _devices.values.toList();

  Future<void> scanOnce() async {
    await _scanForDevices();
  }

  void startInitialScan() {
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    final availablePorts = SerialPort.availablePorts;
    
    // Add known G1 device paths manually if not found by serial scan
    final manualPorts = ['/dev/tty.usbserial-110'];
    final allPorts = <String>{...availablePorts, ...manualPorts}.toList();
    
    final g1Ports = <String>[];

    // Filter for potential G1 devices (USB serial ports)
    for (final portName in allPorts) {
      if (_isLikelyG1Port(portName)) {
        g1Ports.add(portName);
      }
    }

    // Remove devices that are no longer available
    final removedPorts = _devices.keys.where((port) => !g1Ports.contains(port)).toList();
    for (final port in removedPorts) {
      await _disconnectDevice(port);
    }

    // Add new devices
    for (final portName in g1Ports) {
      if (!_devices.containsKey(portName)) {
        await _addDevice(portName);
      }
    }

    _devicesController.add(devices);
  }

  bool _isLikelyG1Port(String portName) {
    // macOS: /dev/tty.usbserial-* (callin devices for incoming data)
    // Linux: /dev/ttyUSB* or /dev/ttyACM*
    // Windows: COM*
    // Note: We avoid cu.* devices as they are for outgoing calls, not monitoring incoming data
    if (Platform.isMacOS) {
      return portName.startsWith('/dev/tty.usbserial');
    } else if (Platform.isLinux) {
      return portName.startsWith('/dev/ttyUSB') || portName.startsWith('/dev/ttyACM');
    } else if (Platform.isWindows) {
      return portName.startsWith('COM');
    }
    return false;
  }

  Future<void> _addDevice(String portName) async {
    final deviceId = _generateDeviceId(portName);
    final device = G1Device(
      id: deviceId,
      port: portName,
      name: 'G1 Glasses ${deviceId.substring(0, 8)}',
    );

    _devices[portName] = device;
    _buffers[portName] = StringBuffer();

    try {
      await _connectToDevice(portName);
    } catch (e) {
      print('Failed to connect to device $portName: $e');
      // Schedule reconnection attempt
      Timer(_reconnectDelay, () => _connectToDevice(portName));
    }
  }

  Future<void> _connectToDevice(String portName) async {
    if (_ports.containsKey(portName)) {
      return; // Already connected
    }

    final port = SerialPort(portName);
    
    try {
      // Configure port
      final config = SerialPortConfig()
        ..baudRate = _baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);

      if (!port.openReadWrite()) {
        throw Exception('Failed to open port $portName: ${SerialPort.lastError}');
      }

      port.config = config;
      if (!port.isOpen) {
        port.close();
        throw Exception('Failed to configure port $portName: ${SerialPort.lastError}');
      }

      _ports[portName] = port;
      _devices[portName] = _devices[portName]!.copyWith(isConnected: true);

      // Start reading data
      final reader = SerialPortReader(port);
      _subscriptions[portName] = reader.stream.listen(
        (data) => _handleData(portName, data),
        onError: (error) => _handleError(portName, error),
        onDone: () => _handleDisconnection(portName),
      );

      print('Connected to G1 device on $portName');
      _deviceUpdateController.add(_devices[portName]!);

    } catch (e) {
      port.close();
      _devices[portName] = _devices[portName]!.copyWith(isConnected: false);
      print('Connection failed for $portName: $e');
      
      // Schedule reconnection
      Timer(_reconnectDelay, () => _connectToDevice(portName));
    }
  }

  void _handleData(String portName, Uint8List data) {
    final text = String.fromCharCodes(data);
    final buffer = _buffers[portName]!;
    buffer.write(text);

    // Process complete lines
    final lines = buffer.toString().split('\n');
    buffer.clear();
    
    // Keep incomplete line in buffer
    if (lines.isNotEmpty && !text.endsWith('\n')) {
      buffer.write(lines.removeLast());
    }

    // Process complete lines
    for (final line in lines) {
      if (line.trim().isNotEmpty && G1LogParser.isG1LogLine(line)) {
        _processLogLine(portName, line.trim());
      }
    }
  }

  void _processLogLine(String portName, String line) {
    final currentDevice = _devices[portName];
    if (currentDevice == null) return;

    final updatedDevice = G1LogParser.parseLogLine(line, currentDevice);
    _devices[portName] = updatedDevice;
    _deviceUpdateController.add(updatedDevice);
  }

  void _handleError(String portName, dynamic error) {
    print('Error reading from $portName: $error');
    _handleDisconnection(portName);
  }

  void _handleDisconnection(String portName) {
    print('Device disconnected: $portName');
    _disconnectDevice(portName);
    
    // Schedule reconnection attempt
    Timer(_reconnectDelay, () {
      if (_devices.containsKey(portName)) {
        _connectToDevice(portName);
      }
    });
  }

  Future<void> _disconnectDevice(String portName) async {
    _subscriptions[portName]?.cancel();
    _subscriptions.remove(portName);
    
    _ports[portName]?.close();
    _ports.remove(portName);
    
    _buffers.remove(portName);
    
    if (_devices.containsKey(portName)) {
      _devices[portName] = _devices[portName]!.copyWith(isConnected: false);
      _deviceUpdateController.add(_devices[portName]!);
    }
  }

  String _generateDeviceId(String portName) {
    // Generate a consistent ID based on port name
    return portName.hashCode.abs().toString();
  }

  Future<void> disconnectDevice(String deviceId) async {
    final portName = _devices.entries
        .firstWhere((entry) => entry.value.id == deviceId)
        .key;
    await _disconnectDevice(portName);
  }

  Future<void> reconnectDevice(String deviceId) async {
    final portName = _devices.entries
        .firstWhere((entry) => entry.value.id == deviceId)
        .key;
    await _connectToDevice(portName);
  }

  void dispose() {
    _scanTimer?.cancel();
    _scanTimer = null;
    
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    for (final port in _ports.values) {
      port.close();
    }
    _ports.clear();
    
    _devices.clear();
    _buffers.clear();
    
    _devicesController.close();
    _deviceUpdateController.close();
  }
}