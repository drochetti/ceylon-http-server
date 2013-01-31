import ceylon.io { newServerSocket, SocketAddress }
doc "Run the module `com.github.drochetti.ceylonhttp`."
void run() {
    value server = HttpServer(newServerSocket {
        addr = SocketAddress {
            address = "localhost";
            port = 8080;
        };
    });
    server.listen();
}