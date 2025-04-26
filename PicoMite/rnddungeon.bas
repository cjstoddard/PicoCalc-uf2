'rnddungeon.bas v. 1.1
' Code by Chris Stoddard
' MMBasic 6.00

DIM ROOMS$(25)
DIM PLAYER(3) ' [0] Health, [1] Strength, [2] Inventory
DIM fightOccurred ' Flag to track IF a fight occurred

PLAYER(0) = 100 ' Health
PLAYER(1) = 10 ' Strength
PLAYER(2) = 0 ' Inventory (0 for no treasure)
fightOccurred = 0 ' No fight initially

ROOMS$(1) = "You are at the entrance of the dungeon. There is a dark hallway to the north."
ROOMS$(2) = "A dimly lit room with a strange odor. Is there a kobold here?"
ROOMS$(3) = "This room is filled with rubble. It smells musty in here."
ROOMS$(4) = "This something sticky on the floor. You get an uneasy feeling."
ROOMS$(5) = "A room filled with shimmering light. You hear something move behind you."
ROOMS$(6) = "A narrow hallway. The air is cold here. You feel a presence watching you."
ROOMS$(7) = "An empty room. It's quiet, but you sense danger nearby."
ROOMS$(8) = "This room has a low ceiling, and you can barely move. is there treasure here?"
ROOMS$(9) = "You enter a damp chamber, and water sloshes underfoot."
ROOMS$(10) = "A room filled with strange symbols on the walls. You feel disoriented."
ROOMS$(11) = "A dusty chamber with a large, broken table in the center."
ROOMS$(12) = "A massive stone door that once blocked the exits are now cracked open."
ROOMS$(13) = "A dark and cramped room. You hear something skittering in the shadows."
ROOMS$(14) = "A room full of bones. You feel an eerie chill in the air."
ROOMS$(15) = "This room is filled with smoke, and you can barely see the path ahead."
ROOMS$(16) = "You see a treasure chest here, unfortunately it is empty."
ROOMS$(17) = "A room with strange, glowing mushrooms. The air feels charged with magic."
ROOMS$(18) = "A cold stone chamber with a single, high window. It is eerily quiet."
ROOMS$(19) = "You walk into a room with a large, intricate symbol on the floor."
ROOMS$(20) = "This room is filled with garbage and smells like feet."
ROOMS$(21) = "A room filled with cages, but they are empty."
ROOMS$(22) = "A small room with a spider lurking in the corner."
ROOMS$(23) = "A grand hall with high ceilings. You hear footsteps behind you."
ROOMS$(24) = "This room is filled with treasure, unfortunately it is an illusion!"
ROOMS$(25) = "You see the exit. You've made it out of the dungeon alive!"

currentRoom = 1

DO WHILE action$ <> "q"
    PRINT: PRINT "----------"
    PRINT "You are in room "; currentRoom
    PRINT ROOMS$(currentRoom)
    PRINT "Health: "; PLAYER(0); " Strength: "; PLAYER(1)
    PRINT "Inventory: "; PLAYER(2)
    IF currentRoom = 25 THEN
        END
    ENDIF

    PRINT "What will you do? (n = North, s = South, e = East, w = West, q = Quit)"
    INPUT action$
    IF action$ = "q" THEN
        PRINT "You run screaming from the dungeon like a scared little child!"
        END
    ENDIF

    IF action$ = "n" THEN
        IF currentRoom > 5 THEN
            currentRoom = currentRoom - 5
        ELSE
            PRINT "You can't move north."
        ENDIF
    ENDIF

    IF action$ = "s" THEN
        IF currentRoom < 21 THEN
            currentRoom = currentRoom + 5
        ELSE
            PRINT "You can't move south."
        END IF
    ENDIF

    IF action$ = "e" THEN
        IF currentRoom = 1 OR currentRoom = 2 OR currentRoom = 3 OR currentRoom = 4 OR currentRoom = 5 THEN
            currentRoom = currentRoom + 1
        ELSEIF currentRoom = 6 OR currentRoom = 7 OR currentRoom = 8 OR currentRoom = 9 OR currentRoom = 10 THEN
            currentRoom = currentRoom + 1
        ELSEIF currentRoom = 11 OR currentRoom = 12 OR currentRoom = 13 OR currentRoom = 14 OR currentRoom = 15 THEN
            currentRoom = currentRoom + 1
        ELSEIF currentRoom = 16 OR currentRoom = 17 OR currentRoom = 18 OR currentRoom = 19 OR currentRoom = 20 THEN
            currentRoom = currentRoom + 1
        ELSEIF currentRoom = 21 OR currentRoom = 22 OR currentRoom = 23 THEN
            currentRoom = currentRoom + 1
        ELSE
            PRINT "You can't move east."
        ENDIF
    ENDIF

    IF action$ = "w" THEN
        IF currentRoom > 1 AND currentRoom < 25 THEN
            currentRoom = currentRoom - 1
        ELSE
            PRINT "You can't move west."
        ENDIF
    ENDIF

    IsMonster = Int(Rnd * 100) + 1
    IF IsMonster < 31 THEN
        monster = Int(Rnd * 3) + 1
        PRINT "A monster appears!"
        IF monster = 1 THEN
            PRINT "A goblin appears!"
        ELSEIF monster = 2 THEN
            PRINT "An orc attacks!"
        ELSE
            PRINT "A kobold sneaks up on you!"
        ENDIF

        PRINT "Do you want to fight or run? (f = Fight, r = Run)"
        INPUT fightRun$
        
        IF fightRun$ = "f" THEN
            Roll_d20 = Int(Rnd * 20) + 1
            Attack = Roll_d20 + PLAYER(1)
            IF Attack > 17 THEN
                PRINT "You defeated the monster!"
                PLAYER(0) = PLAYER(0) - 10
                PLAYER(1) = PLAYER(1) + .25
            ELSE
                PRINT "The monster defeats you!"
                PLAYER(0) = PLAYER(0) - 20
                PLAYER(1) = PLAYER(1) + .1
            ENDIF
            fightOccurred = 1
        ELSEIF fightRun$ = "r" THEN
            PRINT "You ran away!"
            currentRoom = currentRoom - 1
            fightOccurred = 1
        ELSE
            PRINT "Invalid choice. You stand there frozen."
        ENDIF
    ELSE
        PRINT "You are alone in this room."
        fightOccurred = 0
    ENDIF

   IsTrap = Int(Rnd * 100) + 1
    IF IsTrap < 11 THEN
        WhatTrap = Int(Rnd * 3) + 1
        IF WhatTrap = 1 THEN
            TrapType$ = "Poison Dart Trap"
        ELSEIF WhatTrap = 2 THEN
            TrapType$ = "Pit Trap"
        ELSE
            TrapType$ = "Exploding Rune Trap"
        ENDIF
        Roll_d20 = Int(Rnd * 20) + 1
        ResolveTrap = Roll_d20 + PLAYER(1)
        IF ResolveTrap > 17 THEN
            PRINT "You found a " ;  TrapType$
            Print "You managed to avoid being hurt when it went off."
            PLAYER(1) = PLAYER(1) + .25
        ELSEIF ResolveTrap < 18 THEN
            PRINT "A " ;  TrapType$ ; " found you."
            Print "You failed to avoid the trap."
            PLAYER(0) = PLAYER(0) - 10
            PLAYER(1) = PLAYER(1) + .1
            fightOccurred = 1
        ENDIF
    ENDIF

    IF fightOccurred = 0 AND PLAYER(0) < 100 THEN
        PLAYER(0) = PLAYER(0) + 1
        PRINT "You rest and regain 1 health."
    ENDIF

    IF PLAYER(0) <= 0 THEN
        PRINT "You have died. Game Over."
        END
    ENDIF

    IsTreasure = Int(Rnd * 100) + 1
    IF IsTreasure < 21 THEN
        PRINT "You find some treasure!"
        PLAYER(2) = PLAYER(2) + 1
    ENDIF
LOOP
