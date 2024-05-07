Print "MFinputs/" instead of "/path/to/MFinputs/" to log file and terminal.

@x
if (term_offset+length(name) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(name);update_terminal;
@y
if (length(name) >= length(MF_area) &&
    strncmp(str_pool+str_start[name], str_pool+str_start[MF_area], length(MF_area)) == 0) {
  assert(str_ptr < max_strings);
  str_start[str_ptr] = str_start[name] + length(MF_area) - strlen("MFinputs/");
  str_start[str_ptr+1] = str_start[name+1];

  if (term_offset+length(str_ptr) > max_print_line-2) print_ln();
  else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
  print_char('(');incr(open_parens);slow_print(str_ptr);update_terminal;

  str_start[str_ptr] = pool_ptr;
}
else {
  if (term_offset+length(name) > max_print_line-2) print_ln();
  else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
  print_char('(');incr(open_parens);slow_print(name);update_terminal;
}
@z
