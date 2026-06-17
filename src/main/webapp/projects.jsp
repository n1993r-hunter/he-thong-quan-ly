<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Không render trùng Project Hub. Trang danh sách dự án chính là index.jsp do MyGroupsServlet đổ dữ liệu.
  response.sendRedirect("MyGroupsServlet");
%>
