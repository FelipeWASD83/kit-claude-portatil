---
name: inicializar-pasta
description: Mapeia os projetos que já existem na pasta de trabalho - varre cada projeto, preenche o mapa do CLAUDE.md, monta o launch.json e o PORTAS.md, e garante git em tudo (só local). Usar quando a pessoa chamar /inicializar-pasta, quando chegar projeto novo de fora para dentro da pasta, ou quando o mapa da seção 7 das regras da raiz ainda estiver vazio e já houver projeto aqui.
argument-hint: "[nada, ou o nome que a pasta deve ter]"
disable-model-invocation: true
---

# Inicializar a pasta

Esta pasta nasceu de um kit: a configuração está pronta, as skills estão
prontas, a biblioteca visual está pronta, mas o `CLAUDE.md` da raiz não sabe
**quais projetos existem aqui**, e sem isso descreve uma pasta imaginária.

O trabalho desta skill é fechar essa distância com cuidado, e sair.

Nome pedido para a pasta (se houver): `$0`

## 0. Ver se dá para começar

1. Se o topo do `CLAUDE.md` ainda tem o aviso de que a **primeira configuração**
   não foi feita (a seção 0, "Sobre mim", vazia), rodar antes a
   `/primeira-configuracao`: ela é manual, então abrir
   `.claude/skills/primeira-configuracao/SKILL.md` e seguir. Sem saber quem é a
   pessoa e como é a máquina, o mapa sai genérico.
2. Se a pasta **não tem projeto nenhum ainda**, não há o que mapear: dizer isso e
   parar. O mapa fica vazio até o primeiro projeto nascer, e aí vale esta skill
   de novo (ou a regra 4.6 do `CLAUDE.md`, que manda atualizar o mapa a cada
   projeto).
3. Se o mapa da seção 7 **já tem projeto listado**, a pasta já foi inicializada.
   Não rodar de novo por cima: dizer isso e perguntar se ela quer **atualizar** o
   mapa (projeto novo que entrou, projeto que saiu), que é um trabalho menor,
   feito só com os passos 2 e 4.

## 1. Olhar a pasta antes de escrever qualquer coisa

```powershell
Get-ChildItem -Force | Select-Object Mode, Name
```

Separar em três grupos:

- **Projetos**: as pastas de trabalho de verdade.
- **Infra do kit**: `.claude/`, `_organizacao/`, `_REVISAR/`, `.gitignore`,
  `CLAUDE.md`, `PORTAS.md`, `LEIA-PRIMEIRO.md`. Não são projeto e não entram no
  mapa.
- **Fora do lugar**: arquivo solto na raiz, `.zip`, pasta com espaço ou
  parêntese no nome, sufixo `_1`/`_2` de download repetido. **Não mover nada
  agora**: anotar e reportar no fim. Mexer na pasta dela sem avisar é pior que
  deixar bagunçado.

## 2. Abrir cada projeto, não deduzir pelo nome

Esta é a regra que faz a diferença entre um mapa útil e um mapa inventado. Para
cada pasta de projeto, **ler antes de descrever**:

1. `CLAUDE.md`, `README.md` e qualquer `.md` de documentação da pasta. Se
   existirem, mandam mais que qualquer dedução minha.
2. O manifesto da stack: `package.json` (olhar `scripts`), `requirements.txt`,
   `pyproject.toml`, `*.csproj`, `wrangler.jsonc`, `index.html`.
3. O ponto de entrada real: `main`, `src/main.*`, `server.py`, `app.py`,
   `*.bat`, `index.html`.

Só depois escrever a linha do mapa. Quatro colunas:

```
| pasta | o que é, em uma frase que diga o propósito | stack | como rodar |
```

Regras da descrição:

- **Uma frase que distinga.** "Jogo em JS" não distingue nada. "Snake modular
  com editor de fase" distingue.
- **Como rodar é o comando literal**, com a porta quando houver.
- Se a pasta for **output** e não código (imagens exportadas, traduções, PDFs),
  dizer isso na frase: é a informação mais importante sobre ela.
- Se duas pastas parecem a mesma coisa, **descobrir a diferença e escrever a
  diferença**. Duas pastas parecidas sem explicação é a origem clássica de
  alguém apagar a errada.
- Não achou o que a pasta é depois de abrir os arquivos? **Perguntar.** Uma
  linha inventada no mapa envenena todas as sessões futuras.

## 3. Perguntar o que não dá para descobrir sozinho

Estas quatro coisas não estão escritas em lugar nenhum do disco, e errar em
qualquer uma delas custa caro. Perguntar de uma vez, em bloco:

1. **Algum projeto é de cliente ou está em produção?** Muda tudo: confirmar
   antes de mexer, nunca deploy automático, `entregar-site` obrigatória.
2. **Algum projeto é privado**, para eu não abrir nem comentar o conteúdo sem
   ela pedir na conversa?
3. **Algum projeto deve ficar fora do git de propósito?**
4. **Algum já é publicado hoje, e como?** (Cloudflare por CLI, upload em painel,
   FTP, loja de app.)

As respostas viram: a tabela de deploy na seção 6, as observações da seção 7, a
lista `$fora` do `_organizacao\git-setup.ps1` e as regras `deny`/`ask` do
`.claude/settings.json`.

## 4. Montar o `launch.json` e o `PORTAS.md`

Toda pasta que serve alguma coisa por HTTP ganha entrada no `.claude/launch.json`:
é o que liga o preview e a verificação automática do Claude Code Desktop, e serve
de índice de portas. Projeto sem entrada perde as duas coisas.

A porta de cada projeto sai das faixas do `PORTAS.md` da raiz, para não colidir
nem ter que lembrar, e **cada porta usada entra na tabela de lá** (projeto,
porta, como sobe, observação).

Duas armadilhas:

- **Nunca `python3`.** No Windows cai no stub da Microsoft Store e falha.
- **Nunca repetir porta.** Projetos que guardam dado no navegador
  (`localStorage`, IndexedDB) são separados **por origem**: duas coisas na mesma
  porta enxergam o dado uma da outra e corrompem o estado.

Formato, estático:

```json
{
  "name": "nome-do-projeto",
  "runtimeExecutable": "python",
  "runtimeArgs": ["-m", "http.server", "4310", "--bind", "127.0.0.1",
                  "--directory", "nome-do-projeto"],
  "port": 4310
}
```

Formato, projeto com script próprio (`cwd` é a pasta onde o comando roda):

```json
{
  "name": "nome-do-projeto",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "dev"],
  "cwd": "nome-do-projeto",
  "port": 5173
}
```

Depois de escrever, **conferir que o arquivo é JSON válido**:

```powershell
python -c "import json;d=json.load(open('.claude/launch.json'));print(len(d['configurations']),'entradas')"
```

E subir pelo menos **um** projeto para confirmar que a configuração funciona de
verdade, em vez de afirmar que funciona.

## 5. Git (só local) e backup

```powershell
powershell -ExecutionPolicy Bypass -File ".\_organizacao\git-setup.ps1"
```

Ele cria git em quem não tem. Nesta pasta o git é **só local** (ver a regra de
GitHub na seção 6 do `CLAUDE.md`): o script não cobra repositório remoto. Projeto
que ela disser para deixar fora do git entra na lista `$fora` do script **com o
motivo escrito**, e vira linha na seção 8.

Se o backup local já foi configurado (`_organizacao\backup-destino.txt`), rodar o
`backup-local.ps1` ao final. Se não foi, oferecer a skill `backup-local`.

## 6. Fechar as regras da pasta

- Trocar `NOME-DA-PASTA` no título pelo nome real, se ainda estiver assim.
- **Apagar a citação de aviso do topo**, se ela ainda existir: ela só vale até a
  inicialização rodar.
- Preencher a seção 7 (mapa e observações) e o que as respostas do passo 3
  produziram na seção 6.
- Datar a seção 8 com a varredura de hoje. Se não houver pendência, escrever
  "nenhuma pendência aberta" com a data: vazio sem data não diz se foi conferido
  ou esquecido.
- Conferir a seção 2: ela descreve a máquina medida na primeira configuração. Se
  mudou, **medir** de novo em vez de repetir.

Depois rodar o conferidor:

```powershell
powershell -ExecutionPolicy Bypass -File ".\_organizacao\checar-pasta.ps1"
```

## 7. Relatar

```
Pasta: <nome>
Projetos mapeados: <n> — <lista curta>
No launch.json e no PORTAS.md: <n> entradas, portas <faixas>. Testei: <qual subi e o que vi>
Git: <n> já tinham, <n> criei (só local)
Fora do lugar (não mexi): <arquivo solto, nome fora do padrão, zip>
Precisa de você: <o que eu não consegui descobrir e não inventei>
```

Não marcar como feito o que não foi verificado. O mapa é documento de consulta de
todas as sessões futuras: uma linha errada aqui vira erro repetido para sempre.
