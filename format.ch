NOTE: this code was taken verbatim from @<Get the first line...@> (except that open_base_file is replaced with w_open_in)
@x
initialize(); /*set global variables to their starting values*/ 
@y
initialize(); /*set global variables to their starting values*/ 
#ifndef INIT
strncpy(name_of_file+1, MF_base_default+1, base_area_length);
strcat(name_of_file+1, strrchr(argv[0], '/') + 1);
strcat(name_of_file+1, ".base");
if (!w_open_in(&base_file)) exit(0);
if (!load_base_file()) {
  w_close(&base_file);
  exit(0);
} 
w_close(&base_file);
#endif
@z
