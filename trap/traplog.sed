s/(preloaded base=trap .....[0-9]\+.[0-9]\+)  [0-9]\+ ... .... ..:..$/(preloaded base=trap 2014.1.7)  7 JAN 2014 18:11/
s/68 strings out of 1416/68 strings out of 883/
s/3752 string characters out of [0-9]\+/3752 string characters out of 11386/
s/Memory usage 1084&67 (749 still untouched)/Memory usage 1084\&202 (749 still untouched)/
s/Memory usage 1462&67 (104 still untouched)/Memory usage 1462\&588 (104 still untouched)/
s/String usage 24&92 (1391&28203 still untouched)/String usage 24\&92 (858\&11309 still untouched)/
s/String usage 41&161 (1348&24528 still untouched)/String usage 41\&161 (815\&7634 still untouched)/
s/CAPSULE17x/CAPSULE17/g
s/CAPSULE382x/CAPSULE382/g
s/CAPSULE604x/CAPSULE1049/g
s/CAPSULE1354x/CAPSULE1885/g
s/CAPSULE1360x/CAPSULE604/g
s/CAPSULE1376x/CAPSULE1176/g
s/CAPSULE1386x/CAPSULE1375/g
s/CAPSULE1615x/CAPSULE1615/g
s/CAPSULE1675x/CAPSULE1172/g
s/CAPSULE1744x/CAPSULE1889/g

# these must translate to 1367
s/CAUPSULE1370x/&/g
s/CAPSULE1378x/&/g # this must also translate to 1350

# these must translate to 1494
s/CAPSULE368x/&/g
s/CAPSULE1051x/&/g

# these must translate to 1893
s/CAPSULE1362x/&/g
s/CAPSULE1364x/&/g
