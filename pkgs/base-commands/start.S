.text
.globl _start
_start:
#if defined(__x86_64__) && !defined(__ILP32__)
    mov $60, %eax
    mov $1, %edi
    syscall
#elif defined(__aarch64__)
    mov x8, #93
    mov x0, #1
    svc #0
#else
#error Unsupported Linux architecture
#endif

.section .note.GNU-stack,"",%progbits
