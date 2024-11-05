package exception;

@SuppressWarnings("serial")
public class AlreadyActivedReservationException extends RuntimeException {
	public AlreadyActivedReservationException(String message) {
		super(message);
	}

}
