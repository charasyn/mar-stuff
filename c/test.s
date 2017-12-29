	.text
	.globl _manhattanDistance
_manhattanDistance:
	pushl	%ebx
	movl	12(%esp), %edx
	movl	20(%esp), %ebx
	movl	8(%esp), %ecx
	subl	16(%esp), %ecx
	movl	%ecx, %eax
	testl	%ecx, %ecx
	js	L5
L2:
	subl	%ebx, %edx
	movl	%edx, %ecx
	testl	%edx, %edx
	js	L6
L3:
	addl	%ecx, %eax
	popl	%ebx
	ret
L5:
	negl	%eax
	jmp	L2
L6:
	negl	%edx
	movl	%edx, %ecx
	jmp	L3
	.globl _TestFunc
_TestFunc:
	movl	4(%esp), %eax
	movl	8(%esp), %edx
	imull	%eax, %eax
	imull	%edx, %edx
	addl	%edx, %eax
	ret
	.globl _c_main
_c_main:
	subl	$24, %esp
	pushl	$_str
	call	_PrintStr
	movl	$1, (%esp)
	call	_DoInventory
	addl	$8, %esp
	pushl	$10
	pushl	$0
	call	_GoInDirection
	addl	$8, %esp
	pushl	$5
	pushl	$1
	call	_GoInDirection
	addl	$28, %esp
	ret
	.globl _str
	.data
	.align 2
_str:
	.ascii "Hello World!\12\0"
	.subsections_via_symbols
