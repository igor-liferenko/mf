@x
enum {@+@!mem_max=30000@+}; /*greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise | >= mem_top|*/ 
@y
enum {@+@!mem_max=262142@+};
@z

@x
@d mem_top	30000 /*largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|*/ 
@y
@d mem_top      262142
@z

@x
@d max_in_open	6 /*maximum number of input files and error insertions that
  can be going on simultaneously*/
@y
@d max_in_open 10
@z

@x
@d max_quarterword	255 /*largest allowable value in a |quarterword|*/
@y
@d max_quarterword 511
@z

@x
@d max_halfword	65535 /*largest allowable value in a |halfword|*/
@y
@d max_halfword 262143
@z

@x
typedef uint8_t quarterword; /*1/4 of a word*/ 
typedef uint16_t halfword; /*1/2 of a word*/ 
@y
typedef uint16_t quarterword; /*1/4 of a word*/ 
typedef uint32_t halfword; /*1/2 of a word*/ 
@z
