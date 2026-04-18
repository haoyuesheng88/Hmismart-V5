# Variable Lookup

Use this reference when the user asks for a tag address, register, or connection from the live WinCC SMART editor.

## Preferred flow

1. Run `inspect-wincc-smart-session.ps1 -Capture`.
2. If the editor is not visible, move it onscreen and capture again.
3. Open the tag editor or HMI variable grid in the live project tree.
4. Find the target variable row by exact name.
5. Read the address cell first.
6. Use the lower properties pane to confirm data type, connection, or length if needed.

## What to report

- Variable name
- Address or register such as `VW 492`, `VD 550`, `M 10.0`, `Q 0.1`
- Data type when visible
- Connection when visible

## Verified example

In a verified live session for project `小闭路-20220826.hmismart`, the visible row showed:

- `TZ通针 -> VW 492`
- `数据类型 = Word`
- `连接 = 连接_1`
- `长度 = 2`

Treat examples like this as format guidance, not as a replacement for checking the current visible editor state.
