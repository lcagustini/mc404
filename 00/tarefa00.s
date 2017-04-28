.org 0x200

start:
    set r0, 0x5000
    set r1, 0x200
    add r0, r1
    shl r0, 0x2
    hlt
