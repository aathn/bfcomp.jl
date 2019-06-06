"""A Brainfuck interpreter."""
function main(args)
    if length(args) < 1
        println("No file specified.")
        println("Usage: julia bfinterp.jl <input file>")
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

    memory = zeros(UInt8, 30000)
    proglen = length(prog)
    idx = 1

    i = 1
    while i <= proglen
        c = prog[i]
        if c == '>'
            idx += 1
        elseif c == '<'
            idx -= 1
        elseif c == '+'
            memory[idx] += 1
        elseif c == '-'
            memory[idx] -= 1
        elseif c == '.'
            print(Char(memory[idx]))
        elseif c == ','
            memory[idx] = read(STDIN, UInt8)
        elseif c == '['
            if memory[idx] == 0
                bracketstomatch = 1
                while bracketstomatch > 0
                    i += 1
                    if i > proglen
                        exit(1)
                    end
                    if prog[i] == '['
                        bracketstomatch += 1
                    elseif prog[i] == ']'
                        bracketstomatch -= 1
                    end
                end
            end
        elseif c == ']'
            if memory[idx] != 0
                bracketstomatch = 1
                while bracketstomatch > 0
                    i -= 1
                    if i < 1
                        exit(1)
                    end
                    if prog[i] == '['
                        bracketstomatch -= 1
                    elseif prog[i] == ']'
                        bracketstomatch += 1
                    end
                end
            end
        end
        i += 1
    end
    println()
end
main(ARGS)
