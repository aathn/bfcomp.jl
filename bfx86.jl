"""A program compiling Brainfuck code to a Linux x86 executable."""
function main(args)
    if length(args) < 1
        println("No file specified.")
        println("Usage: julia bfx86.jl <input file> [output file]")
        exit(1)
    end
    prog = ""
    try
        prog = String(
        open(args[1]) do file
            read(file)
        end
        )
    catch
        println("Could not open file!")
        exit(1)
    end

    output =
"global _start

section .data
memory_arr: times 30000 db 0

section .text
_start:
push r12
mov r12, memory_arr
\n"

    proglen = length(prog)
    current_label = 0
    labelcounts = Int[]

    i = 1
    while i <= proglen
        c = prog[i]
        if c == '>'
            substr = match(r"[\s>]+", prog, i).match
            i += length(substr)-1
            nr_to_shift = length(filter(!isspace, substr))
            output *= "add r12, $nr_to_shift\n\n"

        elseif c == '<'
            substr = match(r"[\s<]+", prog, i).match
            i += length(substr)-1
            nr_to_shift = length(filter(!isspace, substr))
            output *= "sub r12, $nr_to_shift\n\n"

        elseif c == '+'
            substr = match(r"[\s\+]+", prog, i).match
            i += length(substr)-1
            nr_to_add = length(filter(!isspace, substr))
            output *=

"mov al, [r12]
add al, $nr_to_add
mov byte [r12], al
\n"

        elseif c == '-'
            substr = match(r"[\s\-]+", prog, i).match
            i += length(substr)-1
            nr_to_sub = length(filter(!isspace, substr))
            output *=

"mov al, [r12]
sub al, $nr_to_sub
mov byte [r12], al
\n"

        elseif c == '.'
            output *=

"mov rax, 0x1
mov rdi, 0x1
mov rsi, r12
mov rdx, 0x1
syscall
\n"

        elseif c == ','
            output *=

"mov rax, 0x0
mov rdi, 0x1
mov rsi, r12
mov rdx, 0x1
syscall
\n"

        elseif c == '['
            output *=

"mov al, [r12]
cmp al, 0
je closelabel$current_label

openlabel$current_label:
"
            push!(labelcounts, current_label)
            current_label+=1
        elseif c == ']'
            thislabel = pop!(labelcounts)
            output *=

"mov al, [r12]
cmp al, 0
jne openlabel$thislabel

closelabel$thislabel:
"
        end
        i += 1
    end

    output *=

"
mov rax, 0x1
mov rdi, 0x1
mov byte [r12], 0xa
mov rsi, r12
mov rdx, 0x1
syscall

pop r12
mov rax, 0x3c
xor rdi, rdi
syscall
\n"

    outfile = length(args) < 2 ? "a.out" : args[2]

    open("output.asm", "w") do f
        write(f, output)
    end
    run(`nasm output.asm -f elf64`)
    run(`ld output.o -o $outfile`)
    run(`rm output.asm output.o`)

end

main(ARGS)
