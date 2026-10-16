# Changelog

## 1.0.0 (16/10/2026)

Primeira versão que funciona de ponta a ponta.

**Novo**
- Instalação por um comando no PowerShell, sem conta no GitHub e sem levar arquivo
  na mão: o `instalar.ps1` baixa o pacote da release, confere o SHA-256 e monta tudo.
- A pasta de trabalho completa: regras (`CLAUDE.md`), 13 skills, biblioteca de
  referências visuais com 23 prints, `launch.json`, `PORTAS.md` e os scripts de
  organização (git local, conferência da pasta, backup local com agendamento).
- Duas skills pessoais em `~/.claude/skills`: `ver-video` e `context7-mcp`.
- `~/.claude`: `CLAUDE.md` pessoal com campos por preencher, regra de documentação
  atual de bibliotecas e permissões seguras somadas às que já existirem, com backup.
- Os MCP `chrome-devtools`, `deepwiki` e `context7`, adicionados quando o comando
  `claude` existe.
- Skills novas: `primeira-configuracao` (mede a máquina, entrevista a pessoa,
  grava as preferências e conversa sobre GitHub uma vez, apagando depois essa
  parte), `depurar`, `diagnosticar-pc` e `backup-local`.
- Rodar o instalador de novo atualiza skills e scripts (a versão trocada vai para
  `~/.claude/kit-backups`) sem tocar no `CLAUDE.md`, nas permissões e nos projetos.
