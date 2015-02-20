# CallGraphs

[![Build Status](https://travis-ci.org/timholy/CallGraphs.jl.svg?branch=master)](https://travis-ci.org/timholy/CallGraphs.jl)

A package for analyzing source-code callgraphs, particularly of Julia's `src/` directory.
The main motivation for this package was to aid in finding all functions that might
trigger garbage collection by directly or indirectly calling `jl_gc_collect`; however,
the package has broader uses.

## Installation

Add with

```julia
Pkg.clone("https://github.com/timholy/CallGraphs.jl.git")
```

You'll also need to have `clang++` installed, as well at the corresponding `opt` tool.
On the author's machine, `opt` is called `opt-3.4`.

### Analyzing a source repository

#### Extracting the callgraph

An example script is `callgraph_jlsrc.bash`, which is set to analyze julia's `src` directory.
It should be called from  within that directory. You may need to change the `OPT` variable
to match your system. This script can be modified to analyze other code repositories.

This writes a series of `*.ll` and `*.dot` files. These `*.dot` files are then analyzed by
the julia code in this repository.

#### Analyzing the callgraph

The most general approach is

```julia
using CallGraphs
cgs = parsedots()   # or supply the dirname
calls, calledby = combine(cgs...)
```

This will merge data from all the `*.dot` files in the directory into a single
callgraph. `parsedots` and `combine` are both described in online help.

#### Garbage-collection analysis

If your main interest is analyzing the callgraph of julia's garbage collection,
you will likely be more interested in

```julia
using CallGraphs
gcnames = findgc()
highlight(srcfilename, gcnames)
```

which produces output that looks like this:

![Source highlighting](/figures/highlightgc.png)

Shown in red are all functions that might trigger a call to `jl_gc_collect`.
The general principle is to look for cases where one line's allocation is not protected from
a later garbage-collection.
