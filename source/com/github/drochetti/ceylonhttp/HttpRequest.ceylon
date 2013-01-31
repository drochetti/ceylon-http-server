
doc "Simple data class that represents a request."
class HttpRequest(method, path, protocol) {

	shared String method;
	shared String path;
	shared String protocol;

}

doc "Parse the string content of a http request to the [[Request]] type."
HttpRequest parseRequest(String requestContent) {
	String? spec = requestContent.lines.first;
	if (is String spec, join(spec.occurrences(" ")).size == 2 ) {
		value specItems = join(spec.split());
		return HttpRequest {
			method = specItems[0] else "GET";
			path = specItems[1] else "/";
			protocol = specItems[2] else "HTTP/1.1";
		};
	}
	throw Exception("Error parsing request: invalid request content.");
}