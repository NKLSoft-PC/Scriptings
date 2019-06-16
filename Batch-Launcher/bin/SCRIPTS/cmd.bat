@ECHO OFF
TITLE NKLSoft-PC WMIC AUTOCONFIG	
COLOR 0C
PROMPT $
SET REDWMIC="ECHO\ WMIC is deprecated."

COLOR 0F
PROMPT $
ECHO\ "[global switches] <command>"
ECHO\ " following global switches are available:"
ECHO\ "/NAMESPACE           Path for the namespace the alias operate against."
ECHO\ "/ROLE                Path for the role containing the alias definitions."
ECHO\ "/NODE                Servers the alias will operate against."
ECHO\ "/IMPLEVEL            Client impersonation level."
ECHO\ "/AUTHLEVEL           Client authentication level."
ECHO\ "/LOCALE              Language id the client should use."
PAUSE


