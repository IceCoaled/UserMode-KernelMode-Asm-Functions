.code

;EXTERN_C void* __stdcall FunctionExport(__in const uintmax_t functionHash, __in void* dllBase);
FunctionExport proc

	mov r10, rcx 
	push r10 ; Save function hash

	mov r11, rdx
	push r11 ; Save dll base
	
	push rbx ; Preserve non volatile registers
	push rsi
	push rdi
	push rbp

	mov rcx, r11 ; Set the dll base
	mov ebx, dword ptr [r11 + 3Ch] ; Get the Pe header
	add rcx, rbx ; Add the dll base to Pe header
	
	mov ebx, dword ptr [rcx + 88h] ; Get the export directory
	add rbx, r11 ; Add the dll base to the export directory
	
	mov edi, dword ptr [rbx + 20h] ; Get AddressOfNames
	add rdi, r11 ; Add the dll base to the AddressOfNames Rva

	xor rbp, rbp ; Clear index


Search:
	mov esi, dword ptr [rdi + rbp * 04h] ; Get the function Rva
	add rsi, r11 ; Add the dll base to the function Rva
	inc ebp ; Increment the index
	
	xor r14, r14 ; Clear the register for hash
	mov r12, 0F0101010101h ; Set the hash

Hash:
    	xor rax, rax ; Clear the register for the char
	lodsb ; Load the char from the string
	test al, al ; Check if the string is over
	jz HashEnd ; If it is, end the hash

	xor r14, rax
	imul r14, r12 
	sub r12, r14
	ror r14, 10h
	shl r14, 6h

	jmp Hash ; Repeat the hash

HashEnd:
	mov rax, r14 ; rax = hash
	cmp r10, rax ; Compare the hash with the function hash
	jnz Search ; If not, search the next function

	xor rax, rax ; Clear for the return value
	
	mov r15d, dword ptr [rbx + 24h] ; Get the AddressofnamesOrdinals
	add r15, r11 ; Add the dll base to the AddressofnamesOrdinals Rva

	mov bp, word ptr [r15 + rbp * 02h] ; Get the function ordinal
	mov r15d, dword ptr [rbx + 1Ch] ; Get the AddressOfFunctions
	add r15, r11 ; Add the dll base to the AddressOfFunctions Rva

	mov r15d, dword ptr [r15 + rbp * 04h - 04h] ; Get the function address
	add r15, r11 ; Add the dll base to the function address
	mov rax, r15 ; Set the return value

	pop rbp ; Restore non volatile registers
	pop rdi
	pop rsi
	pop rbx
	
	pop r11 ; Restore the dll base
	pop r10 ; Restore the function hash
	
	ret

FunctionExport endp


end
