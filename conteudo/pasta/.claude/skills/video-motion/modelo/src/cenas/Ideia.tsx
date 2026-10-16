// Exemplo: camadas presas à fala. O número entra na mola viva (o destaque da cena) assim que a voz começa, para a
// tela não ficar vazia enquanto ela diz "Depois,"; o título sobe na marca {uma}; na marca {tempo} o traço se
// desenha embaixo e o texto de apoio entra.
// Em pé, o número fica em cima do título; deitado, ao lado.
import {AbsoluteFill} from 'remotion';
import {Respira, Surge, Traco} from '../componentes/Apoio';
import {Palavras} from '../componentes/Palavras';
import {useCena} from '../linha';
import {COR, FONTE_APOIO, FONTE_TITULO, MOLA_VIVA} from '../tema';

export const Ideia: React.FC = () => {
  const {formato, quando, fala} = useCena();
  const v = formato.vertical;
  const voz = fala ?? 0;
  const tempo = quando('tempo');
  const larguraTraco = v ? 620 : 760;
  return (
    <Respira>
      <AbsoluteFill style={{justifyContent: 'center', alignItems: 'center'}}>
        <div style={{display: 'flex', flexDirection: v ? 'column' : 'row', alignItems: v ? 'center' : 'flex-end', gap: v ? 20 : 70}}>
          <Surge inicio={voz}mola={MOLA_VIVA} escala={0.92} distancia={60}>
            <div style={{fontFamily: FONTE_TITULO, fontWeight: 800, fontSize: v ? 300 : 360, lineHeight: 0.8, color: COR.destaque}}>1</div>
          </Surge>
          <div style={{display: 'flex', flexDirection: 'column', alignItems: v ? 'center' : 'flex-start', gap: 26}}>
            <Palavras texto={'{uma}uma ideia\npor cena.'} tamanho={v ? 112 : 128} alinhamento={v ? 'center' : 'left'} />
            <Traco d={`M 4 14 Q ${larguraTraco * 0.5} 2 ${larguraTraco - 4} 12`} largura={larguraTraco} altura={24} inicio={tempo} />
            <Surge inicio={tempo + 6} distancia={24}>
              <div style={{fontFamily: FONTE_APOIO, fontWeight: 500, fontSize: v ? 50 : 46, color: COR.textoSuave}}>presa ao tempo da fala</div>
            </Surge>
          </div>
        </div>
      </AbsoluteFill>
    </Respira>
  );
};
