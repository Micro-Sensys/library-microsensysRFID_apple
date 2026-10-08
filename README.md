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
- `LICENSE.txt` — the license valid for that release

Unzip and drag `microsensysRFID.xcframework` into your Xcode project ("Embed & Sign").

## Documentation

See [`microsensysRFID.md`](../../releases/latest) in the latest release for the full quick-start guide and API reference.  
Two protocol modes are covered there: **SPC** (Script Programmed Communication) and **DOC** (Direct Online Communication) — exactly one is selected at app start.

## Sample App

The `SPC-DOC-SAMPLE/` folder contains an example Xcode project. It does **not**
include `microsensysRFID.xcframework` (see [Installation](#installation)).

1. Download `microsensysRFID.xcframework.zip` from the [Releases](../../releases) page
   (e.g. release *microsensysRFID v1.0.0 (Build 1)*, tag `v1.0.0`) and unzip it.
2. Place it at `SPC-DOC-SAMPLE/microsensysRFID.xcframework`.
3. Open `SPC-DOC-SAMPLE.xcodeproj` in Xcode — the project already references this
   path, so the framework is picked up automatically once it's in place.
4. Build and run on a physical device (BLE is not available in the simulator).

## License

See [`LICENSE.txt`](LICENSE.txt). The license may change between versions — the `LICENSE.txt` attached to each release applies to that release.

## Support

For coding questions or questions about this library, you can use [support@microsensys.de](mailto:support@microsensys.de)  
For general questions about the company or our devices, you can contact us using [info@microsensys.de](mailto:info@microsensys.de)
