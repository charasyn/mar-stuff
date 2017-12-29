;; command-interpreter.asm
;; Designed to allow you to enter simple commands
;; Scroll down to "command_list:"

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
CMD_WAIT      equ 0x05

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

    dw CMD_GO,DIR_SOUTH,1

; Don't put commands after the CMD_DONE
    dw CMD_DONE


initialized: dw 0
restore_valid: dw 0
restore_sp: dw 0

prgm_status: dw 0
debug_text: dw 0

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
    mov a,[bp-1]
    mov b,[a+command_list]
    add a,1
    cmp b,CMD_GO
    jz Main_cmd_go
    cmp b,CMD_DRILL
    jz Main_cmd_drill
    cmp b,CMD_LASER
    jz Main_cmd_laser
    cmp b,CMD_INVENTORY
    jz Main_cmd_inventory
    cmp b,CMD_WAIT
    jz Main_cmd_wait
    mov a,INVENTORY_POLL
    mov [debug_text],b
    hwi HWID_INVENTORY
    jmp Main_finishedLoop

Main_cmd_wait:
    mov [bp-1],a
    call WaitForNextTick
    jmp Main_loop

Main_cmd_go:
    sub sp,2
    mov b,[a+command_list]
    mov [sp],b
    add a,1
    mov b,[a+command_list]
    mov [sp+1],b
    add a,1
    mov [bp-1],a
    call GoInDirection
    add sp,2
    jmp Main_loop

Main_cmd_drill:
    mov [bp-1],a
    call DrillAhead
    jmp Main_loop

Main_cmd_laser:
    sub sp,2
    mov b,[a+command_list]
    mov [sp],b
    add a,1
    mov b,[a+command_list]
    mov [sp+1],b
    add a,1
    mov [bp-1],a
    call DoLaser
    add sp,2
    jmp Main_loop

Main_cmd_inventory:
    mov b,[a+command_list]
    push b
    add a,1
    mov [bp-1],a
    call DoInventory
    add sp,1
    jmp Main_loop

Main_finishedLoop:
    mov [prgm_status],0xd000
    call WaitForNextTick
    jmp Main_finishedLoop

DoInventory:
    push bp
    mov bp,sp
    mov a,[bp+2]
    mov b,0xffff
    hwi HWID_INVENTORY
    mov [debug_text],b
    mov sp,bp
    pop bp
    ret

DoLaser:
    push bp
    mov bp,sp
    mov a,[bp+2]
    mov b,[bp+3]
    hwi HWID_LASER
    call WaitForNextTick
    mov sp,bp
    pop bp
    ret

DrillAhead:
    mov a,DRILL_GATHER_SLOW
    hwi HWID_DRILL
DrillAhead_loop:
    call WaitForNextTick
    mov a,DRILL_POLL
    hwi HWID_DRILL
    test b,b
    jnz DrillAhead_loop
    ret

GoInDirection:
    push bp
    mov bp,sp
    sub sp,4
    mov a,[bp+3] ; get distance
    mov [bp-1],a
    mov a,GET_POS
    hwi HWID_LIDAR
GoInDirection_loop2:
    mov [bp-4],5
GoInDirection_loop1:
    sub [bp-4],1
    jz CrashPrgm
    mov [bp-2],x
    mov [bp-3],y
    mov b,[bp+2] ; get direction
    mov a,SET_DIRECTION_AND_WALK
    hwi HWID_LEGS
    call WaitForNextTick
    mov a,GET_POS
    hwi HWID_LIDAR
    cmp x,[bp-2]
    jnz GoInDirection_notEqual
    cmp y,[bp-3]
    jz GoInDirection_loop1
GoInDirection_notEqual:
    mov a,[bp-1]
    sub a,1
    mov [bp-1],a
    jnz GoInDirection_loop2
    add sp,4
    pop bp
    ret

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
    hwi 9
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