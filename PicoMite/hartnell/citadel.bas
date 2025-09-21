'citadel.bas
' Original code by Tim Hartnell 1983
' Updated code by Chris Stoddard 2025

'==============================================================
' THE CITADEL OF PERSHU — PicoMite BASIC Edition (modernized)
' - No line numbers; structured SUBs/FUNCTIONs
' - Uses PAUSE instead of busy-loops
' - Single-key commands: N/S/E/W/U/D, P=Pick up, G=Drop, F=Fight,
'   R=Run (asks direction), Q=Quit
' - Darkness, keys, magic, scoring, exit/death rooms preserved
'==============================================================

OPTION EXPLICIT
OPTION BASE 1

'---------------- Constants ----------------
CONST COL_N=1, COL_S=2, COL_E=3, COL_W=4, COL_U=5, COL_D=6, COL_ITEM=7, COL_MON=8
CONST DELAY_SHORT=400, DELAY_MED=800

'---------------- State ----------------
DIM rooms%(43,8)            ' room graph + item + monster
DIM haveItem%(9)            ' items 1..9 carried (1=have,0=no)
DIM itemName$(18)           ' 1..18
DIM monsterName$(19)        ' 1..19
DIM roomTreasureVal%(43)    ' value cached per room for treasure pickup

' Player stats
DIM pName$, spells%, kills%, cash%, torchOn%
DIM r%, tally%
DIM st%, ch%, de%, iq%, wi%, co%         ' attributes (IN -> iq)
DIM monName$, mStr%, mCha%, mDex%, mInt%, mWis%, mCon% ' cached monster stats for current room

'---------------- Entry ----------------
SUB Main
  RANDOMIZE TIMER
  InitGame
  GameLoop
END SUB

'==============================================================
' Utility: space-only trim for PicoMite
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
' Main loop
'==============================================================
SUB GameLoop
  DO
    PRINT : PRINT "----------------------------------"
    ShowStatus
    DescribeRoom

    ' Exit or death rooms (after description)
    IF r% = 31 OR r% > 43 THEN FinalScore

    ' Monster present? show once per visit
    IF rooms%(r%, COL_MON) <> 0 THEN
      DescribeMonster
    ENDIF

    ' Entrance torch visible without light
    IF r% = 6 AND torchOn% = 0 THEN DescribeContents
    ' Contents visible with light anywhere
    IF rooms%(r%, COL_ITEM) <> 0 AND torchOn% = 1 THEN DescribeContents

    GetCommand
    ' If any attribute dropped to/below zero, you die
    IF st%*ch%*de%*iq%*wi%*co% = 0 THEN
      PRINT "YOUR COMBINED ATTRIBUTES ARE NO LONGER"
      PRINT "ENOUGH TO SUSTAIN YOU...YOU ARE DEAD!"
      FinalScore
    ENDIF

    tally% = tally% + 1
    ' One-shot key consumption behavior (as in the original)
    IF r% = 15 THEN haveItem%(2) = 0
    IF r% = 20 THEN haveItem%(3) = 0
  LOOP
END SUB

'==============================================================
' Status
'==============================================================
SUB ShowStatus
  LOCAL j%, firstPrinted%
  PRINT pName$
  IF spells% > 0 THEN PRINT "MAGIC SPELLS: YOU HAVE "; spells%; " LEFT"
  IF kills%  > 0 THEN PRINT "MONSTERS KILLED: "; kills%
  PRINT "YOU HAVE ";
  firstPrinted% = 0
  FOR j% = 1 TO 9
    IF haveItem%(j%) <> 0 THEN
      IF firstPrinted% = 1 THEN PRINT ", ";
      PRINT itemName$(j%);
      firstPrinted% = 1
    ENDIF
  NEXT j%
  IF cash% > 0 THEN
    IF firstPrinted% = 1 THEN PRINT ", ";
    PRINT "$"; cash%;
    firstPrinted% = 1
  ENDIF
  IF firstPrinted% = 0 THEN PRINT "nothing";
  PRINT
  ' clamp negatives
  IF st% < 0 THEN st% = 0
  IF ch% < 0 THEN ch% = 0
  IF de% < 0 THEN de% = 0
  IF iq% < 0 THEN iq% = 0
  IF wi% < 0 THEN wi% = 0
  IF co% < 0 THEN co% = 0

  PRINT : PRINT "STRENGTH: "; st%; "   CHARISMA: "; ch%
  PRINT "DEXTERITY: "; de%; "   INTELLIGENCE: "; iq%
  PRINT "WISDOM: "; wi%; "     CONSTITUTION: "; co%
  PRINT
END SUB

'==============================================================
' Room description (includes special death rooms 44..47)
'==============================================================
SUB DescribeRoom
  IF torchOn% = 0 AND r% <> 6 THEN PRINT "IT IS VERY DARK": PauseBeat: EXIT SUB

  IF r% <= 19 THEN
    SELECT CASE r%
      CASE 1
        PRINT "AN UNDERGROUND RIVER FLOWS SWIFTLY BY"
        IF RND()>.5 THEN PRINT "THERE IS AN EXIT TO THE WEST"
        IF RND()>.5 THEN PRINT "A TUNNEL LEADS TO THE SOUTH"
      CASE 2
        PRINT "YOU ARE IN THE CITADEL'S FOOD STORAGE AREA"
        PRINT "OLD CHEESES AND BLACK LOAVES OF BREAD CAN"
        PRINT "BE SEEN, AS WELL AS MANY SACKS OF SUPPLIES"
      CASE 3
        PRINT "YOU ARE IN THE CITADEL'S KITCHEN. A HUGE"
        PRINT "JOINT OF MEAT TURNS SLOWLY OVER A RAGING"
        PRINT "FIRE. DOORS LEAD INTO CUPBOARDS, AS WELL"
        PRINT "AS TO THE WEST AND TO THE SOUTH"
      CASE 4
        PRINT "THIS IS THE CENTRAL LIBRARY. LEATHER-BOUND"
        PRINT "VOLUMES LINE THE WALLS, RIGHT UP TO THE"
        PRINT "ORNATELY-CARVED CEILING..."
      CASE 5
        PRINT "THIS ROOM IS AN AWFUL MESS. IT USED TO BE"
        PRINT "AN ARTIST'S STUDIO. PAINT AND OLD EASELS"
        PRINT "LIE AROUND THE FLOOR"
      CASE 6
        PRINT "THIS IS THE ENTRANCE TO THE CITADEL OF PERSHU"
        PRINT "TURN NOW, IF YOU WISH. MANY STRONGER THAN YOU"
        PRINT "HAVE TAKEN FRIGHT AT ITS MENACING TOWERS AND"
        PRINT "DARK PORTALS. IF YOU WISH TO PROCEED, MOVE"
        PRINT "EAST TOWARDS THE BLACK, GAPING DOORWAY..."
      CASE 7
        PRINT "A STONE ALTAR STANDS IN THE MIDDLE OF THE ROOM"
        PRINT "WITH TWO DEAD CANDLES ON IT. AN OLD BOOK LIES"
        PRINT "ON ONE PART OF THE ALTAR TOP, AND A FADED, RED"
        PRINT "PARCHMENT CLOTH COVERS THE FRONT OF IT"
      CASE 8
        PRINT "YOU STAND HIGH ON THE BLACK TOWER, THE"
        PRINT "CITADEL STRETCHES TO THE NORTH, SOUTH"
        PRINT "AND EAST OF YOU."
        PRINT "THERE IS ONLY ONE WAY OUT"
      CASE 9
        PRINT "YOU ARE IN THE NORTHERN SECTION OF THE"
        PRINT "CITADEL'S LARGE WINE CELLAR. HEAVY"
        PRINT "BARRELS LIE ALL AROUND YOU IN THIS END"
        PRINT "OF THE CELLAR. THERE IS A DOOR TO THE NORTH"
        PRINT "AND ONE TO THE SOUTH"
      CASE 10
        PRINT "YOU ARE IN THE WEST WING OF THE WINE"
        PRINT "CELLAR. THERE IS A DOOR TO THE WEST AND"
        PRINT "ONE TO THE EAST. THE CENTRAL CIRCULAR"
        PRINT "PART OF THE CELLAR LIES BEYOND THE EAST DOOR."
      CASE 11
        PRINT "YOU ARE IN THE CENTRAL, CIRCULAR"
        PRINT "AREA OF THE WINE CELLAR. THERE IS"
        PRINT "A DOOR AT EACH COMPASS POINT."
      CASE 12
        PRINT "YOU ARE IN THE EAST SECTION OF THE"
        PRINT "WINE CELLAR. THERE IS A DOOR TO THE"
        PRINT "WEST AND ONE—WHICH YOU CANNOT USE,"
        PRINT "AS IT ONLY ALLOWS ENTRANCE TO WHERE"
        PRINT "YOU NOW STAND—TO THE EAST"
      CASE 13
        PRINT "THERE ARE MANY, MANY WINE BOTTLES HERE"
        PRINT "LYING ON THEIR SIDES, IN THIS SOUTHERN"
        PRINT "SECTION OF THE WINE CELLAR. THERE IS A"
        PRINT "DARK, UNFRIENDLY-LOOKING HOLE TO THE WEST"
        PRINT "AND DOORS TO THE NORTH AND TO THE SOUTH"
      CASE 14
        PRINT "THIS IS THE CITADEL'S ARMORY. ROW UPON ROW"
        PRINT "OF SHINY SUITS OF ARMOR ARE STORED HERE..."
      CASE 15
        PRINT "YOU ARE IN THE RULER'S BEDCHAMBER"
        PRINT "A LARGE FIRE BURNS IN THE SOUTH OF"
        PRINT "THE ROOM, WITH A SMALL DOOR BESIDE"
        PRINT "IT. OTHER EXITS ARE TO THE NORTH"
        PRINT "AND TO THE WEST"
      CASE 16
        PRINT "THIS CURIOUS ROOM HAS A FLOOR COVERED"
        PRINT "IN SAND, HEAPED ALL OVER THE PLACE"
        PRINT "BY PEEPING OVER THE 'DUNES' YOU CAN"
        PRINT "SEE A GOLDEN PASSAGEWAY LEADS TO THE"
        PRINT "WEST, AND THERE IS A DOOR TO THE SOUTH"
        PRINT "YOU ARE NOT SURE WHETHER OR NOT YOU"
        PRINT "HAVE SEEN ALL THE EXITS"
      CASE 17
        PRINT "YOU ARE IN THE PICTURE GALLERY. PORTRAITS"
        PRINT "OF LONG-DEAD PRINCES LINE ALL OF THE"
        PRINT "WALLS. THE ROOM IS DOMINATED BY A HUGE"
        PRINT "LANDSCAPE, HANGING ABOVE THE EXIT TO THE"
        PRINT "EAST WHICH LEADS, VIA THE GOLD PASSAGEWAY,"
        PRINT "BACK TO THAT CURIOUS ROOM OF SAND"
      CASE 18
        PRINT "YOU ARE ON A REMOTE TOWER BALCONY"
        IF RND()>.5 THEN PRINT "A BAT FLIES PAST YOU, SHRIEKING"
        PRINT "THERE ARE STAIRS HERE"
      CASE 19
        PRINT "YOU WALK BENEATH A STONE ARCHWAY"
        PRINT "YOU CAN ONLY WALK NORTH OR SOUTH"
        PRINT "UNLESS YOU DECIDE TO TAKE THE STAIRS"
    END SELECT
    PauseBeat: EXIT SUB
  ENDIF

  IF r% <= 35 THEN
    SELECT CASE r% - 19
      CASE 1
        PRINT "THIS VAST HALL HAS A MARBLE FLOOR, AND"
        PRINT "THE SLIGHTEST SOUND ECHOES VIOLENTLY"
        PRINT "THERE ARE PURPLE DRAPES CONCEALING"
        PRINT "THE EXITS FROM THIS HALL"
      CASE 2
        PRINT "YOU ARE IN THE CLOVE STOREROOM"
        PRINT "THE WEST DOOR RADIATES HEAT"
        PRINT "ANOTHER DOOR LEADS TO THE SOUTH"
      CASE 3
        PRINT "YOU ARE IN THE SILVER CROSSES STOREROOM"
        PRINT "THERE ARE ONLY TWO EXITS"
      CASE 4
        PRINT "YOU ARE IN THE AMULET STOREROOM"
        PRINT "DOORS LEAD NORTH, AND SOUTH"
      CASE 5
        PRINT "YOU ARE IN THE KAZOO STOREROOM"
        PRINT "THERE ARE TWO EXITS"
      CASE 6
        PRINT "YOU ARE IN THE SATCHEL STOREROOM"
      CASE 7
        PRINT "YOU ARE IN THE STOREROOM FOR WOODEN"
        PRINT "BOXES...THERE ARE TWO EXITS"
      CASE 8
        PRINT "THIS IS WHERE PRINTED VASES ARE"
        PRINT "STORED...AS YOU CAN EASILY SEE"
      CASE 9
        PRINT "THE HEAVY AIR OF THIS AREA SEEMS TO MAKE"
        PRINT "YOUR TORCH VERY DIM. YOU CAN HARDLY SEE"
        PRINT "AIR IS RUSHING UP FROM SOMEWHERE"
        PRINT "YOU CAN JUST MAKE OUT THAT THIS AREA MUST"
        PRINT "BE A MINE OF SOME SORT"
      CASE 10
        PRINT "YOU APPEAR TO BE IN AN ENDLESS LABYRINTH,"
        PRINT "LINED WITH PAINTINGS........."
        PRINT "WHICHEVER WAY YOU TURN, THERE SEEMS TO"
        PRINT "BE MORE TUNNELS, ALL LINED WITH PAINTINGS"
      CASE 11
        PRINT "THIS IS THE SOUTHERN TOWER OF THE CITADEL"
      CASE 12
        PRINT "WELL DONE, YOU HAVE MANAGED TO FIND THE"
        PRINT "EXIT. TAKE A DEEP BREATH OF GOOD,"
        PRINT "CLEAN AIR..........."
      CASE 13
        PRINT "THIS ROOM IS FILLED WITH SWIRLING SMOKE"
        PRINT "SO YOU CANNOT SEE...AIR RUSHES PAST A"
        PRINT "STATUE OF THE GODDESS DIANA. THIS"
        PRINT "MUST BE THE CITADEL'S MEDITATION CHAMBER"
      CASE 14
        PRINT "A SMALL FORKED BRIDGE CROSSES A STREAM"
        PRINT "HERE. YOU CAN MOVE NORTH, SOUTH OR WEST"
      CASE 15
        PRINT "YOU ARE IN A ROUGH STONE CAVERN, WITH"
        PRINT "STAIRS LEADING UP FROM IT"
        PRINT "THERE IS ALSO A SINGLE DOOR WHICH"
        PRINT "LEADS AWAY FROM THE CAVERN"
      CASE 16
        PRINT "THIS IS THE FORMER CITADEL UNDERGROUND"
        PRINT "STABLE. IT SMELLS TERRIBLE"
    END SELECT
    PauseBeat: EXIT SUB
  ENDIF

  SELECT CASE r% - 35
    CASE 1
      PRINT "YOU FIND YOURSELF IN AN UNDERGROUND"
      PRINT "COURTYARD. STRANGE, TWISTED TREES ARE"
      PRINT "AROUND YOU, AND A WIND OF INCREDIBLE"
      PRINT "COLDNESS BLOWS FROM THE EAST"
    CASE 2
      PRINT "THIS IS THE ORACLE ROOM, ALTHOUGH THE"
      PRINT "MYSTIC VOICE HAS NOT SPOKEN FOR MANY YEARS"
      IF RND()>.3 THEN PRINT "BUT NOW IT TELLS YOU THERE IS": PRINT "A HIDDEN STAIRWELL IN THE ROOM"
      IF RND()>.7 THEN PRINT "THE VOICE FAINTLY MURMURS OF THE DOOR TO THE SOUTH"
    CASE 3
      PRINT "HORRORS. A COLD SHUDDER PASSES THROUGH AS YOU"
      PRINT "REALISE THIS IS THE PRIESTS' SACRIFICE ROOM"
      PRINT "DRIED UP BLOOD IS ON THE FLOOR, AND AN"
      PRINT "SKULL GRINS AT YOU, FROM HIGH ON THE WALL"
    CASE 4
      PRINT "OLD STRAW MATTRESSES, AND RINGS CHAINED TO THE"
      PRINT "WALL TELL YOU THIS WAS THE CITADEL'S DUNGEON"
      IF RND()>.4 THEN PRINT "A SMALL DOOR LEADS TO THE NORTH": PRINT "AND ANOTHER TO THE EAST"
      PRINT "THE DUNGEON SEEMS TO STRETCH FOREVER, WITH MANY"
      PRINT "SMALL PARTITIONED AREAS...."
    CASE 5
      PRINT "YOU ARE IN A SMALL ALCOVE, WITH A SOLID"
      PRINT "GREY GRANITE THRONE IN THE MIDDLE OF IT"
    CASE 6
      PRINT "THIS IS THE ORC'S GUARDROOM, WAY BELOW"
      PRINT "THE GROUND. A STAIRWELL ENDS HERE, AND"
      PRINT "A DOOR LEADS TO THE EAST"
    CASE 7
      PRINT "THERE IS A HEALING POOL HERE WITH A"
      PRINT "DANGEROUS, SWIRLING AREA OF WATER"
    CASE 8
      PRINT "THE UNDERPRIESTS OF ODRIC USED THIS"
      PRINT "TINY HALL FOR THEIR FORBIDDEN WORSHIP"
      PRINT "EONS AGO. IT IS AN UNPLEASANT AREA,"
      PRINT "SO YOU ARE THRILLED TO SEE A SET OF"
      PRINT "STONE STAIRS"
    CASE 9 ' 44 — drowning
      PRINT "WATER COVERS YOUR HEAD": PauseBeat
      PRINT "YOU ARE DROWNING": PauseBeat
      PRINT "GLUG...GASP..............."
    CASE 10 ' 45 — burning
      PRINT "THE FLAMES STRIKE AT YOU...": PauseBeat
      PRINT "AS YOU SLOWLY BURN TO DEATH": PauseBeat
      DO : LOOP WHILE RND()>.7
    CASE 11 ' 46 — freezing
      PRINT "YOU ARE HIT BY A FREEZING SPELL"
      PRINT "AND TURN INTO A BLOCK OF PERPETUAL"
      PRINT "LIVING STONE. THIS IS THE END"
    CASE 12 ' 47 — bottomless pit
      PRINT "YOU TUMBLE DOWN A BOTTOMLESS PIT": PauseBeat
      PRINT "DOWN, DOWN, DOWN..."
      DO : LOOP WHILE RND()>.4
  END SELECT
END SUB

'==============================================================
' Monster description (also seeds fight attributes)
'==============================================================
SUB DescribeMonster
  monName$ = monsterName$(rooms%(r%, COL_MON))
  mStr% = (INT(RND()*6)+1)*3
  mCha% = (INT(RND()*6)+1)*3
  mDex% = (INT(RND()*6)+1)*3
  mInt% = (INT(RND()*6)+1)*3
  mWis% = (INT(RND()*6)+1)*3
  mCon% = (INT(RND()*6)+1)*3

  IF RND() > .5 THEN
    PRINT "YOU COME FACE TO FACE WITH A "; monName$
  ELSE
    PRINT "THE ROOM CONTAINS A "; monName$
  ENDIF
  PRINT "WITH ATTRIBUTES AS FOLLOWS:"
  PRINT "STRENGTH: "; mStr%; "   CHARISMA: "; mCha%
  PRINT "DEXTERITY: "; mDex%; "   INTELLIGENCE: "; mInt%
  PRINT "WISDOM: "; mWis%; "     CONSTITUTION: "; mCon%
  PauseBeat
END SUB

'==============================================================
' Contents description (light-aware; assigns treasure value)
'==============================================================
SUB DescribeContents
  LOCAL thing$
  thing$ = itemName$(rooms%(r%, COL_ITEM))
  PRINT "YOU CAN SEE....": PauseBeat
  PRINT thing$
  IF rooms%(r%, COL_ITEM) > 9 THEN
    IF roomTreasureVal%(r%) = 0 THEN roomTreasureVal%(r%) = INT(RND()*100) + 56
    PRINT "WORTH $"; roomTreasureVal%(r%)
  ENDIF
  PauseBeat
END SUB

'==============================================================
' Pick up / Drop
'==============================================================
SUB DoPickUp
  LOCAL idx%
  IF torchOn% = 0 AND rooms%(r%, COL_ITEM) <> 1 THEN
    PRINT "IT IS TOO DARK TO SEE ANYTHING": PauseBeat: EXIT SUB
  ENDIF
  IF rooms%(r%, COL_ITEM) = 0 THEN
    PRINT "THERE IS NOTHING TO PICK UP": EXIT SUB
  ENDIF

  idx% = rooms%(r%, COL_ITEM)
  IF idx% = 1 THEN
    torchOn% = 1
  ELSEIF idx% <= 9 THEN
    haveItem%(idx%) = 1
  ELSE
    IF roomTreasureVal%(r%) = 0 THEN roomTreasureVal%(r%) = INT(RND()*100) + 56
    cash% = cash% + roomTreasureVal%(r%)
  ENDIF
  rooms%(r%, COL_ITEM) = 0
END SUB

SUB DoDrop
  LOCAL any%, j%, choose%
  any% = 0
  FOR j% = 1 TO 9
    IF haveItem%(j%) <> 0 THEN any% = 1
  NEXT j%
  IF any% = 0 THEN PRINT "YOU HAVE NOTHING TO GET RID OF": PauseBeat: EXIT SUB
  IF rooms%(r%, COL_ITEM) <> 0 THEN PRINT "THERE IS ALREADY SOMETHING HERE": PauseBeat: EXIT SUB

  PRINT "YOU ARE CARRYING:"
  FOR j% = 1 TO 9
    IF haveItem%(j%) <> 0 THEN PRINT j%; " - "; itemName$(j%)
  NEXT j%
  DO
    INPUT "ENTER NUMBER OF OBJECT TO DROP"; choose%
  LOOP UNTIL choose% >= 1 AND choose% <= 9

  IF haveItem%(choose%) = 0 THEN
    PRINT "YOU ARE NOT CARRYING "; itemName$(choose%) : PauseBeat
    EXIT SUB
  ENDIF

  IF choose% = 1 THEN torchOn% = 0
  rooms%(r%, COL_ITEM) = choose%
  haveItem%(choose%) = 0
END SUB

'==============================================================
' Fight (uses attributes seeded by DescribeMonster)
'==============================================================
SUB DoFight
  LOCAL mTally%, hTally%, z%, q%, k%, knocked%, doMagic%

  IF rooms%(r%, COL_MON) = 0 THEN PRINT "THERE IS NOTHING TO FIGHT": EXIT SUB

  ' Ensure monster stats exist (if player skipped description)
  IF monName$ = "" OR monName$ <> monsterName$(rooms%(r%, COL_MON)) THEN DescribeMonster

  PRINT : PRINT "YOUR OPPONENT IS A "; monName$
  mTally% = 0 : hTally% = 0
  PRINT "WITH THE FOLLOWING ATTRIBUTES:"
  PRINT "1 - STRENGTH "; mStr%; "   2 - CHARISMA "; mCha%
  PRINT "3 - DEXTERITY "; mDex%; "  4 - INTELLIGENCE "; mInt%
  PRINT "5 - WISDOM "; mWis%; "     6 - CONSTITUTION "; mCon%
  PRINT : PRINT "YOUR ATTRIBUTES ARE:"
  PRINT "1 - STRENGTH "; st%; "   2 - CHARISMA "; ch%
  PRINT "3 - DEXTERITY "; de%; "  4 - INTELLIGENCE "; iq%
  PRINT "5 - WISDOM "; wi%; "     6 - CONSTITUTION "; co%

  ' Equipment edges
  IF haveItem%(4) THEN PRINT "YOU HAVE A SWORD": hTally% = hTally% + 1
  IF haveItem%(5) THEN PRINT "YOUR WAR HAMMER WILL BE OF AID": hTally% = hTally% + 1
  IF haveItem%(6) THEN PRINT "CHAIN MAIL ARMOR GIVES YOU AN EDGE": hTally% = hTally% + 1
  IF haveItem%(7) THEN PRINT "YOUR SHIELD WILL HELP IN THIS FIGHT AGAINST THE "; monName$: hTally% = hTally% + 1
  IF haveItem%(8) THEN PRINT "THE CLOAK OF PROTECTION SURROUNDS YOU": hTally% = hTally% + 1
  IF haveItem%(9) THEN PRINT "THE WAND OF FIREBALLS ENHANCES YOUR STRENGTH": hTally% = hTally% + 1

  ' Magic option
  IF spells% > 0 THEN
    DO
      INPUT "ENTER 1 TO FIGHT WITH MAGIC, OR 2 TO RELY ON SKILL"; doMagic%
    LOOP UNTIL doMagic% = 1 OR doMagic% = 2
    IF doMagic% = 1 THEN
      spells% = spells% - 1
      PRINT "YOUR MAGIC DESTROYS IT": PauseBeat
      kills% = kills% + 1
      rooms%(r%, COL_MON) = 0
      monName$ = ""
      EXIT SUB
    ENDIF
  ENDIF

  PRINT : PRINT "WHICH TWO ATTRIBUTES WILL YOU FIGHT WITH (1-6)?  e.g., 1,3"
  DO
    INPUT z%, q%
  LOOP UNTIL z% >= 1 AND z% <= 6 AND q% >= 1 AND q% <= 6 AND z% <> q%

  IF z% = 1 OR q% = 1 THEN mTally% = mTally% + mStr%: hTally% = hTally% + st%
  IF z% = 2 OR q% = 2 THEN mTally% = mTally% + mCha%: hTally% = hTally% + ch%
  IF z% = 3 OR q% = 3 THEN mTally% = mTally% + mDex%: hTally% = hTally% + de%
  IF z% = 4 OR q% = 4 THEN mTally% = mTally% + mInt%: hTally% = hTally% + iq%
  IF z% = 5 OR q% = 5 THEN mTally% = mTally% + mWis%: hTally% = hTally% + wi%
  IF z% = 6 OR q% = 6 THEN mTally% = mTally% + mCon%: hTally% = hTally% + co%

  PRINT : PRINT "THE FIGHT STARTS IN FAVOR OF "; : IF hTally% > mTally% THEN PRINT "YOU" ELSE PRINT "THE "; monName$
  DO
    k% = INT(RND()*8)
    PRINT "THE "; monName$; " - "; mTally%
    PRINT pName$; " - "; hTally% : PRINT
    SELECT CASE k%
      CASE 0: PRINT "YOU GET IN A GLANCING BLOW": mTally% = mTally% - 1
      CASE 1: PRINT "THE "; monName$; " STRIKES OUT!": hTally% = hTally% - 3: st% = st% - 1: ch% = ch% - 1
      CASE 2: PRINT "YOU DRAW THE "; monName$; "'S BLOOD": mTally% = mTally% - 1
      CASE 3: PRINT "YOU ARE WOUNDED!!": hTally% = hTally% - (INT(RND()*3)+1): de% = de% - 1
      CASE 4: PRINT "THE "; monName$; " IS TIRING": mTally% = mTally% - 1
      CASE 5: PRINT "YOU ARE BLEEDING....": hTally% = hTally% - 2: wi% = wi% - 1: co% = co% - 1
      CASE 6: PRINT "YOU WOUND THE "; monName$: mTally% = mTally% - 1
      CASE 7:
        knocked% = INT(RND()*cash% + 1)
        IF knocked% > cash% THEN knocked% = cash%
        PRINT "IT KNOCKS $"; knocked%; " FROM YOUR HAND"
        cash% = cash% - knocked%
    END SELECT
    PAUSE DELAY_MED
  LOOP WHILE RND() > .25 AND hTally% > 0 AND mTally% > 0

  IF hTally% > mTally% THEN
    PRINT "YOU HAVE KILLED THE "; monName$
    kills% = kills% + 1
  ELSE
    PRINT "THE "; monName$; " GOT THE BETTER OF YOU THAT TIME"
    IF z% = 1 OR q% = 1 THEN st% = 4*INT(st%/5)
    IF z% = 2 OR q% = 2 THEN ch% = 3*INT(ch%/4)
    IF z% = 3 OR q% = 3 THEN de% = 6*INT(de%/7)
    IF z% = 4 OR q% = 4 THEN iq% = 2*INT(iq%/3)
    IF z% = 5 OR q% = 5 THEN wi% = 5*INT(wi%/6)
    IF z% = 6 OR q% = 6 THEN co% = 3*INT(co%/6)
  ENDIF

  rooms%(r%, COL_MON) = 0
  monName$ = ""
  PauseBeat
END SUB

'==============================================================
' Command handling
'==============================================================
SUB GetCommand
  LOCAL cmd$, d$
  DO
    PRINT : PRINT "WHAT DO YOU WANT TO DO?  (N/S/E/W/U/D,  P=Pick up,  G=Drop,  F=Fight,  R=Run,  Q=Quit)"
    INPUT cmd$
    cmd$ = UCASE$(LEFT$(TrimSpaces$(cmd$),1))
  LOOP UNTIL cmd$ <> ""

  SELECT CASE cmd$
    CASE "Q"
      PRINT "COWARD...QUITTER....TURNCOAT..."
      FinalScore

    CASE "F"
      IF rooms%(r%, COL_MON) = 0 THEN PRINT "THERE IS NOTHING TO FIGHT" ELSE DoFight

    CASE "P"
      IF rooms%(r%, COL_ITEM) = 0 THEN PRINT "THERE IS NOTHING TO PICK UP" ELSE DoPickUp

    CASE "G"
      DoDrop

    CASE "R"
      IF rooms%(r%, COL_MON) <> 0 AND RND() > .4 THEN
        PRINT "NO, YOU MUST STAND AND FIGHT"
        DoFight
        EXIT SUB
      ENDIF
      INPUT "WHICH DIRECTION WILL YOU RUN (N/S/E/W/U/D)"; d$
      d$ = UCASE$(LEFT$(TrimSpaces$(d$),1))
      TryMove d$

    CASE "N","S","E","W","U","D"
      TryMove cmd$

    CASE ELSE
      PRINT "I DON'T UNDERSTAND."
  END SELECT
END SUB

SUB TryMove(d$)
  ' Keyed doors
  IF r% = 15 AND haveItem%(2) = 0 AND d$ = "E" THEN PRINT "YOU NEED THE SILVER KEY TO UNLOCK THE DOOR": EXIT SUB
  IF r% = 22 AND haveItem%(3) = 0 AND d$ = "W" THEN PRINT "YOU NEED THE GOLD KEY TO UNLOCK THE DOOR": EXIT SUB

  ' Exits present?
  IF d$="N" AND rooms%(r%,COL_N)=0 THEN PRINT "NO EXIT THAT WAY": EXIT SUB
  IF d$="S" AND rooms%(r%,COL_S)=0 THEN PRINT "THERE IS NO EXIT SOUTH": EXIT SUB
  IF d$="E" AND rooms%(r%,COL_E)=0 THEN PRINT "YOU CANNOT GO IN THAT DIRECTION": EXIT SUB
  IF d$="W" AND rooms%(r%,COL_W)=0 THEN PRINT "YOU CANNOT MOVE THROUGH SOLID STONE": EXIT SUB
  IF d$="U" AND rooms%(r%,COL_U)=0 THEN PRINT "THERE IS NO WAY UP FROM HERE": EXIT SUB
  IF d$="D" AND rooms%(r%,COL_D)=0 THEN PRINT "YOU CANNOT DESCEND FROM HERE": EXIT SUB

  SELECT CASE d$
    CASE "N": r% = rooms%(r%, COL_N)
    CASE "S": r% = rooms%(r%, COL_S)
    CASE "E": r% = rooms%(r%, COL_E)
    CASE "W": r% = rooms%(r%, COL_W)
    CASE "U": r% = rooms%(r%, COL_U)
    CASE "D": r% = rooms%(r%, COL_D)
  END SELECT
END SUB

'==============================================================
' Scoring / Ending
'==============================================================
SUB FinalScore
  LOCAL w!
  PRINT : PRINT "YOUR FINAL SCORE, "; pName$; ", IS ";
  PRINT 3*cash% + 30*kills% + 3*(st%+ch%+de%+iq%+wi%+co%) + tally%

  w! = r% + tally%/1000.0
  DO WHILE w! > 99
    w! = w! - RND()*8
  LOOP
  IF r% = 31 THEN w! = 100
  PRINT "YOU COMPLETED "; INT(w!); "% OF THE QUEST"
  END
END SUB

'==============================================================
' Delay helper
'==============================================================
SUB PauseBeat
  PAUSE DELAY_SHORT
END SUB

'==============================================================
' Init
'==============================================================
SUB InitGame
  LOCAL b%, c%, j%, t%
  CLS
  ' Graph
  RESTORE RoomGraph
  FOR b% = 1 TO 43
    FOR c% = 1 TO 8
      READ rooms%(b%, c%)
    NEXT c%
  NEXT b%

  ' Place monsters (1..15) randomly (excluding certain rooms)
  FOR j% = 1 TO 15
    DO
      t% = INT(RND()*43) + 1
    LOOP WHILE t% = 6 OR t% = 31 OR t% = 4 OR t% = 21 OR rooms%(t%, COL_MON) <> 0
    rooms%(t%, COL_MON) = j%
  NEXT j%

  ' Place treasure items 4..18 randomly (exclude 6,31); 1..3 are fixed in graph
  FOR j% = 4 TO 18
    DO
      t% = INT(RND()*43) + 1
    LOOP WHILE t% = 6 OR t% = 31 OR rooms%(t%, COL_ITEM) <> 0
    rooms%(t%, COL_ITEM) = j%
  NEXT j%

  INPUT "WHAT IS YOUR NAME, EXPLORER"; pName$
  CLS

  ' Names
  RESTORE ItemNames
  FOR j% = 1 TO 18
    READ itemName$(j%)
  NEXT j%
  RESTORE MonsterNames
  FOR j% = 1 TO 19
    READ monsterName$(j%)
  NEXT j%

  ' Start state
  tally%   = 0
  torchOn% = 0
  r%       = 6      ' entrance
  cash%    = 100
  kills%   = 0
  spells%  = 3

  st% = 3*(INT(RND()*6)+1)
  ch% = 3*(INT(RND()*6)+1)
  de% = 3*(INT(RND()*6)+1)
  iq% = 3*(INT(RND()*6)+1)
  wi% = 3*(INT(RND()*6)+1)
  co% = 3*(INT(RND()*6)+1)
END SUB

'==============================================================
' DATA
'==============================================================
RoomGraph:
' N,S,E,W,U,D, item, monster   (rooms 1..43)
DATA 1,4,1,8,0,0,0,0
DATA 0,5,3,0,0,0,0,0
DATA 3,7,3,2,0,0,0,0
DATA 1,0,5,0,0,0,2,0
DATA 2,0,0,4,0,0,0,0
DATA 0,0,7,0,0,0,1,0        ' entrance: torch
DATA 3,14,15,6,0,0,0,0
DATA 1,8,8,8,0,0,0,0
DATA 10,11,0,0,0,0,0,0
DATA 0,0,11,9,0,0,0,0
DATA 9,13,12,10,0,0,0,0
DATA 0,0,0,11,0,0,0,0
DATA 11,16,0,44,0,0,0,0      ' west -> 44 (drown)
DATA 7,0,0,0,0,0,0,0
DATA 7,45,0,12,0,0,0,0       ' south -> 45 (burn)
DATA 0,19,0,17,0,37,0,0      ' down -> 37
DATA 0,0,16,0,0,0,0,0
DATA 0,30,0,0,0,34,0,0       ' up -> 34
DATA 16,28,0,0,0,43,0,0      ' down -> 43
DATA 0,31,22,0,0,0,0,0
DATA 0,23,0,45,0,0,3,0       ' needs silver key east from 15; here item slot fixed GOLD KEY=3
DATA 0,24,0,20,0,0,0,0
DATA 21,25,0,0,0,0,0,0
DATA 22,0,25,0,0,0,0,0
DATA 23,27,30,24,0,0,0,0
DATA 0,0,27,0,0,0,0,0
DATA 25,0,0,26,0,0,0,0
DATA 19,28,28,28,0,47,0,0     ' down -> 47 (pit)
DATA 26,29,29,29,0,0,0,0
DATA 18,0,0,25,0,0,0,0
DATA 20,0,0,0,0,0,0,0         ' 31 exit room
DATA 0,0,34,0,0,47,0,0        ' down -> 47
DATA 34,36,0,35,0,0,0,0
DATA 34,33,34,32,18,0,0,0     ' up -> 18
DATA 33,38,36,0,0,0,0,0
DATA 33,39,46,35,0,0,0,0      ' east -> 46 (freeze)
DATA 0,40,0,0,16,0,0,0        ' up -> 16
DATA 35,0,0,0,0,41,0,0        ' down -> 41
DATA 36,39,40,39,0,0,0,0
DATA 37,0,0,39,0,0,0,0
DATA 0,0,42,0,38,0,0,0        ' up -> 38
DATA 42,43,42,41,0,47,0,0     ' down -> 47
DATA 0,0,42,0,19,0,0,0        ' up -> 19

ItemNames:
DATA "FLAMING TORCH","SILVER KEY","GOLD KEY","SWORD","WAR HAMMER","CHAIN MAIL ARMOR","SHIELD","CLOAK OF PROTECTION","WAND OF FIREBALLS"
DATA "EMERALDS","SILVER RINGS","ELVEN AMETHYSTS","DIAMOND DRAGON EYES","CRYSTAL BALL","PIECES OF EIGHT","ELEMENTAL GEMS","SHAPE-SHIFTING STONES","GOLD DUBLOONS"

MonsterNames:
DATA "SWASHBUCKLER","WEREBEAR","CAECLIAE","MANTICORE","VAMPIRE","PREDEBEAST","GARGOYLE","MEDUSAE","MAGI","FIRE LIZARD","PHASE SPIDER","TROLL","HELL HOUND","FROST GIANT","NECROMANCER","HYDRA OF 10 HEADS","PATRIARCH","MASTER THIEF","LIVING STATUE"

'---------------- Launch ----------------
Main
