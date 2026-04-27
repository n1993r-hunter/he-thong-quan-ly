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

function showMessage(message, type = 'error') {
  messageBox.textContent = message;
  messageBox.className = `message-box ${type}`;
}

function clearMessage() {
  messageBox.textContent = '';
  messageBox.className = 'message-box';
}

function setLoading(button, isLoading, defaultText) {
  if (isLoading) {
    button.textContent = 'Đang xử lý...';
    button.disabled = true;
    button.style.opacity = '0.7';
    button.style.cursor = 'not-allowed';
  } else {
    button.textContent = defaultText;
    button.disabled = false;
    button.style.opacity = '1';
    button.style.cursor = 'pointer';
  }
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
    formSubtitle.textContent =
      'Truy cập hệ thống để quản lý dự án và theo dõi bảng điện coin của nhóm.';

    setTimeout(() => {
      document.getElementById('loginEmail').focus();
    }, 100);
  }

  if (type === 'register') {
    registerTab.classList.add('active');
    registerForm.classList.add('active');

    formTitle.textContent = 'Đăng ký';
    formSubtitle.textContent =
      'Tạo tài khoản để bắt đầu quản lý dự án và đánh giá hiệu suất nhóm.';

    setTimeout(() => {
      document.getElementById('fullName').focus();
    }, 100);
  }

  if (type === 'forgot') {
    forgotPasswordForm.classList.add('active');

    formTitle.textContent = 'Quên mật khẩu';
    formSubtitle.textContent =
      'Nhập email đã đăng ký và thiết lập mật khẩu mới.';

    tabs.classList.add('is-hidden');

    setTimeout(() => {
      document.getElementById('forgotEmail').focus();
    }, 100);
  }
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

loginTab.addEventListener('click', () => switchForm('login'));
registerTab.addEventListener('click', () => switchForm('register'));

if (forgotPasswordBtn) {
  forgotPasswordBtn.addEventListener('click', () => {
    switchForm('forgot');
  });
}

document.querySelectorAll('.hint button').forEach((button) => {
  button.addEventListener('click', () => {
    switchForm(button.dataset.target);
  });
});

document.querySelectorAll('input, select').forEach((field) => {
  field.addEventListener('input', clearMessage);
  field.addEventListener('change', clearMessage);
});

loginForm.addEventListener('submit', function (event) {
  event.preventDefault();

  const emailInput = document.getElementById('loginEmail');
  const passwordInput = document.getElementById('loginPassword');

  const email = emailInput.value.trim();
  const password = passwordInput.value.trim();

  if (!email) {
    showMessage('Vui lòng nhập email hoặc username.');
    emailInput.focus();
    return;
  }

  if (!password) {
    showMessage('Vui lòng nhập mật khẩu.');
    passwordInput.focus();
    return;
  }

  setLoading(loginBtn, true, 'Đăng nhập');
  loginForm.submit();
});

registerForm.addEventListener('submit', function (event) {
  event.preventDefault();

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

  if (!fullName) {
    showMessage('Vui lòng nhập họ và tên.');
    fullNameInput.focus();
    return;
  }

  if (!email) {
    showMessage('Vui lòng nhập email.');
    emailInput.focus();
    return;
  }

  if (!isValidEmail(email)) {
    showMessage('Email không hợp lệ.');
    emailInput.focus();
    return;
  }

  if (!username) {
    showMessage('Vui lòng nhập tên đăng nhập.');
    usernameInput.focus();
    return;
  }

  if (username.length < 3) {
    showMessage('Tên đăng nhập phải có ít nhất 3 ký tự.');
    usernameInput.focus();
    return;
  }

  if (!password) {
    showMessage('Vui lòng nhập mật khẩu.');
    passwordInput.focus();
    return;
  }

  if (password.length < 6) {
    showMessage('Mật khẩu phải có ít nhất 6 ký tự.');
    passwordInput.focus();
    return;
  }

  if (!confirmPassword) {
    showMessage('Vui lòng xác nhận mật khẩu.');
    confirmPasswordInput.focus();
    return;
  }

  if (password !== confirmPassword) {
    showMessage('Mật khẩu xác nhận không khớp.');
    confirmPasswordInput.focus();
    return;
  }

  setLoading(registerBtn, true, 'Tạo tài khoản');
  registerForm.submit();
});

forgotPasswordForm.addEventListener('submit', function (event) {
  event.preventDefault();

  const forgotEmailInput = document.getElementById('forgotEmail');
  const newPasswordInput = document.getElementById('newPassword');
  const confirmNewPasswordInput = document.getElementById('confirmNewPassword');

  const email = forgotEmailInput.value.trim();
  const newPassword = newPasswordInput.value.trim();
  const confirmNewPassword = confirmNewPasswordInput.value.trim();

  if (!email) {
    showMessage('Vui lòng nhập email khôi phục.');
    forgotEmailInput.focus();
    return;
  }

  if (!isValidEmail(email)) {
    showMessage('Email không hợp lệ.');
    forgotEmailInput.focus();
    return;
  }

  if (!newPassword) {
    showMessage('Vui lòng nhập mật khẩu mới.');
    newPasswordInput.focus();
    return;
  }

  if (newPassword.length < 6) {
    showMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
    newPasswordInput.focus();
    return;
  }

  if (!confirmNewPassword) {
    showMessage('Vui lòng xác nhận mật khẩu mới.');
    confirmNewPasswordInput.focus();
    return;
  }

  if (newPassword !== confirmNewPassword) {
    showMessage('Mật khẩu mới xác nhận không khớp.');
    confirmNewPasswordInput.focus();
    return;
  }

  setLoading(forgotBtn, true, 'Cập nhật mật khẩu');
  forgotPasswordForm.submit();
});
