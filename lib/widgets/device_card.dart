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
              const SizedBox(height: 16),
              _buildTemperatureSection(),
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
        if (device.caseBatteryVoltage != null) ...[
          const SizedBox(height: 8),
          Text(
            'Case Voltage: ${device.caseBatteryVoltage} mV',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildBatteryIndicator(String label, int? percentage, Color color) {
    final percent = percentage ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          SizedBox(
            height: 60,
            width: 30,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 30,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 26,
                  height: (56 * percent / 100).clamp(0, 56),
                  decoration: BoxDecoration(
                    color: _getBatteryColor(percent),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  child: Text(
                    '${percent}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
            Expanded(
              child: _buildInfoTile('VRECT', '${device.vrectVoltage ?? 0} mV', Icons.electrical_services),
            ),
            Expanded(
              child: _buildInfoTile('Current', '${device.chargingCurrent ?? 0} mA', Icons.flash_on),
            ),
            Expanded(
              child: _buildInfoTile(
                'Status',
                device.isCharging == true ? 'Charging' : 'Not Charging',
                device.isCharging == true ? Icons.battery_charging_full : Icons.battery_std,
              ),
            ),
          ],
        ),
      ],
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
            Expanded(
              child: _buildInfoTile('NFC State', device.nfcState ?? 'Unknown', Icons.nfc),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperature Readings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile('NFC IC0', '${device.nfcTemp0 ?? 0}°C', Icons.thermostat),
            ),
            Expanded(
              child: _buildInfoTile('NFC IC1', '${device.nfcTemp1 ?? 0}°C', Icons.thermostat),
            ),
            Expanded(
              child: _buildInfoTile('Battery', '${device.batteryTemp ?? 0}°C', Icons.battery_alert),
            ),
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