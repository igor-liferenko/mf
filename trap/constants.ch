@x
enum {@+@!mem_max=30000@+}; /*greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise | >= mem_top|*/ 
@y
enum {@+@!mem_max=3000@+};
@z

@x
enum {@+@!error_line=72@+}; /*width of context lines on terminal error messages*/ 
enum {@+@!half_error_line=42@+}; /*width of first lines of contexts in terminal
  error messages; should be between 30 and |error_line-15|*/ 
enum {@+@!max_print_line=79@+}; /*width of longest text lines output; should be at least 60*/ 
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/ 
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/ 
@y
enum {@+@!error_line=64@+};
enum {@+@!half_error_line=32@+};
enum {@+@!max_print_line=72@+};
enum {@+@!screen_width=100@+};
enum {@+@!screen_depth=200@+};
@z

@x
enum {@+@!gf_buf_size=800@+}; /*size of the output buffer, must be a multiple of 8*/ 
@y
enum {@+@!gf_buf_size=8@+};
@z

@x
@d mem_top	30000 /*largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|*/ 
@y
@d mem_top      3000
@z

@x Screen routines:
@p bool init_screen(void)
{@+return false;
@y
@p bool init_screen(void)
{@+return true; /* screen instructions will be logged */
@z
