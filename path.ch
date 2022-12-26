@x
enum {@+@!file_name_size=40@+}; /*file names shouldn't be longer than this*/
@y
enum {@+@!file_name_size=256@+}; /*file names shouldn't be longer than this*/
@z

@x
uint8_t @!name_length;@/ /*this many characters are actually
@y
uint16_t @!name_length;@/ /*this many characters are actually
@z

@x
else{@+if ((c=='>')||(c==':'))
@y
else{@+if (c=='/')
@z

@x
@d base_default_length	18 /*length of the |MF_base_default| string*/ 
@d base_area_length	8 /*length of its area part*/ 
@y
@d base_default_length 32 /*length of the |MF_base_default| string*/ 
@d base_area_length 22 /*length of its area part*/ 
@z

@x
strcpy(MF_base_default+1, "MFbases/plain.base");
@y
strcpy(MF_base_default+1, "/home/user/mf/MFbases/plain.base");
@z

@x
@d str_465 "MFinputs/"
@y
@d str_465 "/home/user/mf/MFinputs/"
@z
