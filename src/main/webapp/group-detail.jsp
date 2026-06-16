<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.MemberStock" %>

<%
    String groupName = (String) request.getAttribute("groupName");
    Integer groupId = (Integer) request.getAttribute("groupId");
    Integer currentUserId = (Integer) request.getAttribute("currentUserId");

    Boolean isLeaderObj = (Boolean) request.getAttribute("isLeader");
    boolean isLeader = isLeaderObj != null && isLeaderObj.booleanValue();

    String msg = request.getParameter("msg");

    @SuppressWarnings("unchecked")
    List<MemberStock> members = (List<MemberStock>) request.getAttribute("members");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết nhóm</title>

    <style>
        body {
            font-family: Arial, sans-serif;
        }

        .top-box {
            border: 1px solid #ccc;
            padding: 15px;
            width: 950px;
            border-radius: 5px;
        }

        table {
            border-collapse: collapse;
            width: 950px;
            margin-top: 15px;
        }

        th, td {
            border: 1px solid #333;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        .btn {
            display: inline-block;
            padding: 7px 12px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-right: 8px;
            border: none;
            cursor: pointer;
        }

        .btn-secondary {
            background-color: #6c757d;
        }

        .btn-danger {
            background-color: #dc3545;
        }

        .btn-warning {
            background-color: #fd7e14;
        }

        .price-up {
            font-weight: bold;
            color: green;
        }

        .price-normal {
            font-weight: bold;
        }

        .message-success {
            color: green;
            font-weight: bold;
        }

        .message-error {
            color: red;
            font-weight: bold;
        }

        form.inline-form {
            display: inline;
        }
    </style>
</head>
<body>

    <div class="top-box">
        <h2>Chi tiết nhóm: <%= groupName != null ? groupName : "Không xác định" %></h2>
        <p>ID nhóm: <%= groupId %></p>

        <a class="btn" href="MyGroupsServlet">Quay lại danh sách nhóm</a>
        <a class="btn btn-secondary" href="index.jsp">Trang chủ</a>

        <% if (isLeader) { %>
            <form class="inline-form"
                  action="DissolveGroupServlet"
                  method="POST"
                  onsubmit="return confirm('Bạn chắc chắn muốn giải thể nhóm này? Toàn bộ dữ liệu nhóm, thành viên, stock và task liên quan sẽ bị xóa.');">

                <input type="hidden" name="groupId" value="<%= groupId %>">

                <button type="submit" class="btn btn-danger">
                    Giải thể nhóm
                </button>
            </form>
        <% } %>

        <% if ("kick_success".equals(msg)) { %>
            <p class="message-success">✅ Đã kick thành viên khỏi nhóm.</p>
        <% } else if ("kick_fail".equals(msg)) { %>
            <p class="message-error">❌ Kick thành viên thất bại. Chỉ leader mới có quyền hoặc dữ liệu đang bị ràng buộc.</p>
        <% } else if ("cannot_kick_self".equals(msg)) { %>
            <p class="message-error">⚠️ Leader không thể tự kick chính mình. Hãy dùng chức năng giải thể nhóm.</p>
        <% } else if ("dissolve_fail".equals(msg)) { %>
            <p class="message-error">❌ Giải thể nhóm thất bại.</p>
        <% } %>
    </div>

    <h3>Bảng xếp hạng cổ phiếu thành viên</h3>

    <%
        if (members == null || members.isEmpty()) {
    %>
            <p>Nhóm này chưa có thành viên nào.</p>
    <%
        } else {
    %>
            <table>
                <tr>
                    <th>Hạng</th>
                    <th>Họ tên</th>
                    <th>Username</th>
                    <th>Vai trò</th>
                    <th>Mã Stock</th>
                    <th>Giá trị hiện tại</th>
                    <% if (isLeader) { %>
                        <th>Hành động</th>
                    <% } %>
                </tr>

                <%
                    int rank = 1;

                    for (MemberStock m : members) {
                %>
                    <tr>
                        <td><%= rank++ %></td>
                        <td><%= m.getFullName() %></td>
                        <td><%= m.getUsername() %></td>
                        <td><%= m.getRole() %></td>
                        <td>
                            <%= m.getStockCode() != null ? m.getStockCode() : "Chưa có stock" %>
                        </td>
                        <td>
                            <%
                                if (m.getCurrentPrice() > 100) {
                            %>
                                    <span class="price-up"><%= m.getCurrentPrice() %></span>
                            <%
                                } else {
                            %>
                                    <span class="price-normal"><%= m.getCurrentPrice() %></span>
                            <%
                                }
                            %>
                        </td>

                        <% if (isLeader) { %>
                            <td>
                                <%
                                    boolean isCurrentUser = currentUserId != null && currentUserId == m.getUserId();
                                    boolean memberIsLeader = "leader".equalsIgnoreCase(m.getRole());
                                %>

                                <% if (!isCurrentUser && !memberIsLeader) { %>
                                    <form action="KickMemberServlet"
                                          method="POST"
                                          onsubmit="return confirm('Bạn chắc chắn muốn kick thành viên này khỏi nhóm?');">

                                        <input type="hidden" name="groupId" value="<%= groupId %>">
                                        <input type="hidden" name="userId" value="<%= m.getUserId() %>">

                                        <button type="submit" class="btn btn-warning">
                                            Kick
                                        </button>
                                    </form>
                                <% } else { %>
                                    Không khả dụng
                                <% } %>
                            </td>
                        <% } %>
                    </tr>
                <%
                    }
                %>
            </table>
    <%
        }
    %>

</body>
</html>