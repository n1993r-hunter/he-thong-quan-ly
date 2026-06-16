package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import utils.DBConnection;

public class ActivityLogDAO {
    
    /**
     * Ghi lại một hoạt động vào hệ thống (Dùng ngầm định trong Backend)
     * @param userId ID của người thực hiện hành động
     * @param groupId ID của nhóm (Có thể null nếu hành động không thuộc nhóm nào)
     * @param taskId ID của công việc (Có thể null nếu hành động không liên quan đến task)
     * @param activityType Loại hành động (VD: 'CREATED_GROUP', 'ASSIGNED_TASK', 'COMMENTED')
     */
    public void logActivity(int userId, Integer groupId, Integer taskId, String activityType) {
        String sql = "INSERT INTO ACTIVITY_LOGS (user_id, group_id, task_id, activity_type) VALUES (?, ?, ?, ?)";
        
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            
            ps.setInt(1, userId);
            
            // Xử lý Integer (Có thể null) cho group_id
            if (groupId != null) {
                ps.setInt(2, groupId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            
            // Xử lý Integer (Có thể null) cho task_id
            if (taskId != null) {
                ps.setInt(3, taskId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            
            ps.setString(4, activityType);
            
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace(); 
            // Lưu ý: Không return boolean vì việc ghi log thất bại 
            // không được làm gián đoạn luồng chính của hệ thống.
        }
    }
}