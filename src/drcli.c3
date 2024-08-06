module drcli;
import std::io;
import std::collections::list;

fault ClidreiError {
    NOT_INITALIZED,
    FLAG_NOT_FOUND,
    VALIDATION
}

struct ProgramFlag {
    String flag;
    String description;
    bool required;
    bool hasArgs;
}

fn bool List(<ProgramFlag>).contains(self, String flag) {
    foreach(f : self) {
        if (f.flag == flag) return true;
    }
    return false;
}

fn ProgramFlag! List(<ProgramFlag>).getByFlag(self, String flag) {
    foreach(f : self) {
        if (f.flag == flag) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}

struct UserFlag {
    ProgramFlag programFlag;
    List(<String>) flagValues;
}

fn bool List(<UserFlag>).contains(self, String flag) {
    foreach(f : self) {
        if (f.programFlag.flag == flag) return true;
    }
    return false;
}

fn UserFlag! List(<UserFlag>).getByFlag(self, String flag) {
    foreach(f : self) {
        if (f.programFlag.flag == flag) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}

struct Drcli {
    String program;
    List(<ProgramFlag>) programFlags;
    List(<UserFlag>) userFlags;
}

fn Drcli! new(List(<ProgramFlag>) programFlags, String[] args) {
    if (programFlags.len() == 0) return ClidreiError.NOT_INITALIZED?;

    String program = args[0];
    List(<UserFlag>) userFlags;

    for (int i = 1; i < args.len; ++i) {
        String arg = args[i];

        ProgramFlag! programFlag = programFlags.getByFlag(arg);
        if (catch err = programFlag) {
            io::printfn("ERROR: Undefined flag: %s", arg);
            continue;
        }

        UserFlag userFlag = {
            programFlag,
            {}
        };

        for (int j = i + 1; j < args.len && !args[j].starts_with("-"); i = j, ++j) {
            userFlag.flagValues.push(args[j]);
        }
        userFlags.push(userFlag);
    
    }

    Drcli cli = {
        program,
        programFlags,
        userFlags
    };

    if (!cli.validate()) return ClidreiError.VALIDATION?;

    return cli;
}

fn bool Drcli.validate(self) {
    foreach (pf : self.programFlags) {
        UserFlag! uf = self.userFlags.getByFlag(pf.flag);
        
        if (catch err = uf) {
            if (pf.required) {
                io::eprintfn("ERROR: Flag %s is required, but was not provided.", pf.flag);
                self.usage();
                return false;
            } 
            continue;
        }

        if (pf.hasArgs && uf.flagValues.len() == 0) {
            io::eprintfn("ERROR: Flag %s requires values, but flag was not provided.", pf.flag);
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
    foreach(pf : self.programFlags) {
        io::printf("  %-3s  %-25s", pf.flag, pf.description);
        io::printf("  Required: %-20s Requires values: %s", pf.required ? "True" : "False", pf.hasArgs ? "True" : "False");
        io::printn();
    }
    io::printn();
}
