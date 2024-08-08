module drcli;
import std::io;
import std::collections::list;

fault ClidreiError {
    NOT_INITALIZED,
    FLAG_NOT_FOUND,
    VALIDATION
}

struct Flag {
    String identifier;
    String description;
    bool required;
    bool hasArgs;
}

struct Flags {
    Flag flag;
    List(<String>) values;
}

struct Drcli {
    String program;
    List(<Flags>) flags;
}

fn bool List(<Flag>).contains(self, String identifier) {
    foreach(f : self) {
        if (f.identifier == identifier) return true;
    }
    return false;
}

fn Flag! List(<Flag>).getById(self, String identifier) {
    foreach(f : self) {
        if (f.identifier == identifier) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}


fn bool List(<Flags>).contains(self, String identifier) {
    foreach(f : self) {
        if (f.flag.identifier == identifier) return true;
    }
    return false;
}

fn Flags! List(<Flags>).getById(self, String identifier) {
    foreach(f : self) {
        if (f.flag.identifier == identifier) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}


fn Drcli! new(List(<Flag>) defaultFlags, String[] args) {
    if (defaultFlags.len() == 0) return ClidreiError.NOT_INITALIZED?;

    String program = args[0];
    List(<Flags>) userFlags;

    for (int i = 1; i < args.len; ++i) {
        String arg = args[i];

        Flag! flag = defaultFlags.getById(arg);
        if (catch err = flag) {
            io::printfn("ERROR: Unknown flag: %s", arg);
            continue;
        }

        Flags userFlag = {
            flag,
            {}
        };

        for (int j = i + 1; j < args.len && !args[j].starts_with("-"); i = j, ++j) {
            userFlag.values.push(args[j]);
        }
        userFlags.push(userFlag);
    
    }

    Drcli cli = {
        program,
        userFlags
    };

    if (!cli.validate(defaultFlags)) return ClidreiError.VALIDATION?;

    return cli;
}

fn bool Drcli.validate(self, List(<Flag>) defaultFlags) {
    foreach (f : defaultFlags) {
        Flags! uf = self.flags.getById(f.identifier);
        
        if (catch err = uf) {
            if (f.required) {
                io::eprintfn("ERROR: Flag %s is required.", f.identifier);
                self.usage(defaultFlags);
                return false;
            } 
            continue;
        }

        if (f.hasArgs && uf.values.len() == 0) {
            io::eprintfn("ERROR: Flag %s requires arguments.", f.identifier);
            self.usage(defaultFlags);
            return false;
        }
    }

    return true;
}

fn void Drcli.usage(self, List(<Flag>) defaultFlags) {
    io::printn();
    io::printfn("USAGE: %s [OPTION] [VALUE]", self.program);
    io::printn("OPTIONS:");
    foreach(f : defaultFlags) {
        io::printf("  %-10s  %s", f.identifier, f.description);
        io::printn();
    }
    io::printn();
}
