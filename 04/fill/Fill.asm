// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.
(LOOP)
@paint
M=0

@24576 //keyboard
D=M
@WHITE
D;JEQ

@paint
M=-1

(WHITE)
//全体を塗りつぶすためのループ
@SCREEN
D=A
@i
M=D //i=screen
@8192
D=A
@i
M=M+D //i=screen+8192
(PAINTLOOP)
@i
D=M
@PAINTLOOPEND
D;JEQ //(i==0なら抜ける)
//<drawing
@paint
D=M
@i
M=M-1 //デクリメント
A=M
M=D
//drawing>
@PAINTLOOP
0;JMP
(PAINTLOOPEND)

@LOOP
0;JMP
