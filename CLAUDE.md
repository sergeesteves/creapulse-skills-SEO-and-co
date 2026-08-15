# CLAUDE.md — creapulse-skills-SEO-and-co

Contexte de projet chargé automatiquement à chaque session ouverte dans ce dossier.

## Ce qu'est ce projet

Librairie **monorepo** Claude Code orientée marketing, en **trois couches** :
- **skills/** (couche 1) — savoir-faire atomiques : **SEO en cœur** (internal-linking, technical, on-page,
  keyword research, GEO/AI search…) + adjacents (analytics GTM/GA4/Looker, content, social, UX, design,
  CRO, landing). **Vendorés** depuis GitHub + tracés dans `registry.yml`.
- **agents/** (couche 2) — **métiers écrits maison** qui composent les skills (ex. `ai-citation-strategist`).
  Pas de vendoring : inspiration seulement (cf. ROADMAP §5.2). Voir `agents/README.md`.
- **plugins/** (couche 3, PLUS TARD) — packaging installable qui combine skills + agents + connecteurs.

Rappel du modèle : **skill = savoir-faire, agent = qui le fait, connecteur = avec quel outil,
plugin = comment on livre.** Ne pas construire la couche plugin par anticipation.

But : **constituer ET maintenir dans le temps** cette librairie — curation depuis GitHub,
vendoring propre, normalisation, puis maintenance via deux veilles (upstream + web).

👉 **Le plan complet et à jour est dans [ROADMAP.md](./ROADMAP.md). Ouvre-le en début de session.**

## Décisions actées (ne pas re-débattre sans raison)

- **Vendoring + manifeste de provenance** (`registry.yml`) : on copie l'utile, on trace
  `source_repo` + `source_sha` + `license` + `tracking` (`tracked` vs `forked-hard`) **par skill**.
  Pas de multiples forks.
- **Monorepo unique** (pas un repo par domaine), **3 couches** : `skills/` + `agents/` maintenant,
  `plugins/` + `marketplace.json` plus tard.
- **Agents = écrits maison** (inspiration `msitarzewski/agency-agents` + agents de `AgriciDaniel/claude-seo`,
  adaptés FR/Creapulse). Pas de vendoring pour les agents.
- **Sources d'inspiration skills** (ordre de priorité, cf. ROADMAP §5.1) : `aaron-he-zhu/seo-geo-claude-skills`,
  `AgriciDaniel/claude-seo`, `coreyhaines31/marketingskills`, `resciencelab/opc-skills`.
- Les 2 veilles de maintenance (diff upstream + veille web Google/SEO) **proposent**, Serge valide.
  **Jamais d'auto-merge.**
- **Ne pas industrialiser avant d'avoir rodé un domaine pilote complet** (suggéré : SEO/internal-linking
  ou SEO technical).

## build/ — chaîne de publication (transverse, pas une 4e couche)

`build/` n'est pas une couche de contenu : c'est l'outillage qui publie les skills vers la
**Skills API d'Anthropic**, pour les rendre consommables depuis n8n sans infra Claude Code.
Voir [build/README.md](./build/README.md).

**Règle structurante : on versionne la transformation, pas son résultat.**
Quand on modifie lourdement un skill vendorisé, on n'édite **pas** la copie sous `skills/` —
elle reste conforme à l'upstream. Les modifications vivent dans `build/<nom>/apply.ps1` et
sont rejouées au build. C'est ce qui permet de rester `tracking: tracked` malgré une
modification massive : un bump de `source_sha` produit un diff upstream lisible.

Tracé par le champ `transform:` de `registry.yml` (extension du schéma, cf. note dans le fichier).

## Statut

**Amorcé.** Deux skills en place :
- `dataforseo` (first-party) — playbook cost-aware de l'API DataForSEO.
- `diagram-design` (tracked + transform) — 27 types de diagrammes éditoriaux, rebrandé
  Creapulse par script. Premier skill publié vers la Skills API et consommé depuis n8n.

Chaîne `git → Skills API → n8n` opérationnelle et testée (`build/publish-skill.ps1`,
GitHub Action `publish-skills.yml`).

Reste à faire = **Phase 0** de la ROADMAP (cartographie fine, critères de sélection) pour
industrialiser la curation. Le squelette `registry.yml` existe.

## Notes outillage / environnement

- Le clone local vit dans Google Drive (`D:\Mon-drive\creapulse local\claude code\…`) — OK car la
  synchro Drive de Serge est **unidirectionnelle (local → cloud)**, donc le `.git` n'est jamais réécrit
  par le cloud.
- `gh` (CLI GitHub) **n'est pas installé**. Le push git local fonctionne (Git Credential Manager a un
  token valide). Le token GitHub MCP est en lecture/portée limitée (ne peut PAS créer de repo).
- Identité git : Serge Esteves / serge.esteves@gmail.com.
