package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import model.AIEvaluationResult;
import model.SubmissionContext;
import utils.DBConnection;

public class AIEvaluationDAO {

    public SubmissionContext getSubmissionContext(int submissionId) {
        String sql = "SELECT " +
                     "ts.submission_id, ts.assignment_id, ts.task_id, ts.user_id, " +
                     "ts.file_name, ts.file_path, ts.submit_version, " +
                     "t.group_id, t.title AS task_title, t.description AS task_description, t.deadline, " +
                     "g.group_name, " +
                     "u.full_name, u.username " +
                     "FROM TASK_SUBMISSIONS ts " +
                     "JOIN TASKS t ON ts.task_id = t.task_id " +
                     "JOIN `GROUPS` g ON t.group_id = g.group_id " +
                     "JOIN USERS u ON ts.user_id = u.user_id " +
                     "WHERE ts.submission_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, submissionId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                SubmissionContext ctx = new SubmissionContext();

                ctx.setSubmissionId(rs.getInt("submission_id"));
                ctx.setAssignmentId(rs.getInt("assignment_id"));
                ctx.setTaskId(rs.getInt("task_id"));
                ctx.setUserId(rs.getInt("user_id"));
                ctx.setFileName(rs.getString("file_name"));
                ctx.setFilePath(rs.getString("file_path"));
                ctx.setSubmitVersion(rs.getInt("submit_version"));

                ctx.setGroupId(rs.getInt("group_id"));
                ctx.setTaskTitle(rs.getString("task_title"));
                ctx.setTaskDescription(rs.getString("task_description"));
                ctx.setDeadline(rs.getTimestamp("deadline"));

                ctx.setGroupName(rs.getString("group_name"));
                ctx.setFullName(rs.getString("full_name"));
                ctx.setUsername(rs.getString("username"));

                rs.close();
                ps.close();
                conn.close();

                return ctx;
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public int insertEvaluation(SubmissionContext ctx, AIEvaluationResult result) {
        String sql = "INSERT INTO AI_EVALUATIONS " +
                     "(submission_id, task_id, user_id, ai_star, converted_point, summary, strengths, weaknesses, raw_response) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String weaknessesFull =
                "Weaknesses: " + safe(result.getWeaknesses()) +
                "\nMissing requirements: " + safe(result.getMissingRequirements()) +
                "\nEvidence: " + safe(result.getEvidence());

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            ps.setInt(1, ctx.getSubmissionId());
            ps.setInt(2, ctx.getTaskId());
            ps.setInt(3, ctx.getUserId());
            ps.setInt(4, result.getAiStar());
            ps.setInt(5, result.getConvertedPoint());
            ps.setString(6, result.getSummary());
            ps.setString(7, result.getStrengths());
            ps.setString(8, weaknessesFull);
            ps.setString(9, result.getRawResponse());

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();

            int newId = -1;

            if (rs.next()) {
                newId = rs.getInt(1);
            }

            rs.close();
            ps.close();
            conn.close();

            return newId;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    public Integer getBestAiStarByTaskAndUser(int taskId, int userId) {
        String sql = "SELECT MAX(ai_star) AS best_star FROM AI_EVALUATIONS WHERE task_id = ? AND user_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, taskId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();

            Integer bestStar = null;

            if (rs.next()) {
                Object value = rs.getObject("best_star");

                if (value != null) {
                    bestStar = rs.getInt("best_star");
                }
            }

            rs.close();
            ps.close();
            conn.close();

            return bestStar;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}