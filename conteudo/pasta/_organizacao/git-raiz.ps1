# git-raiz.ps1 - git da CONFIGURACAO da pasta (regras, PORTAS.md, .gitignore,
# .claude, _organizacao). Os projetos ficam de fora: cada um tem o
# repositorio dele.
#
# POR QUE NAO E UM .git NORMAL: um .git na raiz faz as buscas do Claude Code e
# (ripgrep) ignorarem todas as pastas de projeto, e muda a "raiz do
# projeto" das subpastas que nao tem git. Por isso o repositorio mora em
# .config-git (pasta escondida, com core.worktree apontando para a raiz), e a
# lista do que entra fica em .config-git\info\exclude.
#
# COMO USAR, na raiz (tudo depois do nome do script vai direto para o git):
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\git-raiz.ps1" status
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\git-raiz.ps1" log --oneline
#
# git add SEMPRE com caminho - nunca -A.
#
# PASTA NOVA (vinda do kit): criar uma vez com
#     git --git-dir=.config-git init -b main
#     git --git-dir=.config-git config core.worktree "<caminho da raiz>"
#     git --git-dir=.config-git config status.showUntrackedFiles no
# e escrever em .config-git\info\exclude a lista: /* e depois !/CLAUDE.md,
# !/PORTAS.md, !/.gitignore, !/.claude/, !/_organizacao/

$raiz = Split-Path -Parent $PSScriptRoot
$gitDir = Join-Path $raiz '.config-git'
if (-not (Test-Path $gitDir)) {
    Write-Host 'Nao existe .config-git na raiz - veja o cabecalho deste script para criar.' -ForegroundColor Red
    exit 1
}
& git --git-dir="$gitDir" --work-tree="$raiz" @args
exit $LASTEXITCODE
