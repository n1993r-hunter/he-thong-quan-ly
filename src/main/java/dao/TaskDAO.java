package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import utils.DBConnection;

public class TaskDAO {
    
    /**
     * Tạo một công việc mới trong nhóm
     * @param groupId ID của nhóm chứa công việc
     * @param title Tiêu đề công việc
     * @param description Mô tả chi tiết (có thể null)
     * @param createdBy ID của người tạo (Lấy từ Session)
     * @param deadline Hạn chót (Định dạng YYYY-MM-DD HH:MM:SS)
     * @return true nếu tạo thành công, false nếu thất bại
     */
    public boolean createTask(int groupId, String title, String description, int createdBy, String deadline) {
        String sql = "INSERT INTO TASKS (group_id, title, description, created_by, deadline) VALUES (?, ?, ?, ?, ?)";
        
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setInt(1, groupId);
            ps.setString(2, title);
            ps.setString(3, description);
            ps.setInt(4, createdBy);
            ps.setString(5, deadline); 
            
            int rowAffected = ps.executeUpdate();
            return rowAffected > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Giao công việc cho một thành viên cụ thể
     * @param taskId ID của công việc
     * @param userId ID của thành viên được giao
     * @return true nếu giao thành công, false nếu thất bại (ví dụ: đã giao rồi)
     */
    public boolean assignTask(int taskId, int userId) {
        // Lệnh INSERT vào bảng TASK_ASSIGNMENTS.
        // Cột progress và status sẽ tự động nhận giá trị mặc định là 0 và 'todo' theo DB.
        String sql = "INSERT INTO TASK_ASSIGNMENTS (task_id, user_id) VALUES (?, ?)";
        
        try {
            Connection conn = utils.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            
            int rowAffected = ps.executeUpdate();
            return rowAffected > 0;
            
        } catch (Exception e) {
            // Sẽ nhảy vào đây nếu vi phạm lỗi UNIQUE (giao 1 task cho 1 người 2 lần)
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Thêm bình luận mới vào một công việc
     * @param taskId ID của công việc đang được bình luận
     * @param userId ID của người bình luận (Lấy từ Session)
     * @param content Nội dung bình luận
     * @return true nếu thêm thành công, false nếu thất bại
     */
    public boolean addTaskComment(int taskId, int userId, String content) {
        String sql = "INSERT INTO TASK_COMMENTS (task_id, user_id, content) VALUES (?, ?, ?)";
        
        try {
            Connection conn = utils.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            
            int rowAffected = ps.executeUpdate();
            return rowAffected > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}