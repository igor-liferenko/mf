s#@d str_\(.*\) \("pool size"\)#s/..@<|\2|@>../\1/#p
s#@d str_\(.*\) \("! "\)#0,/..@<|\2|@>../s//\1/#p
s#@d str_\(.*\) \("independent variables"\)#s/..@<|\2|@>../\1/#p
s#@d str_\(.*\) \("input stack size"\)#s/..@<|\2|@>../\1/#p
s#@d str_\(.*\) \("file name for output"\)#s/..@<|\2|@>../\1/#p
s#@d str_\(.*\) \("Too far to skip"\)#s/..@<|\2|@>../\1/#p
s#@d str_\(.*\) \("At most 127 lig/kern steps can separate skipto1 from 1::."\)#s%..@<|\2|@>..%\1%#p
s#@d str_\(.*\) \("I'm processing `extensible c: t,m,b,r'."\)#s/..@<|\2|@>../\1/#p
