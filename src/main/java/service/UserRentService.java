package service;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import database.PostgreConnector;
import dto.RentReserved;
import dto.RentResponse;
import entity.Rent;
import entity.User;
import entity.UserRent;
import exception.AlreadyActivedReservationException;
import exception.BannedUserException;
import exception.RentInvalidException;
import exception.RentNotFoundException;
import exception.UserRentAlreadyExists;

public class UserRentService {
	private static UserRentService instance;

	private UserRentService() {
		
	}
	
	public static UserRentService getInstance() {
		if (instance == null)
			instance = new UserRentService();
		return instance;
	}
	
	public void rent(Rent rent, User user) throws SQLException {
		if (!user.actived())
			throw new BannedUserException("Usuário banido, não é permitido alugar espaços.");
			
		if (existsActivedReservationByUserId(user.id()))
			throw new AlreadyActivedReservationException("Conclua sua reserva ativa antes de iniciar outra.");
		
		if (existsByRentId(rent.id()))
			throw new UserRentAlreadyExists("Esse espaço já está alugado!");
		
		var connection = PostgreConnector.getConnection();
		var now = LocalDateTime.now();
		
		try (PreparedStatement stmt = connection.prepareStatement(
				"insert into tb_user_rent (user_id, rent_id, rent_status, created_at, updated_at) values (?, ?, ?, ?, ?)"
        )) {
        	stmt.setObject(1, user.id());
            stmt.setObject(2, rent.id());
            stmt.setLong(3, 2L);
            stmt.setObject(4, now);
            stmt.setObject(5, now);
            stmt.executeUpdate();
        }
        connection.close();
	}
	
	private Boolean existsByRentId(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select * from tb_user_rent where rent_id = ? and rent_status != 1 limit 1"
	    )) {
	        stmt.setObject(1, id);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	            	connection.close();
	                return true;
	            }
	        }
	    }
	    return false;
	}
	
	private Boolean existsActivedReservationByUserId(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select * from tb_user_rent where rent_status in (2,3,4) and user_id = ? limit 1"
	    )) {
	        stmt.setObject(1, id);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	            	connection.close();
	                return true;
	            }
	        }
	    }
	    return false;
	}
	
	public Boolean existsActivedReservationByRentId(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select * from tb_user_rent where rent_status in (2,3,4,5) and rent_id = ? limit 1"
	    )) {
	        stmt.setObject(1, id);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	            	connection.close();
	                return true;
	            }
	        }
	    }
	    return false;
	}
	
	public List<RentResponse> findByUser(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();
		var rentals = new ArrayList<RentResponse>();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select tr.*, tur.rent_status, tur.id as user_rent_id from tb_rent as tr join tb_user_rent as tur on tr.id = tur.rent_id where tur.user_id = ? order by tur.updated_at desc"
	    )) {
	        stmt.setObject(1, id);

	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	            	rentals.add(new RentResponse(
	                		UUID.fromString(rs.getString("id")),
		                    rs.getString("name"),
		                    rs.getString("address"),
		                    rs.getLong("rent_type"),
		                    rs.getTimestamp("initial_datetime").toLocalDateTime(),
		                    rs.getTimestamp("final_datetime").toLocalDateTime(),
		                    rs.getString("description"),
		                    rs.getLong("rent_status"),
		                    rs.getLong("user_rent_id")
	        		));
	            }
	        }
	    }
	    return rentals;
	}
	
	public UserRent findById(Long id) throws SQLException {
		var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement("select * from tb_user_rent where id = ?")) {
            stmt.setLong(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
            	if (rs.next()) {
                    var user = new UserRent(
                        rs.getLong("id"),
                        UUID.fromString(rs.getString("user_id")),
                        UUID.fromString(rs.getString("rent_id")),
                        rs.getLong("rent_status"),
                        rs.getTimestamp("created_at").toLocalDateTime(),
                        rs.getTimestamp("updated_at").toLocalDateTime()
                    );
                    connection.close();
                    return user;
                }
            }
        }
        return null;
	}
	
	public void closure(Long userRentId) throws SQLException {
		var rent = findById(userRentId);
		
		if (rent == null)
			throw new RentNotFoundException("Aluguel não encontrado.");
		
		if (rent.rentStatus() != 3L)
			throw new RentInvalidException("Operação inválida.");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user_rent set rent_status = 4, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
        	stmt.setLong(2, userRentId);
        	stmt.executeUpdate();
        }
        connection.close();
	}
	
	public void conclude(Long userRentId) throws SQLException {
		var rent = findById(userRentId);
		
		if (rent == null)
			throw new RentNotFoundException("Aluguel não encontrado.");
		
		if (rent.rentStatus() != 4L)
			throw new RentInvalidException("Operação inválida.");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user_rent set rent_status = 5, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
        	stmt.setLong(2, userRentId);
        	stmt.executeUpdate();
        }
        connection.close();
	}
	
	public void cancel(Long userRentId) throws SQLException {
		var rent = findById(userRentId);
		
		if (rent == null)
			throw new RentNotFoundException("Aluguel não encontrado.");
		
		if (rent.rentStatus() != 2L)
			throw new RentInvalidException("Operação inválida.");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user_rent set rent_status = 1, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
        	stmt.setLong(2, userRentId);
        	stmt.executeUpdate();
        }
        connection.close();
	}
	
	public void approve(Long userRentId) throws SQLException {
		var rent = findById(userRentId);
		
		if (rent == null)
			throw new RentNotFoundException("Aluguel não encontrado.");
		
		if (rent.rentStatus() != 2L)
			throw new RentInvalidException("Operação inválida.");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user_rent set rent_status = 3, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
        	stmt.setLong(2, userRentId);
        	stmt.executeUpdate();
        }
        connection.close();
	}
	
	public List<RentReserved> findAllReservedRentals() throws SQLException {
		var connection = PostgreConnector.getConnection();
		var rentals = new ArrayList<RentReserved>();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select tr.*, tur.id as user_rental_id, tur.rent_status, tur.user_id from tb_rent as tr join tb_user_rent as tur on tr.id = tur.rent_id where tur.rent_status in (2,4);"
	    )) {
	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	            	rentals.add(new RentReserved(
	            			new Rent(
	            					UUID.fromString(rs.getString("id")),
	    		                    rs.getString("name"),
	    		                    rs.getString("address"),
	    		                    rs.getLong("rent_type"),
	    		                    rs.getTimestamp("initial_datetime").toLocalDateTime(),
	    		                    rs.getTimestamp("final_datetime").toLocalDateTime(),
	    		                    rs.getString("description"),
	    		                    rs.getTimestamp("created_at").toLocalDateTime(),
	    		                    rs.getTimestamp("updated_at").toLocalDateTime()
		                    ),
	            			rs.getLong("user_rental_id"),
	            			rs.getLong("rent_status"),
	            			UUID.fromString(rs.getString("user_id"))
	        		));
	            }
	        }
	    }
	    return rentals;
	}
}
