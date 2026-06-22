## Cara Install (Auto Setup)

Buka **PowerShell** (Wajib *Run as Administrator*). caranya win+r, ketik "powershell", terus shift+ctrl+alt+enter. lalu *copy-paste* perintah di bawah ini dan tekan Enter:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/rafaelatantya/scala-one-liner/main/setup-scala-env.ps1 | iex"
```

Tunggu prosesnya sampai selesai, dan VS Code akan otomatis terbuka dengan *environment* Scala yang sudah siap!
