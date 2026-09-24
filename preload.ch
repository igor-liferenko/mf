'ready_already' trick does not work on modern systems, so load base file on each run.
Base name is passed via environment variable 'base'.
load_base_file() is called with silenced output,
in order to reproduce the behaviour of original MF which can not fail here.

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
