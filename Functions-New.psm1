Import-Module -Name .\Functions-Get.psm1


# Create new folder
function New-Folder($Path) {
    If (!(Test-Path $Path)) {
        #Write-Host "Folder $Path does not exists. Creating folder"
        
        # delimter character used when splitting folder paths
        $DelimterChar = '\'
        
        # remove trailing slash if one is detected
        If ($Path.Length -eq $Path.LastIndexOf($DelimterChar)+1) {
            $Path = $Path.TrimEnd($DelimterChar)
        }
        
        # $FolderPath is the path to the folder WIHTOUT the name of
        # the folder included in the string
        $FolderPath = $Path.Substring(0,$Path.LastIndexOf($DelimterChar)+1)
        
        # $FolderName is the folders name WITHOUT the path to the folder
        $FolderName = $Path.Substring($Path.LastIndexOf($DelimterChar)+1, `
            $Path.Length-$Path.LastIndexOf($DelimterChar)-1)
        
        New-Item -Path $FolderPath -Name $FolderName -ItemType "directory"
    }

    #If (Test-Path $Path) {
    #    Write-Host "Folder $Path has now been created"
    #} else {
    #    Write-Host "Folder $Path does still not exists"
    #}
}


# Create AD User from csvimport
function New-CsvADUsers($CsvFilePath = "C:\newuserstoad.txt") {
    $Users = Import-Csv -Delimiter "," -Path $CsvFilePath
    ForEach ($User in $Users) {
        $ADServer = $domainController
        $SAM = $User.Firstname.Substring(0,3) + ($User.Lastname -replace ".{3}$")
        $UserDisplayname = $User.Firstname + " " + $User.Othernames `
            + " " + $User.Lastname
        $UPN = $SAM + "." `
            <#+ (Get-Date -UFormat "T%H%M%S")#> `
            + "@" `
            + $User.Maildomain
        
        Try {
            Get-ADUser -Identity $SAM -ErrorAction Stop
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning -Message 'Account not found'
        }
        Finally
        {
            If ((Get-DoesFolderExist -Path "C:\Logs") -eq $False) {
                New-Folder -Path "C:\Logs"
            }
            $Time = ((Get-Date -Format o).Split("{+}")[0]) -replace ".{4}$"
            "This script made a read attempt at $Time" |
                out-file "$computerLogFolder\New-ADUser.log" -append
        }
        
        # Maximum length of SAM is 20 characters.
        If ($SAM.length -gt 20) {
            # Log a message telling the $User creation failed
            <#
            --> log error code to system log or custom log file here
            #>
            
            # Stop creating current $User
            break
        }

        # Create @var $UserInitials
        $User.Firstname.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Othernames.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Lastname.split(' ') | ForEach {$UserInitials += $_[0]}
        
        Write-Host "\n\n" + 'DEBUG OUTPUT BEFORE NEW-ADUSER COMMAND IS EXECUTED' + "\n" + $User "\n\n"
        
        New-ADUser `
            -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $false `
            -City $User.City `
            -Company $User.Company `
            -Country $User.Country `
            -Department $User.Department `
            -Description $User.Description `
            -DisplayName "$UserDisplayname" `
            -Division $User.Division `
            -EmployeeNumber $User.EmployeeNumber `
            -Enabled $true `
            -GivenName $User.Firstname `
            -Intials $UserInitials `
            -Manager $User.Manager `
            -Name "$UserDisplayname" `
            -OfficePhone $User.OfficePhone `
            -OtherName $User.Othernames
            -Path $User.OU `
            -PostalCode $User.PostalCode `
            -SamAccountName $SAM `
            -State $User.State
            -StreetAddress $User.StreetAddress `
            -Surname $User.Lastname `
            -Title $User.Title `
            -UserPrincipalName $SAM `
            -server domain.loc `
            -PasswordNeverExpires $true
    }
}
