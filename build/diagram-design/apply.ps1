# Transformation Creapulse de la skill diagram-design.
#
# Principe : skills/diagram-design/ reste une COPIE CONFORME de l'upstream (tracking: tracked).
# Nos modifications vivent ici, sous forme de transformation rejouable. On ne modifie
# jamais la copie vendorisée — on produit un artefact dans dist/.
#
# Toute ancre qui ne matche plus = ERREUR BLOQUANTE, jamais un silence.
# C'est voulu : si l'upstream déplace le texte, le build casse et Serge relit.
#
#   pwsh build/diagram-design/apply.ps1
#   pwsh build/diagram-design/apply.ps1 -NoZip     # pour inspecter dist/ sans zipper

[CmdletBinding()]
param(
    [string] $Source,
    [string] $OutRoot,
    [switch] $NoZip
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Source)  { $Source  = Join-Path $repoRoot 'skills\diagram-design' }
if (-not $OutRoot) { $OutRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'creapulse-skill-build' }  # hors Google Drive (evite les locks de sync)

$fragments = $PSScriptRoot
$work      = Join-Path $OutRoot 'diagram-design'

function Fail($msg) { throw "[apply.ps1] $msg" }

# ---------------------------------------------------------------- 0. préparation

if (-not (Test-Path (Join-Path $Source 'SKILL.md'))) { Fail "Source introuvable : $Source" }

New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
Copy-Item $Source $work -Recurse

Write-Host "Source  : $Source"
Write-Host "Sortie  : $work"
Write-Host ""

# --------------------------------------------- 1. SKILL.md : neutraliser la porte

# Upstream §0 déclenche une question à l'utilisateur ("veux-tu personnaliser la charte ?").
# Insoluble en exécution non interactive : on remplace la section entière.

$skillPath = Join-Path $work 'SKILL.md'
$skill     = Get-Content $skillPath -Raw

$reSection0 = '(?s)## 0\..*?(?=\r?\n---\r?\n\r?\n## 1\. )'
$m0 = [regex]::Match($skill, $reSection0)
if (-not $m0.Success) {
    Fail "Ancre §0 introuvable dans SKILL.md. L'upstream a restructure ses sections — relire avant de rejouer."
}

# On ne se contente pas de trouver "une section 0" : on verifie que c'est bien LA porte
# de branding. Sinon un upstream qui remplacerait §0 par autre chose se ferait ecraser
# en silence. Signature attendue : le renvoi au style guide + la mise en pause.
$signature = @('style-guide.md', 'ask the user')
$manquants = $signature | Where-Object { $m0.Value -notlike "*$_*" }
if ($manquants) {
    Fail ("La section 0 trouvee ne ressemble plus a la porte de branding (absent : " +
          ($manquants -join ', ') +
          "). L'upstream l'a probablement remplacee par autre chose — relire SKILL.md avant de rejouer.")
}

$section0 = (Get-Content (Join-Path $fragments 'section-0.md') -Raw).TrimEnd()
$skill    = [regex]::Replace($skill, $reSection0, { $section0 }, 'Singleline')

Set-Content $skillPath -Value $skill -NoNewline -Encoding UTF8
Write-Host "[1/5] SKILL.md : porte de branding fermee"

# ------------------------------- 2. style-guide.md : couleurs, prose, typographie

$sgPath = Join-Path $work 'references\style-guide.md'
$sg     = Get-Content $sgPath -Raw

# 2a. phrase d'introduction
$introFrom = 'Default skin is a cool editorial palette — white-smoke paper, jet-black ink, atomic-tangerine accent, blue-slate muted. It''s designed to look good out of the box; swap these values'
$introTo   = 'Active skin is the **Creapulse** palette — light-grey paper, dark-grey ink, creapulse-pink accent, neutral-grey muted, creapulse-blue links. Swap these values'
if ($sg -notlike "*$introFrom*") { Fail "Ancre 'intro style-guide' introuvable dans references/style-guide.md." }
$sg = $sg.Replace($introFrom, $introTo)

# 2b. tableau des roles semantiques + encart de provenance
$reTokens = '(?s)\| `paper` \| Page background.*?(?=\r?\n\r?\n> \*\*Note:\*\* The pre-baked)'
if (-not [regex]::IsMatch($sg, $reTokens)) {
    Fail "Ancre 'tableau des tokens' introuvable dans references/style-guide.md."
}
$tokens = (Get-Content (Join-Path $fragments 'style-guide-tokens.md') -Raw).TrimEnd()
$sg     = [regex]::Replace($sg, $reTokens, { $tokens }, 'Singleline')

# 2c. section Typography : trois roles en polices systeme + planchers de taille
$reTypo = '(?s)## Typography.*?(?=\r?\n---\r?\n\r?\n## Stroke)'
if (-not [regex]::IsMatch($sg, $reTypo)) {
    Fail "Ancre 'section Typography' introuvable dans references/style-guide.md."
}
$typo = (Get-Content (Join-Path $fragments 'typography.md') -Raw).TrimEnd()
$sg   = [regex]::Replace($sg, $reTypo, { $typo }, 'Singleline')

Set-Content $sgPath -Value $sg -NoNewline -Encoding UTF8
Write-Host "[2/5] style-guide.md : tokens Creapulse + typographie systeme"

# --------------------------- 3. output-spec.md : canevas 720 + ramp typographique

# Le SVG s'affiche en width:100% dans une colonne d'article (~720px). Dessine a 1280,
# il est reduit de 44% : un libelle a 12px sort a 6,8px a l'ecran. On dessine donc a
# 720 pour que l'unite SVG vaille un pixel, et on remonte les planchers a 14 / 12.

$osPath = Join-Path $work 'references\output-spec.md'
$os     = Get-Content $osPath -Raw

$reDocInline = '(?m)^\| `doc-inline` \(default\) \|.*$'
if (-not [regex]::IsMatch($os, $reDocInline)) {
    Fail "Ancre 'ligne doc-inline' introuvable dans references/output-spec.md."
}
$lignesPreset = @(
    '| `creapulse-article` (**default**) | `0 0 720 <fit>` | width fixed at 720, height from content | @2 | creapulse | **Article column. Rendered 1:1 — one SVG unit is one screen pixel.** |'
    '| `doc-inline` | `0 0 960 600` | 8:5 | 1920x1200 | standard | Body-width diagram in a post or README |'
) -join [Environment]::NewLine
$os = [regex]::Replace($os, $reDocInline, { $lignesPreset })

$reRamp = '(?s)\| Role \| standard \| presentation \| print \|.*?\| Min gap between nodes \|[^\r\n]*'
if (-not [regex]::IsMatch($os, $reRamp)) {
    Fail "Ancre 'type ramp' introuvable dans references/output-spec.md."
}
$ramp = @(
    '| Role | **creapulse** | standard | presentation | print |'
    '|---|---|---|---|---|'
    '| Title (serif) | **22** | 28 | 40 | 32 |'
    '| Node name (sans 600) | **14** | 12 | 16 | 12 |'
    '| Sublabel (mono) | **12** | 9 | 12 | 9 |'
    '| Arrow label (mono) | **12** | 8 | 12 | 8 |'
    '| Eyebrow / tag (mono) | **12** | 8 | 8 | 8 |'
    '| Node box min height | **56** | 48 | 64 | 48 |'
    '| Min gap between nodes | **24** | 24 | 40 | 24 |'
    ''
    'The `creapulse` ramp is expressed in **real screen pixels**. The canvas is 720 wide and'
    'the SVG is displayed at 100% width in a column of roughly that size, so no downscaling'
    'happens. 14px and 12px are hard floors — never shrink type to win space.'
    ''
    '**Consequence — orientation.** At 720 wide, a six-step process laid out horizontally'
    'cannot hold 14px labels. Stack it vertically instead. Wide horizontal layouts belong to'
    'the larger presets, not to the article column.'
) -join [Environment]::NewLine
$os = [regex]::Replace($os, $reRamp, { $ramp }, 'Singleline')

Set-Content $osPath -Value $os -NoNewline -Encoding UTF8
Write-Host "[3/5] output-spec.md : preset creapulse-article (720) + planchers 14/12"

# ------------------------------------------ 4. remap global couleurs + polices

# Le style-guide se présente comme "single source of truth", mais les hex et les familles
# sont codés en dur partout, templates de génération compris. Editer les tableaux ne suffit pas.
#
# Ordre sans collision : aucune valeur cible n'apparaît parmi les sources.
# Volontairement NON remappés : la palette de séries des graphiques multi-séries
# (registre désaturé séparé) et le skin terminal opt-in (#ff5a36).

$map = [ordered]@{
    '#4f5d75'          = '#5f6368'            # muted (clair)
    '#2d3142'          = '#2e2e2e'            # ink clair / paper sombre
    '#bfc0c0'          = '#c4c4c4'            # silver : muted sombre / rule-solid clair
    '#eb6c36'          = '#f83595'            # accent (clair)
    '#f08a59'          = '#fb5faa'            # accent (sombre)
    '#7a8399'          = '#8a8d91'            # soft (clair)
    '#2e5aa8'          = '#0284c7'            # link (clair)
    '#6a95d8'          = '#029ae5'            # link (sombre)
    '#393e53'          = '#3a3a3a'            # paper-2 (sombre)
    '#8e98ac'          = '#8e8e8e'            # soft (sombre)
    '#3d4460'          = '#3d3d3d'            # surface sombre
    '#4a5270'          = '#4a4a4a'            # surface sombre
    'rgba(45,49,66'    = 'rgba(46,46,46'      # ink @ opacite
    'rgba(79,93,117'   = 'rgba(95,99,104'     # muted @ opacite
    'rgba(122,131,153' = 'rgba(138,141,145'   # soft @ opacite
    'rgba(142,152,172' = 'rgba(142,142,142'   # soft sombre @ opacite
    'rgba(235,108,54'  = 'rgba(248,53,149'    # accent clair @ opacite
    'rgba(240,138,89'  = 'rgba(251,95,170'    # accent sombre @ opacite
    'rgba(191,192,192' = 'rgba(196,196,196'   # silver @ opacite
    'rgba(28,25,23'    = 'rgba(46,46,46'      # ink legacy @ opacite
    'rgba(250,247,242' = 'rgba(245,245,245'   # paper legacy @ opacite
}

# Polices systeme : rien a telecharger, rien a enqueue cote WordPress.
$sans  = "'Open Sans', system-ui, -apple-system, 'Segoe UI', Roboto, Arial, sans-serif"
$mono  = "ui-monospace, SFMono-Regular, Menlo, Consolas, 'Liberation Mono', monospace"
$serif = "Georgia, 'Times New Roman', serif"

# ORDRE CRITIQUE : "Geist Mono" AVANT "Geist", sinon les 1490 occurrences du mono
# deviendraient "<pile sans> Mono". Remplacement en respectant la casse.
$fonts = [ordered]@{
    "'Geist Mono', monospace"   = $mono
    '"Geist Mono", monospace'   = $mono
    "'Geist Mono'"              = $mono
    '"Geist Mono"'              = $mono
    'Geist Mono'                = 'mono'
    "'Instrument Serif', serif" = $serif
    '"Instrument Serif", serif' = $serif
    "'Instrument Serif'"        = $serif
    '"Instrument Serif"'        = $serif
    'Instrument Serif'          = 'serif'
    "'Geist', sans-serif"       = $sans
    '"Geist", sans-serif'       = $sans
    "'Geist'"                   = $sans
    '"Geist"'                   = $sans
    'Geist'                     = 'sans'
}

# Le remap laisse les fallbacks d'origine derriere la nouvelle pile
# ("...Arial, sans-serif, system-ui, sans-serif"). Inoffensif en CSS mais negligé :
# on recolle. Variantes longues avant les courtes.
$nettoyage = [ordered]@{
    'monospace, ui-monospace, Menlo, monospace' = 'monospace'
    'monospace, ui-monospace, monospace'        = 'monospace'
    'monospace,ui-monospace,monospace'          = 'monospace'
    'sans-serif, system-ui, sans-serif'         = 'sans-serif'
    'sans-serif,system-ui,sans-serif'           = 'sans-serif'
    "serif, 'Times New Roman', serif"           = 'serif'
}

$files    = Get-ChildItem $work -Recurse -Include *.md, *.html -File
$rCouleur = 0
$rPolice  = 0
$rLien    = 0
$touched  = 0

foreach ($f in $files) {
    $txt  = Get-Content $f.FullName -Raw
    $orig = $txt

    # Les references Google Fonts partent en premier : leurs URLs contiennent
    # "Geist+Mono" et "Instrument+Serif", que le remap ci-dessous mutilerait.
    # Et la skill ne doit plus emettre aucun chargement de police.
    $motifsLien = @(
        '(?i)<link[^>]*fonts\.googleapis\.com[^>]*>\s*'
        "(?i)@import\s+url\([^)]*fonts\.googleapis\.com[^)]*\);?"
        '(?i)<link[^>]*fonts\.gstatic\.com[^>]*>\s*'
    )
    foreach ($m in $motifsLien) {
        $n = ([regex]::Matches($txt, $m)).Count
        if ($n -gt 0) { $rLien += $n; $txt = [regex]::Replace($txt, $m, '') }
    }

    foreach ($k in $map.Keys) {
        $n = ([regex]::Matches($txt, [regex]::Escape($k), 'IgnoreCase')).Count
        if ($n -gt 0) {
            $rCouleur += $n
            $txt = [regex]::Replace($txt, [regex]::Escape($k), $map[$k], 'IgnoreCase')
        }
    }

    foreach ($k in $fonts.Keys) {
        $n = ([regex]::Matches($txt, [regex]::Escape($k))).Count   # casse respectee
        if ($n -gt 0) {
            $rPolice += $n
            $txt = $txt.Replace($k, $fonts[$k])
        }
    }

    foreach ($k in $nettoyage.Keys) {
        if ($txt.Contains($k)) { $txt = $txt.Replace($k, $nettoyage[$k]) }
    }

    if ($txt -ne $orig) {
        Set-Content $f.FullName -Value $txt -NoNewline -Encoding UTF8
        $touched++
    }
}
Write-Host "[4/5] Remap : $rCouleur couleurs, $rPolice polices, $rLien liens de police retires ($touched fichiers)"

# ------------------------------------------------------------------ verifications

Write-Host ""
$errs = @()

# a. plus aucune couleur de l'ancienne charte
$restes = Select-String -Path (Join-Path $work '*'), (Join-Path $work '**\*') `
    -Pattern ($map.Keys | Where-Object { $_ -like '#*' } | ForEach-Object { $_.TrimStart('#') }) `
    -AllMatches -ErrorAction SilentlyContinue
if ($restes) { $errs += "Couleurs upstream residuelles : $(($restes | Select-Object -First 3 -ExpandProperty Filename) -join ', ')" }

# b. plus aucune police upstream, ni chargement distant
$restesF = Select-String -Path (Join-Path $work '*'), (Join-Path $work '**\*') `
    -Pattern 'Geist', 'Instrument Serif' -CaseSensitive -AllMatches -ErrorAction SilentlyContinue
if ($restesF) { $errs += "Polices upstream residuelles : $(($restesF | Select-Object -First 3 -ExpandProperty Filename) -join ', ')" }

# On cible le CHARGEMENT, pas la mention : self_check.py nomme legitimement le
# domaine dans sa liste blanche, et onboarding.md en parle en prose.
$restesL = Select-String -Path (Join-Path $work '*'), (Join-Path $work '**\*') `
    -Pattern '<link[^>]*fonts\.googleapis', '@import[^;]*fonts\.googleapis' -AllMatches -ErrorAction SilentlyContinue
if ($restesL) { $errs += "Chargement de police residuel : $(($restesL | Select-Object -First 3 -ExpandProperty Filename) -join ', ')" }

# c. frontmatter intact et conforme aux contraintes de la Skills API
$fm = Get-Content $skillPath -TotalCount 4
if ($fm[0] -ne '---')                  { $errs += "SKILL.md ne commence pas par un frontmatter." }
if ($fm[1] -notmatch '^name: [a-z0-9-]{1,64}$') { $errs += "Frontmatter 'name' non conforme : $($fm[1])" }
$desc = ($fm[2] -replace '^description: ', '')
if ($fm[2] -notmatch '^description: ') { $errs += "Frontmatter 'description' absent." }
elseif ($desc.Length -gt 1024)         { $errs += "Description trop longue : $($desc.Length) > 1024." }

# d. la porte est bien fermee
if ((Get-Content $skillPath -Raw) -notmatch 'gate closed') { $errs += "Section 0 non remplacee." }

# e. les templates de generation portent la charte ET la pile systeme
$tpl = Get-Content (Join-Path $work 'assets\template.html') -Raw
if ($tpl -notmatch '--color-accent:\s*#f83595')    { $errs += "assets/template.html ne porte pas l'accent Creapulse." }
if ($tpl -notmatch [regex]::Escape("'Open Sans'")) { $errs += "assets/template.html ne porte pas la pile de polices systeme." }

# f. le canevas 720 et les planchers sont en place
$osFinal = Get-Content $osPath -Raw
if ($osFinal -notmatch 'creapulse-article')                       { $errs += "output-spec.md : preset creapulse-article absent." }
if ($osFinal -notmatch '\| Node name \(sans 600\) \| \*\*14\*\*') { $errs += "output-spec.md : ramp creapulse absent." }

if ($errs) {
    $errs | ForEach-Object { Write-Host "  ECHEC : $_" -ForegroundColor Red }
    Fail "$($errs.Count) verification(s) en echec."
}
Write-Host "[5/5] Verifications OK : couleurs, polices, chargements, frontmatter, porte, templates, canevas" -ForegroundColor Green

# -------------------------------------------------------------------------- zip

if (-not $NoZip) {
    $zip = Join-Path $OutRoot 'diagram-design.zip'
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path $work -DestinationPath $zip
    Write-Host ("Archive : $zip ({0:N2} Mo)" -f ((Get-Item $zip).Length / 1MB)) -ForegroundColor Green
}
