@256
D=A
@0
M=D
@return-address.0
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
@0
D=D-A
@5
D=D-A
@2
M=D
@0
D=M
@1
M=D
@Sys.init
0;JMP
(return-address.0)
(Main.fibonacci)
@0
D=A
@2
A=M+D
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=A
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
D=M-D
M=-1
@jump_point.0
D;JLT
@0
A=M
M=0
(jump_point.0)
@0
M=M+1
@0
M=M-1
A=M
D=M
@IF_TRUE
D;JNE
@IF_FALSE
0;JMP
(IF_TRUE)
@0
D=A
@2
A=M+D
D=M
@0
A=M
M=D
@0
M=M+1
@1
D=M
@13
M=D
@5
D=A
@13
A=M-D
D=M
@14
M=D
@0
D=A
@2
M=M+D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@0
D=A
@2
M=M-D
@2
D=M
@0
M=D+1
@1
D=A
@13
A=M-D
D=M
@4
M=D
@2
D=A
@13
A=M-D
D=M
@3
M=D
@3
D=A
@13
A=M-D
D=M
@2
M=D
@4
D=A
@13
A=M-D
D=M
@1
M=D
@14
A=M
0;JMP
(IF_FALSE)
@0
D=A
@2
A=M+D
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=A
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
M=M-D
@0
M=M+1
@return-address.1
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
@1
D=D-A
@5
D=D-A
@2
M=D
@0
D=M
@1
M=D
@Main.fibonacci
0;JMP
(return-address.1)
@0
D=A
@2
A=M+D
D=M
@0
A=M
M=D
@0
M=M+1
@1
D=A
@0
A=M
M=D
@0
M=M+1
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
M=M-D
@0
M=M+1
@return-address.2
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
@1
D=D-A
@5
D=D-A
@2
M=D
@0
D=M
@1
M=D
@Main.fibonacci
0;JMP
(return-address.2)
@0
M=M-1
A=M
D=M
@0
M=M-1
A=M
M=M+D
@0
M=M+1
@1
D=M
@13
M=D
@5
D=A
@13
A=M-D
D=M
@14
M=D
@0
D=A
@2
M=M+D
@0
M=M-1
A=M
D=M
@2
A=M
M=D
@0
D=A
@2
M=M-D
@2
D=M
@0
M=D+1
@1
D=A
@13
A=M-D
D=M
@4
M=D
@2
D=A
@13
A=M-D
D=M
@3
M=D
@3
D=A
@13
A=M-D
D=M
@2
M=D
@4
D=A
@13
A=M-D
D=M
@1
M=D
@14
A=M
0;JMP
(Sys.init)
@4
D=A
@0
A=M
M=D
@0
M=M+1
@return-address.3
D=A
@0
A=M
M=D
@0
M=M+1
@1
D=M
@0
A=M
M=D
@0
M=M+1
@2
D=M
@0
A=M
M=D
@0
M=M+1
@3
D=M
@0
A=M
M=D
@0
M=M+1
@4
D=M
@0
A=M
M=D
@0
M=M+1
@0
D=M
@1
D=D-A
@5
D=D-A
@2
M=D
@0
D=M
@1
M=D
@Main.fibonacci
0;JMP
(return-address.3)
(WHILE)
@WHILE
0;JMP
(END)
@END
0;JMP
