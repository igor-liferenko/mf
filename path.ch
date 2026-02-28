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
