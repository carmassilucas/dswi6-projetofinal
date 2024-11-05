package dto;

import java.util.UUID;

import entity.Occurrence;

public record OccurrenceDetails(Occurrence occurrence, String rentName, String userName, UUID userId) {

}
