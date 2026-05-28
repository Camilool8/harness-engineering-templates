---
name: foundation-models-app-intent
description: Wire Apple Foundation Models to an App Intent — typed guided generation, tool calls, streaming. Includes the device-gating fallback pattern.
---

# Foundation Models in an App Intent

## When to use

- On-device summarization / extraction / classification / rewriting for an App Intent surface (Siri, Shortcuts, Spotlight, Widgets).
- NOT for: world knowledge, advanced reasoning, multi-turn chat — push those to a hosted LLM with explicit 5.1.2(i) consent.

## Pattern

```swift
import FoundationModels
import AppIntents

@available(iOS 18.0, *)
struct SummarizeNotesIntent: AppIntent {
    static let title: LocalizedStringResource = "Summarize Notes"

    @Parameter(title: "Notes")
    var notes: [String]

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard SystemLanguageModel.default.isAvailable else {
            // Apple Intelligence not available on this device — fall back.
            return .result(dialog: "Summaries are not available on this device.")
        }
        let session = LanguageModelSession()
        let summary = try await session.respond(to: "Summarize these notes: \(notes.joined(separator: "\n"))")
        return .result(dialog: "\(summary.content)")
    }
}
```

## Device gating

`SystemLanguageModel.default.isAvailable` is the canonical check. Always ship the non-Apple-Intelligence path.

## Guarded outputs

Use `LanguageModelSession.respond(to:generating:)` with a `@Generable` Swift type for structured output. Validate at the boundary; do not pass raw model output to a privileged sink.
