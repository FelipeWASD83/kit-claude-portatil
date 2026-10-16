# Instalar as ferramentas do Claude Code

Guia de referência. Duas coisas importantes antes de começar:

- **PowerShell** = o terminal do Windows. Comandos que começam com `winget`,
  `npx` ou `claude mcp` vão aí.
- **Dentro do Claude Code** = digitado na conversa com o Claude, como mensagem.
  Comandos que começam com `/` vão aí.

Confundir os dois é o erro mais comum. Cada seção abaixo diz onde rodar.

O instalador do kit já tenta fazer a parte 1 sozinho. Este guia existe para
conferir, refazer ou instalar à mão.

---

## 1. MCP: as ferramentas extras do Claude

Todos precisam de Node instalado.

**No PowerShell, de qualquer pasta:**

```powershell
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
claude mcp add --transport http --scope user deepwiki https://mcp.deepwiki.com/mcp
claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp
```

O que cada um faz:

- **chrome-devtools**: deixa o Claude abrir a página, tirar screenshot, ler erro de
  console e rede, e rodar Lighthouse. É o que faz a `/revisar-visual` funcionar de
  verdade.
- **deepwiki**: deixa o Claude ler e perguntar sobre qualquer repositório público
  do GitHub. Gratuito, sem login (e sem precisar de conta no GitHub).
- **context7**: documentação atualizada de biblioteca, na versão que você usa.
  Anônimo, com limite de uso menor.

`--scope user` = vale em todos os projetos, não só na pasta atual.

**Conferir:** `claude mcp list`. Os três têm que aparecer conectados.

---

## 2. Cloudflare (só se for publicar site lá)

**Dentro do Claude Code**, digitando na conversa:

```
/plugin marketplace add cloudflare/skills
/plugin install cloudflare@cloudflare
```

Na primeira vez que o Claude usar uma ferramenta da Cloudflare, abre o navegador
pedindo autorização (OAuth) e você escolhe as permissões.

Serve para publicar site em Cloudflare Pages e para trabalhar com Worker.

---

## 3. GitHub (opcional, e nada disso é necessário sem conta)

Esta pasta funciona **sem GitHub**: o git é só local e o backup é o
`_organizacao\backup-local.ps1`. Se um dia você criar a conta, a skill
`primeira-configuracao` (ou o Claude, se você pedir) liga o resto. O básico:

```powershell
winget install --id GitHub.cli
gh auth login
```

Fecha e abre o PowerShell depois do winget (senão o `gh` não aparece no PATH).

---

## Se der errado

- `claude mcp add` não encontrado → o Claude Code CLI não está no PATH; abre o
  terminal integrado do Claude Code Desktop e roda de lá.
- MCP aparece como `failed` no `claude mcp list` → quase sempre é Node velho;
  `node -v` precisa ser LTS.
- Script `.ps1` não roda →
  `powershell -ExecutionPolicy Bypass -File ".\caminho.ps1"`.
