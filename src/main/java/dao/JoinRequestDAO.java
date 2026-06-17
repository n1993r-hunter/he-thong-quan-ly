package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.JoinRequestView;
import utils.DBConnection;

public class JoinRequestDAO {

    public String sendJoinRequest(int groupId, int userId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return "fail";
            }

            if (!groupExists(conn, groupId)) {
                return "group_not_found";
            }

            if (isAlreadyMember(conn, groupId, userId)) {
                return "already_member";
            }

            String oldStatus = getOldRequestStatus(conn, groupId, userId);

            if ("pending".equals(oldStatus)) {
                return "already_pending";
            }

            if (oldStatus != null) {
                String updateSql =
                        "UPDATE GROUP_JOIN_REQUESTS " +
                        "SET status = 'pending', requested_at = CURRENT_TIMESTAMP, reviewed_at = NULL, reviewed_by = NULL " +
                        "WHERE group_id = ? AND user_id = ?";

                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, groupId);
                    psUpdate.setInt(2, userId);

                    int row = psUpdate.executeUpdate();
                    return row > 0 ? "sent" : "fail";
                }
            }

            String insertSql =
                    "INSERT INTO GROUP_JOIN_REQUESTS (group_id, user_id, status) " +
                    "VALUES (?, ?, 'pending')";

            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setInt(1, groupId);
                psInsert.setInt(2, userId);

                int row = psInsert.executeUpdate();
                return row > 0 ? "sent" : "fail";
            }

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

    public List<JoinRequestView> getPendingRequestsByGroupId(int groupId) {
        List<JoinRequestView> list = new ArrayList<>();

        String sql =
                "SELECT " +
                "r.request_id, r.group_id, r.user_id, r.status, r.requested_at, r.reviewed_at, r.reviewed_by, " +
                "u.full_name, u.username, u.email " +
                "FROM GROUP_JOIN_REQUESTS r " +
                "JOIN USERS u ON r.user_id = u.user_id " +
                "WHERE r.group_id = ? AND r.status = 'pending' " +
                "ORDER BY r.requested_at ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, groupId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        JoinRequestView view = new JoinRequestView();

                        view.setRequestId(rs.getInt("request_id"));
                        view.setGroupId(rs.getInt("group_id"));
                        view.setUserId(rs.getInt("user_id"));
                        view.setStatus(rs.getString("status"));
                        view.setRequestedAt(rs.getTimestamp("requested_at"));
                        view.setReviewedAt(rs.getTimestamp("reviewed_at"));

                        int reviewedBy = rs.getInt("reviewed_by");
                        if (!rs.wasNull()) {
                            view.setReviewedBy(reviewedBy);
                        }

                        view.setFullName(rs.getString("full_name"));
                        view.setUsername(rs.getString("username"));
                        view.setEmail(rs.getString("email"));

                        list.add(view);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean approveRequest(int requestId, int groupId, int leaderId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            Integer userId = getPendingRequestUserId(conn, requestId, groupId);

            if (userId == null) {
                conn.rollback();
                return false;
            }

            if (!isAlreadyMember(conn, groupId, userId)) {
                String insertMemberSql =
                        "INSERT INTO GROUP_MEMBERS (group_id, user_id, role) " +
                        "VALUES (?, ?, 'member')";

                try (PreparedStatement psMember = conn.prepareStatement(insertMemberSql)) {
                    psMember.setInt(1, groupId);
                    psMember.setInt(2, userId);
                    psMember.executeUpdate();
                }

                createStockIfNotExists(conn, userId, groupId);
            }

            String updateRequestSql =
                    "UPDATE GROUP_JOIN_REQUESTS " +
                    "SET status = 'approved', reviewed_at = CURRENT_TIMESTAMP, reviewed_by = ? " +
                    "WHERE request_id = ? AND group_id = ?";

            try (PreparedStatement psUpdate = conn.prepareStatement(updateRequestSql)) {
                psUpdate.setInt(1, leaderId);
                psUpdate.setInt(2, requestId);
                psUpdate.setInt(3, groupId);

                int row = psUpdate.executeUpdate();

                if (row <= 0) {
                    conn.rollback();
                    return false;
                }
            }

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

    public boolean rejectRequest(int requestId, int groupId, int leaderId) {
        String sql =
                "UPDATE GROUP_JOIN_REQUESTS " +
                "SET status = 'rejected', reviewed_at = CURRENT_TIMESTAMP, reviewed_by = ? " +
                "WHERE request_id = ? AND group_id = ? AND status = 'pending'";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, leaderId);
                ps.setInt(2, requestId);
                ps.setInt(3, groupId);

                int row = ps.executeUpdate();
                return row > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private Integer getPendingRequestUserId(Connection conn, int requestId, int groupId) throws Exception {
        String sql =
                "SELECT user_id " +
                "FROM GROUP_JOIN_REQUESTS " +
                "WHERE request_id = ? AND group_id = ? AND status = 'pending'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, groupId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }

        return null;
    }

    private boolean groupExists(Connection conn, int groupId) throws Exception {
        String sql = "SELECT group_id FROM `GROUPS` WHERE group_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean isAlreadyMember(Connection conn, int groupId, int userId) throws Exception {
        String sql = "SELECT member_id FROM GROUP_MEMBERS WHERE group_id = ? AND user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String getOldRequestStatus(Connection conn, int groupId, int userId) throws Exception {
        String sql = "SELECT status FROM GROUP_JOIN_REQUESTS WHERE group_id = ? AND user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }

        return null;
    }

    private void createStockIfNotExists(Connection conn, int userId, int groupId) throws Exception {
        String stockCode = "U" + userId + "G" + groupId;

        String sql =
                "INSERT IGNORE INTO STOCKS (user_id, group_id, stock_code, current_price) " +
                "VALUES (?, ?, ?, 100)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ps.setString(3, stockCode);
            ps.executeUpdate();
        }
    }
}