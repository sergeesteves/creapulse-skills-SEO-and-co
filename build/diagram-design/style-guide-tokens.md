| `paper` | Page background, default node fill | `#f5f5f5` (light grey) | `#2e2e2e` (charcoal) |
| `paper-2` | Diagram container bg, secondary fill | `#ececec` | `#3a3a3a` |
| `ink` | Primary text, primary stroke | `#2e2e2e` (dark grey) | `#f5f5f5` (light grey) |
| `muted` | Secondary text, default arrow stroke | `#5f6368` (grey) | `#c4c4c4` |
| `soft` | Sublabels, boundary labels | `#8a8d91` | `#8e8e8e` |
| `rule` | Hairline borders | `rgba(46,46,46,0.12)` | `rgba(245,245,245,0.12)` |
| `rule-solid` | Stronger borders, baselines | `#c4c4c4` | `rgba(196,196,196,0.25)` |
| `accent` | Focal / 1–2 max per diagram | `#f83595` (creapulse-pink) | `#fb5faa` |
| `accent-tint` | Fill for accent-bordered boxes | `rgba(248,53,149,0.08)` | `rgba(251,95,170,0.10)` |
| `link` | HTTP/API calls, external arrows | `#0284c7` (creapulse-blue, darkened) | `#029ae5` |

> **Brand palette source (Creapulse):** `creapulse-pink #f83595` (accent), `creapulse-blue #029ae5` (secondary → `link`), light grey `#f5f5f5` (paper), dark grey `#2e2e2e` (ink). The `muted`, `soft`, `rule` and `rule-solid` tokens are neutral greys derived from `ink` — deliberately desaturated so the two brand hues stay the only color in the diagram.

> **Contrast notes.** On `paper #f5f5f5`: `accent #f83595` clears 3.2:1 — enough for shapes, strokes and large focal labels (WCAG 1.4.11 non-text, 3:1), **not** for small body text. Keep body copy on `ink` or `muted`. The pure brand blue `#029ae5` only reaches 2.9:1 on light paper, below the 3:1 floor for graphical objects, so `link` uses the darkened `#0284c7` (3.8:1) in light mode; the untouched `#029ae5` is used in dark mode, where it reads at 4.9:1.
