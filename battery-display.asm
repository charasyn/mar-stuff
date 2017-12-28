mov a,1 ; battery: poll cur.
hwi 10
push b
mov a,2 ; battery: poll max.
hwi 10
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
cmp b,0x0999
jl notgt
mov b,0x0999
notgt:
or b,0xb000
mov a,b
hwi 9