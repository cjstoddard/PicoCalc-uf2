'asimovian.bas
' Original code by Tim Hartnell 1983
' Updated code by Chris Stoddard 2025

'==============================================================
' AFTERMATH OF THE ASIMOVIAN DISASTER  — PicoMite BASIC Edition
' Modernized from classic line-numbered BASIC
' - No line numbers
' - Meaningful variable names
' - SUBs & FUNCTIONs instead of GOSUB/RETURN
' - PicoMite-friendly (OPTIONs, PAUSE, etc.)
'==============================================================

OPTION EXPLICIT
OPTION BASE 1

'---------------------------
' Constants / Configuration
'---------------------------
CONST DIR_NORTH = 1
CONST DIR_SOUTH = 2
CONST DIR_EAST  = 3
CONST DIR_WEST  = 4
CONST DIR_UP    = 5
CONST DIR_DOWN  = 6
CONST DIR_ITEM  = 7          ' contents: >9 treasure; 0 none; negative = monster

CONST DELAY_MS = 200

'---------------------------
' State Variables
'---------------------------
DIM rooms%(19, 7)            ' adjacency, content
DIM dangerRating%            ' FF in original
DIM killsCount%              ' MK
DIM turnCount%               ' TALLY
DIM visitRoom13Count%        ' QQ
DIM playerStrength%          ' STRENGTH
DIM playerWealth%            ' WEALTH
DIM oxygenUnits%             ' OXY
DIM hasIonGun%               ' ION (0/1)
DIM hasLaser%                ' LASER (0/1)
DIM hasTransporter%          ' TRANSPORTER (0/1)
DIM hasSuit%                 ' SUIT (0/1)
DIM hasLight%                ' LIGHT (0/1)
DIM currentRoom%             ' RO
DIM monsterName$             ' M$
DIM playerName$              ' N$

'---------------------------
' Entry Point
'---------------------------
Randomize Timer
GameInit
MainLoop
END

'==============================================================
'                 Main Game Loop
'==============================================================
SUB MainLoop
  DO
    ' Special: track visits to room 13 (radiation room)
    IF currentRoom% = 13 THEN
      visitRoom13Count% = visitRoom13Count% + 1
      IF visitRoom13Count% = 2 THEN
        PrintFinalScoreAndEnd
      ENDIF
    ENDIF

    MajorTurn
  LOOP
END SUB

'==============================================================
'                 One Turn of Status & Input
'==============================================================
SUB MajorTurn
  ' Status decay and checks
  playerStrength% = playerStrength% - 5
  IF playerStrength% < 10 THEN
    PRINT "WARNING, CAPTAIN "; playerName$; ", YOUR STRENGTH"
    PRINT "IS RUNNING LOW"
    PRINT "YOU NEED AN OXYGEN BOOST"
  ENDIF
  IF playerStrength% < 1 THEN
    PrintOxygenDeathAndEnd
  ENDIF

  turnCount% = turnCount% + 1

  PRINT "CAPTAIN "; playerName$; ", YOUR STRENGTH IS "; playerStrength%
  IF playerWealth% > 0 THEN PRINT "YOU HAVE $"; playerWealth%; " IN SOLARIAN CREDITS"
  IF oxygenUnits% > 0 THEN PRINT "YOUR RESERVE TANKS HOLD "; oxygenUnits%; " UNITS OF OXYGEN"
  IF hasSuit% = 1 THEN PRINT "YOU ARE WEARING BATTLE ARMOR"

  IF hasIonGun% = 0 AND hasLaser% = 0 AND hasTransporter% = 0 THEN
    ' nothing to print
  ELSE
    PRINT "YOU ARE CARRYING ";
    IF hasIonGun% = 1 THEN PRINT "AN ION GUN ";
    IF hasLaser% = 1 THEN PRINT "A LASER ";
    IF (hasLaser% + hasIonGun%) > 0 AND hasTransporter% = 1 THEN PRINT "AND ";
    IF hasTransporter% = 1 THEN PRINT "THE MATTER TRANSPORTER";
    PRINT
  ENDIF

  IF hasLight% = 0 THEN
    PRINT "IT IS TOO DARK TO SEE ANYTHING"
  ELSE
    DescribeCurrentRoom
  ENDIF

  ' Room contents
  LOCAL k% : k% = rooms%(currentRoom%, DIR_ITEM)
  IF k% <> 0 THEN
    IF k% > 9 THEN
      PRINT "THERE IS TREASURE HERE WORTH $"; k%
    ELSE
      PRINT : PRINT : PRINT "DANGER...THERE IS DANGER HERE...."
      PauseBeat
      SELECT CASE k%
        CASE -1: monsterName$ = "BERSERK ANDROID": dangerRating% = 5
        CASE -2: monsterName$ = "DERANGED DEL-FIEVIAN": dangerRating% = 10
        CASE -3: monsterName$ = "RAMPAGING ROBOTIC DEVICE": dangerRating% = 15
        CASE -4: monsterName$ = "SNIGGERING GREEN ALIEN": dangerRating% = 20
      END SELECT
      PRINT : PRINT "IT IS A "; monsterName$
      PRINT : PRINT "YOUR PERSONAL DANGER METER REGISTERS "; dangerRating%; "!!"
    ENDIF
  ENDIF

  PauseBeat
  PRINT : PRINT : PRINT "WHAT DO YOU WANT TO DO";
  LOCAL cmd$
  DO
    INPUT cmd$
    cmd$ = UCASE$(LEFT$(cmd$, 1))
    ' If there's an enemy, only allow F or R (fight or run)
    IF rooms%(currentRoom%, DIR_ITEM) < 0 AND cmd$ <> "F" AND cmd$ <> "R" THEN
      ' re-prompt while enemy present
    ELSE
      EXIT DO
    ENDIF
  LOOP
  PRINT : PRINT : PRINT "------------------------------------" : PRINT

  ' Commands
  SELECT CASE cmd$
    CASE "Q"
      PrintFinalScoreAndEnd

    CASE "N","S","E","W","U","D"
      IF IsBlocked(cmd$) THEN
        PRINT NoExitMessage$(cmd$)
        PauseBeat
      ELSE
        MovePlayer cmd$
      ENDIF

    CASE "R"
      ' 30% chance you fail to run → forced fight
      IF RND() > 0.7 THEN
        PRINT "NO YOU MUST STAND AND FIGHT"
        PauseBeat
        DoFight
      ELSE
        ' successful run: ask direction
        rooms%(currentRoom%, DIR_ITEM) = 0
        PRINT "WHICH WAY DO YOU WANT TO RUN";
        LOCAL dir$
        INPUT dir$
        dir$ = UCASE$(LEFT$(dir$,1))
        IF dir$="N" OR dir$="S" OR dir$="E" OR dir$="W" OR dir$="U" OR dir$="D" THEN
          IF IsBlocked(dir$) THEN
            PRINT NoExitMessage$(dir$)
            PauseBeat
          ELSE
            MovePlayer dir$
          ENDIF
        ENDIF
      ENDIF

    CASE "F"
      IF rooms%(currentRoom%, DIR_ITEM) > -1 THEN
        PRINT "THERE IS NOTHING TO FIGHT HERE"
        PauseBeat
      ELSE
        DoFight
      ENDIF

    CASE "I"
      SupplyAndroid

    CASE "B"
      IF oxygenUnits% = 0 THEN
        PRINT "YOU HAVE NO OXYGEN"
        PauseBeat
      ELSE
        ReplenishOxygen
      ENDIF

    CASE "P"
      PickupTreasure

    CASE "M"
      ' Matter transporter
      IF currentRoom% = 13 THEN
        PRINT "THAT IS NOT POSSIBLE"
        PauseBeat
      ELSE
        TeleportRandomRoom
      ENDIF

    CASE ELSE
      ' ignore
  END SELECT
END SUB

'==============================================================
'                  Movement Helpers
'==============================================================
FUNCTION IsBlocked(c$)
  SELECT CASE c$
    CASE "N": IsBlocked = (rooms%(currentRoom%, DIR_NORTH) = 0)
    CASE "S": IsBlocked = (rooms%(currentRoom%, DIR_SOUTH) = 0)
    CASE "E": IsBlocked = (rooms%(currentRoom%, DIR_EAST)  = 0)
    CASE "W": IsBlocked = (rooms%(currentRoom%, DIR_WEST)  = 0)
    CASE "U": IsBlocked = (rooms%(currentRoom%, DIR_UP)    = 0)
    CASE "D": IsBlocked = (rooms%(currentRoom%, DIR_DOWN)  = 0)
    CASE ELSE: IsBlocked = 1
  END SELECT
END FUNCTION

SUB MovePlayer(c$)
  SELECT CASE c$
    CASE "N": currentRoom% = rooms%(currentRoom%, DIR_NORTH)
    CASE "S": currentRoom% = rooms%(currentRoom%, DIR_SOUTH)
    CASE "E": currentRoom% = rooms%(currentRoom%, DIR_EAST)
    CASE "W": currentRoom% = rooms%(currentRoom%, DIR_WEST)
    CASE "U": currentRoom% = rooms%(currentRoom%, DIR_UP)
    CASE "D": currentRoom% = rooms%(currentRoom%, DIR_DOWN)
  END SELECT
END SUB

FUNCTION NoExitMessage$(c$)
  SELECT CASE c$
    CASE "N": NoExitMessage$ = "NO EXIT THAT WAY"
    CASE "S": NoExitMessage$ = "THERE IS NO EXIT SOUTH"
    CASE "E": NoExitMessage$ = "YOU CANNOT GO IN THAT DIRECTION"
    CASE "W": NoExitMessage$ = "YOU CANNOT MOVE THROUGH SOLID WALLS"
    CASE "U": NoExitMessage$ = "THERE IS NO WAY UP FROM HERE"
    CASE "D": NoExitMessage$ = "YOU CANNOT DESCEND FROM HERE"
    CASE ELSE: NoExitMessage$ = "CAN'T GO THAT WAY"
  END SELECT
END FUNCTION

'==============================================================
'                   Combat
'==============================================================
SUB DoFight
  ' Wait for any key to start
  DO WHILE INKEY$ <> "": LOOP
  PRINT "PRESS ANY KEY TO FIGHT"
  DO WHILE INKEY$ = "": LOOP

  IF hasSuit% = 1 THEN
    PRINT "YOUR SPACE-ARMOR INCREASES YOUR CHANCE OF SUCCESS"
    dangerRating% = 3 * (INT(dangerRating% / 4))
    PauseBeat
  ENDIF

  CLS
  LOCAL j%
  FOR j% = 1 TO INT(RND()*6)+1
    PRINT "*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*"
  NEXT j%
  PRINT

  ' Weapon choice modifies danger
  IF hasIonGun% = 0 AND hasLaser% = 0 THEN
    PRINT "YOU HAVE NO WEAPONS"
    PRINT "YOU MUST FIGHT WITH BARE HANDS"
    dangerRating% = INT(dangerRating% + dangerRating%/5)
  ELSEIF hasIonGun% = 1 AND hasLaser% = 0 THEN
    PRINT "YOU HAVE ONLY THE ION GUN TO FIGHT WITH"
    dangerRating% = 4 * INT(dangerRating% / 5)
  ELSEIF hasIonGun% = 0 AND hasLaser% = 1 THEN
    PRINT "YOU MUST FIGHT WITH YOUR LASER"
    dangerRating% = 3 * INT(dangerRating% / 4)
  ELSE
    LOCAL wSel%
    DO
      INPUT "WHICH WEAPON? 1 - ION GUN, 2 - LASER "; wSel%
    LOOP UNTIL wSel% = 1 OR wSel% = 2
    IF wSel% = 1 THEN dangerRating% = 4 * INT(dangerRating% / 5)
    IF wSel% = 2 THEN dangerRating% = 3 * INT(dangerRating% / 4)
  ENDIF

  PRINT : PRINT
  DO
    IF RND() > 0.5 THEN PRINT monsterName$; " ATTACKS" ELSE PRINT "YOU ATTACK"
    PauseBeat

    IF RND() > 0.5 THEN
      PRINT : PRINT "YOU GET THE "; monsterName$; " A GLANCING BLOW"
      dangerRating% = INT(5 * dangerRating% / 6)
    ENDIF
    PauseBeat

    IF RND() > 0.5 THEN
      PRINT : PRINT "THE "; monsterName$; " WOUNDS YOU!"
      playerStrength% = playerStrength% - 5
    ENDIF

    IF RND() <= 0.35 THEN EXIT DO
  LOOP

  IF RND()*16 > dangerRating% THEN
    PRINT : PRINT "AND YOU MANAGE TO KILL THE "; monsterName$
    killsCount% = killsCount% + 1
  ELSE
    PRINT : PRINT "THE "; monsterName$; " SERIOUSLY WOUNDS YOU"
    playerStrength% = INT(playerStrength% / 2)
  ENDIF

  ' Clear room threat and short rest
  rooms%(currentRoom%, DIR_ITEM) = 0
  BriefRest
  PRINT : PRINT
  PauseBeat
END SUB

'==============================================================
'                   Room Descriptions
'==============================================================
SUB DescribeCurrentRoom
  PRINT : PRINT "******************************" : PRINT : PRINT
  SELECT CASE currentRoom%
    CASE 1
      PRINT "YOU ARE IN THE FORMER RECREATION"
      PRINT "CENTER. EQUIPMENT FOR MUSCLE-TRAINING"
      PRINT "IN ZERO GRAVITY LITTERS THE AREA"

    CASE 2
      PRINT "THIS WAS THE REPAIR AND MAINTENANCE"
      PRINT "HOLD OF THE SHIP. YOU CAN ONLY LEAVE IT"
      PRINT "VIA THE GIANT HANGAR DOOR TO THE WEST"

    CASE 3
      PRINT "YOU ARE IN THE WRECKED HOLD OF A SPACESHIP"
      PRINT "THE CAVERNOUS INTERIOR IS LITTERED WITH"
      PRINT "FLOATING WRECKAGE, AS IF FROM SOME"
      PRINT "TERRIBLE EXPLOSION EONS AGO......"

    CASE 4
      IF RND() > .6 THEN PRINT "WHAT A SUPERB SIGHT......."
      PRINT "THE VIEW OF THE STARS FROM THIS OBSERVATION"
      PRINT "PLATFORM IS MAGNIFICENT, AS FAR AS THE EYE"
      PRINT "CAN SEE. THE SINGLE EXIT IS BACK WHERE YOU"
      PRINT "CAME FROM"

    CASE 5
      PRINT "ACRE UPON ACRE OF DRIED-UP HYDROPONIC"
      PRINT "PLANT BEDS STRETCH AROUND YOU. ONCE THIS"
      PRINT "AREA FED THE THOUSAND ON BOARD THE SHIP"
      IF RND() > .5 THEN PRINT "THE SOLAR LAMPS ARE STILL SHINING"
      IF RND() > .5 THEN PRINT "A FEW PLANTS ARE STILL ALIVE TO THE EAST"

    CASE 6
      PRINT "YOU ARE FREE. YOU HAVE MADE IT. YOUR"
      PRINT "POD SAILS FREE INTO SPACE..........."
      PrintFinalScoreAndEnd

    CASE 7
      PRINT "YOU ARE IN THE CREW'S SLEEPING QUARTERS"
      IF RND() > .5 THEN PRINT "MOST OF THE SLEEPING SHELLS ARE EMPTY"
      IF RND() > .5 THEN
        PRINT "THE FEW REMAINING CREW STIR FITFULLY"
        PRINT "IN THEIR ENDLESS, DREAMLESS SLEEP"
      ENDIF
      IF RND() > .7 THEN PRINT "THERE ARE EXITS TO THE NORTH, EAST AND WEST"

    CASE 8
      PRINT "THE FORMER PASSENGER SUSPENDED ANIMATION DORMITORY..."
      IF RND() > .5 THEN PRINT "PASSENGERS FLOAT BY AT RANDOM"
      IF RND() > .5 THEN PRINT "IT IS ENORMOUS, IT SEEMS TO GO ON FOREVER"
      IF RND() > .9 THEN PRINT "THE ONLY EXITS ARE TO THE WEST AND SOUTH"

    CASE 9
      PRINT "THIS IS THE SHIP'S HOSPITAL, WHITE AND STERILE."
      PRINT "A BUZZING SOUND, AND A STRANGE WARMTH COME FROM"
      PRINT "THE SOUTH, WHILE A CHILL IS FELT TO THE NORTH"

    CASE 10
      PRINT "FOOD FOR ALL THE CREW WAS PREPARED IN THIS"
      PRINT "GALLEY. THE REMAINS FROM PREPARATIONS OF"
      PRINT "FINAL MEAL CAN BE SEEN. DOORS LEAVE THE"
      PRINT "GALLEY TO THE SOUTH AND TO THE WEST"

    CASE 11
      PRINT "AHA...THAT LOOKS LIKE THE SPACE POD"
      PRINT "NOW, AND ITS OUTSIDE DIALS"
      PRINT "INDICATE IT IS STILL IN PERFECT CONDITION."

    CASE 12
      IF RND() > .5 THEN PRINT "THIS IS THE SHIP'S MAIN NAVIGATION ROOM"
      PRINT "STRANGE MACHINERY LINES THE WALLS, WHILE"
      PRINT "OVERHEAD, A HOLOGRAPHIC STAR MAP SLOWLY TURNS"
      PRINT "BY THE FLICKERING GREEN LIGHT YOU CAN JUST"
      PRINT "MAKE OUT EXITS";
      IF RND() > .8 THEN PRINT " TO THE SOUTH AND TO THE EAST" ELSE PRINT

    CASE 13
      IF RND() > .5 THEN PRINT "YOUR BODY TWISTS AND BURNS..."
      PRINT "YOU ARE CAUGHT IN A DEADLY RADIATION FIELD"
      PRINT "SLOWLY YOU REALISE THIS IS THE END"
      IF RND() > .5 THEN PRINT "NO MATTER WHAT YOU DO"
      IF RND() > .5 THEN PRINT "YOU ARE DOOMED TO DIE HERE"

    CASE 14
      PRINT "THIS IS THE POWER CENTER OF THE SHIP"
      PRINT "THE CHARACTERISTIC BLUE METAL LIGHT"
      PRINT "OF THE STILL-FUNCTIONING ION DRIVE"
      PRINT "FILLS THE ENGINE ROOM. THROUGH THE"
      PRINT "HAZE YOU CAN SEE DOORS"
      IF RND() > .9 THEN PRINT "TO THE NORTH AND WEST"
      IF RND() > .6 THEN PRINT "A SHAFT LEADS DOWNWARDS TO THE REPAIR CENTER"

    CASE 15
      PRINT "YOU ARE STANDING IN THE ANDROID STORAGE HOLD"
      PRINT "ROW UPON ROW OF METAL MEN STAND STIFFLY AT"
      PRINT "ATTENTION, AWAITING THE DISTINCTIVE SOUND OF"
      PRINT "THEIR LONG-DEAD CAPTAIN TO SET THEM INTO MOTION"
      PRINT "A LIGHT COMES FROM THE WEST AND THROUGH THE"
      PRINT "GRAVITY WELL SET INTO THE FLOOR"

    CASE 16
      PRINT "ANOTHER CAVERNOUS, SEEMINGLY ENDLESS HOLD,"
      PRINT "THIS ONE CRAMMED WITH GOODS FOR TRADING..."
      IF RND() > .7 THEN PRINT "RARE METALS AND VENUSIAN SCULPTURES"
      IF RND() > .8 THEN PRINT "PRESERVED SCALAPIAN DESERT FISH"
      IF RND() > .7 THEN PRINT "FLASHING EBONY SCITH STONES FROM XARIAX IV"
      IF RND() > .8 THEN PRINT "AWESOME TRADER ANT EFIGIES FROM THE QWERTYIOPIAN EMPIRE"
      IF RND() > .9 THEN PRINT "THE LIGHT IS STRONGER TO THE WEST"

    CASE 17
      PRINT "A STARK, METALLIC ROOM, REEKING OF LUBRICANTS"
      PRINT "WEAPONS LINE THE WALL, RANK UPON RANK. EXITS FOR"
      PRINT "SOLDIER ANDROIDS ARE TO THE NORTH AND THE EAST"

    CASE 18
      PRINT "ABOVE YOU IS THE GRAVITY SHAFT LEADING TO"
      PRINT "THE ENGINE ROOM. THIS IS THE SHIP REPAIR"
      PRINT "CENTER WITH EMERGENCY EXITS TO THE SOLDIER"
      PRINT "ANDROIDS STORAGE AND TO THE TRADING GOODS HOLD"

    CASE 19
      PRINT "YOU'VE STUMBLED ON THE SECRET COMMAND CENTER"
      PRINT "WHERE SCREENS BRING VIEWS FROM ALL AROUND"
      PRINT "THE SHIP. THERE ARE TWO EXITS........"
      IF RND() > .5 THEN
        PRINT "ONE OF WHICH IS THE GRAVITY WELL"
      ELSE
        PRINT "ONE OF WHICH LEADS TO THE GOODS HOLD"
      ENDIF
  END SELECT
END SUB

'==============================================================
'                   Actions
'==============================================================
SUB PickupTreasure
  IF rooms%(currentRoom%, DIR_ITEM) < 10 THEN
    PRINT "THERE IS NOTHING OF VALUE HERE"
    PauseBeat
    EXIT SUB
  ENDIF
  IF hasLight% = 0 THEN
    PRINT "YOU CANNOT SEE WHERE IT IS"
    PauseBeat
    EXIT SUB
  ENDIF
  playerWealth% = playerWealth% + rooms%(currentRoom%, DIR_ITEM)
  rooms%(currentRoom%, DIR_ITEM) = 0
END SUB

SUB ReplenishOxygen
  CLS
  IF oxygenUnits% < 1 THEN EXIT SUB
  PRINT "YOU HAVE "; oxygenUnits%; " UNITS OF OXYGEN LEFT"
  PRINT "HOW MANY DO YOU WANT TO ADD TO YOUR TANKS";
  LOCAL z%
  DO
    INPUT z%
  LOOP UNTIL z% >= 0 AND z% <= oxygenUnits%
  oxygenUnits% = INT(oxygenUnits% - z%)
  playerStrength% = INT(playerStrength% + 5*z%)
  BriefRest
  CLS
END SUB

SUB TeleportRandomRoom
  DO
    currentRoom% = INT(RND()*19) + 1
  LOOP WHILE currentRoom% = 6 OR currentRoom% = 11
END SUB

SUB SupplyAndroid
  PRINT "A SUPPLY ANDROID HAS ARRIVED"
  ShowWealth
  LOCAL choice%
  IF playerWealth% < 1 THEN
    choice% = 0
  ELSE
    PRINT "YOU CAN BUY 1 - NUCLEONIC LIGHT ($15)"
    PRINT "            2 - ION GUN ($10)"
    PRINT "            3 - LASER ($20)"
    PRINT "            4 - OXYGEN ($2 PER UNIT)"
    PRINT "            5 - MATTER TRANSPORTER ($30)"
    PRINT "            6 - COMBAT SUIT ($50)"
    PRINT "            0 - TO CONTINUE EXPLORATION"
    INPUT "ENTER NO. OF ITEM REQUIRED "; choice%
  ENDIF

  IF choice% = 0 THEN CLS : EXIT SUB

  SELECT CASE choice%
    CASE 1: hasLight%       = 1: playerWealth% = playerWealth% - 15
    CASE 2: hasIonGun%      = 1: playerWealth% = playerWealth% - 10
    CASE 3: hasLaser%       = 1: playerWealth% = playerWealth% - 20
    CASE 5: hasTransporter% = 1: playerWealth% = playerWealth% - 30
    CASE 6: hasSuit%        = 1: playerWealth% = playerWealth% - 50
    CASE 4
      LOCAL q%
      DO
        INPUT "HOW MANY UNITS OF OXYGEN "; q%
        q% = INT(q%)
        IF 2*q% > playerWealth% THEN PRINT "YOU HAVEN'T GOT ENOUGH MONEY"
      LOOP UNTIL 2*q% <= playerWealth% AND q% >= 0
      oxygenUnits%  = oxygenUnits% + q%
      playerWealth% = playerWealth% - 2*q%
    CASE ELSE
      ' ignore
  END SELECT

  IF playerWealth% < 0 THEN
    PRINT "YOU HAVE TRIED TO CHEAT ME!"
    playerWealth% = 0
    hasSuit% = 0: hasLight% = 0: hasIonGun% = 0: hasLaser% = 0: hasTransporter% = 0
    oxygenUnits% = INT(oxygenUnits% / 4)
    PauseBeat
  ENDIF

  ' Stay in shop until player chooses 0
  SupplyAndroid
END SUB

SUB ShowWealth
  IF playerWealth% > 0 THEN
    PRINT : PRINT : PRINT "YOU HAVE $"; playerWealth%; " IN SOLARIAN CREDITS"
  ELSE
    PRINT "YOU HAVE NO SOLARIAN CREDITS LEFT"
    PauseBeat
  ENDIF
  LOCAL pad%: FOR pad% = 1 TO 4: PRINT : NEXT pad%
END SUB

'==============================================================
'                   Initialization
'==============================================================
SUB GameInit
  CLS
  ' Player and run state
  playerStrength% = INT(RND()*50) + 75
  playerWealth%   = INT(RND()*50) + 50
  oxygenUnits%    = INT(RND()*16)
  turnCount% = 0
  visitRoom13Count% = 0
  killsCount% = 0

  ' Load map
  LoadRoomsData

  INPUT "WHAT IS YOUR NAME, SPACE HERO "; playerName$
  CLS

  currentRoom%   = 3   ' starting room
  hasLaser%      = 0
  hasTransporter%= 0
  hasIonGun%     = 0
  hasSuit%       = 0
  hasLight%      = 0

  ' Place valuables
  LOCAL j%, m%
  FOR j% = 1 TO 7
    DO
      m% = INT(RND()*19) + 1
    LOOP WHILE m% = 6 OR m% = 11 OR m% = 13 OR rooms%(m%, DIR_ITEM) <> 0
    rooms%(m%, DIR_ITEM) = INT(RND()*100) + 10
  NEXT j%

  ' Place monsters (two passes of four types)
  LOCAL t%
  FOR t% = 1 TO 2
    FOR j% = 1 TO 4
      DO
        m% = INT(RND()*18) + 1
      LOOP WHILE m% = 6 OR m% = 11 OR m% = 13 OR rooms%(m%, DIR_ITEM) <> 0
      rooms%(m%, DIR_ITEM) = -j%   ' -1..-4
    NEXT j%
  NEXT t%
END SUB

SUB LoadRoomsData
  LOCAL r%, c%
  RESTORE RoomsData
  FOR r% = 1 TO 19
    FOR c% = 1 TO 7
      READ rooms%(r%, c%)
    NEXT c%
  NEXT r%
  EXIT SUB

RoomsData:
  ' N, S, E, W, U, D, item
  DATA 0,5,2,0,0,0,0     ' Room 1
  DATA 0,0,0,1,0,0,0     ' Room 2
  DATA 3,7,4,3,3,3,0     ' Room 3
  DATA 0,0,0,3,0,0,0     ' Room 4
  DATA 1,5,7,5,5,5,0     ' Room 5
  DATA 6,6,6,6,6,6,0     ' Room 6  (escape)
  DATA 3,0,8,5,0,0,0     ' Room 7
  DATA 8,12,8,7,8,8,0    ' Room 8
  DATA 11,13,10,0,0,0,0  ' Room 9
  DATA 0,14,0,9,0,0,0    ' Room 10
  DATA 9,6,6,6,6,6,0     ' Room 11
  DATA 8,16,19,0,0,0,0   ' Room 12
  DATA 13,0,0,13,0,13,0  ' Room 13 (radiation)
  DATA 10,0,15,17,0,18,0 ' Room 14
  DATA 0,0,0,14,0,19,0   ' Room 15
  DATA 12,16,16,18,16,16,0 ' Room 16
  DATA 14,0,18,0,0,0,0   ' Room 17
  DATA 0,0,16,17,14,0,0  ' Room 18
  DATA 0,12,0,0,15,0,0   ' Room 19
END SUB

'==============================================================
'                   Endings & Utilities
'==============================================================
SUB PrintOxygenDeathAndEnd
  PRINT "YOU HAVE RUN OUT OF OXYGEN...."
  PauseBeat
  PrintFinalScoreAndEnd
END SUB

SUB PrintFinalScoreAndEnd
  LOCAL score%
  score% = 3*turnCount% + 5*playerStrength% + 2*playerWealth% + 10*oxygenUnits% + 30*killsCount%
  PRINT "YOUR SCORE WAS "; score%
  END
END SUB

SUB PauseBeat
  PAUSE DELAY_MS
END SUB

SUB BriefRest
  PauseBeat
END SUB
