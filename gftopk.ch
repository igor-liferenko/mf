TODO:
1) do via fork+exec directly (like in wayland.w)
2) kill if gftopk fails (like in 'git lg -- input.ch' in tex/)

@x
b_close(&gf_file);
@y
char fname[1000];
char tmp[1000];
snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(gf_file.f));
int nb = readlink(tmp, fname, sizeof fname - 1);
b_close(&gf_file);
if (nb != -1) {
  strncat(strcpy(tmp, "gftopk "), fname, nb);
  system(tmp);
}
@z
