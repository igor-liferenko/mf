I wonder which is a scenario where change 575 (mf84.bug) serves any purpose.
If the assert() trap is ever triggered, describe the scenario
that reproduces the trap in README.bug and delete this change-file.

@x
case 'E': if (file_ptr > 0) if (input_stack[file_ptr].name_field >= 256)
@y
case 'E': if (file_ptr > 0) assert(input_stack[file_ptr].name_field >= 256);
          if (file_ptr > 0)
@z

@x
if (file_ptr > 0) if (input_stack[file_ptr].name_field >= 256) 
@y
if (file_ptr > 0) assert(input_stack[file_ptr].name_field >= 256);
if (file_ptr > 0)
@z
