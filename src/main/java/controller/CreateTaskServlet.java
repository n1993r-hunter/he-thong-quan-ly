package controller;

import java.io.IOException;

import dao.ActivityLogDAO;
import dao.GroupDAO;
import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet("/CreateTaskServlet")
public class CreateTaskServlet extends HttpServlet {
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

            GroupDAO groupDAO = new GroupDAO();

            if (!groupDAO.isLeader(currentUser.getUserId(), groupId)) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=not_leader");
                return;
            }

            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String deadlineRaw = request.getParameter("deadline");
            String assigneeIdRaw = request.getParameter("assigneeId");

            if (title == null || title.trim().isEmpty()) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=task_title_empty");
                return;
            }

            String deadline = normalizeDeadline(deadlineRaw);

            if (deadline == null) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=deadline_empty");
                return;
            }

            TaskDAO taskDAO = new TaskDAO();

            int taskId = taskDAO.createTaskReturnId(
                    groupId,
                    title.trim(),
                    description,
                    currentUser.getUserId(),
                    deadline
            );

            if (taskId <= 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=task_fail");
                return;
            }

            if (assigneeIdRaw != null && !assigneeIdRaw.trim().isEmpty()) {
                int assigneeId = Integer.parseInt(assigneeIdRaw);
                taskDAO.assignTask(taskId, assigneeId);
            }

            ActivityLogDAO logDao = new ActivityLogDAO();
            logDao.logActivity(currentUser.getUserId(), groupId, taskId, "CREATED_TASK");

            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=task_created");

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=invalid_data");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=invalid_data");
            }
        }
    }

    private String normalizeDeadline(String deadlineRaw) {
        if (deadlineRaw == null || deadlineRaw.trim().isEmpty()) {
            return null;
        }

        String deadline = deadlineRaw.trim();

        if (deadline.contains("T")) {
            deadline = deadline.replace("T", " ");
        }

        if (deadline.length() == 16) {
            deadline += ":00";
        }

        if (deadline.length() == 10) {
            deadline += " 23:59:00";
        }

        return deadline;
    }
}