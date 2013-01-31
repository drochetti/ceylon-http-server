import ceylon.file { File, current }
import ceylon.io { ServerSocket, Socket }
import ceylon.io.buffer { ByteBuffer }
import ceylon.io.charset { utf8 }

doc "A simple HTTP server written in Ceylon as a Proof of Concept"
by "Daniel Rochetti"
shared
class HttpServer(ServerSocket serverSocket) {

	shared void listen() {
		value serverAddress = serverSocket.localAddress;
		print("Ceylon HTTP Server 1.0");
		print("Listening to connections on "
			serverAddress.address ":" serverAddress.port "");
		while(true) {
			value socket = serverSocket.accept();
			socket.readFully((ByteBuffer buffer) {
				consumeRequest(socket, parseRequest(utf8.decode(buffer)))
			});
		}
	}

	void consumeRequest(Socket socket, HttpRequest request) {
		variable HttpStatus status := statusOk;
		variable ResponseBody body := null;
		value requestMethod = request.method.uppercased;
		if ({ "GET", "HEAD" }.containsAny(requestMethod)) {
			value file = current.childPath("static" request.path "").resource;
			if (is File file, file.readable, file.name.endsWith(".html")) {
				body := !requestMethod == "HEAD" then file;
			} else {
				status := statusNotFound;
				body := generateErrorHtml {
					status = status;
					message = "The requested resource " request.path " could not be found!";
				};
			}
		} else {
			status := statusNotImplemented;
			body := generateErrorHtml {
				status = status;
				message = "501 Not Implemented: " request.method " method.";
			};
		}
		sendResponse(socket, status, body);
	}

	void sendResponse(Socket socket, HttpStatus status, ResponseBody body) {
		value response = HttpResponse {
			status = status;
			body = body;
		};
		socket.writeFully(response.result);
	}

	doc "
		Generates a simple HTML page to be used to report errors.
		TODO: of course this in a near future will be done using Ceylon objects
		just like the ceylon-lang.org landing Html sample.
	"
	String generateErrorHtml(HttpStatus status, String message) {
		return "
			<html>
				<head>
					<title>
						Ceylon HttpServer - Error "	status.code " - " status.message"!
					</title>
				</head>
				<body>
					<h2>" message "</h2>
				</body>
			</html>
		";
	}

}