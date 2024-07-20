;EXTERN_C uintmax_t __stdcall SdbmHash(const char* str);
SdbmHash proc

	push rbx ; Preserve non volatile registers
	push rsi
	push rdi
	push rbp
	
	push rcx ; save string
	xor rax, rax ; clear register for hash
	xor rbx, rbx ; clear register for index

	mov rsi, rcx ; Set the string
	Hash:
	lodsb ; Load the char from the string
	test al, al ; Check if the string is over
	jz HashEnd ; If it is, end the hash

	shl rax, 06h
	add rax, rbx ; add the hash
	shl rax, 10h
	sub rax, rbx ; subtract the hash

	jmp Hash

HashEnd:
	pop rcx ; restore string
	
	pop rbp ; Restore non volatile registers
	pop rdi
	pop rsi
	pop rbx


	ret
SdbmHash endp
