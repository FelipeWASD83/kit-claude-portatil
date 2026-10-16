---
name: backup-local
description: Configura e roda o backup local da pasta de trabalho - escolhe com a pessoa o destino (HD externo, pendrive, outra pasta), grava _organizacao/backup-destino.txt, simula, roda o espelho e oferece agendar de hora em hora. Usar quando a pessoa pedir backup, quando _organizacao/backup-destino.txt não existir, ou quando o backup falhar e for preciso entender por quê.
argument-hint: "[nada]"
allowed-tools: Read Write Edit Bash PowerShell
---

# Backup local da pasta de trabalho

O git de cada projeto guarda o **histórico**, mas mora dentro da própria pasta: se
a pasta for apagada ou o disco morrer, o histórico vai junto. O backup local é uma
**cópia fiel desta pasta inteira em outro lugar**, e enquanto não houver
repositório remoto é a única cópia fora do PC. Quem faz o trabalho é o
`_organizacao\backup-local.ps1`; esta skill só o configura e o confere.

## 1. Ver em que pé está

```powershell
Test-Path ".\_organizacao\backup-destino.txt"
Get-Content ".\_organizacao\backup-destino.txt" -ErrorAction SilentlyContinue
Get-Content ".\_organizacao\.backup-local.log" -Tail 8 -ErrorAction SilentlyContinue
```

Já existe e está rodando? Mostrar o destino, a última linha do log e perguntar o
que ela quer mudar. Só entrar nos passos abaixo para o que for novo.

## 2. Escolher o destino

Mostrar o que o computador tem:

```powershell
Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, DriveType, @{n='LivreGB';e={[math]::Round($_.SizeRemaining/1GB)}}, @{n='TotalGB';e={[math]::Round($_.Size/1GB)}}
Get-PhysicalDisk | Select-Object FriendlyName, BusType, MediaType, @{n='GB';e={[math]::Round($_.Size/1GB)}}
```

Recomendar, nesta ordem:

1. **HD ou SSD externo (USB)**, de preferência guardado longe do PC. Protege de
   disco que morre, de apagar sem querer e de vírus.
2. **Pendrive grande** (cabe a pasta com folga?). Mesma proteção, mais frágil.
3. **Outro disco interno** do mesmo PC. Protege de apagar sem querer, mas não de
   queda de energia forte, furto nem incêndio.
4. **Outra pasta no mesmo disco** (C:): só protege de apagar sem querer. Dizer isso
   com todas as letras; não vender como backup de verdade.

Pasta de **sincronização na nuvem** (OneDrive, Google Drive, iCloud) como destino:
possível, mas o espelho copia tudo, inclusive `node_modules`, e a nuvem vai tentar
subir cada arquivo. Se ela quiser mesmo assim, avisar do peso e do consumo.

O tamanho da pasta de origem, para saber se cabe:

```powershell
"{0:N1} GB" -f ((Get-ChildItem -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1GB)
```

O destino **nunca** pode ficar dentro da pasta de trabalho (o script recusa).

## 3. Gravar o destino

Criar `_organizacao\backup-destino.txt`, uma chave por linha:

```
caminho=E:\Backup\Trabalho
rotulo=Meu HD Externo
```

- `caminho` é a pasta onde cai o espelho (o script cria se não existir).
- `rotulo` só para disco externo: com ele, se a letra do drive mudar (o Windows às
  vezes troca de E: para F:), o script acha o disco pelo nome. O nome está na
  coluna `FileSystemLabel` do comando acima; se estiver vazio, sugerir dar um nome
  ao disco no Explorador (botão direito > Renomear) e deixar `rotulo` de fora até lá.
- `fonte=<pasta>` (opcional, pode repetir) leva junto outra pasta dela, como
  `Documentos\Projetos`.

Esse arquivo é da máquina (cada disco tem sua letra): já está no `.gitignore`.

## 4. Simular, depois rodar

```powershell
powershell -ExecutionPolicy Bypass -File ".\_organizacao\backup-local.ps1" -Simular
```

Mostrar o resumo (quantos arquivos, o que entraria). Se estiver certo, rodar de
verdade sem `-Simular`. Depois **conferir de verdade**: abrir o destino e checar que
a pasta e o `LEIA-PRIMEIRO.md` estão lá e que um arquivo qualquer do projeto abre.

## 5. Agendar

Explicar: o backup do fim de cada tarefa já roda sozinho (regra da seção 6 do
`CLAUDE.md`); o agendamento cobre o que acontece **longe do Claude** (de hora em
hora e ao entrar no Windows). Se ela quiser:

```powershell
powershell -ExecutionPolicy Bypass -File ".\_organizacao\agendar-backup-local.ps1"
```

Para tirar: o mesmo comando com `-Remover`. Disco desplugado não dá erro: a tarefa
só não copia nada e tenta na próxima hora.

## 6. Avisar o que isso é e o que não é

- É **espelho**, não histórico: o que ela apagar no PC some do destino na próxima
  cópia (`robocopy /MIR`). Para voltar uma versão antiga, o caminho é o git do
  projeto.
- Não substitui uma cópia **fora de casa**. Se ela tiver nuvem, copiar à mão as
  coisas que doeria perder para lá de vez em quando; e o GitHub (privado) é a
  forma mais simples de ter isso para o código.
- Códigos de saída do script: `0` ok, `1` falha ou origem suspeita, `2` destino
  desconectado, `3` backup não configurado.

## Se der errado

- **Código 2**: o disco não está plugado (ou o `rotulo` não bate). Plugar e rodar
  de novo.
- **"O destino está DENTRO de uma pasta de origem"**: escolher um destino fora da
  pasta de trabalho.
- **"origem com N arquivos, abaixo do mínimo"**: a trava de segurança do `/MIR`
  achou a pasta quase vazia; não rodou de propósito. Conferir se a pasta de
  trabalho está no lugar antes de forçar qualquer coisa.
- **Falha do robocopy (código 8 ou mais)**: ver o fim do log em
  `_organizacao\.backup-local.log`; causas comuns são disco cheio, arquivo aberto
  por outro programa e caminho longo demais.
