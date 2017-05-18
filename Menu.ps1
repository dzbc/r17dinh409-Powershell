. "$PSScriptRoot\Functions.ps1"

Remove-Module cliMenu -ErrorAction SilentlyContinue; Import-Module .\cliMenu-master-c4e266e\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "Show something to me" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "get_bios_params()"
    DisplayName = "Show Local Machine info"
    Action = { get_bios_params }
    DisableConfirm = $true
}

$newItem3 = @{
    Name = "StartStoppedServices"
    DisplayName = "Start Stopped Services (Default is to start stopped services set to 'autostart')"
    Action = { start_stopped_services }
    DisableConfirm = $true
}

<#
$newItemX = @{ #Array to store menu point in
    Name = "ExampleName" #Some name WIHTOUT spaces
    DisplayName = "Example ultra short line!" #Line to be displayed
    Action = { ExampleFunction($args) } #Call cmdlet/function
    DisableConfirm = $true #OPTIONAL. Only include to avoid confirm dialog after choosing menu entry
#>

$newMenu = @{
    Name = "Main"
    DisplayName = "Main Menu"
}

# Create a new menu (first menu will become the main menu)
$mainMenu = New-Menu @newMenu

# Add menu ITEMS to the menu named 'main'
New-MenuItem @newItem1 | Add-MenuItem -Menu main
New-MenuItem @newItem3 | Add-MenuItem -Menu main

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
