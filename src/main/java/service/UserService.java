package service;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import database.PostgreConnector;
import dto.AuthUserRequest;
import entity.User;
import exception.AuthFailedException;
import exception.PasswordsNotMatches;
import exception.UnderageException;
import exception.UserNotFoundException;
import exception.UsernameAlreadyExistsException;

public class UserService {
	private static UserService instance;

	private UserService() {
		
	}
	
	public static UserService getInstance() {
		if (instance == null)
			instance = new UserService();
		return instance;
	}
	
	public User auth(AuthUserRequest a) throws SQLException {		
		User u = findByUsernameAndPassword(a.username(), a.password());
		
		if (u == null)
			throw new AuthFailedException("Usuário ou senha incorreto");
		
		return u;
	}
	
	public void create(User u) throws SQLException {
    	if (findByUsername(u.username()) != null)
    		throw new UsernameAlreadyExistsException("Nome de usuário já está em uso");
    	
    	if (u.birthDate().isAfter(LocalDate.now().minusYears(18)))
    		throw new UnderageException("Plataforma proibida para menores");
    	
    	var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement(
        		"insert into tb_user (id, name, username, password, user_type, birth_date, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?)"
        )) {
            stmt.setObject(1, u.id());
            stmt.setString(2, u.name());
            stmt.setString(3, u.username());
            stmt.setString(4, u.password());
            stmt.setLong(5, u.userType());
            stmt.setObject(6, u.birthDate());
            stmt.setObject(7, u.createdAt());
            stmt.setObject(8, u.updatedAt());
            stmt.executeUpdate();
        }
        
        connection.close();
    }
	
	public User findById(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement("select * from tb_user where id = ?")) {
            stmt.setObject(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
            	if (rs.next()) {
                    var user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getLong("user_type"),
                        rs.getObject("birth_date", LocalDate.class),
                        rs.getTimestamp("created_at").toLocalDateTime(),
                        rs.getTimestamp("updated_at").toLocalDateTime(),
                        rs.getBoolean("actived")
                    );
                    connection.close();
                    return user;
                }
            }
        }
        return null;
	}
	
	public User findByUsername(String username) throws SQLException {
    	var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement("select * from tb_user where username = ?")) {
            stmt.setString(1, username);
            
            try (ResultSet rs = stmt.executeQuery()) {
            	if (rs.next()) {
                    var user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getLong("user_type"),
                        rs.getObject("birth_date", LocalDate.class),
                        rs.getTimestamp("created_at").toLocalDateTime(),
                        rs.getTimestamp("updated_at").toLocalDateTime(),
                        rs.getBoolean("actived")
                    );
                    connection.close();
                    return user;
                }
            }
        }
        return null;
    }
	
	public User findByUsernameAndPassword(String username, String password) throws SQLException {
    	var connection = PostgreConnector.getConnection();
    	
        try (PreparedStatement stmt = connection.prepareStatement("select * from tb_user where username = ? and password = ?")) {
            stmt.setString(1, username);
            stmt.setString(2, password);
            
            try (ResultSet rs = stmt.executeQuery()) {
            	if (rs.next()) {
                    var user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getLong("user_type"),
                        rs.getObject("birth_date", LocalDate.class),
                        rs.getTimestamp("created_at").toLocalDateTime(),
                        rs.getTimestamp("updated_at").toLocalDateTime(),
                        rs.getBoolean("actived")
                    );
                    connection.close();
                    return user;
                }
            }
        }
        return null;
    }
	
	public void ban(UUID id) throws SQLException {
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user set actived = false where id = ?"
        )) {
        	stmt.setObject(1, id);
            stmt.executeUpdate();
        }
        connection.close();
	}

	public void unban(UUID userId) throws SQLException {
		if (findById(userId) == null)
			throw new UserNotFoundException("Usuário não encontrado");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user set actived = true, updated_at = ? where id = ?"
        )) {
        	stmt.setObject(1, LocalDateTime.now());
            stmt.setObject(2, userId);
            stmt.executeUpdate();
        }
        connection.close();
	}
	
	public User updatePassword(String password1, String password2, User user) throws SQLException {
		if (!password1.equals(password2))
			throw new PasswordsNotMatches("As senhas não correspondem");
		
		var connection = PostgreConnector.getConnection();
		
        try (PreparedStatement stmt = connection.prepareStatement(
        		"update tb_user set password = ?, actived = true, updated_at = ? where id = ?"
        )) {
        	stmt.setString(1, password1);
        	stmt.setObject(2, LocalDateTime.now());
            stmt.setObject(3, user.id());
            stmt.executeUpdate();
        }
        connection.close();
        
        return findById(user.id());
	}
}
