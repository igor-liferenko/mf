@x
@h
@y
#include <unistd.h>
@h
@z

@x
b_close(&gf_file);
@y
char absname[1000];
char tmp[1000];
snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(gf_file.f));
int nb = readlink(tmp, absname, sizeof absname - 1);
b_close(&gf_file);
if (nb != -1) {
  strcpy(tmp, "gftopk ");
  strcat(strncat(tmp, absname, nb), " >/dev/null 2>/dev/null");
  system(tmp);
}
@z
