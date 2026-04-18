---
name: wincc-flexible-smart-v5
description: Attach to an already-open Siemens WinCC flexible SMART V5 editor on Windows, bring the HmiES window onscreen, inspect the active hmismart project session, capture the live editor window, and help locate HMI tag addresses or registers such as VW, VD, VB, M, I, and Q from the visible variable grid or properties pane. Use when the user says WinCC flexible SMART V5 is installed/open and asks to connect to the app, inspect the current hmismart project, query a variable address like "TZ通针", or form an input/output closed loop against the live editor instead of an offline copy.
---

# WinCC flexible SMART V5

Use this skill when WinCC flexible SMART V5 is already open on Windows and the task depends on the live editor state.

Prefer the currently open `HmiES.exe` session over unopened backup files. This skill is especially useful when the editor window is on a disconnected monitor, hidden behind other apps, or the user wants the address currently shown in the tag grid.

## Quick Start

1. Run [scripts/inspect-wincc-smart-session.ps1](./scripts/inspect-wincc-smart-session.ps1) with `-Capture` to locate the active `HmiES.exe` process, move it onscreen if needed, and capture the current editor window.
2. View the screenshot and confirm the visible project title, open editor tab, and whether the tag grid or properties pane already shows the requested variable.
3. If the tag grid is not visible, navigate the live project tree to the HMI variable area first, then capture again.
4. Read the variable row and the lower properties pane from the screenshot. Treat the visible address cell as the source of truth.
5. Report the exact register or address with any visible data type and connection name.

## Stable Workflow

For most requests, use this order:

1. `inspect-wincc-smart-session.ps1 -Capture`
2. If needed, `move-wincc-smart-window.ps1`
3. If needed, `capture-wincc-smart-window.ps1`
4. Read focused references only when needed:
   - variable lookup flow: [references/variable-lookup.md](./references/variable-lookup.md)
   - cache and layout clues: [references/cache-layout.md](./references/cache-layout.md)

## Rules

- Treat the live WinCC editor as the source of truth when the user asks for the current project state.
- Prefer the visible tag row and lower properties pane over inference from backup `.hmismart` files.
- If the window is offscreen, move it back before trying to read anything.
- If the requested variable is not visible, say that it is not visible yet and continue by opening the relevant tag editor rather than guessing.
- Quote the exact variable name and address shown in the UI, for example `TZ通针 -> VW 492`.
- Mention when the answer came from the visible grid, the properties pane, or a cached layout clue.

## PowerShell Helpers

Inspect the live session and capture a screenshot:

```powershell
& ".\skills\wincc-flexible-smart-v5\scripts\inspect-wincc-smart-session.ps1" -Capture
```

List visible WinCC SMART editor processes:

```powershell
& ".\skills\wincc-flexible-smart-v5\scripts\find-open-wincc-smart-process.ps1"
```

Move the active editor window back to the primary screen:

```powershell
& ".\skills\wincc-flexible-smart-v5\scripts\move-wincc-smart-window.ps1"
```

Capture the current editor window to a PNG:

```powershell
& ".\skills\wincc-flexible-smart-v5\scripts\capture-wincc-smart-window.ps1"
```

## Deliverable

Return:

- the variable name
- the exact visible address or register
- the visible data type when shown
- the connection name when shown
- a brief note about where the value was read from
