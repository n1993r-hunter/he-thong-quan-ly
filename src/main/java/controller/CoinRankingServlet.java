package controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;

import dao.GroupDAO;
import dao.StockDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CoinRankingView;
import model.User;

@WebServlet("/CoinRankingServlet")
public class CoinRankingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loginedUser") == null) {
            result.put("success", false);
            result.put("message", "Bạn chưa đăng nhập.");
            new Gson().toJson(result, response.getWriter());
            return;
        }

        User currentUser = (User) session.getAttribute("loginedUser");

        String rawGroupId = request.getParameter("groupId");
        String rawQueryTime = request.getParameter("queryTime");

        if (rawGroupId == null || rawGroupId.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Thiếu groupId.");
            new Gson().toJson(result, response.getWriter());
            return;
        }

        int groupId;

        try {
            groupId = Integer.parseInt(rawGroupId);
        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("message", "groupId không hợp lệ.");
            new Gson().toJson(result, response.getWriter());
            return;
        }

        GroupDAO groupDAO = new GroupDAO();

        if (!groupDAO.isLeader(currentUser.getUserId(), groupId)) {
            result.put("success", false);
            result.put("message", "Chỉ nhóm trưởng mới được xem bảng xếp hạng coin.");
            new Gson().toJson(result, response.getWriter());
            return;
        }

        Timestamp queryTime = parseDateTime(rawQueryTime);

        StockDAO stockDAO = new StockDAO();
        List<CoinRankingView> ranking = stockDAO.getCoinRankingAtTimeByGroupId(groupId, queryTime);

        result.put("success", true);
        result.put("ranking", ranking);
        result.put("queryTime", rawQueryTime);

        new Gson().toJson(result, response.getWriter());
    }

    private Timestamp parseDateTime(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            String normalized = value.trim().replace("T", " ");

            if (normalized.length() == 16) {
                normalized = normalized + ":00";
            }

            return Timestamp.valueOf(normalized);

        } catch (Exception e) {
            return null;
        }
    }
}