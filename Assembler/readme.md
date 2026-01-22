Examples for using BASIC with Assembler routines.
* GETSEG(DS%,CS%) . return the CS and DS segments of a called subroutine (CS==DS)
* SUM(X#(),N%,SX#) - calculate the sum of array elements using the 80x87 math coprocessor
* SUMSQ(X#(),N%,SQX#) - calculate the sum of the square of array elements using the 80x87 math coprocessor
* SUMXY(X#(),Y#(),N%,SXY#) - calculate the sum of the product of corresponding array elements using the 80x87 math coprocessor
* STATSXY - combines SUM, SUMSQ, SUMXY for statistical analysis using the 80x87 math coprocessor
* TRANS(S$,T$) - translate characters in a string from one set to another (limited to codes 0..255)
* TRANS%(B$,T%()) - translate characters in a string from one set to another (converts codes 0..256)
* REV(A$,B$) - reverse the characters in a string
* OCC%(A$,I%,N%) - count the occurances of one specific character code in a astring
* INTER(INT%,AX%,BX%,CX%,DX%,DS%,ES%,SI%,DI%) - call an interrupt with a given set of registers
* TOUPPER(S$) - convert a string to upper case
* TOLOWER(S$) - convert a string to lower case
* CHKSUM%(S$,C%) - calculate the checksum over the characters in a string
* BITCOUNT (I%) - count the '1'-bits in an integer
