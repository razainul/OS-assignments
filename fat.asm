;FAT
.model small

print macro msg

        push ax
        push dx
        mov ah,09h
        lea dx,msg
        int 21h
        pop dx
        pop ax
endm

PUSHALL MACRO
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
ENDM

POPALL MACRO
       POP DI
       POP SI
       POP DX
       POP CX  
       POP BX  
       POP AX 
 ENDM

.stack

.data
        fat_buffer db 4608 dup(0)
        file_buffer db 512 dup(0)
        name_buf db 11 dup(0)
        root_dir_buf db 512 dup(0)
        msg_found db 10,13,"file found$"
        msg_notfound db 10,13,"file not found$"
        clus_end db 10,13,"file endds$"
        count db 00h
        srt_clus dW 00h
        CLUS_NEXT DW 00H
        RET_MSG DB "RETUN FROM PROC$"
        NEWLINE DB 10,13,10,13,"$"

.code

main proc
        
                mov ax,@data
                mov ds,ax
                mov es,ax

                mov ah,01h
                lea di,name_buf
                mov cx,11
                bk:
                int 21h
                stosb
                dec cx
                jnz bk

                ot:
                
                mov al,0
                mov cx,1
                mov dx,13h
                
                lea bx,root_dir_buf 
                int 25h
                lea di,root_dir_buf
                mov count,16
                up:
                
                lea si,name_buf
                mov dx,di
                mov cx,11
                repe cmpsb 
                
                cmp cx,0
                        je found
                
                ;if not found
                mov di,dx
                add di,32
                dec count
                jnz up

                cmp count,0
                        jne found

             
                        print msg_notfound
                        mov ah,4Ch
                        int 21h


                
                found:
                        print msg_found
                        MOV DI,DX
                        ADD DI,1AH
                        MOV bX,[DI]
                        
                        mov srt_clus ,bX

                        mov bX,srt_clus                
                        
                        ;****read and print sector

                        add BX,31
                        MOV DX,BX
                        mov al,0
                        mov cx,1
                        lea bx,file_buffer
                        int 25h
                                     
                        lea si,file_buffer
                        mov cx,512
               
                        neww:
                        
                         lodsb
                         mov dl,al
                         mov ah,02h
                         int 21h
                         dec cx
                         jnz neww

                        
                        mov al,0
                        mov cx,9
                        mov dx,1
                        lea bx,fat_buffer
                        int 25h
                        
                        mov bx,srt_clus
                        mov clus_next,bx

                      bk4:  
                        
                        MOV AX,clus_next
                        PRINT NEWLINE

                        PUSH AX
                        ADD AL,30H
                        MOV DL,AL
                        MOV AH,02H
                        INT 21H
                        POP AX
                        
                        PRINT NEWLINE

                        MOV CL,3
                        MUL CL
                        
                        
                        SHR AX,1
                        
                        MOV BX,AX

                        MOV AX,clus_next
                        mov cl,2
                        div cl
                        CMP Ah,0
                                JE EVEN1
                        
                        ;ELSE ODD
                             
                             MOV AX,bX
                             LEA DI,FAT_BUFFER

                             PUSH BX
                             ADD DI,AX
                             MOV BX ,[DI]
                             MOV CLUS_NEXT,BX
                             POP BX
                             
                             SHR CLUS_NEXT,4
                             MOV DX,CLUS_NEXT
                             cmp dx,0FFFh
                                je endd

                             ;MOV BX,DX
                             
                             ;****read and print sector

                        add dX,31
                        ;MOV DX,BX
                        mov al,0
                        mov cx,1
                        lea bx,file_buffer
                        int 25h
                                     
                        lea si,file_buffer
                        mov cx,512
               
                        neww1:
                        
                         lodsb
                         mov dl,al
                         mov ah,02h
                         int 21h
                         dec cx
                         jnz neww1

                             
                             JMP bk4


                        EVEN1:
                             
                             MOV AX,BX
                             LEA DI,FAT_BUFFER
                             
                             PUSH BX
                             
                             ADD DI,AX
                             MOV BX,[DI]
                             MOV CLUS_NEXT ,BX
                             POP BX

                             
                             AND CLUS_NEXT,0FFFH
                             
                             MOV DX,CLUS_NEXT
                             cmp dx,0FFFh
                                
                                je endd
                            ;MOV BX,DX
                            ;******read and print sector

                        add dX,31
                        ;MOV DX,BX
                        mov al,0
                        mov cx,1
                        lea bx,file_buffer
                        int 25h
                                     
                        lea si,file_buffer
                        mov cx,512
               
                        neww2:
                        
                         lodsb
                         mov dl,al
                         mov ah,02h
                         int 21h
                         dec cx
                         jnz neww2



                        JMP bk4

                ENDD:
                mov ah,4ch
                int 21h

ENDP MAIN
END MAIN


