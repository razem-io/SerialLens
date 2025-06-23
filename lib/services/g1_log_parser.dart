import 'dart:convert';
import '../models/g1_device.dart';

class G1LogParser {
  static final RegExp _boxBatteryRegex = RegExp(r'box bat: (\d+) mV, (\d+)%');
  static final RegExp _nfc0DataRegex = RegExp(r'NFC0: \[\d+\] Get data:(\w{2}) (\w{2}) (\w{2}) (\w{2}), Rx VRECT: (\d+)mV, Battery Level: (\d+)%, curFlg:(\d+),current:(\d+)');
  static final RegExp _nfc1DataRegex = RegExp(r'NFC1: \[\d+\] Get data:(\w{2}) (\w{2}) (\w{2}) (\w{2}), Rx VRECT: (\d+)mV, Battery Level: (\d+)%, curFlg:(\d+),current:(\d+)');
  static final RegExp _nfcTempRegex = RegExp(r'NFC IC0:(\d+), NFC IC1:(\d+), Bat:(\d+)');
  static final RegExp _usbLidRegex = RegExp(r'usb:(\d+), lid:(\d+),\s+charge:(\d+)');
  static final RegExp _timestampRegex = RegExp(r'NFC[01]:\[(\d+)\]');
  static final RegExp _wlcStateRegex = RegExp(r'WLC State: ([A-Z_]+)');
  static final RegExp _batteryLevelRegex = RegExp(r'RX BatLevel--L:(\d+)%, R:(\d+)%, bat:(\d+)');
  static final RegExp _lidEventRegex = RegExp(r'\.{5}lid event\.{4}(open|close)');

  static G1Device parseLogLine(String line, G1Device currentDevice) {
    final updatedDevice = currentDevice.copyWith(lastUpdate: DateTime.now());

    // Parse case battery information
    final boxBatteryMatch = _boxBatteryRegex.firstMatch(line);
    if (boxBatteryMatch != null) {
      return updatedDevice.copyWith(
        caseBatteryVoltage: int.parse(boxBatteryMatch.group(1)!),
        caseBatteryPercentage: int.parse(boxBatteryMatch.group(2)!),
      );
    }

    // Parse NFC0 (Right glass) charging data
    final nfc0DataMatch = _nfc0DataRegex.firstMatch(line);
    if (nfc0DataMatch != null) {
      return updatedDevice.copyWith(
        rightVrectVoltage: int.parse(nfc0DataMatch.group(5)!),
        rightChargingCurrent: int.parse(nfc0DataMatch.group(8)!),
        rightIsCharging: nfc0DataMatch.group(7) == '1',
      );
    }

    // Parse NFC1 (Left glass) charging data
    final nfc1DataMatch = _nfc1DataRegex.firstMatch(line);
    if (nfc1DataMatch != null) {
      return updatedDevice.copyWith(
        leftVrectVoltage: int.parse(nfc1DataMatch.group(5)!),
        leftChargingCurrent: int.parse(nfc1DataMatch.group(8)!),
        leftIsCharging: nfc1DataMatch.group(7) == '1',
      );
    }

    // Parse NFC IC temperatures
    final nfcTempMatch = _nfcTempRegex.firstMatch(line);
    if (nfcTempMatch != null) {
      return updatedDevice.copyWith(
        nfcTemp0: int.parse(nfcTempMatch.group(1)!),
        nfcTemp1: int.parse(nfcTempMatch.group(2)!),
        batteryTemp: int.parse(nfcTempMatch.group(3)!),
      );
    }

    // Parse USB and lid status, and infer case charging
    final usbLidMatch = _usbLidRegex.firstMatch(line);
    if (usbLidMatch != null) {
      final chargeStatus = int.parse(usbLidMatch.group(3)!);
      return updatedDevice.copyWith(
        usbConnected: usbLidMatch.group(1) == '01',
        lidClosed: usbLidMatch.group(2) == '01',
        caseIsCharging: chargeStatus > 0, // charge:02 or charge:03 indicates charging
      );
    }

    // Parse battery levels for left and right glasses
    final batteryLevelMatch = _batteryLevelRegex.firstMatch(line);
    if (batteryLevelMatch != null) {
      return updatedDevice.copyWith(
        leftGlassBattery: int.parse(batteryLevelMatch.group(1)!),
        rightGlassBattery: int.parse(batteryLevelMatch.group(2)!),
      );
    }

    // Parse timestamps from NFC communication
    final timestampMatch = _timestampRegex.firstMatch(line);
    if (timestampMatch != null) {
      final wlcStateMatch = _wlcStateRegex.firstMatch(line);
      return updatedDevice.copyWith(
        timestamp: int.parse(timestampMatch.group(1)!),
        nfcState: wlcStateMatch?.group(1),
      );
    }

    // Parse lid events
    final lidEventMatch = _lidEventRegex.firstMatch(line);
    if (lidEventMatch != null) {
      return updatedDevice.copyWith(
        lidClosed: lidEventMatch.group(1) == 'close',
      );
    }

    return updatedDevice;
  }

  static Map<String, dynamic> extractAllData(String line) {
    final data = <String, dynamic>{};

    // Extract all numeric values and their context
    final patterns = {
      'box_battery_voltage': _boxBatteryRegex,
      'nfc0_data': _nfc0DataRegex,
      'nfc1_data': _nfc1DataRegex,
      'nfc_temps': _nfcTempRegex,
      'usb_lid_status': _usbLidRegex,
      'battery_levels': _batteryLevelRegex,
      'timestamp': _timestampRegex,
    };

    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(line);
      if (match != null) {
        data[entry.key] = match.groups(List.generate(match.groupCount, (i) => i + 1));
      }
    }

    return data;
  }

  static bool isG1LogLine(String line) {
    return line.contains('NFC') ||
           line.contains('box bat:') ||
           line.contains('Get data:') ||
           line.contains('usb:') ||
           line.contains('lid:') ||
           line.contains('WLC State:') ||
           line.contains('RX BatLevel') ||
           line.contains('lid event');
  }
}