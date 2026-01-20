10 REM
20 REM Microsoft GWBASIC 3.23 memory dumper
30 REM Addresses valid for GWBASIC.EXE 
40 REM date: 05/OCT/1988, size: 80608 bytes
50 REM
60 REM Martin Hepperle, 2020
70 REM
80 REM Make sure that segment address is default
90 DEF SEG
100 DIM ARY(128)
110 DIM CMD$(124),XFD$(11),XFE$(40),XFF$(37)
120 REM get a word at A -> FN becomes a simple variable, bit 7 in 1st character set 
130 DEF FNPEEKW(A)=PEEK(A)+256*PEEK(A+1)
140 RESET
150 REM Read single byte tokens
160 FOR I% = 0 TO 123 : READ CMD$(I%) : NEXT I%
170 REM Read escaped tokens
180 FOR I% = 0 TO 10 : READ XFD$(I%) : NEXT I%
190 FOR I% = 0 TO 39 : READ XFE$(I%) : NEXT I%
200 FOR I% = 0 TO 36 : READ XFF$(I%) : NEXT I%
210 PRINT "Start offset for HEX dump";
220 INPUT S
230 E=S+4*64-1
240 L$ = ""
250 N=16
260 PRINT "MEMORY FROM";S;"TO";E;
270 REM PRINT RIGHT$("000"+HEX$(S),4);": ";
280 FOR I = S TO E
290  IF N = 16 THEN PRINT " "; L$ : N = 0 : L$ = "" : PRINT RIGHT$("000"+HEX$(I),4);": ";
300  C% = PEEK(I)
310  IF C% > 31 AND C%<128 THEN C$ = CHR$(C%) ELSE C$ = "."
320  L$ = L$ + C$
330  PRINT MID$("0" + HEX$(C%), 1 - (C% > 15)); " ";
340  N=N+1
350 NEXT I
360 IF N>0 THEN FOR I=1 TO 16-N : PRINT "   "; : NEXT I : PRINT " ";L$
370 PRINT "[Press ENTER to continue]" : LINE INPUT C$
380 PRINT "Variables:"
390 MSG$ = "TOPMEM": OFFS% = 311: GOSUB 640 : REM O.K. -> top of stack
400 MSG$ = "MAXMEM": OFFS% = 1101: GOSUB 640 : REM O.K. -> &HFFFE data seg size
410 MSG$ = "MEMSIZ": OFFS% = 1103: GOSUB 640 : REM O.K. -> &HFDFC max. offset used
420 MSG$ = "FRETOP": OFFS% = 1140: GOSUB 640 : REM O.K. -> 
430 REM MSG$ = "DEVTBL": OFFS% = 321: GOSUB 630 : REM ???
440 MSG$ = "STREND": OFFS% = 1186: GOSUB 640 : REM O.K. -> lower end of string vars
450 MSG$ = "ARYTAB": OFFS% = 1184: GOSUB 640 : REM O.K. -> array variables
460 MSG$ = "ARYTA2": OFFS% = 1425: GOSUB 640: REM O.K. same as ARYTAB
470 MSG$ = "VARTAB": OFFS% = 1182: GOSUB 640 : REM O.K. -> simple variables
480 MSG$ = "TXTTAB": OFFS% = 315: GOSUB 640 : REM O.K. -> program TEXT
490 MSG$ = "DATPTR": OFFS% = 1188: GOSUB 640 : REM O.K. -> initial DATA: 0 byte before TEXT
500 MSG$ = "AUTINC": OFFS% = 1159: GOSUB 640 : REM O.K. AUTO line # increment
510 MSG$ = "USRTAB": OFFS% = 264: GOSUB 640 : REM O.K. -> USR0 to USR9 functions
520 MSG$ = "DEFTBL": OFFS% = 1190: GOSUB 640 : REM O.K. -> 26 default types, 4,4 ...
530 MSG$ = "SAVSEG": OFFS% = 1174: GOSUB 640 : REM O.K. DEF SEG
540 PRINT "[Press ENTER to continue]" : LINE INPUT C$
550 REM output simple variables
560 GOSUB 1840
570 PRINT "[Press ENTER to continue]" : LINE INPUT C$
580 GOSUB 2050
590 PRINT "[Press ENTER to dump BASIC program]" : LINE INPUT C$
600 GOSUB 730
610 PRINT "Done."
620 STOP
630 REM ---
640 V = FNPEEKW(OFFS%)
650 H$ = HEX$(V)
660 H$ = RIGHT$("000"+H$,4)
670 PRINT MSG$; "-> 0x"; H$; " ="; STR$(V); "d (";HEX$(PEEK(OFFS%));" ";HEX$(PEEK(OFFS%+1));")";
680 IF V>4700 AND V<20000 THEN PRINT " -> ";HEX$(PEEK(V));",";HEX$(PEEK(V+1));",";HEX$(PEEK(V+2));",";HEX$(PEEK(V+3));",...";
690 PRINT
700 RETURN
710 REM --- dump BASIC program tokens
720 REM TXTTAB -> start of program
730 TXT% = 315
740 REM address of first line of BASIC program
750 TXT% = FNPEEKW(TXT%)
760 REM address of next line
770 NXT% = FNPEEKW(TXT%)
780 IF NXT% = 0 THEN GOTO 1260
790 REM line number
800 L% = FNPEEKW(TXT% + 2)
810 PRINT "LINE "; L%; " at "; TXT%; ":"; CHR$(9);
820 FOR I% = TXT% + 4 TO NXT% - 1
830  C% = PEEK(I%)
840  PRINT " "; MID$("0" + HEX$(C%), 1 - (C% > 15));
850 NEXT I%
860 PRINT
870 PRINT "                       "; CHR$(9);
880 J% = 0
890 FOR I% = TXT% + 4 TO NXT%-1
900  C% = PEEK(I%)
910  REM 0B: two byte OCT number
920  IF C% = &HB THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " &O"; OCT$(N%); : GOTO 1210
930  REM 0C: two byte HEX number
940  IF C% = &HC THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " &H"; HEX$(N%); : GOTO 1210
950  REM 0D: two byte address of line (compiled, GOTO line# becomes GOTO ADDR)
960  IF C% = &HD THEN A% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; FNPEEKW(A% + 3) : GOTO 1210
970  REM 0E: two byte line number (not yet compiled)
980  IF C% = &HE THEN A% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; A%; : GOTO 1210
990  REM 0F: single byte integer number 0..255
1000  IF C% = &HF THEN N% = PEEK(I%+1): I% = I% + 1: PRINT " "; N%; : GOTO 1210
1010  REM 1C: two byte integer number
1020  IF C% = &H1C THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; N%; : GOTO 1210
1030  REM 1D: four byte single floating point number
1040  IF C% = &H1D THEN  K%=4 : GOSUB 1270: I% = I% + 4: PRINT " "; N$; : GOTO 1210
1050  REM 1E: not handled
1060  REM 1F: eight byte double floating point number 
1070  IF C% = &H1F THEN K%=8 : GOSUB 1270: I% = I% + 8: PRINT " "; N$; : GOTO 1210
1080  REM escaped codes
1090  IF C% = &HFD THEN J% = C%: GOTO 1210
1100  IF C% = &HFE THEN J% = C%: GOTO 1210
1110  IF C% = &HFF THEN J% = C%: GOTO 1210
1120  REM regular command token
1130  IF J% = 0 AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; CMD$(C% - &H81); : GOTO 1210
1140  REM escaped command token
1150  IF J% = &HFD AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; XFD$(C% - &H81);""; : J% = 0: GOTO 1210
1160  IF J% = &HFE AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; XFE$(C% - &H81);""; : J% = 0: GOTO 1210
1170  IF J% = &HFF AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; XFF$(C% - &H81);""; : J% = 0: GOTO 1210
1180  REM regular characters
1190  IF C% < &H20 AND C% > 0 THEN PRINT C% - &H11; : GOTO 1210
1200  IF C% < &H20 OR C% > &H80 THEN PRINT " --";  ELSE PRINT " "; CHR$(C%); " ";
1210 NEXT I%
1220 PRINT
1230 REM address of next line
1240 TXT% = NXT%
1250 GOTO 770
1260 RETURN
1270 REM convert floating point number of K% (4 or 8) bytes 
1280 REM test for zero
1290 B%=0
1300 FOR D%=1 TO K% : B%=B%+PEEK(I%+D%) : NEXT D%
1310 IF B%=0 THEN N!=0! : GOTO 1430
1320 REM biased exponent
1330 E%=PEEK(I%+K%)-129
1340 REM negative sign bit
1350 S%=1-2*((PEEK(I%+K%-1) AND &H80)\128)
1360 D!=1! : REM D!=start value for bit value: 1.0, 0.5, 0.25, ...
1370 S!=1! : REM S!=start value for sum
1380 O%=&H7F : REM mask off sign on first mantissa byte
1390 FOR D%=K%-1 TO 1 STEP -1
1400  B%=PEEK(I%+D%) AND O% : GOSUB 1750 : O%=&HFF
1410 NEXT D%
1420 N!=S%*S!*2^E%
1430 N$=STR$(N!)
1440 N$=N$+SPACE$(3+K%*3-LEN(N$))
1450 RETURN
1460 REM CMD$ single byte tokens &H81 ... &HFC = 124 items
1470 DATA "END","FOR","NEXT","DATA","INPUT","DIM","READ","LET","GOTO"
1480 DATA "RUN","IF","RESTORE","GOSUB","RETURN","REM","STOP","PRINT","CLEAR"
1490 DATA "LIST","NEW","ON","WAIT","DEF","POKE","CONT","","","OUT"
1500 DATA "LPRINT","LLIST","","WIDTH","ELSE","TRON","TROFF","SWAP","ERASE"
1510 DATA "EDIT","ERROR","RESUME","DELETE","AUTO","RENUM","DEFSTR","DEFINT"
1520 DATA "DEFSNG","DEFDBL","LINE","WHILE","WEND","CALL","","",""
1530 DATA "WRITE","OPTION","RANDOMIZE","OPEN","CLOSE","LOAD","MERGE"
1540 DATA "SAVE","COLOR","CLS","MOTOR","BSAVE","BLOAD","SOUND","BEEP"
1550 DATA "PSET","PRESET","SCREEN","KEY","LOCATE","","TO","THEN","TAB("
1560 DATA "STEP","USR","FN","SPC(","NOT","ERL","ERR","STRING$","USING"
1570 DATA "INSTR","'","VARPTR","CSRLIN","POINT","OFF","INKEY$"
1580 DATA "","","","","","","",">","=","<","+","-","*","/","^"
1590 DATA "AND","OR","XOR","EQV","IMP","MOD","\","","","","","","","",""
1600 REM XFD$ escaped tokens &HFD + &H81...&H8B = 11 items
1610 DATA "CVI","CVS","CVD","MKI$","MKS$","MKD$","","","","","EXTERR"
1620 REM XFE$ escaped tokens &HFE + &H81...&HA8 = 40 items 
1630 DATA "FILES","FIELD","SYSTEM","NAME","LSET","RSET","KILL","PUT","GET"
1640 DATA "RESET","COMMON","CHAIN","DATE$","TIME$","PAINT","COM","CIRCLE"
1650 DATA "DRAW","PLAY","TIMER","ERDEV","IOCTL","CHDIR","MKDIR","RMDIR"
1660 DATA "SHELL","ENVIRON","VIEW","WINDOW","PMAP","PALETTE","LCOPY","CALLS"
1670 DATA "","","","","","LOCK","UNLOCK"
1680 REM XFF$ escaped tokens &HFF + &H81...&HA5 = 37 items 
1690 DATA "LEFT$","RIGHT$","MID$","SGN","INT","ABS","SQR","RND","SIN","LOG"
1700 DATA "EXP","COS","TAN","ATN","FRE","INP","POS","LEN","STR$","VAL","ASC"
1710 DATA "CHR$","PEEK","SPACE$","OCT$","HEX$","LPOS","CINT","CSNG","CDBL"
1720 DATA "FIX","PEN","STICK","STRIG","EOF","LOC","LOF"
1730 REM -------------------
1740 REM add value of each bit in byte J% to sum S!
1750 M%=&H80 : REM mask
1760 FOR F%=0 TO 7
1770  IF (B% AND M%) THEN S!=S!+D!
1780  REM shift mask
1790  M%=M%\2
1800  REM next bit value
1810  D!=D!/2!
1820 NEXT F%
1830 RETURN
1840 REM ----- output of simple variables
1850 PRINT "Simple Variables:"
1860 OFFS% = 1184 : ADR% = FNPEEKW(OFFS%) : REM ARYTAB
1870 OFFS% = 1182 : TXT% = FNPEEKW(OFFS%)
1880 T%=PEEK(TXT%) : TXT%=TXT%+1 : REM type 2,3,4,8
1890 C%=PEEK(TXT%) : N$=CHR$(C%) : TXT%=TXT%+1 : REM 1st character of name
1900 IF C% AND &H80 THEN N$="fn"+CHR$(C% AND &H7F) : REM function
1910 C%=PEEK(TXT%) : TXT%=TXT%+1 : REM 2nd character of name or zero
1920 IF C%<>0 THEN N$=N$+CHR$(C%)
1930 N%=PEEK(TXT%) : TXT%=TXT%+1 : REM number of extra chars in name
1940 FOR I%=1 TO N% : C%=PEEK(TXT%) AND &H7F : N$=N$+CHR$(C%) : TXT%=TXT%+1 : NEXT I%
1950 IF T%=2 THEN N$=N$+"%":N$="INTEGER "+CHR$(9)+N$
1960 IF T%=3 THEN N$=N$+"$":N$="STRING  "+CHR$(9)+N$
1970 IF T%=4 THEN N$=N$+"!":N$="SINGLE  "+CHR$(9)+N$
1980 IF T%=8 THEN N$=N$+"#":N$="DOUBLE  "+CHR$(9)+N$
1990 IF MID$(N$,10,2)="fn" THEN N$=N$+"   (function)"
2000 PRINT T%;N$
2010 TXT%=TXT%+T% : REM advance over data to next variable
2020 IF TXT%<ADR% THEN GOTO 1880
2030 RETURN
2040 REM ----- output of array variable
2050 PRINT "Array Variables:"
2060 OFFS% = 1186 : ADR% = FNPEEKW(OFFS%) : REM below STREND?
2070 OFFS% = 1184 : TXT% = FNPEEKW(OFFS%)
2080 T%=PEEK(TXT%) : TXT%=TXT%+1 : REM type 2,3,4,8
2090 C%=PEEK(TXT%) : N$=CHR$(C%) : TXT%=TXT%+1 : REM 1st character of name
2100 C%=PEEK(TXT%) : TXT%=TXT%+1 : REM 2nd character of name or zero
2110 IF C%<>0 THEN N$=N$+CHR$(C%)
2120 N%=PEEK(TXT%) : TXT%=TXT%+1 : REM number of extra chars in name
2130 FOR I%=1 TO N% : C%=PEEK(TXT%) AND &H7F : N$=N$+CHR$(C%) : TXT%=TXT%+1 : NEXT I%
2140 I% = FNPEEKW(TXT%) : TXT%=TXT%+2 : REM SIZE bytes follow
2150 N% = PEEK(TXT%) : REM NDIM
2160 IF T%=2 THEN N$=N$+"%":N$="INTEGER "+CHR$(9)+N$
2170 IF T%=3 THEN N$=N$+"$":N$="STRING  "+CHR$(9)+N$
2180 IF T%=4 THEN N$=N$+"!":N$="SINGLE  "+CHR$(9)+N$
2190 IF T%=8 THEN N$=N$+"#":N$="DOUBLE  "+CHR$(9)+N$
2200 PRINT T%;N$;" (";
2210 FOR I=TXT%+N%*2-1 TO TXT%+1 STEP -2 : REM right to left
2220  PRINT FNPEEKW(I);
2230  IF I>TXT%+1 THEN PRINT ",";
2240 NEXT I
2250 PRINT ")   ";N%;"DIMENSION(S)";I%;"BYTES INCL. NDIM,DIM..."
2260 TXT%=TXT%+I% : REM advance over data to next array
2270 IF TXT%<ADR% THEN GOTO 2080
2280 RETURN
2290 REM ----- END -----