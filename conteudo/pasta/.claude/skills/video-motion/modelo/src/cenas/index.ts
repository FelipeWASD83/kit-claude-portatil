// Cada id de cena do roteiro aponta para o componente dela. As três de agora são o exemplo do modelo: trocar.
import {Fecho} from './Fecho';
import {Gancho} from './Gancho';
import {Ideia} from './Ideia';

export const CENAS: Record<string, React.FC> = {
  gancho: Gancho,
  ideia: Ideia,
  fecho: Fecho,
};
