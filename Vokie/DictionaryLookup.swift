//
//  DictionaryLookup.swift
//  Vokie
//

import CoreServices
import Foundation

/// Looks words up in the built-in macOS Dictionary (offline, no network needed).
enum DictionaryLookup {
    static func define(_ word: String) -> String? {
        let range = CFRange(location: 0, length: word.utf16.count)
        guard let raw = DCSCopyTextDefinition(nil, word as NSString, range)?.takeRetainedValue() else {
            return nil
        }
        return clean(raw as String)
    }

    /// Dictionary Services returns e.g. "ephemeral e·phem·er·al | əˈfem(ə)rəl | adjective lasting…  ORIGIN …".
    /// Drop the headword/pronunciation prefix and the etymology tail so only the definition remains.
    static func clean(_ text: String) -> String {
        var result = text
        let pipes = result.indices.filter { result[$0] == "|" }
        if pipes.count >= 2 {
            result = String(result[result.index(after: pipes[1])...])
        }
        let tailMarkers = [" PHRASES ", " PHRASAL VERBS ", " DERIVATIVES ", " ORIGIN "]
        if let cut = tailMarkers.compactMap({ result.range(of: $0)?.lowerBound }).min() {
            result = String(result[..<cut])
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
