//
//  MenuBarView.swift
//  Vokie
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MenuBarView: View {
    let store: VocabularyStore

    @State private var input = ""
    @State private var status: Status?
    @FocusState private var inputFocused: Bool

    private struct Status {
        var message: String
        var isError: Bool
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Paste a word and press Return", text: $input)
                .textFieldStyle(.roundedBorder)
                .focused($inputFocused)
                .onSubmit(addWord)

            if let status {
                Text(status.message)
                    .font(.caption)
                    .foregroundStyle(status.isError ? Color.red : Color.secondary)
                    .lineLimit(3)
            }

            Divider()

            if store.entries.isEmpty {
                Text("No words yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(store.entries.reversed()) { entry in
                            EntryRow(entry: entry) { store.remove(entry) }
                        }
                    }
                }
                .frame(maxHeight: 260)
            }

            Divider()

            HStack {
                Text("\(store.entries.count) word\(store.entries.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Export CSV…", action: exportCSV)
                    .disabled(store.entries.isEmpty)
                Menu {
                    Button("Clear All Words", role: .destructive, action: confirmClear)
                        .disabled(store.entries.isEmpty)
                    Divider()
                    Button("Quit Vokie") { NSApp.terminate(nil) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
        }
        .padding(12)
        .frame(width: 340)
        .onAppear { inputFocused = true }
    }

    private func addWord() {
        let word = input.trimmingCharacters(in: .whitespacesAndNewlines)
        switch store.add(word) {
        case .added(let entry):
            status = Status(message: "Added “\(entry.word)”.", isError: false)
            input = ""
        case .duplicate:
            status = Status(message: "“\(word)” is already in your list.", isError: true)
        case .notFound:
            status = Status(message: "No dictionary entry for “\(word)”.", isError: true)
        case .empty:
            status = nil
        }
    }

    private func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "vocabulary.csv"
        panel.canCreateDirectories = true
        NSApp.activate()
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.csv.write(to: url, atomically: true, encoding: .utf8)
            status = Status(message: "Exported \(store.entries.count) words to \(url.lastPathComponent).", isError: false)
        } catch {
            status = Status(message: "Export failed: \(error.localizedDescription)", isError: true)
        }
    }

    private func confirmClear() {
        let alert = NSAlert()
        alert.messageText = "Clear all \(store.entries.count) words?"
        alert.informativeText = "This can't be undone. Export a CSV first if you want to keep them."
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].hasDestructiveAction = true
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            store.removeAll()
            status = nil
        }
    }
}

private struct EntryRow: View {
    let entry: VocabularyEntry
    let onDelete: () -> Void

    @State private var hovering = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.word).font(.headline)
                Text(entry.definition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .help(entry.definition)
            }
            Spacer(minLength: 4)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .opacity(hovering ? 1 : 0)
            .help("Remove")
        }
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }
}
