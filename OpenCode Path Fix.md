# Opencode Not Recognized in PowerShell — Troubleshooting Log

## The Error

```
PS E:\Personal Website> opencode --port 18561

opencode : The term 'opencode' is not recognized as the name of a cmdlet, function,
script file, or operable program.
```

Happened when opening a PowerShell terminal inside a project folder. The command seemed
to work in other terminal sessions.

---

## Root Cause

`opencode-ai` is installed globally via npm, but the npm global bin folder
(`C:\Users\Cikal Merdeka\AppData\Roaming\npm`) was not in the PATH for that PowerShell
session. Additionally, the binary is not an `.exe` but a `.cmd` file, so `where.exe
opencode` couldn't find it either.

---

## Diagnosis Steps

### 1. Confirm opencode is missing from PATH
```powershell
where.exe opencode
# Output: INFO: Could not find files for the given pattern(s).
```

### 2. Confirm it is actually installed via npm
```powershell
npm list -g --depth=0
# Output:
# C:\Users\Cikal Merdeka\AppData\Roaming\npm
# ├── @anthropic-ai/claude-code@2.0.76
# ├── flowise@1.6.0
# ├── opencode-ai@1.4.0   ← installed!
# └── typescript@5.9.2
```

### 3. Locate the actual binary
```powershell
dir "C:\Users\Cikal Merdeka\AppData\Roaming\npm\opencode*"
# Finds: opencode.cmd  (not opencode.exe — that's why where.exe failed)
```

---

## Fix

### Quick fix — run it directly with full path
```powershell
& "C:\Users\Cikal Merdeka\AppData\Roaming\npm\opencode.cmd" --port 18561
```

### Permanent fix — add npm global bin to PowerShell profile PATH
```powershell
Add-Content $PROFILE "`n`$env:PATH += `";C:\Users\Cikal Merdeka\AppData\Roaming\npm`""
```

Restart the terminal, then `opencode --port 18561` should work normally from any folder.

---

## Key Takeaways

- `where.exe opencode` returning nothing does **not** mean opencode is uninstalled —
  it may just be a `.cmd` file that `where.exe` misses.
- Always check `npm list -g --depth=0` first to confirm global installs.
- The npm global bin path for this machine is:
  `C:\Users\Cikal Merdeka\AppData\Roaming\npm`
- If a command works in one terminal but not another, it's almost always a PATH issue
  scoped to that session — not a missing install.
