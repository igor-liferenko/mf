This is useful if we would want to do post-processing.

@x
@h
@y
#include <limits.h>
@h
@z

@x
b_close(&gf_file);
@y
if (getenv("tmpfile")) {
  char fname[PATH_MAX];
  sprintf(fname, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(strdup(fname), fname));
  FILE *tmpfile;
  assert(tmpfile = fopen(getenv("tmpfile"), "w"));
  fprintf(tmpfile, "%s", fname);
  fclose(tmpfile);
}
b_close(&gf_file);
@z
