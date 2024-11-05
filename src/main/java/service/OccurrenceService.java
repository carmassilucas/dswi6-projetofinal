package service;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import database.PostgreConnector;
import dto.CreateOccurrenceRequest;
import dto.OccurrenceDetails;
import entity.Occurrence;
import exception.OccurrenceAlreadyExistsException;
import exception.OccurrenceNotFoundException;

public class OccurrenceService {
	private static OccurrenceService instance;

	private OccurrenceService() {
		
	}
	
	public static OccurrenceService getInstance() {
		if (instance == null)
			instance = new OccurrenceService();
		return instance;
	}
	
	public void create(CreateOccurrenceRequest occurrence) throws SQLException {
		if (findByUserRentId(occurrence.userRentId()) != null)
			throw new OccurrenceAlreadyExistsException("Já existe uma ocorrência para essa reserva.");
		
		var connection = PostgreConnector.getConnection();
		var now = LocalDateTime.now();
    	
        try (PreparedStatement stmt = connection.prepareStatement(
        		"insert into tb_rent_occurrence (user_rent_id, description, created_at, updated_at) values (?, ?, ?, ?)"
        )) {
        	stmt.setLong(1, occurrence.userRentId());
            stmt.setString(2, occurrence.description());
            stmt.setObject(3, now);
            stmt.setObject(4, now);
            stmt.executeUpdate();
        }
        
        connection.close();
	}
	
	public List<OccurrenceDetails> findAll() throws SQLException {
		var connection = PostgreConnector.getConnection();
		var occurrences = new ArrayList<OccurrenceDetails>();

	    try (PreparedStatement stmt = connection.prepareStatement(
	    		"select tro.*, tu.name as user_name, tu.id as user_id, tr.name as rent_name from tb_rent_occurrence as tro join tb_user_rent as tur on tro.user_rent_id = tur.id join tb_user as tu on tur.user_id = tu.id join tb_rent as tr on tur.rent_id = tr.id"
		)) {
	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	                occurrences.add(new OccurrenceDetails(
	                		new Occurrence(
	                				rs.getLong("id"),
	        	                    rs.getLong("user_rent_id"),
	        	                    rs.getString("description"),
	        	                    rs.getTimestamp("created_at").toLocalDateTime(),
	        	                    rs.getBoolean("unblock_user"),
	        	                    rs.getTimestamp("updated_at").toLocalDateTime()
            				),
	                		rs.getString("rent_name"),
	                		rs.getString("user_name"),
	                		UUID.fromString(rs.getString("user_id"))
	                    
	                ));
	                connection.close();
	            }
	        }
	    }
	    return occurrences;
	}

	private Occurrence findByUserRentId(Long userRentId) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement("select * from tb_rent_occurrence where user_rent_id = ?")) {
	        stmt.setLong(1, userRentId);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                var occurrence = new Occurrence(
	                    rs.getLong("id"),
	                    rs.getLong("user_rent_id"),
	                    rs.getString("description"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getBoolean("unblock_user"),
	                    rs.getTimestamp("updated_at").toLocalDateTime()
	                );
	                connection.close();
	                return occurrence;
	            }
	        }
	    }
	    return null;
	}
	
	private Occurrence findById(Long occurrenceId) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement("select * from tb_rent_occurrence where id = ?")) {
	        stmt.setLong(1, occurrenceId);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                var occurrence = new Occurrence(
	                    rs.getLong("id"),
	                    rs.getLong("user_rent_id"),
	                    rs.getString("description"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getBoolean("unblock_user"),
	                    rs.getTimestamp("updated_at").toLocalDateTime()
	                );
	                connection.close();
	                return occurrence;
	            }
	        }
	    }
	    return null;
	}
	
	public void unban(Long occurrenceId, UUID userId) throws SQLException {
		var occurrence = findById(occurrenceId);
		
		if (occurrence == null)
			throw new OccurrenceNotFoundException("Ocorrência não encontrada.");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_rent_occurrence set unblock_user = true, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
            stmt.setObject(2, occurrenceId);
            stmt.executeUpdate();
        }
        connection.close();
		
		UserService.getInstance().unban(userId);
	}
}
