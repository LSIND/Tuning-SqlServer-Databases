# generate database load by starting a number of workers running the same SQL script

param 
(
    [string]$scriptPath,
    $workerCount = 10,
    $sqlServerName = "localhost",
    $sqlDatabaseName = "master",
    $cwd = (Get-Location).Path
)
 
$scriptpath = ($cwd | Join-Path -ChildPath $scriptPath)

#Write-Host $scriptPath


$execScript = {
    param( $sqlServerName, $sqlDatabaseName, $scriptPath  )
    & SQLCMD -E -S $sqlServerName -d $sqlDatabaseName -i $scriptPath
}

for ($counter = 1; $counter -le $workerCount; $counter++ )
{
Start-Job $execScript -ArgumentList $sqlServerName, $sqlDatabaseName, $scriptPath
}


Write-Host -NoNewline "Load running."

while ( @(gjb | Select-Object -ExpandProperty State -Unique) -contains "Running" ){
    Start-Sleep -seconds 2
    Write-Host -NoNewline "."
}

#Write-Host "`nLoad ended"
#Pause