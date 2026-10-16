# Vídeo em motion graphics (modelo da skill video-motion)

Vídeo feito em código com **Remotion 4.0.534** (React), renderizado pelo Edge do
Windows e codificado pelo ffmpeg. Este arquivo vira a base do `CLAUDE.md` do
vídeo: trocar o exemplo pelo que o vídeo é de verdade.

## Como rodar

```powershell
npm install                                   # uma vez (node_modules fica fora do git)
python -m venv .venv                          # uma vez, para a voz
.venv\Scripts\pip install edge-tts==7.3.1
npm run narrar                                # a narração (precisa de internet; só refaz o que mudou)
npm run sons                                  # os efeitos e a trilha
npm run studio                                # o Remotion Studio, para ver e ajustar
python ferramentas/quadros.py 16x9            # folha de quadros com as guias (quadros/)
python ferramentas/entregar.py 16x9 --previa  # prévia em meia resolução, para o ver-video
python ferramentas/entregar.py 9x16 --preset social
```

Presets do `entregar.py`: `social` (Reels, TikTok, Shorts, -14 LUFS), `youtube`
(-14 LUFS), `app` (-16 LUFS, `--teto <MB>`), `site` (720p mudo, MP4 + WebM +
capa WebP). `--sem-trilha` tira a música; `--so-capa` só a capa.

## Como está montado

- `src/roteiro.json`: título, BPM, formatos (`16x9`, `9x16`, `1x1`, `4x5`), o
  segundo da capa, a voz, o volume da trilha e as cenas. Cena com `fala` dura a
  fala mais as folgas; cena sem fala dura os `segundos`. `{marca}` antes de uma
  palavra da fala marca o momento em que ela é dita.
- `src/narracao.gerado.json`: gerado pelo `npm run narrar` (duração, palavras e
  marcas). Se a fala do roteiro mudar e a narração não for refeita, o vídeo
  para com o aviso.
- `src/tema.ts`: a direção visual (cores, fontes, grão), os formatos com a zona
  segura, a transição (uma só: `varredura`, `cortina`, `dissolve`, `corte`), as
  folgas e as duas molas.
- `src/linha.tsx`: a linha do tempo. Dentro de uma cena, `useCena()` dá
  `quando('marca')`, `batida(n)`, `entra`, `dura`, `fala` e o `formato`
  (`vertical`, `seguro`). Fora, `em(cena, q)` e `marca(cena, nome)` dão o
  quadro do vídeo inteiro (o `sons.ts` usa).
- `src/Video.tsx`: o fundo contínuo, as cenas com a transição, a voz, os
  efeitos e a trilha que abaixa sob a voz. `Capa` é o quadro parado do segundo
  `capa`.
- `src/sons.ts`: os efeitos (arquivo, quadro, volume).
- `src/cenas/`: uma cena por arquivo, ligadas ao id em `cenas/index.ts`.
- `src/componentes/`: `Palavras` (tipografia cinética com marcas e destaque),
  `Apoio` (`Respira`, `Traco`, `Surge`, `Guias`), `Fundo`, `Transicao`.
- `ferramentas/`: `narrar.py`, `sons.py`, `quadros.py`, `entregar.py` e o
  `comum.py` que eles dividem.

Composições: `Video-<formato>` e `Capa-<formato>` para cada formato do roteiro.

## Fora do git

`node_modules/`, `.venv/`, `saida/`, `quadros/`, `public/narracao/` (voz gerada
por serviço da Microsoft) e `public/sons/` (regerados pelo `npm run sons`).

## Armadilhas

- O Chrome que o Remotion baixa é barrado pelo Smart App Control: o
  `remotion.config.ts` aponta para o Edge. Não tirar.
- Nada de CSS animation, `Math.random()` ou relógio: tudo sai de
  `useCurrentFrame()`.
- Espaço no fim de `inline-block` some: palavras separadas pelo gap do flex.
- Composição de capa com 1 quadro sai vazia: ela tem a duração do vídeo.
