Note: If you have problems with any of these functioning, just let me know with a brief outline of the issue and ill fix it.

>>>>>ALL HASHING IS CASE SENSTIVE<<<<<

Ive included Here ASM Functions for extracting function pointers from PE32+ images. With a couple 
functions for obtaining dll base addresses. one kernel specific for ntoskrnl.
The Hash algorithm is created custom by me, i havent had any collisions yet from various testing.

UM-KM File holds a GetProcAddress that takes a function name hash, as well as a image base address
![Screenshot 2024-07-20 011832](https://github.com/user-attachments/assets/13fce2c1-3a6d-446b-a894-d1d1b6f75c00)

KmFunctions File holds a Function to get Ntoskrnl base Address with an out parameter of PsLoadedModulesList.
It also includes a GetProcAddress for Ntoskrnl specifically that takes just a function name hash.
![Screenshot 2024-07-20 012458](https://github.com/user-attachments/assets/a183ce09-57ab-485e-895c-3dffb471a9d3)

Getting Ntoskrnl base Address uses RVA's these are obviously subject to change based on Nt Version.
I'm currently on version 23h2 (OS build 22631.3880), it has a kernel verison of Windows 10 Kernel Version 22621.
that means this should work just fine down to that windows 10 version with no changes.

UPDATE: Added wide char hash function, as well as a function to get any dll base. it takes the dll name hash(wchar_t*)
![Screenshot 2024-07-20 165916](https://github.com/user-attachments/assets/0704b291-92e6-4303-a8a5-96c5e65236c0)

UPDATE2: Added A PsLoadedModuleList walker, this takes module name hash(wchar_t*) and PsLoadedModuleList pointer
![Screenshot 2024-07-21 013540](https://github.com/user-attachments/assets/42aef968-1b69-4bbf-9923-508a445c6d28)


This Project was directly inspired by 
https://zerosum0x0.blogspot.com/2017/04/doublepulsar-initial-smb-backdoor-ring.html

