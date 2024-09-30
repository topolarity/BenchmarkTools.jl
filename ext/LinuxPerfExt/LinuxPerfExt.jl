module LinuxPerfExt

import BenchmarkTools: PerfInterface
import LinuxPerf: LinuxPerf, PerfBench, EventGroup, EventType
import LinuxPerf: enable!, disable!, enable_all!, disable_all!, close, read!

function interface()
    return PerfInterface(;
        setup=() -> PerfBench(
            0, [EventGroup([EventType(:hw, :instructions), EventType(:hw, :branches)])]
        ),
        start=(bench) -> enable_all!(),
        stop=(bench) -> disable_all!(),
        # start=(bench) -> enable!(bench),
        # stop=(bench) -> disable!(bench),
        teardown=(bench) -> close(bench),
        read=(bench) -> let g = only(bench.groups)
            (insts, branches) = read!(g.leader_io, Vector{UInt64}(undef, 5))
            return (insts, branches)
        end,
    )
end

end
