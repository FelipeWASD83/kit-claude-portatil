// O fundo contínuo por baixo do vídeo inteiro (não corta entre as cenas): dois tons, duas luzes que andam devagar,
// vinheta e grão. As cores vêm do tema. Trocar o desenho daqui faz parte da direção visual de cada vídeo.
import {AbsoluteFill, useCurrentFrame, useVideoConfig} from 'remotion';
import {COR, GRAO} from '../tema';

const RUIDO =
  "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='220' height='220'%3E%3Cfilter id='g'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23g)' opacity='.6'/%3E%3C/svg%3E\")";

const Luz: React.FC<{cor: string; x: number; y: number; r: number; fase: number}> = ({cor, x, y, r, fase}) => {
  const f = useCurrentFrame();
  const dx = Math.sin(f / 80 + fase) * r * 0.16;
  const dy = Math.cos(f / 95 + fase) * r * 0.12;
  return (
    <div
      style={{
        position: 'absolute',
        left: x - r + dx,
        top: y - r + dy,
        width: r * 2,
        height: r * 2,
        borderRadius: '50%',
        background: `radial-gradient(circle, ${cor} 0%, transparent 70%)`,
      }}
    />
  );
};

export const Fundo: React.FC = () => {
  const f = useCurrentFrame();
  const {width, height} = useVideoConfig();
  const maior = Math.max(width, height);
  return (
    <AbsoluteFill style={{background: `linear-gradient(160deg, ${COR.fundo} 0%, ${COR.fundo2} 100%)`, overflow: 'hidden'}}>
      <Luz cor={COR.luz1} x={width * 0.18} y={height * 0.2} r={maior * 0.5} fase={0} />
      <Luz cor={COR.luz2} x={width * 0.85} y={height * 0.85} r={maior * 0.45} fase={2.4} />
      <AbsoluteFill style={{background: 'radial-gradient(ellipse 85% 80% at 50% 50%, transparent 55%, rgba(0,0,0,.45) 100%)'}} />
      {GRAO > 0 && (
        <AbsoluteFill
          style={{backgroundImage: RUIDO, backgroundPosition: `${(f % 4) * 37}px ${(f % 4) * 53}px`, opacity: GRAO, mixBlendMode: 'overlay'}}
        />
      )}
    </AbsoluteFill>
  );
};
