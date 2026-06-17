package controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import dao.AIEvaluationDAO;
import dao.GroupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.AIEvaluationResult;
import model.SubmissionContext;
import model.User;
import service.LLMService;

@WebServlet("/EvaluateSubmissionServlet")
public class EvaluateSubmissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final Gson gson = new Gson();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        JsonObject json = new JsonObject();

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("loginedUser");

        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Bạn chưa đăng nhập.");
            response.getWriter().write(gson.toJson(json));
            return;
        }

        String submissionIdRaw = request.getParameter("submissionId");

        int submissionId;

        try {
            submissionId = Integer.parseInt(submissionIdRaw);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "submissionId không hợp lệ.");
            response.getWriter().write(gson.toJson(json));
            return;
        }

        try {
            AIEvaluationDAO aiDAO = new AIEvaluationDAO();
            SubmissionContext ctx = aiDAO.getSubmissionContext(submissionId);

            if (ctx == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                json.addProperty("success", false);
                json.addProperty("message", "Không tìm thấy bài nộp.");
                response.getWriter().write(gson.toJson(json));
                return;
            }

            GroupDAO groupDAO = new GroupDAO();

            boolean isOwner = currentUser.getUserId() == ctx.getUserId();
            boolean isLeader = groupDAO.isLeader(currentUser.getUserId(), ctx.getGroupId());

            if (!isOwner && !isLeader) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                json.addProperty("success", false);
                json.addProperty("message", "Bạn không có quyền chấm bài nộp này.");
                response.getWriter().write(gson.toJson(json));
                return;
            }

            String fileContent = readSubmissionFile(ctx.getFilePath());

            LLMService llmService = new LLMService();
            AIEvaluationResult result = llmService.evaluateSubmission(ctx, fileContent);

            int evaluationId = aiDAO.insertEvaluation(ctx, result);

            if (evaluationId <= 0) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.addProperty("success", false);
                json.addProperty("message", "AI đã chấm nhưng lưu database thất bại.");
                response.getWriter().write(gson.toJson(json));
                return;
            }

            json.addProperty("success", true);
            json.addProperty("message", "AI đã chấm bài thành công.");
            json.addProperty("evaluationId", evaluationId);
            json.addProperty("submissionId", ctx.getSubmissionId());
            json.addProperty("taskId", ctx.getTaskId());
            json.addProperty("userId", ctx.getUserId());
            json.addProperty("aiStar", result.getAiStar());
            json.addProperty("convertedPoint", result.getConvertedPoint());
            json.addProperty("summary", result.getSummary());
            json.addProperty("strengths", result.getStrengths());
            json.addProperty("weaknesses", result.getWeaknesses());
            json.addProperty("missingRequirements", result.getMissingRequirements());
            json.addProperty("evidence", result.getEvidence());

            response.getWriter().write(gson.toJson(json));

        } catch (Exception e) {
            e.printStackTrace();

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            json.addProperty("success", false);
            json.addProperty("message", e.getMessage());

            response.getWriter().write(gson.toJson(json));
        }
    }

    private String readSubmissionFile(String filePath) throws IOException {
        Path path = Path.of(filePath);

        if (!path.isAbsolute()) {
            String rootPath = getServletContext().getRealPath("/");
            path = Path.of(rootPath).resolve(filePath).normalize();
        }

        if (!Files.exists(path)) {
            throw new IOException("Không tìm thấy file bài nộp: " + path);
        }

        long fileSize = Files.size(path);

        if (fileSize > 2_000_000) {
            throw new IOException("File quá lớn. Bản đầu chỉ hỗ trợ file text/code dưới 2MB.");
        }

        return Files.readString(path, StandardCharsets.UTF_8);
    }
}