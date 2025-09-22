'pico-edit.bas
' Code by Chris Stoddard

FONT 1
CLS RGB(0, 0, 0)

CONST ROWS = 24
CONST COLS = 40

DIM myText$(ROWS)
FOR i = 1 TO ROWS
  myText$(i) = SPACE$(COLS)
NEXT i

' -- current file name and dirty flag --
DIM currentFile$ : currentFile$ = ""
DIM dirty% : dirty% = 0

' -- cursor & colours --
DIM cursorRow = 1
DIM cursorCol = 1

CONST FG = RGB(0, 255, 0)
CONST BG = RGB(0, 0, 0)
CONST CURSORFG = RGB(0, 0, 0)
CONST CURSORBG = RGB(0, 255, 0)
CONST SELFG = RGB(0, 0, 0)
CONST SELBG = RGB(0, 128, 255)   ' selection highlight

' -- selection state (line-based) --
DIM selectionActive% : selectionActive% = 0
DIM selecting% : selecting% = 0
DIM selStart% : selStart% = 0
DIM selEnd% : selEnd% = 0

' -- clipboard (line block) --
DIM clip$(ROWS)
DIM clipCount% : clipCount% = 0

' help text for footer (HELP is a keyword, so use help1$)
help1$ = "Ctrl+l:Help  Ctrl+o:Open  Ctrl+s:Save  Ctrl+n:New  Ctrl+i:Ins  Ctrl+d:Del  Sel: Ctrl+b/E  K/V/X  G"

DO
  ' --- draw text area ---
  FOR i = 1 TO ROWS
    inSel% = 0
    IF selectionActive% THEN
      s1% = selStart% : s2% = selEnd% : NormalizeSel s1%, s2%
      IF i >= s1% AND i <= s2% THEN inSel% = 1
    ENDIF

    FOR j = 1 TO COLS
      x = (j - 1) * 8
      y = (i - 1) * 12
      char$ = MID$(myText$(i), j, 1)

      IF i = cursorRow AND j = cursorCol THEN
        TEXT x, y, char$, l, 1, 1, CURSORFG, CURSORBG
      ELSEIF inSel% THEN
        TEXT x, y, char$, l, 1, 1, SELFG, SELBG
      ELSE
        TEXT x, y, char$, l, 1, 1, FG, BG
      END IF
    NEXT j
  NEXT i

  ' --- help and status lines (rows 25 & 26) ---
  TEXT 0, (24 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (25 * 12), SPACE$(COLS), l, 1, 1, FG, BG

  TEXT 0, (24 * 12), LEFT$(help1$ + SPACE$(COLS), COLS), l, 1, 1, FG, BG

  fname$ = currentFile$
  IF fname$ = "" THEN fname$ = "(untitled)"
  dirtyMark$ = ""
  IF dirty% THEN dirtyMark$ = " *"

  r$ = RIGHT$("  " + LTRIM$(STR$(cursorRow)), 2)
  c$ = RIGHT$("  " + LTRIM$(STR$(cursorCol)), 2)
  status$ = "Row:" + r$ + " Col:" + c$ + "  " + fname$ + dirtyMark$ + "  Esc/Ctrl+Q:Quit"

  TEXT 0, (25 * 12), LEFT$(status$ + SPACE$(COLS), COLS), l, 1, 1, FG, BG

  ' --- key handling ---
  k$ = INKEY$
  IF k$ <> "" THEN
    SELECT CASE ASC(k$)

      CASE 27, 17   ' ESC or Ctrl+Q
        END

      CASE 12       ' Ctrl+L : Help
        ShowHelpScreen

      CASE 14       ' Ctrl+N : New (confirm if dirty)
        IF dirty% THEN
          IF ConfirmYesNo("Discard unsaved changes? (Y/Enter=Yes, N/Esc=No)") = 0 THEN
            ' canceled
          ELSE
            GOSUB DoNew
          ENDIF
        ELSE
          GOSUB DoNew
        ENDIF

      CASE 19       ' Ctrl+S : Save
        IF currentFile$ = "" THEN
          PromptFilenameInteractive "Save as", "", tmp$
          IF tmp$ <> "" THEN currentFile$ = tmp$
        ENDIF
        IF currentFile$ <> "" THEN
          SaveFile currentFile$
          dirty% = 0
          FlashMessage "Saved to " + currentFile$
        ELSE
          FlashMessage "Save canceled"
        ENDIF

      CASE 15       ' Ctrl+O : Open
        IF dirty% THEN
          IF ConfirmYesNo("Discard unsaved changes to open? (Y/Enter=Yes, N/Esc=No)") = 0 THEN
            ' canceled
          ELSE
            GOSUB DoOpen
          ENDIF
        ELSE
          GOSUB DoOpen
        ENDIF

      CASE 2        ' Ctrl+B : begin/extend selection
        IF selectionActive% = 0 THEN
          selectionActive% = 1 : selecting% = 1
          selStart% = cursorRow : selEnd% = cursorRow
        ELSE
          selecting% = 1
          selEnd% = cursorRow
        ENDIF

      CASE 5        ' Ctrl+E : finish selection
        IF selectionActive% THEN
          selEnd% = cursorRow
          selecting% = 0
        ENDIF

      CASE 7        ' Ctrl+G : clear selection
        ClearSelection

      CASE 11       ' Ctrl+K : copy selection (or line)
        CopySelectionOrLine

      CASE 24       ' Ctrl+X : cut selection (or line)
        CutSelectionOrLine
        dirty% = 1

      CASE 22       ' Ctrl+V : paste clipboard
        IF clipCount% > 0 THEN
          InsertLinesAt cursorRow, clipCount%
          FOR ii% = 1 TO clipCount%
            myText$(cursorRow + ii% - 1) = LEFT$(clip$(ii%) + SPACE$(COLS), COLS)
          NEXT ii%
          dirty% = 1
        ELSE
          FlashMessage "Clipboard empty"
        ENDIF

      CASE 8        ' Backspace
        IF cursorCol > 1 THEN
          MID$(myText$(cursorRow), cursorCol - 1, 1) = " "
          cursorCol = cursorCol - 1
          dirty% = 1
        END IF

      CASE 13       ' Enter
        IF cursorRow < ROWS THEN
          cursorRow = cursorRow + 1
          cursorCol = 1
          IF selecting% THEN selEnd% = cursorRow
        END IF

      CASE 9        ' Ctrl+I : Insert blank line
        InsertLinesAt cursorRow, 1
        myText$(cursorRow) = SPACE$(COLS)
        dirty% = 1

      CASE 4        ' Ctrl+D : Delete line
        DeleteLinesRange cursorRow, cursorRow
        dirty% = 1
        IF selecting% THEN selEnd% = cursorRow

      CASE 128      ' Up
        IF cursorRow > 1 THEN
          cursorRow = cursorRow - 1
          IF selecting% THEN selEnd% = cursorRow
        ENDIF

      CASE 129      ' Down
        IF cursorRow < ROWS THEN
          cursorRow = cursorRow + 1
          IF selecting% THEN selEnd% = cursorRow
        ENDIF

      CASE 130      ' Left
        IF cursorCol > 1 THEN cursorCol = cursorCol - 1

      CASE 131      ' Right
        IF cursorCol < COLS THEN cursorCol = cursorCol + 1

      CASE ELSE
        ch = ASC(k$)
        IF ch >= 32 AND ch <= 126 THEN
          MID$(myText$(cursorRow), cursorCol, 1) = CHR$(ch)
          dirty% = 1
          IF cursorCol < COLS THEN
            cursorCol = cursorCol + 1
          ELSEIF cursorRow < ROWS THEN
            cursorRow = cursorRow + 1
            cursorCol = 1
            IF selecting% THEN selEnd% = cursorRow
          END IF
        END IF

    END SELECT
  END IF

  PAUSE 10
LOOP


'======================
' Inline subroutines (GOSUB targets)
'======================

DoNew:
  FOR i = 1 TO ROWS
    myText$(i) = SPACE$(COLS)
  NEXT i
  currentFile$ = ""
  cursorRow = 1 : cursorCol = 1
  ClearSelection
  dirty% = 0
  FlashMessage "New file started"
RETURN

DoOpen:
  PromptFilenameInteractive "Open", "", tmp$
  IF tmp$ <> "" THEN
    LoadFile tmp$
    currentFile$ = tmp$
    cursorRow = 1 : cursorCol = 1
    ClearSelection
    dirty% = 0
    FlashMessage "Opened " + currentFile$
  ELSE
    FlashMessage "Open canceled"
  ENDIF
RETURN


'======================
' Utility procedures
'======================

Sub FlashMessage(msg$)
  TEXT 0, (25 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (25 * 12), LEFT$(msg$ + SPACE$(COLS), COLS), l, 1, 1, FG, BG
  PAUSE 900
End Sub

' Simple Y/N confirmation dialog on the footer lines.
Function ConfirmYesNo(prompt$)
  Local k$, ch
  TEXT 0, (24 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (24 * 12), LEFT$(prompt$ + SPACE$(COLS), COLS), l, 1, 1, FG, BG
  TEXT 0, (25 * 12), LEFT$("Press Y/Enter to confirm, N/Esc to cancel" + SPACE$(COLS), COLS), l, 1, 1, FG, BG
  DO
    k$ = INKEY$
    IF k$ <> "" THEN
      ch = ASC(k$)
      IF ch = 27 OR ch = 110 OR ch = 78 THEN ConfirmYesNo = 0 : EXIT FUNCTION ' Esc or 'n'/'N'
      IF ch = 13 OR ch = 121 OR ch = 89 THEN ConfirmYesNo = 1 : EXIT FUNCTION ' Enter or 'y'/'Y'
    ENDIF
    PAUSE 10
  LOOP
End Function

' Show a modal help screen and wait for any key to return.
Sub ShowHelpScreen
  CLS RGB(0,0,0)
  TEXT 0, 0*12,  "=== PICO-EDIT HELP ===", l, 1, 1, FG, BG
  TEXT 0, 2*12,  "Ctrl+L : Help (this screen)", l, 1, 1, FG, BG
  TEXT 0, 3*12,  "Ctrl+N : New (asks if unsaved)", l, 1, 1, FG, BG
  TEXT 0, 4*12,  "Ctrl+O : Open file", l, 1, 1, FG, BG
  TEXT 0, 5*12,  "Ctrl+S : Save file", l, 1, 1, FG, BG
  TEXT 0, 6*12,  "Arrows  : Move cursor", l, 1, 1, FG, BG
  TEXT 0, 7*12,  "Backsp  : Delete left", l, 1, 1, FG, BG
  TEXT 0, 8*12,  "Enter   : New line", l, 1, 1, FG, BG
  TEXT 0, 9*12,  "Ctrl+I  : Insert blank line", l, 1, 1, FG, BG
  TEXT 0, 10*12, "Ctrl+D  : Delete line", l, 1, 1, FG, BG

  TEXT 0, 12*12, "Selection:", l, 1, 1, FG, BG
  TEXT 0, 13*12, "  Ctrl+B : Start/extend at cursor", l, 1, 1, FG, BG
  TEXT 0, 14*12, "  Ctrl+E : Finish selection", l, 1, 1, FG, BG
  TEXT 0, 15*12, "  Ctrl+G : Clear selection", l, 1, 1, FG, BG

  TEXT 0, 17*12, "Clipboard:", l, 1, 1, FG, BG
  TEXT 0, 18*12, "  Ctrl+K : Copy", l, 1, 1, FG, BG
  TEXT 0, 19*12, "  Ctrl+X : Cut", l, 1, 1, FG, BG
  TEXT 0, 20*12, "  Ctrl+V : Paste (above cursor)", l, 1, 1, FG, BG

  TEXT 0, 22*12, "Esc/Ctrl+Q : Quit", l, 1, 1, FG, BG
  TEXT 0, 24*12, "Press any key to return…", l, 1, 1, FG, BG

  DO : LOOP UNTIL INKEY$ <> ""
End Sub

' Interactive, on-screen filename prompt using INKEY$
Sub PromptFilenameInteractive(action$, default$, ByRef out1$)
  Local buf$, k$, ch
  buf$ = default$
  out1$ = ""

  ' instruction line
  TEXT 0, (24 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (24 * 12), LEFT$(action$ + " filename (Enter=OK, Esc=Cancel):" + SPACE$(COLS), COLS), l, 1, 1, FG, BG

  DO
    ' draw editable buffer on status line
    TEXT 0, (25 * 12), SPACE$(COLS), l, 1, 1, FG, BG
    TEXT 0, (25 * 12), LEFT$(buf$ + "_" + SPACE$(COLS), COLS), l, 1, 1, FG, BG

    k$ = INKEY$
    IF k$ <> "" THEN
      ch = ASC(k$)
      SELECT CASE ch
        CASE 13   ' Enter
          out1$ = Trim$(buf$, " ")
          EXIT DO
        CASE 27   ' Esc
          out1$ = ""
          EXIT DO
        CASE 8    ' Backspace
          IF LEN(buf$) > 0 THEN buf$ = LEFT$(buf$, LEN(buf$) - 1)
        CASE ELSE
          IF ch >= 32 AND ch <= 126 THEN
            IF LEN(buf$) < 64 THEN buf$ = buf$ + CHR$(ch)
          ENDIF
      END SELECT
    ENDIF
    PAUSE 10
  LOOP
End Sub

Sub LoadFile(fname$)
  Local i, L$
  FOR i = 1 TO ROWS
    myText$(i) = SPACE$(COLS)
  NEXT i

  ON ERROR SKIP
  OPEN fname$ FOR INPUT AS #1
  IF ERRNO = 0 THEN
    FOR i = 1 TO ROWS
      IF EOF(#1) THEN EXIT FOR
      LINE INPUT #1, L$
      myText$(i) = LEFT$(L$ + SPACE$(COLS), COLS)
    NEXT i
    CLOSE #1
  ELSE
    FlashMessage "File not found: " + fname$
  ENDIF
  ON ERROR ABORT
End Sub

Sub SaveFile(fname$)
  Local i, t$
  ON ERROR SKIP
  OPEN fname$ FOR OUTPUT AS #1
  IF ERRNO = 0 THEN
    FOR i = 1 TO ROWS
      t$ = Trim$(myText$(i), " ")
      PRINT #1, t$
    NEXT i
    CLOSE #1
  ELSE
    FlashMessage "Cannot save: " + fname$
  ENDIF
  ON ERROR ABORT
End Sub

Sub ClearSelection
  selectionActive% = 0
  selecting% = 0
  selStart% = 0
  selEnd% = 0
End Sub

Sub NormalizeSel(ByRef s1%, ByRef s2%)
  IF s1% > s2% THEN
    Local t% : t% = s1% : s1% = s2% : s2% = t%
  ENDIF
  IF s1% < 1 THEN s1% = 1
  IF s2% < 1 THEN s2% = 1
  IF s1% > ROWS THEN s1% = ROWS
  IF s2% > ROWS THEN s2% = ROWS
End Sub

Sub CopySelectionOrLine
  Local s1%, s2%, i%
  IF selectionActive% = 0 THEN
    clipCount% = 1
    clip$(1) = myText$(cursorRow)
  ELSE
    s1% = selStart% : s2% = selEnd% : NormalizeSel s1%, s2%
    clipCount% = s2% - s1% + 1
    IF clipCount% > ROWS THEN clipCount% = ROWS
    FOR i% = 1 TO clipCount%
      clip$(i%) = myText$(s1% + i% - 1)
    NEXT i%
  ENDIF
  FlashMessage "Copied " + STR$(clipCount%) + " line(s)"
End Sub

Sub CutSelectionOrLine
  Local s1%, s2%
  CopySelectionOrLine
  IF selectionActive% = 0 THEN
    DeleteLinesRange cursorRow, cursorRow
  ELSE
    s1% = selStart% : s2% = selEnd% : NormalizeSel s1%, s2%
    DeleteLinesRange s1%, s2%
    ClearSelection
    cursorRow = s1%
  ENDIF
  FlashMessage "Cut " + STR$(clipCount%) + " line(s)"
End Sub

Sub InsertLinesAt(atRow%, count%)
  Local i%
  IF count% <= 0 THEN EXIT SUB
  IF atRow% < 1 OR atRow% > ROWS THEN EXIT SUB
  FOR i% = ROWS TO atRow% + count% STEP -1
    IF i% - count% >= 1 THEN
      myText$(i%) = myText$(i% - count%)
    ELSE
      myText$(i%) = SPACE$(COLS)
    ENDIF
  NEXT i%
  FOR i% = 0 TO count% - 1
    IF atRow% + i% <= ROWS THEN myText$(atRow% + i%) = SPACE$(COLS)
  NEXT i%
End Sub

Sub DeleteLinesRange(r1%, r2%)
  Local s1%, s2%, i%
  s1% = r1% : s2% = r2% : NormalizeSel s1%, s2%
  Local span% : span% = s2% - s1% + 1
  IF span% <= 0 THEN EXIT SUB
  FOR i% = s1% TO ROWS - span%
    myText$(i%) = myText$(i% + span%)
  NEXT i%
  FOR i% = ROWS - span% + 1 TO ROWS
    myText$(i%) = SPACE$(COLS)
  NEXT i%
End Sub

'======================
' Trim helpers
'======================
Function Trim$(s$, c$)
  Trim$ = RTrim$(LTrim$(s$, c$), c$)
End Function

Function RTrim$(s$, c$)
  RTrim$ = s$
  Do While Len(RTrim$) > 0 AND INSTR(c$, RIGHT$(RTrim$, 1))
    RTrim$ = MID$(RTrim$, 1, Len(RTrim$) - 1)
  Loop
End Function

Function LTrim$(s$, c$)
  LTrim$ = s$
  Do While Len(LTrim$) > 0 AND INSTR(c$, LEFT$(LTrim$, 1))
    LTrim$ = MID$(LTrim$, 2)
  Loop
End Function

