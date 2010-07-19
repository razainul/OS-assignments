;Calculator using math co-processor




DISP MACRO STR
        MOV AH,09H
        MOV DX,OFFSET STR
        INT 21H
ENDM

DATA SEGMENT
        NUM DD 0.0
        NUM1 DD 0.0
        NUM2 DD 0.0
        FLAG DB 0
        RESULT DD ?
        MSG0 DB 10,13,"ENTER NO1 :$"
        MSG1 DB 10,13,"ENTER NO2 :$"
        MSG2 DB 10,13,"1.ADDITION:$"
        MSG3 DB 10,13,"2.SUBTRACTION:$"
        MSG4 DB 10,13,"3.MULTIPLICATION:$"
        MSG5 DB 10,13,"4.DIVISION:$"
        MSG6 DB 10,13,"5.EXIT:$"
        MSG7 DB 10,13,"ENTER YR CHOICE:$"
        MSG8 DB 10,13,"RESULT IS : $"
        MSG9 DB 10,13,"DO U WANT TO CONTINUE:$" 
        MSG10 DB 10,13,"ERROR: DIVIDE BY ZERO$"
        TEN DD 10.0
        IP DW ?
        CW DW ?
        DIVP DD 1.0
        TEMP DD 1.0
        DIVI DD 1.0E5
        TEMP1 DD 1.0E5
        DIG DD 6 DUP(0.0)
            DD 6 DUP(0.0)
        PI DD 3.1416
        
DATA ENDS

CODE SEGMENT
        ASSUME CS:CODE,DS:DATA
START:
        MOV AX,DATA
        MOV DS,AX
       
        FINIT
        DISP MSG0
        CALL ACCEPT
        FWAIT
S1:
        MOV AX,WORD PTR NUM
        MOV WORD PTR NUM1,AX
        MOV AX,WORD PTR NUM+2
        MOV WORD PTR NUM1+2,AX

        MOV WORD PTR NUM,0
        MOV WORD PTR NUM+2,0

        MOV AX,WORD PTR TEMP
        MOV WORD PTR DIVP,AX
        MOV AX,WORD PTR TEMP+2
        MOV WORD PTR DIVP+2,AX
        
        MOV AX,WORD PTR TEMP1
        MOV WORD PTR DIVI,AX
        MOV AX,WORD PTR TEMP1+2
        MOV WORD PTR DIVI+2,AX
        FINIT
        DISP MSG1
        MOV FLAG,00H
        CALL ACCEPT
        FWAIT

        MOV AX,WORD PTR NUM
        MOV WORD PTR NUM2,AX
        MOV AX,WORD PTR NUM+2
        MOV WORD PTR NUM2+2,AX
        
        MOV WORD PTR NUM,0
        MOV WORD PTR NUM+2,0

        MOV AX,WORD PTR TEMP
        MOV WORD PTR DIVP,AX
        MOV AX,WORD PTR TEMP+2
        MOV WORD PTR DIVP+2,AX


        DISP MSG2
        DISP MSG3
        DISP MSG4
        DISP MSG5
        DISP MSG6

        DISP MSG7
        
        
        MOV AH,01H
        INT 21H
        CMP AL,31H
        JE A
        CMP AL,32H
        JE S
        CMP AL,33H
        JE M
        CMP AL,34H
        JE D
        CMP AL,35H
        JE EXIT1

A:      FINIT
        FLD NUM1
        FADD NUM2
        FSTP RESULT
        FWAIT
        CALL CHECK
        JMP C1

S:      FINIT
        FLD NUM1
        FSUB NUM2
        FSTP RESULT
        FWAIT
        CALL CHECK
        JMP C1


M:      FINIT
        FLD NUM1
        FMUL NUM2
        FSTP RESULT
        FWAIT
        CALL CHECK
        JMP C1
S2:     JMP S1 
 EXIT1:JMP EXIT
D:      FINIT
        MOV AX,WORD PTR NUM2                                                                                                                                                                                                      
        CMP AX,0000H
        JE NEXT
        JMP NOERROR
 NEXT:  MOV AX,WORD PTR NUM2+2
        CMP AX,0000H
        JE ERROR
NOERROR:FLD NUM1
        FDIV NUM2
        FSTP RESULT
        CALL CHECK
        JMP C1
ERROR:  DISP MSG10        
        JMP CHOICE
        
C1:     DISP MSG8
        CMP FLAG,02H
        JE  MINUS
        JMP C2
MINUS:  MOV DX,'-'
        MOV AH,02H
        INT 21H
   C2:  SUB SI,SI
        CALL DIGITS
        CALL DIGITS
        LEA SI,DIG
        CALL SHOW
        MOV DL,'.'
        MOV AH,02H
        INT 21H
        CALL SHOW
        
CHOICE:DISP MSG9
       MOV AH,01H
       INT 21H
       CMP AL,'Y'
       JE S2        
EXIT:   MOV AH,4CH
        INT 21H

ACCEPT PROC NEAR
LOOP1:
           SUB AX,AX
           MOV AH,01H
           INT 21H
           CMP AL,'-'
           JE SET
           JMP CONT
    SET:
           MOV FLAG,1
           JMP LOOP1
    CONT:           
           FLD NUM
           XOR AH,AH
           CMP AL,0DH
           JE END1
           CMP AL,'.'
           JE LOOP2

           SUB AL,30H
           MOV IP,AX
           FMUL TEN
           FIADD IP
           FST NUM
           JMP LOOP1

LOOP2:
           MOV AH,01H
           INT 21H

           CMP AL,0DH
           JE END1
           SUB AL,30H
           XOR AH,AH
           MOV IP,AX
           FLD DIVP
           FMUL TEN
           FSTP DIVP
           FILD IP
           FDIV DIVP
           FADD
           JMP LOOP2
END1:
           FST NUM
          
           CMP FLAG,1
           JE SET1
           JMP NOTSET
           sub ax,ax
    SET1:  MOV AX,WORD PTR NUM+2
           OR AX,8000H
           MOV WORD PTR NUM+2,AX
    NOTSET:

           RET
ENDP

DIGITS PROC NEAR
        MOV CX,6
UP:
        FINIT
        
        FSTCW CW
        OR CW,0C00H
        FLDCW CW

        FLD RESULT
        FDIV DIVI
        FRNDINT
        FST DIG[SI]

        FLD DIVI
        FMUL DIG[SI]
        FLD RESULT
        FSUBR
        FST RESULT

        FLD DIVI
        FDIV TEN
        FST DIVI

        FWAIT
        ADD SI,4
        LOOP UP
        RET
ENDP

SHOW PROC NEAR
        MOV CX,6
UP1:
        MOV AH,[SI+3]
        MOV AL,[SI+2]
        SHL AX,1
        SUB AH,127
        MOV DL,[SI+2]
        OR DL,80H
        SUB DH,DH
UP2:
        SHL DX,1
        CMP AH,0
        JZ DOWN
        DEC AH
        JMP UP2

DOWN:
        MOV DL,DH
        ADD DL,30H
        MOV AH,02H
        INT 21H
        ADD SI,4
        LOOP UP1
        RET
ENDP
CHECK PROC NEAR
        MOV FLAG,00H
        MOV AX,WORD PTR RESULT+2
        SHL AX,1
        JC MINUS0
        JMP C1
 MINUS0:
        MOV FLAG,02H
     RET
ENDP
CODE ENDS
END START
        


    


