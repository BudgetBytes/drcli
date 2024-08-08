# Drcli
A cli library developed in C3

## Example
```rust
module main;
import drcli;
import std::io;
import std::collections::list;

fn void! main(String[] args) {

    List(<Flag>) flags;
    List(<String>) defaultPath;
    defaultPath.push(".");
    Flag verbose = {"-v", "Print verbose.", true, false, false, {}};
    Flag list = {"-l", "List files.", false, true, false, {}};
    Flag paths = {"-p", "Path list. Default is '.'", true, true, false, defaultPath};

    flags.push(verbose);
    flags.push(list);
    flags.push(paths);

    Drcli cli = drcli::new(flags, args)!;

    foreach (f : cli.flags) {
        io::printfn("Flag: %s. Values: %s", f.identifier, f.values);
    }

    foreach (f : cli.freeArgs) {
        io::printfn("Free args: %s", f);
    }
}
```
