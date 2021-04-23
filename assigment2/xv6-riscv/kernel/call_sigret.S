.globl call_sigret
.globl end_sigret

# call sig
call_sigret:
    # movl 24, a0
    # int 64
    # sigret()
    li a7,  24
    ecall
    ret
    
end_sigret: