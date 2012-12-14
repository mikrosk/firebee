/*
 * sd_card.h
 *
 * Exported sd-card access routines for the FireBee BaS
 *
 *  Created on: 19.11.2012
 *      Author: mfro
 *
 * This file is part of BaS_gcc.
 *
 * BaS_gcc is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BaS_gcc is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with BaS_gcc.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2010 - 2012 F. Aschwanden
 * Copyright 2011 - 2012 V. Riviere
 * Copyright 2012        M. Froeschle
 *
 */

#ifndef _SD_CARD_H_
#define _SD_CARD_H_

#include <MCF5475.h>
#include <stdint.h>

extern int spi_init(void);
extern uint32_t sd_com(uint32_t data);
extern void sd_card_idle(void);
extern uint8_t sd_card_get_status(void);
extern uint8_t spi_send_byte(uint8_t byte);
extern uint16_t spi_send_word(uint16_t word);

/* MMC card type flags (MMC_GET_TYPE) */
#define CT_MMC		0x01		/* MMC ver 3 */
#define CT_SD1		0x02		/* SD ver 1 */
#define CT_SD2		0x04		/* SD ver 2 */
#define CT_SDC		(CT_SD1|CT_SD2)	/* SD */
#define CT_BLOCK	0x08		/* Block addressing */

#endif /* _SD_CARD_H_ */
