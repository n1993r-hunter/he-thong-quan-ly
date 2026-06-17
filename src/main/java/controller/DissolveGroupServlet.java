package controller;

import java.io.IOException;

import dao.GroupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/DissolveGroupServlet")
public class DissolveGroupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loginedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("loginedUser");

        String rawGroupId = request.getParameter("groupId");

        if (rawGroupId == null || rawGroupId.trim().isEmpty()) {
            response.sendRedirect("MyGroupsServlet?msg=missing_group_id");
            return;
        }

        int groupId;

        try {
            groupId = Integer.parseInt(rawGroupId);
        } catch (NumberFormatException e) {
            response.sendRedirect("MyGroupsServlet?msg=invalid_group_id");
            return;
        }

        GroupDAO groupDAO = new GroupDAO();

        boolean success = groupDAO.dissolveGroup(groupId, currentUser.getUserId());

        if (success) {
            response.sendRedirect("MyGroupsServlet?msg=group_dissolved");
        } else {
            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=dissolve_failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("MyGroupsServlet");
    }
}