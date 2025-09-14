//
//  RPGFINISHApp.swift
//  RPGFINISH
//
//  Created by Marriatii on 7/7/25.
//

import SwiftUI

@main
struct RPGFINISHApp: App {
    @StateObject private var gameState = GameState()
    
    init() {
        print("🚀 RPGFINISH App starting...")
        print("🔍 DEBUG: Testing bundle loading in app init...")
        let testURL = Bundle.main.url(forResource: "SignullSchema", withExtension: "json")
        print("🔍 DEBUG: Bundle.main.url result: \(testURL?.absoluteString ?? "nil")")
        
        if let url = testURL {
            print("🔍 DEBUG: File exists at: \(url)")
            if let data = try? Data(contentsOf: url) {
                print("🔍 DEBUG: File size: \(data.count) bytes")
            } else {
                print("🔍 DEBUG: Failed to read data from file")
            }
        } else {
            print("🔍 DEBUG: File not found in bundle")
        }
        
        // Dump bundle inventory to disk for hard evidence
        dumpBundleInventory()
    }
    
    private func dumpBundleInventory() {
        let fm = FileManager.default
        let root = Bundle.main.bundleURL
        let docs = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let out = docs.appendingPathComponent("bundle_inventory.txt")

        var lines: [String] = []
        lines.append("BUNDLE: \(root.path)")
        if let resURL = Bundle.main.resourceURL { lines.append("resourceURL: \(resURL.path)") }

        if let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil) {
            for case let url as URL in enumerator {
                if url.lastPathComponent.lowercased().contains("signullschema") || url.pathExtension == "json" {
                    lines.append("FOUND: \(url.path)")
                }
            }
        }

        // Try all lookup variants:
        let candidates: [(String,String?,String?)] = [
            ("SignullSchema","json",nil),
            ("signullschema","json",nil),
            ("SignullSchema","json",""), // subdir root
        ]
        for (name, ext, sub) in candidates {
            let u = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub)
            lines.append("lookup \(name).\(ext ?? "") sub=\(sub ?? "nil") -> \(u?.path ?? "nil")")
        }

        try? (lines.joined(separator: "\n")).write(to: out, atomically: true, encoding: .utf8)
        print("📁 Bundle inventory dumped to: \(out.path)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
        }
    }
}
