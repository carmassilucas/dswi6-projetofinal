package exception;

@SuppressWarnings("serial")
public class OccurrenceAlreadyExistsException extends RuntimeException {
	public OccurrenceAlreadyExistsException(String message) {
		super(message);
	}

}
