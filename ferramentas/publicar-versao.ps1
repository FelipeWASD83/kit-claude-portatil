# publicar-versao.ps1 - publica a versao atual do kit como release no GitHub. E a release
# que o "irm ... | iex" do instalar.ps1 baixa (releases/latest/download/...).
#
# Antes: subir a versao em versao.json e no CHANGELOG.md, commitar e dar push.
# Precisa do gh logado (gh auth login) com permissao no repositorio.
# PUBLICAR E DECISAO DO DONO DO REPOSITORIO: este script nunca roda sozinho.
#
# Uso, na raiz do projeto:
#   powershell -ExecutionPolicy Bypass -File ".\ferramentas\publicar-versao.ps1"

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

function Rodar([string]$exe, [string[]]$argumentos) {
    # No PowerShell 5.1, com 'Stop', qualquer linha que o git ou o gh escrevam no stderr vira
    # erro fatal, mesmo quando deu certo. Aqui quem decide e o codigo de saida.
    $ErrorActionPreference = 'Continue'
    $saida = & $exe @argumentos 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ codigo = $LASTEXITCODE; saida = (($saida -join "`n").Trim()) }
}

$info = Get-Content (Join-Path $raiz 'versao.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$versao = [string]$info.versao
$repo = [string]$info.repositorio
$changelog = Get-Content (Join-Path $raiz 'CHANGELOG.md') -Raw -Encoding UTF8
if ($changelog -notmatch ('## ' + [regex]::Escape($versao) + ' ')) { throw ('O CHANGELOG.md nao tem a secao da versao ' + $versao + '.') }

if ((Rodar git @('status', '--porcelain')).saida) { throw 'Ha mudancas nao commitadas. Commite antes de publicar.' }
$r = Rodar git @('fetch', '-q', 'origin')
if ($r.codigo -ne 0) { throw ('Nao deu para falar com o GitHub (git fetch): ' + $r.saida) }
$local = (Rodar git @('rev-parse', 'HEAD')).saida
$r = Rodar git @('rev-parse', '@{u}')
if ($r.codigo -ne 0) { throw 'Este ramo nao esta ligado ao GitHub. Rode: git push -u origin main' }
if ($local -ne $r.saida) { throw 'O commit atual ainda nao foi enviado (git push) ou esta atras do GitHub.' }
if ((Rodar gh @('release', 'view', ('v' + $versao), '--repo', $repo)).codigo -eq 0) { throw ('A release v' + $versao + ' ja existe.') }

# notas: so a secao desta versao do CHANGELOG
$linhas = $changelog -split "`r?`n"
$achou = $linhas | Where-Object { $_ -match ('^## ' + [regex]::Escape($versao) + ' ') } | Select-Object -First 1
$inicio = [array]::IndexOf($linhas, $achou)
$notas = @()
for ($i = $inicio + 1; $i -lt $linhas.Length; $i++) {
    if ($linhas[$i] -match '^## ') { break }
    $notas += $linhas[$i]
}
$tmp = Join-Path $env:TEMP ('kit-release-' + $versao)
New-Item -ItemType Directory -Force $tmp | Out-Null
$arqNotas = Join-Path $tmp 'notas.md'
[IO.File]::WriteAllText($arqNotas, (($notas -join "`n").Trim()), (New-Object Text.UTF8Encoding($false)))

# pacote (com a varredura de privacidade dentro)
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'montar-pacote.ps1')
if ($LASTEXITCODE -ne 0) { throw 'O empacotamento falhou.' }
$dist = Join-Path $raiz 'dist'

Write-Host ('Publicando v' + $versao + ' em ' + $repo)
$r = Rodar gh @('release', 'create', ('v' + $versao), (Join-Path $dist 'kit.zip'), (Join-Path $dist 'kit.zip.sha256'),
    (Join-Path $raiz 'instalar.ps1'), '--repo', $repo, '--title', ('kit-claude-portatil ' + $versao),
    '--notes-file', $arqNotas, '--target', $local)
if ($r.codigo -ne 0) { throw ('O gh nao criou a release: ' + $r.saida) }
Write-Host $r.saida
Write-Host 'Pronto. O comando de instalacao ja baixa esta versao.'
