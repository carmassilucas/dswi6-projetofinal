package exception;

@SuppressWarnings("serial")
public class PasswordsNotMatches extends RuntimeException {
	public PasswordsNotMatches(String message) {
		super(message);
	}
}
