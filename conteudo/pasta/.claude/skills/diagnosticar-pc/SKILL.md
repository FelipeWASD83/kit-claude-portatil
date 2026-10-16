---
name: diagnosticar-pc
description: Diagnosticar problema do Windows e do hardware (lentidão, travamento, tela azul, disco cheio ou lento, rede, som, jogo com FPS baixo, boot demorado) usando logs, Visualizador de Eventos e medições reais antes de sugerir qualquer mudança. Usar quando a pessoa descrever um problema no computador, pedir para descobrir por que algo está lento ou instável, ou perguntar se uma peça é o gargalo.
argument-hint: "[o sintoma]"
allowed-tools: Read Grep Glob Bash PowerShell WebSearch
---

# Diagnosticar o computador por evidência

O erro típico é concluir pelo **nome das peças** ("é um processador forte, então o
gargalo é a placa de vídeo") ou culpar a temperatura sem ter medido. Aqui a ordem é
outra: **sintoma, medição, interpretação, só então solução**, da mais segura para a
mais invasiva.

Sintoma: `$ARGUMENTS`

Antes de tudo, ler a seção 2 do `CLAUDE.md` da pasta (a máquina medida na primeira
configuração). Se a pessoa já mandou números (temperatura, FPS, uso, clocks),
**eles valem mais que qualquer suposição genérica** sobre o hardware.

## 1. Descrever o sintoma

Perguntar só o que muda o caminho, em bloco curto:

- O que acontece exatamente, e quando? (sempre, só em um programa, só depois de
  horas ligado)
- **Desde quando, e o que mudou antes?** Atualização do Windows, driver novo,
  programa instalado, peça trocada, obra de energia.
- Aparece mensagem ou código? Pedir a frase exata ou o print.

## 2. Coletar (só leitura)

Escolher pelo sintoma. Tudo abaixo apenas lê. Rodar em PowerShell; o que precisar
de administrador, dizer e pedir que a pessoa abra o PowerShell como administrador.

**Eventos recentes de erro (quase sempre o primeiro passo):**

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-3)} -MaxEvents 40 |
  Select-Object TimeCreated, ProviderName, Id, @{n='Msg';e={($_.Message -split "`n")[0]}}
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-3)} -MaxEvents 30 |
  Select-Object TimeCreated, ProviderName, Id, @{n='Msg';e={($_.Message -split "`n")[0]}}
```

IDs que valem atenção: `Kernel-Power 41` (desligou sem avisar: energia, fonte,
temperatura ou travamento), `BugCheck 1001` (tela azul, com o código), `disk`/`Ntfs`
(disco com erro), `WHEA-Logger` (erro de hardware: processador, memória, PCIe),
`Display` (driver de vídeo parou e voltou).

**Lentidão e travamento:**

```powershell
# uso agora (WMI: os nomes das classes não mudam com o idioma do Windows, ao contrário do
# Get-Counter, que em Windows em português exige os nomes dos contadores traduzidos)
1..5 | ForEach-Object {
  $cpu = (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'").PercentProcessorTime
  $disco = (Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk -Filter "Name='_Total'").PercentDiskTime
  $os = Get-CimInstance Win32_OperatingSystem
  '{0}% CPU | {1}% disco | {2} MB de RAM livre' -f $cpu, $disco, [math]::Round($os.FreePhysicalMemory/1KB)
  Start-Sleep -Seconds 2
}
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, @{n='MB';e={[math]::Round($_.WorkingSet64/1MB)}}
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
```

**Disco (cheio, lento, com erro):**

```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{n='LivreGB';e={[math]::Round($_.Free/1GB)}}, @{n='UsadoGB';e={[math]::Round($_.Used/1GB)}}
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, @{n='GB';e={[math]::Round($_.Size/1GB)}}
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId, Temperature, Wear, ReadErrorsTotal, WriteErrorsTotal, PowerOnHours
```

**Rede:**

```powershell
ping -n 10 1.1.1.1
ping -n 10 8.8.8.8
Get-NetAdapter | Select-Object Name, Status, LinkSpeed
ipconfig /all
```

Perda de pacote e tempo máximo no resumo do `ping` mostram instabilidade que a
velocidade média esconde. Para saber se o problema é o Wi-Fi, o roteador ou o
provedor, comparar o ping até o roteador (o "Gateway padrão" do `ipconfig`) com o
ping até fora.

**Som, vídeo, drivers:**

```powershell
Get-PnpDevice -PresentOnly | Where-Object { $_.Status -ne 'OK' } | Select-Object FriendlyName, Class, Status
Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceClass -in 'DISPLAY','MEDIA' } | Select-Object DeviceName, DriverVersion, DriverDate
nvidia-smi
```

**Jogo ou programa pesado com FPS baixo:** pedir o uso de CPU e de GPU **durante** o
problema (Gerenciador de Tarefas > Desempenho, ou `nvidia-smi dmon`), a resolução, o
limitador de FPS e o V-Sync. Gargalo de GPU = GPU perto de 100% e CPU folgada;
gargalo de CPU = uma thread no teto e GPU abaixo; limitado por V-Sync ou por
limite de FPS = os dois folgados e FPS cravado em um número redondo.

**Temperatura:** o Windows não expõe de forma confiável. Pedir a leitura de um
programa de monitoramento (HWiNFO, HWMonitor, MSI Afterburner) **com o problema
acontecendo**, não parado.

**Integridade do sistema (leva minutos; dizer antes):**

```powershell
DISM /Online /Cleanup-Image /CheckHealth
sfc /verifyonly
```

`/CheckHealth` e `/verifyonly` só verificam, não mudam nada. O reparo
(`sfc /scannow`, `DISM /RestoreHealth`) é um passo à parte: explicar o que faz e
pedir o ok.

## 3. Interpretar

Separar em três listas, sem misturar:

- **Confirmado**: o que a medição mostrou.
- **Inferência**: o que decorre disso, com o raciocínio.
- **Suspeita**: o que ainda não foi testado, e qual medição decidiria.

Se a evidência contradiz a hipótese de partida, **a hipótese cai**: não defender
"o normal esperado" contra o dado da pessoa.

## 4. Soluções, da mais segura para a mais invasiva

1. Reversíveis e sem risco: fechar o que consome, desligar item de inicialização,
   liberar espaço, atualizar ou reverter o driver, trocar um cabo, reiniciar o
   serviço.
2. Configuração do Windows ou do programa (plano de energia, taxa de atualização,
   limite de FPS), dizendo o valor de antes para poder voltar.
3. Reparo do sistema (`sfc /scannow`, `DISM /RestoreHealth`, `chkdsk` sem `/f` para
   só ler), com o efeito explicado antes.
4. Trocar peça ou reinstalar o Windows: **última opção**, e nunca a primeira
   resposta. Formatar não é solução genérica.

Antes de qualquer comando que **mude** algo no sistema, dizer em uma frase o que
ele afeta e pedir o ok. **Não mexer em configuração de segurança** (Defender, UAC,
firewall, Smart App Control, política de execução): se for o caso, explicar e deixar
a pessoa fazer.

## 5. Verificar depois

Repetir a mesma medição do passo 2 e comparar. "Parece melhor" não conta: números
antes e depois, ou o sintoma reproduzido de novo sem aparecer. Se não deu para medir
de novo, dizer que não foi verificado.

## Relatar

```
Sintoma: <como a pessoa descreveu>
Medi: <o que, e o resultado>
Conclusão: <causa provável> (confirmado / inferência / suspeita)
Fiz / sugiro: <em ordem, do mais seguro ao mais invasivo>
Depois: <a medição repetida, ou "não verificado">
```
