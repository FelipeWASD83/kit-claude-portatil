# O ofício: princípios de motion design

Ler antes de animar. Os números são ponto de partida a 30 qps, não lei: muda
se a direção pedir, dizendo por quê.

## Tempo em quadros (30 qps)

| O quê | Quadros | Segundos |
|---|---|---|
| Micro-reação (pulso, brilho, tique) | 4 a 8 | 0,13 a 0,27 |
| Entrada de palavra ou ícone | 10 a 16 | 0,33 a 0,53 |
| Entrada de bloco grande, painel, card | 14 a 22 | 0,47 a 0,73 |
| Saída (sempre mais curta que a entrada) | 2/3 da entrada | |
| Transição de cena | 12 a 20 | 0,4 a 0,67 |
| Intervalo entre palavras (stagger) | 2 a 4 | |
| Intervalo entre blocos | 6 a 10 | |
| Pausa mínima com tudo assentado antes de sair | 20 | 0,67 |

Batida: quadros por batida = `fps * 60 / bpm`. A 120 BPM e 30 qps, 15 quadros
por batida e 60 por compasso. Cortes e impactos na batida; entradas podem
começar meia batida antes para **assentar** na batida.

Leitura: texto na tela fica pelo menos `palavras / 3 + 1` segundos. Com
narração, o texto entra junto da palavra falada (marca) e fica até a fala
acabar.

## Curvas

- **Entrada:** desacelera no fim (`Easing.out(Easing.cubic)`, `Easing.bezier(0.16, 1, 0.3, 1)` ou mola seca). A coisa chega e assenta.
- **Saída:** acelera no fim (`Easing.in(Easing.cubic)`). A coisa decide ir embora.
- **De A a B na tela:** `Easing.inOut(Easing.cubic)`.
- **Linear** só para o que não começa nem termina: rotação contínua, rolagem
  infinita, contador, drift de fundo.
- **Molas:** no Remotion, `spring({frame, fps, config, durationInFrames})`.
  - seca, sem sobra: `{damping: 200, mass: 0.6, stiffness: 180}` para texto e interface;
  - viva, com sobra leve: `{damping: 14, mass: 0.7, stiffness: 140}` para o destaque, **uma vez por cena**.
  Sobra em tudo deixa o vídeo "borrachudo".
- Movimento em escala parte de 0,9 a 0,96, não de 0. Coisa nascendo de escala
  0 é efeito de PowerPoint.

## Hierarquia e foco

- **Um foco por vez.** O olho vai para o que se mexe: se tudo se mexe, nada
  tem foco. Enquanto o destaque entra, o resto está parado ou quase.
- **Overlap:** o bloco seguinte começa antes do anterior terminar (uns 40 %
  antes). Animação em fila indiana fica lenta e mecânica.
- **Follow-through:** quem chega primeiro assenta primeiro; elementos ligados
  (título e linha embaixo) chegam com poucos quadros de diferença, não juntos.
- **Direção coerente:** tudo da cena entra pelo mesmo lado ou do mesmo jeito.
  Texto entrando de quatro direções é ruído.
- Contraste e tamanho dizem a ordem de leitura; o movimento confirma, não
  substitui.

## Tipografia cinética

- Palavra subindo de dentro de uma máscara (o padrão do `<Palavras>`) é a base
  mais limpa. Letra por letra só em palavra curta e importante.
- Títulos com tracking negativo (-0,02 a -0,04 em) e entrelinha curta (1 a 1,1).
- **Poucas palavras por tela:** 3 a 7 em vídeo de rede social. Frase longa vira
  duas telas.
- Destaque por cor ou peso em **uma** palavra por frase.
- Nada de texto em caixa com sombra pesada, contorno ou degradê em tudo.

## Vida e profundidade

- **Nada fica 100 % parado:** durante o tempo assentado, a câmera aproxima
  2 a 3 % (`<Respira>`), o fundo respira, a luz anda devagar.
- **Camadas:** fundo, meio e frente andando em velocidades diferentes
  (parallax) dão profundidade sem 3D.
- **Textura:** grão leve (opacidade 5 a 8 %) e vinheta tiram o "liso de
  computador".
- **Motion blur** em movimento rápido (`@remotion/motion-blur`, ver
  `remotion.md`) deixa o movimento contínuo, mas pesa no render: usar só onde
  a velocidade é alta.

## Transição

- Uma família só no vídeo inteiro. A troca de cena acontece **coberta** (o
  quadro do corte nunca mostra as duas cenas pela metade sem querer).
- Corte seco na batida também é transição, e muitas vezes a melhor.
- **Match cut** (a forma de uma cena vira a forma da próxima) é o que mais
  parece trabalho de estúdio: planejar no roteiro, não improvisar.
- Fade cruzado de 10 a 15 quadros serve para vídeo calmo; em vídeo rápido,
  parece indeciso.

## Ritmo do vídeo inteiro

- Começo forte, meio com variação de densidade (cena cheia, cena de respiro),
  fim com uma pausa para a marca ou a chamada.
- Rede social: a primeira imagem já tem movimento e a promessa do vídeo.
- **Loop limpo** em Reels e TikTok: o último quadro leva ao primeiro (mesmo
  fundo, mesma posição), o vídeo recomeça sem salto.
- Fora do social: 1 a 1,5 s de respiro no fim, com a trilha descendo.

## O que denuncia vídeo amador

- Tudo entrando com fade, ou tudo com a mesma mola com sobra.
- Movimento linear de A a B.
- Transição diferente a cada corte.
- Texto pequeno, muitas palavras por tela, texto encostado na borda ou fora da zona segura.
- Três fontes, cinco cores, degradê em tudo, sombra pesada.
- Elementos nascendo todos no mesmo quadro.
- Tela parada, morta, esperando a fala acabar.
- Efeito sonoro em cada movimento; trilha alta por cima da voz.
- Animação que não bate com a fala (o número aparece depois de ser dito).
- Final que corta seco no meio da trilha.
