    processor 12F675
    #include <P12F675.INC>
;    __config 0x314C
;    __config _CPD_OFF & _CP_ON & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_ON & _INTRC_OSC_NOCLKOUT 
    __config _CPD_OFF & _CP_OFF & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_ON & _INTRC_OSC_NOCLKOUT 
    __idlocs 0x00FE

;   EEPROM-Data
;;; CV1  0x05
;;; CV61 0x06
;;; CV64 0x09
    Org 0x2100
    DE 0xFF, 0x06, 0x01, 0xFE, 0x81, 0x03, 0x02, 0x00   ;  ........
    DE 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60   ;  .......`
    DE 0x90, 0xB0, 0xA0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ;  ........

; RAM-Variable
LRAM_0x20 equ 0x20
LRAM_0x21 equ 0x21
LRAM_0x22 equ 0x22
LRAM_0x23 equ 0x23
LRAM_0x24 equ 0x24
LRAM_0x25 equ 0x25
LRAM_0x26 equ 0x26
LRAM_0x27 equ 0x27
LRAM_0x28 equ 0x28
LRAM_0x29 equ 0x29
EEPROM_ADDR equ 0x2A
EEPROM_DATA equ 0x2B
LRAM_0x2C equ 0x2C
LRAM_0x2D equ 0x2D
LRAM_0x2E equ 0x2E
LRAM_0x2F equ 0x2F
LRAM_0x30 equ 0x30
CV_1 equ 0x31
CV_61 equ 0x32
LRAM_0x33 equ 0x33
LRAM_0x34 equ 0x34
CV_64 equ 0x35
LRAM_0x36 equ 0x36
LRAM_0x37 equ 0x37
LRAM_0x38 equ 0x38
LRAM_0x39 equ 0x39
LRAM_0x3A equ 0x3A
LRAM_0x3B equ 0x3B
LRAM_0x3C equ 0x3C
LRAM_0x3D equ 0x3D
LRAM_0x3E equ 0x3E

; Program

    Org 0x0000

;   Reset-Vector
    GOTO MainStart
LADR_0x0001
    CLRF PCLATH          ; !!Bank Program-Page-Select
    ANDLW 0x0F           ;   b'00001111'  d'015'
    ADDWF PCL,F          ; !!Program-Counter-Modification
;   Interrupt-Vector
    RETLW 0x0D           ;   b'00001101'  d'013'
    RETLW 0x95           ;   b'10010101'  d'149'
    RETLW 0x25           ;   b'00100101'  d'037'  "%"
    RETLW 0x38           ;   b'00111000'  d'056'  "8"
    RETLW 0xB1           ;   b'10110001'  d'177'
    RETLW 0x29           ;   b'00101001'  d'041'  ")"
    RETLW 0x99           ;   b'10011001'  d'153'
    RETLW 0xB2           ;   b'10110010'  d'178'
    RETLW 0x2A           ;   b'00101010'  d'042'  "*"
    RETLW 0x9A           ;   b'10011010'  d'154'
    RETLW 0x8B           ;   b'10001011'  d'139'
    RETLW 0x13           ;   b'00010011'  d'019'
    RETLW 0xA3           ;   b'10100011'  d'163'
    RETLW 0x34           ;   b'00110100'  d'052'  "4"
    RETLW 0xAC           ;   b'10101100'  d'172'
    RETLW 0x1C           ;   b'00011100'  d'028'
LADR_0x0014
    CLRF PCLATH          ; !!Bank Program-Page-Select
    MOVF LRAM_0x21,W
    ADDWF PCL,F          ; !!Program-Counter-Modification
    RETLW 0x3E           ;   b'00111110'  d'062'  ">"
    RETLW 0x1C           ;   b'00011100'  d'028'
    RETLW 0x05           ;   b'00000101'  d'005'
    RETLW 0x86           ;   b'10000110'  d'134'
    RETLW 0x07           ;   b'00000111'  d'007'
    RETLW 0x00           ;   b'00000000'  d'000'
    RETLW 0x3C           ;   b'00111100'  d'060'  "<"
    RETLW 0x10           ;   b'00010000'  d'016'
    RETLW 0x11           ;   b'00010001'  d'017'
    RETLW 0x3F           ;   b'00111111'  d'063'  "?"
    RETLW 0x30           ;   b'00110000'  d'048'  "0"
    RETLW 0x31           ;   b'00110001'  d'049'  "1"
    RETLW 0x3D           ;   b'00111101'  d'061'  "="
    RETLW 0x0E           ;   b'00001110'  d'014'
    RETLW 0x0F           ;   b'00001111'  d'015'
    RETLW 0x35           ;   b'00110101'  d'053'  "5"
LADR_0x0027
    BCF LRAM_0x22,4
    BSF LRAM_0x22,5
    MOVLW 0xE6           ;   b'11100110'  d'230'
    MOVWF LRAM_0x20
LADR_0x002B
    CLRWDT
    MOVLW 0x03           ;   b'00000011'  d'003'
    BTFSS LRAM_0x20,0
    BTFSS LRAM_0x20,1
    GOTO LADR_0x0035
    CALL LADR_0x0052
    ADDWF LRAM_0x20,F
    BTFSC LRAM_0x23,7
    RETLW 0x00           ;   b'00000000'  d'000'
    MOVLW 0x04           ;   b'00000100'  d'004'
LADR_0x0035
    ADDWF LRAM_0x20,F
    BTFSS LRAM_0x20,7
    BCF LRAM_0x22,5
    BTFSC LRAM_0x22,3
    GOTO LADR_0x003F
    NOP
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x002B
    BSF LRAM_0x22,3
    GOTO LADR_0x0042
LADR_0x003F
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x002B
    BCF LRAM_0x22,3
LADR_0x0042
    BTFSC LRAM_0x22,4
    RETLW 0x00           ;   b'00000000'  d'000'
    BSF LRAM_0x22,4
    GOTO LADR_0x002B
    MOVLW 0x14           ;   b'00010100'  d'020'
    MOVWF LRAM_0x21
    CLRF LRAM_0x20
LADR_0x0049
    CLRWDT
    GOTO LADR_0x004B
LADR_0x004B
    DECFSZ LRAM_0x20,F
    GOTO LADR_0x0049
    DECFSZ LRAM_0x21,F
    GOTO LADR_0x0049
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x0050
    BSF LRAM_0x23,6
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x0052
    BTFSC TMR0,7         ; !!Bank!! TMR0 - OPTION_REG
    GOTO LADR_0x0058
    BCF LRAM_0x22,2
    BTFSC GPIO,5         ; !!Bank!! GPIO - TRISIO
    BSF LRAM_0x24,4
    RETLW 0x02           ;   b'00000010'  d'002'
LADR_0x0058
    BTFSS LRAM_0x22,2
    GOTO LADR_0x005D
    BTFSC GPIO,5         ; !!Bank!! GPIO - TRISIO
    BSF LRAM_0x24,4
    RETLW 0x02           ;   b'00000010'  d'002'
LADR_0x005D
    BSF LRAM_0x22,2
    MOVLW 0x01           ;   b'00000001'  d'001'
    ADDWF LRAM_0x2E,F
    BTFSS STATUS,DC
    GOTO LADR_0x006D
    BTFSC STATUS,C
    BSF LRAM_0x2E,7
    BSF LRAM_0x2E,2
    COMF LRAM_0x38,W
    ANDLW 0x07           ;   b'00000111'  d'007'
    ADDWF LRAM_0x2E,F
    BTFSS LRAM_0x23,6
    BSF LRAM_0x23,7
    BCF LRAM_0x23,6
    BSF LRAM_0x22,6
    RETLW 0x05           ;   b'00000101'  d'005'
LADR_0x006D
    NOP
    BTFSS LRAM_0x22,6
    RETLW 0x04           ;   b'00000100'  d'004'
    BCF LRAM_0x22,6
    BCF STATUS,C
    RLF LRAM_0x36,F
    BTFSC STATUS,C
    BSF LRAM_0x36,0
    BCF STATUS,C
    RLF LRAM_0x37,F
    BTFSC STATUS,C
    BSF LRAM_0x37,0
    BCF LRAM_0x23,0
    RETLW 0x06           ;   b'00000110'  d'006'
LADR_0x007B
    MOVWF FSR
    MOVF INDF,W
    MOVWF LRAM_0x28
    ANDLW 0x07           ;   b'00000111'  d'007'
    ADDWF PCL,F          ; !!Program-Counter-Modification
    RETLW 0xFF           ;   b'11111111'  d'255'
    RETLW 0xA5           ;   b'10100101'  d'165'
    RETLW 0xC8           ;   b'11001000'  d'200'
    RETLW 0xE0           ;   b'11100000'  d'224'
    RETLW 0x80           ;   b'10000000'  d'128'
    RETLW 0xA0           ;   b'10100000'  d'160'
    RETLW 0xC3           ;   b'11000011'  d'195'
    RETLW 0xE7           ;   b'11100111'  d'231'
LADR_0x0088
    CALL LADR_0x007B
    MOVWF INDF
    BTFSC FSR,0
    GOTO LADR_0x0090
    BCF LRAM_0x38,6
    BTFSC LRAM_0x28,6
    BSF LRAM_0x38,6
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x0090
    BCF LRAM_0x38,7
    BTFSC LRAM_0x28,6
    BSF LRAM_0x38,7
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x0094
    MOVLW 0x01           ;   b'00000001'  d'001'
    MOVWF EEPROM_ADDR
    RETLW 0x00           ;   b'00000000'  d'000'
MainStart
    BSF LRAM_0x23,5
    CLRWDT
    CLRF GPIO            ; !!Bank!! GPIO - TRISIO
    MOVLW 0xC1           ;   b'11000001'  d'193'
    TRIS GPIO            ; !! TRIS
    MOVLW 0xC5           ;   b'11000101'  d'197'
    OPTION               ; !! OPTION
    MOVLW 0x07           ;   b'00000111'  d'007'
    MOVWF CMCON          ; !!Bank!! CMCON - VRCON
    CALL LADR_0x03FF
    BSF STATUS,RP0       ; !!Bank Register-Bank(0/1)-Select
    MOVWF T1CON          ; !!Bank!! T1CON - OSCCAL
    CLRF ADCON0          ; !!Bank!! ADCON0 - ANSEL
    CLRF WPU             ; !!Bank!! Unimplemented - WPU
    BCF STATUS,RP0       ; !!Bank Register-Bank(0/1)-Select
    CLRF LRAM_0x2C
    CLRF LRAM_0x22
    CLRF LRAM_0x23
    CLRF LRAM_0x24
    BSF LRAM_0x23,5
LADR_0x00AB
    MOVLW 0x2D           ;   b'00101101'  d'045'  "-"
    MOVWF FSR
    MOVLW 0x12           ;   b'00010010'  d'018'
    MOVWF LRAM_0x28
    CALL LADR_0x0094
LADR_0x00B0
    CALL EEPROM_READ
    MOVF EEPROM_DATA,W
    MOVWF INDF
    INCF FSR,F
    DECFSZ LRAM_0x28,F
    GOTO LADR_0x00B0
    CLRF LRAM_0x2F
    CLRF LRAM_0x2E
    CLRF LRAM_0x30
    MOVLW 0x36           ;   b'00110110'  d'054'  "6"
    CALL LADR_0x0088
    MOVLW 0x37           ;   b'00110111'  d'055'  "7"
    CALL LADR_0x0088
    CALL LADR_0x0050
    CLRF LRAM_0x24
LADR_0x00BF
    MOVLW 0xC1           ;   b'11000001'  d'193'
    BTFSC CV_64,2
    MOVLW 0xF1           ;   b'11110001'  d'241'
    TRIS GPIO            ; !! Unknown Command
    BCF LRAM_0x22,0
LADR_0x00C4
    BTFSC LRAM_0x22,0
    GOTO LADR_0x00EC
LADR_0x00C6
    BCF LRAM_0x22,0
    BSF LRAM_0x22,5
    MOVLW 0x1C           ;   b'00011100'  d'028'
    ADDWF LRAM_0x30,W
    MOVWF LRAM_0x21
    CLRF LRAM_0x30
LADR_0x00CC
    MOVLW 0x0B           ;   b'00001011'  d'011'
    MOVWF LRAM_0x20
Read_DCC_Sginal
    CLRWDT
    CALL LADR_0x0052
    BTFSC LRAM_0x23,7
    GOTO LADR_0x015F
    SUBWF LRAM_0x20,F
    BTFSS LRAM_0x22,3
    GOTO Wait_DCC_Start
    NOP
Wait_DCC_Receive
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x00E2
    DECFSZ LRAM_0x20,F
    GOTO Wait_DCC_Receive
    BCF LRAM_0x22,5
    GOTO LADR_0x00CC
Wait_DCC_Start
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x00E2
    DECFSZ LRAM_0x20,F
    GOTO Wait_DCC_Start
    BCF LRAM_0x22,5
    GOTO LADR_0x00CC
LADR_0x00E2
    MOVLW 0x08           ;   b'00001000'  d'008'
    XORWF LRAM_0x22,F
    BTFSS LRAM_0x22,5
    GOTO LADR_0x00C4
    MOVLW 0x0C           ;   b'00001100'  d'012'
    MOVWF LRAM_0x20
    DECFSZ LRAM_0x21,F
    GOTO Read_DCC_Sginal
    BSF LRAM_0x22,0
    GOTO Read_DCC_Sginal
LADR_0x00EC
    CALL LADR_0x0050
    MOVLW 0x25           ;   b'00100101'  d'037'  "%"
    MOVWF FSR
    CLRF INDF
    BSF LRAM_0x22,4
    BCF LRAM_0x22,5
    CALL LADR_0x002B
    CLRF LRAM_0x29
    CLRF EEPROM_ADDR
    CLRF LRAM_0x28
    MOVLW 0x06           ;   b'00000110'  d'006'
    MOVWF EEPROM_DATA
LADR_0x00F8
    MOVLW 0x08           ;   b'00001000'  d'008'
    MOVWF LRAM_0x21
LADR_0x00FA
    CALL LADR_0x0027
    BTFSC LRAM_0x23,7
    GOTO LADR_0x00C6
    BCF STATUS,C
    BTFSC LRAM_0x22,5
    BSF STATUS,C
    RLF INDF,F
    DECFSZ LRAM_0x21,F
    GOTO LADR_0x00FA
    INCF FSR,F
    CALL LADR_0x0050
    CALL LADR_0x0027
    BTFSC LRAM_0x22,5
    GOTO LADR_0x010B
    DECFSZ EEPROM_DATA,F
    GOTO LADR_0x00F8
    GOTO LADR_0x0117
LADR_0x010B
    MOVLW 0x05           ;   b'00000101'  d'005'
    SUBWF EEPROM_DATA,F
    BTFSC STATUS,C
    GOTO LADR_0x0117
    BCF LRAM_0x23,7
    MOVF LRAM_0x25,W
    XORWF LRAM_0x26,W
    XORWF LRAM_0x27,W
    XORWF LRAM_0x28,W
    XORWF LRAM_0x29,W
    XORWF EEPROM_ADDR,W
    BTFSS STATUS,Z
LADR_0x0117
    GOTO LADR_0x00BF
    BTFSC LRAM_0x23,5
    GOTO LADR_0x011B
LADR_0x011A
    GOTO LADR_0x01E7
LADR_0x011B
    MOVLW 0x04           ;   b'00000100'  d'004'
    CALL LADR_0x037D
    MOVF EEPROM_DATA,W
    XORLW 0x81           ;   b'10000001'  d'129'
    BCF LRAM_0x23,5
    BTFSC STATUS,Z
    GOTO LADR_0x0150
    MOVLW 0x08           ;   b'00001000'  d'008'
    XORWF EEPROM_DATA,W
    BTFSC STATUS,Z
    GOTO LADR_0x012C
    MOVLW 0x03           ;   b'00000011'  d'003'
    CALL LADR_0x037D
    MOVF EEPROM_DATA,W
    XORLW 0xFE           ;   b'11111110'  d'254'
    BTFSC STATUS,Z
    GOTO LADR_0x0150
LADR_0x012C
    CLRF FSR
    CALL LADR_0x0094
    MOVLW 0x06           ;   b'00000110'  d'006'
    CALL LADR_0x0369
    MOVLW 0x01           ;   b'00000001'  d'001'
    CALL LADR_0x0369
    MOVLW 0xFE           ;   b'11111110'  d'254'
    CALL LADR_0x0369
    INCF EEPROM_ADDR,F
    MOVLW 0x03           ;   b'00000011'  d'003'
    CALL LADR_0x0369
    MOVLW 0x02           ;   b'00000010'  d'002'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x00           ;   b'00000000'  d'000'
    CALL LADR_0x0369
    MOVLW 0x60           ;   b'01100000'  d'096'  "`"
    CALL LADR_0x0369
    MOVLW 0x04           ;   b'00000100'  d'004'
    MOVWF EEPROM_ADDR
    MOVLW 0x81           ;   b'10000001'  d'129'
    CALL LADR_0x0369
    GOTO LADR_0x00AB
LADR_0x0150
    BTFSS CV_1,7
    GOTO LADR_0x011A
    BCF CV_1,7
    MOVF LRAM_0x2D,F
    BTFSC STATUS,Z
    GOTO LADR_0x00BF
    CALL LADR_0x0094
    BCF LRAM_0x2D,5
    MOVF LRAM_0x2D,W
    CALL LADR_0x0369
    MOVLW 0x05           ;   b'00000101'  d'005'
    MOVWF EEPROM_ADDR
    MOVF CV_1,W
    CALL LADR_0x0369
    GOTO LADR_0x00BF
LADR_0x015F
    BCF LRAM_0x22,0
    BCF LRAM_0x23,7
    BTFSS LRAM_0x2D,2
    GOTO LADR_0x00BF
    BSF LRAM_0x24,7
    BSF LRAM_0x23,5
    GOTO LADR_0x02BE
LADR_0x0166
    BTFSC CV_61,1
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    GOTO LADR_0x0190
LADR_0x0170
    MOVWF LRAM_0x20
    CALL LADR_0x01AC
    CALL LADR_0x017D
    CALL LADR_0x01AC
    CALL LADR_0x017D
    CALL LADR_0x01AC
    CALL LADR_0x017D
    CALL LADR_0x01AC
    CALL LADR_0x017D
    CALL LADR_0x01AC
    CALL LADR_0x017D
    CALL LADR_0x01AC
    GOTO LADR_0x017D
LADR_0x017D
    RLF LRAM_0x20,F
    BTFSC CV_61,1
    BTFSS LRAM_0x20,6
    RETLW 0x00           ;   b'00000000'  d'000'
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BCF LRAM_0x24,0
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BTFSC LRAM_0x20,6
    BSF LRAM_0x24,0
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x019D
LADR_0x0190
    BTFSS CV_61,1
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC LRAM_0x22,3
    GOTO LADR_0x0194
LADR_0x0194
    GOTO LADR_0x0195
LADR_0x0195
    GOTO LADR_0x0196
LADR_0x0196
    GOTO LADR_0x0197
LADR_0x0197
    GOTO LADR_0x0198
LADR_0x0198
    NOP
    BTFSC LRAM_0x24,0
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    NOP
    GOTO LADR_0x019D
LADR_0x019D
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    NOP
    BTFSC LRAM_0x24,0
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x01A2
LADR_0x01A2
    GOTO LADR_0x01A3
LADR_0x01A3
    NOP
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x01A6
LADR_0x01A6
    GOTO LADR_0x01A7
LADR_0x01A7
    BTFSC LRAM_0x24,0
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    GOTO LADR_0x01AA
LADR_0x01AA
    BCF GPIO,1           ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x01AC
    BTFSS LRAM_0x22,3
    GOTO LADR_0x01C0
    BCF LRAM_0x22,3
LADR_0x01AF
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSS GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    GOTO LADR_0x01AF
LADR_0x01C0
    BSF LRAM_0x22,3
LADR_0x01C1
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    BTFSC GPIO,0         ; !!Bank!! GPIO - TRISIO
    RETLW 0x00           ;   b'00000000'  d'000'
    GOTO LADR_0x01C1
LADR_0x01D2
    BSF STATUS,C
    BTFSS LRAM_0x26,7
    BTFSS LRAM_0x26,6
    GOTO LADR_0x01D7
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x01D7
    MOVF LRAM_0x26,W
    XORLW 0x3F           ;   b'00111111'  d'063'  "?"
    BTFSS STATUS,Z
    BCF STATUS,C
    RETLW 0x01           ;   b'00000001'  d'001'
LADR_0x01DC
    MOVWF LRAM_0x21
LADR_0x01DD
    DECFSZ LRAM_0x21,F
    GOTO LADR_0x01DD
    RETLW 0x00           ;   b'00000000'  d'000'
LADR_0x01E0
    CLRF LRAM_0x2C
    MOVF LRAM_0x26,W
    BTFSC STATUS,Z
    GOTO LADR_0x01E5
    GOTO LADR_0x022C
LADR_0x01E5
    INCF LRAM_0x2C,F
    GOTO LADR_0x00AB
LADR_0x01E7
    BCF LRAM_0x24,0
    BCF CV_61,1
    INCF LRAM_0x25,W
    BTFSC STATUS,Z
    GOTO LADR_0x028D
    BSF LRAM_0x24,7
    CALL LADR_0x01AC
    BTFSS LRAM_0x25,7
    GOTO LADR_0x0209
    BTFSS LRAM_0x25,6
    GOTO LADR_0x029D
    BTFSC LRAM_0x2D,5
    GOTO LADR_0x01F7
LADR_0x01F4
    MOVF LRAM_0x27,W
    MOVWF LRAM_0x26
    GOTO LADR_0x0265
LADR_0x01F7
    BCF LRAM_0x24,1
    MOVF LRAM_0x34,W
    XORWF LRAM_0x26,W
    BTFSS STATUS,Z
    GOTO LADR_0x01F4
    BSF LRAM_0x24,1
    MOVF LRAM_0x33,W
    XORWF LRAM_0x25,W
    ANDLW 0x3F           ;   b'00111111'  d'063'  "?"
    BTFSS STATUS,Z
    GOTO LADR_0x01F4
    MOVF LRAM_0x27,W
    MOVWF LRAM_0x26
    MOVF LRAM_0x28,W
    MOVWF LRAM_0x27
    MOVF LRAM_0x29,W
    MOVWF LRAM_0x28
    GOTO LADR_0x021A
LADR_0x0209
    MOVF LRAM_0x25,W
    BTFSC STATUS,Z
    GOTO LADR_0x01E0
    ANDLW 0xF0           ;   b'11110000'  d'240'
    XORLW 0x70           ;   b'01110000'  d'112'  "p"
    BTFSS STATUS,Z
    GOTO LADR_0x0214
    BCF LRAM_0x24,7
    MOVF LRAM_0x2C,W
    BTFSS STATUS,Z
    GOTO LADR_0x02F6
LADR_0x0214
    CLRF LRAM_0x2C
    MOVF LRAM_0x25,W
    XORWF CV_1,W
    BTFSS LRAM_0x2D,5
    BTFSS STATUS,Z
    GOTO LADR_0x0265
LADR_0x021A
    BSF LRAM_0x24,6
    MOVF LRAM_0x26,W
    XORLW 0xEC           ;   b'11101100'  d'236'
    BTFSS LRAM_0x3B,5
    BTFSS STATUS,Z
    GOTO LADR_0x022A
    MOVF LRAM_0x27,W
    MOVWF EEPROM_ADDR
    MOVF LRAM_0x28,W
    MOVWF LRAM_0x26
    BSF LRAM_0x25,3
    MOVLW 0x01           ;   b'00000001'  d'001'
    MOVWF LRAM_0x2C
    CALL LADR_0x0319
    BSF LRAM_0x23,5
    GOTO LADR_0x00AB
LADR_0x022A
    BTFSC CV_61,1
    BSF LRAM_0x24,0
LADR_0x022C
    BTFSC LRAM_0x26,7
    BTFSC LRAM_0x26,6
    GOTO LADR_0x024E
    BSF LRAM_0x23,1
    BTFSS CV_64,2
    GOTO LADR_0x024E
    MOVF LRAM_0x2F,W
    BTFSC CV_64,3
    BTFSC LRAM_0x23,3
    GOTO LADR_0x0237
    MOVLW 0x00           ;   b'00000000'  d'000'
LADR_0x0237
    MOVWF LRAM_0x21
    SWAPF LRAM_0x21,W
    CALL LADR_0x0001
    MOVWF EEPROM_ADDR
    MOVF LRAM_0x21,W
    CALL LADR_0x0001
    MOVWF EEPROM_DATA
    XORWF EEPROM_ADDR,W
    MOVWF LRAM_0x29
    BTFSC CV_64,3
    GOTO LADR_0x0246
    MOVLW 0x31           ;   b'00110001'  d'049'  "1"
    BTFSS LRAM_0x29,7
    MOVLW 0x29           ;   b'00101001'  d'041'  ")"
    GOTO LADR_0x0249
LADR_0x0246
    MOVLW 0x25           ;   b'00100101'  d'037'  "%"
    BTFSS LRAM_0x29,7
    MOVLW 0x38           ;   b'00111000'  d'056'  "8"
LADR_0x0249
    MOVWF LRAM_0x29
    BTFSC LRAM_0x23,4
    BSF LRAM_0x23,3
    BSF LRAM_0x23,4
    GOTO LADR_0x0283
LADR_0x024E
    BSF LRAM_0x24,7
    CALL LADR_0x01D2
    BTFSS STATUS,C
    GOTO LADR_0x0261
    ANDLW 0x01           ;   b'00000001'  d'001'
    BTFSS STATUS,Z
    GOTO LADR_0x025E
    BTFSC LRAM_0x2D,1
    GOTO LADR_0x025A
    BCF LRAM_0x3C,4
    BTFSC LRAM_0x26,4
    BSF LRAM_0x3C,4
LADR_0x025A
    BCF LRAM_0x22,7
    BTFSS LRAM_0x26,5
    BSF LRAM_0x22,7
    GOTO LADR_0x0261
LADR_0x025E
    BCF LRAM_0x22,7
    BTFSS LRAM_0x27,7
    BSF LRAM_0x22,7
LADR_0x0261
    CALL LADR_0x01AC
    CALL LADR_0x0166
    MOVLW 0xF7           ;   b'11110111'  d'247'
    GOTO LADR_0x029E
LADR_0x0265
    BTFSC CV_61,1
    BTFSS CV_64,4
    GOTO LADR_0x029D
    CALL LADR_0x01D2
    BTFSS STATUS,C
    GOTO LADR_0x029D
    BTFSS LRAM_0x2D,5
    GOTO LADR_0x0279
    BTFSC LRAM_0x24,Z
    GOTO LADR_0x0274
    BSF LRAM_0x24,2
    MOVLW 0x2A           ;   b'00101010'  d'042'  "*"
    MOVWF LRAM_0x29
    MOVF LRAM_0x34,W
    GOTO LADR_0x027C
LADR_0x0274
    BCF LRAM_0x24,2
    MOVLW 0x0B           ;   b'00001011'  d'011'
    MOVWF LRAM_0x29
    MOVF LRAM_0x33,W
    GOTO LADR_0x027C
LADR_0x0279
    MOVLW 0x19           ;   b'00011001'  d'025'
    MOVWF LRAM_0x29
    MOVF CV_1,W
LADR_0x027C
    MOVWF LRAM_0x21
    SWAPF LRAM_0x21,W
    CALL LADR_0x0001
    MOVWF EEPROM_ADDR
    MOVF LRAM_0x21,W
    CALL LADR_0x0001
    MOVWF EEPROM_DATA
LADR_0x0283
    CALL LADR_0x01AC
    CALL LADR_0x0166
    MOVF LRAM_0x29,W
    CALL LADR_0x0170
    MOVF EEPROM_ADDR,W
    CALL LADR_0x0170
    MOVF EEPROM_DATA,W
    CALL LADR_0x0170
    MOVLW 0xE5           ;   b'11100101'  d'229'
    GOTO LADR_0x029E
LADR_0x028D
    CALL LADR_0x01AC
    CALL LADR_0x01AC
    BTFSC CV_61,1
    BTFSC LRAM_0x24,6
    GOTO LADR_0x029D
    CALL LADR_0x0166
    MOVLW 0x3C           ;   b'00111100'  d'060'  "<"
    BTFSC LRAM_0x24,1
    MOVLW 0x3F           ;   b'00111111'  d'063'  "?"
    CALL LADR_0x0170
    MOVLW 0x00           ;   b'00000000'  d'000'
    BTFSC LRAM_0x24,1
    MOVLW 0x30           ;   b'00110000'  d'048'  "0"
    CALL LADR_0x0170
    MOVLW 0xEB           ;   b'11101011'  d'235'
    GOTO LADR_0x029E
LADR_0x029D
    MOVLW 0xFB           ;   b'11111011'  d'251'
LADR_0x029E
    MOVWF LRAM_0x30
    BTFSC LRAM_0x24,3
    BSF GPIO,1           ; !!Bank!! GPIO - TRISIO
    CALL LADR_0x01AC
    BTFSC LRAM_0x23,1
    GOTO LADR_0x02A7
    BTFSS LRAM_0x23,0
    GOTO LADR_0x02BE
    GOTO LADR_0x02BC
LADR_0x02A7
    BCF LRAM_0x23,1
    MOVLW 0x3C           ;   b'00111100'  d'060'  "<"
    MOVWF FSR
    BTFSS LRAM_0x26,5
    GOTO LADR_0x02AF
    INCF FSR,F
    BTFSS LRAM_0x26,4
    INCF FSR,F
LADR_0x02AF
    MOVF LRAM_0x26,W
    XORWF INDF,F
    MOVWF INDF
    MOVWF EEPROM_DATA
    BTFSC STATUS,Z
    GOTO LADR_0x02BC
    MOVF FSR,W
    ANDLW 0x03           ;   b'00000011'  d'003'
    MOVWF EEPROM_ADDR
    MOVLW 0x10           ;   b'00010000'  d'016'
    ADDWF EEPROM_ADDR,F
    CALL LADR_0x036A
    BCF LRAM_0x23,0
LADR_0x02BC
    BCF LRAM_0x24,4
    GOTO LADR_0x02F5
LADR_0x02BE
    BTFSS LRAM_0x24,7
    GOTO LADR_0x02F5
    MOVF LRAM_0x3C,W
    MOVWF LRAM_0x20
    MOVWF LRAM_0x28
    MOVF LRAM_0x3D,W
    MOVWF LRAM_0x21
    MOVF LRAM_0x3E,W
    BTFSC CV_64,1
    GOTO LADR_0x02D9
    BTFSC CV_64,C
    GOTO LADR_0x02D0
    NOP
    BCF STATUS,C
    RLF LRAM_0x20,F
    BTFSC LRAM_0x20,5
    BSF LRAM_0x20,0
    GOTO Toggle_Light
LADR_0x02D0
    RRF LRAM_0x20,F
    RRF LRAM_0x20,F
    BCF LRAM_0x20,2
    BTFSC LRAM_0x21,C
    BSF LRAM_0x20,2
    BCF LRAM_0x20,3
    BTFSC LRAM_0x21,1
    BSF LRAM_0x20,3
    GOTO Toggle_Light
LADR_0x02D9
    MOVWF LRAM_0x20
    BTFSC CV_64,C
    GOTO Toggle_Light
    MOVF LRAM_0x21,W
    MOVWF LRAM_0x20
Toggle_Light
    BCF LRAM_0x24,3
    MOVLW 0x00           ;   b'00000000'  d'000'
    BTFSS LRAM_0x20,0
    GOTO Do_Nothing
    BTFSS LRAM_0x2D,0
    GOTO LADR_0x02E7
    BTFSS LRAM_0x22,7
    GOTO Toggle_Rev_Light
    GOTO Toggle_Front_Light
LADR_0x02E7
    BTFSS LRAM_0x22,7
    GOTO Toggle_Front_Light
Toggle_Rev_Light
    IORLW 0x04           ;   b'00000100'  d'004'
    GOTO LADR_0x02EE
Toggle_Front_Light
    BSF LRAM_0x24,3
    IORLW 0x02           ;   b'00000010'  d'002'
Do_Nothing
    NOP
LADR_0x02EE
    BTFSC CV_61,C
    RLF LRAM_0x20,F
    BTFSC LRAM_0x20,1
    IORLW 0x20           ;   b'00100000'  d'032'  " "
    MOVWF GPIO           ; !!Bank!! GPIO - TRISIO
    BSF LRAM_0x23,0
    GOTO LADR_0x00BF
LADR_0x02F5
    GOTO LADR_0x00BF
LADR_0x02F6
    MOVF LRAM_0x2C,W
    BTFSS STATUS,Z
    CALL LADR_0x02FA
    GOTO LADR_0x02F5
LADR_0x02FA
    MOVLW 0xFE           ;   b'11111110'  d'254'
    XORWF EEPROM_DATA,W
    BTFSS STATUS,Z
    GOTO LADR_0x0305
    BTFSS LRAM_0x25,2
    GOTO LADR_0x0345
    MOVF LRAM_0x26,W
    MOVWF EEPROM_ADDR
    MOVF LRAM_0x27,W
    MOVWF LRAM_0x26
    GOTO LADR_0x0319
LADR_0x0305
    MOVLW 0x01           ;   b'00000001'  d'001'
    MOVWF EEPROM_ADDR
    BTFSS LRAM_0x25,2
    GOTO LADR_0x030E
    MOVF LRAM_0x25,W
    ANDLW 0x03           ;   b'00000011'  d'003'
    ADDWF EEPROM_ADDR,F
    CLRF LRAM_0x20
    GOTO LADR_0x032A
LADR_0x030E
    INCF EEPROM_ADDR,F
    CALL EEPROM_READ
    DECF EEPROM_DATA,F
    RLF EEPROM_DATA,W
    MOVWF EEPROM_ADDR
    RLF EEPROM_ADDR,F
    MOVLW 0xFC           ;   b'11111100'  d'252'
    ANDWF EEPROM_ADDR,F
    MOVF LRAM_0x25,W
    ANDLW 0x03           ;   b'00000011'  d'003'
    ADDWF EEPROM_ADDR,F
LADR_0x0319
    CLRF LRAM_0x21
    BTFSC EEPROM_ADDR,7
    GOTO LADR_0x0345
LADR_0x031C
    CALL LADR_0x0014
    MOVWF LRAM_0x20
    ANDLW 0x7F           ;   b'01111111'  d'127'  ""
    XORWF EEPROM_ADDR,W
    BTFSC STATUS,Z
    GOTO LADR_0x0328
    INCF LRAM_0x21,F
    MOVLW 0x10           ;   b'00010000'  d'016'
    XORWF LRAM_0x21,W
    BTFSS STATUS,Z
    GOTO LADR_0x031C
    GOTO LADR_0x0331
LADR_0x0328
    MOVF LRAM_0x21,W
    MOVWF EEPROM_ADDR
LADR_0x032A
    BTFSC LRAM_0x25,3
    GOTO LADR_0x0346
    CALL EEPROM_READ
    MOVF EEPROM_DATA,W
    XORWF LRAM_0x26,W
    BTFSS STATUS,Z
    GOTO LADR_0x0345
LADR_0x0331
    BTFSC CV_61,6
    GOTO LADR_0x0345
    MOVLW 0xC0           ;   b'11000000'  d'192'
    MOVWF GPIO           ; !!Bank!! GPIO - TRISIO
    CLRF LRAM_0x21
    CALL LADR_0x01DC
    CALL LADR_0x01DC
    CALL LADR_0x01DC
    MOVLW 0x50           ;   b'01010000'  d'080'  "P"
    MOVWF LRAM_0x20
LADR_0x033B
    MOVLW 0xC6           ;   b'11000110'  d'198'
    MOVWF GPIO           ; !!Bank!! GPIO - TRISIO
    MOVLW 0x0C           ;   b'00001100'  d'012'
    CALL LADR_0x01DC
    MOVLW 0xC0           ;   b'11000000'  d'192'
    MOVWF GPIO           ; !!Bank!! GPIO - TRISIO
    MOVLW 0x0C           ;   b'00001100'  d'012'
    CALL LADR_0x01DC
    DECFSZ LRAM_0x20,F
    GOTO LADR_0x033B
LADR_0x0345
    RETURN
LADR_0x0346
    INCF LRAM_0x2C,F
    BTFSS LRAM_0x2C,0
    GOTO LADR_0x034B
    CLRF LRAM_0x2C
    GOTO LADR_0x0331
LADR_0x034B
    CALL LADR_0x0357
    BTFSC STATUS,C
    GOTO LADR_0x0345
    BTFSC LRAM_0x20,7
    GOTO LADR_0x0331
    MOVF EEPROM_ADDR,W
    XORLW 0x05           ;   b'00000101'  d'005'
    BTFSC STATUS,Z
    BSF LRAM_0x26,7
    MOVF LRAM_0x26,W
    CALL LADR_0x0369
    GOTO LADR_0x0345
LADR_0x0357
    BSF STATUS,C
    MOVF LRAM_0x3A,W
    XORWF LRAM_0x39,W
    ANDLW 0x07           ;   b'00000111'  d'007'
    BTFSC STATUS,Z
    GOTO LADR_0x0367
    MOVF EEPROM_ADDR,W
    XORLW 0x0D           ;   b'00001101'  d'013'
    BTFSC STATUS,Z
    GOTO LADR_0x0365
    MOVF EEPROM_ADDR,W
    XORLW 0x02           ;   b'00000010'  d'002'
    BTFSS STATUS,Z
    GOTO LADR_0x0366
LADR_0x0365
    BCF STATUS,C
LADR_0x0366
    BTFSC LRAM_0x3B,6
LADR_0x0367
    BCF STATUS,C
    RETURN
LADR_0x0369
    MOVWF EEPROM_DATA
LADR_0x036A
    BTFSC LRAM_0x23,5
    RETLW 0x00           ;   b'00000000'  d'000'
    BSF STATUS,RP0       ; !!Bank Register-Bank(0/1)-Select
    CLRWDT
EEPROM_WRITE
    BTFSC EECON1,1       ; !!Bank!! Unimplemented - EECON1
    GOTO EEPROM_WRITE
    MOVF EEPROM_ADDR,W
    MOVWF EEADR          ; !!Bank!! Unimplemented - EEADR
    MOVF EEPROM_DATA,W
    MOVWF EEDATA         ; !!Bank!! Unimplemented - EEDATA
    BCF INTCON,GIE
    BSF EECON1,WREN         ; !!Bank!! Unimplemented - EECON1
    MOVLW 0x55           ;   b'01010101'  d'085'  "U"
    MOVWF EECON2         ; !!Bank!! Unimplemented - EECON2
    MOVLW 0xAA           ;   b'10101010'  d'170'
    MOVWF EECON2         ; !!Bank!! Unimplemented - EECON2
    BSF EECON1,WR         ; !!Bank!! Unimplemented - EECON1
    BSF INTCON,GIE
    GOTO LADR_0x0386
LADR_0x037D
    MOVWF EEPROM_ADDR
EEPROM_READ
    BSF STATUS,RP0       ; !!Bank Register-Bank(0/1)-Select
    BTFSC EECON1,1       ; !!Bank!! Unimplemented - EECON1
    GOTO EEPROM_READ
    MOVF EEPROM_ADDR,W
    MOVWF EEADR          ; !!Bank!! Unimplemented - EEADR
    BSF EECON1,RD        ; !!Bank!! Unimplemented - EECON1
    MOVF EEDATA,W        ; !!Bank!! Unimplemented - EEDATA
    MOVWF EEPROM_DATA
LADR_0x0386
    INCF EEPROM_ADDR,F
    BCF STATUS,RP0       ; !!Bank Register-Bank(0/1)-Select
    RETURN
    
LADR_0x03FF
    RETLW 0x24           ;   b'00100100'  d'036'  "$"
    
    End
