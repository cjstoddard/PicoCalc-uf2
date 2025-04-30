'picogotchi.bas
' Code by Chris Stoddard

' === Constants and Faces ===
Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const RED=RGB(RED)
Const GRN=RGB(GREEN)
Const ORG=RGB(BROWN)
Const CYA=RGB(CYAN)

LOOK_R$ = "(  o_o)"
LOOK_L$ = "(o_o  )"
HAPPY$ = "( O O )"
SAD$ = "( T_T )"
ANGRY$ = "(-_-  )"
BORED$ = "(-___-)"
WORKING$ = "( @_@ )"
SLEEP0$ = "( -.- )"
DEBUG$ = "( #_# )"
GLITCH1$ = "( o_o )"
GLITCH2$ = "( O_O )"
GLITCH3$ = "( x_x )"

' === Display Layout Constants ===
Const BOX_X = 10
Const BOX_Y = 240
Const BOX_W = 300
Const BOX_H = 70

' === Display Setup ===
Font 2
Colour BLK,YLW

' === Manual Trim Functions ===
Function LTrim$(s$)
  Do While Left$(s$, 1) = " " And Len(s$) > 0
    s$ = Mid$(s$, 2)
  Loop
  LTrim$ = s$
End Function

Function RTrim$(s$)
  Do While Right$(s$, 1) = " " And Len(s$) > 0
    s$ = Left$(s$, Len(s$) - 1)
  Loop
  RTrim$ = s$
End Function

Function Trim$(s$)
  Trim$ = LTrim$(RTrim$(s$))
End Function

' === Sub: Simulate CPU Work ===
Sub SimulateWork()
  Local i%, x!
  For i% = 1 To 5000
    x! = Sqr(i%) * Log(i% + 1)
  Next i%
End Sub

' === Sub: Animate Looking Around ===
Sub AnimateLook()
  Local i%
  For i% = 1 To 3
    Box BOX_X, BOX_Y, BOX_W, BOX_H, 1, RED, YLW
    Colour BLK,YLW
    CenterText BOX_Y + 25, LOOK_L$
    Pause 1000
    Box BOX_X, BOX_Y, BOX_W, BOX_H, 1, RED, YLW
    Colour BLK,YLW
    CenterText BOX_Y + 25, LOOK_R$
    Pause 1000
  Next i%
End Sub

' === Sub: Random Idle Face with Rare Glitches ===
Sub ShowIdleFace()
  Local idleFace$, r%
  r% = Int(Rnd * 20)
  Select Case r%
    Case 0: idleFace$ = GLITCH1$
    Case 1: idleFace$ = GLITCH2$
    Case 2: idleFace$ = GLITCH3$
    Case 3: idleFace$ = LOOK_L$
    Case 4: idleFace$ = LOOK_R$
    Case 5: idleFace$ = BORED$
    Case 6: idleFace$ = SLEEP0$
    Case 7: idleFace$ = DEBUG$
    Case Else: idleFace$ = "( -_- )"
  End Select

  Box BOX_X, BOX_Y, BOX_W, BOX_H, 1, RED, YLW
  Colour BLK,YLW
  CenterText BOX_Y + 5, "..."
  CenterText BOX_Y + 25, idleFace$
  If showRamNext% Then
    ShowRamStat BOX_Y + 45
  Else
    ShowUptimeStat BOX_Y + 45
  EndIf
  showRamNext% = Not showRamNext%
  Pause 300
End Sub

' === Sub: Show RAM ===
Sub ShowRamStat(y%)
  Local freeMem%
  freeMem% = MM.INFO(HEAP)
  CenterText y%, "RAM: " + Str$(freeMem%) + " bytes"
End Sub

' === Sub: Show Uptime ===
Sub ShowUptimeStat(y%)
  Local uptime%
  uptime% = MM.INFO(UPTIME)
  CenterText y%, "UPTIME: " + Str$(uptime%) + " sec"
End Sub

' === Sub: Center text inside the mood box (cleaned) ===
Sub CenterText(y%, text$)
  Local clean$
  clean$ = Trim$(text$)
  Text BOX_X + (BOX_W - Len(clean$) * 8) / 2, y%, clean$
End Sub

' === Main Loop ===
Dim tStart!, tEnd!, busyTime!
Dim mood$, msg$, msgColor%
Dim idleCounter%
Dim showRamNext%
Dim freeMem%, uptime%

idleCounter% = 0
showRamNext% = 1

Do
  tStart! = TIMER
  SimulateWork()
  tEnd! = TIMER
  busyTime! = tEnd! - tStart!

  freeMem% = MM.INFO(HEAP)
  uptime% = MM.INFO(UPTIME)

  ' Priority: low memory > long uptime > cpu load
  If freeMem% < 5000 Then
    mood$ = SAD$
    msg$ = "Running low!"
    msgColor% = CYA
  ElseIf uptime% > 10000 Then
    mood$ = SLEEP0$
    msg$ = "Getting sleepy"
    msgColor% = ORG
  ElseIf busyTime! < 100 Then
    mood$ = HAPPY$
    msg$ = "All chill"
    msgColor% = GRN
  ElseIf busyTime! < 300 Then
    mood$ = WORKING$
    msg$ = "Working hard"
    msgColor% = ORG
  Else
    mood$ = ANGRY$
    msg$ = "Overloaded!"
    msgColor% = RED
  EndIf

  ' Animate looking around
  AnimateLook()

  ' Display mood box and content
  Box BOX_X, BOX_Y, BOX_W, BOX_H, 1, RED, YLW
  Colour BLK, msgColor%
  CenterText BOX_Y + 5, msg$
  Colour BLK,YLW
  CenterText BOX_Y + 25, mood$
  If showRamNext% Then
    ShowRamStat BOX_Y + 45
  Else
    ShowUptimeStat BOX_Y + 45
  EndIf
  showRamNext% = Not showRamNext%

  Pause 1000

  ' Random idle animation every few cycles
  idleCounter% = idleCounter% + 1
  If idleCounter% >= 5 Then
    ShowIdleFace()
    idleCounter% = 0
  EndIf
Loop

