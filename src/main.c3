module main;
import clidrei;
import std::io;
import std::collections::list;

fn void! main(String[] args) {

    List(<ProgramFlag>) flags;
    ProgramFlag verbose = {"-v", "Print verbose", true, false};
    ProgramFlag paths = {"-p", "Path list", true, true};

    flags.push(verbose);
    flags.push(paths);

    Clidrei cli = clidrei::new(flags, args)!;
}