package service;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import database.PostgreConnector;
import dto.CreateRentRequest;
import dto.EditRentRequest;
import dto.ListRentResponse;
import entity.Rent;
import exception.DateRangeException;
import exception.RentAreadyExists;

public class RentService {
	private static RentService instance;

	private RentService() {
		
	}
	
	public static RentService getInstance() {
		if (instance == null)
			instance = new RentService();
		return instance;
	}

	public void create(CreateRentRequest dto) throws SQLException {
		if (dto.finalDatetime().isBefore(dto.initialDatetime()))
			throw new DateRangeException("A data de início deve ser inferior que a data final.");
		
		if (findByCharacteristics(dto) != null)
    		throw new RentAreadyExists("Localidade já cadastrada nessa data.");
    	
    	var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement(
        		"insert into tb_rent (id, name, address, rent_type, initial_datetime, final_datetime, description, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        )) {
        	stmt.setObject(1, UUID.randomUUID());
            stmt.setString(2, dto.name());
            stmt.setString(3, dto.address());
            stmt.setLong(4, dto.rentType());
            stmt.setObject(5, dto.initialDatetime());
            stmt.setObject(6, dto.finalDatetime());
            stmt.setString(7, dto.description());
            stmt.setObject(8, LocalDateTime.now());
            stmt.setObject(9, LocalDateTime.now());
            stmt.executeUpdate();
        }
        
        connection.close();
	}

	private Rent findByCharacteristics(CreateRentRequest dto) throws SQLException {
	    var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select * from tb_rent where address = ? and tsrange(initial_datetime::timestamp without time zone, final_datetime::timestamp without time zone) && tsrange(?::timestamp without time zone, ?::timestamp without time zone)"
	    )) {
	        stmt.setString(1, dto.address());
	        stmt.setObject(2, dto.initialDatetime());
	        stmt.setObject(3, dto.finalDatetime());

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                var rent = new Rent(
	                    UUID.fromString(rs.getString("id")),
	                    rs.getString("name"),
	                    rs.getString("address"),
	                    rs.getLong("rent_type"),
	                    rs.getTimestamp("initial_datetime").toLocalDateTime(),
	                    rs.getTimestamp("final_datetime").toLocalDateTime(),
	                    rs.getString("description"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getTimestamp("updated_at").toLocalDateTime()
	                );
	                connection.close();
	                return rent;
	            }
	        }
	    }
	    return null;
	}
	
	public List<ListRentResponse> findAll() throws SQLException {
		var connection = PostgreConnector.getConnection();
        var rentals = new ArrayList<ListRentResponse>();
        
        try (PreparedStatement stmt = connection.prepareStatement(
        		"select r.*, exists (select 1 from tb_user_rent ur where ur.rent_status in (2, 3, 4) and ur.rent_id = r.id limit 1) as is_reserved, exists (select 1 from tb_user_rent ur where ur.rent_status = 5 and ur.rent_id = r.id limit 1) as is_conclude from tb_rent r order by r.created_at desc")
		) {
        	ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
            	rentals.add(new ListRentResponse(
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
            			rs.getBoolean("is_reserved"),
            			rs.getBoolean("is_conclude")
        		));
            }
        }
        
        connection.close();
        return rentals;
	}
	
	public List<ListRentResponse> filter(String address, String initialDate, String finalDate) throws SQLException {
	    var connection = PostgreConnector.getConnection();
	    var rentals = new ArrayList<ListRentResponse>();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select r.*, exists (select 1 from tb_user_rent ur where ur.rent_status in (2, 3, 4) and ur.rent_id = r.id limit 1) as is_reserved, " +
	            "exists (select 1 from tb_user_rent ur where ur.rent_status = 5 and ur.rent_id = r.id limit 1) as is_conclude " +
	            "from tb_rent r " +
	            "where (coalesce(?, '') = '' or r.address ilike ?) " +
	            "and (coalesce(?, r.initial_datetime::date) <= r.initial_datetime::date) " +
	            "and (coalesce(?, r.final_datetime::date) >= r.final_datetime::date) " +
	            "order by r.created_at desc"
	    )) {
	        stmt.setString(1, address != null ? address : "");
	        stmt.setString(2, address != null ? "%" + address + "%" : "");

	        if (initialDate != null && !initialDate.isEmpty()) {
	            stmt.setObject(3, LocalDate.parse(initialDate));
	        } else {
	            stmt.setObject(3, null);
	        }

	        if (finalDate != null && !finalDate.isEmpty()) {
	            stmt.setObject(4, LocalDate.parse(finalDate));
	        } else {
	            stmt.setObject(4, null);
	        }

	        ResultSet rs = stmt.executeQuery();

	        while (rs.next()) {
	            rentals.add(new ListRentResponse(
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
	                    rs.getBoolean("is_reserved"),
	                    rs.getBoolean("is_conclude")
	            ));
	        }
	    }

	    connection.close();
	    return rentals;
	}
	
	public Rent findById(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();

	    try (PreparedStatement stmt = connection.prepareStatement(
	            "select * from tb_rent where id = ?"
	    )) {
	        stmt.setObject(1, id);

	        try (ResultSet rs = stmt.executeQuery()) {
	            if (rs.next()) {
	                var rent = new Rent(
	                    UUID.fromString(rs.getString("id")),
	                    rs.getString("name"),
	                    rs.getString("address"),
	                    rs.getLong("rent_type"),
	                    rs.getTimestamp("initial_datetime").toLocalDateTime(),
	                    rs.getTimestamp("final_datetime").toLocalDateTime(),
	                    rs.getString("description"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getTimestamp("updated_at").toLocalDateTime()
	                );
	                connection.close();
	                return rent;
	            }
	        }
	    }
	    return null;
	}
	
	public Rent update(EditRentRequest dto) throws SQLException {
		if (dto.finalDatetime().isBefore(dto.initialDatetime()))
			throw new DateRangeException("A data de início deve ser inferior que a data final.");
		
		var connection = PostgreConnector.getConnection();
    	var now = LocalDateTime.now();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_rent set name = ?, address = ?, rent_type = ?, initial_datetime = ?, final_datetime = ?, description = ?, updated_at = ? where id = ?"
        )) {
        	stmt.setString(1, dto.name());
            stmt.setString(2, dto.address());
            stmt.setLong(3, dto.rentType());
            stmt.setObject(4, dto.initialDatetime());
            stmt.setObject(5, dto.finalDatetime());
            stmt.setString(6, dto.description());
            stmt.setObject(7, now);
            stmt.setObject(8, dto.id());
            stmt.executeUpdate();
        }
        connection.close();
        
        return new Rent(
        		dto.id(),
        		dto.name(),
        		dto.address(),
        		dto.rentType(),
        		dto.initialDatetime(),
        		dto.finalDatetime(),
        		dto.description(),
        		dto.createdAt(),
        		now
		);
	}
	
	public List<Rent> findAvailableRentals() throws SQLException {
		var connection = PostgreConnector.getConnection();
        var rentals = new ArrayList<Rent>();
        
        try (PreparedStatement stmt = connection.prepareStatement(
        		"select r.* from tb_rent as r left join (select ur.rent_id, ur.updated_at, ur.rent_status, row_number() over (partition by ur.rent_id order by ur.updated_at desc) as rn from tb_user_rent as ur) as ranked_ur on r.id = ranked_ur.rent_id and ranked_ur.rn = 1 where ranked_ur.rent_id is null or ranked_ur.rent_status = 1"
		)) {
        	ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
            	rentals.add(new Rent(
                		UUID.fromString(rs.getString("id")),
	                    rs.getString("name"),
	                    rs.getString("address"),
	                    rs.getLong("rent_type"),
	                    rs.getTimestamp("initial_datetime").toLocalDateTime(),
	                    rs.getTimestamp("final_datetime").toLocalDateTime(),
	                    rs.getString("description"),
	                    rs.getTimestamp("created_at").toLocalDateTime(),
	                    rs.getTimestamp("updated_at").toLocalDateTime()
        		));
            }
        }
        
        connection.close();
        return rentals;
	}
}
