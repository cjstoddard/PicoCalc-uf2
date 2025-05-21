'pipedit.bas
' Code by Chris Stoddard

FONT 1
CLS RGB(0, 0, 0)

CONST ROWS = 24
CONST COLS = 40

DIM myText$(ROWS)
FOR i = 1 TO ROWS
  myText$(i) = SPACE$(COLS)
NEXT i

ON ERROR SKIP
OPEN "edit.txt" FOR INPUT AS #1
IF ERRNO = 0 THEN
  FOR i = 1 TO ROWS
    IF EOF(#1) THEN EXIT FOR
    LINE INPUT #1, L$
    myText$(i) = LEFT$(L$ + SPACE$(COLS), COLS)
  NEXT i
  CLOSE #1
END IF
ON ERROR ABORT

DIM cursorRow = 1
DIM cursorCol = 1

CONST FG = RGB(0, 255, 0)
CONST BG = RGB(0, 0, 0)
CONST CURSORFG = RGB(0, 0, 0)
CONST CURSORBG = RGB(0, 255, 0)

DO

  FOR i = 1 TO ROWS
    FOR j = 1 TO COLS
      x = (j - 1) * 8
      y = (i - 1) * 12
      char$ = MID$(myText$(i), j, 1)
      IF i = cursorRow AND j = cursorCol THEN
        TEXT x, y, char$, l, 1, 1, CURSORFG, CURSORBG
      ELSE
        TEXT x, y, char$, l, 1, 1, FG, BG
      END IF
    NEXT j
  NEXT i

  TEXT 0, (24 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (25 * 12), SPACE$(COLS), l, 1, 1, FG, BG
  TEXT 0, (24 * 12), "Ctrl+s:Save Ctrl+i:Ins Ctrl+d:Del", l, 1, 1, FG, BG
  status$ = "Row:" + RIGHT$(" " + STR$(cursorRow), 2) + " Col:" + RIGHT$(" " + STR$(cursorCol), 2) + " Ctrl+q/ESC:Quit"
  TEXT 0, (25 * 12), status$, l, 1, 1, FG, BG

  k$ = INKEY$
  IF k$ <> "" THEN
    SELECT CASE ASC(k$)
      CASE 27, 17 ' ESC or Ctrl+Q
        RUN "pipboy.bas"
        'END
      CASE 19 ' Ctrl+S
        OPEN "edit.txt" FOR OUTPUT AS #1
        FOR i = 1 TO ROWS
          PRINT #1, Trim$(myText$(i), " ")
        NEXT i
        CLOSE #1
        TEXT 0, (25 * 12), SPACE$(COLS), l, 1, 1, FG, BG
        TEXT 0, (25 * 12), "File saved to edit.txt", l, 1, 1, FG, BG
        PAUSE 1000
      CASE 8 ' Backspace
        IF cursorCol > 1 THEN
          MID$(myText$(cursorRow), cursorCol - 1, 1) = " "
          cursorCol = cursorCol - 1
        END IF
      CASE 13 ' Enter
        IF cursorRow < ROWS THEN
          cursorRow = cursorRow + 1
          cursorCol = 1
        END IF
      CASE 9 ' Ctrl+I = Insert line
        FOR i = ROWS TO cursorRow + 1 STEP -1
          myText$(i) = myText$(i - 1)
        NEXT i
        myText$(cursorRow) = SPACE$(COLS)
      CASE 4 ' Ctrl+D = Delete line
        FOR i = cursorRow TO ROWS - 1
          myText$(i) = myText$(i + 1)
        NEXT i
        myText$(ROWS) = SPACE$(COLS)
      CASE 128 ' Up arrow
        IF cursorRow > 1 THEN cursorRow = cursorRow - 1
      CASE 129 ' Down arrow
        IF cursorRow < ROWS THEN cursorRow = cursorRow + 1
      CASE 130 ' Left arrow
        IF cursorCol > 1 THEN cursorCol = cursorCol - 1
      CASE 131 ' Right arrow
        IF cursorCol < COLS THEN cursorCol = cursorCol + 1
      CASE ELSE
        ch = ASC(k$)
        IF ch >= 32 AND ch <= 126 THEN
          MID$(myText$(cursorRow), cursorCol, 1) = CHR$(ch)
          IF cursorCol < COLS THEN
            cursorCol = cursorCol + 1
          ELSEIF cursorRow < ROWS THEN
            cursorRow = cursorRow + 1
            cursorCol = 1
          END IF
        END IF
      END SELECT
  END IF
  PAUSE 10
LOOP

Function Trim$(s$, c$)
  Trim$ = RTrim$(LTrim$(s$, c$), c$)
End Function

Function RTrim$(s$, c$)
  RTrim$ = s$
  Do While Len(RTrim$) > 0 AND Instr(c$, Right$(RTrim$, 1))
    RTrim$ = Mid$(RTrim$, 1, Len(RTrim$) - 1)
  Loop
End Function

Function LTrim$(s$, c$)
  LTrim$ = s$
  Do While Len(LTrim$) > 0 AND Instr(c$, Left$(LTrim$, 1))
    LTrim$ = Mid$(LTrim$, 2)
  Loop
End Function

