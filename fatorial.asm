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

    pow:                    ; routine power calculation
      cmp rsi, 0            ; compare rsi with 0 
      je .zero              ; if rsi == 0, jump to zero
      cmp rsi, 1            ; compare rsi with 1
      je .um                ; if rsi == 1, jump to one
      jmp .exp              ; else jump to exp

      .zero:
        mov rax, 1
        ret
      
      .um:
        mov rax, rdi
        ret
      
      .exp:
        push rcx            ; save rcx value 
        mov rcx, 2          ; mov 2 to rcx
        mov rax, rdi        ; mov rdi to rax
        .loop:
          mul rdi           ; multiply rax to rdi
          cmp rcx, rsi      ; compare rsi with rcx
          je .end           ; if rsi == rcx, jump to end
          inc rcx           ; else, increment rcx
          jmp .loop         ; jump to loop
        
      .end:
        pop rcx             ; get value of rcx
        ret                 ; return
  
    isnum:
      mov al, 0x30          ; mov 0x30 to al

      .loop:      
        cmp rdi, rax        ; compare rdi with rax 
        je .end             ; if rdi == rax, jump to end
        cmp rax, 0x3a       ; compare rax with 0x3a
        je .false           ; if rax == 0x3a, jump to false
        inc rax             ; else, increment rax
        jmp .loop           ; jump to loop

      .end:
        mov rax, 1          ; mov true to rax 
        ret
  
      .false:
        mov rax, 0          ; mov false to rax
        ret

    asciiToHex:
      call strlen         ; calcula o tamanho da str
      
      xor r9, r9          ; r9 guarda o valor convertido em hexa
      mov r8, rax         ; r8 = tamanho da str  
      xor rcx, rcx        ;
      

      .loop:
        dec r8              ; decrementa o ponteiro
        
        mov rdx, [rdi+rcx]     ; rcx = ponteiro
        xor eax, eax        ; garante que rax estara zerado
        mov al, dl          ; copia apenas um byte para ax
        
        push rdi            ; save addr of str
        push rax            ; salva o caracter na pilha
        
        xor rdi, rdi        ; garante que rdi estara zerado 
        mov rdi, rax        ; passa o char como arg1, para verificar se eh um num    
        call isnum          ; call isnum routine
        
        cmp rax, 0          ; compare if isnum returned error         
        je .err             ; if yes, jump for err
        
        pop rax             ; else recover rax, rdi values
        pop rdi             ; recover addr of str

        sub eax, 0x30       ; get hex value (0x35 ==> 0x5)           
        push rdi            ; push rdi, rax  
        push rax            ;

        mov rdi, 10         ; passa o arg 1 de pow (base)
        mov rsi, r8         ; passa o arg 2 de pow (potencia)
        call pow
        
        pop rdi             ; get base number in rdi
        cmp r8, 1           ; compare if r8 == 1
        jl .jmprdi          ; if r8 < 1 jump rdi
        mul rdi             ; else multiply rax to rdi
        
        .jmprdi:            
          inc rcx           ; increment rcx
          add r9, rax       ; sum rax to r9, r9 == [rdi]
          cmp r8, 0         ; compare if r8 == 0
          je .end           ; if yes, jump to end
          pop rdi
          jmp .loop         ; else jump to loop

      .err:       
        pop rdi             ; recover rdi addr to input.txt content
        mov rax, msgerror   ; set rax with error message
        ret

      .end:
        pop rdi             ; recover rdi addr to input.txt content
        mov rax, r9         ; rax = hexa value 
        ret      

    fatorial:
      call asciiToHex
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
        
