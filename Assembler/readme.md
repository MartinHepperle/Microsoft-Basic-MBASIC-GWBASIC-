Examples for using BASIC with Assembler routines.
Each archive contains the assembler source, the assembled binary and an example program.
The binary can be built from the assembler module by running GO.BAT (adapt to your environment).

* BIN$(I%,S$) - Return a string of "0", "1" characters with the binary value of I%.
* BITCOUNT (I%) - count the '1'-bits in an integer.
* BITS... - a whole bunch of functions combined into a larger module, demonstrating two methods of loading the binary.
* CHKSUM%(S$,C%) - calculate the checksum over the characters in a string.
* GETSEG(DS%,CS%) . return the CS and DS segments of a called subroutine (CS==DS).
* INT(INT%,AX%,BX%,CX%,DX%,DS%,ES%,SI%,DI%) - call an interrupt with a given set of registers.
* MEMSET(MAT%(0),L%,V%) - set the values of an array to a constant value.
* OCC%(A$,I%,N%) - count the occurances of one specific character code in a astring
* REV(A$,B$) - reverse the characters in a string
* STATSXY() - combines SUM, SUM2, SUMXY for statistical analysis using the 80x87 math coprocessor, includes floating point conversion between IEEE-754 and MBF.
* SUM(X#(),N%,SX#) - calculate the sum of array elements using the 80x87 math coprocessor, includes floating point conversion between IEEE-754 and MBF.
* SUM2(X#(),N%,SQX#) - calculate the sum of the square of array elements using the 80x87 math coprocessor, includes floating point conversion between IEEE-754 and MBF.
* SUMXY(X#(),Y#(),N%,SXY#) - calculate the sum of the product of corresponding array elements using the 80x87 math coprocessor, includes floating point conversion between IEEE-754 and MBF.
* TICKS (T%) - Wait until T% timer ticks (18.2 per second) have passed.
* TOLOWER(S$) - convert a string to lower case.
* TOUPPER(S$) - convert a string to upper case.
* TRANS(S$,T$) - translate characters in a string from one set to another (limited to codes 0..255).
* TRANS%(B$,T%()) - translate characters in a string from one set to another (converts codes 0..256).
