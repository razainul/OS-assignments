;A Program to show File operations

.model small

print macro msg
        push dx
        push ax
        mov ah,09h
        lea dx,msg
        int 21h
        pop ax
        pop dx
endm

.stack
.data
        buffer db 20 dup(0)
        ren1 db 10,13,10,13,"FILE RENAMED!!$"
        filenam db 30 dup(0)
        handle dw 0
        input db 10,13,10,13,"enter data:$",10,13
        msg db 10,13,10,13,"failed to open$"
        msg2 db 10,13,10,13,"failed to write$"
        count dw 00h
        
        NEWNAM DB 30 DUP(0)
        cret db 10,13,10,13,"FILE CREATED!$"
        openn db 10,13,10,13,"FILE OPENED!$"
        write db 10,13,10,13,"FILE WRITE SUCCESSFUL!$"
        read db 10,13,10,13,"FILE CONTENTS ARE::$"
        flag db 00h
        choice db 00h
        msgQ db 10,13,10,13,"MENU:::$"
        msga db 10,13,"1.CREATE NEW FILE$"
        msgb db 10,13,"2.OPEN A FILE$"
        msgc db 10,13,"3.WRITE INTO FILE$"
        msgd db 10,13,"4.READ FROM FILE$"
        msge db 10,13,"5.RENAME FILE$"
        msgf db 10,13,"6.DELETE FILE$"
        ERR1 db 10,13,".....ERROR IN FILE OPERATION...$"
        msgEC db 10,13,10,13,"enter choice:: $"
        DEE DB 10,13,10,13,"FILE DELETED!$"
        NOCRET DB 10,13,10,13,"CREATE FILE FIRST!$"
        nowrit db 10,13,10,13,"NO DATA WRITTEN-CANNOT READ!$"
        ENTR DB 10,13,10,13,"ENTER FILE NAME(with ext):$"


.code

        main proc
                mov ax,@data
                mov ds,ax     ;initialise ds:dx as file pointer    
                mov es,ax
menu:                

                
                call option

                cmp choice,'1'
                        je create
                cmp choice,'2'
                        je open
                cmp choice,'3'
                        je writ
                cmp choice,'4'
                        je rd
                cmp choice,'5'
                        je renm
                cmp choice,'6'
                        je del
                cmp choice,'7'
                        je ext
jmp menu



        EXT:        
                mov ah,4Ch
                int 21h

        CREATE:        
                print entr

                lea di,filenam     ;array to store elements          
                bk2:
                
                mov ah,01h         ;read char
                int 21h
                cmp al,0Dh
                        je ot2
                
                stosb           ;store in buffer
                jmp bk2            ;read till 'enter'
               
              ot2:

                mov dx,offset filenam
                mov cx,00h        ;file attrib:normal
                mov ah,3Ch        ;create
                int 21h
                JC ERROR          ;PRINT IF UNSUCCESFUL
                PRINT CRET
                MOV FLAG,1
                jmp menu

ERROR:       

                print err1
                jmp menu


        OPEN:         
                CALL OPN
                JMP MENU

        WRIT:        
                call inpt
                call wr
                jmp menu
        
        RD:
                call reed
                jmp menu                
                
        RENM:
                CALL RENQ
                JMP MENU

        DEL: 
                mov ah,41h
                
                lea dx,filenam
                int 21h
                jc ERROR
                PRINT DEE
                JMP MENU
                

endp main

OPN PROC NEAR

                CMP FLAG,1
                        JNE ER        

                mov ah,3Dh      ;open
                mov al,2        ;access mode-read write
                int 21h
                jc fail         ;failed to open        
                
                PRINT OPENN
                mov handle,ax   ;save handle (16bit) 
                MOV FLAG,2
                jmp menu
        
           ER:
                PRINT NOCRET
                
           fail:
                print msg
                

RET
ENDP

RENQ PROC NEAR

                cmp flag,2
                
                jle end2

                PRINT ENTR
                
                lea di,NEWNAM   ;array to store elements          
                bk1:
                
                mov ah,01h      ;read char
                int 21h
                cmp al,0Dh
                        je ot1
                
                stosb           ;store in buffer
                jmp bk1         ;read till 'enter'
               
              ot1:

                mov dx,offset filenam
                mov di,offset newnam

                mov ah,56h
                int 21h
                jc incrt
                PRINT REN1
                MOV CX,30
                LEA DI,FILENAM
                LEA SI,NEWNAM
                REP MOVSB

                JMP EXIT1
                incrt:
                        print err1
                jmp exit1

END2:                       
print nocret
print err1

exit1:


RET 
ENDP


reed proc near


                ;********close file and reopen****

                CMP FLAG,3
                        jne ER2

                mov bx,handle      ;file to close
                mov ah,3Eh         ;close a file
                int 21h
                
                mov ah,3Dh        ;reopen file in read mode
                mov al,00h        ;read mode
                mov dx,offset filenam
                int 21h

                mov ah,3Fh        ;read a file
                mov bx,handle     ;handle
                mov cx,count      ;no of bytes to be read
                mov dx,offset buffer  
                int 21h           ;buffer to store bytes read
               
                print read
                
                lea si,buffer     ;print nos read from file                       
                mov cx,count
                mov ah,02h
                AA:
                
                lodsb
                mov dl,al
                int 21h
                dec cx
                jnz AA
                jmp end3
                ER2:
                        print nowrit

end3:                        

ret
endp


option proc near

        push ax        
        
                print msgQ
                print msga
                print msgb
                print msgc
                print msgd
                print msge
                print msgf
                print msgEC

                mov ah,01h
                int 21h

                mov choice,al

        pop ax
ret
endp

inpt proc near

        push ax        
        push di
        push cx

                CMP FLAG,2
                        jne errr1
                
                print input

lea di,buffer     ;array to store elements          
                mov cx,00h

                bk:
                
                mov ah,01h            ;read char
                int 21h
                cmp al,0Dh
                        je ot
                
                stosb           ;store in buffer
                inc cx
                
                jmp bk          ;read till 'enter'
               
              ot:

                mov count,cx
                jmp AS

        ERRR1:
        print err1

        AS:
        pop cx
        pop di
        pop ax
ret
endp

wr proc near

                ;*******WRITE INTO FILE********
                CMP FLAG,2
                JNE ER3
                mov ah,40h           ;write into file
                mov bx,handle        ;bx gets file handle
                mov cx,count         ;no of bytes to write
                mov dx,offset buffer ;ds:dx has buffer address
                int 21h
                jc FAIL_w            ;failes to write        
                print write
                mov flag,3
                jmp endd
             fail_w:
                print msg2
                ER3:

endd:

ret
endp

end main

