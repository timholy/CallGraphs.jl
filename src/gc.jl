
### Utilities specifically targeted at finding functions that can
### trigger a GC event
@doc """
`gcnames = findgc(dirname=".")` parses the `*.dot` files in the specified
directory, assembles the combined callgraph, and then finds the names of all
functions which might, directly or indirectly, trigger a garbage-collection
event by calling `jl_gc_collect`.
""" ->
function findgc(dirname=".")
    cgs = parsedots(dirname)
    calls, calledby = combine(cgs...)
    callers = findcallers(calledby, "jl_gc_collect")
    uniquenames(callers)
end

@doc """
`highlight(srcfilename, gcnames)` displays the specified C source file in the REPL,
coloring in red all function calls which might trigger garbage collection.
In some cases, this can be helpful in determining whether one might be missing a GC root.
""" ->
function highlightgc(srcfilename, gcnames::Set)
    lines = open(srcfilename) do file
        readlines(file)
    end
    modline = IOBuffer()
    for line in lines
        indx = 1
        while true
            m = match(ralphanum, line, indx)
            if m == nothing
                print(modline, line[indx:end])
                break
            end
            print(modline, line[indx:m.offset-1])
            if m.match in gcnames
                print_with_color(:red, modline, m.match)
            else
                print(modline, m.match)
            end
            indx = m.offset + length(m.match)
        end
        print(takebuf_string(modline))
    end
end

@doc """
```
emacs_highlighting(filename, funcnames, face="font-lock-warning-face")
```
Creates an emacs highlighting file from a list of function names.
""" ->
function emacs_highlighting(filename, funcnames, face="font-lock-warning-face")
    open(filename, "w") do file
        print(file, "(defvar CallGraphFuncs\n  '((\"\\\\<\\\\(")
        first = true
        for fname in funcnames
            if !first
                print(file, "\\\\|")
            end
            print(file, fname)
            first = false
        end
        println(file, "\\\\)\\\\>\" . '$face)))")
        println(file, "\n(font-lock-add-keywords 'c-mode CallGraphFuncs)")
    end
end
