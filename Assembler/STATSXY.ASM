PAGE 60,120
; ---------------------------------------------------------------------
; A simple example for using a 80x87 math coprocessor from
; interpreted Microsoft BASIC like MBASIC or GWBASIC.
;
; These two BASIC versions use the MBF representation for floating
; point numbers, so that a conversion of input and output to
; resp. from the IEEE-754 format is required.
; Despite the conversion effort, the code using the coprocessor runs
; faster than the interpreted BASIC code when the array size is large.
;
; Building:
; ---------
; MASM SUMXY,SUMXY;
; LINK SUMXY;                 Neglect "no stack segment" warning
; EXE2BIN SUMXY.EXE SUMXY.BIN
; DEL SUMXY.EXE
;
; or:
;
; TASM /L SUMXY
; TLINK SUMXY
; EXE2BIN SUMXY.EXE SUMXY.BIN
; DEL SUMXY.EXE
;
; Usage:
; ------
; This module contains three subroutines
; All use BASIC arrays and integers for input and one output.
; The input arrays X# and Y# MUST be declared as double (8 bytes).
; The output parameter S# MUST also be double (8 bytes).
; The count N% MUST be integer (2 bytes).
; Warning: the code expects, but does not test for the presence of
; an 80x87 coprocessor, therefore use it only if one is installed.
; Also no tests for over- or underflow are performed.
; 
; Subroutines:
;
; SUMX ( X#, N%, S# )
;    Sum the first N% elements in array X#.
; SUMXQ ( X#, N%, S# )
;    Sum the first N% elements in array X#.
; SUMXY ( X#, Y#, N%, S# )
;    Sum the products of the first N% elements in arrays X# and Y#.
;
; Parameters:
; X#() input,  8 byte double,  first element of array
; Y#() input,  8 byte double,  first element of array
; N%   input,  2 byte integer, element count
; S#   output, 8 byte double,  result
;
; In BASIC all parameters are passed by reference (as offsets into DS).
;
; The code can be BLOADed into an integer array of sufficient size.
; The binary file starts with a 7 byte BLOAD header, which is not loaded.
; Binary file size: 430 bytes => (430-7)/2 - 1 => DIM CODE%(214) or larger
; 
; DIM CODE%(214) : REM INTEGER
; DIM X#(2500)   : REM DOUBLE
; DIM Y#(2500)   : REM DOUBLE
; REM preset array with some test values
; FOR K%=0 TO 2500 : X#(K%)=K%-1250 : NEXT K%
; FOR K%=0 TO 2500 : Y#(K%)=K%+1250 : NEXT K%
; REM load routine into memory
; BLOAD "STATSXY.BIN",VARPTR(CODE%(0))
; REM 2501 elements from 0 to 2500 - INTEGER
; N%=2501
; REM pre-allocate DOUBLE variables for results
; SX#=0# : SXQ#=0# : SXY#=0#
; REM Note: any new scalar variable allocation moves arrays!
; REM Therefore, pre-allocate variables before obtaining code addresses 
; SUMX%=0 : SUMXQ%=0 : SUMXY%=0
; SUMX%=VARPTR(CODE%(0))
; SUMXQ%=SUMX%+3 
; SUMXY%=SUMXQ%+3
; CALL SUMX%(X#(0),N%,SX#)
; CALL SUMXQ%(X#(0),N%,SXQ#)
; CALL SUMXY%(X#(0),Y#(0),N%,SXY#)
;
; Martin Hepperle, 2025
; ---------------------------------------------------------------------

.8086               ; enable 8086 instruction set
.8087               ; enable coprocessor instructions, automatically inserts FWAITs

DEBUG    EQU    0   ; 0=release version, load STATSXY.BIN into BASIC
;DEBUG    EQU    1   ; 1=debug version, run as STATSXY.EXE

; header for BLOAD command (7 bytes)
MAGIC  EQU  0FDh
BLOAD_HDR STRUC
     HDR_MAGIC  DB MAGIC
     HDR_SEG    DW ?                ; not used
     HDR_OFF    DW ?                ; not used
     HDR_LEN    DW ?                ; number of bytes to load
BLOAD_HDR ENDS

; for addressing parameter lists of the form X#(), N%, S#
ARRAY_1_FRAME STRUC
               DW ?         ;   0 saved BP
               DW 2 DUP(?)  ;   2 RETURN far address
       S_1     DW ?         ;   6 last parameter
       N_1     DW ?         ;   8 second parameter
       X_1     DW ?         ;  10 first parameter
ARRAY_1_FRAME ENDS

; for addressing parameter lists of the form X#(), Y#(), N%, S#
ARRAY_2_FRAME STRUC
               DW ?         ;   0 saved BP
               DW 2 DUP(?)  ;   2 RETURN far address
       S_2     DW ?         ;   6 last parameter
       N_2     DW ?         ;   8 second parameter
       Y_2     DW ?         ;  10 first parameter
       X_2     DW ?         ;  12 first parameter
ARRAY_2_FRAME ENDS

; ---------------------------------------------------------------------
if DEBUG
; define function call parameters
; =====================================================================
D_SEG SEGMENT WORD PUBLIC 'DATA'
; ---------------------------------------------------------------------
             ; 1/3 in MBF double, GWBASIC: 1#/3#
             DB 'X[' ; marker for debugging
       X_    DB      0ABh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 02Ah, 07Fh
             ; 1/4 in MBF double, GWBASIC: 1#/3#
             DB  0, 0, 0, 0, 0, 0, 0, 07Fh,  02Ah, 07Fh
             DB ']' ; marker for debugging

             DB 'Y[' ; marker for debugging
       Y_    DB  0ABh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 02Ah, 07Fh
             ; 1/4 in MBF double, GWBASIC: 1#/3#
             DB  0, 0, 0, 0, 0, 0, 0, 07Fh,  02Ah, 07Fh
             DB ']' ; for debugging
             ; sum in MBF must be 1/3 + 1/4 = 0.5833333 
             ;   = 5x 55 55 55 55 55 15 80 where x can be 0...4

             DB 'N<' ; marker for debugging
       N_    DW  2
             DB '>' ; marker for debugging

             DB 'S<' ; marker for debugging
       S_    DB  0, 0, 0, 0, 0, 0, 0, 0,  0, 0

             DB 'BUF<' ; marker for debugging
DBLE_BUF     DQ ?   ; 8 byte conversion buffer MBF <-> IEEE
SI_SAVE      DW ?   ; save SI address of Y#() in SUMXY()
             DB '>' ; marker for debugging
D_SEG ENDS
; ---------------------------------------------------------------------
S_SEG SEGMENT PARA STACK 'STACK'
       DB 128 DUP(7)
S_SEG ENDS
; ---------------------------------------------------------------------
endif
; ---------------------------------------------------------------------

; =====================================================================
C_SEG SEGMENT BYTE PUBLIC 'CODE'
; ---------------------------------------------------------------------
if DEBUG
      ASSUME CS:C_SEG,DS:D_SEG,SS:S_SEG
else
      ASSUME CS:C_SEG,DS:C_SEG,ES:C_SEG    ; BASIC uses small model
      ORG  0               ; will be EXE2BINed into a BLOADable binary file
endif
ENTRY:
; ---------------------------------------------------------------------
if DEBUG

      ; test routine linked as .EXE program

      MOV  AX,SEG X_       ; ADDRESS OF DATA SEGMENT
      MOV  DS,AX           ; TO DATA SEGMENT
      MOV  ES,AX           ; TO EXTRA SEGMENT
      ASSUME DS:D_SEG      ; TELL ASSEMBLER
      ASSUME ES:D_SEG      ; TELL ASSEMBLER

      ; --- test SUMXY function

      LEA  AX,X_           ; address of X#()
      PUSH AX
      LEA  AX,Y_           ; address of Y#()
      PUSH AX
      LEA  AX,N_           ; address of N%
      PUSH AX
      LEA  AX,S_           ; address of S#
      PUSH AX

      CALL FAR PTR SUMXY

      MOV  AH,4Ch
      MOV  AL,0FFh
      INT  21H                  ; terminate
endif
; ---------------------------------------------------------------------

; note on naming: mantissa == significand
;                 biased exponent == characteristic.
; Double Precision, 8 bytes floating point formats:
; MBF:  mantissa: 63 bits, exponent 8 bits, biased 129, sign 1 bit
; IEEE: mantissa: 60 bits, exponent 11 bits, biased 1023, sign 1 bit
; IEEE has 3 additional exponent bits, 3 mantissa bits of MBF are lost
;
; MBF       = MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM SMMMMMMM EEEEEEEE
; MBF       = TTTTTggg RRRRRfff QQQQQeee PPPPPddd OOOOOccc NNNNNbbb 0MMMMaaa EEEEEEEE
; (lost: ggg) fffTTTTT eeeRRRRR dddQQQQQ cccPPPPP bbbOOOOO aaaNNNNN EEEEMMMM SeeeEEEE
;             0        1        2        3        4        5        6        7
; IEEE-754  = SeeeEEEE EEEEMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
;             7        6        5        4        3        2        1        0
;

if DEBUG
; no header for BLOAD command neded
else
; define header for BLOAD command
BLOAD_HDR    <MAGIC,0,0,END_OF_CODE-START_OF_CODE>
endif

START_OF_CODE LABEL NEAR

;    The entry points
;    All entries are 3 bytes apart, assembler may insert NOPs
     JMP NEAR PTR SUMX    ; 0 sum Xi
     JMP NEAR PTR SUMXQ   ; 3 sum Xi^2
     JMP NEAR PTR SUMXY   ; 6 sum Xi*Yi

; ---------------------------------------------------------------------
; Usage:
; CALL SUMX ( X#, N%, S# )
;
; Sum the first N% elements in array X#.
;
; All parameters are passed by reference as offsets.
; Result is returned in the last parameter.
;
;      +10  X#    offset 1. parameter
;       +8  N%    offset 2. parameter
;       +6  S#    offset 3. parameter
;       +4  return address segment CS, pushed by far call
;       +2  return address offset  IP, pushed by far call
; BP->  +0  BP saved (after PUSH BP)
;
SUMX  PROC FAR

      ; Interpreted BASIC: CS == DS == ES == DEF SEG

      PUSH BP                          ; save BP
      MOV  BP,SP                       ; copy SP

      ; get absolute address of DBLE_BUF to DI
if DEBUG
      MOV  DI, OFFSET DBLE_BUF         ; in data segment of .exe file
else
      CALL H_1                         ; relocate
H_1:  POP  DI                          ; get absolute address of H_1
      ADD  DI, OFFSET DBLE_BUF - OFFSET H_1
                                       ; absolute address of DBLE_BUF
endif

      FINIT                            ; initialize the coprocessor
      FLDZ                             ; load zero to stack
                                       
      ; prepare loop                   
      MOV  SI,[BP].X_1                 ; get address of X#()
                                       
      MOV  BX,[BP].N_1                 ; get address of N%
      MOV  CX,[BX]                     ; loop counter

NEXT_ELEM_1:
      ; ----- copy next number from X#() (DS:SI) to DBLE_BUF (ES:DI)
      MOV  BX,CX                       ; save loop counter
      MOV  CX,4                        ; copy 8 bytes from SI to DI 
      REP  MOVSW                       ; increments SI and DI by 8
      SUB  DI,8                        ; back to DBLE_BUF for conversion, leave SI at next element
      CALL MBF_TO_IEEE                 ; convert 8 byte MBF in [DI...DI+7] to IEEE-754 format, preserves BX, SI, DI
      MOV  CX,BX                       ; restore loop counter
      ; -----                            add element to sum
      FADD QWORD PTR [DI]              ; ST <= ST + DBLE_BUF
      LOOP NEXT_ELEM_1                   
                                       
      FSTP QWORD PTR [DI]              ; drop result to DBLE_BUF

      ; convert result back to MBF
      CALL IEEE_TO_MBF                 ; convert 8 byte IEEE-754 in [DI...DI+7] to MBF real format
                                       
      MOV SI,DI                        ; source for REP MOVSW
      MOV DI,[BP].S_1                  ; destination: address of S#
      MOV CX,4                         ; copy 8 bytes from SI to DI 
      REP MOVSW                        
                                       
      POP  BP                          ; restore
                                       
      RET  6                           ; drop 3 word parameters (near addresses)

SUMX  ENDP

; ---------------------------------------------------------------------
; Usage:
; CALL SUMXQ ( X#, N%, S# )
;
; Sum the squares of the first N% elements in array X#.
;
; All parameters are passed by reference as offsets.
; Result is returned in the last parameter.
;
;      +10  X#    offset 1. parameter
;       +8  N%    offset 2. parameter
;       +6  S#    offset 3. parameter
;       +4  return address segment CS, pushed by far call
;       +2  return address offset  IP, pushed by far call
; BP->  +0  BP saved (after PUSH BP)
;
SUMXQ PROC FAR

      ; Interpreted BASIC: CS == DS == ES == DEF SEG

      PUSH BP                          ; save BP
      MOV  BP,SP                       ; copy SP

      ; get absolute address of DBLE_BUF to DI
if DEBUG
      MOV  DI, OFFSET DBLE_BUF         ; in data segment of .exe file
else
      CALL H_2                         ; relocate
H_2:  POP  DI                          ; get absolute address of H_2
      ADD  DI, OFFSET DBLE_BUF - OFFSET H_2    ; absolute address of DBLE_BUF
endif

      FINIT                            ; initialize the coprocessor
      FLDZ                             ; load zero to stack ST: 0
                                       
      ; prepare loop                   
      MOV  SI,[BP].X_1                 ; get address of X#()
                                       
      MOV  BX,[BP].N_1                 ; get address of N%
      MOV  CX,[BX]                     ; loop counter

NEXT_ELEM_2:
      ; ----- copy next number from X#() (DS:SI) to DBLE_BUF (ES:DI)
      MOV  BX,CX                       ; save loop counter
      MOV  CX,4                        ; copy 8 bytes from SI to DI 
      REP  MOVSW                       ; increments SI and DI by 8
      SUB  DI,8                        ; back to DBLE_BUF for conversion, leave SI at next element
      CALL MBF_TO_IEEE                 ; convert 8 byte MBF in [DI...DI+7] to IEEE-754 format, preserves BX, SI, DI
      MOV  CX,BX                       ; restore loop counter
                                       
      ; -----                            load element, square it and add square to sum
      FLD  QWORD PTR [DI]              ; ST: 0, DBLE_BUF
      FMUL QWORD PTR [DI]              ; ST: 0, DBLE_BUF^2
      FADD                             ; ST: 0+DBLE_BUF^2
      ; -----
      LOOP NEXT_ELEM_2

      FSTP QWORD PTR [DI]              ; drop result to DBLE_BUF

      ; convert result back to MBF
      CALL IEEE_TO_MBF                 ; convert 8 byte IEEE-754 in [DI...DI+7] to MBF real format
                                       
      MOV SI,DI                        ; source for REP MOVSW
      MOV DI,[BP].S_1                  ; destination: address of S#
      MOV CX,4                         ; copy 8 bytes from SI to DI 
      REP MOVSW                        
                                       
      POP  BP                          ; restore
                                       
      RET  6                           ; drop 3 word parameters (near addresses)

SUMXQ  ENDP

; ---------------------------------------------------------------------
; Usage:
; CALL SUMXY ( X#, Y#, N%, S# )
;
; Sum the products of the first N% elements in arrays X# and Y#.
;
; All parameters are passed by reference as offsets.
; Result is returned in the last parameter.
;
;      +12  X#    offset 1. parameter
;      +10  Y#    offset 2. parameter
;       +8  N%    offset 3. parameter
;       +6  S#    offset 4. parameter
;       +4  return address segment CS, pushed by far call
;       +2  return address offset  IP, pushed by far call
; BP->  +0  BP saved (after PUSH BP)
;
SUMXY PROC FAR
   
      ; Interpreted BASIC: CS == DS == ES == DEF SEG

      PUSH BP                          ; save BP
      MOV  BP,SP                       ; copy SP

      ; get absolute address of DBLE_BUF to DI
if DEBUG
      MOV  DI, OFFSET DBLE_BUF         ; in data segment of .exe file
else
      CALL H_3                         ; relocate
H_3:  POP  DI                          ; get absolute address of H_3
      ADD  DI, OFFSET DBLE_BUF - OFFSET H_3    ; absolute address of DBLE_BUF
endif

      FINIT                            ; initialize the coprocessor
      FLDZ                             ; load zero to stack ST: 0
                                       
      ; prepare loop                   
      MOV  SI,[BP].Y_2                 ; get address of Y#()
      PUSH SI                          ; save address
      MOV  SI,[BP].X_2                 ; get address of X#()
                                       
      MOV  BX,[BP].N_2                 ; get address of N%
      MOV  CX,[BX]                     ; loop counter

NEXT_ELEM_3:
      ; ----- copy next number from X#() (DS:SI) to DBLE_BUF (ES:DI)
      MOV  BX,CX                       ; save loop counter
      MOV  CX,4                        ; copy 8 bytes X#() from SI to DI 
      REP  MOVSW                       ; increments SI and DI by 8
      MOV  [DI],SI                     ; save address of X#() at SI_SAVE
      SUB  DI,8                        ; back to DBLE_BUF for conversion, leave SI at next element
      CALL MBF_TO_IEEE                 ; convert 8 byte MBF in [DI...DI+7] to IEEE-754 format, preserves BX, SI, DI
      ; -----                            load element X#()
      FLD  QWORD PTR [DI]              ; ST: 0, DBLE_BUF

      POP  SI                          ; restore address Y#()
      MOV  CX,4                        ; copy 8 bytes from SI to DI 
      REP  MOVSW                       ; increments SI and DI by 8
      PUSH SI                          ; save incremented address
      MOV  SI,[DI]                     ; restore address of X#() from SI_SAVE
      SUB  DI,8                        ; back to DBLE_BUF for conversion, leave SI at next element
      CALL MBF_TO_IEEE                 ; convert 8 byte MBF in [DI...DI+7] to IEEE-754 format, preserves BX, SI, DI

      MOV  CX,BX                       ; restore loop counter
                                       
      ; -----                            multiply element X#() by Y#() and add to sum
      FMUL QWORD PTR [DI]              ; ST: 0, DBLE_BUF^2
      FADD                             ; ST: 0+DBLE_BUF^2
      ; -----
      LOOP NEXT_ELEM_3

      POP  SI                          ; drop address Y#() to balance stack

      FSTP QWORD PTR [DI]              ; drop result to DBLE_BUF

      ; convert result back to MBF
      CALL IEEE_TO_MBF                 ; convert 8 byte IEEE-754 in [DI...DI+7] to MBF real format
                                       
      MOV SI,DI                        ; source for REP MOVSW
      MOV DI,[BP].S_2                  ; destination: address of S#
      MOV CX,4                         ; copy 8 bytes from SI to DI 
      REP MOVSW                        
                                       
      POP  BP                          ; restore
                                       
      RET  2*4                         ; drop 4 word parameters (near addresses)

SUMXY   ENDP
; ---------------------------------------------------------------------

MBF_TO_IEEE PROC NEAR
;
; Input:
; DI = address of buffer, on entry: MBF, on exit: IEEE-754
; preserves BX, SI, DI
; destroys  AX, CX, DX
;
; MBF       = EEEEEEEE SMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMmmm
;             7        6        5        4        3        2        1        0
; IEEE-754  = SeeeEEEE EEEEMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
;             7        6        5        4        3        2        1        0
;
; MBF to IEEE-754:
; ----------------
; E% = B%(7) - 129 + 1023               newly biased exponent
; S% = B%(6) AND 128                    sign bit
; B%(6) = B%(6) AND 127                 leave mantissa bits
; B%(0) = B%(0)\8 + (B%(1) AND 7)*32    upper 5 bits of B%(0) + lower 3 bits of B%(1)
; B%(1) = B%(1)\8 + (B%(2) AND 7)*32
; B%(2) = B%(2)\8 + (B%(3) AND 7)*32
; B%(3) = B%(3)\8 + (B%(4) AND 7)*32
; B%(4) = B%(4)\8 + (B%(5) AND 7)*32
; B%(5) = B%(5)\8 + (B%(6) AND 7)*32
; B%(6) = B%(6)\8 + (E% AND 15)*16
; B%(7) = (E%\16 AND 127) + S%          upper 4 bits to lower 4 bits + sign bit 7
;
            PUSH DI                    ; save

            ; save sign bit in DL, 8-bit exponent in DH
            MOV DX,[DI+6]              ; get DH.DL=B(7).B(6) and ...
            AND DL,128                 ; ... mask sign bit
                                       
            MOV CX,6                   ; loop over bytes 0..5, could be optimized using 3 words instead
NEXT1:                                 
            PUSH CX                    ; save loop counter
            MOV CL,3                   
            MOV AL,[DI]                ; take upper 5 bits        76543...
            SHR AL,CL                  ; shift right by 3 bits to ...76543
            ;                          
            MOV AH,[DI+1]              ; take lower 3 bits of next byte
            AND AH,7                   ; mask lower 3 bits         .....210
            ROR AH,CL                  ; rotate right by 5 bits to 210.....
            ;                          
            OR AL,AH                   ; combine
            MOV [DI],AL                ; store
            INC DI                     ; 0..6
            POP CX                     ; restore
            LOOP NEXT1

            ; loop ends with DI=6, copy remaining six mantissa bits
            MOV AL,[DI]                ; take byte 6
            AND AL,127                 ; ... mask off sign bit
            MOV CL,3                   ; shift count
            SHR AL,CL                  ; shift remaining 7 mantissa bits right by 3 bits to bits 3..0
            MOV [DI],AL                ; store these 4 mantissa bits

            MOV AH,DL                  ; save sign bit

            ; apply new bias to exponent
            MOV DL,DH                  ; 8-bit exponent to low byte
            XOR DH,DH                  ; zero high byte
            CMP DX,0                   ; zero?
            JE  ZERO1                  ; leave exponent alone
            ADD DX,(1023-129)          ; adjustment may produce upper 4 bits in DH
ZERO1:                                 
            INC CL                     ; make 4
            MOV AL,DL                  ; take lower 4 bits of new exponent
            SHL AL,CL                  ; shift left by 4 bits to bits 7..4
            OR [DI],AL                 ; ...and add to mantissa bits 3..0
                                       
            INC DI                     ; move on to byte 7
            SHR DX,CL                  ; shift remaining 8 bits right, exposing 4 zero bits
            OR  DL,AH                  ; set the sign bit 7
            MOV [DI],DL                ; to lower 8 bits
                                       
            POP DI                     ; restore

            RET

MBF_TO_IEEE ENDP

; ---------------------------------------------------------------------

IEEE_TO_MBF PROC NEAR
;
; Input:
; DI = address of buffer, on entry: MBF, on exit: IEEE-754
; preserves BX, SI, DI
; destroys  AX, CX, DX
;
; IEEE-754  = SeeeEEEE EEEEMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
;             7        6        5        4        3        2        1        0
; MBF       = EEEEEEEE SMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMmmm
;             7        6        5        4        3        2        1        0
; IEEE-754 to MBF:
; ----------------
; S% = B%(7) AND 128                               sign bit
; B%(7) = (B%(7) AND 127)*16 + B(6)\16 - 1023 + 129   newly biased exponent
; B%(6) = (B%(6) AND 15)*8 + (B%(5) AND 224)\32 OR S%
; B%(5) = (B%(5) AND 31)*8 + (B%(4) AND 224)\32    3 upper bits to lower 3 bits
; B%(4) = (B%(4) AND 31)*8 + (B%(3) AND 224)\32    3 upper bits to lower 3 bits
; B%(3) = (B%(3) AND 31)*8 + (B%(2) AND 224)\32    3 upper bits to lower 3 bits
; B%(2) = (B%(2) AND 31)*8 + (B%(1) AND 224)\32    3 upper bits to lower 3 bits
; B%(1) = (B%(1) AND 31)*8 + (B%(0) AND 224)\32    3 upper bits to lower 3 bits
; B%(0) = B%(0)*8 AND 248                          5 lower bits of B%(0) to upper 5 bits

            ; truncate 11 bit exponent to 8 bit
            MOV DH,BYTE PTR [DI+7]     ; get B(7)
            AND DH,127                 ; clear sign bit
            MOV DL,BYTE PTR [DI+6]     ; get B(6)
            MOV CL,4                   
            SHR DX,CL                  ; /16
            CMP DX,0                   ; if zero
            JE  ZERO2                  ; leave exponent alone
            SUB DX,(1023-129)          ; DL: newly biased exponent
ZERO2:
            ; grab sign bit before overwriting B(7)
            MOV DH,BYTE PTR [DI+7]     ; get DH=B(7)
            AND DH,128                 ; leave sign bit in DH
            ; write 8 bit exponent to B(7)
            MOV BYTE PTR [DI+7],DL     ; set B(7)

            MOV AL,BYTE PTR [DI+6]     ; get the lower 4 bits of B(6)
            AND AL,00001111b           ; mask 4 bits   ....3210
            DEC CL                     ; make 3
            SHL AL,CL                  ; shift left to .3210... (leave space for sign bit)
                                       ;
            MOV AH,BYTE PTR [DI+5]     ; get upper 3 bits of B(5)
            ; mask bits 0..2 and roll 3 times right
            AND AH,224                 ; mask upper 3 bits        765.....
            ROL AH,CL                  ; rotate left by 3 bits to .....765

            OR  AL,AH                  ; merge both parts
            OR  AL,DH                  ; insert sign bit
            MOV BYTE PTR [DI+6],AL     ; set B(6)

            MOV CX,5
            ADD DI,4
NEXT2:                                 ; loop over bytes, could be optimized using words
            MOV DX,CX                  ; save loop counter
            MOV AL,[DI+1]              ; take the lower 5 bits from B(5..1)
            MOV CL,3
            SHL AL,CL                  ; and left align them
                                       ;
            MOV AH,[DI]                ; take the upper 3 bits from B(4..0)
            INC CL
            INC CL
            SHR AH,CL                  ; and right align
            OR  AL,AH                  ; merge both parts
            MOV BYTE PTR [DI+1],AL     ; set B(5...1)
            DEC DI
            MOV CX,DX                  ; restore loop counter
            LOOP NEXT2

            ; 5 lower bits of B%(0) to upper 5 bits
            INC DI                     ; back to (0)
            MOV AL,[DI]                ; take the upper 5 bits
            SHL AL,1                   ; *2
            SHL AL,1                   ; *4
            SHL AL,1                   ; *8 ... left align them
            ;                          ; 3 zero bits will be shifted in
            MOV BYTE PTR [DI],AL       ; set B(0)

            RET
IEEE_TO_MBF ENDP

; ---------------------------------------------------------------------

; buffer for conversion
if DEBUG
             DB '<'                    ; marker for debugging
else
; buffer for conversion MBF <-> IEEE
DBLE_BUF     DQ ?                      ; X#(), Y#()
SI_SAVE      DW ?                      ; save SI address of Y#()
endif

if DEBUG
             DB '>'                    ; marker for debugging
endif

END_OF_CODE   LABEL   NEAR

; ---------------------------------------------------------------------
C_SEG  ENDS
; =====================================================================

      END ENTRY

