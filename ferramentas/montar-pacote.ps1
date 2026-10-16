# montar-pacote.ps1 - gera dist\kit.zip (o pacote que o instalar.ps1 baixa), o
# dist\kit.zip.sha256 e copia o instalar.ps1 para dist\. Nada disso e versionado
# (dist\ esta no .gitignore): o pacote e gerado na hora, como manda a regra 4 da pasta.
#
# Uso, na raiz do projeto:
#   powershell -ExecutionPolicy Bypass -File ".\ferramentas\montar-pacote.ps1"
#
# Antes de empacotar roda a varredura de privacidade (ferramentas\verificar-privacidade.py):
# achou termo proibido, nao gera pacote.

param([string]$Saida)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $Saida) { $Saida = Join-Path $raiz 'dist' }

$info = Get-Content (Join-Path $raiz 'versao.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$versao = [string]$info.versao

# 1. varredura de privacidade da pasta de conteudo
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { throw 'python nao encontrado: preciso dele para a varredura de privacidade.' }
& $py.Source -I (Join-Path $PSScriptRoot 'verificar-privacidade.py')
if ($LASTEXITCODE -ne 0) { throw 'A varredura de privacidade achou problema. Nao gerei o pacote.' }

# 2. zip com barras normais (o Compress-Archive do 5.1 grava barra invertida)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path $Saida) { Remove-Item $Saida -Recurse -Force }
New-Item -ItemType Directory -Force $Saida | Out-Null
$zip = Join-Path $Saida 'kit.zip'

$arquivos = @()
$arquivos += Get-ChildItem -LiteralPath (Join-Path $raiz 'conteudo') -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\__pycache__\\' -and $_.Extension -ne '.pyc' -and $_.Name -notlike '.backup-*' }

$fs = [System.IO.File]::Open($zip, [System.IO.FileMode]::Create)
$arq = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    # O versao.json do pacote leva so a versao: o endereco do repositorio e do dono, nao do pacote.
    $entrada = $arq.CreateEntry('versao.json', [System.IO.Compression.CompressionLevel]::Optimal)
    $w = New-Object System.IO.StreamWriter($entrada.Open(), (New-Object System.Text.UTF8Encoding($false)))
    try { $w.Write('{ "versao": "' + $versao + '" }' + "`n") } finally { $w.Dispose() }
    foreach ($f in $arquivos) {
        $nome = $f.FullName.Substring($raiz.TrimEnd('\').Length).TrimStart('\').Replace('\', '/')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arq, $f.FullName, $nome, [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally { $arq.Dispose(); $fs.Dispose() }

# 3. SHA-256 e o instalador ao lado
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
[System.IO.File]::WriteAllText((Join-Path $Saida 'kit.zip.sha256'), ($hash + '  kit.zip' + "`n"), (New-Object System.Text.UTF8Encoding($false)))
Copy-Item (Join-Path $raiz 'instalar.ps1') (Join-Path $Saida 'instalar.ps1')

$mb = [math]::Round((Get-Item $zip).Length / 1MB, 1)
Write-Host ('Pacote da versao ' + $versao + ': ' + ($arquivos.Count + 1) + ' arquivos, ' + $mb + ' MB') -ForegroundColor Green
Write-Host ('  ' + $zip)
Write-Host ('  SHA-256 ' + $hash)
