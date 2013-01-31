import ceylon.file { File }
import ceylon.io.buffer { ByteBuffer }
import ceylon.io.charset { utf8 }

doc "Alias type that represents a response body content."
alias ResponseBody = String|File?;

doc "Simple data class that represents a response."
class HttpResponse(body, status = statusOk, mimeType = "text/html") {

	shared ResponseBody body;
	shared HttpStatus status;
	shared String mimeType;

	doc "
		Convert this object to a response body [[String]] representation.
		TODO: I'm sure there's a better way to write this method, mainly the IO part...
	"
	shared ByteBuffer result {
		variable String? guessedMimeType := null;
		variable String content := "";
		if (is String body) {
			content := body;
		} else if (is File body) {
			// TODO how to read binary files?
			value reader = body.reader(utf8.name);
			try {
				variable String fileContent := "";
				while(is String line = reader.readLine()) {
					fileContent := "" fileContent "" line "" process.newline "";
				}
				content := fileContent.trimmed;
			} finally {
				// TODO try with resources
				reader.destroy();
			}
			guessedMimeType := body.contentType;
		}
		value headers = buildHeaders(content.size, guessedMimeType else mimeType);
		return utf8.encode("" headers "" content "");
	}

	String buildHeaders(Integer contentSize, String contentType) {
		return elements(
			"HTTP/1.0 " status.code " " status.message "",
			"Server: Ceylon HTTP Server 1.0",
			"Date: " process.milliseconds "", // TODO ceylon.time module support
			"Content-type: " contentType "; charset=" utf8.name "",
			"Content-length: " contentSize "",
			process.newline
		).fold {
			initial = "";
			// TODO improve to M5 syntax?
			function accumulating(String partial, String elem) {
				return "" partial "" process.newline "" elem "";
			}
		};
	}

}