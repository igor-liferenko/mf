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
@d str_550 "/home/user/mf/MFinputs/cm/"
@d str_551 "/home/user/mf/MFinputs/om/"
@d str_552 "/home/user/mf/MFinputs/lh/"
@z

@x
str_544 str_545 str_546 str_547 str_548 str_549
@y
str_544 str_545 str_546 str_547 str_548 str_549 str_550 str_551 str_552
@z

@x
str_start_548, str_start_549, str_start_550
@y
str_start_548, str_start_549, str_start_550, str_start_551, str_start_552, str_start_553
@z

@x
str_start_550=str_start_549+sizeof(str_549)-1,@/
@y
str_start_550=str_start_549+sizeof(str_549)-1,@/
str_start_551=str_start_550+sizeof(str_550)-1,@/
str_start_552=str_start_551+sizeof(str_551)-1,@/
str_start_553=str_start_552+sizeof(str_552)-1,@/
@z

@x
@ @<|pool_ptr| initialization@>= str_start_550
@y
@ @<|pool_ptr| initialization@>= str_start_553
@z

@x
@ @<|str_ptr| initialization@>= 550
@y
@ @<|str_ptr| initialization@>= 553
@z
