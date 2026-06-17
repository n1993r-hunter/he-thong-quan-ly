package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.TaskSubmissionView;
import utils.DBConnection;

public class TaskDAO {

    public boolean createTask(int groupId, String title, String description, int createdBy, String deadline) {
        return createTaskReturnId(groupId, title, description, createdBy, deadline) > 0;
    }

    public int createTaskReturnId(int groupId, String title, String description, int createdBy, String deadline) {
        String sql = "INSERT INTO TASKS (group_id, title, description, created_by, deadline) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return -1;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, groupId);
                ps.setString(2, title);
                ps.setString(3, description);
                ps.setInt(4, createdBy);
                ps.setString(5, deadline);

                int rowAffected = ps.executeUpdate();

                if (rowAffected <= 0) {
                    return -1;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    public boolean assignTask(int taskId, int userId) {
        String sql = "INSERT INTO TASK_ASSIGNMENTS (task_id, user_id) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, userId);

                int rowAffected = ps.executeUpdate();
                return rowAffected > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean addTaskComment(int taskId, int userId, String content) {
        String sql = "INSERT INTO TASK_COMMENTS (task_id, user_id, content) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, userId);
                ps.setString(3, content);

                int rowAffected = ps.executeUpdate();
                return rowAffected > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<TaskSubmissionView> getTaskSubmissionViewsByGroupId(int groupId) {
        List<TaskSubmissionView> list = new ArrayList<>();

        String sql =
            "SELECT " +
            "ta.assignment_id, " +
            "t.task_id, t.group_id, t.title, t.description, t.deadline, " +
            "ta.status AS assignment_status, ta.progress, " +
            "u.user_id AS assignee_user_id, u.full_name AS assignee_full_name, u.username AS assignee_username, " +
            "ts.submission_id, ts.file_name, ts.file_path, ts.submit_version, ts.submitted_at, " +
            "ae.ai_evaluation_id, ae.ai_star, ae.converted_point, ae.summary, ae.strengths, ae.weaknesses, ae.raw_response, ae.evaluated_at " +
            "FROM TASKS t " +
            "JOIN TASK_ASSIGNMENTS ta ON t.task_id = ta.task_id " +
            "JOIN USERS u ON ta.user_id = u.user_id " +
            "LEFT JOIN TASK_SUBMISSIONS ts ON ts.submission_id = ( " +
            "    SELECT ts2.submission_id " +
            "    FROM TASK_SUBMISSIONS ts2 " +
            "    WHERE ts2.assignment_id = ta.assignment_id " +
            "    ORDER BY ts2.submit_version DESC, ts2.submission_id DESC " +
            "    LIMIT 1 " +
            ") " +
            "LEFT JOIN AI_EVALUATIONS ae ON ae.ai_evaluation_id = ( " +
            "    SELECT ae2.ai_evaluation_id " +
            "    FROM AI_EVALUATIONS ae2 " +
            "    WHERE ae2.submission_id = ts.submission_id " +
            "    ORDER BY ae2.evaluated_at DESC, ae2.ai_evaluation_id DESC " +
            "    LIMIT 1 " +
            ") " +
            "WHERE t.group_id = ? " +
            "ORDER BY t.deadline ASC, t.task_id ASC, u.full_name ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, groupId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapTaskSubmissionView(rs));
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public TaskSubmissionView getAssignmentForUpload(int assignmentId) {
        String sql =
            "SELECT " +
            "ta.assignment_id, " +
            "t.task_id, t.group_id, t.title, t.description, t.deadline, " +
            "ta.status AS assignment_status, ta.progress, " +
            "u.user_id AS assignee_user_id, u.full_name AS assignee_full_name, u.username AS assignee_username " +
            "FROM TASK_ASSIGNMENTS ta " +
            "JOIN TASKS t ON ta.task_id = t.task_id " +
            "JOIN USERS u ON ta.user_id = u.user_id " +
            "WHERE ta.assignment_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return null;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, assignmentId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        TaskSubmissionView view = new TaskSubmissionView();

                        view.setAssignmentId(rs.getInt("assignment_id"));
                        view.setTaskId(rs.getInt("task_id"));
                        view.setGroupId(rs.getInt("group_id"));
                        view.setTitle(rs.getString("title"));
                        view.setDescription(rs.getString("description"));
                        view.setDeadline(rs.getTimestamp("deadline"));
                        view.setAssignmentStatus(rs.getString("assignment_status"));
                        view.setProgress(rs.getInt("progress"));

                        view.setAssigneeUserId(rs.getInt("assignee_user_id"));
                        view.setAssigneeFullName(rs.getString("assignee_full_name"));
                        view.setAssigneeUsername(rs.getString("assignee_username"));

                        return view;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public int insertTaskSubmission(int assignmentId, int userId, int taskId, String fileName, String filePath, String fileType) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return -1;
            }

            conn.setAutoCommit(false);

            int nextVersion = getNextSubmitVersion(conn, assignmentId);

            String insertSql =
                "INSERT INTO TASK_SUBMISSIONS " +
                "(assignment_id, user_id, task_id, file_name, file_path, file_type, submit_version) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

            int newSubmissionId = -1;

            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, assignmentId);
                ps.setInt(2, userId);
                ps.setInt(3, taskId);
                ps.setString(4, fileName);
                ps.setString(5, filePath);
                ps.setString(6, fileType);
                ps.setInt(7, nextVersion);

                int row = ps.executeUpdate();

                if (row <= 0) {
                    conn.rollback();
                    return -1;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newSubmissionId = rs.getInt(1);
                    }
                }
            }

            String updateAssignmentSql =
                "UPDATE TASK_ASSIGNMENTS " +
                "SET status = 'done', progress = 100, submitted_at = CURRENT_TIMESTAMP, completed_at = CURRENT_TIMESTAMP " +
                "WHERE assignment_id = ?";

            try (PreparedStatement psUpdate = conn.prepareStatement(updateAssignmentSql)) {
                psUpdate.setInt(1, assignmentId);
                psUpdate.executeUpdate();
            }

            conn.commit();

            return newSubmissionId;

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

        return -1;
    }

    private int getNextSubmitVersion(Connection conn, int assignmentId) throws Exception {
        String sql = "SELECT COALESCE(MAX(submit_version), 0) + 1 AS next_version FROM TASK_SUBMISSIONS WHERE assignment_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("next_version");
                }
            }
        }

        return 1;
    }

    private TaskSubmissionView mapTaskSubmissionView(ResultSet rs) throws Exception {
        TaskSubmissionView view = new TaskSubmissionView();

        view.setAssignmentId(rs.getInt("assignment_id"));
        view.setTaskId(rs.getInt("task_id"));
        view.setGroupId(rs.getInt("group_id"));
        view.setTitle(rs.getString("title"));
        view.setDescription(rs.getString("description"));
        view.setDeadline(rs.getTimestamp("deadline"));
        view.setAssignmentStatus(rs.getString("assignment_status"));
        view.setProgress(rs.getInt("progress"));

        view.setAssigneeUserId(rs.getInt("assignee_user_id"));
        view.setAssigneeFullName(rs.getString("assignee_full_name"));
        view.setAssigneeUsername(rs.getString("assignee_username"));

        int submissionId = rs.getInt("submission_id");
        if (!rs.wasNull()) {
            view.setSubmissionId(submissionId);
            view.setFileName(rs.getString("file_name"));
            view.setFilePath(rs.getString("file_path"));
            view.setSubmitVersion(rs.getInt("submit_version"));
            view.setSubmittedAt(rs.getTimestamp("submitted_at"));
        }

        int aiEvaluationId = rs.getInt("ai_evaluation_id");
        if (!rs.wasNull()) {
            view.setAiEvaluationId(aiEvaluationId);
            view.setAiStar(rs.getInt("ai_star"));
            view.setConvertedPoint(rs.getInt("converted_point"));
            view.setAiSummary(rs.getString("summary"));
            view.setAiStrengths(rs.getString("strengths"));
            view.setAiWeaknesses(rs.getString("weaknesses"));
            view.setRawResponse(rs.getString("raw_response"));
            view.setEvaluatedAt(rs.getTimestamp("evaluated_at"));
        }

        return view;
    }
}