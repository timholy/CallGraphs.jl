#!/bin/bash

SRC=( jltypes.c gc.c gf.c ast.c builtins.c module.c codegen.cpp disasm.cpp debuginfo.cpp interpreter.c alloc.c dlload.c sys.c init.c task.c array.c dump.c toplevel.c jl_uv.c jlapi.c profile.c llvm-simdloop.cpp )
OPT=opt-3.4

for fl in ${SRC[@]}
do
    clang++ -Isupport -Iflisp -I../usr/include -I../deps/valgrind -imacros callgraph.macros -S -emit-llvm $fl -o - | $OPT -analyze -dot-callgraph
    cat callgraph.dot | c++filt > $fl.dot
done
rm callgraph.dot
