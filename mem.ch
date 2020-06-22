Allow to increase mem_max in constants.ch (mem_top, max_quarterword and max_halfword are also
adjusted accordingly).
@x
typedef uint8_t quarterword; /*1/4 of a word*/ 
typedef uint16_t halfword; /*1/2 of a word*/ 
@y
typedef int16_t quarterword; /*1/4 of a word*/ 
typedef int32_t halfword; /*1/2 of a word*/ 
@z
