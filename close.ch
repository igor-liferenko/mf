Do not allow file descriptors be owned by another process (online display) unnecessarily.

@x
@h
@y
#include <fcntl.h>
@h
@z

a_open_in
@x
{@+reset(*f, name_of_file, "r"); return reset_OK(*f);
@y
{@+reset(*f, name_of_file, "r");
if (f->f != NULL) @<Set close-on-exec flag@>
return reset_OK(*f);
@z

a_open_out
@x
{@+rewrite(*f, name_of_file, "w"); return rewrite_OK(*f);
@y
{@+rewrite(*f, name_of_file, "w");
if (f->f != NULL) @<Set close-on-exec flag@>
return rewrite_OK(*f);
@z

b_open_out
@x
{@+rewrite(*f, name_of_file, "wb"); return rewrite_OK(*f);
@y
{@+rewrite(*f, name_of_file, "wb");
if (f->f != NULL) @<Set close-on-exec flag@>
return rewrite_OK(*f);
@z

w_open_in
@x
{@+reset(*f, name_of_file, "rb"); return reset_OK(*f);
@y
{@+reset(*f, name_of_file, "rb");
if (f->f != NULL) @<Set close-on-exec flag@>
return reset_OK(*f);
@z

w_open_out
@x
{@+rewrite(*f, name_of_file, "wb"); return rewrite_OK(*f);
@y
{@+rewrite(*f, name_of_file, "wb");
if (f->f != NULL) @<Set close-on-exec flag@>
return rewrite_OK(*f);
@z

@x
@ Appendix: Replacement of the string pool file.
@y
@ @<Set close-on-exec flag@>= {
  int fd, flags;
  assert((fd = fileno(f->f)) != -1);
  assert((flags = fcntl(fd, F_GETFD)) != -1);
  assert(fcntl(fd, F_SETFD, flags | FD_CLOEXEC) == 0);
}

@ Appendix: Replacement of the string pool file.
@z
