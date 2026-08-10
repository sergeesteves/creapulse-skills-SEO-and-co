# ROADMAP — Librairie Claude marketing (SEO & co) : skills, agents, plugins

> Repo : `sergeesteves/creapulse-skills-SEO-and-co` — monorepo privé.
> Objectif : constituer et **maintenir dans le temps** une librairie Claude Code orientée marketing
> (SEO en cœur, + analytics, content, social, UX, design, CRO, landing pages), en **trois couches** :
> **skills** (savoir-faire atomiques, curatés depuis GitHub et vendorisés), **agents** (métiers qui
> composent ces skills), et plus tard **plugins** (packaging installable qui combine skills + agents +
> connecteurs).

Statut : **planification** (rien n'est encore construit côté skills/agents). Dernière mise à jour : 2026-07-03.

---

## 0. Principe directeur (la décision qui structure tout)

Il y a une tension à arbitrer **par skill**, pas globalement :

- On veut **copier seulement l'utile + apporter nos propres améliorations** ;
- ET **suivre les nouveautés des repos parents**.

Ces deux objectifs se contredisent : plus on modifie un skill localement, plus le « sync upstream »
devient pénible et peu utile. La réponse n'est pas de choisir, mais d'enregistrer **l'intention par skill**
dans un manifeste de provenance (`registry.yml`).

### Approche retenue : vendoring + manifeste (ni fork pur, ni copie aveugle)

- On **copie** uniquement les skills utiles dans CE monorepo (pas 15 forks à moitié morts).
- Chaque skill copié garde une fiche d'identité dans `registry.yml` :
  - `source_repo`, `source_path`, **`source_sha`** (commit exact au moment de la copie)
  - `license`
  - `tracking` : `tracked` (rester proche de l'upstream) | `forked-hard` (on l'a fait nôtre, on ne sync plus)
  - `local_changes` : liste de nos modifs
- C'est ce manifeste qui rend possible la veille upstream : `diff(source_sha → HEAD upstream)`
  → « voici ce qui a changé, est-ce significatif ? ».

**Sans ce manifeste, l'objectif "checker régulièrement les repos parents" est infaisable proprement.**

---

## 1. Les trois couches : skills, agents, plugins

Le concept qui débloque tout : **ces trois notions ne sont pas concurrentes, elles sont empilées.**

| Couche | C'est quoi | Rôle | Granularité |
|---|---|---|---|
| **Skill** | Une **capacité** atomique (`technical-seo`, `internal-linking`…) | *ce qu'on sait faire* | **fine** (un skill = un sous-domaine) |
| **Agent** | Un **métier** qui **mobilise** plusieurs skills + des connecteurs | *qui fait le travail* | **grossière** (un agent = un métier entier) |
| **Connecteur (MCP)** | Un **outil** externe (DataForSEO, crawler, Firecrawl…) | *avec quel outil* | par outil |
| **Plugin** | Une **boîte de livraison** qui empaquette skills + agents + connecteurs + commandes | *comment on livre le tout ensemble* | par tranche cohérente |

> Formule : **skill = savoir-faire, agent = qui le fait, connecteur = avec quel outil, plugin = comment on livre.**

Conséquences de design :

- **Un « Consultant SEO » n'est PAS un skill fin.** C'est un **agent** grossier, censé être bon sur *tous*
  ses skills (technical, on-page, internal-linking, GEO…). Il ne re-décrit pas le détail : il **pointe vers
  les skills** et sait quand les mobiliser. Les skills se déclenchent seules par leur `description` ; l'agent
  apporte la **posture, le workflow, l'ordre des priorités**.
- **Agent ≠ plugin, ce ne sont pas les mêmes axes.** L'agent *consomme* des connecteurs à l'exécution ;
  le plugin *emballe* skills + agents + connecteurs pour la distribution. Pas de redondance : l'un est
  l'ouvrier, l'autre est le carton d'expédition.
- **Ordre d'apparition dans le repo :** d'abord `skills/` (matière première), puis `agents/` (composition,
  peu nombreux, écrits maison), puis `plugins/` (packaging, **seulement quand il y a de quoi remplir le carton**).
  Ne pas construire la couche plugin par anticipation.

---

## 2. Cartographie des besoins en skills

> SEO = le plus gros morceau (éclaté en sous-domaines). Le reste en domaines adjacents.
> Règle : **frontières nettes** entre skills pour éviter les collisions de déclenchement
> (content / social / SEO se recouvrent énormément).

### SEO (cœur)
- **Technical SEO** — crawl, indexation, robots.txt, sitemaps, Core Web Vitals, rendu JS, log analysis
- **On-page** — title/meta, headings, optimisation de contenu, entités
- **Internal linking** ⭐ (explicitement demandé)
- **Structured data / Schema.org**
- **Keyword research & search intent** — SERP analysis, clustering de requêtes
- **Content SEO** — briefs, topical authority, maillage sémantique
- **Off-page / backlinks / digital PR**
- **Local SEO**
- **E-commerce & SEO programmatique**
- **International / hreflang**
- **Migration & redirections**
- **Reporting SEO** — Google Search Console
- **GEO / AI search visibility** — optimisation pour moteurs génératifs (LLM). Récent, stratégique.

### Analytics
- GTM, GA4, Looker Studio, server-side tagging, consent mode

### Domaines adjacents
- **Content** · **Social** · **UX** · **Design** · **CRO** · **Landing pages**

> ⚠️ Doublons inter-domaines à surveiller : « content SEO » vs « content », « social » vs « community ».
> À résoudre au moment de la cartographie fine (Phase 0).

---

## 3. Cartographie des agents (métiers)

Peu d'agents, **écrits maison** (le repo agency-agents sert d'inspiration rédactionnelle, pas de vendoring —
cf. §5). Chaque agent est un métier qui compose des skills du §2 et, plus tard, des connecteurs.

Noyau visé (à affiner) :

- **AI Citation Strategist** — visibilité dans les réponses des LLM (GEO/AEO, citations, entités). *Point de départ.*
- **SEO Consultant** — chapeau SEO généraliste : mobilise technical / on-page / internal-linking / keyword / GEO.
- **Content Strategist** — briefs, topical authority, calendrier éditorial, rédaction.
- **Social Media Strategist** — stratégie multi-plateformes (carrousels IG, LinkedIn), s'appuie sur le pipeline Buffer/Postiz.
- **Frontend/WordPress Dev** — intégration blog creapulse.fr (thème, blocs, perf).

> Règle de granularité : si tu hésites entre « en faire un skill ou un agent », demande-toi *« est-ce un
> savoir-faire précis (skill) ou une posture de métier qui en orchestre plusieurs (agent) ? »*.

---

## 4. Critères de sélection « les meilleurs sur GitHub »

Filtres pour qualifier un candidat (skill **ou** agent) :
- Commits **récents** (repo maintenu, pas abandonné)
- **Qualité de la `description` frontmatter** = qualité du déclenchement (critère #1 en pratique)
- **Responsabilité unique** (un skill = une tâche claire, pas un couteau suisse)
- **Licence permissive** (MIT/Apache) — à tracer dans le manifeste
- Pas de dépendances lourdes / exotiques
- Lisibilité du prompt et des instructions

> La curation déjà faite par Serge sert de point de départ ; ces critères servent à
> trancher entre candidats et à écarter les faux-bons.

---

## 5. Sources d'inspiration & veille

Deux natures de sources, traitées différemment.

### 5.1 Skills — repos à vendoriser (par ordre de priorité)

Ces repos sont la **matière première** : on y pioche des skills, on les vendorise, on trace dans `registry.yml`.
Ils sont aussi **suivis par la veille upstream** (nouveaux skills, évolutions).

| # | Repo | Contenu | Licence | Rôle chez nous |
|---|---|---|---|---|
| 1 | [aaron-he-zhu/seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) | 20 skills `SKILL.md` en 5 phases (Research/Build/Optimize/Monitor/Cross-cutting), focus GEO, frameworks CORE-EEAT & CITE, MCP-ready | Apache 2.0 | ⭐ **Candidat n°1 du pilote** — structure nette, cœur SEO+GEO |
| 2 | [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo) | 25 sous-skills + **18 agents** + **8 connecteurs MCP** (DataForSEO, Firecrawl, Ahrefs, SE Ranking, Profound, Bing WMT, Unlighthouse), 271 tests, aligné QRG sept. 2025 | MIT | ⭐ Le plus complet — **illustre exactement le modèle skills+agents+connecteurs**. Mine d'or mais gros → vendoring **très sélectif**. Aussi source pour les couches agents ET connecteurs |
| 3 | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | 50+ skills marketing (CRO, copy, content, social, ads, analytics, SEO), 35,9k ⭐, très maintenu, skill-socle `product-marketing` | MIT | **Domaines adjacents** : content / social / CRO / landing |
| 4 | [resciencelab/opc-skills](https://github.com/resciencelab/opc-skills) | 11 skills solopreneur (seo-geo, reddit, twitter, producthunt, image gen nanobanana/logo/banner) | Apache 2.0 | Plus léger — recoupe le **pipeline image** (Replicate) et la **veille** (reddit/twitter). À piocher ponctuellement |

**Skills unitaires** (repos mono-skill, hors classement de priorité) :

- [Suganthan-Mohanadasan/tech-seo-audit-skill](https://github.com/Suganthan-Mohanadasan/tech-seo-audit-skill)
  — `SKILL.md` d'audit SEO technique, 10 catégories (crawlability, indexation, on-page, archi, perf, mobile,
  schema, sécurité, international, **AI readiness**), moteur Python (pandas/beautifulsoup4/firecrawl-py optionnel),
  MIT, MAJ mars 2026. **Candidat fort pour le pilote SEO/technical** — nuance : dépendances Python = plus lourd
  qu'un skill pur-prompt (cf. critère §4 « pas de dépendances lourdes »). À arbitrer vs `aaron-he-zhu` pour le pilote.
- [Suganthan-Mohanadasan/avoid-ai-writing](https://github.com/Suganthan-Mohanadasan/avoid-ai-writing)
  — `SKILL.md` qui retire les patterns d'écriture IA (61+ signatures, détecteur déterministe zéro-dépendance),
  MIT. Domaine *content*. ⚠️ **Recoupe le skill `humanizer`** déjà présent dans `creapulse-tools` → arbitrer
  lequel garder avant de vendoriser (éviter le doublon).

### 5.2 Agents — repos d'inspiration rédactionnelle (PAS de vendoring)

Les agents sont des **prompts de rôle** : on s'en inspire pour rédiger nos propres métiers, on ne les copie pas tels quels.

- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — 250+ rôles en 16 divisions.
  Sélection retenue comme point de départ (à adapter FR / Creapulse) :
  - **SEO / IA** : `marketing-ai-citation-strategist`, `marketing-seo-specialist`, `marketing-aeo-foundations`,
    `marketing-agentic-search-optimizer`
  - **Rédaction** : `marketing-content-creator`, `engineering-technical-writer`
  - **Social** : `marketing-social-media-strategist`, `marketing-carousel-growth-engine`,
    `marketing-instagram-curator`, `marketing-linkedin-content-creator`, `marketing-multi-platform-publisher`
  - **IA / image** : `engineering-ai-engineer`, `engineering-prompt-engineer`, `design-image-prompt-engineer`
  - **Front-end** : `engineering-frontend-developer`, `engineering-cms-developer`
  - *(À écarter : tout le bloc marché chinois — Baidu, Douyin, WeChat, Weibo, Xiaohongshu, Zhihu…)*
- `AgriciDaniel/claude-seo` (cf. 5.1) contient aussi 18 agents SEO — bon corpus d'inspiration pour nos métiers.

### 5.3 Intégration à la veille

La veille (Phase 5) surveille **deux types de changements** sur les repos ci-dessus :

- **Veille par skill vendorisé** : `diff(source_sha → HEAD)` sur chaque skill déjà copié → changement significatif ?
- **Veille par repo source** : nouveaux skills/agents **apparus** dans ces repos depuis le dernier check
  → « intéressant à intégrer ou pas ? ». C'est ici que rentrent les 5 repos du §5.1/§5.2.

Sortie dans les deux cas : un **rapport + propositions**, jamais d'auto-merge. Serge valide.

### 5.4 Sources d'idées & références (hors vendoring — « à garder sous le coude »)

Repos qui ne fournissent **pas** de skills/agents à copier, mais qui inspirent des **thèmes, features,
automatisations** ou servent de **référence** (outils, connecteurs). On ne les vendorise pas, on ne les
trace pas dans `registry.yml` — on les consulte au besoin (et la veille peut y repérer des idées neuves).

- [Shubhamsaboo/awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) — 100+ apps LLM
  d'exemple (agents, RAG, MCP, voice, always-on), Apache 2.0. Un peu fourre-tout, mais sections pertinentes :
  *AI Competitor Intelligence*, *Product Launch Intelligence*, *AI News & Podcast Agent*, *Always-on HN
  briefing* (veille), *Web Scraping Agent*, *RAG apps* (base de connaissances). Idées d'**automatisations
  n8n / agents métier**, pas des skills à intégrer tels quels.
- [Suganthan-Mohanadasan/awesome-seo-tools](https://github.com/Suganthan-Mohanadasan/awesome-seo-tools) —
  liste curée de 208+ outils SEO (23 catégories : suites, keyword, technical, backlinks, rank tracking,
  local, **LLM visibility / AI SEO**, Core Web Vitals, **plugins WordPress**, outils Google gratuits), MIT/CC0.
  **Référence outillage** : sert surtout à repérer les outils **avec API** → candidats connecteurs pour les
  agents (ex. DataForSEO, SearchAPI.io — cf. décision ouverte §9). Utile aussi pour l'agent
  `ai-citation-strategist` (section LLM visibility) et le front WordPress (section plugins).

### 5.5 Connecteurs (MCP) — candidats à brancher sur les agents

Les connecteurs sont un **axe distinct** (cf. §1) : un serveur MCP ne se **vendorise pas** dans `skills/`,
il s'**installe/configure** (env vars, credentials), puis se **bundle** plus tard dans le `.mcp.json` d'un
plugin. On les liste ici comme candidats, on décide lesquels brancher en §9.

| Connecteur | Source | Ce qu'il expose | Domaine nourri | Notes |
|---|---|---|---|---|
| **GSC** | [Suganthan…/Suganthans-GSC-MCP](https://github.com/Suganthan-Mohanadasan/Suganthans-GSC-MCP) | 20 outils (snapshots, quick wins, cannibalisation, content decay, CTR, indexation URL/sitemap) — Node/TS, MIT | Reporting SEO / GSC | **Le plus actionnable.** Auth OAuth ou service account, API Search Console à activer sur GCP |
| **BigQuery** | [Suganthan…/BigQuery-MCP-Server](https://github.com/Suganthan-Mohanadasan/Suganthans-BigQuery-MCP-Server) | 32 outils (forecasting, anomalies, GSC bulk export, blend GA4+GSC, attribution/ROI) — Node/TS, Apache 2.0 | Analytics | Puissant mais **setup GCP/BigQuery** (service account, 3 rôles IAM, export bulk GSC) |
| **KWI content calendar** | [Suganthan…/kwi-content-calendar-mcp](https://github.com/Suganthan-Mohanadasan/kwi-content-calendar-mcp) | 2 outils : parse CSV clustering Keyword Insights → calendrier éditorial Excel (5 feuilles) — Node/TS, MIT | Content SEO | Niche — **dépend d'un export de l'outil Keyword Insights** (18 colonnes) |

> Rappel : Firecrawl est **déjà** dispo en MCP dans l'environnement de Serge — 1er connecteur « gratuit » pour les agents.

---

## 6. Architecture du repo (monorepo, 3 couches)

```
creapulse-skills-SEO-and-co/
├── README.md
├── ROADMAP.md                ← ce fichier
├── CLAUDE.md                 ← contexte projet chargé à chaque session
├── registry.yml              ← manifeste de provenance des skills (colonne vertébrale)
├── LICENSE
├── docs/
│   ├── selection-criteria.md
│   ├── naming-conventions.md  ← normalisation frontmatter / nommage
│   └── maintenance.md         ← procédure des veilles
├── skills/                    ← COUCHE 1 : matière première (vendorée + tracée)
│   ├── seo/{internal-linking,technical,on-page,...}
│   ├── analytics/  content/  social/  ux/  design/  cro/  landing-pages/
├── agents/                    ← COUCHE 2 : métiers, écrits maison (composition)
│   ├── README.md              ← convention des agents
│   ├── ai-citation-strategist.md
│   └── ...
├── plugins/                   ← COUCHE 3 : PLUS TARD — packaging installable
│   └── seo/
│       ├── .claude-plugin/plugin.json
│       ├── agents/  skills/   └── .mcp.json   (DataForSEO, crawler…)
├── .claude-plugin/
│   └── marketplace.json       ← PLUS TARD — rend le repo installable comme marketplace
└── overlays/                  ← nos patches/améliorations, séparés du code upstream
```

Décisions actées : **monorepo unique** ; **`skills/` et `agents/` maintenant**, **`plugins/` + `marketplace.json`
plus tard** (Phase 3, quand une tranche mérite d'être livrée d'un bloc).

### Format cible de `registry.yml`
```yaml
skills:
  - name: internal-linking
    domain: seo
    path: skills/seo/internal-linking
    source_repo: https://github.com/<author>/<repo>
    source_path: skills/internal-linking
    source_sha: <commit-sha-au-moment-de-la-copie>
    license: MIT
    tracking: tracked        # tracked | forked-hard
    local_changes: []
    last_upstream_check: null
```

---

## 7. Phases d'exécution (ordre d'attaque)

### Phase 0 — Fondations
- [x] Repo créé (privé)
- [x] Dossier `agents/` + convention (README) + 1er squelette (`ai-citation-strategist`)
- [ ] Cartographie fine validée (taxonomie sans recouvrements)
- [ ] `selection-criteria.md` + `naming-conventions.md` rédigés
- [ ] Squelette `registry.yml` + arborescence `skills/`
- [ ] Choix licence du repo + politique d'attribution upstream

### Phase 1 — Domaine pilote (rôder le process de bout en bout)
> Ne PAS industrialiser avant d'avoir rodé un domaine complet. Pilote suggéré : **SEO / internal-linking**
> ou **SEO technical** (source privilégiée : `aaron-he-zhu/seo-geo-claude-skills`).
- [ ] Sélection des candidats du domaine pilote
- [ ] Copie (vendoring) + remplissage `registry.yml` (avec SHA)
- [ ] Revue commune de ce que fait chaque skill
- [ ] Améliorations immédiates (dans `overlays/`) + backlog d'améliorations futures
- [ ] Test de déclenchement (via `skill-creator` / evals)

### Phase 2 — Premier agent branché sur des skills
- [ ] Étoffer un agent métier (ex. `ai-citation-strategist` ou `seo-consultant`) qui mobilise les skills du pilote
- [ ] Vérifier la composition (l'agent déclenche bien les bons skills)
- [ ] Éventuel 1er connecteur MCP en lecture (DataForSEO / Firecrawl) branché sur l'agent

### Phase 3 — Normalisation & packaging
- [ ] Passe d'harmonisation frontmatter / nommage / descriptions (anti-collision)
- [ ] Packaging en **plugin / marketplace Claude Code** (installable + synchronisable sur toutes machines)
- [ ] Versioning + CHANGELOG de notre librairie

### Phase 4 — Extension
- [ ] Dérouler le process rodé sur les autres sous-domaines SEO, puis domaines adjacents
- [ ] Mise à jour continue du manifeste

### Phase 5 — Automatisation de la maintenance (2 veilles distinctes)
> Règle d'or : les veilles **proposent**, Serge valide. **Jamais d'auto-merge.**

- [ ] **Veille upstream** (routine planifiée / cron) : diff `source_sha → HEAD` de chaque repo `tracked`
      + repérage des **nouveaux** skills/agents dans les repos sources (§5) → résumé → propose des PR.
- [ ] **Veille web** (routine planifiée) : nouveautés Google / SEO / GA4 / GEO… → propose des évolutions.
- [ ] Sortie des deux veilles : un rapport + des propositions, à valider manuellement.

---

## 8. Points de gouvernance / risques

- **Modifs locales vs sync** : garder nos améliorations dans `overlays/` (patch séparé) pour ne pas les
  perdre au prochain sync upstream.
- **Licences & attribution** : copier le code d'autrui a des implications → tracées dans `registry.yml`.
  Les 4 repos skills sont MIT/Apache 2.0 (permissifs) — attribution à conserver.
- **Agents ≠ vendoring** : les agents sont écrits maison (inspiration seulement) → pas d'entrée `registry.yml`
  pour eux, mais on cite les sources d'inspiration dans le fichier de l'agent.
- **Infra** : le clone local vit dans Google Drive, **OK** car la synchro Drive de Serge est
  **unidirectionnelle (local → cloud)** — le `.git` n'est jamais réécrit par le cloud. GitHub = sauvegarde cloud.
- **Collisions de déclenchement** : le vrai risque qualité du projet → discipline sur les `description`.

---

## 9. Décisions ouvertes (à trancher)

- **Nom & visibilité du repo** : garder `creapulse-skills-SEO-and-co` **et privé** pour l'instant
  (pas de renommage). « skill seo » est plus recherché que « agent seo » → si passage au public un jour,
  piste privilégiée : **garder ce repo privé** (labo perso complet) et **publier une version dérivée
  curatée** pour le public, plutôt que d'ouvrir celui-ci tel quel.
- **Packaging plugin** : un seul plugin global ou un plugin par domaine ? (tranche en Phase 3)
- **Cadence des veilles** (hebdo ? mensuel ?) et canal de notification (Slack ? mail ?)
- **Connecteurs** : lesquels brancher en premier sur les agents (cf. candidats §5.5). Piste : **Firecrawl**
  (déjà dispo) + **GSC-MCP** (le plus actionnable, données propres à Creapulse) ; BigQuery-MCP plus tard
  (setup GCP lourd) ; DataForSEO / SearchAPI.io si besoin de données SERP externes.
- **Doublon `avoid-ai-writing` vs `humanizer`** : garder lequel ? (arbitrer avant de vendoriser, cf. §5.1)
</content>
</invoke>
