package entity;

import java.time.LocalDateTime;

public record Occurrence(Long id, Long userRentId, String description, LocalDateTime createdAt, Boolean unblockUser, LocalDateTime updatedAt) {

}
