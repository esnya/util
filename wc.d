module wc;

import std.algorithm;
import std.file;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.typecons;

enum Version = "ukatama Word Count v0.1.0";

struct WC {
    @("|c") bool bytes = false;
    @("|m") bool chars = false;
    @("|l") bool lines = false;
    string files0_from;
    @("|L") bool max_line_length;
    @("|W") bool words = false;
    bool help = false;
    bool version_ = false;
}

auto getopt(T)(ref string[] args) {
    import std.getopt;
    import std.typetuple;

    T options;

    template getArg(string member) {
        private auto genArg() {
            enum attrs = __traits(getAttributes, __traits(getMember, T, member));

            static if (attrs.length > 0) {
                enum prefix = attrs[0];
            } else {
                enum prefix = "";
            }

            return (member[$-1] == '_' ? member[0 .. $-1] : member).replace("_", "-") ~ prefix;
        }
        private enum arg = genArg();

        enum getArg = '"' ~ arg ~ `", &options.` ~ member;
    }

    //pragma(msg, "getopt(args, " ~ [staticMap!(getArg, __traits(allMembers, T))].join(", ") ~ ");");
    mixin("getopt(args, " ~ [staticMap!(getArg, __traits(allMembers, T))].join(", ") ~ ");");

    return options;
}

enum bool[4] CountDefault = [true, true, true, false];

void wc_write(ulong[] result, string file) {
    writefln("%(%s\t%)\t%s", result, file);
}

ulong[] wc(S)(S file, bool[4] count = CountDefault) if (isSomeString!S) {
    import std.path;
    import std.uni;

    if (!file.exists) {
        stderr.writeln("wc: ", file, ": No such file or directory");
        return new ulong[count[].filter!`a`().count()];
    } else if (file.isDir) {
        return file
            .dirEntries(SpanMode.shallow)
            .filter!`a.isFile`()
            .map!`a.name`()
            .wc(count, false);
    }


    auto text = file.readText();

    ulong[4] counters;

    if (count[0]) counters[0] = text.splitLines.length;
    if (count[1]) counters[1] = text.split!isWhite().filter!`!a.empty`.count();
    if (count[2]) counters[2] = text.count();
    if (count[3]) counters[3] = text.length;

    auto result = zip(counters[], count[])
        .filter!`a[1]`()
        .map!`a[0]`()
        .array;

    wc_write(result, file);

    return result;
}

ulong[] wc(R)(R files, bool[4] count = CountDefault, bool writeTotal = true) if (isInputRange!R && isSomeString!(ElementType!R)) {
    auto result = files
        .map!(a => wc(a, count))()
        .reduce!`zip(a, b).map!"a[0] + a[1]"().array`()
        .array;

    if (writeTotal) wc_write(result, "total");

    return result;
}

void main(string[] args) {
    WC options;

    try {
        options = args.getopt!WC();
    } catch (std.getopt.GetOptException e) {
        stderr.writeln("Error: ", e.msg);
        options.help = true;
    }
    args.popFront();

    if (options.help) {
        writeln("Usage: ", args[0], " [option(s)] file(s)");
        // ToDo: help
    } else if (options.version_) {
        writeln(Version);
        writeln("Compiled: ", __TIMESTAMP__);
    } else {
        bool[4] count;

        count[0] = options.lines;
        count[1] = options.words;
        count[2] = options.chars;
        count[3] = options.bytes;

        if (count[].any!`a`()) {
            wc(args, count);
        } else {
            wc(args);
        }
    }
}

