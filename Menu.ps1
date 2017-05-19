Import-Module -Name $PSScriptRoot\Functions-Get.psm1 -Function Get-NetIntIndex,Get-BiosParams
Import-Module -Name $PSScriptRoot\Functions-New.psm1 -Function New-CsvADUsers
#Import-Module -Name $PSScriptRoot\Functions-Set.psm1 -Function Set-StartStoppedServices


# Default module from https://github.com/torgro/cliMenu
Remove-Module cliMenu -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\cliMenu-master-c4e266e\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "Show something to me" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "GetBiosParams"
    DisplayName = "Show Local Machine info"
    Action = { Get-BiosParams }
    DisableConfirm = $true
}

$newItem3 = @{
    Name = "StartStoppedServices"
    DisplayName = "Start non-running auto-start services"
    Action = { Set-StartStoppedServices }
    DisableConfirm = $true
}

<#
$newItemX = @{ #Array to store menu point in
    Name = "ExampleName" #Some name WIHTOUT spaces
    DisplayName = "Example ultra short line!" #Line to be displayed
    Action = { ExampleFunction($args) } #Call cmdlet/function
    DisableConfirm = $true #OPTIONAL. Only include to avoid confirm dialog after choosing menu entry
#>

$newItem4 = @{
    Name = "AddUsersToADFromCsvFile"
    DisplayName = "Create AD Users from Csv file"
    Action = { New-CsvADUsers -CsvFilePath "C:\newuserstoad.txt" }
    DisableConfirm = $true
}

$newMenu = @{
    Name = "Main"
    DisplayName = "Main Menu"
}

# Create a new menu (first menu will become the main menu)
$mainMenu = New-Menu @newMenu

# Add menu ITEMS to the menu named 'main'
New-MenuItem @newItem1 | Add-MenuItem -Menu main
New-MenuItem @newItem3 | Add-MenuItem -Menu main
New-MenuItem @newItem4 | Add-MenuItem -Menu main

$newItem2 = @{
    Name = "GoToSub"
    DisplayName = "Go to submenu"
    Action = { Show-Menu -MenuName SubMenu }
}

# Add a menuitem to the main menu
$mainMenu | New-MenuItem @newItem2 -DisableConfirm

$newItemSubMenu = @{
    Name = "GoToMain"
    DisplayName = "Go to Main Menu"
    Action = { Show-Menu }
}

# Create a new menu (sub-menu) and add a menu-item to it
New-Menu -Name SubMenu -DisplayName "*** SubMenu1 ***" | New-MenuItem @newItemSubMenu -DisableConfirm

clear-host
Show-Menu
