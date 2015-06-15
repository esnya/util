module publish;

import std.algorithm;
import std.file;
import std.range;
import std.stdio;
import std.parallelism;
import std.path;
import std.process;
import std.typecons;

void pipe(S, D, I)(S src, D dst, I id) {
    src.byLine().each!((line) {
        dst.lock();
        scope(exit) dst.unlock();

        dst.writeln(id, "> ", line);
    })();
}

auto publish(I, C, P)(I id, C cmd, P pipes) {
    writeln(id, "> ", cmd.join(" "));

    pipes.stdout.task!pipe(stdout, id).executeInNewThread();
    pipes.stderr.task!pipe(stderr, id).executeInNewThread();

    auto code = pipes.pid.wait();
    (code ? stderr : stdout).writeln(id, "> Done (", code, ')');

    return code;
}

void main(string[] args) {
    auto dst = (args.length > 1) ? args[1] : "/usr/local/bin";
    auto src = (args.length > 2) ? args[2] : ".";

    src.dirEntries(SpanMode.shallow)
        .filter!`a.isFile`()
        .map!`a.name`()
        .filter!`a.endsWith(".d")`()
        .map!(a => tuple(a.baseName(".d"), ["dmd", "-release", "-O", "-inline", "-od" ~ tempDir, "-of" ~ buildPath(dst, a.baseName(".d")), a]))()
        .map!(a => tuple(a[0], a[1], a[1].pipeProcess(Redirect.stdout | Redirect.stderr)))()
        .each!(a => task!publish(a.expand).executeInNewThread())();
}
