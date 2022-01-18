Format name is taken from 0th argument (symlink to virmf).

NOTE: it is assumed that argv[0] contains absolute path

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
