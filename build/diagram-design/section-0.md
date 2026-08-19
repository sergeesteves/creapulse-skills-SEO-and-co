## 0. Style guide — already branded, gate closed

**This build ships a customized style guide. The first-run onboarding gate does not apply — never pause to ask about branding.**

[`references/style-guide.md`](references/style-guide.md) carries the **Creapulse** skin: light-grey paper `#f5f5f5`, dark-grey ink `#2e2e2e`, creapulse-pink accent `#f83595`, creapulse-blue link `#0284c7`. These are the active tokens. Read that file for the full table and treat it as the single source of truth.

This build runs **non-interactively** (API / automation context). There is no user to answer questions. Therefore:

- Never ask which brand, palette, or profile to use.
- Never run the URL-onboarding flow in [`references/onboarding.md`](references/onboarding.md) — the execution container has no network access, so it cannot fetch a site.
- Never offer to save a client profile.
- Ignore any `.diagram-design` marker lookup; there is no project root.

### Scope — do not read out-of-scope references

Every file you read is reprocessed on every later turn of this run, so an irrelevant read is paid many times over. This automated pipeline **never** animates, imports, exports, or uses alternate skins. Therefore **do not open**:

- `references/animation.md`, `template-motion.html` — output is static, mode `none`.
- `references/export.md` — the caller extracts the SVG itself. Emit the diagram HTML only; never run a PNG/SVG export.
- `references/import-drawio.md`, `references/import-mermaid.md`, `scripts/drawio_extract.py`, `scripts/mermaid_extract.py` — nothing is imported here.
- `references/onboarding.md`, `references/profiles.md` — the brand is fixed (above).
- `references/primitive-terminal.md`, `references/primitive-sketchy.md` — the default skin is the only skin.

Read exactly what the task needs: `SKILL.md` routing, the one matching `references/type-<name>.md`, `references/style-guide.md`, `references/output-spec.md`, and a template. Nothing else unless the brief explicitly calls for it.

### Iteration budget

Generating the SVG is worth getting right, but not endlessly. **Cap self-correction at 3 generate-and-verify passes.** If the geometry still isn't perfect after the third pass, ship the best version rather than starting a fourth — a slightly imperfect diagram delivered is better than a fourth pass nobody asked for. Run the geometry/self-check once per pass, not repeatedly on an unchanged file.

Go straight to §1 and generate the diagram with the tokens above.
