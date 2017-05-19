Import-Module -Name $PSScriptRoot\Functions-Get.psm1


# Create new folder
Function New-Folder($Path) {
    If ((Test-Path $Path) -eq $False) {
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
    #} Else {
    #    Write-Host "Folder $Path does still not exists"
    #}
}


# Create AD User from csvimport
Function New-CsvADUsers($CsvFilePath = "C:\newuserstoad.txt") {
    $Users = Import-Csv -Delimiter "," -Path $CsvFilePath
    ForEach ($User in $Users) {
        $ADServer = $domainController
        $FN3chars = $User.Firstname.Substring(0,3)
        $LN3chars = $User.Lastname -replace ".{3}$"
        $SAM =  ($FN3chars + $LN3chars).ToLower()
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
            If ((Test-Path "C:\Logs") -eq $False) {
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
            Break
        }

        # Create @var $UserInitials
        $User.Firstname.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Othernames.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Lastname.split(' ') | ForEach {$UserInitials += $_[0]}
        
        Write-Host 'DEBUG OUTPUT BEFORE NEW-ADUSER COMMAND IS EXECUTED'
        Write-Host $User
        Write-Host 'OTHER INPUTS FOR NEW-ADUSER'
        Write-Host "UserDisplayname=" + $UserDisplayname `
            + "; SAM=" + $SAM `
            + "; UserInitials=" + $UserInitials `
            + "; server=" + $domainController
        
        New-ADUser `
            -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $True `
            -City $User.City `
            -Company $User.Company `
            -Country $User.Country `
            -Department $User.Department `
            -Description $User.Description `
            -DisplayName $UserDisplayname `
            -Division $User.Division `
            -EmployeeNumber $User.EmployeeNumber `
            -Enabled $true `
            -GivenName $User.Firstname `
            -Initials $UserInitials `
            #-Manager $User.Manager `
            -Name $UserDisplayname `
            -OfficePhone $User.OfficePhone `
            -OtherName $User.Othernames `
            -PasswordNeverExpires $true `
            #-Path $User.OU `
            -PostalCode $User.PostalCode `
            -SamAccountName $SAM `
            -Server $domainController `
            -State $User.State `
            -StreetAddress $User.StreetAddress `
            -Surname $User.Lastname `
            -Title $User.Title `
            -UserPrincipalName $SAM
    }
}
