'pico-ed.bas
' Code by Chris Stoddard
' MMBasic 6.00

CONST MAXLINES = 20
DIM lines$(MAXLINES)

TopOfTheWorld:

filelines = 0

PRINT "Pico-ed.bas"
PRINT STRING$(30, "-")
PRINT "Enter filename to open/create:"
INPUT filename$

fileExists$ = DIR$(filename$, FILE)

IF fileExists$ <> "" THEN
    OPEN filename$ FOR INPUT AS #1
    DO WHILE NOT EOF(1) AND filelines < MAXLINES
        LINE INPUT #1, lines$(filelines)
        filelines = filelines + 1
    LOOP
    CLOSE #1
    PRINT filelines; " lines loaded."
ELSE
    PRINT "File not found. Starting new file."
    filelines = 0
END IF

EditLoop:
PRINT
PRINT "Commands: A=Append, D <n>=Delete,"
PRINT "E <n>=Edit, H=Help, I <n>=Insert,"
PRINT "L=List, O=Open, Q=Quit, S=Save,"
PRINT "W=Write"
PRINT "> ";
INPUT cmd$

c$ = UCASE$(LEFT$(cmd$,1))
strArg$ = MID$(cmd$,3)
intArg = VAL(strArg$)

SELECT CASE c$
    CASE "L"
        CLS
        PRINT
        FOR i = 0 TO filelines - 1
            PRINT i; ": "; lines$(i)
        NEXT i

    CASE "E"
        IF intArg >= 0 AND intArg < filelines THEN
            PRINT "Editing line "; intArg; ": "; lines$(intArg)
            PRINT "New content: ";
            INPUT TempText$
            newText$ = InputString(TempText$)
            lines$(intArg) = newText$
        ELSE
            PRINT "Invalid line number."
        END IF

    CASE "A"
        IF filelines < MAXLINES THEN
            PRINT "Enter new line content:";
            INPUT TempText$
            newText$ = InputString(TempText$)
            lines$(filelines) = newText$
            filelines = filelines + 1
        ELSE
            PRINT "File is full."
        END IF

    CASE "I"
        IF intArg >= 0 AND intArg <= filelines THEN
            PRINT "Enter line to insert at "; intArg; ":"
            INPUT TempText$
            newText$ = InputString(TempText$)
            IF filelines < MAXLINES THEN
                filelines = filelines + 1
            END IF
            FOR i = filelines - 1 TO intArg + 1 STEP -1
                lines$(i) = lines$(i - 1)
            NEXT i
            lines$(intArg) = newText$
        ELSE
            PRINT "Invalid insert position."
        END IF
        
    CASE "D"
        IF intArg >= 0 AND intArg < filelines THEN
            FOR i = intArg TO filelines - 2
                lines$(i) = lines$(i+1)
            NEXT i
            lines$(filelines - 1) = ""
            filelines = filelines - 1
            PRINT "Line deleted."
        ELSE
            PRINT "Invalid line number."
        END IF

    CASE "S"
        PRINT "Saving file..."
        GOSUB SaveFile

    CASE "O"
        PRINT "Saving current file..."
        GOSUB SaveFile
        GOTO TopOfTheWorld

    CASE "W"
        PRINT "Enter new filename to save as:"
        INPUT filename$
        PRINT "Saving file..."
        GOSUB SaveFile

    CASE "H"
        CLS
        PRINT "Pico-ed Help"
        PRINT STRING$(30, "-")
        PRINT "A            Append new line at end"
        PRINT "D <n>        Delete line n"
        PRINT "E <n>        Edit line number n"
        PRINT "H            Show this help screen"
        PRINT "I <n>        Insert line at position n"
        PRINT "L            List all lines"
        PRINT "O            Open file"
        PRINT "Q            Save and Quit"
        PRINT "S            Save to current filename"
        PRINT "W            Save As (write to new file)"
        PRINT STRING$(30, "-")
        
    CASE "Q"
        PRINT "Saving file before exit..."
        GOSUB SaveFile
        PRINT "Goodbye!"
        END

    CASE ELSE
        PRINT "Unknown command."
END SELECT

GOTO EditLoop

SaveFile:
    OPEN filename$ FOR OUTPUT AS #1
    FOR i = 0 TO filelines - 1
        PRINT #1, lines$(i)
    NEXT i
    CLOSE #1
    PRINT "File saved."
    RETURN

function InputString(b$) as String
    local r$="", i, m$

    for i = 1 to len(b$)
        m$ = mid$(b$,i,1)
        select case asc(m$)
            ' Left shift, right shift, ctrl, alt
            case 162, 163, 161, 165
               m$=""
        end select

        r$=r$+m$
    next i

    InputString = r$
end function
