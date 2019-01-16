#!/usr/bin/ruby

#fromsulley-cmdinjectionandsqlinjection
#https://github.com/OpenRCE/sulley/blob/master/sulley/primitives.py

FUZZSTR = [
"",
#stringsrippedfromspike(andsomeothersIadded)
"/.:/"+"A"*5000+"\x00\x00",
"/.../"+"A"*5000+"\x00\x00",
"/.../.../.../.../.../.../.../.../.../.../",
"/../../../../../../../../../../../../etc/passwd",
"/../../../../../../../../../../../../boot.ini",
"..:..:..:..:..:..:..:..:..:..:..:..:..:",
"\\\\*",
"\\\\?\\",
"/\\"*5000,
"/."*5000,
"!@#$%%^#$%#$@#$%$$@#$%^^**(()",
"%01%02%03%04%0a%0d%0aADSF",
"%01%02%03@%04%0a%0d%0aADSF",
"/%00/",
"%00/",
"%00",
"%u0000",
"%\xfe\xf0%\x00\xff",
"%\xfe\xf0%\x01\xff"*20,

#formatstrings.
"%n"*100,
"%n"*500,
"\"%n\""*500,
"%s"*100,
"%s"*500,
"\"%s\""*500,

#somebinarystrings.
"\xde\xad\xbe\xef",
"\xde\xad\xbe\xef"*10,
"\xde\xad\xbe\xef"*100,
"\xde\xad\xbe\xef"*1000,
"\xde\xad\xbe\xef"*10000,
"\x00"*1000,

#miscellaneous.
"\r\n"*100,
"<>"*500 #sendmailcrackaddr(http://lsd-pl.net/other/sendmail.txt)
]

