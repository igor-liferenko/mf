NOTE: editor must be full-screen (like vi, not like ed) - otherwise
output from editor will interfere with TeX's output

@x
@h
@y
#include <assert.h>
#include <unistd.h>
@h
@z

@x
  {@+print_nl("You want to edit file ");
@.You want to edit file x@>
  slow_print(input_stack[file_ptr].name_field);
  print_str(" at line ");print_int(line);@/
@y
{ char tmp[30];
  assert(snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(input_file[input_stack[file_ptr].index_field].f)) < sizeof tmp);
  char fname[500] = { };
  assert(readlink(tmp, fname, sizeof fname) != -1 && fname[sizeof fname - 1] == '\0');
  char editor[500];
  assert(snprintf(editor, sizeof editor, "em %s %d", fname, line) < sizeof editor);
  assert(system(editor) == 0);
@z
