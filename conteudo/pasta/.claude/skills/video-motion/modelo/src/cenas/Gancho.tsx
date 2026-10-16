// Exemplo: o gancho. Uma frase grande; o destaque entra junto da palavra marcada na fala.
import {AbsoluteFill} from 'remotion';
import {Respira} from '../componentes/Apoio';
import {Palavras} from '../componentes/Palavras';
import {useCena} from '../linha';

export const Gancho: React.FC = () => {
  const {formato} = useCena();
  return (
    <Respira>
      <AbsoluteFill style={{justifyContent: 'center', alignItems: 'center'}}>
        <Palavras
          // em pé, a quebra é escolhida à mão: deixar o navegador quebrar deixa palavra órfã numa linha
          texto={formato.vertical ? 'Todo vídeo\nbom {gancho}começa\ncom *um gancho.*' : 'Todo vídeo bom\n{gancho}começa com *um gancho.*'}
          tamanho={formato.vertical ? 104 : 150}
          largura={formato.vertical ? 865 : 1600}
        />
      </AbsoluteFill>
    </Respira>
  );
};
