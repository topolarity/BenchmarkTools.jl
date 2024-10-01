module LinuxPerfExt

import BenchmarkTools: PerfInterface
import LinuxPerf: LinuxPerf, PerfBench, EventGroup, EventType
import LinuxPerf: enable!, disable!, enable_all!, disable_all!, close, read!



function interface()
    let g = try
        EventGroup([EventType(:hw, :instructions), EventType(:hw, :branches)])
    catch
        # If perf is not working on the system, the above constructor will throw an
        # :ioctl SystemError (after presenting a warning to the user)
        return PerfInterface()
    end
        close(g)
        length(g.fds) != 2 && return PerfInterface()
    end

    # If we made it here, perf seems to be working on this system
    return PerfInterface(;
        setup=() -> let g = EventGroup([EventType(:hw, :instructions), EventType(:hw, :branches)])
            PerfBench(0, EventGroup[g])
        end,
        start=(bench) -> enable_all!(),
        stop=(bench) -> disable_all!(),
        # start=(bench) -> enable!(bench),
        # stop=(bench) -> disable!(bench),
        teardown=(bench) -> close(bench),
        read=(bench) -> let g = only(bench.groups)
            (insts, branches) = read!(g.leader_io, Vector{UInt64}(undef, 5))[4:5]
            (insts, branches)
        end,
    )
end

end
