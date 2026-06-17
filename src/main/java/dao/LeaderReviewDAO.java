package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.LeaderReviewView;
import utils.DBConnection;

public class LeaderReviewDAO {

    public boolean upsertLeaderReview(int leaderId, int reviewedUserId, int taskId, int groupId, int star, String comment) {
        String sql =
                "INSERT INTO LEADER_REVIEWS " +
                "(leader_id, reviewed_user_id, task_id, group_id, star, comment) " +
                "VALUES (?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE " +
                "star = VALUES(star), " +
                "comment = VALUES(comment), " +
                "review_time = CURRENT_TIMESTAMP";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, leaderId);
                ps.setInt(2, reviewedUserId);
                ps.setInt(3, taskId);
                ps.setInt(4, groupId);
                ps.setInt(5, star);
                ps.setString(6, comment);

                int row = ps.executeUpdate();
                return row > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<LeaderReviewView> getLeaderReviewsByGroupId(int groupId) {
        List<LeaderReviewView> list = new ArrayList<>();

        String sql =
                "SELECT " +
                "lr.leader_review_id, lr.leader_id, lr.reviewed_user_id, lr.task_id, lr.group_id, " +
                "lr.star, lr.comment, lr.review_time, " +
                "leader.full_name AS leader_full_name, " +
                "leader.username AS leader_username, " +
                "reviewed.full_name AS reviewed_full_name, " +
                "reviewed.username AS reviewed_username, " +
                "t.title AS task_title " +
                "FROM LEADER_REVIEWS lr " +
                "JOIN USERS leader ON lr.leader_id = leader.user_id " +
                "JOIN USERS reviewed ON lr.reviewed_user_id = reviewed.user_id " +
                "LEFT JOIN TASKS t ON lr.task_id = t.task_id " +
                "WHERE lr.group_id = ? " +
                "ORDER BY lr.review_time DESC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, groupId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LeaderReviewView view = new LeaderReviewView();

                        view.setLeaderReviewId(rs.getInt("leader_review_id"));
                        view.setLeaderId(rs.getInt("leader_id"));
                        view.setReviewedUserId(rs.getInt("reviewed_user_id"));

                        int taskId = rs.getInt("task_id");
                        if (!rs.wasNull()) {
                            view.setTaskId(taskId);
                        }

                        view.setGroupId(rs.getInt("group_id"));
                        view.setStar(rs.getInt("star"));
                        view.setComment(rs.getString("comment"));
                        view.setReviewTime(rs.getTimestamp("review_time"));

                        view.setLeaderFullName(rs.getString("leader_full_name"));
                        view.setLeaderUsername(rs.getString("leader_username"));
                        view.setReviewedFullName(rs.getString("reviewed_full_name"));
                        view.setReviewedUsername(rs.getString("reviewed_username"));
                        view.setTaskTitle(rs.getString("task_title"));

                        list.add(view);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Double getLeaderStarByTaskAndUser(int taskId, int reviewedUserId) {
        String sql =
                "SELECT star " +
                "FROM LEADER_REVIEWS " +
                "WHERE task_id = ? AND reviewed_user_id = ? " +
                "ORDER BY review_time DESC " +
                "LIMIT 1";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, reviewedUserId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getDouble("star");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}