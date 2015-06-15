import std.algorithm;
import std.file;
import std.json;
import std.stdio;

void main(string[] args) {
    auto text = args[1].readText();
    auto json = text.parseJSON();

    ((text.count('\n') >= 2) ? json.toString() : json.toPrettyString()).write();
}
