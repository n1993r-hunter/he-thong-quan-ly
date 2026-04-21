package model;

public class User {
    private int userId;
    private String fullName;
    private String email;
    private String username;
    private String password;

    // Constructor rỗng
    public User() {
    }

    // Constructor đầy đủ
    public User(int userId, String fullName, String email, String username, String password) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.username = username;
        this.password = password;
    }

    // Các hàm Getter và Setter
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}