# Remotion neste PC: regras, armadilhas e pacotes

Versão fixa: **4.0.534** em todos os pacotes `remotion` e `@remotion/*`
(versão exata no `package.json`, sem `^`). Pacote `@remotion/*` novo entra na
**mesma** versão; versões misturadas quebram o render. Atualizar o Remotion é
decisão com teste: o Smart App Control pode barrar o que vier junto.

Documentação atual: Context7, biblioteca `/websites/remotion_dev` (API) e
`/remotion-dev/skills` (boas práticas oficiais para agentes). Consultar antes
de usar API que não está no modelo.

Licença: grátis para pessoa física e empresa de até 3 pessoas, inclusive uso
comercial para fazer os próprios vídeos. Acima disso, licença de empresa.

## Regras que o render impõe

- **Tudo sai do quadro.** `useCurrentFrame()` + `interpolate()` ou `spring()`.
  CSS `animation`, `transition`, `setTimeout`, `requestAnimationFrame` e
  `useEffect` para tempo **não aparecem no render** (cada quadro é tirado
  sozinho, em paralelo e fora de ordem).
- **Sem aleatório solto:** `random('semente-' + i)` do `remotion`, nunca
  `Math.random()` (cada quadro sortearia diferente e tremeria).
- `interpolate` sempre com `extrapolateLeft: 'clamp', extrapolateRight: 'clamp'`
  quando o valor não pode passar do intervalo (quase sempre).
- `spring` com `durationInFrames` para o tempo ser previsível.
- `<Sequence from={q}>` zera o relógio dentro dela: o componente filho vê o
  quadro 0 no começo da sequência. `layout="none"` para áudio.
- Imagem com `<Img src={staticFile('x.png')}>` (espera carregar antes de tirar
  o quadro); vídeo e áudio com `<Video>` e `<Audio>` de `@remotion/media`.
  Arquivo em `public/`, chamado por `staticFile()`.
- Fonte do Google por `@remotion/google-fonts/<Nome>` no nível do módulo (o
  pacote segura o render até a fonte carregar). Fonte local por
  `@remotion/fonts` (`loadFont`) com o arquivo em `public/`.
- `getStaticFiles()` lista o que existe em `public/` (o modelo usa para avisar
  quando falta rodar `npm run sons`).
- Duração que depende de dado (narração): o modelo calcula ao importar o
  `narracao.gerado.json`; quando o dado vem de fora, `calculateMetadata` na
  `<Composition>`.

## Rodar no Windows

- **Com o Smart App Control ligado, o Chrome que o Remotion baixa pode ser
  barrado** ("spawn UNKNOWN"). O `remotion.config.ts` do modelo aponta para o
  Edge do Windows, que roda. Não tirar.
- De Python, chamar `node_modules\.bin\remotion.cmd` por `cmd /c` (é `.cmd`).
- `--props` com JSON na linha de comando é um inferno de aspas no Windows:
  gravar o JSON num arquivo e passar o caminho (`--props=saida/.props.json`).
- O render paralelo padrão usa os núcleos que o processador tiver: vídeo de 30 s
  em 1080p leva poucos minutos num processador moderno (medir nesta máquina).
- Comandos úteis:
  - `npx remotion still src/index.ts <Comp> saida/q.png --frame=90`: um quadro.
  - `npx remotion render src/index.ts <Comp> saida/a.wav --codec wav`: **só o
    áudio** em segundos, para testar mixagem e voz.
  - `--sequence --every-nth-frame=15 --scale=0.3 --image-format=jpeg`:
    quadros soltos (é o que o `quadros.py` usa).
  - `--scale=0.5`: render rápido em meia resolução.
- Editar arquivo com barra invertida por heredoc no Git Bash come as barras:
  usar a ferramenta de edição ou um `.py`.

## Armadilhas já pagas aqui

- **Espaço no fim de `inline-block` some.** Palavras animadas separadas por
  `columnGap` do flex ou margem, não por espaço (o `<Palavras>` já faz).
- **Capa** é um quadro congelado (`<Freeze>`) dentro de uma composição com a
  duração do vídeo inteiro. Composição de 1 quadro corta todas as `<Sequence>`
  depois do quadro 0 e a capa sai vazia.
- O painel de navegador do agente (Electron) pausa vídeo que toca sozinho sem gesto:
  testar `<video>` de site num Edge headless, não no painel.
- A voz do edge-tts às vezes junta ou separa palavras ("A P I" e "API"): o
  `narrar.py` alinha isso e para com erro se uma marca não casar, mostrando o
  que a voz disse.
- Música por baixo atrapalha a transcrição de nome próprio: testar a fala com
  a trilha (render `--codec wav` + `ver-video`).
- O Remotion entrega `yuvj420p` (faixa cheia); alguns players mostram com
  contraste errado. O `entregar.py` converte para `yuv420p` faixa de TV.

## Pacotes opcionais (mesma versão 4.0.534)

| Pacote | Para quê |
|---|---|
| `@remotion/transitions` | `<TransitionSeries>` com fade, slide, wipe, flip, clockWipe. Alternativa ao `<Transicao>` do modelo quando a troca precisa mexer nas duas cenas (empurrar) |
| `@remotion/paths` | `evolvePath()` para desenhar traço SVG, interpolar formas, medir caminho |
| `@remotion/shapes` | formas prontas (estrela, polígono, seta) como SVG |
| `@remotion/noise` | ruído suave (`noise2D`) para movimento orgânico sem tremer |
| `@remotion/motion-blur` | `<CameraMotionBlur>` e `<Trail>`; pesa no render, usar só no rápido |
| `@remotion/lottie` | animação Lottie (JSON do After Effects via Bodymovin) |
| `@remotion/three` | three.js dentro do vídeo, com o relógio do Remotion |
| `@remotion/captions` | legenda a partir de transcrição (palavra a palavra) |
| `@remotion/layout-utils` | `fitText()` e `measureText()` para texto que cabe na largura |

Pacote novo é dependência nova: instalar com versão exata e testar o render
pelo Edge antes de contar com ele.
