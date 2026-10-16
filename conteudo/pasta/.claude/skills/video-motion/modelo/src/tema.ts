// A direção visual do vídeo e o relógio. TROCAR as cores e as fontes pela direção fechada na skill direcao-visual:
// os valores abaixo são só um ponto de partida neutro para o modelo renderizar, não uma estética.
import {loadFont as carregarTitulo} from '@remotion/google-fonts/Inter';
import {loadFont as carregarApoio} from '@remotion/google-fonts/Inter';

export const {fontFamily: FONTE_TITULO} = carregarTitulo('normal', {weights: ['600', '800'], subsets: ['latin', 'latin-ext']});
export const {fontFamily: FONTE_APOIO} = carregarApoio('normal', {weights: ['400', '500'], subsets: ['latin', 'latin-ext']});

// Paleta curta: dois tons de fundo, texto, texto de apoio, uma cor de destaque e as duas luzes do fundo.
export const COR = {
  fundo: '#16181d',
  fundo2: '#22252c',
  texto: '#f3f1ec',
  textoSuave: '#a7a39a',
  destaque: '#e9b44c',
  luz1: 'rgba(233,180,76,.20)',
  luz2: 'rgba(120,140,200,.16)',
};

// Opacidade do grão por cima de tudo (0 desliga). Entre 0,05 e 0,08 tira o "liso de computador" sem sujar.
export const GRAO = 0.06;

export const FPS = 30;

// Os formatos que o roteiro pode pedir. O lado curto é sempre 1080: tamanho em px vale para todos.
// "seguro" é a margem onde texto e logo não entram (referencias/som-e-entrega.md).
export type Formato = {
  id: string;
  largura: number;
  altura: number;
  seguro: {topo: number; dir: number; base: number; esq: number};
};
export const FORMATOS: Record<string, Formato> = {
  '16x9': {id: '16x9', largura: 1920, altura: 1080, seguro: {topo: 54, dir: 96, base: 54, esq: 96}},
  '9x16': {id: '9x16', largura: 1080, altura: 1920, seguro: {topo: 250, dir: 150, base: 350, esq: 65}},
  '1x1': {id: '1x1', largura: 1080, altura: 1080, seguro: {topo: 60, dir: 60, base: 60, esq: 60}},
  '4x5': {id: '4x5', largura: 1080, altura: 1350, seguro: {topo: 70, dir: 70, base: 120, esq: 70}},
};

// Uma transição só para o vídeo inteiro:
//   'varredura' faixa na cor de destaque atravessa na diagonal e cobre o corte
//   'cortina'   painel no tom do fundo entra pela direita, cobre o corte e sai pela esquerda
//   'dissolve'  a cena velha some enquanto a nova aparece (vídeo calmo)
//   'corte'     corte seco no meio da troca
export type TipoTransicao = 'varredura' | 'cortina' | 'dissolve' | 'corte';
export const TRANSICAO: TipoTransicao = 'varredura';
export const TROCA = 16; // quadros da troca; o corte fica no meio
// Som tocado em cada troca (arquivo em public/), ou null para nenhum.
export const SOM_DA_TROCA: string | null = 'sons/varredura.wav';

// Folgas de cada cena narrada: da troca até a fala começar e da fala até a próxima troca.
export const ANTES = 6;
export const DEPOIS = 20;

// Um vocabulário só de movimento: a seca para quase tudo, a viva para o destaque (uma vez por cena).
export const MOLA_SECA = {damping: 200, mass: 0.6, stiffness: 180};
export const MOLA_VIVA = {damping: 14, mass: 0.7, stiffness: 140};
