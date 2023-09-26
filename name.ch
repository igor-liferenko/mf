Get GF file name.

@x
@h
@y
#include <limits.h>
@h
@z

@x
b_close(&gf_file);
@y
if (getenv("gf")) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("gf"), "w"));
  fprintf(f, "%s", s2);
  fclose(f);
}
b_close(&gf_file);
@z
