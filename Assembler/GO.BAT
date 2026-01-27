@ECHO OFF
REM ----------------------------------------------------
REM Build an assembler code module for MBASIC or GWBASIC
REM Can be used with one argument, otherwise a hard 
REM wired name is used
REM Uses MASM, LINK, EXE2BIN, could be changed 
REM to use later versions of LINK /TINY or
REM TASM and TLINK /Tdc, both woithout EXE2BIN.
REM
REM Adapt the PATH in the script below to where you 
REM store these executables files.
REM SET PATH=\MASM;\MIXLANG;%PATH%
REM
REM Usage:
REM C:> GO
REM or
REM C:> GO SUM
REM
REM User configurable name of default assembler module
SET PROG=TOUPPER$
REM ----------------------------------------------------
REM Override module name by command line parameter
IF NOT %1_ == _  SET PROG=%1
REM Save
SET P=%PATH%
REM User configurable: provide access to the tools
REM MASM, LINK, EXE2BIN
SET PATH=\MASM;\MIXLANG;%PATH%
ECHO Assembling binary from %PROG%
REM Assemble source to object module
MASM %PROG%,%PROG%,%PROG%; | MORE
REM Pause to show assembler error messages
IF ERRORLEVEL 1 PAUSE
REM
REM Link object module to executable
LINK %PROG%;
REM Pause to show linker error messages
IF ERRORLEVEL 1 PAUSE
REM
REM Convert executable to binary
EXE2BIN %PROG%.EXE %PROG%.BIN
REM Show file size for calculating required code array DIM
ECHO.
DIR %PROG%.BIN | FIND /I %PROG%
REM Restore
SET PATH=%P%
SET P=
SET PROG=
