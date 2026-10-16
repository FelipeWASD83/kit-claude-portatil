// As composições: para cada formato do roteiro, o vídeo (Video-16x9, Video-9x16...) e a capa (Capa-16x9...).
import {Composition} from 'remotion';
import {LINHA, ROTEIRO} from './linha';
import {FORMATOS, FPS} from './tema';
import {Capa, Video, type PropsVideo} from './Video';

export const Raiz: React.FC = () => (
  <>
    {ROTEIRO.formatos.map((id) => {
      const f = FORMATOS[id];
      if (!f) throw new Error(`formato desconhecido no roteiro: ${id}`);
      const props: PropsVideo = {formato: id, guias: false, som: true, trilha: true};
      return [
        <Composition key={`v-${id}`} id={`Video-${id}`} component={Video} durationInFrames={LINHA.duracao} fps={FPS} width={f.largura} height={f.altura} defaultProps={props} />,
        <Composition key={`c-${id}`} id={`Capa-${id}`} component={Capa} durationInFrames={LINHA.duracao} fps={FPS} width={f.largura} height={f.altura} defaultProps={props} />,
      ];
    })}
  </>
);
