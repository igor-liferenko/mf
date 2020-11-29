Ensure that input consists only of BMP characters and is valid UTF-8.

@x
@h
@y
#include <errno.h>
@h
@z

@x
{@+if(((*f).f=fopen(name_of_file+1,"r"))!=NULL)get((*f));return reset_OK((*f));
@y
{@+if(((*f).f=fopen(name_of_file+1,"r"))!=NULL)
  if (get((*f))) assert((*f).d > 0);
  return reset_OK((*f));
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof((*f)))
  if (get((*f))) assert((*f).d > 0);
@z

@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[(*f).d];
    if (get((*f))) assert((*f).d > 0);
    incr(last);
@z
