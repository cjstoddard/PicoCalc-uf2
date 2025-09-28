'eliza.bas
' Original program by Joseph Weizenbaum, 1967
' Ported to Basic by Jeff Shrager, 1977
' Updated by Chris Stoddard

OPTION EXPLICIT
OPTION BASE 1

CONST KEYWORD_COUNT = 36
CONST CONJ_COUNT    = 12
CONST REPLY_COUNT   = 112

DIM Keyword$(KEYWORD_COUNT)
DIM ConjugationToken$(CONJ_COUNT)
DIM ReplyLine$(REPLY_COUNT)

DIM ReplyStartIndex(KEYWORD_COUNT)
DIM ReplyCurrentIndex(KEYWORD_COUNT)
DIM ReplyEndIndex(KEYWORD_COUNT)

DIM PrevUserInput$ : PrevUserInput$ = ""

DIM userRaw$, normalized$
DIM keywordIndex%, keywordPos%

FUNCTION Upper$(s$)
  Upper$ = UCASE$(s$)
END FUNCTION

FUNCTION RemoveApostrophes$(s$)
  LOCAL i%, c$, out1$
  out1$ = ""
  FOR i% = 1 TO LEN(s$)
    c$ = MID$(s$, i%, 1)
    IF c$ <> CHR$(39) THEN
      out1$ = out1$ + c$
    ENDIF
  NEXT
  RemoveApostrophes$ = out1$
END FUNCTION

FUNCTION TrimLeadingOneSpace$(s$)
  IF LEN(s$) >= 1 AND MID$(s$, 1, 1) = " " THEN
    TrimLeadingOneSpace$ = MID$(s$, 2)
  ELSE
    TrimLeadingOneSpace$ = s$
  ENDIF
END FUNCTION

FUNCTION ReplaceAll$(text$, target$, replacement$)
  LOCAL idxPos%, work$
  work$ = text$
  IF target$ = "" THEN
    ReplaceAll$ = work$
    EXIT FUNCTION
  ENDIF
  DO
    idxPos% = INSTR(work$, target$)
    IF idxPos% = 0 THEN EXIT DO
    work$ = LEFT$(work$, idxPos% - 1) + replacement$ + MID$(work$, idxPos% + LEN(target$))
  LOOP
  ReplaceAll$ = work$
END FUNCTION

' Swap a$ <-> b$ safely (no double-swap)
FUNCTION ReplacePairwise$(text$, a$, b$)
  LOCAL tmp$
  tmp$ = ReplaceAll$(text$, a$, "#PAIR_A#")
  tmp$ = ReplaceAll$(tmp$, b$, "#PAIR_B#")
  tmp$ = ReplaceAll$(tmp$, "#PAIR_A#", b$)
  tmp$ = ReplaceAll$(tmp$, "#PAIR_B#", a$)
  ReplacePairwise$ = tmp$
END FUNCTION

' Apply all conjugation swaps on the right-hand fragment
FUNCTION ConjugateFragment$(fragment$)
  LOCAL out1$, i%
  out1$ = fragment$
  FOR i% = 1 TO CONJ_COUNT STEP 2
    out1$ = ReplacePairwise$(out1$, ConjugationToken$(i%), ConjugationToken$(i% + 1))
  NEXT i%
  out1$ = TrimLeadingOneSpace$(out1$)
  ConjugateFragment$ = out1$
END FUNCTION

SUB InitAllData
  LOCAL k%, startIndex%, spanLen%

  RESTORE KeywordsData
  FOR k% = 1 TO KEYWORD_COUNT
    READ Keyword$(k%)
    Keyword$(k%) = Upper$(Keyword$(k%))
  NEXT

  RESTORE ConjugationsData
  FOR k% = 1 TO CONJ_COUNT
    READ ConjugationToken$(k%)
    ConjugationToken$(k%) = Upper$(ConjugationToken$(k%))
  NEXT

  RESTORE RepliesData
  FOR k% = 1 TO REPLY_COUNT
    READ ReplyLine$(k%)
  NEXT

  RESTORE ReplyRangesData
  FOR k% = 1 TO KEYWORD_COUNT
    READ startIndex%, spanLen%
    ReplyStartIndex(k%)   = startIndex%
    ReplyCurrentIndex(k%) = startIndex%
    ReplyEndIndex(k%)     = startIndex% + spanLen% - 1
  NEXT
END SUB

FUNCTION FindKeywordIndex%(normalizedInput$, BYREF hitPos%)
  LOCAL k%, idxPos%
  FindKeywordIndex% = 0
  hitPos% = 0
  FOR k% = 1 TO KEYWORD_COUNT
    idxPos% = INSTR(normalizedInput$, Keyword$(k%))
    IF idxPos% > 0 THEN
      FindKeywordIndex% = k%
      hitPos% = idxPos%
      EXIT FUNCTION
    ENDIF
  NEXT k%
END FUNCTION

SUB RespondToKeyword(keywordIndex%, normalizedInput$, hitPos%)
  LOCAL reply$, rhsFragment$, keyToken$, idx%
  idx% = ReplyCurrentIndex(keywordIndex%)

  ' rotate pointer for next time
  ReplyCurrentIndex(keywordIndex%) = ReplyCurrentIndex(keywordIndex%) + 1
  IF ReplyCurrentIndex(keywordIndex%) > ReplyEndIndex(keywordIndex%) THEN
    ReplyCurrentIndex(keywordIndex%) = ReplyStartIndex(keywordIndex%)
  ENDIF

  reply$ = ReplyLine$(idx%)

  IF RIGHT$(reply$, 1) = "*" THEN
    keyToken$ = Keyword$(keywordIndex%)
    rhsFragment$ = " " + MID$(normalizedInput$, hitPos% + LEN(keyToken$))
    rhsFragment$ = ConjugateFragment$(rhsFragment$)
    PRINT LEFT$(reply$, LEN(reply$) - 1); rhsFragment$
  ELSE
    PRINT reply$
  ENDIF
END SUB

CLS
InitAllData
PRINT "HI! I'M ELIZA. WHAT'S YOUR PROBLEM?"
PRINT

DO
  INPUT "> ", userRaw$

  IF INSTR(UCASE$(userRaw$), "SHUT") > 0 THEN
    PRINT "SHUT UP..."
    END
  ENDIF

  ' emulate classic padding; strip apostrophes
  userRaw$ = " " + userRaw$ + "  "
  userRaw$ = RemoveApostrophes$(userRaw$)

  IF userRaw$ = PrevUserInput$ THEN
    PRINT "PLEASE DON'T REPEAT YOURSELF!"
    CONTINUE DO
  ENDIF

  normalized$ = Upper$(userRaw$)

  keywordIndex% = FindKeywordIndex%(normalized$, keywordPos%)
  IF keywordIndex% = 0 THEN
    keywordIndex% = KEYWORD_COUNT        ' use NOKEYFOUND bucket
    keywordPos% = LEN(normalized$)
  ENDIF

  RespondToKeyword keywordIndex%, normalized$, keywordPos%

  PrevUserInput$ = userRaw$
LOOP

KeywordsData:
DATA "CAN YOU","CAN I","YOU ARE","YOURE","I DONT","I FEEL"
DATA "WHY DONT YOU","WHY CANT I","ARE YOU","I CANT","I AM","IM "
DATA "YOU ","I WANT","WHAT","HOW","WHO","WHERE","WHEN","WHY"
DATA "NAME","CAUSE","SORRY","DREAM","HELLO","HI ","MAYBE"
DATA " NO","YOUR","ALWAYS","THINK","ALIKE","YES","FRIEND"
DATA "COMPUTER","NOKEYFOUND"

ConjugationsData:
' Keep spaces so swaps hit whole tokens only
DATA " ARE "," AM ","WERE ","WAS "," YOU "," I ","YOUR ","MY "
DATA " IVE "," YOUVE "," IM "," YOURE "

RepliesData:
DATA "DON'T YOU BELIEVE THAT I CAN*"
DATA "PERHAPS YOU WOULD LIKE TO BE ABLE TO*"
DATA "YOU WANT ME TO BE ABLE TO*"
DATA "PERHAPS YOU DON'T WANT TO*"
DATA "DO YOU WANT TO BE ABLE TO*"
DATA "WHAT MAKES YOU THINK I AM*"
DATA "DOES IT PLEASE YOU TO BELIEVE I AM*"
DATA "PERHAPS YOU WOULD LIKE TO BE*"
DATA "DO YOU SOMETIMES WISH YOU WERE*"
DATA "DON'T YOU REALLY*"
DATA "WHY DON'T YOU*"
DATA "DO YOU WISH TO BE ABLE TO*"
DATA "DOES THAT TROUBLE YOU?"
DATA "TELL ME MORE ABOUT SUCH FEELINGS."
DATA "DO YOU OFTEN FEEL*"
DATA "DO YOU ENJOY FEELING*"
DATA "DO YOU REALLY BELIEVE I DON'T*"
DATA "PERHAPS IN GOOD TIME I WILL*"
DATA "DO YOU WANT ME TO*"
DATA "DO YOU THINK YOU SHOULD BE ABLE TO*"
DATA "WHY CAN'T YOU*"
DATA "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*"
DATA "WOULD YOU PREFER IF I WERE NOT*"
DATA "PERHAPS IN YOUR FANTASIES I AM*"
DATA "HOW DO YOU KNOW YOU CAN'T*"
DATA "HAVE YOU TRIED?"
DATA "PERHAPS YOU CAN NOW*"
DATA "DID YOU COME TO ME BECAUSE YOU ARE*"
DATA "HOW LONG HAVE YOU BEEN*"
DATA "DO YOU BELIEVE IT IS NORMAL TO BE*"
DATA "DO YOU ENJOY BEING*"
DATA "WE WERE DISCUSSING YOU-- NOT ME."
DATA "OH, I*"
DATA "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?"
DATA "WHAT WOULD IT MEAN TO YOU IF YOU GOT*"
DATA "WHY DO YOU WANT*"
DATA "SUPPOSE YOU SOON GOT*"
DATA "WHAT IF YOU NEVER GOT*"
DATA "I SOMETIMES ALSO WANT*"
DATA "WHY DO YOU ASK?"
DATA "DOES THAT QUESTION INTEREST YOU?"
DATA "WHAT ANSWER WOULD PLEASE YOU THE MOST?"
DATA "WHAT DO YOU THINK?"
DATA "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"
DATA "WHAT IS IT THAT YOU REALLY WANT TO KNOW?"
DATA "HAVE YOU ASKED ANYONE ELSE?"
DATA "HAVE YOU ASKED SUCH QUESTIONS BEFORE?"
DATA "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"
DATA "NAMES DON'T INTEREST ME."
DATA "I DON'T CARE ABOUT NAMES-- PLEASE GO ON."
DATA "IS THAT THE REAL REASON?"
DATA "DON'T ANY OTHER REASONS COME TO MIND?"
DATA "DOES THAT REASON EXPLAIN ANYTHING ELSE?"
DATA "WHAT OTHER REASONS MIGHT THERE BE?"
DATA "PLEASE DON'T APOLOGIZE!"
DATA "APOLOGIES ARE NOT NECESSARY."
DATA "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE."
DATA "DON'T BE SO DEFENSIVE!"
DATA "WHAT DOES THAT DREAM SUGGEST TO YOU?"
DATA "DO YOU DREAM OFTEN?"
DATA "WHAT PERSONS APPEAR IN YOUR DREAMS?"
DATA "ARE YOU DISTURBED BY YOUR DREAMS?"
DATA "HOW DO YOU DO ... PLEASE STATE YOUR PROBLEM."
DATA "YOU DON'T SEEM QUITE CERTAIN."
DATA "WHY THE UNCERTAIN TONE?"
DATA "CAN'T YOU BE MORE POSITIVE?"
DATA "YOU AREN'T SURE?"
DATA "DON'T YOU KNOW?"
DATA "ARE YOU SAYING NO JUST TO BE NEGATIVE?"
DATA "YOU ARE BEING A BIT NEGATIVE."
DATA "WHY NOT?"
DATA "ARE YOU SURE?"
DATA "WHY NO?"
DATA "WHY ARE YOU CONCERNED ABOUT MY*"
DATA "WHAT ABOUT YOUR OWN*"
DATA "CAN YOU THINK OF A SPECIFIC EXAMPLE?"
DATA "WHEN?"
DATA "WHAT ARE YOU THINKING OF?"
DATA "REALLY, ALWAYS?"
DATA "DO YOU REALLY THINK SO?"
DATA "BUT YOU ARE NOT SURE YOU*"
DATA "DO YOU DOUBT YOU*"
DATA "IN WHAT WAY?"
DATA "WHAT RESEMBLANCE DO YOU SEE?"
DATA "WHAT DOES THE SIMILARITY SUGGEST TO YOU?"
DATA "WHAT OTHER CONNECTIONS DO YOU SEE?"
DATA "COULD THERE REALLY BE SOME CONNECTION?"
DATA "HOW?"
DATA "YOU SEEM QUITE POSITIVE."
DATA "ARE YOU SURE?"
DATA "I SEE."
DATA "I UNDERSTAND."
DATA "WHY DO YOU BRING UP THE TOPIC OF FRIENDS?"
DATA "DO YOUR FRIENDS WORRY YOU?"
DATA "DO YOUR FRIENDS PICK ON YOU?"
DATA "ARE YOU SURE YOU HAVE ANY FRIENDS?"
DATA "DO YOU IMPOSE ON YOUR FRIENDS?"
DATA "PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU."
DATA "DO COMPUTERS WORRY YOU?"
DATA "ARE YOU TALKING ABOUT ME IN PARTICULAR?"
DATA "ARE YOU FRIGHTENED BY MACHINES?"
DATA "WHY DO YOU MENTION COMPUTERS?"
DATA "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?"
DATA "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"
DATA "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"
DATA "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?"
DATA "WHAT DOES THAT SUGGEST TO YOU?"
DATA "I SEE."
DATA "I'M NOT SURE I UNDERSTAND YOU FULLY."
DATA "COME COME ELUCIDATE YOUR THOUGHTS."
DATA "CAN YOU ELABORATE ON THAT?"
DATA "THAT IS QUITE INTERESTING."

ReplyRangesData:
DATA 1,3,  4,2,  6,4,  6,4, 10,4, 14,3, 17,3, 20,2, 22,3, 25,3
DATA 28,4, 28,4, 32,3, 35,5, 40,9, 40,9, 40,9, 40,9, 40,9, 40,9
DATA 49,2, 51,4, 55,4, 59,4, 63,1, 63,1, 64,5, 69,5, 74,2, 76,4
DATA 80,3, 83,5, 89,4, 93,6, 99,7, 106,7
