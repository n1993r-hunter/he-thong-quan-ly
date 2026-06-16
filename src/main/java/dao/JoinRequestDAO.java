package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import utils.DBConnection;

public class JoinRequestDAO {

    public String sendJoinRequest(int groupId, int userId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return "fail";
            }

            // 1. Kiểm tra nhóm có tồn tại không
            if (!groupExists(conn, groupId)) {
                return "group_not_found";
            }

            // 2. Kiểm tra user đã ở trong nhóm chưa
            if (isAlreadyMember(conn, groupId, userId)) {
                return "already_member";
            }

            // 3. Kiểm tra đã từng gửi request chưa
            String oldStatus = getOldRequestStatus(conn, groupId, userId);

            if ("pending".equals(oldStatus)) {
                return "already_pending";
            }

            // Nếu đã từng bị reject hoặc approved nhưng hiện không còn là member
            // thì cho gửi lại request
            if (oldStatus != null) {
                String updateSql = "UPDATE GROUP_JOIN_REQUESTS " +
                                   "SET status = 'pending', requested_at = CURRENT_TIMESTAMP, reviewed_at = NULL, reviewed_by = NULL " +
                                   "WHERE group_id = ? AND user_id = ?";

                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setInt(1, groupId);
                psUpdate.setInt(2, userId);

                int row = psUpdate.executeUpdate();
                psUpdate.close();

                return row > 0 ? "sent" : "fail";
            }

            // 4. Tạo request mới
            String insertSql = "INSERT INTO GROUP_JOIN_REQUESTS (group_id, user_id, status) VALUES (?, ?, 'pending')";

            PreparedStatement psInsert = conn.prepareStatement(insertSql);
            psInsert.setInt(1, groupId);
            psInsert.setInt(2, userId);

            int row = psInsert.executeUpdate();
            psInsert.close();

            return row > 0 ? "sent" : "fail";

        } catch (Exception e) {
            e.printStackTrace();
            return "fail";

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private boolean groupExists(Connection conn, int groupId) throws Exception {
        String sql = "SELECT group_id FROM `GROUPS` WHERE group_id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, groupId);

        ResultSet rs = ps.executeQuery();

        boolean exists = rs.next();

        rs.close();
        ps.close();

        return exists;
    }

    private boolean isAlreadyMember(Connection conn, int groupId, int userId) throws Exception {
        String sql = "SELECT member_id FROM GROUP_MEMBERS WHERE group_id = ? AND user_id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, groupId);
        ps.setInt(2, userId);

        ResultSet rs = ps.executeQuery();

        boolean exists = rs.next();

        rs.close();
        ps.close();

        return exists;
    }

    private String getOldRequestStatus(Connection conn, int groupId, int userId) throws Exception {
        String sql = "SELECT status FROM GROUP_JOIN_REQUESTS WHERE group_id = ? AND user_id = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, groupId);
        ps.setInt(2, userId);

        ResultSet rs = ps.executeQuery();

        String status = null;

        if (rs.next()) {
            status = rs.getString("status");
        }

        rs.close();
        ps.close();

        return status;
    }
}