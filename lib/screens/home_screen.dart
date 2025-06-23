import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/device_card.dart';
import '../models/g1_device.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Perform initial scan when the app launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().startInitialScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Serial Lens'),
            Consumer<DeviceProvider>(
              builder: (context, provider, child) {
                return Text(
                  '${provider.connectedDeviceCount}/${provider.totalDeviceCount} devices connected',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<DeviceProvider>().scanOnce();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan for Devices',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'about':
                  _showAboutDialog();
                  break;
                case 'settings':
                  _showSettingsDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          if (provider.devices.isEmpty) {
            return _buildEmptyState(false);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.scanOnce();
            },
            child: _buildDeviceList(provider.devices),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool _) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_display_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'No G1 Glasses Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the refresh button to search for connected devices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<G1Device> devices) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceCard(
          device: device,
          onReconnect: () => _reconnectDevice(device.id),
          onDisconnect: () => _disconnectDevice(device.id),
        );
      },
    );
  }

  Future<void> _reconnectDevice(String deviceId) async {
    final provider = context.read<DeviceProvider>();
    try {
      await provider.reconnectDevice(deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconnecting device...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reconnect: $e')),
        );
      }
    }
  }

  Future<void> _disconnectDevice(String deviceId) async {
    final provider = context.read<DeviceProvider>();
    try {
      await provider.disconnectDevice(deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device disconnected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disconnect: $e')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Serial Lens',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.smart_display, size: 48),
      children: [
        const Text(
          'Serial Lens is a cross-platform monitoring application for Even Realities G1 smart AR glasses. '
          'It provides real-time information about battery levels, charging status, and device health.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Multi-device support'),
        const Text('• Real-time battery monitoring'),
        const Text('• Charging status tracking'),
        const Text('• Temperature monitoring'),
        const Text('• Hardware status indicators'),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Auto-reconnect'),
              subtitle: const Text('Automatically reconnect to disconnected devices'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement auto-reconnect setting
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Show notifications for low battery'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement notifications setting
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}