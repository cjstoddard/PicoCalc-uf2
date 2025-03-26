'ssd1963-bme280.bas

' Based on code written by matherp at TheBackShed.com Forums
' https://www.thebackshed.com/forum/ViewTopic.php?TID=8362
' and KW Services.
' https://github.com/kwinter745321/PicoDisplay
' MIT License
' MMBASIC 5.08

Const BME280_ADDRESS = &H76
Const BME280_REGISTER_T1 = &H88
Const BME280_REGISTER_P1 = &H8E
Const BME280_REGISTER_H1 = &HA1
Const BME280_REGISTER_H2 = &HE1
Const BME280_REGISTER_CHIPID = &HD0
Const BME280_REGISTER_CONTROLHUMID = &HF2
Const BME280_REGISTER_CONTROL = &HF4
Const BME280_REGISTER_PRESSUREDATA = &HF7
Const BME280_REGISTER_TEMPDATA = &HFA
Const BME280_REGISTER_HUMIDDATA = &HFD

Const BLK=RGB(BLACK)
Const WHT=RGB(WHITE)
Const YLW=RGB(YELLOW)
Const GRN=RGB(GREEN)
Const RED=RGB(RED)
Const BLU=RGB(BLUE)
Const CYA=RGB(CYAN)

Dim INTEGER s16=&HFFFFFFFFFFFF0000 , s16b=&H8000
Dim INTEGER s12=&HFFFFFFFFFFFFF000 , s12b=&H800
Dim INTEGER s8= &HFFFFFFFFFFFFFF00 , s8b=&H80
Dim INTEGER T1,T2,T3
Dim INTEGER P1,P2,P3,P4,P5,P6,P7,P8,P9
Dim INTEGER H1,H2,H3,H4,H5,H6
Dim INTEGER t_fine

SetPin GP26, GP27, I2C2
RTC GETTIME
GUI DELETE ALL
Font 5
Colour BLK,WHT
CLS WHT

GUI FRAME #1, "Home", 20, 20, 760, 440, BLK
GUI CAPTION #2, "Temperature", 280, 50, LT, BLK, WHT
GUI CAPTION #3, "Humidity", 565, 50, LT, BLK, WHT
GUI GAUGE #4,400,200,100,BLK,BLK,0,120,1,"F",YLW,60,GRN,90,RED
' If you want temperature in Celsius, Comment out the previous line
' and uncomment the next line.
'GUI GAUGE #4,400,200,100,BLK,BLK,0,100,1,"C",YLW,15,GRN,32,RED
GUI GAUGE #5,640,200,100,BLK,BLK,0,100,1,"%",YLW,30,GRN,60,RED
GUI CAPTION #6, "States:", 50, 100, LT, BLK, WHT
GUI LED #7, "Running", 70, 180, 20, GRN
GUI LED #8, "Resting", 70, 230, 20, RED
GUI CAPTION #9, Time$, 50, 450, LT, BLK, WHT
GUI BUTTON #10, "Exit|EXIT", 50, 300, 200, 75, BLK, CYATemperature in Celsius, comment out the
GUI GAUGE #11,400,375,100,BLK,BLK,600,1200,1,"hPa",YLW,900,GRN,1100,RED
GUI CAPTION #12, "Pressure", 550, 350, LT, BLK, WHT

CtrlVal(#7) = 0
CtrlVal(#8) = 1

bme280_init

Do
  btn = CtrlVal(#10)

  If btn = 1 Then
    CLS BLK
    Exit
  Else
    temp_c = bme280_read_temp()
    temp_f = (temp_c * 1.8) + 32
    CtrlVal(#4) = temp_f
    ' If you want Temperature in Celsius, comment out the
    ' previous 3 lines and uncomment the next line.
    'CtrlVal(#4) = bme280_read_temp()
    CtrlVal(#5) = bme280_read_humidity()
    CtrlVal(#11) = bme280_read_pressure()
    CtrlVal(#9) = Time$
    CtrlVal(#7) = 0
    CtrlVal(#8) = 1
    CPU SLEEP 0.5
    CtrlVal(#7) = 1
    CtrlVal(#8) = 0
  EndIf
Loop

end

function bme280_read_temp() as float
  local integer var1,var2,adc_T
  local adc%(2)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_TEMPDATA
  I2C2 read BME280_ADDRESS,0,3,adc%()
  adc_T=((adc%(0)<<16) OR (adc%(1)<<8) or adc%(2))>>4
  var1 = ((((adc_T>>3) - (T1 <<1))) * T2) \ q(11)
  var2 = (((((adc_T>>4) - (T1)) * ((adc_T\ q(4)) - (T1))) \ q(12)) * (T3)) \ q(14)
  t_fine = var1 + var2
  bme280_read_temp = ((t_fine * 5 + 128) \ q(8))/100.0
end function

function bme280_read_pressure() as float
  local integer var1, var2, adc_P, p
  local adc%(2)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_PRESSUREDATA
  I2C2 read BME280_ADDRESS,0,3,adc%()
  adc_P=((adc%(0)<<16) OR (adc%(1)<<8) or adc%(2))>>4
  var1 = t_fine - 128000
  var2 = var1 * var1 * P6
  var2 = var2 + ((var1 * P5)<<17)
  var2 = var2 + (P4 << 35)
  var1 = ((var1 * var1 * P3)\ q(8)) + ((var1 * P2)<<12)
  var1 = ((1<<47)+var1)*P1\ q(33)
  if var1 = 0 THEN
    bme280_read_pressure = 0
  exit function
  endif
  p = 1048576 - adc_P
  p = (((p<<31) - var2)*3125) \ var1
  var1 = (P9 * (p\ q(13)) * (p\ q(13))) \ q(25)
  var2 = (P8 * p) \ q(19)
  p = ((p + var1 + var2) \ q(8)) + (P7<<4)
  bme280_read_pressure = p/25600.0
end function

function bme280_read_humidity() as float
  local integer v_x1,adc_H
  local adc%(1)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_HUMIDDATA
  I2C2 read BME280_ADDRESS,0,2,adc%()
  adc_H=(adc%(0)<<8) or adc%(1)
  v_x1 = t_fine - 76800
  v_x1=(((((adc_H<<14)-((H4)<<20)-(H5*v_x1))+16384)\ q(15))*(((((((v_x1*H6)\ q(10))*(((v_x1*H3)\ q(11))+32768))\ q(10))+2097152)*H2+8192)\ q(14)))
  v_x1 = (v_x1 - (((((v_x1 \ q(15)) * (v_x1 \ q(15))) \ q(7)) * (H1)) \ q(4)))
  if v_x1< 0 then v_x1 = 0
  if v_x1 > 419430400 then v_x1= 419430400
  bme280_read_humidity = (v_x1\ q(12)) / 1024.0
end function

sub bme280_init
  local i%,cal%(17)
  I2C2 open 400,1000
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_CHIPID
  I2C2 read BME280_ADDRESS,0,1,i%
  if i%<>&H60 then print "Error BME280 not found"

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_T1
  I2C2 read BME280_ADDRESS,0,6,cal%()
  T1=cal%(0) OR (cal%(1)<< 8)
  T2=cal%(2) OR (cal%(3)<< 8): if T2 and s16b then T2=T2 OR s16
  T3=cal%(4) OR (cal%(5)<< 8): if T3 and s16b then T3=T3 OR s16

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_P1
  I2C2 read BME280_ADDRESS,0,18,cal%()
  P1=cal%(0) OR (cal%(1)<<8)
  P2=cal%(2) OR (cal%(3)<<8): if P2 and s16b then P2=P2 OR s16
  P3=cal%(4) OR (cal%(5)<<8): if P3 and s16b then P3=P3 OR s16
  P4=cal%(6) OR (cal%(7)<<8): if P4 and s16b then P4=P4 OR s16
  P5=cal%(8) OR (cal%(9)<<8): if P5 and s16b then P5=P5 OR s16
  P6=cal%(10) OR (cal%(11)<<8): if P6 and s16b then P6=P6 OR s16
  P7=cal%(12) OR (cal%(13)<<8): if P7 and s16b then P7=P7 OR s16
  P8=cal%(14) OR (cal%(15)<<8): if P8 and s16b then P8=P8 OR s16
  P9=cal%(16) OR (cal%(17)<<8): if P9 and s16b then P9=P9 OR s16

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_H1
  I2C2 read BME280_ADDRESS,0,1,H1
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_H2
  I2C2 read BME280_ADDRESS,0,7,cal%()
  H2=cal%(0) OR (cal%(1)<< 8): if H2 and s16b then H2=H2 OR s16
  H3=cal%(2)
  H6=cal%(6): if H6 and s8b then H6=H6 OR s8
  H4=(cal%(3)<<4) OR (cal%(4) and &H0F): if H4 and s12b then H4=H4 OR s12
  H5=(cal%(5)<<4) OR (cal%(4)>>4): if H5 and s12b then H5=H5 OR s12

  I2C2 write BME280_ADDRESS,0,2,BME280_REGISTER_CONTROLHUMID,&H05
  I2C2 write BME280_ADDRESS,0,2,BME280_REGISTER_CONTROL,&HB7
end sub

function q(x as integer) as integer
  q=(1<<x)
End Function 