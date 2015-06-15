/// InteRactive D console
module ird;

import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.process;
import std.stdio;
import std.string;

void main(string[] args) {
    string tempFile;
    do {
        import std.path;
        import std.datetime;

        tempFile = buildPath(tempDir, "ird" ~ Clock.currTime.toUnixTime().to!string() ~ ".d");
    } while (tempFile.exists());
    scope(exit) if (tempFile.exists()) tempFile.remove();

    string[] src;
    ulong offset;

    with (["dmd", "--version"].execute()) {
        if (status) {
            throw new Exception("Failed to execute dmd");
        }
        write(output);
    }
    writeln();
    writeln("Wellcome to interactive D console.");
    writeln(`Type "exit" or "quit" to quit console.`);
    writeln();

    while (1) {
        write("ird> ");

        auto line = readln().chomp();

        if (!line.endsWith(';')) {
            line ~= ';';
        }

        if (line == "exit;" || line == "quit;") {
            break;
        }

        auto prev = src.save;
        src ~= line;

        with (File(tempFile, "w")) {
            write("import std.stdio;void saveCode(string dst){import std.file;std.file.copy(__FILE__, dst);}void main(char[][]args){");
            foreach (s; src) {
                write("\n(() {");
                write(s);
            }
            foreach (s; src) {
                write("})();");
            }
            write("}");
            close();
        }

        auto cmd = ["dmd", "-release", "-run", tempFile] ~ args[1 .. $];
        with (cmd.execute()) {
            if (!status) {
                write(output[offset .. $]);
                offset = output.length;
            } else {
                string formatError(string line) {
                    if (line.startsWith(tempFile)) {
                        auto s = line.findSplit(": ");

                        s[0].findSkip(tempFile);
                        if (!s[0].startsWith('(') || !s[0].endsWith(')')) {
                            return line;
                        }

                        auto n = s[0][1 .. $-1].to!size_t() - 2;
                        if (n >= src.length) {
                            return line;
                        }

                        return src[n] ~ " // " ~ s[2];
                    } else {
                        return line;
                    }
                    assert(0);
                }

                stderr.writeln(output.splitLines().map!formatError().join("\n"));

                src = prev;
            }
        }
    }
}
