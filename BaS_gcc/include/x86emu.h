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
 * Description:  Header file for public specific functions.
 *               Any application linking against us should only
 *               include this header
 *
 ****************************************************************************/
/* $XFree86: xc/extras/x86emu/include/x86emu.h,v 1.2 2000/11/21 23:10:25 tsi Exp $ */

#ifndef __X86EMU_X86EMU_H
#define __X86EMU_X86EMU_H

#include "bas_types.h"
#define	X86API
#define	X86APIP	*
#include "x86regs.h"

typedef uint16_t X86EMU_pioAddr;

/*---------------------- Macros and type definitions ----------------------*/

//#pragma	pack(1)

/****************************************************************************
REMARKS:
Data structure containing ponters to programmed I/O functions used by the
emulator. This is used so that the user program can hook all programmed
I/O for the emulator to handled as necessary by the user program. By
default the emulator contains simple functions that do not do access the
hardware in any way. To allow the emualtor access the hardware, you will
need to override the programmed I/O functions using the X86EMU_setupPioFuncs
function.

HEADER:
x86emu.h

MEMBERS:
inb		- Function to read a byte from an I/O port
inw		- Function to read a word from an I/O port
inl     - Function to read a dword from an I/O port
outb	- Function to write a byte to an I/O port
outw    - Function to write a word to an I/O port
outl    - Function to write a dword to an I/O port
 ****************************************************************************/
typedef struct
{
	uint8_t  	(X86APIP inb)(X86EMU_pioAddr addr);
	uint16_t 	(X86APIP inw)(X86EMU_pioAddr addr);
	uint32_t 	(X86APIP inl)(X86EMU_pioAddr addr);
	void 	(X86APIP outb)(X86EMU_pioAddr addr, uint8_t val);
	void 	(X86APIP outw)(X86EMU_pioAddr addr, uint16_t val);
	void 	(X86APIP outl)(X86EMU_pioAddr addr, uint32_t val);
} X86EMU_pioFuncs;

/****************************************************************************
REMARKS:
Data structure containing ponters to memory access functions used by the
emulator. This is used so that the user program can hook all memory
access functions as necessary for the emulator. By default the emulator
contains simple functions that only access the internal memory of the
emulator. If you need specialised functions to handle access to different
types of memory (ie: hardware framebuffer accesses and BIOS memory access
etc), you will need to override this using the X86EMU_setupMemFuncs
function.

HEADER:
x86emu.h

MEMBERS:
rdb		- Function to read a byte from an address
rdw		- Function to read a word from an address
rdl     - Function to read a dword from an address
wrb		- Function to write a byte to an address
wrw    	- Function to write a word to an address
wrl    	- Function to write a dword to an address
 ****************************************************************************/
typedef struct {
	uint8_t  	(X86APIP rdb)(uint32_t addr);
	uint16_t 	(X86APIP rdw)(uint32_t addr);
	uint32_t 	(X86APIP rdl)(uint32_t addr);
	void 	(X86APIP wrb)(uint32_t addr, uint8_t val);
	void 	(X86APIP wrw)(uint32_t addr, uint16_t val);
	void	(X86APIP wrl)(uint32_t addr, uint32_t val);
} X86EMU_memFuncs;

/****************************************************************************
  Here are the default memory read and write
  function in case they are needed as fallbacks.
 ***************************************************************************/
extern uint8_t X86API rdb(uint32_t addr);
extern uint16_t X86API rdw(uint32_t addr);
extern uint32_t X86API rdl(uint32_t addr);
extern void X86API wrb(uint32_t addr, uint8_t val);
extern void X86API wrw(uint32_t addr, uint16_t val);
extern void X86API wrl(uint32_t addr, uint32_t val);

//#pragma	pack()

/*--------------------- type definitions -----------------------------------*/

typedef void (X86APIP X86EMU_intrFuncs)(int num);
extern X86EMU_intrFuncs _X86EMU_intrTab[256];

/*-------------------------- Function Prototypes --------------------------*/

#ifdef  __cplusplus
extern "C" {            			/* Use "C" linkage when in C++ mode */
#endif

	void 	X86EMU_setupMemFuncs(X86EMU_memFuncs *funcs);
	void 	X86EMU_setupPioFuncs(X86EMU_pioFuncs *funcs);
	void 	X86EMU_setupIntrFuncs(X86EMU_intrFuncs funcs[]);
	void 	X86EMU_prepareForInt(int num);

	/* decode.c */

	void 	X86EMU_exec(void);
	void 	X86EMU_halt_sys(void);

#ifdef	DEBUG
#define	HALT_SYS() \
	DPRINT("halt_sys: file "); \
	DPRINT(__FILE__); \
	DPRINTVAL(", line ", __LINE__);	\
	DPRINT("\r\n"); \
	X86EMU_halt_sys();
#else
#define	HALT_SYS()	X86EMU_halt_sys()
#endif

	/* Debug options */

#define DEBUG_DECODE_F          0x000001 /* print decoded instruction  */
#define DEBUG_TRACE_F           0x000002 /* dump regs before/after execution */
#define DEBUG_STEP_F            0x000004
#define DEBUG_DISASSEMBLE_F     0x000008
#define DEBUG_BREAK_F           0x000010
#define DEBUG_SVC_F             0x000020
#define DEBUG_FS_F              0x000080
#define DEBUG_PROC_F            0x000100
#define DEBUG_SYSINT_F          0x000200 /* bios system interrupts. */
#define DEBUG_TRACECALL_F       0x000400
#define DEBUG_INSTRUMENT_F      0x000800
#define DEBUG_MEM_TRACE_F       0x001000 
#define DEBUG_IO_TRACE_F        0x002000 
#define DEBUG_TRACECALL_REGS_F  0x004000
#define DEBUG_DECODE_NOPRINT_F  0x008000 
#define DEBUG_SAVE_IP_CS_F      0x010000
#define DEBUG_SYS_F             (DEBUG_SVC_F|DEBUG_FS_F|DEBUG_PROC_F)

	void 	X86EMU_trace_regs(void);
	void 	X86EMU_trace_xregs(void);
	void 	X86EMU_dump_memory(uint16_t seg, uint16_t off, uint32_t amt);
	int 	X86EMU_trace_on(void);
	int 	X86EMU_trace_off(void);
	int		X86EMU_set_debug(int debug);
	void	X86EMU_setMemBase(void *base, unsigned long size);

#ifdef  __cplusplus
}                       			/* End of "C" linkage for C++   	*/
#endif

#endif /* __X86EMU_X86EMU_H */
