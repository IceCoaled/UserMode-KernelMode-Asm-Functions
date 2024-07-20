Ive included Here ASM Functions for extracting function pointers from PE32+ images.
The Hash algorithm is created custom by me, i havent had any collisions yet from various testing.

UM-KM File holds a GetProcAddress that takes a function name hash, as well as a image base address
![Screenshot 2024-07-20 011832](https://github.com/user-attachments/assets/13fce2c1-3a6d-446b-a894-d1d1b6f75c00)

KmFunctions File holds a Function to get Ntoskrnl base Address with an out parameter of PsLoadedModulesList.
It also includes a GetProcAddress for Ntoskrnl specifically that takes just a function name hash.
![Screenshot 2024-07-20 012458](https://github.com/user-attachments/assets/a183ce09-57ab-485e-895c-3dffb471a9d3)

Getting Ntoskrnl base Address uses RVA's these are obviously subject to change based on Nt Version.
I'm currently on version 23h2 (OS build 22631.3880), it has a kernel verison of Windows 10 Kernel Version 22621.
that means this should work just fine down to that windows 10 version with no changes.

This Project was directly inspired by 
https://zerosum0x0.blogspot.com/2017/04/doublepulsar-initial-smb-backdoor-ring.html

