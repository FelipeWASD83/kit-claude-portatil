# PORTAS.md — portas dos projetos desta pasta

Qual porta cada projeto usa. O preview do Claude Code lê o
`.claude/launch.json`; este arquivo existe para ninguém precisar abrir JSON
para saber se uma porta está livre, e para guardar o que o JSON não diz: porta
de dados, porta de uso real e divergência.

**Criou ou mudou porta? Atualizar o `launch.json` e este arquivo na mesma
tarefa.** O `_organizacao\checar-pasta.ps1` avisa quando uma porta do
`launch.json` não aparece aqui.

> Vazio porque a pasta é nova. O `/inicializar-pasta` preenche junto com o
> `launch.json`.

## Faixas

| Tipo de projeto | Faixa |
|---|---|
| Estático servido por `python -m http.server` | 4300–4399 |
| Vite / bundler com servidor próprio | 5170–5199 |
| Backend Python (Flask, FastAPI, servidor próprio) | 8000–8099 |
| Ferramenta e serviço auxiliar | 8700–8799 |

**Porta repetida é bug, não economia:** `localStorage` e IndexedDB são
separados por origem, então dois projetos na mesma porta enxergam os dados um
do outro. Projeto cujo servidor de uso real guarda dados precisa de uma porta
só dele, e o preview do agente não pode ocupá-la.

## Por projeto

| Projeto | Porta | Como sobe | Observação |
|---|---|---|---|
| _(vazio)_ | | | |
