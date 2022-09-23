@x
@h
@y
#include <limits.h>
@h
bool font_making;
@z

@x
b_close(&gf_file);
@y
if (getenv("name")) {
  char s1[50], s2[PATH_MAX];
  sprintf(s1, "/proc/self/fd/%d", fileno(gf_file.f));
  assert(realpath(s1, s2));
  FILE *f;
  assert(f = fopen(getenv("name"), "w"));
  fprintf(f, "%s", s2);
  fclose(f);
  if (font_making) chmod(getenv("name"), S_IRUSR | S_IWUSR | S_IXUSR);
  else             chmod(getenv("name"), S_IRUSR | S_IWUSR);
}
b_close(&gf_file);
@z

@x
    internal[fontmaking]=0; /*avoid loop in case of fatal error*/ 
@y
    internal[fontmaking]=0; /*avoid loop in case of fatal error*/ 
    font_making=1;
@z
