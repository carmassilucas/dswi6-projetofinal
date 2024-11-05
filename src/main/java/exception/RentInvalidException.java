package exception;

@SuppressWarnings("serial")
public class RentInvalidException extends RuntimeException {
	public RentInvalidException(String message) {
		super(message);
	}
}
