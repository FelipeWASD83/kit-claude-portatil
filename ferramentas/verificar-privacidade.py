"""Varre o que vai no pacote atras de coisa pessoal do dono do kit (ou de regra que nao pode viajar).

Uso, na raiz do projeto:
    python ferramentas\\verificar-privacidade.py              # varre a pasta conteudo/
    python ferramentas\\verificar-privacidade.py --zip dist\\kit.zip   # varre o que realmente esta no zip

Sai com 0 se limpo e 1 se achou algo (e imprime arquivo:linha: termo).

Dois niveis de lista:
- TERMOS, abaixo: genericos e sem dado pessoal, ficam no git.
- ferramentas/privacidade-local.txt: um termo (ou regex) por linha, `#` comenta. Fica FORA do git
  (esta no .gitignore) porque escrever aqui o que se quer proteger publicaria o que se protege.
  Sem o arquivo, so vale a lista de baixo.
"""
import io
import re
import sys
import zipfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LOCAL = Path(__file__).resolve().parent / "privacidade-local.txt"

# (rotulo, regex). Case-insensitive. So entra aqui o que nao entrega nada de pessoal:
# o que e pessoal de verdade (nomes de projeto, hardware, regras de conteudo) mora no
# privacidade-local.txt, fora do git.
TERMOS = [
    ("outro agente (o kit e so do Claude Code)", r"\bcodex\b|agents\.md|\.agents\b"),
    ("caminho de usuario real", r"c:\\users\\(?!fulana|usuario|voce)[a-z0-9._-]+\\"),
    ("e-mail pessoal", r"[\w.+-]+@(gmail|hotmail|outlook|yahoo|icloud)\.com"),
    ("chave de API", r"sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}"),
    ("chave privada", r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
]

EXT_TEXTO = {".md", ".txt", ".json", ".ps1", ".py", ".ts", ".tsx", ".js", ".mjs", ".cjs", ".css", ".html",
             ".yaml", ".yml", ".toml", ".gitignore", ".cmd", ".bat", ".svg"}


def termos():
    lista = [(r, re.compile(rx, re.IGNORECASE)) for r, rx in TERMOS]
    if LOCAL.exists():
        for n, linha in enumerate(LOCAL.read_text(encoding="utf-8").splitlines(), 1):
            linha = linha.strip()
            if linha and not linha.startswith("#"):
                lista.append((f"privacidade-local.txt:{n}", re.compile(linha, re.IGNORECASE)))
    return lista


def eh_texto(nome):
    p = Path(nome)
    return p.suffix.lower() in EXT_TEXTO or p.name in {".gitignore", ".gitattributes"}


def varrer_texto(rotulo, texto, lista, achados):
    for n, linha in enumerate(texto.splitlines(), 1):
        for nome_termo, rx in lista:
            m = rx.search(linha)
            if m:
                achados.append(f"{rotulo}:{n}: [{nome_termo}] {m.group(0)!r}  | {linha.strip()[:110]}")


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    lista = termos()
    achados = []
    n_arquivos = 0
    if "--zip" in sys.argv:
        caminho = Path(sys.argv[sys.argv.index("--zip") + 1])
        with zipfile.ZipFile(caminho) as z:
            for nome in z.namelist():
                if nome.endswith("/") or not eh_texto(nome):
                    continue
                n_arquivos += 1
                varrer_texto(nome, z.read(nome).decode("utf-8", errors="replace"), lista, achados)
    else:
        base = RAIZ / "conteudo"
        for p in sorted(base.rglob("*")):
            if not p.is_file() or not eh_texto(p.name) or "__pycache__" in p.parts:
                continue
            n_arquivos += 1
            rel = p.relative_to(RAIZ).as_posix()
            varrer_texto(rel, p.read_text(encoding="utf-8", errors="replace"), lista, achados)
    print(f"Varredura de privacidade: {n_arquivos} arquivos de texto, {len(lista)} termos"
          + ("" if LOCAL.exists() else " (sem privacidade-local.txt)") + f", {len(achados)} achado(s).")
    for a in achados[:200]:
        print("  " + a)
    if len(achados) > 200:
        print(f"  ... e mais {len(achados) - 200}")
    return 1 if achados else 0


if __name__ == "__main__":
    sys.exit(main())
