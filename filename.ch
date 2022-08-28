@x
@h
@y
#include <limits.h>
@h
@z

@x
b_close(&gf_file);
@y
if (getenv("mf_tmp")) {
  char fname[PATH_MAX];
  sprintf(fname, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(strdup(fname), fname));
  FILE *stream;
  assert(stream = fopen(getenv("mf_tmp"), "w"));
  fprintf(stream, "%s", fname);
  fclose(stream);
}
b_close(&gf_file);
@z
