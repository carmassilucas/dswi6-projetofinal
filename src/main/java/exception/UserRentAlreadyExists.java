package exception;

@SuppressWarnings("serial")
public class UserRentAlreadyExists extends RuntimeException {
	public UserRentAlreadyExists(String message) {
		super(message);
	}
}
