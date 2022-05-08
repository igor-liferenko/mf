Ensure that input consists only of ASCII characters.

@x
{ reset(*f, name_of_file, "r"); return reset_OK(*f);
@y
{ if ((f->f=fopen(name_of_file+1,"r"))!=NULL) {
    get(*f);
    if (!ferror(f->f) && !feof(f->f)) assert(f->d >= 0);
  }
  return reset_OK(*f);
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof(*f)) {
  get(*f);
  if (!feof(f->f)) assert(f->d >= 0);
}
@z

@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[f->d];
    get(*f);
    if (!feof(f->f)) assert(f->d >= 0);
    incr(last);
@z
