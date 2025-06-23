class G1Device {
  final String id;
  final String port;
  final String name;
  bool isConnected;
  DateTime? lastUpdate;
  
  // Battery information
  int? caseBatteryVoltage; // mV
  int? caseBatteryPercentage;
  int? leftGlassBattery;
  int? rightGlassBattery;
  
  // Charging information
  // Case charging
  int? caseVrectVoltage; // mV
  int? caseChargingCurrent; // mA
  bool? caseIsCharging;
  
  // Left glass charging
  int? leftVrectVoltage; // mV
  int? leftChargingCurrent; // mA
  bool? leftIsCharging;
  
  // Right glass charging
  int? rightVrectVoltage; // mV
  int? rightChargingCurrent; // mA
  bool? rightIsCharging;
  
  // Hardware status
  bool? usbConnected;
  bool? lidClosed;
  int? nfcTemp0; // NFC IC0 temperature
  int? nfcTemp1; // NFC IC1 temperature
  int? batteryTemp; // Battery temperature
  
  // NFC status
  String? nfcState;
  int? timestamp;

  G1Device({
    required this.id,
    required this.port,
    required this.name,
    this.isConnected = false,
    this.lastUpdate,
    this.caseBatteryVoltage,
    this.caseBatteryPercentage,
    this.leftGlassBattery,
    this.rightGlassBattery,
    this.caseVrectVoltage,
    this.caseChargingCurrent,
    this.caseIsCharging,
    this.leftVrectVoltage,
    this.leftChargingCurrent,
    this.leftIsCharging,
    this.rightVrectVoltage,
    this.rightChargingCurrent,
    this.rightIsCharging,
    this.usbConnected,
    this.lidClosed,
    this.nfcTemp0,
    this.nfcTemp1,
    this.batteryTemp,
    this.nfcState,
    this.timestamp,
  });

  G1Device copyWith({
    String? id,
    String? port,
    String? name,
    bool? isConnected,
    DateTime? lastUpdate,
    int? caseBatteryVoltage,
    int? caseBatteryPercentage,
    int? leftGlassBattery,
    int? rightGlassBattery,
    int? caseVrectVoltage,
    int? caseChargingCurrent,
    bool? caseIsCharging,
    int? leftVrectVoltage,
    int? leftChargingCurrent,
    bool? leftIsCharging,
    int? rightVrectVoltage,
    int? rightChargingCurrent,
    bool? rightIsCharging,
    bool? usbConnected,
    bool? lidClosed,
    int? nfcTemp0,
    int? nfcTemp1,
    int? batteryTemp,
    String? nfcState,
    int? timestamp,
  }) {
    return G1Device(
      id: id ?? this.id,
      port: port ?? this.port,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      caseBatteryVoltage: caseBatteryVoltage ?? this.caseBatteryVoltage,
      caseBatteryPercentage: caseBatteryPercentage ?? this.caseBatteryPercentage,
      leftGlassBattery: leftGlassBattery ?? this.leftGlassBattery,
      rightGlassBattery: rightGlassBattery ?? this.rightGlassBattery,
      caseVrectVoltage: caseVrectVoltage ?? this.caseVrectVoltage,
      caseChargingCurrent: caseChargingCurrent ?? this.caseChargingCurrent,
      caseIsCharging: caseIsCharging ?? this.caseIsCharging,
      leftVrectVoltage: leftVrectVoltage ?? this.leftVrectVoltage,
      leftChargingCurrent: leftChargingCurrent ?? this.leftChargingCurrent,
      leftIsCharging: leftIsCharging ?? this.leftIsCharging,
      rightVrectVoltage: rightVrectVoltage ?? this.rightVrectVoltage,
      rightChargingCurrent: rightChargingCurrent ?? this.rightChargingCurrent,
      rightIsCharging: rightIsCharging ?? this.rightIsCharging,
      usbConnected: usbConnected ?? this.usbConnected,
      lidClosed: lidClosed ?? this.lidClosed,
      nfcTemp0: nfcTemp0 ?? this.nfcTemp0,
      nfcTemp1: nfcTemp1 ?? this.nfcTemp1,
      batteryTemp: batteryTemp ?? this.batteryTemp,
      nfcState: nfcState ?? this.nfcState,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'G1Device(id: $id, port: $port, name: $name, connected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is G1Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}