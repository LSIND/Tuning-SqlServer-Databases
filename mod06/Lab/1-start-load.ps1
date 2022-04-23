# generate database load by starting a number of workers running the same SQL script

param 
(
    $scriptPath = "1-start-load-sql.sql",
    $workerCount = 10,
    $sqlServerName = "localhost",
    $sqlDatabaseName = "master"
)

$execScript = {
    param( $sqlServerName, $sqlDatabaseName, $scriptPath  )
    & SQLCMD -E -S $sqlServerName -d $sqlDatabaseName -i $scriptPath > $null
}
$sw = [diagnostics.stopwatch]::StartNew()

(1..$workerCount) | % {
    Start-Job $execScript -ArgumentList $sqlServerName, $sqlDatabaseName, $scriptPath
}

Write-Host -NoNewline "Load running."

while ( @(gjb | Select-Object -ExpandProperty State -Unique) -contains "Running" ){
    Start-Sleep -seconds 2
    Write-Host -NoNewline "."
}
Write-Host "`nFinished after " $sw.Elapsed

Pause