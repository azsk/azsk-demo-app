$i = 1 
$j = 1
$n = Read-Host "Enter the number"
if($n -eq 1) 
{
    Write-Host $i;    
}
elseif($n -eq 2)
{
     Write-Host $i; 
     Write-Host $j; 
}
else
{
    Write-Host $i; 
    Write-Host $j; 
    for ($k = 2; $k -lt $n; $k++)
    { 
        $x = $i + $j
        Write-Host $x
        $i = $j
        $j = $x
    }
}

#######################################################################################################

function GetFibonacciMaster([int] $n)
{
    GetFibonaaci -a 1 -b 1 -counter 1 -n $n
}

function GetFibonaaci([int] $a, [int] $b, [int] $counter, [int] $n)
{
    if($counter -le $n){
        Write-Host $a.ToString();
        GetFibonaaci -a $b -b ($a + $b) -counter ($counter + 1) -n $n;
    }
}
$n = Read-Host "Enter the number"
GetFibonacciMaster($n)

#######################################################################################################


$uniqueProcess = @()

$processes = Get-Process 
foreach($process in $processes)
{
    $processName = $process.ProcessName
    if(-not $uniqueProcess.Contains($processName))
    {
        $uniqueProcess+= $processName;
    }
}
$uniqueProcess 

Get-Process | Select ProcessName -Unique