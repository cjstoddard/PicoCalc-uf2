'pipboy.bas
' Code by Chris Stoddard

ON ERROR IGNORE

Const BLK=RGB(BLACK)
Const GRN=RGB(GREEN)

Font 1
Colour GRN, BLK

StationChoice = 1
ScreenChoice = 1

StatScreen()

Do
  KeyPress$ = Inkey$
  AscKey = Asc(KeyPress$)
  Select Case AscKey
    Case 145 ' F1 Key
      ScreenChoice = 1
    Case 146 ' F2 Key
      ScreenChoice = 2
    Case 147 ' F3 Key
      ScreenChoice = 3
    Case 148 ' F4 Key
      ScreenChoice = 4
    Case 149 ' F5 Key
      CLS
      End
    Case 150  ' F6 Key
      StationChoice = 1
    Case 151  ' F7 Key
      StationChoice = 2      
    Case 152  ' F8 Key
      StationChoice = 3
    Case 153  ' F9 Key
      StationChoice = 4

'===This needs to be altered to reflect the contents of your music folder==
    Case 120  ' x Key
      If StationChoice = 1 Then
        Play MP3 "music/Appalachia Radio.mp3", StopMusic()
      Elseif StationChoice = 2 Then
        Play MP3 "music/Diamond City Radio.mp3", StopMusic()
      Elseif StationChoice = 3 Then
        Play MP3 "music/Galaxy News Radio.mp3", StopMusic()
      Elseif StationChoice = 4 Then 
        Play MP3 "music/Wastelanders Radio.mp3", StopMusic()
      Endif
'===This needs to be altered to reflect the contents of your music folder==

    Case 113  ' q Key
      Play Stop    
    Case 99   ' c key
      Play Pause
    Case 114  ' r key
      Play Resume
    Case 131  ' Right Arrow Key
      ScreenChoice =  ScreenChoice + 1
    Case 130  ' Left Arrow Key
      ScreenChoice =  ScreenChoice - 1
    Case 5    ' Ctrl+E to launch pipedit
      IF ScreenChoice = 2 THEN
        RUN "pipedit.bas"
      ENDIF
   Case Else
     GoTo Skipper
   End Select

  If ScreenChoice > 4 Then
    ScreenChoice = 1
  ElseIf ScreenChoice < 1 Then
    ScreenChoice = 4
  EndIf

  If ScreenChoice = 1 Then
    StatScreen()
  ElseIf ScreenChoice = 2 Then
    InvScreen()
  ElseIf ScreenChoice = 3 Then
    DataScreen()
  ElseIf ScreenChoice = 4 Then
    RadioScreen()
  EndIf

Skipper:
Loop

Sub StatScreen()

  CLS
  Box 5,5,315,315
  Box 25,10,60,20
  Text 55,14,"Stat",c,,,BLK,GRN
  Box 95,10,60,20
  Text 125,14,"Inv",c
  Box 165,10,60,20
  Text 195,14,"Data",c
  Box 235,10,60,20
  Text 265,14,"Radio",c
  Load png "assets/vb.png",120,100
  Load png "assets/gun.png",25,275
  Load png "assets/aim.png",75,275
  Load png "assets/helm.png",125,275
  Load png "assets/shld.png",175,275
  Load png "assets/volt.png",225,275
  Load png "assets/nuc.png",275,275
  
  IntBattery = MM.Info(battery)
  StrBattery$ = Str$(IntBattery) + "%"
  Text 25,85, "Battery:",l
  Text 25,100,StrBattery$,l

  On Error Ignore
  IPAddress$ = MM.Info(ip address)
  If IPAddress$ = "" Then
    IPAddress$ = "0.0.0.0"
  Endif
  Text 120,50, "IP Adress:"
  Text 120,65, IPAddress$,l

  TimeUp$ = Str$(Int(MM.Info(uptime)/60)) + " Minutes"
  Text 25,185, "Uptime:"
  Text 25,200, TimeUp$,l

  IntFreeMem = MM.Info(HEAP)
  IntFreeMem = Int(IntFreeMem/1024)
  StrFreeMem$ = Str$(IntFreeMem) + "kb"
  Text 220,85, "Free Mem:",l
  Text 220,100,StrFreeMem$,l

  IntFreeSpace = MM.Info(FREE SPACE)
  IntFreeSpace = Cint(IntFreeSpace / (1024*1024*1024))
  StrFreeSpace$ = Str$(IntFreeSpace) + "GB"
  Text 220,185, "Free Spc:",l
  Text 220,200,StrFreeSpace$,l
  
  Text 170,240, "Lucy",c

End Sub

Sub InvScreen()
  CLS
  Box 5,5,315,315
  Box 25,10,60,20
  Text 55,14,"Stat",c
  Box 95,10,60,20
  Text 125,14,"Inv",c,,,BLK,GRN
  Box 165,10,60,20
  Text 195,14,"Data",c
  Box 235,10,60,20
  Text 265,14,"Radio",c

  Box 25, 50, 270, 230
  TEXT 30, 290, "Ctrl+e to edit notes", l, 1, 1, GRN, BLK

  ON ERROR SKIP
  OPEN "edit.txt" FOR INPUT AS #1
  IF ERRNO = 0 THEN
    FOR i = 0 TO 10  ' Max 11 lines to fit
      IF EOF(#1) THEN EXIT FOR
      LINE INPUT #1, L$
      TEXT 30, 60 + i * 12, LEFT$(L$, 38), "L", 1, 1, GRN, BLK
    NEXT i
    CLOSE #1
  ENDIF
  ON ERROR ABORT

End Sub

Sub DataScreen()

  CLS
  Box 5,5,315,315
  Box 25,10,60,20
  Text 55,14,"Stat",c
  Box 95,10,60,20
  Text 125,14,"Inv",c
  Box 165,10,60,20
  Text 195,14,"Data",c,,,BLK,GRN
  Box 235,10,60,20
  Text 265,14,"Radio",c

End Sub

Sub RadioScreen()

  CLS
  Box 5,5,315,315
  Box 25,10,60,20
  Text 55,14,"Stat",c
  Box 95,10,60,20
  Text 125,14,"Inv",c
  Box 165,10,60,20
  Text 195,14,"Data",c
  Box 235,10,60,20
  Text 265,14,"Radio",c,,,BLK,GRN
  Box 25, 50,110, 110
  Load png "assets/radio.png", 30,55
  Box 25, 185, 275, 120
  
  Text 150, 65, " x - Radio On"
  Text 150, 85, " q - Radio Off"
  Text 150, 105," c - Pause Radio"
  Text 150, 125," r - Resume Radio"
  Text 190, 165, "Stations:", l,2

  If StationChoice = 1 Then  
    Text 35,200,"F6:Appalachia Radio",l,2,,BLK,GRN
    Text 35,225,"F7:Diamond City Radio",l,2
    Text 35,250,"F8:Galaxy News Radio",l,2
    Text 35,275,"F9:Wastelanders Radio",l,2
  Elseif StationChoice = 2 Then  
    Text 35,200,"F6:Appalachia Radio",l,2
    Text 35,225,"F7:Diamond City Radio",l,2,,BLK,GRN
    Text 35,250,"F8:Galaxy News Radio",l,2
    Text 35,275,"F9:Wastelanders Radio",l,2
  Elseif StationChoice = 3 Then  
    Text 35,200,"F6:Appalachia Radio",l,2
    Text 35,225,"F7:Diamond City Radio",l,2
    Text 35,250,"F8:Galaxy News Radio",l,2,,BLK,GRN
    Text 35,275,"F9:Wastelanders Radio",l,2
  Elseif StationChoice = 4 Then  
    Text 35,200,"F6:Appalachia Radio",l,2
    Text 35,225,"F7:Diamond City Radio",l,2
    Text 35,250,"F8:Galaxy News Radio",l,2
    Text 35,275,"F9:Wastelanders Radio",l,2,,BLK,GRN
  Endif

End Sub

Sub StopMusic()
  Play Stop 
End Sub
