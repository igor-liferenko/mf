Get GF and TFM file names.

@x
@h
@y
#include <limits.h>
@h
@z

@x
b_close(&tfm_file)
@y
if (getenv("name")) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(tfm_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("name"), "a"));
  fprintf(f, "%s\n", s2);
  fclose(f);
}
b_close(&tfm_file)
@z

@x
b_close(&gf_file);
@y
if (getenv("name") && total_chars > 0) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("name"), "a"));
  fprintf(f, "%s\n", s2);
  fclose(f);
}
b_close(&gf_file);
@z
