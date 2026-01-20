10 REM Statistics of Two Variables
20 REM Demonstrates using the 8087 with MBASIC and GWBASIC.
30 REM Martin Hepperle, 2025
40 DIM CODE%(214)
50 DIM X#(3000),Y#(3000)
60 PRINT "Loading array data...";
70 REM --- Test case from many HP Solutions Books
80 REM N%=7
90 REM FOR I%=0 TO N%-1 : READ X#(I%) : NEXT I%
100 REM FOR I%=0 TO N%-1 : READ Y#(I%) : NEXT I%
110 REM DATA 26#, 30#, 44#, 50#, 62#, 68#,74#
120 REM DATA 92#, 85#, 78#, 81#, 54#, 51#, 40#
130 REM --- Another large test
140 REM N%=2501
150 REM FOR I%=0 TO N%-1 : X#(I%)=I%+1 : NEXT I%
160 REM FOR I%=0 TO N%-1 : Y#(I%)=I%*2+1 : NEXT I%
170 REM --- Another large test with means of 10 and 20
180 N%=2501
190 RANDOMIZE TIMER
200 FOR I%=0 TO N%-1 : X#(I%)=RND+9.5 : NEXT I%
210 FOR I%=0 TO N%-1 : Y#(I%)=RND+19.5 : NEXT I%
220 REM ---
230 PRINT " Done.  Calculating...";
240 REM pre-allocate all simple variables to avoid movement of CODE%()
250 SX#=0# : SY#=0# : SQX#=0# : SQY#=0# : SXY#=0#
260 SUM%=0 : SUMSQ%=0 : SUMXY%=0
270 BLOAD "STATSXY.BIN",VARPTR(CODE%(0))
280 REM Preparing addresses of entry points, 3 bytes apart (JMP NEAR)
290 SUM%=VARPTR(CODE%(0)) : SUMSQ%=SUM%+3 : SUMXY%=SUMSQ%+3 
300 CALL SUM%(X#(0),N%,SX#) : CALL SUM%(Y#(0),N%,SY#)
310 CALL SUMSQ%(X#(0),N%,SQX#) : CALL SUMSQ%(Y#(0),N%,SQY#)
320 CALL SUMXY%(X#(0),Y#(0),N%,SXY#)
330 REM Processing
340 N#=1#/N% : N1#=1#/(N%-1)
350 MX#=SX#*N# : MY#=SY#*N# : REM MEANs
360 QX#=(SQX#-SX#*MX#) : QY#=(SQY#-SY#*MY#)
370 SDX#=SQR(QX#*N1#) : SDY#=SQR(QY#*N1#) : REM STD DEVs
380 SVX#=QX#*N1# : SVY#=QY#*N1# : REM STD VARs
390 CV#=(SXY#-SX#*SY#*N#)*N1# : REM COV
400 CR#=CV#/(SDX#*SDY#) : REM CORR
410 PRINT " Done."
420 REM Output results
430 PRINT "Statistics of";N%;" Xi(),Yi() pairs:"
440 PRINT "Xi() from";X#(0);"to";X#(N%-1)
450 PRINT "Yi() from";Y#(0);"to";Y#(N%-1)
460 PRINT "SUM                    Xi   Yi   = ";SX#;TAB(60);SY#
470 PRINT "SUM                    Xi^2 Yi^2 = ";SQX#;TAB(60);SQY#
480 PRINT "SUM                      Xi*Yi   = ";SXY#
490 PRINT "COVARIANCE               Xi,Yi   = ";CV#
500 PRINT "CORRELATION COEFFICIENT  Xi,Yi   = ";CR#
510 PRINT "MEAN VALUE             Xi   Yi   = ";MX#;TAB(60);MY#
520 PRINT "SAMPLE STANDARD DEV    Xi   Yi   = ";SDX#;TAB(60);SDY#
530 PRINT "SAMPLE VARIANCE        Xi   Yi   = ";SVX#;TAB(60);SVY#
540 END
