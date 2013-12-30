/****************************************************************************
*
*						Realmode X86 Emulator Library
*
*            	Copyright (C) 1996-1999 SciTech Software, Inc.
* 				     Copyright (C) David Mosberger-Tang
* 					   Copyright (C) 1999 Egbert Eich
*
*  ========================================================================
*
*  Permission to use, copy, modify, distribute, and sell this software and
*  its documentation for any purpose is hereby granted without fee,
*  provided that the above copyright notice appear in all copies and that
*  both that copyright notice and this permission notice appear in
*  supporting documentation, and that the name of the authors not be used
*  in advertising or publicity pertaining to distribution of the software
*  without specific, written prior permission.  The authors makes no
*  representations about the suitability of this software for any purpose.
*  It is provided "as is" without express or implied warranty.
*
*  THE AUTHORS DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
*  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
*  EVENT SHALL THE AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
*  CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
*  USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
*  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
*  PERFORMANCE OF THIS SOFTWARE.
*
*  ========================================================================
*
* Language:		ANSI C
* Environment:	Any
* Developer:    Kendall Bennett
*
* Description:  Header file for system specific functions. These functions
*				are always compiled and linked in the OS depedent libraries,
*				and never in a binary portable driver.
*
****************************************************************************/

/* $XFree86: xc/extras/x86emu/src/x86emu/x86emu/x86emui.h,v 1.4 2001/04/01 13:59:58 tsi Exp $ */

#ifndef __X86EMU_X86EMUI_H
#define __X86EMU_X86EMUI_H

/*
 * If we are compiling in C++ mode, we can compile some functions as
 * inline to increase performance (however the code size increases quite
 * dramatically in this case).
 */

#if	defined(__cplusplus) && !defined(_NO_INLINE)
#define	_INLINE	inline
#else
#define	_INLINE static
#endif

/* Get rid of unused parameters in C++ compilation mode */

#ifdef __cplusplus
#define	X86EMU_UNUSED(v)
#else
#define	X86EMU_UNUSED(v)	v
#endif

#include "radeonfb.h"

#ifdef DEBUG_X86EMU
#define DEBUG  /* => see also sys.c */
#else
#undef DEBUG
#endif

#include "x86emu.h"
#include "x86regs.h"
#include "x86decode.h"
#include "x86ops.h"
#include "x86prim_ops.h"
#include "x86fpu.h"

/*--------------------------- Inline Functions ----------------------------*/

#ifdef  __cplusplus
extern "C" {            			/* Use "C" linkage when in C++ mode */
#endif

extern uint8_t  	(X86APIP sys_rdb)(uint32_t addr);
extern uint16_t 	(X86APIP sys_rdw)(uint32_t addr);
extern uint32_t 	(X86APIP sys_rdl)(uint32_t addr);
extern void (X86APIP sys_wrb)(uint32_t addr,uint8_t val);
extern void (X86APIP sys_wrw)(uint32_t addr,uint16_t val);
extern void (X86APIP sys_wrl)(uint32_t addr,uint32_t val);

extern uint8_t  	(X86APIP sys_inb)(X86EMU_pioAddr addr);
extern uint16_t 	(X86APIP sys_inw)(X86EMU_pioAddr addr);
extern uint32_t 	(X86APIP sys_inl)(X86EMU_pioAddr addr);
extern void (X86APIP sys_outb)(X86EMU_pioAddr addr,uint8_t val);
extern void (X86APIP sys_outw)(X86EMU_pioAddr addr,uint16_t val);
extern void	(X86APIP sys_outl)(X86EMU_pioAddr addr,uint32_t val);

#ifdef  __cplusplus
}                       			/* End of "C" linkage for C++   	*/
#endif

#endif /* __X86EMU_X86EMUI_H */