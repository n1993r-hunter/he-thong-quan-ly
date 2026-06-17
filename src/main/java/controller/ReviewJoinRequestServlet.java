package controller;

import java.io.IOException;

import dao.GroupDAO;
import dao.JoinRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/ReviewJoinRequestServlet")
public class ReviewJoinRequestServlet extends HttpServlet {
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
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String action = request.getParameter("action");

            GroupDAO groupDAO = new GroupDAO();

            if (!groupDAO.isLeader(currentUser.getUserId(), groupId)) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=not_leader");
                return;
            }

            JoinRequestDAO joinDAO = new JoinRequestDAO();

            boolean success;

            if ("approve".equals(action)) {
                success = joinDAO.approveRequest(requestId, groupId, currentUser.getUserId());

                if (success) {
                    response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=join_approved");
                } else {
                    response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=join_approve_fail");
                }

                return;
            }

            if ("reject".equals(action)) {
                success = joinDAO.rejectRequest(requestId, groupId, currentUser.getUserId());

                if (success) {
                    response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=join_rejected");
                } else {
                    response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=join_reject_fail");
                }

                return;
            }

            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=invalid_action");

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=review_request_error");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=review_request_error");
            }
        }
    }
}