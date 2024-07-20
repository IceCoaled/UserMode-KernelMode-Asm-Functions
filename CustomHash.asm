.code

;EXTERN_C uintmax_t __stdcall CustomHash(const char* str);
CustomHash proc

	push rbx ; Preserve non volatile registers
	push rsi
	push rdi
	push rbp
	
	push rcx ; save string
	xor r14, r14 ; clear register for hash

	mov rsi, rcx ; Set the string
	mov r13, 0F0101010101h ; Set the hash
	
Hash:
	xor rax, rax ; Clear the register for the char
	lodsb ; Load the char from the string
	test al, al ; Check if the string is over
	jz HashEnd ; If it is, end the hash

	xor r14, rax
	imul r14, r13 
	sub r13, r14
	ror r14, 10h
	shl r14, 6h

	jmp Hash

HashEnd:
        mov rax, r14 ; Set the return value
	pop rcx ; restore string
	
	pop rbp ; Restore non volatile registers
	pop rdi
	pop rsi
	pop rbx


	ret
CustomHash endp

end
