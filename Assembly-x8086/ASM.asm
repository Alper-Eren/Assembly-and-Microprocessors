STACKSG SEGMENT PARA STACK 'STACK'
	DW 80 DUP(?)			;STACK SEGMENTIMIZ
STACKSG ENDS

DATASG SEGMENT PARA 'DATA'
	N_SAYISI DW 10			;N SAYISINI TANIMLIYORUZ
DATASG ENDS

CODESG SEGMENT PARA 'CODE'
	ASSUME CS:CODESG, DS:DATASG, SS:STACKSG
							;CODE SEGMENTIMIZ
BASLA PROC FAR
	PUSH DS
	XOR AX, AX
	PUSH AX
	
	MOV AX, DATASG			;DATA SEGMENTIN TANIMI
	MOV DS, AX


	PUSH N_SAYISI			;N_SAYISINI PUSHLUYORUZ 
	CALL FAR PTR DNUM_PROC	;DNUM_PROCUMU CAGIRIYORUZ
	POP AX					;SONUCUMUZU AX UZERINDEN GERI ALIYORUZ
	CALL FAR PTR PRINTINT	;YAZDIRMAK ICIN PRINTINT PROCUNU CAGIRIYORUZ
	
	RETF
BASLA ENDP
	
DNUM_PROC PROC FAR
	
	PUSH N_SAYISI				
	PUSH AX
	PUSH BX 				;GEREKLI PUSH ISLEMLERI
	PUSH CX
	PUSH DX
	PUSH BP
	
	MOV BP, SP				;6 REG PUSHLADIGIMIZ ICIN 6X2 DEN 12 
	ADD BP, 16				;2 BYTE CS 2 BYTE DA IP TOPLAM 16 EKLEMEMIZ GEREKIYOR BP'YE
	
	MOV AX, [BP]			;YIGINDAKI PARAMETREYI AX'E ALIYORUZ
	CMP AX, 0				
	JE DNUM_0				;0'SA DNUM_0'A ATLIYORUZ
	CMP AX, 1
	JE DNUM_1				;1 VEYA 2 ISE DNUM_1'E ATLIYORUZ
	CMP AX, 2
	JE DNUM_1

	DEC AX					;AX=N-1 
	PUSH AX
	CALL FAR PTR DNUM_PROC	;D(N-1)
	POP BX					;BX=D(N-1)
	PUSH BX					
	CALL FAR PTR DNUM_PROC	;D(D(N-1))
	POP CX					;CX=D(D(N-1))
	DEC AX					;AX=N-2
	PUSH AX
	CALL FAR PTR DNUM_PROC	;D(N-2)
	POP DX					;DX=D(N-2)
	INC AX 					;AX=N-2 IDI +1 EKLIYORUZ AX=N-1 OLDU
	SUB AX, DX				;N-1-D(N-2)
	PUSH AX
	CALL DNUM_PROC			;D(N-1-D(N-2))
	POP AX 					;AX=D(N-1-D(N-2))
	
	ADD AX, CX				;AX=D(D(N-1))+D(N-1-D(N-2)) FONKSIYONUMUZU AX'TE ELDE ETTIK
	JMP EXIT

DNUM_0:
	MOV AX, 0				;D(0)=0 OLDUGU ICIN AX'E DIREKT 0 ATIYORUZ
	JMP EXIT
	
DNUM_1:
	MOV AX, 1				;D(1)=1 VE D(2)=1 OLDUGU ICIN AX'E DIREKT 1 ATIYORUZ
EXIT:
	MOV [BP], AX			;AX'TEKI DEGERI YIGINA ATIYORUZ
	POP BP
	POP DX
	POP CX					;PUSHLADIKLARIMIZI TAM TERSI SIRAYLA POPLUYORUZ
	POP BX
	POP AX
	POP N_SAYISI
	RETF 

DNUM_PROC ENDP

PRINTINT PROC 
	CMP AX, 0				;AX=0 MI DIYE KONTROL EDIYORUZ
	JNE DEVAM				;DEGILSE DEVAM ETIKETINE ATLIYORUZ
	
	PUSH AX					
	MOV AL, '0'
	MOV AH, 0EH				;10'LUK TABAN ICIN GEREKLI ATAMALARI YAPIYORUZ
	INT 10H
	POP AX
	
	RET

DEVAM:
	PUSH AX
	PUSH BX					;GEREKLI PUSH ISLEMLERI
	PUSH DX
	
	XOR DX, DX				;DX=0 
	CMP AX, 0				;AX'I TEKRAR KONTROL ETTIK
	JE SON					;0'SA EKRANA SIFIR YAZDIRDIK
	
	MOV BX, 10				;BX'E 10 DEGERINI ATADIK
	DIV BX					;10'A BOLUP BIRLER BASAMAGINDAN ITIBAREN YAZDIK
	CALL DEVAM
	
	MOV AX, DX				;DX'TEKI DEGERI AX'E ATIYORUZ
	ADD AL, '0'				
	MOV AH, 0EH				;10'LUK TABAN ICIN GEREKLI ATAMA VE INTERRUPT ISLEMI
	INT 10H
	
SON:
	POP DX
	POP BX					;PUSHLADIKLARIMIZI SIRASIYLA POPLUYORUZ	
	POP AX
	RET

PRINTINT ENDP
CODESG ENDS
	END BASLA