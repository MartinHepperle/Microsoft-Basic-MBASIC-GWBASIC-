10 REM
20 REM Microsoft BASIC 5.28 memory dumper
30 REM Addresses valid for MBASIC.EXE 
40 REM size: 31744 bytes
50 REM
60 REM Martin Hepperle, 2020
70 REM
80 REM Make sure that segment address is default
90 DEF SEG
100 DIM ARY(128)
110 DIM CMD$(126),XFF$(81)
120 REM get a word at A -> FN becomes a simple variable, bit 7 in 1st character set 
130 DEF FNPEEKW(A)=PEEK(A)+256*PEEK(A+1)
140 RESET
150 REM Read single byte tokens
160 FOR I% = 0 TO 125 : READ CMD$(I%) : NEXT I%
170 REM Read escaped tokens
180 FOR I% = 0 TO 80 : READ XFF$(I%) : NEXT I%
190 PRINT "Start offset for HEX dump";
200 INPUT S
210 E=S+4*64-1
220 L$ = ""
230 N=16
240 PRINT "MEMORY FROM";S;"TO";E;
250 REM PRINT RIGHT$("000"+HEX$(S),4);": ";
260 FOR I = S TO E
270  IF N = 16 THEN PRINT " "; L$ : N = 0 : L$ = "" : PRINT RIGHT$("000"+HEX$(I),4);": ";
280  C% = PEEK(I)
290  IF C% > 31 AND C%<128 THEN C$ = CHR$(C%) ELSE C$ = "."
300  L$ = L$ + C$
310  PRINT MID$("0" + HEX$(C%), 1 - (C% > 15)); " ";
320  N=N+1
330 NEXT I
340 IF N>0 THEN FOR I=1 TO 16-N : PRINT "   "; : NEXT I : PRINT " ";L$
350 PRINT "[Press ENTER to continue]" : LINE INPUT C$
360 PRINT "Variables:"
370 MSG$ = "TOPMEM": OFFS% = 348: GOSUB 620 : REM O.K. -> top of stack
380 MSG$ = "MAXMEM": OFFS% = 1157: GOSUB 620 : REM O.K. -> &HFFFE data seg size
390 MSG$ = "MEMSIZ": OFFS% = 1159: GOSUB 620 : REM O.K. -> &HFDFC max. offset used
400 MSG$ = "FRETOP": OFFS% = 1196: GOSUB 620 : REM O.K. -> 
410 REM MSG$ = "DEVTBL": OFFS% = 358: GOSUB 630 : REM ???
420 MSG$ = "STREND": OFFS% = 1244: GOSUB 620 : REM O.K. -> lower end of string vars
430 MSG$ = "ARYTAB": OFFS% = 1242: GOSUB 620 : REM O.K. -> array variables
440 MSG$ = "ARYTA2": OFFS% = 1483: GOSUB 620: REM O.K. same as ARYTAB
450 MSG$ = "VARTAB": OFFS% = 1240: GOSUB 620 : REM O.K. -> simple variables
460 MSG$ = "TXTTAB": OFFS% = 352: GOSUB 620 : REM O.K. -> program TEXT
470 MSG$ = "DATPTR": OFFS% = 1246: GOSUB 620 : REM O.K. -> initial DATA: 0 byte before TEXT
480 MSG$ = "AUTINC": OFFS% = 1215: GOSUB 620 : REM O.K. AUTO line # increment
490 MSG$ = "USRTAB": OFFS% = 285: GOSUB 620 : REM O.K. -> USR0 to USR9 functions
500 MSG$ = "DEFTBL": OFFS% = 1248: GOSUB 620 : REM O.K. -> 26 default types, 4,4 ...
510 MSG$ = "SAVSEG": OFFS% = 1230: GOSUB 620 : REM O.K. DEF SEG
520 PRINT "[Press ENTER to continue]" : LINE INPUT C$
530 REM output simple variables
540 GOSUB 1720
550 PRINT "[Press ENTER to continue]" : LINE INPUT C$
560 GOSUB 1930
570 PRINT "[Press ENTER to dump BASIC program]" : LINE INPUT C$
580 GOSUB 710
590 PRINT "Done."
600 STOP
610 REM ---
620 V = FNPEEKW(OFFS%)
630 H$ = HEX$(V)
640 H$ = RIGHT$("000"+H$,4)
650 PRINT MSG$; "-> 0x"; H$; " ="; STR$(V); "d (";HEX$(PEEK(OFFS%));" ";HEX$(PEEK(OFFS%+1));")";
660 IF V>4700 AND V<20000 THEN PRINT " -> ";HEX$(PEEK(V));",";HEX$(PEEK(V+1));",";HEX$(PEEK(V+2));",";HEX$(PEEK(V+3));",...";
670 PRINT
680 RETURN
690 REM --- dump BASIC program tokens
700 REM TXTTAB -> start of program
710 TXT% = 352
720 REM address of first line of BASIC program
730 TXT% = FNPEEKW(TXT%)
740 REM address of next line
750 NXT% = FNPEEKW(TXT%)
760 IF NXT% = 0 THEN GOTO 1200
770 REM line number
780 L% = FNPEEKW(TXT% + 2)
790 PRINT "LINE "; L%; " at "; TXT%; ":"; CHR$(9);
800 FOR I% = TXT% + 4 TO NXT% - 1
810  C% = PEEK(I%)
820  PRINT " "; MID$("0" + HEX$(C%), 1 - (C% > 15));
830 NEXT I%
840 PRINT
850 PRINT "                       "; CHR$(9);
860 J% = 0
870 FOR I% = TXT% + 4 TO NXT%-1
880  C% = PEEK(I%)
890  REM 0B: two byte OCT number
900  IF C% = &HB THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " &O"; OCT$(N%); : GOTO 1150
910  REM 0C: two byte HEX number
920  IF C% = &HC THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " &H"; HEX$(N%); : GOTO 1150
930  REM 0D: two byte address of line (compiled, GOTO line# becomes GOTO ADDR)
940  IF C% = &HD THEN A% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; PEEK(A% + 3) + 256 * PEEK(A% + 4) : GOTO 1150
950  REM 0E: two byte line number (not yet compiled)
960  IF C% = &HE THEN A% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; A%; : GOTO 1150
970  REM 0F: single byte integer number 0..255
980  IF C% = &HF THEN N% = PEEK(I%+1): I% = I% + 1: PRINT " "; N%; : GOTO 1150
990  REM 1C: two byte integer number
1000  IF C% = &H1C THEN N% = FNPEEKW(I%+1) : I% = I% + 2: PRINT " "; N%; : GOTO 1150
1010  REM 1D: four byte single floating point number
1020  IF C% = &H1D THEN  K%=4 : GOSUB 1210: I% = I% + 4: PRINT " "; N$; : GOTO 1150
1030  REM 1E: not handled
1040  REM 1F: eight byte double floating point number 
1050  IF C% = &H1F THEN K%=8 : GOSUB 1210: I% = I% + 8: PRINT " "; N$; : GOTO 1150
1060  REM escaped codes
1070  IF C% = &HFF THEN J% = C%: GOTO 1150
1080  REM regular command token
1090  IF J% = 0 AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; CMD$(C% - &H81); : GOTO 1150
1100  REM escaped command token
1110  IF J% = &HFF AND C% > &H80 AND C% < (&H80 + 127) THEN PRINT " "; XFF$(C% - &H81);""; : J% = 0: GOTO 1150
1120  REM regular characters
1130  IF C% < &H20 AND C% > 0 THEN PRINT C% - &H11; : GOTO 1150
1140  IF C% < &H20 OR C% > &H80 THEN PRINT " --";  ELSE PRINT " "; CHR$(C%); " ";
1150 NEXT I%
1160 PRINT
1170 REM address of next line
1180 TXT% = NXT%
1190 GOTO 750
1200 RETURN
1210 REM convert floating point number of K% (4 or 8) bytes 
1220 REM test for zero
1230 B%=0
1240 FOR D%=1 TO K% : B%=B%+PEEK(I%+D%) : NEXT D%
1250 IF B%=0 THEN N!=0! : GOTO 1370
1260 REM biased exponent
1270 E%=PEEK(I%+K%)-129
1280 REM negative sign bit
1290 S%=1-2*((PEEK(I%+K%-1) AND &H80)\128)
1300 D!=1! : REM D!=start value for bit value: 1.0, 0.5, 0.25, ...
1310 S!=1! : REM S!=start value for sum
1320 O%=&H7F : REM mask off sign on first mantissa byte
1330 FOR D%=K%-1 TO 1 STEP -1
1340  B%=PEEK(I%+D%) AND O% : GOSUB 1630 : O%=&HFF
1350 NEXT D%
1360 N!=S%*S!*2^E%
1370 N$=STR$(N!)
1380 N$=N$+SPACE$(3+K%*3-LEN(N$))
1390 RETURN
1400 REM CMD$ single byte tokens &H81 ... &HFC = 128 items
1410 DATA "END","FOR","NEXT","DATA","INPUT","DIM","READ","LET","GOTO"
1420 DATA "RUN","IF","RESTORE","GOSUB","RETURN","REM","STOP","PRINT","CLEAR"
1430 DATA "LIST","NEW","ON","NULL","WAIT","DEF","POKE","CONT","","","OUT"
1440 DATA "LPRINT","LLIST","","WIDTH","ELSE","TRON","TROFF","SWAP","ERASE"
1450 DATA "EDIT","ERROR","RESUME","DELETE","AUTO","RENUM","DEFSTR","DEFINT"
1460 DATA "DEFSNG","DEFDBL","LINE","BLOAD","BSAVE","WHILE","WEND","CALL"
1470 DATA "WRITE","COMMON","CHAIN","OPTION","RANDOMIZE","CALLS","SYSTEM"
1480 DATA "","OPEN","FIELD","GET","PUT","CLOSE","LOAD","MERGE","FILES"
1490 DATA "NAME","KILL","LSET","RSET","SAVE","RESET","","TO","THEN","TAB("
1500 DATA "STEP","USR","FN","SPC(","NOT","ERL","ERR","STRING$","USING"
1510 DATA "INSTR","","VARPTR","INKEY$","","","","","","","","","","",""
1520 DATA "","","","","","",">","=","<","+","-","*","/","^"
1530 DATA "AND","OR","XOR","EQV","IMP","MOD","\",""
1540 REM XFF$ escaped tokens &HFF + &H81...&HD1 = 81 items 
1550 DATA "LEFT$","RIGHT$","MID$","SGN","INT","ABS","SQR","RND","SIN","LOG"
1560 DATA "EXP","COS","TAN","ATN","FRE","INP","POS","LEN","STR$","VAL","ASC"
1570 DATA "CHR$","PEEK","SPACE$","OCT$","HEX$","LPOS","CINT","CSNG","CDBL"
1580 DATA "FIX","","","","","","","","","","","","CVI","CVS","CVD","","EOF"
1590 DATA "LOC","LOF","MKI$","MKS$","MKD$","","","","","","","","","","",""
1600 DATA "","","","","","","","","","","","","","","","","DATE","TIME"
1610 REM -------------------
1620 REM add value of each bit in byte J% to sum S!
1630 M%=&H80 : REM mask
1640 FOR F%=0 TO 7
1650  IF (B% AND M%) THEN S!=S!+D!
1660  REM shift mask
1670  M%=M%\2
1680  REM next bit value
1690  D!=D!/2!
1700 NEXT F%
1710 RETURN
1720 REM ----- output of simple variables
1730 PRINT "Simple Variables:"
1740 OFFS% = 1242 : ADR% = FNPEEKW(OFFS%) : REM ARYTAB
1750 OFFS% = 1240 : TXT% = FNPEEKW(OFFS%) : REM VARTAB
1760 T%=PEEK(TXT%) : TXT%=TXT%+1 : REM type 2,3,4,8
1770 C%=PEEK(TXT%) : N$=CHR$(C%) : TXT%=TXT%+1 : REM 1st character of name
1780 IF C% AND &H80 THEN N$="fn"+CHR$(C% AND &H7F) : REM function
1790 C%=PEEK(TXT%) : TXT%=TXT%+1 : REM 2nd character of name or zero
1800 IF C%<>0 THEN N$=N$+CHR$(C%)
1810 N%=PEEK(TXT%) : TXT%=TXT%+1 : REM number of extra chars in name
1820 FOR I%=1 TO N% : C%=PEEK(TXT%) AND &H7F : N$=N$+CHR$(C%) : TXT%=TXT%+1 : NEXT I%
1830 IF T%=2 THEN N$=N$+"%":N$="INTEGER "+CHR$(9)+N$
1840 IF T%=3 THEN N$=N$+"$":N$="STRING  "+CHR$(9)+N$
1850 IF T%=4 THEN N$=N$+"!":N$="SINGLE  "+CHR$(9)+N$
1860 IF T%=8 THEN N$=N$+"#":N$="DOUBLE  "+CHR$(9)+N$
1870 IF MID$(N$,10,2)="fn" THEN N$=N$+"   (function)"
1880 PRINT T%;N$
1890 TXT%=TXT%+T% : REM advance over data to next variable
1900 IF TXT%<ADR% THEN GOTO 1760
1910 RETURN
1920 REM ----- output of array variable
1930 PRINT "Array Variables:"
1940 OFFS% = 1244 : ADR% = FNPEEKW(OFFS%) : REM STREND
1950 OFFS% = 1242 : TXT% = FNPEEKW(OFFS%) : REM ARYTAB
1960 T%=PEEK(TXT%) : TXT%=TXT%+1 : REM type 2,3,4,8
1970 C%=PEEK(TXT%) : N$=CHR$(C%) : TXT%=TXT%+1 : REM 1st character of name
1980 C%=PEEK(TXT%) : TXT%=TXT%+1 : REM 2nd character of name or zero
1990 IF C%<>0 THEN N$=N$+CHR$(C%)
2000 N%=PEEK(TXT%) : TXT%=TXT%+1 : REM number of extra chars in name
2010 FOR I%=1 TO N% : C%=PEEK(TXT%) AND &H7F : N$=N$+CHR$(C%) : TXT%=TXT%+1 : NEXT I%
2020 I% = FNPEEKW(TXT%) : TXT%=TXT%+2 : REM SIZE bytes follow
2030 N% = PEEK(TXT%) : REM NDIM
2040 IF T%=2 THEN N$=N$+"%":N$="INTEGER "+CHR$(9)+N$
2050 IF T%=3 THEN N$=N$+"$":N$="STRING  "+CHR$(9)+N$
2060 IF T%=4 THEN N$=N$+"!":N$="SINGLE  "+CHR$(9)+N$
2070 IF T%=8 THEN N$=N$+"#":N$="DOUBLE  "+CHR$(9)+N$
2080 PRINT T%;N$;" (";
2090 FOR I=TXT%+N%*2-1 TO TXT%+1 STEP -2 : REM right to left
2100  PRINT FNPEEKW(I);
2110  IF I>TXT%+1 THEN PRINT ",";
2120 NEXT I
2130 PRINT ")   ";N%;"DIMENSION(S)";I%;"BYTES INCL. NDIM,DIM..."
2140 TXT%=TXT%+I% : REM advance over data to next array
2150 IF TXT%<ADR% THEN GOTO 1960
2160 RETURN
2180 REM ----- END -----