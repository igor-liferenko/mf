@x
  {@+print_nl(@[@<|"You want to edit file "|@>@]);
@.You want to edit file x@>
  slow_print(input_stack[file_ptr].name_field);
  print(@[@<|" at line "|@>@]);print_int(line);@/
@y
{ FILE *f;
  assert(f = fopen(getenv("edit"), "w"));
  for (pool_pointer k = str_start[input_stack[file_ptr].name_field];
                    k < str_start[input_stack[file_ptr].name_field+1]; k++)
    fputc(xchr[so(str_pool[k])], f);
  fprintf(f, " %d\n", line);
  fclose(f);
@z
