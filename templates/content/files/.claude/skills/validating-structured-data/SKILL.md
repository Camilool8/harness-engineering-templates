---
name: validating-structured-data
description: Validate schema.org JSON-LD structured data — use after adding or editing structured data on any page, before it ships.
---

# Validating structured data

AI Overviews, Perplexity, and ChatGPT search decide what to cite partly from a
page's structured data. Malformed or missing JSON-LD costs citations and rich
results. Validate every change.

## Steps

1. **Locate the JSON-LD.** It lives in a `<script type="application/ld+json">`
   block. There may be more than one — check all.
2. **Check it is valid JSON.** A trailing comma or unescaped quote silently
   kills the whole block. Parse it (`jq .` on the extracted text) first.
3. **Check the schema type.** `@context` must be `https://schema.org`. The
   `@type` must match the page (`Article`, `Product`, `FAQPage`, `Recipe`,
   `Organization`, `BreadcrumbList`, ...).
4. **Check required and recommended properties** for that type — e.g.
   `Article` needs `headline`, `author`, `datePublished`; `Product` needs
   `name`, `offers`; `FAQPage` needs `mainEntity` Q&A pairs.
5. **Validate against Google Rich Results.** Run the markup through Google's
   Rich Results Test and the schema.org validator. Resolve every error; review
   every warning.
6. **Check it matches the visible page.** Structured data must describe what a
   user actually sees — mismatches are a spam signal and get penalized.

## Rule

Do not ship a page with structured data that has not passed the Rich Results
Test clean. A green parse is necessary but not sufficient — the validator is.
