# CWEB does not allow @<...@> to be used in replacement text of @d.
# This is the case for modules, into which web2w converts strings listed
# in this script. Therefore, we convert these modules into string numbers.
s#@d str_\(.*\) \("pool size"\)#/@d str_room/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("! "\)#/@d print_err/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("independent variables"\)#/@d new_indep/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("input stack size"\)#/@d push_input/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("file name for output"\)#/@d set_output_file_name/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("Too far to skip"\)#/@d skip_error/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("At most 127 lig/kern steps can separate skipto1 from 1::."\)#/@d skip_error/,/^$/s^@<|\2|@>^\1/*\2*/^#p
s#@d str_\(.*\) \("I'm processing `extensible c: t,m,b,r'."\)#/@d missing_extensible_punctuation/,/^$/s^@<|\2|@>^\1/*\2*/^#p
