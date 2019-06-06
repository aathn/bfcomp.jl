"""A program compiling Brainfuck code to MIPS assembly."""
function main(args)
    if length(args) < 1
        println("No file specified.")
        println("Usage: julia bfcomp.jl <input file> [output file]")
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
".data
memory_arr: .space 30000

.text
main:
la \$t0, memory_arr
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
            output *= "addi \$t0, \$t0, $nr_to_shift\n\n"

        elseif c == '<'
            substr = match(r"[\s<]+", prog, i).match
            i += length(substr)-1
            nr_to_shift = length(filter(!isspace, substr))
            output *= "addi \$t0, \$t0, -$nr_to_shift\n\n"

        elseif c == '+'
            substr = match(r"[\s\+]+", prog, i).match
            i += length(substr)-1
            nr_to_add = length(filter(!isspace, substr))
            output *=

"lb \$t1, (\$t0)
addi \$t1, \$t1, $nr_to_add
sb \$t1, (\$t0)
\n"

        elseif c == '-'
            substr = match(r"[\s\-]+", prog, i).match
            i += length(substr)-1
            nr_to_sub = length(filter(!isspace, substr))
            output *=

"lb \$t1, (\$t0)
addi \$t1, \$t1, -$nr_to_sub
sb \$t1, (\$t0)
\n"

        elseif c == '.'
            output *=

"lb \$a0, (\$t0)
li \$v0, 11
syscall
\n"

        elseif c == ','
            output *=

"li \$v0, 12
syscall
sb \$v0, (\$t0)
\n"

        elseif c == '['
            output *=

"lb \$t1, (\$t0)
beq \$t1, \$0, closelabel$current_label

openlabel$current_label:
"

            push!(labelcounts, current_label)
            current_label+=1
        elseif c == ']'
            thislabel = pop!(labelcounts)
            output *=

"lb \$t1, (\$t0)
bne \$t1, \$0, openlabel$thislabel

closelabel$thislabel:
"
        end
        i += 1
    end

    output *=

"li \$v0, 10
syscall
\n"

    outfile = length(args) < 2 ? "output.asm" : args[2]

    open(outfile, "w") do f
        write(f, output)
    end
end

main(ARGS)
