@x
enum {@+@!mem_max=30000@+}; /*greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise | >= mem_top|*/ 
@y
enum {@+@!mem_max=mem_top@+};
@z

@x
enum {@+@!max_strings=2000@+}; /*maximum number of strings; must not exceed |max_halfword|*/ 
@y
enum {@+@!max_strings=3000@+}; /*maximum number of strings; must not exceed |max_halfword|*/ 
@z

@x
enum {@+@!file_name_size=40@+}; /*file names shouldn't be longer than this*/
@y
enum {@+@!file_name_size=256@+}; /*file names shouldn't be longer than this*/
@z

@x
@d mem_top	30000 /*largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|*/ 
@y
@d mem_top	4999999
@z

@x
uint8_t @!name_length;@/ /*this many characters are actually
@y
uint16_t name_length; /*this many characters are actually
@z
