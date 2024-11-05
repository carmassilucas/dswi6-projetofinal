package dto;

import java.time.LocalDateTime;

public record CreateRentRequest(
		String name,
		String address,
		Long rentType,
		LocalDateTime initialDatetime,
		LocalDateTime finalDatetime,
		String description
) {}
