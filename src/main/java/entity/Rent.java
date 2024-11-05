package entity;

import java.time.LocalDateTime;
import java.util.UUID;

public record Rent(
		UUID id,
		String name,
		String address,
		Long rentType,
		LocalDateTime initialDatetime,
		LocalDateTime finalDatetime,
		String description,
		LocalDateTime createdAt,
	    LocalDateTime updatedAt
) {}
