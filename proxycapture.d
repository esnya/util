module proxycapture;

import std.algorithm;
import std.conv;
import std.parallelism;
import std.socket;
import std.stdio;

auto get(string str) {
    auto s = str.findSplit(":");
    return getAddress(s[0], s[2].to!ushort())[0];
}

void proxy(Socket src, Socket dst) {
    scope(exit) dst.close();

    ubyte[1024] buf;
    while (1) {
        auto r = src.receive(buf);
        if (r <= 0) break;
        synchronized {
            writeln(src.remoteAddress(), " -> ", dst.remoteAddress());
            writeln(cast(char[])buf[0 .. r]);
        }
        dst.send(buf[0 .. r]);
    }
}

void main(string[] args) {
    if (args.length != 3) {
        stderr.writeln("Usage: ", args[0], " srcaddr:port dstaddr:port");
        return;
    }

    auto srcAddr = get(args[1]);
    auto dstAddr = get(args[2]);

    writeln(srcAddr, "->", dstAddr);

    auto server = new Socket(srcAddr.addressFamily, SocketType.STREAM);
    server.bind(srcAddr);
    server.listen(1);

    while (1) {
        auto client = server.accept(); 
        auto socket = new Socket(dstAddr.addressFamily, SocketType.STREAM);
        socket.connect(dstAddr);

        auto p1 = task!proxy(client, socket);
        auto p2 = task!proxy(socket, client);

        p1.executeInNewThread();
        p2.executeInNewThread();
    }
}
