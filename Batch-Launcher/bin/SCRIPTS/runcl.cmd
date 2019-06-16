@echo off
goto end_comments
rem --------------------------------------------------------

    Find the most recent version of this: https://gist.github.com/mburr/3308168
    
    This script helps integrate compilers into UltraEdit or other editors

    The first parameter is an ID for the compiler to use (vc60, vc71, vc80, etc.)

    The second parameter is the file to compile.

    Some notes:

    1) An example command line (for VC 2005)that would go into UltraEdit is:

            c:\util\runcl.cmd vc80 "%f"

    1) the .pdb file is deleted if it exists.  VC complains when there's a .pdb file
        already there but from a different compiler. I don't know why it doesn't just go ahead and
        overwrite it, but it doesn't.

rem --------------------------------------------------------
:end_comments

setlocal
if /i {%1}=={vc} goto set_params
if /i {%1}=={msvc}  goto set_params
if /i {%1}=={cl} goto set_params

if /i {%1}=={vc60} goto set_params
if /i {%1}=={vc6}  goto set_params
if /i {%1}=={vs98} goto set_params
if /i {%1}=={vc98} goto set_params

if /i {%1}=={vc71} goto set_params
if /i {%1}=={vs2003} goto set_params
if /i {%1}=={vc2003} goto set_params

if /i {%1}=={vc80} goto set_params
if /i {%1}=={vc8}  goto set_params
if /i {%1}=={vs2005} goto set_params
if /i {%1}=={vc2005} goto set_params

if /i {%1}=={vc90} goto set_params
if /i {%1}=={vc9}  goto set_params
if /i {%1}=={vs2008} goto set_params
if /i {%1}=={vc2008} goto set_params

if /i {%1}=={vc10} goto set_params
if /i {%1}=={vs2010} goto set_params
if /i {%1}=={vc2010} goto set_params

if /i {%1}=={vc11} goto set_params
if /i {%1}=={vs2012} goto set_params
if /i {%1}=={vc2012} goto set_params

if /i {%1}=={vc12} goto set_params
if /i {%1}=={vs2013} goto set_params
if /i {%1}=={vc2013} goto set_params

if /i {%1}=={vc14} goto set_params
if /i {%1}=={vs2015} goto set_params
if /i {%1}=={vc2015} goto set_params

if /i {%1}=={gcc}  goto set_params
if /i {%1}=={gcc32}  goto set_params
if /i {%1}=={gcc64}  goto set_params
if /i {%1}=={mingw}  goto set_params
if /i {%1}=={mingw32}  goto set_params
if /i {%1}=={mingw64}  goto set_params

if /i {%1}=={como} goto set_params
if /i {%1}=={dm}   goto set_params
if /i {%1}=={test} goto set_params


echo Unsupported Compiler: %1
echo Usage:
echo %0 ^<vc ^| vc60 ^| vc71 ^| vc80 ^| vc90 ^| vc10 ^| vc11 ^| vc12 ^| vc14 ^| como ^| dm ^| gcc ^| test^> ^<filename^>
goto :eof

:set_params
(set ECHO_COMMANDLINE=1)
if {%CC_OPT%} == {} (set CC_OPT=/Wall)
if {%CC_OPT_VC6%} == {} (set CC_OPT_VC6=) & rem VC6 doesn't support "/Wall"
if {%WARNING_LEVEL%} == {} (set WARNING_LEVEL=3)
rem if {%INTERSLICE_INCLUDE%} == {} (set INTERSLICE_INCLUDE=C:\DevTrees\includes;C:\DevTrees\Boost\boost_1_34_1)
if {%INTERSLICE_INCLUDE%} == {} (set INTERSLICE_INCLUDE=C:\DevTrees\includes;C:\boost\boost_1_49_0)
if {%WIN32_WINNT%} == {} (set WIN32_WINNT=0x0500)
(set SOURCE_BASE_FILENAME=%~n2) & rem - base filename (without extension)
(set SOURCE_FILE=%~f2) & rem - full path and filename
(set SOURCE_FILEEXT=%~x2) & rem - just the extension
(set PDB_FILE=%~dpn2.pdb) & rem - drive+path+basename followed by .pdb
(set LIBRARIES=kernel32.lib user32.lib gdi32.lib advapi32.lib shlwapi.lib oleaut32.lib ws2_32.lib)
(set x64=0)
(set PROG_FILES=c:\Program Files)

rem - The ProgramFiles(x86) environment variable usually contains parens
rem -    when the variable is expanded, the ')' paren gets parsed as the
rem -    paren that ends a cmd.exe 'nesting' set of parens.
rem -
rem -    This means YOU CANNOT USE the "ProgramFiles(x86)" environment
rem -    variable inside a block of cmd.exe command's enclosed in parens.
rem -
rem -    Jeez - another straw in the pile of cmd scripting goofs...
rem
rem **NOTE**  Johannes Roessel describes another way to use
rem         environment variables that contain parens in `set`
rem         statements: http://stackoverflow.com/questions/2771285/2771431#2771431
rem
rem     essentially, put the stuff **after** the `set` command in quotes:
rem
rem         set "PROG_FILES=%ProgramFilesx86%"
rem
rem     Note, my workaround of not using those env vars inside a paren-
rem     delimted block was also described by him.

set ProgramFilesx86=%ProgramFiles(x86)%
if not {"%ProgramFiles%"} == {""} set PROG_FILES=%ProgramFiles%
if not {"%ProgramFilesx86%"} == {""} set PROG_FILES=%ProgramFilesx86%
if not {"%ProgramFilesx86%"} == {""} (
    (set x64=1)
)
@rem echo PROG_FILES: "%PROG_FILES%"
rem @echo off

goto %1



:delpdb
rem subroutine to delete the PDB file
if exist %PDB_FILE% del %PDB_FILE%
goto :eof

:get_filetype
rem subroutine to set the type of file on the commandline
(set FILETYPE="")
if /i "%SOURCE_FILEEXT%" == ".c"   (set FILETYPE="C")
if /i "%SOURCE_FILEEXT%" == ".cpp" (set FILETYPE="CPP")
if /i "%SOURCE_FILEEXT%" == ".cxx" (set FILETYPE="CPP")
if /i "%SOURCE_FILEEXT%" == ".cc"  (set FILETYPE="CPP")
goto :eof


:msvc
:vc
:cl
rem - a generic VC target - this will try to figure out the most recent version of
rem     visual studio on the machine and use that...
rem

rem - I think that the vs2107 installer put this here becuase I selected some 
rem - installation option for it to install a vc 2015 toolchain
if exist "%PROG_FILES%\Microsoft Visual Studio\Shared\14.0\VC\vcvarsall.bat"         goto vs2015
rem - if exist "%PROG_FILES%\Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat"      goto vs2015
if exist "%PROG_FILES%\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"      goto vs2013
if exist "%PROG_FILES%\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"      goto vs2012
if exist "%PROG_FILES%\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat"      goto vs2010
if exist "%PROG_FILES%\Microsoft Visual Studio 9.0\Common7\Tools\vsvars32.bat"       goto vs2008
if exist "%PROG_FILES%\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"         goto vs2005
if exist "%PROG_FILES%\Microsoft Visual Studio .NET 2003\Common7\Tools\vsvars32.bat" goto vs2003
if exist "%PROG_FILES%\Microsoft Visual Studio\VC98\Bin\vcvars32.bat"                goto vc6

echo. Error: Could not find an appropriate MSVC compiler...
goto :eof




:vs98
:vc98
:vc60
:vc6
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio\VC98\Bin\vcvars32.bat"
echo Visual C/C++ 6 (VC98) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT_VC6% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio\VC98\Bin\cl" %CC_OPT% /GX /Zi -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /INCREMENTAL:NO %LIBRARIES%)
call :exec %CC%
goto :eof


:vs2003
:vc2003
:vc71
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio .NET 2003\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2003 (VC 7.1) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%

rem
rem /Wall generates too many warnings from system includes, that I've decided
rem		just to not bother with it for VS2003 (so I use the VC6 options)
rem
set CC_OPT=%CC_OPT_VC6% -W%WARNING_LEVEL%

(set CC="%PROG_FILES%\Microsoft Visual Studio .NET 2003\Vc7\bin\cl" %CC_OPT% /Gi- /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof

:vs2005
:vc2005
:vc80
:vc8
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2005 (VC 8.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 8\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof

:vs2008
:vc2008
:vc90
:vc9
call :delpdb
call :get_filetype

if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)

call "%PROG_FILES%\Microsoft Visual Studio 9.0\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2008 (VC 9.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 9.0\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof


:vs2010
:vc2010
:vc10
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2010 (VC 10.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 10.0\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof

:vs2012
:vc2012
:vc11
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2012 (VC 11.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 11.0\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof


:vs2013
:vc2013
:vc12
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2013 (VC 12.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 12.0\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof


:vs2015
:vc2015
:vc14
call :delpdb
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
call "%PROG_FILES%\Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat"
echo Visual C/C++ 2015 (VC 14.0) Compile...
set INCLUDE=%INCLUDE%;%INTERSLICE_INCLUDE%
set CC_OPT=%CC_OPT% -W%WARNING_LEVEL%
(set CC="%PROG_FILES%\Microsoft Visual Studio 14.0\VC\bin\cl.exe" %CC_OPT% /Zi /EHsc -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" /link /incremental:no %LIBRARIES%)
call :exec %CC%
goto :eof

:como
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
rem - set up environment for Comeau C/C++ compiler

call "%PROG_FILES%\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat"
set path=c:\como\xp4310beta2\bin;%path%

rem - COMO_MS_INCLUDE is a special environemnt variable that como uses internally to
rem     find headers for MSVC.  It's not passed on the command line.
set COMO_MS_INCLUDE=%PROG_FILES%\Microsoft Visual Studio 9.0\VC\include

rem - VS2008 installs the Platform SDK in the following directory instead of in the VS directory
rem
rem - Note that VS 2008 puts the SDK libraries in "C:\Program Files" even if the machine has a 64-bit OS.

rem - COMO_PLATFORM_SDK is a special env var that como uses internally (so it's not passed on
rem     any command line)
set COMO_PLATFORM_SDK=c:\Program Files\Microsoft SDKs\Windows\v6.0A

rem - Comeau does not use the file extension to figure out whether to
rem   compile as C++ or straight C, so we need to do it
rem
rem - Also, there's some weirdness with the inline keyword and the
rem     Windows SDK (at least v6.0a, which comes with VC9)
rem     for C compiles, define "inline" to "__inline"
rem
rem     That seems to help, but I'm not sure exactly what's going on...
rem
rem     Oh, and use the "-D" option, not the "--define_macro" option -
rem     "--define_macro" causes a weird error about the "--c"
rem     command line option...
rem
set COMPILE_TYPE_OPT=--c++
set COMO_INLINE=
if %FILETYPE% == "C" (
    set COMPILE_TYPE_OPT=--c
    set COMO_INLINE=-D inline=__inline
)


set SOURCE_BASE_FILENAME=%SOURCE_BASE_FILENAME:"=%

rem - set up a compiler switch for INTERSLICE_INCLUDE if there's something there
(set COMO_INCLUDE=)
if NOT "%INTERSLICE_INCLUDE%" == "" (set COMO_INCLUDE=-I%INTERSLICE_INCLUDE:;= -I%)


rem (set CC=como  --plv %COMO_INLINE% -o "%SOURCE_BASE_FILENAME%.exe" %COMPILE_TYPE_OPT% "%SOURCE_FILE%")
(set CC=como  %COMO_INLINE% -c %COMPILE_TYPE_OPT% %COMO_INCLUDE% "%SOURCE_FILE%")

rem
rem como needs to have the libraries it links to specified without spaces (even if the path is quoted)
rem the following `for` command converts the long-filename-path for advapi32.lib to a path that
rem only has short, 8.3 path components (no spaces). This uses the 'percent' ~s modifier available
rem to the `for` command. (note that I couldn't use the actual percent sign in the comment, because the
rem stinkin' cmd.exe parser actually throws some sort of syntax error even though it's in a comment -
rem jeez, batch files really, really drive me crazy).
rem
for %%a in ("%COMO_PLATFORM_SDK%\Lib\AdvAPI32.Lib") do set advapi32lib=%%~sa
(set LINK=como  -o "%SOURCE_BASE_FILENAME%.exe" "%SOURCE_BASE_FILENAME%.obj" "%advapi32lib%")

@echo.
@echo compile...
call :exec %CC%
@echo link...
call :exec %LINK%

goto :eof

:dm
call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)
echo Digital Mars C/C++ Compile...
rem - the following dumps Digital Mars compiler version info (I think scppn.exe is the actual compiler)
for /F "usebackq tokens=1*" %%i in (`c:\dm\bin\scppn.exe`) do (
    if /i "%%i" == "Digital" echo %%i %%j
)
echo.

rem - do not let any residual VC include path from the system environment get to DMC
rem - the default DMC include path is set in the c:\dm\bin\sc.ini file
(set INCLUDE=)
rem - set up a compiler switch for INTERSLICE_INCLUDE if there's something there
(set DMC_INCLUDE=)
if NOT "%INTERSLICE_INCLUDE%" == "" (set DMC_INCLUDE=-I%INTERSLICE_INCLUDE%)
rem - C++ compiles get an additional include directory that's set in the DMC_CPP_INCLUDE var
(set DMC_CPP_INCLUDE=)
if {%FILETYPE%} == {"CPP"} (set DMC_CPP_INCLUDE=-Ic:\dm\stlport\stlport)
rem "C:\dm\bin\dmc" -Ae -v1 -r -g -mn %DMC_INCLUDE% %DMC_CPP_INCLUDE% -IC:/DevTrees/Boost/boost_1_34_1 -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%"  %LIBRARIES%
(set CC="C:\dm\bin\dmc" -Ae -v1 -r -g -mn %DMC_INCLUDE% %DMC_CPP_INCLUDE% -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" %LIBRARIES%)
call :exec %CC%
goto :eof


:mingw64
:gcc64
set GCC_TARGET=-m64

:mingw
:mingw32
:gcc
:gcc32
if "%GCC_TARGET%" == "" (set GCC_TARGET=-m32)

call :get_filetype
if NOT %FILETYPE% == "C" (
    if NOT %FILETYPE% == "CPP" goto :not_compilable
)


rem some GCC options:
rem
rem     -g  compile in debugging information
rem     -Werror treat warnings as errors
rem     -Wextra  enable extra warnings (unsigned compare with 0, comma expression with no side effects, etc)
rem
rem     -E  preprocess only (no compile/assembly/link)
rem     -E -dM  causes GCC to dump pre-defined macros
rem
rem     -H gcc's /showIncludes
rem 
rem     -M will cause included files to be listed (similar to /showIncludes)
rem        (note: use the -H option instead)
rem
rem     -MM  like -M except done't output headers that are in system include dirs
rem          or that are included by (even indirectly) by system headers
rem
rem     -S  produce assembly output file filename.s (but won't link)
rem     -masm=intel     use Intel syntax for assembly language
rem
rem     --verbose-asm    add some information to assembly output
rem     -instrument-functions   add calls to user-supplied profiling functions
rem
rem     -Wshadow    warn if a variable for built-in function is hidden
rem     -Wcast-align    warn if a pointer is cast to something with a stricter alignment
rem
rem     -fmudflap   add runtime buffer boundary checks
rem
rem     -save-temps retain preprocessor and/or assembly outputs
rem
rem     -v              dump information about default options, and search paths
rem		-Wl,--verbose	tell linker to dump info about libraries being searched
rem
rem     -std=c89
rem     -std=c90
rem     -std=c99
rem     -std=c11        4.7+
rem
rem     -std=gnu90      (default for C compiles)
rem     -std=gnu99
rem     -std=gnu11      4.7+
rem
rem     -std=c++98
rem     -std=c++03      4.8+ (same function as c++98)
rem     -std=c++0x      4.3+ (deprecated 4.7)
rem		-std=c++11      4.7+
rem     -std=c++14      5.0+(?)
rem
rem     -std=gnu++98    (default for C++ compiles)
rem     -std=gnu++03    4.8+ (same function as gnu++98)
rem     -std=gnu++0x    4.3+ (deprecated 4.7)
rem		-std=gnu++11    4.7+
rem     -std=gnu++14    5.0+(?)
rem
rem     -O0     disable optimizations (default)
rem     -O or -O1
rem     -O2
rem     -O3
rem
rem     -x c        compile files as C
rem     -x c++      compile files as C++
rem     -x none     compile files according to extension
rem
rem                 other options for `-x` include c-header, cpp-output, c++-header,
rem                      c++-cpp-output, java, objective-c, and many more.
rem
rem		-mwindows	compile/link as Win32 GUI program
rem		-mconsole 	compile/link as Win32 console program
rem		-mdll		generate a DLL, enabling the selection of the required runtime 
rem						startup object and entry point. 
rem		-mthread	MinGW-specific thread support is to be used. I'm not sure how This
rem						relates to pthreads (if at all)
rem
rem     --help=class[,qualifier]
rem             Print on the standard output a description of the command line options 
rem             understood by the compiler that fit into a specific class. The class can be 
rem             one of `optimizers', `warnings', `target', `params', or language:
rem         
rem             `optimizers'
rem                 This will display all of the optimization options supported by the compiler.
rem             `warnings'
rem                 This will display all of the options controlling warning messages produced by the compiler.
rem             `target'
rem                 This will display target-specific options. Unlike the --target-help option however, 
rem                 target-specific options of the linker and assembler will not be displayed. 
rem                 This is because those tools do not currently support the extended --help= syntax.
rem             `params'
rem                 This will display the values recognized by the --param option.
rem             language
rem                 This will display the options supported for language, where language is the 
rem                 name of one of the languages supported in this version of GCC.
rem             `common'
rem                 This will display the options that are common to all languages. 
rem         
rem             It is possible to further refine the output of the --help= option by adding a comma 
rem             separated list of qualifiers after the class. These can be any from the following list:
rem         
rem             `undocumented'
rem                 Display only those options which are undocumented.
rem             `joined'
rem                 Display options which take an argument that appears after an equal sign in 
rem                 the same continuous piece of text, such as: `--help=target'.
rem             `separate'
rem                 Display options which take an argument that appears as a separate 
rem                 word following the original option, such as: `-o output-file'. 
rem 
rem    use -Q with the above to display the actual setting instead of help for options:
rem 
rem     -Q --help=target    # display options affected by target architecture setting
rem     -Q --help=warning   # display warnings enabled/disbled
rem
rem  These warning options are turned on by `-Wall` and/or `-Wextra`.
rem  
rem  They create too much noise for little test runs, and seem to provide little benefit, 
rem  so I turn them off explicitly:
rem  
rem      -Wunused-parameter
rem      -Wunused-variable
rem      -Wunused-function
rem  
rem  These warnings cause common structure initializations (such as `= {0}` or not using full bracing) 
rem  to cause warnings.  So I turn them off explicitly as well:
rem  
rem      -Wmissing-field-initializers
rem      -Wmissing-braces
rem      
rem set GCC_OPTS=-Wall 

rem if MINGW_PATH isn't explicitly set, use the first of:
rem     x:\MinGW64\bin, x:\MinGW32\bin,    x:\MinGW\bin that we find
rem where x: is c: or d:
if {%MINGW_PATH%} == {} if exist c:\MinGW-4.8.1-tdm64\bin\gcc.exe (set MINGW_PATH=c:\MinGW-4.8.1-tdm64\bin)
if {%MINGW_PATH%} == {} if exist d:\MinGW-4.8.1-tdm64\bin\gcc.exe (set MINGW_PATH=d:\MinGW-4.8.1-tdm64\bin)
if {%MINGW_PATH%} == {} if exist c:\MinGW64\bin\gcc.exe (set MINGW_PATH=c:\MinGW64\bin)
if {%MINGW_PATH%} == {} if exist d:\MinGW64\bin\gcc.exe (set MINGW_PATH=d:\MinGW64\bin)
if {%MINGW_PATH%} == {} if exist c:\MinGW32\bin\gcc.exe (set MINGW_PATH=c:\MinGW32\bin)
if {%MINGW_PATH%} == {} if exist d:\MinGW32\bin\gcc.exe (set MINGW_PATH=d:\MinGW32\bin)
if {%MINGW_PATH%} == {} if exist c:\MinGW\bin\gcc.exe   (set MINGW_PATH=c:\MinGW\bin)
if {%MINGW_PATH%} == {} if exist d:\MinGW\bin\gcc.exe   (set MINGW_PATH=d:\MinGW\bin)

if {%MINGW_PATH%} == {} (
    echo "MinGW toolchain could not be found"
    goto :eof
)


if "%GCC_WARNING_CONFIG%" == "" (
    (set GCC_WARNING_CONFIG=-Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-missing-field-initializers -Wno-missing-braces)
)

if "%GCC_OPTS%" == "" (
    (set GCC_OPTS=-g -Wall -Wextra %GCC_WARNING_CONFIG%)
)

if "%GCC_OPTS_C%" == "" (
    rem - default options that apply only to C builds
    (set GCC_OPTS_C=-Wstrict-prototypes)
)

if "%GCC_OPTS_CPP%" == "" (
    rem - no default C++ only options yet
    (set GCC_OPTS_CPP=)
)

echo GCC/MinGW C/C++ Compile...
rem - collect the GCC version
for /f %%a in ('%MINGW_PATH%\gcc -dumpversion') do (set GCC_VERSION=%%a)
@echo GCC Version %GCC_VERSION%

rem sets the "-std=" option appropriately (GCC_STD_C and GCC_STD_CPP variables)
call :gcc_set_std %GCC_VERSION%
rem - do not let any residual VC include path from the system environement get to MinGW
(set INCLUDE=%MINGW_PATH%\..\include)
rem - set up a compiler switch for INTERSLICE_INCLUDE if there's something there
(set GCC_INCLUDE=-I%INCLUDE%)
if NOT "%INTERSLICE_INCLUDE%" == "" (set GCC_INCLUDE=%GCC_INCLUDE% -I%INTERSLICE_INCLUDE:;= -I%)
rem - C++ compiles get an additional include directory that's set in the GCC_CPP_INCLUDE var
(set GCC_CPP_INCLUDE=)


rem C++ specific items
if {%FILETYPE%} == {"CPP"} (
    (set GCC_OPTS=%GCC_STD_CPP% %GCC_OPTS% %GCC_OPTS_CPP%)
    (set GCC_CPP_INCLUDE=-I%INCLUDE%\c++\%GCC_VERSION%)

    (set GCC_COMPILER="%MINGW_PATH%\g++")
)

rem C specific items
if {%FILETYPE%} == {"C"} (
    (set GCC_OPTS=%GCC_STD_C% %GCC_OPTS% %GCC_OPTS_C%)

    (set GCC_COMPILER="%MINGW_PATH%\gcc")
)


rem set up the libraries for the gcc command line
(set GCC_LIBRARIES=)
for %%a in (%LIBRARIES%) do call :gcc_appendlib %%a

rem NOTE
rem MinGW versions before 4.2.2 need to be in the path on Vista or later because
rem     of the _access() bug (worked around in later GCC builds with the
rem     -D__USE_MINGW_ACCESS hack).  One of these days, I'll make the script
rem     smart enoough to detect this situation, but for now I'll just add the
rem     configured MinGW to the path (which I'd rather not do)...
rem
rem Versions 4.2.2 or later of MinGW (or earler versions running on XP) will find
rem subprocesses just fine without being on the path because of the -B option.
rem (-B is supported on GCC 2.96 or later - I've never used anything prior to 3.4.5)
rem
set PATH=%MINGW_PATH%;%PATH%

(set CC=%GCC_COMPILER% -B%MINGW_PATH% %GCC_TARGET% %GCC_OPTS%  %GCC_CPP_INCLUDE% %GCC_INCLUDE% -D__USE_MINGW_ACCESS -D_WIN32_WINNT=%WIN32_WINNT% "%SOURCE_FILE%" %GCC_LIBRARIES% -o "%SOURCE_BASE_FILENAME%.exe")
call :exec %CC%
goto :eof

:gcc_appendlib
(set GCC_LIBRARIES=%GCC_LIBRARIES% -l%~n1)
goto :eof


rem Function: parse_gcc_ver
goto :end_parse_gcc_ver
:parse_gcc_ver

rem @echo off
setlocal
goto :start_parse_gcc_ver
rem
rem Parse a GCC version number in the form 4.5.6 into a single number
rem (allowing two digits for each part, just in case) such as 40506.
rem 
rem This function expects a single argument in the form os the 
rem version triplet produced by "gcc -dumpversion" - for example: 4.5.6
rem 
rem The return value of the function is provided in an environment
rem variable named RET, as per convention.
rem
rem This will allow us to easily compare the GCC version in the script
rem so that we can set sensible language defaults. For example, if
rem GCC 4.7 (40700) or later is used we can default to "-std=gnu++11" 
rem
rem As a note, the GCC docs claim that C99 isn't fully supported until
rem version 4.9!  I think it's probably mostly usable far earlier than
rem that - in fact, I think the the default of "-std=gnu90" probably
rem supports most the the useful C99 features as extensions.
rem

:start_parse_gcc_ver

set RAWVER=%1

for /f "tokens=1-3 delims=." %%i in ("%RAWVER%") do (
        set /a MAJ=%%i + 0
        set /a MIN=%%j + 0
        set /a PAT=%%k + 0
)

set /a VERNUM= MAJ * 10000
set /a VERNUM+=MIN * 100
set /a VERNUM+=PAT

endlocal && set "RET=%VERNUM%"
goto :eof

:end_parse_gcc_ver


rem Function to set the proper support "-std=" option
rem 
rem   expects the gcc version in the form 4.5.6
rem
:gcc_set_std

setlocal
call :parse_gcc_ver %1
set /a VERNUM=RET + 0

rem set basic defaults
set GCC_STD_C=-std=gnu90
set GCC_STD_CPP=-std=gnu++98

rem 4.7.0 and later support C++11
if %VERNUM% GEQ 40700 (
    set GCC_STD_CPP=-std=gnu++11
)

rem 4.9.0 and later support C99
if %VERNUM% GEQ 40900 (
    set GCC_STD_C=-std=gnu99
)

rem return the correct settings in variables GCC_STD_C and GCC_STD_CPP
endlocal && (set GCC_STD_C=%GCC_STD_C%) && (set GCC_STD_CPP=%GCC_STD_CPP%)
goto :eof




:exec
if {%ECHO_ENVIRONMENT%} == {1} (
set
)
if {%ECHO_COMMANDLINE%} == {1} (
echo %*
)
%*
goto :eof

:not_compilable
echo Cannot compile a "%SOURCE_FILEEXT%" type of file
goto :eof

:test
echo current dir is:
cd
echo %%1: %1
echo %%2: %2
echo %%SOURCE_FILE%%: %SOURCE_FILE%
echo %%SOURCE_FILEEXT%%: %SOURCE_FILEEXT%
echo %%SOURCE_BASE_FILENAME%%: %SOURCE_BASE_FILENAME%
echo %%PDB_FILE%%: %PDB_FILE%
echo %%~d2: %~d2
echo %%~p2: %~p2
echo %%~n2: %~n2
echo %%~x2: %~x2
echo %%~dpn2: %~dpn2
echo %%3: %3
goto :eof


