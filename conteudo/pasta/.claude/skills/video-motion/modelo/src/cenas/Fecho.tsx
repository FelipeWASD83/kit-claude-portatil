// Exemplo: fecho sem fala, guiado pela batida. O círculo se desenha, a marca entra na mola viva e o apoio vem uma
// batida depois. A cena tem os "segundos" do roteiro; o vídeo termina com o fundo respirando.
import {AbsoluteFill} from 'remotion';
import {Respira, Surge, Traco} from '../componentes/Apoio';
import {Palavras} from '../componentes/Palavras';
import {useCena} from '../linha';
import {COR, FONTE_APOIO, MOLA_VIVA} from '../tema';

const R = 70;

export const Fecho: React.FC = () => {
  const {formato, batida} = useCena();
  const v = formato.vertical;
  return (
    <Respira quanto={0.02}>
      <AbsoluteFill style={{justifyContent: 'center', alignItems: 'center', gap: 46}}>
        <Surge inicio={batida(0)} mola={MOLA_VIVA} escala={0.9} distancia={0}>
          <div style={{position: 'relative', width: R * 2 + 16, height: R * 2 + 16}}>
            <Traco
              d={`M ${R + 8} 8 A ${R} ${R} 0 1 1 ${R + 7.9} 8`}
              largura={R * 2 + 16}
              altura={R * 2 + 16}
              inicio={batida(0)}
              duracao={20}
              espessura={10}
              style={{position: 'absolute', inset: 0}}
            />
            <div style={{position: 'absolute', inset: R * 0.62, borderRadius: '50%', background: COR.destaque}} />
          </div>
        </Surge>
        <Palavras texto="seu vídeo aqui" tamanho={v ? 104 : 112} inicio={batida(1)} />
        <Surge inicio={batida(2)} distancia={20}>
          <div style={{fontFamily: FONTE_APOIO, fontWeight: 500, fontSize: 40, color: COR.textoSuave, letterSpacing: '0.04em'}}>
            feito em código com Remotion
          </div>
        </Surge>
      </AbsoluteFill>
    </Respira>
  );
};
