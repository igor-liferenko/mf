# CWEB does not allow @<...@> to be used in replacement text of @d.
# This is the case for modules, into which web2w converts sttrings listed
# in this script. Therefore, we convert these modules into string numbers.
s#@d str_\(.*\) \("pool size"\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("! "\)#0,/..@<|\2|@>../s^^\1^#p
s#@d str_\(.*\) \("independent variables"\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("input stack size"\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("file name for output"\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("Too far to skip"\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("At most 127 lig/kern steps can separate skipto1 from 1::."\)#s^..@<|\2|@>..^\1^#p
s#@d str_\(.*\) \("I'm processing `extensible c: t,m,b,r'."\)#s^..@<|\2|@>..^\1^#p
# NOTE: use /*\2*/ after \1 if you want to keep the string
