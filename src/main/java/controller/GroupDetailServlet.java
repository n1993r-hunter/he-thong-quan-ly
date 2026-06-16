package controller;

import java.io.IOException;
import java.util.List;

import dao.GroupDAO;
import dao.StockDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.MemberStock;
import model.User;

@WebServlet("/GroupDetailServlet")
public class GroupDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String groupIdRaw = request.getParameter("groupId");

        if (groupIdRaw == null || groupIdRaw.trim().isEmpty()) {
            response.sendRedirect("MyGroupsServlet");
            return;
        }

        int groupId;

        try {
            groupId = Integer.parseInt(groupIdRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect("MyGroupsServlet");
            return;
        }

        GroupDAO groupDAO = new GroupDAO();

        boolean isMember = groupDAO.isUserInGroup(currentUser.getUserId(), groupId);

        if (!isMember) {
            response.sendRedirect("MyGroupsServlet?msg=no_permission");
            return;
        }

        boolean isLeader = groupDAO.isLeader(currentUser.getUserId(), groupId);

        StockDAO stockDAO = new StockDAO();

        String groupName = stockDAO.getGroupNameById(groupId);
        List<MemberStock> members = stockDAO.getMemberStocksByGroupId(groupId);

        request.setAttribute("groupId", groupId);
        request.setAttribute("groupName", groupName);
        request.setAttribute("members", members);
        request.setAttribute("isLeader", isLeader);
        request.setAttribute("currentUserId", currentUser.getUserId());

        request.getRequestDispatcher("group-detail.jsp").forward(request, response);
    }
}