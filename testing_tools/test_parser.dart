import 'dart:io';
import 'serial_lens/lib/models/g1_device.dart';
import 'serial_lens/lib/services/g1_log_parser.dart';

void main() {
  // Read the sample log file
  final logFile = File('log-g1-example.txt');
  final lines = logFile.readAsLinesSync();
  
  // Create a test device
  var device = G1Device(
    id: 'test-device',
    port: '/dev/tty.test',
    name: 'Test G1 Glasses',
  );
  
  print('Testing G1 Log Parser with sample data...\n');
  
  int lineCount = 0;
  int parsedCount = 0;
  
  for (final line in lines) {
    lineCount++;
    
    // Remove line numbers (format: "   123→content")
    final cleanLine = line.replaceFirst(RegExp(r'^\s*\d+→'), '').trim();
    
    if (cleanLine.isNotEmpty && G1LogParser.isG1LogLine(cleanLine)) {
      final originalDevice = device;
      device = G1LogParser.parseLogLine(cleanLine, device);
      
      if (device != originalDevice) {
        parsedCount++;
        
        // Print interesting updates
        if (device.caseBatteryPercentage != null && originalDevice.caseBatteryPercentage != device.caseBatteryPercentage) {
          print('📦 Case Battery: ${device.caseBatteryVoltage}mV (${device.caseBatteryPercentage}%)');
        }
        
        if (device.leftGlassBattery != null && device.rightGlassBattery != null && 
            (originalDevice.leftGlassBattery != device.leftGlassBattery || originalDevice.rightGlassBattery != device.rightGlassBattery)) {
          print('👓 Glasses Battery: L:${device.leftGlassBattery}% R:${device.rightGlassBattery}%');
        }
        
        if (device.vrectVoltage != null && device.vrectVoltage! > 0 && originalDevice.vrectVoltage != device.vrectVoltage) {
          print('⚡ Charging: ${device.vrectVoltage}mV, ${device.chargingCurrent}mA, Active: ${device.isCharging}');
        }
        
        if (device.nfcTemp0 != null && originalDevice.nfcTemp0 != device.nfcTemp0) {
          print('🌡️  Temps: NFC0:${device.nfcTemp0}°C, NFC1:${device.nfcTemp1}°C, Bat:${device.batteryTemp}°C');
        }
        
        if (device.lidClosed != null && originalDevice.lidClosed != device.lidClosed) {
          print('📱 Lid: ${device.lidClosed! ? "Closed" : "Open"}, USB: ${device.usbConnected}');
        }
      }
    }
  }
  
  print('\n📊 Summary:');
  print('Total lines: $lineCount');
  print('Parsed lines: $parsedCount');
  print('Parse rate: ${(parsedCount / lineCount * 100).toStringAsFixed(1)}%');
  
  print('\n🔋 Final Device State:');
  print('Case Battery: ${device.caseBatteryVoltage}mV (${device.caseBatteryPercentage}%)');
  print('Left Glass: ${device.leftGlassBattery}%');
  print('Right Glass: ${device.rightGlassBattery}%');
  print('Charging Voltage: ${device.vrectVoltage}mV');
  print('Charging Current: ${device.chargingCurrent}mA');
  print('Is Charging: ${device.isCharging}');
  print('USB Connected: ${device.usbConnected}');
  print('Lid Closed: ${device.lidClosed}');
  print('NFC Temps: IC0:${device.nfcTemp0}°C, IC1:${device.nfcTemp1}°C');
  print('Battery Temp: ${device.batteryTemp}°C');
  print('Connection: ${device.isConnected ? "Connected" : "Disconnected"}');
}