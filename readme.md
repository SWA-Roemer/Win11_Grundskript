# Windows 11 Grundskript

Ein Satz von PowerShell-Skripten und Konfigurationsdateien, um Windows-Installationen konsequent auf einen bestimmten Stand zu bringen. Es entfernt außerdem unerwünschte vorinstallierte Windows 11 Services.

## 🛠 Anwendung
1. Lade die letzte Version unter https://github.com/SWA-Roemer/Win11_Grundskript/releases herunter
2. Entpacke die ZIP in einen Ordner
3. Führe die `execute_grundskript.bat` als Administrator aus!

## 📂 Erklärung des Skriptes
Das Skript ist in Module unterteilt, welcher nacheinander ausgeführt werden:
```sh
├─── apps_m365.txt [App Liste der M365 Apps, kann optional dazugeladen werden]
├─── apps_standard.txt [App Liste der Bloatware von Windows]
├─── execute_grundskript.bat [Datei um dieses Skript auszuführen]
├─── version.txt [Die aktuelle lokale Version, für den Updater]
├─── windows_grundskript.ps1 [Die Hauptdatei inkl. Updater]
└─── modules
     ├─── 00_config_file.ps1 [Auswahl der Apps Datei (Mit/Ohne M365)]
     ├─── 01_outlook_removal.ps1 [Entfernt das neue Outlook]
     ├─── 02_outlook_registry.ps1 [Verhindert neuinstallation von Outlook]
     ├─── 03_app_removal.ps1 [Entfernt die in 00 definierten Apps]
     ├─── 04_energy_options.ps1 [Setzt Energieoptionen]
     ├─── 05_win_features.ps1 [Aktiviert .NET 3.5 und TCP/IP]
     ├─── 06_firewall_rdp.ps1 [Aktiviert Firewall Regeln für RDP]
     ├─── 07_rdp.ps1 [Aktiviert RDP]
     ├─── 08_explorer.ps1 [Aktiviert Dateiendungen]
     ├─── 09_disconnect.ps1 [Setzt autodisconnect auf -1]
     ├─── 10_numlock.ps1 [Aktiviert Numlock beim start]
     ├─── 11_telemetry.ps1 [Deaktiviert telemetrie]
     ├─── 12_bing_search.ps1 [Deaktiviert Bing Suche im Startmenü]
     └─── 13_lockscreen.ps1 [Deaktiviert Werbung im Lockscreen]
```

---

## ⚠️ Sicherheitshinweis

Die Verwendung erfolgt auf eigene Gefahr. Das Entfernen von System-Apps kann in seltenen Fällen zu unerwartetem Verhalten führen. Es wird empfohlen, vor der Ausführung einen Systemwiederherstellungspunkt zu erstellen.
