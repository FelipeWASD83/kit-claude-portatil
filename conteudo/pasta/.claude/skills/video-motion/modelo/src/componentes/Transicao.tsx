// A transição do vídeo (uma só, escolhida em tema.ts). As cenas são transparentes sobre o fundo contínuo, então a
// troca funciona assim: a cena velha some e a nova aparece no meio da troca, e a cobertura esconde esse corte.
import {AbsoluteFill, Easing, interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import type {Cena} from '../linha';
import {COR, TRANSICAO, TROCA} from '../tema';

const LIMITA = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

// opacidade da cena no quadro f (relativo a ela)
export const visibilidade = (f: number, cena: Cena, ultima: boolean): number => {
  if (TRANSICAO === 'dissolve') {
    const entrada = cena.indice === 0 ? 1 : interpolate(f, [0, TROCA], [0, 1], {...LIMITA, easing: Easing.inOut(Easing.quad)});
    const saida = ultima ? 1 : interpolate(f, [cena.dura, cena.dura + TROCA], [1, 0], {...LIMITA, easing: Easing.inOut(Easing.quad)});
    return Math.min(entrada, saida);
  }
  const meio = TROCA / 2;
  if (cena.indice > 0 && f < meio) return 0;
  if (!ultima && f >= cena.dura + meio) return 0;
  return 1;
};

// o que passa por cima no momento da troca (dura TROCA quadros; o corte é no meio)
export const Cobertura: React.FC = () => {
  const f = useCurrentFrame();
  const {width, height} = useVideoConfig();
  const t = interpolate(f, [0, TROCA], [0, 1], {...LIMITA, easing: Easing.inOut(Easing.cubic)});
  if (t <= 0 || t >= 1) return null;

  if (TRANSICAO === 'varredura') {
    const diag = Math.hypot(width, height);
    const comprimento = diag * 3;
    const espessura = diag * 1.2;
    const curso = espessura / 2 + diag / 2;
    const d = interpolate(t, [0, 1], [curso, -curso]);
    return (
      <AbsoluteFill style={{overflow: 'hidden', pointerEvents: 'none'}}>
        <div
          style={{
            position: 'absolute',
            left: width / 2 - comprimento / 2,
            top: height / 2 - espessura / 2,
            width: comprimento,
            height: espessura,
            background: COR.destaque,
            transform: `rotate(-28deg) translateY(${d}px)`,
          }}
        />
      </AbsoluteFill>
    );
  }

  if (TRANSICAO === 'cortina') {
    // entra pela direita até cobrir no meio da troca e sai pela esquerda
    const x = t < 0.5 ? interpolate(t, [0, 0.5], [100, 0]) : interpolate(t, [0.5, 1], [0, -100]);
    const borda = t < 0.5 ? 'left' : 'right';
    return (
      <AbsoluteFill style={{overflow: 'hidden', pointerEvents: 'none'}}>
        <AbsoluteFill style={{background: COR.fundo2, transform: `translateX(${x}%)`}}>
          <div style={{position: 'absolute', top: 0, bottom: 0, [borda]: 0, width: 6, background: COR.destaque}} />
        </AbsoluteFill>
      </AbsoluteFill>
    );
  }

  return null; // dissolve e corte não cobrem nada
};
