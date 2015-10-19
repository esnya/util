module rand;

import std.conv;
import std.stdio;
import std.random;

void main(string[] args) {
    long min = 0;
    long max = long.max;

    if (args.length == 2) {
        max = args[1].to!long();
    } else if (args.length == 3) {
        min = args[1].to!long();
        max = args[2].to!long();
    }

    writeln(uniform(min, max));
}
