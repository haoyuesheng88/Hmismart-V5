# Hmismart-V5

This repository packages the `wincc-flexible-smart-v5` Codex skill in a portable layout.

## Install on another computer

Run:

```powershell
.\install-skill.ps1
```

This copies `skills\wincc-flexible-smart-v5` into the local Codex skills directory.

## Typical use

After installation, prompt Codex with requests such as:

- `WinCC flexible SMART V5 已经打开，请连接到该软件并查询变量 TZ通针 的寄存器地址`
- `连接到当前打开的 hmismart 工程，截图并检查变量表`
- `把 WinCC flexible SMART V5 窗口移回主屏并读取当前可见变量地址`
