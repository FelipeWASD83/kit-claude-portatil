# Ligar o modo GitHub

Usar só quando a pessoa criou a conta e fez `gh auth login` (conferir com
`gh auth status`). Cada edição abaixo é pequena e deve ser mostrada a ela antes.

## 1. `CLAUDE.md` da pasta

**Seção 0:** trocar a linha `- **GitHub:** ...` por
`- **GitHub:** usa (conta de <usuário>, criada em AAAA-MM-DD)`. O usuário sai de
`gh api user --jq .login`.

**Seção 6, "Commit":** trocar o bloco entre `<!-- github:inicio -->` e
`<!-- github:fim -->` (a marca inclusive) por:

```
- **Repositório no GitHub:** todo projeto novo ganha também um repositório na
  conta da pessoa, com o nome da pasta, criado junto do commit inicial
  (`gh repo create <nome> --source . --remote origin --push`, com `--private` ou
  `--public`). **Antes de criar, pergunto se é privado ou público.** Não pergunto, e
  crio privado, quando o projeto tem dado pessoal ou de segurança da dona. A
  resposta à pergunta já é a aprovação de tornar público; mudar depois a
  visibilidade de um repositório que existe só com aprovação dela. A única exceção
  a ter repositório é coisa **absurdamente simples** (uma calculadora de terminal):
  esses não ganham repositório nem git. Na dúvida, cria.
- **O primeiro push do repositório novo é automático; o push dos commits seguintes
  continua decisão dela** (o `settings.json` pergunta no `git push`). **Nunca
  `git push --force`. Nunca reescrever histórico já publicado.**
```

**Seção 6, "Backup":** acrescentar depois do primeiro item:
`- **O GitHub guarda o código.** Todo projeto com git tem repositório privado, e o
  backup local guarda o resto (o que o git ignora).`

**Seção 3, regra 9:** acrescentar no fim: "Projeto que tem git mas fica só local,
sem GitHub, de propósito, vai na lista `$soLocal` do `git-setup.ps1`, com o motivo."

## 2. `_organizacao\git-setup.ps1`

Trocar `$usarGitHub = $false` por `$usarGitHub = $true`.

## 3. `.claude\settings.json`

Acrescentar em `permissions.allow`:

```
"Bash(gh pr list*)", "Bash(gh issue list*)", "Bash(gh repo view*)"
```

e em `permissions.ask`:

```
"Bash(gh repo create *)"
```

Conferir que o JSON continua válido.

## 4. Subir o que já existe

Rodar `_organizacao\git-setup.ps1`: ele lista os projetos sem repositório remoto,
com o comando pronto. **Não publicar nada sem ela escolher**, projeto por projeto,
entre privado e público. Padrão se ela não souber: privado.

## 5. Apps com atualização pelo GitHub (opcional)

Se algum projeto dela for um app instalado no PC, vale ele ter dentro de si o botão
de procurar atualização pelas releases do repositório. Só propor quando o assunto
aparecer.
