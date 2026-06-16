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
            response.sendRedirect("MyGroupsServlet");
            return;
        }

        GroupDAO dao = new GroupDAO();

        boolean success = dao.dissolveGroup(groupId, currentUser.getUserId());

        if (success) {
            response.sendRedirect("MyGroupsServlet?msg=group_deleted");
        } else {
            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=dissolve_fail");
        }
    }
}