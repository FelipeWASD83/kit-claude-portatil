// Peças pequenas que quase toda cena usa: Respira (a câmera aproxima devagar no tempo parado), Traco (um caminho SVG
// que se desenha), Surge (um bloco que entra numa mola) e Guias (a zona segura, só para conferir).
import {AbsoluteFill, Easing, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {useCena} from '../linha';
import {COR, FONTE_APOIO, MOLA_SECA, TROCA, type Formato} from '../tema';

const LIMITA = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

export const Respira: React.FC<{children: React.ReactNode; quanto?: number}> = ({children, quanto = 0.03}) => {
  const f = useCurrentFrame();
  const cena = useCena();
  const s = interpolate(f, [cena.entra, cena.dura + TROCA], [1, 1 + quanto], LIMITA);
  return <AbsoluteFill style={{transform: `scale(${s})`}}>{children}</AbsoluteFill>;
};

type PropsTraco = {
  d: string;
  largura: number;
  altura: number;
  inicio: number;
  duracao?: number;
  cor?: string;
  espessura?: number;
  style?: React.CSSProperties;
};

export const Traco: React.FC<PropsTraco> = ({d, largura, altura, inicio, duracao = 18, cor = COR.destaque, espessura = 8, style}) => {
  const f = useCurrentFrame();
  const p = interpolate(f, [inicio, inicio + duracao], [0, 1], {...LIMITA, easing: Easing.inOut(Easing.cubic)});
  return (
    <svg width={largura} height={altura} viewBox={`0 0 ${largura} ${altura}`} style={{overflow: 'visible', ...style}}>
      <path d={d} pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - p} fill="none" stroke={cor} strokeWidth={espessura} strokeLinecap="round" />
    </svg>
  );
};

type PropsSurge = {
  children: React.ReactNode;
  inicio: number;
  mola?: typeof MOLA_SECA;
  distancia?: number; // px que ele sobe ao entrar
  escala?: number; // escala de partida (0,9 a 0,96; nunca 0)
  style?: React.CSSProperties;
};

export const Surge: React.FC<PropsSurge> = ({children, inicio, mola = MOLA_SECA, distancia = 40, escala = 1, style}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const s = spring({frame: f - inicio, fps, config: mola, durationInFrames: 20});
  const op = interpolate(s, [0, 0.4], [0, 1], LIMITA);
  return (
    <div style={{opacity: op, transform: `translateY(${(1 - s) * distancia}px) scale(${escala + (1 - escala) * s})`, ...style}}>{children}</div>
  );
};

export const Guias: React.FC<{formato: Formato}> = ({formato}) => {
  const {topo, dir, base, esq} = formato.seguro;
  return (
    <AbsoluteFill style={{pointerEvents: 'none'}}>
      <div style={{position: 'absolute', left: esq, top: topo, right: dir, bottom: base, border: '4px dashed rgba(255,70,70,.85)'}} />
      <div style={{position: 'absolute', left: '50%', top: 0, bottom: 0, width: 2, background: 'rgba(255,70,70,.35)'}} />
      <div style={{position: 'absolute', top: '50%', left: 0, right: 0, height: 2, background: 'rgba(255,70,70,.35)'}} />
      <div style={{position: 'absolute', left: esq + 12, top: topo + 8, fontFamily: FONTE_APOIO, fontSize: 28, color: 'rgba(255,70,70,.95)'}}>
        zona segura {formato.id}
      </div>
    </AbsoluteFill>
  );
};
