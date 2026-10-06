# microsensysRFID

Swift framework for BLE communication with microsensys RFID readers for iOS, iPadOS, macOS and Mac Catalyst.

Supports iID®PENsolid basic, iID®PENsolid PRO, iID®POCKETwork PRO, and iID®wearable readers.

## Requirements

| Requirement | Value |
|---|---|
| Platform | iOS/iPadOS 17.6+ (arm64) / macOS 14.6+ (Apple Silicon & Intel) |
| Mac Catalyst | Supported (Apple Silicon & Intel) |
| Language | Swift 5.0+ |
| Dependency | CoreBluetooth |
| Permission | `NSBluetoothAlwaysUsageDescription` in `Info.plist` |

## Installation

Download the latest release from the [Releases](../../releases) page. Each release contains:

- `microsensysRFID.xcframework.zip` — the framework binary
- `microsensysRFID.md` — full documentation (quick start, API reference)

Unzip and drag `microsensysRFID.xcframework` into your Xcode project ("Embed & Sign").

## Documentation

See [`microsensysRFID.md`](../../releases/latest) in the latest release for the full quick-start guide and API reference. Two protocol modes are covered there: **SPC** (Script Programmed Communication) and **DOC** (Direct Online Communication) — exactly one is selected at app start.

## License

See [`LICENSE.txt`](LICENSE.txt).

## Support

For coding questions or questions about this library, you can use [support@microsensys.de](mailto:support@microsensys.de)
For general questions about the company or our devices, you can contact us using [info@microsensys.de](mailto:info@microsensys.de)
