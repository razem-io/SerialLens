# Serial Lens - Even Realities G1 Glasses Monitor

<div align="center">

![SerialLens Logo](https://img.shields.io/badge/SerialLens-G1%20Monitor-blue?style=for-the-badge&logo=flutter)

A cross-platform Flutter application for monitoring multiple Even Realities G1 smart AR glasses via serial interface.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-ALPHA-red?style=for-the-badge)](https://github.com/yourusername/SerialLens)

> **⚠️ ALPHA SOFTWARE** - This application is currently in early development. Only tested on macOS with G1 glasses. Use at your own risk.

</div>

## 🚀 Features

- **🔗 Multi-Device Support**: Monitor multiple G1 glasses simultaneously
- **📊 Real-Time Monitoring**: Live battery levels, charging status, and hardware metrics
- **🌐 Cross-Platform**: Works on macOS, Windows, Linux, iOS, and Android
- **🎨 Modern UI**: Material Design 3 with dark/light theme support
- **🔄 Auto-Reconnection**: Automatic device detection and reconnection
- **📱 Responsive Design**: Optimized for all screen sizes

## 📋 Monitored Data

### 🔋 Battery Information
- **Case Battery**: Voltage (mV) and percentage
- **Left Glass**: Battery percentage
- **Right Glass**: Battery percentage

### ⚡ Charging Status
- **VRECT Voltage**: Wireless charging voltage (mV)
- **Charging Current**: Active charging current (mA)
- **Charging State**: Active/inactive status

### 🔧 Hardware Status
- **USB Connection**: Connection state
- **Lid Position**: Open/closed detection
- **NFC Communication**: Real-time NFC states and transitions

### 🌡️ Temperature Monitoring
- **NFC IC Temperatures**: Both NFC chips (°C)
- **Battery Temperature**: Internal battery temperature (°C)

## 🖼️ Screenshots

*Beautiful, responsive interface showing real-time G1 glasses data*

## 🔧 Installation & Setup

### Prerequisites

- **Flutter SDK** (latest stable version)
- **G1 Glasses** connected via USB-C cable
- **Platform-specific requirements**:
  - **macOS**: Xcode command line tools
  - **Linux**: Build essentials, libudev-dev
  - **Windows**: Visual Studio Build Tools

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/SerialLens.git
   cd SerialLens
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Connect your G1 glasses** via USB-C cable

4. **Run the application**:
   ```bash
   # macOS (tested)
   flutter run -d macos
   
   # Windows (experimental)
   flutter run -d windows
   
   # Linux (experimental)
   flutter run -d linux
   ```

## 🔍 Manual Testing (Without App)

Before using Serial Lens, you can manually verify your G1 glasses are sending data:

### Monitor G1 Data in Terminal

```bash
# macOS/Linux - Use screen to monitor live data
screen /dev/tty.usbserial-110 115200

# You should see live output like:
# box bat: 4250 mV, 90%
# NFC1:[3254900] Get data:01 02 30 63, Rx VRECT: 560mV, Battery Level: 99%
# usb:01, lid:01, charge:02
# NFC IC0:30, NFC IC1:32, Bat:27
# !!!!!!!!!!! PB4 LOW !!!!!!!!!!

# To exit screen:
# Ctrl+A, Ctrl+D = Detach (keeps session running)
# Ctrl+A, \ = Kill session immediately (like Ctrl+C)
# Ctrl+A, K, Y = Kill session with confirmation

# Alternative: minicom (if available)
minicom -D /dev/tty.usbserial-110 -b 115200

# Windows - Use PuTTY or similar terminal emulator
# Configure: Serial, COM3 (or your port), 115200 baud, 8-N-1
```

**Screen Command Quick Reference:**
- **Ctrl+A, Ctrl+D**: Detach from session (keeps it running)
- **Ctrl+A, K, Y**: Kill session with confirmation
- **screen -r**: Reattach to a detached session
- **screen -list**: List all screen sessions

### Verify G1 Hardware Connection

```bash
# Check if device is recognized by system
# macOS
system_profiler SPUSBDataType | grep -i "1a86\|serial"

# Linux
lsusb | grep -i "1a86\|ch34"
dmesg | grep -i "ch34\|1a86" | tail -5

# Check port permissions
ls -la /dev/tty.usbserial-*
# Should show: crw-rw-rw- (readable/writable by all)
```

If you see data flowing in the terminal, Serial Lens should work perfectly!

## 🐛 Troubleshooting

### Device Not Detected

<details>
<summary>Click to expand troubleshooting steps</summary>

1. **Test Manual Connection**:
   ```bash
   # macOS/Linux - Test with screen command
   screen /dev/tty.usbserial-110 115200
   # Exit: Ctrl+A, \ (immediate kill) or Ctrl+A, Ctrl+D (detach)
   # If you see G1 data flowing, the app should work!
   ```

2. **Check Permissions** (Linux):
   ```bash
   
   # Check current permissions
   ls -la /dev/tty.usbserial-*
   ```

</details>


### No Data Received

1. **Check if glasses are active**: G1 glasses may not send data when idle
2. **Try interacting with glasses**: Open/close case, put glasses on/off charging
3. **Verify baud rate**: Should be 115200 (default)
4. **Check cable**: Try different USB-C cable

## 🧪 Testing Tools

Serial Lens includes comprehensive testing tools for debugging connection issues:

### Basic Connection Test
```bash
dart testing_tools/test_serial_basic.dart
```

### Flutter Serial Test App
```bash
flutter run --target=testing_tools/test_flutter_serial.dart -d macos
```

### Log Parser Test
```bash
dart testing_tools/test_parser.dart
```

## 🏗️ Architecture

### Backend Services
- **`SerialDeviceManager`**: Manages multiple device connections and auto-reconnection
- **`G1LogParser`**: Parses G1 serial data with regex patterns
- **`G1Device`**: Data model for device state

### Frontend Components
- **`DeviceProvider`**: State management with Provider pattern
- **`DeviceCard`**: Rich UI component for each device
- **`HomeScreen`**: Main interface with device list

### Supported Platforms
- **Desktop**: macOS, Windows, Linux (via flutter_libserialport)
- **Mobile**: iOS, Android (with USB OTG support)

## 📊 Data Format

The G1 glasses send various log messages over serial at 115200 baud:

```
box bat: 4250 mV, 90%                           # Case battery
NFC1: [3254900] Get data:01 02 30 63, Rx VRECT: 560mV, Battery Level: 99%  # Glass data
usb:01, lid:01, charge:02                       # Hardware status
NFC IC0:30, NFC IC1:32, Bat:27                 # Temperature readings
RX BatLevel--L:99%, R:2%, bat:2                # Both glasses battery
WLC State: WLC_STATE_STATIC (4)                # NFC charging state
```

## 🔧 Hardware Details

- **G1 Glasses USB-Serial Chip**: CH34x (Vendor ID: 0x1a86)
- **Serial Settings**: 115200 baud, 8N1, no flow control
- **Connection**: USB-C cable to charging case

## 🚧 Known Issues & Limitations

### ALPHA Status Limitations
- **⚠️ Platform Support**: Only thoroughly tested on **macOS Big Sur/Monterey/Ventura**
- **🧪 Windows/Linux**: Experimental support - may have connection issues
- **📱 Mobile**: iOS/Android support implemented but untested
- **🔗 Multi-Device**: Multi-device architecture ready but needs testing with multiple glasses

### Current Issues
- **macOS**: Requires proper entitlements for serial port access (✅ included)
- **Resource Busy**: Ensure no other apps (like `screen`) are using the serial port  
- **Port Detection**: May need manual port specification on some systems
- **Reconnection**: Auto-reconnection logic may be aggressive on some platforms

### Help Us Test!
We need testers on:
- [ ] **Windows 10/11** with G1 glasses
- [ ] **Linux** (Ubuntu, Fedora, etc.) with G1 glasses  
- [ ] **Multiple G1 devices** simultaneously
- [ ] **Different G1 hardware revisions**

Please report your testing results in [GitHub Issues](https://github.com/yourusername/SerialLens/issues)!

## 🗺️ Roadmap

- [ ] Battery level charts and historical data
- [ ] Low battery notifications
- [ ] Data export functionality (CSV, JSON)
- [ ] Multiple device comparison view
- [ ] Charging optimization recommendations
- [ ] Mobile app optimization for USB OTG
- [ ] Real-time charting with fl_chart integration

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Even Realities** for creating the innovative G1 smart glasses
- **Flutter Team** for the excellent cross-platform framework
- **flutter_libserialport** contributors for reliable serial communication
- **Community** for testing and feedback

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/razem-io/SerialLens/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/razem-io/SerialLens/discussions)
- 📧 **Email**: julian@pieles.digital

---

<div align="center">

**Made with ❤️ for the G1 community**

[⭐ Star this repo](https://github.com/razem-io/SerialLens) if you find it useful!

</div>