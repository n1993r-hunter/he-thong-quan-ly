package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.User;
import utils.DBConnection;

public class UserDAO {
    
    // Hàm kiểm tra Đăng nhập
    public User checkLogin(String username, String password) {
        User user = null;
        // Câu lệnh SQL tìm người dùng khớp username và password
        String sql = "SELECT * FROM USERS WHERE username = ? AND password = ?";
        
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            // Truyền tham số vào dấu ?
            ps.setString(1, username);
            ps.setString(2, password);
            
            ResultSet rs = ps.executeQuery();
            
            // Nếu tìm thấy tài khoản trong Database
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
        
        return user; // Trả về đối tượng user nếu đúng, trả về null nếu sai
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