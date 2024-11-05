package dto;

import entity.Rent;

public record ListRentResponse(
	Rent rent,
	Boolean isReserved,
	Boolean isConclude
) {}
