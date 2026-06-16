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

@WebServlet("/KickMemberServlet")
public class KickMemberServlet extends HttpServlet {
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
        String userIdRaw = request.getParameter("userId");

        int groupId;
        int userIdToKick;

        try {
            groupId = Integer.parseInt(groupIdRaw);
            userIdToKick = Integer.parseInt(userIdRaw);
        } catch (Exception e) {
            response.sendRedirect("MyGroupsServlet");
            return;
        }

        if (currentUser.getUserId() == userIdToKick) {
            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=cannot_kick_self");
            return;
        }

        GroupDAO dao = new GroupDAO();

        boolean success = dao.kickMemberFromGroup(groupId, userIdToKick, currentUser.getUserId());

        if (success) {
            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=kick_success");
        } else {
            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=kick_fail");
        }
    }
}