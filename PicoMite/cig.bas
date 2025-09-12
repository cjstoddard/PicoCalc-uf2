'cig.bas
' Code by Chris Stoddard

OPTION EXPLICIT
RANDOMIZE TIMER

' ---- Screen / colors ----
DIM INTEGER HRES, VRES
HRES = MM.HRES
VRES = MM.VRES

CONST COL_BG%     = RGB(0,0,0)
CONST COL_WHITE%  = RGB(255,255,255)
CONST COL_TAN%    = RGB(210,180,140)
CONST COL_EMBER1% = RGB(255,60,0)
CONST COL_EMBER2% = RGB(255,160,0)
CONST COL_GREY1%  = RGB(200,200,200)
CONST COL_GREY2%  = RGB(160,160,160)
CONST COL_GREY3%  = RGB(120,120,120)
CONST COL_STRIPE% = RGB(140,110,80)
CONST COL_ASH%    = RGB(100,100,100)

CLS
COLOUR COL_WHITE%, COL_BG%

' ---- Cigarette geometry ----
DIM INTEGER cigW, cigH, cigX, cigY, filterW, midY
cigW    = 180
cigH    = 18
filterW = 45

cigX = (HRES - cigW) \ 2
cigY = VRES - 80
midY = cigY + (cigH - 1) \ 2   ' visual centerline through the rectangle

' Utility: filled circle (outline + fill = same colour)
SUB FillCircle(x AS INTEGER, y AS INTEGER, r AS INTEGER, col AS INTEGER)
  CIRCLE x, y, r, , , col, col
END SUB

' ---- Draw cigarette (top-anchored so stripes align) ----
SUB DrawCig()
  ' Body (white) as thick horizontal line starting at top y=cigY
  LINE cigX, cigY, cigX + cigW - 1, cigY, cigH, COL_WHITE%

  ' Filter (tan) over right end (same top y=cigY)
  LINE cigX + cigW - filterW, cigY, cigX + cigW - 1, cigY, cigH, COL_TAN%

  ' Filter stripes (inside the tan area)
  LINE cigX + cigW - filterW + 6,  cigY, cigX + cigW - filterW + 6,  cigY + cigH - 1, 1, COL_STRIPE%
  LINE cigX + cigW - filterW + 12, cigY, cigX + cigW - filterW + 12, cigY + cigH - 1, 1, COL_STRIPE%

  ' Ash edge at left tip
  LINE cigX - 1, cigY, cigX - 1, cigY + cigH - 1, 2, COL_ASH%

  ' Ember glow centered on midY (now visually centered)
  FillCircle cigX,     midY, 8, COL_EMBER1%
  FillCircle cigX + 3, midY, 6, COL_EMBER2%
END SUB

' ---- Smoke particles ----
CONST MAXPUFFS = 12
DIM INTEGER puffX(MAXPUFFS-1), puffY(MAXPUFFS-1), puffR(MAXPUFFS-1)
DIM INTEGER puffVx(MAXPUFFS-1), puffVy(MAXPUFFS-1), puffShade(MAXPUFFS-1)

SUB ResetPuff(idx)
  puffX(idx)     = cigX + 6 + INT(RND() * 5)
  puffY(idx)     = midY - 2 + INT(RND() * 5) - 2
  puffR(idx)     = 2 + INT(RND() * 3)
  puffVx(idx)    = -1 + INT(RND() * 3)        ' -1..+1
  puffVy(idx)    = -1 - INT(RND() * 2)        ' -1 or -2 (upward)
  puffShade(idx) = 1 + INT(RND() * 3)         ' 1..3
END SUB

FUNCTION ShadeToColour%(s)
  SELECT CASE s
    CASE 1: ShadeToColour% = COL_GREY1%
    CASE 2: ShadeToColour% = COL_GREY2%
    CASE ELSE: ShadeToColour% = COL_GREY3%
  END SELECT
END FUNCTION

SUB DrawPuff(idx, col)
  CIRCLE puffX(idx), puffY(idx), puffR(idx), , , col, col
END SUB

' ---- Initialise puffs ----
DIM INTEGER i
FOR i = 0 TO MAXPUFFS - 1
  ResetPuff i
  puffY(i) = puffY(i) - i * 6
NEXT i

DrawCig()

' ---- Animation loop ----
DIM INTEGER frame
frame = 0

DO
  IF INKEY$ = CHR$(27) THEN END

  ' Ember flicker
  IF (frame MOD 6) = 0 THEN
    FillCircle cigX,     midY, 8, COL_EMBER1%
    FillCircle cigX + 3, midY, 6, COL_EMBER2%
  ENDIF

  ' Update smoke
  FOR i = 0 TO MAXPUFFS - 1
    DrawPuff i, COL_BG%
    puffX(i) = puffX(i) + puffVx(i) + INT(RND() * 3) - 1
    puffY(i) = puffY(i) + puffVy(i)
    IF (frame MOD 2) = 0 AND RND() > 0.4 THEN puffR(i) = puffR(i) + 1
    IF (frame MOD 4) = 0 AND puffShade(i) > 1 THEN puffShade(i) = puffShade(i) - 1
    IF puffY(i) < -10 OR puffR(i) > 18 THEN ResetPuff i
    DrawPuff i, ShadeToColour%(puffShade(i))
  NEXT i

  ' Keep ash edge crisp
  LINE cigX - 1, cigY, cigX - 1, cigY + cigH - 1, 2, COL_ASH%

  PAUSE 30
  frame = frame + 1
LOOP

