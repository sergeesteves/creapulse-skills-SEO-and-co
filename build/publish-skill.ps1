# Publie un skill du monorepo vers la Skills API d'Anthropic.
#
# Pipeline générique :
#   1. si build/<skill>/apply.ps1 existe   -> on le joue, on publie dist/<skill>.zip
#      sinon                                -> on zippe skills/<skill> tel quel
#   2. premier envoi  : POST /v1/skills                       -> crée le skill, renvoie un skill_id
#      envois suivants: POST /v1/skills/<id>/versions         -> ajoute une version immuable
#   3. le skill_id est mémorisé dans build/skill-ids.json (identifiant, pas un secret)
#
# Les consommateurs qui demandent version: "latest" (workflows n8n) suivent sans rien changer.
#
#   $env:ANTHROPIC_API_KEY = 'sk-ant-...'
#   pwsh build/publish-skill.ps1 -Skill diagram-design
#   pwsh build/publish-skill.ps1 -Skill diagram-design -DryRun

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Skill,
    [string] $SkillId,
    [switch] $DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$idsPath  = Join-Path $PSScriptRoot 'skill-ids.json'
$curl     = if ($IsWindows) { 'curl.exe' } else { 'curl' }

function Fail($msg) { throw "[publish-skill] $msg" }

if (-not $DryRun -and -not $env:ANTHROPIC_API_KEY) {
    Fail "ANTHROPIC_API_KEY absent de l'environnement."
}

$skillDir = Join-Path $repoRoot "skills/$Skill"
if (-not (Test-Path (Join-Path $skillDir 'SKILL.md'))) { Fail "skills/$Skill/SKILL.md introuvable." }

# ------------------------------------------------------------------ 1. artefact

$applyPath = Join-Path $PSScriptRoot "$Skill/apply.ps1"
$distRoot  = Join-Path $repoRoot 'dist'

if (Test-Path $applyPath) {
    Write-Host "Transformation trouvee : build/$Skill/apply.ps1" -ForegroundColor Cyan
    # apply.ps1 est en ErrorActionPreference=Stop : toute ancre manquante leve
    # une exception qui remonte ici et interrompt la publication.
    & $applyPath
    $zip = Join-Path $distRoot "$Skill.zip"
} else {
    Write-Host "Pas de transformation : publication de skills/$Skill tel quel" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $distRoot | Out-Null
    $zip = Join-Path $distRoot "$Skill.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path $skillDir -DestinationPath $zip
}

if (-not (Test-Path $zip)) { Fail "Archive attendue introuvable : $zip" }
$sizeMb = (Get-Item $zip).Length / 1MB
Write-Host ("Archive : $zip ({0:N2} Mo)" -f $sizeMb)
if ($sizeMb -gt 30) { Fail "Archive > 30 Mo, au-dela de la limite de la Skills API." }

# --------------------------------------------------------------- 2. skill_id connu ?

$ids = if (Test-Path $idsPath) { Get-Content $idsPath -Raw | ConvertFrom-Json -AsHashtable } else { @{} }
if (-not $SkillId -and $ids.ContainsKey($Skill)) { $SkillId = $ids[$Skill] }

if ($DryRun) {
    $cible = if ($SkillId) { "nouvelle version de $SkillId" } else { "creation d'un nouveau skill" }
    Write-Host "[dry-run] Rien d'envoye. Cible : $cible" -ForegroundColor Yellow
    return
}

# ------------------------------------------------------------------ 3. publication

$url = if ($SkillId) {
    "https://api.anthropic.com/v1/skills/$SkillId/versions"
} else {
    "https://api.anthropic.com/v1/skills"
}
Write-Host "POST $url"

$raw = & $curl -s -X POST $url `
    -H "x-api-key: $env:ANTHROPIC_API_KEY" `
    -H "anthropic-version: 2023-06-01" `
    -H "anthropic-beta: skills-2025-10-02" `
    -F "files[]=@$zip"

$res = $raw | ConvertFrom-Json
if ($res.PSObject.Properties.Name -contains 'error') {
    Write-Host ($res.error | ConvertTo-Json -Depth 6) -ForegroundColor Red
    Fail "L'API a rejete la publication."
}

# Creation -> l'id est sur la racine ; nouvelle version -> l'id du skill parent.
$newId = if ($res.PSObject.Properties.Name -contains 'id' -and -not $SkillId) { $res.id } else { $SkillId }
$ver   = if ($res.PSObject.Properties.Name -contains 'latest_version') { $res.latest_version } `
         elseif ($res.PSObject.Properties.Name -contains 'version')     { $res.version } else { '(inconnue)' }

Write-Host ""
Write-Host "Publie." -ForegroundColor Green
Write-Host "  skill_id : $newId"
Write-Host "  version  : $ver"

if ($newId -and (-not $ids.ContainsKey($Skill) -or $ids[$Skill] -ne $newId)) {
    $ids[$Skill] = $newId
    $ids | ConvertTo-Json -Depth 3 | Set-Content $idsPath -Encoding UTF8
    Write-Host "  build/skill-ids.json mis a jour"
}

Write-Host ""
Write-Host "Les workflows n8n en version:'latest' prennent cette version sans modification." -ForegroundColor Yellow
