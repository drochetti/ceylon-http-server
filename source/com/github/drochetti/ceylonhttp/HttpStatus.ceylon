
doc "
	Represents a HTTP response status code as defined by
	W3C reference http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
"
by "Daniel Rochetti"
shared class HttpStatus(code, message) {
	shared Integer code;
	shared String message;
}

shared object statusOk extends HttpStatus(200, "OK") { }

shared object statusNotFound extends HttpStatus(404, "Not Found") { }

shared object statusNotImplemented extends HttpStatus(501, "Not Implemented") { }

