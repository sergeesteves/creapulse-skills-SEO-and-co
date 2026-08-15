# build/ — de git vers la Skills API d'Anthropic

Chaîne de publication des skills du monorepo vers l'API Anthropic, pour qu'ils soient
consommables depuis n8n (ou n'importe quel appel `/v1/messages`) **sans infra Claude Code**.

```
skills/<nom>/            copie conforme de l'upstream (ou skill maison)
build/<nom>/apply.ps1    nos modifications, sous forme de transformation rejouable
        ↓
dist/<nom>.zip           artefact de build (non versionné)
        ↓
Skills API               POST /v1/skills[/<id>/versions]  → version immuable
        ↓
n8n                      container.skills[{ skill_id, version: "latest" }]
```

## Le principe : versionner la transformation, pas le résultat

Quand on modifie lourdement un skill vendorisé, la tentation est d'éditer directement la copie
sous `skills/`. C'est un aller simple vers le **fork dur** : au prochain bump de `source_sha`,
le diff upstream est noyé sous nos propres modifications et devient illisible. On arrête alors
de suivre l'upstream, et on perd ses corrections.

D'où la règle : **`skills/<nom>/` reste une copie conforme.** Nos modifications vivent dans
`build/<nom>/` sous forme de script + fragments, et sont rejouées à chaque build.

Conséquence pratique : un bump de `source_sha` produit un diff qui ne contient que les vrais
changements de l'upstream. On relit, on rejoue la transformation, on republie.

C'est ce que trace le champ `transform:` de `registry.yml`.

## Utilisation

```bash
pwsh build/publish-skill.ps1 -Skill diagram-design -DryRun
```

```bash
pwsh build/publish-skill.ps1 -Skill diagram-design
```

Le script :
1. joue `build/<nom>/apply.ps1` s'il existe, sinon zippe `skills/<nom>` tel quel ;
2. crée le skill au premier envoi, ajoute une **version immuable** ensuite ;
3. mémorise le `skill_id` dans `skill-ids.json` (identifiant, pas un secret — versionné).

Les consommateurs qui demandent `version: "latest"` suivent **sans aucune modification**.
Un workflow de prod peut au contraire épingler une version précise.

## Écrire une transformation

Un `apply.ps1` doit respecter trois règles :

- **Ne jamais écrire dans `skills/`.** Il copie vers `dist/` et travaille sur la copie.
- **Échouer bruyamment.** Toute ancre de texte qui ne matche plus est une erreur bloquante,
  jamais un silence. Si l'upstream déplace le texte, le build casse — c'est le signal qu'il
  faut relire avant de republier.
- **Vérifier son propre résultat.** Contrôles de sortie avant de zipper (voir
  `diagram-design/apply.ps1` : résidus de couleurs, frontmatter conforme aux contraintes de
  l'API, section neutralisée, templates effectivement rebrandés).

## Contraintes de la Skills API

- `SKILL.md` à la racine d'un dossier dont le nom correspond au skill.
- Frontmatter : `name` (≤64 car., minuscules/chiffres/tirets) et `description` (≤1024 car.).
- Archive < 30 Mo décompressée.
- Header `anthropic-beta: skills-2025-10-02`.
- Côté `/v1/messages` : outil `code_execution` obligatoire, **8 skills max par requête**.

## Ce que le conteneur d'exécution ne sait pas faire

À garder en tête en écrivant ou en vendorisant un skill destiné à cette chaîne :

- **Pas de réseau.** Tout skill qui va chercher une URL (onboarding depuis un site, appel
  d'API tierce) échouera. C'est pour ça que la charte de `diagram-design` est figée au build.
- **Pas d'interaction.** Un skill qui pose une question à l'utilisateur bloque. Il faut
  neutraliser la question dans le skill lui-même, pas dans le prompt appelant — sinon chaque
  appelant doit s'en souvenir.
- **Pas de navigateur headless.** Screenshots, export PNG et rendu de page ne passent pas.
