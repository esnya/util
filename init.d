module init;

import std.algorithm;
import std.process;
import std.range;
import std.stdio;

auto init(in char[] cmd) {
    auto init = cmd ~ " init";
    writeln(init);
    return spawnShell(init);
}

void main(in char[][] args) {
    args.drop(1).map!init().each!wait();
}
