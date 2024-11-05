package entity;

import java.time.LocalDateTime;
import java.util.UUID;

public record UserRent(
		Long id,
		UUID userId,
		UUID rentId,
		Long rentStatus,
		LocalDateTime createdAt,
		LocalDateTime updatedAt
		
) {}
