Print "MFinputs/" instead of "/path/to/MFinputs/" to log file and terminal.

@x
@p void start_input(void) /*\MF\ will \.{input} something*/
{@+
@y
@p void start_input(void) /*\MF\ will \.{input} something*/
{@+
bool use_area = false;
@z

@x
    if (a_open_in(&cur_file)) goto done;
@y
    if (a_open_in(&cur_file)) { use_area = true; goto done; }
@z

@x
done: name=a_make_name_string(&cur_file);str_ref[cur_name]=max_str_ref;
@y
done: name=a_make_name_string(&cur_file);str_ref[cur_name]=max_str_ref;
if (use_area) pack_file_name(cur_name, MF_area_short, cur_ext);
str_number printed_name=a_make_name_string(&cur_file);
@z

@x
if (term_offset+length(name) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(name);update_terminal;
@y
if (term_offset+length(printed_name) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(printed_name);update_terminal;
@z

===== Add "MFinputs/" to string pool: =====

@x
@<|"debug # (-1 to exit):"|@>= 1081
@y
@<|"debug # (-1 to exit):"|@>= 1081
@ @d str_1082 "MFinputs/"
@d MF_area_short 1082
@z

@x
str_1080 str_1081
@y
str_1080 str_1081 str_1082
@z

@x
str_start_1080, str_start_1081, str_start_1082
@y
str_start_1080, str_start_1081, str_start_1082, str_start_1083
@z

@x
str_start_1082=str_start_1081+sizeof(str_1081)-1,@/
@y
str_start_1082=str_start_1081+sizeof(str_1081)-1,@/
str_start_1083=str_start_1082+sizeof(str_1082)-1,
@z

@x
@ @<|pool_ptr| initialization@>= str_start_1082
@y
@ @<|pool_ptr| initialization@>= str_start_1083
@z

@x
@ @<|str_ptr| initialization@>= 1082
@y
@ @<|str_ptr| initialization@>= 1083
@z
