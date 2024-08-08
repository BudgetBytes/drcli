module main;
import drcli;
import std::io;
import std::collections::list;

fn void! main(String[] args) {

    List(<Flag>) flags;
    Flag verbose = {"-v", "Print verbose", true, false};
    Flag list = {"-l", "List files", false, true};
    Flag paths = {"-p", "Path list", true, true};

    flags.push(verbose);
    flags.push(list);
    flags.push(paths);

    Drcli cli = drcli::new(flags, args)!;

    foreach (f : cli.flags) {
        io::printfn("Flag: %s", f.flag.identifier);
        io::print("Values: ");
        foreach (value : f.values) {
            io::printf("%s, ", value);
        }
        io::printn();
    }
}