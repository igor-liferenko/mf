@x
uint8_t @!name_length;@/ /*this many characters are actually
@y
int       name_length;@/ /*this many characters are actually
@z

@x
else{@+if ((c=='>')||(c==':'))
@y
else{  if (c=='/')
@z

@x
strcpy(MF_base_default+1, "MFbases:plain.base");
@y
strcpy(MF_base_default+1, "MFbases/plain.base");
@z

@x
eight_bits @!k; /*runs through character codes*/
@y
uint16_t     k; /*runs through character codes*/
@z

@x
@d str_741 "MFinputs:"
@y
@d str_741 "MFinputs/"
@z
