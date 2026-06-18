# CLAUDE.md — creapulse-skills-SEO-and-co

Contexte de projet chargé automatiquement à chaque session ouverte dans ce dossier.

## Ce qu'est ce projet

Librairie **monorepo** de skills Claude Code orientés marketing : **SEO en cœur** (éclaté en
sous-domaines : internal-linking, technical, on-page, keyword research, GEO/AI search, etc.)
+ adjacents : analytics (GTM/GA4/Looker Studio), content, social, UX, design, CRO, landing pages.

But : **constituer ET maintenir dans le temps** cette librairie — curation depuis GitHub,
vendoring propre, normalisation, puis maintenance via deux veilles (upstream + web).

👉 **Le plan complet et à jour est dans [ROADMAP.md](./ROADMAP.md). Ouvre-le en début de session.**

## Décisions actées (ne pas re-débattre sans raison)

- **Vendoring + manifeste de provenance** (`registry.yml`) : on copie l'utile, on trace
  `source_repo` + `source_sha` + `license` + `tracking` (`tracked` vs `forked-hard`) **par skill**.
  Pas de multiples forks.
- **Monorepo unique** (pas un repo par domaine).
- Les 2 veilles de maintenance (diff upstream + veille web Google/SEO) **proposent**, Serge valide.
  **Jamais d'auto-merge.**
- **Ne pas industrialiser avant d'avoir rodé un domaine pilote complet** (suggéré : SEO/internal-linking
  ou SEO technical).

## Statut

**Planification.** Rien de construit côté skills. Prochaine étape = **Phase 0** de la ROADMAP
(cartographie fine, critères de sélection, squelette `registry.yml`).

## Notes outillage / environnement

- Le clone local vit dans Google Drive (`D:\Mon-drive\creapulse local\claude code\…`) — OK car la
  synchro Drive de Serge est **unidirectionnelle (local → cloud)**, donc le `.git` n'est jamais réécrit
  par le cloud.
- `gh` (CLI GitHub) **n'est pas installé**. Le push git local fonctionne (Git Credential Manager a un
  token valide). Le token GitHub MCP est en lecture/portée limitée (ne peut PAS créer de repo).
- Identité git : Serge Esteves / serge.esteves@gmail.com.
