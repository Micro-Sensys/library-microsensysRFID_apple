//
//  DOCView.swift
//  SPC-DOC-SAMPLE
//

import SwiftUI
import microsensysRFID

/// Demonstrates DOC mode for both HF and UHF readers.
/// `identify()` dispatches to the right ISO command (15693/14443A for HF,
/// 18000-6C/EPC for UHF) internally, so the same button works for both.
struct DOCView: View {
    /// HF tags can be ISO 15693 or ISO 14443A - the read/write commands differ per type.
    private enum HFTagType: Hashable {
        case iso15693, iso14443A
    }

    @State private var readerType: DocReaderType = .hf
    @State private var hfTagType: HFTagType = .iso15693
    @State private var memoryBank: MemoryBank = .user

    @State private var lastTag: [UInt8] = []
    @State private var blockOrOffset = "4"
    @State private var byteCount = "8"
    @State private var writeDataHex = "01020304"

    @State private var log: [String] = []
    @State private var isBusy = false

    private var rfid: DocInterfaceControl {
        MicrosensysRFID.DocInterfaceControl(readerType)
    }

    var body: some View {
        Form {
            Section("Reader Type") {
                Picker("Type", selection: $readerType) {
                    Text("HF").tag(DocReaderType.hf)
                    Text("UHF").tag(DocReaderType.uhf)
                }
                .pickerStyle(.segmented)
            }

            // Switching reader type disconnects the previous peripheral, so reset
            // the scan panel's state by giving it a fresh identity.
            BLEScanView(control: rfid)
                .id(readerType)

            Section("Identify") {
                Button("Identify Tag") { identify() }
                    .disabled(isBusy)
                Button("Read Reader Info") { readReaderInfo() }
                    .disabled(isBusy)
                if !lastTag.isEmpty {
                    // UID (HF) or EPC (UHF) bytes from identify() - required by every read/write call below.
                    Text("Current tag: \(hex(lastTag))")
                        .font(.system(.footnote, design: .monospaced))
                }
            }

            Section("Read / Write") {
                if readerType == .hf {
                    Picker("HF Tag Type", selection: $hfTagType) {
                        Text("ISO 15693").tag(HFTagType.iso15693)
                        Text("ISO 14443A").tag(HFTagType.iso14443A)
                    }
                    // ISO 14443A blocks 0-3 hold manufacturer data/lock bits; writing there
                    // can permanently alter or lock the tag. Keep Block >= 4 unless that's intended.
                } else {
                    Picker("Memory Bank", selection: $memoryBank) {
                        Text("EPC").tag(MemoryBank.epc)
                        Text("TID").tag(MemoryBank.tid)
                        Text("User").tag(MemoryBank.user)
                    }
                    // Only EPC and User are writable on standard tags; writing TID typically errors.
                }

                LabeledContent("Block / Offset") {
                    TextField("Block / Offset", text: $blockOrOffset)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Bytes to Read") {
                    TextField("Bytes to Read", text: $byteCount)
                        .multilineTextAlignment(.trailing)
                }
                Button("Read Bytes") { readBytes() }
                    .disabled(isBusy || lastTag.isEmpty)

                TextField("Hex data to write", text: $writeDataHex)
                Button("Write Bytes") { writeBytes() }
                    .disabled(isBusy || lastTag.isEmpty)
            }

            Section("Log") {
                if log.isEmpty {
                    Text("No data yet").foregroundStyle(.secondary)
                }
                ForEach(log.indices.reversed(), id: \.self) { index in
                    Text(log[index]).font(.system(.footnote, design: .monospaced))
                }
            }
        }
        .navigationTitle("DOC Mode")
    }

    private func readReaderInfo() {
        let control = rfid
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                let info = try await control.readReaderID()
                log.append("ReaderID: \(info.readerID), HW: \(info.hwInfo), FW: \(info.fwInfo)")
            } catch {
                log.append(errorDescription(error))
            }
        }
    }

    private func identify() {
        let control = rfid
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                let tags = try await control.identify()
                lastTag = tags.first ?? []
                if tags.isEmpty {
                    log.append("No transponder in field")
                } else {
                    for tag in tags {
                        log.append("Tag: \(hex(tag))")
                    }
                }
            } catch {
                log.append(errorDescription(error))
            }
        }
    }

    private func readBytes() {
        guard let block = UInt8(blockOrOffset), let count = UInt8(byteCount) else {
            log.append("Invalid block/offset or byte count")
            return
        }
        let control = rfid
        let tag = lastTag
        let type = hfTagType
        let bank = memoryBank
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                let data: [UInt8]
                switch readerType {
                case .hf:
                    switch type {
                    case .iso15693:
                        data = try await control.iso15693_Read_Bytes(uid: tag, blockNumber: block, numberOfBytes: count)
                    case .iso14443A:
                        data = try await control.iso14443A_Read_Bytes(uid: tag, blockNumber: block, numberOfBytes: count)
                    }
                case .uhf:
                    data = try await control.iso180006C_Read_Bytes(epc: tag, memoryBank: bank, from: UInt32(block), numberOfBytes: count)
                @unknown default:
                    data = []
                }
                log.append(data.isEmpty ? "No tag present" : "Read: \(hex(data))")
            } catch {
                log.append(errorDescription(error))
            }
        }
    }

    private func writeBytes() {
        guard let block = UInt8(blockOrOffset) else {
            log.append("Invalid block/offset")
            return
        }
        let control = rfid
        let tag = lastTag
        let type = hfTagType
        let bank = memoryBank
        let data = hexStringToBytes(writeDataHex)
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                let success: Bool
                switch readerType {
                case .hf:
                    switch type {
                    case .iso15693:
                        success = try await control.iso15693_Write_Bytes(uid: tag, blockNumber: block, data: data)
                    case .iso14443A:
                        success = try await control.iso14443A_Write_Bytes(uid: tag, blockNumber: block, data: data)
                    }
                case .uhf:
                    success = try await control.iso180006C_Write_Bytes(epc: tag, memoryBank: bank, from: UInt32(block), bytes: data)
                @unknown default:
                    success = false
                }
                log.append(success ? "Write OK" : "Write failed: no tag present")
            } catch {
                log.append(errorDescription(error))
            }
        }
    }

    private func errorDescription(_ error: Error) -> String {
        if case let MssError.error(code) = error {
            return "Error: \(hex(code))"
        }
        return "Error: \(error.localizedDescription)"
    }

    private func hex(_ bytes: [UInt8]) -> String {
        bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private func hexStringToBytes(_ hexString: String) -> [UInt8] {
        var bytes: [UInt8] = []
        var remainder = Substring(hexString)
        while remainder.count >= 2 {
            let pairEnd = remainder.index(remainder.startIndex, offsetBy: 2)
            if let byte = UInt8(remainder[..<pairEnd], radix: 16) {
                bytes.append(byte)
            }
            remainder = remainder[pairEnd...]
        }
        return bytes
    }
}
