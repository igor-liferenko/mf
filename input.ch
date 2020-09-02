see interrupt.ch

This change is not used in interrupt - it is just to use fgetc uniformly.
@x
   /*open a text file for input*/
{@+reset((*f), name_of_file,"r");return reset_OK((*f));
@y
{@+
if (((*f).f=fopen(name_of_file+1,"r"))!=NULL) (*f).d = fgetc((*f).f); return reset_OK((*f));
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof((*f))) {
  (*f).d = fgetc((*f).f);
  if (ferror((*f).f)) {
    clearerr((*f).f);
    return true;
  }
}
@z

@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[(*f).d];(*f).d = fgetc((*f).f);
    if (ferror((*f).f)) {clearerr((*f).f);return true;} incr(last);
@z
