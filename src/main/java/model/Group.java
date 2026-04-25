package model;

public class Group {
    private int groupId;
    private String groupName;
    private int createdBy;

    public Group() {}

    public Group(int groupId, String groupName, int createdBy) {
        this.groupId = groupId;
        this.groupName = groupName;
        this.createdBy = createdBy;
    }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}