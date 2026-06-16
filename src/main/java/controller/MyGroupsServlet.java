package controller;

import java.io.IOException;
import java.util.List;

import dao.GroupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Group;
import model.User;

@WebServlet("/MyGroupsServlet")
public class MyGroupsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        GroupDAO dao = new GroupDAO();
        List<Group> groups = dao.getGroupsByUserId(currentUser.getUserId());

        request.setAttribute("groups", groups);
        request.getRequestDispatcher("my-groups.jsp").forward(request, response);
    }
}