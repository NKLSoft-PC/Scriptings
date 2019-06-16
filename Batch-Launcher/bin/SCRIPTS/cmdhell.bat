@Echo Off
:: Варианит 1
Set xOS=x64
If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86
Echo %xOS%
Pause

:: ===================================================================================
:: Варианит 2
Set xOS=x86
If Defined PROCESSOR_ARCHITEW6432 (Set xOS=x64) Else If "%PROCESSOR_ARCHITECTURE%"=="AMD64" Set xOS=x64
Echo %xOS%
Pause

:: ===================================================================================
:: Запуск приложений в зависимости от разрядности из разных папок с именами x64 и x86
Set xOS=x64
If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86
"c:\My Test\%xOS%\install.exe" /S

:: ===================================================================================
:: Запуск приложений в зависимости от разрядности из одной папки с именами сожержащими суффикс x64 и x86 (install_x64.exe и install_x86.exe)
Set xOS=x64
If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86
"c:\My Test\install_%xOS%.exe" /S

:: ===================================================================================
:: Запуск приложений в зависимости от разрядности из разных папок, с разными именами и/или ключами
Set xOS=x64
If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 Set xOS=x86
If %xOS%==x86 ("c:\My Test\i86\install.exe" /S) Else ("c:\My Test\AMD64\setup.msi" /qn)