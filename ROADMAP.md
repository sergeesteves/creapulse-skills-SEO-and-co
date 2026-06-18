# ROADMAP — Librairie de skills Claude marketing (SEO & co)

> Repo : `sergeesteves/creapulse-skills-SEO-and-co` — monorepo privé.
> Objectif : constituer et **maintenir dans le temps** une librairie de skills Claude Code
> orientés marketing (SEO en cœur, + analytics, content, social, UX, design, CRO, landing pages),
> curatés depuis GitHub, vendorisés proprement, normalisés, puis maintenus via deux veilles.

Statut : **planification** (rien n'est encore construit). Dernière mise à jour : 2026-06-18.

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

## 1. Cartographie des besoins en skills

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

## 2. Critères de sélection « les meilleurs sur GitHub »

Filtres pour qualifier un candidat :
- Commits **récents** (repo maintenu, pas abandonné)
- **Qualité de la `description` frontmatter** = qualité du déclenchement (critère #1 en pratique)
- **Responsabilité unique** (un skill = une tâche claire, pas un couteau suisse)
- **Licence permissive** (MIT/Apache) — à tracer dans le manifeste
- Pas de dépendances lourdes / exotiques
- Lisibilité du prompt et des instructions

> La curation déjà faite par Serge sert de point de départ ; ces critères servent à
> trancher entre candidats et à écarter les faux-bons.

---

## 3. Architecture du repo (monorepo)

```
creapulse-skills-SEO-and-co/
├── README.md
├── ROADMAP.md                ← ce fichier
├── registry.yml              ← manifeste de provenance (colonne vertébrale)
├── LICENSE
├── docs/
│   ├── selection-criteria.md
│   ├── naming-conventions.md  ← normalisation frontmatter / nommage
│   └── maintenance.md         ← procédure des 2 veilles
├── skills/
│   ├── seo/
│   │   ├── internal-linking/
│   │   ├── technical/
│   │   └── ...
│   ├── analytics/
│   ├── content/
│   ├── social/
│   ├── ux/
│   ├── design/
│   ├── cro/
│   └── landing-pages/
└── overlays/                 ← nos patches/améliorations séparés du code upstream
```

Décision actée : **monorepo unique** (plus simple à maintenir et à synchroniser qu'un repo par domaine).

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

## 4. Phases d'exécution (ordre d'attaque)

### Phase 0 — Fondations
- [ ] Repo créé (privé) ✅ *(fait)*
- [ ] Cartographie fine validée (taxonomie sans recouvrements)
- [ ] `selection-criteria.md` + `naming-conventions.md` rédigés
- [ ] Squelette `registry.yml` + arborescence `skills/`
- [ ] Choix licence du repo + politique d'attribution upstream

### Phase 1 — Domaine pilote (rôder le process de bout en bout)
> Ne PAS industrialiser avant d'avoir rodé un domaine complet. Pilote suggéré : **SEO / internal-linking**
> ou **SEO technical**.
- [ ] Sélection des candidats du domaine pilote
- [ ] Copie (vendoring) + remplissage `registry.yml` (avec SHA)
- [ ] Revue commune de ce que fait chaque skill
- [ ] Améliorations immédiates (dans `overlays/`) + backlog d'améliorations futures
- [ ] Test de déclenchement (via `skill-creator` / evals)

### Phase 2 — Normalisation & packaging
- [ ] Passe d'harmonisation frontmatter / nommage / descriptions (anti-collision)
- [ ] Packaging en **plugin / marketplace Claude Code** (installable + synchronisable sur toutes machines)
- [ ] Versioning + CHANGELOG de notre librairie

### Phase 3 — Extension
- [ ] Dérouler le process rodé sur les autres sous-domaines SEO, puis domaines adjacents
- [ ] Mise à jour continue du manifeste

### Phase 4 — Automatisation de la maintenance (2 veilles distinctes)
> Règle d'or : les veilles **proposent**, Serge valide. **Jamais d'auto-merge.**

- [ ] **Veille upstream** (routine planifiée / cron) :
      diff `source_sha → HEAD` de chaque repo `tracked` → résumé des changements significatifs → propose des PR.
- [ ] **Veille web** (routine planifiée) :
      nouveautés Google / SEO / GA4 / GEO… → propose des évolutions des skills concernés.
- [ ] Sortie des deux veilles : un rapport + des propositions, à valider manuellement.

---

## 5. Points de gouvernance / risques

- **Modifs locales vs sync** : garder nos améliorations dans `overlays/` (patch séparé) pour ne pas les
  perdre au prochain sync upstream.
- **Licences & attribution** : copier le code d'autrui a des implications → tracées dans `registry.yml`.
- **Infra** : le clone local vit **hors Google Drive** (`C:\Users\serge\dev\…`) — un `.git` dans Drive
  se corrompt (sync partielle, locks). GitHub = la sauvegarde cloud.
- **Collisions de déclenchement** : le vrai risque qualité du projet → discipline sur les `description`.

---

## 6. Décisions ouvertes (à trancher en Phase 0)

- Licence du repo (rester privé ? quelle licence si un jour public ?)
- Packaging plugin : un seul plugin global ou un plugin par domaine ?
- Cadence des veilles (hebdo ? mensuel ?) et canal de notification (Slack ? mail ?)
