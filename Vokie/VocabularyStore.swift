//
//  VocabularyStore.swift
//  Vokie
//

import Foundation
import Observation

struct VocabularyEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    var word: String
    var definition: String
    var dateAdded = Date()
}

@Observable
final class VocabularyStore {
    enum AddResult {
        case added(VocabularyEntry)
        case duplicate
        case notFound
        case empty
    }

    private(set) var entries: [VocabularyEntry] = []

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Vokie", isDirectory: true)
            try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
            self.fileURL = support.appendingPathComponent("vocabulary.json")
        }
        load()
    }

    func add(_ input: String) -> AddResult {
        let word = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return .empty }
        if entries.contains(where: { $0.word.caseInsensitiveCompare(word) == .orderedSame }) {
            return .duplicate
        }
        guard let definition = DictionaryLookup.define(word) else { return .notFound }
        let entry = VocabularyEntry(word: word, definition: definition)
        entries.append(entry)
        save()
        return .added(entry)
    }

    func remove(_ entry: VocabularyEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func removeAll() {
        entries.removeAll()
        save()
    }

    var csv: String {
        var lines = ["vocabulary,definition"]
        for entry in entries {
            lines.append("\(Self.csvField(entry.word)),\(Self.csvField(entry.definition))")
        }
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    private static func csvField(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        entries = (try? JSONDecoder().decode([VocabularyEntry].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
