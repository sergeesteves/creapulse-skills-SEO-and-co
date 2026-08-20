# Crawl4AI — API REST du serveur Docker + usage n8n (ajout Creapulse)

> ⚠️ **Fichier ajouté par Creapulse** (hors zip officiel). Le skill upstream couvre le **SDK Python**
> (`AsyncWebCrawler`). Ceci couvre le **serveur REST self-hosté** (image `unclecode/crawl4ai`,
> port par défaut `11235`) — c'est ce qu'on appelle depuis **n8n** / une app externe.
> Source : docs.crawl4ai.com (Self-Hosting), versions 0.7.x → 0.9.x.

## Authentification

- **0.9.0 = secure-by-default** : le serveur **exige un token**. En-tête `Authorization: Bearer <token>`.
- Si `security.jwt_enabled: true` dans `config.yml` : d'abord `POST /token` (`{ "email": "..." }`) pour
  obtenir un JWT, puis Bearer.
- En 0.8.x la sécurité est off par défaut (pas de token). → **dépend de ta config serveur.**
- Côté n8n : garde le token dans un **credential** (Header Auth), jamais en clair dans le nœud.

## Endpoints

| Méthode | Path | Body | Renvoie |
|---|---|---|---|
| POST | `/crawl` | cf. § body ci-dessous | `{ "results": [...] }` (markdown, cleaned_html, links, media, screenshot, pdf, extracted_content…) |
| POST | `/crawl/stream` | idem `/crawl` | NDJSON streamé (1 résultat par ligne) |
| POST | `/md` | `{ "url", "f"?, "q"?, "c"? }` | markdown seul (f = filtre, q = requête, c = cache) — **le plus direct pour du contenu SEO** |
| POST | `/html` | `{ "url" }` | HTML préprocessé (pour extraction de schéma) |
| POST | `/screenshot` | `{ "url", "screenshot_wait_for"?, "output_path"? }` | PNG (base64 ou id d'artefact en 0.9) |
| POST | `/pdf` | `{ "url", "output_path"? }` | PDF |
| POST | `/execute_js` | `{ "url", "scripts": ["return document.title", ...] }` | résultat de crawl + retours JS |
| GET | `/health` | — | `{ "status": "healthy", "version": "0.7.4" }` |
| GET | `/schema` | — | schéma complet de l'API |
| GET | `/metrics` | — | métriques Prometheus |
| GET | `/mcp/schema` | — | **le serveur expose aussi un endpoint MCP** (utilisable comme connecteur MCP) |

## ⚠️ Piège du body `/crawl` : le wrapper `{ type, params }`

`browser_config` et `crawler_config` **ne sont PAS des dicts plats** — ils prennent la forme sérialisée
(`Config.dump()`). Se tromper là-dessus = erreur de validation.

```json
{
  "urls": ["https://example.com"],
  "browser_config": { "type": "BrowserConfig",    "params": { "headless": true } },
  "crawler_config":  { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass", "screenshot": false } }
}
```

- Les **enums passent en string** (`"cache_mode": "bypass"`, pas l'objet Python).
- Les clés de `params` = les champs de `BrowserConfig` / `CrawlerRunConfig` (liste complète dans
  [`complete-sdk-reference.md`](complete-sdk-reference.md)).

## Champs `crawler_config.params` utiles pour le SEO

- `cache_mode` : `"bypass"` | `"enabled"` | `"disabled"`
- `css_selector`, `excluded_tags`, `word_count_threshold`
- `wait_for`, `page_timeout`, `js_code`, `scan_full_page`, `remove_consent_popups`
- `extraction_strategy` (ex. `JsonCssExtractionStrategy` → extraction structurée **sans LLM**)
- `screenshot`, `pdf`, `check_robots_txt`, `exclude_external_links`

## Câblage n8n — nœud HTTP Request

- **Method** : `POST`
- **URL** : `{{server}}/crawl` (ou `{{server}}/md` pour du markdown simple)
- **Authentication** : *Generic Credential* → **Header Auth** → Name `Authorization`, Value `Bearer <token>`
  (le token vit dans le credential n8n)
- **Headers** : `Content-Type: application/json`
- **Body** : *JSON / raw*, la structure `{type, params}` ci-dessus. Exemple paramétrable :

```json
{
  "urls": ["{{ $json.url }}"],
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

- **Lecture de la réponse** : `results[0].markdown` (Markdown), `.cleaned_html`, `.links`,
  `.extracted_content` (si `extraction_strategy`), `.screenshot` / `.pdf` (base64 ou id).

Règle du pouce : **contenu éditorial/SEO → `/md`** (le plus simple) ; **extraction structurée**
(prix, produits, SERP maison, données de page) **→ `/crawl` + `extraction_strategy`**.

## Alternative : brancher le serveur en connecteur MCP

Le serveur expose `/mcp/schema` → il peut être utilisé comme **connecteur MCP** (au lieu d'un HTTP
Request), cohérent avec l'axe connecteurs du kit (ROADMAP §5.5). À évaluer si tu veux l'appeler
aussi depuis Claude, pas seulement depuis n8n.

## Confirmer la version exacte de TON serveur (sans token)

Les endpoints publics (pas d'auth) permettent d'introspecter la version déployée :
`GET {{server}}/health` (→ version) et `GET {{server}}/schema` (schéma complet des champs de ta
version). Utile pour caler le body sur ta version précise plutôt que sur la doc générique.
