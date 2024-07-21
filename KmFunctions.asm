.code


; EXTERN_C void* __stdcall GetNtoskrnlBase(__out void** psLoadedModuleList);
GetNtoskrnlBase proc

  	push rbx ; Preserve non volatile registers
  	push rsi
  	push rdi
  	push rbp; 
  	
  	mov r10, rcx
  	push r10 ; Save out parameter
  
  	mov rdx, gs:[38h] ; rdx = _KIDTENTRY64* inside _KPCR
  
  	mov ecx, [rdx + 8h] ; ecx = _KIDTENTRY64->highOffset
  	shl rcx, 10h
  	add cx, [rdx + 6h] ; _KIDTENTRY64->middleOffset
  	shl rcx, 10h
  	add cx, [rdx] ; _KIDTENTRY64->lowOffset
  	mov rdx, rcx
  	shr rdx, 0Ch
  	shl rdx, 0Ch ; rdx = IDT Base address
  
  
  pageLoop:
  	sub rdx, 01000h ; Subtract page size
  	mov rsi, [rdx] 
  	cmp si, 5A4Dh ; Check for Dos Header Signature(4 Byte packed version of mz sig)
  
  	jne pageLoop ; If not, continue
  
  	sub rdx, 01A2000h ; ntoskrnl base = rdx - 0x1A2000
  	mov rax, rdx ; rax = ntoskrnlBase Address
  
  
  	add rdx, 0C13510h ; PsLoadedModuleList = ntoskrnlBase + 0xC1510
  	pop r10 
  	mov rcx, r10 ; rcx = out parameter
  	mov [rcx], rdx ; rcx = PsLoadedModuleList
  
  	pop rbp ; Restore non volatile registers
  	pop rdi
  	pop rsi
  	pop rbx
  
  	ret

GetNtoskrnlBase endp


; EXTERN_C void* __stdcall GetNtosKrnlExport(__in const uintmax_t functionHash);
GetNtosKrnlExport proc

    push rbx ; Preserve non volatile registers
    push rsi
    push rdi
    push rbp; 
    
    mov r10, rcx
    push r10 ; Save function hash
    
    mov rdx, gs:[38h] ; rdx = _KIDTENTRY64* inside _KPCR
    
    mov ecx, [rdx + 8h] ; ecx = _KIDTENTRY64->highOffset
    shl rcx, 10h
    add cx, [rdx + 6h] ; _KIDTENTRY64->middleOffset
    shl rcx, 10h
    add cx, [rdx] ; _KIDTENTRY64->lowOffset
    mov rdx, rcx
    shr rdx, 0Ch
    shl rdx, 0Ch ; rdx = IDT Base address
    
    
pageLoop:
    sub rdx, 01000h ; Subtract page size
    mov rsi, [rdx] 
    cmp si, 5A4Dh ; Check for Dos Header Signature(4 Byte packed version of mz sig)
    
    jne pageLoop ; If not, continue
    
    sub rdx, 01A2000h ; ntoskrnl base = rdx - 0x1A2000
    push rdx ; Save ntoskrnl base
    mov rcx, rdx ; Set rcx to ntoskrnl base
    
    ; Get the Pe header
    mov ebx, dword ptr [rdx + 3Ch]
    add rcx, rbx ; Add ntoskrnl base to Pe header
    
    mov ebx, dword ptr [rcx + 88h] ; Get the export directory
    add rbx, rdx ; Add ntoskrnl base to the export directory
    
    mov edi, dword ptr [rbx + 20h] ; Get AddressOfNames
    add rdi, rdx ; Add ntoskrnl base to the AddressOfNames Rva
    
    xor rbp, rbp ; Clear index


Search:
  	mov esi, dword ptr [rdi + rbp * 04h] ; Get the function Rva
  	add rsi, rdx ; Add ntoskrnl base to the function Rva
  	inc ebp ; Increment the index
  	
  
  	xor r14, r14 ; Clear the register for the hash
  	mov r13, 0F0101010101h ; Set the hash

Hash:
      xor rax, rax ; Clear the register for the char
  	lodsb ; Load the char from the string
  	test al, al ; Check if the string is over
  	jz HashEnd ; If it is, end the hash
  
  	xor r14, rax ; xor the char with the hash
  	imul r14, r13 ; Multiply the hash with the magic number
  	sub r13, r14 ; Subtract the hash from the magic number
  	ror r14, 10h ; Rotate the hash
  	shl r14, 6h ; Shift the hash
  
  	jmp Hash ; Repeat the hash

HashEnd:
    mov rax, r14 ; Set the hash to the return value
  	cmp r10, rax ; Compare the hash with the function hash
  	jnz Search ; If not, search the next function
  
  	xor rax, rax ; Clear for the return value
  	
  	mov r15d, dword ptr [rbx + 24h] ; Get the AddressofnamesOrdinals
  	add r15, rdx ; Add ntoskrnl base to the AddressofnamesOrdinals Rva
  
  	mov bp, word ptr [r15 + rbp * 02h] ; Get the function ordinal
  	mov r15d, dword ptr [rbx + 1Ch] ; Get the AddressOfFunctions
  	add r15, rdx ; Add ntoskrnl base to the AddressOfFunctions Rva
  
  	mov r15d, dword ptr [r15 + rbp * 04h - 04h] ; Get the function address
  	add r15, rdx ; Add ntoskrnl base to the function address
  	mov rax, r15 ; Set the return value
  
  	pop rdx ; Restore ntoskrnl base
  	pop r10 ; Restore function hash
  
  	pop rbp ; Restore non volatile registers
  	pop rdi
  	pop rsi
  	pop rbx
  	
  	ret
GetNtosKrnlExport endp



; EXTERN_C void* __stdcall GetModuleBase(__in const uintmax_t moduleNameHash, __in const void* PsLoadedModuleList);
GetModuleBase proc
	
	
	mov r10, rcx 
	push r10 ; Save module name hash
	
	push rbx ; Preserve non volatile registers
	push rsi
	push rdi
	push rbp
	
	mov rax, qword ptr [rdx] ; Get the first module

	mov rbx, rax 
	mov rbp, rax ; Save the first module
	jmp FirstModule

NextModule:
	mov rbp, qword ptr [rbp] ; Get the next module
	cmp rbp, rbx ; Compare the next module with the first module
	je ModuleNotFound ; If we are, the module is not loaded
FirstModule:
		
	mov rsi, qword ptr [rbp + 60h]; Get the Module base name string

	xor r14, r14 ; Clear the register for hash
	mov r12, 0F0101010101h ; Set the hash

Hash:
	xor rax, rax ; Clear the register for the char
	lodsw ; Load the char from the string
	test al, al ; Check if the string is over
	jz HashEnd ; If it is, end the hash

	xor r14, rax ; xor hash with char
	imul r14, r12 ; multiply hash with magic number
	sub r12, r14 ; subtract the hash from the magic number
	ror r14, 10h ; rotate the hash
	shl r14, 6h ; shift the hash

	jmp Hash ; Repeat the hash

HashEnd:
	cmp r10, r14 ; Compare the hash with the module name hash
	jnz NextModule ; If not, search the next module
	mov rax, qword ptr [rbp + 30h] ; Get the module base
	jmp ModuleFound ; End the function

ModuleNotFound:
	xor rax, rax ; Clear the return value
	
ModuleFound:	
	pop rbp ; Restore non volatile registers
	pop rdi
	pop rsi
	pop rbx
	pop r10 ; Restore module name hash

	ret
GetModuleBase endp

end



