$NOMOD51
$INCLUDE (8051.MCU) 


;===============Definitions===============


;=========================================

;================Variables================
    salva               equ     0Fh
    ADCDATA                   equ          P1
    START_ADC                equ          P3.3
    END_CONV                  equ          P3.2
    lamp1                           equ          P0
    lamp2                           equ           P2
    led                                equ          P3.6
    punt_M                         equ           R0
    postescaler                  equ           R2 
    cont_muestras             equ           R3
    estado_TX                   equ            R7
    punt_M_1                     equ           R4
    punt_M_2                     equ          R5
    punt_M_3             equ          R1

;==========================================


;============Interrupt vectors=============
    org 0000h
    jmp Inicio

    org 0003h
    jmp IT_AD

    org 000Bh
    jmp IT_T0

    org 0023h
    jmp IT_PS


;===========================================
;===============Main program================
Inicio:
        mov punt_M, #1Bh
        mov DPTR, #Tabla_7seg
        mov lamp1, #40h
        mov lamp2, #40h
        mov postescaler, #40
        mov cont_muestras, #0
    mov punt_M_3, #0
    mov punt_M_2, #0
    mov punt_M_1, #0
        mov TH0, #high(15536)
        mov TL0, #low(15536)
        mov TH1, #0F4h
        mov TL1, #0F4h
        mov TMOD, #00100001b
        mov TCON, #01010001b
        mov IE, #10010011b
        mov SCON, #01000000b
        clr F0
        jnb F0, $
        jmp Inicio
;===========================================
;===============Interruptions===============

IT_T0:
        mov TH0, #high(15536)
        mov TL0, #low(15536)
        djnz postescaler, salir
    mov postescaler, #40
        mov TH0, #high(15536)
        mov TL0, #low(15536)
        setb START_ADC
    mov DPTR, #Tabla_7seg
        nop
    nop
        clr START_ADC
salir: reti

IT_AD:
        mov A, ADCDATA
        mov B, #51
        mul AB 
        mov A, B 
    push ACC
        mov @R0, A
        mov B, #10
        div AB 
        movc A, @A+DPTR
        mov lamp1, A
        mov A, B 
        movc A, @A+DPTR
        mov lamp2, A
        pop ACC
        inc punt_M
        inc cont_muestras
        clr c 
        cjne cont_muestras, #2, comp1
        setb Ren
    clr Ex0
        reti
;=========================COMPARACIONES===========================================
comp1:
        cjne A, #0, ver_s_1
        mov estado_TX, #1
        setb TI
        reti

    ver_s_1:
            cjne A, #20, c_comp1
            mov estado_TX, #1
            setb TI
            reti

    c_comp1:
            jnc comp2
            mov estado_TX, #1
            setb TI
            reti

comp2: 
        cjne A, #21, ver_s_2
        mov estado_TX, #2
        setb TI
        reti

    ver_s_2:
            cjne A, #35, c_comp2
            mov estado_TX, #2
            setb TI
            reti

    c_comp2:
            jnc comp3
            mov estado_TX, #2
            setb TI
            reti

comp3:
        cjne A, #36, ver_s_3
        mov estado_TX, #3
        setb TI
        reti

    ver_s_3:
            cjne A, #50, c_comp3
            mov estado_TX, #3
            setb TI
            reti

    c_comp3:
            jnc out
            mov estado_TX, #3
            setb TI
       out: reti
;=======================================================================================
IT_PS: 
       jnb RI, TX
       clr RI
       mov A, SBUF
       cjne A, #1Ah, fuera
       setb F0
    fuera: reti

   TX:
           clr TI
          cjne estado_TX, #1, ver_2 
          clr led
          mov DPTR, #Tabla_M1
          mov A, punt_M_1
          inc punt_M_1
          movc A, @A+DPTR
          jz basta
          mov SBUF, A
          reti
      basta:mov punt_M_1, #0
          reti
       ver_2:
       cjne estado_TX, #2, ver_3 
       setb led
          mov A, punt_M_2
          inc punt_M_2
          mov DPTR, #Tabla_M2
          movc A, @A+DPTR
          jz basta1 
          mov SBUF, A
          reti
    basta1: mov punt_M_2, #0
          reti



   ver_3:
       cjne estado_TX, #3 , fuera1
       setb led
       mov A, punt_M_3
       inc punt_M_3
       mov DPTR, #Tabla_M3
       movc A, @A+DPTR
       jz fuera1
       mov SBUF, A
       reti
   fuera1:mov punt_M_3, #0
           reti

;===========================================
;==================Tables===================
Tabla_7seg: db 0C0h, 0F9h, 0A4h, 0B0h, 99h, 92h, 82h, 0F8h, 80h, 90h
Tabla_M1: db ' Temperatura Baja' ,0
Tabla_M2: db ' Temperatura Normal' ,0
Tabla_M3: db ' Incendio' ,0
   
;===========================================
end