.code



GetDllBase proc
	
	mov r10, rcx 
	push r10 ; Save dll name hash
	
	push rbx ; Preserve non volatile registers
	push rsi
	push rdi
	push rbp
	
	mov rax, qword ptr gs:[60h] ; Get the PEB
	lea rbx, qword ptr [rax + 18h] 
	mov rdx , qword ptr [rbx] ; load the Ldr
	lea rbx, qword ptr [rdx + 20h] 
	mov rax, qword ptr [rbx] ; load InMemoryOrderModuleList
	mov rax, qword ptr [rax] ; Get the first module

	mov rbx, rax 
	mov rbp, rax ; Save the first module
	jmp FirstModule

NextModule:
	mov rbp, qword ptr [rbp] ; Get the next module
	cmp rbp, rbx ; Compare the next module with the first module
	je ModuleNotFound ; If we are, the module is not loaded
FirstModule:
		
	mov rsi, qword ptr [rbp + 50h]; Get the dll base name string

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
	cmp r10, r14 ; Compare the hash with the dll name hash
	jnz NextModule ; If not, search the next module
	lea rax, qword ptr [rbp + 20h] ; Get the dll base
	mov rax, [rax] ; Set the return value
	jmp ModuleFound ; End the function

ModuleNotFound:
	xor rax, rax ; Clear the return value
	
ModuleFound:	
	pop rbp ; Restore non volatile registers
	pop rdi
	pop rsi
	pop rbx
	pop r10 ; Restore dll name hash

	ret
GetDllBase endp

	end
