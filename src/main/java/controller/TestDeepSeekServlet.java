package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.AIEvaluationResult;
import model.SubmissionContext;
import service.LLMService;

@WebServlet("/TestDeepSeekServlet")
public class TestDeepSeekServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            SubmissionContext ctx = new SubmissionContext();

            ctx.setSubmissionId(1);
            ctx.setAssignmentId(1);
            ctx.setTaskId(1);
            ctx.setUserId(1);
            ctx.setGroupId(1);

            ctx.setGroupName("Nhóm test hệ thống stock performance");
            ctx.setFullName("Nguyễn Văn A");
            ctx.setUsername("usera");

            ctx.setTaskTitle("Xây dựng chức năng upload file");
            ctx.setTaskDescription(
                    "Thành viên cần xây dựng chức năng upload file bài làm. " +
                    "Yêu cầu: có form upload, servlet xử lý file, lưu file_path, file_name, task_id, user_id vào database."
            );

            ctx.setDeadline(new Timestamp(System.currentTimeMillis() + 86400000));
            ctx.setFileName("UploadServlet.java");
            ctx.setFilePath("test/UploadServlet.java");
            ctx.setSubmitVersion(1);

            String fakeFileContent =
                    "package controller;\n\n" +
                    "public class UploadServlet {\n" +
                    "    // Demo code upload file\n" +
                    "    public void upload() {\n" +
                    "        System.out.println(\"Upload file and save information to database\");\n" +
                    "    }\n" +
                    "}\n";

            LLMService service = new LLMService();
            AIEvaluationResult result = service.evaluateSubmission(ctx, fakeFileContent);

            out.println("<h2>Test DeepSeek thành công</h2>");
            out.println("<p><b>AI Star:</b> " + result.getAiStar() + "</p>");
            out.println("<p><b>Converted Point by Java:</b> " + result.getConvertedPoint() + "</p>");
            out.println("<p><b>Summary:</b> " + escape(result.getSummary()) + "</p>");
            out.println("<p><b>Strengths:</b> " + escape(result.getStrengths()) + "</p>");
            out.println("<p><b>Weaknesses:</b> " + escape(result.getWeaknesses()) + "</p>");
            out.println("<p><b>Missing Requirements:</b> " + escape(result.getMissingRequirements()) + "</p>");
            out.println("<p><b>Evidence:</b> " + escape(result.getEvidence()) + "</p>");

        } catch (Exception e) {
            e.printStackTrace();

            out.println("<h2 style='color:red;'>Test DeepSeek thất bại</h2>");
            out.println("<pre>");
            out.println(escape(e.toString()));
            out.println("</pre>");
        }
    }

    private String escape(String text) {
        if (text == null) {
            return "";
        }

        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}