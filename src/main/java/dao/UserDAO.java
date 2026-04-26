package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.User;
import utils.DBConnection;

public class UserDAO {
    
	// Đổi tên biến truyền vào cho chuẩn nghĩa: 'account' có thể là email hoặc username
	public User checkLogin(String account, String password) {
	    User user = null;
	    
	    // NÂNG CẤP SQL: Kiểm tra xem biến account truyền vào có khớp với cột username HOẶC cột email không
	    String sql = "SELECT * FROM USERS WHERE (username = ? OR email = ?) AND password = ?";
	    
	    try {
	        Connection conn = DBConnection.getConnection();
	        PreparedStatement ps = conn.prepareStatement(sql);
	        
	        // Truyền cùng một biến 'account' vào cả 2 dấu hỏi chấm đầu tiên
	        ps.setString(1, account); 
	        ps.setString(2, account);
	        ps.setString(3, password);
	        
	        ResultSet rs = ps.executeQuery();
	        
	        if (rs.next()) {
	            user = new User();
	            user.setUserId(rs.getInt("user_id"));
	            user.setFullName(rs.getString("full_name"));
	            user.setEmail(rs.getString("email"));
	            user.setUsername(rs.getString("username"));
	            user.setPassword(rs.getString("password"));
	        }
	        
	        rs.close();
	        ps.close();
	        conn.close();
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    
	    return user;
	}
    
 // Hàm thêm người dùng mới vào Database
    public boolean registerUser(User user) {
        String sql = "INSERT INTO USERS (full_name, email, username, password) VALUES (?, ?, ?, ?)";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getUsername());
            ps.setString(4, user.getPassword());
            
            int rowAffected = ps.executeUpdate(); // Trả về số dòng được thêm
            return rowAffected > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}