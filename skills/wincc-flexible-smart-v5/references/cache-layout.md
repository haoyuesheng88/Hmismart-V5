# Cache Layout

Use this reference when troubleshooting the live session or when the editor window opens offscreen.

## Common local paths

- Installed editor executable:
  `C:\Program Files\Siemens\SIMATIC WinCC flexible\WinCC flexible SMART V5\HmiES.exe`
- User cache root:
  `%LOCALAPPDATA%\Siemens AG\SIMATIC WinCC flexible SMART V5\Caches`

## Useful files

- `CurrentLayoutAfterOpenProject.xml`
  Helps confirm which tool windows, commands, and layout elements were recently open.
- `ReadWrite\ProjectInfoPool.data`
  Binary project metadata cache. Treat as diagnostic only unless a deterministic parser is available.

## Useful command clues seen in layout XML

- `.Tag.HmiTag`
- `.Communication.HmiConnection`
- `DisplayTag`
- `FindTags`

These clues help confirm the tag editor exists in the current session, but they do not replace reading the visible grid.
