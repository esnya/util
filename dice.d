module dice;

import std.regex;
import std.random;
import std.stdio;

uint dice(uint num, uint eyes) {
    uint sum = 0;

    for (auto i = 0; i < num; ++i) {
        sum += uniform(1, eyes);
    }

    return sum;
}

uint dice(in char[] s) {
    return 0;
}

void main(char[][] args) {
}
