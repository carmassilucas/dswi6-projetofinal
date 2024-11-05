package exception;

@SuppressWarnings("serial")
public class UnderageException extends RuntimeException {
	public UnderageException(String message) {
		super(message);
	}
}
