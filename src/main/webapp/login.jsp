<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
%>

<%
    String errorMessage = (String) request.getAttribute("error");
    String successMessage = (String) request.getAttribute("success");
    String oldUsername = (String) request.getAttribute("oldUsername");

    if (errorMessage == null) {
        String errorParam = request.getParameter("error");

        if ("invalid".equals(errorParam)) {
            errorMessage = "Sai tên đăng nhập hoặc mật khẩu!";
        } else if ("missing".equals(errorParam)) {
            errorMessage = "Vui lòng nhập đầy đủ tài khoản và mật khẩu!";
        } else if ("server".equals(errorParam)) {
            errorMessage = "Hệ thống đang gặp lỗi. Vui lòng thử lại sau!";
        }
    }

    if (successMessage == null) {
        String successParam = request.getParameter("success");

        if ("register".equals(successParam)) {
            successMessage = "Đăng ký thành công. Bạn có thể đăng nhập ngay.";
        } else if ("forgot".equals(successParam)) {
            successMessage = "Đổi mật khẩu thành công. Bạn có thể đăng nhập lại.";
        }
    }

    String savedUsername = "";
    String savedPassword = "";
    boolean remembered = false;

    Cookie[] cookies = request.getCookies();

    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("cUser".equals(cookie.getName())) {
                savedUsername = cookie.getValue();
            }

            if ("cPass".equals(cookie.getName())) {
                savedPassword = cookie.getValue();
            }
        }
    }

    if (oldUsername == null || oldUsername.trim().isEmpty()) {
        oldUsername = savedUsername;
    }

    if (savedUsername != null && !savedUsername.trim().isEmpty()) {
        remembered = true;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <title>Zero-Sum Coin Exchange | Authentication</title>

  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" />

  <link
    href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
    rel="stylesheet"
  />

  <link rel="stylesheet" href="assets/css/auth.css" />

  <style>
    .auth-error-message {
      margin: 18px 0;
      padding: 14px 16px;
      border-radius: 16px;
      background: rgba(239, 68, 68, 0.12);
      border: 1px solid rgba(239, 68, 68, 0.35);
      color: #fecaca;
      font-weight: 700;
      line-height: 1.5;
    }

    .auth-success-message {
      margin: 18px 0;
      padding: 14px 16px;
      border-radius: 16px;
      background: rgba(34, 197, 94, 0.12);
      border: 1px solid rgba(34, 197, 94, 0.35);
      color: #bbf7d0;
      font-weight: 700;
      line-height: 1.5;
    }
  </style>
</head>

<body>
  <main class="auth-wrapper">
    <section class="intro-panel">
      <div class="brand">
        <div class="brand-icon">ZC</div>

        <div class="brand-text">
          <h2>Zero-Sum Coin Exchange</h2>
          <p>Team Performance Evaluation System</p>
        </div>
      </div>

      <div class="intro-content">
        <div class="tag">Zero-Sum Gamification</div>

        <h1>Biến hiệu suất nhóm thành một sàn giao dịch trực quan.</h1>

        <p>
          Theo dõi đóng góp, đánh giá thành viên và phân phối coin công bằng trong từng dự án.
          Mỗi thay đổi đều được phản ánh như biến động trên một bảng điện hiệu suất.
        </p>
      </div>

      <div class="market-preview">
        <div class="market-card">
          <span>Total Pool</span>
          <strong>500 COIN</strong>
          <div class="up">Stable Market</div>
        </div>

        <div class="market-card">
          <span>Top Gainer</span>
          <strong>AN +12</strong>
          <div class="up">▲ 9.8%</div>
        </div>

        <div class="market-card">
          <span>Watchlist</span>
          <strong>BINH -6</strong>
          <div class="down">▼ 4.2%</div>
        </div>
      </div>
    </section>

    <section class="form-panel">
      <div class="auth-box">
        <h2 id="formTitle">Đăng nhập</h2>

        <p class="subtitle" id="formSubtitle">
          Truy cập hệ thống để quản lý dự án và theo dõi bảng điện coin của nhóm.
        </p>

        <div class="tabs">
          <button class="tab-btn active" id="loginTab" type="button">Đăng nhập</button>
          <button class="tab-btn" id="registerTab" type="button">Đăng ký</button>
        </div>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
          <div class="auth-error-message">
            <%= h(errorMessage) %>
          </div>
        <% } %>

        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
          <div class="auth-success-message">
            <%= h(successMessage) %>
          </div>
        <% } %>

        <div class="message-box" id="messageBox"></div>

        <!-- LOGIN FORM -->
        <form class="form active" id="loginForm" action="LoginServlet" method="post">
          <div class="form-group">
            <label for="loginEmail">Email hoặc username</label>

            <input
              type="text"
              id="loginEmail"
              name="username"
              placeholder="Nhập email hoặc username"
              autocomplete="username"
              value="<%= h(oldUsername) %>"
              required
            />
          </div>

          <div class="form-group">
            <label for="loginPassword">Mật khẩu</label>

            <input
              type="password"
              id="loginPassword"
              name="password"
              placeholder="Nhập mật khẩu"
              autocomplete="current-password"
              value="<%= h(savedPassword) %>"
              required
            />
          </div>

          <div class="form-options">
            <label>
              <input type="checkbox" name="remember" <%= remembered ? "checked" : "" %> />
              Ghi nhớ đăng nhập
            </label>

            <button class="forgot-link" type="button" id="forgotPasswordBtn">
              Quên mật khẩu?
            </button>
          </div>

          <button class="submit-btn" type="submit">Đăng nhập</button>

          <p class="hint">
            Chưa có tài khoản?
            <button type="button" data-target="register">Tạo tài khoản mới</button>
          </p>
        </form>

        <!-- REGISTER FORM -->
        <form class="form" id="registerForm" action="RegisterServlet" method="post">
          <div class="form-group">
            <label for="fullName">Họ và tên</label>

            <input
              type="text"
              id="fullName"
              name="fullName"
              placeholder="Nhập họ và tên"
              autocomplete="name"
              required
            />
          </div>

          <div class="form-group">
            <label for="registerEmail">Email</label>

            <input
              type="email"
              id="registerEmail"
              name="email"
              placeholder="Nhập email"
              autocomplete="email"
              required
            />
          </div>

          <div class="form-group">
            <label for="registerUsername">Username</label>

            <input
              type="text"
              id="registerUsername"
              name="username"
              placeholder="VD: tramnguyen"
              autocomplete="username"
              required
            />
          </div>

          <div class="form-group">
            <label for="registerPassword">Mật khẩu</label>

            <input
              type="password"
              id="registerPassword"
              name="password"
              placeholder="Tạo mật khẩu"
              autocomplete="new-password"
              required
            />
          </div>

          <div class="form-group">
            <label for="confirmPassword">Xác nhận mật khẩu</label>

            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              placeholder="Nhập lại mật khẩu"
              autocomplete="new-password"
              required
            />
          </div>

          <button class="submit-btn" type="submit">Tạo tài khoản</button>

          <p class="hint">
            Đã có tài khoản?
            <button type="button" data-target="login">Đăng nhập ngay</button>
          </p>
        </form>

        <!-- FORGOT PASSWORD FORM -->
        <form class="form" id="forgotPasswordForm" action="ForgotPasswordServlet" method="post">
          <div class="form-group">
            <label for="forgotEmail">Email khôi phục</label>

            <input
              type="email"
              id="forgotEmail"
              name="email"
              placeholder="Nhập email đã đăng ký"
              autocomplete="email"
              required
            />
          </div>

          <div class="form-group">
            <label for="forgotNewPassword">Mật khẩu mới</label>

            <input
              type="password"
              id="forgotNewPassword"
              name="newPassword"
              placeholder="Nhập mật khẩu mới"
              autocomplete="new-password"
              required
            />
          </div>

          <button class="submit-btn" type="submit">Gửi yêu cầu khôi phục</button>

          <p class="hint">
            Đã nhớ mật khẩu?
            <button type="button" data-target="login">Quay lại đăng nhập</button>
          </p>
        </form>
      </div>
    </section>
  </main>

  <script src="assets/js/auth.js"></script>
</body>
</html>