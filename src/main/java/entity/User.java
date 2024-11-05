package entity;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record User(
		UUID id,
	    String name,
	    String username,
	    String password,
	    Long userType,
	    LocalDate birthDate,
	    LocalDateTime createdAt,
	    LocalDateTime updatedAt,
	    Boolean actived
) {}
