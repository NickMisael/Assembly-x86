%define O_RONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2

section .data
  fname: db "input.txt",0
  desc: db "! = ",0 
  msgerror: db "Error: Invalid Input!",0  

section .text
  global _start:
    strlen:
      xor rax, rax
      .loop:
        cmp byte[rdi+rax], 0
        je .end
        cmp byte[rdi+rax],0xa
        je .end
        inc rax
        jmp .loop
        
        .end:
          ret
  
    printStr:
      push rdi
      call strlen  
      pop rsi
      mov rdx, rax
      mov rax, 1
      mov rdi, 1
      syscall
      ret

    printUint:
      mov rax, rdi
      mov rdi, rsp
      push 0 
      sub rsp, 16
    
      dec rdi
      mov r8, 10

      .loop:
        xor rdx, rdx
        div r8
        or dl, 0x30
        dec rdi
        mov [rdi], dl
        test rax, rax
        jnz .loop

        call printStr
        add rsp, 24
        ret     

    verNum:
      mov rax, 1
      cmp rdi, 0
      jl .false
      jmp .end
      .false:
        mov rax, 0
     .end:
        ret

    pow:
      cmp rsi, 0
      je .zero
      cmp rsi, 1
      je .um
      jmp .exp      
      
      .zero:
        mov rdi, 1
        ret
      
      .um:
        mov rax, rdi
        ret
      
      .exp:
        push rcx
        mov rcx, 2
        mov rax, rdi
        .loop:
          mul rdi
          cmp rcx, rsi
          je .end
          inc rcx
          jmp .loop
        
      .end:
        pop rcx
        ret
  
    isnum:
      mov al, 0x30

      .loop:
        cmp rdi, rax 
        je .end     
        cmp rax, 0x3a
        je .false
        inc rax
        jmp .loop
        
      .end:
        mov rax, 1
        ret
  
      .false:
        mov rax, 0
        ret

    asciiToDecimal:
      xor r9, r9
      call strlen
      mov r8, rax         ; r8 = tamanho da str  
      xor rcx, rcx        ; rcx = ponteiro
      push rdi

      .loop:
      dec r8
      pop rdi
      mov rdx, [rdi+rcx]  ; rdx = um char 
      xor eax, eax
      mov al, dl
      push rdi
      push rax
      xor rdi, rdi
      mov rdi, rax
      call isnum
      cmp rax, 0
      je .err
      pop rax
      pop rdi
      sub eax, 0x30       ; rax = char  
      push rdi
      push rax
      mov rdi, 10        ; passa o arg 1 de pow (base)
      mov rsi, r8         ; passa o arg 2 de pow (potencia)
      call pow
      pop rdi
      cmp r8, 1
      jl .jmprdi
      mul rdi
      .jmprdi:
      inc rcx
      add r9, rax         ; r9 = numero em hexa
      cmp r8, 0
      je .end
      jmp .loop

      .err:
        pop rdi
        pop rdi
        mov rax, msgerror
        ret

      .end:
        pop rdi
        mov rax, r9
        ret      

    fatorial:
      call asciiToDecimal
      cmp rax, msgerror
      jne .cont
      mov rdi, rax
      call printStr
      ret
      .cont:
        push rax 
        mov rdi, rax
        call printUint
        
        pop rax
        mov rdi, rax
        dec rdi
      
        .loop:
          cmp rdi, 0
          je .end 
          mul rdi
          dec rdi
          jmp .loop
        
        .end:
          ret        
   
    open:
      mov rax, 2
      mov rsi, O_RONLY
      mov rdx, 0 
      syscall 
      ret

    mmap:
      mov rax, 9
      mov rdi, 0
      mov rsi, 4096
      mov rdx, PROT_READ
      mov r10, MAP_PRIVATE
      mov r9, 0
      syscall
      ret  

    exit:
      mov rax, 60
      xor rdi, rdi
      syscall 

    _start:
      mov rdi, fname
      call open 

      mov r8, rax
      call mmap
     
      push rax 
      mov rdi, rax
      call fatorial

      push rax
      mov rdi, desc
      call printStr

      pop rdi
      call printUint
      

      mov rdi, rdi
      

      call exit
        
