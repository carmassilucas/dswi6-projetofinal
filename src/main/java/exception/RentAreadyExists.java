package exception;

@SuppressWarnings("serial")
public class RentAreadyExists extends RuntimeException {
	public RentAreadyExists(String message) {
		super(message);
	}
}
