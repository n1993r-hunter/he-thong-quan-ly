package utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Đường dẫn mới đến Database của Hưng
            String url = "jdbc:mysql://localhost:3306/he_thong_quan_ly"; 
            String user = "root";
            String password = "123456"; 
            
            return DriverManager.getConnection(url, user, password);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void main(String[] args) {
        if (getConnection() != null) {
            System.out.println("🎉 KẾT NỐI THÀNH CÔNG ĐẾN HE_THONG_QUAN_LY!");
        } else {
            System.out.println("❌ THẤT BẠI. Kiểm tra Driver hoặc Password.");
        }
    }
}