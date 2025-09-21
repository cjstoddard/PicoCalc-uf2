'chateau.bas
' Original code by Tim Hartnell 1983
' Updated code by Chris Stoddard 2025

'==============================================================
' CHATEAU GAILLARD  — PicoMite BASIC Edition (modernized)
' - No line numbers; structured SUBs/FUNCTIONs
' - Meaningful identifiers
' - Uses PAUSE instead of delay loops
' - Case-insensitive input; classic two-word parser (VERB NOUN)
'==============================================================

OPTION EXPLICIT
OPTION BASE 1

'---------------- Constants ----------------
CONST DIR_N = 1, DIR_S = 2, DIR_E = 3, DIR_W = 4, DIR_U = 5, DIR_D = 6, DIR_ITEM1 = 7, DIR_MON = 8, DIR_ITEM2 = 9, DIR_ITEM3 = 10
CONST DELAY_SHORT = 200, DELAY_MED = 600, DELAY_LONG = 1200

'---------------- State ----------------
DIM rooms%(44, 10)
DIM bag%(5)                    ' carried object indices (avoid reserved names)
DIM objName$(20), objValue%(20)
DIM monsterName$(20)
DIM weaponHint%(5)             ' temporary per fight

' Player attributes
DIM pStr%, pCha%, pDex%, pInt%, pWis%, pCon%
DIM cash%                      ' value of currently carried items
DIM room%                      ' current room
DIM quitFactor!                ' QU in original (float for odd endings)
DIM kills%                     ' MK monsters killed
DIM chestOpened%               ' BOX flag (0/1)

' Parser scratch
DIM verb3$, noun3$

'---------------- Entry ----------------
SUB Main
  RANDOMIZE TIMER
  GameInit
  MainLoop
END SUB

'==============================================================
' Helper: trim spaces/tabs from both ends (portable)
'==============================================================
FUNCTION TrimSpaces$(s$)
  LOCAL t$, ch$
  t$ = s$
  ' left trim
  DO WHILE LEN(t$) > 0
    ch$ = MID$(t$, 1, 1)
    IF ch$ <> " " AND ch$ <> CHR$(9) THEN EXIT DO
    t$ = MID$(t$, 2)
  LOOP
  ' right trim
  DO WHILE LEN(t$) > 0
    ch$ = RIGHT$(t$, 1)
    IF ch$ <> " " AND ch$ <> CHR$(9) THEN EXIT DO
    t$ = LEFT$(t$, LEN(t$) - 1)
  LOOP
  TrimSpaces$ = t$
END FUNCTION

FUNCTION Tidy$(s$)
  Tidy$ = TrimSpaces$(s$)
END FUNCTION

'==============================================================
' Input parsing
'==============================================================
FUNCTION GetCommand%(BYREF v3$, BYREF n3$)
  LOCAL cmdline$, sp%
  v3$ = "": n3$ = ""
  PRINT
  INPUT "What do you want to do"; cmdline$
  cmdline$ = UCASE$(TrimSpaces$(cmdline$))
  IF cmdline$ = "" THEN GetCommand% = 0 : EXIT FUNCTION

  ' Split into tokens (first two words)
  sp% = INSTR(cmdline$, " ")
  IF sp% = 0 THEN
    v3$ = LEFT$(cmdline$, 3)
    IF v3$ = "HEL" OR v3$ = "QUI" THEN
      GetCommand% = 1
    ELSE
      PRINT cmdline$; " IS JUST ONE WORD"
      PRINT TAB(4); "I NEED TWO"
      GetCommand% = 0
    ENDIF
    EXIT FUNCTION
  ENDIF

  v3$ = LEFT$(LEFT$(cmdline$, sp% - 1), 3)
  n3$ = LEFT$(MID$(cmdline$, sp% + 1), 3)
  n3$ = TrimSpaces$(n3$)
  IF n3$ = "" THEN
    PRINT TAB(6); "BY ITSELF, "; v3$; " CAN'T BE ACTED ON"
    GetCommand% = 0
  ELSE
    GetCommand% = 1
  ENDIF
END FUNCTION

'==============================================================
' Main game loop (report → input → action)
'==============================================================
SUB MainLoop
  DO
    PAUSE DELAY_SHORT
    CLS
    DescribeRoom

    ' Objects visible?
    IF rooms%(room%, DIR_ITEM1) <> 0 OR rooms%(room%, DIR_ITEM2) <> 0 OR rooms%(room%, DIR_ITEM3) <> 0 THEN
      DescribeObjects
    ENDIF

    ' Locked door notice
    IF rooms%(room%, DIR_ITEM1) > 98 THEN
      PRINT "One of the doors is locked"
      PRINT "preventing you from exploring"
      PRINT "further"
    ENDIF

    ' Monster present?
    IF rooms%(room%, DIR_MON) <> 0 THEN
      PRINT TAB(3); "LOOK OUT!"
      PRINT "THERE IS A "; monsterName$(rooms%(room%, DIR_MON)); " HERE!"
      IF RND() > 0.7 AND rooms%(room%, DIR_MON) <> 1 THEN
        PRINT "THE "; monsterName$(rooms%(room%, DIR_MON)); " ATTACKS!"
        DoFight
        GOTO NextTurn
      ENDIF
    ENDIF

    ' Attribute drift (fatigue)
    DegradeStat pStr%
    DegradeStat pCha%
    DegradeStat pDex%
    DegradeStat pInt%
    DegradeStat pWis%
    DegradeStat pCon%

    ' Whisper hint if dwarf blocks in room 16
    IF (RND() > 0.84) AND room% = 16 AND rooms%(room%, DIR_MON) = 1 THEN
      PRINT : PRINT "You hear a whispered voice warning you:"
      PRINT "'You must do something about the dwarf'"
    ENDIF

    ' Show attributes
    PRINT : PRINT "Your attributes are:"
    PRINT TAB(4); "Strength - "; pStr%; "  Charisma - "; pCha%
    PRINT TAB(4); "Dexterity - "; pDex%; "  Intelligence - "; pInt%
    PRINT TAB(4); "Wisdom - "; pWis%; "  Constitution - "; pCon%

    ' Exhaustion ends adventure (any zero)
    IF pStr% * pCha% * pDex% * pInt% * pWis% * pCon% = 0 THEN
      PRINT "You are exhausted..."
      PRINT "so this adventure must end"
      quitFactor! = 2
      EndGame
    ENDIF

    ' Inventory
    ShowInventory

    ' Input & dispatch
    IF GetCommand%(verb3$, noun3$) = 0 THEN GOTO NextTurn

    ' Rooms 8 or 34: locked door prevents exploring unless UNL
    IF (room% = 8 OR room% = 34) AND rooms%(room%, DIR_ITEM1) > 98 AND verb3$ <> "UNL" THEN
      PRINT TAB(4); "** The doors are locked **"
      GOTO NextTurn
    ENDIF

    SELECT CASE verb3$
      CASE "HEL"   : PRINT "NO HELP FOR MORTALS IN THIS GAME!": PRINT "...although reading and drinking": PRINT "may help..."
      CASE "QUI"   : quitFactor! = 4 : EndGame
      CASE "STA","KIL","FIG","KIC","PUN","SLA","ATT"
                   : DoFight

      CASE "GO","MOV","CLI","RUN","WAL"
                   : DoMove noun3$

      CASE "TAK","GET","STE","LIF"
                   : DoTake noun3$

      CASE "DRO","PUT","THR","BRE"
                   : DoDrop verb3$, noun3$

      CASE "UNL"   : DoUnlock
      CASE "OPE"   : DoOpen noun3$
      CASE "REA"   : DoRead
      CASE "DRI","SWA"
                   : DoDrink noun3$

      CASE "BRI","PAY"
                   : DoBribe

      CASE ELSE
        SELECT CASE INT(RND()*3)
          CASE 0: PRINT "IT WOULD NOT BE WISE TO "; UCASE$(verb3$ + " " + noun3$)
          CASE 1: PRINT "ONLY A FOOL WOULD TRY TO "; UCASE$(verb3$ + " " + noun3$)
          CASE 2: PRINT "I DON'T UNDERSTAND '"; UCASE$(verb3$ + " " + noun3$); "'"
        END SELECT
    END SELECT

NextTurn:
    ' loop
  LOOP
END SUB

'==============================================================
' Movement
'==============================================================
SUB DoMove(n3$)
  ' Dwarf blocks room 16
  IF room% = 16 AND rooms%(16, DIR_MON) = 1 THEN
    PRINT : PRINT "The dwarf refuses to let"
    PRINT TAB(9); "you proceed..."
    PAUSE DELAY_MED
    EXIT SUB
  ENDIF

  LOCAL d$
  d$ = LEFT$(n3$,1)
  IF d$ = "N" AND rooms%(room%, DIR_N) = 0 THEN PRINT "You cannot go that way": EXIT SUB
  IF d$ = "S" AND rooms%(room%, DIR_S) = 0 THEN PRINT "There is no exit south": EXIT SUB
  IF d$ = "E" AND rooms%(room%, DIR_E) = 0 THEN PRINT "I see nowhere to the east to go": EXIT SUB
  IF d$ = "W" AND rooms%(room%, DIR_W) = 0 THEN PRINT "Even you cannot walk through walls": EXIT SUB
  IF d$ = "U" AND rooms%(room%, DIR_U) = 0 THEN PRINT "There is no way to move up": EXIT SUB
  IF d$ = "D" AND rooms%(room%, DIR_D) = 0 THEN PRINT "You cannot descend from here": EXIT SUB

  SELECT CASE d$
    CASE "N": room% = rooms%(room%, DIR_N)
    CASE "S": room% = rooms%(room%, DIR_S)
    CASE "E": room% = rooms%(room%, DIR_E)
    CASE "W": room% = rooms%(room%, DIR_W)
    CASE "U": room% = rooms%(room%, DIR_U)
    CASE "D": room% = rooms%(room%, DIR_D)
  END SELECT
END SUB

'==============================================================
' Take
'==============================================================
SUB DoTake(n3$)
  LOCAL carried%, j%, pick%, nm$
  carried% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) <> 0 THEN carried% = carried% + 1
  NEXT j%
  IF carried% = 5 THEN PRINT "You are already carrying your": PRINT "maximum of five objects": EXIT SUB

  IF n3$ = "CHE" THEN PRINT "It is far too heavy to lift": EXIT SUB
  IF rooms%(room%, DIR_ITEM1) = 0 AND rooms%(room%, DIR_ITEM2) = 0 AND rooms%(room%, DIR_ITEM3) = 0 THEN
    PRINT "I see nothing to pick up"
    EXIT SUB
  ENDIF

  pick% = 0
  IF rooms%(room%, DIR_ITEM1) <> 0 THEN
    nm$ = LEFT$(objName$(rooms%(room%, DIR_ITEM1)), 3)
    IF n3$ = LEFT$(UCASE$(nm$),3) AND rooms%(room%, DIR_ITEM1) < 99 THEN pick% = rooms%(room%, DIR_ITEM1): rooms%(room%, DIR_ITEM1) = 0
  ENDIF
  IF pick% = 0 AND rooms%(room%, DIR_ITEM2) <> 0 THEN
    nm$ = LEFT$(objName$(rooms%(room%, DIR_ITEM2)), 3)
    IF n3$ = LEFT$(UCASE$(nm$),3) AND rooms%(room%, DIR_ITEM2) < 99 THEN pick% = rooms%(room%, DIR_ITEM2): rooms%(room%, DIR_ITEM2) = 0
  ENDIF
  IF pick% = 0 AND rooms%(room%, DIR_ITEM3) <> 0 THEN
    nm$ = LEFT$(objName$(rooms%(room%, DIR_ITEM3)), 3)
    IF n3$ = LEFT$(UCASE$(nm$),3) AND rooms%(room%, DIR_ITEM3) < 99 THEN pick% = rooms%(room%, DIR_ITEM3): rooms%(room%, DIR_ITEM3) = 0
  ENDIF

  IF pick% = 0 THEN EXIT SUB

  FOR j% = 1 TO 5
    IF bag%(j%) = 0 THEN bag%(j%) = pick% : EXIT FOR
  NEXT j%
  PRINT TAB(3); ">-> YOU NOW HAVE THE "; Tidy$(objName$(pick%))
END SUB

'==============================================================
' Drop / Put / Throw / Break
'==============================================================
SUB DoDrop(v3$, n3$)
  LOCAL hasAny%, j%, targetName$, targetIdx%
  hasAny% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) <> 0 THEN hasAny% = 1
  NEXT j%
  IF hasAny% = 0 THEN PRINT "You are not carrying anything": EXIT SUB

  IF rooms%(room%, DIR_ITEM1) <> 0 AND rooms%(room%, DIR_ITEM2) <> 0 AND rooms%(room%, DIR_ITEM3) <> 0 THEN
    PRINT "This room already holds its"
    PRINT TAB(6); "maximum objects"
    EXIT SUB
  ENDIF

  targetName$ = "": targetIdx% = 0
  FOR j% = 1 TO 18
    IF LEFT$(UCASE$(objName$(j%)),3) = n3$ THEN targetName$ = objName$(j%): targetIdx% = j%
  NEXT j%
  IF targetName$ = "" THEN
    PRINT TAB(3); "How can you when you're"
    PRINT TAB(5); "not holding it?"
    EXIT SUB
  ENDIF

  ' remove from bag if present
  FOR j% = 1 TO 5
    IF bag%(j%) = targetIdx% THEN bag%(j%) = 0
  NEXT j%

  ' place into room slots (first empty)
  IF rooms%(room%, DIR_ITEM1) = 0 THEN
    rooms%(room%, DIR_ITEM1) = targetIdx%
  ELSEIF rooms%(room%, DIR_ITEM2) = 0 THEN
    rooms%(room%, DIR_ITEM2) = targetIdx%
  ELSE
    rooms%(room%, DIR_ITEM3) = targetIdx%
  ENDIF

  SELECT CASE v3$
    CASE "DRO": PRINT "YOU HAVE DROPPED THE "; Tidy$(targetName$)
    CASE "PUT": PRINT "YOU HAVE PUT THE "; Tidy$(targetName$); " DOWN"
    CASE "THR": PRINT "WITH A MIGHTY HEAVE, YOU": PRINT "THROW THE "; Tidy$(targetName$); " AWAY"
    CASE "BRE": PRINT "YOU HAVE BROKEN THE "; Tidy$(targetName$)
  END SELECT
END SUB

'==============================================================
' Fight
'==============================================================
SUB DoFight
  ' Dwarf refuses to fight
  IF rooms%(room%, DIR_MON) = 1 THEN
    PRINT "The dwarf refuses to fight"
    PRINT "and his magic protects him"
    EXIT SUB
  ENDIF

  IF rooms%(room%, DIR_MON) = 0 THEN
    IF RND() < 0.5 THEN PRINT "There is nothing to fight here" ELSE PRINT "You can't fight empty air!"
    EXIT SUB
  ENDIF

  LOCAL mon$
  mon$ = monsterName$(rooms%(room%, DIR_MON))

  ' Monster attributes (3d6 + 3)
  LOCAL mStr%, mCha%, mDex%, mInt%, mWis%, mCon%
  mStr% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  mCha% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  mDex% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  mInt% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  mWis% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  mCon% = INT(RND()*6 + RND()*6 + RND()*6) + 3

  PRINT "------------------------------------------"
  PRINT "YOUR OPPONENT IS A "; mon$
  LOCAL monTally%, humanTally%
  monTally% = 0 : humanTally% = 0

  LOCAL danger%
  danger% = mStr% * (INT(RND()*6) + 1)
  PRINT : PRINT "---------------------------------------"
  PRINT "THE "; mon$; "'S DANGER LEVEL IS "; danger%
  PAUSE DELAY_LONG

  ' Weapon hints
  LOCAL j%, usableCount%, choice%
  FOR j% = 1 TO 5
    weaponHint%(j%) = 0
    SELECT CASE bag%(j%)
      CASE 1:  PRINT "YOUR AXE COULD BE HANDY":                      weaponHint%(j%) = 1
      CASE 2:  PRINT "YOUR SKILL WITH THE SWORD": PRINT "MAY STAND YOU IN GOOD STEAD": weaponHint%(j%) = 2
      CASE 3:  PRINT "YOUR DAGGER IS USEFUL AGAINST "; mon$; "S":    weaponHint%(j%) = 3
      CASE 4:  PRINT "THE MACE WILL MAKE SHORT WORK OF IT":           weaponHint%(j%) = 4
      CASE 5:  PRINT "YOUR QUARTERSTAFF WILL GIVE": PRINT "IT NO QUARTER...": weaponHint%(j%) = 5
      CASE 6:  PRINT "SWINGING YOUR MORNING STAR MAY INFLICT": PRINT "HEAVY WOUNDS ON THE "; mon$: weaponHint%(j%) = 6
      CASE 7:  PRINT "A FALCHION IS A USEFUL WEAPON":                 weaponHint%(j%) = 7
    END SELECT
  NEXT j%

  usableCount% = 0
  FOR j% = 1 TO 5
    IF weaponHint%(j%) <> 0 THEN usableCount% = usableCount% + 1
  NEXT j%

  IF usableCount% = 0 THEN
    PRINT "YOU MUST FIGHT THE "; mon$; " WITH"
    PRINT "YOUR BARE HANDS"
  ELSEIF usableCount% = 1 THEN
    FOR j% = 1 TO 5: IF weaponHint%(j%) <> 0 THEN usableCount% = weaponHint%(j%): EXIT FOR: NEXT j%
    PRINT "YOU MUST FIGHT WITH YOUR "; Tidy$(objName$(usableCount%))
    danger% = INT(danger% * 2 / usableCount%)
  ELSE
    PRINT "CHOOSE YOUR WEAPON:"
    FOR j% = 1 TO 5
      IF bag%(j%) <> 0 THEN PRINT j%; " - "; Tidy$(objName$(bag%(j%)))
    NEXT j%
    DO
      INPUT "Enter the number to choose"; choice%
    LOOP UNTIL choice% >= 1 AND choice% <= 5 AND bag%(choice%) <> 0
    PRINT "RIGHT, SO YOU CHOOSE TO FIGHT"
    PRINT "WITH THE "; Tidy$(objName$(bag%(choice%)))
    danger% = INT(danger% * 2 / choice%)
  ENDIF

  PAUSE DELAY_LONG

  PRINT "THE "; mon$; " HAS THE FOLLOWING ATTRIBUTES:"
  PRINT "1 - Strength "; mStr%; "  2 - Charisma "; mCha%
  PRINT "3 - Dexterity "; mDex%; " 4 - Intelligence "; mInt%
  PRINT "5 - Wisdom "; mWis%; "    6 - Constitution "; mCon%
  PRINT : PRINT "YOUR ATTRIBUTES ARE:"
  PRINT "1 - Strength "; pStr%; "  2 - Charisma "; pCha%
  PRINT "3 - Dexterity "; pDex%; " 4 - Intelligence "; pInt%
  PRINT "5 - Wisdom "; pWis%; "    6 - Constitution "; pCon%

PRINT : PRINT "Which two attributes will you fight with (1-6)?"
LOCAL z%, q%
DO
  PRINT "Enter first attribute (1-6):"
  INPUT z%
  PRINT "Enter second attribute (1-6, different from first):"
  INPUT q%
LOOP UNTIL z% >= 1 AND z% <= 6 AND q% >= 1 AND q% <= 6 AND z% <> q%

  IF z% = 1 OR q% = 1 THEN monTally% = monTally% + mStr%: humanTally% = humanTally% + pStr%
  IF z% = 2 OR q% = 2 THEN monTally% = monTally% + mCha%: humanTally% = humanTally% + pCha%
  IF z% = 3 OR q% = 3 THEN monTally% = monTally% + mDex%: humanTally% = humanTally% + pDex%
  IF z% = 4 OR q% = 4 THEN monTally% = monTally% + mInt%: humanTally% = humanTally% + pInt%
  IF z% = 5 OR q% = 5 THEN monTally% = monTally% + mWis%: humanTally% = humanTally% + pWis%
  IF z% = 6 OR q% = 6 THEN monTally% = monTally% + mCon%: humanTally% = humanTally% + pCon%

  IF humanTally% = monTally% THEN PRINT TAB(10); "You are evenly matched" ELSE
    PRINT "IT LOOKS LIKE THE ODDS"
    PRINT "ARE IN FAVOR OF "; : IF humanTally% > monTally% THEN PRINT "YOU" ELSE PRINT "THE "; mon$
  ENDIF

  DO
    PRINT "THE "; mon$; " - "; monTally%
    PRINT "YOU - "; humanTally%
    PRINT
    LOCAL k%
    k% = INT(RND()*7)
    SELECT CASE k%
      CASE 0: PRINT "You struck a splendid blow!": monTally% = monTally% - 1
      CASE 1: PRINT "THE "; mon$; " STRIKES OUT": humanTally% = humanTally% - 3: pStr% = pStr% - 1: pCha% = pCha% - 1
      CASE 2: PRINT "YOU DRAW THE "; mon$; "'S BLOOD": monTally% = monTally% - 1
      CASE 3: PRINT "You are wounded!!": humanTally% = humanTally% - (INT(RND()*3) + 1): pDex% = pDex% - 1
      CASE 4: PRINT "THE "; mon$; " IS TIRING": monTally% = monTally% - 1
      CASE 5: PRINT "You are bleeding...": humanTally% = humanTally% - 2: pWis% = pWis% - 1: pCon% = pCon% - 1
      CASE 6: PRINT "YOU WOUND THE "; mon$: monTally% = monTally% - 1
    END SELECT
    PAUSE DELAY_MED
  LOOP WHILE RND() > 0.25 AND humanTally% > 0 AND monTally% > 0

  IF humanTally% > monTally% THEN
    PRINT "YOU HAVE SLAIN THE "; mon$
    kills% = kills% + 1
  ELSE
    PRINT "THE "; mon$; " GOT THE BETTER OF"
    PRINT "YOU THAT TIME..."
    IF z% = 1 OR q% = 1 THEN pStr% = 4 * INT(pStr% / 5)
    IF z% = 2 OR q% = 2 THEN pCha% = 3 * INT(pCha% / 4)
    IF z% = 3 OR q% = 3 THEN pDex% = 6 * INT(pDex% / 7)
    IF z% = 4 OR q% = 4 THEN pInt% = 2 * INT(pInt% / 3)
    IF z% = 5 OR q% = 5 THEN pWis% = 5 * INT(pWis% / 6)
    IF z% = 6 OR q% = 6 THEN pCon% = INT(pCon% / 2)
  ENDIF

  rooms%(room%, DIR_MON) = 0
END SUB

'==============================================================
' Unlock doors (rooms 8 or 34)
'==============================================================
SUB DoUnlock
  IF NOT ((room% = 8 OR room% = 34) AND rooms%(room%, DIR_ITEM1) >= 99) THEN
    PRINT "There is no locked door in this room"
    EXIT SUB
  ENDIF

  LOCAL have%, slot%, j%
  have% = 0: slot% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) = 17 THEN have% = 1: slot% = j%      ' silver
    IF bag%(j%) = 18 THEN have% = 2: slot% = j%      ' golden
  NEXT j%
  IF have% = 0 THEN PRINT "You do not have a key!": EXIT SUB
  IF (have% = 2 AND room% = 8) OR (have% = 1 AND room% = 34) THEN
    PRINT "That key does not fit this door"
    EXIT SUB
  ENDIF

  PRINT "There is a creak as the key turns"
  PAUSE DELAY_LONG
  PRINT ".....THE DOOR IS NOW UNLOCKED..."
  rooms%(room%, DIR_ITEM1) = 0
  bag%(slot%) = 0
END SUB

'==============================================================
' Open chest (CHE) in rooms 13 or 40
'==============================================================
SUB DoOpen(n3$)
  IF n3$ <> "CHE" THEN PRINT "THAT WOULD NOT BE WISE": EXIT SUB
  IF room% <> 13 AND room% <> 40 THEN PRINT "I CANNOT SEE ANYTHING TO OPEN HERE": EXIT SUB

  IF chestOpened% = 1 THEN
    IF RND() > 0.6 THEN PRINT TAB(4); "It holds nothing but dust..." ELSE PRINT "IT IS EMPTY!"
    EXIT SUB
  ENDIF

  IF room% = 13 OR chestOpened% = 1 THEN PRINT "IT IS EMPTY!": EXIT SUB

  PRINT "INSIDE YOU FIND A PARCHMENT, WITH"
  PRINT "THE FOLLOWING MESSAGE: 'A little"
  PRINT "man can be bound by gold'"
  chestOpened% = 1
END SUB

'==============================================================
' Read scroll (must carry item 12)
'==============================================================
SUB DoRead
  LOCAL hasScroll%, j%
  hasScroll% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) = 12 THEN hasScroll% = 1
  NEXT j%
  IF hasScroll% = 0 THEN PRINT "You are not holding anything": PRINT "which you can read": EXIT SUB
  SELECT CASE INT(RND()*3)
    CASE 0: PRINT "It says 'THE LOCKS NEED SPECIAL KEYS'"
    CASE 1: PRINT "The scroll reads:'CHESTS CAN CONTAIN AID'"
    CASE 2: PRINT "It says 'THE AMULET IS IMPORTANT'"
  END SELECT
END SUB

'==============================================================
' Drink potion (must carry item 13)
'==============================================================
SUB DoDrink(n3$)
  LOCAL slot%, j%
  slot% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) = 13 THEN slot% = j%
  NEXT j%
  IF slot% = 0 THEN PRINT "YOU CAN'T DRINK "; n3$: EXIT SUB
  PRINT "You are instantly filled with"
  PRINT "healing, and your strength is restored"
  PRINT "The bottle holding the potion"
  PRINT "magically fades from view..."
  pStr% = 20
  bag%(slot%) = 0
END SUB

'==============================================================
' Bribe dwarf (monster #1). Wants amulet (item 9).
'==============================================================
SUB DoBribe
  IF rooms%(room%, DIR_MON) <> 1 THEN
    PRINT "YOU SHOULDN'T TRY THAT"
    IF rooms%(room%, DIR_MON) <> 0 THEN PRINT "WITH A "; monsterName$(rooms%(room%, DIR_MON))
    EXIT SUB
  ENDIF

  PRINT "He demands the amulet!"
  LOCAL slot%, j%
  slot% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) = 9 THEN slot% = j%
  NEXT j%

  IF slot% <> 0 THEN
    PRINT "Lucky for you that you had it!"
    bag%(slot%) = 0
    rooms%(room%, DIR_MON) = 0
    EXIT SUB
  ENDIF

  PRINT "YOU DO NOT HAVE IT..."
  PAUSE DELAY_MED
  IF RND() > 0.5 THEN
    PRINT "HE WOULD ACCEPT ANYTHING"
    PRINT "THAT HE REALLY WANTS"
  ELSE
    PRINT "HE DECIDES, HOWEVER, TO ACCEPT"
    PRINT "A 'GIFT' OF ";
    slot% = 0
    FOR j% = 1 TO 5
      IF bag%(j%) <> 0 THEN slot% = j%
    NEXT j%
    IF slot% = 0 THEN
      PRINT "ANYTHING VALUABLE"
      PRINT : PRINT "BUT YOU HAVE NOTHING"
      PRINT "AND SO HE KILLS YOU!!"
      quitFactor! = 3
      VictoryOrQuit
    ELSE
      PRINT "THE "; Tidy$(objName$(bag%(slot%)))
      bag%(slot%) = 0
      rooms%(room%, DIR_MON) = 0
    ENDIF
  ENDIF
END SUB

'==============================================================
' Report: room description (includes some lethal rooms & endings)
'==============================================================
SUB DescribeRoom
  IF room% <= 11 THEN
    SELECT CASE room%
      CASE 1
        PRINT "You are out on the battlements of the"
        PRINT "chateau. There is only one way back"

      CASE 2
        PRINT "This is an eerie room, where once"
        PRINT "magicians convorted with evil"
        PRINT "sprites and werebeasts..."
        PRINT "Exits lead in three directions"
        PRINT "An evil smell comes from the south"

      CASE 3
        PRINT "An old straw mattress lies in one"
        PRINT "corner...it has been ripped apart to"
        PRINT "find any treasure which was hidden in it"
        PRINT "Light comes fitfully from a window to"
        PRINT "the north, and around the doors to"
        PRINT "south, east and west"

      CASE 4
        PRINT "This wooden-panelled room makes"
        PRINT "you feel damp and uncomfortable"
        IF RND() > .5 THEN PRINT "A mouse scampers across the floor" ELSE PRINT "A bat flits across the ceiling"
        PRINT "There are three doors leading"
        PRINT "from this room, one made of iron"
        PRINT "Your sixth sense warns you to"
        PRINT "choose carefully..."

      CASE 5
        PRINT "You ignore your intuition..."
        PRINT "A Spell of Living Stone, primed"
        PRINT "to trap the first intruder has"
        PRINT "been set on you...with your last"
        PRINT "seconds of life you have time"
        PRINT "only to feel profound regret..."
        ScoreThenEnd 50, 0

      CASE 6
        PRINT "You are in an L-shaped room"
        PRINT "Heavy parchment lines the walls"
        PRINT "You can see through an archway"
        PRINT "to the east...but that is not"
        PRINT "the only exit from this room"

      CASE 7
        PRINT "There is an archway to the west,"
        PRINT "leading to an L-shaped room"
        PRINT "a door leads in the opposite direction"

      CASE 8
        PRINT "This must be the Chateau's main kitchen"
        PRINT "but any food left here has long"
        PRINT "rotted away..."
        PRINT
        PRINT "A door leads to the north, and"
        PRINT "there is one to the west"

      CASE 9
        PRINT "You find yourself in a small,"
        PRINT "room...which makes you feel"
        PRINT "claustrophobic...": PRINT
        PRINT "There is a picture of a black"
        PRINT "dragon painted on the north"
        PRINT "wall, above the door..."

      CASE 10
        PRINT "A stairwell ends in this room, which"
        PRINT "more of a landing than a real"
        PRINT "room. The door to the north is"
        PRINT "made of iron, which has rusted"
        PRINT "over the centuries..."

      CASE 11
        PRINT "There is a stone archway to the north,"
        PRINT "You are in a very long room."
        PRINT : PRINT "Fresh air blows down some stairs"
        PRINT "and rich red drapes cover"
        PRINT "the walls...You can see doors"
        PRINT "to the south and east"
    END SELECT
    EXIT SUB
  ENDIF

  IF room% <= 22 THEN
    SELECT CASE room% - 11
      CASE 1
        PRINT "You have entered a room filled"
        PRINT "with swirling, choking smoke.": PRINT
        PRINT "You must leave quickly to remain"
        PRINT "healthy enough to continue"
        PRINT "your chosen quest..."

      CASE 2
        PRINT "There is a mirror in the corner"
        PRINT "you glance at it, and feel"
        PRINT "suddenly very ill.": PRINT
        PRINT "You realise the looking-glass has"
        PRINT "been enfused with a Spell of Charisma"
        PRINT "Reduction...oh dear..."
        pCha% = pCha% - 1

      CASE 3
        PRINT "This room is richly finished, with"
        PRINT "a white marble floor. Strange"
        PRINT "footprints lead to the two doors"
        PRINT "from this room...Dare you follow them?"

      CASE 4
        PRINT "You are in a long, long"
        PRINT "hallway, lined on each side"
        PRINT "with rich, red drapes..."
        PRINT : PRINT "They are parted halfway down"
        PRINT "the east wall where there is a door"

      CASE 5
        PRINT "Someone has spent a long time"
        PRINT "painting this room a bright yellow..."
        PRINT : PRINT "You remember reading that"
        PRINT "yellow Is the Ancient Oracle's"
        PRINT "Color of Warning..."

      CASE 6
        PRINT "As you stumble down the ladder"
        PRINT "you fall into the room. The ladder"
        PRINT "crashes down behind you...there"
        PRINT "is now no way back..."
        PRINT : PRINT "A small door leads east from"
        PRINT "this very cramped room..."

      CASE 7
        PRINT "You find yourself in a Hall of"
        PRINT "Mirrors...and see yourself"
        PRINT "reflected a hundred times or"
        PRINT "more...Through the bright glare"
        PRINT "you can make out doors in all"
        PRINT "directions...You notice the"
        PRINT "mirrors around the east door"
        PRINT "are heavily tarnished..."

      CASE 8
        PRINT "You find yourself in a long corridor"
        PAUSE DELAY_MED
        PRINT "Your footsteps echo as you walk"

      CASE 9
        PRINT "You feel as you've been wandering"
        PRINT "around this chateau for ever..."
        PRINT "and you begin to despair of ever"
        PRINT "escaping..."
        PRINT : PRINT "Still, you can't get too depressed, but"
        PRINT "must struggle on. Looking around, you"
        PRINT "see you are in a room which has a"
        PRINT "heavy timbered ceiling, and white"
        PRINT "roughly-finished walls..."
        PRINT : PRINT "There are two doors..."
        PAUSE DELAY_MED

      CASE 10
        PRINT "You are in a small alcove. You"
        PRINT "look around...but can see nothing in"
        PRINT "gloom...perhaps if you wait a"
        PRINT "while your eyes will adjust to the"
        PRINT "murky dark of this alcove..."
        PAUSE 2000

      CASE 11
        PRINT "A dried-up fountain stands in the"
        PRINT "center of this courtyard, which"
        PRINT "once held beautiful flowers...but"
        PRINT "have long-since died..."
    END SELECT
    EXIT SUB
  ENDIF

  IF room% <= 33 THEN
    SELECT CASE room% - 22
      CASE 1
        PRINT "The scent of dying flowers fills"
        PRINT "this brightly-lit room..."
        PRINT : PRINT "There are two exits from it.."

      CASE 2
        PRINT "This is a round stone cavern"
        PRINT "off the side of the alcove to"
        PRINT "your north..."

      CASE 3
        PRINT "You are in an enormous circular"
        PRINT "room, which looks as if it was"
        PRINT "used as a games room. Rubble covers"
        PRINT "the floor, partially blocking"
        PRINT "the only exit..."

      CASE 4
        PRINT "Through the dim mustiness of"
        PRINT "this small potting shed you can"
        PRINT "see a stairwell..."

      CASE 5
        PRINT "You begin this Adventure in a small"
        PRINT "wood outside the Chateau..."
        PAUSE 3000
        PRINT : PRINT "While out walking one day, you come"
        PRINT "across a small, ramshackle shed in"
        PRINT "the woods. Entering it, you see a"
        PRINT "hole in one corner...an old ladder"
        PRINT "leads down from the hole..."

      CASE 6
        PRINT "How wonderful! Fresh air, sunlight..."
        PAUSE DELAY_MED
        PRINT : PRINT "Birds are singing...you"
        PRINT "are free at last...."
        PRINT : PRINT
        VictoryOrQuit

      CASE 7
        PRINT "The smell came from bodies"
        PRINT "rotting in huge traps..."
        PAUSE DELAY_MED
        PRINT "One springs shut on you,"
        PRINT "trapping you forever"
        quitFactor! = 3.5
        EndGame

      CASE 8
        PRINT "You fall into a pit of flames..."
        DO : LOOP WHILE RND() > .7
        ScoreThenEnd 10, 3.4

      CASE 9
        PRINT "Aaaaahhh...you have fallen into"
        PAUSE 3000
        PRINT "a pool of acid...now you know - too"
        PRINT "late - why the mirrors were"
        PRINT "so badly tarnished"
        ScoreThenEnd 20, 3

      CASE 10
        PRINT "It's too bad you chose that exit"
        PRINT "from the alcove..."
        PAUSE 2000
        PRINT "A giant Funnel-Web Spider leaps"
        PRINT "on you...and before you can react"
        PRINT "bites you on the neck...you"
        PRINT "have 10 seconds to live..."
        LOCAL t%
        FOR t% = 10 TO 1 STEP -1
          PRINT TAB(t%); t%
          PAUSE 300
          PRINT
        NEXT t%
        ScoreThenEnd 3, 5

      CASE 11
        PRINT "A stairwell leads into this room, a"
        PRINT "poor and common hovel with many"
        PRINT "doors and exits..."
    END SELECT
    EXIT SUB
  ENDIF

  ' 34..44
  SELECT CASE room% - 33
    CASE 1
      PRINT "It is hard to see in this room,"
      PRINT "and you slip slightly on the"
      PRINT "uneven, rocky floor..."

    CASE 2
      PRINT "Horrors! This room was once"
      PRINT "the torture chamber of the Chateau.."
      PRINT : PRINT "Skeletons lie on the floor, still"
      PRINT "with chains around the bones..."

    CASE 3
      PRINT "Another room with very unpleasant"
      PRINT "memories..."
      PAUSE DELAY_MED
      PRINT : PRINT "This foul hole was used as the"
      PRINT "Chateau dungeon...."

    CASE 4
      PRINT "Oh no, this is a Gargoyle's lair..."
      PAUSE DELAY_MED
      PRINT "It has been held prisoner here for"
      PRINT "three hundred years..."
      PAUSE DELAY_MED
      PRINT : PRINT "In his frenzy he thrashes out at you..."
      PAUSE DELAY_MED
      PRINT TAB(12); "and..."
      PAUSE DELAY_MED
      PRINT "...breaks your neck!!"
      ScoreThenEnd 0, 3

    CASE 5
      PRINT "This was the Lower Dancing Hall..."
      PRINT "With doors to the north, the east"
      PRINT "and to the west, you would seem to be"
      PRINT "able to flee any danger..."
      PAUSE DELAY_MED

    CASE 6
      PRINT "This is a dingy pit at the foot of"
      PRINT "some extremely dubious-looking"
      PRINT "stairs. A door leads to the east..."

    CASE 7
      PRINT "Doors open to each compass point from"
      PRINT "the Trophy Room of the Chateau..."
      PRINT : PRINT "The heads of strange creatures shot"
      PRINT "by the ancestral owners are mounted"
      PRINT "high up on each wall..."

    CASE 8
      PRINT "You have stumbled on a secret room..."
      PAUSE DELAY_LONG
      PRINT : PRINT "Down here, eons ago, the ancient"
      PRINT "Necromancers of Thorin plied their"
      PRINT "evil craft...and the remnant of"
      PRINT "their spells hangs heavy on the air..."

    CASE 9
      PRINT "Cobwebs brush your face as you make"
      PRINT "your way through the gloom of this"
      PRINT "room of shadows..."

    CASE 10
      PRINT "This gloomy passage lies at the"
      PRINT "intersection of three rooms..."

    CASE 11
      PRINT "You are in the rear turret room, below"
      PRINT "the extreme western wall of the"
      PRINT "ancient chateau..."
  END SELECT
END SUB

'==============================================================
' Objects present text
'==============================================================
SUB DescribeObjects
  PRINT
  IF rooms%(room%, DIR_ITEM1) > 98 AND rooms%(room%, DIR_ITEM2) = 0 AND rooms%(room%, DIR_ITEM3) = 0 THEN EXIT SUB
  PRINT TAB(3); "YOU CAN SEE ";
  IF rooms%(room%, DIR_ITEM1) < 99 AND rooms%(room%, DIR_ITEM1) <> 0 THEN PRINT Tidy$(objName$(rooms%(room%, DIR_ITEM1)))
  IF rooms%(room%, DIR_ITEM2) < 99 AND rooms%(room%, DIR_ITEM2) <> 0 THEN PRINT Tidy$(objName$(rooms%(room%, DIR_ITEM2)))
  IF rooms%(room%, DIR_ITEM3) < 99 AND rooms%(room%, DIR_ITEM3) <> 0 THEN PRINT Tidy$(objName$(rooms%(room%, DIR_ITEM3)))
  PAUSE DELAY_SHORT
  PRINT
END SUB

'==============================================================
' Inventory + carried value
'==============================================================
SUB ShowInventory
  LOCAL any%, j%
  any% = 0
  FOR j% = 1 TO 5
    IF bag%(j%) <> 0 THEN any% = 1
  NEXT j%
  IF any% = 0 THEN PRINT : EXIT SUB

  cash% = 0
  PRINT : PRINT "You are carrying:"
  FOR j% = 1 TO 5
    IF bag%(j%) <> 0 THEN
      PRINT TAB(4); Tidy$(objName$(bag%(j%)))
      cash% = cash% + objValue%(bag%(j%))
    ENDIF
  NEXT j%
  IF cash% > 0 THEN PRINT TAB(8); "Total value - $"; STR$(cash%)
  PRINT
END SUB

'==============================================================
' Endings / scoring
'==============================================================
SUB VictoryOrQuit
  ScoringAndEnd 100
END SUB

SUB ScoreThenEnd(baseScore%, q!)
  LOCAL oldQ!
  oldQ! = quitFactor!
  IF q! <> 0 THEN quitFactor! = q! ELSE IF quitFactor! = 0 THEN quitFactor! = 1
  ScoringAndEnd baseScore%
  quitFactor! = oldQ!
END SUB

SUB EndGame
  ScoringAndEnd 0
END SUB

SUB ScoringAndEnd(baseScore%)
  LOCAL score!, denom!
  PRINT
  IF quitFactor! = 4 THEN
    PRINT "I did not imagine you would turn"
    PRINT TAB(5); "out to be a quitter!"
  ELSEIF baseScore% >= 100 THEN
    PRINT : PRINT "CONGRATULATIONS! You have completed"
    PRINT TAB(7); "THE ADVENTURE"
  ENDIF

  score! = baseScore%
  denom! = quitFactor! : IF denom! = 0 THEN denom! = 1
  score! = (score! + 20 * cash% + 47 * kills% + pStr% + 2 * pCha% + 3 * pDex% + 4 + pInt% + 5 * pWis% + 6 * pCon%) / denom!

  IF kills% > 0 THEN PRINT "YOU KILLED "; kills%; " MONSTERS"
  IF kills% > 0 AND cash% > 0 THEN PRINT "AND ";
  PRINT : PRINT "YOU FOUND $"; STR$(cash%); " WORTH"
  PRINT TAB(8); "OF TREASURE"
  PRINT : PRINT "Your score for this Adventure is "; INT(score! + 0.5)
  END
END SUB

'==============================================================
' Helpers
'==============================================================
SUB DegradeStat(BYREF s%)
  IF s% < 1 THEN s% = 0 ELSE IF RND() > .84 THEN s% = s% - 1
END SUB

'==============================================================
' Initialization
'==============================================================
SUB GameInit
  CLS
  PRINT "PRESS ANY KEY TO START THE ADVENTURE"
  DO : LOOP WHILE INKEY$ = ""
  RANDOMIZE TIMER
  CLS
  PRINT : PRINT "Please stand by..."

  ' Arrays
  LOCAL x%, y%
  RESTORE RoomsData
  FOR x% = 1 TO 44
    FOR y% = 1 TO 10
      READ rooms%(x%, y%)
    NEXT y%
  NEXT x%

  ' Objects & values
  RESTORE ObjectData
  LOCAL z%
  FOR z% = 1 TO 20
    READ objName$(z%), objValue%(z%)
  NEXT z%

  ' Place random treasure (object indices 1..16) into empty item slots (col 7)
  LOCAL q%
  FOR q% = 1 TO 16
    DO
      z% = INT(RND()*44) + 1
    LOOP WHILE z% = 5 OR z% = 17 OR z% = 27 OR z% = 29 OR z% = 30 OR z% = 31 OR z% = 32 OR z% = 37 OR rooms%(z%, DIR_ITEM1) <> 0
    rooms%(z%, DIR_ITEM1) = q%
  NEXT q%

  PRINT : PRINT TAB(3); "Just a few moments more..."

  ' Monsters
  RESTORE MonstersData
  LOCAL j%
  FOR j% = 1 TO 20
    READ monsterName$(j%)
    IF j% = 1 THEN
      ' dwarf placed below
    ELSE
      DO
        z% = INT(RND()*44) + 1
      LOOP WHILE z% = 5 OR z% = 16 OR z% = 17 OR z% = 27 OR z% = 29 OR z% = 30 OR z% = 31 OR z% = 32 OR z% = 37 OR rooms%(z%, DIR_MON) <> 0
      rooms%(z%, DIR_MON) = j%
    ENDIF
  NEXT j%

  ' Initial stats (3d6+3)
  pStr% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  pCha% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  pDex% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  pInt% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  pWis% = INT(RND()*6 + RND()*6 + RND()*6) + 3
  pCon% = INT(RND()*6 + RND()*6 + RND()*6) + 3

  cash% = 0
  room% = 27
  quitFactor! = 1
  kills% = 0
  chestOpened% = 0

  ' Locked doors & fixed items/monsters
  rooms%(8,  DIR_ITEM1) = 99      ' locked door i
  rooms%(34, DIR_ITEM1) = 100     ' locked door ii
  rooms%(40, DIR_ITEM1) = 20      ' chest (iron)
  rooms%(13, DIR_ITEM1) = 19      ' chest (stone)
  rooms%(16, DIR_MON)   = 1       ' dwarf in room 16
END SUB

'==============================================================
' DATA
'==============================================================
RoomsData:
' Each line: N,S,E,W,U,D, item1, monster, item2, item3
DATA 1,1,2,1,1,1,0,0,0,0     ' 1
DATA 0,29,3,1,0,0,17,0,0,0   ' 2
DATA 0,8,4,2,0,0,0,0,0,0     ' 3
DATA 0,9,5,3,0,0,0,0,0,0     ' 4
DATA 5,5,5,5,5,5,0,0,0,0     ' 5
DATA 0,11,7,30,0,0,0,0,0,0   ' 6
DATA 0,0,8,6,0,0,0,0,0,0     ' 7
DATA 3,0,0,7,0,0,99,0,0,0    ' 8
DATA 4,10,0,0,0,0,0,0,0,0    ' 9
DATA 9,0,0,0,0,39,0,0,0,0    ' 10
DATA 6,0,0,0,28,0,0,0,0,0    ' 11
DATA 0,16,13,0,0,0,0,0,0,0   ' 12
DATA 0,0,14,12,0,0,19,0,0,0  ' 13
DATA 0,18,0,13,0,0,0,0,0,0   ' 14
DATA 0,21,16,0,0,0,0,0,0,0   ' 15
DATA 12,20,19,15,0,0,0,1,0,0 ' 16
DATA 0,0,18,0,27,0,0,0,0,0   ' 17
DATA 14,19,31,17,0,0,0,0,0,0 ' 18
DATA 18,23,0,16,0,0,0,0,0,0  ' 19
DATA 16,25,0,0,0,0,0,0,0,0   ' 20
DATA 15,24,0,32,0,0,0,0,0,0  ' 21
DATA 0,26,23,0,0,0,0,0,0,0   ' 22
DATA 19,0,0,22,0,0,0,0,0,0   ' 23
DATA 21,0,0,0,0,0,0,0,0,0    ' 24
DATA 20,25,25,25,25,25,0,0,0,0 ' 25
DATA 22,0,0,0,0,33,0,0,0,0   ' 26
DATA 0,0,0,0,0,17,0,0,0,0    ' 27
DATA 0,0,0,0,0,11,0,0,0,0    ' 28
DATA 29,29,29,29,29,29,0,0,0,0 ' 29
DATA 30,30,30,30,30,30,0,0,0,0 ' 30
DATA 31,31,31,31,31,31,0,0,0,0 ' 31
DATA 32,32,32,32,32,32,0,0,0,0 ' 32
DATA 43,42,40,0,26,0,0,0,0,0 ' 33
DATA 0,38,35,0,0,0,100,0,0,0 ' 34
DATA 0,43,36,34,0,0,0,0,0,0  ' 35
DATA 0,40,37,35,0,0,0,0,0,0  ' 36
DATA 37,37,37,37,37,37,0,0,0,0 ' 37
DATA 34,0,43,39,0,0,0,0,0,0  ' 38
DATA 0,0,38,0,10,0,0,0,0,0   ' 39
DATA 36,41,44,33,0,0,20,0,0,0 ' 40
DATA 40,41,41,42,41,41,0,0,0,0 ' 41
DATA 33,42,41,42,42,42,0,0,0,0 ' 42
DATA 35,33,0,38,0,0,0,0,0,0  ' 43
DATA 0,0,0,40,0,0,18,0,0,0   ' 44

ObjectData:
DATA "AXE",0,"SWORD",0,"DAGGER",0,"MACE",0
DATA "QUARTERSTAFF",0,"MORNING STAR",0,"FALCHION",0
DATA "CRYSTAL RALL",99,"AMULET",247," EBONY RING",166,"GEMS",462,"MYSTIC SCROLL",195,"HEALING POTION",231,"DILITHIUM CRYSTALS",162,"COPPER PIECES",27,"DIADEM",141,"SILVER KEY",0,"GOLDEN KEY",0,"CHEST OF STONE",0,"CHEST MADE OF IRON",0

MonstersData:
DATA "DWARF","MONOCEROS","PARADRUS","VAMPYRE","WRNACH","GIOLLA DACKER","KRAKEN","FENRIS WOLF","CALOPUS","BASILISK","GRIMOIRE","FLYING BUFFALO","BERSERKOID","WYRM","CROWTHERWOOD","GYGAX","RAGNAROK","FOMORINE","HAFGYGR","GRENDEL"

'---------------- Launch ----------------
Main
