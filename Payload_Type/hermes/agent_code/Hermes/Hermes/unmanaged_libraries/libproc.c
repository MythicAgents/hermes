/*
 * Copyright (c) 2006, 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#include <sys/cdefs.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <strings.h>
#include <sys/errno.h>
#include <sys/msgbuf.h>
#include <sys/resource.h>
#include "process_policy.h"
#include <mach/message.h>

#include "libproc_internal.h"

#define PROC_PIDLISTFDS            1
#define PROC_PIDLISTFD_SIZE        (sizeof(struct proc_fdinfo))
#define PROC_PIDTASKALLINFO        2
#define PROC_PIDTASKALLINFO_SIZE    (sizeof(struct proc_taskallinfo))
#define PROC_PIDTBSDINFO        3
#define PROC_PIDTBSDINFO_SIZE        (sizeof(struct proc_bsdinfo))
#define PROC_PIDTASKINFO        4
#define PROC_PIDTASKINFO_SIZE        (sizeof(struct proc_taskinfo))
#define PROC_PIDTHREADINFO        5
#define PROC_PIDTHREADINFO_SIZE        (sizeof(struct proc_threadinfo))
#define PROC_PIDLISTTHREADS        6
#define PROC_PIDLISTTHREADS_SIZE    (2* sizeof(uint32_t))
#define PROC_PIDREGIONINFO        7
#define PROC_PIDREGIONINFO_SIZE        (sizeof(struct proc_regioninfo))
#define PROC_PIDREGIONPATHINFO        8
#define PROC_PIDREGIONPATHINFO_SIZE    (sizeof(struct proc_regionwithpathinfo))
#define PROC_PIDVNODEPATHINFO        9
#define PROC_PIDVNODEPATHINFO_SIZE    (sizeof(struct proc_vnodepathinfo))
#define PROC_PIDTHREADPATHINFO        10
#define PROC_PIDTHREADPATHINFO_SIZE    (sizeof(struct proc_threadwithpathinfo))
#define PROC_PIDPATHINFO        11
#define PROC_PIDPATHINFO_SIZE        (MAXPATHLEN)
#define PROC_PIDPATHINFO_MAXSIZE    (4*MAXPATHLEN)
#define PROC_PIDWORKQUEUEINFO        12
#define PROC_PIDWORKQUEUEINFO_SIZE    (sizeof(struct proc_workqueueinfo))
#define PROC_PIDT_SHORTBSDINFO        13
#define PROC_PIDT_SHORTBSDINFO_SIZE    (sizeof(struct proc_bsdshortinfo))
#define PROC_PIDLISTFILEPORTS        14
#define PROC_PIDLISTFILEPORTS_SIZE    (sizeof(struct proc_fileportinfo))
#define PROC_PIDTHREADID64INFO        15
#define PROC_PIDTHREADID64INFO_SIZE    (sizeof(struct proc_threadinfo))
#define PROC_PID_RUSAGE            16
#define PROC_PID_RUSAGE_SIZE        0
#ifdef  PRIVATE
#define PROC_PIDUNIQIDENTIFIERINFO    17
#define PROC_PIDUNIQIDENTIFIERINFO_SIZE \
                                      (sizeof(struct proc_uniqidentifierinfo))
#define PROC_PIDT_BSDINFOWITHUNIQID    18
#define PROC_PIDT_BSDINFOWITHUNIQID_SIZE \
                                     (sizeof(struct proc_bsdinfowithuniqid))
#define PROC_PIDARCHINFO        19
#define PROC_PIDARCHINFO_SIZE        \
                    (sizeof(struct proc_archinfo))
#define PROC_PIDCOALITIONINFO        20
#define PROC_PIDCOALITIONINFO_SIZE    (sizeof(struct proc_pidcoalitioninfo))
#define PROC_PIDNOTEEXIT        21
#define PROC_PIDNOTEEXIT_SIZE        (sizeof(uint32_t))
#define PROC_PIDREGIONPATHINFO2        22
#define PROC_PIDREGIONPATHINFO2_SIZE    (sizeof(struct proc_regionwithpathinfo))
#define PROC_PIDREGIONPATHINFO3        23
#define PROC_PIDREGIONPATHINFO3_SIZE    (sizeof(struct proc_regionwithpathinfo))
#define PROC_PIDEXITREASONINFO        24
#define PROC_PIDEXITREASONINFO_SIZE    (sizeof(struct proc_exitreasoninfo))
#define PROC_PIDEXITREASONBASICINFO    25
#define PROC_PIDEXITREASONBASICINFOSIZE    (sizeof(struct proc_exitreasonbasicinfo))
#define PROC_PIDLISTUPTRS      26
#define PROC_PIDLISTUPTRS_SIZE (sizeof(uint64_t))
#define PROC_PIDLISTDYNKQUEUES      27
#define PROC_PIDLISTDYNKQUEUES_SIZE (sizeof(kqueue_id_t))
#define PROC_PIDLISTTHREADIDS        28
#define PROC_PIDLISTTHREADIDS_SIZE    (2* sizeof(uint32_t))
#define PROC_PIDVMRTFAULTINFO        29
#define PROC_PIDVMRTFAULTINFO_SIZE (7 * sizeof(uint64_t))
#endif /* PRIVATE */
/* Flavors for proc_pidfdinfo */
#define PROC_PIDFDVNODEINFO        1
#define PROC_PIDFDVNODEINFO_SIZE    (sizeof(struct vnode_fdinfo))
#define PROC_PIDFDVNODEPATHINFO        2
#define PROC_PIDFDVNODEPATHINFO_SIZE    (sizeof(struct vnode_fdinfowithpath))
#define PROC_PIDFDSOCKETINFO        3
#define PROC_PIDFDSOCKETINFO_SIZE    (sizeof(struct socket_fdinfo))
#define PROC_PIDFDPSEMINFO        4
#define PROC_PIDFDPSEMINFO_SIZE        (sizeof(struct psem_fdinfo))
#define PROC_PIDFDPSHMINFO        5
#define PROC_PIDFDPSHMINFO_SIZE        (sizeof(struct pshm_fdinfo))
#define PROC_PIDFDPIPEINFO        6
#define PROC_PIDFDPIPEINFO_SIZE        (sizeof(struct pipe_fdinfo))
#define PROC_PIDFDKQUEUEINFO        7
#define PROC_PIDFDKQUEUEINFO_SIZE    (sizeof(struct kqueue_fdinfo))
#define PROC_PIDFDATALKINFO        8
#define PROC_PIDFDATALKINFO_SIZE    (sizeof(struct appletalk_fdinfo))
#ifdef PRIVATE
#define PROC_PIDFDKQUEUE_EXTINFO    9
#define PROC_PIDFDKQUEUE_EXTINFO_SIZE    (sizeof(struct kevent_extinfo))
#define PROC_PIDFDKQUEUE_KNOTES_MAX    (1024 * 128)
#define PROC_PIDDYNKQUEUES_MAX    (1024 * 128)
#endif /* PRIVATE */
/* Flavors for proc_pidfileportinfo */
#define PROC_PIDFILEPORTVNODEPATHINFO    2    /* out: vnode_fdinfowithpath */
#define PROC_PIDFILEPORTVNODEPATHINFO_SIZE    \
                    PROC_PIDFDVNODEPATHINFO_SIZE
#define PROC_PIDFILEPORTSOCKETINFO    3    /* out: socket_fdinfo */
#define PROC_PIDFILEPORTSOCKETINFO_SIZE    PROC_PIDFDSOCKETINFO_SIZE
#define PROC_PIDFILEPORTPSHMINFO    5    /* out: pshm_fdinfo */
#define PROC_PIDFILEPORTPSHMINFO_SIZE    PROC_PIDFDPSHMINFO_SIZE
#define PROC_PIDFILEPORTPIPEINFO    6    /* out: pipe_fdinfo */
#define PROC_PIDFILEPORTPIPEINFO_SIZE    PROC_PIDFDPIPEINFO_SIZE
/* used for proc_setcontrol */
#define PROC_SELFSET_PCONTROL        1
#define PROC_SELFSET_THREADNAME        2
#define PROC_SELFSET_THREADNAME_SIZE    (MAXTHREADNAMESIZE -1)
#define PROC_SELFSET_VMRSRCOWNER    3
#define PROC_SELFSET_DELAYIDLESLEEP    4
/* used for proc_dirtycontrol */
#define PROC_DIRTYCONTROL_TRACK         1
#define PROC_DIRTYCONTROL_SET           2
#define PROC_DIRTYCONTROL_GET           3
#define PROC_DIRTYCONTROL_CLEAR         4
/* proc_track_dirty() flags */
#define PROC_DIRTY_TRACK                0x1
#define PROC_DIRTY_ALLOW_IDLE_EXIT      0x2
#define PROC_DIRTY_DEFER                0x4
#define PROC_DIRTY_LAUNCH_IN_PROGRESS   0x8
#define PROC_DIRTY_DEFER_ALWAYS         0x10
/* proc_get_dirty() flags */
#define PROC_DIRTY_TRACKED              0x1
#define PROC_DIRTY_ALLOWS_IDLE_EXIT     0x2
#define PROC_DIRTY_IS_DIRTY             0x4
#define PROC_DIRTY_LAUNCH_IS_IN_PROGRESS   0x8
/* Flavors for proc_udata_info */
#define PROC_UDATA_INFO_GET        1
#define PROC_UDATA_INFO_SET        2
/* Flavors for proc_pidoriginatorinfo */
#define PROC_PIDORIGINATOR_UUID        0x1
#define PROC_PIDORIGINATOR_UUID_SIZE    (sizeof(uuid_t))
#define PROC_PIDORIGINATOR_BGSTATE    0x2
#define PROC_PIDORIGINATOR_BGSTATE_SIZE (sizeof(uint32_t))
#define PROC_PIDORIGINATOR_PID_UUID     0x3
#define PROC_PIDORIGINATOR_PID_UUID_SIZE (sizeof(struct proc_originatorinfo))
/* Flavors for proc_listcoalitions */
#define LISTCOALITIONS_ALL_COALS    1
#define LISTCOALITIONS_ALL_COALS_SIZE   (sizeof(struct procinfo_coalinfo))
#define LISTCOALITIONS_SINGLE_TYPE    2
#define LISTCOALITIONS_SINGLE_TYPE_SIZE (sizeof(struct procinfo_coalinfo))
/* reasons for proc_can_use_foreground_hw */
#define PROC_FGHW_OK                     0 /* pid may use foreground HW */
#define PROC_FGHW_DAEMON_OK              1
#define PROC_FGHW_DAEMON_LEADER         10 /* pid is in a daemon coalition */
#define PROC_FGHW_LEADER_NONUI          11 /* coalition leader is in a non-focal state */
#define PROC_FGHW_LEADER_BACKGROUND     12 /* coalition leader is in a background state */
#define PROC_FGHW_DAEMON_NO_VOUCHER     13 /* pid is a daemon with no adopted voucher */
#define PROC_FGHW_NO_VOUCHER_ATTR       14 /* pid has adopted a voucher with no bank/originator attribute */
#define PROC_FGHW_NO_ORIGINATOR         15 /* pid has adopted a voucher for a process that's gone away */
#define PROC_FGHW_ORIGINATOR_BACKGROUND 16 /* pid has adopted a voucher for an app that's in the background */
#define PROC_FGHW_VOUCHER_ERROR         98 /* error in voucher / originator callout */
#define PROC_FGHW_ERROR                 99 /* syscall parameter/permissions error */
/* flavors for proc_piddynkqueueinfo */
#define PROC_PIDDYNKQUEUE_INFO         0
#define PROC_PIDDYNKQUEUE_INFO_SIZE    (sizeof(struct kqueue_dyninfo))
#define PROC_PIDDYNKQUEUE_EXTINFO      1
#define PROC_PIDDYNKQUEUE_EXTINFO_SIZE (sizeof(struct kevent_extinfo))
/* __proc_info() call numbers */
#define PROC_INFO_CALL_LISTPIDS          0x1
#define PROC_INFO_CALL_PIDINFO           0x2
#define PROC_INFO_CALL_PIDFDINFO         0x3
#define PROC_INFO_CALL_KERNMSGBUF        0x4
#define PROC_INFO_CALL_SETCONTROL        0x5
#define PROC_INFO_CALL_PIDFILEPORTINFO   0x6
#define PROC_INFO_CALL_TERMINATE         0x7
#define PROC_INFO_CALL_DIRTYCONTROL      0x8
#define PROC_INFO_CALL_PIDRUSAGE         0x9
#define PROC_INFO_CALL_PIDORIGINATORINFO 0xa
#define PROC_INFO_CALL_LISTCOALITIONS    0xb
#define PROC_INFO_CALL_CANUSEFGHW        0xc
#define PROC_INFO_CALL_PIDDYNKQUEUEINFO  0xd
#define PROC_INFO_CALL_UDATA_INFO        0xe

int __proc_info(int callnum, int pid, int flavor, uint64_t arg, void * buffer, int buffersize);
__private_extern__ int proc_setthreadname(void * buffer, int buffersize);
int __process_policy(int scope, int action, int policy, int policy_subtype, proc_policy_attribute_t * attrp, pid_t target_pid, uint64_t target_threadid);
int proc_rlimit_control(pid_t pid, int flavor, void *arg);

int
proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize)
{
    int retval;
    
    if ((type >= PROC_ALL_PIDS) || (type <= PROC_PPID_ONLY)) {
        if ((retval = __proc_info(PROC_INFO_CALL_LISTPIDS, type, typeinfo,(uint64_t)0, buffer, buffersize)) == -1)
            return(0);
    } else {
        errno = EINVAL;
        retval = 0;
    }
    return(retval);
}


int
proc_listallpids(void * buffer, int buffersize)
{
    int numpids;
    numpids = proc_listpids(PROC_ALL_PIDS, (uint32_t)0, buffer, buffersize);

    if (numpids == -1)
        return(-1);
    else
        return(numpids/sizeof(int));
}

int
proc_listpgrppids(pid_t pgrpid, void * buffer, int buffersize)
{
    int numpids;
    numpids = proc_listpids(PROC_PGRP_ONLY, (uint32_t)pgrpid, buffer, buffersize);
    if (numpids == -1)
        return(-1);
    else
        return(numpids/sizeof(int));
}

int
proc_listchildpids(pid_t ppid, void * buffer, int buffersize)
{
    int numpids;
    numpids = proc_listpids(PROC_PPID_ONLY, (uint32_t)ppid, buffer, buffersize);
    if (numpids == -1)
        return(-1);
    else
        return(numpids/sizeof(int));
}


int
proc_pidinfo(int pid, int flavor, uint64_t arg,  void *buffer, int buffersize)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_PIDINFO, pid, flavor,  arg,  buffer, buffersize)) == -1)
        return(0);
        
    return(retval);
}


int
proc_pidoriginatorinfo(int flavor, void *buffer, int buffersize)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_PIDORIGINATORINFO, getpid(), flavor,  0,  buffer, buffersize)) == -1)
        return(0);
        
    return(retval);
}

int
proc_pid_rusage(int pid, int flavor, rusage_info_t *buffer)
{
    return (__proc_info(PROC_INFO_CALL_PIDRUSAGE, pid, flavor, 0, buffer, 0));
}

int
proc_setthread_cpupercent(uint8_t percentage, uint32_t ms_refill)
{
    uint32_t arg = 0;

    /* Pack percentage and refill into a 32-bit number to match existing kernel implementation */
    if ((percentage >= 100) || (ms_refill & ~0xffffffU)) {
        errno = EINVAL;
        return -1;
    }

    arg = ((ms_refill << 8) | percentage);

    return (proc_rlimit_control(-1, RLIMIT_THREAD_CPULIMITS, (void *)(uintptr_t)arg));
}

int
proc_pidfdinfo(int pid, int fd, int flavor, void * buffer, int buffersize)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_PIDFDINFO, pid,  flavor, (uint64_t)fd, buffer, buffersize)) == -1)
        return(0);
        
    return (retval);
}


int
proc_pidfileportinfo(int pid, uint32_t fileport, int flavor, void *buffer, int buffersize)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_PIDFILEPORTINFO, pid, flavor, (uint64_t)fileport, buffer, buffersize)) == -1)
        return (0);
    return (retval);
}


int
proc_name(int pid, void * buffer, uint32_t buffersize)
{
    int retval = 0, len;
    struct proc_bsdinfo pbsd;
    
    
    if (buffersize < sizeof(pbsd.pbi_name)) {
        errno = ENOMEM;
        return(0);
    }

    retval = proc_pidinfo(pid, PROC_PIDTBSDINFO, (uint64_t)0, &pbsd, sizeof(struct proc_bsdinfo));
    if (retval != 0) {
        if (pbsd.pbi_name[0]) {
            bcopy(&pbsd.pbi_name, buffer, sizeof(pbsd.pbi_name));
        } else {
            bcopy(&pbsd.pbi_comm, buffer, sizeof(pbsd.pbi_comm));
        }
        len = (int)strlen(buffer);
        return(len);
    }
    return(0);
}

int
proc_regionfilename(int pid, uint64_t address, void * buffer, uint32_t buffersize)
{
    int retval = 0, len;
    struct proc_regionwithpathinfo reginfo;
    
    if (buffersize < MAXPATHLEN) {
        errno = ENOMEM;
        return(0);
    }
    
    retval = proc_pidinfo(pid, PROC_PIDREGIONPATHINFO, (uint64_t)address, &reginfo, sizeof(struct proc_regionwithpathinfo));
    if (retval != -1) {
        len = (int)strlen(&reginfo.prp_vip.vip_path[0]);
        if (len != 0) {
            if (len > MAXPATHLEN)
                len = MAXPATHLEN;
            bcopy(&reginfo.prp_vip.vip_path[0], buffer, len);
            return(len);
        }
        return(0);
    }
    return(0);
            
}

int
proc_kmsgbuf(void * buffer, uint32_t  buffersize)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_KERNMSGBUF, 0,  0, (uint64_t)0, buffer, buffersize)) == -1)
        return(0);
    return (retval);
}

int
proc_pidpath(int pid, void * buffer, uint32_t  buffersize)
{
    int retval, len;

    if (buffersize < PROC_PIDPATHINFO_SIZE) {
        errno = ENOMEM;
        return(0);
    }
    if (buffersize >  PROC_PIDPATHINFO_MAXSIZE) {
        errno = EOVERFLOW;
        return(0);
    }

    retval = __proc_info(PROC_INFO_CALL_PIDINFO, pid, PROC_PIDPATHINFO,  (uint64_t)0,  buffer, buffersize);
    if (retval != -1) {
        len = (int)strlen(buffer);
        return(len);
    }
    return (0);
}


int
proc_libversion(int *major, int * minor)
{

    if (major != NULL)
        *major = 1;
    if (minor != NULL)
        *minor = 1;
    return(0);
}

int
proc_setpcontrol(const int control)
{
    int retval ;

    if (control < PROC_SETPC_NONE || control > PROC_SETPC_TERMINATE)
        return(EINVAL);

    if ((retval = __proc_info(PROC_INFO_CALL_SETCONTROL, getpid(), PROC_SELFSET_PCONTROL, (uint64_t)control, NULL, 0)) == -1)
        return(errno);
        
    return(0);
}


__private_extern__ int
proc_setthreadname(void * buffer, int buffersize)
{
    int retval;

        retval = __proc_info(PROC_INFO_CALL_SETCONTROL, getpid(), PROC_SELFSET_THREADNAME, (uint64_t)0, buffer, buffersize);

    if (retval == -1)
                return(errno);
    else
        return(0);
}

int
proc_track_dirty(pid_t pid, uint32_t flags)
{
    if (__proc_info(PROC_INFO_CALL_DIRTYCONTROL, pid, PROC_DIRTYCONTROL_TRACK, flags, NULL, 0) == -1) {
        return errno;
    }
        
    return 0;
}

int
proc_set_dirty(pid_t pid, bool dirty)
{
    if (__proc_info(PROC_INFO_CALL_DIRTYCONTROL, pid, PROC_DIRTYCONTROL_SET, dirty, NULL, 0) == -1) {
        return errno;
    }

    return 0;
}

int
proc_get_dirty(pid_t pid, uint32_t *flags)
{
    int retval;
    
    if (!flags) {
        return EINVAL;
    }
    
    retval = __proc_info(PROC_INFO_CALL_DIRTYCONTROL, pid, PROC_DIRTYCONTROL_GET, 0, NULL, 0);
    if (retval == -1) {
        return errno;
    }
    
    *flags = retval;

    return 0;
}

int
proc_clear_dirty(pid_t pid, uint32_t flags)
{
    if (__proc_info(PROC_INFO_CALL_DIRTYCONTROL, pid, PROC_DIRTYCONTROL_CLEAR, flags, NULL, 0) == -1) {
        return errno;
    }

    return 0;
}

int
proc_terminate(pid_t pid, int *sig)
{
    int retval;
    
    if (!sig) {
        return EINVAL;
    }
    
    retval = __proc_info(PROC_INFO_CALL_TERMINATE, pid, 0, 0, NULL, 0);
    if (retval == -1) {
        return errno;
    }
    
    *sig = retval;
    
    return 0;
}

int
proc_set_cpumon_params(pid_t pid, int percentage, int interval)
{
    proc_policy_cpuusage_attr_t attr;

    attr.ppattr_cpu_attr = PROC_POLICY_RSRCACT_NOTIFY_EXC;
    attr.ppattr_cpu_percentage = percentage;
    attr.ppattr_cpu_attr_interval = (uint64_t)interval;
    attr.ppattr_cpu_attr_deadline = 0;

    return(__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_SET, PROC_POLICY_RESOURCE_USAGE,
        PROC_POLICY_RUSAGE_CPU, (proc_policy_attribute_t*)&attr, pid, 0));
}

int
proc_get_cpumon_params(pid_t pid, int *percentage, int *interval)
{
    proc_policy_cpuusage_attr_t attr;
    int ret;

    ret = __process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_GET, PROC_POLICY_RESOURCE_USAGE,
        PROC_POLICY_RUSAGE_CPU, (proc_policy_attribute_t*)&attr, pid, 0);

    if ((ret == 0) && (attr.ppattr_cpu_attr == PROC_POLICY_RSRCACT_NOTIFY_EXC)) {
        *percentage = attr.ppattr_cpu_percentage;
        *interval = (int)attr.ppattr_cpu_attr_interval;
    } else {
        *percentage = 0;
        *interval = 0;
    }

    return (ret);
}

int
proc_set_cpumon_defaults(pid_t pid)
{
    proc_policy_cpuusage_attr_t attr;

    attr.ppattr_cpu_attr = PROC_POLICY_RSRCACT_NOTIFY_EXC;
    attr.ppattr_cpu_percentage = PROC_POLICY_CPUMON_DEFAULTS;
    attr.ppattr_cpu_attr_interval = 0;
    attr.ppattr_cpu_attr_deadline = 0;

    return(__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_SET, PROC_POLICY_RESOURCE_USAGE,
        PROC_POLICY_RUSAGE_CPU, (proc_policy_attribute_t*)&attr, pid, 0));
}

int
proc_disable_cpumon(pid_t pid)
{
    proc_policy_cpuusage_attr_t attr;

    attr.ppattr_cpu_attr = PROC_POLICY_RSRCACT_NOTIFY_EXC;
    attr.ppattr_cpu_percentage = PROC_POLICY_CPUMON_DISABLE;
    attr.ppattr_cpu_attr_interval = 0;
    attr.ppattr_cpu_attr_deadline = 0;

    return(__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_SET, PROC_POLICY_RESOURCE_USAGE,
        PROC_POLICY_RUSAGE_CPU, (proc_policy_attribute_t*)&attr, pid, 0));
}


/*
 * Turn on the CPU usage monitor using the supplied parameters, and make
 * violations of the monitor fatal.
 *
 * Returns:  0 on success;
 *        -1 on failure and sets errno
 */
int
proc_set_cpumon_params_fatal(pid_t pid, int percentage, int interval)
{
    int current_percentage = 0;
    int current_interval = 0;   /* intervals are in seconds */
    int ret = 0;

    if ((percentage <= 0)  || (interval <= 0)) {
        errno = EINVAL;
        return (-1);
    }

    /*
     * Do a simple query to see if CPU monitoring is
     * already active.  If either the percentage or the
     * interval is nonzero, then CPU monitoring is
     * already in use for this process.
     */
    (void)proc_get_cpumon_params(pid, &current_percentage, &current_interval);
    if (current_percentage || current_interval)
    {
        /*
         * The CPU monitor appears to be active.
         * We choose not to disturb those settings.
         */
        errno = EBUSY;
        return (-1);
    }
    
    if ((ret = proc_set_cpumon_params(pid, percentage, interval)) != 0) {
        /* Failed to activate the CPU monitor */
        return (ret);
    }
    
    if ((ret = proc_rlimit_control(pid, RLIMIT_CPU_USAGE_MONITOR, CPUMON_MAKE_FATAL)) != 0) {
        /* Failed to set termination, back out the CPU monitor settings. */
        (void)proc_disable_cpumon(pid);
    }

    return (ret);
}

int
proc_set_wakemon_params(pid_t pid, int rate_hz, int flags __unused)
{
    struct proc_rlimit_control_wakeupmon params;

    params.wm_flags = WAKEMON_ENABLE;
    params.wm_rate = rate_hz;

    return (proc_rlimit_control(pid, RLIMIT_WAKEUPS_MONITOR, &params));
}

#ifndef WAKEMON_GET_PARAMS
#define WAKEMON_GET_PARAMS 0x4
#define WAKEMON_SET_DEFAULTS 0x8
#endif

int
proc_get_wakemon_params(pid_t pid, int *rate_hz, int *flags)
{
    struct proc_rlimit_control_wakeupmon params;
    int error;

    params.wm_flags = WAKEMON_GET_PARAMS;

    if ((error = proc_rlimit_control(pid, RLIMIT_WAKEUPS_MONITOR, &params)) != 0) {
        return (error);
    }

    *rate_hz = params.wm_rate;
    *flags = params.wm_flags;

    return (0);
}

int
proc_set_wakemon_defaults(pid_t pid)
{
    struct proc_rlimit_control_wakeupmon params;

    params.wm_flags = WAKEMON_ENABLE | WAKEMON_SET_DEFAULTS;
    params.wm_rate = -1;

    return (proc_rlimit_control(pid, RLIMIT_WAKEUPS_MONITOR, &params));
}

int
proc_disable_wakemon(pid_t pid)
{
    struct proc_rlimit_control_wakeupmon params;

    params.wm_flags = WAKEMON_DISABLE;
    params.wm_rate = -1;

    return (proc_rlimit_control(pid, RLIMIT_WAKEUPS_MONITOR, &params));
}




/* Donate importance to adaptive processes from this process */
int
proc_donate_importance_boost()
{
    int rval;

    rval = __process_policy(PROC_POLICY_SCOPE_PROCESS,
                            PROC_POLICY_ACTION_SET,
                            PROC_POLICY_BOOST,
                            PROC_POLICY_IMP_DONATION,
                            NULL, getpid(), 0);

    if (rval == 0)
        return (0);
    else
        return (errno);
}

static __attribute__((noinline)) void
proc_importance_bad_assertion(char *reason) {
    (void)reason;
}

/*
 * Use the address of these variables as the token.  This way, they can be
 * printed in the debugger as useful names.
 */
uint64_t important_boost_assertion_token = 0xfafafafafafafafa;
uint64_t normal_boost_assertion_token    = 0xfbfbfbfbfbfbfbfb;
uint64_t non_boost_assertion_token       = 0xfcfcfcfcfcfcfcfc;
uint64_t denap_boost_assertion_token     = 0xfdfdfdfdfdfdfdfd;

/*
 * Accept the boost on a message, or request another boost assertion
 * if we have already accepted the implicit boost for this message.
 *
 * Returns EOVERFLOW if an attempt is made to take an extra assertion when not boosted.
 *
 * Returns EIO if the message was not a boosting message.
 * TODO: Return a 'non-boost' token instead.
 */
int
proc_importance_assertion_begin_with_msg(mach_msg_header_t  *msg,
                                __unused mach_msg_trailer_t *trailer,
                                         uint64_t           *assertion_token)
{
    int rval = 0;

    if (assertion_token == NULL)
        return (EINVAL);

#define LEGACYBOOSTMASK (MACH_MSGH_BITS_VOUCHER_MASK | MACH_MSGH_BITS_RAISEIMP)
#define LEGACYBOOSTED(m) (((m)->msgh_bits & LEGACYBOOSTMASK) == MACH_MSGH_BITS_RAISEIMP)

    /* Is this a legacy boosted message? */
    if (LEGACYBOOSTED(msg)) {

        /*
         * Have we accepted the implicit boost for this message yet?
         * If we haven't accepted it yet, no need to call into kernel.
         */
        if ((msg->msgh_bits & MACH_MSGH_BITS_IMPHOLDASRT) == 0) {
            msg->msgh_bits |= MACH_MSGH_BITS_IMPHOLDASRT;
            *assertion_token = (uint64_t) &important_boost_assertion_token;
            return (0);
        }

        /* Request an additional boost count */
        rval = __process_policy(PROC_POLICY_SCOPE_PROCESS,
                                PROC_POLICY_ACTION_HOLD,
                                PROC_POLICY_BOOST,
                                PROC_POLICY_IMP_IMPORTANT,
                                NULL, getpid(), 0);
        if (rval == 0) {
            *assertion_token = (uint64_t) &important_boost_assertion_token;
            return (0);
        } else if (errno == EOVERFLOW) {
            proc_importance_bad_assertion("Attempted to take assertion while not boosted");
            return (errno);
        } else {
            return (errno);
        }
    }
    
    return (EIO);
}


/*
 * Drop a boost assertion.
 * Returns EOVERFLOW on boost assertion underflow.
 */
int
proc_importance_assertion_complete(uint64_t assertion_token)
{
    int rval = 0;

    if (assertion_token == 0)
        return (0);

    if (assertion_token == (uint64_t) &important_boost_assertion_token) {
        rval = __process_policy(PROC_POLICY_SCOPE_PROCESS,
                                PROC_POLICY_ACTION_DROP,
                                PROC_POLICY_BOOST,
                                PROC_POLICY_IMP_IMPORTANT,
                                NULL, getpid(), 0);
        if (rval == 0) {
            return (0);
        } else if (errno == EOVERFLOW) {
            proc_importance_bad_assertion("Attempted to drop too many assertions");
            return (errno);
        } else {
            return (errno);
        }
    } else {
        proc_importance_bad_assertion("Attempted to drop assertion with invalid token");
        return (EIO);
    }
}

/*
 * Accept the De-Nap boost on a message, or request another boost assertion
 * if we have already accepted the implicit boost for this message.
 *
 * Interface is deprecated before it really got started - just as synonym
 * for proc_importance_assertion_begin_with_msg() now.
 */
int
proc_denap_assertion_begin_with_msg(mach_msg_header_t  *msg,
                    uint64_t           *assertion_token)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return proc_importance_assertion_begin_with_msg(msg, NULL, assertion_token);
#pragma clang diagnostic pop
}


/*
 * Drop a denap boost assertion.
 *
 * Interface is deprecated before it really got started - just a synonym
 * for proc_importance_assertion_complete() now.
 */
int
proc_denap_assertion_complete(uint64_t assertion_token)
{
    return proc_importance_assertion_complete(assertion_token);
}


int
proc_clear_vmpressure(pid_t pid)
{
    if (__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_RESTORE, PROC_POLICY_RESOURCE_STARVATION, PROC_POLICY_RS_VIRTUALMEM, NULL, pid, (uint64_t)0) != -1)
        return(0);
    else
        return(errno);
}

/* set the current process as one who can resume suspended processes due to low virtual memory. Need to be root */
int
proc_set_owner_vmpressure(void)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_SETCONTROL, getpid(), PROC_SELFSET_VMRSRCOWNER, (uint64_t)0, NULL, 0)) == -1)
        return(errno);
        
    return(0);
}

/* mark yourself to delay idle sleep on disk IO */
int
proc_set_delayidlesleep(void)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_SETCONTROL, getpid(), PROC_SELFSET_DELAYIDLESLEEP, (uint64_t)1, NULL, 0)) == -1)
        return(errno);

    return(0);
}

/* Reset yourself to delay idle sleep on disk IO, if already set */
int
proc_clear_delayidlesleep(void)
{
    int retval;

    if ((retval = __proc_info(PROC_INFO_CALL_SETCONTROL, getpid(), PROC_SELFSET_DELAYIDLESLEEP, (uint64_t)0, NULL, 0)) == -1)
        return(errno);

    return(0);
}

/* disable the launch time backgroudn policy and restore the process to default group */
int
proc_disable_apptype(pid_t pid, int apptype)
{
    switch (apptype) {
        case PROC_POLICY_OSX_APPTYPE_TAL:
        case PROC_POLICY_OSX_APPTYPE_DASHCLIENT:
            break;
        default:
            return(EINVAL);
    }

    if (__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_DISABLE, PROC_POLICY_APPTYPE, apptype, NULL, pid, (uint64_t)0) != -1)
        return(0);
    else
        return(errno);

}

/* re-enable the launch time background policy if it had been disabled. */
int
proc_enable_apptype(pid_t pid, int apptype)
{
    switch (apptype) {
        case PROC_POLICY_OSX_APPTYPE_TAL:
        case PROC_POLICY_OSX_APPTYPE_DASHCLIENT:
            break;
        default:
            return(EINVAL);

    }

    if (__process_policy(PROC_POLICY_SCOPE_PROCESS, PROC_POLICY_ACTION_ENABLE, PROC_POLICY_APPTYPE, apptype, NULL, pid, (uint64_t)0) != -1)
        return(0);
    else
        return(errno);
 
}

#if !TARGET_IPHONE_SIMULATOR

int
proc_suppress(__unused pid_t pid, __unused uint64_t *generation)
{
    return 0;
}

#endif /* !TARGET_IPHONE_SIMULATOR */



