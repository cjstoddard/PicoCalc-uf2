'PicoCalc-dht22.bas

' Copyright (C) 2024 Chris Stoddard
' MIT License
' MMBASIC 5.08

OPTION GUI CONTROLS 5

Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const GRN=RGB(GREEN)
Const RED=RGB(RED)
Const BLU=RGB(BLUE)
Const CYA=RGB(CYAN)

Dim FLOAT temp, humidity

Font 1
CLS BLU
Colour WHT,BLU

GUI FRAME #1, "Home",  5, 5, 310, 310, WHT
GUI CAPTION #2, "Temperature: " + Str$(temp), 50, 50, LT, WHT, BLU
GUI CAPTION #3, "Humidity: " + Str$(humidity), 50, 150, LT, WHT, BLU
GUI BARGAUGE #4, 10, 100, 300, 25, WHT, BLU, 0, 120, GRN, 40, YLW, 80, RED, 120
GUI BARGAUGE #5, 10, 200, 300, 25, WHT, BLU, 0, 100, GRN, 33, YLW, 66, RED, 100

Do
  Device HUMID GP28, temp, humidity
  ' If you want the temp dispayed in Celsius
  ' comment out the next 2 lines
  f_temp = (temp * 1.8) + 32
  temp = f_temp
  CtrlVal(#2) = "Temperature: " + Str$(temp)
  CtrlVal(#3) = "Humidity: " + Str$(humidity)
  CtrlVal(#4) = temp
  CtrlVal(#5) = humidity
  CPU SLEEP 0.5
Loop
