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
Write-Host "[1/3] SKILL.md §0 remplacee (porte de branding fermee)"

# ------------------------------------- 2. style-guide.md : tableau + prose de marque

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

Set-Content $sgPath -Value $sg -NoNewline -Encoding UTF8
Write-Host "[2/3] style-guide.md : tokens Creapulse + notes de contraste"

# --------------------------------------------------- 3. remap global des couleurs

# Le style-guide se présente comme "single source of truth", mais les hex sont codés
# en dur partout, templates de génération compris. Editer le tableau ne suffit pas.
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

$files = Get-ChildItem $work -Recurse -Include *.md, *.html -File
$replaced = 0
$touched  = 0

foreach ($f in $files) {
    $txt  = Get-Content $f.FullName -Raw
    $orig = $txt
    foreach ($k in $map.Keys) {
        $n = ([regex]::Matches($txt, [regex]::Escape($k), 'IgnoreCase')).Count
        if ($n -gt 0) {
            $replaced += $n
            $txt = [regex]::Replace($txt, [regex]::Escape($k), $map[$k], 'IgnoreCase')
        }
    }
    if ($txt -ne $orig) {
        Set-Content $f.FullName -Value $txt -NoNewline -Encoding UTF8
        $touched++
    }
}
Write-Host "[3/3] Remap couleurs : $replaced occurrences dans $touched fichiers"
Write-Host ""

# ------------------------------------------------------------------ verifications

$errs = @()

# a. plus aucune couleur de l'ancienne charte
$restes = Select-String -Path (Join-Path $work '*'), (Join-Path $work '**\*') `
    -Pattern ($map.Keys | Where-Object { $_ -like '#*' } | ForEach-Object { $_.TrimStart('#') }) `
    -AllMatches -ErrorAction SilentlyContinue
if ($restes) { $errs += "Couleurs upstream residuelles : $(($restes | Select-Object -First 3 -ExpandProperty Filename) -join ', ')" }

# b. frontmatter intact et conforme aux contraintes de la Skills API
$fm = Get-Content $skillPath -TotalCount 4
if ($fm[0] -ne '---')                  { $errs += "SKILL.md ne commence pas par un frontmatter." }
if ($fm[1] -notmatch '^name: [a-z0-9-]{1,64}$') { $errs += "Frontmatter 'name' non conforme : $($fm[1])" }
$desc = ($fm[2] -replace '^description: ', '')
if ($fm[2] -notmatch '^description: ') { $errs += "Frontmatter 'description' absent." }
elseif ($desc.Length -gt 1024)         { $errs += "Description trop longue : $($desc.Length) > 1024." }

# c. la porte est bien fermee
if ((Get-Content $skillPath -Raw) -notmatch 'gate closed') { $errs += "Section 0 non remplacee." }

# d. les templates de generation portent bien l'accent Creapulse
$tpl = Get-Content (Join-Path $work 'assets\template.html') -Raw
if ($tpl -notmatch '--color-accent:\s*#f83595') { $errs += "assets/template.html ne porte pas l'accent Creapulse." }

if ($errs) {
    $errs | ForEach-Object { Write-Host "  ECHEC : $_" -ForegroundColor Red }
    Fail "$($errs.Count) verification(s) en echec."
}
Write-Host "Verifications : OK (couleurs, frontmatter, porte fermee, templates)" -ForegroundColor Green

# -------------------------------------------------------------------------- zip

if (-not $NoZip) {
    $zip = Join-Path $OutRoot 'diagram-design.zip'
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path $work -DestinationPath $zip
    Write-Host ("Archive : $zip ({0:N2} Mo)" -f ((Get-Item $zip).Length / 1MB)) -ForegroundColor Green
}
