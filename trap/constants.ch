@x
@!mem_max=30000; {greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise |>=mem_top|}
@y
@!mem_max=3000;
@z

@x
@!error_line=72; {width of context lines on terminal error messages}
@!half_error_line=42; {width of first lines of contexts in terminal
@y
@!error_line=64; {width of context lines on terminal error messages}
@!half_error_line=32; {width of first lines of contexts in terminal
@z

@x
@!max_print_line=79; {width of longest text lines output; should be at least 60}
@!screen_width=768; {number of pixels in each row of screen display}
@!screen_depth=1024; {number of pixels in each column of screen display}
@y
@!max_print_line=72; {width of longest text lines output; should be at least 60}
@!screen_width=100; {number of pixels in each row of screen display}
@!screen_depth=200; {number of pixels in each column of screen display}
@z

@x
@!gf_buf_size=800; {size of the output buffer, must be a multiple of 8}
@y
@!gf_buf_size=8; {size of the output buffer, must be a multiple of 8}
@z

@x
@d mem_top==30000 {largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|}
@y
@d mem_top==3000
@z
