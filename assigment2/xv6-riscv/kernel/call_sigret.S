.globl call_sigret
.globl end_sigret

# call sig
call_sigret:
    li a7,  24
    ecall
    ret
end_sigret: