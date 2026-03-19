#!/usr/bin/env swift
//
// clipboard-unwrap.swift
// Monitors the clipboard and fixes soft-wrapped text when copying from terminal apps.
// Based on https://github.com/HartreeWorks/scripts--clipboard-unwrap-from-terminal

import Cocoa
import Foundation

let terminalBundleIDs: Set<String> = [
    "com.mitchellh.ghostty",
    "dev.warp.Warp-Stable",
    "com.apple.Terminal",
    "com.googlecode.iterm2",
]
let trailingWsThreshold = 3
let paddedLineRatio = 0.5

let dryRun = CommandLine.arguments.contains("--dry-run")
let verbose = CommandLine.arguments.contains("--verbose")

extension String {
    func trimmingLeadingWhitespace() -> String {
        var idx = startIndex
        while idx < endIndex && (self[idx] == " " || self[idx] == "\t") {
            idx = index(after: idx)
        }
        return String(self[idx...])
    }

    func trimmingTrailingWhitespace() -> String {
        var end = endIndex
        while end > startIndex {
            let prev = index(before: end)
            if self[prev] == " " || self[prev] == "\t" {
                end = prev
            } else {
                break
            }
        }
        return String(self[..<end])
    }

    var trailingWhitespaceCount: Int {
        var count = 0
        var idx = endIndex
        while idx > startIndex {
            let prev = index(before: idx)
            if self[prev] == " " || self[prev] == "\t" {
                count += 1
                idx = prev
            } else {
                break
            }
        }
        return count
    }
}

func fixSoftWrap(_ text: String) -> String? {
    let lines = text.components(separatedBy: "\n")
    let nonBlankLines = lines.filter { !$0.trimmingTrailingWhitespace().isEmpty }
    guard nonBlankLines.count >= 2 else { return nil }

    let lengths = nonBlankLines.map { $0.count }
    let lengthCounts = Dictionary(lengths.map { ($0, 1) }, uniquingKeysWith: +)
    let (paneWidth, modeCount) = lengthCounts.max(by: { $0.value < $1.value })!
    let uniformRatio = Double(modeCount) / Double(nonBlankLines.count)
    guard uniformRatio >= paddedLineRatio else { return nil }

    let linesAtPaneWidth = nonBlankLines.filter { $0.count == paneWidth }
    let hasPaddedLine = linesAtPaneWidth.contains {
        $0.trailingWhitespaceCount >= trailingWsThreshold
    }
    guard hasPaddedLine else { return nil }

    let stripped = lines.map { $0.trimmingTrailingWhitespace() }
    let nonBlankStripped = stripped.filter { !$0.trimmingLeadingWhitespace().isEmpty }

    let gaps = nonBlankStripped.map { paneWidth - $0.count }
    let sortedGaps = gaps.sorted()

    let minGapJump = 5
    var gapThreshold: Int? = nil
    for i in 0..<(sortedGaps.count - 1) {
        let jump = sortedGaps[i + 1] - sortedGaps[i]
        if jump >= minGapJump {
            gapThreshold = (sortedGaps[i] + sortedGaps[i + 1]) / 2
            break
        }
    }

    if let threshold = gapThreshold {
        return rejoinByGapThreshold(stripped, paneWidth: paneWidth,
                                    gapThreshold: threshold, originalText: text)
    }

    guard linesAtPaneWidth.allSatisfy({ $0.trailingWhitespaceCount >= trailingWsThreshold }) else {
        return nil
    }
    return rejoinAsParagraphs(stripped, originalText: text)
}

func rejoinByGapThreshold(_ stripped: [String], paneWidth: Int,
                          gapThreshold: Int, originalText: String) -> String? {
    var result: [String] = []
    var current = ""
    var lastBlank = false

    for line in stripped {
        let content = line.trimmingLeadingWhitespace()
        if content.isEmpty {
            if !current.isEmpty { result.append(current); current = "" }
            if !lastBlank && !result.isEmpty { result.append("") }
            lastBlank = true
            continue
        }
        lastBlank = false
        current = current.isEmpty ? content : current + content
        let gap = paneWidth - line.count
        if gap > gapThreshold {
            result.append(current)
            current = ""
        }
    }
    if !current.isEmpty { result.append(current) }
    while result.last?.isEmpty == true { result.removeLast() }

    let output = result.joined(separator: "\n")
    return output == originalText ? nil : output
}

func rejoinAsParagraphs(_ stripped: [String], originalText: String) -> String? {
    var paragraphs: [[String]] = [[]]
    var lastWasBlank = false

    for line in stripped {
        if line.trimmingLeadingWhitespace().isEmpty {
            if !lastWasBlank && !paragraphs[paragraphs.count - 1].isEmpty {
                paragraphs.append([])
            }
            lastWasBlank = true
        } else {
            paragraphs[paragraphs.count - 1].append(line.trimmingLeadingWhitespace())
            lastWasBlank = false
        }
    }

    let output = paragraphs
        .filter { !$0.isEmpty }
        .map { $0.joined(separator: " ") }
        .joined(separator: "\n\n")
    return output == originalText ? nil : output
}

func fixBrokenURLs(_ text: String) -> String? {
    let lines = text.components(separatedBy: "\n")
    guard lines.count >= 2 else { return nil }

    var result: [String] = []
    var i = 0
    var changed = false

    while i < lines.count {
        var line = lines[i]

        // If this line ends with something that looks like a broken URL/path
        // and the next line looks like a continuation (starts with whitespace
        // or continues a URL pattern), join them
        while i + 1 < lines.count {
            let next = lines[i + 1]
            let trimmedNext = next.trimmingLeadingWhitespace()

            // Next line is a continuation if it starts with whitespace and
            // the joined result looks like it was one token/URL
            let looksLikeContinuation =
                !trimmedNext.isEmpty &&
                next != trimmedNext &&  // had leading whitespace
                !line.trimmingTrailingWhitespace().isEmpty

            // Check if joining would form a URL or the current line ends mid-URL
            let stripped = line.trimmingTrailingWhitespace()
            let endsInURL = stripped.contains("://") || stripped.hasSuffix("/")
            let nextContinuesURL = trimmedNext.hasPrefix("/") ||
                trimmedNext.hasPrefix("?") ||
                trimmedNext.hasPrefix("#") ||
                trimmedNext.hasPrefix("&")
            let midToken = !stripped.hasSuffix(" ") && !stripped.hasSuffix("\t")

            if looksLikeContinuation && (endsInURL || nextContinuesURL || midToken) {
                line = stripped + trimmedNext
                changed = true
                i += 1
            } else {
                break
            }
        }
        result.append(line)
        i += 1
    }

    return changed ? result.joined(separator: "\n") : nil
}

func log(_ msg: String) {
    if verbose {
        let ts = ISO8601DateFormatter().string(from: Date())
        FileHandle.standardError.write(Data("[\(ts)] \(msg)\n".utf8))
    }
}

let pasteboard = NSPasteboard.general
var lastChangeCount = pasteboard.changeCount

log("clipboard-unwrap started (dry-run: \(dryRun))")

let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
    let currentCount = pasteboard.changeCount
    guard currentCount != lastChangeCount else { return }
    lastChangeCount = currentCount

    guard let frontApp = NSWorkspace.shared.frontmostApplication,
          let bundleID = frontApp.bundleIdentifier,
          terminalBundleIDs.contains(bundleID) else {
        return
    }

    guard let text = pasteboard.string(forType: .string) else { return }
    let fixed = fixBrokenURLs(text) ?? fixSoftWrap(text) ?? text

    if fixed != text {
        log("Fixed clipboard content (\(text.count) → \(fixed.count) chars)")
        if dryRun {
            FileHandle.standardError.write(Data("--- ORIGINAL ---\n\(text)\n--- FIXED ---\n\(fixed)\n---\n".utf8))
        } else {
            pasteboard.clearContents()
            pasteboard.setString(fixed, forType: .string)
            lastChangeCount = pasteboard.changeCount
        }
    }
}

RunLoop.current.add(timer, forMode: .default)
RunLoop.current.run()
