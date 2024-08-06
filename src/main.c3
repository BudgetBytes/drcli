module main;
import drcli;
import std::io;
import std::collections::list;

fn void! main(String[] args) {

    List(<ProgramFlag>) flags;
    ProgramFlag verbose = {"-v", "Print verbose", true, false};
    ProgramFlag list = {"-l", "List files", false, true};
    ProgramFlag paths = {"-p", "Path list", true, true};

    flags.push(verbose);
    flags.push(list);
    flags.push(paths);

    Drcli cli = drcli::new(flags, args)!;
}