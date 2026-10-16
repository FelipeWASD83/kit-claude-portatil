# checar-pasta.ps1 - confere se a pasta ainda bate com o que o CLAUDE.md diz.
#
# O QUE FAZ: so olha e relata. NAO move, NAO apaga, NAO renomeia e NAO commita.
#
# Existe porque a documentacao envelhece calada: projeto novo entra na pasta e
# ninguem lembra de por no mapa nem no launch.json, e a partir dai toda sessao
# comeca com informacao errada.
#
# COMO USAR: no PowerShell, dentro da pasta raiz:
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\checar-pasta.ps1"

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

$problemas = 0
function Alerta($txt) {
    Write-Host ('  ' + $txt) -ForegroundColor Yellow
    $script:problemas++
}
function Titulo($txt) {
    Write-Host ''
    Write-Host $txt -ForegroundColor Cyan
}

# Arquivos que podem ficar soltos na raiz. Qualquer outro e violacao da regra 2.
$raizPermitida = @('CLAUDE.md', 'PORTAS.md', 'LEIA-PRIMEIRO.md',
                   '.gitignore', 'README.md', '.gitattributes')

# Pastas que nao sao projeto.
$infra = @('_REVISAR', '_organizacao')

# Pacotes que ele decidiu manter onde estao. Caminho relativo a raiz, com o
# motivo e a data - sem isso o script vira ruido e ninguem olha mais.
$pacotesOk = @{
    # 'projeto\pasta\arquivo.zip' = 'motivo - decisao dele em AAAA-MM-DD'
}

# Pastas que nao devem ser vasculhadas nem cobradas (privadas, ou conteudo que
# nao e codigo). Manter o motivo escrito - excecao sem motivo vira pendencia
# falsa toda vez que alguem roda isto aqui.
$naoCobrar = @{
    # 'nome-da-pasta' = 'projeto pessoal privado - nao abrir, nao indexar'
}

$projetos = Get-ChildItem -Directory |
    Where-Object { $_.Name -notlike '.*' -and $infra -notcontains $_.Name } |
    Sort-Object Name

Write-Host ('Checando ' + $raiz) -ForegroundColor White
Write-Host ($projetos.Count.ToString() + ' pastas de projeto') -ForegroundColor DarkGray

# ---------------------------------------------------------------- 1. raiz limpa
Titulo '1) Arquivo solto na raiz (regra 2)'
$soltos = Get-ChildItem -File | Where-Object { $raizPermitida -notcontains $_.Name }
if ($soltos) {
    foreach ($f in $soltos) { Alerta ($f.Name + ' - nao pertence a nenhum projeto') }
}
else { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- 2. nomes
Titulo '2) Nome de pasta fora do padrao (regra 3)'
$achouNome = $false
foreach ($p in $projetos) {
    $n = $p.Name
    $motivo = $null
    if ($n -match '\s')            { $motivo = 'tem espaco' }
    elseif ($n -match '[()\[\]]')  { $motivo = 'tem parentese ou colchete' }
    elseif ($n -match '_\d+$')     { $motivo = 'sufixo de download repetido' }
    elseif ($n -cmatch '[a-z]' -and $n -cmatch '[A-Z]') { $motivo = 'mistura maiuscula e minuscula (use kebab-case, ou CAIXA ALTA se for nome-marca)' }
    if ($motivo) { Alerta ($n + ' - ' + $motivo); $achouNome = $true }
}
if (-not $achouNome) { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- 3. pacotes
Titulo '3) Zip/rar guardado dentro de projeto (regra 4)'
$pacotes = Get-ChildItem -Recurse -File -Include *.zip, *.rar, *.7z -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*\_REVISAR\*' } |
    Where-Object { -not $pacotesOk.ContainsKey($_.FullName.Replace($raiz + '\', '')) }
if ($pacotes) {
    foreach ($f in $pacotes) {
        if ($f.Length -ge 1MB) { $tam = [string][math]::Round($f.Length / 1MB, 1) + ' MB' }
        else { $tam = [string][math]::Round($f.Length / 1KB, 1) + ' KB' }
        Alerta ($f.FullName.Replace($raiz + '\', '') + ' - ' + $tam)
    }
}
else { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- 4. lixo versionado
Titulo '4) Build ou cache versionado no git (regra 5)'
$achouLixo = $false
foreach ($p in $projetos) {
    if (-not (Test-Path (Join-Path $p.Name '.git'))) { continue }
    Push-Location $p.Name
    $sujo = git ls-files | Where-Object { $_ -match '(^|/)(node_modules|__pycache__|dist)/' }
    Pop-Location
    if ($sujo) {
        Alerta ($p.Name + ' - ' + ($sujo | Measure-Object).Count + ' arquivo(s) de build/cache versionados')
        $achouLixo = $true
    }
}
if (-not $achouLixo) { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- 5. launch.json
Titulo '5) launch.json'
$lj = '.claude\launch.json'
$antes = $problemas
if (-not (Test-Path $lj)) {
    Alerta 'nao existe - nenhum projeto tem preview nem verificacao automatica'
}
else {
    try {
        $cfg = (Get-Content $lj -Raw | ConvertFrom-Json).configurations
    }
    catch {
        Alerta 'JSON invalido - o preview nao vai abrir'
        $cfg = @()
    }

    $portas = @{}
    foreach ($c in $cfg) {
        if ($c.runtimeExecutable -eq 'python3' -or ($c.runtimeArgs -contains 'python3')) {
            Alerta ($c.name + ' - usa python3, que no Windows cai no stub da Microsoft Store')
        }
        if ($c.port) {
            if ($portas.ContainsKey($c.port)) {
                Alerta ('porta ' + $c.port + ' repetida: ' + $portas[$c.port] + ' e ' + $c.name)
            }
            else { $portas[$c.port] = $c.name }
        }
        $alvo = $c.cwd
        if (-not $alvo) {
            $i = [array]::IndexOf($c.runtimeArgs, '--directory')
            if ($i -ge 0) { $alvo = $c.runtimeArgs[$i + 1] }
        }
        if ($alvo -and -not (Test-Path $alvo)) {
            Alerta ($c.name + ' - aponta para "' + $alvo + '", que nao existe mais')
        }
    }

    # toda porta do launch.json precisa estar registrada no PORTAS.md
    if (-not (Test-Path 'PORTAS.md')) {
        Alerta 'PORTAS.md nao existe na raiz - o registro de portas sumiu'
    }
    else {
        $textoPortas = Get-Content 'PORTAS.md' -Raw -Encoding UTF8
        foreach ($c in $cfg) {
            if ($c.port -and ($textoPortas -notmatch ('(?<!\d)' + $c.port + '(?!\d)'))) {
                Alerta ($c.name + ' - porta ' + $c.port + ' esta no launch.json e nao no PORTAS.md')
            }
        }

        # porta da raiz que o PORTAS.md marca como reservada = colisao.
        # Em "## Reservadas", cada item comeca pelas portas; depois do
        # travessao e so explicacao.
        $reservadas = @()
        $secao = [regex]::Match($textoPortas, '(?ms)^## Reservadas.*?(?=^## |\z)')
        if ($secao.Success) {
            foreach ($linha in ($secao.Value -split "`n")) {
                if ($linha -notmatch '^\s*- `') { continue }
                $cabeca = [regex]::Split($linha, [string][char]0x2014)[0]
                foreach ($m in [regex]::Matches($cabeca, '`(\d{4})` a `(\d{4})`')) {
                    $reservadas += ([int]$m.Groups[1].Value)..([int]$m.Groups[2].Value)
                }
                foreach ($m in [regex]::Matches($cabeca, '`(\d{4})`')) { $reservadas += [int]$m.Groups[1].Value }
            }
        }
        foreach ($c in $cfg) {
            if ($c.port -and ($reservadas -contains [int]$c.port)) {
                Alerta ($c.name + ' - porta ' + $c.port + ' esta em Reservadas no PORTAS.md: ja e usada fora do launch.json')
            }
        }
    }

    # a mesma porta em dois projetos (launch.json da raiz x launch.json proprio
    # de cada projeto): mesma origem, e os dados de um aparecem no outro
    $donoDaPorta = @{}
    foreach ($c in $cfg) {
        if (-not $c.port) { continue }
        $dono = $c.cwd
        if (-not $dono) {
            $i = [array]::IndexOf($c.runtimeArgs, '--directory')
            if ($i -ge 0) { $dono = $c.runtimeArgs[$i + 1] }
        }
        if (-not $dono) { $dono = $c.name }
        $donoDaPorta[[string]$c.port] = ($dono -split '[\\/]')[0]
    }
    foreach ($p in $projetos) {
        if ($naoCobrar.ContainsKey($p.Name)) { continue }
        $ljProj = Join-Path $p.FullName '.claude\launch.json'
        if (-not (Test-Path $ljProj)) { continue }
        try { $cfgProj = (Get-Content $ljProj -Raw | ConvertFrom-Json).configurations } catch { continue }
        foreach ($c in $cfgProj) {
            if (-not $c.port) { continue }
            $k = [string]$c.port
            if ($donoDaPorta.ContainsKey($k) -and $donoDaPorta[$k] -ne $p.Name) {
                Alerta ($p.Name + ' - porta ' + $k + ' do launch.json proprio ja e de ' + $donoDaPorta[$k])
            }
            elseif (-not $donoDaPorta.ContainsKey($k)) { $donoDaPorta[$k] = $p.Name }
        }
    }

    # projeto com cara de web e sem entrada
    $nomes = @($cfg | ForEach-Object { $_.name })
    foreach ($p in $projetos) {
        $temEntrada = $false
        foreach ($c in $cfg) {
            $alvo = $c.cwd
            if (-not $alvo) {
                $i = [array]::IndexOf($c.runtimeArgs, '--directory')
                if ($i -ge 0) { $alvo = $c.runtimeArgs[$i + 1] }
            }
            if ($c.name -eq $p.Name -or ($alvo -and $alvo -like ($p.Name + '*'))) { $temEntrada = $true }
        }
        if (-not $temEntrada -and -not $naoCobrar.ContainsKey($p.Name)) {
            # App de desktop (Electron) tem index.html e nao roda por servidor:
            # cobrar entrada no launch.json dele seria ruido.
            $ehDesktop = $false
            $pkg = Join-Path $p.FullName 'package.json'
            if (Test-Path $pkg) {
                if ((Get-Content $pkg -Raw) -match '"electron"') { $ehDesktop = $true }
            }
            $web = Get-ChildItem -LiteralPath $p.FullName -Filter 'index.html' -Recurse -Depth 2 -ErrorAction SilentlyContinue |
                Select-Object -First 1
            if ($web -and -not $ehDesktop) {
                Alerta ($p.Name + ' - tem index.html e nenhuma entrada no launch.json (fica sem preview)')
            }
        }
    }

    if ($problemas -eq $antes) { Write-Host ('  ok - ' + ($cfg | Measure-Object).Count + ' entradas') -ForegroundColor Green }
}

# ---------------------------------------------------------------- 6. mapa
Titulo '6) Mapa do CLAUDE.md x pastas de verdade'
if (-not (Test-Path 'CLAUDE.md')) {
    Alerta 'CLAUDE.md nao existe na raiz'
}
else {
    $texto = Get-Content 'CLAUDE.md' -Raw
    $faltando = @()
    foreach ($p in $projetos) {
        if ($texto -notmatch [regex]::Escape('`' + $p.Name + '`')) { $faltando += $p.Name }
    }
    if ($faltando) {
        foreach ($n in $faltando) { Alerta ($n + ' - existe na pasta e nao aparece no CLAUDE.md') }
    }
    else { Write-Host '  ok - todo projeto aparece no CLAUDE.md' -ForegroundColor Green }
}

# ---------------------------------------------------------------- 7. documentacao
Titulo '7) Projeto sem nenhuma documentacao propria'
$semDoc = @()
foreach ($p in $projetos) {
    if ($naoCobrar.ContainsKey($p.Name)) { continue }
    $temMd = Get-ChildItem -LiteralPath $p.FullName -Filter '*.md' -Recurse -Depth 1 -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notlike '*\node_modules\*' } |
        Select-Object -First 1
    if (-not $temMd) { $semDoc += $p.Name }
}
if ($semDoc) {
    foreach ($n in $semDoc) { Alerta ($n + ' - sem README.md nem CLAUDE.md') }
}
else { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- 8. kit
# O kit chega com a secao 0 do CLAUDE.md por preencher. Enquanto a
# /primeira-configuracao nao rodar, toda sessao trabalha sem saber quem e a
# pessoa nem como e a maquina.
Titulo '8) Primeira configuracao e backup'
$antes8 = $problemas

if (Test-Path 'CLAUDE.md') {
    $txt = Get-Content 'CLAUDE.md' -Raw -Encoding UTF8
    if ($txt -match '_\(preencher\)_') {
        Alerta 'CLAUDE.md ainda tem _(preencher)_: rodar a /primeira-configuracao'
    }
    if ($txt -match 'NOME-DA-PASTA') {
        Alerta 'CLAUDE.md ainda diz NOME-DA-PASTA no titulo'
    }
}

$destinoBackup = Join-Path $PSScriptRoot 'backup-destino.txt'
if (-not (Test-Path $destinoBackup)) {
    Alerta 'backup-destino.txt nao existe: o backup local ainda nao foi configurado (skill backup-local)'
}

foreach ($p in $projetos) {
    if ($naoCobrar.ContainsKey($p.Name)) { continue }
    if (-not (Test-Path (Join-Path $p.FullName '.git'))) {
        Alerta ($p.Name + ' - sem git (rodar _organizacao\git-setup.ps1)')
    }
}

if ($problemas -eq $antes8) { Write-Host '  ok' -ForegroundColor Green }

# ---------------------------------------------------------------- fim
Write-Host ''
if ($problemas -eq 0) {
    Write-Host 'Nada a corrigir.' -ForegroundColor Green
}
else {
    Write-Host ($problemas.ToString() + ' ponto(s) para olhar. Nada foi movido nem alterado.') -ForegroundColor Yellow
}
Write-Host ''
