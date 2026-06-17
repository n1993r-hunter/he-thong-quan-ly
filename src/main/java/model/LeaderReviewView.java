package model;

import java.sql.Timestamp;

public class LeaderReviewView {
    private int leaderReviewId;

    private int leaderId;
    private String leaderFullName;
    private String leaderUsername;

    private int reviewedUserId;
    private String reviewedFullName;
    private String reviewedUsername;

    private Integer taskId;
    private String taskTitle;

    private int groupId;
    private int star;
    private String comment;
    private Timestamp reviewTime;

    public int getLeaderReviewId() {
        return leaderReviewId;
    }

    public void setLeaderReviewId(int leaderReviewId) {
        this.leaderReviewId = leaderReviewId;
    }

    public int getLeaderId() {
        return leaderId;
    }

    public void setLeaderId(int leaderId) {
        this.leaderId = leaderId;
    }

    public String getLeaderFullName() {
        return leaderFullName;
    }

    public void setLeaderFullName(String leaderFullName) {
        this.leaderFullName = leaderFullName;
    }

    public String getLeaderUsername() {
        return leaderUsername;
    }

    public void setLeaderUsername(String leaderUsername) {
        this.leaderUsername = leaderUsername;
    }

    public int getReviewedUserId() {
        return reviewedUserId;
    }

    public void setReviewedUserId(int reviewedUserId) {
        this.reviewedUserId = reviewedUserId;
    }

    public String getReviewedFullName() {
        return reviewedFullName;
    }

    public void setReviewedFullName(String reviewedFullName) {
        this.reviewedFullName = reviewedFullName;
    }

    public String getReviewedUsername() {
        return reviewedUsername;
    }

    public void setReviewedUsername(String reviewedUsername) {
        this.reviewedUsername = reviewedUsername;
    }

    public Integer getTaskId() {
        return taskId;
    }

    public void setTaskId(Integer taskId) {
        this.taskId = taskId;
    }

    public String getTaskTitle() {
        return taskTitle;
    }

    public void setTaskTitle(String taskTitle) {
        this.taskTitle = taskTitle;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public int getStar() {
        return star;
    }

    public void setStar(int star) {
        this.star = star;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getReviewTime() {
        return reviewTime;
    }

    public void setReviewTime(Timestamp reviewTime) {
        this.reviewTime = reviewTime;
    }
}