Ensure that input consists only of ASCII characters.

@x
   /*open a text file for input*/
{@+reset(*f, name_of_file);return reset_OK(*f);
@y
   /*open a text file for input*/
{@+reset(*f, name_of_file);
  if (f->f && !eof(*f) && !ferror(f->f)) assert(f->d >= 0);
  return reset_OK(*f);
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof(*f))
  if (get(*f)) assert(f->d >= 0);
@z

@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[f->d];
    if (get(*f)) assert(f->d >= 0);
    incr(last);
@z
