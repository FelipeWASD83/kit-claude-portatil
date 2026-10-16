# Sua pasta de trabalho com o Claude

Esta pasta veio do **kit-claude-portatil**. É a pasta onde você guarda os seus
projetos (um projeto por subpasta), já configurada para o Claude Code trabalhar
bem nela: regras, procedimentos prontos (skills), biblioteca de referências
visuais e scripts de organização e backup.

## Primeiro passo: abrir o Claude aqui e configurar

1. Abra o Claude Code **nesta pasta** (a pasta que contém este arquivo, não uma
   subpasta).
2. Digite:

   ```
   /primeira-configuracao
   ```

   O Claude faz algumas perguntas sobre você, mede o seu computador e escreve as
   suas preferências nas regras. Leva uns minutos e só precisa ser feito uma vez.
3. Se você já tem projetos para trazer, jogue as pastas deles aqui dentro (uma
   pasta por projeto, direto na raiz) e digite `/inicializar-pasta`.
4. Quando as duas estiverem feitas, pode apagar este arquivo.

## O que tem aqui

```
CLAUDE.md                     as regras de trabalho do Claude nesta pasta
PORTAS.md                     registro de portas dos projetos web
.gitignore                    o padrão do que não vai para o git
.claude/
  settings.json               permissões: o que é livre, o que pergunta, o que é proibido
  launch.json                 como rodar e previsualizar cada projeto web
  skills/                     os procedimentos (veja abaixo)
  referencias-visuais/        biblioteca de sites bem feitos, para o visual não ficar genérico
_organizacao/                 scripts de manutenção: git, backup, conferência
_REVISAR/                     quarentena: o que sai de lugar vem para cá, nada é apagado
```

Fora da pasta, em `~/.claude/` (a sua pasta de usuário), ficam o `CLAUDE.md` com as
suas preferências pessoais, duas skills que valem em qualquer lugar (`ver-video` e
`context7-mcp`) e as regras de documentação.

## As skills (procedimentos prontos)

Você chama uma digitando `/` e o nome. As marcadas com (sozinha) o Claude usa quando
o assunto pede.

| Skill | Para quê |
|---|---|
| `primeira-configuracao` | A entrevista inicial (uma vez) |
| `inicializar-pasta` | Mapear os projetos que já estão aqui |
| `direcao-visual` (sozinha) | Decidir a cara de um site antes de escrever o CSS |
| `revisar-visual` | Abrir no navegador, tirar prints e corrigir o que estiver feio ou quebrado |
| `checklist-web` (sozinha) | O que precisa estar pronto antes de dizer "acabou" |
| `entregar-site` | Checklist antes de publicar um site |
| `revisar-codigo` (sozinha) | Procurar o que ficou pela metade ou só finge funcionar |
| `pesquisa-tecnica` (sozinha) | Pesquisar antes de escolher uma biblioteca ou ferramenta |
| `depurar` (sozinha) | Achar a causa de um defeito por evidência, sem chute |
| `diagnosticar-pc` (sozinha) | Problema no Windows: logs e medição antes de mexer |
| `backup-local` (sozinha) | Configurar o backup num HD, pendrive ou outra pasta |
| `gml` (sozinha) | GameMaker: conferir função no manual oficial |
| `video-motion` (sozinha) | Vídeo animado em código, do roteiro ao MP4 |
| `ver-video` (sozinha, global) | O Claude "assiste" a um vídeo ou link e transcreve a fala |

## Git e GitHub

O git daqui é **só local**: cada projeto guarda o próprio histórico dentro da pasta
dele, e o backup da pasta inteira é o `_organizacao\backup-local.ps1` (configure o
destino com a skill `backup-local`). O GitHub é opcional; a `/primeira-configuracao`
conversa sobre isso uma vez, e dá para ligar a qualquer momento depois.

## Atualizar o kit

Para pegar a versão mais nova do kit (skills e scripts), rode de novo o comando de
instalação que você usou da primeira vez. As suas preferências e os seus projetos
não são tocados.
