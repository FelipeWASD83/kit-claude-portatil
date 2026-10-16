# Som e entrega

## Narração

- `npm run narrar` (o `ferramentas/narrar.py`): edge-tts 7.3.1, a voz de
  leitura do Edge, num `.venv` do projeto (criado na primeira vez:
  `python -m venv .venv` e `.venv\Scripts\pip install edge-tts==7.3.1`).
  Precisa de internet e é serviço da Microsoft que pode mudar sem aviso. A
  narração gerada não vai para o git.
- Vozes boas em pt-BR: `pt-BR-ThalitaMultilingualNeural` (padrão do modelo, a
  +6%), `pt-BR-FranciscaNeural`, `pt-BR-AntonioNeural`. Em inglês:
  `en-US-AvaMultilingualNeural`, `en-US-AndrewMultilingualNeural`. Trocar no
  `roteiro.json` (`voz.nome`, `voz.velocidade`).
- Cada fala vira `public/narracao/<cena>.mp3` e o tempo de cada palavra vai
  para `src/narracao.gerado.json`. Fala que não mudou não é pedida de novo.
- Grafia de pronúncia na fala, nome certo na tela. Conferir com a transcrição
  do `ver-video`: é ela que pega nome próprio que a voz leu errado.
- Voz de IA em vídeo público: dizer que é voz sintética quando a plataforma
  pedir (o Instagram e o YouTube têm rótulo de conteúdo gerado por IA).

## Efeitos e trilha

- `npm run sons` (`ferramentas/sons.py`) sintetiza em numpy: varredura,
  deslize, toque, clique, tique, impacto, subida e uma trilha de acordes no
  BPM do roteiro. Sem amostra de ninguém: sem problema de direito.
- Efeito em evento que importa (corte, chegada do destaque, impacto do preço),
  não em todo movimento. Efeito começa 1 a 2 quadros **antes** do visual que
  ele acompanha (o ouvido percebe antes).
- Os sons do vídeo ficam em `src/sons.ts`: arquivo, quadro (por marca ou
  batida) e volume.
- Música de terceiros só com licença que ela confirme. Para Reels e TikTok, a
  saída limpa é exportar sem trilha (`--sem-trilha` no `entregar.py`) e ela
  pôr a música da biblioteca do app ao postar.

## Mixagem

| Camada | Nível (relativo) |
|---|---|
| Voz | referência (volume 1) |
| Trilha sob a voz | -18 a -22 dB abaixo da voz (o modelo abaixa sozinho: `trilha.sobVoz`) |
| Trilha sem voz | -10 a -14 dB abaixo do pico da voz |
| Efeitos | um pouco abaixo da voz; impacto pode encostar nela |

Teste rápido de mixagem: `npx remotion render src/index.ts Video-16x9
saida/mix.wav --codec wav` leva segundos. Medir com o relatório do
`entregar.py` ou ouvir pela transcrição.

## Loudness e codificação por plataforma

O `entregar.py` mede o áudio, normaliza em duas passadas (`loudnorm` do
ffmpeg) e codifica:

| Preset | Para | Vídeo | Áudio |
|---|---|---|---|
| `social` | Reels, TikTok, Shorts | H.264 High, CRF 18, `yuv420p` TV, 30 qps, `+faststart` | AAC 192k, 48 kHz, **-14 LUFS**, pico -1 dBTP |
| `youtube` | YouTube, Vimeo | H.264 High, CRF 17 | AAC 256k, **-14 LUFS**, pico -1 dBTP |
| `app` | vídeo baixado dentro de app, release | H.264, CRF 23 subindo até caber no teto (`--teto 15` MB) | AAC 128k, **-16 LUFS** |
| `site` | vídeo de fundo ou demo em página | 720p H.264 CRF 23 **e** WebM VP9 CRF 34, **mudo** | sem áudio |

Todos tiram uma capa (`saida/<nome>-capa.jpg`, 1280 px; WebP no `site`) do
segundo `capa` do roteiro.

Site: o `<video>` vai com `muted playsinline`, `preload="none"`, `poster` da
capa, toca só quando aparece na tela, botão de pausar (WCAG 2.2.2) e quem pediu
menos movimento vê só a capa.

## Zonas seguras

Não há número oficial para Reels orgânico; estes são conservadores e são os do
modelo (guias desenhadas com `guias: true`, que o `quadros.py` liga sozinho):

| Formato | Tamanho | Topo | Direita | Base | Esquerda |
|---|---|---|---|---|---|
| 9:16 (Reels, TikTok, Shorts) | 1080 × 1920 | 250 | 150 | 350 | 65 |
| 4:5 (feed) | 1080 × 1350 | 70 | 70 | 120 | 70 |
| 1:1 | 1080 × 1080 | 60 | 60 | 60 | 60 |
| 16:9 | 1920 × 1080 | 54 | 96 | 54 | 96 |

Texto e logo dentro da zona; fundo e elementos decorativos podem sangrar até a
borda. A direita do 9:16 é larga por causa dos botões de curtir e comentar; a
base, pela legenda e pelo nome do perfil.
