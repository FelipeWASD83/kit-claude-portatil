# CLAUDE.md: kit-claude-portatil

Kit que monta, por **um comando no PowerShell**, uma pasta de trabalho completa para o
Claude Code e a configuração do Claude em `~/.claude` **no computador de outra pessoa**
(criado em 16/10/2026 a pedido dele para uma pessoa que não usa GitHub). O que ele quer
dele: baixar tudo pela internet, sem levar arquivo na mão, com as mesmas configurações da
pasta dele **menos o que é pessoal**, e o Claude instalado lá fazendo a configuração com as
preferências da pessoa. Versão atual: ver `versao.json` (anda junto com o topo do
`CHANGELOG.md`).

## O que existe

| Caminho | O que é |
|---|---|
| `instalar.ps1` | O instalador que a pessoa roda (`irm .../instalar.ps1 \| iex`). Baixa `kit.zip` da release mais nova, confere o SHA-256, copia a pasta de trabalho e a config global. **ASCII, sem BOM, de propósito** (ver armadilhas) |
| `conteudo/pasta/` | A pasta de trabalho que a pessoa recebe. Base: o `_template` da raiz dele, limpo do que é pessoal e sem Codex |
| `conteudo/global/` | O que vai para `~/.claude`: `CLAUDE.md` pessoal (modelo com `_(preencher)_`), `rules/`, `settings.kit.json` (permissões somadas), `skills/ver-video` e `skills/context7-mcp` |
| `ferramentas/montar-pacote.ps1` | Gera `dist/kit.zip` + `.sha256` + cópia do instalador. Roda a varredura de privacidade antes |
| `ferramentas/verificar-privacidade.py` | Varre `conteudo/` (ou o zip, com `--zip`) atrás de termos que não podem viajar |
| `ferramentas/privacidade-local.txt` | **Fora do git.** A lista de termos pessoais (nomes de projeto, conta, hardware, regras de conteúdo). Escrever a lista num arquivo versionado publicaria o que ela protege |
| `ferramentas/publicar-versao.ps1` | Cria a release no GitHub (zip, sha256, instalador). **Só com ele mandando** |
| `testes/test_kit.py` | 27 testes: empacota, instala numa "casa" de mentira (`KIT_HOME`), atualiza, soma permissões, baixa por HTTP local, roda os scripts da pasta |

## Decisões que não se desfazem sem motivo

- **Tira só o que é pessoal.** Regras, skills e scripts são os dele; saem tudo o que é
  identidade e infraestrutura pessoal (nome, hardware, servidores, projetos e personas
  dele, o backup dele), o espelho para outro agente e as regras de conteúdo que
  são só dele. A varredura de privacidade impede o pacote de ser gerado se qualquer um
  aparecer.
- **A pessoa é "ela"** nos textos (pedido dele). O que depende do que ela sabe ou prefere
  é condicional à seção 0 do `CLAUDE.md` dela, que a `/primeira-configuracao` preenche.
- **Git só local, sem GitHub**, mas com **recomendação forte uma vez**: o passo 5 da
  `primeira-configuracao` (entre as marcas `github-recomendacao:inicio/fim`) argumenta, pergunta e,
  **assim que ela responde, o próprio Claude apaga o passo inteiro do `SKILL.md`**. Se ela
  aceitar, `referencias/github.md` troca o bloco `github:inicio/fim` do `CLAUDE.md` e liga
  `$usarGitHub` no `git-setup.ps1`. Um teste confere que as marcas são pareadas e que
  tirar o bloco deixa a skill inteira.
- **Distribuição pela release pública** do repositório (`releases/latest/download/`):
  assim a pessoa não precisa de conta nem de token. Por isso o repositório é **público** e
  nada pessoal pode entrar nele. **Tornar público e publicar release são decisões dele.**
- **O instalador não instala nada da máquina** (Git, Python, Node, Claude Code): só avisa. Só
  o `ver-video` tem instalador próprio, e só com ela confirmando (baixa vários GB).
- **Atualizar é rodar de novo.** Troca o que é do kit (com backup em `~/.claude/kit-backups`),
  nunca o que é dela: `CLAUDE.md`, `settings.json`, `launch.json`, `PORTAS.md`,
  `LEIA-PRIMEIRO.md`, `git-setup.ps1`, `checar-pasta.ps1` e os projetos. Arquivo dela que
  ela apagou não volta. Depois que `kit-instalado.json` diz `configurado: true`, a
  `primeira-configuracao` também não é mais trocada (senão a recomendação do GitHub voltaria).
- **Permissões somam, nunca substituem.** `settings.json` existente é lido, as permissões do
  kit são somadas sem duplicar, hooks e o resto ficam, e o antigo vai para o backup. JSON
  inválido não é tocado (o do kit fica ao lado em `settings.kit.json`).
- **`~/.claude/CLAUDE.md` pessoal existente nunca é sobrescrito**: o modelo do kit fica ao lado
  em `CLAUDE.kit-modelo.md`.
- **Skills novas (16/10/2026):** `primeira-configuracao`, `depurar`, `diagnosticar-pc`, `backup-local`.
  As outras 9 vêm do `_template` com os nomes e o hardware dele trocados por texto neutro
  (a `inicializar-pasta` foi reescrita: sem Codex, sem GitHub).

## Armadilhas

- **Todo `.ps1` do kit é ASCII, sem BOM** (os testes conferem). O `irm | iex` do PowerShell
  5.1 estraga a primeira linha de um script com BOM, e script sem BOM é lido como ANSI.
  Por isso as mensagens não têm acento. Para regex que precisa de caractere não ASCII
  (o travessão do `checar-pasta.ps1`), usar `[char]0x2014`.
- **Editar arquivo com barra invertida: `Write` ou `Edit`, nunca heredoc.** Mais de uma vez o
  heredoc comeu `\b` e virou caractere de controle (aconteceu de novo no `LEIA-PRIMEIRO.md`).
- `KIT_HOME` existe só para os testes (instalar numa casa de mentira); com ele o instalador pula
  MCP e ver-video. O `-BaseUrl` do instalador também é para teste (servidor HTTP local).
- O pacote leva um `versao.json` **só com a versão**: o endereço do repositório (e a conta dele)
  não viaja no zip.
- `privacidade-local.txt` não está no git: num PC novo, recriar (os testes do zip ainda passam
  com a lista embutida, mas só a local pega nomes de projeto e regras de conteúdo).
- Dentro da pasta `Claude Code` dele, o Claude Code lista as skills de `conteudo/pasta` com
  prefixo e escopo (ruído da lista, igual ao `_template`).

## Testar

```powershell
python -m unittest discover -s testes -v
```

Leva ~30 s, usa o Windows PowerShell 5.1, não toca no `~/.claude` real, no `claude mcp` nem na
internet. **Não testado:** o download de verdade pelo GitHub (a release ainda não existe), o
Claude Code lendo as skills no PC dela, o `ver-video` instalando (baixa GB) e um Smart App
Control ligado no PC dela.

## Publicar uma versão (decisão dele)

1. Subir a versão em `versao.json` e no `CHANGELOG.md`, rodar os testes, commitar, `git push`.
2. `powershell -ExecutionPolicy Bypass -File .\ferramentas\publicar-versao.ps1` (cria a release
   `vX.Y.Z` com `kit.zip`, `kit.zip.sha256` e `instalar.ps1`).
3. Conferir o comando de instalação do `README.md` num PowerShell limpo.

## Mexer nas regras da pasta dele?

Este kit **não é espelho** do `_template`: foi copiado e limpo em 16/10/2026. Regra nova que vale
para qualquer pasta, e que ele queira que a outra pessoa receba, entra aqui à mão (e o
`CHANGELOG.md` sobe), depois de passar pela varredura de privacidade.
