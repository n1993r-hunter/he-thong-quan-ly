
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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
}