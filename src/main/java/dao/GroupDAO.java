package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import utils.DBConnection;

public class GroupDAO {
    
    // Hàm tạo nhóm mới và tự động gán quyền Leader
    public boolean createGroup(String groupName, int creatorId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            // Tắt tự động lưu để gộp 2 lệnh SQL thành 1 giao dịch (Transaction)
            conn.setAutoCommit(false); 

            // LỆNH 1: Thêm vào bảng GROUPS
            // Chú ý: Từ GROUPS phải có dấu ` (ngoặc nhọn) vì nó là từ khóa của MySQL
            String sql1 = "INSERT INTO `GROUPS` (group_name, created_by) VALUES (?, ?)";
            // Cài đặt Statement.RETURN_GENERATED_KEYS để lấy ID của nhóm vừa tạo
            PreparedStatement ps1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            ps1.setString(1, groupName);
            ps1.setInt(2, creatorId);
            ps1.executeUpdate();

            // Lấy ra ID của Nhóm mới tạo
            ResultSet rs = ps1.getGeneratedKeys();
            int newGroupId = -1;
            if (rs.next()) {
                newGroupId = rs.getInt(1);
            }

            // LỆNH 2: Thêm người tạo vào bảng GROUP_MEMBERS với quyền 'leader'
            if (newGroupId != -1) {
                String sql2 = "INSERT INTO GROUP_MEMBERS (group_id, user_id, role) VALUES (?, ?, 'leader')";
                PreparedStatement ps2 = conn.prepareStatement(sql2);
                ps2.setInt(1, newGroupId);
                ps2.setInt(2, creatorId);
                ps2.executeUpdate();
            }

            // Nếu cả 2 lệnh thành công -> Lưu vĩnh viễn (Commit)
            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi ở bất kỳ bước nào -> Hủy bỏ toàn bộ (Rollback)
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) {}
            }
        } finally {
            // Đóng kết nối
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) {}
            }
        }
        return false;
    }
}