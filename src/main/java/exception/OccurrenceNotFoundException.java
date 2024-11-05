package exception;

@SuppressWarnings("serial")
public class OccurrenceNotFoundException extends RuntimeException {
	public OccurrenceNotFoundException(String message) {
		super(message);
	}
}
