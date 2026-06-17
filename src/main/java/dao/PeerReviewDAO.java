package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.PeerReviewView;
import utils.DBConnection;

public class PeerReviewDAO {

    public boolean upsertPeerReview(int reviewerId, int reviewedUserId, int taskId, int groupId, int star, String comment) {
        String sql =
                "INSERT INTO PEER_REVIEWS " +
                "(reviewer_id, reviewed_user_id, task_id, group_id, star, comment) " +
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
                ps.setInt(1, reviewerId);
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

    public List<PeerReviewView> getPeerReviewsByGroupId(int groupId) {
        List<PeerReviewView> list = new ArrayList<>();

        String sql =
                "SELECT " +
                "pr.review_id, pr.reviewer_id, pr.reviewed_user_id, pr.task_id, pr.group_id, " +
                "pr.star, pr.comment, pr.review_time, " +
                "reviewer.full_name AS reviewer_full_name, " +
                "reviewer.username AS reviewer_username, " +
                "reviewed.full_name AS reviewed_full_name, " +
                "reviewed.username AS reviewed_username, " +
                "t.title AS task_title " +
                "FROM PEER_REVIEWS pr " +
                "JOIN USERS reviewer ON pr.reviewer_id = reviewer.user_id " +
                "JOIN USERS reviewed ON pr.reviewed_user_id = reviewed.user_id " +
                "LEFT JOIN TASKS t ON pr.task_id = t.task_id " +
                "WHERE pr.group_id = ? " +
                "ORDER BY pr.review_time DESC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, groupId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        PeerReviewView view = new PeerReviewView();

                        view.setReviewId(rs.getInt("review_id"));
                        view.setReviewerId(rs.getInt("reviewer_id"));
                        view.setReviewedUserId(rs.getInt("reviewed_user_id"));

                        int taskId = rs.getInt("task_id");
                        if (!rs.wasNull()) {
                            view.setTaskId(taskId);
                        }

                        view.setGroupId(rs.getInt("group_id"));
                        view.setStar(rs.getInt("star"));
                        view.setComment(rs.getString("comment"));
                        view.setReviewTime(rs.getTimestamp("review_time"));

                        view.setReviewerFullName(rs.getString("reviewer_full_name"));
                        view.setReviewerUsername(rs.getString("reviewer_username"));
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

    public Double getAveragePeerStar(int taskId, int reviewedUserId) {
        String sql =
                "SELECT AVG(star) AS avg_star " +
                "FROM PEER_REVIEWS " +
                "WHERE task_id = ? AND reviewed_user_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, reviewedUserId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        double avg = rs.getDouble("avg_star");

                        if (!rs.wasNull()) {
                            return avg;
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}