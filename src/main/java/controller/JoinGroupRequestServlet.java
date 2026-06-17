package controller;

import java.io.IOException;

import dao.JoinRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/JoinGroupRequestServlet")
public class JoinGroupRequestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String groupIdRaw = request.getParameter("groupId");

        int groupId;

        try {
            groupId = Integer.parseInt(groupIdRaw);
        } catch (Exception e) {
            response.sendRedirect("MyGroupsServlet?msg=invalid_group");
            return;
        }

        JoinRequestDAO dao = new JoinRequestDAO();

        String result = dao.sendJoinRequest(groupId, currentUser.getUserId());

        if ("sent".equals(result)) {
            response.sendRedirect("MyGroupsServlet?msg=join_sent");
        } else if ("group_not_found".equals(result)) {
            response.sendRedirect("MyGroupsServlet?msg=join_group_not_found");
        } else if ("already_member".equals(result)) {
            response.sendRedirect("MyGroupsServlet?msg=join_already_member");
        } else if ("already_pending".equals(result)) {
            response.sendRedirect("MyGroupsServlet?msg=join_already_pending");
        } else {
            response.sendRedirect("MyGroupsServlet?msg=join_fail");
        }
    }
}