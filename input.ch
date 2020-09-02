see interrupt.ch

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
