s/(preloaded base=trap .....[0-9]\+.[0-9]\+)  [0-9]\+ ... .... ..:..$/(preloaded base=trap 2014.1.7)  7 JAN 2014 18:11/
s/68 strings out of 1416/68 strings out of 883/
s/3752 string characters out of [0-9]\+/3752 string characters out of 11386/
s/Memory usage 1084&67 (749 still untouched)/Memory usage 1084\&202 (749 still untouched)/
s/Memory usage 1462&67 (104 still untouched)/Memory usage 1462\&588 (104 still untouched)/
s/String usage 24&92 (1391&28203 still untouched)/String usage 24\&92 (858\&11309 still untouched)/
s/String usage 41&161 (1348&24528 still untouched)/String usage 41\&161 (815\&7634 still untouched)/
s/xpart %CAPSULE1370=xx/xpart %CAPSULE1359=xx/
s/%CAPSULE1378=2yy-2/%CAPSULE1367=2yy-2/
s/%CAPSULE1386 = 3.3333xx+3.3333/%CAPSULE1375 = 3.3333xx+3.3333/
s/xpart %CAPSULE604 = 8000o2-4000o1+1000o3+9/xpart %CAPSULE1049 = 8000o2-4000o1+1000o3+9/
s/xpart %CAPSULE1394=xpart '/xpart %CAPSULE1383=xpart '/
s/ypart %CAPSULE1394=ypart '/ypart %CAPSULE1383=ypart '/
s/### 4000o1 = -xpart %CAPSULE604+8000o2+1000o3+9/### 4000o1 = -xpart %CAPSULE1049+8000o2+1000o3+9/
s/### -4.87383o2 = -oo-0.0004xpart %CAPSULE604+0.39673o3-17.99643/### -4.87383o2 = -oo-0.0004xpart %CAPSULE1049+0.39673o3-17.99643/
s/### -alfa=-xpart %CAPSULE368/### -alfa=-xpart %CAPSULE1494/
s/{xpart((xpart %CAPSULE368,0))}/{xpart((xpart %CAPSULE1494,0))}/
s/### -xpart %CAPSULE17=-%CAPSULE1376/### -xpart %CAPSULE17=-%CAPSULE1176/
s/{(%CAPSULE382)+(%CAPSULE1376)}/{(%CAPSULE382)+(%CAPSULE1176)}/
s/### -%CAPSULE382=-%CAPSULE1364+%CAPSULE1376/### -%CAPSULE382=-%CAPSULE1893+%CAPSULE1176/
s/### -%CAPSULE1364=-ypart %CAPSULE604/### -%CAPSULE1893=-ypart %CAPSULE1049/
s/### p$=-ypart %CAPSULE1360+1/### p$=-ypart %CAPSULE604+1/
s@{(2/3)\*((-ypart %CAPSULE1360+1,ypart %CAPSULE1360))}@{(2/3)*((-ypart %CAPSULE604+1,ypart %CAPSULE604))}@
s/### ypart %CAPSULE1360=-xpart %CAPSULE1360+1/### ypart %CAPSULE604=-xpart %CAPSULE604+1/
s/### -0.66667xpart %CAPSULE1360=-xpart %CAPSULE1744/### -0.66667xpart %CAPSULE604=-xpart %CAPSULE1889/
s/{-((xpart %CAPSULE1744,-xpart %CAPSULE1744+0.66667))}/{-((xpart %CAPSULE1889,-xpart %CAPSULE1889+0.66667))}/
s/### xpart %CAPSULE1744=-xpart %CAPSULE1675/### xpart %CAPSULE1889=-xpart %CAPSULE1172/
/{((xpart %CAPSULE604,ypart %CAPSULE604))=((xpart %CAPSULE1675,-xpart %CA/N
s/.*\nPSULE1675-0.66667))}/{((xpart %CAPSULE1049,ypart %CAPSULE1049))=((xpart %CAPSULE1172,-xpart %\nCAPSULE1172-0.66667))}/
s/## xpart %CAPSULE1675=-ypart %CAPSULE604-0.66667/## xpart %CAPSULE1172=-ypart %CAPSULE1049-0.66667/
s/## ypart %CAPSULE604=-xpart %CAPSULE604-0.66667/## ypart %CAPSULE1049=-xpart %CAPSULE1049-0.66667/
s/### -xpart %CAPSULE604=-xpart %CAPSULE1675/### -xpart %CAPSULE1049=-xpart %CAPSULE1172/
s/{((xpart ',ypart '))=((xpart %CAPSULE1675,-xpart %CAPSULE1675-0.66667))}/{((xpart ',ypart '))=((xpart %CAPSULE1172,-xpart %CAPSULE1172-0.66667))}/
s/## xpart %CAPSULE1675=-ypart '-0.66667/## xpart %CAPSULE1172=-ypart '-0.66667/
s/### -ooo=-%CAPSULE1051/### -ooo=-%CAPSULE1494/
s/{(%CAPSULE1051)+(1)}/{(%CAPSULE1494)+(1)}/
s/### -%CAPSULE1051=-%CAPSULE1378+1/### -%CAPSULE1494=-%CAPSULE1350+1/
s@{(1/2)\*(%CAPSULE1378)}@{(1/2)*(%CAPSULE1350)}@
s/### -0.5%CAPSULE1378=-%CAPSULE1370/### -0.5%CAPSULE1350=-%CAPSULE1367/
s/{-(%CAPSULE1370)}/{-(%CAPSULE1367)}/
s/### %CAPSULE1370=-%CAPSULE1362/### %CAPSULE1367=-%CAPSULE1893/
s/{(2)\*(%CAPSULE1362)}/{(2)*(%CAPSULE1893)}/
s/### -2%CAPSULE1362=-%CAPSULE1354/### -2%CAPSULE1893=-%CAPSULE1885/
s/{(-0.5%CAPSULE1354-0.5)=(%CAPSULE1354)}/{(-0.5%CAPSULE1885-0.5)=(%CAPSULE1885)}/
s/## %CAPSULE1354=-0.33333/## %CAPSULE1885=-0.33333/
