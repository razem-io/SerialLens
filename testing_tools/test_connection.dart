import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() async {
  print('🔍 G1 Glasses Serial Connection Test\n');
  
  // Test 1: List all available serial ports
  print('📋 Step 1: Scanning for available serial ports...');
  final availablePorts = SerialPort.availablePorts;
  
  if (availablePorts.isEmpty) {
    print('❌ No serial ports found!');
    return;
  }
  
  print('✅ Found ${availablePorts.length} serial port(s):');
  for (final port in availablePorts) {
    print('   - $port');
  }
  print('');
  
  // Test 2: Filter for likely G1 ports
  print('🔎 Step 2: Filtering for G1-like ports...');
  final g1Ports = <String>[];
  
  for (final portName in availablePorts) {
    if (_isLikelyG1Port(portName)) {
      g1Ports.add(portName);
      print('✅ G1 candidate: $portName');
    } else {
      print('❌ Not G1-like: $portName');
    }
  }
  
  if (g1Ports.isEmpty) {
    print('❌ No G1-like ports found!');
    print('💡 Expected patterns: /dev/tty.usbserial* (macOS), /dev/ttyUSB* (Linux), COM* (Windows)');
    return;
  }
  print('');
  
  // Test 3: Try to connect to each G1 port
  for (final portName in g1Ports) {
    print('🔌 Step 3: Testing connection to $portName...');
    await _testPort(portName);
    print('');
  }
}

bool _isLikelyG1Port(String portName) {
  if (Platform.isMacOS) {
    return portName.startsWith('/dev/tty.usbserial');
  } else if (Platform.isLinux) {
    return portName.startsWith('/dev/ttyUSB') || portName.startsWith('/dev/ttyACM');
  } else if (Platform.isWindows) {
    return portName.startsWith('COM');
  }
  return false;
}

Future<void> _testPort(String portName) async {
  SerialPort? port;
  
  try {
    // Step 3a: Create port instance
    port = SerialPort(portName);
    print('   ✅ Port instance created');
    
    // Step 3b: Get port info
    try {
      final info = SerialPortInfo(portName);
      print('   📋 Port info:');
      print('      Description: ${info.description ?? "Unknown"}');
      print('      Manufacturer: ${info.manufacturer ?? "Unknown"}');
      print('      Product Name: ${info.productName ?? "Unknown"}');
      print('      Serial Number: ${info.serialNumber ?? "Unknown"}');
      print('      Vendor ID: ${info.vendorId?.toRadixString(16) ?? "Unknown"}');
      print('      Product ID: ${info.productId?.toRadixString(16) ?? "Unknown"}');
    } catch (e) {
      print('   ⚠️  Could not get port info: $e');
    }
    
    // Step 3c: Try to open port
    print('   🔓 Attempting to open port...');
    if (!port.openReadWrite()) {
      print('   ❌ Failed to open port: ${SerialPort.lastError}');
      return;
    }
    print('   ✅ Port opened successfully');
    
    // Step 3d: Configure port
    print('   ⚙️  Configuring port (115200 baud, 8N1)...');
    final config = SerialPortConfig()
      ..baudRate = 115200
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);
    
    port.config = config;
    print('   ✅ Port configured');
    
    // Step 3e: Test reading data
    print('   📖 Testing data reading (5 second timeout)...');
    
    final reader = SerialPortReader(port, timeout: 5000);
    final dataReceived = <int>[];
    var lineCount = 0;
    var g1DataFound = false;
    
    await for (final data in reader.stream) {
      dataReceived.addAll(data);
      
      // Convert to string and check for lines
      final text = String.fromCharCodes(dataReceived);
      final lines = text.split('\n');
      
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          lineCount++;
          print('   📄 Line $lineCount: ${line.trim()}');
          
          // Check if this looks like G1 data
          if (_isG1Data(line)) {
            g1DataFound = true;
            print('   🎯 G1 data detected!');
          }
          
          // Limit output
          if (lineCount >= 10) {
            print('   📄 ... (truncated after 10 lines)');
            break;
          }
        }
      }
      
      if (lineCount >= 10) break;
    }
    
    if (lineCount == 0) {
      print('   ⚠️  No data received within timeout');
      print('   💡 This might be normal if glasses are not actively sending data');
    } else {
      print('   ✅ Received $lineCount lines of data');
      if (g1DataFound) {
        print('   🎉 G1 glasses data confirmed!');
      } else {
        print('   ⚠️  Data doesn\'t look like G1 format');
      }
    }
    
  } catch (e) {
    print('   ❌ Error testing port: $e');
  } finally {
    // Step 3f: Clean up
    try {
      port?.close();
      print('   🔒 Port closed');
    } catch (e) {
      print('   ⚠️  Error closing port: $e');
    }
  }
}

bool _isG1Data(String line) {
  // Check for common G1 data patterns
  return line.contains('NFC') ||
         line.contains('box bat:') ||
         line.contains('Get data:') ||
         line.contains('usb:') ||
         line.contains('WLC State:') ||
         line.contains('RX BatLevel') ||
         line.contains('lid event') ||
         line.contains('PB4 LOW');
}