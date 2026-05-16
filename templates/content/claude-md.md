## Content / marketing / SEO rules

**Brand voice is encoded, not implied.** The voice is defined by explicit
forbidden phrases in `.claude/banned-phrases.txt` plus the required tone
markers in the brand brief. The `brand-voice-guard` hook flags banned clichés
in edited content. Treat a flagged phrase as a defect to rewrite, not a
suggestion to weigh.

**Do not chase AI-detector evasion.** "Make it not sound AI-written" is an
unwinnable arms race — independent 2026 testing put detector accuracy in the
60-76% range, so the base-rate problem makes it pointless. Spend that effort on
what actually matters: brand voice, factual accuracy, and originality of
argument. Never reword text just to fool a detector.

**Structured data must validate.** schema.org JSON-LD is how AI Overviews,
Perplexity, and ChatGPT search decide what to cite. After any structured-data
change, validate it against Google Rich Results — see the
`validating-structured-data` skill. Do not ship unvalidated markup.

**The brief is the spec.** Audience, angle, target keywords, and structure come
from the content brief. Write to it; flag drift instead of quietly diverging.

**Content quality is graded.** Drafts are checked against the brand-voice
golden eval set so "on brand" is measured, not asserted.
