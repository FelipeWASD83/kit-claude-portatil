---
name: revisar-visual
description: Abre o projeto no navegador, tira screenshots em desktop e mobile, lê o console e a rede, e corrige o que estiver quebrado ou feio. Usar quando a pessoa pedir /revisar-visual ou pedir para conferir como um site/app está ficando.
argument-hint: "[projeto] [caminho-opcional]"
disable-model-invocation: true
---

# Revisão visual de projeto web

A pessoa pode **não ler HTML/CSS/JS de forma útil** (a seção 0 do `CLAUDE.md`
diz). Nesse caso ela não tem como abrir o código e ver que um botão sumiu ou que
o layout estourou. Esta revisão existe para que **eu** enxergue o resultado, não
ela.

Projeto: `$0` — Caminho extra (se houver): `$1`

## 1. Subir o projeto

1. Ler `.claude/launch.json` na raiz da pasta e procurar uma configuração com o
   nome do projeto. Se existir, usar a porta de lá. Se não existir, **criar a
   entrada faz parte do trabalho** — sem ela o projeto não tem preview nem
   verificação automática. (O arquivo é do preview do Claude Code, mas serve
   de índice de portas para qualquer agente.)
2. Para saber como o projeto roda, ler a documentação dele
   (`dev.bat`, `npm run dev`, `iniciar.bat`, `python -m http.server`).
3. **Windows: usar `python`, nunca `python3`.**
4. Se o projeto for HTML single-file sem servidor, servir com
   `python -m http.server` mesmo assim — `file://` quebra fetch, módulos e fontes,
   e aí eu reviso um bug que não existe em produção.

Se não der para descobrir como rodar, **perguntar** em vez de chutar uma porta.

## 2. Olhar de verdade

Com a ferramenta de navegador do agente — MCP do Chrome DevTools
(`chrome-devtools`) ou o painel de preview do Claude Code:

1. Navegar até a URL.
2. Screenshot em **1440×900** (desktop).
3. Redimensionar para as resoluções das telas dela (seção 2 do `CLAUDE.md`; sem
   isso, a maior que o navegador permitir) e tirar um screenshot de cada. Só se o
   projeto for para celular (ela pediu, ou é de cliente/público e ela confirmou),
   tirar também um em **390×844**; a regra da pasta é que, sem pedido, o projeto
   roda só no PC dela.
4. Ler as mensagens de **console** — erro e warning.
5. Ler as **requisições de rede** — procurar 404 e 500 (fonte, imagem, JSON, API).
6. Se o projeto tem interação principal (botão de começar, formulário, menu),
   executar essa interação e tirar screenshot **do estado depois**, não só da
   tela inicial.

Se não houver nenhuma ferramenta de navegador disponível, **dizer isso** e parar
por aqui. Não fingir que revisou.

## 3. Julgar

Para cada screenshot, listar o que está errado — sendo específico e honesto.
Olhar principalmente:

- Texto cortado, sobreposto, estourando o container ou saindo da tela.
- Scroll horizontal indevido no mobile.
- Contraste baixo demais para ler.
- Espaçamento inconsistente (um bloco com 40px, o vizinho com 13px sem motivo).
- Elemento interativo com área de toque menor que ~44px no mobile.
- Alinhamento quebrado, imagem esticada, proporção errada.
- Estado vazio/carregando/erro que aparece como tela em branco.
- Erro de console e recurso 404.

Depois rodar a skill `checklist-web` e reportar os itens que falharem.

## 3.5 Comparar com a referência visual

Julgar "está feio" no vácuo não leva a lugar nenhum. Abrir
`.claude/referencias-visuais/CLAUDE.md`, identificar qual verbete guiou este
projeto (se nenhum guiou, escolher agora o da seção certa: **Produto** para
app/ferramenta/painel/site institucional, **Espetáculo/Premiados** para landing
e campanha) e abrir o print correspondente em
`.claude/referencias-visuais/prints/`.

Com o print da referência de um lado e o screenshot do projeto do outro,
responder as cinco perguntas do passo 4 daquele arquivo:

1. A hierarquia é tão clara quanto a da referência?
2. O respiro é comparável, ou o meu está apertado?
3. O contraste de escala entre título e corpo é parecido?
4. A cor está fazendo o mesmo papel, ou só copiei o hex?
5. Existe um elemento que só faz sentido neste projeto?

O que falhar aqui entra na lista de correções junto com os defeitos técnicos.
E vale a lista de "não copiar" da seção 6 da biblioteca: portão de entrada,
scroll sequestrado, som automático, cursor sem função, animação antes da
primeira leitura, contraste baixo por estilo. Se o projeto tiver algum desses,
é defeito — mesmo que tenha sido eu que coloquei.

Para capturar o print do resultado sem depender do navegador do agente, dá para
usar o capturador da biblioteca apontando para o localhost do projeto:

```bash
python .claude/referencias-visuais/capturar-print.py lista.json pasta-de-saida
```

## 4. Corrigir

- **Corrigir**, não descrever teoricamente o que ela poderia corrigir.
- Depois de corrigir, **tirar os screenshots de novo** e comparar. Só afirmar que
  arrumou se o screenshot novo mostrar que arrumou.
- Decisão de gosto (qual cor, qual dos dois layouts) segue a regra de escolha
  delegada das regras da pasta: se ela não reservou essa escolha para si,
  decidir, corrigir e contar no relatório. Perguntar, mostrando as opções, só
  se ela pediu para escolher ou se o projeto é de cliente.

## 5. Relatar

Formato do relatório final, em português, sem jargão de CSS:

```
O que eu vi: <descrição do que a página mostra hoje>
Comparado com: <qual referência da biblioteca, e onde o projeto fica atrás dela>
Corrigido: <lista do que arrumei, em linguagem simples>
Ainda quebrado: <o que não deu para arrumar e por quê>
Decidi por você: <escolha de gosto que eu fiz, e por quê>
Decisão sua: <só o que ela reservou para si, ou o que é de cliente>
```

Se ela precisar mexer em algo na mão, usar sempre o formato
`no arquivo X, procure a linha Y e troque para Z`.
