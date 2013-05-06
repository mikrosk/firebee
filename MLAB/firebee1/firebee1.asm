;**********************************************************
;*  firebee1 PIC18F4321 MAIN FILE
;**********************************************************
;*  CREATED BY FREDI ASCHWANDEN
;*  DATE 22.9.2009
;**********************************************************
	list PE=18f4520				;EXTENDED INSTRUCTION SET
	include "P18f4520.inc"
;------------------------ Equates --------------------------;
;Register addresses
;BANK 0
SECS           		equ    	0x00
SECS_ALARM			EQU		0x01
MINS         		equ    	0x02
MINS_ALRAM			EQU		0x03
HOURS           	equ    	0x04
HOURS_ALARM			EQU		0x05
DAY_OF_WEEK			EQU		0x06
DAYS				EQU		0x07
MONTHS				EQU		0x08
YEARS				EQU		0x09		;offset vom 1968
REGA				EQU		0x0A
REGB				EQU		0x0B
REGC				EQU		0x0C
REGD				EQU		0x0D
RTC_RAM				EQU		0x0E		; bis 0x3F
free				equ		0x40
TICKS           	equ    	0x41		;125MS
TASTE_ON_TIME		EQU		0x42
TASTE_OFF_TIME		EQU		0x43
POWER_ON_TIME		EQU		0x44
AD_KANAL			EQU		0x45
U_ERR				EQU		0x46		;SPANNUNGSFEHLER WENN BIT 0=1, BIT1=1 WARTEN AUF GELADEN
U_ERR_TIME			EQU		0x47		;ZEIT SEIT SPANNUNGSFEHLER
U_POWER_IN			EQU		0x48		;SPANNUNG POWER IN 1V CA. 6E
RX_B				EQU		0x49		;RECEIVED BYT
RX_STATUS			EQU		0x4A		;STATUS: 0x00=WAIT AUF MCF COMMANDO, 0x82=EMPFANGE 64BYT FROM RTC
TX_STATUS			EQU		0x4B		;STATUS: 0x00=WAIT 0x81=SENDE 64BYT FROM RTC
GO_SUB				EQU		0x4C		;WENN GLEICH 0xFB DANN SUBROUTINE AUSF�HREN
GO_INT				EQU		0x4D		;WENN GLEICH 0xFB DANN SUBROUTINE AUSF�HREN
EAPIR1				EQU		0x4E		;INTERRUPT ACTIV UND ENABLE
EAPIR2				EQU		0x4F		;INTERRUPT ACTIV UND ENABLE
;BANK 1 AB 0x100
RX_BUFFER			EQU		0x100		;0x80 BYT BUFFER BIS 0x17F BANK
TX_BUFFER			EQU		0x180		;0X80 BYT BUFFER BIS 0x1FF BANK

;--------------------------------------------------------------
SEND_RTC_TIME		EQU		.2			;0.25 SEC (EINHEIT IST EIN TICK = 128MS
RESET_ON_TIME		EQU		.2			;0.25 SEC (EINHEIT IST EIN TICK = 128MS
RESET_OFF_TIME		EQU		.4			;0.5 SEC (EINHEIT IST EIN TICK = 128MS
OFF_TIME			EQU		.20			;2.5 SEC (EINHEIT IST EIN TICK = 128MS
ON_TIME				EQU		.2			;0.25 SEC (EINHEIT IST EIN TICK = 128MS
TIMER_HB			EQU		.240		;256- (32768Hz PRO 1/8SEC = 4096TICKS/256) => 256-16=240 (resp 256-16/4 (wenn osco) = 252)
TIME_MAX			EQU		.160		;MAXIMALTIME
U_ERR_PW_AUS		EQU		.40			;5 SEC
;SERIEL
SYNC1				EQU		0FFh
SYNC1_DATA			EQU		'A';
SYNC2				EQU		0FEh
SYNC2_DATA			EQU		'C';
SYNC3				EQU		0FDh	
SYNC3_DATA			EQU		'P';
SYNC4				EQU		0FCh
SYNC4_DATA			EQU		'F';
REQ_RTCD_FROM_PIC	EQU		01h			;RTC AND NVRAM DATEN VOM PIC ANFORDERN
RTCD_FROM_PIC		EQU		81h			;RTC AND NVRAM DATEN HEADER UND STATUS
REQ_RTCD_FROM_MCF	EQU		02h			;RTC AND NVRAM DATEN VOM MCF ANFORDERN
RTCD_FROM_MCF		EQU		82h			;RTC AND NVRAM DATEN HEADER UND STATUS
U_MIN_TO_MCF		EQU		03h			;UNTERSPANNUNGSMITTEILUNG AN PROCESSOR
EXT_SUB_GO			EQU		04h			;SERIELL CODE UM SUBROUTINEN/INTERRUPTS ZU AKTIVIEREN
EXT_SUB_STOP		EQU		05h			;SERIELL CODE UM SUBROUTINEN/INTERRUPTS ZU STOPPEN
CMD_FROM_MCF		EQU		0Ch			;3 BYT COMMANDOS FROM MCF = TOTAL 4 BYT
CLK_SLEEP	   		EQU		B'00010010'		;125kHz intern, SLEEP MODE
CLK_ACTIV	   		EQU		B'01110010'		;inTernal CLK=8MHz, SLEEP MODE, SLEEP MODE
EXT_CODE			EQU		0xFB		;CODE F�R EXTERNE SUBROUTINEN/INTERRUPTS AUSF�HREN (FireBee!)
EXTERN_INT_ADR		EQU		0x2000		;HIER MUSS 0xFB STEHEN WENN EXTERNE INTERRUPTS AUSF�HRBAR
EXTERN_INTERRUPTS	EQU		0x2002		;STARTPUNKT EXTERNE SUBROUTINES
EXTERN_SUB_ADR		EQU		0x2010		;HIER MUSS 0xFB STEHEN WENN EXTERNE SUBROUTINES AUSF�HRBAR
EXTERN_SUBROUTINES	EQU		0x2012		;STARTPUNKT EXTERNE SUBROUTINES
REQ_BLOCK			EQU		0xA0		;BLOCK DATEN LESEN -> CODE UND 3 BYTS ADRESSE = TOTAL 4 BYTES
READ_BLOCK			EQU		0xA1		;PROGRAMM BLOCK PIC->MCF -> CODE, 3 BYTS ADRESSE UND 64 BYTS DATEN = TOTAL 68 BYTES
WRITE_BLOCK			EQU		0xA2		;PROGRAMM BLOCK MCF->PIC -> CODE, 3 BYTS ADRESSE UND 64 BYTS DATEN UND 1 BYT CHECKSUM = TOTAL 69 BYTES
PRG_OK				EQU		0x00		;PROGRAMMIERUNG BLOCK FERTIG
CHECKSUM_ERROR		EQU		0xFE
;**********************************************************************************************"""""""""""""
; Start at the reset vector
Reset_Vector code 0x000 
	BRA 	KALT_START
;--------------------------------------------------------------
HIGH_INT_VEC code 	0x0008
 	GOTO	0x18
	
LOW_INT_VEC	code 	0x0018
INT_HANDLER
	CLRF	BSR					;IMMER ACCESS BANK
;SETZEN GRUPPE 1
	MOVFF	PIE1,EAPIR1			;INTERRUPTS HOLEN
	MOVF	PIR1,0				;MASKE
	ANDWF	EAPIR1				;ACTIVE SETZEN
	BTFSC	EAPIR1,TMR1IF 		;uhr interrupt?
	BRA		RTC_ISR				;ja->
	BTFSC	EAPIR1,ADIF			;AD INTERRUTP?
	BRA		AD_ISR				;JA->
 	BTFSC	EAPIR1,TXIF			;seriell TX?
 	BRA		TX_ISR				;JA->
 	BTFSC	EAPIR1,RCIF			;seriell RX?
 	BRA		RX_ISR				;JA->

;SETZEN GRUPPE 2
	MOVFF	PIE2,EAPIR2			;INTERRUPTS HOLEN
	MOVF	PIR2,0				;MASKE
	ANDWF	EAPIR2				;ACTIVE SETZEN

 	BTFSC	EAPIR2,HLVDIF		;UNDER/OVERVOLTAGE DETECT
 	BRA		HLVD_ISR			;JA->
	RETFIE

;TESTEN UND SETZEN GRUPPE 1
	MOVFF	PIE1,EAPIR1			;INTERRUPTS HOLEN
	MOVF	PIR1,0				;MASKE
	ANDWF	EAPIR1				;ACTIVE SETZEN
	TSTFSZ	EAPIR1
	BRA		INT_HANDLER
;TESTEN UND SETZEN GRUPPE 2
	MOVFF	PIE2,EAPIR2			;INTERRUPTS HOLEN
	MOVF	PIR2,0				;MASKE
	ANDWF	EAPIR2				;ACTIVE SETZEN
	TSTFSZ	EAPIR2
	BRA		INT_HANDLER

	MOVLW	EXT_CODE			;GO EXTERNE SUBROUTINEN AKTIV?
	CPFSEQ	GO_INT				;SKIP WENN JA
	RETFIE
	GOTO	EXTERN_INTERRUPTS	;REGISTER SICHERN UND STARTEN

;BLOCK PROGRAMMIEREN **********************************************************************************************"""""""""""""
PB	CODE 	0x0080
PROGRAMM_BLOCK 
	LFSR	1,RX_BUFFER			;BYT COUNTER AUF RX BUFFER
	MOVFF 	POSTINC1,TBLPTRU	;TABLE POINTER SETZEN
	MOVFF 	POSTINC1,TBLPTRH	;TABLE POINTER SETZEN
	MOVFF 	POSTINC1,TBLPTRL	;TABLE POINTER SETZEN 
;EREASE BLOCK
	BCF		INTCON,GIE			; DISABLE INTTERUPT
	BSF 	EECON1,EEPGD	 	; point to Flash program memory
	BCF		EECON1,CFGS 		; access Flash program memory
	BSF 	EECON1,WREN	 		; enable write to memory
	BSF 	EECON1,FREE 		; enable Row Erase operation
	MOVLW 	55h
	MOVWF 	EECON2 				; write 55h
	MOVLW 	0AAh				; write 0AAh
	MOVWF 	EECON2 
	BSF 	EECON1,WR 			; start erase (CPU stall)
	BSF		INTCON,GIE			; ENABLE INTERRUPT
	TBLRD*-						; POINTER DUMMY DECREMENT
; BLOCK WRITE 1.H�LFTE
	MOVLW	23h					; 67 BYT 3 BYT ADR + 64 BYT DATEN 
WRITE_WORD_TO_HREG1
	MOVFF 	POSTINC1,TABLAT		; get byte of buffer data
	TBLWT+* 					; write data, perform a short write to internal TBLWT holding register.
	CPFSEQ	FSR1L				; SCHON BEI 32 BYTES?
	BRA 	WRITE_WORD_TO_HREG1	;NEIN->LOOP
; PROGRAMM BLOCK
	BSF 	EECON1,EEPGD 		; point to Flash program memory
	BCF 	EECON1,CFGS 		; access Flash program memory
	BSF 	EECON1,WREN 		; enable write to memory
	BCF		INTCON,GIE			; DISABLE INTTERUPT
	MOVLW 	55h
	MOVWF 	EECON2 				; write 55h
	MOVLW 	0AAh
	MOVWF 	EECON2 				; write 0AAh
	BSF 	EECON1,WR 			; start program (CPU stall)
	BCF 	EECON1,WREN 		; disable write to memory
; BLOCK WRITE 2. H�LFTE
	MOVLW	43h					; 67 BYT 3 BYT ADR + 64 BYT DATEN 
WRITE_WORD_TO_HREG2
	MOVFF 	POSTINC1,TABLAT		; get byte of buffer data
	TBLWT+* 					; write data, perform a short write to internal TBLWT holding register.
	CPFSEQ	FSR1L				; SCHON BEI 64 BYTES?
	BRA 	WRITE_WORD_TO_HREG2	;NEIN->LOOP
; PROGRAMM BLOCK
	BSF 	EECON1,EEPGD 		; point to Flash program memory
	BCF 	EECON1,CFGS 		; access Flash program memory
	BSF 	EECON1,WREN 		; enable write to memory
	MOVLW 	55h
	MOVWF 	EECON2 				; write 55h
	MOVLW 	0AAh
	MOVWF 	EECON2 				; write 0AAh
	BSF 	EECON1,WR 			; start program (CPU stall)
	BCF 	EECON1,WREN 		; disable write to memory
	BSF		INTCON,GIE			; ENABLE INTERRUPT
	MOVLW	PRG_OK				; OK senden
	MOVWF	TXREG
	CLRF	RX_STATUS			; FERTIG
	RETFIE
;**********************************************************************************************"""""""""""""
	; Start application beyond vector area
STD	CODE	0x0100
KALT_START
;RESET MODE
	CLRF	BSR					;BANK 0
;ALLE INT AUS UND R�CKSETZEN
	CLRF	INTCON				;alle INTERRUPT AUS
	CLRF	RCON				;INT PRIORITY AUS
	CLRF	PIE1				;MASK DISABLE
	CLRF	PIE2
	CLRF	PIR1				;INT ACT AUS
	CLRF	PIR2
	CLRF	IPR1				;LOW PRIORITY
	CLRF	IPR2
	; clock 
; 	MOVLW	B'01000000'			;32MHZ
; 	MOVWF	OSCTUNE
	CLRF	OSCTUNE
;CLOCK
   	MOVLW	CLK_ACTIV
   	MOVWF	OSCCON
	; div init
;SET PORT A: **7:#master/0.409*5V0 **6:PIC_AMKB_RX **5:PIC_SWTICH **4:HIGH_CHARGE_CURRENT **3:2V5 *2:3V3/2 **1:1V25 **0:POWER_IN/11
	MOVLW	B'01000000'			;RA6 auf high 
	MOVWF	PORTA				;#master(7)=0, REST=0
	MOVLW	B'11111111'			;alles auf Input  
	MOVWF	TRISA
;SET PORT B: **7:PGD **6:PGC **5:PGM **4:PIN_INT,1V5 **3:GAME PORT PIN10 **2:GAME PORT PIN11 **1:GAME PORT PIN6 **0: GAME PORT PIN5
	CLRF	PORTB				;ALLES AUF 0
	MOVWF	TRISB
;SET PORT C: **7: PIC_RX **6:PIC_TX **5:AMKB_TX **4:GAME PORT PIN4 **3:GAME PORT PIN12 **2:GAME PORT PIN13 **1+0: OCS 32K768Hz
	CLRF	PORTC
	MOVWF	TRISC
;SET PORT D: **7:#RSTI **6:GAME PORT PIN3 **5:PS2 KB CLK **4:PS2 MS CLK **3:PS2 KB DATA **2:MS DATA **1:TASTER **0:POWER ON/OFF (0=ON)
; SET TASTE UND POWER
	CLRF	PORTD				;ALLES AUF 0
	MOVWF	TRISD				;ALLES AUF INPUT
;SET PORT E: **3:#MCLR **2:#PCI_RESET **1:PCI 3V3 **0:PIC LED (0=ON)
	CLRF	PORTE				;ALLES AUF 0
	MOVLW	B'00000111'			;tri: PCI RESET; PCI3V3; LED
	MOVWF	TRISE				;direction setzen
;--------------------------
;  set OVERvoltage detekt 
	MOVLW	B'10011011'			;INT WENN �BER 3.9V
	MOVWF	HLVDCON	
	MOVLW	B'00000011'			;ERRORS ON, WAIT AUF LADEN
	MOVWF	U_ERR
	MOVLW	.20					;SEIT 20SEC ERROR 			 
	MOVWF	U_ERR_TIME			;SETZEN
 	BSF 	PIE2,HLVDIE 		;Enable interrupt
;INTIALISIERUNGSPROGAMME
	CALL	LADESTROM			;LADESTROM EINSTELLEN
;UHR initialisieren
	MOVLW 	TIMER_HB			;Preload TMR1 register 
	MOVWF 	TMR1H 				;
	CLRF 	TMR1L				;=0
	MOVLW	B'00001111'			; 8 BIT, osc1 enable, TIMER MODE, TIMMER ENABLE
	MOVWF 	T1CON 				; SET
	CLRF	TICKS				; 1/8 sec register
	CLRF 	SECS				; Initialize timekeeping registers
	CLRF 	MINS 				;
	MOVLW	.12
	MOVWF 	HOURS
	MOVLW	.1
	MOVWF	DAY_OF_WEEK
	MOVLW	.1
	MOVWF	DAYS
	MOVLW	.8
	MOVWF	MONTHS
	MOVLW	.42
	MOVWF	YEARS				;MONTAG 19.7.2010 12:00:00 (JAHR-1968)
	MOVLW	0x27				;32kHz TEILER=64
	MOVWF	REGA
	MOVLW	B'00000011'			;24H, SOMMERZEIT
	MOVWF	REGB
	CLRF	REGC
	CLRF	REGD
	CLRF	TASTE_ON_TIME
	CLRF	TASTE_OFF_TIME
	CLRF	POWER_ON_TIME
	CLRF	RX_STATUS
	CLRF	TX_STATUS
	BSF 	PIE1,TMR1IE 		;Enable Timer1 interrupt
;AD WANDLER INITIALISIEREN
	CLRF	AD_KANAL			;BEI 0 BEGINNEN
	CLRF	ADCON0				;AD MOUDUL AUS
	MOVLW	B'00001001'			;VREF=VDD,ANALOG INPUT AN0-AN5
	MOVWF	ADCON1
	MOVLW	B'00000000'			;LINKSSB�NDIG,0 TAD,CLOCK=Fosc/2
	MOVWF	ADCON2
; 	BSF		PIE1,ADIE			;INTERRUPT ENABLE
	CLRF	U_POWER_IN			;WERT AUF 0 VOLT
; seriell initialisieren
	CLRF	SPBRGH
	MOVLW	.16
	MOVWF	SPBRG				;BAUDE RATE = 115K
	MOVLW	B'00000100'			;TX AUS, ASYNC HIGH SPEED
 	MOVWF	TXSTA
	MOVLW	B'10010000'			;SERIEL EIN,RX EIN,
 	MOVWF	RCSTA
	MOVLW	B'00001000'			;16BIT BRG, RISING EDGE INTERRUPT
 	MOVWF	BAUDCON				;SETZEN
;EXTERNER SUBROUTINES
	CLRF	GO_SUB
; interrupts
	CLRF	INTCON3				;EXTER INTERRUPT AUS, low priority
	MOVLW	B'11110000'			;PORT B PULLUPS AUS, EXT INT ON RISING EDGE, TMR0 AND BPIP Low priority
	MOVWF	INTCON2
	MOVLW	B'11000000'			;global on, PERIPHERAL INT on
 	MOVWF	INTCON
;CLOCK
   	MOVLW	CLK_SLEEP			;GEHT JETZT IN SLEEP MODE
   	MOVWF	OSCCON
;-------------------------------------------------------------------------
;---------------------------- MAIN LOOP -------------------------------------------------
;-------------------------------------------------------------------------
MAIN						
	MOVLW	EXT_CODE			;GO EXTERNE SUBROUTINEN AKTIV?
	CPFSEQ	GO_SUB				;SKIP WENN JA
	BRA		WARTEN				;SONST WARTEN
	CALL	MAIN2,1				;REGISTER SICHERN UND STARTEN
WARTEN
	BTFSC	TRISD,RD0			;SKIP IF POWER ON
 	SLEEP						;SLEPP BIS ZUM N�CHSTEN INTERRUPT
	BRA	MAIN
MAIN2
	CALL	EXTERN_SUBROUTINES	;EXTERNE SUBROUTINEN AUSF�HREN AN STELLE 0 MUSS 0xFA STEHEN SONST UNG�LTIG
	RETURN	1					;RETURN MIT REGISTER ZUR�CK
;**********************************************************************************************"""""""""""""
;--------------------------- subroutines -------------------------------------------------
;**********************************************************************************************"""""""""""""
;POWER ON/OFF 
POWER_EIN
;CLOCK
   	MOVLW	CLK_ACTIV
   	MOVWF	OSCCON

	BCF		TRISA,RA7			;CLOCK EINSCHALTEN
	BCF		TRISD,RD7			;#RSTI AKTIVIEREN = LOW
	BCF		TRISB,RB4			;PIC_INT AKTIVIEREN
	BCF		TRISD,RD0			;POWER ON
	BCF		TRISA,RA6			;PIC_AMKB_RX auf output
	BRA		LS_ON_POWER			;LADESTROM EINSTELLEN
POWER_AUS
;CLOCK
   	MOVLW	CLK_SLEEP
   	MOVWF	OSCCON

	BSF		TRISA,RA6			;PIC_AMKB_RX auf input
	BSF		TRISD,RD0			;POWER OFF
	BSF		TRISD,RD7			;#RSTI DEAKTIVIEREN
	BSF		TRISB,RB4			;PIC INT DEAKTIVIEREN
	BSF		TRISA,RA7			;CLOCK DEAKTIVIEREN
	CLRF	POWER_ON_TIME		;R�CKSETZEN
	BRA		LS_OFF_POWER		;LADESTROM EINSTELLEN
;LADESTROM EINSTELLEN ----------------------------
LADESTROM
	BTFSC	TRISD,RD0			; ONPOWER?
	BRA		LS_OFF_POWER		; NEIN->
LS_ON_POWER						;GROSSER LADESTROM 5A
	BCF		TRISA,RA4			;10K ON
	RETURN
LS_OFF_POWER					;KLEINER LADESTROM_MIN 1.85A
	BSF		TRISA,RA4			;10K OFF
	RETURN
;---------------------------------------------------
;SERIELL AUS/EIN
SERIAL_OFF
	BCF		TXSTA,TXEN			;TX AUS
	BCF 	PIE1,RCIE 			;DISABLE RX interrupt
	BCF 	PIR1,RCIF 			;CLEAR RX interrupt
	BCF 	PIE1,TXIE			;DISABLE TX interrupt
	BCF 	PIR1,TXIF			;CLEAR TX interrupt
	RETURN
SERIAL_ON
	BTFSC	TXSTA,TXEN			;SCHON EIN?
	RETURN						;JA->
	BSF		TXSTA,TXEN			;TX EIN
	MOVLW	SYNC1
	MOVWF	RX_STATUS			;AUF SYNC WARTEN
	CLRF	TX_STATUS
	MOVFF	RCREG,RX_B			;RCREG LEEREN
	MOVFF	RCREG,RX_B			;RCREG LEEREN
	BCF 	PIR1,TXIF			;CLEAR TX interrupt
	BCF		PIR1,RCIF			;INTERRUPT RX FLAG L�SCHEN
	BSF 	PIE1,RCIE 			;ENABLE RX interrupt
	NOP
	RETURN
;---------------------------------------------------------------------
; TASTENDRUCK
TASTE
	BTFSS	PORTD,RD1			;TASTE GEDR�CKT?
	BRA		TG_JA				;->JA
;TASTE NICHT GEDR�CKT ODER LOSGELASSEN
	CLRF	TASTE_ON_TIME		;R�CKSETZEN

	MOVLW	TIME_MAX			;MAX
	CPFSGT	TASTE_OFF_TIME		;L�NGER?
	INCF	TASTE_OFF_TIME		;NEIN ERH�HEN

	MOVLW	RESET_OFF_TIME		;2SEC
	CPFSGT	POWER_ON_TIME		;L�NGER?
	RETURN						;NEIN->
;RESET AUFHEBEN
	BSF		TRISD,RD7			;JA -> #RSTI DEAKTIVIEREN =HIGH
	CALL	SERIAL_ON			;SERIELL EINSCHALTEN
	RETURN
;TASTE GEDR�CKT
TG_JA
	MOVLW	OFF_TIME+1
	CPFSLT	TASTE_ON_TIME		;K�RZER ALS ONTIME+1
	RETURN						;NEIN->FERTIG
	BTFSC	TRISD,RD0			;ONPOWER?
	BRA		TG_OFF_POWER		;NEIN->
TG_ON_POWER
	MOVLW	SEND_RTC_TIME		;ZEIT F�R RTC REQ FROM MCF HOLEN?
	CPFSEQ	TASTE_ON_TIME		;TEST
	BRA		TG_ON_POWER2		;NEIN->
SEND_RTC_REG
	MOVLW	REQ_RTCD_FROM_MCF
	MOVWF	TXREG				;SENDEN
	BRA		TG_END;			
TG_ON_POWER2
	MOVLW	RESET_ON_TIME		;
	CPFSLT	TASTE_ON_TIME		;K�RZER?
	BRA		RESETEN
TG_ON_POWER3
	MOVLW	OFF_TIME
	CPFSLT	TASTE_ON_TIME		;K�RZER ON/OFF TIME?
	CALL	POWER_AUS			;NEIN->POWER OFF
	BRA		TG_END
TG_OFF_POWER
	MOVLW	ON_TIME
	CPFSLT	TASTE_ON_TIME		;K�RZER ALS ON/OFF TIME?
	CALL	POWER_EIN			;NEIN->POWER ON
TG_END
	CLRF	TASTE_OFF_TIME		;R�CKSETZEN
	INCF	TASTE_ON_TIME		;ERH�HEN 
	RETURN
RESETEN
	CALL	SERIAL_OFF			;SERIELL DEAKTIVIEREN
	BCF		TRISD,RD7			;NEIN-> #RSTI AKTIVIEREN =LOW  -->>>RESET
	BRA		TG_ON_POWER3
;**********************************************************************************************"""""""""""""
;----------------------------------------- INTERRUPTS 
;**********************************************************************************************"""""""""""""
; SERIELL INTERRUPTS
;**********************************************************************************************"""""""""""""
;TX
TX_ISR							;TRANSMIT
	MOVLW	RTCD_FROM_PIC		;RTC DATEN SENDEN?
	CPFSEQ	TX_STATUS			;SKIP JA
	BRA		TX_ISR1				;NEIN->
	MOVFF	POSTINC0,TXREG		;BYT SENDEN
	MOVLW	0x3F				;SCHON LETZTES BYTS?
	CPFSGT	FSR0L				;SKIP WENN FERTIG
	RETFIE						;NEIN WEITERE SENDEN
TX_ISR_FERTIG
	CLRF	TX_STATUS
	BCF 	PIE1,TXIE 			;SONST DISABLE interrupt
	BCF		PIR1,TXIF			;INTERRUPT FLAG L�SCHEN
	RETFIE
TX_ISR1
	MOVLW	READ_BLOCK			;READ BLOCK?
	CPFSEQ	TX_STATUS			;SKIP JA
	BRA		TX_ISR2				;NEIN->
	MOVFF	POSTINC0,TXREG		;BYT SENDEN
	MOVLW	0xC3				;SCHON LETZTES BYTS?
	CPFSEQ	FSR0L				;SKIP WENN FERTIG
	RETFIE						;NEIN WEITERE SENDEN
TX_ISR2
	BRA 	TX_ISR_FERTIG
;**********************************************************************************************"""""""""""""
;RX
RX_ISR							; BYT RECEIVED
	MOVFF	RCREG,RX_B			; BYT HOLEN	
;   	MOVFF	RX_B,TXREG			; ECHO
	MOVLW	SYNC4				;IM SYNC STATUS?
	CPFSLT	RX_STATUS			;SKIP WENN NEIN
	BRA		RX_SYNC_START		;JA -> ZUERST SYNC EMPFANGEN
;RTC DATEN EMPFANGEN?  -----------------------------------------------------------------------------------
	MOVLW	RTCD_FROM_MCF		; DATEN VOM MCF CODE 0x82? 
	CPFSEQ	RX_STATUS			; WENN JA-> SKIP
	BRA		RX_ISR1				; NEIN->
;64 BYT EMPFANGEN -------------------------------------
	MOVFF	RX_B,POSTINC1		;HOLEN -> (CNT+)
	MOVLW	0x40				;64 BYT �BERTRAGEN?
	CPFSLT	FSR1L				;NEIN ->SKIP
	CLRF	RX_STATUS			;JA FERTIG
	RETFIE	
; SETZEN? ---------------------------------------------------
RX_ISR1
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR2				;JA ->
	CPFSEQ	RX_B				;BLOCK HEADER 0X82?
	BRA		RX_ISR2				;NEIN->
	MOVWF	RX_STATUS			;STATUS SETZEN = EMPFANGENES BYT
	LFSR	1,.0				;BYT COUNTER AUF O
	RETFIE
; RTC DATEN SENDEN? -------------------------------------------------------------------------------------
RX_ISR2
	MOVLW	REQ_RTCD_FROM_PIC	;DATEN SENDEN?
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR3				;JA ->
	CPFSEQ	RX_B				;SKIP WENN JA
	BRA		RX_ISR3				;SONST NEXT
;BLOCK HEADER UND 64 BYT SENDEN -----------
	LFSR	0,.0
	BCF		PIR1,TXIF			;INTERRUPT FLAG L�SCHEN
	BSF 	PIE1,TXIE 			;Enable interrupt
	MOVLW	RTCD_FROM_PIC
	MOVWF	TX_STATUS			;STATUS SETZEN		
	MOVWF	TXREG				;BLOCK HEADER = 0X81
	CLRF	RX_STATUS			;STATUS R�CKSETZEN
	RETFIE						;UND WEG
;EXT SUB INT STARTEN?-------------------------------------------------------------------------------------
RX_ISR3
	MOVLW	EXT_SUB_GO			;EXT SUB FREIGEBEN?
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR4				;JA ->
	CPFSEQ	RX_B
	BRA		RX_ISR4				;NEIN->	
;EXT SUBS FREIGEBEN --------------------------------------------------------------			
	MOVLW	(EXTERN_INT_ADR & 0xFF0000)>>16
	MOVWF	TBLPTRU
	MOVLW	(EXTERN_INT_ADR & 0x00FF00)>>8
	MOVWF	TBLPTRH
	MOVLW	(EXTERN_INT_ADR & 0x0000FF)
	MOVWF	TBLPTRL				;ADRESSE SETZEN
	TBLRD*						;WERT HOLEN (MUSS 0xFB SEIN SONST UNG�LTIG)
	MOVFF	TABLAT,GO_INT		;EXTERNE SUBROUTINES AKTIVIEREN WENN OK
	MOVLW	(EXTERN_SUB_ADR & 0xFF0000)>>16
	MOVWF	TBLPTRU
	MOVLW	(EXTERN_SUB_ADR & 0x00FF00)>>8
	MOVWF	TBLPTRH
	MOVLW	(EXTERN_SUB_ADR & 0x0000FF)
	MOVWF	TBLPTRL				;ADRESSE SETZEN
	TBLRD*						;WERT HOLEN (MUSS 0xFB SEIN SONST UNG�LTIG)
	MOVFF	TABLAT,GO_SUB		;EXTERNE SUBROUTINES AKTIVIEREN WENN OK
	CLRF	RX_STATUS			;STATUS R�CKSETZEN
	RETFIE						;UND WEG
;EXT SUB INT STOPPEN? -------------------------------------------------------------------------------------
RX_ISR4
	MOVLW	EXT_SUB_STOP		;EXT SUB STOPPEN?
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR5				;JA ->
	CPFSEQ	RX_B
	BRA		RX_ISR5				;NEIN->	
;EXT SUBS STOPPEN --------------------------------------------------------------
	CLRF	GO_INT				;STOPPEN			
	CLRF	GO_SUB				;STOPPEN			
	CLRF	RX_STATUS			;STATUS R�CKSETZEN
	RETFIE						;UND WEG
;REQ BLOCK? -------------------------------------------------------------------------------------
RX_ISR5
	MOVLW	REQ_BLOCK			;REQ BLOCK?
	TSTFSZ	RX_STATUS			;TASK H�NGIG? SKIP NON
	BRA		RX_ISR6				;JA ->
	CPFSEQ	RX_B
	BRA		RX_ISR6				;NEIN->
;REQ BLOCK SETZEN
	MOVWF	RX_STATUS			;STATUS SETZEN = EMPFANGENES BYT
	LFSR	1,TX_BUFFER			;BYT COUNTER AUF TX_BUFFER -> GLEICH EINTRAGEN
	RETFIE
RX_ISR6
	CPFSEQ	RX_STATUS			;REQ BLOCK ADRESSE EMPFANGFEN?
	BRA		RX_ISR7				;NEIN->
;3 BYT EMPFANGEN ---------------------------
	MOVFF	RX_B,POSTINC1		;HOLEN -> (CNT+)
	MOVLW	0x83				;3 BYT �BERTRAGEN? (BUFFER BEGINNT BEI 0x180
	CPFSEQ	FSR1L				;NEIN ->SKIP
	RETFIE						;NEXT ->
	LFSR	1,TX_BUFFER			;BYT RX COUNTER AUF TX_BUFFER 
	MOVFF	POSTINC1,TBLPTRU	;ADRESSE EINTRAGEN
	MOVFF	POSTINC1,TBLPTRH
	MOVFF	POSTINC1,TBLPTRL
	MOVLW	0xC3				;67 BYT �BERTRAGEN?  (BUFFER BEGINNT BEI 0x180
RX_RB3B2
	TBLRD	*+					;LESEN UND NEXT
	MOVFF	TABLAT,POSTINC1		;UND EINTRAGEN
	CPFSEQ	FSR1L				;WENN FERTIG ->SKIP
	BRA		RX_RB3B2			;SONST LOOP
;BLOCK HEADER  3 BYTS ADRESSE UND 64 BYT SENDEN STARTEN 
	LFSR	0,TX_BUFFER			;TX COUNTER AUF TX_BUFFER 
	BCF		PIR1,TXIF			;INTERRUPT FLAG L�SCHEN
	BSF 	PIE1,TXIE 			;Enable interrupt
	MOVLW	READ_BLOCK			;CODE HEADER 0xA1
	MOVWF	TX_STATUS			;STATUS SETZEN		
	MOVWF	TXREG				;BLOCK HEADER = 0XA1
	CLRF	RX_STATUS			;STATUS R�CKSETZEN
	RETFIE						;UND WEG
;PROGRAMM BLOCK? -------------------------------------------------------------------------------------
RX_ISR7	
	MOVLW	WRITE_BLOCK			;WRITE BLOCK 0xA2 BYT EMPFANGEN?
	CPFSEQ	RX_STATUS			;WENN JA-> SKIP
	BRA		RX_ISR8				;NEIN->
;WRITE BLOCK ------------------------
;68 BYT EMPFANGEN: 3 BYT ADRESSE; 64 BYT DATEN; 1 BYT CHECKSUM -------------------
	MOVFF	RX_B,POSTINC1		;HOLEN -> (CNT+)
	MOVLW	0x44				;68 BYT �BERTRAGEN?
	CPFSEQ	FSR1L				;WENN FERTIG ->SKIP
	RETFIE
; ADRESSE UND DATEN und CHECKSUM SIND DA -> PROGRAMMING FLASH
; TEST CHECKSUM
	LFSR	1,RX_BUFFER			;BYT COUNTER AUF RX BUFFER
	MOVLW	43h					;67 BYTES
	MOVWF	RX_B				;COUNTER
	MOVLW	0h					;SUM CLEAR
LOOP_TEST_CHECKSUM
	ADDWF	POSTINC1,0			;ADD TO WREG
	DECFSZ	RX_B				;-1 SKIP WENN 0
	BRA		LOOP_TEST_CHECKSUM
	CPFSEQ	POSTINC1			;SUM = CHECKESUM? SKIP JA  
	BRA		CHK_ERR				;NEIN CHECKSUM ERROR
	BRA		PROGRAMM_BLOCK		; OK-> PROGRAMMIEREN
CHK_ERR
	MOVLW	CHECKSUM_ERROR		; ERROR senden
	MOVWF	TXREG;
	CLRF	RX_STATUS			; FERTIG
	RETFIE
;WRITE BLOCK SETZEN?
RX_ISR8	
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR9				;JA ->
	CPFSEQ	RX_B				;BLOCK HEADER COMMANDOE 0XA2?
	BRA		RX_ISR9				;NEIN->
	MOVWF	RX_STATUS			;STATUS SETZEN = EMPFANGENES BYT
	LFSR	1,RX_BUFFER			;BYT COUNTER AUF RX BUFFER
	RETFIE
;--------------------------------------------------------------------------------------------
RX_ISR9
	MOVLW	CMD_FROM_MCF		;CMD HEADER 0x0C EMPFANGEN?
	CPFSEQ	RX_STATUS			;WENN JA-> SKIP
	BRA		RX_ISR15			;NEIN->
;COMMAND BYT EMPFANGEN
;3 BYT EMPFANGEN -------------------------------------
	MOVFF	RX_B,POSTINC1		;HOLEN -> (CNT+)
	MOVLW	0x3					;3 BYT �BERTRAGEN?
	CPFSEQ	FSR1L				;NEIN ->SKIP
	RETFIE	
CMD_AUSWERTEN
;RESET?
	LFSR	1,RX_BUFFER			;ZEIGER AUF RX BUFFER
	MOVLW	'R'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC2					;NEIN->
	MOVLW	'S'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC2					;NEIN->
	MOVLW	'T'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC2					;NEIN->
;RESET MCF
	CALL	SERIAL_OFF			;SERIELL DEAKTIVIEREN
	BCF		TRISD,RD7			;NEIN-> #RSTI AKTIVIEREN =LOW  -->>>RESET
	MOVLW	0FFh
LC1_WAIT
	NOP
	NOP
	NOP
	DECFSZ	WREG
	BRA		LC1_WAIT
	BSF		TRISD,RD7			;JA -> #RSTI DEAKTIVIEREN =HIGH
	CALL	SERIAL_ON			;SERIELL EINSCHALTEN
	CLRF	RX_STATUS			;JA FERTIG
	RETFIE
LC2:
;POWER AUS?
	LFSR	1,RX_BUFFER			;ZEIGER AUF RX BUFFER
	MOVLW	'O'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC4					;NEIN->
	MOVLW	'F'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC4					;NEIN->
	MOVLW	'F'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC4					;NEIN->
;POWER OFF
	CALL	POWER_AUS
	CLRF	RX_STATUS			;JA FERTIG
	RETFIE
LC4:
;RESET PIC?
	LFSR	1,RX_BUFFER			;ZEIGER AUF RX BUFFER
	MOVLW	'R'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC6					;NEIN->
	MOVLW	'P'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC6					;NEIN->
	MOVLW	'I'
	CPFSEQ	POSTINC1			;=? SIKP JA
	BRA		LC6					;NEIN->
;RESET PIC
	RESET
;HIER SOLLTE ER NICHT HINKOMMEN	
	BRA		KALT_START
LC6
;NO REAL CMA
	CLRF	RX_STATUS			;JA FERTIG
	RETFIE
;END CDM AUSWERTEN
RX_ISR15
	TSTFSZ	RX_STATUS			;TASK H�NGIG?
	BRA		RX_ISR20			;JA ->
	CPFSEQ	RX_B				;CMD?
	BRA		RX_ISR20			;NEIN->
;CMD SETZEN
	MOVWF	RX_STATUS			;STATUS SETZEN = EMPFANGENES BYT
	LFSR	1,RX_BUFFER			;ZEIGER AUF RX BUFFER
	RETFIE
RX_ISR20
RX_ISR_END
	CLRF	RX_STATUS
	RETFIE
;-------------------------------------------------------------------------------------
;SYNC ABWARTEN UND WENN DA "OK!" SENDEN ----------------------------------------------------
;-------------------------------------------------------------------------------------
RX_SYNC_START
	MOVLW	SYNC1
	CPFSEQ	RX_STATUS
	BRA		RX_SYNC2
	MOVLW	SYNC1_DATA
	CPFSEQ	RX_B
	BRA		NON_SYNC
	MOVLW	SYNC2
	MOVWF	RX_STATUS
	RETFIE
NON_SYNC
	MOVLW	SYNC1
	MOVWF	RX_STATUS
	RETFIE
RX_SYNC2						;TEST AUF SYNC UND DATA 2
	MOVLW	SYNC2
	CPFSEQ	RX_STATUS
	BRA		RX_SYNC3			;NICHT SYNC 2
	MOVLW	SYNC2_DATA
	CPFSEQ	RX_B
	BRA		NON_SYNC
	MOVLW	SYNC3
	MOVWF	RX_STATUS
	RETFIE
RX_SYNC3						;TEST AUF SYNC UND DATA 3
	MOVLW	SYNC3
	CPFSEQ	RX_STATUS
	BRA		RX_SYNC4			;NICHT SYNC 3
	MOVLW	SYNC3_DATA
	CPFSEQ	RX_B
	BRA		NON_SYNC
	MOVLW	SYNC4
	MOVWF	RX_STATUS
	RETFIE
RX_SYNC4						;TEST AUF SYNC UND DATA 4
	MOVLW	SYNC4
	CPFSEQ	RX_STATUS
	BRA		NON_SYNC			;WIEDER VON VORN
	MOVLW	SYNC4_DATA
	CPFSEQ	RX_B				;SKIP OK
	BRA		NON_SYNC			;NICHT SYNC4 DATA 
RX_WAIT1
	BTFSS	TXSTA,TRMT
	BRA		RX_WAIT1
	MOVLW	'O'					;SENDE OK!
	MOVWF	TXREG
RX_WAIT2
	BTFSS	TXSTA,TRMT
	BRA		RX_WAIT2
	MOVLW	'K'					;SENDE OK!
	MOVWF	TXREG
RX_WAIT3
	BTFSS	TXSTA,TRMT
	BRA		RX_WAIT3
	MOVLW	'!'
	MOVWF	TXREG
	CLRF	RX_STATUS			;OK START NORMAL
	RETFIE
;**********************************************************************************************"""""""""""""
;SPANNUNGS�BERWACHUNGS INTERRUPT
HLVD_ISR
	BTFSS	U_ERR,1				;WARTEN AUF GELADEN?
	BRA	HLVD_LE					;NEIN UNTERSPANNUNG DETEKT->
	BCF		U_ERR,0				;SPANNUNGSFEHLER AUS
	BCF		U_ERR,1				;WARTEN AUF GELADEN=AUS
	MOVLW	U_ERR_PW_AUS+2		;POWER AUS �BERSPRINGEN
	MOVWF	U_ERR_TIME			;ZEIT SETZEN 
	MOVLW	B'00010111'			;INT WENN UNTER 3.12V
	MOVWF	HLVDCON	
WAIT_LVDOK:
	BTFSS	HLVDCON,IVRST		;ABWARTEN BIS AENDERUNG AKTIV
	BRA		WAIT_LVDOK
	BCF		PIR2,HLVDIF			;INTERRUPT FLAG L�SCHEN
	RETFIE	
HLVD_LE							;UNTERSPANNUNG
	BSF		U_ERR,0				;ERROR SETZEN
	BSF		U_ERR,1				;WARTEN AUF GELADEN SETZEN
	CLRF	U_ERR_TIME			;R�CKSETZEN
;MESSAGE AN PROCESSOR
	MOVLW	U_MIN_TO_MCF
	MOVWF	TXREG				;SENDEN

	MOVLW	B'10011010'			;INT WENN �BER 3.7V
	MOVWF	HLVDCON	
	BRA		WAIT_LVDOK
;**********************************************************************************************"""""""""""""
;A/D INTERRUPT
AD_ISR
	BCF		PIR1,ADIF			;CLEAR INTERRUPT PENDIG
	RETFIE						;RETURN
;*************************************************************************************************************
; uhr interrupt ALLE 1/8 SEC
RTC_ISR
;UHR WIEDER R�CKSETZEN UND AKTIVIEREN
	MOVLW	TIMER_HB		;WIEDER AUF STARTWERT
	MOVWF	TMR1H			;SETZEN
	BCF		PIR1,TMR1IF		;INTERRUPT FLAG L�SCHEN
	BSF		PORTB,RB4		;PIC INT HIGH --------
	BSF		TRISE,RE0		;LED=OFF
	BCF		PORTB,RB4		;PIC INT = LOW
	BTFSC	TRISD,RD0		;POWER OFF?
	BRA		POWER_OFF_I		;JA->
; POWER IS ON: 
; BLINKEN 4X/SEC WENN RESET
	BTFSC	TRISD,RD7		;RESET AKTIV?
	BRA 	PINGS			;NEIN->
	BTFSC 	TICKS,0			;UNGERADE TICKS?
	BCF		TRISE,RE0		;NEIN->LED=ON
	BRA	PINGS			
POWER_OFF_I
	MOVLW	.3				
	ANDWF	SECS,0			;4 SEKUNDEN AUSMASKIEREN
	BNZ		PINGS			;NICHT MODULO4 ->
	MOVLW	.7
	CPFSEQ	TICKS			;7. TICK?
	BRA	POWER_OFF_I2		;NEIN->
	BCF		TRISE,RE0		;JA->LED=ON
POWER_OFF_I2
	MOVLW	.30				; WENIGER ALS 30 SEC SEIT LETZTEM SPANNUNGSFEHLER?
	CPFSLT	U_ERR_TIME
	BRA	PINGS				;NEIN->
	MOVLW	.5
	CPFSEQ	TICKS			;5. TICK?
	BRA	PINGS				;NEIN->
	BCF		TRISE,RE0		;JA->LED=ON
PINGS
	CALL	TASTE			;UP TASTE
; TASTE LOSGELASSEN?
	MOVLW	RESET_OFF_TIME
	CPFSGT	TASTE_OFF_TIME	;TASTE L�NGER ALS 2 SEC LOSGELASSEN?
	BRA		PINGW			;NEIN->
	BSF 	TRISD,RD7	 	;JA-> #RSTI INAKTIV =HIGH
	BTFSS	TRISD,RD0		;POWER ON?
	CALL	SERIAL_ON		;ja->SERIELL EINSCHALTEN
;--TICKS=125MS
PINGW
	INCF	TICKS			;inc ticks
	BTFSS	TRISD,RD0		;POWER ON?
	BRA		PINGS2			;JA->
	MOVLW	20
	CPFSLT	U_POWER_IN		;LADEGER�T ANGESCHLOSSEN?
	BRA		PINGS2			;->JA LED HELLER
	MOVLW	TIME_MAX		;>=MAXIMALZEIT?
	CPFSLT	U_ERR_TIME		;SEIT SPANNUNGSFEHLER
	BSF		TRISE,RE0		;JA -> LED OFF
PINGS2
	MOVLW	.7				; 7?
	CPFSGT	TICKS			
	RETFIE					; NEIN ->RETURN
SEKUNDEN
;led blinken POWER ON-----------------------------------------
	BTFSS	TRISD,RD0		;POWER ON?
	BCF		TRISE,RE0		;JA -> LED_ON
;TIMER U_ERR ERH�HEN
	MOVLW	TIME_MAX		;>=MAXIMALZEIT?
	CPFSGT	U_ERR_TIME		;SEIT SPANNUNGSFEHLER
	INCF	U_ERR_TIME		;NEIN ERH�HEN
;SPANNUNGSFEHLER BEARBEITEN ----------------------------------------
	MOVLW	U_ERR_PW_AUS	;POWER AUS ZEIT?
	CPFSEQ 	U_ERR_TIME		;
	BRA		SEK_NPA			;NEIN
	CALL 	POWER_AUS		;JA AUSSCHALTEN
;--------------------------------------------------------
SEK_NPA
;SPANNUNG POWER IN MESSEN
	MOVLW	B'00000001'			;KANAL 0, AD ON
	MOVWF	ADCON0				; 
	BSF		ADCON0,1			;GO
SEK_2
	BTFSC	ADCON0,1			;FERTIG?
	BRA		SEK_2				;NEIN
	MOVFF	ADRESH,U_POWER_IN	;OK WERT EINTRAGEN

;SPANNUNG 2V5 MESSEN -> U_ERR TIMER NICHT ERH�HEN WENN �BER 3.2V RESP. WIEDER -1
	BTFSC	TRISD,RD0			;POWER ON?
	BRA		SEK_4				;NEIN NICHT MESSEN

	MOVLW	B'00001101'			;KANAL 3, AD ON
	MOVWF	ADCON0				; 
	BSF		ADCON0,1			;GO
SEK_3
	BTFSC	ADCON0,1			;FERTIG?
	BRA		SEK_3				;NEIN
	MOVLW	.200				;UNTER 3.2V -> WENN WERT �BER 78%
	CPFSLT 	ADRESH				;JA ->
	BRA		SEK_4				;SONST WEITER
;TIMER U_ERR ERH�HEN
	BTFSS	U_ERR,0				;SPANNUNGSERROR?
	BRA		SEK_4				;NEIN
	MOVLW	TIME_MAX			;>=MAXIMALZEIT?
	CPFSGT	U_ERR_TIME			;SEIT SPANNUNGSFEHLER
	DECF	U_ERR_TIME			;NEIN -> -1
;-------------------------------------------------------------
SEK_4
	CLRF	TICKS
	INCF 	SECS	 		; Increment seconds

;?????????????????????????????????????????????????????
;test pic ps2 keyboard
;	MOVLW	0f9h		;2 
;	CALL	send
;	nop
;	nop
;	MOVLW	.10
;	CALL	send
;	nop
;	nop
;	MOVLW	.10
;	CALL	send
;--------------------------------------------------------------
	MOVLW 	.59 			; 60 seconds elapsed?
	CPFSGT 	SECS
	RETFIE	 				;RETURN
MINUTEN
	CLRF 	SECS 			; Clear seconds
	INCF 	MINS	 		; Increment minutes
	MOVLW 	.59 			; 60 minutes elapsed?
	CPFSGT 	MINS
	RETFIE 					;RETURN 
STUNDEN
	CLRF 	MINS 			; clear minutes
	INCF 	HOURS	 		; Increment hours
	MOVLW 	.23 			; 24 hours elapsed?
	CPFSGT 	HOURS
	RETFIE	 				;RETURN 
TAGE_UND_TAG_DER_WOCHE
	CLRF 	HOURS 			; Reset hours
	MOVLW	.7
	CPFSLT	DAY_OF_WEEK
	CLRF	DAY_OF_WEEK
	INCF	DAY_OF_WEEK
	INCF	DAYS
	MOVLW	.28				
	CPFSGT	DAYS
	RETFIE	 				;RETURN 
MEHR_ALS_28_TAGE
	MOVLW	.2
	CPFSEQ	MONTHS			;FEB?
	BRA		NOT_FEB			;NEIN->
FEB
	MOVLW	.3
	ANDWF	YEARS,0			;SCHALTJAHR
	BNZ		NEXT_MONTH		;NEIN->
SCHALTJAHR
	MOVLW	.29
	CPFSGT	DAYS
	RETFIE	 				;RETURN 
NEXT_MONTH
	MOVLW	.1
	MOVWF	DAYS
	INCF	MONTHS
	MOVLW	12
	CPFSGT	MONTHS
	RETFIE	 				;RETURN 
YEAR	
	MOVLW	.1
	MOVWF	MONTHS
	INCF	YEARS
	RETFIE	 				;RETURN 
NOT_FEB
	MOVLW	.30
	CPFSGT	DAYS
	RETFIE	 			
MEHR_ALS_30_TAGE
	MOVLW	.4				;APRIL?
	CPFSEQ	MONTHS			;SKIP
	BRA		NOT_APRIL 
	BRA		NEXT_MONTH		;APRIL->
NOT_APRIL
	MOVLW	.6				;JUNI?
	CPFSEQ	MONTHS
	BRA		NOT_JUNI 
	BRA		NEXT_MONTH		;JUNI->
NOT_JUNI
	MOVLW	.9				;SEPTEMBER?
	CPFSEQ	MONTHS	 
	BRA		NOT_SEP 
	BRA		NEXT_MONTH		;SEPTEMBER->	 
NOT_SEP
	MOVLW	.11				;NOVEMBER?
	CPFSEQ	MONTHS			;SKIP
	RETFIE					;SIND MONATE MIT 31 TAGEN-> 
	BRA		NEXT_MONTH		;SONST NOVEMBER->
;**********************************************************************************************"""""""""""""
; ENDE MAIN 
;**********************************************************************************************"""""""""""""
;**********************************************************************************************"""""""""""""
; EXTERN_SUBOUTINES FOGEN AB 0x2000 DIE SP�TER EINPROGRAMMIERT WERDEN
;**********************************************************************************************"""""""""""""
EXT_INT	CODE	0x2000
EXT_INT_MAGIC	DB 0	
EXT_INT_START

EXT_SUB	CODE	0x2010
EXT_SUB_MAGIC	DB 0
EXT_SUT_START	

clockrate equ .8000000 ;Xtal value (8Mhz in this case)
fclk equ clockrate/4
;baudrate equ ((fclk/.7812.5)/3-2) ;7812.5 is the baud rate
baudrate equ .83 ;7812.5 is the baud rate

txreg 	equ 10
delay 	equ 11
count 	equ 12
txchar 	equ 13

send
	movwf txreg
	movlw baudrate
	movwf delay
	movlw .9
	movwf count
	bcf PORTA,6 ;send start bit
	nop ;even out bit times
next 
	decfsz delay,f
	goto next
	movlw baudrate ;rest of program is 9 instructions
	movwf delay
	decfsz count,f
	goto sendnextbit
	bcf PORTA,6 ;send stop bit
	movlw baudrate ;Delay for line to settle
	movwf delay ;Delay for line to settle
p1 
	decfsz delay,f ;Delay for line to settle
	goto p1 ;Delay for line to settle
	bsf PORTA,6
p2 	
	decfsz delay,f
	goto p2
	return
sendnextbit
	rrcf txreg,F
	btfss STATUS,C ;check next bit to tx
	goto setlo
	bsf PORTA,6 ;send a high bit
	goto next
setlo 
	bcf PORTA,6 ;send a low bit
	goto next


	end