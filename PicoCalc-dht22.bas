'ssd1963-dht22.bas

' Copyright (C) 2024 Chris Stoddard
' MIT License
' MMBASIC 5.08

Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const GRN=RGB(GREEN)
Const RED=RGB(RED)
Const BLU=RGB(BLUE)

Dim FLOAT temp, humidity

RTC GETTIME
Font 5
CLS BLU
Colour WHT,BLU

GUI FRAME #1, "Time, Temperature and Humidity", 20, 20, 760, 440, WHT
GUI CAPTION #2, "Time: " + Time$, 50, 50, LT, WHT, BLU
GUI CAPTION #3, "Temp: " + Str$(temp), 50, 150, LT, WHT, BLU
GUI CAPTION #4, "Humi: " + Str$(humidity), 50, 250, LT, WHT, BLU
GUI BARGAUGE #5, 50, 100, 325, 25, WHT, BLU, 0, 24, GRN, 8, YLW, 16, RED, 24
GUI BARGAUGE #6, 50, 200, 325, 25, WHT, BLU, 0, 120, GRN, 40, YLW, 80, RED, 120
GUI BARGAUGE #7, 50, 300, 325, 25, WHT, BLU, 0, 100, GRN, 33, YLW, 66, RED, 100

Do
  Device HUMID GP27, temp, humidity
  ' If you want the temp dispayed in celcius
  ' comment out the next 2 lines
  f_temp = (temp * 1.8) + 32
  temp = f_temp
  CtrlVal(#2) = "Time: " + Time$
  CtrlVal(#3) = "Temp: " + Str$(temp)
  CtrlVal(#4) = "Humi: " + Str$(humidity)
  CtrlVal(#5) = Val(Left$(Time$,2))
  CtrlVal(#6) = temp
  CtrlVal(#7) = humidity
  Pause 1000
Loop
