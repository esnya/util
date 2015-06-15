import std.algorithm;
import std.csv;
import std.file : readText;
import std.range;
import std.stdio;
import std.typecons;

enum PORT_NUMBERS = "service-names-port-numbers.csv";

void main(string[] args) {
    alias Service = Tuple!(
            string, "name",
            string, "port",
            string, "protocol",
            string, "description",
            string, "assignee",
            string, "contact",
            string, "registration",
            string, "modification",
            string, "reference",
            string, "code",
            string, "unauthorized",
            string, "notes");

    Service[][string] services;

    auto csv = PORT_NUMBERS.readText();
    foreach (record; csvReader!Service(csv)) {
        services[record.port] ~= record;
    }

    foreach (port; args[1 .. $]) {
        if (port in services) {
            services[port]
                .filter!`a.protocol == "tcp"`()
                .map!`a.port ~ ' ' ~ a.name ~ ' ' ~ a.description`()
                .join(", ")
                .writeln();
        }
    }
}
