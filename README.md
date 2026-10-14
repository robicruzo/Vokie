# Vokie

A tiny macOS menu bar app for building a vocabulary list.

1. Click the book icon in the menu bar.
2. Paste a word and press **Return**. Vokie looks it up in the built-in macOS Dictionary (offline) and adds the word and its definition to your list.
3. Click **Export CSV…** to save the list as a `vocabulary,definition` CSV.

Hover a word to remove it. The **⋯** menu has *Clear All Words* and *Quit*. Duplicate words (case-insensitive) are skipped.

## Build

Open `Vokie.xcodeproj` in Xcode and run, or from the command line:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project Vokie.xcodeproj -scheme Vokie build
```

Vokie runs as a menu bar–only app (`LSUIElement`), so it has no Dock icon.

## Data

The list is saved as JSON in the app's sandbox container:
`~/Library/Containers/github.com-robicruzo.Vokie/Data/Library/Application Support/Vokie/vocabulary.json`
