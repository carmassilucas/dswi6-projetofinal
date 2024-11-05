package dto;

import java.util.UUID;

import entity.Rent;

public record RentReserved(
	Rent rent,
	Long userRentId,
	Long rentStatus,
	UUID userId
) {}
