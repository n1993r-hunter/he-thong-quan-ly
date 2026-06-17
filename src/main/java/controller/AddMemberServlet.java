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

@WebServlet("/AddMemberServlet")
public class AddMemberServlet extends HttpServlet {
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

        int groupId = -1;

        try {
            groupId = Integer.parseInt(request.getParameter("groupId"));
            String username = request.getParameter("username");

            if (username == null || username.trim().isEmpty()) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=username_empty");
                return;
            }

            GroupDAO dao = new GroupDAO();

            if (!dao.isLeader(currentUser.getUserId(), groupId)) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=not_leader");
                return;
            }

            boolean success = dao.addMemberToGroup(groupId, username.trim());

            if (success) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=add_member_success");
            } else {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=add_member_fail");
            }

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=add_member_error");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=add_member_error");
            }
        }
    }
}