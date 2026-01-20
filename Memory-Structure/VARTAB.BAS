10 REM
20 REM
30 REM
40 REM ! Do not change the first 3 empty REM lines!
50 REM Microsoft MBASIC, GWBASIC
60 REM Find addresses of VARTAB, ARYTAB, ...
70 REM ! 'I' MUST be the first defined simple variable!
80 REM Allocate all simple variables to avoid movement of R%()
90 I=0 : A=0 : B=0 : C=0 : D=0 : T=0 : U=0 : X=0 : Y=0 : Z=0 : L$=""
95 REM Allocate an array of integer elements
100 DIM R%(19,1) : R%(0,0)=1 : R%(1,0)=2 : R%(2,0)=3
110 REM first look for the sequence of the 3 empty REM lines
120 FOR I=100 TO 1500
130 Z=PEEK(I)+256*PEEK(I+1)
140 IF Z=65535! THEN GOTO 190
150 Y=PEEK(Z)+256*PEEK(Z+1)
160 IF Y=65535! THEN GOTO 190
170 X=PEEK(Y)+256*PEEK(Y+1) : REM sequence of lines 6 bytes apart?
180 IF Y=Z+6 AND X=Y+6 THEN PRINT "TXTTAB @";I;"->";Z;" start of BASIC program." : U=I : I=1000
190 NEXT I
200 REM -----
210 REM VARPTR returns address of the first data byte B0
220 REM 4,'I',0,0,B0,B1,B2,B3                           first simple var
230 A=VARPTR(I)-4
240 REM 2,'R',0,0,SIZ0,SIZ1,NDIM,D1L,D1H,D2L,D2H,B0,B1  first array var
250 B=VARPTR(R%(0,0))-11
260 FOR I=500 TO 2000
270 X=PEEK(I)+256*PEEK(I+1)
280 IF X=A THEN PRINT "VARTAB @";I;"->";X;"start of simple variables"
290 IF X=B AND T=1 THEN PRINT "ARYTA2 @";I;"->";X;"start of array variables, again" : I=2000
300 IF X=B AND T=0 THEN PRINT "ARYTAB @";I;"->";X;"start of array variables" : D=I : T=1
310 NEXT I
320 REM ----- string space above R%(): ARYTAB + 11 + 40*2 = 91 bytes
330 C=PEEK(D)+256*PEEK(D+1)+91
340 REM should also be stored at STREND:
350 I=D+2 : X=PEEK(I)+256*PEEK(I+1)
360 IF C=X THEN PRINT "STREND @";I;"->";X;"bottom of string space"
370 I=D+4 : X=PEEK(I)+256*PEEK(I+1)
380 REM DATPTR should be (*TXTTAB)-1
390 IF X=Z-1 THEN PRINT "DATPTR @";I;"->";X;"address of next DATA line"
400 REM ----- all 26 default types are 4
410 FOR I=500 TO 2000
420 FOR C=I TO I+26-1
430 IF PEEK(C)<>4 THEN GOTO 460
440 NEXT C
450 IF C=I+26 THEN PRINT "DEFTBL @";C-26;"start of default types A-Z [4,4,..,4]" : I=2000
460 NEXT I
470 REM ----- all 10 undefined USR? functions are &HFFFF
480 FOR I=100 TO 800
490 FOR C=I TO I+20-1
500 IF PEEK(C)<>255 THEN GOTO 530
510 NEXT C
520 IF C=I+20 THEN PRINT "USRTAB @";C-20;"start of USR functions 0-9" : I=800
530 NEXT I
540 REM ----- look for days/month table
550 FOR I=100 TO 1000
560 IF PEEK(I)<>31 THEN GOTO 620
570 IF PEEK(I+1)<>28 THEN GOTO 620
580 IF PEEK(I+2)<>31 THEN GOTO 620
590 IF PEEK(I+3)<>30 THEN GOTO 620
600 IF PEEK(I+11)<>31 THEN GOTO 620
610 PRINT "DAYSPM @";I;"days per month table [31,28,31,..,31]" : A=I : I=800
620 NEXT I
630 REM ----- likely 4 bytes in front of TXTTAB
640 A=U-4
650 PRINT "TOPMEM @";A;"->";PEEK(A)+256*PEEK(A+1);"top location for stack           ... likely, check"
660 REM ----- look for BUF buffer
670 INPUT "Enter '<' character 10 times ";L$
680 FOR I=100 TO 1000
690 FOR C=I TO I+9
700 IF PEEK(C)<>60 THEN GOTO 730
710 NEXT C
720 IF C=I+10 THEN PRINT "BUF    @";C-10;"start of input buffer" : I=1000
730 NEXT I
740 REM ----- read array data sequentially
750 PRINT "Linear access to 2D-Array variable R(20,2):"
760 B=B+11 : PRINT "R(0) ="; PEEK(B)+256*PEEK(B+1)
770 B=B+2 : PRINT "R(1) =";PEEK(B)+256*PEEK(B+1)
780 B=B+2 : PRINT "R(2) =";PEEK(B)+256*PEEK(B+1)
790 REM -----
800 END

