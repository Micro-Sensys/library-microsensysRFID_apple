//
//  SPCView.swift
//  SPC-DOC-SAMPLE
//

import SwiftUI
import microsensysRFID

/// Demonstrates SPC mode: sending script commands and receiving heartbeat / raw data.
struct SPCView: View {
    private let rfid = MicrosensysRFID.SpcInterfaceControl

    @State private var useProtocol = false
    @State private var writeDataHex = "0011223344556677"
    @State private var log: [String] = []

    var body: some View {
        Form {
            BLEScanView(control: rfid)

            Section("SPC Settings") {
                // Must be set before connecting - cannot change on an active connection.
                Toggle("Use v4/CRC-16 Protocol Frame", isOn: $useProtocol)
                    .onChange(of: useProtocol) { _, newValue in
                        rfid.useProtocol = newValue
                    }
            }

            Section("Commands") {
                Button("Send ~T (Trigger Read)") {
                    rfid.sendRequest("T")
                }

                // Data for ~W must be ASCII hex text, not raw bytes.
                TextField("Hex data", text: $writeDataHex)
                Button("Send ~W (Write)") {
                    rfid.sendRequest("W" + writeDataHex)
                }
            }

            Section("Received Data") {
                if log.isEmpty {
                    Text("No data yet").foregroundStyle(.secondary)
                }
                ForEach(log.indices.reversed(), id: \.self) { index in
                    Text(log[index]).font(.system(.footnote, design: .monospaced))
                }
            }
        }
        .navigationTitle("SPC Mode")
        .onAppear {
            // Register before connecting so no early heartbeat/data packet is missed.
            rfid.onHeartbeatCallback { hb in
                log.append("Heartbeat: serial=\(hb.serialNumber) battery=\(hb.batteryLevel)")
            }
            rfid.onRawCallback { bytes, text in
                let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
                log.append("Data: \(text) (\(hex))")
            }
        }
    }
}
