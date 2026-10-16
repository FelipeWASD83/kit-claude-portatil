# agendar-backup-local.ps1 - cria (ou remove) a tarefa do Agendador de Tarefas do
# Windows que roda o backup-local.ps1 sozinho, de hora em hora e ao entrar no
# Windows. Sem ela, o espelho so fica em dia quando alguem lembra.
#
# COMO USAR, no PowerShell, na raiz da pasta de trabalho:
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\agendar-backup-local.ps1"
#     powershell -ExecutionPolicy Bypass -File ".\_organizacao\agendar-backup-local.ps1" -Remover
#
# POR QUE DE HORA EM HORA: esta tarefa e rede de seguranca, e comparar muitos
# arquivos varias vezes por hora e desgaste sem ganho. O backup do fim de cada
# tarefa continua valendo - esta so cobre o que acontece longe do Claude Code.
#
# A tarefa roda com o usuario atual, so com ele logado, sem senha nem
# administrador, e sem janela nenhuma (conhost --headless, ver abaixo).
#
# DESTINO DESCONECTADO NAO E PROBLEMA: o backup-local.ps1 sai com codigo 2 sem
# copiar nada. A tarefa marca "ultima execucao 0x2" e pronto, sem alarme.
#
# Criar de novo so substitui a tarefa (-Force); nao duplica.

param([switch]$Remover)

$nome = 'Backup local da pasta de trabalho'

if ($Remover) {
    Unregister-ScheduledTask -TaskName $nome -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Tarefa '$nome' removida (se existia)."
    exit 0
}

$raiz   = Split-Path -Parent $PSScriptRoot
$script = Join-Path $PSScriptRoot 'backup-local.ps1'

if (-not (Test-Path $script)) {
    Write-Host "Nao achei o backup-local.ps1 em $PSScriptRoot." -ForegroundColor Red
    exit 1
}

# conhost.exe --headless e o que impede a janela: com o Windows Terminal como
# terminal padrao, um powershell.exe lancado direto pelo Agendador abre uma janela
# do Terminal mesmo com -WindowStyle Hidden, que so esconde depois que ela ja nasceu.
$argumentos = '--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Silencioso' -f $script

$acao = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument $argumentos -WorkingDirectory $raiz

# Ao entrar no Windows (com 2 minutos de folga) e de hora em hora, pra sempre.
$gatilhos = @(
    (New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME),
    (New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) -RepetitionInterval (New-TimeSpan -Hours 1))
)
$gatilhos[0].Delay = 'PT2M'

$config = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 2)
$quem = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $gatilhos -Settings $config `
    -Principal $quem -Description 'Espelha a pasta de trabalho no destino do backup local (backup-local.ps1). Sai sem fazer nada quando o destino nao esta conectado.' `
    -Force | Out-Null

$t = Get-ScheduledTask -TaskName $nome
Write-Host "Tarefa '$nome' criada: $($t.State). Proxima rodada: $((Get-ScheduledTaskInfo -TaskName $nome).NextRunTime)"
Write-Host "O que aconteceu em cada rodada fica em _organizacao\.backup-local.log"
