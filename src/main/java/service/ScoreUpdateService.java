package service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import utils.DBConnection;

public class ScoreUpdateService {

    public boolean recalculateTaskScore(int taskId, int userId, int groupId, String sourceType, String reason) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            Integer assignmentId = getAssignmentId(conn, taskId, userId);

            if (assignmentId == null) {
                conn.rollback();
                return false;
            }

            double oldStockChange = getOldStockChange(conn, assignmentId);

            Double bestAiStar = getBestAiStar(conn, taskId, userId);
            Double avgPeerStar = getAveragePeerStar(conn, taskId, userId, groupId);
            Double leaderStar = getLeaderStar(conn, taskId, userId, groupId);

            double aiWeight = getWeight(conn, "ai", 0.4);
            double peerWeight = getWeight(conn, "peer", 0.3);
            double leaderWeight = getWeight(conn, "leader", 0.3);

            double aiPoint = bestAiStar == null ? 0 : starToPoint(conn, bestAiStar);
            double peerPoint = avgPeerStar == null ? 0 : starToPoint(conn, avgPeerStar);
            double leaderPoint = leaderStar == null ? 0 : starToPoint(conn, leaderStar);

            double weightedTotal = 0;
            double availableWeight = 0;

            if (bestAiStar != null) {
                weightedTotal += aiPoint * aiWeight;
                availableWeight += aiWeight;
            }

            if (avgPeerStar != null) {
                weightedTotal += peerPoint * peerWeight;
                availableWeight += peerWeight;
            }

            if (leaderStar != null) {
                weightedTotal += leaderPoint * leaderWeight;
                availableWeight += leaderWeight;
            }

            double newStockChange = 0;

            if (availableWeight > 0) {
                newStockChange = weightedTotal / availableWeight;
            }

            double delta = newStockChange - oldStockChange;

            upsertTaskScoreSummary(
                    conn,
                    assignmentId,
                    taskId,
                    userId,
                    groupId,
                    bestAiStar,
                    avgPeerStar,
                    leaderStar,
                    aiPoint,
                    peerPoint,
                    leaderPoint,
                    newStockChange
            );

            if (Math.abs(delta) >= 0.0001) {
                StockSnapshot stock = getOrCreateStock(conn, userId, groupId);

                double priceBefore = stock.currentPrice;
                double priceAfter = priceBefore + delta;

                if (priceAfter < 0) {
                    priceAfter = 0;
                }

                double realChange = priceAfter - priceBefore;

                updateStockPrice(conn, stock.stockId, priceAfter);
                insertStockHistory(
                        conn,
                        stock.stockId,
                        taskId,
                        sourceType,
                        priceBefore,
                        priceAfter,
                        realChange,
                        reason
                );
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

    private Integer getAssignmentId(Connection conn, int taskId, int userId) throws Exception {
        String sql =
                "SELECT assignment_id " +
                "FROM TASK_ASSIGNMENTS " +
                "WHERE task_id = ? AND user_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("assignment_id");
                }
            }
        }

        return null;
    }

    private double getOldStockChange(Connection conn, int assignmentId) throws Exception {
        String sql =
                "SELECT stock_change " +
                "FROM TASK_SCORE_SUMMARY " +
                "WHERE assignment_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("stock_change");
                }
            }
        }

        return 0;
    }

    private Double getBestAiStar(Connection conn, int taskId, int userId) throws Exception {
        String sql =
                "SELECT MAX(ai_star) AS value " +
                "FROM AI_EVALUATIONS " +
                "WHERE task_id = ? AND user_id = ?";

        return getNullableDouble(conn, sql, taskId, userId);
    }

    private Double getAveragePeerStar(Connection conn, int taskId, int userId, int groupId) throws Exception {
        String sql =
                "SELECT AVG(star) AS value " +
                "FROM PEER_REVIEWS " +
                "WHERE task_id = ? AND reviewed_user_id = ? AND group_id = ?";

        return getNullableDouble(conn, sql, taskId, userId, groupId);
    }

    private Double getLeaderStar(Connection conn, int taskId, int userId, int groupId) throws Exception {
        String sql =
                "SELECT star AS value " +
                "FROM LEADER_REVIEWS " +
                "WHERE task_id = ? AND reviewed_user_id = ? AND group_id = ? " +
                "ORDER BY review_time DESC " +
                "LIMIT 1";

        return getNullableDouble(conn, sql, taskId, userId, groupId);
    }

    private Double getNullableDouble(Connection conn, String sql, Object... params) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double value = rs.getDouble("value");

                    if (rs.wasNull()) {
                        return null;
                    }

                    return value;
                }
            }
        }

        return null;
    }

    private double getWeight(Connection conn, String component, double defaultValue) throws Exception {
        String sql =
                "SELECT weight " +
                "FROM SCORING_WEIGHTS " +
                "WHERE component = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, component);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("weight");
                }
            }
        }

        return defaultValue;
    }

    private double starToPoint(Connection conn, Double star) throws Exception {
        if (star == null) {
            return 0;
        }

        int starLevel = (int) Math.round(star);

        if (starLevel < 1) {
            starLevel = 1;
        }

        if (starLevel > 5) {
            starLevel = 5;
        }

        String sql =
                "SELECT score_change " +
                "FROM REWARD_PENALTY_RULES " +
                "WHERE star_level = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, starLevel);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("score_change");
                }
            }
        }

        switch (starLevel) {
            case 5:
                return 20;
            case 4:
                return 10;
            case 3:
                return 0;
            case 2:
                return -10;
            case 1:
                return -20;
            default:
                return 0;
        }
    }

    private void upsertTaskScoreSummary(
            Connection conn,
            int assignmentId,
            int taskId,
            int userId,
            int groupId,
            Double bestAiStar,
            Double avgPeerStar,
            Double leaderStar,
            double aiPoint,
            double peerPoint,
            double leaderPoint,
            double stockChange
    ) throws Exception {

        String sql =
                "INSERT INTO TASK_SCORE_SUMMARY " +
                "(assignment_id, task_id, user_id, group_id, " +
                "best_ai_star, avg_peer_star, leader_star, " +
                "ai_point, peer_point, leader_point, stock_change, calculated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP) " +
                "ON DUPLICATE KEY UPDATE " +
                "best_ai_star = VALUES(best_ai_star), " +
                "avg_peer_star = VALUES(avg_peer_star), " +
                "leader_star = VALUES(leader_star), " +
                "ai_point = VALUES(ai_point), " +
                "peer_point = VALUES(peer_point), " +
                "leader_point = VALUES(leader_point), " +
                "stock_change = VALUES(stock_change), " +
                "calculated_at = CURRENT_TIMESTAMP";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, taskId);
            ps.setInt(3, userId);
            ps.setInt(4, groupId);

            setNullableDouble(ps, 5, bestAiStar);
            setNullableDouble(ps, 6, avgPeerStar);
            setNullableDouble(ps, 7, leaderStar);

            ps.setDouble(8, aiPoint);
            ps.setDouble(9, peerPoint);
            ps.setDouble(10, leaderPoint);
            ps.setDouble(11, stockChange);

            ps.executeUpdate();
        }
    }

    private StockSnapshot getOrCreateStock(Connection conn, int userId, int groupId) throws Exception {
        String selectSql =
                "SELECT stock_id, current_price " +
                "FROM STOCKS " +
                "WHERE user_id = ? AND group_id = ? " +
                "FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StockSnapshot stock = new StockSnapshot();
                    stock.stockId = rs.getInt("stock_id");
                    stock.currentPrice = rs.getDouble("current_price");
                    return stock;
                }
            }
        }

        String stockCode = "U" + userId + "G" + groupId;

        String insertSql =
                "INSERT INTO STOCKS (user_id, group_id, stock_code, current_price) " +
                "VALUES (?, ?, ?, 100)";

        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, groupId);
            ps.setString(3, stockCode);

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    StockSnapshot stock = new StockSnapshot();
                    stock.stockId = keys.getInt(1);
                    stock.currentPrice = 100;
                    return stock;
                }
            }
        }

        throw new IllegalStateException("Không thể tạo stock cho userId=" + userId + ", groupId=" + groupId);
    }

    private void updateStockPrice(Connection conn, int stockId, double priceAfter) throws Exception {
        String sql =
                "UPDATE STOCKS " +
                "SET current_price = ?, last_updated = CURRENT_TIMESTAMP " +
                "WHERE stock_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, priceAfter);
            ps.setInt(2, stockId);
            ps.executeUpdate();
        }
    }

    private void insertStockHistory(
            Connection conn,
            int stockId,
            int taskId,
            String sourceType,
            double priceBefore,
            double priceAfter,
            double priceChange,
            String reason
    ) throws Exception {

        String sql =
                "INSERT INTO STOCK_PRICE_HISTORY " +
                "(stock_id, task_id, source_type, price_before, price_after, price_change, change_reason) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, stockId);
            ps.setInt(2, taskId);
            ps.setString(3, sourceType);
            ps.setDouble(4, priceBefore);
            ps.setDouble(5, priceAfter);
            ps.setDouble(6, priceChange);
            ps.setString(7, reason);

            ps.executeUpdate();
        }
    }

    private void setParams(PreparedStatement ps, Object... params) throws Exception {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }

    private void setNullableDouble(PreparedStatement ps, int index, Double value) throws Exception {
        if (value == null) {
            ps.setNull(index, java.sql.Types.DOUBLE);
        } else {
            ps.setDouble(index, value);
        }
    }

    private static class StockSnapshot {
        int stockId;
        double currentPrice;
    }
}