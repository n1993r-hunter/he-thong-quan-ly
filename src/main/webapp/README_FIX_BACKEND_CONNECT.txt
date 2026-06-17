Bản fix kết nối frontend-backend:

1) index.jsp
- Không để JS tự render danh sách project nữa.
- Danh sách dự án được render trực tiếp từ request attribute "groups" do MyGroupsServlet gửi sang.
- Link chi tiết dùng đúng GroupDetailServlet?groupId=...
- Form tạo dự án POST tới GroupServlet với name="groupName".
- Thêm form tham gia dự án, gửi name="groupId" tới JoinGroupRequestServlet.

2) group_detail.jsp / project-detail.jsp
- Đọc groupId từ request parameter "groupId"; vẫn fallback "id" để tránh lỗi cũ.
- Đọc request attribute "group" nếu GroupDetailServlet setAttribute("group", group).
- Hiển thị Group ID và nút Copy Group ID.
- Nhóm trưởng thấy form duyệt/kick thành viên: ApproveMemberServlet, KickMemberServlet.

3) projects.js
- Xóa hoàn toàn project demo/mockup.
- Trên JSP không ghi đè HTML backend render.
- Chỉ gắn click/filter/modal.

4) project-detail.js
- Xóa sampleProject/demo.
- Đọc groupId/group từ window.ZC_BACKEND_GROUP do JSP truyền.
- Không tự redirect sai id/projectId.

Lưu ý backend cần khớp:
- MyGroupsServlet nên forward về index.jsp, không phải my-groups.jsp.
- GroupDetailServlet nên nhận request.getParameter("groupId") và forward về group_detail.jsp hoặc project-detail.jsp.
- Nếu muốn duyệt/kick hoạt động thật, cần có JoinGroupRequestServlet, ApproveMemberServlet, KickMemberServlet hoặc đổi action form theo servlet backend đang có.
