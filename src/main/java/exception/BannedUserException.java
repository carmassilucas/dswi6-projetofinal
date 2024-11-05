package exception;

@SuppressWarnings("serial")
public class BannedUserException extends RuntimeException {
	public BannedUserException(String message) {
		super(message);
	}

}
