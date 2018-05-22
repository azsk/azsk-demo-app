############################################################################
<#
    PowerShell 101 Agenda
    1. Editors
    2. Basics to get started
       a. First script "Hello World"        
       b. Examples
       c. Can i use C# langauage in PS?
    3. Commands /Get-Help
    4. Exercises 
       a. Print first 'n' fibonacii series 
       b. Print all the files in system32 folder having size greater than 10MB
    5. Classes in PS
-------------------------------------------------------------------------------
    1. Editors
        > Console VS ISE
        > How to execute the scripts
    2. Variables/ types / Arrays/ Hashtables / loop variables/ Core functions like Write-Host and Read-Host
#>

#4. First  script hello world
#can i use the variable directly?
$name = Read-Host "Enter you name";
Write-Host "Hi $Name!! Welcome to PowerShell 101 session!!" -ForegroundColor Cyan

1..10 | Write-Host 

[int] $counter = 0
1..10 | ForEach-Object{$counter += $_}
Write-Host $counter

#comparision operators
$counter =0
for ($i = 1; $i -le 10; $i++)
{ 
  $counter += $i  
}
Write-Host $counter
#similarly you can also use while/ do-while loops

Write-Host [System.DateTime]::UtcNow
Write-Host $([System.DateTime]::UtcNow)
Write-Host "Current datetime: $([System.DateTime]::UtcNow)"

#Array example
$evenArray = @()
1..10 | ForEach-Object {
    if($_ % 2 -eq 0)
    {
        $evenArray += $_
    }
}
$evenArray

#Hashtable example
$evenOddHashTable = @{}
$evenArray = @()
$oddArray = @()
1..10 | ForEach-Object {
    if(-not($_ % 2 -eq 0))
    {
        $oddArray += $_;
    }
    else
    {
        $evenArray += $_;
    }
}
$evenOddHashTable.Add("Even",$evenArray);
$evenOddHashTable.Add("Odd",$oddArray);
$evenOddHashTable


#Get commands
Get-Command "Write-Host"
Get-Command *AzureRM*

#Different ways of calling a command and understanding the object structure
Get-ChildItem -Path "$env:ProgramFiles\WindowsPowerShell" -Filter "*.psd1" -Recurse -File
gci "$env:ProgramFiles\WindowsPowerShell" "*.psd1" -rec -af
$files = gci "$env:ProgramFiles\WindowsPowerShell" "*.psd1" -rec -af
$files[0]
$files[0] | FL *
$files[0].FullName

#Exercise 1: Print first 'n' number of Fibonacii series
#################
##Spoiler space##
#################
#Exercise 2: Print unique system process names

class Shape
{
    [string] $Name;
}

class Circle : Shape
{
    hidden [void] Display([string] $prefix)
    {
        $this.Name = "Circle";
        Write-Host "I am $prefix$($this.Name)";
    }

    [void] Display()
    {
        $this.Display("");
        $this.Display("Semi-");
    }
}

[Circle] $c = [Circle]::new();
$c.Display()



