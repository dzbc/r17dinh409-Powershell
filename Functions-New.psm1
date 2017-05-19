Param(
    $computerName = $env:COMPUTERNAME,
    $computerLogFolder = "C:\Logs"
)


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
}


# Create AD User from csvimport
Function New-CsvADUsers($CsvFilePath = "C:\newuserstoad.txt") {
    $Users = Import-Csv -Delimiter "," -Path $CsvFilePath
    ForEach ($User in $Users) {
        $ADServer = $DomainController
        $FN3chars = $User.Firstname.Substring(0,3)
        $LN3chars = $User.Lastname.Substring(($User.Lastname.Length)-3,3)
        $SAM =  ($FN3chars + $LN3chars).ToLower()
        $UserDisplayName = $User.Firstname + " " + $User.Othernames `
            + " " + $User.Lastname
        $UPN = $SAM + "@" + $User.Maildomain
        
        # Create var $UserInitials
        $UserInitials = '' #define empty $var
        $User.Firstname.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Othernames.split(' ') | ForEach {$UserInitials += $_[0]}
        $User.Lastname.split(' ') | ForEach {$UserInitials += $_[0]}
        
        $DomainController = "DC-01.5.5.2017.test.netravnen.eu"
        $UserInitials = $UserInitials.ToUpper()
        
        Write-Host 'DEBUG OUTPUT BEFORE NEW-ADUSER COMMAND IS EXECUTED'
        Write-Host $User
        Write-Host 'OTHER INPUTS FOR NEW-ADUSER'
        Write-Host "UserDisplayName=" + $UserDisplayName `
            + "; SAM=" + $SAM `
            + "; UserInitials=" + $UserInitials `
            + "; server=" + $DomainController
        
        $NewAdUserProperties = @{
            AccountPassword       = (ConvertTo-SecureString $User.Password -AsPlainText -Force)
            ChangePasswordAtLogon = $True
            City                  = $User.City
            Company               = $User.Company
            Country               = $User.Country
            Department            = $User.Department
            Description           = $User.Description
            DisplayName           = "$UserDisplayName"
            Division              = $User.Division
            EmployeeNumber        = $User.EmployeeNumber
            Enabled               = $True
            GivenName             = $User.Firstname
            Initials              = $UserInitials
           #Manager               = $User.Manager
            Name                  = "$UserDisplayName"
            OfficePhone           = $User.OfficePhone
            OtherName             = $User.Othernames
            PasswordNeverExpires  = $False
           #Path                  = $User.OU
            PostalCode            = $User.PostalCode
            SamAccountName        = $SAM
            Server                = $DomainController
            State                 = $User.State
            StreetAddress         = $User.StreetAddress
            Surname               = $User.Lastname
            Title                 = $User.Title
            UserPrincipalName     = $UPN
        }
        
        $success = $False
        $ErrorMessage = $Null

        Try {
            New-ADUser @NewAdUserProperties -ErrorAction Stop
            $success = $True
        } Catch {
            $sucess = $False
            $ErrorMessage = $_.Exception.Message
        }
        Finally
        {
            If ((Test-Path "C:\Logs") -eq $False) { New-Folder -Path "C:\Logs" }
            
            $Time = ((Get-Date -Format o).Split("{+}")[0]) -replace ".{4}$"
            
            "$Time - SUCCESS $success - ERROR $ErrorMessage - ACCOUNT $SAM $UserDisplayName - DC $DomainController" |
                out-file "$computerLogFolder\New-ADUser.log" -append
        }
    }
}
