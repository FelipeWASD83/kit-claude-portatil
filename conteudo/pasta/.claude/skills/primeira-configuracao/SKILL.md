---
name: primeira-configuracao
description: Primeira configuração do Claude neste computador - mede a máquina, entrevista a pessoa, escreve as preferências dela no CLAUDE.md da pasta e no ~/.claude/CLAUDE.md, ajusta o git, conversa sobre GitHub (uma vez) e termina limpando o que só serve para a primeira vez. Usar quando a pessoa chamar /primeira-configuracao ou quando o CLAUDE.md da pasta ainda estiver com _(preencher)_.
argument-hint: "[nada]"
disable-model-invocation: true
---

# Primeira configuração

O kit trouxe regras, skills e scripts prontos, mas **não sabe quem é a pessoa nem
como é o computador dela**. Esta skill fecha essa distância uma vez, conversando.
Quanto melhor ela for feita, menos a pessoa vai precisar repetir coisa depois.

Regras desta conversa:

- Perguntar em blocos curtos (no máximo 4 perguntas por vez), com opções quando
  houver, usando a ferramenta de perguntas do Claude Code se ela existir. Dizer no
  começo que "pula" vale para qualquer pergunta e que tudo pode ser mudado depois.
- **Medir antes de perguntar**: o que o computador responde, não se pergunta.
- **Nunca pedir nem digitar senha, token ou chave da pessoa.** Quando algo exigir
  login, dizer onde clicar e deixar ela fazer.
- Escrever só o que ela disse ou o que foi medido. Campo sem resposta continua
  `_(preencher)_`, não vira chute.
- Pasta desta configuração: a raiz que contém este `.claude\skills\` (se a sessão
  estiver dentro de um projeto, subir até achar o `CLAUDE.md` com a seção 0; o
  caminho também está em `~/.claude/kit-instalado.json`, campo `pasta`).

## 0. Ver se já foi feito

Abrir o `CLAUDE.md` da raiz. Se a seção 0 e a seção 2 já não têm `_(preencher)_` e
o aviso do topo sumiu, a pasta já foi configurada: dizer isso e perguntar o que ela
quer **atualizar** (uma preferência, a máquina que mudou, o git). Fazer só esse
pedaço e sair.

## 1. Medir a máquina

Só leitura, nada que mude o sistema. PowerShell:

```powershell
# sistema, processador, memória
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors
[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB), 'GB de RAM'
# placa de vídeo (AdapterRAM trava em 4 GB: para NVIDIA, o nvidia-smi dá o número certo)
Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, CurrentRefreshRate
nvidia-smi --query-gpu=name,memory.total --format=csv
# telas
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::AllScreens | Select-Object DeviceName, Primary, Bounds
# espaço em disco
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{n='LivreGB';e={[math]::Round($_.Free/1GB)}}
# Smart App Control: 0 desligado, 1 ligado, 2 em avaliação
(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' -ErrorAction SilentlyContinue).VerifiedAndReputablePolicyState
```

As resoluções de `Screen` podem sair reduzidas pela escala do Windows; confirmar
com a pessoa ("o seu monitor principal é 1920×1080? 2560×1440?"). Ferramentas, com
a versão de cada uma (cada uma que faltar vira "não instalado", sem alarde):

```powershell
foreach ($c in 'python','py','node','npm','git','gh','ffmpeg','yt-dlp','winget','claude','code') {
  $x = Get-Command $c -ErrorAction SilentlyContinue
  '{0}: {1}' -f $c, $(if ($x) { $x.Source } else { 'nao instalado' })
}
python --version; node --version; git --version
```

`python` que abre a Microsoft Store é o stub, não é Python instalado: tratar como
não instalado e sugerir `winget install Python.Python.3.13`.

Mostrar o resumo à pessoa em poucas linhas e pedir para ela corrigir o que
estiver errado.

## 2. Entrevista

Quatro blocos, adaptando ao que ela for respondendo.

**A. Quem é.** Como quer ser chamada; o que faz (trabalho, estudo, hobby); para que
vai usar o Claude (sites, automação, jogos, vídeo e áudio, planilhas, estudo,
escrita...).

**B. O que sabe de programação.** Nenhuma, o básico, ou quais linguagens lê e
escreve bem. Com isso decidir: em quais linguagens posso falar técnico direto; em
quais devo explicar **o que o programa faz e como usar** em vez de como funciona
por dentro; se ela consegue mexer em código quando eu disser exatamente onde.
Perguntar também quais programas usa (editores de vídeo, imagem, áudio, jogo).

**C. Tom e formato.** Formal ou informal; gíria e palavrão liberados ou não; humor
ou direto ao ponto; respostas curtas ou detalhadas; o que a irrita (elogio
automático, emoji, texto com cara de IA, travessão, pergunta demais). Isso vira o
"Tom" do `~/.claude/CLAUDE.md`.

**D. Jeito de trabalhar.** Quer plano e aprovação antes de tarefas grandes (padrão
das regras: sim, para o que não é pequeno)? Commit automático ao fim de cada
tarefa (padrão: sim)? Tem estética preferida para sites, ou quer que eu escolha
por projeto (padrão: por projeto)? O projeto roda só no PC dela ou também no
celular (padrão: só no PC)?

## 3. Escrever

1. **`CLAUDE.md` da pasta.** Trocar `NOME-DA-PASTA` no título pelo nome da pasta.
   Preencher a seção 0 com as respostas e a seção 2 (a máquina) com o que foi
   medido e confirmado. Se o que ela respondeu mudar uma regra das seções 1 a 6
   (por exemplo "não quero plano antes de tudo"), ajustar a regra, com uma linha
   dizendo que é preferência dela.
2. **`~/.claude/CLAUDE.md`** (valendo em qualquer pasta). O instalador deixa o modelo
   em `~/.claude/CLAUDE.kit-modelo.md` e, se a pessoa ainda não tinha um
   `CLAUDE.md` global, uma cópia dele como `~/.claude/CLAUDE.md`. Três casos:
   - o `CLAUDE.md` global tem `_(preencher)_`: trocar cada campo pelas respostas e
     pelo que foi medido (tom, "Sobre mim", "Meu computador"), e apagar o
     `CLAUDE.kit-modelo.md` depois;
   - não existe nenhum dos dois: criar a partir do modelo do kit (a cópia dele no
     `.zip` não está mais aqui; escrever o essencial das seções "Sobre mim",
     "Meu computador", "Tom" e "Respostas" com o que a conversa produziu);
   - existe e é dela, **sem** marcas do kit: **não sobrescrever**. Comparar com o
     `CLAUDE.kit-modelo.md`, propor o que acrescentar e só acrescentar o que ela
     aprovar; apagar o modelo depois.
3. **Git da máquina.** Se `git config --global user.name` estiver vazio, perguntar
   o nome e o e-mail que ela quer nos commits (ficam só no computador dela) e
   configurar com `git config --global user.name "..."` e `user.email`. Não mexer
   se já estiver configurado.
4. **Fuso, idioma e formato de data** só se ela mencionar algo diferente do padrão
   brasileiro.

## 4. Ferramentas

Com a pessoa concordando em cada uma:

- `claude mcp list`: chrome-devtools, deepwiki e context7 devem aparecer
  conectados. Se faltar algum, os comandos estão em
  `_organizacao\instalar-ferramentas.md`.
- **ver-video**: se não existir `%USERPROFILE%\.claude\ver-video\venv`, explicar
  que ver e ouvir vídeo precisa de ffmpeg, yt-dlp e um ambiente Python com Whisper
  (vários GB, alguns minutos) e oferecer rodar
  `powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\ver-video\instalar.ps1"`.
  Se ela não quiser agora, a skill `ver-video` oferece de novo na primeira vez que
  for preciso.
- **Backup**: oferecer a skill `backup-local` (escolher o HD, pendrive ou pasta
  de destino). É o único backup dela fora do próprio PC enquanto não houver
  repositório remoto.

<!-- github-recomendacao:inicio -->
## 5. GitHub: recomendar com força, uma vez só

A pessoa disse antes que não usa nem quer criar conta no GitHub. Mesmo assim, **esta
é a recomendação mais forte desta configuração**, e ela merece ouvi-la inteira antes
de decidir. Dizer em poucas linhas, sem sermão e sem repetir depois:

1. **Backup fora do PC e fora de casa.** O backup local protege de apagar sem querer
   e de o disco morrer; não protege de furto, incêndio, enchente nem de um HD
   externo que cai da mesa junto com o notebook. Um repositório privado é uma cópia
   em outro lugar, grátis.
2. **Histórico e desfazer de verdade.** Todo projeto já tem git, mas só local: se
   a pasta for apagada, o histórico vai junto. Com o repositório, qualquer versão
   antiga volta.
3. **Custa nada.** Conta gratuita, repositório privado gratuito e ilimitado, uns 5
   minutos para criar. Só precisa de um e-mail.
4. **Privado é privado.** Nada vira público sem ela mandar, e o Claude não torna
   nada público sozinho.
5. **O Claude trabalha melhor com ele.** Cria o repositório de cada projeto no
   momento em que o projeto nasce, abre e revisa pull request, e o Claude Code na
   nuvem (`/web-setup`) só funciona com o GitHub.
6. **Publicar site fica trivial.** Cloudflare Pages e o próprio GitHub Pages
   publicam direto de um repositório.

Dizer com franqueza que a decisão é dela, e perguntar: **criar a conta agora (eu
guio)**, **depois**, ou **não quero**.

- **Agora:** guiar passo a passo, sem nunca digitar a senha dela.
  1. Ela abre `https://github.com/signup` no navegador e cria a conta (e-mail,
     senha, nome de usuário). O Claude não preenche isso.
  2. `winget install --id GitHub.cli`; fechar e abrir o PowerShell.
  3. `gh auth login` → GitHub.com → HTTPS → autenticar o git → login pelo
     navegador (ela cola o código que aparece).
  4. Conferir com `gh auth status`.
  5. Trocar o modo da pasta seguindo `.claude/skills/primeira-configuracao/referencias/github.md`
     (regra de GitHub da seção 6, `$usarGitHub = $true` no `git-setup.ps1`,
     permissões do `gh` no `settings.json`, linha "GitHub:" da seção 0) e
     **oferecer** subir os projetos que já existem, perguntando privado ou
     público projeto a projeto.
- **Depois ou não quero:** respeitar, sem insistir. Registrar na seção 0 do
  `CLAUDE.md`: `GitHub: não usa (recomendado em AAAA-MM-DD; adiou/recusou)`. Deixar
  `referencias/github.md` onde está: se ela mudar de ideia, o Claude liga o modo
  GitHub sem recomeçar.

**Assim que ela responder, apagar este passo 5 inteiro deste `SKILL.md`**, das
marcas `github-recomendacao:inicio` até `github-recomendacao:fim`, e conferir que
sobrou nenhuma das duas marcas (`Select-String -Path ... -Pattern 'github-recomendacao'`).
A recomendação existe para ser feita uma vez; depois dela, esta skill não volta a
tocar no assunto.
<!-- github-recomendacao:fim -->

## 6. Fechar

1. **Pastas e arquivos.** Confirmar que existem `_REVISAR\` e `.claude\launch.json`.
2. **Conferir a pasta:**

   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\_organizacao\checar-pasta.ps1"
   ```

   O que sobrar de alerta, explicar; o que for só "backup não configurado", lembrar
   da skill `backup-local`.
3. **Aviso do topo do `CLAUDE.md`.** Se já houver projeto na pasta e o mapa da
   seção 7 estiver vazio, trocar o aviso por uma linha: "rodar `/inicializar-pasta`".
   Se não, apagar o aviso inteiro.
4. **Marcar como feito** em `~/.claude/kit-instalado.json`: `"configurado": true` e
   `"configurado_em": "AAAA-MM-DD"` (manter o resto do JSON).
5. **Relatar**, em português simples:

   ```
   Máquina: <o que foi medido, em uma linha>
   Preferências gravadas: <o que entrou em quais arquivos>
   Ferramentas: <MCP ok / ver-video instalado ou adiado / backup configurado ou adiado>
   GitHub: <o que ela decidiu>
   Falta: <o que ficou _(preencher)_ de propósito>
   Próximo passo: <digitar /inicializar-pasta se houver projeto; senão, começar um projeto>
   ```

   Não marcar como feito o que não foi verificado.
