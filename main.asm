list P=18F8722

#include <p18f8722.inc>
config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

state   udata 0x21	    ; state of pace
state

counter   udata 0x22	    ; timer counter
counter
   
Gflags   udata 0x23	    ; 0,3 : for fire (RG1)
Gflags			    ; 1,4 : for down (RG2)
			    ; 2,5 : for up (RG3)
			    ; 6 for astreoid first flag
			    ; 7 for RG0

beamBuffer    udata 0x24	; tempA1
beamBuffer    
    
kartal	    udata 0x25        ; kartal
kartal

vites_high	udata 0x26
vites_high
	    
vites_low	udata 0x27
vites_low	
	
shift_count	udata 0x28
shift_count
	
temp_mod    udata 0x29
temp_mod    
    
F0_buffer   udata 0x2A
F0_buffer
   
temp_high   udata 0x2B
temp_high
  
A_lazer_new udata 0x2C
A_lazer_new
 
B_lazer_new udata 0x2D
B_lazer_new
 
C_lazer_new udata 0x2E
C_lazer_new
 
D_lazer_new udata 0x2F
D_lazer_new
 
E_lazer_new udata 0x30
E_lazer_new
 
F_lazer_new udata 0x31
F_lazer_new
 
A_lazer_old udata 0x32
A_lazer_old
 
B_lazer_old udata 0x33
B_lazer_old
 
C_lazer_old udata 0x34
C_lazer_old
 
D_lazer_old udata 0x35
D_lazer_old
 
E_lazer_old udata 0x36
E_lazer_old
 
F_lazer_old udata 0x37
F_lazer_old
 
 
A_asteroid_new udata 0x38
A_asteroid_new
 
B_asteroid_new udata 0x39
B_asteroid_new
 
C_asteroid_new udata 0x3A
C_asteroid_new
 
D_asteroid_new udata 0x3B
D_asteroid_new
 
E_asteroid_new udata 0x3C
E_asteroid_new
 
F_asteroid_new udata 0x3D
F_asteroid_new
 
A_asteroid_old udata 0x3E
A_asteroid_old
 
B_asteroid_old udata 0x3F
B_asteroid_old
 
C_asteroid_old udata 0x40
C_asteroid_old
 
D_asteroid_old udata 0x41
D_asteroid_old
 
E_asteroid_old udata 0x42
E_asteroid_old
 
F_asteroid_old udata 0x43
F_asteroid_old 
 
temp_logic udata 0x44
temp_logic
 
kartal_old  udata 0x45        
kartal_old 
  
top udata 0x46  
top
 
bottom	udata 0x47
bottom	
	
asteroid_count	udata 0x48
asteroid_count
	
Tflags	udata 0x49 ; 0 is used for timer flag
Tflags

   

org     0x00
goto    init

org     0x08
goto    isr             ;go to interrupt service routine
   

init:
    ;Disable interrupts
    clrf    INTCON
    clrf    INTCON2

    ;Configure Output Ports
    clrf    LATA 
    clrf    LATB 
    clrf    LATC 
    clrf    LATD 
    clrf    LATE
    clrf    LATF 
    clrf    LATH 
    clrf    LATJ 
    
    clrf    TRISA
    clrf    TRISB 
    clrf    TRISC 
    clrf    TRISD 
    clrf    TRISE 
    clrf    TRISF 
    clrf    TRISH 
    clrf    TRISJ 

    BSF ADCON1 , 0
    BSF ADCON1 , 1
    BSF ADCON1 , 2
    BSF ADCON1 , 3
    
    ;Clear the state number
    clrf state
    
    ;Configure Input/Interrupt Ports
    movlw   b'00001111' 
    movwf   TRISG   
    clrf    PORTG

    ;Initialize Timer0
    movlw   b'01000111' ; 8-bit 64 pre-scalar for T0 conf
    movwf   T0CON 
    movlw   b'00111111' ; load 55 to T0 to count 156, to make 5 ms
    movwf   TMR0L
    
    ;Initialize Timer1
    movlw   b'11001101' ; 16-bit w/o pre-scalar for T1 conf
    movwf   T1CON
    
    
    movlw b'00100000'   ; initilizing bottom and top of the board
    movwf bottom , 1
    movlw b'00000001'
    movwf top , 1
    
    movlw b'00001000'       ; INITILIZING THE SPACESHIP
    movwf kartal
    movf kartal , 0
    movff kartal , LATA    ; ALSO PORTA

    
    ;Enable interrupts
    movlw   b'10100000' ;Enable Global, peripheral, Timer0 and RB interrupts by setting GIE, PEIE, TMR0IE and RBIE bits to 1
    movwf   INTCON
    
    ;Enable timer0, timer1
    bsf     T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1
    bsf     T1CON, 0    ;Enable Timer0 by setting TMR0ON to 1
    
    
    
    
    
main:
    call state_check
    call button_task
    call fire_task
    call up_task
    call down_task
    call kartal_move
    BTFSC Tflags , 0
    call GameEngine
    goto main
    
state_check:
    clrf WREG
    CPFSEQ state
    goto other_states
    zeroth_state:
	bcf T0CON,7 ;disable timer 0
	clrf TMR0L  ;clear timer0 buffer
	; Clear all buffers
	clrf A_lazer_new
	clrf A_asteroid_new
	clrf A_lazer_old
	clrf A_asteroid_old
	
	clrf B_lazer_new
	clrf B_asteroid_new
	clrf B_lazer_old
	clrf B_asteroid_old
	
	clrf C_lazer_new
	clrf C_asteroid_new
	clrf C_lazer_old
	clrf C_asteroid_old
	
	clrf D_lazer_new
	clrf D_asteroid_new
	clrf D_lazer_old
	clrf D_asteroid_old
	
	clrf E_lazer_new
	clrf E_asteroid_new
	clrf E_lazer_old
	clrf E_asteroid_old
	
	clrf F_lazer_new
	clrf F_asteroid_new
	clrf F_lazer_old
	clrf F_asteroid_old
	
	clrf asteroid_count
	clrf kartal
	clrf kartal_old
	clrf counter
	clrf beamBuffer
	clrf temp_high
	clrf F0_buffer
	;Cleaned all buffers
	call set_initial_leds
	wait_for_RG0:
	    BTFSS PORTG , 0
	    goto wait_for_RG0
	wait_for_RG0_release:
	    BTFSC PORTG , 0
	    goto wait_for_RG0_release
	incf state
	movlw b'00001000'
	movwf kartal
	movlw   b'00111111' ; load 55 to T0 , to make 5 ms
	bsf     T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1
	return
    other_states:
	movlw b'00000001' ;set wreg to 1
	cpfseq state      
	goto state2       ;if state is not 1
	movlw b'00001010' ;set wreg to 10
	cpfslt asteroid_count
	incf state  ;else increment state
	return	    ;if asteroid_count is less than 10
	state2:
	    movlw b'00000010' ;set wreg to 2
	    cpfseq state      
	    goto state3       ;if state is not 2
	    movlw b'00011110' ;set wreg to 30
	    cpfslt asteroid_count
	    incf state  ;else increment state
	    return
	state3:
	    movlw b'000000011' ;set wreg to 3
	    cpfseq state      
	    goto state4       ;if state is not 3
	    movlw b'00110010' ;set wreg to 50
	    cpfslt asteroid_count
	    incf state  ;else increment state
	    return
	state4:
	    return
	    
	
	
set_initial_leds:
    movlw b'00011111'
    movwf LATA
    movwf LATB
    movwf LATC
    movwf LATD
    movwf LATE
    movwf LATF
    return
    
fire_task:
    BTFSC Gflags , 0
    BTFSC PORTG , 1
    return
    BSF Gflags , 3
    BCF Gflags , 0
    return
down_task:
    BTFSC Gflags , 1
    BTFSC PORTG , 2
    return
    BSF Gflags , 4
    BCF Gflags , 1
    return
up_task:
    BTFSC Gflags , 2
    BTFSC PORTG , 3
    return
    BSF Gflags , 5
    BCF Gflags , 2   
    return
    
button_task:
    BTFSC PORTG , 1
    BSF Gflags , 0
    BTFSC PORTG , 2
    BSF Gflags , 1
    BTFSC PORTG , 3
    BSF Gflags , 2
    return
    
kartal_move:
    BTFSC Gflags , 3
    call kartal_fire
    BTFSC Gflags , 4
    call kartal_down 
    BTFSC Gflags , 5
    call kartal_up
    return
    
kartal_fire:
    movf kartal , 0
    IORWF beamBuffer,1
    BCF Gflags, 3
    return
   
kartal_up:
    movff top , WREG
    CPFSGT kartal 
    goto highest
    movff kartal , kartal_old
    RRNCF kartal , 1
    call kartal_update
    highest:
	BCF Gflags, 5
	return

kartal_down:
    movff bottom , WREG
    CPFSLT kartal 
    goto lowest
    movff kartal , kartal_old
    RLNCF kartal , 1
    call kartal_update
    lowest:
	BCF Gflags, 4
	return
 
kartal_update:
    movf PORTA , 0
    xorwf kartal_old , 0
    iorwf kartal,0
    movwf LATA
    return
    

create_asteroids:
    incf asteroid_count	    ;increment asteroid count
    btfsc Gflags, 6	    
    goto label		    ;if this is not the first asteroid
    movff TMR1L, vites_low
    movff TMR1H, vites_high
    bsf Gflags, 6
    label:
	movlw b'00001010'
	CPFSEQ shift_count
	goto kucuk
	clrf shift_count
	comf vites_low , 1
	comf vites_high , 1
	kucuk:
	    movlw b'00000111'
	    andwf vites_low,0
	    BTFSS WREG , 2
	    goto label2
	    BTFSS WREG , 1
	    goto label2
	    BCF WREG , 2
	    BCF WREG , 1
	    label2:
		movwf temp_mod
		incf temp_mod
		movlw b'00000001'
		loop:
		    dcfsnz temp_mod , 1
		    goto continue
		    RLNCF WREG
		    goto loop
		continue:
		    movwf F0_buffer
		    movff vites_high , temp_high
		    RRCF vites_high , 1
		    RRCF vites_low , 1
		    RRCF temp_high , 1
		    movff temp_high , vites_high
		    incf shift_count , 1
		
		    return

		    
GameEngine:
    bcf Tflags , 0
    clrf counter
    ;Calculations for A buffers
    movff beamBuffer , A_lazer_new 
    movff beamBuffer , A_lazer_old 
    call create_asteroids
    movff F0_buffer , F_asteroid_new
    movf A_lazer_new , 0
    comf WREG 
    andwf B_asteroid_old , 0
    movwf A_asteroid_new
    
    ;Calculations for B buffers
    movf B_asteroid_old , 0
    iorwf C_asteroid_old , 0
    comf WREG 
    iorwf B_lazer_old , 0
    andwf A_lazer_old , 0
    movwf B_lazer_new 
    movf A_lazer_old , 0
    iorwf B_lazer_old , 0
    comf WREG 
    movwf temp_logic 
    movf A_lazer_old , 0
    andwf B_asteroid_old , 0
    iorwf temp_logic , 0
    andwf C_asteroid_old , 0
    movwf B_asteroid_new 
    
    
  ;Dalculations for C buffers
    movf C_asteroid_old , 0
    iorwf D_asteroid_old , 0
    comf WREG 
    iorwf C_lazer_old , 0
    andwf B_lazer_old , 0
    movwf C_lazer_new
    
    movf B_lazer_old , 0
    iorwf C_lazer_old , 0
    comf WREG
    movwf temp_logic 
    movf B_lazer_old , 0
    andwf C_asteroid_old , 0
    iorwf temp_logic , 0
    andwf D_asteroid_old , 0
    movwf C_asteroid_new
    
    
  ;Dalculations for D buffers
    movf D_asteroid_old , 0
    iorwf E_asteroid_old , 0
    comf WREG 
    iorwf D_lazer_old , 0
    andwf C_lazer_old , 0
    movwf D_lazer_new 
    
    movf C_lazer_old , 0
    iorwf D_lazer_old , 0
    comf WREG
    movwf temp_logic 
    movf C_lazer_old , 0
    andwf D_asteroid_old , 0
    iorwf temp_logic , 0
    andwf E_asteroid_old , 0
    movwf D_asteroid_new 
    
    
  ;Dalculations for E buffers
    movf E_asteroid_old , 0
    iorwf F_asteroid_old , 0
    comf WREG 
    iorwf E_lazer_old , 0
    andwf D_lazer_old , 0
    movwf E_lazer_new 
    
    movf D_lazer_old , 0
    iorwf E_lazer_old , 0
    comf WREG
    movwf temp_logic 
    movf D_lazer_old , 0
    andwf E_asteroid_old , 0
    iorwf temp_logic , 0
    andwf F_asteroid_old , 0
    movwf E_asteroid_new 
    
    
  ;Dalculations for F buffers
    movf F_asteroid_old , 0
    iorwf F0_buffer , 0
    comf WREG 
    iorwf F_lazer_old , 0
    andwf E_lazer_old , 0
    movwf F_lazer_new 
    
    movf E_lazer_old , 0
    iorwf F_lazer_old , 0
    comf WREG
    movwf temp_logic 
    movf E_lazer_old , 0
    andwf F_asteroid_old , 0
    iorwf temp_logic , 0
    andwf F0_buffer , 0
    movwf F_asteroid_new
    
    movff A_asteroid_new , A_asteroid_old
    movff B_asteroid_new , B_asteroid_old
    movff C_asteroid_new , C_asteroid_old
    movff D_asteroid_new , D_asteroid_old
    movff E_asteroid_new , E_asteroid_old
    movff F_asteroid_new , F_asteroid_old
    
    movff A_lazer_new , A_lazer_old
    movff B_lazer_new , B_lazer_old
    movff C_lazer_new , C_lazer_old
    movff D_lazer_new , D_lazer_old
    movff E_lazer_new , E_lazer_old
    movff F_lazer_new , F_lazer_old
    
    movf kartal , 0
    iorwf A_asteroid_new , 0
    movwf LATA
    
    movf B_asteroid_new , 0
    iorwf B_lazer_new , 0
    movwf LATB 
    
    movf C_asteroid_new , 0
    iorwf C_lazer_new , 0
    movwf LATC 
    
    movf D_asteroid_new , 0
    iorwf D_lazer_new , 0
    movwf LATD 
    
    movf E_asteroid_new , 0
    iorwf E_lazer_new , 0
    movwf LATE 
    
    movf F_asteroid_new , 0
    iorwf F_lazer_new , 0
    movwf LATF 
    
    clrf beamBuffer 
    return
    

isr:
    BCF INTCON,2   ;timer0 interrupt is received, make 0 overflow bit
    incf counter,1 ;increment timer counter
    movlw b'00000001' ;set wreg to 1
    cpfseq state
    goto state_2_isr
    goto state_1_isr
    state_1_isr:
	movlw   b'00111111' ; load 55 to T0 to count 156, to make 5 ms
	movwf   TMR0L
	movlw b'01100100'
	CPFSLT counter  
	BSF Tflags, 0   ;if counter is not less than 100
	retfie FAST
    state_2_isr:
	movlw b'00000010' ;set wreg to 2
	cpfseq state
	goto state_3_isr
	movlw   b'00111111' ; load 55 to T0 to count 156, to make 5 ms
	movwf   TMR0L
	movlw b'01010000'
	CPFSLT counter  
	BSF Tflags, 0   ;if counter is not less than 80
	retfie FAST
    state_3_isr:
	movlw b'00000011' ;set wreg to 2
	cpfseq state
	goto state_4_isr
	movlw   b'00111111' ; load 55 to T0 to count 156, to make 5 ms
	movwf   TMR0L
	movlw b'00111100'
	CPFSLT counter  
	BSF Tflags, 0   ;if counter is not less than 60
	retfie FAST
    state_4_isr:
	movlw   b'00111111' ; load 55 to T0 to count 156, to make 5 ms
	movwf   TMR0L
	movlw b'00101000'
	CPFSLT counter  
	BSF Tflags, 0   ;if counter is not less than 40
	retfie FAST
end