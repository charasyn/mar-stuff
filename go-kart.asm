;; Hardware IDs
HWID_LEGS     equ 0x1
HWID_LASER    equ 0x2
HWID_LIDAR    equ 0x3
HWID_KEYBOARD equ 0x4
HWID_DRILL    equ 0x5
HWID_INV      equ 0x6
HWID_RNG      equ 0x7
HWID_CLOCK    equ 0x8
HWID_HOLO     equ 0x9
HWID_BATTERY  equ 0xA
HWID_FLOPPY   equ 0xB

;;  Drill
;;  Version 1.0B
DRILL_POLL        equ 1 ; Cost: 0kJ
  ;; Get the status of the drill
DRILL_GATHER_SLOW equ 2 ; Cost: 1400kJ
  ;; Gather the resource located under the Cubot (4 tick)*
DRILL_GATHER_FAST equ 3 ; Cost: 2000kJ
  ;; Gather the resource located under the Cubot (1 tick)

;;  Additional info
;;  The drill status is either STATUS_OK (0x0000) or STATUS_BUSY = (0x0001).
;;  When trying to activate the mining drill while it is busy, it will fail silently


;;  Inventory
;;  Version 1.0B
INV_POLL  equ 1 ; Cost: 0kJ
  ;; Get the contents of the inventory (B = Item ID, 0x0000 if empty)
INV_CLEAR equ 2 ; Cost: 100kJ
  ;; Safely destroy the contents of the inventory


;;  Laser
;;  Version 1.0B
LASER_WITHDRAW equ 1 ; Cost: 30kJ
  ;; Withdraw the desired item
LASER_DEPOSIT  equ 2 ; Cost: 30kJ
  ;; Withdraw the desired item

;; Additional Info
;; Specify the desired item by setting the value of the B register with an item ID.


;;  Legs
;;  Version 1.0B
LEGS_SET_DIRECTION          equ 1 ; Cost: 20kJ
  ;; Set the direction
LEGS_SET_DIRECTION_AND_WALK equ 2 ; Cost: 100kJ
  ;; Set the direction and walk forward

LEGS_DIR_NORTH equ 0
LEGS_DIR_EAST  equ 1
LEGS_DIR_SOUTH equ 2
LEGS_DIR_WEST  equ 3

;;  Additional Info
;;  Specify the direction in the B register


;;  LiDAR
;;  Version 1.0B
LIDAR_GET_POS       equ 1 ; Cost: 0kJ
  ;; Copy the current (x,y) coordinates in the World in the X and Y registers
LIDAR_GET_PATH      equ 2 ; Cost: 50kJ
  ;; Calculate the shortest path to the specified coordinates and copy it to memory
LIDAR_GET_MAP       equ 3 ; Cost: 10kJ
  ;; Generate the current World's map and copy it to memory
LIDAR_GET_WORLD_POS equ 4 ; Cost: 0kJ
  ;; Copy the current (x,y) coordinates in the Universe in the X and Y registers

;; Additional Info
;; Theres a lot, see it at:
;; https://github.com/simon987/Much-Assembly-Required/wiki/Hardware:-LiDAR


;;  Keyboard
;;  Version NA
KEYBOARD_CLEAR     equ 0 ; Cost: 0kJ
  ;; Clear the keypress buffer
KEYBOARD_FETCH_KEY equ 1 ; Cost: 0kJ
  ;; Reads the oldest keycode from the buffer into the B register and remove it

;;  Additional Info
;;  Keycodes: keycode.info


;;  Hologram Projector
;;  Version 1.0B
HOLO_CLEAR equ 0 ; Cost: 0kJ
  ;; Don't display anything
HOLO_DISPLAY_HEX equ 1
HOLO_DISPLAY_STRING equ 2

;;  Additional Info
;;  Setting Register A to anything other than 0 will cause that value to be displayed
;;  Note that the Hologram Projector will clear itself at the end of the tick,
;;  it is only necessary to use CLEAR when you want to cancel a DISPLAY command
;;  executed within the same tick.


;;  Battery
;;  Version 1.0B
BATTERY_POLL             equ 1 ; Cost: 0kJ
  ;; Copy the current charge of the battery in kJ in the B register
BATTERY_GET_MAX_CAPACITY equ 2 ; Cost: 0kJ
  ;; Copy the maximum capacity of the battery in the B register

;;  Additional Info
;;  Maximum Capacity: 60,000 kJ
;;  As of v1.2a, the only way to refill the battery is to use the temporary
;;  REFILL = 0xFFFF value in the A register (See #2)


;;  Random Number Generator
;;  Version 1.0B
RNG_POLL equ 0 ; Cost: 1kJ
  ;; Copy a randomly generated word into the B register
  ;; Set to 0 just as a placeholder, can be any number

;;  Additional Info
;;  Random number bounds: 0x0000 - 0xFFFF


;;  Clock
;;  Version 1.0B
CLOCK_POLL equ 0 ; Cost: 0kJ
  ;; Get the current time in ticks since the beginning of the universe as
  ;; a 32-bit number stored in B:C (least significant bits in C)
  ;; Set to 0 just as a placeholder, can be any number


;;  Floppy Drive
;;  Version 1.0B
FLOPPY_POLL equ 1 ; Cost: 0kJ
  ;; Get the status of the drive (READY = 0, NO_MEDIA=1)
FLOPPY_READ_SECTOR equ 2 ; Cost: 1kJ
  ;; Reads sector X to CPU ram starting at address Y
FLOPPY_WRITE_SECTOR equ 3 ; Cost: 1kJ
  ;; Writes sector X from CPU ram starting at Y

;;  Additional Info
;;  The players can upload their own binary data to a floppy disk or
;;  download to a file using the floppy buttons in the editor.
;;  Floppies contains 80 tracks with 18 sectors per track. That's
;;  1440 sectors of 512 words. (total 1,474,560 bytes / 737,280 words / 1.44MB)
;;  Read and write operations are synchronous. Track seeking time is 2ms.*
;;  *Seek time is added to the total execution time, which is not yet calculated as of v1.3a


ACTION_NONE  equ 0x0000
ACTION_LOOK  equ 0x0001
ACTION_WALK  equ 0x0002
ACTION_LASER equ 0x0003

.data

initialized: dw 0
restore_valid: dw 0
restore_sp: dw 0

debug_text: dw 0

action:    dw 0
action_p1: dw 0
action_p2: dw 0

display: dw 0,0,0,0,0,0,0,0,0

.text
    jmp __start
_main:
    call _ClearKeyboard
;_main_loop:
;    call _PollKeyboard
;    ; left up right down
;    cmp a,0x25
;    jl _main_notdirs
;    cmp a,0x28
;    jg _main_notdirs
;    ; they pressed a directional key
;    push a
;    call _HandleDirectionalKey
;    add sp,2
;_main_notdirs:

    call _FinishTick
    jmp _main_loop

; void HandleDirectionalKey(int keycode);
_HandleDirectionalKey:
    push bp
    mov bp,sp
    mov [action], ACTION_WALK
    mov a,[bp+2]
    sub a,0x26 ; subtract the value for up
    jns _HandleDirectionalKey_noadd
    add a,4
_HandleDirectionalKey_noadd:
    mov [action_p1],a
    mov sp,bp
    pop bp
    ret

; void ClearKeyboard(void);
_ClearKeyboard:
    mov a,KEYBOARD_CLEAR
    hwi HWID_KEYBOARD
    ret

; int PollKeyboard(void);
_PollKeyboard:
    mov a,KEYBOARD_FETCH_KEY
    hwi HWID_KEYBOARD
    mov a,b
    ret

; void DrawStringOnScreen(int * str);
_DrawStringOnScreen:
    push bp
    mov bp,sp
    mov b,[bp+2]
    mov a,HOLO_DISPLAY_STRING
    hwi HWID_HOLO
    mov sp,bp
    pop bp
    ret

; void FinishTick(void);
_FinishTick:
    push bp
    mov bp,sp

    push display
    call _WriteBatteryText
    add sp,2
    push display
    call _DrawStringOnScreen
    add sp,2

    call _WaitForNextTick
    mov sp,bp
    pop bp
    ret

; void WriteTimeText(int * dest);
_WriteTimeText:
    push bp
    mov bp,sp
    add sp,0

    

    mov sp,bp
    pop bp
    ret

; void WriteBatteryText(int * dest);
_WriteBatteryText:
    push bp
    mov bp,sp
    add sp,0

    mov c,[bp+2]
    mov [c+0],0x42 ; B
    mov [c+1],0x3a ; :
    mov [c+5],0x2e ; .
    mov [c+7],0x25 ; %
    mov a, BATTERY_POLL
    hwi HWID_BATTERY
    push b
    mov a, BATTERY_GET_MAX_CAPACITY
    hwi HWID_BATTERY
    xor y,y
    pop a
    mul 1000
    div b
    cmp a,1000
    jle _WriteBatteryText_max_no
    mov a,1000
_WriteBatteryText_max_no:
    xor y,y
    div 10
    add y,0x30
    mov [c+6],y
    xor y,y
    div 10
    add y,0x30
    mov [c+4],y
    xor y,y
    div 10
    add y,0x30
    mov [c+3],y
    add a,0x30
    mov [c+2],a
    mov sp,bp
    pop bp
    ret

__start:
    mov a,[restore_valid]
    test a,a
    jnz RestorePrevTickState
    mov a,[initialized]
    test a,a
    jnz InvalidRestore
    mov a,1
    mov [initialized],a
    jmp _main

; void WaitForNextTick(void);
_WaitForNextTick:
    push bp
    mov [restore_sp],sp
    mov a,1
    mov [restore_valid],a
    brk
RestorePrevTickState:
    xor a,a
    mov [restore_valid],a
    mov sp,[restore_sp]
    pop bp
    ret

; void CrashPrgm(void);
_CrashPrgm:
    mov [prgm_status],0xc000
    call _WaitForNextTick
    jmp _CrashPrgm

; void InvalidRestore(void);
_InvalidRestore:
    mov a,0xff80
    hwi HWID_HOLO
    brk
