@x
  {@+print_nl("You want to edit file ");
@.You want to edit file x@>
  slow_print(input_stack[file_ptr].name_field);
  print_str(" at line ");print_int(line);@/
@y
{ char tmp[30];
  assert(snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(cur_file.f)) < sizeof tmp);
  char fname[500] = { };
  assert(readlink(tmp, fname, sizeof fname) != -1 && fname[sizeof fname - 1] == '\0');
  char cmd[500];
  assert(snprintf(cmd, sizeof cmd, "em %s %d", fname, line) < sizeof cmd);
  system(cmd);
@z
