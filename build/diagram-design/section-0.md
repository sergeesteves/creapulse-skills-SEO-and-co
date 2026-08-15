## 0. Style guide — already branded, gate closed

**This build ships a customized style guide. The first-run onboarding gate does not apply — never pause to ask about branding.**

[`references/style-guide.md`](references/style-guide.md) carries the **Creapulse** skin: light-grey paper `#f5f5f5`, dark-grey ink `#2e2e2e`, creapulse-pink accent `#f83595`, creapulse-blue link `#0284c7`. These are the active tokens. Read that file for the full table and treat it as the single source of truth.

This build runs **non-interactively** (API / automation context). There is no user to answer questions. Therefore:

- Never ask which brand, palette, or profile to use.
- Never run the URL-onboarding flow in [`references/onboarding.md`](references/onboarding.md) — the execution container has no network access, so it cannot fetch a site.
- Never offer to save a client profile.
- Ignore any `.diagram-design` marker lookup; there is no project root.

Go straight to §1 and generate the diagram with the tokens above.
