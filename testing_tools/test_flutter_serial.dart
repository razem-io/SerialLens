// Run this from the serial_lens directory with: flutter run --target=../test_flutter_serial.dart

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G1 Serial Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SerialTestScreen(),
    );
  }
}

class SerialTestScreen extends StatefulWidget {
  @override
  _SerialTestScreenState createState() => _SerialTestScreenState();
}

class _SerialTestScreenState extends State<SerialTestScreen> {
  List<String> _logs = [];
  List<String> _availablePorts = [];
  String? _selectedPort;
  SerialPort? _port;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _scanPorts();
  }

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  void _scanPorts() {
    _log('🔍 Scanning for serial ports...');
    
    try {
      final ports = SerialPort.availablePorts;
      
      // Add known G1 device paths manually if not found
      final manualPorts = ['/dev/tty.usbserial-110'];
      final allPorts = <String>{...ports, ...manualPorts}.toList();
      
      setState(() {
        _availablePorts = allPorts;
      });
      
      _log('✅ Found ${ports.length} scanned port(s): ${ports.join(", ")}');
      _log('📝 Total available ports (including manual): ${allPorts.join(", ")}');
      
      // Check each port for details and if it looks like G1 glasses
      final g1Candidates = <String>[];
      for (final portName in allPorts) {
        _log('📋 Port found: $portName');
        
        // Check if this looks like G1 glasses based on port name
        if (_isLikelyG1Port(portName)) {
          _log('🎯 This looks like G1 glasses!');
          g1Candidates.add(portName);
        }
      }
      
      // Prefer tty.usbserial over cu.usbserial for macOS
      if (g1Candidates.isNotEmpty && _selectedPort == null) {
        String? preferredPort;
        
        // Look for tty.usbserial first
        for (final port in g1Candidates) {
          if (port.contains('/dev/tty.usbserial')) {
            preferredPort = port;
            _log('🎯 Selecting preferred tty device: $port');
            break;
          }
        }
        
        // Fallback to any G1 candidate
        preferredPort ??= g1Candidates.first;
        
        setState(() {
          _selectedPort = preferredPort;
        });
      }
      
    } catch (e) {
      _log('❌ Error scanning ports: $e');
    }
  }

  bool _isLikelyG1Port(String portName) {
    // Check port name pattern for G1 glasses
    if (portName.startsWith('/dev/tty.usbserial') || portName.startsWith('/dev/cu.usbserial')) {
      return true;
    }
    
    // Check other common USB serial patterns
    if (portName.startsWith('/dev/ttyUSB') || portName.startsWith('/dev/ttyACM')) {
      return true;
    }
    
    // Windows COM ports
    if (portName.startsWith('COM')) {
      return true;
    }
    
    return false;
  }

  Future<void> _connectToPort(String portName) async {
    _log('🔌 Connecting to $portName...');
    
    try {
      _port = SerialPort(portName);
      
      if (!_port!.openReadWrite()) {
        _log('❌ Failed to open port: ${SerialPort.lastError}');
        return;
      }
      
      _log('✅ Port opened');
      
      // Configure port
      final config = SerialPortConfig()
        ..baudRate = 115200
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      
      _port!.config = config;
      _log('⚙️  Port configured (115200 8N1)');
      
      // Start reading
      final reader = SerialPortReader(_port!);
      _subscription = reader.stream.listen(
        (data) => _handleData(data),
        onError: (error) => _log('❌ Read error: $error'),
        onDone: () => _log('📡 Connection closed'),
      );
      
      setState(() {
        _isConnected = true;
      });
      
      _log('📡 Started listening for data...');
      
    } catch (e) {
      _log('❌ Connection error: $e');
      _port?.close();
    }
  }

  void _handleData(List<int> data) {
    final text = String.fromCharCodes(data);
    final lines = text.split('\n');
    
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        _log('📄 Data: ${line.trim()}');
        
        // Check if this looks like G1 data
        if (_isG1Data(line)) {
          _log('🎯 G1 data detected!');
        }
      }
    }
  }

  bool _isG1Data(String line) {
    return line.contains('NFC') ||
           line.contains('box bat:') ||
           line.contains('Get data:') ||
           line.contains('usb:') ||
           line.contains('WLC State:') ||
           line.contains('RX BatLevel') ||
           line.contains('PB4 LOW');
  }

  void _disconnect() {
    _log('🔌 Disconnecting...');
    _subscription?.cancel();
    _port?.close();
    setState(() {
      _isConnected = false;
    });
    _log('✅ Disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('G1 Serial Connection Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _scanPorts,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Port selection
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Ports:', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    if (_availablePorts.isEmpty)
                      Text('No ports found', style: TextStyle(color: Colors.red))
                    else
                      DropdownButton<String>(
                        value: _selectedPort,
                        hint: Text('Select a port'),
                        isExpanded: true,
                        items: _availablePorts.map((port) => DropdownMenuItem(
                          value: port,
                          child: Text(port),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPort = value;
                          });
                        },
                      ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectedPort != null && !_isConnected
                              ? () => _connectToPort(_selectedPort!)
                              : null,
                          child: Text('Connect'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isConnected ? _disconnect : null,
                          child: Text('Disconnect'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _scanPorts,
                          child: Text('Scan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Connection status
            Card(
              color: _isConnected ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected to $_selectedPort' : 'Not connected',
                      style: TextStyle(
                        color: _isConnected ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Logs
            Text('Logs:', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color? color;
                    if (log.contains('❌')) color = Colors.red;
                    else if (log.contains('✅')) color = Colors.green;
                    else if (log.contains('🎯')) color = Colors.blue;
                    else if (log.contains('📄')) color = Colors.purple;
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Clear logs button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _logs.clear();
                });
              },
              child: Text('Clear Logs'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _port?.close();
    super.dispose();
  }
}