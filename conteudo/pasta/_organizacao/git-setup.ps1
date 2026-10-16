# git-setup.ps1 - garante git nos projetos da pasta de trabalho.
#
# O QUE FAZ:
#   1. Descobre os projetos sozinho, varrendo as pastas da raiz.
#   2. Cria repositorio git e primeiro commit em quem ainda nao tem.
#   3. Com $usarGitHub = $true (mais abaixo), tambem lista quem tem git mas nao
#      tem backup no GitHub, e quem tem commit parado sem publicar, com o comando
#      pronto pra copiar. Com $false (o padrao deste kit), o git e so local e
#      o backup e o backup-local.ps1.
#
# NAO cria repositorio no GitHub e NAO faz push por conta propria. Publicar manda
# trabalho pra internet: isso e decisao sua, o script so mostra o comando.
#
# COMO USAR: abra o PowerShell na pasta de trabalho e rode:
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\git-setup.ps1"
#
# E SEGURO: nao apaga, nao sobrescreve e nao mexe em projeto que ja tem .git.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

# Mude para $true so se a pessoa passar a usar GitHub (a skill primeira-configuracao
# faz isso se ela aceitar). Com $false, nada aqui cobra repositorio remoto.
$usarGitHub = $false

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'git nao encontrado. Instale com: winget install --id Git.Git' -ForegroundColor Red
    exit 1
}

# Pastas que NAO sao projeto, ou que ficam fora do git de proposito.
# Esta lista e a $soLocal (mais abaixo) sao os unicos lugares que precisam de
# manutencao - projeto novo entra sozinho na varredura, sem ninguem lembrar de
# cadastrar.
$fora = @{
    '_REVISAR'     = 'quarentena da organizacao, nao e projeto'
    '_organizacao' = 'os scripts desta pasta, nao e projeto'
    # Acrescentar aqui toda pasta que ficar fora do git DE PROPOSITO, com o
    # motivo escrito. Excecao sem motivo vira pendencia falsa toda vez que
    # alguem roda isto - e alguem acaba criando git onde nao devia.
    # Exemplo:
    # 'nome-da-pasta' = 'conteudo pessoal privado - decisao dela em AAAA-MM-DD'
}

# Projetos que TEM git mas ficam so locais de proposito, sem repositorio no
# GitHub (so tem efeito com $usarGitHub = $true). Motivo sempre escrito.
$soLocal = @{
    # Exemplo:
    # 'nome-da-pasta' = 'projeto pessoal - git so local por decisao dela em AAAA-MM-DD'
}

# Autor do commit inicial: o do git da maquina, se existir; senao um generico.
$nomeGit = (git config --get user.name)
$emailGit = (git config --get user.email)
if (-not $nomeGit) { $nomeGit = 'Dono da pasta' }
if (-not $emailGit) { $emailGit = 'dono@localhost' }

$projetos = Get-ChildItem -Directory |
    Where-Object { $_.Name -notlike '.*' -and -not $fora.ContainsKey($_.Name) } |
    Sort-Object Name

$feitos = 0
$jaTinham = 0
$semBackup = @()
$soLocalVistos = @()
$naoPublicados = @()

foreach ($proj in $projetos) {
    $p = $proj.Name

    if (Test-Path (Join-Path $p '.git')) {
        $jaTinham++
    }
    else {
        Write-Host ('==> ' + $p + ' (sem git, criando)') -ForegroundColor Cyan
        Push-Location $p

        git init -q -b main

        if (-not (Test-Path '.gitignore')) {
            Copy-Item (Join-Path $raiz '.gitignore') '.gitignore'
        }

        git add -A
        git -c user.name=$nomeGit -c user.email=$emailGit commit -q -m 'primeiro commit: estado atual do projeto'

        $arquivos = (git ls-files | Measure-Object).Count
        Write-Host ('    ok - ' + $arquivos + ' arquivos versionados') -ForegroundColor Green
        $feitos++

        Pop-Location
    }

    if (-not $usarGitHub) { continue }

    # --- diagnostico de backup no GitHub, so com $usarGitHub ---
    #
    # Usa "git config --get" e "git rev-parse --verify" de proposito: no
    # PowerShell 5.1, um comando nativo que escreve em stderr (como
    # "git remote get-url origin" num repo sem remote) vira ErrorRecord e,
    # com $ErrorActionPreference = 'Stop', derruba o script inteiro.
    # Estes dois nao escrevem em stderr - so devolvem vazio.
    Push-Location $p

    $remote = git config --get remote.origin.url
    if (-not $remote) {
        if ($soLocal.ContainsKey($p)) { $soLocalVistos += $p }
        else { $semBackup += $p }
    }
    else {
        $branch = git rev-parse --abbrev-ref HEAD
        $temTracking = git rev-parse --verify --quiet ('refs/remotes/origin/' + $branch)
        if (-not $temTracking) {
            $naoPublicados += ($p + ' (branch ' + $branch + ' nunca foi publicada)')
        }
        else {
            $pendentes = git rev-list --count ('origin/' + $branch + '..' + $branch)
            if ($pendentes -and [int]$pendentes -gt 0) {
                $naoPublicados += ($p + ' (' + $pendentes + ' commit(s) em ' + $branch + ')')
            }
        }
    }

    Pop-Location
}

Write-Host ''
Write-Host ('Varridos ' + $projetos.Count + ' projetos: ' + $feitos + ' com git novo, ' + $jaTinham + ' ja tinham.') -ForegroundColor Yellow

if ($fora.Count -gt 0) {
    Write-Host ''
    Write-Host 'Fora da varredura de proposito:' -ForegroundColor DarkGray
    foreach ($k in ($fora.Keys | Sort-Object)) {
        Write-Host ('    ' + $k + ' - ' + $fora[$k]) -ForegroundColor DarkGray
    }
}

if (-not $usarGitHub) {
    Write-Host ''
    Write-Host 'Git so local (sem GitHub, como combinado). O backup e o _organizacao\backup-local.ps1.' -ForegroundColor Green
}
else {
    if ($soLocalVistos.Count -gt 0) {
        Write-Host ''
        Write-Host 'So git local, sem GitHub de proposito (nao e pendencia):' -ForegroundColor DarkGray
        foreach ($p in $soLocalVistos) {
            Write-Host ('    ' + $p + ' - ' + $soLocal[$p]) -ForegroundColor DarkGray
        }
    }

    if ($semBackup.Count -gt 0) {
        Write-Host ''
        Write-Host 'SEM BACKUP no GitHub (git local so):' -ForegroundColor Red
        foreach ($p in $semBackup) {
            Write-Host ('    cd "' + $p + '"; gh repo create ' + $p + ' --private --source=. --push') -ForegroundColor Gray
        }
        Write-Host '    (precisa de "gh auth login" antes)' -ForegroundColor DarkGray
    }
    else {
        Write-Host ''
        Write-Host 'Todo projeto com git tem repositorio no GitHub, fora os so locais acima.' -ForegroundColor Green
    }

    if ($naoPublicados.Count -gt 0) {
        Write-Host ''
        Write-Host 'COMMIT FEITO E NAO PUBLICADO (esse trabalho nao esta no backup):' -ForegroundColor Red
        foreach ($p in $naoPublicados) {
            Write-Host ('    ' + $p) -ForegroundColor Gray
        }
        Write-Host '    Publicar com: cd NOME-DO-PROJETO; git push' -ForegroundColor DarkGray
    }
}

Write-Host ''
Write-Host 'Pra desfazer alteracoes nao commitadas de um projeto:' -ForegroundColor Yellow
Write-Host '    cd NOME-DO-PROJETO; git checkout .' -ForegroundColor Gray
