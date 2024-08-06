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
	String example;
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
		if (pf.required) {
			UserFlag! uf = self.userFlags.contains(pf.flag);
			if (catch err = uf) {
				io::eprintfn("ERROR: Flag %s is required, but was not provided.", pf.flag);
				return false;
			}
			if (pf.hasArgs && uf.flagValues.len() == 0) {
				io::eprintfn("ERROR: Flag %s requires values, but none was provided.", pf.flag);
				return false;
			}
		}
	}

	return true;
}

fn void main(String[] args) {

	List(<ProgramFlag>) flags;
	ProgramFlag verbose = {"-v", "Print verbose", "-v", false, false};
	ProgramFlag paths = {"-p", "Path list", "-p file1.txt file2.txt", true, true};

	flags.push(verbose);
	flags.push(paths);

	Clidrei! cli = new(flags, args);

	if (catch err = cli) {
		switch(err) {
			case ClidreiError.NOT_INITALIZED: {
				io::eprintfn("ERROR: You need to provide flags.");
				return;
			}
			case ClidreiError.FLAG_NOT_FOUND: {
				io::eprintfn("ERROR: A flag was not found.");
				return;
			}
			case ClidreiError.VALIDATION: {
				io::eprintfn("ERROR: Failed to validate program state.");
				return;
			} 
			default: {
				io::eprintfn("ERROR: An unexpected error occurred.");
				return;
			}
		}
	}

	foreach (f : cli.userFlags) {
		io::printfn("Flag: %s, values: %s", f.programFlag.flag, f.flagValues);
	}
}