ready_already trick does not work on modern systems, so load base file on each run.
Base name is passed via environment variable 'base'.

load_base_file() has its own error message ("(Fatal format file error; I'm stymied)"),
but we use assert() which prints its own error message,
so error message would be printed two times. To avoid this, error message during base loading
at startup is suppressed (besides, the error message could not appear on the system where MF
was written, i.e., where ready_already trick was used).

@x
initialize(); /*set global variables to their starting values*/ 
@y
initialize(); /*set global variables to their starting values*/ 
#ifndef INIT
if (getenv("base")) {
  strncpy(name_of_file+1, MF_base_default+1, base_area_length);
  strcat(name_of_file+1, getenv("base"));
  strcat(name_of_file+1, ".base");
  assert(w_open_in(&base_file));
  term_out.f=fopen("/dev/null","w"); assert(load_base_file()); fclose(term_out.f); term_out.f=stdout;
  w_close(&base_file);
}
#endif
@z
