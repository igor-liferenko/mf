@x
    if (a_open_in(&cur_file)) goto done;
@y
    if (a_open_in(&cur_file)) goto done;
    pack_file_name(cur_name, MF_area_2, cur_ext);
    if (a_open_in(&cur_file)) goto done;
    pack_file_name(cur_name, MF_area_3, cur_ext);
    if (a_open_in(&cur_file)) goto done;
@z

@x
@<|" (INIMF)"|@>=@+549
@y
@<|" (INIMF)"|@>=@+549
@
@d str_550 "/usr/share/texlive/texmf-dist/fonts/source/public/cm/"
@d MF_area_2 550
@
@d str_551 "/usr/share/texlive/texmf-dist/fonts/source/lh/base/"
@d MF_area_3 551
@z

@x
str_544 str_545 str_546 str_547 str_548 str_549
@y
str_544 str_545 str_546 str_547 str_548 str_549 str_550 str_551
@z

@x
str_start_548, str_start_549, str_start_550
@y
str_start_548, str_start_549, str_start_550, str_start_551, str_start_552
@z

@x
str_start_end } str_starts;
@y
str_start_551=str_start_550+sizeof(str_550)-1,@/
str_start_552=str_start_551+sizeof(str_551)-1,@/
str_start_end } str_starts;
@z

@x
@ @<|pool_ptr| initialization@>= str_start_550
@y
@ @<|pool_ptr| initialization@>= str_start_552
@z

@x
@ @<|str_ptr| initialization@>= 550
@y
@ @<|str_ptr| initialization@>= 552
@z
