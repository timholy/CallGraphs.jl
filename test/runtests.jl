using CallGraphs
using Base.Test

const JULIA_ROOT = splitdir(splitdir(JULIA_HOME)[1])[1]
const CallGraphs_ROOT = Pkg.dir("CallGraphs")
const jlsrc_script = joinpath(CallGraphs_ROOT, "callgraph_jlsrc.bash")

gcnames = cd(joinpath(JULIA_ROOT, "src")) do
    run(`bash $jlsrc_script`)
    gcnames = findgc()
end
@test "array_resize_buffer" in gcnames
