// O vídeo inteiro: fundo contínuo, as cenas em sequência com a transição, a narração, os efeitos e a trilha
// (que abaixa sozinha enquanto a voz fala). Serve a todos os formatos do roteiro.
import {AbsoluteFill, Freeze, Sequence, getStaticFiles, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {Audio} from '@remotion/media';
import {CENAS} from './cenas';
import {Guias} from './componentes/Apoio';
import {Fundo} from './componentes/Fundo';
import {Cobertura, visibilidade} from './componentes/Transicao';
import {CenaProvider, LINHA, ROTEIRO, type Cena} from './linha';
import {SONS} from './sons';
import {FORMATOS, FPS, SOM_DA_TROCA, TROCA, type Formato} from './tema';

export type PropsVideo = {formato: string; guias: boolean; som: boolean; trilha: boolean};

const exigir = (arquivo: string, comando: string) => {
  if (!getStaticFiles().some((a) => a.name === arquivo)) throw new Error(`falta public/${arquivo}: rode ${comando}`);
};

const formatoDe = (id: string): Formato => {
  const f = FORMATOS[id];
  if (!f) throw new Error(`formato desconhecido: ${id} (tem: ${Object.keys(FORMATOS).join(', ')})`);
  return f;
};

const CenaNaTela: React.FC<{cena: Cena; ultima: boolean; formato: Formato}> = ({cena, ultima, formato}) => {
  const f = useCurrentFrame();
  const Componente = CENAS[cena.id];
  if (!Componente) throw new Error(`falta o componente da cena "${cena.id}" em src/cenas/index.ts`);
  const op = visibilidade(f, cena, ultima);
  return (
    <CenaProvider value={{cena, formato}}>
      <AbsoluteFill style={{opacity: op, visibility: op === 0 ? 'hidden' : undefined}}>
        <Componente />
      </AbsoluteFill>
    </CenaProvider>
  );
};

export const Video: React.FC<PropsVideo> = ({formato, guias, som, trilha}) => {
  const fmt = formatoDe(formato);
  const {durationInFrames} = useVideoConfig();
  const {cenas} = LINHA;

  const efeitos = som
    ? [
        ...(SOM_DA_TROCA ? cenas.slice(1).map((c) => ({arquivo: SOM_DA_TROCA, quadro: c.de - 4, volume: 0.45})) : []),
        ...SONS(),
      ]
    : [];
  if (som) {
    for (const e of efeitos) exigir(e.arquivo, 'npm run sons');
    for (const c of cenas) if (c.arquivo) exigir(c.arquivo, 'npm run narrar');
    if (trilha) exigir('sons/trilha.wav', 'npm run sons');
  }

  // a trilha abaixa enquanto a voz fala, com rampa de 10 quadros
  const falas = cenas.filter((c) => c.fala !== null).map((c) => [c.de + c.fala!, c.de + c.fala! + c.falaDura]);
  const sobVoz = (q: number) => {
    let m = 0;
    for (const [a, b] of falas) {
      const d = q < a ? a - q : q > b ? q - b : 0;
      m = Math.max(m, 1 - Math.min(1, d / 10));
    }
    return 1 - ROTEIRO.trilha.sobVoz * m;
  };
  const entraESai = (q: number) =>
    interpolate(q, [0, 20, durationInFrames - 45, durationInFrames - 2], [0, 1, 1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});

  return (
    <AbsoluteFill>
      <Fundo />
      {cenas.map((c, i) => {
        const ultima = i === cenas.length - 1;
        return (
          <Sequence key={c.id} from={c.de} durationInFrames={c.dura + (ultima ? 0 : TROCA)} name={`${i + 1} ${c.id}`}>
            <CenaNaTela cena={c} ultima={ultima} formato={fmt} />
          </Sequence>
        );
      })}
      {cenas.slice(1).map((c) => (
        <Sequence key={`troca-${c.id}`} from={c.de} durationInFrames={TROCA} name={`troca ${c.id}`}>
          <Cobertura />
        </Sequence>
      ))}
      {som &&
        cenas
          .filter((c) => c.arquivo)
          .map((c) => (
            <Sequence key={`fala-${c.id}`} from={c.de + c.fala!} name={`fala ${c.id}`} layout="none">
              <Audio src={staticFile(c.arquivo!)} />
            </Sequence>
          ))}
      {efeitos.map((e, i) => (
        <Sequence key={`som-${i}`} from={Math.max(0, e.quadro)} name={`som ${e.arquivo}`} layout="none">
          <Audio src={staticFile(e.arquivo)} volume={e.volume} />
        </Sequence>
      ))}
      {som && trilha && <Audio src={staticFile('sons/trilha.wav')} volume={(q) => ROTEIRO.trilha.volume * sobVoz(q) * entraESai(q)} />}
      {guias && <Guias formato={fmt} />}
    </AbsoluteFill>
  );
};

// A capa: um quadro parado do vídeo (o segundo "capa" do roteiro). A composição tem a duração do vídeo inteiro:
// com 1 quadro só, as cenas depois do quadro 0 seriam cortadas e a capa sairia vazia.
export const QUADRO_DA_CAPA = Math.min(Math.round(ROTEIRO.capa * FPS), LINHA.duracao - 1);

export const Capa: React.FC<PropsVideo> = (props) => (
  <Freeze frame={QUADRO_DA_CAPA}>
    <Video {...props} som={false} />
  </Freeze>
);
