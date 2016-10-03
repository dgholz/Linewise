# Linewise
Swift protocol to add lines() to InputStreams. Line terminators get stripped.

# How to use

    # Package.swift
    dependencies: [
        .Package(url: "https://github.com/dgholz/Linewise.git", majorVersion: 0),
    ]


    # main.swift
    import Foundation
    import Linewise

    for arg in CommandLine.arguments.dropFirst() {
        if let r = InputStream(fileAtPath: arg) {
            for line in r.lines() {
                print("\(arg): \(line)")
            }
        }
    }