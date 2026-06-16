package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Group;
import utils.DBConnection;

public class GroupDAO {

    // Hàm tạo nhóm mới, gán người tạo làm leader, đồng thời tạo stock cho leader
    public boolean createGroup(String groupName, int creatorId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return false;
            }

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

                // 4. Tạo stock cho leader
                createStock(conn, creatorId, newGroupId);

                ps2.close();
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

    // Hàm lấy danh sách nhóm mà user đang tham gia
    public List<Group> getGroupsByUserId(int userId) {
        List<Group> list = new ArrayList<>();

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
                Group group = new Group();
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

    // Hàm thêm thành viên mới vào nhóm, đồng thời tạo stock cho thành viên đó
    public boolean addMemberToGroup(int groupId, String usernameToAdd) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            // 1. Tìm user_id theo username
            String findUserSql = "SELECT user_id FROM USERS WHERE username = ?";
            PreparedStatement psFindUser = conn.prepareStatement(findUserSql);
            psFindUser.setString(1, usernameToAdd);

            ResultSet rs = psFindUser.executeQuery();

            int userIdToAdd = -1;

            if (rs.next()) {
                userIdToAdd = rs.getInt("user_id");
            }

            rs.close();
            psFindUser.close();

            if (userIdToAdd == -1) {
                conn.rollback();
                return false;
            }

            // 2. Thêm user vào GROUP_MEMBERS với role = member
            String addMemberSql = "INSERT INTO GROUP_MEMBERS (group_id, user_id, role) VALUES (?, ?, 'member')";
            PreparedStatement psAddMember = conn.prepareStatement(addMemberSql);
            psAddMember.setInt(1, groupId);
            psAddMember.setInt(2, userIdToAdd);

            int rowAffected = psAddMember.executeUpdate();
            psAddMember.close();

            if (rowAffected <= 0) {
                conn.rollback();
                return false;
            }

            // 3. Tạo stock cho thành viên mới
            createStock(conn, userIdToAdd, groupId);

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

    // Hàm phụ: tạo stock cho một user trong một group
    private void createStock(Connection conn, int userId, int groupId) throws Exception {
        String stockCode = "U" + userId + "G" + groupId;

        String sql = "INSERT INTO STOCKS (user_id, group_id, stock_code, current_price) VALUES (?, ?, ?, 100)";
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setInt(1, userId);
        ps.setInt(2, groupId);
        ps.setString(3, stockCode);

        ps.executeUpdate();
        ps.close();
    }
}