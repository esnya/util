import std.stdio;
import std.file;
import std.datetime;

void main(string[] args) {
    auto file = args[1];
    if (!file.exists) {
        File(file, "w");
    } else {
        auto time = Clock.currTime();
        file.setTimes(time, time);
    }
}
