//
//  BLEScanView.swift
//  SPC-DOC-SAMPLE
//

import SwiftUI
import microsensysRFID

/// Reusable scan/connect/battery panel shared by the SPC and DOC sample pages.
/// Works with any `RFIDInterfaceControl` (SPC or DOC), since scanning, connecting
/// and battery level are part of the shared protocol.
struct BLEScanView: View {
    let control: any RFIDInterfaceControl

    @State private var devices: [RFIDDevice] = []
    @State private var isScanning = false
    @State private var connectedName: String?
    @State private var statusText = "Not connected"
    @State private var batteryLevel: Int?

    var body: some View {
        Section("Bluetooth") {
            Text(statusText)
                .foregroundStyle(.secondary)

            if let batteryLevel {
                Text("Battery: \(batteryLevel) %")
            }

            Button(isScanning ? "Scanning…" : "Scan for Devices") {
                scan()
            }
            .disabled(isScanning || connectedName != nil)

            ForEach(devices, id: \.name) { device in
                Button {
                    connect(to: device.name)
                } label: {
                    HStack {
                        Text(device.name)
                        Spacer()
                        Text("\(device.rssi) dBm").foregroundStyle(.secondary)
                    }
                }
                .disabled(connectedName != nil)
            }

            if connectedName != nil {
                Button("Disconnect", role: .destructive) {
                    control.disconnect()
                }
            }
        }
        .onAppear {
            // Register before connecting so no early notification is missed.
            control.onBatteryLevel { percent in
                batteryLevel = percent
            }
        }
    }

    private func scan() {
        // Scans for up to 30 s and only reports recognized iID device names.
        devices = []
        isScanning = true
        control.search { device in
            devices.append(device)
        } onFinished: { all in
            devices = all
            isScanning = false
        } onError: { error in
            statusText = error.localizedDescription
            isScanning = false
        }
    }

    private func connect(to name: String) {
        // Only one connection is supported at a time; the framework would disconnect
        // any previous peripheral automatically. Bounded by a 10 s timeout.
        statusText = "Connecting…"
        control.connect(name: name) { result in
            switch result {
            case .connected:
                connectedName = name
                statusText = "Connected to \(name)"
                control.readBatteryLevel()
            case .timeout:
                statusText = "Connection timed out"
            case .failed(let error):
                statusText = "Connection failed: \(error?.localizedDescription ?? "unknown")"
            @unknown default:
                statusText = "Unknown connection result"
            }
        } onDisconnect: {
            connectedName = nil
            batteryLevel = nil
            statusText = "Disconnected"
        }
    }
}
