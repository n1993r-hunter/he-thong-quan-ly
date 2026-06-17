package model;

import java.sql.Timestamp;

public class TaskSubmissionView {
    private int assignmentId;
    private int taskId;
    private int groupId;

    private int assigneeUserId;
    private String assigneeFullName;
    private String assigneeUsername;

    private String title;
    private String description;
    private Timestamp deadline;
    private String assignmentStatus;
    private int progress;

    private Integer submissionId;
    private String fileName;
    private String filePath;
    private Integer submitVersion;
    private Timestamp submittedAt;

    private Integer aiEvaluationId;
    private Integer aiStar;
    private Integer convertedPoint;
    private String aiSummary;
    private String aiStrengths;
    private String aiWeaknesses;
    private String rawResponse;
    private Timestamp evaluatedAt;

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public int getAssigneeUserId() {
        return assigneeUserId;
    }

    public void setAssigneeUserId(int assigneeUserId) {
        this.assigneeUserId = assigneeUserId;
    }

    public String getAssigneeFullName() {
        return assigneeFullName;
    }

    public void setAssigneeFullName(String assigneeFullName) {
        this.assigneeFullName = assigneeFullName;
    }

    public String getAssigneeUsername() {
        return assigneeUsername;
    }

    public void setAssigneeUsername(String assigneeUsername) {
        this.assigneeUsername = assigneeUsername;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getDeadline() {
        return deadline;
    }

    public void setDeadline(Timestamp deadline) {
        this.deadline = deadline;
    }

    public String getAssignmentStatus() {
        return assignmentStatus;
    }

    public void setAssignmentStatus(String assignmentStatus) {
        this.assignmentStatus = assignmentStatus;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public Integer getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(Integer submissionId) {
        this.submissionId = submissionId;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Integer getSubmitVersion() {
        return submitVersion;
    }

    public void setSubmitVersion(Integer submitVersion) {
        this.submitVersion = submitVersion;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }

    public Integer getAiEvaluationId() {
        return aiEvaluationId;
    }

    public void setAiEvaluationId(Integer aiEvaluationId) {
        this.aiEvaluationId = aiEvaluationId;
    }

    public Integer getAiStar() {
        return aiStar;
    }

    public void setAiStar(Integer aiStar) {
        this.aiStar = aiStar;
    }

    public Integer getConvertedPoint() {
        return convertedPoint;
    }

    public void setConvertedPoint(Integer convertedPoint) {
        this.convertedPoint = convertedPoint;
    }

    public String getAiSummary() {
        return aiSummary;
    }

    public void setAiSummary(String aiSummary) {
        this.aiSummary = aiSummary;
    }

    public String getAiStrengths() {
        return aiStrengths;
    }

    public void setAiStrengths(String aiStrengths) {
        this.aiStrengths = aiStrengths;
    }

    public String getAiWeaknesses() {
        return aiWeaknesses;
    }

    public void setAiWeaknesses(String aiWeaknesses) {
        this.aiWeaknesses = aiWeaknesses;
    }

    public String getRawResponse() {
        return rawResponse;
    }

    public void setRawResponse(String rawResponse) {
        this.rawResponse = rawResponse;
    }

    public Timestamp getEvaluatedAt() {
        return evaluatedAt;
    }

    public void setEvaluatedAt(Timestamp evaluatedAt) {
        this.evaluatedAt = evaluatedAt;
    }
}