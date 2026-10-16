"""Copia a configuracao do Claude que mora fora desta pasta para _organizacao/config-agentes.

Uso, na raiz da pasta:
    python _organizacao\\salvar-config.py            # atualiza a copia
    python _organizacao\\salvar-config.py --simular  # so mostra o que mudaria

Por que: as instrucoes globais (~/.claude/CLAUDE.md), as regras, as skills
pessoais, as permissoes e a memoria do Claude Code desta pasta moram em
~/.claude, e o espelho do backup so leva esta pasta. Copiando para ca, elas entram
no backup. O backup-local.ps1 roda este script antes de espelhar.

Lista FECHADA do que entra (origens). Nunca entra credencial, sessao, cache, log
nem banco. A pasta de destino e espelho: arquivo que sumiu da origem sai daqui
tambem, so dentro de config-agentes/ e nunca o LEIA.md.
"""
import filecmp
import shutil
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "_organizacao" / "config-agentes"
HOME = Path.home()
FICA = {"LEIA.md"}
# Pastas de projeto do Claude Code que sao teste descartavel, nao memoria de verdade.
TEMPORARIAS = ("AppData-Local-Temp",)
# Dentro de ~/.claude/skills nao entra o que se refaz sozinho.
IGNORAR = {"__pycache__", "venv", "saidas", "modelos", "node_modules"}


def origens():
    """[(caminho de origem, caminho relativo no destino)] do que existe hoje."""
    lista = []

    def arquivo(origem, destino):
        if origem.is_file():
            lista.append((origem, destino))

    def pasta(origem, destino, so_md=False):
        if origem.is_dir():
            for p in sorted(origem.rglob("*")):
                if not p.is_file() or IGNORAR & set(p.parts):
                    continue
                if so_md and p.suffix != ".md":
                    continue
                lista.append((p, destino / p.relative_to(origem)))

    c = HOME / ".claude"
    arquivo(c / "CLAUDE.md", Path("claude/CLAUDE.md"))
    arquivo(c / "settings.json", Path("claude/settings.json"))
    arquivo(c / "keybindings.json", Path("claude/keybindings.json"))
    pasta(c / "rules", Path("claude/rules"))
    pasta(c / "skills", Path("claude/skills"))
    projetos = c / "projects"
    if projetos.is_dir():
        for proj in sorted(projetos.glob("*")):
            if any(t in proj.name for t in TEMPORARIAS):
                continue
            pasta(proj / "memory", Path("claude/memoria") / proj.name, so_md=True)
    return lista


def main():
    simular = "--simular" in sys.argv
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    lista = origens()
    esperados = {rel.as_posix() for _, rel in lista}
    novos = mudados = apagados = 0
    for origem, rel in lista:
        alvo = DESTINO / rel
        if alvo.exists() and filecmp.cmp(origem, alvo, shallow=False):
            continue
        novo = not alvo.exists()
        print(("novo:    " if novo else "mudou:   ") + rel.as_posix())
        novos, mudados = novos + novo, mudados + (not novo)
        if not simular:
            alvo.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(origem, alvo)
    if DESTINO.exists():
        for p in sorted(DESTINO.rglob("*"), reverse=True):
            rel = p.relative_to(DESTINO).as_posix()
            if p.is_file() and rel not in esperados and rel not in FICA:
                print("saiu:    " + rel)
                apagados += 1
                if not simular:
                    p.unlink()
            elif p.is_dir() and not simular and not any(p.iterdir()):
                p.rmdir()
    print(f"{len(lista)} arquivos na lista: {novos} novos, {mudados} mudaram, {apagados} sairam"
          + (" (simulado)" if simular else "") + f". Destino: {DESTINO}")


if __name__ == "__main__":
    main()
