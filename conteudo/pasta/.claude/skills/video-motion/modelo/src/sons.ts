// Os efeitos sonoros do vídeo: arquivo (em public/, gerado por npm run sons), quadro do vídeo e volume.
// marca(cena, nome) é o quadro em que a palavra marcada é dita; em(cena, q) é o quadro q da cena.
// O efeito começa 1 ou 2 quadros antes do visual que ele acompanha. O som de cada troca já vem do tema (SOM_DA_TROCA).
import {acharCena, em, marca} from './linha';

export type Som = {arquivo: string; quadro: number; volume: number};

export const SONS = (): Som[] => [
  {arquivo: 'sons/impacto.wav', quadro: marca('gancho', 'gancho') - 1, volume: 0.5},
  {arquivo: 'sons/toque.wav', quadro: em('ideia', acharCena('ideia').fala ?? 0) - 1, volume: 0.4},
  {arquivo: 'sons/deslize.wav', quadro: marca('ideia', 'tempo') - 2, volume: 0.35},
  {arquivo: 'sons/impacto.wav', quadro: em('fecho', 14), volume: 0.45},
];
