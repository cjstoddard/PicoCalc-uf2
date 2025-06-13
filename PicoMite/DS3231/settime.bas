'settime.bas
' Original code credits
' tassyJim
' https://www.thebackshed.com/forum/ViewTopic.php?TID=17833&PID=236974#236974

Dim RTCbuffer(20)
Dim RTCTime$
Dim RTCDate$

SetPin GP4, GP5, I2C

getRTCtime

Print "===================="
Print RTCtime$
Time$ = RTCtime$
Print RTCdate$
Date$ = RTCdate$
Print "===================="
Drive "b:"
Print "Defaulting to drive B:"
Print "===================="

End

Sub getRTCtime
  LOCAL RTCsec$,RTCmin$,RTChr$,RTCwday$,RTCday$,RTCmon$,RTCyr$
  I2C open 1000, 1000
  I2C write &H68, 0, 1, 0
  I2C read &H68, 0, 19, RTCBuffer(0)
  I2C Close
  RTCsec$ =HEX$((RTCbuffer(0) AND &H7F),2)
  RTCmin$ =HEX$((RTCbuffer(1) AND &H7F),2)
  RTChr$  =HEX$((RTCbuffer(2) AND &H3F),2)
  RTCwday$=HEX$((RTCbuffer(3) AND &H07),2)
  RTCday$ =HEX$((RTCbuffer(4) AND &H3F),2)
  RTCmon$ =HEX$((RTCbuffer(5) AND &H1F),2)
  RTCyr$  ="20"+HEX$((RTCbuffer(6)),2)
  RTCtime$=RTChr$+":"+RTCmin$+":"+RTCsec$
  RTCdate$=RTCday$+"-"+RTCmon$+"-"+RTCyr$
End Sub
