module clidrei;
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

fn ProgramFlag! List(<ProgramFlag>).contains(self, String flag) {
    foreach(f : self) {
        if (f.flag == flag) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}

struct UserFlag {
    ProgramFlag programFlag;
    List(<String>) flagValues;
}

fn UserFlag! List(<UserFlag>).contains(self, String flag) {
    foreach(f : self) {
        if (f.programFlag.flag == flag) return f;
    }
    return ClidreiError.FLAG_NOT_FOUND?;
}

struct Clidrei {
    String program;
    List(<ProgramFlag>) programFlags;
    List(<UserFlag>) userFlags;
}

fn Clidrei! new(List(<ProgramFlag>) programFlags, String[] args) {
    if (programFlags.len() == 0) return ClidreiError.NOT_INITALIZED?;

    String program = args[0];
    List(<UserFlag>) userFlags;

    for (int i = 1; i < args.len; ++i) {
        String arg = args[i];

        ProgramFlag! programFlag = programFlags.contains(arg);
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

    Clidrei cli = {
        program,
        programFlags,
        userFlags
    };

    if (!cli.validate()) return ClidreiError.VALIDATION?;

    return cli;
}

fn bool Clidrei.validate(self) {
    foreach (pf : self.programFlags) {
        UserFlag! uf = self.userFlags.contains(pf.flag);
        
        if (pf.required) {
            if (catch err = uf) {
                io::eprintfn("ERROR: Flag %s is required, but was not provided.", pf.flag);
                self.usage();
                return false;
            }
        }
        if (pf.hasArgs) {
            if (catch err = uf) {
                io::eprintfn("ERROR: Flag %s requires values, but flag was not provided.", pf.flag);
                self.usage();
                return false;
            }

            if (uf.flagValues.len() == 0) {
                io::eprintfn("ERROR: Flag %s requires values, but none was provided.", pf.flag);
                self.usage();
                return false;
            }
        }
    }

    return true;
}

fn void Clidrei.usage(self) {
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
