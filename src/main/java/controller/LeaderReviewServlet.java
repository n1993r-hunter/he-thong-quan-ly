package controller;

import java.io.IOException;

import service.ScoreUpdateService;
import dao.GroupDAO;
import dao.LeaderReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/LeaderReviewServlet")
public class LeaderReviewServlet extends HttpServlet {
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
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            int reviewedUserId = Integer.parseInt(request.getParameter("reviewedUserId"));
            int star = Integer.parseInt(request.getParameter("star"));
            String comment = request.getParameter("comment");

            if (star < 1 || star > 5) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=invalid_leader_star");
                return;
            }

            if (currentUser.getUserId() == reviewedUserId) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=cannot_leader_review_self");
                return;
            }

            GroupDAO groupDAO = new GroupDAO();

            boolean isLeader = groupDAO.isLeader(currentUser.getUserId(), groupId);

            if (!isLeader) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=not_leader");
                return;
            }

            boolean reviewedInGroup = groupDAO.isUserInGroup(reviewedUserId, groupId);

            if (!reviewedInGroup) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=reviewed_user_not_in_group");
                return;
            }

            LeaderReviewDAO dao = new LeaderReviewDAO();

            boolean success = dao.upsertLeaderReview(
                    currentUser.getUserId(),
                    reviewedUserId,
                    taskId,
                    groupId,
                    star,
                    comment
            );

            if (success) {
                ScoreUpdateService scoreService = new ScoreUpdateService();

                scoreService.recalculateTaskScore(
                        taskId,
                        reviewedUserId,
                        groupId,
                        "leader_review",
                        "Cập nhật điểm từ Leader Review"
                );

                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=leader_review_saved");
            } else {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=leader_review_fail");
            }

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=leader_review_error");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=leader_review_error");
            }
        }
    }
}