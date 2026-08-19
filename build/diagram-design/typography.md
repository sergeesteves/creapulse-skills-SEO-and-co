## Typography

Three roles, three **system font stacks**. Nothing is downloaded and nothing has to be
enqueued by the host site: every family below ships with the OS or is already loaded by
the Creapulse theme (Open Sans).

| Role | Family | Size | Weight | Usage |
|---|---|---|---|---|
| `title` | serif | 22px | 400 | Diagram title |
| `node-name` | sans | 14px | 600 | Human-readable labels |
| `sublabel` | mono | 12px | 400 | Port, protocol, URL, field type |
| `eyebrow` | mono | 12px | 500, tracked 0.18em, uppercase | Type tags, axis labels |
| `arrow-label` | mono | 12px | 400, tracked 0.06em | Arrow annotations |
| `callout` | serif *italic* | 14px | 400 | Editorial asides only |

### Font stacks

```
sans   'Open Sans', system-ui, -apple-system, 'Segoe UI', Roboto, Arial, sans-serif
mono   ui-monospace, SFMono-Regular, Menlo, Consolas, 'Liberation Mono', monospace
serif  Georgia, 'Times New Roman', serif
```

Write these stacks verbatim into every `font-family` attribute. **Never emit a `<link>` or
an `@import` for fonts** — the diagram must render identically whether or not the host page
loads anything.

**Load-bearing rule:** mono is for *technical* content (ports, commands, URLs, field types).
Names go in sans. The diagram title is serif. Italic serif is reserved for annotation
callouts (see [primitive-annotation.md](primitive-annotation.md)).

**Minimum sizes are absolute, not decorative.** 14px for any label a reader must parse,
12px for eyebrows and legends — measured at 1:1 display (see
[output-spec.md](output-spec.md) §2). Never go below them to win space: drop a node,
shorten a label, or switch to a vertical layout instead.
