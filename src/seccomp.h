/*
png2pos -- SECCOMP filter
*/

#ifndef _seccomp_h_
#define _seccomp_h_

#include <sys/prctl.h>
#include <linux/seccomp.h>
#include <linux/filter.h>
#include <linux/audit.h> /* for AUDIT_ARCH_xx */
#include <stddef.h> /* for offsetof */
#include <sys/syscall.h>

/* used syscalls could be listed via strace command:
   strace -c -f -S name \
       ./png2pos -c -a R -r -p -s 1 -o /dev/null test*.png 2>&1 1>/dev/null \
       | tail -n +3 | head -n -2 | awk '{print $(NF)}'
*/


#if defined(__i386__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_I386
#elif defined(__x86_64__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_X86_64
#elif defined(__arm__)
    /*
       <linux/audit.h> includes <linux/elf-em.h>, which does not define EM_ARM.
       <linux/elf.h> only includes <asm/elf.h> if we're in the kernel.
    */
    #ifndef EM_ARM
        #define EM_ARM 40
    #endif
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_ARM
#elif defined(__aarch64__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_AARCH64
#elif defined(__powerpc__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_PPC
#elif defined(__powerpc64le__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_PPC64LE
#elif defined(__powerpc64__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_PPC64
#elif defined(__s390__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_S390
#elif defined(__s390x__)
    #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_S390X
#elif defined(__mips__)
    #if defined(__MIPSEL__)
        #if defined(__LP64__)
            #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_MIPSEL64
        #else
            #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_MIPSEL
        #endif
            #elif defined(__LP64__)
        #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_MIPS64
    #else
        #define SECCOMP_AUDIT_ARCH AUDIT_ARCH_MIPS
    #endif
#else
    #error "Platform does not support seccomp filter yet"
#endif


#define ALLOW_SYSCALL(number) \
    BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, (number), 0, 1), \
    BPF_STMT(BPF_RET + BPF_K, SECCOMP_RET_ALLOW)

struct sock_filter filter[] = {
    /* validate architecture */
    BPF_STMT(BPF_LD + BPF_W + BPF_ABS, offsetof(struct seccomp_data, arch)),
    BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, SECCOMP_AUDIT_ARCH, 1, 0),
    BPF_STMT(BPF_RET + BPF_K, SECCOMP_RET_KILL),

    /* load syscall */
    BPF_STMT(BPF_LD + BPF_W + BPF_ABS, offsetof(struct seccomp_data, nr)),

    /* allowed syscalls */
#ifdef __NR_rt_sigreturn
    ALLOW_SYSCALL(__NR_rt_sigreturn),
#endif
#ifdef __NR_sigreturn
    ALLOW_SYSCALL(__NR_sigreturn),
#endif
#ifdef __NR_exit
    ALLOW_SYSCALL(__NR_exit),
#endif
#ifdef __NR_exit_group
    ALLOW_SYSCALL(__NR_exit_group),
#endif
#ifdef __NR_brk
    ALLOW_SYSCALL(__NR_brk),
#endif
#ifdef __NR_mmap
    ALLOW_SYSCALL(__NR_mmap),
#endif
#ifdef __NR_mmap2
    ALLOW_SYSCALL(__NR_mmap2),
#endif
#ifdef __NR_mremap
    ALLOW_SYSCALL(__NR_mremap),
#endif
#ifdef __NR_munmap
    ALLOW_SYSCALL(__NR_munmap),
#endif
#ifdef __NR_ioctl
    ALLOW_SYSCALL(__NR_ioctl),
#endif
#ifdef __NR_access
    ALLOW_SYSCALL(__NR_access),
#endif
#ifdef __NR_open
    ALLOW_SYSCALL(__NR_open),
#endif
#ifdef __NR_openat
    ALLOW_SYSCALL(__NR_openat),
#endif
#ifdef __NR_read
    ALLOW_SYSCALL(__NR_read),
#endif
#ifdef __NR_write
    ALLOW_SYSCALL(__NR_write),
#endif
#ifdef __NR_close
    ALLOW_SYSCALL(__NR_close),
#endif
#ifdef __NR_fstat
    ALLOW_SYSCALL(__NR_fstat),
#endif
#ifdef __NR_fstat64
    ALLOW_SYSCALL(__NR_fstat64),
#endif
#ifdef __NR_lseek
    ALLOW_SYSCALL(__NR_lseek),
#endif
#ifdef __NR_llseek
    ALLOW_SYSCALL(__NR_llseek),
#endif
#ifdef __NR__llseek
    ALLOW_SYSCALL(__NR__llseek),
#endif
#ifdef __NR_lseek64
    ALLOW_SYSCALL(__NR_lseek64),
#endif

    /* default policy: die (trap for debug) */
#ifdef DEBUG
    BPF_STMT(BPF_RET + BPF_K, SECCOMP_RET_TRAP)
#else
    BPF_STMT(BPF_RET + BPF_K, SECCOMP_RET_KILL)
#endif
};

struct sock_fprog seccomp_filter_prog = {
    .len = (unsigned short) (sizeof filter / sizeof filter[0]),
    .filter = (struct sock_filter *) filter
};

#endif
