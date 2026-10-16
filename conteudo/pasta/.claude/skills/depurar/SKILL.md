---
name: depurar
description: Achar a causa de um defeito por evidência, antes de mexer no código - reproduzir, ler o erro inteiro, levantar uma hipótese de cada vez, testar, corrigir a causa e provar que sumiu. Usar quando algo quebrou, falhou ou se comporta diferente do esperado, quando um erro aparece sem explicação, e sempre que a primeira correção não resolveu.
argument-hint: "[o que está errado]"
allowed-tools: Read Grep Glob Bash Edit Write
---

# Depurar por evidência

Defeito não se resolve por palpite. O caminho mais caro é o mais comum: mudar
três coisas "para ver se vai", não saber qual resolveu (ou se algo resolveu) e
deixar a causa de pé.

Problema: `$ARGUMENTS`

## 1. Reproduzir

Antes de qualquer hipótese, **fazer o defeito acontecer de novo**, com o comando ou
os passos exatos. Anotar o que se vê, palavra por palavra.

- Não consegue reproduzir? Dizer isso. Pedir o que falta (passo, arquivo, versão,
  print). Corrigir o que não se vê é só adivinhar com mais cerimônia.
- Reproduz só às vezes? Isso é a evidência mais importante: o que muda entre uma
  vez e outra (hora, ordem, dado, cache, rede, outra janela aberta)?

## 2. Ler a evidência inteira

- A mensagem de erro **do começo ao fim**, não só a última linha. A causa costuma
  estar na primeira linha do rastro e no "caused by" mais abaixo.
- Logs, saída do terminal, console do navegador, aba de rede, o arquivo que foi
  gerado de errado. Citar o trecho que sustenta cada conclusão.
- Versões e ambiente: sistema, versão da linguagem e das bibliotecas, de qual pasta
  o comando rodou.

## 3. Delimitar

Cortar o problema pela metade até sobrar o menor caso que ainda quebra.

- **O que mudou desde que funcionava?** `git log`, `git diff`, versão de pacote
  atualizada, arquivo editado, atualização do Windows. Se o git tem um commit bom,
  dá para bisseccionar (`git bisect`).
- O mesmo código funciona em outra pasta, outro arquivo de dados, outra máquina?
- Comentar um pedaço e ver se o defeito some diz em qual metade ele mora.

## 4. Hipóteses, uma de cada vez

Escrever de uma a três hipóteses, da mais provável para a menos, **cada uma com o
teste barato que a confirma ou descarta**. Testar uma, registrar o resultado, e só
então a seguinte.

- Hipótese **descartada** fica anotada. **Não voltar a ela sem um motivo novo e
  concreto** (um dado que não existia).
- Distinguir o que está **confirmado** (eu vi), o que é **inferência** (decorre do
  que vi) e o que é **suspeita** (ainda não testei). Misturar os três é como a
  causa errada vira "a correção".
- Duas tentativas seguidas sem avançar: parar, voltar ao passo 2 e procurar o dado
  que está faltando em vez de tentar uma terceira ideia.

## 5. Corrigir a causa, não o sintoma

Sinais de que é sintoma: um `try/except` que engole o erro, um `sleep` que "dá
tempo", um `if` especial para o caso que quebrou, um valor fixo no lugar do que
deveria ser calculado. Se a correção é assim, explicar por quê e procurar a causa
de verdade; se não dá para chegar nela agora, dizer que é um remendo.

Mudar o mínimo. Defeito pequeno não pede refatoração. Achou outro problema no
caminho? Avisar, não consertar calado.

## 6. Provar

- Rodar **o mesmo caso que falhava** e mostrar que passa.
- Rodar o que o projeto tem de teste (`npm test`, `python -m unittest`, o linter) e
  o que estava ao lado do trecho mexido, para ver que nada quebrou de rebote.
- Quando couber, deixar um **teste que falharia sem a correção**. Defeito que volta
  é defeito que não ganhou teste.
- Não deu para rodar (sem dado, sem chave, sem permissão)? Dizer que **não foi
  verificado**, em vez de escrever "corrigido".

## 7. Relatar

```
Causa: <o que estava errado, em uma ou duas frases> (confirmado / inferência)
Como achei: <a evidência que mostrou, não o caminho todo>
O que mudei: <arquivo e o quê, em linguagem simples>
Como provei: <o que rodei e o resultado>
Não verificado: <o que ficou sem prova>
Descartado no caminho: <hipóteses que não eram, para não voltarem>
```

## Armadilhas frequentes no Windows

- `python3` abre a Microsoft Store: usar `python`.
- Caminho com espaço sem aspas; barra invertida comida por heredoc ou por
  `\n` dentro de string. Em PowerShell, preferir `-LiteralPath`.
- Arquivo salvo com BOM ou com a codificação errada (acento virando `Ã©`): um
  `.ps1` com acento precisa de UTF-8 com BOM; já o PowerShell 5.1 sem BOM lê ANSI.
- Porta já ocupada por um servidor esquecido: `netstat -ano | findstr :PORTA`.
- Antivírus ou Smart App Control bloqueando um `.exe`/`.dll` novo ("uma política
  bloqueou este arquivo"): não é bug do código.
- Dado guardado do lado do navegador (`localStorage`, IndexedDB) que sobreviveu à
  mudança: o defeito pode estar no estado antigo, não no código novo. Testar em
  janela anônima.
- Cache: do navegador, do `node_modules`, do `__pycache__`, do build. "Funciona na
  minha máquina" muitas vezes é "funciona com o cache velho".
