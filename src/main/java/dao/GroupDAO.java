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
    public boolean isUserInGroup(int userId, int groupId) {
        String sql = "SELECT member_id FROM GROUP_MEMBERS WHERE user_id = ? AND group_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setInt(2, groupId);

            ResultSet rs = ps.executeQuery();

            boolean exists = rs.next();

            rs.close();
            ps.close();
            conn.close();

            return exists;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
 // Kiểm tra user có phải leader của nhóm không
    public boolean isLeader(int userId, int groupId) {
        String sql = "SELECT member_id FROM GROUP_MEMBERS WHERE user_id = ? AND group_id = ? AND role = 'leader'";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setInt(2, groupId);

            ResultSet rs = ps.executeQuery();

            boolean result = rs.next();

            rs.close();
            ps.close();
            conn.close();

            return result;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // Leader kick thành viên khỏi nhóm
    public boolean kickMemberFromGroup(int groupId, int memberUserId, int leaderId) {
        if (!isLeader(leaderId, groupId)) {
            return false;
        }

        // Không cho leader tự kick chính mình
        if (memberUserId == leaderId) {
            return false;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Xóa dữ liệu AI liên quan đến bài nộp của member trong nhóm
            executeUpdate(conn,
                "DELETE ae FROM AI_EVALUATIONS ae " +
                "JOIN TASK_SUBMISSIONS ts ON ae.submission_id = ts.submission_id " +
                "JOIN TASKS t ON ts.task_id = t.task_id " +
                "WHERE t.group_id = ? AND ts.user_id = ?",
                groupId, memberUserId
            );

            // Xóa bài nộp của member trong nhóm
            executeUpdate(conn,
                "DELETE ts FROM TASK_SUBMISSIONS ts " +
                "JOIN TASKS t ON ts.task_id = t.task_id " +
                "WHERE t.group_id = ? AND ts.user_id = ?",
                groupId, memberUserId
            );

            // Xóa log tiến độ của member
            executeUpdate(conn,
                "DELETE tpl FROM TASK_PROGRESS_LOGS tpl " +
                "JOIN TASK_ASSIGNMENTS ta ON tpl.assignment_id = ta.assignment_id " +
                "JOIN TASKS t ON ta.task_id = t.task_id " +
                "WHERE t.group_id = ? AND ta.user_id = ?",
                groupId, memberUserId
            );

            // Xóa tổng hợp điểm task của member
            executeUpdate(conn,
                "DELETE FROM TASK_SCORE_SUMMARY WHERE group_id = ? AND user_id = ?",
                groupId, memberUserId
            );

            // Xóa assignment của member
            executeUpdate(conn,
                "DELETE ta FROM TASK_ASSIGNMENTS ta " +
                "JOIN TASKS t ON ta.task_id = t.task_id " +
                "WHERE t.group_id = ? AND ta.user_id = ?",
                groupId, memberUserId
            );

            // Xóa review liên quan đến member
            executeUpdate(conn,
                "DELETE FROM PEER_REVIEWS WHERE group_id = ? AND (reviewer_id = ? OR reviewed_user_id = ?)",
                groupId, memberUserId, memberUserId
            );

            executeUpdate(conn,
                "DELETE FROM LEADER_REVIEWS WHERE group_id = ? AND (leader_id = ? OR reviewed_user_id = ?)",
                groupId, memberUserId, memberUserId
            );

            // Xóa comment của member trong task thuộc nhóm
            executeUpdate(conn,
                "DELETE FROM TASK_COMMENTS WHERE user_id = ? AND task_id IN (SELECT task_id FROM TASKS WHERE group_id = ?)",
                memberUserId, groupId
            );

            // Xóa activity log
            executeUpdate(conn,
                "DELETE FROM ACTIVITY_LOGS WHERE group_id = ? AND user_id = ?",
                groupId, memberUserId
            );

            // Xóa điểm cuối nếu có
            executeUpdate(conn,
                "DELETE FROM MEMBER_FINAL_SCORES WHERE group_id = ? AND user_id = ?",
                groupId, memberUserId
            );

            // Xóa lịch sử stock trước
            executeUpdate(conn,
                "DELETE sph FROM STOCK_PRICE_HISTORY sph " +
                "JOIN STOCKS s ON sph.stock_id = s.stock_id " +
                "WHERE s.group_id = ? AND s.user_id = ?",
                groupId, memberUserId
            );

            // Xóa stock của member
            executeUpdate(conn,
                "DELETE FROM STOCKS WHERE group_id = ? AND user_id = ?",
                groupId, memberUserId
            );

            // Xóa member khỏi group
            int row = executeUpdate(conn,
                "DELETE FROM GROUP_MEMBERS WHERE group_id = ? AND user_id = ?",
                groupId, memberUserId
            );

            conn.commit();

            return row > 0;

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


    // Leader giải thể nhóm
    public boolean dissolveGroup(int groupId, int leaderId) {
        if (!isLeader(leaderId, groupId)) {
            return false;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Xóa điểm cuối và điểm thầy cô
            executeUpdate(conn, "DELETE FROM MEMBER_FINAL_SCORES WHERE group_id = ?", groupId);
            executeUpdate(conn, "DELETE FROM GROUP_TEACHER_SCORES WHERE group_id = ?", groupId);

            // Xóa review
            executeUpdate(conn, "DELETE FROM PEER_REVIEWS WHERE group_id = ?", groupId);
            executeUpdate(conn, "DELETE FROM LEADER_REVIEWS WHERE group_id = ?", groupId);

            // Xóa AI evaluations
            executeUpdate(conn,
                "DELETE ae FROM AI_EVALUATIONS ae " +
                "JOIN TASKS t ON ae.task_id = t.task_id " +
                "WHERE t.group_id = ?",
                groupId
            );

            // Xóa task score summary
            executeUpdate(conn, "DELETE FROM TASK_SCORE_SUMMARY WHERE group_id = ?", groupId);

            // Xóa progress logs
            executeUpdate(conn,
                "DELETE tpl FROM TASK_PROGRESS_LOGS tpl " +
                "JOIN TASK_ASSIGNMENTS ta ON tpl.assignment_id = ta.assignment_id " +
                "JOIN TASKS t ON ta.task_id = t.task_id " +
                "WHERE t.group_id = ?",
                groupId
            );

            // Xóa submissions
            executeUpdate(conn,
                "DELETE ts FROM TASK_SUBMISSIONS ts " +
                "JOIN TASKS t ON ts.task_id = t.task_id " +
                "WHERE t.group_id = ?",
                groupId
            );

            // Xóa task assignments
            executeUpdate(conn,
                "DELETE ta FROM TASK_ASSIGNMENTS ta " +
                "JOIN TASKS t ON ta.task_id = t.task_id " +
                "WHERE t.group_id = ?",
                groupId
            );

            // Xóa comment, subtask
            executeUpdate(conn,
                "DELETE FROM TASK_COMMENTS WHERE task_id IN (SELECT task_id FROM TASKS WHERE group_id = ?)",
                groupId
            );

            executeUpdate(conn,
                "DELETE FROM SUBTASKS WHERE task_id IN (SELECT task_id FROM TASKS WHERE group_id = ?)",
                groupId
            );

            // Xóa stock history theo stock
            executeUpdate(conn,
                "DELETE sph FROM STOCK_PRICE_HISTORY sph " +
                "JOIN STOCKS s ON sph.stock_id = s.stock_id " +
                "WHERE s.group_id = ?",
                groupId
            );

            // Xóa stock history theo task nếu còn
            executeUpdate(conn,
                "DELETE sph FROM STOCK_PRICE_HISTORY sph " +
                "JOIN TASKS t ON sph.task_id = t.task_id " +
                "WHERE t.group_id = ?",
                groupId
            );

            // Xóa activity logs
            executeUpdate(conn, "DELETE FROM ACTIVITY_LOGS WHERE group_id = ?", groupId);

            // Xóa stocks
            executeUpdate(conn, "DELETE FROM STOCKS WHERE group_id = ?", groupId);

            // Xóa tasks
            executeUpdate(conn, "DELETE FROM TASKS WHERE group_id = ?", groupId);

            // Xóa group members
            executeUpdate(conn, "DELETE FROM GROUP_MEMBERS WHERE group_id = ?", groupId);

            // Xóa group
            int row = executeUpdate(conn, "DELETE FROM `GROUPS` WHERE group_id = ?", groupId);

            conn.commit();

            return row > 0;

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


    // Hàm phụ để chạy DELETE/UPDATE/INSERT
    private int executeUpdate(Connection conn, String sql, Object... params) throws Exception {
        PreparedStatement ps = conn.prepareStatement(sql);

        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }

        int row = ps.executeUpdate();

        ps.close();

        return row;
    }
}