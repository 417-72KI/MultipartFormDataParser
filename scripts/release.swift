#!/usr/bin/env swift

import Foundation

do {
    let args = CommandLine.arguments
    guard args.count == 3 else {
        throw "Usage: \(args[0]) <projectName> <tag>"
    }

    let projectName = args[1]
    let tag = args[2]
    let isDebug = sh("git symbolic-ref --short HEAD") != "main"
    if isDebug {
        print("\u{001B}[33m⚠️ Release job is enabled only in main. Run in debug mode\u{001B}[m")
    }

    let rootPath = sh("git rev-parse --show-toplevel")
    FileManager.default.changeCurrentDirectoryPath(rootPath)

    guard let _ = tag.wholeMatch(of: #/^([0-9]+)\.([0-9]+)\.([0-9]+)$/#) else {
        throw "Invalid version format: \(tag)"
    }

    let localChanges = sh("git diff --name-only HEAD")
        .split(separator: "\n")

    let makefile = "Makefile"

    switch localChanges {
    case []: break
    case ["Makefile"]:
        let makefileDiff = sh("git diff -U0 \(makefile)")
            .split(separator: "\n")
            .filter { $0.prefixMatch(of: #/^[+-]((?!(-- a|\+\+ b)))/#) != nil }
            .first { $0.prefixMatch(of: #/^[+-]ver = [0-9]*\.[0-9]*\.[0-9]*$/#) == nil }
        guard makefileDiff == nil else {
            throw "`ver` line is only accepted as a local change."
        }
    default:
        throw "There are some local changes."
    }

    guard sh("git fetch --tags && git tag | grep \"\(tag)\"").isEmpty else {
        throw "Tag `\(tag)` already exists."
    }

    // Update version
    let readmeFile = "README.md"
    try String(decoding: try Data(contentsOf: URL(fileURLWithPath: readmeFile)), as: UTF8.self)
        .replacing(try! Regex(#"(?<prefix>\.package\(url: \".*\#(projectName)\.git\", from: \").*(?<suffix>\"\),?)"#)) { match in
            if let values = match.output.extractValues(as: (Substring, prefix: Substring, suffix: Substring).self) {
                "\(values.prefix)\(tag)\(values.suffix)"
            } else {
                ""
            }
        }
        .write(toFile: readmeFile, atomically: true, encoding: .utf8)

    let packageFile = "Package.swift"
    let packageContent = String(decoding: try Data(contentsOf: URL(fileURLWithPath: packageFile)), as: UTF8.self)
    try packageContent.replacing(#/(let isRelease = )(true|false)/#) { match in
        "\(match.output.1)true"
    }
    .write(toFile: packageFile, atomically: true, encoding: .utf8)

    // Update podspec
    let macOSVersion = packageContent.firstMatch(of: #/macOS\(\.v([0-9]+)\)/#)!.output.1.paddingCommaZero()
    let iOSVersion = packageContent.firstMatch(of: #/iOS\(\.v([0-9]+)\)/#)!.output.1.paddingCommaZero()
    let tvOSVersion = packageContent.firstMatch(of: #/tvOS\(\.v([0-9]+)\)/#)!.output.1.paddingCommaZero()

    let podspecFile = "\(projectName).podspec"
    try String(decoding: try Data(contentsOf: URL(fileURLWithPath: podspecFile)), as: UTF8.self)
        .replacing(#/(spec\.version *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/#) { match in
            "\(match.output.1)\"\(tag)\""
        }
        .replacing(#/(spec\.osx\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/#) { match in
            "\(match.output.1)\"\(macOSVersion)\""
        }
        .replacing(#/(spec\.ios\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/#) { match in
            "\(match.output.1)\"\(iOSVersion)\""
        }
        .replacing(#/(spec\.tvos\.deployment_target *= )\"([0-9]*\.[0-9]*(\.[0-9]*)?)\"/#) { match in
            "\(match.output.1)\"\(tvOSVersion)\""
        }
        .write(toFile: podspecFile, atomically: true, encoding: .utf8)

    // Commit and release
    let commitOption = isDebug ? "--dry-run" : ""
    sh(#"git commit \#(commitOption) -m "Bump version to \#(tag)" \#(readmeFile) \#(packageFile) \#(podspecFile) \#(makefile)"#)

    if isDebug {
        print("\u{001B}[34mDry run mode. Skip pushing and releasing.\u{001B}[m")
    } else {
        sh("git push origin main")
        sh("gh release create \(tag) --target main --title \(tag) --generate-notes")
    }

    // Revert to develop mode
    try packageContent.write(toFile: packageFile, atomically: true, encoding: .utf8)
    sh(#"git commit \#(commitOption) -m 'switch release flag to false' \#(packageFile)"#)
    if !isDebug {
        sh("git push origin main")
    }
} catch {
    print("\u{001B}[31m⛔️ \(error)\u{001B}[m")
    exit(1)
}

// MARK: - functions
@discardableResult
func sh(_ command: String) -> String {
    // print("\u{001B}[34m\(command)\u{001B}[m")
    let task = Process()
    let stdout = Pipe()
    task.launchPath = "/bin/sh"
    task.standardOutput = stdout
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()
    let data = stdout.fileHandleForReading.readDataToEndOfFile()
    return String(decoding: data, as: UTF8.self)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Error
extension String: LocalizedError {
    public var errorDescription: String? { self }
}

// MARK: - Regex
extension StringProtocol {
    func paddingCommaZero() -> String {
        if contains(".") {
            String(self)
        } else {
            "\(self).0"
        }
    }
}
