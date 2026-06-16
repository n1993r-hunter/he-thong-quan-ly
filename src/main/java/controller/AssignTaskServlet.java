package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import dao.TaskDAO;
import model.User;

@WebServlet("/AssignTaskServlet")
public class AssignTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // 1. Bảo mật
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Nhận dữ liệu
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            int assigneeId = Integer.parseInt(request.getParameter("assigneeId")); // ID của người được giao

            // 3. Gọi DAO
            TaskDAO dao = new TaskDAO();
            boolean isSuccess = dao.assignTask(taskId, assigneeId);

            // 4. Trả kết quả
            if (isSuccess) {
                response.sendRedirect("task_detail.jsp?taskId=" + taskId + "&msg=assign_success");
            } else {
                response.sendRedirect("task_detail.jsp?taskId=" + taskId + "&msg=assign_fail");
            }
        } catch (Exception e) {
            response.sendRedirect("index.jsp?msg=invalid_data");
        }
    }
}