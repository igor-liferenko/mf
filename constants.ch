@x
enum {@+@!mem_max=30000@+}; /*greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise | >= mem_top|*/ 
@y
#ifdef INIT
enum {@+@!mem_max=30000@+};
#else
enum {@+@!mem_max=50000@+};
#endif
@z
