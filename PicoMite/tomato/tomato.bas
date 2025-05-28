'tomato.bas
' Code by Chris Stoddard

AWAKE$ = "assets/AWAKE.png"
LOOK_L$ = "assets/LOOK_L.png"
LOOK_R$ = "assets/LOOK_R.png"
HAPPY$ = "assets/HAPPY.png"
SLEEP0$ = "assets/SLEEP.png"

ANGRY$ = "assets/ANGRY.png"
BORED$ = "assets/BORED.png"
BROKEN$ = "assets/BROKEN.png"
COOL$ = "assets/COOL.png"
DEBUG$ = "assets/DEBUG.png"
DEMOTIVATED$ = "assets/DEMOTIVATED.png"
EXCITED$ = "assets/EXCITED.png"
FRIEND$ = "assets/FRIEND.png"
GRATEFUL$ = "assets/GRATEFUL.png"
INTENSE$ = "assets/INTENSE.png"
LONELY$ = "assets/LONELY.png"
LOOK_R_Happy$ = "assets/LOOK_L_HAPPY.png"
LOOK_R_HAPPY$ = "assets/LOOK_R_HAPPY.png"
MOTIVATED$ = "assets/MOTIVATED.png"
SAD$ = "assets/SAD.png"
SLEEP1$ = "assets/SLEEP2.png"
SMART$ = "assets/SMART.png"
UPLOAD1$ = "assets/UPLOAD1.png"
UPLOAD2$ = "assets/UPLOAD2.png"
UPLOAD$ = "assets/UPLOAD.png"

lastTick = Timer

Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const maxVisible = 3
Const scrollDelayMs = 10000 ' 10 seconds

Dim info$(4) ' 5 lines: index 0 to 4
Dim scrollPos = 0
Dim numLines = 5 ' Adjust if you add more info lines

Font 1
Colour WHT,BLK

DrawBoxes()
WakeUp()
CollectInfo()
UpdateInfo()

Do
  currentTick = Timer
  If currentTick - lastTick >= scrollDelayMs Then
    CollectInfo()
    lastTick = currentTick
    scrollPos = scrollPos + 1
    If scrollPos > numLines - maxVisible Then scrollPos = 0
    LookAround()
    UpdateInfo()
  EndIf

  KeyPress$ = Inkey$
  If KeyPress$ <> "" Then
    CLS
    End
  Endif

  Pause 500
Loop

Sub CollectInfo()
  Local IntBattery, IntFreeMem, IntUptime, IntFreeSpace, IPAddress$

  IntBattery = MM.Info(battery)
  info$(0) = "Battery: " + Str$(IntBattery) + "%    "

  IPAddress$ = MM.Info(ip address)
  info$(1) = "IP: " + IPAddress$

  IntFreeMem = Int(MM.Info(HEAP)/1024)
  info$(2) = "Free Mem: " + Str$(IntFreeMem) + " kb   "

  IntUptime = Int((MM.INFO(UPTIME) / 60)/60)
  info$(3) = "Uptime: " + left$((str$((mm.info(uptime)/60)/60)), 5) + " hrs   "

  IntFreeSpace = Cint(MM.Info(FREE SPACE) / (1024*1024*1024))
  info$(4) = "Free Spc: " + Str$(IntFreeSpace) + " GB   "
End Sub

Sub UpdateInfo()
  For count = 0 To maxVisible - 1
    If scrollPos + count < numLines Then
      Text 12, 12 + (COUNT * 16), info$(scrollPos + COUNT)
    EndIf
  Next COUNT
End Sub

Sub DrawBoxes()
  CLS
  Box 5,5,315,315
  Box 180,10,135,65
  Box 10,10,165,65
  Box 10,80,305,235
End Sub

Sub WakeUp()
  Load PNG SLEEP0$, 185, 11
  Text 255,11,"ZZZZZZ"
  Pause 1000
  Load PNG AWAKE$, 185, 11
  Pause 1000
  LookAround()
  Pause 1000
End Sub

Sub LookAround()
  Load PNG LOOK_R$, 185, 11
  Text 255,11,"Look"
  Text 255,21,"Here"
  Pause 1000
  Load PNG LOOK_L$, 185, 11
  Text 255,11,"Look"
  Text 255,21,"There"
  Pause 1000
  Load PNG HAPPY$, 185, 11
  Text 255,11,"       "
  Text 255,21,"       "
End Sub
