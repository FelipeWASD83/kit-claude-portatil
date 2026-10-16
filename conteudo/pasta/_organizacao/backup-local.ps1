# backup-local.ps1 - espelha a pasta de trabalho inteira num destino local
# (HD externo, pendrive, outra pasta), em copia fiel.
#
# Aqui nao tem acento de proposito: o PowerShell 5.1 le arquivo sem BOM como ANSI.
#
# O DESTINO fica em _organizacao\backup-destino.txt, uma chave por linha:
#     caminho=E:\Backup\Trabalho          (obrigatoria: a pasta onde cai o espelho)
#     rotulo=Meu HD Externo               (opcional: se a letra do drive mudar, acha pelo rotulo)
#     fonte=C:\Users\fulana\Documents\X   (opcional, pode repetir: mais uma pasta para levar junto)
# A skill backup-local cria esse arquivo conversando com a pessoa.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File ".\_organizacao\backup-local.ps1"
#   ...  -Simular     -> mostra o que MUDARIA, sem copiar e sem apagar nada
#   ...  -Silencioso  -> so o resumo no fim (pra tarefa agendada)
#
# Codigos de saida: 0 ok, 1 falha ou origem suspeita, 2 destino nao encontrado
# (HD desplugado: nao e erro, so nao rodou), 3 backup ainda nao configurado.
#
# O espelho e /MIR: o que some na origem some no backup. E isso que deixa o backup
# igual ao original - e e por isso que existe a trava de seguranca abaixo, que
# aborta se a origem sumir ou vier vazia. Nao tira ela.

[CmdletBinding()]
param(
    [switch]$Simular,
    [switch]$Silencioso
)

$ErrorActionPreference = 'Stop'

function Falar($texto, $cor = 'Gray') {
    if (-not $Silencioso) { Write-Host $texto -ForegroundColor $cor }
}

$Log = Join-Path $PSScriptRoot '.backup-local.log'
function Registrar($texto) {
    $linha = "{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $texto
    Add-Content -Path $Log -Value $linha -Encoding UTF8
}

# --- ler a configuracao -----------------------------------------------------
$arqConfig = Join-Path $PSScriptRoot 'backup-destino.txt'
if (-not (Test-Path $arqConfig)) {
    Falar 'Backup local ainda nao foi configurado (falta _organizacao\backup-destino.txt). Use a skill backup-local.' 'Yellow'
    Registrar 'ABORTADO: sem backup-destino.txt'
    exit 3
}

$caminho = $null
$rotulo = $null
$extras = @()
foreach ($linha in (Get-Content $arqConfig -Encoding UTF8)) {
    $l = $linha.Trim()
    if (-not $l -or $l.StartsWith('#')) { continue }
    $i = $l.IndexOf('=')
    if ($i -lt 1) { continue }
    $k = $l.Substring(0, $i).Trim().ToLower()
    $v = $l.Substring($i + 1).Trim().Trim('"')
    switch ($k) {
        'caminho' { $caminho = $v }
        'rotulo'  { $rotulo = $v }
        'fonte'   { if ($v) { $extras += $v } }
    }
}
if (-not $caminho) {
    Falar 'backup-destino.txt sem a linha caminho=... Nada foi copiado.' 'Red'
    Registrar 'ABORTADO: sem caminho'
    exit 3
}

# --- achar o destino --------------------------------------------------------
# A letra do drive pode mudar quando o HD e plugado em outra porta: com rotulo, o
# rotulo manda e a letra do caminho e trocada pela atual.
$destinoBase = $caminho
if ($rotulo) {
    $vol = Get-Volume -ErrorAction SilentlyContinue |
        Where-Object { $_.FileSystemLabel -eq $rotulo -and $_.DriveLetter } | Select-Object -First 1
    if ($vol -and $caminho -match '^[A-Za-z]:') {
        $destinoBase = ('{0}:' -f $vol.DriveLetter) + $caminho.Substring(2)
    }
}

$unidade = Split-Path $destinoBase -Qualifier -ErrorAction SilentlyContinue
if ($unidade -and -not (Test-Path ($unidade + '\'))) {
    Falar "Destino do backup ($unidade) nao esta conectado. Backup nao rodou." 'Yellow'
    Registrar "ABORTADO: destino $unidade ausente"
    exit 2
}

# --- origens ----------------------------------------------------------------
$PastaDeProjetos = Split-Path $PSScriptRoot -Parent
$Fontes = @(
    [pscustomobject]@{ Nome = (Split-Path $PastaDeProjetos -Leaf); Caminho = $PastaDeProjetos; MinimoArquivos = 20; Opcional = $false }
)
foreach ($e in $extras) {
    $Fontes += [pscustomobject]@{ Nome = (Split-Path $e -Leaf); Caminho = $e; MinimoArquivos = 1; Opcional = $true }
}

# Destino dentro da origem faria o robocopy copiar o backup dentro do proprio
# backup, sem parar.
$destResolvido = [System.IO.Path]::GetFullPath($destinoBase).TrimEnd('\') + '\'
foreach ($f in $Fontes) {
    $orig = [System.IO.Path]::GetFullPath($f.Caminho).TrimEnd('\') + '\'
    if ($destResolvido.StartsWith($orig, [System.StringComparison]::OrdinalIgnoreCase)) {
        Falar "O destino ($destinoBase) esta DENTRO de uma pasta de origem ($($f.Caminho)). Escolha outro destino." 'Red'
        Registrar "ABORTADO: destino dentro da origem"
        exit 1
    }
}

Falar ""
Falar "Backup local -> $destinoBase" 'Cyan'
if ($Simular) { Falar "(SIMULACAO: nada vai ser copiado nem apagado)" 'Yellow' }
Falar ""

if (-not (Test-Path $destinoBase)) {
    if ($Simular) { Falar "(a pasta de destino ainda nao existe; seria criada)" 'DarkGray' }
    else { New-Item -ItemType Directory -Path $destinoBase -Force | Out-Null }
}

# --- config do Claude que mora fora da pasta --------------------------------
# As instrucoes globais, as regras e a memoria ficam em ~/.claude; o
# salvar-config.py copia para _organizacao\config-agentes antes do espelho, e
# ai elas vao junto. Falha aqui nunca derruba o backup.
if (-not $Simular) {
    try {
        $salvar = Join-Path $PSScriptRoot 'salvar-config.py'
        $py = Get-Command python -ErrorAction SilentlyContinue
        if ($py -and (Test-Path $salvar)) {
            $saidaCfg = & $py.Source $salvar 2>&1 | Select-Object -Last 1
            Falar "Config do Claude: $saidaCfg" 'DarkGray'
        }
    }
    catch {
        Registrar "AVISO: salvar-config.py falhou: $($_.Exception.Message)"
    }
}

# --- espelhar ---------------------------------------------------------------
$houveErro = $false
$resumo = @()

foreach ($f in $Fontes) {
    if (-not (Test-Path $f.Caminho)) {
        if ($f.Opcional) {
            Falar "-  $($f.Nome): ainda nao existe no PC. Pulando." 'DarkGray'
            continue
        }
        Falar "[X] $($f.Nome): origem nao existe ($($f.Caminho)). PULADO - o backup dela fica intacto." 'Red'
        Registrar "ABORTADO ($($f.Nome)): origem nao existe"
        $houveErro = $true
        continue
    }

    # Trava de seguranca: origem vazia ou quase vazia com /MIR apagaria o backup
    # inteiro. Melhor nao rodar do que rodar contra o que e nosso.
    $qtd = (Get-ChildItem $f.Caminho -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($qtd -lt $f.MinimoArquivos) {
        Falar "[X] $($f.Nome): so $qtd arquivos na origem (esperado >= $($f.MinimoArquivos)). PULADO por seguranca." 'Red'
        Registrar "ABORTADO ($($f.Nome)): origem com $qtd arquivos, abaixo do minimo"
        $houveErro = $true
        continue
    }

    $alvo = Join-Path $destinoBase $f.Nome
    Falar "-> $($f.Nome)  ($qtd arquivos)" 'White'

    $roboArgs = @($f.Caminho, $alvo, '/MIR', '/R:2', '/W:2', '/MT:16', '/NFL', '/NDL', '/NP', '/NJH')
    if ($Simular) { $roboArgs += '/L' }

    $saida = & robocopy.exe @roboArgs
    $codigo = $LASTEXITCODE

    # Robocopy: 0-7 e sucesso (0 = nada mudou, 1 = copiou, 2 = apagou extras,
    # 4 = arquivo desigual). 8 ou mais e falha de verdade.
    if ($codigo -ge 8) {
        Falar "   FALHOU (codigo $codigo)" 'Red'
        $saida | Select-Object -Last 12 | ForEach-Object { Falar "   $_" 'DarkGray' }
        Registrar "FALHA ($($f.Nome)): robocopy codigo $codigo"
        $houveErro = $true
    }
    else {
        $linhas = $saida | Where-Object { $_ -match '^\s*(Arquiv|Files|Bytes)' }
        $linhas | ForEach-Object { Falar "   $_" 'DarkGray' }
        Falar "   OK (codigo $codigo)" 'Green'
        $resumo += "$($f.Nome): ok ($codigo)"
    }
}

# --- carimbo no destino -----------------------------------------------------
if (-not $Simular -and -not $houveErro) {
    $quando = Get-Date -Format 'dd/MM/yyyy HH:mm'
    $tabela = ($Fontes | Where-Object { Test-Path $_.Caminho } |
        ForEach-Object { "| ``$($_.Nome)\`` | ``$($_.Caminho)`` |" }) -join "`n"
    $leia = @"
# Backup da pasta de trabalho

Espelho automatico feito pelo ``_organizacao\backup-local.ps1``.

**Ultima sincronia: $quando**

## O que tem aqui

| Pasta daqui | Volta pra |
|---|---|
$tabela

E copia fiel, inclusive ``.git``, ``node_modules`` e o que o git ignora
(``_originais``, ``.env``). Nada foi filtrado.

A configuracao do Claude que mora fora da pasta (instrucoes globais, regras,
``settings.json``, memoria) vai junto, copiada antes de cada espelho para
``_organizacao\config-agentes``. Credencial nao vai: numa maquina nova, e login
de novo.

## Como restaurar

Copia a pasta de volta pro caminho da tabela. So isso: nao tem formato proprio,
nao tem programa pra instalar, nao tem senha. Se for restaurar por cima de uma
pasta que ainda existe, renomeia a antiga antes em vez de sobrescrever.

## Cuidado

O espelho e ``robocopy /MIR``: o que voce apagar no PC some daqui na proxima
sincronia. Isto e um backup de espelho, nao um historico de versoes - quem guarda
historico e o git de cada projeto, que esta aqui dentro tambem.
"@
    Set-Content -Path (Join-Path $destinoBase 'LEIA-PRIMEIRO.md') -Value $leia -Encoding UTF8
}

# --- fim --------------------------------------------------------------------
Falar ""
if ($houveErro) {
    Falar "Backup terminou COM PROBLEMA. Olha as linhas em vermelho acima." 'Red'
    Registrar 'FIM: com problema'
    exit 1
}
else {
    Falar ("Backup completo. {0}" -f ($resumo -join ' | ')) 'Green'
    Registrar ("OK: " + ($resumo -join ' | '))
    exit 0
}
