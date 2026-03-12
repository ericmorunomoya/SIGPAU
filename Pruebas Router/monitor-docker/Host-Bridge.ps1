<#
.SYNOPSIS
    Host Bridge para Control de Failover desde Docker.
.DESCRIPTION
    Este script abre un servidor HTTP ligero en el puerto 9001 que escucha
    peticiones POST para lanzar máquinas de VirtualBox.
#>
$Port = 9001
$BackupVM = "Router- Servidor-Backup"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add("http://*:$Port/")
$Listener.Start()

Write-Host "--- Host Bridge Activo en el puerto $Port ---" -ForegroundColor Cyan
Write-Host "Escuchando peticiones de Docker..."

while ($Listener.IsListening) {
    $Context = $Listener.GetContext()
    $Request = $Context.Request
    $Response = $Context.Response

    Write-Host "$(Get-Date): Recibida peticion $($Request.HttpMethod) en $($Request.Url.PathAndQuery)"

    # Manejo de CORS
    $Response.AddHeader("Access-Control-Allow-Origin", "*")
    $Response.AddHeader("Access-Control-Allow-Methods", "POST, OPTIONS")
    $Response.AddHeader("Access-Control-Allow-Headers", "Content-Type")

    if ($Request.HttpMethod -eq "OPTIONS") {
        $Response.StatusCode = 200
        $Response.Close()
        continue
    }

    if ($Request.Url.PathAndQuery -eq "/start-backup" -and $Request.HttpMethod -eq "POST") {
        try {
            Write-Host "Iniciando $BackupVM..." -ForegroundColor Yellow
            & $VBoxPath startvm $BackupVM
            $Response.StatusCode = 200
            $Buffer = [System.Text.Encoding]::UTF8.GetBytes("OK")
            $Response.ContentLength64 = $Buffer.Length
            $Response.OutputStream.Write($Buffer, 0, $Buffer.Length)
        } catch {
            Write-Error "Error al iniciar VM: $($_.Exception.Message)"
            $Response.StatusCode = 500
        }
    } else {
        $Response.StatusCode = 404
    }

    $Response.Close()
}
