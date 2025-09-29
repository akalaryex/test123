;------------------------------------------------------------------------------
; 文件:        29-352.asm
; 目标器件:    PIC12F675（8 位 MCU，带内部 RC 振荡器、EEPROM）
; 功能概述:    这是一个用于 NMRA DCC 解码器的主程序。固件从轨道信号中
;              解析 DCC 数据包，根据配置变量（CV）和当前方向/功能位
;              控制输出（例如车灯、方向灯等），并能在编程模式下读写
;              EEPROM 中的配置参数。
;              本文件在原始程序基础上补充了详细注释，帮助理解每一段
;              代码的用途以及关键寄存器位的含义。
;------------------------------------------------------------------------------

    processor 12F675              ; 声明目标器件
    #include <P12F675.INC>        ; 引入官方寄存器/位定义
;    __config 0x314C              ; 旧版配置字，仅作为参考保留
;    __config _CPD_OFF & _CP_ON & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_ON & _INTRC_OSC_NOCLKOUT
    __config _CPD_OFF & _CP_OFF & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_ON & _INTRC_OSC_NOCLKOUT
                                 ; 配置字: 禁止代码/数据保护, 开启欠压复位
                                 ; 关闭 MCLR 引脚, 允许上电延时, 开启看门狗
                                 ; 使用内部 RC 振荡器并关闭 CLKOUT
    __idlocs 0x00FE               ; 设置 ID 位置

;------------------------------------------------------------------------------
; EEPROM 预置数据（在 DCC 解码器中通常对应各个 CV 的初值）
; - CV1  ：默认地址
; - CV61 ：扩展功能设置
; - CV64 ：灯光/方向相关参数
;------------------------------------------------------------------------------
    Org 0x2100
    DE 0xFF, 0x06, 0x01, 0xFE, 0x81, 0x03, 0x02, 0x00   ; CV 表初值（地址、速度表、功能位等）
    DE 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60   ; 其他默认值，最后的 0x60 为 CV64 缺省
    DE 0x90, 0xB0, 0xA0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   ; 未使用的 EEPROM 空间用 0xFF 填充
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    DE 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

;------------------------------------------------------------------------------
; RAM 变量分配表
; 说明: 绝大部分变量都是 0x20-0x3E 区间的通用寄存器，用于暂存信号测量
;       状态、DCC 数据包内容、EEPROM 地址/数据等。为保持与原代码一致
;       保留原有名称，仅在注释中说明用途。
;------------------------------------------------------------------------------
LRAM_0x20 equ 0x20        ; 计时/循环临时变量（多处复用）
LRAM_0x21 equ 0x21        ; 多功能计数器（如脉宽计数、循环计数等）
LRAM_0x22 equ 0x22        ; 各类状态位标志（bit0: 数据包完成; bit3: 电平状态等）
LRAM_0x23 equ 0x23        ; 状态标志寄存器（bit5: 初始化完成; bit7: 有新数据包）
LRAM_0x24 equ 0x24        ; 功能输出状态与触发标志（bit0: 灯闪烁；bit3: 正向灯等）
LRAM_0x25 equ 0x25        ; 当前接收的地址/指令字节
LRAM_0x26 equ 0x26        ; 当前数据字节 / 方向信息
LRAM_0x27 equ 0x27        ; 下一个数据字节 / 功能或扩展命令
LRAM_0x28 equ 0x28        ; 临时寄存器：接收缓冲、异或累加
LRAM_0x29 equ 0x29        ; 校验值 / 用于程序流程判断
EEPROM_ADDR equ 0x2A      ; EEPROM 地址暂存寄存器
EEPROM_DATA equ 0x2B      ; EEPROM 数据暂存寄存器
LRAM_0x2C equ 0x2C        ; 超时/重复计数器（编程模式相关）
LRAM_0x2D equ 0x2D        ; 配置标志（bit5: 扩展寻址; bit0: 前灯模式等）
LRAM_0x2E equ 0x2E        ; 速度步计数器 / 调速过程状态
LRAM_0x2F equ 0x2F        ; 功能输出刷新计数器
LRAM_0x30 equ 0x30        ; DCC 位计数器（记录当前位序号）
CV_1 equ 0x31             ; EEPROM 中读取的 CV1（地址）
CV_61 equ 0x32            ; EEPROM 中读取的 CV61（功能设置）
LRAM_0x33 equ 0x33        ; EEPROM 缓冲：功能组 / 速度表
LRAM_0x34 equ 0x34        ; EEPROM 缓冲：功能组 / 速度表
CV_64 equ 0x35            ; EEPROM 中读取的 CV64（灯光配置）
LRAM_0x36 equ 0x36        ; 速度表缓存（高字节）
LRAM_0x37 equ 0x37        ; 速度表缓存（低字节）
LRAM_0x38 equ 0x38        ; 方向/功能状态镜像（bit6/7 用于方向检测）
LRAM_0x39 equ 0x39        ; 速度表索引 / 功能扩展字节
LRAM_0x3A equ 0x3A        ; 速度表索引（上一状态）
LRAM_0x3B equ 0x3B        ; 标志字节：编程模式/灯光模式等
LRAM_0x3C equ 0x3C        ; 输出寄存器缓存（对应 GPIO 最终状态）
LRAM_0x3D equ 0x3D        ; 功能输出模式参数
LRAM_0x3E equ 0x3E        ; 方向灯调度参数

;------------------------------------------------------------------------------
; 主程序区
;------------------------------------------------------------------------------

    Org 0x0000

;------------------------------------------------------------------------------
; 复位向量：上电或复位后跳转到 MainStart 完成初始化
;------------------------------------------------------------------------------
    GOTO MainStart

;------------------------------------------------------------------------------
; LADR_0x0001 - 查表入口
; 用途: 通过 W 寄存器提供的偏移访问第一张查表（常用于 ASCII/数码管输出）
; 说明: 进入该表前需要先确保 W 中存放的索引值小于 16
;------------------------------------------------------------------------------
LADR_0x0001
    CLRF PCLATH          ; 切换到程序存储器第 0 页，保证查表正确
    ANDLW 0x0F           ; 限制索引范围 0..15
    ADDWF PCL,F          ; 自修改 PC，实现查表

;------------------------------------------------------------------------------
; 中断向量（此固件未使用硬件中断，改作常量查表使用）
; 每条 RETLW 返回一个特定字节，例如用于调光曲线或 ASCII 字符。
;------------------------------------------------------------------------------
; 表 1: 字符常量 / 功能掩码
    RETLW 0x0D           ; 回车符（或脉宽常量）
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
;------------------------------------------------------------------------------
; LADR_0x0014 - 第二张查表（根据 LRAM_0x21 中的索引值选择灯光/速度常量）
;------------------------------------------------------------------------------
LADR_0x0014
    CLRF PCLATH          ; 重置页寄存器，确保查表地址正确
    MOVF LRAM_0x21,W     ; W <- 查表索引
    ADDWF PCL,F          ; 跳转到对应的 RETLW 项
    RETLW 0x3E           ; 亮度/定时参数（>）
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
;------------------------------------------------------------------------------
; LADR_0x0027 - DCC 信号采样准备
; 功能: 清除“起始位检测完成”标志，准备计时器阈值，随后进入位宽测量循环。
;------------------------------------------------------------------------------
LADR_0x0027
    BCF LRAM_0x22,4       ; 清除“已完成 1 个字节”标志
    BSF LRAM_0x22,5       ; 标记为正在采样 DCC 脉冲
    MOVLW 0xE6           ; 初始计数器 (用于超时门限)
    MOVWF LRAM_0x20
;------------------------------------------------------------------------------
; LADR_0x002B - DCC 位宽测量主循环
; 通过采样 TMR0/引脚状态判定 DCC 位，返回位值或继续等待。
; 返回值: W=0/2/4/5/6/其他用于上层解码逻辑的状态码。
;------------------------------------------------------------------------------
LADR_0x002B
    CLRWDT                ; 喂狗，防止进入 WDT 复位
    MOVLW 0x03           ; W <- 基准计数
    BTFSS LRAM_0x20,0     ; 判断是否仍需补偿低位计时
    BTFSS LRAM_0x20,1
    GOTO LADR_0x0035      ; 若计数器低位均为 0，跳过补偿
    CALL LADR_0x0052      ; 读取当前位并根据 TMR0 状态返回
    ADDWF LRAM_0x20,F     ; 累加计数器（用于平均滤波）
    BTFSC LRAM_0x23,7     ; 如果上层已标记“包接收完成”
    RETLW 0x00            ; 则退出，返回 0
    MOVLW 0x04           ; 否则准备补偿值
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
;------------------------------------------------------------------------------
; LADR_0x0052 - 检查 TMR0 / 输入引脚状态
; 功能: 根据 TMR0 第 7 位判断当前采样是否跨越 58μs，结合 GPIO5 输入
;       决定返回值，并维护若干标志位。
; 返回: W=0x02/0x05/0x04/0x06 等，表示不同的位宽或状态。
;------------------------------------------------------------------------------
LADR_0x0052
    BTFSC TMR0,7         ; 若 TMR0<0x80，则尚未达到长脉宽
    GOTO LADR_0x0058
    BCF LRAM_0x22,2      ; 清除“检测到长脉宽”标志
    BTFSC GPIO,5         ; 读取辅助输入（用于编程轨判定）
    BSF LRAM_0x24,4      ; 记录辅助输入高电平
    RETLW 0x02           ; 返回短脉宽状态码
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
;------------------------------------------------------------------------------
; LADR_0x007B - 灯光模式查表
; 入口: W=指向模式参数的 EEPROM 地址
; 功能: 读取 EEPROM/工作 RAM 中的灯光配置字节，并据此返回不同的灯光输出
;       模式编码（共 8 个条目，分别对应常亮、闪烁、渐亮等模式）。
; 返回: 通过 RETLW 返回模式掩码。
;------------------------------------------------------------------------------
LADR_0x007B
    MOVWF FSR            ; FSR <- 表地址
    MOVF INDF,W          ; W <- 地址所指数据
    MOVWF LRAM_0x28      ; 缓存原始数据
    ANDLW 0x07           ; 仅保留低 3 位（模式编号）
    ADDWF PCL,F          ; 跳到对应模式的 RETLW
    RETLW 0xFF           ; 模式 0: 默认/无效（所有位为 1）
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
;------------------------------------------------------------------------------
; MainStart - 系统初始化入口
; - 关闭 GPIO 输出，配置方向寄存器
; - 设置 OPTION、比较器、振荡器校准等
; - 清零工作 RAM，加载 EEPROM 中的配置
;------------------------------------------------------------------------------
MainStart
    BSF LRAM_0x23,5       ; 标记为“正在初始化”
    CLRWDT                ; 上电后立即喂狗
    CLRF GPIO            ; 清空 GPIO 输出口
    MOVLW 0xC1
    TRIS GPIO            ; GPIO5/4 输入，其余输出（带上拉设置）
    MOVLW 0xC5
    OPTION               ; 配置 TMR0 分频、拉电阻等
    MOVLW 0x07
    MOVWF CMCON          ; 禁用比较器，启用数字输入
    CALL LADR_0x03FF      ; 读取出厂 OSCCAL 校准值
    BSF STATUS,RP0       ; 切换到银行 1
    MOVWF T1CON          ; 将 OSCCAL 值写入 OSCCAL/T1CON 寄存器
    CLRF ADCON0          ; 禁用 ADC（12F675 中 ADCON0 位于银行 1）
    CLRF WPU             ; 清除弱上拉配置
    BCF STATUS,RP0       ; 返回银行 0
    CLRF LRAM_0x2C       ; 相关状态寄存器全部清零
    CLRF LRAM_0x22
    CLRF LRAM_0x23
    CLRF LRAM_0x24
    BSF LRAM_0x23,5       ; 再次标记初始化中，防止 EEPROM 写入
;------------------------------------------------------------------------------
; LADR_0x00AB - 初始化 EEPROM 缓冲区
; 步骤:
;   1. 将 FSR 指向 RAM 中的 CV 缓存区（0x2D 开始）
;   2. 设置需要读取的字节数（0x12 = 18 字节）
;   3. 调用 LADR_0x0094 设定 EEPROM 起始地址
;   4. 通过循环调用 EEPROM_READ 将数据搬运到 RAM
;------------------------------------------------------------------------------
LADR_0x00AB
    MOVLW 0x2D           ; FSR -> RAM 0x2D，作为 CV 缓冲起始
    MOVWF FSR
    MOVLW 0x12           ; 需要复制的字节数 = 18
    MOVWF LRAM_0x28
    CALL LADR_0x0094     ; EEPROM_ADDR <- 1（跳过保留字节）
LADR_0x00B0
    CALL EEPROM_READ     ; 从 EEPROM 读取一个字节
    MOVF EEPROM_DATA,W   ; W <- 数据
    MOVWF INDF           ; 写入 RAM 缓冲
    INCF FSR,F           ; FSR++
    DECFSZ LRAM_0x28,F   ; 计数器--，若未完成继续
    GOTO LADR_0x00B0
    CLRF LRAM_0x2F       ; 清空速度/功能状态
    CLRF LRAM_0x2E
    CLRF LRAM_0x30
    MOVLW 0x36           ; 加载 CV54/55 等灯光配置
    CALL LADR_0x0088
    MOVLW 0x37
    CALL LADR_0x0088
    CALL LADR_0x0050     ; 设置初始状态（标记 EEPROM 已加载）
    CLRF LRAM_0x24
;------------------------------------------------------------------------------
; LADR_0x00BF - 主循环入口
; 根据 CV64 的设置选择 GPIO 方向（普通运行/编程模式），然后进入读取 DCC
; 信号的状态机。整个主循环以 LADR_0x00BF 为枢纽，不断处理数据包。
;------------------------------------------------------------------------------
LADR_0x00BF
    MOVLW 0xC1
    BTFSC CV_64,2         ; 若启用辅助输入监测
    MOVLW 0xF1            ; 则将 GPIO2/3 也配置为输入
    TRIS GPIO             ; 更新引脚方向
    BCF LRAM_0x22,0       ; 清除“数据包完成”标志
;------------------------------------------------------------------------------
; LADR_0x00C4 - DCC 数据包接收状态机
; bit0 (LRAM_0x22) 用于标识是否检测到完整数据包。
; 若未完成，则进入 Read_DCC_Sginal 解析起始位与数据位；
; 若已完成则跳转到 LADR_0x00EC 进行包处理。
;------------------------------------------------------------------------------
LADR_0x00C4
    BTFSC LRAM_0x22,0     ; 数据包是否完成？
    GOTO LADR_0x00EC      ; 是 -> 处理数据
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
;------------------------------------------------------------------------------
; Read_DCC_Sginal - 读取单个 DCC 位的核心循环
; 根据 LADR_0x0052 返回的状态判断当前位是否为“0/1/起始位”，
; 同时利用 LRAM_0x20 作为超时计数，保证在信号异常时能退出。
;------------------------------------------------------------------------------
Read_DCC_Sginal
    CLRWDT                ; 定期喂狗
    CALL LADR_0x0052      ; 获取当前位状态
    BTFSC LRAM_0x23,7     ; 若已捕获完整字节（LADR_0x0052 设置）
    GOTO LADR_0x015F
    SUBWF LRAM_0x20,F     ; 根据返回值调整计时器
    BTFSS LRAM_0x22,3     ; 检查当前电平是否低
    GOTO Wait_DCC_Start   ; 若非低电平，则等待起始位
    NOP                   ; 保持时间均衡
Wait_DCC_Receive
    BTFSS GPIO,0         ; 监测 DCC 输入是否变高
    GOTO LADR_0x00E2     ; 若持续为低电平，则标记错误
    DECFSZ LRAM_0x20,F   ; 超时保护
    GOTO Wait_DCC_Receive
    BCF LRAM_0x22,5      ; 本位解析完成
    GOTO LADR_0x00CC
Wait_DCC_Start
    BTFSC GPIO,0         ; 检测是否拉低以标识起始位
    GOTO LADR_0x00E2     ; 如果一直为高，说明噪声，转错误处理
    DECFSZ LRAM_0x20,F   ; 超时计数
    GOTO Wait_DCC_Start
    BCF LRAM_0x22,5
    GOTO LADR_0x00CC
LADR_0x00E2
    MOVLW 0x08           ; 翻转状态字中的起始位标志
    XORWF LRAM_0x22,F
    BTFSS LRAM_0x22,5    ; 如果仍在等待过程
    GOTO LADR_0x00C4     ; 则重新开始
    MOVLW 0x0C
    MOVWF LRAM_0x20      ; 重新装载超时计数
    DECFSZ LRAM_0x21,F   ; 减少剩余位数
    GOTO Read_DCC_Sginal
    BSF LRAM_0x22,0      ; 标记“数据包完成”
    GOTO Read_DCC_Sginal ; 返回继续清理状态
;------------------------------------------------------------------------------
; LADR_0x00EC - 接收完成后的 DCC 数据包处理入口
; 步骤:
;   1. 调整状态标志，清空缓冲
;   2. 调用 LADR_0x002B 继续监测下一帧
;   3. 初始化 EEPROM 地址/数据，准备解析接收的字节流
;------------------------------------------------------------------------------
LADR_0x00EC
    CALL LADR_0x0050      ; 设置标志：准备处理新数据包
    MOVLW 0x25
    MOVWF FSR             ; FSR -> 数据缓冲区（存放接收的字节）
    CLRF INDF             ; 清空首字节
    BSF LRAM_0x22,4       ; 标记正在处理
    BCF LRAM_0x22,5       ; 清除采样状态
    CALL LADR_0x002B      ; 再次启动采样（确保同步）
    CLRF LRAM_0x29        ; 清空 XOR 校验
    CLRF EEPROM_ADDR
    CLRF LRAM_0x28
    MOVLW 0x06
    MOVWF EEPROM_DATA     ; 初始化数据计数（默认 6 字节）
;------------------------------------------------------------------------------
; LADR_0x00F8 - DCC 包字节接收循环
; 每个字节包含 8 位数据，使用 LADR_0x0027/LADR_0x002B 组合完成位采集，
; 然后存入以 FSR 指向的缓冲区。EEPROM_DATA 保存剩余字节数。
;------------------------------------------------------------------------------
LADR_0x00F8
    MOVLW 0x08           ; 每字节 8 位
    MOVWF LRAM_0x21      ; 位计数器初始化
LADR_0x00FA
    CALL LADR_0x0027     ; 读取一位
    BTFSC LRAM_0x23,7    ; 若检测到错误
    GOTO LADR_0x00C6     ; 回到等待状态
    BCF STATUS,C
    BTFSC LRAM_0x22,5    ; 根据状态位决定当前 DCC 位是 1 还是 0
    BSF STATUS,C
    RLF INDF,F           ; 将位写入缓冲
    DECFSZ LRAM_0x21,F   ; 收满 8 位？
    GOTO LADR_0x00FA     ; 未完成 -> 继续
    INCF FSR,F           ; 下一个缓冲位置
    CALL LADR_0x0050     ; 更新状态标志
    CALL LADR_0x0027     ; 检查下一个起始位
    BTFSC LRAM_0x22,5    ; 若检测到分隔位异常
    GOTO LADR_0x010B
    DECFSZ EEPROM_DATA,F ; 字节计数--
    GOTO LADR_0x00F8     ; 继续接收
    GOTO LADR_0x0117     ; 完成 -> 进入校验/解析
;------------------------------------------------------------------------------
; LADR_0x010B - 校验字节处理 / 长度检查
; 将剩余字节数与 5 比较，判断是否为基本格式的数据包；若不是则执行
; XOR 校验累积，最终判断包合法性。
;------------------------------------------------------------------------------
LADR_0x010B
    MOVLW 0x05
    SUBWF EEPROM_DATA,F   ; 检查是否仍有 5 字节
    BTFSC STATUS,C
    GOTO LADR_0x0117      ; 若已满足 -> 正常结束
    BCF LRAM_0x23,7       ; 清除错误标志，准备进行校验
    MOVF LRAM_0x25,W
    XORWF LRAM_0x26,W
    XORWF LRAM_0x27,W
    XORWF LRAM_0x28,W
    XORWF LRAM_0x29,W
    XORWF EEPROM_ADDR,W   ; 校验和（异或累加）
    BTFSS STATUS,Z
LADR_0x0117
    GOTO LADR_0x00BF     ; 无论成功或失败，回到主循环等待下一包
    BTFSC LRAM_0x23,5
    GOTO LADR_0x011B
;------------------------------------------------------------------------------
; LADR_0x011A/0x011B - 服务模式（编程轨）命令处理
; 根据接收到的数据包类型选择写 CV、读 CV 或其他扩展命令。
;------------------------------------------------------------------------------
LADR_0x011A
    GOTO LADR_0x01E7     ; 进入运行模式命令解析
LADR_0x011B
    MOVLW 0x04
    CALL LADR_0x037D     ; 读取数据包中的第 4 个字节（命令类型）
    MOVF EEPROM_DATA,W
    XORLW 0x81           ; 比较是否为“读 CV”命令
    BCF LRAM_0x23,5
    BTFSC STATUS,Z
    GOTO LADR_0x0150     ; 如果是读命令，跳到对应处理
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
;------------------------------------------------------------------------------
; LADR_0x012C - 写入默认 CV（服务模式编程）
; 当检测到“重置至出厂设置”命令时，通过多次调用 LADR_0x0369 写入一组
; 预定义的值到 EEPROM，随后重新加载到 RAM 中。
;------------------------------------------------------------------------------
LADR_0x012C
    CLRF FSR             ; FSR 指向 EEPROM 缓冲区起始
    CALL LADR_0x0094     ; EEPROM_ADDR <- 1
    MOVLW 0x06
    CALL LADR_0x0369     ; CV1 默认地址
    MOVLW 0x01
    CALL LADR_0x0369     ; CV2 速度模式
    MOVLW 0xFE
    CALL LADR_0x0369     ; CV3 加速度
    INCF EEPROM_ADDR,F   ; 指向下一位置
    MOVLW 0x03
    CALL LADR_0x0369
    MOVLW 0x02
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369     ; 其余值全部清零
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x00
    CALL LADR_0x0369
    MOVLW 0x60
    CALL LADR_0x0369     ; CV64 默认灯光参数
    MOVLW 0x04
    MOVWF EEPROM_ADDR    ; 指向 CV4
    MOVLW 0x81
    CALL LADR_0x0369     ; 写入标志字节
    GOTO LADR_0x00AB     ; 重新从 EEPROM 加载配置
;------------------------------------------------------------------------------
; LADR_0x0150 - CV 读取命令响应
; 如果 CV1 bit7 被置位表示请求读取地址，则将当前地址写入 EEPROM 缓冲，
; 随后回到主循环等待发送 ACK。
;------------------------------------------------------------------------------
LADR_0x0150
    BTFSS CV_1,7
    GOTO LADR_0x011A     ; 非读取命令，转运行模式处理
    BCF CV_1,7           ; 清除标志
    MOVF LRAM_0x2D,F
    BTFSC STATUS,Z
    GOTO LADR_0x00BF     ; 若未进入编程轨，直接返回
    CALL LADR_0x0094
    BCF LRAM_0x2D,5
    MOVF LRAM_0x2D,W
    CALL LADR_0x0369     ; 写入 CV 地址高字节
    MOVLW 0x05
    MOVWF EEPROM_ADDR
    MOVF CV_1,W
    CALL LADR_0x0369     ; 写入 CV1 当前值
    GOTO LADR_0x00BF
;------------------------------------------------------------------------------
; LADR_0x015F - 错误处理 / 进入编程响应
; 当检测到非法脉冲或特殊位序列时，若允许编程模式则跳转到灯光闪烁
; 子程序以发出 ACK，否则返回主循环。
;------------------------------------------------------------------------------
LADR_0x015F
    BCF LRAM_0x22,0
    BCF LRAM_0x23,7
    BTFSS LRAM_0x2D,2     ; 是否允许编程轨 ACK？
    GOTO LADR_0x00BF
    BSF LRAM_0x24,7       ; 触发闪灯 ACK
    BSF LRAM_0x23,5
    GOTO LADR_0x02BE
;------------------------------------------------------------------------------
; LADR_0x0166 - 功能输出刷新（灯光控制）
; 根据 CV61 设置决定是否在 ACK 或状态变化时驱动 GPIO1 闪烁。
;------------------------------------------------------------------------------
LADR_0x0166
    BTFSC CV_61,1
    BCF GPIO,1           ; 清除输出，准备重新点亮
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    CALL LADR_0x0190
    CALL LADR_0x01AC
    GOTO LADR_0x0190
;------------------------------------------------------------------------------
; LADR_0x0170 - ACK 脉冲生成辅助子程序
; 使用 LRAM_0x20 的位模式通过多次调用 LADR_0x017D 产生特定闪烁节奏。
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
; LADR_0x017D - 单个 ACK 脉冲输出序列
; 根据模式位决定是否点亮 GPIO1，并设置 LRAM_0x24,0 作为闪烁标志。
;------------------------------------------------------------------------------
LADR_0x017D
    RLF LRAM_0x20,F
    BTFSC CV_61,1
    BTFSS LRAM_0x20,6
    RETLW 0x00           ; 若 CV61 未启用或模式位为 0，则退出
    BSF GPIO,1
    BSF GPIO,1
    BCF LRAM_0x24,0
    BCF GPIO,1
    BTFSC LRAM_0x20,6
    BSF LRAM_0x24,0      ; 记录闪烁状态
    BSF GPIO,1
    BSF GPIO,1
    BSF GPIO,1
    BCF GPIO,1
    BCF GPIO,1
    BCF GPIO,1
    BSF GPIO,1
    BSF GPIO,1
    GOTO LADR_0x019D
;------------------------------------------------------------------------------
; LADR_0x0190 - ACK 脉冲尾声控制
; 在输出完一组闪烁后，确保 GPIO1 返回低电平并根据标志位决定是否继续。
;------------------------------------------------------------------------------
LADR_0x0190
    BTFSS CV_61,1
    RETLW 0x00           ; 若未启用功能则直接返回
    BTFSC LRAM_0x22,3
    GOTO LADR_0x0194
LADR_0x0194
    GOTO LADR_0x0195
; 下面一系列空跳转用于细调执行周期，以便形成准确的 ACK 脉宽
LADR_0x0195
    GOTO LADR_0x0196
LADR_0x0196
    GOTO LADR_0x0197
LADR_0x0197
    GOTO LADR_0x0198
LADR_0x0198
    NOP
    BTFSC LRAM_0x24,0
    BSF GPIO,1           ; 输出 ACK 高电平
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
;------------------------------------------------------------------------------
; LADR_0x01AC - DCC 输入同步等待
; 通过轮询 GPIO0 的电平变化来确保在正确的位边界上输出 ACK。
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
; LADR_0x01D2 - 速度命令有效性检测
; 检查数据字节的高位，判断其是否表示速度命令并在 C 标志中返回结果。
;------------------------------------------------------------------------------
LADR_0x01D2
    BSF STATUS,C
    BTFSS LRAM_0x26,7
    BTFSS LRAM_0x26,6
    GOTO LADR_0x01D7
    RETLW 0x00
LADR_0x01D7
    MOVF LRAM_0x26,W
    XORLW 0x3F
    BTFSS STATUS,Z
    BCF STATUS,C
    RETLW 0x01
LADR_0x01DC
    MOVWF LRAM_0x21
LADR_0x01DD
    DECFSZ LRAM_0x21,F
    GOTO LADR_0x01DD
    RETLW 0x00           ;   b'00000000'  d'000'
;------------------------------------------------------------------------------
; LADR_0x01E0 - 速度命令为 0 的特殊处理
; 如果速度为 0，则将超时计数 LRAM_0x2C 加 1 并重新加载配置；否则进入
; 正常运行模式命令解析。
;------------------------------------------------------------------------------
LADR_0x01E0
    CLRF LRAM_0x2C
    MOVF LRAM_0x26,W
    BTFSC STATUS,Z
    GOTO LADR_0x01E5
    GOTO LADR_0x022C
LADR_0x01E5
    INCF LRAM_0x2C,F
    GOTO LADR_0x00AB
;------------------------------------------------------------------------------
; LADR_0x01E7 - 正常运行模式命令解析
; 依据接收到的地址/指令字节决定执行速度、方向、功能、CV 写入等操作。
;------------------------------------------------------------------------------
LADR_0x01E7
    BCF LRAM_0x24,0       ; 清除闪烁标志
    BCF CV_61,1
    INCF LRAM_0x25,W      ; 地址加 1，用于检测广播命令
    BTFSC STATUS,Z
    GOTO LADR_0x028D      ; 处理广播指令
    BSF LRAM_0x24,7       ; 标记已接收到有效命令
    CALL LADR_0x01AC      ; 等待位边界
    BTFSS LRAM_0x25,7     ; 判断是否为速度/方向命令
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
