'picocalc-bme280.bas

' Based on code written by matherp at TheBackShed.com Forums
' https://www.thebackshed.com/forum/ViewTopic.php?TID=8362
' and KW Services.
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

Dim INTEGER s16=&HFFFFFFFFFFFF0000 , s16b=&H8000
Dim INTEGER s12=&HFFFFFFFFFFFFF000 , s12b=&H800
Dim INTEGER s8= &HFFFFFFFFFFFFFF00 , s8b=&H80
Dim INTEGER T1,T2,T3
Dim INTEGER P1,P2,P3,P4,P5,P6,P7,P8,P9
Dim INTEGER H1,H2,H3,H4,H5,H6
Dim INTEGER t_fine

' This is the GPIO pins for the BME280, these will need 
' to be adjusted for the available PicoCalc pins.
SetPin GP2, GP3, I2C2
GUI DELETE ALL
Font 1
Colour BLK,WHT
CLS WHT

GUI FRAME #1, "Home", 5, 5, 310, 310, BLK
GUI CAPTION #2, "Temp", 70, 30, LT, BLK, WHT
GUI CAPTION #3, "Humi", 225, 30, LT, BLK, WHT
GUI GAUGE #4,100,130,60,BLK,BLK,0,120,1,"F",YLW,60,GRN,90,RED
' If you want temperature in Celsius, Comment out the previous line
' and uncomment the next line.
'GUI GAUGE #4,100,130,60,BLK,BLK,0,100,1,"C",YLW,15,GRN,32,RED
GUI GAUGE #5,250,130,60,BLK,BLK,0,100,1,"%",YLW,30,GRN,60,RED
GUI GAUGE #6,100,270,60,BLK,BLK,600,1200,1,"hPa",YLW,900,GRN,1100,RED
GUI CAPTION #7, "Pres", 225, 250, LT, BLK, WHT

bme280_init

Do
  temp_c = bme280_read_temp()
  temp_f = (temp_c * 1.8) + 32
  CtrlVal(#4) = temp_f
  ' If you want Temperature in Celsius, comment out the
  ' previous 3 lines and uncomment the next line.
  'CtrlVal(#4) = bme280_read_temp()
  CtrlVal(#5) = bme280_read_humidity()
  CtrlVal(#6) = bme280_read_pressure()
  CPU SLEEP 0.5
Loop

End

Function bme280_read_temp() As float
  Local integer var1,var2,adc_T
  Local adc%(2)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_TEMPDATA
  I2C2 read BME280_ADDRESS,0,3,adc%()
  adc_T=((adc%(0)<<16) Or (adc%(1)<<8) Or adc%(2))>>4
  var1 = ((((adc_T>>3) - (T1 <<1))) * T2) \ q(11)
  var2 = (((((adc_T>>4) - (T1)) * ((adc_T\ q(4)) - (T1))) \ q(12)) * (T3)) \ q(1
  t_fine = var1 + var2
  bme280_read_temp = ((t_fine * 5 + 128) \ q(8))/100.0
End Function

Function bme280_read_pressure() As float
  Local integer var1, var2, adc_P, p
  Local adc%(2)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_PRESSUREDATA
  I2C2 read BME280_ADDRESS,0,3,adc%()
  adc_P=((adc%(0)<<16) Or (adc%(1)<<8) Or adc%(2))>>4
  var1 = t_fine - 128000
  var2 = var1 * var1 * P6
  var2 = var2 + ((var1 * P5)<<17)
  var2 = var2 + (P4 << 35)
  var1 = ((var1 * var1 * P3)\ q(8)) + ((var1 * P2)<<12)
  var1 = ((1<<47)+var1)*P1\ q(33)
  If var1 = 0 Then
    bme280_read_pressure = 0
  Exit Function
  EndIf
  p = 1048576 - adc_P
  p = (((p<<31) - var2)*3125) \ var1
  var1 = (P9 * (p\ q(13)) * (p\ q(13))) \ q(25)
  var2 = (P8 * p) \ q(19)
  p = ((p + var1 + var2) \ q(8)) + (P7<<4)
  bme280_read_pressure = p/25600.0
End Function

Function bme280_read_humidity() As float
  Local integer v_x1,adc_H
  Local adc%(1)
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_HUMIDDATA
  I2C2 read BME280_ADDRESS,0,2,adc%()
  adc_H=(adc%(0)<<8) Or adc%(1)
  v_x1 = t_fine - 76800
  v_x1=(((((adc_H<<14)-((H4)<<20)-(H5*v_x1))+16384)\ q(15))*(((((((v_x1*H6)\ q(1
  v_x1 = (v_x1 - (((((v_x1 \ q(15)) * (v_x1 \ q(15))) \ q(7)) * (H1)) \ q(4)))
  If v_x1< 0 Then v_x1 = 0
  If v_x1 > 419430400 Then v_x1= 419430400
  bme280_read_humidity = (v_x1\ q(12)) / 1024.0
End Function

Sub bme280_init
  Local i%,cal%(17)
  I2C2 open 400,1000
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_CHIPID
  I2C2 read BME280_ADDRESS,0,1,i%
  If i%<>&H60 Then Print "Error BME280 not found"

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_T1
  I2C2 read BME280_ADDRESS,0,6,cal%()
  T1=cal%(0) Or (cal%(1)<< 8)
  T2=cal%(2) Or (cal%(3)<< 8): If T2 And s16b Then T2=T2 Or s16
  T3=cal%(4) Or (cal%(5)<< 8): If T3 And s16b Then T3=T3 Or s16

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_P1
  I2C2 read BME280_ADDRESS,0,18,cal%()
  P1=cal%(0) Or (cal%(1)<<8)
  P2=cal%(2) Or (cal%(3)<<8): If P2 And s16b Then P2=P2 Or s16
  P3=cal%(4) Or (cal%(5)<<8): If P3 And s16b Then P3=P3 Or s16
  P4=cal%(6) Or (cal%(7)<<8): If P4 And s16b Then P4=P4 Or s16
  P5=cal%(8) Or (cal%(9)<<8): If P5 And s16b Then P5=P5 Or s16
  P6=cal%(10) Or (cal%(11)<<8): If P6 And s16b Then P6=P6 Or s16
  P7=cal%(12) Or (cal%(13)<<8): If P7 And s16b Then P7=P7 Or s16
  P8=cal%(14) Or (cal%(15)<<8): If P8 And s16b Then P8=P8 Or s16
  P9=cal%(16) Or (cal%(17)<<8): If P9 And s16b Then P9=P9 Or s16

  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_H1
  I2C2 read BME280_ADDRESS,0,1,H1
  I2C2 write BME280_ADDRESS,1,1,BME280_REGISTER_H2
  I2C2 read BME280_ADDRESS,0,7,cal%()
  H2=cal%(0) Or (cal%(1)<< 8): If H2 And s16b Then H2=H2 Or s16
  H3=cal%(2)
  H6=cal%(6): If H6 And s8b Then H6=H6 Or s8
  H4=(cal%(3)<<4) Or (cal%(4) And &H0F): If H4 And s12b Then H4=H4 Or s12
  H5=(cal%(5)<<4) Or (cal%(4)>>4): If H5 And s12b Then H5=H5 Or s12

  I2C2 write BME280_ADDRESS,0,2,BME280_REGISTER_CONTROLHUMID,&H05
  I2C2 write BME280_ADDRESS,0,2,BME280_REGISTER_CONTROL,&HB7
End Sub

Function q(x As integer) As integer
  q=(1<<x)
End Function
