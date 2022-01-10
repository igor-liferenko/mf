Format name is taken from 0th argument (symlink to virmf).

Gdb automatically sets full path to symlink.
To simplify the logic below, symlink is run via full path too.
@x
@p int main(int argc, char **argv) {
@y
@p int main(int argc, char **argv) {
#ifndef INIT
assert(*argv[0] == '/');
#endif
@z

@x
initialize(); /*set global variables to their starting values*/ 
@y
initialize(); /*set global variables to their starting values*/ 
#ifndef INIT
strncpy(name_of_file+1, MF_base_default+1, base_area_length);
strcat(name_of_file+1, strrchr(argv[0], '/') + 1);
strcat(name_of_file+1, ".base");
assert(w_open_in(&base_file));
term_out.f=fopen("/dev/null","w"); assert(load_base_file()); fclose(term_out.f); term_out.f=stdout;
w_close(&base_file);
#endif
@z
