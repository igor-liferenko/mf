@x
#include "pascal.tab.h"
@y
#include "pascal-mf.tab.h"
@z

@x
SYM_PTR("register")->name="internal_register";
@y
SYM_PTR("register")->name="internal_register";
SYM_PTR("void")->name="v\320\276id"; /* reserved word in C */
SYM_PTR("time")->name="time_of_day"; /* for ../time.ch */
SYM_PTR("read")->name="pascal_read"; /* for ../screen.ch */
SYM_PTR("close")->name="pascal_close"; /* for ../screen.ch */
@z

@x
    else@+ if (t->sym_no==TeXinputs_no) wprint("TEX_area");
@y
    else@+ if (t->sym_no==TeXinputs_no) wprint("MF_area");
@z

@x
    else if (t->sym_no==fmt_no) wprint("format_extension");
@y
    else if (t->sym_no==fmt_no) wprint("base_extension");
@z

@x
    else if (str_k->sym_no==TeXinputs_no) wputs("@@d TEX_area "),wputi(k);
@y
    else if (str_k->sym_no==TeXinputs_no) wputs("@@d MF_area "),wputi(k);
@z

@x
    else if (str_k->sym_no==fmt_no) wputs("@@d format_extension "),wputi(k);
@y
    else if (str_k->sym_no==fmt_no) wputs("@@d base_extension "),wputi(k);
@z

@x
TeXinputs_no=predefine("\"TeXinputs:\"",PID,0); 
@y
TeXinputs_no=predefine("\"MFinputs:\"",PID,0); 
@z

@x
fmt_no=predefine("\".fmt\"",PID,0); 
@y
fmt_no=predefine("\".base\"",PID,0); 
@z
