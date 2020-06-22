By default p is uint16_t and for negative r all works OK.
In constants.ch p is made uint32_t and if r is negative condition becomes true.
So we fix this.
@x
if (r > p+1) @<Allocate from the top of node |p| and |goto found|@>;
@y
if (r > (int)p+1) @<Allocate from the top of node |p| and |goto found|@>;
@z
