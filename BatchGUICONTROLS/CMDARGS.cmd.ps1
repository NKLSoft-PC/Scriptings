$user = Read-Host user
$pass = Read-Host pass
$servername=$user
$envname=$pass
write-host "If this script were really going to do something, it would do it on $servername in the $envname environment" 
pause