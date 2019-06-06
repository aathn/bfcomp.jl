# bfcomp.jl
A brainfuck compiler written in Julia.

This is the repo of a small project to write a simple Brainfuck
compiler in Julia. The files contained are:

- [bfinterp.jl](bfinterp.jl): A Brainfuck interpreter
- [bfcomp.jl](bfcomp.jl): A program compiling Brainfuck to MIPS assembly
- [bfx86.jl](bfx86.jl): A program compiling Brainfuck to an x86 executable for Linux

The repo also includes an example Brainfuck program calculating the
first 11 Fibonacci numbers.

To test the interpreter:

`$ julia bfinterp.jl bfibonacci.b`

`1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89`
