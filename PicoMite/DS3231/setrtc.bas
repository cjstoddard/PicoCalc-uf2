'setrtc.bas
' Original code credits
' rlauzon
' https://github.com/rlauzon54/PicoCalcBasic/blob/main/onboot.bas
' tassyJim
' https://www.thebackshed.com/forum/ViewTopic.php?TID=17833&PID=236974#236974

Dim RTCbuffer(20)
Dim RTCTime$
Dim RTCDate$

SetPin GP4, GP5, I2C

InputDate:
input "Year";year:print
input "Month";month:print
input "Day";day:print

' Validate input
if year < 100 then year = year+2000
if month < 1 or month > 12 then goto InputDate
if day < 1 or day > 31 then goto InputDate

date$=str$(year)+"-"+str$(month)+"-"+str$(day)
print "Set date to ";date$
print

InputTime:
input "Hour";hour:print
input "Minute";minute:print
' I don't bother to set seconds from
' input simply because it won't be
' even close to right

' Validate input
if hour < 1 or hour > 24 then goto InputTime
if minute < 0 or monute > 60 then goto InputTime

time$=str$(hour)+":"+str$(minute)+":30"

print "Set time to ";time$
print

setRTC

end

SUB setRTC ' set RTC to MM time
 LOCAL INTEGER BCDh, BCDm, BCDs, BCDd, BCDmo, BCDy, BCDw
 LOCAL now$, today$
 now$=TIME$
 today$=DATE$
 BCDh  = VAL("&H"+LEFT$(now$, 2))
 BCDm  = VAL("&H"+MID$(now$, 4, 2))
 BCDs  = VAL("&H"+MID$(now$, 7,2))
 BCDd  = VAL("&H"+LEFT$(today$, 2))
 BCDmo = VAL("&H"+MID$(today$, 4, 2))
 BCDy  = VAL("&H"+RIGHT$(today$, 2))
 BCDw  = doweek(today$)
 
 ' Write Time to RTC
 i2c OPEN 100,100' Enable I2C
 i2c WRITE RTCaddr, 0, 8,0, BCDs, BCDm, BCDh, BCDw, BCDd, BCDmo, BCDy
 i2c CLOSE
 PRINT "0=ok 1=nack 2=timeout   "; MM.I2C
 PRINT "RTC set to: ";now$;"   ";today$
 PRINT
END SUB

FUNCTION doweek(theDate$) AS INTEGER
 LOCAL INTEGER dy, month, year, dayofyear, dayz
 dy = VAL(LEFT$(theDate$, 2))
 month = VAL(MID$(theDate$, 4, 2))
 year = VAL(RIGHT$(theDate$, 4))
 dayofyear= dy+INT((month-1)*30.57+0.5)
 IF month >2 THEN
   dayofyear= dayofyear-1
   IF (year/4)>0 THEN dayofyear= dayofyear-1
 ENDIF
 dayz= INT((year-1900)*365.25)+dayofyear+1
 doweek= dayz-1-INT((dayz-1)/7)*7
END FUNCTION