
package dao;
import java.util.ArrayList;
import java.util.List;
import model.StockHistoryView;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.sql.Timestamp;
import model.CoinRankingView;
import model.MemberStock;
import utils.DBConnection;

public class StockDAO {

    // Lấy tên nhóm theo group_id
    public String getGroupNameById(int groupId) {
        String groupName = null;

        String sql = "SELECT group_name FROM `GROUPS` WHERE group_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, groupId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                groupName = rs.getString("group_name");
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return groupName;
    }

    // Lấy danh sách thành viên + stock trong nhóm, sắp xếp theo current_price giảm dần
    public List<MemberStock> getMemberStocksByGroupId(int groupId) {
        List<MemberStock> list = new ArrayList<>();

        String sql = "SELECT " +
                     "u.user_id, " +
                     "u.full_name, " +
                     "u.username, " +
                     "gm.group_id, " +
                     "gm.role, " +
                     "s.stock_code, " +
                     "s.current_price " +
                     "FROM GROUP_MEMBERS gm " +
                     "JOIN USERS u ON gm.user_id = u.user_id " +
                     "LEFT JOIN STOCKS s ON s.user_id = gm.user_id AND s.group_id = gm.group_id " +
                     "WHERE gm.group_id = ? " +
                     "ORDER BY s.current_price DESC";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, groupId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                MemberStock member = new MemberStock();

                member.setUserId(rs.getInt("user_id"));
                member.setFullName(rs.getString("full_name"));
                member.setUsername(rs.getString("username"));
                member.setGroupId(rs.getInt("group_id"));
                member.setRole(rs.getString("role"));
                member.setStockCode(rs.getString("stock_code"));
                member.setCurrentPrice(rs.getFloat("current_price"));

                list.add(member);
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public List<StockHistoryView> getStockHistoryByGroupId(int groupId) {
        List<StockHistoryView> list = new ArrayList<>();

        String sql =
                "SELECT " +
                "h.history_id, h.stock_id, h.task_id, h.source_type, " +
                "h.price_before, h.price_after, h.price_change, h.change_reason, h.recorded_at, " +
                "s.user_id, s.stock_code, " +
                "u.full_name, u.username " +
                "FROM STOCK_PRICE_HISTORY h " +
                "JOIN STOCKS s ON h.stock_id = s.stock_id " +
                "JOIN USERS u ON s.user_id = u.user_id " +
                "WHERE s.group_id = ? " +
                "ORDER BY h.recorded_at ASC, h.history_id ASC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, groupId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        StockHistoryView view = new StockHistoryView();

                        view.setHistoryId(rs.getInt("history_id"));
                        view.setStockId(rs.getInt("stock_id"));
                        view.setUserId(rs.getInt("user_id"));
                        view.setStockCode(rs.getString("stock_code"));

                        int taskId = rs.getInt("task_id");
                        if (!rs.wasNull()) {
                            view.setTaskId(taskId);
                        }

                        view.setSourceType(rs.getString("source_type"));
                        view.setPriceBefore(rs.getDouble("price_before"));
                        view.setPriceAfter(rs.getDouble("price_after"));
                        view.setPriceChange(rs.getDouble("price_change"));
                        view.setChangeReason(rs.getString("change_reason"));
                        view.setRecordedAt(rs.getTimestamp("recorded_at"));

                        view.setFullName(rs.getString("full_name"));
                        view.setUsername(rs.getString("username"));

                        list.add(view);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public List<CoinRankingView> getCoinRankingAtTimeByGroupId(int groupId, Timestamp queryTime) {
        List<CoinRankingView> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();

        sql.append("SELECT ");
        sql.append("s.user_id, ");
        sql.append("u.full_name, ");
        sql.append("u.username, ");
        sql.append("s.stock_code, ");
        sql.append("s.current_price AS now_price, ");

        if (queryTime != null) {
            sql.append("COALESCE(( ");
            sql.append("    SELECT h.price_after ");
            sql.append("    FROM STOCK_PRICE_HISTORY h ");
            sql.append("    WHERE h.stock_id = s.stock_id ");
            sql.append("    AND h.recorded_at <= ? ");
            sql.append("    ORDER BY h.recorded_at DESC, h.history_id DESC ");
            sql.append("    LIMIT 1 ");
            sql.append("), 100) AS price_at_time, ");

            sql.append("( ");
            sql.append("    SELECT COUNT(*) ");
            sql.append("    FROM STOCK_PRICE_HISTORY h2 ");
            sql.append("    WHERE h2.stock_id = s.stock_id ");
            sql.append("    AND h2.recorded_at <= ? ");
            sql.append(") AS change_count ");

        } else {
            sql.append("s.current_price AS price_at_time, ");
            sql.append("( ");
            sql.append("    SELECT COUNT(*) ");
            sql.append("    FROM STOCK_PRICE_HISTORY h2 ");
            sql.append("    WHERE h2.stock_id = s.stock_id ");
            sql.append(") AS change_count ");
        }

        sql.append("FROM STOCKS s ");
        sql.append("JOIN USERS u ON s.user_id = u.user_id ");
        sql.append("JOIN GROUP_MEMBERS gm ON gm.group_id = s.group_id AND gm.user_id = s.user_id ");
        sql.append("WHERE s.group_id = ? ");

        if (queryTime != null) {
            sql.append("AND gm.joined_at <= ? ");
        }

        sql.append("ORDER BY price_at_time DESC, u.full_name ASC");

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                return list;
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int index = 1;

                if (queryTime != null) {
                    ps.setTimestamp(index++, queryTime);
                    ps.setTimestamp(index++, queryTime);
                }

                ps.setInt(index++, groupId);

                if (queryTime != null) {
                    ps.setTimestamp(index++, queryTime);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    int rank = 1;

                    while (rs.next()) {
                        double nowPrice = rs.getDouble("now_price");
                        double priceAtTime = rs.getDouble("price_at_time");

                        CoinRankingView view = new CoinRankingView();

                        view.setRank(rank++);
                        view.setUserId(rs.getInt("user_id"));
                        view.setFullName(rs.getString("full_name"));
                        view.setUsername(rs.getString("username"));
                        view.setStockCode(rs.getString("stock_code"));

                        // Ở chức năng này, currentPrice dùng để hiển thị coin tại thời điểm được truy vấn
                        view.setCurrentPrice(priceAtTime);

                        // periodChange dùng để hiển thị chênh lệch giữa hiện tại và thời điểm đó
                        view.setPeriodChange(nowPrice - priceAtTime);

                        view.setChangeCount(rs.getInt("change_count"));

                        list.add(view);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}