import 'package:flutter/foundation.dart';
import '../models/g1_device.dart';
import '../services/serial_device_manager.dart';

class DeviceProvider extends ChangeNotifier {
  final SerialDeviceManager _deviceManager = SerialDeviceManager();
  List<G1Device> _devices = [];

  List<G1Device> get devices => _devices;
  int get connectedDeviceCount => _devices.where((d) => d.isConnected).length;
  int get totalDeviceCount => _devices.length;

  DeviceProvider() {
    _deviceManager.devicesStream.listen((devices) {
      _devices = devices;
      notifyListeners();
    });

    _deviceManager.deviceUpdateStream.listen((device) {
      final index = _devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        _devices[index] = device;
        notifyListeners();
      }
    });
  }

  void startInitialScan() {
    _deviceManager.startInitialScan();
  }

  Future<void> scanOnce() async {
    await _deviceManager.scanOnce();
  }

  Future<void> reconnectDevice(String deviceId) async {
    await _deviceManager.reconnectDevice(deviceId);
  }

  Future<void> disconnectDevice(String deviceId) async {
    await _deviceManager.disconnectDevice(deviceId);
  }

  G1Device? getDeviceById(String deviceId) {
    try {
      return _devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  List<G1Device> getConnectedDevices() {
    return _devices.where((device) => device.isConnected).toList();
  }

  List<G1Device> getDisconnectedDevices() {
    return _devices.where((device) => !device.isConnected).toList();
  }

  @override
  void dispose() {
    _deviceManager.dispose();
    super.dispose();
  }
}