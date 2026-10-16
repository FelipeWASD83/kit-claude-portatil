# kit-claude-portatil

Uma pasta de trabalho pronta para o **Claude Code**, instalada com **um comando no
PowerShell**: regras de trabalho, 13 skills, biblioteca de referências visuais, scripts
de git e backup, e a configuração do Claude em `~/.claude`. Não precisa de conta no
GitHub, de administrador, nem de levar arquivo de um computador para outro.

Depois de instalar, o próprio Claude faz uma entrevista (a `/primeira-configuracao`),
mede o computador e grava as preferências da pessoa.

## Instalar

No PowerShell, em qualquer pasta:

```powershell
irm https://github.com/FelipeWASD83/kit-claude-portatil/releases/latest/download/instalar.ps1 | iex
```

Ele pergunta onde criar a pasta de trabalho (padrão: `Documentos\Claude Code`), baixa o
pacote, confere o SHA-256 e instala. Para não responder nada e escolher a pasta:

```powershell
& ([scriptblock]::Create((irm https://github.com/FelipeWASD83/kit-claude-portatil/releases/latest/download/instalar.ps1))) -Destino "D:\Trabalho" -Sim
```

Parâmetros: `-Destino` (a pasta), `-Sim` (aceita os padrões, sem perguntar), `-SemVideo`
(não oferece instalar o que a skill `ver-video` precisa), `-SemMcp` (não mexe nos MCP),
`-ArquivoLocal` (usa um `kit.zip` que já está no disco, para instalar sem internet).

Depois:

```powershell
cd "$HOME\Documents\Claude Code"
claude
```

e dentro do Claude: `/primeira-configuracao`.

## Atualizar

Rodar o mesmo comando de novo. Skills e scripts do kit são trocados (a versão antiga vai
para `~\.claude\kit-backups\<data>`); o `CLAUDE.md`, o `settings.json`, o `launch.json`,
o `PORTAS.md`, os projetos e as preferências ficam como estão.

## O que entra

| Onde | O que |
|---|---|
| Pasta de trabalho | `CLAUDE.md` (regras), `PORTAS.md`, `.gitignore`, `LEIA-PRIMEIRO.md`, `_REVISAR\` |
| `.claude\skills` | `primeira-configuracao`, `inicializar-pasta`, `direcao-visual`, `revisar-visual`, `checklist-web`, `entregar-site`, `revisar-codigo`, `pesquisa-tecnica`, `depurar`, `diagnosticar-pc`, `backup-local`, `gml`, `video-motion` |
| `.claude\referencias-visuais` | 23 prints analisados e o método de usar referência |
| `_organizacao` | git local, conferência da pasta, backup local e agendamento, guia de ferramentas |
| `~\.claude\skills` | `ver-video` (o Claude vê e ouve vídeo) e `context7-mcp` |
| `~\.claude` | `CLAUDE.md` pessoal (campos por preencher), `rules\context7.md`, permissões somadas ao `settings.json` |
| MCP | `chrome-devtools`, `deepwiki`, `context7` (se o comando `claude` existir) |

O que **não** faz: não instala Git, Python, Node nem Claude Code (só avisa se faltarem),
não mexe em configuração de segurança do Windows e não cria conta em lugar nenhum.

## Git sem GitHub

O git é só local: cada projeto guarda o próprio histórico, e o backup da pasta inteira é o
`_organizacao\backup-local.ps1` (destino escolhido com a skill `backup-local`: HD externo,
pendrive ou outra pasta). A `/primeira-configuracao` conversa uma vez sobre criar a conta
no GitHub e, se a pessoa aceitar, liga o modo GitHub; em qualquer caso, depois disso ela
apaga a própria recomendação.

## Para quem mantém o kit

Ver o [`CLAUDE.md`](CLAUDE.md): estrutura, testes, privacidade e como publicar uma versão.

Licença: MIT.
