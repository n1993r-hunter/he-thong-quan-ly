package controller;

import java.io.IOException;

import service.ScoreUpdateService;
import dao.GroupDAO;
import dao.PeerReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/PeerReviewServlet")
public class PeerReviewServlet extends HttpServlet {
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
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=invalid_peer_star");
                return;
            }

            if (currentUser.getUserId() == reviewedUserId) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=cannot_review_self");
                return;
            }

            GroupDAO groupDAO = new GroupDAO();

            boolean reviewerInGroup = groupDAO.isUserInGroup(currentUser.getUserId(), groupId);
            boolean reviewedInGroup = groupDAO.isUserInGroup(reviewedUserId, groupId);

            if (!reviewerInGroup || !reviewedInGroup) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=peer_no_permission");
                return;
            }

            PeerReviewDAO dao = new PeerReviewDAO();

            boolean success = dao.upsertPeerReview(
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
                        "peer_review",
                        "Cập nhật điểm từ Peer Review"
                );

                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=peer_review_saved");
            } else {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=peer_review_fail");
            }

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=peer_review_error");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=peer_review_error");
            }
        }
    }
}