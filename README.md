# SerialLens - Even Realities G1 Glasses Monitor

<div align="center">

![SerialLens Logo](https://img.shields.io/badge/SerialLens-G1%20Monitor-blue?style=for-the-badge&logo=flutter)

A cross-platform Flutter application for monitoring multiple Even Realities G1 smart AR glasses via serial interface.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

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
   # macOS
   flutter run -d macos
   
   # Windows
   flutter run -d windows
   
   # Linux
   flutter run -d linux
   ```

## 🐛 Troubleshooting

### Device Not Detected

<details>
<summary>Click to expand troubleshooting steps</summary>

1. **Check USB Connection**:
   ```bash
   # macOS
   ls -la /dev/*usbserial*
   
   # Linux
   ls -la /dev/ttyUSB* /dev/ttyACM*
   
   # Windows
   mode
   ```

2. **Test Manual Connection**:
   ```bash
   # macOS/Linux
   screen /dev/tty.usbserial-110 115200
   # Exit with Ctrl+A, then K
   ```

3. **Check Permissions** (macOS/Linux):
   ```bash
   # Add user to dialout group (Linux)
   sudo usermod -a -G dialout $USER
   
   # Check current permissions
   ls -la /dev/tty.usbserial-*
   ```

4. **Install Drivers** (if needed):
   - **CH34x Driver**: For G1 glasses USB-serial chip
   - **FTDI Driver**: Alternative USB-serial chips

</details>

### App Permissions (macOS)

If you get "Operation not permitted" errors, the app includes the necessary entitlements for serial port access. If issues persist:

1. Grant terminal/app access in **System Preferences > Security & Privacy > Privacy > Developer Tools**
2. Try running with elevated permissions (testing only):
   ```bash
   sudo flutter run -d macos
   ```

### No Data Received

1. **Check if glasses are active**: G1 glasses may not send data when idle
2. **Try interacting with glasses**: Open/close case, put glasses on/off charging
3. **Verify baud rate**: Should be 115200 (default)
4. **Check cable**: Try different USB-C cable

## 🧪 Testing Tools

SerialLens includes comprehensive testing tools for debugging connection issues:

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

## 🚧 Known Issues

- **macOS**: Requires proper entitlements for serial port access (included)
- **Resource Busy**: Ensure no other apps (like `screen`) are using the serial port
- **Multiple Devices**: Currently optimized for single device, multi-device support is implemented but may need refinement

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

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/yourusername/SerialLens/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/SerialLens/discussions)
- 📧 **Email**: support@seriallens.dev

---

<div align="center">

**Made with ❤️ for the G1 community**

[⭐ Star this repo](https://github.com/yourusername/SerialLens) if you find it useful!

</div>