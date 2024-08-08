module drcli;
import std::io;
import std::collections::list;

fault DrcliError {
    NOT_INITALIZED,
    FLAG_NOT_FOUND,
    VALIDATION
}


struct Flag {
    String identifier;
    String description;
    bool required;
    bool hasArgs;
    bool provided;
    List(<String>) values;
}

struct Drcli {
    String program;
    List(<Flag>) flags;
    List(<String>) freeArgs; // arguments passed without flag
}

fn bool List(<Flag>).contains(self, String identifier) {
    foreach(f : self) {
        if (f.identifier == identifier && f.provided) return true;
    }
    return false;
}

fn Flag! List(<Flag>).getById(self, String identifier) {
    foreach(f : self) {
        if (f.identifier == identifier) return f;
    }
    return DrcliError.FLAG_NOT_FOUND?;
}

fn bool List(<Flag>).updateFlag(self, Flag flag) {
    foreach(&f : self) {
        if (f.identifier == flag.identifier) {
            *f = flag;
            return true;
        }
    }
    return false;
}

fn Drcli! new(List(<Flag>) defaultFlags, String[] args) {
    if (defaultFlags.len() == 0) return DrcliError.NOT_INITALIZED?;

    String program = args[0];
    List(<String>) freeArgs;

    for (int i = 1; i < args.len; ++i) {
        String arg = args[i];

        Flag! flag = defaultFlags.getById(arg);
        if (catch err = flag) {
            if (arg.starts_with("-")) {
                io::printfn("ERROR: Unknown flag: %s", arg);
            } else {
                freeArgs.push(arg);
            }
            continue;
        }

        if (flag.hasArgs) {
            for (int j = i + 1;  j < args.len && !args[j].starts_with("-"); i = j, ++j) {
                flag.values.push(args[j]);
            }
        }

        flag.provided = true;
        defaultFlags.updateFlag(flag);
    }

    Drcli cli = {
        program,
        defaultFlags,
        freeArgs
    };

    if (!cli.validate()) return DrcliError.VALIDATION?;

    return cli;
}

fn bool Drcli.validate(self) {
    foreach (f : self.flags) {
        if (f.required && !f.provided && f.values.len() == 0) {
            io::eprintfn("ERROR: Flag %s is required.", f.identifier);
            self.usage();
            return false;
        } 

        if (f.provided && f.hasArgs && f.values.len() == 0) {
            io::eprintfn("ERROR: Flag %s requires arguments.", f.identifier);
            self.usage();
            return false;
        }
    }

    return true;
}

fn void Drcli.usage(self) {
    io::printn();
    io::printfn("USAGE: %s [OPTION] [VALUE]", self.program);
    io::printn("OPTIONS:");
    foreach(f : self.flags) {
        io::printf("  %-10s  %s", f.identifier, f.description);
        io::printn();
    }
    io::printn();
}
