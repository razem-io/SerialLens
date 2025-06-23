import 'dart:io';

void main() async {
  print('🔍 G1 Glasses Serial Connection Test (Basic)\n');
  
  // Test 1: Check if we can see the serial devices using system commands
  print('📋 Step 1: Scanning for USB serial devices...\n');
  
  if (Platform.isMacOS || Platform.isLinux) {
    await _testUnixSerialPorts();
  } else if (Platform.isWindows) {
    await _testWindowsSerialPorts();
  }
  
  print('\n🔌 Step 2: Testing direct connection with screen command...\n');
  await _testScreenConnection();
  
  print('\n📋 Step 3: Checking permissions...\n');
  await _testPermissions();
  
  print('\n💡 Step 4: Recommendations...\n');
  _printRecommendations();
}

Future<void> _testUnixSerialPorts() async {
  final commands = [
    'ls -la /dev/tty.usb*',
    'ls -la /dev/ttyUSB*', 
    'ls -la /dev/ttyACM*',
    'dmesg | grep -i usb | tail -10',
  ];
  
  for (final cmd in commands) {
    try {
      print('Running: $cmd');
      final result = await Process.run('sh', ['-c', cmd]);
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        print('✅ Output:');
        print(result.stdout);
      } else {
        print('❌ No results or error');
        if (result.stderr.toString().trim().isNotEmpty) {
          print('Error: ${result.stderr}');
        }
      }
    } catch (e) {
      print('❌ Command failed: $e');
    }
    print('');
  }
}

Future<void> _testWindowsSerialPorts() async {
  try {
    print('Running: mode');
    final result = await Process.run('mode', []);
    if (result.exitCode == 0) {
      print('✅ Available COM ports:');
      print(result.stdout);
    } else {
      print('❌ Failed to get COM ports');
    }
  } catch (e) {
    print('❌ Command failed: $e');
  }
}

Future<void> _testScreenConnection() async {
  // Check if the known G1 device exists
  final g1Port = '/dev/tty.usbserial-110';
  
  print('Checking if G1 port exists: $g1Port');
  final file = File(g1Port);
  
  if (await file.exists()) {
    print('✅ G1 port found: $g1Port');
    
    // Test if we can read from it
    print('Testing read access...');
    try {
      final result = await Process.run('sh', ['-c', 'ls -la $g1Port']);
      print('Port details:');
      print(result.stdout);
      
      // Check if screen command is available
      final screenTest = await Process.run('which', ['screen']);
      if (screenTest.exitCode == 0) {
        print('✅ screen command available at: ${screenTest.stdout.trim()}');
        print('💡 You can manually test with: screen $g1Port 115200');
        
        // Test a quick read (timeout after 3 seconds)
        print('🧪 Testing quick data read (3 second timeout)...');
        try {
          final process = await Process.start('timeout', ['3', 'cat', g1Port]);
          
          // Read some data
          final output = StringBuffer();
          process.stdout.listen((data) {
            output.write(String.fromCharCodes(data));
          });
          
          final exitCode = await process.exitCode;
          final outputText = output.toString();
          
          if (outputText.isNotEmpty) {
            print('✅ Data received:');
            final lines = outputText.split('\n').take(5);
            for (final line in lines) {
              if (line.trim().isNotEmpty) {
                print('   📄 $line');
              }
            }
          } else {
            print('⚠️  No data received (this might be normal if glasses are idle)');
          }
          
        } catch (e) {
          print('⚠️  Quick read test failed: $e');
        }
        
      } else {
        print('❌ screen command not found');
      }
      
    } catch (e) {
      print('❌ Error accessing port: $e');
    }
    
  } else {
    print('❌ G1 port not found: $g1Port');
    print('💡 Check if glasses are connected and recognized by system');
  }
}

Future<void> _testPermissions() async {
  final currentUser = Platform.environment['USER'] ?? 'unknown';
  print('Current user: $currentUser');
  
  // Check groups (important for serial port access)
  try {
    final result = await Process.run('groups', []);
    if (result.exitCode == 0) {
      final groups = result.stdout.toString().trim().split(' ');
      print('User groups: ${groups.join(", ")}');
      
      final importantGroups = ['dialout', 'uucp', 'admin', 'wheel'];
      final hasGroups = groups.where((g) => importantGroups.contains(g)).toList();
      
      if (hasGroups.isNotEmpty) {
        print('✅ User has serial access groups: ${hasGroups.join(", ")}');
      } else {
        print('⚠️  User might not have serial port access groups');
        print('💡 Consider adding user to dialout/uucp group (Linux) or admin group (macOS)');
      }
    }
  } catch (e) {
    print('❌ Could not check user groups: $e');
  }
  
  // Check if we can access the specific port
  final g1Port = '/dev/tty.usbserial-110';
  try {
    final result = await Process.run('ls', ['-la', g1Port]);
    if (result.exitCode == 0) {
      print('G1 port permissions:');
      print(result.stdout);
    }
  } catch (e) {
    print('Could not check port permissions: $e');
  }
}

void _printRecommendations() {
  print('🔧 Troubleshooting recommendations:');
  print('');
  print('1. 📱 Hardware Check:');
  print('   - Ensure G1 glasses are connected via USB-C cable');
  print('   - Try different USB-C cable or port');
  print('   - Check if glasses are powered on');
  print('');
  print('2. 🖥️  System Check:');
  print('   - Run: system_profiler SPUSBDataType | grep -A 10 -B 5 serial');
  print('   - Check System Information > Hardware > USB for connected devices');
  print('');
  print('3. 🔐 Permissions Check:');
  print('   - Try running app with sudo (for testing only)');
  print('   - Add user to dialout group: sudo usermod -a -G dialout \$USER');
  print('');
  print('4. 🐛 Driver Check:');
  print('   - Install FTDI drivers if needed: https://ftdichip.com/drivers/');
  print('   - Restart computer after driver installation');
  print('');
  print('5. 🧪 Manual Test:');
  print('   - Test with: screen /dev/tty.usbserial-110 115200');
  print('   - Press Ctrl+A, then K to exit screen');
  print('');
  print('6. 🔄 Flutter App Debug:');
  print('   - Run flutter app with: flutter run -d macos --verbose');
  print('   - Check console output for serial port errors');
}