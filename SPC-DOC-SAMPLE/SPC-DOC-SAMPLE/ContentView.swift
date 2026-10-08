//
//  ContentView.swift
//  SPC-DOC-SAMPLE
//
//  Created by Michel Rennert on 08.10.26.
//

import SwiftUI
import microsensysRFID

/// Entry point of the sample: pick a protocol mode once, then enter the matching
/// demo screen. The mode is fixed for the app's lifetime - configure(_:) may only
/// be called again with the *same* mode; a different mode triggers a fatalError.
struct ContentView: View {
    private enum Mode: Hashable {
        case spc, doc
    }

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Button("SPC Mode") {
                    MicrosensysRFID.configure(.spc)
                    path.append(Mode.spc)
                }
                Button("DOC Mode") {
                    MicrosensysRFID.configure(.doc)
                    path.append(Mode.doc)
                }
            }
            .navigationTitle("microsensysRFID Sample")
            .navigationDestination(for: Mode.self) { mode in
                switch mode {
                case .spc: SPCView()
                case .doc: DOCView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
