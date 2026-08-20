# Crawl4AI self-hosté — 3 voies d'accès : MCP, nœud n8n, REST (ajout Creapulse)

> ⚠️ **Fichier ajouté par Creapulse** (hors zip officiel). Le skill upstream couvre le **SDK Python**
> (`AsyncWebCrawler`). Ceci couvre le **serveur Docker self-hosté** (`unclecode/crawl4ai`, port `11235`)
> — c'est ce qu'on appelle depuis Claude (MCP), n8n, ou une app. Sources : docs.crawl4ai.com +
> schémas MCP réels du serveur Creapulse (`crawl4ai.creapulse.fr`, branché en MCP).

## Quelle voie selon le contexte

| Contexte | Voie recommandée |
|---|---|
| **Depuis Claude** (Desktop/Code) | Le **connecteur MCP `crawl4ai`** (déjà branché) — tools `crawl` / `md` / `html` / `screenshot` / `pdf` / `execute_js` / `ask` |
| **Depuis n8n** | Le **nœud communautaire `n8n-nodes-crawl4ai-plus`** (gère credential + wrapping + a un op *SEO Metadata*), sinon **HTTP Request** (portable) |
| **Depuis une app / du code** | **REST** direct (ou le SDK Python du skill upstream) |

## Authentification (serveur 0.9.0 = secure-by-default)

- Le serveur exige un **token** → en-tête `Authorization: Bearer <token>`. (0.8.x : sécurité off par défaut.)
- Si `security.jwt_enabled: true` : `POST /token` (`{ "email": "..." }`) → JWT, puis Bearer.
- n8n : token dans un **credential** (jamais en clair). MCP : géré par la config du connecteur.

---

## Voie 1 — MCP (tools réels du serveur Creapulse)

Le serveur expose un endpoint MCP (`/mcp/schema`). Tools disponibles depuis Claude :

| Tool | Params | Usage |
|---|---|---|
| `crawl` | `urls[]`, `browser_config`, `crawler_config`, `crawler_configs`, `hooks` | crawl complet → CrawlResult JSON (markdown, links, media, extracted_content…) |
| `md` | `url`, `f` (mode), `q` (requête), `c` (cache, def "0"), `provider`, `temperature` | **markdown** — voir modes ci-dessous |
| `html` | `url` | HTML préprocessé (pour bâtir un schéma d'extraction) |
| `screenshot` | `url`, `screenshot_wait_for` (def 2), `wait_for_images` | PNG → `artifact_id` + `url` |
| `pdf` | `url` | PDF → `artifact_id` + `url` |
| `execute_js` | `url`, `scripts[]` | exécute des snippets JS (IIFE/async qui **retournent une valeur**) → CrawlResult complet |
| `ask` | `context_type` (code\|doc\|all), `query`, `score_ratio`, `max_results` | **RAG sur la doc/le code de la LIBRAIRIE Crawl4AI** (pas sur une page arbitraire) — contexte pour générer du code crawl4ai |

**Modes de `md.f`** (clé pour le SEO) :
- `fit` (défaut) : extraction *Readability* → contenu propre.
- `raw` : DOM → Markdown brut.
- `bm25` : **classement de pertinence BM25 par rapport à `q`** → ne garde que les passages pertinents pour une requête. Idéal pour extraire la partie utile d'une page selon une intention.
- `llm` : résumé LLM avec `q` (nécessite un provider LLM configuré).

> ⚠️ Ne pas confondre : le tool MCP `ask` interroge la **doc de la librairie Crawl4AI**, pas une page web
> que tu crawles. Pour poser une question *sur une page*, crawle-la (`md`/`crawl`) puis raisonne dessus.

---

## Voie 2 — Nœud n8n `n8n-nodes-crawl4ai-plus`

Repo : https://github.com/msoukhomlinov/n8n-nodes-crawl4ai-plus — **2 nœuds** :

**Crawl4AI Plus** (simple, 4 ops) : *Get Page Content*, *Ask Question* (QA LLM sur la page),
*Extract Data* (contact/financier/custom, regex ou IA), *CSS Extractor*.

**Crawl4AI Plus Advanced** (15 ops, 3 groupes) :
- **Crawling** : Crawl URL, Crawl Multiple URLs, Stream Crawl, Process Raw HTML, Discover Links.
- **Extraction** : LLM Extractor, CSS Extractor, JSON Extractor, Regex Extractor, Cosine Similarity, **SEO Metadata**.
- **Jobs & Monitoring** : Submit Crawl Job, Submit LLM Job, Get Job Status, Health Check.

**Credential « Crawl4AI API »** : *Docker URL* (déf `http://crawl4ai:11235`), *Authentication*
(No Auth 0.8.x / **Token** 0.9.0+), *LLM Settings* (OpenAI/Anthropic/Groq/Ollama/LiteLLM).
Collections de params : *Browser & Session*, *Crawl Settings*, *Output & Filtering*.

**Avantage du nœud** : il gère le credential, le wrapping `{type, params}`, et offre des ops
prêtes (dont **SEO Metadata**, *Discover Links*, *Cosine Similarity*) — plus rapide que HTTP Request
pour les cas courants. **Inconvénient** : dépendance à un nœud communautaire (à installer/maintenir).

---

## Voie 3 — REST (HTTP Request n8n / app / curl)

Endpoints : `POST /crawl`, `/crawl/stream`, `/md`, `/html`, `/screenshot`, `/pdf`, `/execute_js` ;
`GET /health`, `/schema`, `/metrics`, `/mcp/schema`.

### ⚠️ Piège du body `/crawl` : wrapper `{ type, params }`

`browser_config`/`crawler_config` ne sont **pas** des dicts plats (enums en **string**) :

```json
{
  "urls": ["https://example.com"],
  "browser_config": { "type": "BrowserConfig",    "params": { "headless": true } },
  "crawler_config":  { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass", "screenshot": false } }
}
```

`/md` prend un body simple : `{ "url": "...", "f": "bm25", "q": "ma requête", "c": "0" }`.

### Câblage HTTP Request n8n
- **Method** POST · **URL** `{{server}}/crawl` (ou `/md`) · **Auth** Header Auth : `Authorization: Bearer <token>` (credential) · **Headers** `Content-Type: application/json` · **Body** JSON raw (structure ci-dessus).
- Réponse : `results[0].markdown` / `.cleaned_html` / `.links` / `.extracted_content` (si extraction).

### Champs `crawler_config.params` utiles SEO
`cache_mode`, `css_selector`, `excluded_tags`, `word_count_threshold`, `wait_for`, `js_code`,
`scan_full_page`, `remove_consent_popups`, `extraction_strategy` (ex. `JsonCssExtractionStrategy`,
extraction **sans LLM**), `screenshot`, `pdf`, `check_robots_txt`. Liste complète :
[`complete-sdk-reference.md`](complete-sdk-reference.md).

---

## Vérifier la version exacte de ton serveur (sans token)

`GET {{server}}/health` (→ version) et `GET {{server}}/schema` (schéma complet des champs de ta
version) sont **publics** — utile pour caler le body sur ta version précise.
