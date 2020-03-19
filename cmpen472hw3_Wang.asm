**************************************************************************
*
* Title:                LED Light Blinking
* 
* Objective:            CSE472 Homework 3 
*
* Revision:             V4.5
*
* Date:                 Sep. 20. 2019
*
* Programmer:           Songmeng Wang
* 
* Company:              The Pennsylvania State University
*                       Department of Computer Science and Engineering
*
* Algorithm:            Loops and branches on CSM12C128 board
*
* Resister use:         A accumulator
*                       B acuumulator
*                       X register
*                       Y register
*
* Memory use:           RAM Locations from $3000 for data.
*                                     from $3100 for program.
*
* Input:                
*
* Output:               
*
* Observation:          
*               
* Comments:
*             
*****************************************************************************
*Parameter Declearation Section
*
*Export Symbols
            XDEF      pgstart     ; export 'pgstart' symbol
            ABSENTRY  pgstart     ; for assembly entry point
*                                 ; This is first instruction of the program
*                                 ;     up on the start of simulation

*Symbols and Macros
PORTA       EQU       $0000       ; i/o port addresses(port A not used)
DDRA        EQU       $0002

PORTB       EQU       $0001       ; PORT B is connected with LEDs
DDRB        EQU       $0003
PUCR        EQU       $000C       ; to enable pull-up mode for PORT A,B,E,K

PTP         EQU       $0258       ; PORTP data register, used for Push Switch
PTIP        EQU       $0259       ; PORTP input register <<==================
DDRP        EQU       $025A       ; PORTP data direction register
PERP        EQU       $025C       ; PORTP pull up/down enable
PPSP        EQU       $025D       ; PORTP pull up/down selection

*****************************************************************************
*Data Section
*
            ORG       $3000       ; reserved RAM memory starting address
                                  ;   Memory $3000 to $30FF are for Data
Counter1    DC.W      $0004       ; initial X register count number
Counter2    DC.W      $0001       ; initial Y register count number
Counter3    DC.B      $07         ; initial count number 7 for 7% lightening
Counter4    DC.B      $5D         ; initial count number 93 for 7% lightening
Counter5    DC.B      $0E         ; initial count number 14 for 14% lightening
Counter6    DC.B      $56         ; initial count number 86 for 14% lightening

StackSpace                        ; remaining memory space for stack data
                                  ; initial stack pointer position set
                                  ; to $3100 (pgstart)
*
*****************************************************************************
* Program Section
*
            ORG       $3100           ; Program start address, in RAM
pgstart     LDS       #pgstart        ; initialize the stack pointer

            LDAA      #%11110000      ; set PORTB bit 7,6,5,4 as output, 3,2,1,0
            STAA      DDRB            ; LED 1,2,3,4 on PORTB bit 4,5,6,7
                                      ; DIP switch 1,2,3,4 on PORTB bit 0,1,2,3
            BSET      PUCR,%00000010  ; enable PORTB pull up/down feature, for the DIP switch 1,2,3,4 on the bits 0,1,2,3.

                                      
            BCLR      DDRP,%00000011  ; Push Button Switch 1 and 2 at PORTP bit 0 and 1    
                                      ; set PORTP bit 0 and 1 as input
            BSET      PERP,%00000011  ; enable the pull up/down feature at PORTP bit 0 and 1
            BCLR      PPSP,%00000011  ; select pull up feature at PORTP bit 0 and 1 for the 
                                      ;   Push Button Switch 1 and 2.
                                      
            LDAA      #%00110000      ; Turn off LED 1,2 at PORTB bit 4,5
            STAA      PORTB           ; Note:LED numbers and PORTB bit numbers are different
            
mainLoop    
            LDAA      PTIP            ; Read push button SW1 at PORTP0
            ANDA      #%00000001      ; check the bit 0 only
            BEQ       sw1pushed       ;
            
             
sw1notpush  BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4
            JSR       times7delay     ; run delay10us by 14 times
            BSET      PORTB,%00010000 ; Turn off LED 1 at PORTB4
            JSR       times93delay    ; run delay10us by 86 times
            BRA       mainLoop        ; jump back to mainloop
                         
sw1pushed   BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4
            JSR       times14delay    ; run delay10us by 7 times
            BSET      PORTB,%00010000 ; Turn off LED 1 at PORTB4
            JSR       times86delay    ; run delay10us by 93 times
            BRA       mainLoop        ; jump back to mainloop            
*****************************************************************************
* Subroutine Section
*

;***********************************************
; 7% brightness subroutines
; include times7delay and times93delay
; two subroutines runs delay10us by 7/93 times
; 
; Input: 8 bit count numbers in 'Counter3' and 'Counter4'
; Output: 7% brightness for LED 1
; Registers in use: B register, as counter
; Memory locations in use: 8 bit input numbers in 'Counter3' and 'Counter4'
;

times7delay
            PSHB
            
            LDAB      Counter3
dly7loop    
            JSR       delay10us            ; B*delay10us
            DECB
            BNE       dly7loop
            
            PULB
            RTS

times93delay
            PSHB
            
            LDAB      Counter4
dly93loop    
            JSR       delay10us            ; B*delay10us
            DECB
            BNE       dly93loop
            
            PULB
            RTS
            
            
;***********************************************
; 14% brightness subroutines
; include times14delay and times86delay
; two subroutines runs delay10us by 14/86 times
; 
; Input: 8 bit count numbers in 'Counter5' and 'Counter6'
; Output: 14% brightness for LED 1
; Registers in use: B register, as counter
; Memory locations in use: 8 bit input numbers in 'Counter5' and 'Counter6'
;

times14delay
            PSHB
            
            LDAB      Counter5
dly14loop    
            JSR       delay10us            ; B*delay10us
            DECB
            BNE       dly14loop
            
            PULB
            RTS

times86delay
            PSHB
            
            LDAB      Counter6
dly86loop    
            JSR       delay10us            ; B*delay10us
            DECB
            BNE       dly86loop
            
            PULB
            RTS
            
;***********************************************
; delay10us subroutine
; 
; This subroutine runs 10 us delay
; 
; Input: a 16 bit count number in 'Counter2'
; Output: time delay of 10us
; Registers in use: Y register, as counter
; Memory locations in use: a 16 bit input numbers in 'Counter2'
    
delay10us
            PSHY
            
            LDY       Counter2
dly10loop   JSR       delay1us               ; Y*delay1us
            DEY
            BNE       dly10loop
            
            PULY
            RTS
            
;************************************************************
; delay1us subroutine
;
; This subroutine causes 1 us delay
; Input: a 16 bit count number in 'Counter1'
; Output: time delay, cpu cycle waisted
; Register in use: X register, as counter
; Memory locations in use: a 16 bit input number in 'Counter1'
;

delay1us
          PSHX
          
          LDX       Counter1             ; short delay
dly1loop  DEX
          BNE       dly1loop
          
          PULX
          RTS
   
            
            
   

            end                   ; last line of a file
            
