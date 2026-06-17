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

@WebServlet("/GroupServlet")
public class GroupServlet extends HttpServlet {
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

        String groupName = request.getParameter("groupName");

        if (groupName == null || groupName.trim().isEmpty()) {
            response.sendRedirect("MyGroupsServlet?msg=group_name_empty");
            return;
        }

        GroupDAO dao = new GroupDAO();
        boolean isSuccess = dao.createGroup(groupName.trim(), currentUser.getUserId());

        if (isSuccess) {
            response.sendRedirect("MyGroupsServlet?msg=group_created");
        } else {
            response.sendRedirect("MyGroupsServlet?msg=group_fail");
        }
    }
}