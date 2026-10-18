If environment variable 'comment' is set, append its value to GF comment.

@x
print_dd(t/60);print_dd(t%60);@/
@y
print_dd(t/60);print_dd(t%60);@/
char *comment = getenv("comment");
if (comment && cur_length+strlen(comment) <= 255)
  while (*comment!='\0') print_char(*comment++);
@z
