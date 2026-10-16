---
name: video-motion
description: Fazer vídeo profissional em motion graphics em código (Remotion), do briefing ao MP4 conferido - Reels, TikTok, Shorts, vídeo de produto, explicativo, tutorial animado, vinheta, abertura, anúncio. Usar sempre que o pedido for criar, refazer ou melhorar um vídeo animado, e antes de escrever a primeira cena. Não usar para só cortar ou converter um vídeo gravado (isso é ffmpeg direto) nem para assistir um vídeo (isso é a skill ver-video).
---

# Vídeo em motion graphics

O que separa vídeo profissional de vídeo "feito por IA" não é a ferramenta: é
roteiro com tempo, uma direção visual fechada, quadros parados aprovados antes
de animar, movimento com intenção, som mixado e conferência de verdade antes
de entregar. Esta skill é esse caminho, na ordem. Pular etapa é o que faz o
resultado parecer template.

A ferramenta é o **Remotion 4.0.534** (vídeo em React, renderizado pelo Edge,
codificado pelo ffmpeg). Foi escolhido em 07/10/2026
depois de comparar as opções de vídeo em código, e o `modelo/` desta skill é o
caminho já testado de ponta a ponta.

Arquivos desta skill:

- `modelo/`: projeto Remotion pronto para copiar (roteiro, tema, formatos,
  narração, sons, transição, texto cinético, guias de zona segura, ferramentas
  de conferência e entrega).
- `referencias/principios.md`: o ofício (tempo em quadros, curvas, molas,
  hierarquia, tipografia, ritmo, o que denuncia amador). **Ler antes de animar.**
- `referencias/remotion.md`: regras do Remotion, armadilhas já pagas aqui e
  pacotes opcionais.
- `referencias/som-e-entrega.md`: narração, trilha, mixagem, loudness,
  especificação por plataforma e zonas seguras.

## Quando a ferramenta é outra

- **Cortar, juntar, legendar ou converter vídeo gravado** sem animação: ffmpeg
  direto, sem Remotion.
- **Plano 3D de verdade** (produto girando com luz física, cena modelada):
  Blender em Python,
  renderizado em sequência de imagens e montado dentro do Remotion com
  `<Video>` ou `<Img>`. Three.js dentro do Remotion (`@remotion/three`) serve
  para 3D simples e estilizado.
- **Ela pede projeto do After Effects** (`.aep`, expressão, script `.jsx`):
  dá para escrever, mas não dá para rodar nem conferir o AE daqui. Dizer isso
  antes e entregar marcado como não testado.

## 1. Briefing

Tirar do pedido e do projeto antes de perguntar. O que precisa estar claro:

| Item | Pergunta | Padrão se ninguém disser |
|---|---|---|
| Onde passa | Reels/TikTok/Shorts, YouTube, site, dentro de um app, apresentação | o que o pedido sugere |
| Formato | 9:16, 16:9, 1:1, 4:5 (pode ser mais de um, da mesma animação) | 9:16 para rede social, 16:9 para o resto |
| Duração | | social 15 a 30 s; explicativo 45 a 90 s; vinheta 3 a 6 s |
| Mensagem | a **uma** coisa que quem assiste tem que lembrar | sai do pedido |
| Fecho | o que a pessoa faz depois (seguir, abrir, comprar, nada) | marca e endereço |
| Som | narração, só música, só efeitos, mudo | social: efeitos + trilha; site: mudo |
| Língua | pt-BR, inglês, os dois | pt-BR |
| Dono | projeto pessoal, de cliente, público | identidade de cliente manda, sempre |

Escolha subjetiva que ela não fez está delegada (seção 1 do `CLAUDE.md` da
raiz): supor, dizer a suposição numa linha e seguir. Vídeo que não é trivial
passa pelo plano da seção 5, e o **roteiro com tempo entra no plano**: é a
parte que ela mais vai querer ver antes.

## 2. Onde o vídeo mora

- **Vídeo de um projeto** (vitrine, app, produto): subpasta `video/` dentro
  dele. Segue o git e o changelog do projeto dono.
- **Vídeo avulso**: é projeto novo na raiz, com tudo que projeto novo pede
  (nome em kebab-case, git, linha no mapa da seção 7).
- Nos dois casos, **entrada no `.claude/launch.json` e no `PORTAS.md`** para o
  Remotion Studio (`remotion studio src/index.ts --port <porta>`), escolhendo
  uma porta livre pelo `PORTAS.md`. É o que deixa abrir o Studio no preview.

Copiar o modelo (PowerShell, da raiz):

```powershell
Copy-Item -Recurse ".claude/skills/video-motion/modelo/*" "<destino>/"
Copy-Item ".claude/skills/video-motion/modelo/.gitignore" "<destino>/"
cd "<destino>"; npm install
```

O `README.md` do modelo diz o que cada arquivo faz e vira a base do
`CLAUDE.md` do vídeo .
Trocar o `name` do `package.json`.

## 3. Roteiro com tempo

O vídeo inteiro é guiado por `src/roteiro.json`. Antes de abrir qualquer
componente:

1. **Uma ideia por cena.** Cena que diz duas coisas vira duas cenas.
2. **Gancho nos primeiros 1,5 s** em vídeo de rede social: a frase ou a imagem
   mais forte vem primeiro, logo, contexto depois. Nada de logo abrindo vídeo
   de Reels.
3. **Tempo de fala:** narração em pt-BR anda a ~2,6 palavras por segundo com a
   voz do modelo a +6%. Contar as palavras e somar as folgas de cada cena
   (meio segundo antes e depois) para saber a duração antes de gerar a voz.
4. **Texto na tela sem narração** fica pelo menos `palavras / 3 + 1` segundos
   (leitura confortável). Se não cabe no tempo, corta texto, não tempo.
5. **Marcas `{nome}`** antes da palavra que dispara uma animação ("{preco}R$
   200"). A animação pergunta `quando('preco')` e fica presa à fala, mesmo
   que a voz mude.
6. Sem narração, as cenas têm `segundos` e o tempo vem da **batida**: o modelo
   tem `bpm` no roteiro e `batida(n)` nas cenas. Corte na batida é o que faz
   motion parecer editado e não "passando".
7. **Ler o roteiro em voz alta** (de verdade: gerar a narração e ouvir pela
   transcrição do passo 8) antes de animar. Frase que trava na voz trava no
   vídeo.

Nome em inglês na narração em português: a voz pronuncia errado ("Claude" vira
"Cloud"). Escrever pela pronúncia na fala ("Clód") e o nome certo na tela.
Conferir sempre pela transcrição (passo 8).

## 4. Direção visual

Mesma regra de qualquer projeto visual aqui: **ler
`.claude/referencias-visuais/CLAUDE.md` e seguir a skill `direcao-visual`**
antes de escolher cor e fonte. A pessoa não tem estética padrão. Em vídeo, a
direção fecha estas decisões, escritas no `src/tema.ts`:

- **Paleta curta:** um fundo (ou dois tons dele), uma cor de texto, uma de
  ação/destaque, no máximo uma de apoio. Mais que isso vira confete.
- **Duas fontes no máximo** (título e apoio), com pesos definidos. Título em
  vídeo é grande: em 1080 px de largura, título entre 110 e 200 px, texto de
  apoio nunca abaixo de 40 px em vídeo vertical (é visto no celular).
- **Uma transição só** para o vídeo inteiro (`TRANSICAO` no tema). Variedade
  de transição é a assinatura do amador.
- **Um vocabulário de movimento:** uma mola seca (sem sobra) para quase tudo e
  uma mola viva (com sobra leve) para o destaque de cada cena.
- **Um elemento-assinatura** que só este vídeo tem (uma varredura de luz, uma folha
  de papel, uma forma que se repete). É o que a pessoa lembra.
- Fundo **contínuo** por baixo do vídeo inteiro, com textura (grão, luz que
  respira): o vídeo não pisca para preto entre cenas.

Cliente: a identidade do cliente manda, e a direção só varia dentro dela.

## 5. Styleframes antes de animar

O passo que mais diferencia. Para cada cena, montar o **quadro assentado**
(tudo já entrou, nada se mexendo) e renderizar como imagem:

```powershell
npx remotion still src/index.ts Video-16x9 quadros/sf-gancho.png --frame=<quadro>
```

Olhar cada styleframe com a ferramenta de imagem e corrigir composição,
hierarquia, contraste, margem e zona segura **antes** de escrever qualquer
animação. Animar um quadro feio dá um vídeo feio que se mexe. Em trabalho que
não é trivial, mostrar os styleframes a ela (enviando as imagens) junto do plano ou
logo depois, e seguir sem esperar se ela já delegou.

## 6. Animar

Ler `referencias/principios.md` antes. O resumo que não pode faltar:

- Tudo sai de `useCurrentFrame()`. Nada de CSS animation, transition,
  `Math.random()` ou relógio (ver `referencias/remotion.md`).
- Entrada com desaceleração (mola seca ou `Easing.out`), saída mais rápida
  que a entrada, movimento de A a B com `inOut`. **Linear só** para o que é
  contínuo (rotação, rolagem infinita, contador).
- **Nada nasce junto:** palavras com 2 a 4 quadros entre si, blocos com 6 a
  10. Um foco por vez; o olho vai para o que se mexe.
- **Nada fica morto:** durante o tempo parado, a câmera aproxima 2 a 3 %
  (`<Respira>`) e o fundo continua vivo.
- Cada animação presa a uma marca da fala ou a uma batida, nunca a um número
  solto.
- Toda cena funciona em todos os formatos do roteiro: usar `useCena().formato`
  (largura, altura, vertical, zona segura) em vez de pixel fixo.

Abrir o Studio pelo preview (entrada do `launch.json`) para ver a cena enquanto
anima; a conferência que vale é a do passo 8.

## 7. Som

Detalhes em `referencias/som-e-entrega.md`. Em resumo:

- **Narração:** `npm run narrar` (edge-tts, voz neural da Microsoft, precisa de
  internet, tempo de cada palavra salvo). Só refaz a fala que mudou.
- **Efeitos e trilha:** `npm run sons` sintetiza em numpy (sem amostra de
  ninguém, sem problema de direito). Quem tem programa de música pode
  trocar a trilha sintetizada pela dela.
- Música de terceiros só se ela trouxer e disser que pode usar. No Reels, a
  saída é ela escolher na biblioteca do Instagram ao postar (exportar sem
  trilha).
- Trilha abaixa sob a voz (já automático no modelo). Efeito em cada evento
  importante, não em todo movimento.

## 8. Conferir (obrigatório)

Nada de "ficou bom" sem isto. Na ordem:

1. **Folha de quadros:** `python ferramentas/quadros.py <formato> 15` monta
   uma imagem com um quadro a cada meio segundo, o tempo escrito e as guias de
   zona segura. Olhar inteira: texto cortado ou fora da zona segura, quadro
   vazio, cena que não assentou, contraste, duas coisas disputando o foco.
2. **Quadros-chave em tamanho cheio** (`remotion still`) onde a folha deixou
   dúvida.
3. **Prévia rápida:** `python ferramentas/entregar.py <formato> --previa`
   (metade da resolução) e rodar a skill `ver-video` nela: a transcrição tem
   que bater com o roteiro (nome errado, palavra engolida, trilha cobrindo a
   voz) e os quadros têm que mostrar cada coisa na hora em que é dita.
4. **Render final** com `entregar.py` (passo 9). O relatório no fim diz
   duração, resolução, fps, tamanho, loudness integrado e pico. Fora da meta,
   corrigir antes de entregar.
5. Dizer a ela o que **não** foi visto: fluidez em tempo real e o som no
   ouvido de verdade eu não verifico; a folha e a transcrição são indiretas.

## 9. Entregar

`python ferramentas/entregar.py <formato> --preset <social|youtube|app|site>`
renderiza pelo Edge, normaliza o áudio em duas passadas, codifica com a
especificação da plataforma e tira a capa. Saída em `saida/` (fora do git).

- Mandar o MP4 e a capa a ela pela ferramenta de enviar arquivo do agente.
- Vai para o git: código, roteiro, `narracao.gerado.json` e capas pequenas.
  Fica fora: `saida/`, `quadros/`, `public/narracao/`, `public/sons/` e
  `node_modules/` (o `.gitignore` do modelo já faz isso).
- Publicar o vídeo (Instagram, release, site) é decisão dela, sempre.

## Pronto para entregar

- [ ] Roteiro com tempo, uma ideia por cena, gancho no começo (social)
- [ ] Direção no `tema.ts`: paleta curta, até duas fontes, uma transição, um elemento-assinatura
- [ ] Styleframe de cada cena olhado antes de animar
- [ ] Nenhum movimento linear fora do que é contínuo; nada nasce junto; nada fica morto
- [ ] Texto legível no tamanho real e dentro da zona segura em todos os formatos
- [ ] Folha de quadros olhada inteira; transcrição da prévia batendo com o roteiro
- [ ] Loudness na meta da plataforma, pico abaixo de -1 dBTP
- [ ] Último quadro pensado (loop limpo no social, respiro no fim do resto)
- [ ] O que não foi verificado dito a ela
