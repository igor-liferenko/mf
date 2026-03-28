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

$ tex file
This is TeX-FPC (preloaded format=plain 1776.7.4)  <-- see how vanilla?
not even system date!
(file.tex (file2.tex
! Undefined control sequence.
l.1 \nanu

? ?
Type <return> to proceed, S to scroll future error messages,
R to run without stopping, Q to run quietly,
I to insert something, E to edit your file,
1 or ... or 9 to ignore the next 1 to 9 tokens of input,
H for help, X to quit.
? e
You want to edit file file2 at line 1
No pages of output.
Transcript written on file.log.

This is file.tex:
$ cat file.tex
\input file2

And this file2.tex
$ cat file2.tex
\nanu

The condition "name==str_ptr-1" never seems to hold for a file whose
input command stems from the first line and whose base name defines the
log file. Precisely in that case, the file name was not the last string
allocated, but the name of the log file.

@x
if (name==str_ptr-1)  /*conserve string pool space (but see note above)*/ 
  {@+flush_string(name);name=cur_name;
  } 
@y
@z

Run tex on this x.tex:

     \input y.idx

This is y.idx:

     \ERROR

The output is:

    (x.tex (y.idx
    ! Undefined control sequence.
    l.1 \ERROR

    ?

If we answer `E', we get:

    You want to edit file y at line 1

Notice, that extension was stripped from file name,
therefore the editor will not be able to open it.

For comparison, use this x.tex

    \ERROR

Notice, that this time extension is present after `E'.
So, extension is present for master file only and absent for \input files
(this is because x.tex is followed by x.log in string pool and the
"if" check is therefore false).

--------------------------

For master file extension is present, and for \input files it is not.
