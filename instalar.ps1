# instalar.ps1 - instala (ou atualiza) o kit-claude-portatil neste computador.
#
# Cola isto no PowerShell (nao precisa de administrador, de GitHub nem de conta):
#
#   irm https://github.com/FelipeWASD83/kit-claude-portatil/releases/latest/download/instalar.ps1 | iex
#
# O que faz:
#   1. Baixa o kit.zip da versao mais nova e confere o SHA-256.
#   2. Cria a pasta de trabalho (Documentos\Claude Code, ou onde voce escolher) com as
#      regras, as skills, a biblioteca visual e os scripts.
#   3. Poe em ~\.claude as skills que valem em qualquer pasta (ver-video, context7-mcp),
#      o CLAUDE.md com as preferencias pessoais (so se ainda nao existir), as permissoes
#      seguras (somadas as que ja existem, sem apagar nada) e as ferramentas MCP.
#   4. Oferece instalar o que o ver-video precisa (ffmpeg, yt-dlp, Whisper).
#
# Rodar de novo ATUALIZA o kit: skills e scripts sao trocados (a versao antiga vai para
# ~\.claude\kit-backups), mas o CLAUDE.md, as permissoes, os projetos e tudo o que ela
# escreveu ficam como estao.
#
# Quem chama pode passar parametros assim:
#   & ([scriptblock]::Create((irm <url>))) -Destino "D:\Trabalho" -SemVideo
#
# Este arquivo e ASCII de proposito (sem acento, sem BOM): o "irm | iex" do PowerShell 5.1
# estraga a primeira linha de um script com BOM.

param(
    [string]$Destino,
    [string]$Repo = 'FelipeWASD83/kit-claude-portatil',
    [string]$ArquivoLocal,
    [string]$BaseUrl,
    [switch]$SemVideo,
    [switch]$SemMcp,
    [switch]$Sim
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch { }

# KIT_HOME so existe para os testes do kit (instalar numa casa de mentira).
$Casa = if ($env:KIT_HOME) { $env:KIT_HOME } else { $env:USERPROFILE }
$ClaudeDir = Join-Path $Casa '.claude'
$Marca = Join-Path $ClaudeDir 'kit-instalado.json'
$Carimbo = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backups = Join-Path $ClaudeDir ('kit-backups\' + $Carimbo)
$Temp = Join-Path ([IO.Path]::GetTempPath()) ('kit-claude-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$Utf8SemBom = New-Object System.Text.UTF8Encoding($false)

function Dizer([string]$texto, [string]$cor = 'Gray') { Write-Host $texto -ForegroundColor $cor }
function Titulo([string]$texto) { Write-Host ''; Write-Host $texto -ForegroundColor Cyan }

function Perguntar-SimNao([string]$pergunta, [bool]$padrao) {
    if ($Sim) { return $padrao }
    $sufixo = if ($padrao) { '[S/n]' } else { '[s/N]' }
    $r = Read-Host ($pergunta + ' ' + $sufixo)
    if (-not $r) { return $padrao }
    return ($r.Trim().ToLower() -in @('s', 'sim', 'y', 'yes'))
}

function Guardar-Backup([string]$arquivo, [string]$raizRelativa, [string]$prefixo) {
    # Copia o arquivo que vai ser trocado para kit-backups\<data>\<prefixo>\, mantendo o caminho.
    if (-not (Test-Path -LiteralPath $arquivo)) { return }
    $rel = $arquivo.Substring($raizRelativa.TrimEnd('\').Length).TrimStart('\')
    $alvo = Join-Path (Join-Path $Backups $prefixo) $rel
    New-Item -ItemType Directory -Force (Split-Path $alvo -Parent) | Out-Null
    Copy-Item -LiteralPath $arquivo -Destination $alvo -Force
}

function Mesmo-Conteudo([string]$a, [string]$b) {
    if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $b)) { return $false }
    if ((Get-Item -LiteralPath $a).Length -ne (Get-Item -LiteralPath $b).Length) { return $false }
    return ((Get-FileHash -LiteralPath $a -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $b -Algorithm SHA256).Hash)
}

# Copia uma arvore. Modo 'Trocar': arquivo diferente e substituido (com backup).
# Modo 'SoSeFaltar': arquivo que ja existe e deixado em paz (e do usuario).
function Copiar-Arvore([string]$origem, [string]$destino, [string]$modo, [string[]]$pular = @(), [string]$raizBackup = $null, [string]$prefixo = 'x') {
    $trocados = 0; $novos = 0; $mantidos = 0
    $origem = (Resolve-Path -LiteralPath $origem).Path.TrimEnd('\')
    foreach ($f in (Get-ChildItem -LiteralPath $origem -Recurse -File -Force)) {
        $rel = $f.FullName.Substring($origem.Length).TrimStart('\')
        $ignorar = $false
        foreach ($p in $pular) { if ($rel -eq $p -or $rel.StartsWith($p.TrimEnd('\') + '\')) { $ignorar = $true } }
        if ($ignorar) { continue }
        $alvo = Join-Path $destino $rel
        if (Test-Path -LiteralPath $alvo) {
            if (Mesmo-Conteudo $f.FullName $alvo) { continue }
            if ($modo -eq 'SoSeFaltar') { $mantidos++; continue }
            if ($raizBackup) { Guardar-Backup $alvo $raizBackup $prefixo }
            Copy-Item -LiteralPath $f.FullName -Destination $alvo -Force
            $trocados++
        }
        else {
            New-Item -ItemType Directory -Force (Split-Path $alvo -Parent) | Out-Null
            Copy-Item -LiteralPath $f.FullName -Destination $alvo -Force
            $novos++
        }
    }
    return [pscustomobject]@{ Novos = $novos; Trocados = $trocados; Mantidos = $mantidos }
}

function Ler-Json([string]$caminho) {
    if (-not (Test-Path -LiteralPath $caminho)) { return $null }
    try { return (Get-Content -LiteralPath $caminho -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { return $null }
}

function Gravar-Json($objeto, [string]$caminho) {
    $json = $objeto | ConvertTo-Json -Depth 20
    [IO.File]::WriteAllText($caminho, $json, $Utf8SemBom)
}

# Soma as permissoes do kit as que ja existem no settings.json, sem apagar nenhuma.
function Somar-Permissoes([string]$settings, [string]$modeloKit) {
    $kit = Ler-Json $modeloKit
    if (-not $kit) { Dizer '  (modelo de permissoes do kit ilegivel; pulei)' 'Yellow'; return }
    $existia = Test-Path -LiteralPath $settings
    if ($existia) {
        $cfg = Ler-Json $settings
        if (-not $cfg) {
            Dizer '  settings.json existe mas nao e um JSON valido; nao mexi. As permissoes do kit ficaram em settings.kit.json ao lado.' 'Yellow'
            Copy-Item -LiteralPath $modeloKit -Destination (Join-Path (Split-Path $settings -Parent) 'settings.kit.json') -Force
            return
        }
        Guardar-Backup $settings $ClaudeDir 'global'
    }
    else { $cfg = [pscustomobject]@{} }
    if (-not $cfg.PSObject.Properties['permissions']) { $cfg | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{}) }
    $acrescentadas = 0
    foreach ($lista in 'deny', 'ask', 'allow') {
        $atual = @()
        if ($cfg.permissions.PSObject.Properties[$lista]) { $atual = @($cfg.permissions.$lista) }
        $doKit = @()
        if ($kit.permissions.PSObject.Properties[$lista]) { $doKit = @($kit.permissions.$lista) }
        $novas = @($doKit | Where-Object { $atual -notcontains $_ })
        $acrescentadas += $novas.Count
        $soma = @($atual) + @($novas)
        if ($cfg.permissions.PSObject.Properties[$lista]) { $cfg.permissions.$lista = $soma }
        else { $cfg.permissions | Add-Member -NotePropertyName $lista -NotePropertyValue $soma }
    }
    New-Item -ItemType Directory -Force (Split-Path $settings -Parent) | Out-Null
    Gravar-Json $cfg $settings
    Dizer ('  settings.json: ' + $acrescentadas + ' permissao(oes) somada(s); o resto ficou como estava.')
}

function Comando-Existe([string]$nome) { return [bool](Get-Command $nome -ErrorAction SilentlyContinue) }

# No PowerShell 5.1, com 'Stop', qualquer linha que um programa escreva no stderr vira erro fatal,
# mesmo quando deu certo. Aqui quem decide e o codigo de saida.
function Rodar-Nativo([string]$exe, [string[]]$argumentos) {
    $antes = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $saida = & $exe @argumentos 2>&1 | ForEach-Object { "$_" }
        return [pscustomobject]@{ Codigo = $LASTEXITCODE; Saida = ($saida -join "`n") }
    }
    catch { return [pscustomobject]@{ Codigo = 1; Saida = $_.Exception.Message } }
    finally { $ErrorActionPreference = $antes }
}

# ---------------------------------------------------------------- comeco
Dizer ''
Dizer '== kit-claude-portatil ==' 'White'

try {
    # ------------------------------------------------------------ 1. pegar o pacote
    Titulo '1) Pegando o kit'
    New-Item -ItemType Directory -Force $Temp | Out-Null
    $zip = Join-Path $Temp 'kit.zip'
    if ($ArquivoLocal) {
        if (-not (Test-Path -LiteralPath $ArquivoLocal)) { throw "Nao achei o arquivo $ArquivoLocal" }
        Copy-Item -LiteralPath $ArquivoLocal -Destination $zip
        Dizer ('  usando o arquivo local ' + $ArquivoLocal)
        $arqSha = ($ArquivoLocal + '.sha256')
        if (Test-Path -LiteralPath $arqSha) { $shaTexto = (Get-Content -LiteralPath $arqSha -Raw) } else { $shaTexto = $null }
    }
    else {
        $base = if ($BaseUrl) { $BaseUrl.TrimEnd('/') + '/' } else { 'https://github.com/' + $Repo + '/releases/latest/download/' }
        Dizer ('  baixando ' + $base + 'kit.zip')
        try {
            Invoke-WebRequest -UseBasicParsing -Uri ($base + 'kit.zip') -OutFile $zip
            $shaTexto = (Invoke-WebRequest -UseBasicParsing -Uri ($base + 'kit.zip.sha256')).Content
            if ($shaTexto -is [byte[]]) { $shaTexto = [Text.Encoding]::ASCII.GetString($shaTexto) }
        }
        catch {
            throw ('Nao consegui baixar o kit. Confira a internet e se o endereco abre no navegador: ' + $base + 'kit.zip. Detalhe: ' + $_.Exception.Message)
        }
    }
    if ($shaTexto) {
        $esperado = ([regex]::Match($shaTexto, '[0-9a-fA-F]{64}')).Value.ToLower()
        $real = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
        if (-not $esperado) { throw 'O arquivo .sha256 do kit veio vazio ou estranho. Nao instalei nada.' }
        if ($esperado -ne $real) { throw ('O SHA-256 do kit nao confere (esperado ' + $esperado + ', veio ' + $real + '). Nao instalei nada.') }
        Dizer '  SHA-256 conferido.' 'Green'
    }
    else { Dizer '  (sem .sha256 ao lado: nao deu para conferir o pacote)' 'Yellow' }

    $extraido = Join-Path $Temp 'kit'
    Expand-Archive -LiteralPath $zip -DestinationPath $extraido -Force
    $info = Ler-Json (Join-Path $extraido 'versao.json')
    if (-not $info) { throw 'O pacote nao tem versao.json valido.' }
    $versao = [string]$info.versao
    $srcPasta = Join-Path $extraido 'conteudo\pasta'
    $srcGlobal = Join-Path $extraido 'conteudo\global'
    if (-not (Test-Path -LiteralPath $srcPasta) -or -not (Test-Path -LiteralPath $srcGlobal)) { throw 'O pacote esta incompleto (faltam conteudo\pasta ou conteudo\global).' }
    Dizer ('  versao ' + $versao)

    # ------------------------------------------------------------ 2. onde vai a pasta
    $anterior = Ler-Json $Marca
    $docs = Join-Path $Casa 'Documents'
    if (-not $env:KIT_HOME) { try { $docs = [Environment]::GetFolderPath('MyDocuments') } catch { } }
    if (-not $Destino) {
        if ($anterior -and $anterior.pasta -and (Test-Path -LiteralPath $anterior.pasta)) {
            $Destino = [string]$anterior.pasta
            Dizer ('  instalacao anterior encontrada: ' + $Destino + ' (vai ser atualizada)')
        }
        else {
            $padrao = Join-Path $docs 'Claude Code'
            if ($Sim) { $Destino = $padrao }
            else {
                $r = Read-Host ('Onde criar a sua pasta de trabalho? [Enter = ' + $padrao + ']')
                $Destino = if ($r) { $r.Trim().Trim('"') } else { $padrao }
            }
        }
    }
    $Destino = [IO.Path]::GetFullPath($Destino)
    $atualizando = Test-Path -LiteralPath (Join-Path $Destino 'CLAUDE.md')

    # ------------------------------------------------------------ 3. o que ja tem na maquina
    Titulo '2) Conferindo o computador'
    $pyReal = $false
    foreach ($c in 'py', 'python') {
        if (Comando-Existe $c) {
            $r = Rodar-Nativo $c @('-c', 'import sys; print(sys.version_info[0])')
            if ($r.Codigo -eq 0 -and $r.Saida.Trim() -eq '3') { $pyReal = $true; break }
        }
    }
    $tem = [ordered]@{
        'Python'  = $pyReal
        'Node.js' = (Comando-Existe 'node')
        'Git'     = (Comando-Existe 'git')
        'winget'  = (Comando-Existe 'winget')
        'Claude Code (comando claude)' = (Comando-Existe 'claude')
    }
    foreach ($k in $tem.Keys) {
        if ($tem[$k]) { Dizer ('  ok       ' + $k) 'Green' } else { Dizer ('  FALTA    ' + $k) 'Yellow' }
    }
    if (-not $tem['Git']) { Dizer '  -> o Git faz falta para os projetos: winget install --id Git.Git' 'Yellow' }
    if (-not $tem['Python']) { Dizer '  -> sem Python o backup nao copia a config do Claude e o ver-video nao roda: winget install Python.Python.3.13' 'Yellow' }
    Dizer '  (nao instalo nada disso por conta propria)' 'DarkGray'

    # ------------------------------------------------------------ 4. a pasta de trabalho
    Titulo ('3) Pasta de trabalho: ' + $Destino)
    if ($atualizando) { Dizer '  ja existe um CLAUDE.md aqui: so os arquivos do kit vao ser atualizados.' }
    New-Item -ItemType Directory -Force $Destino | Out-Null

    $configurada = ($anterior -and $anterior.configurado -eq $true)
    # Arquivos da pessoa: copiados so se faltarem.
    $dela = @('CLAUDE.md', 'PORTAS.md', 'LEIA-PRIMEIRO.md', '.gitignore', '.claude\settings.json', '.claude\launch.json',
              '_organizacao\git-setup.ps1', '_organizacao\checar-pasta.ps1')
    $pularDoKit = @($dela)
    if ($configurada) { $pularDoKit += '.claude\skills\primeira-configuracao' }

    # 1a passada: o que e do kit (troca, com backup). 2a, so na primeira instalacao: o que e dela.
    # Em atualizacao os arquivos dela nao voltam nem se ela os apagou (o LEIA-PRIMEIRO, por exemplo).
    $r1 = Copiar-Arvore $srcPasta $Destino 'Trocar' $pularDoKit $Destino 'pasta'
    if (-not $atualizando) { $null = Copiar-Arvore $srcPasta $Destino 'SoSeFaltar' @() $null }
    Dizer ('  skills e scripts do kit: ' + $r1.Novos + ' novo(s), ' + $r1.Trocados + ' atualizado(s)')
    if ($atualizando) { Dizer ('  mantive como estavam: ' + (($dela | ForEach-Object { $_.Replace('\', '/') }) -join ', ')) }
    New-Item -ItemType Directory -Force (Join-Path $Destino '_REVISAR') | Out-Null
    Get-ChildItem -LiteralPath $Destino -Recurse -File -Force -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $Backups) { Dizer ('  as versoes antigas trocadas ficaram em ' + $Backups) 'DarkGray' }

    # ------------------------------------------------------------ 5. ~/.claude
    Titulo ('4) Configuracao do Claude em ' + $ClaudeDir)
    New-Item -ItemType Directory -Force $ClaudeDir | Out-Null
    $r3 = Copiar-Arvore (Join-Path $srcGlobal 'skills') (Join-Path $ClaudeDir 'skills') 'Trocar' @() (Join-Path $ClaudeDir 'skills') 'global-skills'
    Dizer ('  skills pessoais (ver-video, context7-mcp): ' + $r3.Novos + ' novo(s), ' + $r3.Trocados + ' atualizado(s)')
    $null = Copiar-Arvore (Join-Path $srcGlobal 'rules') (Join-Path $ClaudeDir 'rules') 'SoSeFaltar' @() $null
    $globalMd = Join-Path $ClaudeDir 'CLAUDE.md'
    $modeloMd = Join-Path $srcGlobal 'CLAUDE.md'
    $modeloAlvo = Join-Path $ClaudeDir 'CLAUDE.kit-modelo.md'
    if (-not (Test-Path -LiteralPath $globalMd)) {
        Copy-Item -LiteralPath $modeloMd -Destination $globalMd
        Copy-Item -LiteralPath $modeloMd -Destination $modeloAlvo -Force
        Dizer '  CLAUDE.md pessoal criado (com campos por preencher).'
    }
    else {
        Copy-Item -LiteralPath $modeloMd -Destination $modeloAlvo -Force
        Dizer '  ja existe um CLAUDE.md pessoal: nao toquei nele. O modelo do kit ficou em CLAUDE.kit-modelo.md.'
    }
    Somar-Permissoes (Join-Path $ClaudeDir 'settings.json') (Join-Path $srcGlobal 'settings.kit.json')

    # ------------------------------------------------------------ 6. MCP
    if ($SemMcp -or $env:KIT_HOME) {
        Dizer '  MCP: pulado.' 'DarkGray'
    }
    elseif (-not $tem['Claude Code (comando claude)']) {
        Dizer '  MCP: o comando claude nao foi encontrado; os comandos estao em _organizacao\instalar-ferramentas.md.' 'Yellow'
    }
    elseif (-not $tem['Node.js']) {
        Dizer '  MCP: sem Node.js nao da para o chrome-devtools; instale o Node LTS e rode de novo.' 'Yellow'
    }
    else {
        $lista = (Rodar-Nativo 'claude' @('mcp', 'list')).Saida
        $mcps = @(
            @{ nome = 'chrome-devtools'; args = @('mcp', 'add', '--scope', 'user', 'chrome-devtools', '--', 'npx', 'chrome-devtools-mcp@latest') },
            @{ nome = 'deepwiki'; args = @('mcp', 'add', '--transport', 'http', '--scope', 'user', 'deepwiki', 'https://mcp.deepwiki.com/mcp') },
            @{ nome = 'context7'; args = @('mcp', 'add', '--transport', 'http', '--scope', 'user', 'context7', 'https://mcp.context7.com/mcp') }
        )
        foreach ($m in $mcps) {
            if ($lista -match ('(?m)^\s*' + [regex]::Escape($m.nome) + ':')) { Dizer ('  MCP ' + $m.nome + ': ja estava.'); continue }
            $r = Rodar-Nativo 'claude' $m.args
            if ($r.Codigo -eq 0) { Dizer ('  MCP ' + $m.nome + ': adicionado.') 'Green' }
            else { Dizer ('  MCP ' + $m.nome + ': nao consegui adicionar (veja _organizacao\instalar-ferramentas.md).') 'Yellow' }
        }
    }

    # ------------------------------------------------------------ 7. marca da instalacao
    $primeira = if ($anterior -and $anterior.instalado_em) { [string]$anterior.instalado_em } else { (Get-Date -Format 'yyyy-MM-dd') }
    $dados = [ordered]@{
        versao        = $versao
        pasta         = $Destino
        instalado_em  = $primeira
        atualizado_em = (Get-Date -Format 'yyyy-MM-dd')
        configurado   = [bool]$configurada
    }
    if ($anterior -and $anterior.configurado_em) { $dados['configurado_em'] = [string]$anterior.configurado_em }
    Gravar-Json ([pscustomobject]$dados) $Marca

    # ------------------------------------------------------------ 8. ver-video
    $venvVideo = Join-Path $ClaudeDir 'ver-video\venv\Scripts\python.exe'
    if (-not $SemVideo -and -not $env:KIT_HOME -and -not (Test-Path -LiteralPath $venvVideo)) {
        Titulo '5) Ver e ouvir video (opcional)'
        Dizer '  A skill ver-video deixa o Claude assistir a um arquivo ou link de video e transcrever a fala.'
        Dizer '  Precisa instalar ffmpeg e yt-dlp (winget) e um ambiente Python com o Whisper: baixa alguns GB e leva minutos.'
        if (Perguntar-SimNao '  Instalar agora?' $false) {
            $inst = Join-Path $ClaudeDir 'skills\ver-video\instalar.ps1'
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $inst
        }
        else { Dizer '  Tudo bem. A /primeira-configuracao e a propria skill oferecem de novo quando for preciso.' 'DarkGray' }
    }

    # ------------------------------------------------------------ fim
    Titulo 'Pronto.'
    Dizer ('  Kit ' + $versao + ' instalado em: ' + $Destino) 'Green'
    if (-not $configurada) {
        Dizer ''
        Dizer '  Proximo passo: abra o Claude Code NESTA pasta e digite  /primeira-configuracao' 'White'
        Dizer ('    cd "' + $Destino + '"') 'Gray'
        Dizer '    claude' 'Gray'
        Dizer '  Ele mede o computador, faz algumas perguntas e grava as suas preferencias.' 'Gray'
    }
    else { Dizer '  Atualizacao concluida; as suas preferencias nao foram tocadas.' }
    Dizer ''
}
finally {
    try { if (Test-Path -LiteralPath $Temp) { Remove-Item -LiteralPath $Temp -Recurse -Force -ErrorAction SilentlyContinue } } catch { }
}
