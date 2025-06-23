import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/g1_device.dart';

class DeviceCard extends StatelessWidget {
  final G1Device device;
  final VoidCallback? onReconnect;
  final VoidCallback? onDisconnect;

  const DeviceCard({
    super.key,
    required this.device,
    this.onReconnect,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            if (device.isConnected) ...[
              _buildBatterySection(),
              const SizedBox(height: 16),
              _buildChargingSection(),
              const SizedBox(height: 16),
              _buildStatusSection(),
            ] else ...[
              _buildDisconnectedState(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.smart_display,
          color: device.isConnected ? Colors.green : Colors.red,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                device.port,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildConnectionStatus(),
        const SizedBox(width: 8),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: device.isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        device.isConnected ? 'Connected' : 'Disconnected',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return IconButton(
      onPressed: device.isConnected ? onDisconnect : onReconnect,
      icon: Icon(
        device.isConnected ? Icons.link_off : Icons.refresh,
        color: device.isConnected ? Colors.red : Colors.blue,
      ),
      tooltip: device.isConnected ? 'Disconnect' : 'Reconnect',
    );
  }

  Widget _buildBatterySection() {
    final bool showGlassBatteryHint = device.lidClosed == true && 
        (device.leftGlassBattery == null || device.rightGlassBattery == null);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Battery Levels',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBatteryIndicator('Case', device.caseBatteryPercentage, Colors.blue)),
            Expanded(child: _buildBatteryIndicator('Left', device.leftGlassBattery, Colors.green)),
            Expanded(child: _buildBatteryIndicator('Right', device.rightGlassBattery, Colors.orange)),
          ],
        ),
        if (showGlassBatteryHint) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Open the case lid to see glasses battery levels',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBatteryIndicator(String label, int? percentage, Color color) {
    const double totalHeight = 60.0;
    const double borderWidth = 2.0;
    const double borderRadius = 2.0;
    
    // Show checking state if no data available
    if (percentage == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            SizedBox(
              height: totalHeight,
              width: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer container (border)
                  Container(
                    width: 30,
                    height: totalHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: borderWidth),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Checking indicator
                  const Text(
                    '?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final percent = percentage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          SizedBox(
            height: totalHeight,
            width: 30,
            child: Stack(
              children: [
                // Outer container (border)
                Container(
                  width: 30,
                  height: totalHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: borderWidth),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Inner fill - positioned from bottom
                Positioned(
                  bottom: borderWidth,
                  left: borderWidth,
                  right: borderWidth,
                  child: Container(
                    height: percent >= 100 
                        ? totalHeight - (borderWidth * 2) // Fill completely for 100%
                        : ((totalHeight - (borderWidth * 2)) * percent / 100).clamp(0.0, totalHeight - (borderWidth * 2)),
                    decoration: BoxDecoration(
                      color: _getBatteryColor(percent),
                      borderRadius: percent >= 100 
                          ? BorderRadius.circular(borderRadius)
                          : BorderRadius.only(
                              bottomLeft: Radius.circular(borderRadius),
                              bottomRight: Radius.circular(borderRadius),
                            ),
                    ),
                  ),
                ),
                // Percentage text
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${percent}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int percentage) {
    if (percentage > 50) return Colors.green;
    if (percentage > 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildChargingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Charging Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildChargingTile('Case', device.caseIsCharging, device.caseVrectVoltage, device.caseChargingCurrent, device.batteryTemp)),
            Expanded(child: _buildChargingTile('Left', device.leftIsCharging, device.leftVrectVoltage, device.leftChargingCurrent, device.nfcTemp1)),
            Expanded(child: _buildChargingTile('Right', device.rightIsCharging, device.rightVrectVoltage, device.rightChargingCurrent, device.nfcTemp0)),
          ],
        ),
      ],
    );
  }

  Widget _buildChargingTile(String label, bool? isCharging, int? vrectVoltage, int? chargingCurrent, int? temperature) {
    // If we have no current data (mA), we're definitely not charging
    final bool charging = (chargingCurrent != null && chargingCurrent > 0) && isCharging == true;
    // For case, also consider caseBatteryVoltage as data
    // For glasses, temperature data means we have NFC communication, so show 'Not Charging' instead of 'Unknown'
    final bool hasData = isCharging != null || vrectVoltage != null || chargingCurrent != null || 
                        (label == 'Case' && device.caseBatteryVoltage != null) ||
                        (label != 'Case' && temperature != null);
    final String status = hasData ? (charging ? 'Charging' : 'Not Charging') : 'Unknown';
    final String voltage = vrectVoltage != null ? '${vrectVoltage}mV' : '--';
    final String current = chargingCurrent != null ? '${chargingCurrent}mA' : '--';
    final String temp = temperature != null ? '${temperature}°C' : '--';
    
    // For case, show case battery voltage instead of VRECT
    final String displayVoltage = label == 'Case' && device.caseBatteryVoltage != null 
        ? '${device.caseBatteryVoltage}mV' 
        : voltage;
    
    // Determine if we should show voltage - for case check caseBatteryVoltage, for glasses check vrectVoltage > 0
    final bool hasVoltage = label == 'Case' 
        ? device.caseBatteryVoltage != null 
        : (vrectVoltage != null && vrectVoltage > 0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      height: 140, // Fixed height for consistency
      decoration: BoxDecoration(
        color: !hasData ? Colors.orange[50] : (charging ? Colors.green[50] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
        border: !hasData ? Border.all(color: Colors.orange[200]!) : (charging ? Border.all(color: Colors.green[200]!) : null),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Icon(
                !hasData ? Icons.help_outline : (charging ? Icons.battery_charging_full : Icons.battery_std),
                size: 20,
                color: !hasData ? Colors.orange[600] : (charging ? Colors.green : Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: !hasData ? Colors.orange[700] : (charging ? Colors.green[700] : Colors.grey[700]),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                temp,
                style: TextStyle(
                  fontSize: 8, 
                  color: !hasData ? Colors.orange[600] : (charging ? Colors.green[600] : Colors.grey[600]),
                ),
                textAlign: TextAlign.center,
              ),
              // Always reserve space for voltage and current
              Text(
                hasVoltage ? displayVoltage : '',
                style: TextStyle(fontSize: 8, color: charging ? Colors.green[600] : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              Text(
                charging ? current : '',
                style: TextStyle(fontSize: 8, color: Colors.green[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hardware Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusTile('USB', device.usbConnected == true, Icons.usb),
            ),
            Expanded(
              child: _buildStatusTile('Lid', device.lidClosed == true ? 'Closed' : 'Open', Icons.laptop),
            ),
            // Removed NFC State as it changes too rapidly and creates visual noise
          ],
        ),
      ],
    );
  }


  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String label, dynamic value, IconData icon) {
    final isActive = value is bool ? value : false;
    final displayValue = value is bool ? (value ? 'On' : 'Off') : value.toString();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green[700] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Device Disconnected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the refresh button to reconnect',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}