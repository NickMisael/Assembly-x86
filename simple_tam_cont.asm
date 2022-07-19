%define O_RONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2

section .bss
  stat: resb 144

section .data
  fname: db "teste.txt",0
  tamtxt: db "O tamanho do arquivo eh: ",0
  nl: db 0xA
  contxt: db "Conteudo:",0xA
  
  struc STAT
    .st_dev         resq 1
    .st_ino         resq 1
    .st_nlink       resq 1
    .st_mode        resd 1
    .st_uid         resd 1
    .st_gid         resd 1
    .st_pad0        resd 1
    .st_rdev        resq 1
    .st_size        resq 1
    .st_blksize     resq 1
    .st_blocks      resq 1
    .st_atime       resq 1
    .st_atime_nsec  resq 1
    .st_mtime       resq 1
    .st_mtime_nsec  resq 1
    .st_ctime       resq 1
    .st_ctime_nsec  resq 1
  endstruc
  
    

section .text
  global _start:
    strlen:
       xor rax, rax             ; zera o nosso contador/pointer
        .loop:                  ;
          cmp byte[rdi+rax], 0  ; compara se o endereco mais para onde o pointer aponta  = \0
          je .end               ; caso seja, encerra o loop
          inc rax               ; caso nao, incrementa o nosso contador
          jmp .loop             ; pula para o inicio do loop
        .end:
          ret  
    
    printStr:
        mov rsi, rdi  ; string 
        call strlen   ; rotina que calcula o tamanho da str
        mov rdx, rax  ; size
        mov rax, 1    ; syscall 'write'
        mov rdi, 1    ; stdout
        syscall
        ret
    
    printChar:
      push rdi        ; salva o valor na pilha
      mov rdi, rsp    ; pega o addr que agora contem o valor guardado
      call printStr   ; chama printStr
      pop rdi         ; retorna o valor para rdi
      ret             ; 

    newLine:
      mov rdi, 0xA    ; passa como arg o \n
      jmp printChar   ; pula para o printChar
  
    uintprint:
      mov rax, rdi    ; salva o arg em rax
      mov rdi, rsp    ; salva o addr do topo da pilha em rdi
      push 0          ; empurra 0 para o topo da pilha
      sub rsp, 16     ; subtrai 0x10 bytes do topo da pilha 

      dec rdi
      mov r8, 10      ; atribui 10 ao r8
      
      .loop:
        xor rdx, rdx    ; zera rdx para divisao
        div r8          ; divide os numeros em EDX:EAX por r8
        or dl, 0x30     ; Faz um OR para pegar o correspondente em decimal
        dec rdi         ; decrementa rsp
        mov [rdi], dl   ; move dl para rdi
        test rax, rax   ; verifica se rax = \0
        jnz .loop       ; se nao retorna ao inicio do loop
        
        call printStr   ; chama a rotina printStr
       
        add rsp, 24     ; incrementa rsp em 0x18
      ret       
  
    _start: 
        mov rax, 4
        mov rdi, fname
        mov rsi, stat
        syscall
        
        mov eax, dword[stat + STAT.st_size] 
        mov edi, eax
        push rdi
        mov rdi, tamtxt
        call printStr
        
        pop rdi
        call uintprint
       
        call newLine

        mov rax, 2
        mov rdi, fname
        mov rsi, O_RONLY
        mov rdx, 0
        syscall 
       
        push rax
        mov rdi, contxt
        call printStr

        pop rax 
        mov r8, rax
        mov rax, 9
        mov rdi, 0
        mov rsi, 4096
        mov rdx, PROT_READ
        mov r10, MAP_PRIVATE
        mov r9, 0
        syscall

        mov rdi, rax
        call printStr

        mov rax, 60
        xor rdi, rdi
        syscall
