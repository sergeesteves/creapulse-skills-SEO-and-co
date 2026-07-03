# `agents/` — les métiers

Couche 2 du repo (cf. [ROADMAP §1](../ROADMAP.md)). Un agent = **un métier** qui compose plusieurs
**skills** (couche 1) et, plus tard, des **connecteurs MCP**. Peu nombreux, stables, **écrits maison**.

## Skill vs agent — la règle

- **Skill** = savoir-faire atomique et fin (`technical-seo`, `internal-linking`). Se déclenche seul
  par sa `description`.
- **Agent** = posture de métier grossière, censée être bonne sur *tous* ses skills. Il n'redécrit pas
  le détail : il **oriente** (workflow, priorités) et laisse les skills faire le travail fin.

> Si tu hésites : *« savoir-faire précis → skill » ; « métier qui en orchestre plusieurs → agent ».*

## Différence avec les skills vendorés

Les agents **ne sont pas vendorés** (pas d'entrée dans `registry.yml`). On s'inspire de corpus externes
(cf. [ROADMAP §5.2](../ROADMAP.md) : `msitarzewski/agency-agents`, agents de `AgriciDaniel/claude-seo`)
mais on **réécrit** le prompt adapté FR / Creapulse. On cite la source d'inspiration dans le fichier.

## Format d'un agent

Fichier `metier-slug.md` (kebab-case), sous-agent Claude Code : frontmatter + corps = system prompt.

```markdown
---
name: ai-citation-strategist
description: >
  Quand mobiliser cet agent (déclencheur). Rôle en une phrase.
tools: Read, Grep, Glob, WebFetch, WebSearch   # allowlist — omettre = tous les outils
model: inherit                                  # inherit | opus | sonnet | haiku
---

Corps = le system prompt du métier : identité, mission, workflow, skills mobilisés,
connecteurs éventuels, style de sortie.
```

### Conventions

- **Nom** : `metier-slug.md`, kebab-case, `name:` du frontmatter identique au nom de fichier.
- **`description`** : c'est le déclencheur — soigne-la (critère #1 de qualité, cf. ROADMAP §4).
- **`tools`** : allowlist restrictive quand le métier n'a pas besoin d'écrire (audit, conseil).
- **Skills mobilisés** : lister dans le corps les skills que l'agent est censé orchestrer — sans les
  recopier (les skills vivent dans `skills/`).
- **Connecteurs** : documenter ceux que l'agent utilisera plus tard (DataForSEO, Firecrawl…) même si
  pas encore branchés.

## Réutilisabilité hors Claude Code

Le corps d'un agent est un **prompt de rôle** : il se recopie tel quel comme instructions d'un
Projet claude.ai, ou comme system prompt d'un workspace AnythingLLM. Garder le corps autonome
(compréhensible sans le frontmatter) facilite cette réutilisation.

## Agents

| Agent | Statut | Skills mobilisés (cible) |
|---|---|---|
| [ai-citation-strategist](./ai-citation-strategist.md) | squelette | GEO / AEO, on-page, entités, content SEO |
</content>
