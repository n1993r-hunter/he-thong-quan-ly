<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Group" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nhóm của tôi</title>

    <style>
        table {
            border-collapse: collapse;
            width: 700px;
        }

        th, td {
            border: 1px solid #333;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        a {
            text-decoration: none;
        }
    </style>
</head>
<body>

    <h2>Danh sách nhóm của tôi</h2>

    <%
        @SuppressWarnings("unchecked")
        List<Group> groups = (List<Group>) request.getAttribute("groups");

        if (groups == null || groups.isEmpty()) {
    %>
            <p>Bạn chưa tham gia nhóm nào.</p>
    <%
        } else {
    %>
            <table>
                <tr>
                    <th>ID nhóm</th>
                    <th>Tên nhóm</th>
                    <th>Người tạo</th>
                    <th>Hành động</th>
                </tr>

                <% for (Group g : groups) { %>
                    <tr>
                        <td><%= g.getGroupId() %></td>
                        <td><%= g.getGroupName() %></td>
                        <td><%= g.getCreatedBy() %></td>
                        <td>
                            <a href="GroupDetailServlet?groupId=<%= g.getGroupId() %>">
                                Xem chi tiết
                            </a>
                        </td>
                    </tr>
                <% } %>
            </table>
    <%
        }
    %>

    <br>
    <a href="index.jsp">Quay lại trang chủ</a>

</body>
</html>