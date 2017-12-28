HWID_LEGS equ 0x1
HWID_LASER equ 0x2
HWID_LIDAR equ 0x3
HWID_KEYBOARD equ 0x4
HWID_DRILL equ 0x5
HWID_INVENTORY equ 0x6
HWID_RNG equ 0x7 ; random number generator
HWID_CLOCK equ 0x8
HWID_HOLO equ 0x9
HWID_BATTERY equ 0xA
HWID_FLOPPY equ 0xB

GET_POS equ 0x1

SET_DIRECTION_AND_WALK equ 0x2

LASER_WITHDRAW equ 1
LASER_DEPOSIT equ 2

DRILL_POLL equ 1
DRILL_GATHER_SLOW equ 2
DRILL_GATHER_FAST equ 3

INVENTORY_POLL equ 1
INVENTORY_CLEAR equ 2

BATTERY_POLL equ 1
BATTERY_GET_MAX_CAPACITY equ 2

CMD_DONE      equ 0x00
CMD_GO        equ 0x01
CMD_DRILL     equ 0x02
CMD_LASER     equ 0x03
CMD_INVENTORY equ 0x04

DIR_NORTH equ 0x0
DIR_EAST  equ 0x1
DIR_SOUTH equ 0x2
DIR_WEST  equ 0x3

.data

command_list:
; Enter commands here!
; Example "Go" command (moves the bot)
;   dw CMD_GO, DIR_SOUTH, 9 ; Moves the bot 9 units south
; Example "Drill" command (drills)
;   dw CMD_DRILL ; Drills the block below you

    ;dw CMD_GO,DIR_NORTH,1
    ;dw CMD_GO,DIR_WEST,5
    ;dw CMD_DRILL
    ;dw CMD_INVENTORY,INVENTORY_POLL
; Don't put commands after the CMD_DONE
    dw CMD_DONE


initialized: dw 0
restore_valid: dw 0
restore_sp: dw 0

prgm_status: dw 0
inhibit_status: dw 0
debug_text: dw 0
temp: dw 0xabcd

.text
    mov a,[restore_valid]
    test a,a
    jnz RestorePrevTickState
    mov a,[initialized]
    test a,a
    jnz InvalidRestore
    mov a,1
    mov [initialized],a
    mov [debug_text],0x3333
    call WaitForNextTick
    mov [debug_text],0x2222
    call WaitForNextTick
    mov [debug_text],0x1111
    call WaitForNextTick
    
Main:
    mov bp,sp
    sub sp,1
    xor a,a
    mov [bp-1],a
Main_loop:
    mov [inhibit_status],1
    call WaitForNextTick
    push 1
    push 2
    push 3
    push 4
    push 5
    push 6
    pop [temp]
    mov [debug_text],[sp]
    call WaitForNextTick
    call WaitForNextTick
    mov [debug_text],[sp+1]
    call WaitForNextTick
    call WaitForNextTick
    mov [debug_text],[sp+2]
    call WaitForNextTick
    call WaitForNextTick
    mov [debug_text],[sp+3]
    call WaitForNextTick
    call WaitForNextTick
    mov [debug_text],[temp]
    call WaitForNextTick
    call WaitForNextTick
    mov [inhibit_status],0
    jmp Main_finishedLoop

Main_finishedLoop:
    mov [inhibit_status],0
    mov [prgm_status],0xd000
    call WaitForNextTick
    jmp Main_finishedLoop

ShowBattery:
    mov a, BATTERY_POLL
    hwi HWID_BATTERY
    push b
    mov a, BATTERY_GET_MAX_CAPACITY
    hwi HWID_BATTERY
    xor y,y
    pop a
    mul 1000
    div b
    xor y,y
    div 10
    mov b,y
    shl b,8
    xor y,y
    div 10
    shr b,4
    shl y,8
    or b,y
    xor y,y
    div 10
    shr b,4
    shl y,8
    or b,y
    test a,a
    jz ShowBattery_notgt
    mov b,0x0999
    ShowBattery_notgt:
    mov a,[prgm_status]
    test a,a
    jnz ShowBattery_noReloadSt
    mov a,0xb000
ShowBattery_noReloadSt:
    or b,a
    mov a,b
    ret

WaitForNextTick:
    push bp
    mov [restore_sp],sp
    mov a,1
    mov [restore_valid],a
    mov a,[debug_text]
    test a,a
    mov [debug_text],0
    jnz WaitForNextTick_validText
    mov a,[inhibit_status]
    test a,a
    mov a,0
    jnz WaitForNextTick_validText
    call ShowBattery
WaitForNextTick_validText:
    hwi HWID_HOLO
    brk
RestorePrevTickState:
    xor a,a
    mov [restore_valid],a
    mov sp,[restore_sp]
    pop bp
    ret

CrashPrgm:
    mov [prgm_status],0xc000
    call WaitForNextTick
    jmp CrashPrgm

InvalidRestore:
    mov a,0xff80
    hwi HWID_HOLO
    brk