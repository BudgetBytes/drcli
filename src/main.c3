module main;
import clidrei;
import std::io;
import std::collections::list;

fn void main(String[] args) {

	List(<ProgramFlag>) flags;
	ProgramFlag verbose = {"-v", "Print verbose", "-v", true, false};
	ProgramFlag paths = {"-p", "Path list", "-p file1.txt file2.txt", true, true};

	flags.push(verbose);
	flags.push(paths);

	Clidrei! cli = clidrei::new(flags, args);

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