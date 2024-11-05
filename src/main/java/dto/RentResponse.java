package dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record RentResponse(
		UUID id,
		String name,
		String address,
		Long rentType,
		LocalDateTime initialDatetime,
		LocalDateTime finalDatetime,
		String description,
		Long rentStatus,
		Long rentUserId
) {}
