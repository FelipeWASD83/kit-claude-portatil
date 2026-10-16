// Tipografia cinética: cada palavra sobe de dentro de uma máscara, numa mola seca.
//   \n           quebra a linha
//   *palavras*   saem na cor de destaque (pode abranger várias palavras)
//   {marca}      antes de uma palavra: ela entra quando a fala diz a palavra marcada (as seguintes vêm em sequência)
// Sem marca, a primeira palavra entra em "inicio" (padrão: quando a fala da cena começa, ou quando a cena aparece).
import {interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {useCena} from '../linha';
import {COR, FONTE_TITULO, MOLA_SECA} from '../tema';

type Props = {
  texto: string;
  tamanho: number;
  inicio?: number;
  intervalo?: number; // quadros entre uma palavra e a próxima
  saida?: number; // quadro em que o bloco inteiro sobe e some
  alinhamento?: 'left' | 'center' | 'right';
  largura?: number;
  cor?: string;
  corDestaque?: string;
  fonte?: string;
  peso?: number;
  entrelinha?: number;
  espacamento?: string; // letter-spacing
};

const MARCA = /^\{([a-z0-9_]+)\}(.*)$/;

export const Palavras: React.FC<Props> = ({
  texto,
  tamanho,
  inicio,
  intervalo = 3,
  saida,
  alinhamento = 'center',
  largura,
  cor = COR.texto,
  corDestaque = COR.destaque,
  fonte = FONTE_TITULO,
  peso = 800,
  entrelinha = 1.04,
  espacamento = '-0.03em',
}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const cena = useCena();
  let relogio = inicio ?? cena.fala ?? cena.entra;
  let dentro = false;

  const linhas = texto.split('\n').map((linha) => {
    const palavras: {texto: string; quando: number; destaque: boolean}[] = [];
    for (let w of linha.split(/\s+/).filter(Boolean)) {
      const m = MARCA.exec(w);
      if (m) {
        relogio = cena.quando(m[1]);
        w = m[2];
        if (!w) continue; // "{marca} palavra": a marca vale para a próxima
      }
      const abre = w.startsWith('*');
      const fecha = /\*[.,;:!?…"')]*$/.test(w);
      palavras.push({texto: w.replace(/\*/g, ''), quando: relogio, destaque: dentro || abre});
      dentro = (dentro || abre) && !fecha;
      relogio += intervalo;
    }
    return palavras;
  });

  const sai = saida === undefined ? 0 : spring({frame: f - saida, fps, config: MOLA_SECA, durationInFrames: 12});
  const justifica = alinhamento === 'center' ? 'center' : alinhamento === 'right' ? 'flex-end' : 'flex-start';
  return (
    <div
      style={{
        fontFamily: fonte,
        fontWeight: peso,
        fontSize: tamanho,
        lineHeight: entrelinha,
        letterSpacing: espacamento,
        color: cor,
        textAlign: alinhamento,
        width: largura,
        transform: `translateY(${-sai * tamanho * 0.4}px)`,
        opacity: 1 - sai,
      }}
    >
      {linhas.map((palavras, l) => (
        // espaço entre palavras pelo gap: espaço no fim de inline-block some
        <div key={l} style={{display: 'flex', flexWrap: 'wrap', justifyContent: justifica, columnGap: tamanho * 0.26}}>
          {palavras.map((p, i) => {
            const s = spring({frame: f - p.quando, fps, config: MOLA_SECA, durationInFrames: 16});
            return (
              <span key={i} style={{display: 'inline-block', overflow: 'hidden', paddingBottom: tamanho * 0.14, marginBottom: -tamanho * 0.14}}>
                <span
                  style={{
                    display: 'inline-block',
                    transform: `translateY(${interpolate(s, [0, 1], [110, 0])}%)`,
                    color: p.destaque ? corDestaque : undefined,
                  }}
                >
                  {p.texto}
                </span>
              </span>
            );
          })}
        </div>
      ))}
    </div>
  );
};
