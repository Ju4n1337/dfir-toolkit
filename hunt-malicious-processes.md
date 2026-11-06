# Hunt Malicious Processes

## 1. Process Enumeration

1. **List processes**

   ```powershell
   Get-Process (name of process)
   ```

2. **List processes with Path, Name & PID**

   ```powershell
   Get-Process (name of process) | Select-Object -Property Path, Name, Id
   ```

3. **If we know the directory of the malicious process, filter with `Where-Object`**

   ```powershell
   Get-Process (name of process) | Select-Object -Property Path, Name, Id | Where-Object -Property Path -Like "*temp*"
   ```

   > In this case, the filter targets the `temp` directory.

4. **Find the path of the malicious process by PID**

   ```powershell
   Get-Process | Select-Object -Property Path, Name, Id | Where-Object -Property Id -eq (malicious ID)
   ```

---

## 2. Network Enumeration

1. **List network connections**

   ```powershell
   Get-NetTCPConnection
   ```

2. **Local address, port, state & owning process**

   ```powershell
   Get-NetTCPConnection | Select-Object -Property LocalAddress, LocalPort, State, OwningProcess
   ```

---

## 3. Registry Enumeration

1. **List content of HKLM**

   ```powershell
   Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
   Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
   ```

2. **List content of HKCU**

   ```powershell
   Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
   Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
   ```

---

## 4. Scheduled Task Enumeration

1. **List scheduled tasks**

   ```powershell
   Get-ScheduledTask
   ```

2. **Examine the contents of a task**

   ```powershell
   Export-ScheduledTask -TaskName "MaliciousTask"
   ```

   > This outputs an XML file for analysis.

---

## 5. Remediation Process

1. **Stop the malicious process**

   ```powershell
   Get-Process | Select-Object -Property Path, Name, Id | Where-Object -Property Id -eq (malicious ID) | Stop-Process
   ```

2. **Remove the ASEP (Auto Start Extensibility Point)**

   ```powershell
   Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name (Malicious Program)
   ```

   Validate again with the next command:

   ```powershell
   Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\(Malicious Program)"
   ```

3. **Remove the program**

   ```powershell
   Remove-Item "$env:temp\malicious.exe"
   ```

   Validate again with the next command:

   ```powershell
   Get-ChildItem "$env:temp\malicious.exe"
   ```

4. **Delete the service**

   ```powershell
   sc.exe delete malicious
   ```

5. **Delete the scheduled task**

   ```powershell
   Unregister-ScheduledTask -TaskName "malicious_task"
   ```

6. **Delete added local users**

   ```powershell
   Remove-LocalUser -Name attacker
   ```

---

## 6. Differential Analysis

### 6.1 Create a baseline

1. **Services**

   ```powershell
   Get-Service | Select-Object -ExpandProperty Name | Out-File "baseline_services.txt"
   ```

2. **Scheduled tasks**

   ```powershell
   Get-ScheduledTask | Select-Object -ExpandProperty TaskName | Out-File "baseline_schtask.txt"
   ```

3. **Local users**

   ```powershell
   Get-LocalUser | Select-Object -ExpandProperty Name | Out-File "baseline_users.txt"
   ```

### 6.2 Capture the current state

1. **Services**

   ```powershell
   Get-Service | Select-Object -ExpandProperty Name | Out-File "now_services.txt"
   ```

2. **Scheduled tasks**

   ```powershell
   Get-ScheduledTask | Select-Object -ExpandProperty TaskName | Out-File "now_schtask.txt"
   ```

3. **Local users**

   ```powershell
   Get-LocalUser | Select-Object -ExpandProperty Name | Out-File "now_users.txt"
   ```

### 6.3 Create variables & compare

1. **Services**

   ```powershell
   $servicenow = Get-Content .\now_services.txt
   $servicebaseline = Get-Content .\baseline_services.txt
   Compare-Object $servicebaseline $servicenow
   ```

2. **Scheduled tasks**

   ```powershell
   $tasknow = Get-Content .\now_schtask.txt
   $taskbaseline = Get-Content .\baseline_schtask.txt
   Compare-Object $taskbaseline $tasknow
   ```

3. **Local users**

   ```powershell
   $usersnow = Get-Content .\now_users.txt
   $usersbaseline = Get-Content .\baseline_users.txt
   Compare-Object $usersbaseline $usersnow
   ```
