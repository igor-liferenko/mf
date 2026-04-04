@x
@<|"debug # (-1 to exit):"|@>=@+1081
@y
@<|"debug # (-1 to exit):"|@>=@+1081
@ @d str_1082 "MFinputs/"
@d MF_area_short 1082
@z

@x
str_1080 str_1081
@y
str_1080 str_1081 str_1082
@z

@x
str_start_1080, str_start_1081, str_start_1082
@y
str_start_1080, str_start_1081, str_start_1082, str_start_1083
@z

@x
str_start_1082=str_start_1081+sizeof(str_1081)-1,@/
@y
str_start_1082=str_start_1081+sizeof(str_1081)-1,@/
str_start_1083=str_start_1082+sizeof(str_1082)-1,
@z

@x
@ @<|pool_ptr| initialization@>= str_start_1082
@y
@ @<|pool_ptr| initialization@>= str_start_1083
@z

@x
@ @<|str_ptr| initialization@>= 1082
@y
@ @<|str_ptr| initialization@>= 1083
@z
