package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import utils.DBConnection;

public class GroupDAO {

    // Hàm tạo nhóm mới, gán người tạo làm leader, đồng thời tạo stock cho leader
    public boolean createGroup(String groupName, int creatorId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Thêm nhóm mới vào GROUPS
            String sql1 = "INSERT INTO `GROUPS` (group_name, created_by) VALUES (?, ?)";
            PreparedStatement ps1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            ps1.setString(1, groupName);
            ps1.setInt(2, creatorId);
            ps1.executeUpdate();

            // 2. Lấy group_id vừa tạo
            ResultSet rs = ps1.getGeneratedKeys();
            int newGroupId = -1;

            if (rs.next()) {
                newGroupId = rs.getInt(1);
            }

            if (newGroupId != -1) {
                // 3. Thêm người tạo nhóm vào GROUP_MEMBERS với role = leader
                String sql2 = "INSERT INTO GROUP_MEMBERS (group_id, user_id, role) VALUES (?, ?, 'leader')";
                PreparedStatement ps2 = conn.prepareStatement(sql2);
                ps2.setInt(1, newGroupId);
                ps2.setInt(2, creatorId);
                ps2.executeUpdate();

                // 4. Tạo mã cổ phiếu cho leader
                // Ví dụ: U1G2 = User 1 trong Group 2
                String stockCode = "U" + creatorId + "G" + newGroupId;

                String sql3 = "INSERT INTO STOCKS (user_id, group_id, stock_code, current_price) VALUES (?, ?, ?, 100)";
                PreparedStatement ps3 = conn.prepareStatement(sql3);
                ps3.setInt(1, creatorId);
                ps3.setInt(2, newGroupId);
                ps3.setString(3, stockCode);
                ps3.executeUpdate();

                ps2.close();
                ps3.close();
            }

            rs.close();
            ps1.close();

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        return false;
    }
    public java.util.List<model.Group> getGroupsByUserId(int userId) {
        java.util.List<model.Group> list = new java.util.ArrayList<>();

        String sql = "SELECT g.group_id, g.group_name, g.created_by " +
                     "FROM `GROUPS` g " +
                     "JOIN GROUP_MEMBERS gm ON g.group_id = gm.group_id " +
                     "WHERE gm.user_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                model.Group group = new model.Group();
                group.setGroupId(rs.getInt("group_id"));
                group.setGroupName(rs.getString("group_name"));
                group.setCreatedBy(rs.getInt("created_by"));
                list.add(group);
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}