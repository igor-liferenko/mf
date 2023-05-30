Print "MFinputs/" instead of "/path/to/MFinputs/" to log file and terminal.

@x
if (term_offset+length(name) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(name);update_terminal;
@y
str_number _ = name;
if (length(name) >= length(MF_area) &&
    strncmp(str_pool+str_start[name], str_pool+str_start[MF_area], length(MF_area)) == 0) {
  _ = make_string();
  str_start[_+1] = str_start[name+1];
  str_start[_] = str_start[name] + length(MF_area) - strlen("MFinputs/");
}
if (term_offset+length(_) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(_);update_terminal;
if (_ != name) str_start[--str_ptr] = pool_ptr;
@z
