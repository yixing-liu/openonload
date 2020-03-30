/**************************************************************************/
/*!  \file  efx_linux_types.h
** \author  bwh
**  \brief  Wrapper for <linux/types.h>
**   \date  2008/12/11
**    \cop  Copyright 2008 Solarflare Communications Inc.
*//************************************************************************/

#ifndef EFX_LINUX_TYPES_H
#define EFX_LINUX_TYPES_H

#include <linux/types.h>
#include <linux/version.h>

/* Although we don't support kernel versions before 2.6.9, the kernel
 * headers for userland may come from a rather older version (as they
 * do in RHEL 4).
 */
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,9)
typedef __u16 __be16;
typedef __u32 __be32;
typedef __u64 __be64;
#endif

/* Prior to Linux 2.6.18, some kernel headers wrongly used the
 * in-kernel type names for user API.  Also, sfctool really wants
 * these names.
 */
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18) || \
  defined(EFX_WANT_KERNEL_TYPES)
typedef __u8 u8;
typedef __u16 u16;
typedef __u32 u32;
typedef __s32 s32;
typedef __u64 u64;
#endif

/* Empty define of __user, for use in struct efx_sfctool */
#define __user

#ifndef noinline_for_stack
#define noinline_for_stack noinline
#endif

#endif /* !EFX_LINUX_TYPES_H */
