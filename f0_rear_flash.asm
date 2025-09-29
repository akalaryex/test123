;------------------------------------------------------------------------------
; 文件:        f0_rear_flash.asm
; 目标器件:    PIC12F675
; 功能概述:    参考 29-352.asm 的初始化方式，实现当方向处于 Rear 状态时
;              将 F0（GPIO1）以约 4 Hz 的频率闪烁。方向信号在此示例中由
;              GPIO0 输入决定（高电平=Forward，低电平=Rear）。实际应用中
;              可在接收到新的 DCC 速度/方向数据后调用 ProcessSpeedDirection
;              子程序，以更新当前方向并自动驱动灯光输出。
;------------------------------------------------------------------------------

    processor 12F675
    #include <P12F675.INC>
    __config _CPD_OFF & _CP_OFF & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __idlocs 0x00FE

;------------------------------------------------------------------------------
; 常量 / 宏定义
;------------------------------------------------------------------------------
F0_BIT          equ 1           ; GPIO1 作为 F0 输出
REAR_FLAG_BIT   equ 0           ; Rear 状态标志位
BLINK_TARGET    equ .15         ; Timer0 溢出计数（1:32 预分频 -> ~122.9 ms）

;------------------------------------------------------------------------------
; RAM 变量
;------------------------------------------------------------------------------
SpeedDirByte    equ 0x20        ; 最近一次的速度/方向字节（bit5=方向）
RearStateFlags  equ 0x21        ; Rear 状态标志（bit0=Rear）
BlinkDivider    equ 0x22        ; Timer0 溢出计数器
OutputShadow    equ 0x23        ; GPIO 输出缓存
NewCommand      equ 0x24        ; 方向检测临时值

;------------------------------------------------------------------------------
; 向量表
;------------------------------------------------------------------------------
    org 0x0000
    GOTO MainStart

    org 0x0004
    RETFIE                    ; 未使用中断，直接返回

;------------------------------------------------------------------------------
; 子程序: ProcessSpeedDirection
; 入口: W=新的速度/方向字节（bit5=1 表示 Forward，bit5=0 表示 Rear）
; 功能: 更新 SpeedDirByte，并根据方向切换 RearStateFlags 与 F0 输出。
;------------------------------------------------------------------------------
ProcessSpeedDirection
    banksel SpeedDirByte
    MOVWF SpeedDirByte
    BCF RearStateFlags,REAR_FLAG_BIT
    BTFSC SpeedDirByte,5        ; bit5=1 -> Forward
    GOTO _DirectionForward
    BSF RearStateFlags,REAR_FLAG_BIT
    MOVLW BLINK_TARGET
    MOVWF BlinkDivider
    banksel INTCON
    BCF INTCON,T0IF
    banksel TMR0
    CLRF TMR0
    RETURN
_DirectionForward
    banksel OutputShadow
    BCF OutputShadow,F0_BIT
    MOVF OutputShadow,W
    banksel GPIO
    MOVWF GPIO
    MOVLW BLINK_TARGET
    banksel BlinkDivider
    MOVWF BlinkDivider
    banksel INTCON
    BCF INTCON,T0IF
    banksel TMR0
    CLRF TMR0
    RETURN

;------------------------------------------------------------------------------
; 子程序: SampleDirectionInput
; 功能: 读取 GPIO0 作为方向输入，必要时调用 ProcessSpeedDirection。
;       这是演示用途，实际项目可由 DCC 数据解析逻辑替换。
;------------------------------------------------------------------------------
SampleDirectionInput
    banksel GPIO
    BTFSC GPIO,0
    GOTO _InputForward
    MOVLW 0x00
    GOTO _StoreNew
_InputForward
    MOVLW 0x20                ; bit5=1 -> Forward
_StoreNew
    MOVWF NewCommand
    MOVF NewCommand,W
    banksel SpeedDirByte
    XORWF SpeedDirByte,W       ; W = NewCommand XOR SpeedDirByte
    BTFSC STATUS,Z
    RETURN                     ; 无变化
    MOVF NewCommand,W
    CALL ProcessSpeedDirection
    RETURN

;------------------------------------------------------------------------------
; 子程序: UpdateRearBlink
; 功能: 在 Rear 状态下按照 4 Hz 左右的频率翻转 GPIO1。
;------------------------------------------------------------------------------
UpdateRearBlink
    banksel RearStateFlags
    BTFSS RearStateFlags,REAR_FLAG_BIT
    GOTO _RearInactive
    banksel INTCON
    BTFSS INTCON,T0IF
    RETURN
    BCF INTCON,T0IF
    banksel BlinkDivider
    DECFSZ BlinkDivider,F
    RETURN
    MOVLW BLINK_TARGET
    MOVWF BlinkDivider
    banksel OutputShadow
    MOVLW (1 << F0_BIT)
    XORWF OutputShadow,F
    MOVF OutputShadow,W
    banksel GPIO
    MOVWF GPIO
    RETURN
_RearInactive
    banksel OutputShadow
    BCF OutputShadow,F0_BIT
    MOVF OutputShadow,W
    banksel GPIO
    MOVWF GPIO
    RETURN

;------------------------------------------------------------------------------
; 主程序
;------------------------------------------------------------------------------
MainStart
    banksel GPIO
    CLRF GPIO

    banksel CMCON
    MOVLW 0x07
    MOVWF CMCON               ; 禁用比较器

    banksel ANSEL
    CLRF ANSEL                ; 全部数字功能

    banksel ADCON0
    CLRF ADCON0               ; 关闭 ADC

    banksel TRISIO
    MOVLW b'00111101'         ; GPIO0 输入(方向)，GPIO1 输出(F0)，其余输入
    MOVWF TRISIO

    banksel OPTION_REG
    MOVLW b'00000100'         ; 预分频 1:32，内部时钟驱动 TMR0
    MOVWF OPTION_REG

    banksel INTCON
    CLRF INTCON

    banksel TMR0
    CLRF TMR0

    banksel BlinkDivider
    MOVLW BLINK_TARGET
    MOVWF BlinkDivider
    CLRF OutputShadow
    CLRF RearStateFlags

    MOVLW 0x20                ; 默认 Forward
    CALL ProcessSpeedDirection

MainLoop
    CALL SampleDirectionInput
    CALL UpdateRearBlink
    GOTO MainLoop

    end
