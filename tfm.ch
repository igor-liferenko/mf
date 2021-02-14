Always put .tfm to TeXfonts/
(prevents naming local font file as any file in TeXfonts/).

@x
@p void pack_job_name(str_number @!s) /*|s==@[@<|".log"|@>@]|, |@[@<|".gf"|@>@]|,
  |@[@<|".tfm"|@>@]|, or |base_extension|*/
{@+cur_area=empty_string;cur_ext=s;
@y
@p void pack_job_name(str_number @!s) /*|s==@[@<|".log"|@>@]|, |@[@<|".gf"|@>@]|,
  |@[@<|".tfm"|@>@]|, or |base_extension|*/
{ if (s == @<|".tfm"|@>) cur_area=@<|"TeXfonts"|@>; else cur_area=empty_string; cur_ext=s;
@z

@x
@<|" (INIMF)"|@>=@+549
@y
@<|" (INIMF)"|@>=@+549
@ 
@d str_550 "/home/user/tex/TeXfonts/"
@<|"TeXfonts"|@>=@+550
@z

@x
str_544 str_545 str_546 str_547 str_548 str_549 
@y
str_544 str_545 str_546 str_547 str_548 str_549 str_550
@z

@x
str_start_548, str_start_549, str_start_550
@y
str_start_548, str_start_549, str_start_550, str_start_551
@z

@x
str_start_end } str_starts;
@y
str_start_551=str_start_550+sizeof(str_550)-1,@/
str_start_end } str_starts;
@z

@x
@ @<|pool_ptr| initialization@>= str_start_550
@y
@ @<|pool_ptr| initialization@>= str_start_551
@z

@x
@ @<|str_ptr| initialization@>= 550
@y
@ @<|str_ptr| initialization@>= 551
@z
