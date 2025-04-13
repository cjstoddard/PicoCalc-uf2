' Transpiled on 01-08-2020 19:19:55

' Copyright (c) 2020 Thomas Hugo Williams
'
' Hand-optimised PicoMite version derived from CMM2 version by Peter Mather

If MM.Device$<>"Colour Maximite"Then
 Option Explicit On
 Option Default Integer
EndIf
'Mode 1
Dim m(64*1024/8+16)
Dim MAD=Peek(VarAddr m())+8
Dim fsz
Dim bst
Function rp()
 rp=LGetByte(m(),pc)
 Inc pc
End Function

Function rb(a)
 rb=LGetByte(m(),a)
End Function

Function rw(a)
 rw=LGetByte(m(),a)*256+LGetByte(m(),a+1)
End Function

Sub wb(a,x)
 Poke Byte MAD+a,x
End Sub

Sub ww(a,x)
 Poke Byte MAD+a,x\256
 Poke Byte MAD+a+1,x Mod 256
End Sub

Sub mem_init(f$)
 Local ad,i,j,s$,sz
 cou("Loading '"+f$+"'"):cen()
 cou("0% ... ")
 sz=MM.Info(filesize f$)
 Open f$ For Input As #1
 j=1
 Do
  s$=Input$(255,#1)
  If Len(s$)=0 Then Exit
  LongString Append m(),s$
  ad=ad+Len(s$)
  If ad>j*sz\10 Then cou(Str$(j*10)+"% ... "):j=j+1
 Loop
 cou("100%"):cen()
 cou("Read "+Str$(ad)+" bytes"):cen()
 Close #1
 bst=rw(&h0E)
 fsz=rw(&h1A)*2
 If fsz>ad Then Error "Story file is truncated"
End Sub

Dim stk(511)
Dim sp

Function spo()
 sp=sp-1
 spo=stk(sp)
End Function

Sub spu(x)
 stk(sp)=x
 Inc sp
End Sub

Function spe(i)
 If i>=sp Then Error "Attempt to peek beyond stack pointer"
 spe=stk(i)
End Function

Sub spk(i,x)
 If i>=sp Then Error "Attempt to poke beyond stack pointer"
 If x<0 Or x>&hFFFF Then Error "Invalid unsigned 16-bit value"
 stk(i)=x
End Sub

Dim gva

Function vge(i)
 If Not i Then
  Inc sp,-1
  vge=stk(sp)
 ElseIf i<16 Then
  vge=stk(fp+i+4)
 ElseIf i<=255 Then
  vge=rw(gva+2*(i-16))
 Else
  Error "Unknown variable "+Str$(i)
 EndIf
End Function

Sub vse(i,x)
 If Not i Then
  spu(x)
 ElseIf i<16 Then
  stk(fp+i+4)=x
 ElseIf i<=255 Then
  ww(gva+2*(i-16),x)
 Else
  Error "Unknown variable "+Str$(i)
 EndIf
End Sub

Dim pc
Dim oc=0
Dim osz=0
Dim oa(4)
Dim ot(4)
Dim ov(4)
Dim st=0
Dim br=0

Sub de_init()
 Local i,s$,x
 Read x
 Dim o0$(x-1)LENGTH 12
 For i=0 To x-1:Read s$:o0$(i)=de_format$(s$):Next i
 Read x
 Dim o1$(x-1)LENGTH 14
 For i=0 To x-1:Read s$:o1$(i)=de_format$(s$):Next i
 Read x
 Dim o2$(x-1)LENGTH 15
 For i=0 To x-1:Read s$:o2$(i)=de_format$(s$):Next i
 Read x
 Dim o3$(x-1)LENGTH 14
 For i=0 To x-1:Read s$:o3$(i)=de_format$(s$):Next i
End Sub

Dim dec_op, dec_s$, dec_sn
Function dec(tr)
 If tr Then cou(Hex$(pc)+": ")
 dec_op=LGetByte(m(),pc)
 Inc pc
 If dec_op<128 Then
  dlo(dec_op)
  dec_s$=o2$(oc)
 ElseIf dec_op<192 Then
  dsh(dec_op)
  If dec_op<176 Then dec_s$=o1$(oc)Else dec_s$=o0$(oc)
 Else
  dva(dec_op)
  If dec_op<224 Then dec_s$=o2$(oc)Else dec_s$=o3$(oc)
 EndIf
 dec_sn=Peek(var dec_s$,1)
 If dec_sn=66 Then
  st=-1
  br=dbr()
 ElseIf dec_sn=83 Then
  st=LGetByte(m(),pc):Inc pc
  br=0
 ElseIf dec_sn=88 Then
  st=LGetByte(m(),pc):Inc pc
  br=dbr()
 Else
  st=-1
  br=0
 EndIf
 If tr Then dmp_op(Mid$(dec_s$,2))
 dec=dec_op
End Function

Sub dlo(op)
 oc=op And 31
 osz=2
 ov(0)=LGetByte(m(),pc):Inc pc
 ov(1)=LGetByte(m(),pc):Inc pc
 If op<=31 Then
  ot(0)=1:oa(0)=ov(0)
  ot(1)=1:oa(1)=ov(1)
 ElseIf op<=63 Then
  ot(0)=1:oa(0)=ov(0)
  ot(1)=2:oa(1)=vge(ov(1))
 ElseIf op<=95 Then
  ot(0)=2:oa(0)=vge(ov(0))
  ot(1)=1:oa(1)=ov(1)
 Else
  ot(0)=2:oa(0)=vge(ov(0))
  ot(1)=2:oa(1)=vge(ov(1))
 EndIf
End Sub

Sub dsh(op)
 oc=op And 15
 osz=1
 If op<=143 Then
  ot(0)=0:ov(0)=LGetByte(m(),pc)*256:Inc PC: Inc ov(0),LGetByte(m(),pc):Inc pc:
oa(0)=ov(0)
 ElseIf op<=159 Then
  ot(0)=&b01:ov(0)=LGetByte(m(),pc):Inc pc:oa(0)=ov(0)
 ElseIf op<=175 Then
  ot(0)=&b10:ov(0)=LGetByte(m(),pc):Inc pc:oa(0)=vge(ov(0))
 Else
  osz=0
 EndIf
End Sub

Sub dva(op)
 Local i,x
 oc=op And 31
 osz=4
 x=LGetByte(m(),pc):Inc pc
 For i=0 To 3
  ot(i)=(x>>6) And 3
  If ot(i)=0 Then
   ov(i)=rp()*256+rp():oa(i)=ov(i)
  ElseIf ot(i)=1 Then
   ov(i)=LGetByte(m(),pc):Inc pc:oa(i)=ov(i)
  ElseIf ot(i)=2 Then
   ov(i)=LGetByte(m(),pc):Inc pc:oa(i)=vge(ov(i))
  Else
   osz=osz-1
  EndIf
  x=x*4
 Next i
End Sub

Function dbr()
 Local a,of,x
 a=LGetByte(m(),pc):Inc pc
 of=a And 63
 If (a And 64)=0 Then
  of=256*of+LGetByte(m(),pc):Inc pc
  If a And 32 Then of=of-16384
 EndIf
 x=pc+of-2
 If a And 128 Then x=x Or &h80000
 dbr=x
End Function

Function de_format$(a$)
 Local p,s$
 If Instr(a$," SB")>0 Then
  s$="X"
 ElseIf Instr(a$," B")>0 Then
  s$="B"
 ElseIf Instr(a$," S")>0 Then
  s$="S"
 Else
  s$=" "
 EndIf
 p=Instr(a$," ")
 If p=0 Then p=Len(a$)+1
 s$=s$+Left$(a$,p-1)
 de_format$=s$
End Function

Data 14
Data "RTRUE","RFALSE","PRINT","PRINT_RET","NOP"
Data "SAVE B","RESTORE B","RESTART","RET_POPPED","POP"
Data "QUIT","NEW_LINE","SHOW_STATUS","VERIFY B"
Data 16
Data "JZ B","GET_SIBLING SB","GET_CHILD SB","GET_PARENT S","GET_PROP_LEN S"
Data "INC","DEC","PRINT_ADDR","Unknown&h8","REMOVE_OBJ"
Data "PRINT_OBJECT","RET","JUMP","PRINT_PADDR","LOAD S"
Data "NOT S"
Data 25
Data "Unknown&h0","JE B","JL B","JG B","DEC_CHK B"
Data "INC_CHK B","JIN B","TEST B","OR S","AND S"
Data "TEST_ATTR B","SET_ATTR","CLEAR_ATTR","STORE","INSERT_OBJ"
Data "LOADW S","LOADB S","GET_PROP S","GET_PROP_ADDR S","GEN_NEXT_PROP S"
Data "ADD S","SUB S","MUL S","DIV S","MOD S"
Data 22
Data "CALL S","STOREW","STOREB","PUT_PROP","READ"
Data "PRINT_CHAR","PRINT_NUM","RANDOM S","PUSH","PULL"
Data "SPLIT_WINDOW","SET_WINDOW","Unknown&hC","Unknown&hD","Unknown&hE"
Data "Unknown&hF","Unknown&h10","Unknown&h11","Unknown&h12","OUTPUT_STREAM"
Data "INPUT_STREAM","SOUND_EFFECT"
Dim fp
Dim num_bp
Dim nop
Dim ztrace
Dim exe_pc,exe_sp,exe_op

Function exe(tr)
 exe_pc=pc:exe_sp=sp
 exe_op=dec(tr)
 Inc nop
 If exe_op<128 Then
  exe=e2o()
 ElseIf exe_op<&hB0 Then
  exe=e1o()
 ElseIf exe_op<&hC0 Then
  exe=e0o()
 ElseIf exe_op<&hE0 Then
  exe=e2o()
 Else
  exe=evo()
 EndIf
 If exe=1 Then
  cou("Unsupported instruction "+hx$(op,2)):cen()
 ElseIf exe=2 Then
  cou("Unimplemented instruction "+hx$(op,2)):cen()
 EndIf
 If exe<>0 Then pc=exe_pc:sp=exe_sp
End Function

Function e2o()
 Local a,b,x,y,_
 a=oa(0)
 b=oa(1)
 If oc=1 Then
  x=(a=b)
  If (Not x)And(osz>2)Then x=(a=oa(2))
  If (Not x)And(osz>3)Then x=(a=oa(3))
  ebr(x,br)
 ElseIf oc=2 Then
  If a>32767 Then a=a-65536
  If b>32767 Then b=b-65536
  ebr(a<b,br)
 ElseIf oc=3 Then
  If a>32767 Then a=a-65536
  If b>32767 Then b=b-65536
  ebr(a>b,br)
 ElseIf oc=4 Then
  x=vge(a)
  If x>32767 Then x=x-65536
  If b>32767 Then b=b-65536
  x=x-1
  y=x<b
  If x<0 Then x=65536+x
  vse(a,x)
  ebr(y,br)
 ElseIf oc=5 Then
  x=vge(a)
  If x>32767 Then x=x-65536
  If b>32767 Then b=b-65536
  x=x+1
  y=x>b
  If x<0 Then x=65536+x
  vse(a,x)
  ebr(y,br)
 ElseIf oc=6 Then
  x=ob_rel(a,4)
  ebr(x=b,br)
 ElseIf oc=7 Then
  ebr((a And b)=b,br)
 ElseIf oc=8 Then
  vse(st,a Or b)
 ElseIf oc=9 Then
  vse(st,a And b)
 ElseIf oc=10 Then
  x=oat(a,b)
  ebr(x=1,br)
 ElseIf oc=11 Then
  _=oat(a,b,1,1)
 ElseIf oc=12 Then
  _=oat(a,b,1,0)
 ElseIf oc=13 Then
  If a=0 Then spk(sp-1,b)Else vse(a,b)
 ElseIf oc=14 Then
  oin(a,b)
 ElseIf oc=15 Then
  x=rw(a+2*b)
  vse(st,x)
 ElseIf oc=16 Then
  x=rb(a+b)
  vse(st,x)
 ElseIf oc=17 Then
  x=opg(a,b)
  vse(st,x)
 ElseIf oc=18 Then
  x=opa(a,b)
  vse(st,x)
 ElseIf oc=19 Then
  x=onp(a,b)
  vse(st,x)
 ElseIf oc<25 Then
  If a>32767 Then a=a-65536
  If b>32767 Then b=b-65536
  If oc=20 Then
   x=a+b
  ElseIf oc=21 Then
   x=a-b
  ElseIf oc=22 Then
   x=a*b
  ElseIf oc=23 Then
   x=a\b
  Else
   x=a Mod b
  EndIf
  If x<0 Then x=65536+x
  vse(st,x)
 Else
  e2o=1
 EndIf
End Function

Function e1o()
 Local a,x
 a=oa(0)
 If oc=0 Then
  ebr(a=0,br)
 ElseIf oc=1 Then
  x=ob_rel(a,5)
  vse(st,x)
  ebr(x<>0,br)
 ElseIf oc=2 Then
  x=ob_rel(a,6)
  vse(st,x)
  ebr(x<>0,br)
 ElseIf oc=3 Then
  x=ob_rel(a,4)
  vse(st,x)
 ElseIf oc=4 Then
  x=opl(a)
  vse(st,x)
 ElseIf oc=5 Then
  x=vge(a)
  If x>32767 Then x=x-65536
  x=x+1
  If x<0 Then x=65536+x
  vse(a,x)
 ElseIf oc=6 Then
  x=vge(a)
  If x>32767 Then x=x-65536
  x=x-1
  If x<0 Then x=65536+x
  vse(a,x)
 ElseIf oc=7 Then
  pzs(a)
 ElseIf oc=9 Then
  ore(a)
 ElseIf oc=10 Then
  opr(a)
 ElseIf oc=11 Then
  ert(a)
 ElseIf oc=12 Then
  If a And &h8000 Then a=a-65536
  pc=pc+a-2
 ElseIf oc=13 Then
  pzs(a*2)
 ElseIf oc=14 Then
  If a=0 Then x=spe(sp-1)Else x=vge(a)
  vse(st,x)
 ElseIf oc=15 Then
  x=a Xor &HFFFF
  vse(st,x)
 Else
  e1o=1
 EndIf
End Function

Function e0o()
 Local x
 If oc=&h0 Then
  ert(1)
 ElseIf oc=1 Then
  ert(0)
 ElseIf oc=2 Then
  pzs(pc)
 ElseIf oc=3 Then
  pzs(pc)
  cen()
  ert(1)
 ElseIf oc=4 Then
 ElseIf oc=5 Then
  If csc And &b10 Then
   cou("IGNORED 'save' command read from script"):cen()
  Else
   x=zsv()
   ebr(x,br)
  EndIf
 ElseIf oc=6 Then
  If csc And &b10 Then
   cou("IGNORED 'restore' command read from script"):cen()
  Else
   x=zsv(1)
  EndIf
 ElseIf oc=7 Then
  If csc And &b10 Then
   cou("IGNORED 'restart' command read from script"):cen()
  Else
   main_init()
   For x=0 To 10:cen():Next x
  EndIf
 ElseIf oc=8 Then
  x=spo()
  ert(x)
 ElseIf oc=9 Then
  sp=sp-1
 ElseIf oc=10 Then
  e0o=4
 ElseIf oc=11 Then
  cen()
 ElseIf oc=12 Then
  ess()
 ElseIf oc=13 Then
  ebr(1,br)
 Else
  e0o=1
 EndIf
End Function

Function evo()
 Local x,_
 If oc=&h0 Then
  ecl(st)
 ElseIf oc=1 Then
  ww(oa(0)+2*oa(1),oa(2))
 ElseIf oc=2 Then
  wb(oa(0)+oa(1),oa(2))
 ElseIf oc=3 Then
  ob_prop_set(oa(0),oa(1),oa(2))
 ElseIf oc=4 Then
  evo=erd(oa(0),oa(1))
 ElseIf oc=5 Then
  cou(Chr$(oa(0)))
 ElseIf oc=6 Then
  x=oa(0)
  If x>32767 Then x=x-65536
  cou(Str$(x))
 ElseIf oc=7 Then
  x=oa(0)
  If x>32767 Then x=x-65536
  x=era(x)
  vse(st,x)
 ElseIf oc=8 Then
  spu(oa(0))
 ElseIf oc=9 Then
  x=spo()
  If oa(0)=0 Then spk(sp-1,x)Else vse(oa(0),x)
 ElseIf oc=19 Then
  evo=2
 ElseIf oc=20 Then
  evo=2
 ElseIf oc=21 Then
 Else
  evo=1
 EndIf
End Function
Dim ebr_x
Sub ebr(z,br)
 If Not(z=(br And &h80000)>0)Then Exit Sub
 ebr_x=br And &h7FFFF
 If ebr_x=pc-1 Then ert(1):Exit Sub
 If ebr_x=pc-2 Then ert(0):Exit Sub
 pc=ebr_x
End Sub

Sub ert(x)
 Local st,_
 sp=fp+4
 pc=spo()*&h10000+spo()
 st=spo()
 fp=spo()
 vse(st,x)
 If ztrace Then dmp_stack()
End Sub

Sub ecl(st)
 Local i,nl,x
 If oa(0)=0 Then vse(st,0):Exit Sub
 spu(fp)
 fp=sp-1
 spu(st)
 spu(pc Mod &h10000)
 spu(pc\&h10000)
 pc=2*oa(0)
 nl=rp()
 spu(nl)
 For i=1 To nl
  x=rp()*256+rp()
  If i<osz Then spu(oa(i))Else spu(x)
 Next i
 If ztrace Then dmp_routine(2*oa(0)):dmp_stack()
End Sub

Function erd(text_buf,parse_buf)
 Local ad,c,i,n,word$,s$,t,wc
 t=Timer
 s$=LCase$(ci$("> ",1))
 If Left$(s$,1)="*"Then erd=esp(s$)
 Timer =t
 If erd<>0 Then Exit Function
 n=Len(s$)
 For i=1 To n:wb(text_buf+i,Peek(Var s$,i)):Next i
 wb(text_buf+n+1,0)
 s$=s$+" "
 For i=1 To n+1
  c=Peek(Var s$,i)
  If c=&h20 Or Instr(ds$(0),Chr$(c))>0 Then
   If Len(word$)>0 Then
    ad=dlk(word$)
    ww(parse_buf+2+wc*4,ad)
    wb(parse_buf+4+wc*4,Len(word$))
    wb(parse_buf+5+wc*4,i-Len(word$))
    wc=wc+1
    word$=""
   EndIf
   If c<>&h20 Then
    ad=dlk(Chr$(c))
    ww(parse_buf+2+wc*4,ad)
    wb(parse_buf+4+wc*4,1)
    wb(parse_buf+5+wc*4,i-1)
    wc=wc+1
   EndIf
  Else
   word$=word$+Chr$(c)
  EndIf
 Next i
 wb(parse_buf+1,wc)
End Function

Function esp(cmd$)
 Local f$,_
 esp=6
 If cmd$="*break"Then
  esp=0
 ElseIf cmd$="*credits"Then
  cecho(ss$(1)+"/credits.txt")
 ElseIf cmd$="*replay"Then
  If csc And &b10 Then
   cou("IGNORED '*replay' command read from script")
  Else
   cou("Select a script file from '")
   cou(ss$(3)+"/"+ss$(5)+"':")
   cen()
   f$=fi_choose$(ss$(3)+"/"+ss$(5),"*.scr")
   If f$<>""Then
    Open f$ For Input As #3
    csc=csc Or &b10
   EndIf
  EndIf
  cen()
 ElseIf cmd$="*status"Then
  ess()
 Else
  esp=0
 EndIf
 If esp=6 Then cou(">")
End Function

Function era(range)
 Static x=7
 Static a=1103515245
 Static c=12345
 Static m=2^31
 If range=0 Then
  x=Timer
 Exit Function
 ElseIf range<0 Then
  x=Abs(range)
 Exit Function
 EndIf
 x=(a*x+c)Mod m
 era=1+Cint((range-1)*(x/m))
End Function

Sub ess()
 Local x
 x=vge(&h10):opr(x):cou(", ")
 x=vge(&h11):cou("Score: "+Str$(x)+", ")
 x=vge(&h12):cou("Moves: "+Str$(x))
 cen()
End Sub

Dim csc
Dim cb$
Dim csp
Dim cli
Dim cco
Dim cx=1
Dim csi

Function ci$(p$,r)
 Local s$
 cou(p$)
 cfl()
 cli=0
 If csc And &b10 Then
  Line Input #3,s$
  If s$=""Then
   csc=csc And &b01
   Close #3
  Else
   cou(s$):cen()
  EndIf
 EndIf
 If Not(csc And &b10)Then Line Input s$:cx=1
 If (r=1)And(csc And &b01)And(s$<>"")Then Print #2,s$
 ci$=s$
End Function

Sub cou(s$)
 cco=0
 If Len(s$)=1 Then
  If (s$=" ")Xor csp Then cfl():csp=(s$=" ")
  cb$=cb$+s$
 Else
  Local c$,i
  For i=1 To Len(s$)
   c$=Mid$(s$,i,1)
   If (c$=" ")Xor csp Then cfl():csp=(c$=" ")
   cb$=cb$+c$
  Next i
 EndIf
End Sub

Sub cfl()
 If csi Then Print Chr$(8);" ";Chr$(8);:csi=0
 Do
  If cx=1 And cli>50-2 Then
   Print "[MORE] ";
   Do While Inkey$<>"":Loop
   Do While Inkey$="":Loop
   Print
   cli=0
  EndIf
  If cx+Len(cb$)>100 Then
   Print
   cli=cli+1
   cx=1
   If csp Then cb$="":Exit Sub
  Else
   Print cb$;
   cx=cx+Len(cb$)
   cb$=""
  Exit Sub
  EndIf
 Loop
End Sub

Sub cen()
 cfl()
 If cco<0 Then
 Exit Sub
 ElseIf cco>=10 Then
  Local i
  For i=0 To 50-cco-1:Print :Next i
  cco=-999
  cli=0
 Exit Sub
 EndIf
 Print
 cco=cco+1
 cli=cli+1
 cx=1
End Sub

Sub cecho(f$)
 Local s$
 Open f$ For Input As #1
 Do
  Line Input #1,s$
  cou(s$)
  cen()
 Loop While Not Eof(#1)
 Close #1
End Sub

Dim al$(2)LENGTH 32
al$(0)=" 123[]abcdefghijklmnopqrstuvwxyz"
al$(1)=" 123[]ABCDEFGHIJKLMNOPQRSTUVWXYZ"
al$(2)=" 123[]@^0123456789.,!?_#'"+Chr$(34)+"/\-:()"

Sub pzs(a)
 Local b,c,i,s,x,zc(2)
 For x=0 To 0 Step 0
  x=rw(a)
  zc(0)=(x And &h7C00)\&h400
  zc(1)=(x And &h3E0)\&h20
  zc(2)=(x And &h1F)
  x=x\&h8000
  For i=0 To 2
   c=zc(i)
   If s<3 Then
    If c=0 Then
     cou(" ")
    ElseIf c<4 Then
     s=c+2
    ElseIf c<6 Then
     s=c-3
    Else
     If c=6 And s=2 Then
      s=6
     ElseIf c=7 And s=2 Then
      cen()
      s=0
     Else
      cou(Mid$(al$(s),c+1,1))
      s=0
     EndIf
    EndIf
   ElseIf s<6 Then
    b=a
    pab((s-3)*32+c)
    a=b
    s=0
   ElseIf s=6 Then
    s=c+7
   Else
    cou(Chr$((s-7)*32+c))
    s=0
   EndIf
  Next i
  a=a+2
 Next x
End Sub

Sub pab(x)
 Local a,b
 a=rw(&h18)
 b=rw(a+x*2)
 pzs(b*2)
End Sub

Function oat(o,a,s,x)
 Local ad,m,y
 If o=0 Then Exit Function
 ad=rw(&h0A)+62+(o-1)*9+a\8
 y=rb(ad)
 m=2^(7-a Mod 8)
 If s=0 Then oat=(y And m)>0:Exit Function
 If x=0 Then y=(y And(m Xor &hFF))Else y=(y Or m)
 wb(ad,y)
 oat=x
End Function

Function ob_rel(o,r,s,x)
 Local ad
 ad=rw(&h0A)+62+(o-1)*9+r
 If s=0 Then ob_rel=rb(ad):Exit Function
 wb(ad,x)
 ob_rel=x
End Function

Function onp(o,p)
 Local ad,x
 If o=0 Then
 Exit Function
 ElseIf p=0 Then
  ad=opb(o)
  ad=ad+1+2*rb(ad)
 Else
  ad=opa(o,p)
  If ad=0 Then Error "Property does not exist"
  x=rb(ad-1)
  ad=ad+1+x\32
 EndIf
 x=rb(ad)
 onp=x And 31
End Function

Function opl(ad)
 Local x
 If ad=0 Then Exit Function
 x=rb(ad-1)
 opl=x\32+1
End Function

Function opb(o)
 Local ad
 ad=rw(&h0A)+62+(o-1)*9+7
 opb=rw(ad)
End Function

Function opa(o,p)
 Local ad,x
 ad=opb(o)
 ad=ad+1+2*rb(ad)
 Do
  x=rb(ad)
  If (x And 31)=p Then opa=ad+1:Exit Function
  If (x And 31)<p Then opa=0:Exit Function
  ad=ad+2+x\32
 Loop
End Function

Function opg(o,p)
 Local ad,sz,x
 ad=opa(o,p)
 If ad>0 Then
  x=rb(ad-1)
  If (x And 31)<>p Then Error
  sz=x\32+1
  If sz=1 Then opg=rb(ad):Exit Function
  If sz=2 Then opg=rw(ad):Exit Function
  Error "Property length > 2"
 EndIf
 ad=rw(&h0A)+2*(p-1)
 opg=rw(ad)
End Function

Sub ob_prop_set(o,p,x)
 Local a,sz
 a=opa(o,p)
 If a=0 Then Error "Object "+Str$(o)+" does not have property "+Str$(p)
 sz=opl(a)
 If sz<0 Or sz>2 Then Error "Object "+Str$(o)+" has length "+Str$(sz)
 If sz=1 Then wb(a,x And &hFF)
 If sz=2 Then ww(a,x)
End Sub

Sub opr(o)
 Local ad
 ad=opb(o)+1
 pzs(ad)
End Sub

Sub oin(o,d)
 Local c,_
 ore(o)
 c=ob_rel(d,6)
 _=ob_rel(d,6,1,o)
 _=ob_rel(o,4,1,d)
 _=ob_rel(o,5,1,c)
End Sub

Sub ore(o)
 Local c,p,s,_
 p=ob_rel(o,4)
 s=ob_rel(o,5)
 c=ob_rel(p,6)
 _=ob_rel(o,4,1,0)
 _=ob_rel(o,5,1,0)
 If o=c Then
  _=ob_rel(p,6,1,s)
 Else
  Do
   If ob_rel(c,5)=o Then _=ob_rel(c,5,1,s):Exit
   c=ob_rel(c,5)
  Loop Until c=0
 EndIf
End Sub

Function lp$(s$,i,c$)
 Local a
 a=Len(s$)
 If c$=""Then c$=" "
 If a<i Then lp$=String$(i-a,c$)+s$ Else lp$=s$
End Function

Function rd$(s$,i,c$)
 Local a
 a=Len(s$)
 If c$=""Then c$=" "
 If a<i Then rd$=s$+String$(i-a,c$)Else rd$=s$
End Function

Function hx$(x,i)
 If i<1 Then i=4
 hx$="&h"+lp$(Hex$(x),i,"0")
End Function

Dim dad
Dim ds$(1)Length 5
Dim del
Dim dsz
Dim dea

Sub di_init()
 Local i,ns
 dad=rw(&h08)
 ns=rb(dad)
 Poke Var ds$(0),0,ns
 For i=1 To ns:Poke Var ds$(0),i,rb(dad+i):Next i
 del=rb(dad+ns+1)
 dsz=rw(dad+ns+2)
 dea=dad+ns+4
End Sub

Function dlk(w$)
 Local c,i,j,nz,sz,z(9)
 sz=Len(w$):If sz>6 Then sz=6
 i=1
 Do While i<7 And nz<7
  If i>sz Then
   z(nz)=5:nz=nz+1
  Else
   c=Asc(Mid$(w$,i,1))
   j=Instr(al$(0),Chr$(c))-1
   If j>-1 Then
    z(nz)=j:nz=nz+1
   Else
    j=Instr(al$(2),Chr$(c))-1
    If j>-1 Then
     z(nz)=5:nz=nz+1
     z(nz)=j:nz=nz+1
    Else
     z(nz)=5:nz=nz+1
     z(nz)=6:nz=nz+1
     z(nz)=c\32:nz=nz+1
     z(nz)=c And 31:nz=nz+1
    EndIf
   EndIf
  EndIf
  i=i+1
 Loop
 Local x(1)
 x(0)=z(0)*1024+z(1)*32+z(2)
 x(1)=z(3)*1024+z(4)*32+z(5)+32768
 Local a,lb,ub,y(1)
 lb=0
 ub=dsz-1
 Do
  i=(lb+ub)\2
  a=dea+del*i
  y(0)=rw(a)
  y(1)=rw(a+2)
  If x(0)>y(0)Then
   lb=i+1
  ElseIf x(0)<y(0)Then
   ub=i-1
  ElseIf x(1)>y(1)Then
   lb=i+1
  ElseIf x(1)<y(1)Then
   ub=i-1
  Else
   dlk=a
   ub=lb-1
  EndIf
 Loop Until ub<lb
End Function

Function zsv(res)
 Local exists(10),i,old_dir$,s$,s2$(2)Length 40
 If res Then
  cou("Select game to restore:"):cen()
 Else
  cou("Select save game slot:"):cen()
 EndIf
 old_dir$=Cwd$
 Chdir ss$(2)+"/"+ss$(5)
 For i=1 To 10
  s$=Dir$("game"+Str$(i)+".sav")
  cou("  ["+Format$(i,"%2g")+"] ")
  If s$=""Then
   cou("Empty"):cen()
  Else
   exists(i)=1
   Open "game"+Str$(i)+".sav"For Input As #1
   Line Input #1,s2$(0)
   Line Input #1,s2$(1)
   Line Input #1,s2$(2)
   Line Input #1,s$
   cou(s2$(2)+" - "+s$):cen()
   Close #1
  EndIf
 Next i
 Chdir old_dir$
 s$=ci$("Game number? ")
 i=Val(s$)
 If i<1 Or i>10 Then i=0
 If i>0 And res And Not exists(i)Then i=0
 If i>0 And Not res And exists(i)Then
  s$=ci$("Overwrite game "+Str$(i)+" [y|N]? ")
  If LCase$(s$)<>"y"Then i=0
 EndIf
 If i>0 And Not res Then
  s$=ci$("Save game name? ")
  If s$=""Then i=0
 EndIf
 If i=0 Then cou("Cancelled"):cen():Exit Function
 s2$(0)=ss$(2)+"/"+ss$(5)+"/game"+Str$(i)+".sav"
 If res Then
  Open s2$(0)For Input As #1
  Line Input #1,s2$(0)
  Line Input #1,s2$(1)
  Line Input #1,s2$(2)
  Line Input #1,s$
  cou("Restoring '"+s$+"' ..."):cen()
  Local ad,err,new_pc,new_fp,stack_sz,mem_sz
  s$=Input$(9,#1)
  new_pc=Peek(Var s$,1)*65536+Peek(Var s$,2)*256+Peek(Var s$,3)
  new_fp=Peek(Var s$,4)*256+Peek(Var s$,5)
  stack_sz=Peek(Var s$,6)*256+Peek(Var s$,7)
  mem_sz=Peek(Var s$,8)*256+Peek(Var s$,9)
  If new_pc<0 Or new_pc>=fsz Then err=1
  If new_fp<0 Or new_fp>stack_sz Then err=2
  If stack_sz<0 Or stack_sz>511 Then err=3
  If mem_sz<>bst Then err=4
  If err<>0 Then
   cou("Save file is invalid (error "+Str$(err)+")")
   Close #1
  Exit Function
  EndIf
  pc=new_pc
  fp=new_fp
  sp=0
  For i=0 To stack_sz-1
   s$=Input$(2,#1)
   spu(Peek(Var s$,1)*256+Peek(Var s$,2))
  Next i
  Do
   s$=Input$(255,#1)
   For i=1 To Len(s$)
    wb(ad,Peek(Var s$,i))
    ad=ad+1
   Next i
  Loop Until Len(s$)=0
  If ad<>bst Then Error "Unrecoverable restore error!"
 Else
  cou("Saving '"+s$+"' ..."):cen()
  Open s2$(0)For Output As #1
  Print #1,"ZMIM save file"
  Print #1,"1"
  Print #1,Date$+" "+Time$
  Print #1,s$
  Print #1,Chr$(pc\65536);Chr$(pc\256);Chr$(pc Mod 256);
  Print #1,Chr$(fp\256);Chr$(fp Mod 256);
  Print #1,Chr$(sp\256);Chr$(sp Mod 256);
  Print #1,Chr$(bst\256);Chr$(bst Mod 256);
  For i=0 To sp-1
   Print #1,Chr$(spe(i)\256);Chr$(spe(i)Mod 256);
  Next i
  For i=0 To bst-1
   Print #1,Chr$(rb(i));
  Next i
 EndIf
 Close #1
 zsv=1
End Function

Function fi_choose$(d$,fspec$)
 Local f$,i,j,nc,nr,old_dir$,sz,width,x
 old_dir$=Cwd$
 Chdir d$
 f$=Dir$(fspec$)
 Do While f$<>""
  If Left$(f$,1)<>"."Then
   sz=sz+1
   If Len(f$)>width Then width=Len(f$)
  EndIf
  f$=Dir$()
 Loop
 If sz=0 Then cou("No files found"):cen():Chdir old_dir$:Exit Function
 Local all$(sz)LENGTH width
 all$(sz)=Chr$(&h7F)
 f$=Dir$(fspec$)
 i=0
 Do
  If Left$(f$,1)<>"."Then all$(i)=f$:i=i+1
  f$=Dir$()
 Loop Until i=sz
 Sort all$()
 Chdir old_dir$
 If sz<8 Then nc=1 Else nc=2
 nr=Cint(sz/nc+0.4999)
 width=width+10
 For i=0 To nr-1
  For j=0 To nc-1
   cfl()
   x=(j*nr)+i
   If x<sz Then
    If j*width>Pos Then cou(Space$(j*width-Pos))
    cou("  ["+Format$(x+1,"%2g")+"] "+all$(x))
   EndIf
  Next j
  cen()
 Next i
 f$=ci$("File number? ")
 If Val(f$)>0 And Val(f$)<=sz Then fi_choose$=d$+"/"+all$(Val(f$)-1)
End Function

Dim ss$(5)Length 20

Function script_file_name$()
 Local i,s$
 s$=ss$(5)+"-"+Date$+"-"+Time$+".scr"
 For i=1 To Len(s$)
  If Peek(Var s$,i)=Asc(":")Then Poke Var s$,i,Asc("-")
 Next i
 script_file_name$=s$
 Print script_file_name$
End Function

Sub main_init()
 Local i,x
 cen()
 mem_init(ss$(4)+"/"+ss$(5)+".z3")
 di_init()
 cen()
 gva=rw(&h0C)
 x=rb(&h01)
 x=x Or &b00010000
 x=x And &b10011111
 wb(&h01,x)
 wb(&h20,50)
 wb(&h21,100)
 pc=rw(&h06)
 For i=0 To 511:stk(i)=0:Next i
 sp=0
 fp=&hFFFF
End Sub

Sub main()
 Local i,old_dir$,state,s$
 ss$(0)="/zmim"
 If MM.Device$="Colour Maximite"Then
  ss$(1)=ss$(0)+"/resour~1"
 Else
  ss$(1)=ss$(0)+"/resources"
 EndIf
 ss$(2)=ss$(0)+"/saves"
 ss$(3)=ss$(0)+"/scripts"
 ss$(4)=ss$(0)+"/stories"
 CLS
 cecho(ss$(1)+"/title.txt")
 de_init()
 cou("Select a story file from '"+ss$(4)+"':"):cen()
 Do While s$=""
  s$=fi_choose$(ss$(4),"*.z3")
 Loop
 s$=Mid$(s$,Len(ss$(4))+2)
 ss$(5)=Left$(s$,Len(s$)-3)
 old_dir$=Cwd$
 Chdir (ss$(2))
 s$=Dir$(ss$(5),File):If s$<>""Then Error "Unexpected file: "+s$
 s$=Dir$(ss$(5),Dir):If s$=""Then Mkdir (ss$(5))
 Chdir (ss$(3))
 s$=Dir$(ss$(5),File):If s$<>""Then Error "Unexpected file:"+s$
 s$=Dir$(ss$(5),Dir):If s$=""Then Mkdir (ss$(5))
 Chdir (old_dir$)
 main_init()
 s$=ss$(3)+"/"+ss$(5)+"/"+script_file_name$()
 If LCase$(ci$("Write script to '"+s$+"' [y|N] "))="y"Then
  Open s$ For Output As #2
  csc=&b01
 EndIf
 For i=0 To 10:cen():Next i
 Timer =0
 Do While state<>4
  If state=0 Then
   state=exe(ztrace)
  ElseIf state=6 Then
   state=exe(ztrace)
  Else
   state=debug()
  EndIf
 Loop
 cen()
 cou("Num instructions processed = "+Str$(nop)):cen()
 cou("Instructions / second      = ")
 cou(Format$(1000*nop/Timer,"%.1f"))
 cen()
 If csc And &b01 Then Close #2
 If csc And &b10 Then Close #3
End Sub

main()
End
