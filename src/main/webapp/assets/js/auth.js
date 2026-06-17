const loginTab = document.getElementById('loginTab');
const registerTab = document.getElementById('registerTab');
const forgotPasswordBtn = document.getElementById('forgotPasswordBtn');

const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const forgotPasswordForm = document.getElementById('forgotPasswordForm');

const formTitle = document.getElementById('formTitle');
const formSubtitle = document.getElementById('formSubtitle');
const messageBox = document.getElementById('messageBox');

const loginBtn = loginForm.querySelector('.submit-btn');
const registerBtn = registerForm.querySelector('.submit-btn');
const forgotBtn = forgotPasswordForm.querySelector('.submit-btn');

const isStaticPreview = ['file:', 'blob:'].includes(window.location.protocol) || window.location.pathname.endsWith('.html');

function showMessage(message, type = 'error') {
  messageBox.textContent = message;
  messageBox.className = `message-box ${type}`;
}

function clearMessage() {
  messageBox.textContent = '';
  messageBox.className = 'message-box';
}

function setLoading(button, isLoading, defaultText) {
  if (!button) return;
  button.textContent = isLoading ? 'Đang xử lý...' : defaultText;
  button.disabled = isLoading;
  button.style.opacity = isLoading ? '0.7' : '1';
  button.style.cursor = isLoading ? 'not-allowed' : 'pointer';
}

function switchForm(type) {
  clearMessage();
  const tabs = document.querySelector('.tabs');

  loginForm.classList.remove('active');
  registerForm.classList.remove('active');
  forgotPasswordForm.classList.remove('active');
  loginTab.classList.remove('active');
  registerTab.classList.remove('active');
  tabs.classList.remove('is-hidden');

  if (type === 'login') {
    loginTab.classList.add('active');
    loginForm.classList.add('active');
    formTitle.textContent = 'Đăng nhập';
    formSubtitle.textContent = 'Truy cập hệ thống để quản lý dự án và theo dõi bảng điện coin của nhóm.';
    setTimeout(() => document.getElementById('loginEmail').focus(), 100);
  }

  if (type === 'register') {
    registerTab.classList.add('active');
    registerForm.classList.add('active');
    formTitle.textContent = 'Đăng ký';
    formSubtitle.textContent = 'Tạo tài khoản để bắt đầu quản lý dự án và đánh giá hiệu suất nhóm.';
    setTimeout(() => document.getElementById('fullName').focus(), 100);
  }

  if (type === 'forgot') {
    forgotPasswordForm.classList.add('active');
    formTitle.textContent = 'Quên mật khẩu';
    formSubtitle.textContent = 'Nhập email đã đăng ký và mật khẩu mới để khôi phục tài khoản.';
    tabs.classList.add('is-hidden');
    setTimeout(() => document.getElementById('forgotEmail').focus(), 100);
  }
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function slugify(value) {
  return String(value || 'user')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') || 'user';
}

function handleServletMessage() {
  const params = new URLSearchParams(window.location.search);
  const msg = params.get('msg');
  if (!msg) return;
  const map = {
    success: ['Đăng ký thành công. Vui lòng đăng nhập.', 'success'],
    fail: ['Đăng ký thất bại. Username hoặc email có thể đã tồn tại.', 'error'],
    group_created: ['Tạo dự án/nhóm thành công.', 'success'],
    group_fail: ['Tạo dự án/nhóm thất bại.', 'error'],
    reset_success: ['Đổi mật khẩu thành công. Vui lòng đăng nhập lại.', 'success'],
    email_not_found: ['Không tìm thấy email trong hệ thống.', 'error']
  };
  if (map[msg]) showMessage(map[msg][0], map[msg][1]);
}

document.addEventListener('DOMContentLoaded', function () {
  loginTab.addEventListener('click', () => switchForm('login'));
  registerTab.addEventListener('click', () => switchForm('register'));
  forgotPasswordBtn?.addEventListener('click', () => switchForm('forgot'));
  document.querySelectorAll('.hint button').forEach((button) => {
    button.addEventListener('click', () => switchForm(button.dataset.target));
  });
  if (window.location.pathname.endsWith('register.jsp')) switchForm('register');
  handleServletMessage();
});

document.querySelectorAll('input, select').forEach((field) => {
  field.addEventListener('input', clearMessage);
  field.addEventListener('change', clearMessage);
});

loginForm.addEventListener('submit', function (event) {
  const accountInput = document.getElementById('loginEmail');
  const passwordInput = document.getElementById('loginPassword');
  const account = accountInput.value.trim();
  const password = passwordInput.value.trim();

  if (!account) {
    event.preventDefault();
    showMessage('Vui lòng nhập email hoặc username.');
    accountInput.focus();
    return;
  }
  if (!password) {
    event.preventDefault();
    showMessage('Vui lòng nhập mật khẩu.');
    passwordInput.focus();
    return;
  }

  localStorage.setItem('zc_logged_in', 'true');
  localStorage.setItem('zc_login_email', account);
  localStorage.setItem('zc_user_name', account.includes('@') ? account.split('@')[0] : account);
  localStorage.setItem('zc_user_id', slugify(account.includes('@') ? account.split('@')[0] : account));

  if (isStaticPreview) {
    event.preventDefault();
    setLoading(loginBtn, true, 'Đăng nhập');
    setTimeout(() => {
      setLoading(loginBtn, false, 'Đăng nhập');
      window.location.href = 'projects.html';
    }, 500);
  }
  // Khi chạy bằng Tomcat, form sẽ POST thẳng tới LoginServlet với name="username" và name="password".
});

registerForm.addEventListener('submit', function (event) {
  const fullNameInput = document.getElementById('fullName');
  const emailInput = document.getElementById('registerEmail');
  const usernameInput = document.getElementById('registerUsername');
  const passwordInput = document.getElementById('registerPassword');
  const confirmPasswordInput = document.getElementById('confirmPassword');

  const fullName = fullNameInput.value.trim();
  const email = emailInput.value.trim();
  const username = usernameInput.value.trim();
  const password = passwordInput.value.trim();
  const confirmPassword = confirmPasswordInput.value.trim();

  if (!fullName) { event.preventDefault(); showMessage('Vui lòng nhập họ và tên.'); fullNameInput.focus(); return; }
  if (!email || !isValidEmail(email)) { event.preventDefault(); showMessage('Email không hợp lệ.'); emailInput.focus(); return; }
  if (!username) { event.preventDefault(); showMessage('Vui lòng nhập username.'); usernameInput.focus(); return; }
  if (!password || password.length < 6) { event.preventDefault(); showMessage('Mật khẩu phải có ít nhất 6 ký tự.'); passwordInput.focus(); return; }
  if (password !== confirmPassword) { event.preventDefault(); showMessage('Mật khẩu xác nhận không khớp.'); confirmPasswordInput.focus(); return; }

  if (isStaticPreview) {
    event.preventDefault();
    setLoading(registerBtn, true, 'Tạo tài khoản');
    setTimeout(() => {
      setLoading(registerBtn, false, 'Tạo tài khoản');
      localStorage.setItem('zc_user_name', fullName);
      localStorage.setItem('zc_user_email', email);
      localStorage.setItem('zc_user_password', password);
      localStorage.setItem('zc_user_id', slugify(username));
      registerForm.reset();
      switchForm('login');
      showMessage('Đăng ký thành công. Vui lòng đăng nhập.', 'success');
    }, 500);
  }
  // Khi chạy bằng Tomcat, form sẽ POST tới RegisterServlet với fullName, email, username, password.
});

forgotPasswordForm.addEventListener('submit', function (event) {
  const forgotEmailInput = document.getElementById('forgotEmail');
  const forgotNewPasswordInput = document.getElementById('forgotNewPassword');
  const email = forgotEmailInput.value.trim();
  const newPassword = forgotNewPasswordInput.value.trim();

  if (!email || !isValidEmail(email)) {
    event.preventDefault();
    showMessage('Email khôi phục không hợp lệ.');
    forgotEmailInput.focus();
    return;
  }
  if (!newPassword || newPassword.length < 6) {
    event.preventDefault();
    showMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
    forgotNewPasswordInput.focus();
    return;
  }

  if (isStaticPreview) {
    event.preventDefault();
    setLoading(forgotBtn, true, 'Gửi yêu cầu khôi phục');
    setTimeout(() => {
      setLoading(forgotBtn, false, 'Gửi yêu cầu khôi phục');
      localStorage.setItem('zc_user_password', newPassword);
      forgotPasswordForm.reset();
      switchForm('login');
      showMessage('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.', 'success');
    }, 500);
  }
  // Khi chạy bằng Tomcat, form sẽ POST tới ForgotPasswordServlet với email và newPassword.
});
