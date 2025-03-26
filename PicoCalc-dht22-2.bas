'ssd1963-dht22-2.bas

' Based on code written by KW Services.
' https://github.com/kwinter745321/PicoDisplay
' MIT License
' MMBASIC 5.08

Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const GRN=RGB(GREEN)
Const RED=RGB(RED)
Const BLU=RGB(BLUE)
Const CYA=RGB(CYAN)

Dim FLOAT temp, humidity

RTC GETTIME
GUI DELETE ALL
Font 5
Colour BLK,WHT
CLS WHT

GUI FRAME #1, "Home", 20, 20, 760, 440, BLK
GUI CAPTION #2, "Temperature", 280, 50, LT, BLK, WHT
GUI CAPTION #3, "Humitiy", 576, 50, LT, BLK, WHT
GUI GAUGE #4,400,200,100,BLK,BLK,0,120,1,"Deg F",GRN,70,YLW,85,RED
GUI GAUGE #5,640,200,100,BLK,BLK,0,100,1,"Prec",GRN,40,YLW,65,RED
GUI CAPTION #6, "States:", 50, 100, LT, BLK, WHT
GUI LED #7, "Running", 70, 180, 20, GRN
GUI LED #8, "Resting", 70, 230, 20, RED
GUI CAPTION #9, Time$, 50, 450, LT, BLK, WHT
GUI BUTTON #10, "Exit|EXIT", 50, 300, 200, 75, BLK, CYA

CtrlVal(#7) = 0
CtrlVal(#8) = 1

Do
  Device HUMID GP27, temp, humidity
  ' If you want the temp dispayed in celcius
  ' comment out the next 2 lines
  f_temp = (temp * 1.8) + 32
  temp = f_temp

  btn = CtrlVal(#10)

  If btn = 1 Then
    CLS BLK
    Exit
  Else
    CtrlVal(#4) = temp
    CtrlVal(#5) = humidity
    CtrlVal(#9) = Time$
    CtrlVal(#7) = 0
    CtrlVal(#8) = 1
    CPU SLEEP 0.5
    CtrlVal(#7) = 1
    CtrlVal(#8) = 0
  EndIf
Loop
