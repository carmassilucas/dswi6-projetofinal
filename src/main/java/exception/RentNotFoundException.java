package exception;

@SuppressWarnings("serial")
public class RentNotFoundException extends RuntimeException {
	public RentNotFoundException(String message) {
		super(message);
	}
}
