;CodeVisionAVR C Compiler V1.24.2c Evaluation
;(C) Copyright 1998-2004 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.ro
;e-mail:office@hpinfotech.ro

;Chip type           : ATmega8
;Program type        : Application
;Clock frequency     : 8,000000 MHz
;Memory model        : Small
;Optimize for        : Size
;(s)printf features  : int, width
;(s)scanf features   : long, width
;External SRAM size  : 0
;Data Stack size     : 256 byte(s)
;Heap size           : 0 byte(s)
;Promote char to int : No
;char is unsigned    : Yes
;8 bit enums         : Yes
;Enhanced core instructions    : On
;Automatic register allocation : On

	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_adc_noise_red=0x10
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __CLRD1S
	LDI  R30,0
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@2,@0+@1
	.ENDM

	.MACRO __GETWRMN
	LDS  R@2,@0+@1
	LDS  R@3,@0+@1+1
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	RCALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	RCALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __CLRD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOV  R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOV  R30,R0
	.ENDM

	.CSEG
	.ORG 0

	.INCLUDE "kurs_obsh_1.vec"
	.INCLUDE "kurs_obsh_1.inc"

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,13
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0x400)
	LDI  R25,HIGH(0x400)
	LDI  R26,0x60
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0x45F)
	OUT  SPL,R30
	LDI  R30,HIGH(0x45F)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0x160)
	LDI  R29,HIGH(0x160)

	RJMP _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x160
;       1 #include <mega8.h>
;       2 #include <delay.h>   
;       3 #include <stdlib.h>
;       4 
;       5 //биты USART
;       6 #define RXCIE 7
;       7 #define TXCIE 6
;       8 #define RXEN 4
;       9 #define TXEN 3         
;      10 #define TXC 6 // флаг регистра UCSRA, устанавливающийся в 1 при завершении передачи  
;      11 #define UDRE 5 // флаг регистра UCSRA, устанавливающийся в 1, когда регистр данных пуст
;      12 
;      13 //биты TWI (I2C)
;      14 #define TWINT 7        
;      15 #define TWEA 6     
;      16 #define TWSTA 5
;      17 #define TWSTO 4
;      18 #define TWEN 2  
;      19 
;      20 //биты таймера1
;      21 #define OCIE1A 4 //бит для разрешения прерывания по совпадению    
;      22 #define WGM12 3  //бит для сброса счетного регистра при совпадении 
;      23 #define CS10 0   //два бита настройки делителя
;      24 #define CS12 2
;      25  
;      26 
;      27 char porog_temp = 5; //пороговая температура.   
;      28 unsigned digit[11] = {0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111, 0b01000000}; //массив с числами для семисегментного индикатора, 11 элемент - знак "-"
_digit:
	.BYTE 0x16
;      29 unsigned razr[5] = {0b11111000, 0b11110100, 0b11101100, 0b11011100, 0b10111100}; //массив с номерами разрядов семисегментного индикатора
_razr:
	.BYTE 0xA
;      30 
;      31 
;      32 unsigned dat_adr[7] = {0b10010000, 0b10010010, 0b10010100, 0b10010110, 0b10011000, 0b10011010, 0b10011100}; //адреса датчиков для i2c интерфейса c сдвинутым влево на 1 разряд (т.к. в i2c нулевой бит - режим чтенияя или записи)    
_dat_adr:
	.BYTE 0xE
;      33 char dat_temp1; //переменная, в которой хранится целая часить температуры текущего датчика
;      34 char dat_temp2; //переменная, в которой хранится дробная часить температуры текущего датчика 
;      35 unsigned char message[5]; //массив для печати на семисегментный дисплей 
_message:
	.BYTE 0x5
;      36 unsigned char fl;//флаг для выхода из режима печати и переключение датчика
;      37 
;      38 void decode(); //функция преобразования двух шестнадцатиричных чисел в строку из пяти элементов, содержащих биты цифр десятичной системы для семисегментного дислпея
;      39 unsigned char dat_num = 1; //номер текущего датчика  
;      40 
;      41 void reset() //функция броса всех настроек к стандартным и подготовки к началу работы
;      42 {                  

	.CSEG
_reset:
;      43 	dat_num = 7;
	LDI  R30,LOW(7)
	MOV  R8,R30
;      44 	
;      45 }       
	RET
;      46 
;      47 unsigned char usart_message[8]; //сообщение, которое будет отправлено по USART на ПЭВМ

	.DSEG
_usart_message:
	.BYTE 0x8
;      48 void temp_transmit()  //функция для передачи сообщение по usart на ПЭВМ                                                                             
;      49 {	

	.CSEG
_temp_transmit:
;      50 	unsigned char sh = 0;   
;      51 	while (sh < 8)
	ST   -Y,R16
;	sh -> R16
	LDI  R16,0
_0x8:
	CPI  R16,8
	BRSH _0xA
;      52 	{            
;      53 		UDR = usart_message[sh];
	MOV  R30,R16
	LDI  R31,0
	SUBI R30,LOW(-_usart_message)
	SBCI R31,HIGH(-_usart_message)
	LD   R30,Z
	OUT  0xC,R30
;      54 		while (!(UCSRA & (1 << UDRE)))
_0xB:
	SBIC 0xB,5
	RJMP _0xD
;      55 		{
;      56 			#asm("nop");	
	nop
;      57 		}		
	RJMP _0xB
_0xD:
;      58 		sh++;
	SUBI R16,-1
;      59 	}
	RJMP _0x8
_0xA:
;      60 }
	LD   R16,Y+
	RET
;      61 
;      62 //функции для запуска вычислений температуры в датчиках
;      63 void dat_init();	
;      64 void dat_conf(unsigned char adr);
;      65 
;      66 //функция получения результатов датчика
;      67 void get_temp(unsigned char adr);       
;      68 
;      69 
;      70 unsigned char re_mes[4];   //сообщение, которое будет принято по USART от ПЭВМ         

	.DSEG
_re_mes:
	.BYTE 0x4
;      71 unsigned char us_s = 0;
;      72 
;      73 interrupt [USART_RXC] void u_rec()   //прерывание по приему байта с интерфейса usart
;      74 { 	                          	                                            

	.CSEG
_u_rec:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;      75 	//каждый байт записывается в строку re_mes, длинной 4 символа
;      76 	//если символ = Enter данные воодятся как пороговая температура и отчет датчиков начинается сначала
;      77 	re_mes[us_s] = UDR;           
	MOV  R26,R9
	LDI  R27,0
	SUBI R26,LOW(-_re_mes)
	SBCI R27,HIGH(-_re_mes)
	IN   R30,0xC
	ST   X,R30
;      78 	if (re_mes[us_s] == 0x0D)
	MOV  R30,R9
	LDI  R31,0
	SUBI R30,LOW(-_re_mes)
	SBCI R31,HIGH(-_re_mes)
	LD   R30,Z
	CPI  R30,LOW(0xD)
	BRNE _0xE
;      79 	{                         
;      80 		porog_temp = atoi(re_mes);
	LDI  R30,LOW(_re_mes)
	LDI  R31,HIGH(_re_mes)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _atoi
	MOV  R4,R30
;      81 		us_s = 0;
	CLR  R9
;      82 		reset();
	RCALL _reset
;      83 	}
;      84 	else
	RJMP _0xF
_0xE:
;      85 	{         
;      86 		us_s++;
	INC  R9
;      87 		if (us_s > 3)
	LDI  R30,LOW(3)
	CP   R30,R9
	BRSH _0x10
;      88 			us_s = 0;
	CLR  R9
;      89 	}
_0x10:
_0xF:
;      90 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;      91 
;      92 interrupt [TIM1_COMPA] void timer_int()
;      93 { 	 
_timer_int:
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
;      94 	fl = 0; //при прерывании таймера Т1 сбрасывается флаг, и переключается номер отображаемого датчика.
	CLR  R7
;      95 }    
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	RETI
;      96 
;      97 void main(void)
;      98 {            
_main:
;      99 
;     100 	DDRB = 0xFF; //порт B на выход для работы с 8ми сегментным индикатором
	LDI  R30,LOW(255)
	OUT  0x17,R30
;     101 	PORTB = 0x00; //начальное значение - погашен.        
	RCALL SUBOPT_0x0
;     102 	
;     103 	DDRD = 0b11111100; //порт С на выход для работы с катодами 8ми сегментных индикаторов
	LDI  R30,LOW(252)
	OUT  0x11,R30
;     104 	PORTD = 0b11111100; //начальнео значение - ни один из разрядов не работает                                                                 
	OUT  0x12,R30
;     105 	
;     106 	//настройка USART
;     107 	UBRRL = 1; //скорость 250к бод
	LDI  R30,LOW(1)
	OUT  0x9,R30
;     108         UCSRB = (1 << RXCIE) | (1 << RXEN) | (1 << TXEN); // прерывание после завершения приема, прием и передача разрешены.
	LDI  R30,LOW(152)
	OUT  0xA,R30
;     109         
;     110 	//настройка TWI (I2C)
;     111 	//предделители устанавливаются таким образом, чтобы частота синхросигнала 
;     112 	//SCL = 100 КГц (требуемая частота работы датчика температуры DS1621 по спецификации.)
;     113 	//F_SCL = F_CPU / ( 16 + 2 * TWBR * 4^TWPS ) - формула расчета.
;     114 	TWBR = 0x20;      //установка делителя частоты работы i2c. 
	LDI  R30,LOW(32)
	OUT  0x0,R30
;     115 	TWSR = 0x00;      //установка предделителя частоты работы i2c, начальное состояние шины - нулевое.  	
	LDI  R30,LOW(0)
	OUT  0x1,R30
;     116 	
;     117 	//настройка таймера T1, который будет работать в режиме "сравнения". 
;     118 	OCR1AH = 0x5B; //запись значений в регистр совпадения, сначала старший байт, потом младший
	LDI  R30,LOW(91)
	OUT  0x2B,R30
;     119 	OCR1AL = 0x8D; //значение выбиралось исходя из задержки = 3с, делителя на 1024 и частоты МК = 8МГц.       
	LDI  R30,LOW(141)
	OUT  0x2A,R30
;     120 	TIMSK = (1 << OCIE1A); //включено прерывание по совпадению счетного регистра таймера Т1 канала A с регистром сравнения
	LDI  R30,LOW(16)
	OUT  0x39,R30
;     121 	#asm("sei");  
	sei
;     122 	TCCR1A = 0;
	LDI  R30,LOW(0)
	OUT  0x2F,R30
;     123 	TCCR1B = (1 << WGM12); //сброс счетного счетчика при совпадении   
	LDI  R30,LOW(8)
	OUT  0x2E,R30
;     124 	//TCCR1B |= (0 << CS10) | (0 << CS12); //установка делителя = 1024  выкл
;     125 	
;     126 	
;     127 	
;     128 	
;     129 	
;     130 	dat_init(); //вычисление температуры датчиками   
	RCALL _dat_init
;     131 	delay_ms(1000); // время на вычисление температуры датчиками                               
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	RCALL SUBOPT_0x1
;     132 
;     133 	while (1)
_0x11:
;     134 	{       		
;     135 		unsigned char i; //счетчик перебора разрядов семисегментного дисплея 
;     136 		unsigned char f2 = 0; //флаг проверки: превышает ли показания датчика пороговое значение.
;     137 		//если f2 = 1, то значения печатаются и передаются по USART, если 0 - переход к след.датчику
;     138 		fl = 0xFF;
	SBIW R28,2
	LDI  R24,1
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x14*2)
	LDI  R31,HIGH(_0x14*2)
	RCALL __INITLOCB
;	i -> Y+1
;	f2 -> Y+0
	LDI  R30,LOW(255)
	MOV  R7,R30
;     139 
;     140 		get_temp(dat_adr[dat_num-1]);
	MOV  R30,R8
	SUBI R30,LOW(1)
	RCALL SUBOPT_0x2
	RCALL _get_temp
;     141 		 
;     142                 
;     143 
;     144 	        if ( ((dat_temp1 < 0x80) && (porog_temp < 0x80)) || ((dat_temp1 >= 0x80) && (porog_temp >= 0x80)) )
	RCALL SUBOPT_0x3
	BRSH _0x16
	RCALL SUBOPT_0x4
	BRLO _0x18
_0x16:
	RCALL SUBOPT_0x3
	BRLO _0x19
	RCALL SUBOPT_0x4
	BRSH _0x18
_0x19:
	RJMP _0x15
_0x18:
;     145 	        	if (dat_temp1 >= porog_temp)
	CP   R5,R4
	BRLO _0x1C
;     146 	        		f2 = 1;
	LDI  R30,LOW(1)
	RJMP _0x53
;     147 	        	else
_0x1C:
;     148 	        		f2 = 0;
	LDI  R30,LOW(0)
_0x53:
	ST   Y,R30
;     149 	        else		
	RJMP _0x1E
_0x15:
;     150                 {
;     151 	        	if ((dat_temp1 >= 0x80) && (porog_temp < 0x80))
	RCALL SUBOPT_0x3
	BRLO _0x20
	RCALL SUBOPT_0x4
	BRLO _0x21
_0x20:
	RJMP _0x1F
_0x21:
;     152 	        		f2 = 0;
	LDI  R30,LOW(0)
	ST   Y,R30
;     153 		        if ((dat_temp1 < 0x80) && (porog_temp >= 0x80))
_0x1F:
	RCALL SUBOPT_0x3
	BRSH _0x23
	RCALL SUBOPT_0x4
	BRSH _0x24
_0x23:
	RJMP _0x22
_0x24:
;     154 		        	f2 = 1;
	LDI  R30,LOW(1)
	ST   Y,R30
;     155 	        } 
_0x22:
_0x1E:
;     156 	        
;     157 	 			
;     158 		if (f2) //если температура с датчика превышает пороговую
	LD   R30,Y
	CPI  R30,0
	BREQ _0x25
;     159 		{
;     160 			decode(); //подготавливается строка для отображение на блоке из семисегментных индикаторов
	RCALL _decode
;     161 			temp_transmit();
	RCALL _temp_transmit
;     162 			TCCR1B |= (1 << CS10) | (1 << CS12); //установка делителя = 1024  вкл
	IN   R30,0x2E
	ORI  R30,LOW(0x5)
	OUT  0x2E,R30
;     163 							     //запускается таймер, отсчитывающий 3 секунды
;     164 							     //на отоборажение результатов этого датчика 
;     165 							     
;     166 			while (fl)                           //печать в блок семисегментного индикатора ПОРАЗРЯДНО
_0x26:
	TST  R7
	BREQ _0x28
;     167 			{		
;     168 				PORTB = message[i];		
	LDD  R30,Y+1
	LDI  R31,0
	SUBI R30,LOW(-_message)
	SBCI R31,HIGH(-_message)
	LD   R30,Z
	OUT  0x18,R30
;     169 				PORTD = razr[4 - i];
	RCALL SUBOPT_0x5
	SUB  R30,R26
	LDI  R26,LOW(_razr)
	LDI  R27,HIGH(_razr)
	RCALL SUBOPT_0x6
	OUT  0x12,R30
;     170 				delay_ms(3);      
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RCALL SUBOPT_0x1
;     171 				PORTB = 0;
	RCALL SUBOPT_0x0
;     172 				i++;
	LDD  R30,Y+1
	SUBI R30,-LOW(1)
	STD  Y+1,R30
;     173 				if (i > 4)
	RCALL SUBOPT_0x5
	CP   R30,R26
	BRSH _0x29
;     174 					i = 0;	
	LDI  R30,LOW(0)
	STD  Y+1,R30
;     175 			}
_0x29:
	RJMP _0x26
_0x28:
;     176 		}
;     177 		
;     178 		dat_num++;
_0x25:
	INC  R8
;     179 		if (dat_num == 8)
	LDI  R30,LOW(8)
	CP   R30,R8
	BRNE _0x2A
;     180 			dat_num = 1;
	LDI  R30,LOW(1)
	MOV  R8,R30
;     181 	}	
_0x2A:
	ADIW R28,2
	RJMP _0x11
;     182 	
;     183 	
;     184 }
_0x2B:
	RJMP _0x2B
;     185 
;     186                         
;     187 void dat_conf(unsigned char adr)
;     188 {     
_dat_conf:
;     189 	//start	 
;     190        	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
	RCALL SUBOPT_0x7
;     191        	while (!(TWCR & (1 << TWINT) )); 
_0x2C:
	RCALL SUBOPT_0x8
	BREQ _0x2C
;     192        	
;     193        	//вводим адресс датчика, режим записи и отправляем
;     194        	TWDR = adr;
	RCALL SUBOPT_0x9
;     195        	TWCR = (1 << TWINT) | (1 << TWEN); 
;     196        	while (!(TWCR & (1 << TWINT) )); 
_0x2F:
	RCALL SUBOPT_0x8
	BREQ _0x2F
;     197        	
;     198        	//передаем команду датчику на вычисление результатов
;     199        	TWDR = 0xEE;
	LDI  R30,LOW(238)
	RCALL SUBOPT_0xA
;     200        	TWCR = (1 << TWINT) | (1 << TWEN); 
;     201        	while (!(TWCR & (1 << TWINT) ));   
_0x32:
	RCALL SUBOPT_0x8
	BREQ _0x32
;     202        	
;     203        	//stop
;     204 	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);
	RCALL SUBOPT_0xB
;     205 }
	RJMP _0x52
;     206 
;     207 void dat_init()
;     208 {           
_dat_init:
;     209 	unsigned char q = 0;
;     210 	while (q < 7)
	ST   -Y,R16
;	q -> R16
	LDI  R16,0
_0x35:
	CPI  R16,7
	BRSH _0x37
;     211 	{
;     212 		dat_conf(dat_adr[q]);
	MOV  R30,R16
	RCALL SUBOPT_0x2
	RCALL _dat_conf
;     213 		q++;
	SUBI R16,-1
;     214 	}	
	RJMP _0x35
_0x37:
;     215 }              
	LD   R16,Y+
	RET
;     216 
;     217 void get_temp(unsigned char adr)
;     218 {
_get_temp:
;     219 	//start	 
;     220        	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
	RCALL SUBOPT_0x7
;     221        	while (!(TWCR & (1 << TWINT) )); 
_0x38:
	RCALL SUBOPT_0x8
	BREQ _0x38
;     222        	
;     223        	//вводим адресс датчика, режим записи и отправляем
;     224        	TWDR = adr;
	RCALL SUBOPT_0x9
;     225        	TWCR = (1 << TWINT) | (1 << TWEN); 
;     226        	while (!(TWCR & (1 << TWINT) ));
_0x3B:
	RCALL SUBOPT_0x8
	BREQ _0x3B
;     227        	
;     228        	//передаем команду датчику на вывод результатов
;     229        	TWDR = 0xAA;
	LDI  R30,LOW(170)
	RCALL SUBOPT_0xA
;     230        	TWCR = (1 << TWINT) | (1 << TWEN); 
;     231        	while (!(TWCR & (1 << TWINT) ));        	
_0x3E:
	RCALL SUBOPT_0x8
	BREQ _0x3E
;     232        	
;     233 	//повторный старт	 
;     234        	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
	RCALL SUBOPT_0x7
;     235        	while (!(TWCR & (1 << TWINT) ));        	
_0x41:
	RCALL SUBOPT_0x8
	BREQ _0x41
;     236        	
;     237        	//вводим адресс датчика, режим чтения и отправляем       	   
;     238        	TWDR = (adr | 1);
	LD   R30,Y
	ORI  R30,1
	RCALL SUBOPT_0xA
;     239        	TWCR = (1 << TWINT) | (1 << TWEN); 
;     240        	while (!(TWCR & (1 << TWINT) ));       	       	
_0x44:
	RCALL SUBOPT_0x8
	BREQ _0x44
;     241        	
;     242    	//включаем TWI, получаем первый байт температуры, посылаем ответ ACK
;     243    	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA); 
	LDI  R30,LOW(196)
	OUT  0x36,R30
;     244        	while (!(TWCR & (1 << TWINT) ));             	
_0x47:
	RCALL SUBOPT_0x8
	BREQ _0x47
;     245         dat_temp1 = TWDR;  
	IN   R5,3
;     246        	
;     247 	//включаем TWI, получаем второй байт температуры, посылаем ответ NAK
;     248         TWCR = (1 << TWINT) | (1 << TWEN) | (0 << TWEA);
	LDI  R30,LOW(132)
	OUT  0x36,R30
;     249        	while (!(TWCR & (1 << TWINT) ));             	
_0x4A:
	RCALL SUBOPT_0x8
	BREQ _0x4A
;     250        	dat_temp2 = TWDR;  
	IN   R6,3
;     251        	
;     252        	//stop
;     253 	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);		
	RCALL SUBOPT_0xB
;     254 }
_0x52:
	ADIW R28,1
	RET
;     255 
;     256 void decode()
;     257 {
_decode:
;     258 	unsigned char r1, r2, r3; 
;     259                 
;     260 	message[0] = digit[dat_num];   
	RCALL __SAVELOCR3
;	r1 -> R16
;	r2 -> R17
;	r3 -> R18
	MOV  R30,R8
	RCALL SUBOPT_0xC
	STS  _message,R30
;     261 	usart_message[0] = dat_num + 0x30;
	MOV  R30,R8
	SUBI R30,-LOW(48)
	STS  _usart_message,R30
;     262 	usart_message[1] = ' '; // пробел
	LDI  R30,LOW(32)
	__PUTB1MN _usart_message,1
;     263 	if (dat_temp1 & 0b10000000) 	
	SBRS R5,7
	RJMP _0x4D
;     264 	{       		
;     265 		dat_temp1 = (dat_temp1 ^ 0b11111111) + 1;  
	LDI  R30,LOW(255)
	EOR  R30,R5
	SUBI R30,-LOW(1)
	MOV  R5,R30
;     266 		if (dat_temp2 == 0x80) dat_temp1--;
	RCALL SUBOPT_0xD
	BRNE _0x4E
	DEC  R5
;     267 		message[1] = digit[10];  
_0x4E:
	__GETW1MN _digit,20
	__PUTB1MN _message,1
;     268 		usart_message[2] = '-';
	LDI  R30,LOW(45)
	__PUTB1MN _usart_message,2
;     269 	}
;     270 	else
	RJMP _0x4F
_0x4D:
;     271 	{
;     272 		r3 = dat_temp1 / 100; 
	RCALL SUBOPT_0xE
	RCALL __DIVB21U
	MOV  R18,R30
;     273                 message[1] = digit[r3];    
	MOV  R30,R18
	RCALL SUBOPT_0xC
	__PUTB1MN _message,1
;     274                	usart_message[2] = r3 + 0x30;
	MOV  R30,R18
	SUBI R30,-LOW(48)
	__PUTB1MN _usart_message,2
;     275   	}
_0x4F:
;     276 	dat_temp1 %= 100;
	RCALL SUBOPT_0xE
	RCALL SUBOPT_0xF
;     277 	r2 = dat_temp1 / 10;
	RCALL SUBOPT_0x10
	RCALL __DIVB21U
	MOV  R17,R30
;     278 	message[2] = digit[r2];       
	MOV  R30,R17
	RCALL SUBOPT_0xC
	__PUTB1MN _message,2
;     279 	usart_message[3] = r2 + 0x30;    
	MOV  R30,R17
	SUBI R30,-LOW(48)
	__PUTB1MN _usart_message,3
;     280 	
;     281 	dat_temp1 %= 10;       
	RCALL SUBOPT_0x10
	RCALL SUBOPT_0xF
;     282 	r1 = dat_temp1;        
	MOV  R16,R5
;     283 	message[3] = (digit[r1] | 0b10000000);    
	MOV  R30,R16
	RCALL SUBOPT_0xC
	ORI  R30,0x80
	__PUTB1MN _message,3
;     284 	usart_message[4] = r1 + 0x30;
	MOV  R30,R16
	SUBI R30,-LOW(48)
	__PUTB1MN _usart_message,4
;     285 	usart_message[5] = '.';
	LDI  R30,LOW(46)
	__PUTB1MN _usart_message,5
;     286 	if (dat_temp2 == 0x80)
	RCALL SUBOPT_0xD
	BRNE _0x50
;     287 	{
;     288 		message[4] = digit[5];
	__GETW1MN _digit,10
	__PUTB1MN _message,4
;     289 		usart_message[6] = '5';
	LDI  R30,LOW(53)
	__PUTB1MN _usart_message,6
;     290 	}
;     291 	else                          
	RJMP _0x51
_0x50:
;     292 	{
;     293 		message[4] = digit[0]; 
	LDS  R30,_digit
	LDS  R31,_digit+1
	__PUTB1MN _message,4
;     294 		usart_message[6] = '0';
	LDI  R30,LOW(48)
	__PUTB1MN _usart_message,6
;     295 	}    
_0x51:
;     296 	usart_message[7] = 0x0D; //переход на следующую строку
	LDI  R30,LOW(13)
	__PUTB1MN _usart_message,7
;     297 }
	RCALL __LOADLOCR3
	ADIW R28,3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x0:
	LDI  R30,LOW(0)
	OUT  0x18,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x1:
	ST   -Y,R31
	ST   -Y,R30
	RJMP _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x2:
	LDI  R26,LOW(_dat_adr)
	LDI  R27,HIGH(_dat_adr)
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	RCALL __GETW1P
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES
SUBOPT_0x3:
	LDI  R30,LOW(128)
	CP   R5,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES
SUBOPT_0x4:
	LDI  R30,LOW(128)
	CP   R4,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x5:
	LDD  R26,Y+1
	LDI  R30,LOW(4)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES
SUBOPT_0x6:
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	RCALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES
SUBOPT_0x7:
	LDI  R30,LOW(164)
	OUT  0x36,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES
SUBOPT_0x8:
	IN   R30,0x36
	ANDI R30,LOW(0x80)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x9:
	LD   R30,Y
	OUT  0x3,R30
	LDI  R30,LOW(132)
	OUT  0x36,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES
SUBOPT_0xA:
	OUT  0x3,R30
	LDI  R30,LOW(132)
	OUT  0x36,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xB:
	LDI  R30,LOW(148)
	OUT  0x36,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES
SUBOPT_0xC:
	LDI  R26,LOW(_digit)
	LDI  R27,HIGH(_digit)
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xD:
	LDI  R30,LOW(128)
	CP   R30,R6
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xE:
	MOV  R26,R5
	LDI  R30,LOW(100)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0xF:
	RCALL __MODB21U
	MOV  R5,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x10:
	MOV  R26,R5
	LDI  R30,LOW(10)
	RET

_atoi:
	ldd  r27,y+1
	ld   r26,y
__atoi0:
	ld   r30,x
	st   -y,r30
	rcall _isspace
	tst  r30
	breq __atoi1
	adiw r26,1
	rjmp __atoi0
__atoi1:
	clt
	ld   r30,x
	cpi  r30,'-'
	brne __atoi2
	set
	rjmp __atoi3
__atoi2:
	cpi  r30,'+'
	brne __atoi4
__atoi3:
	adiw r26,1
__atoi4:
	clr  r22
	clr  r23
__atoi5:
	ld   r30,x
	st   -y,r30
	rcall _isdigit
	tst  r30
	breq __atoi6
	mov  r30,r22
	mov  r31,r23
	lsl  r22
	rol  r23
	lsl  r22
	rol  r23
	add  r22,r30
	adc  r23,r31
	lsl  r22
	rol  r23
	ld   r30,x+
	clr  r31
	subi r30,'0'
	add  r22,r30
	adc  r23,r31
	rjmp __atoi5
__atoi6:
	mov  r30,r22
	mov  r31,r23
	brtc __atoi7
	com  r30
	com  r31
	adiw r30,1
__atoi7:
	adiw r28,2
	ret

_isdigit:
	ldi  r30,1
	ld   r31,y+
	cpi  r31,'0'
	brlo __isdigit0
	cpi  r31,'9'+1
	brlo __isdigit1
__isdigit0:
	clr  r30
__isdigit1:
	ret

_isspace:
	ldi  r30,1
	ld   r31,y+
	cpi  r31,' '
	breq __isspace1
	cpi  r31,9
	breq __isspace1
	cpi  r31,13
	breq __isspace1
	clr  r30
__isspace1:
	ret

_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x7D0
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__DIVB21U:
	CLR  R0
	LDI  R25,8
__DIVB21U1:
	LSL  R26
	ROL  R0
	SUB  R0,R30
	BRCC __DIVB21U2
	ADD  R0,R30
	RJMP __DIVB21U3
__DIVB21U2:
	SBR  R26,1
__DIVB21U3:
	DEC  R25
	BRNE __DIVB21U1
	MOV  R30,R26
	MOV  R26,R0
	RET

__MODB21U:
	RCALL __DIVB21U
	MOV  R30,R26
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD R26,R28
	ADC R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

