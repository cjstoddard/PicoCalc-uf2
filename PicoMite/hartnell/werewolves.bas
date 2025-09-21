'werewolves.bas
' Original code by Tim Hartnell 1983
' Updated code by Chris Stoddard 2025

'==============================================================
' WEREWOLVES AND WANDERER — PicoMite BASIC Edition (modernized)
' - Structured (no line numbers), OPTION EXPLICIT/BASE 1
' - Uses PAUSE instead of delay loops
' - Commands: N/S/E/W/U/D  F=fight  R=run  P=pick up
'             C=eat food  I=inventory/shop  M=teleport  Q=quit
' - Preserves original mechanics, treasures, monsters, scoring
'==============================================================

OPTION EXPLICIT
OPTION BASE 1

'---------------- Constants ----------------
CONST COL_N=1, COL_S=2, COL_E=3, COL_W=4, COL_U=5, COL_D=6, COL_CONTENT=7
CONST DELAY=450

'---------------- World/Room Graph ----------------
DIM rooms%(19,7)      ' exits N,S,E,W,U,D + CONTENT
DIM ro%               ' current room

'---------------- Player State ----------------
DIM pName$, strength%, wealth%, food%, tally%, kills%
DIM hasAxe%, hasSword%, hasAmulet%, hasArmor%, hasLight%

'---------------- Monster in room (via CONTENT<0) ----------------
DIM mName$, danger%

'---------------- Scratch (global) ----------------
DIM i%, j%, k%

'==============================================================
' Utilities (PicoMite-safe trim)
'==============================================================
FUNCTION TrimSpaces$(s$)
  LOCAL res$
  res$ = s$
  DO WHILE LEN(res$) > 0 AND ASC(LEFT$(res$,1)) = 32
    res$ = MID$(res$,2)
  LOOP
  DO WHILE LEN(res$) > 0 AND ASC(RIGHT$(res$,1)) = 32
    res$ = LEFT$(res$,LEN(res$)-1)
  LOOP
  TrimSpaces$ = res$
END FUNCTION

'==============================================================
' Entry
'==============================================================
SUB Main
  RANDOMIZE TIMER
  InitGame
  DO
    IF ro% = 11 THEN WinGame
    MajorTurn
  LOOP
END SUB

'==============================================================
' One game turn (status, room, contents, command)
'==============================================================
SUB MajorTurn
  strength% = strength% - 5
  IF strength% < 10 THEN PRINT "WARNING, "; pName$; ", YOUR STRENGTH IS RUNNING LOW": PRINT
  IF strength% < 1 THEN DieAndScore

  tally% = tally% + 1

  PRINT pName$; ", YOUR STRENGTH IS "; strength%
  IF wealth% > 0 THEN PRINT "YOU HAVE $ "; wealth%
  IF food%   > 0 THEN PRINT "YOUR PROVISIONS SACK HOLDS "; food%; " UNITS OF FOOD"
  IF hasArmor% THEN PRINT "YOU ARE WEARING ARMOR"

  IF hasAxe% + hasSword% + hasAmulet% > 0 THEN
    PRINT "YOU ARE CARRYING ";
    IF hasAxe% THEN PRINT "AN AXE ";
    IF hasSword% THEN PRINT "A SWORD ";
    IF (hasAxe% OR hasSword%) AND hasAmulet% THEN PRINT "AND ";
    IF hasAmulet% THEN PRINT "THE MAGIC AMULET";
    PRINT
  ENDIF

  IF hasLight% = 0 THEN
    PRINT "IT IS TOO DARK TO SEE ANYTHING"
  ELSE
    DescribeRoom
  ENDIF

  ' Content marker (treasure or monster)
  k% = rooms%(ro%, COL_CONTENT)

  IF k% = 0 THEN
    ' empty
  ELSEIF k% > 9 THEN
    PRINT "THERE IS TREASURE HERE WORTH $"; k%
  ELSE
    PRINT: PRINT "DANGER...THERE IS A MONSTER HERE..."
    PauseBeat
    SELECT CASE k%
      CASE -1: mName$="FEROCIOUS WEREWOLF": danger%=5
      CASE -2: mName$="FANATICAL FLESHGORGER": danger%=10
      CASE -3: mName$="MALEVOLENT MALDEMER": danger%=15
      CASE -4: mName$="DEVASTATING ICE-DRAGON": danger%=20
    END SELECT
    PRINT: PRINT "IT IS A "; mName$
    PRINT: PRINT "THE DANGER LEVEL IS "; danger%; "!!"
  ENDIF

  PauseBeat
  GetCommand
END SUB

'==============================================================
' Room descriptions (Room 9 auto-moves to 10 like the lift)
'==============================================================
SUB DescribeRoom
  PRINT: PRINT "**************************": PRINT
  SELECT CASE ro%
    CASE 1
      PRINT "YOU ARE IN THE HALLWAY"
      PRINT "THERE IS A DOOR TO THE SOUTH"
      PRINT "THROUGH WINDOWS TO THE NORTH YOU CAN SEE A SECRET HERB GARDEN"
    CASE 2
      PRINT "THIS IS THE AUDIENCE CHAMBER"
      PRINT "THERE IS A WINDOW TO THE WEST. BY LOOKING TO THE RIGHT"
      PRINT "THROUGH IT YOU CAN SEE THE ENTRANCE TO THE CASTLE."
      PRINT "DOORS LEAVE THIS ROOM TO THE NORTH, EAST AND SOUTH"
    CASE 3
      PRINT "YOU ARE IN THE GREAT HALL, AN L-SHAPED ROOM"
      PRINT "THERE ARE DOORS TO THE EAST AND TO THE NORTH"
      PRINT "IN THE ALCOVE IS A DOOR TO THE WEST"
    CASE 4
      PRINT "THIS IS THE MONARCH'S PRIVATE MEETING ROOM"
      PRINT "THERE IS A SINGLE EXIT TO THE SOUTH"
    CASE 5
      PRINT "THIS INNER HALLWAY CONTAINS A DOOR TO THE NORTH,"
      PRINT "AND ONE TO THE WEST, AND A CIRCULAR STAIRWELL"
      PRINT "PASSES THROUGH THE ROOM"
      PRINT "YOU CAN SEE AN ORNAMENTAL LAKE THROUGH THE"
      PRINT "WINDOWS TO THE SOUTH"
    CASE 6
      PRINT "YOU ARE AT THE ENTRANCE TO A FORBIDDING-LOOKING"
      PRINT "STONE CASTLE. YOU ARE FACING EAST"
    CASE 7
      PRINT "THIS IS THE CASTLE'S KITCHEN. THROUGH WINDOWS IN"
      PRINT "THE NORTH WALL YOU CAN SEE A SECRET HERB GARDEN."
      PRINT "A DOOR LEAVES THE KITCHEN TO THE SOUTH"
    CASE 8
      PRINT "YOU ARE IN THE STORE ROOM, AMIDST SPICES,"
      PRINT "VEGETABLES, AND VAST SACKS OF FLOUR AND"
      PRINT "OTHER PROVISIONS. THERE IS A DOOR TO THE NORTH"
      PRINT "AND ONE TO THE SOUTH"
    CASE 9
      PRINT "YOU HAVE ENTERED THE LIFT..."
      PauseBeat
      PRINT "IT SLOWLY DESCENDS..."
      PauseBeat
      ro% = 10
      DescribeRoom
    CASE 10
      PRINT "YOU ARE IN THE REAR VESTIBULE"
      PRINT "THERE ARE WINDOWS TO THE SOUTH FROM WHICH"
      PRINT "YOU CAN SEE THE ORNAMENTAL LAKE"
      PRINT "THERE IS AN EXIT TO THE EAST AND ONE TO THE NORTH"
    CASE 11
      ' exit room handled in main loop
    CASE 12
      PRINT "YOU ARE IN THE DANK, DARK DUNGEON"
      PRINT "THERE IS A SINGLE EXIT, A SMALL HOLE IN"
      PRINT "THE WALL TOWARDS THE WEST"
    CASE 13
      PRINT "YOU ARE IN THE PRISON GUARDROOM, IN THE"
      PRINT "BASEMENT OF THE CASTLE. THE STAIRWELL"
      PRINT "ENDS IN THIS ROOM. THERE IS ONE OTHER"
      PRINT "EXIT, A SMALL HOLE IN THE EAST WALL"
    CASE 14
      PRINT "YOU ARE IN THE MASTER BEDROOM ON THE UPPER"
      PRINT "LEVEL OF THE CASTLE...."
      PRINT "LOOKING DOWN FROM THE WINDOW TO THE WEST YOU"
      PRINT "CAN SEE THE ENTRANCE TO THE CASTLE, WHILE THE"
      PRINT "SECRET HERB GARDEN IS VISIBLE BELOW THE NORTH"
      PRINT "WINDOW. THERE ARE DOORS TO THE EAST AND TO THE SOUTH...."
    CASE 15
      PRINT "THIS IS THE L-SHAPED UPPER HALLWAY."
      PRINT "TO THE NORTH IS A DOOR, AND THERE IS A"
      PRINT "STAIRWELL IN THE HALL AS WELL. YOU CAN SEE"
      PRINT "THE LAKE THROUGH THE SOUTH WINDOWS"
    CASE 16
      PRINT "THIS ROOM WAS USED AS THE CASTLE TREASURY IN"
      PRINT "BY-GONE YEARS...."
      PRINT "THERE ARE NO WINDOWS, JUST EXITS TO THE"
      PRINT "NORTH AND TO THE EAST"
    CASE 17
      PRINT "OOOOH...YOU ARE IN THE CHAMBERMAIDS' BEDROOM"
      PRINT "THERE IS AN EXIT TO THE WEST AND A DOOR"
      PRINT "TO THE SOUTH...."
    CASE 18
      PRINT "THIS TINY ROOM ON THE UPPER LEVEL IS THE"
      PRINT "DRESSING CHAMBER. THERE IS A WINDOW TO THE"
      PRINT "NORTH, WITH A VIEW OF THE HERB GARDEN DOWN"
      PRINT "BELOW. A DOOR LEAVES TO THE SOUTH"
    CASE 19
      PRINT "THIS IS THE SMALL ROOM OUTSIDE THE CASTLE"
      PRINT "LIFT WHICH CAN BE ENTERED BY A DOOR TO THE NORTH"
      PRINT "ANOTHER DOOR LEADS TO THE WEST. YOU CAN SEE"
      PRINT "THE LAKE THROUGH THE SOUTHERN WINDOWS"
  END SELECT
END SUB

'==============================================================
' Input / command handling
'==============================================================
SUB GetCommand
  LOCAL cmd$, d$, t%
  PRINT: PRINT "WHAT DO YOU WANT TO DO?"
  INPUT cmd$
  cmd$ = UCASE$(LEFT$(TrimSpaces$(cmd$),1))
  PRINT: PRINT "------------------------------------": PRINT

  ' If monster is present, only F or R are allowed until resolved
  IF rooms%(ro%,COL_CONTENT) < 0 AND (cmd$<>"F" AND cmd$<>"R") THEN GetCommand : EXIT SUB

  SELECT CASE cmd$
    CASE "Q"
      ScoreAndEnd

    CASE "F"
      IF rooms%(ro%,COL_CONTENT) > -1 THEN PRINT "THERE IS NOTHING TO FIGHT HERE": PauseBeat
      IF rooms%(ro%,COL_CONTENT) < 0 THEN DoFight

    CASE "R"
      IF RND() > .7 THEN
        PRINT "NO, YOU MUST STAND AND FIGHT": PauseBeat
        DoFight
      ELSE
        INPUT "WHICH WAY DO YOU WANT TO FLEE (N/S/E/W/U/D)"; d$
        TryMove UCASE$(LEFT$(TrimSpaces$(d$),1))
      ENDIF

    CASE "P"
      DoPickUp

    CASE "I"
      DoShop

    CASE "C"
      EatFood

    CASE "M"
      ' Random teleport (original allowed this anytime)
      DO
        t% = INT(RND()*19)+1
      LOOP WHILE t%=6 OR t%=11
      ro% = t%

    CASE "N","S","E","W","U","D"
      TryMove cmd$

    CASE ELSE
      PRINT "I DON'T UNDERSTAND."
  END SELECT
END SUB

SUB TryMove(d$)
  IF d$="N" AND rooms%(ro%,COL_N)=0 THEN PRINT "NO EXIT THAT WAY": EXIT SUB
  IF d$="S" AND rooms%(ro%,COL_S)=0 THEN PRINT "THERE IS NO EXIT SOUTH": EXIT SUB
  IF d$="E" AND rooms%(ro%,COL_E)=0 THEN PRINT "YOU CANNOT GO IN THAT DIRECTION": EXIT SUB
  IF d$="W" AND rooms%(ro%,COL_W)=0 THEN PRINT "YOU CANNOT MOVE THROUGH SOLID STONE": EXIT SUB
  IF d$="U" AND rooms%(ro%,COL_U)=0 THEN PRINT "THERE IS NO WAY UP FROM HERE": EXIT SUB
  IF d$="D" AND rooms%(ro%,COL_D)=0 THEN PRINT "YOU CANNOT DESCEND FROM HERE": EXIT SUB

  SELECT CASE d$
    CASE "N": ro% = rooms%(ro%, COL_N)
    CASE "S": ro% = rooms%(ro%, COL_S)
    CASE "E": ro% = rooms%(ro%, COL_E)
    CASE "W": ro% = rooms%(ro%, COL_W)
    CASE "U": ro% = rooms%(ro%, COL_U)
    CASE "D": ro% = rooms%(ro%, COL_D)
  END SELECT
END SUB

'==============================================================
' Fight sequence
'==============================================================
SUB DoFight
  LOCAL pick%
  ' armor effect (reduce danger)
  IF hasArmor% THEN PRINT "YOUR ARMOR INCREASES YOUR CHANCE OF SUCCESS": danger% = 3*INT(danger%/4): PauseBeat

  CLS
  FOR i% = 1 TO 6: PRINT "*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*": NEXT i%

  ' weapon effect
  IF hasAxe%=0 AND hasSword% = 0 THEN
    PRINT "YOU HAVE NO WEAPONS": PRINT "YOU MUST FIGHT WITH BARE HANDS"
    danger% = INT(danger% + danger%/5)
  ELSEIF hasAxe%=1 AND hasSword%=0 THEN
    PRINT "YOU HAVE ONLY AN AXE TO FIGHT WITH"
    danger% = 4*INT(danger%/5)
  ELSEIF hasAxe%=0 AND hasSword%=1 THEN
    PRINT "YOU MUST FIGHT WITH YOUR SWORD"
    danger% = 3*INT(danger%/4)
  ELSE
    DO
      INPUT "WHICH WEAPON? 1 - AXE, 2 - SWORD"; pick%
    LOOP UNTIL pick% = 1 OR pick% = 2
    IF pick% = 1 THEN danger% = 4*INT(danger%/5) ELSE danger% = 3*INT(danger%/4)
  ENDIF

  PRINT: PRINT
  DO
    IF RND() > .5 THEN PRINT mName$; " ATTACKS" ELSE PRINT "YOU ATTACK"
    PauseBeat
    IF RND() > .5 THEN PRINT: PRINT "YOU MANAGE TO WOUND IT": danger% = INT(5*danger%/6)
    PauseBeat
    IF RND() > .5 THEN PRINT: PRINT "THE MONSTER WOUNDS YOU!": strength% = strength% - 5
  LOOP WHILE RND() > .35

  IF RND()*16 > danger% THEN
    PRINT: PRINT "AND YOU MANAGED TO KILL THE "; mName$: kills% = kills% + 1
  ELSE
    PRINT: PRINT "THE "; mName$; " DEFEATED YOU": strength% = INT(strength%/2)
  ENDIF

  rooms%(ro%, COL_CONTENT) = 0
  PRINT: PRINT
  PauseBeat
END SUB

'==============================================================
' Pick up treasure (needs light, and CONTENT>=10)
'==============================================================
SUB DoPickUp
  IF rooms%(ro%, COL_CONTENT) < 10 THEN PRINT "THERE IS NO TREASURE TO PICK UP": PauseBeat: EXIT SUB
  IF hasLight% = 0 THEN PRINT "YOU CANNOT SEE WHERE IT IS": PauseBeat: EXIT SUB
  wealth% = wealth% + rooms%(ro%, COL_CONTENT)
  rooms%(ro%, COL_CONTENT) = 0
END SUB

'==============================================================
' Eat food
'==============================================================
SUB EatFood
  LOCAL q%
  CLS
  IF food% < 1 THEN PRINT "YOU HAVE NO FOOD": PauseBeat: EXIT SUB
  PRINT "YOU HAVE "; food%; " UNITS OF FOOD"
  DO
    INPUT "HOW MANY DO YOU WANT TO EAT"; q%
  LOOP UNTIL q% >= 0 AND q% <= food%
  food% = food% - q%
  strength% = strength% + 5*q%
  PauseBeat
  CLS
END SUB

'==============================================================
' Shop / Inventory
'==============================================================
SUB DoShop
  LOCAL z%, q%
  PRINT "PROVISIONS & INVENTORY"
  ShowMoney
  DO
    IF wealth% < 1 THEN PRINT "YOU HAVE NO MONEY": PauseBeat: EXIT SUB

    PRINT
    PRINT "YOU CAN BUY 1 - FLAMING TORCH ($15)"
    PRINT "            2 - AXE ($10)"
    PRINT "            3 - SWORD ($20)"
    PRINT "            4 - FOOD ($2 PER UNIT)"
    PRINT "            5 - MAGIC AMULET ($30)"
    PRINT "            6 - SUIT OF ARMOR ($50)"
    PRINT "            0 - TO CONTINUE ADVENTURE"
    INPUT "ENTER NO. OF ITEM REQUIRED"; z%
    IF z% = 0 THEN CLS: EXIT SUB

    SELECT CASE z%
      CASE 1: hasLight% = 1: wealth% = wealth% - 15
      CASE 2: hasAxe%   = 1: wealth% = wealth% - 10
      CASE 3: hasSword% = 1: wealth% = wealth% - 20
      CASE 5: hasAmulet%= 1: wealth% = wealth% - 30
      CASE 6: hasArmor% = 1: wealth% = wealth% - 50
      CASE 4
        DO
          INPUT "HOW MANY UNITS OF FOOD"; q%: q% = INT(q%)
        LOOP UNTIL 2*q% <= wealth% AND q% >= 0
        food% = food% + q%
        wealth% = wealth% - 2*q%
      CASE ELSE
        ' ignore
    END SELECT

    ' Anti-cheat
    IF wealth% < 0 THEN
      PRINT "YOU HAVE TRIED TO CHEAT ME!"
      wealth% = 0: hasArmor% = 0: hasLight% = 0: hasAxe% = 0: hasSword% = 0: hasAmulet% = 0
      food% = INT(food%/4)
      PauseBeat
    ENDIF

    ShowMoney
  LOOP
END SUB

SUB ShowMoney
  IF wealth% > 0 THEN PRINT: PRINT: PRINT "YOU HAVE $"; wealth%
  IF wealth% = 0 THEN PRINT "YOU HAVE NO MONEY"
END SUB

'==============================================================
' Death / Victory / Scoring
'==============================================================
SUB DieAndScore
  PRINT "YOU HAVE DIED........."
  PauseBeat
  ScoreAndEnd
END SUB

SUB WinGame
  PRINT: PRINT "YOU'VE DONE IT!!": PauseBeat
  PRINT "THAT WAS THE EXIT FROM THE CASTLE": PauseBeat
  PRINT: PRINT "YOU HAVE SUCCEEDED, "; pName$; "!"
  PRINT: PRINT "YOU MANAGED TO GET OUT OF THE CASTLE": PauseBeat
  PRINT: PRINT "WELL DONE!": PauseBeat
  ScoreAndEnd
END SUB

SUB ScoreAndEnd
  PRINT: PRINT "YOUR SCORE IS";
  PRINT 3*tally% + 5*strength% + 2*wealth% + food% + 30*kills%
  END
END SUB

'==============================================================
' Init
'==============================================================
SUB InitGame
  LOCAL t%
  CLS
  strength% = 100
  wealth%   = 75
  food%     = 0
  tally%    = 0
  kills%    = 0

  hasAxe%=0: hasSword%=0: hasAmulet% = 0: hasArmor% = 0: hasLight% = 0

  ' Room graph + content
  RESTORE RoomData
  FOR i% = 1 TO 19
    FOR j% = 1 TO 7
      READ rooms%(i%, j%)
    NEXT j%
  NEXT i%

  INPUT "WHAT IS YOUR NAME, EXPLORER"; pName$
  CLS

  ro% = 6      ' start outside the castle entrance

  ' Random treasures (4), skip rooms 6 & 11 and non-empty
  FOR i% = 1 TO 4
    DO
      t% = INT(RND()*19)+1
    LOOP WHILE t%=6 OR t%=11 OR rooms%(t%, COL_CONTENT) <> 0
    rooms%(t%, COL_CONTENT) = INT(RND()*100)+10
  NEXT i%

  ' Random monsters (4) as -1..-4
  FOR i% = 1 TO 4
    DO
      t% = INT(RND()*18)+1
    LOOP WHILE t%=6 OR t%=11 OR rooms%(t%, COL_CONTENT) <> 0
    rooms%(t%, COL_CONTENT) = -i%
  NEXT i%

  ' Fixed bonus treasures in 4 and 16
  rooms%(4,  COL_CONTENT) = 100 + INT(RND()*100)
  rooms%(16, COL_CONTENT) = 100 + INT(RND()*100)
END SUB

'==============================================================
' Data (N,S,E,W,U,D,CONTENT)
'==============================================================
RoomData:
DATA 0,2,0,0,0,0,0  ' 1
DATA 1,3,3,0,0,0,0  ' 2
DATA 2,0,5,2,0,0,0  ' 3
DATA 0,5,0,0,0,0,0  ' 4
DATA 4,0,0,3,15,13,0 ' 5
DATA 0,0,1,0,0,0,0  ' 6 (start)
DATA 0,8,0,0,0,0,0  ' 7
DATA 7,10,0,0,0,0,0 ' 8
DATA 0,19,0,8,0,8,0 ' 9 (lift down to 10)
DATA 8,0,11,0,0,0,0 ' 10
DATA 0,0,10,0,0,0,0 ' 11 (exit)
DATA 0,0,0,13,0,0,0 ' 12
DATA 0,0,12,0,5,0,0 ' 13
DATA 0,15,17,0,0,0,0 ' 14
DATA 14,0,0,0,0,5,0 ' 15
DATA 17,0,19,0,0,0,0 ' 16
DATA 18,16,0,14,0,0,0 ' 17
DATA 0,17,0,0,0,0,0 ' 18
DATA 9,0,16,0,0,0,0 ' 19

'==============================================================
' Utilities
'==============================================================
SUB PauseBeat
  PAUSE DELAY
END SUB

'---------------- Launch ----------------
Main
