package controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.TaskSubmissionView;
import model.User;

@WebServlet("/SubmitTaskServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2 * 1024 * 1024,
        maxRequestSize = 3 * 1024 * 1024
)
public class SubmitTaskServlet extends HttpServlet {
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
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));

            TaskDAO taskDAO = new TaskDAO();
            TaskSubmissionView assignment = taskDAO.getAssignmentForUpload(assignmentId);

            if (assignment == null) {
                response.sendRedirect("MyGroupsServlet?msg=assignment_not_found");
                return;
            }

            groupId = assignment.getGroupId();

            if (assignment.getAssigneeUserId() != currentUser.getUserId()) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=not_task_owner");
                return;
            }

            Part filePart = request.getPart("submissionFile");

            if (filePart == null || filePart.getSize() <= 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=file_empty");
                return;
            }

            String originalFileName = getSafeFileName(filePart);

            if (!isAllowedTextFile(originalFileName)) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=file_type_not_allowed");
                return;
            }

            String storedFileName = System.currentTimeMillis()
                    + "_"
                    + UUID.randomUUID().toString().substring(0, 8)
                    + "_"
                    + originalFileName;

            String rootPath = getServletContext().getRealPath("/");

            Path uploadDir;
            String dbFilePath;

            if (rootPath != null) {
                uploadDir = Path.of(
                        rootPath,
                        "uploads",
                        "submissions",
                        "group_" + groupId,
                        "task_" + assignment.getTaskId(),
                        "user_" + currentUser.getUserId()
                );

                dbFilePath =
                        "uploads/submissions/group_" + groupId
                        + "/task_" + assignment.getTaskId()
                        + "/user_" + currentUser.getUserId()
                        + "/" + storedFileName;
            } else {
                uploadDir = Path.of(
                        System.getProperty("user.home"),
                        "hethongquanly_uploads",
                        "group_" + groupId,
                        "task_" + assignment.getTaskId(),
                        "user_" + currentUser.getUserId()
                );

                dbFilePath = uploadDir.resolve(storedFileName).toString();
            }

            Files.createDirectories(uploadDir);

            Path targetFile = uploadDir.resolve(storedFileName);

            Files.copy(filePart.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);

            String fileType = filePart.getContentType();

            int submissionId = taskDAO.insertTaskSubmission(
                    assignment.getAssignmentId(),
                    currentUser.getUserId(),
                    assignment.getTaskId(),
                    originalFileName,
                    dbFilePath,
                    fileType
            );

            if (submissionId <= 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=submission_save_fail");
                return;
            }

            response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=submission_uploaded");

        } catch (Exception e) {
            e.printStackTrace();

            if (groupId > 0) {
                response.sendRedirect("GroupDetailServlet?groupId=" + groupId + "&msg=submit_fail");
            } else {
                response.sendRedirect("MyGroupsServlet?msg=submit_fail");
            }
        }
    }

    private String getSafeFileName(Part part) {
        String submittedFileName = part.getSubmittedFileName();

        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            return "submission.txt";
        }

        String fileName = Path.of(submittedFileName).getFileName().toString();

        return fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    private boolean isAllowedTextFile(String fileName) {
        String lower = fileName.toLowerCase();

        return lower.endsWith(".txt")
                || lower.endsWith(".java")
                || lower.endsWith(".jsp")
                || lower.endsWith(".html")
                || lower.endsWith(".css")
                || lower.endsWith(".js")
                || lower.endsWith(".sql")
                || lower.endsWith(".xml")
                || lower.endsWith(".json")
                || lower.endsWith(".md")
                || lower.endsWith(".properties");
    }
}