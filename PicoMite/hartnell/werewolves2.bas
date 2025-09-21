'werewolves2.bas
' Original code by Tim Hartnell 1983
' Updated code by Chris Stoddard 2025

'==============================================================
' WEREWOLVES AND WANDERER — UPGRADED — PicoMite BASIC Edition
' - Structured, no line numbers; OPTION EXPLICIT/BASE 1
' - Commands: N/S/E/W/U/D  F=fight  R=run  P=pick up
'             C=eat food  I=inventory/shop  M=teleport
'             T=current score peek  Q=quit
' - Features: extra monsters, richer room text, gem/treasure
'             phrasing, teleport animation, mid-fight gear loss
'==============================================================

OPTION EXPLICIT
OPTION BASE 1

'-------------- Constants --------------
CONST COL_N=1, COL_S=2, COL_E=3, COL_W=4, COL_U=5, COL_D=6, COL_CONTENT=7
CONST DELAY=450

'-------------- World / Rooms --------------
DIM rooms%(19,7)     ' exits N,S,E,W,U,D + CONTENT
DIM ro%              ' current room

'-------------- Player State --------------
DIM pName$
DIM strength%, wealth%, food%, tally%, kills%
DIM hasAxe%, hasSword%, hasAmulet%, hasArmor%, hasLight%

'-------------- Encounter scratch --------------
DIM mName$, danger%

'-------------- Temps (global utilities) --------------
DIM i%, j%, k%

'-------------- Safe trim for PicoMite --------------
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
    IF ro%=11 THEN WinGame
    MajorTurn
  LOOP
END SUB

'==============================================================
' One game turn (status, room, contents, action)
'==============================================================
SUB MajorTurn
  strength% = strength% - 5
  IF strength% < 10 THEN PRINT "WARNING, "; pName$; ", YOUR STRENGTH": PRINT "IS RUNNING LOW": PRINT
  IF strength% < 1 THEN DieAndScore

  tally% = tally% + 1

  PRINT pName$; ", YOUR STRENGTH IS "; strength%
  IF wealth% > 0 THEN PRINT "YOU HAVE $"; wealth%
  IF food%   > 0 THEN PRINT "YOUR PROVISIONS SACK HOLDS "; food%; " UNITS OF FOOD"
  IF hasArmor% THEN PRINT "YOU ARE WEARING ARMOR"

  IF hasAxe% + hasSword% + hasAmulet% > 0 THEN
    PRINT "YOU ARE CARRYING ";
    IF hasAxe%   THEN PRINT "AN AXE ";
    IF hasSword% THEN PRINT "A SWORD ";
    IF (hasAxe% OR hasSword%) AND hasAmulet% THEN PRINT "AND ";
    IF hasAmulet% THEN PRINT "THE MAGIC AMULET";
    PRINT
  ENDIF

  IF hasLight%=0 THEN
    PRINT "IT IS TOO DARK TO SEE ANYTHING"
  ELSE
    DescribeRoom
  ENDIF

  ' Room contents
  k% = rooms%(ro%, COL_CONTENT)

  IF k%=0 THEN
    ' nothing here
  ELSEIF k%>9 THEN
    IF RND()<=.5 THEN
      PRINT "THERE ARE GEMS HERE WORTH $"; k%
    ELSE
      PRINT "THERE IS TREASURE HERE WORTH $"; k%
    ENDIF
  ELSE
    PRINT:PRINT:PRINT "DANGER...THERE IS A MONSTER HERE....": PauseBeat
    SELECT CASE k%
      CASE -1: mName$="FEROCIOUS WEREWOLF"       : danger%= 5
      CASE -2: mName$="FANATICAL FLESHGORGER"    : danger%=10
      CASE -3: mName$="MALEVOLENT MALDEMER"      : danger%=15
      CASE -4: mName$="DEVASTATING ICE-DRAGON"   : danger%=20
      CASE -5: mName$="HORRENDOUS HODGEPODGER"   : danger%=25
      CASE -6: mName$="GHASTLY GRUESOMENESS"     : danger%=30
      CASE ELSE: mName$="UNKNOWN TERROR"         : danger%=12
    END SELECT
    PRINT:PRINT "IT IS A "; mName$
    PRINT:PRINT "THE DANGER LEVEL IS "; danger%; "!!"
  ENDIF

  PauseBeat
  GetCommand
END SUB

'==============================================================
' Describe room (Room 9 auto-elevator to 10)
'==============================================================
SUB DescribeRoom
  PRINT:PRINT "******************************":PRINT
  SELECT CASE ro%
    CASE 1
      PRINT "YOU ARE IN THE HALLWAY"
      IF RND()>.4 THEN PRINT "FROM THE DUST ON THE GROUND YOU CAN TELL":PRINT "NO-ONE HAS WALKED HERE FOR A LONG, LONG TIME"
      PRINT "THERE IS A DOOR TO THE SOUTH"
      PRINT "THROUGH WINDOWS TO THE NORTH YOU CAN SEE A SECRET HERB GARDEN"
    CASE 2
      PRINT "THIS IS THE AUDIENCE CHAMBER"
      IF RND()>.4 THEN PRINT "THE FADED TAPESTRIES ON THE WALL ONLY":PRINT "HINT AT THE SPLENDOR THIS ROOM ONCE HAD"
      PRINT "THERE IS A WINDOW TO THE WEST; LOOKING RIGHT THROUGH IT"
      PRINT "YOU CAN SEE THE ENTRANCE TO THE CASTLE."
    CASE 3
      PRINT "YOU ARE IN THE GREAT HALL, AN L-SHAPED ROOM"
      PRINT "THERE ARE TWO DOORS IN THIS ROOM"
      PRINT "THE WOOD PANELS ARE WARPED AND FADED..."
      IF RND()>.4 THEN PRINT "A MOUSE SCAMPERS BEHIND YOU—YOU WHIRL AROUND...NOTHING!"
    CASE 4
      PRINT "THIS IS THE MONARCH'S PRIVATE MEETING ROOM"
      IF RND()<.4 THEN PRINT "THE ECHO OF ANCIENT PLOTTING HANGS HEAVY IN THE MUSTY AIR..."
      PRINT "THERE IS A SINGLE EXIT TO THE SOUTH"
    CASE 5
      PRINT "THIS INNER HALLWAY CONTAINS A DOOR TO THE NORTH,"
      PRINT "AND ONE TO THE WEST, AND A CIRCULAR STAIRWELL PASSES THROUGH"
      IF RND()>.6 THEN PRINT "THE ROOM IS SMALL, AND UNFRIENDLY"
      PRINT "YOU CAN SEE AN ORNAMENTAL LAKE THROUGH WINDOWS TO THE SOUTH"
    CASE 6
      PRINT "YOU ARE AT THE ENTRANCE TO A FORBIDDING-LOOKING"
      PRINT "STONE CASTLE.  YOU ARE FACING EAST"
    CASE 7
      PRINT "THIS IS THE CASTLE'S KITCHEN."
      PRINT "THROUGH WINDOWS IN THE NORTH WALL YOU CAN SEE A SECRET HERB GARDEN."
      PRINT "IT HAS BEEN MANY YEARS SINCE MEALS WERE PREPARED HERE..."
      IF RND()>.4 THEN PRINT "...A RAT SCURRIES ACROSS THE FLOOR..."
    CASE 8
      PRINT "YOU ARE IN THE STORE ROOM, AMIDST SPICES,"
      PRINT "VEGETABLES, AND VAST SACKS OF FLOUR AND OTHER PROVISIONS."
      PRINT "THE AIR IS THICK WITH SPICE AND CURRY FUMES..."
    CASE 9
      PRINT "YOU HAVE ENTERED THE LIFT..."
      PauseBeat
      PRINT "IT SLOWLY DESCENDS..."
      PauseBeat
      ro% = 10
      DescribeRoom
    CASE 10
      PRINT "YOU ARE IN THE REAR VESTIBULE"
      PRINT "THERE ARE WINDOWS TO THE SOUTH; YOU CAN SEE THE ORNAMENTAL LAKE"
      PRINT "THERE IS AN EXIT TO THE EAST, AND ONE TO THE NORTH"
    CASE 11
      ' victory handled outside
    CASE 12
      PRINT "YOU ARE IN THE DANK, DARK DUNGEON"
      PRINT "THERE IS A SINGLE EXIT, A SMALL HOLE IN THE WALL TOWARDS THE WEST"
      IF RND()>.4 THEN PRINT "...A HOLLOW, DRY CHUCKLE IS HEARD FROM THE GUARD ROOM..."
    CASE 13
      PRINT "YOU ARE IN THE PRISON GUARDROOM, IN THE BASEMENT."
      PRINT "THE STAIRWELL ENDS HERE. THERE IS ONE OTHER EXIT,"
      PRINT "A SMALL HOLE IN THE EAST WALL."
      PRINT "THE AIR IS DAMP AND UNPLEASANT...A CHILL WIND RUSHES THROUGH THE STONE."
    CASE 14
      PRINT "YOU ARE IN THE MASTER BEDROOM ON THE UPPER LEVEL...."
      PRINT "WEST WINDOW: THE CASTLE ENTRANCE. NORTH WINDOW: THE SECRET HERB GARDEN."
      PRINT "DOORS LEAD TO THE EAST AND TO THE SOUTH...."
    CASE 15
      PRINT "THIS IS THE L-SHAPED UPPER HALLWAY."
      IF RND()>.4 THEN PRINT "...A MOTH FLITS NEAR THE CEILING..."
      PRINT "TO THE NORTH IS A DOOR, AND THERE IS A STAIRWELL IN THE HALL."
      PRINT "THE LAKE IS VISIBLE THROUGH THE SOUTH WINDOWS."
    CASE 16
      PRINT "THIS ROOM WAS USED AS THE CASTLE TREASURY IN BY-GONE YEARS...."
      IF RND()>.4 THEN PRINT "...A SPIDER SCAMPERS DOWN THE WALL........"
      PRINT "THERE ARE NO WINDOWS, JUST EXITS."
    CASE 17
      PRINT "OOOOH...YOU ARE IN THE CHAMBERMAIDS' BEDROOM"
      PRINT "FAINT PERFUME STILL HANGS IN THE AIR..."
      PRINT "THERE IS AN EXIT TO THE WEST AND A DOOR TO THE SOUTH...."
    CASE 18
      PRINT "THIS TINY ROOM ON THE UPPER LEVEL IS THE DRESSING CHAMBER."
      PRINT "A NORTH WINDOW LOOKS DOWN UPON THE HERB GARDEN."
      PRINT "A DOOR LEAVES TO THE SOUTH."
      IF RND()>.5 THEN PRINT "A MIRROR SHOWS YOUR DISHEVELED APPEARANCE."
    CASE 19
      PRINT "THIS IS THE SMALL ROOM OUTSIDE THE CASTLE LIFT."
      PRINT "YOU CAN SEE......................"
      PRINT "THE LAKE THROUGH THE SOUTHERN WINDOWS"
  END SELECT
END SUB

'==============================================================
' Input / command handling
'==============================================================
SUB GetCommand
  LOCAL cmd$, d$
  PRINT:PRINT "WHAT DO YOU WANT TO DO?"
  INPUT cmd$
  cmd$ = UCASE$(LEFT$(TrimSpaces$(cmd$),1))

  PRINT:PRINT:PRINT "------------------------------------":PRINT

  ' If monster present: only fight or run until resolved
  IF rooms%(ro%,COL_CONTENT) < 0 AND (cmd$<>"F" AND cmd$<>"R") THEN GetCommand: EXIT SUB

  SELECT CASE cmd$
    CASE "Q"
      ScoreAndEnd

    CASE "N","S","E","W","U","D"
      TryMove cmd$

    CASE "P"
      DoPickUp

    CASE "C"
      IF food%=0 THEN PRINT "YOU HAVE NO FOOD": PauseBeat ELSE EatFood

    CASE "I"
      DoShop

    CASE "M"
      Teleport

    CASE "T"
      PRINT "YOUR TALLY AT PRESENT IS "; (3*tally% + 5*strength% + 2*wealth% + food% + 30*kills%)
      IF RND()>.5 THEN PRINT:PRINT "YOU HAVE KILLED "; kills%; " MONSTERS SO FAR..."

    CASE "R"
      IF RND()>.7 THEN
        FailToRun
      ELSE
        INPUT "WHICH WAY DO YOU WANT TO FLEE (N/S/E/W/U/D)"; d$
        k% = 0  ' cosmetic; monster gate relies on rooms% marker
        TryMove UCASE$(LEFT$(TrimSpaces$(d$),1))
      ENDIF

    CASE "F"
      IF rooms%(ro%,COL_CONTENT) > -1 THEN
        PRINT "THERE IS NOTHING TO FIGHT HERE": PauseBeat
      ELSE
        DoFight
      ENDIF

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

SUB FailToRun
  PRINT "NO YOU MUST STAND AND FIGHT"
  PauseBeat
  DoFight
END SUB

'==============================================================
' Fight sequence (armor + weapon effects, random flavor, gear loss)
'==============================================================
SUB DoFight
  LOCAL pick%
  ' Press any key prompt
  DO WHILE INKEY$<>"": LOOP
  PRINT "PRESS ANY KEY TO FIGHT"
  DO WHILE INKEY$="": LOOP

  IF hasArmor% THEN PRINT "YOUR ARMOR INCREASES YOUR CHANCE OF SUCCESS": danger% = 3*INT(danger%/4): PauseBeat

  CLS
  FOR i%=1 TO 6: PRINT "*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*": NEXT i%

  ' Weapon selection / effect
  IF hasAxe%=0 AND hasSword%=0 THEN
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
    LOOP UNTIL pick%=1 OR pick%=2
    IF pick%=1 THEN danger% = 4*INT(danger%/5) ELSE danger% = 3*INT(danger%/4)
  ENDIF

  PRINT:PRINT
  DO
    IF RND()>.5 THEN PRINT mName$; " ATTACKS" ELSE PRINT "YOU ATTACK"
    PauseBeat

    ' Mid-fight mishaps
    IF RND()>.5 AND hasLight% THEN PRINT "YOUR TORCH WAS KNOCKED FROM YOUR HAND": hasLight%=0: PauseBeat
    IF RND()>.5 AND hasAxe%   THEN PRINT "YOU DROP YOUR AXE IN THE HEAT OF BATTLE": hasAxe%=0: danger% = 5*INT(danger%/4)
    IF RND()>.5 AND hasSword% THEN PRINT "YOUR SWORD IS KNOCKED FROM YOUR HAND!!!": hasSword%=0: danger% = 4*INT(danger%/3)

    IF RND()>.5 THEN PRINT:PRINT "YOU MANAGE TO WOUND IT": danger% = INT(5*danger%/6)

    ' Flavor bursts
    IF RND()>.95 THEN PRINT "Aaaaargh!!!": PauseBeat: PRINT "RIP! TEAR! RIP!"
    IF RND()>.90 THEN PRINT "YOU WANT TO RUN BUT YOU STAND YOUR GROUND..."
    IF RND()>.90 THEN PRINT "*&%%$#$% $%# !! @ #$$# #$@! #$ $#$"
    IF RND()>.70 THEN PRINT "WILL THIS BE A BATTLE TO THE DEATH?"
    IF RND()>.70 THEN PRINT "HIS EYES FLASH FEARFULLY"
    IF RND()>.70 THEN PRINT "BLOOD DRIPS FROM HIS CLAWS"
    IF RND()>.70 THEN PRINT "YOU SMELL THE SULPHUR ON HIS BREATH"
    IF RND()>.70 THEN PRINT "HE STRIKES WILDLY, MADLY..........."
    IF RND()>.70 THEN PRINT "YOU HAVE NEVER FOUGHT AN OPPONENT LIKE THIS!!"

    PauseBeat

    IF RND()>.5 THEN PRINT:PRINT "THE MONSTER WOUNDS YOU!": strength% = strength% - 5
  LOOP WHILE RND()>.35

  IF RND()*16 > danger% THEN
    PRINT:PRINT "AND YOU MANAGED TO KILL THE "; mName$
    kills% = kills% + 1
  ELSE
    PRINT:PRINT "THE "; mName$; " DEFEATED YOU"
    strength% = INT(strength%/2)
  ENDIF

  rooms%(ro%, COL_CONTENT) = 0
  PauseBeat: PRINT:PRINT: PauseBeat
END SUB

'==============================================================
' Pick up treasure (needs light, content>=10)
'==============================================================
SUB DoPickUp
  IF rooms%(ro%, COL_CONTENT) < 10 THEN PRINT "THERE IS NO TREASURE TO PICK UP": PauseBeat: EXIT SUB
  IF hasLight%=0 THEN PRINT "YOU CANNOT SEE WHERE IT IS": PauseBeat: EXIT SUB
  wealth% = wealth% + rooms%(ro%, COL_CONTENT)
  rooms%(ro%, COL_CONTENT) = 0
END SUB

'==============================================================
' Eat food
'==============================================================
SUB EatFood
  LOCAL q%
  CLS
  IF food%<1 THEN PRINT "YOU HAVE NO FOOD": PauseBeat: EXIT SUB
  PRINT "YOU HAVE "; food%; " UNITS OF FOOD"
  DO
    INPUT "HOW MANY DO YOU WANT TO EAT"; q%
  LOOP UNTIL q%>=0 AND q%<=food%
  food% = food% - q%
  strength% = strength% + 5*q%
  PauseBeat: CLS
END SUB

'==============================================================
' Shop / Inventory (with friendly affirmations)
'==============================================================
SUB DoShop
  LOCAL z%, q%
  PRINT "PROVISIONS & INVENTORY"
  ShowWallet
  DO
    IF wealth%<1 THEN PRINT "YOU HAVE NO MONEY": PauseBeat: EXIT SUB

    PRINT
    PRINT "YOU CAN BUY 1 - FLAMING TORCH ($15)"
    PRINT "            2 - AXE ($10)"
    PRINT "            3 - SWORD ($20)"
    PRINT "            4 - FOOD ($2 PER UNIT)"
    PRINT "            5 - MAGIC AMULET ($30)"
    PRINT "            6 - SUIT OF ARMOR ($50)"
    PRINT "            0 - TO CONTINUE ADVENTURE"

    IF hasLight% THEN PRINT "YOU HAVE A TORCH"
    IF hasAxe%   THEN PRINT "YOUR SUPPLIES NOW INCLUDE ONE AXE"
    IF hasSword% THEN PRINT "YOU SHOULD GUARD YOUR SWORD WELL"
    IF hasAmulet% THEN PRINT "YOUR AMULET WILL AID YOU IN TIMES OF STRESS"
    IF hasArmor% THEN PRINT "YOU LOOK GOOD IN ARMOR"

    INPUT "ENTER NO. OF ITEM REQUIRED"; z%
    IF z%=0 THEN CLS: EXIT SUB

    SELECT CASE z%
      CASE 1: hasLight% = 1: wealth% = wealth% - 15
      CASE 2: hasAxe%   = 1: wealth% = wealth% - 10
      CASE 3: hasSword% = 1: wealth% = wealth% - 20
      CASE 5: hasAmulet%= 1: wealth% = wealth% - 30
      CASE 6: hasArmor% = 1: wealth% = wealth% - 50
      CASE 4
        DO
          INPUT "HOW MANY UNITS OF FOOD"; q%: q% = INT(q%)
        LOOP UNTIL 2*q% <= wealth% AND q%>=0
        food% = food% + q%
        wealth% = wealth% - 2*q%
      CASE ELSE
        ' ignore
    END SELECT

    ' Anti-cheat (as per original)
    IF wealth% < 0 THEN
      PRINT "YOU HAVE TRIED TO CHEAT ME!"
      wealth%=0: hasArmor%=0: hasLight%=0: hasAxe%=0: hasSword%=0: hasAmulet%=0
      food% = INT(food%/4)
      PauseBeat
    ENDIF

    ShowWallet
  LOOP
END SUB

SUB ShowWallet
  IF wealth% > 0 THEN
    PRINT : PRINT : PRINT "YOU HAVE $"; wealth%
  ELSE
    PRINT "YOU HAVE NO MONEY"
  ENDIF
END SUB

'==============================================================
' Teleport with little star animation
'==============================================================
SUB Teleport
  LOCAL t%
  FOR j%=1 TO 30
    PRINT TAB(j%);"*"
    PAUSE 20
  NEXT j%
  DO
    t% = INT(RND()*19)+1
  LOOP WHILE t%=6 OR t%=11
  ro% = t%
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
  PRINT:PRINT "YOU'VE DONE IT!!": PauseBeat
  PRINT "THAT WAS THE EXIT FROM THE CASTLE": PauseBeat
  PRINT:PRINT "YOU HAVE SUCCEEDED, "; pName$; "!"
  PRINT:PRINT "YOU MANAGED TO GET OUT OF THE CASTLE": PauseBeat
  PRINT:PRINT "WELL DONE!": PauseBeat
  ScoreAndEnd
END SUB

SUB ScoreAndEnd
  PRINT:PRINT "YOUR SCORE IS";
  PRINT 3*tally% + 5*strength% + 2*wealth% + food% + 30*kills%
  END
END SUB

'==============================================================
' Init
'==============================================================
SUB InitGame
  LOCAL t%
  CLS
  strength% = 60 + INT(RND()*100)
  wealth%   = 30 + INT(RND()*100)
  food%     = 0
  tally%    = 0
  kills%    = 0

  hasAxe%=0: hasSword%=0: hasAmulet%=0: hasArmor%=0: hasLight%=0

  ' Room graph + content
  RESTORE RoomData
  FOR i%=1 TO 19
    FOR j%=1 TO 7
      READ rooms%(i%, j%)
    NEXT j%
  NEXT i%

  INPUT "WHAT IS YOUR NAME, EXPLORER"; pName$
  CLS

  ro% = 6      ' start outside the castle entrance

  ' Random treasures (4), skip rooms 6 & 11 and non-empty
  FOR i%=1 TO 4
    DO
      t% = INT(RND()*19)+1
    LOOP WHILE t%=6 OR t%=11 OR rooms%(t%, COL_CONTENT)<>0
    rooms%(t%, COL_CONTENT) = INT(RND()*100)+10
  NEXT i%

  ' Random monsters (6) as -1..-6
  FOR i%=1 TO 6
    DO
      t% = INT(RND()*18)+1
    LOOP WHILE t%=6 OR t%=11 OR rooms%(t%, COL_CONTENT)<>0
    rooms%(t%, COL_CONTENT) = -i%
  NEXT i%

  ' Fixed bonus treasures
  rooms%(4 , COL_CONTENT) = 100 + INT(RND()*100)
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
DATA 0,19,0,8,0,8,0 ' 9 (lift down)
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
' Utility
'==============================================================
SUB PauseBeat
  PAUSE DELAY
END SUB

'---------------- Launch ----------------
Main
