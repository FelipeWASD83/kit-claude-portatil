# CLAUDE.md: pasta `NOME-DA-PASTA`

> **Este arquivo veio do kit `kit-claude-portatil`.** Se a seção 0 ("Sobre mim")
> ainda está com `_(preencher)_`, ninguém rodou a primeira configuração:
> **a primeira coisa desta sessão é a `/primeira-configuracao`**. Ela é uma skill
> manual, então se a pessoa ainda não a chamou, avise que está pendente, ofereça
> rodar e, com o sim dela, leia `.claude/skills/primeira-configuracao/SKILL.md` e
> siga. Depois dela, e se já houver projeto aqui, a `/inicializar-pasta` preenche o
> mapa da seção 7. Quando as duas estiverem feitas, apagar esta citação.

Instruções para qualquer sessão do Claude Code aberta nesta pasta ou em qualquer
subpasta dela. "A pessoa" é a dona da pasta, e "ela" é ela.

O `CLAUDE.md` de um projeto específico **tem prioridade sobre este arquivo** e
sobre preferência geral: regra de projeto pode restringir o que vale no geral.
Quando duas instruções escritas se contradizem sobre a mesma coisa, vale a
decisão mais recente dela; e o que ela disser na conversa vale mais que qualquer
arquivo.

As preferências pessoais dela valem em qualquer pasta e ficam em
`~/.claude/CLAUDE.md` (a `/primeira-configuracao` cria). A seção 1 abaixo repete o
essencial e acrescenta o que é da pasta.

---

## 0. Sobre mim

Preenchido pela `/primeira-configuracao`. O que vale para qualquer pasta dela vai
também no `~/.claude/CLAUDE.md`; aqui fica o que a sessão precisa saber para
trabalhar nesta.

- **Nome e como prefere ser chamada:** _(preencher)_
- **O que faz, e com o que trabalha:** _(preencher)_
- **Programação:** _(preencher: o que sabe ler e escrever; o que não sabe)_
- **Tom das respostas:** _(preencher)_
- **O que não quer ver nas respostas:** _(preencher)_
- **Estética:** _(preencher: tem preferência fixa ou não)_
- **GitHub:** não usa (git só local; ver seção 6)

---

## 1. Como responder

- **Português do Brasil**, direto ao ponto, no tom da seção 0. Sem preâmbulo e sem
  elogiar o pedido.
- Tamanho da resposta proporcional à complexidade. Pergunta simples, resposta curta.
- Se ela estiver errada, dizer no começo, não escondido no fim.
- Se houver um caminho claramente melhor do que o pedido, apontar **antes** de
  executar. Se ela entender e mantiver a decisão, respeitar.
- Não inventar arquivos, funções, resultados de teste ou fontes. Não afirmar que
  algo funciona sem evidência. Quando não souber, dizer que não sabe.
- Separar o que é fato conferido, o que é dedução e o que é chute.

### Linguagens que ela lê

O que a seção 0 disser que ela sabe, falar técnico direto, sem explicar o básico.
Entregar código completo e rodável, sem TODO, stub ou pseudocódigo. Comentário só
quando a intenção não for óbvia.

### O que ela não lê

Para o que a seção 0 disser que ela **não** lê (muita gente não lê HTML, CSS e
JavaScript):

- Explicar **o que o app faz e como usar**, não como o código funciona por dentro.
- Achou um bug? **Corrigir**, não explicar teoricamente como ela poderia corrigir.
- Precisa que ela altere algo na mão? Dizer no formato
  `no arquivo X, procure a linha Y e troque para Z`.
- Sempre que der, testar e validar o resultado depois de alterar. No Claude Code
  Desktop isso é literal: o preview sobe o servidor pelo `.claude/launch.json` e a
  verificação automática tira screenshot e checa erro sozinha depois de cada
  edição. Projeto sem entrada no `launch.json` perde isso, então adicionar a
  entrada faz parte de trabalhar nele.

### Estética

**Sem estética padrão**, a não ser que a seção 0 diga o contrário. Não aplicar por
reflexo dark, gótico-futurista, neon, glassmorphism, fundo preto, accent color
única ou uma fonte favorita só porque apareceram em projetos anteriores. Escolher
a direção visual pelo propósito, público e conteúdo daquele projeto. Se o projeto é
de cliente, a identidade do cliente manda.

**Regra obrigatória:** em **todo site novo e todo redesign**, antes de propor
qualquer direção visual e antes de escrever a primeira linha de CSS, ler
`.claude/referencias-visuais/CLAUDE.md`. Sem exceção.

**Nunca repetir fundos seguidos.** Em qualquer site, dois blocos consecutivos não
podem ter o mesmo **tom** de fundo: claro depois de claro, ou escuro depois de
escuro, é violação mesmo quando o hex é diferente. **O rodapé conta como bloco.**
A única exceção é quando dois assuntos dividem literalmente um fundo só esticado,
sem emenda visível (sem borda, sem sombra, sem degrau de cor), e nesse caso a prova
é ler os pixels de uma coluna que atravesse a divisa, não comparar a cor
declarada. Conferir **medindo** a luminância computada de cada seção visível na
ordem do documento, incluindo o rodapé; olhar não basta. Acrescentar seção no meio
de uma página quase sempre obriga a trocar o tom de alguma vizinha, e isso faz
parte de inserir a seção.

### Decisões: requisito, padrão e escolha delegada

- **Requisito** é o que está escrito como obrigatório, "nunca", "sempre" ou "sem
  exceção", a identidade de um cliente e o que um projeto fixou no `CLAUDE.md`
  dele: não se flexibiliza por gosto, persona ou pressa. **Padrão** é exemplo,
  categoria sugerida, número de checklist e heurística de gosto: dá para trocar,
  dizendo por quê.
- **Escolha subjetiva que ela não fez está delegada**: estética, nome, copy, qual
  de duas opções igualmente boas. Eu escolho, digo em uma ou duas linhas o que e
  por quê, e sigo. "Escolhe você", "escolhe tudo" e "faz do jeito que achar
  melhor" delegam com mais força ainda: aí nenhuma skill devolve a escolha para
  ela.
- **Perguntar antes só quando** ela disse que quer escolher; o projeto é de
  cliente (quem decide é ela, junto com o cliente); ou uma regra específica manda
  perguntar e ela não delegou na conversa. Dado que falta e não trava o trabalho
  não vira pergunta: supor, dizer a suposição e seguir. **Exceção:** acrescentar o
  que ela não pediu pede permissão antes (seção 5).
- **Delegação explícita dispensa o plano.** Com "escolhe tudo", "escolhe você",
  "faz do jeito que achar melhor" ou algo do tipo, não parar no "pode ir?" da
  seção 5: seguir e contar em poucas linhas o que foi decidido. Delegação não
  cobre ação destrutiva nem mexer em produção de cliente.
- **Pedido no meio da execução já é o "pode ir".** Mensagem com tarefas concretas
  que ela manda enquanto eu trabalho (ou "para depois que terminar isso") é pedido
  e aprovação juntos: terminar o que estava fazendo e emendar nas tarefas novas,
  sem parar no plano da seção 5. Premissa errada eu aponto no relatório, sem
  travar. Não cobre ação destrutiva, deploy, push nem produção de cliente.
- **Persona ou estilo pedido** (tom, personalidade) muda como eu falo na conversa
  e, se ela disser, o gosto nas escolhas delegadas: não muda requisito, precisão
  técnica, honestidade sobre o que foi testado nem regra de cliente. Os arquivos de
  regra e de instrução (`CLAUDE.md`, skills, memória) ficam sempre neutros.

---

## 2. Ambiente

- **Windows**, terminal padrão **PowerShell**. Comandos de exemplo em PowerShell ou
  cmd, não bash. Não propor resolver nada "pelo Linux" ou por WSL a não ser que a
  seção 0 diga que ela usa.
- **Usar `python`, nunca `python3`**: no Windows `python3` cai no stub da Microsoft
  Store e falha.
- Antes de supor que um programa existe (Git, Node, Python, Excel), **conferir**.
- **Temperatura, thermal throttling e "gargalo" não se concluem pelo nome das
  peças:** só com medição real (temperatura, clocks, uso de CPU e GPU, frametime).

### A máquina (medida na primeira configuração)

A `/primeira-configuracao` mede e escreve aqui. Se estiver `_(preencher)_`, medir
antes de recomendar qualquer coisa que dependa de hardware.

- **Sistema:** _(preencher)_
- **Processador, placa de vídeo (e VRAM), memória:** _(preencher)_
- **Telas:** _(preencher: resolução, taxa de atualização, orientação)_
- **Ferramentas instaladas:** _(preencher: Python, Node, Git, ffmpeg, editor)_
- **Smart App Control:** _(preencher: ligado ou desligado)_. Ligado, ele bloqueia
  `.exe` recém-compilado (sem assinatura nem reputação) e pacote Python com parte
  nativa muito novo. Não afeta .NET, Java nem Electron. Saída conhecida para
  código nativo: compilar como DLL e carregar de dentro do `python.exe`. **Desligar
  é irreversível** (só volta reinstalando o Windows): decisão dela, nunca propor
  por conta própria.

### Telas e celular

Assumir que o projeto roda **só no PC dela**: não otimizar nem testar para celular,
rede fraca ou máquina modesta, a não ser que ela peça (aí vale para aquele projeto,
anotado no `CLAUDE.md` dele). E não limitar qualidade por "otimização": detalhe,
resolução, efeitos e peso de arquivo vão até o que o PC dela aguenta, e só se corta
quando a medição mostrar que não dá conta ou quando ela pedir. Conferir projeto web
nas resoluções das telas dela (acima). Projeto de cliente ou site público, que
outras pessoas abrem, não é "só no PC dela": nesses, perguntar numa linha se
celular entra.

---

## 3. Regras desta pasta

1. **Um projeto = uma pasta na raiz.** Não criar pasta nova na raiz sem ela pedir.
   Projeto novo que ela pediu já é o pedido: a pasta nasce com nome na regra 3.
2. **Nada solto na raiz.** Nenhum `.html`, `.png`, `.txt` ou `.zip` avulso. Se um
   arquivo não pertence a nenhum projeto, ele não fica aqui. Na raiz ficam só os
   arquivos de regra, o `PORTAS.md` e o `.gitignore` (mais o `LEIA-PRIMEIRO.md` do
   kit, até a pasta ser inicializada).
3. **Nomes de pasta:** `kebab-case-minusculo`. Sem espaços, sem parênteses
   explicativos, sem sufixo `_1`/`_2` de download repetido.
4. **Não guardar `.zip`/`.rar` do próprio projeto dentro dele.** Se precisar
   empacotar, gerar na hora e não deixar o pacote versionado ao lado do fonte.
5. **Nunca entregar nem versionar:** `__pycache__/`, `*.pyc`, `node_modules/`,
   `dist/`, `*.db-wal`, `*.db-shm`, pastas `uploads/` de runtime, `.env`, senhas,
   chaves e tokens.
6. **`_REVISAR/` é quarentena, não é fonte.** Nunca ler código de lá como se fosse a
   versão atual, nunca restaurar nada de lá sem ela mandar, e **nunca apagar nada
   de lá por conta própria**: a pasta existe justamente para ela revisar antes de
   decidir.
7. **`_organizacao/`** guarda os scripts de manutenção da pasta. Ignorar no dia a
   dia, mas eles existem para não confiar em memória:
   - `git-setup.ps1`: varre as pastas, cria git em quem não tem. Não publica nada
     (o git desta pasta é só local, ver seção 6).
   - `checar-pasta.ps1`: confere as regras desta seção, o `launch.json` contra o
     `PORTAS.md` e se o mapa da seção 7 bate com as pastas de verdade. Não move
     nem apaga nada.
   - `backup-local.ps1`: espelha esta pasta inteira no destino que a pessoa
     escolheu (HD externo, pendrive, outra pasta), lido de
     `_organizacao\backup-destino.txt`. Cópia fiel; com `-Simular`, mostra o que
     mudaria sem copiar. Aborta sozinho se a origem sumir ou vier quase vazia.
   - `agendar-backup-local.ps1`: cria (ou, com `-Remover`, tira) a tarefa do
     Agendador de Tarefas que roda o backup de hora em hora e ao entrar no Windows.
   - `salvar-config.py`: copia para `_organizacao\config-agentes` a configuração do
     Claude que mora fora da pasta (instruções globais, `settings.json`, regras,
     memória; lista fechada, nunca credencial). O `backup-local.ps1` roda antes de
     espelhar.
   - `git-raiz.ps1`: git só da configuração da raiz (regras, `PORTAS.md`,
     `.claude/`, `_organizacao/`), num repositório escondido em `.config-git`.
   - `instalar-ferramentas.md`: como instalar Git, os MCP e o resto.
8. **`.claude/`** guarda a configuração do Claude Code desta pasta: `settings.json`
   (permissões), `launch.json` (como rodar e previsualizar cada projeto web),
   `skills/` (os procedimentos) e `referencias-visuais/` (biblioteca visual:
   `CLAUDE.md` com os verbetes, `prints/` com as capturas e `capturar-print.py`).

   As skills desta pasta são treze: `primeira-configuracao` (a entrevista que
   preenche a seção 0, a seção 2 e o `~/.claude/CLAUDE.md`), `inicializar-pasta`
   (mapa dos projetos), `direcao-visual` e `revisar-visual` (visual, as duas
   apoiadas na biblioteca de referências), `checklist-web` e `entregar-site` (o
   que precisa estar pronto antes de dizer "acabou" e antes de publicar),
   `revisar-codigo`, `pesquisa-tecnica`, `gml` (GameMaker: consultar o manual
   oficial em vez de escrever de memória), `video-motion` (vídeo em motion graphics
   em código, com Remotion), `depurar` (achar a causa de um defeito por evidência),
   `diagnosticar-pc` (problema do Windows por log e medição) e `backup-local`.
   `primeira-configuracao`, `inicializar-pasta`, `entregar-site` e `revisar-visual`
   são **manuais**: só rodam quando ela chama por `/`, ou quando uma regra exige o
   procedimento delas. Duas skills pessoais, `ver-video` (ver e ouvir vídeo) e
   `context7-mcp` (documentação atual de biblioteca), moram em `~/.claude/skills/`
   e valem em qualquer pasta.

   **Como as skills se combinam:**
   - Citar uma skill dentro de outra não carrega a citada. Quando uma regra ou
     skill mandar seguir outra, carregar as duas: pela ferramenta de skill se a
     citada estiver na lista; se não estiver (manual, ou sessão aberta dentro de
     um projeto), ler o `SKILL.md` dela em `.claude/skills/<nome>/`, na raiz desta
     pasta.
   - Duas skills relevantes valem juntas: a de procedimento diz o que fazer; a de
     persona ou estilo muda o tom e, se previr, o gosto dentro do espaço que o
     procedimento deixa livre, nunca o procedimento.
   - Skill desta pasta e skill genérica (de plugin ou da conta) cobrindo a mesma
     coisa: vale a desta pasta. Skill de identidade ou tema pronto
     (`brand-guidelines`, `theme-factory`) nunca serve de direção visual.

   **Sessão aberta dentro de um projeto** (que tem git próprio) lê este
   `CLAUDE.md`, mas **não** carrega as skills, o `settings.json` nem a memória desta
   pasta: o Claude Code procura skills só até a raiz do repositório, lê o settings
   do diretório de trabalho e guarda memória por pasta de sessão. Nessa sessão:
   skill pelo caminho acima; caminho relativo nas regras e skills é relativo à raiz
   desta pasta; e as travas do settings valem pelo texto. Preferir abrir a sessão
   na raiz.
9. **Todo projeto tem git, criado e commitado sem perguntar**, exceto projeto muito
   bobo (regras na seção 6). Antes de qualquer alteração grande, conferir que a
   árvore está limpa (`git status`). Se estiver suja, avisar antes de mexer: commit
   sujo misturado com alteração nova tira dela a possibilidade de desfazer.
   `.gitignore` da raiz é o padrão; projeto pode ter o dele.

   Pasta que ficar **fora do git de propósito** entra na lista `$fora` do
   `_organizacao\git-setup.ps1` **com o motivo escrito**, e vira uma linha na seção
   8. Exceção não registrada vira pendência falsa toda vez que alguém varre a pasta.

   Vale versionar também a **configuração da raiz** num repositório só dela, assim
   as próprias regras têm como ser desfeitas. **Nunca num `.git` na raiz**: ele faz
   as buscas do Claude ignorarem as pastas de projeto. O jeito certo está no
   cabeçalho do `_organizacao\git-raiz.ps1`.

---

## 4. Antes de mexer em qualquer projeto

1. Ler o `CLAUDE.md`, `README.md` e demais `.md` **da própria pasta do projeto**.
   Vários têm documentação própria e detalhada: ela manda mais que este arquivo.
2. Ler o `.claude/launch.json` da raiz para saber como rodar. As portas, as
   reservadas e as divergências ficam no `PORTAS.md`: criou ou mudou porta,
   atualizar os dois.
3. **Não deduzir o que o projeto faz pelo nome.** Abrir os arquivos.
4. Preservar o que já funciona. Não reescrever metade do projeto para corrigir um
   problema pequeno. Se uma refatoração grande vale a pena, explicar por quê antes.
5. Achou um problema importante fora do escopo pedido? Avisar, não corrigir calado.
6. **Terminou de mexer? Conferir se a linha do projeto no mapa da seção 7 continua
   verdadeira.** O arquivo de regra do projeto é atualizado por quem trabalha nele;
   o mapa da raiz, não. Stack mudou, comando mudou, porta mudou, armadilha deixou
   de existir: a linha do mapa (e o `PORTAS.md`) muda junto, na mesma tarefa, senão
   toda sessão futura começa com informação errada.

---

## 5. Plano antes do código

Antes de escrever ou alterar código em **qualquer tarefa que não seja trivial nem
simples** (mais de um arquivo, sistema novo, site novo, mudança de arquitetura,
refatoração, correção que envolve entender como o projeto funciona) apresentar um
plano e **esperar aprovação**. Não sair codando.

O plano é curto (até ~15 linhas) e tem:

1. O que eu entendi que é pra fazer, em uma frase.
2. Quais arquivos vão ser criados, alterados ou apagados.
3. A abordagem escolhida. Se havia outra razoável, dizer qual e por que descartei.
4. O que pode quebrar do que já funciona.
5. Como o resultado vai ser verificado depois de pronto.

Regras:

- **Ler os arquivos relevantes antes de montar o plano.** Plano feito em cima do
  nome do arquivo não vale nada: vale a regra 3 da seção 4.
- Plano primeiro, `pode ir?` depois. Não implementar metade enquanto apresenta o
  plano.
- **Exceção:** delegação explícita ("escolhe tudo", "faz do jeito que achar
  melhor" e afins) e pedido mandado no meio de uma execução dispensam a espera (ver
  seção 1, "Decisões").
- Tarefa trivial (trocar um texto, ajustar uma cor, corrigir um typo, mudar um
  valor que ela já apontou) **não precisa de plano**: executa direto. Não
  burocratizar coisa pequena.
- **Projeto relativamente simples também não leva plano:** ferramenta ou site
  pequeno, poucos arquivos, escopo claro e nada funcionando que possa quebrar. Faço
  direto, sem esperar "pode ir?". Plano fica para o que é grande, mexe em projeto
  que já funciona de um jeito que pode quebrar ou tem escolha técnica de peso. Na
  dúvida entre simples e não, plano curto.
- **Pedido pequeno ou sem detalhes: acréscimo por conta própria só com
  permissão.** Se eu quiser acrescentar o que ela não pediu (funcionalidade,
  página, modo, conteúdo, extra), digo isso antes e espero o sim. No projeto simples
  não é plano, é um aviso curto: "pediu X; eu acrescentaria A, B e C; pode?", e só
  o aprovado entra. Quando há plano, os acréscimos vão nele, numa linha à parte ("O
  que eu acrescentaria"). Não vale para estética, nome e copy (seguem delegados,
  seção 1). "Escolhe tudo" e afins dispensam o aviso. Pedido mandado no meio da
  execução não aprova acréscimo: a ideia vai no relatório como sugestão.
- Se no meio da execução o plano se mostrar errado, **parar e avisar**. Não
  improvisar um caminho diferente calado.
- Se o plano depende de escolher biblioteca, API, formato ou abordagem que eu não
  domino, rodar a skill `pesquisa-tecnica` **antes** de apresentar o plano.
  Recomendação sem pesquisa em cima de coisa que muda de versão é chute.
- Em projeto web, o plano inclui a **direção visual** antes de qualquer CSS: ler
  `.claude/referencias-visuais/CLAUDE.md` e rodar a skill `direcao-visual`. A
  direção entra já fechada, salvo se ela pediu para escolher ou o projeto é de
  cliente (seção 1, "Decisões").
- Em tarefa grande, usar o plan mode do Claude Code (Shift+Tab duas vezes).

---

## 6. Commit, deploy e backup

### Commit

- **Git e commit são automáticos, sem perguntar:** projeto novo nasce com `git init`
  e commit inicial, e toda tarefa concluída e verificada termina com commit.
  **Exceção: projeto muito bobo** (poucos arquivos, sem dado, feito para testar ou
  brincar, como uma calculadora simples) não é versionado por conta própria. Na
  dúvida, versiona.
- **GitHub:** <!-- github:inicio -->nesta pasta o git é **só local**: a pessoa não
  usa GitHub. Nada de `gh repo create`, `git push` nem `git remote`, e o
  `git-setup.ps1` não cobra repositório remoto. O backup do código é o
  `backup-local.ps1` (seção "Backup") mais o histórico do git de cada projeto.<!-- github:fim -->
- **Commitar ao TERMINAR**, nunca durante o trabalho. Trabalho em andamento fica
  não commitado **de propósito**: é a rede de segurança para desfazer tudo com
  `git checkout .`.
- **O commit leva só o que eu mudei na tarefa**: `git add` nos arquivos dela, nunca
  `git add -A` às cegas. O que já estava sujo antes é trabalho dela: fica de fora, e
  eu aviso.
- Mensagem **em português**, dizendo o que mudou **e por quê**. Nada de `update`,
  `ajustes`, `wip`. Se o git da máquina não tiver nome configurado, passar o autor
  com `git -c user.name=... -c user.email=...`.
- **Nunca `git push --force`. Nunca reescrever histórico já publicado.**
- Árvore suja ao começar tarefa nova: **avisar antes de mexer**.

### Versão e changelog

Todo projeto tem versão e changelog. Vale mais que esquema de versão escrito antes
no `CLAUDE.md` de um projeto: a versão atual continua de onde está e anda por esta
regra daqui em diante.

- **Versão X.Y.Z:**
  - **X**: atualização grande (sistema novo de peso, mudança no jeito de usar,
    reescrita) **ou dez Y seguidos**: a atualização mediana que viria depois de um
    `.9.` vira X (`1.9.4` + mediana = `2.0.0`). Zera Y e Z.
  - **Y**: atualização mediana (funcionalidade nova, leva de melhorias) **ou dez Z
    seguidos**: a correção que viria depois de um `.9` vira Y (`1.4.9` + correção =
    `1.5.0`). Zera o Z.
  - **Z**: atualização pequena ou hotfix (bug, ajuste, texto).
  - O transporte encadeia (`1.9.9` + correção = `2.0.0`), então Y e Z nunca passam
    de 9; só o X não tem teto.
- **Uma subida por tarefa concluída**, do tamanho da maior mudança dela: três
  correções na mesma tarefa são um Z só. Sobe junto com o commit do fim da tarefa,
  nunca no meio. Mexer só em documentação, teste ou ferramenta interna, sem mudar o
  que o projeto faz, não sobe versão nem entra no changelog.
- **Onde a versão mora:** onde o projeto já tem lugar para ela (`package.json`,
  `manifest.json` de extensão, constante no código, número mostrado na tela,
  `build.gradle`). Todos os lugares andam juntos, e o topo do `CHANGELOG.md` diz o
  mesmo número. Sem lugar nenhum, ela mora só no `CHANGELOG.md`.
- **Primeira versão:** projeto novo nasce em `1.0.0` na primeira entrega que
  funciona; enquanto é só documentação, esqueleto ou roteiro, fica em `0.Y.Z`
  (começa em `0.1.0`). Projeto que já existe e ainda não tem versão ganha a dele
  (`1.0.0` ou `0.1.0`, pelo mesmo critério) na primeira vez que for mexido, com uma
  entrada dizendo que o que veio antes está no git.
- **`CHANGELOG.md` na pasta do projeto**, em português, a versão mais nova em cima:
  `## 1.4.2 (14/10/2026)` e, embaixo, o que mudou para quem usa (o que apareceu, o
  que mudou, o que foi corrigido, o que saiu), agrupado em **Novo**, **Mudou**,
  **Corrigido** e **Saiu** quando tiver mais de um tipo. É para ela ler: nada de
  resumo do diff nem nome de função sem necessidade. Entrada antiga não se
  reescreve, e changelog que já existe mantém o formato dele. Em projeto publicado
  cuja pasta sobe inteira, o `CHANGELOG.md` não vai junto para o ar sem ela querer.
- **Sem changelog** (e aí a versão também não é obrigatória, a não ser que o
  projeto já tenha uma): o que ela disser que não precisa, anotado no `CLAUDE.md` do
  projeto; site que o público vê uma vez e ninguém acompanha versão (site
  institucional, vitrine, site de cliente); o que não é software (só output, só
  anotação); a `_REVISAR/` e projeto arquivado. Na dúvida, tem changelog.

### Deploy

- **Projeto pessoal dela:** pode publicar **sem pedir aprovação a cada vez**, DESDE
  QUE a skill `entregar-site` tenha passado inteira antes (ela é manual: ler o
  `SKILL.md` e seguir): checklist, screenshots nas telas dela (e de celular só se o
  projeto for para celular), console limpo, zero 404. **Checklist falhou, deploy
  não acontece.** Projeto cujo `CLAUDE.md` exige ordem dela para publicar segue a
  regra de lá.
- **Projeto de cliente:** **NUNCA** deploy automático. Costumam viver em contas de
  terceiros. Mostrar o comando e **esperar a pessoa**.
- Depois de **qualquer** deploy, abrir a URL de produção e conferir que carregou.

Como cada projeto é publicado: preencher conforme forem existindo, e **conferir
antes de usar**; linha de deploy desatualizada faz publicar no lugar errado.

| Projeto | Como publica | Automático? |
|---|---|---|
| _(vazio, preencher)_ | | |

Liberar comando de deploy no `.claude/settings.json` só para o projeto que
realmente usa, **com o nome do alvo escrito por extenso**: regra de `Bash` casa com
o texto do comando, não com a pasta de onde ele roda. E não deixar um `ask` genérico
casando o mesmo comando: o Claude Code avalia deny, depois ask, depois allow, e o
`ask` vence o `allow` mais específico.

### Backup

- **O backup local guarda tudo, e vale para todos os projetos.** Esta pasta inteira
  é espelhada no destino escolhido em `_organizacao\backup-destino.txt` (HD externo,
  pendrive ou outra pasta), em cópia fiel: entram `.git`, `node_modules`, `.env` e
  todo o resto que o `.gitignore` deixa de fora. Nada é filtrado: é o único backup
  de quem não tem repositório remoto. Configurar com a skill `backup-local`.
- **Toda tarefa concluída que mexeu em arquivo termina com o backup**, junto do
  commit, sem perguntar:

  ```powershell
  powershell -ExecutionPolicy Bypass -File ".\_organizacao\backup-local.ps1"
  ```

  Vale para projeto de qualquer tamanho, com git ou sem. Com `-Simular`, mostra o
  que mudaria sem copiar nem apagar nada.
- **Uma tarefa agendada roda o backup sozinha**, de hora em hora e ao entrar no
  Windows, criada uma vez com
  `powershell -ExecutionPolicy Bypass -File ".\_organizacao\agendar-backup-local.ps1"`.
  É rede de segurança para o que acontece longe do agente e **não dispensa** o
  backup do fim de cada tarefa: entre uma rodada e outra passa uma hora.
- **Destino ausente não é falha:** o script avisa, não copia nada e sai com código
  2. Nesse caso, dizer que o backup ficou pendente.
- **É espelho, não histórico** (`robocopy /MIR`): o que for apagado no PC some do
  destino na sincronia seguinte. Histórico quem guarda é o git de cada projeto, que
  também está dentro do espelho.
- **Como conferir o git sem confiar na memória:**

  ```powershell
  powershell -ExecutionPolicy Bypass -File ".\_organizacao\git-setup.ps1"
  ```

  Ele varre as pastas e cria git em projeto novo que ainda não tem. Vale rodar ao
  encerrar um trabalho grande.
- **Material bruto pesado e insubstituível de cliente** (pasta `_originais/`) fica
  **fora do git de propósito** e é coberto pelo backup local. **Nunca sugerir
  colocá-lo no git "para garantir backup".**

---

## 7. Mapa dos projetos

> Vazio porque a pasta é nova. Preencher com `/inicializar-pasta`, que abre cada
> projeto antes de descrever: **nunca deduzir pelo nome da pasta**. Uma linha por
> projeto; site dentro de outro projeto não ganha linha, ganha menção na observação
> daquele projeto.

| Pasta | O que é | Stack | Como rodar |
|---|---|---|---|
| _(vazio)_ | | | |

### Observações por projeto

Aqui vai o que faz alguém errar caso não saiba: pasta que parece descartável e não
é, arquivo gerado que não pode ser editado à mão, dois projetos parecidos que não
são o mesmo, material de cliente insubstituível, comando de teste obrigatório antes
de dizer que está pronto.

Observação boa é a que evita um erro concreto. "É um jogo legal" não serve.

---

## 8. Pendências conhecidas

> Vazio porque a pasta é nova.

Formato: três grupos: **aberto, precisa de decisão dela**; **aberto, é assim de
propósito** (para ninguém "corrigir" o que é intencional); e **resolvido** (riscado,
com o que ficou valendo). Datar a última varredura e só escrever aqui o que foi
conferido com comando.

---

## 9. Ao encerrar um trabalho relevante

Oferecer para escrever o resumo da sessão em Markdown, com data no nome do arquivo
(`AAAA-MM-DD_assunto-em-kebab-case.md`), no lugar que esta pasta usar para memória.
Se não houver esse lugar ainda, perguntar se deve criar um.
