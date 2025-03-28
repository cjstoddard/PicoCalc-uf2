'PicoCalc-dht22-2.bas

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

GUI DELETE ALL
Font 2.5
Colour BLK,WHT
CLS WHT

GUI FRAME #1, "Home", 20, 20, 310, 310, BLK
GUI CAPTION #2, "Temp", 70, 30, LT, BLK, WHT
GUI CAPTION #3, "Humi", 225, 30, LT, BLK, WHT

GUI GAUGE #4,100,130,75,BLK,BLK,0,120,1,"F",YLW,60,GRN,90,RED
' If you want temperature in Celsius, Comment out the previous line
' and uncomment the next line.
'GUI GAUGE #4,100,130,75,BLK,BLK,0,100,1,"C",YLW,15,GRN,32,RED
GUI GAUGE #5,250,130,75,BLK,BLK,0,100,1,"%",YLW,30,GRN,60,RED

Do
' The next line sets the GPIO pin, this will need to be
' adjusted for the PicoCalc's available pins.
  Device HUMID GP27, temp, humidity
  ' If you want the temp dispayed in Celsius
  ' comment out the next 2 lines
  f_temp = (temp * 1.8) + 32
  temp = f_temp

  CtrlVal(#4) = temp
  CtrlVal(#5) = humidity
  CPU SLEEP 0.5
Loop
