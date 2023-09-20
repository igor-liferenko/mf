Get GF, TFM and log file name.

@x
@h
@y
#include <limits.h>
@h
@z

@x
b_close(&tfm_file)
@y
if (getenv("MFtfm")) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(tfm_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("MFtfm"), "a"));
  fprintf(f, "%s\n", s2);
  fclose(f);
}
b_close(&tfm_file)
@z

@x
b_close(&gf_file);
@y
if (getenv("MFgf")) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("MFgf"), "a"));
  fprintf(f, "%s\n", s2);
  fclose(f);
}
b_close(&gf_file);
@z

@x
  a_close(&log_file);selector=selector-2;
@y
  if (getenv("MFlog")) {
    char s1[50], s2[PATH_MAX];
    sprintf(s1, "/proc/self/fd/%d", fileno(log_file.f));
    assert(realpath(s1, s2));
    FILE *f;
    assert(f = fopen(getenv("MFlog"), "a"));
    fprintf(f, "%s\n", s2);
    fclose(f);
  }
  a_close(&log_file);selector=selector-2;
@z
