@x
    if (a_open_in(&cur_file)) goto done;
@y
    if (a_open_in(&cur_file)) goto done;
    for (str_number a = 550; a < @<|str_ptr| initialization@>; a++) {
      pack_file_name(cur_name, a, cur_ext);
      if (a_open_in(&cur_file)) goto done;
    }
@z

@x
@d str_549 " (INIMF)"
@y
@d str_549 " (INIMF)"
@d str_550 "/home/user/mf/MFinputs/mycyr/"
@d str_551 "/usr/share/texlive/texmf-dist/fonts/source/public/amsfonts/cmextra/"
@d str_552 "/home/user/mf/MFinputs/cm/"
@d str_553 "/home/user/mf/MFinputs/cmcyr/"
@d str_554 "/usr/share/texlive/texmf-dist/fonts/source/public/cmextra/"
@d str_555 "/usr/share/texlive/texmf-dist/fonts/source/public/knuth-lib/"
@d str_556 "/usr/share/texlive/texmf-dist/fonts/source/public/levy/"
@d str_557 "/usr/share/texlive/texmf-dist/fonts/source/public/yannisgr/"
@z

@x
str_544 str_545 str_546 str_547 str_548 str_549
@y
str_544 str_545 str_546 str_547 str_548 str_549 str_550 str_551 str_552 str_553 str_554 str_555
str_556 str_557
@z

@x
str_start_548, str_start_549, str_start_550
@y
str_start_548, str_start_549, str_start_550, str_start_551, str_start_552, str_start_553,
str_start_554, str_start_555, str_start_556, str_start_557, str_start_558
@z

@x
str_start_550=str_start_549+sizeof(str_549)-1,@/
@y
str_start_550=str_start_549+sizeof(str_549)-1,@/
str_start_551=str_start_550+sizeof(str_550)-1,@/
str_start_552=str_start_551+sizeof(str_551)-1,@/
str_start_553=str_start_552+sizeof(str_552)-1,@/
str_start_554=str_start_553+sizeof(str_553)-1,@/
str_start_555=str_start_554+sizeof(str_554)-1,@/
str_start_556=str_start_555+sizeof(str_555)-1,@/
str_start_557=str_start_556+sizeof(str_556)-1,@/
str_start_558=str_start_557+sizeof(str_557)-1,@/
@z

@x
@ @<|pool_ptr| initialization@>= str_start_550
@y
@ @<|pool_ptr| initialization@>= str_start_558
@z

@x
@ @<|str_ptr| initialization@>= 550
@y
@ @<|str_ptr| initialization@>= 558
@z
