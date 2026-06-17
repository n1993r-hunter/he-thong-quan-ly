// Trang Project Hub. Khi chạy bằng JSP/Tomcat, backend kiểm tra session; JS chỉ bảo vệ bản HTML tĩnh.
const IS_JSP_PAGE = window.location.pathname.endsWith('.jsp');
const IS_STATIC_PREVIEW = ['file:', 'blob:'].includes(window.location.protocol) || window.location.pathname.endsWith('.html');
(function protectPage() {
  if (!IS_STATIC_PREVIEW || IS_JSP_PAGE) return;
  const isLoggedIn = localStorage.getItem('zc_logged_in') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  if (!isLoggedIn) {
    alert('Bạn cần đăng nhập trước khi vào trang quản lý dự án.');
    window.location.href = 'index.html';
  }
})();

const STORAGE_KEY = 'zc_projects';
const projectModal = document.getElementById('projectModal');
const openCreateModal = document.getElementById('openCreateModal');
const closeModal = document.getElementById('closeModal');
const cancelCreateBtn = document.getElementById('cancelCreateBtn');
const createProjectForm = document.getElementById('createProjectForm');
const memberList = document.getElementById('memberList');
const taskList = document.getElementById('taskList');
const addMemberBtn = document.getElementById('addMemberBtn');
const addTaskBtn = document.getElementById('addTaskBtn');
const projectList = document.getElementById('projectList');
const searchProjectInput = document.getElementById('searchProjectInput');
const statusFilter = document.getElementById('statusFilter');
const emptyState = document.getElementById('emptyState');
const logoutBtn = document.getElementById('logoutBtn');
const currentUserName = document.getElementById('currentUserName');
const sidebarProjectList = document.getElementById('sidebarProjectList');
const projectMenuToggle = document.getElementById('projectMenuToggle');

function slugify(value) {
  return String(value || 'user')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') || 'user';
}

function getCurrentUser() {
  const displayName = localStorage.getItem('zc_user_name') || localStorage.getItem('currentUserName') || 'Team Member';
  const userId = localStorage.getItem('zc_user_id') || slugify(displayName);
  localStorage.setItem('zc_user_id', userId);
  return { userId, displayName };
}

const currentUser = getCurrentUser();
currentUserName.textContent = currentUser.displayName;

let projects = JSON.parse(localStorage.getItem(STORAGE_KEY)) || [
  {
    id: 'demo-web-tracking',
    name: 'Web Tracking Behavior',
    desc: 'Theo dõi tiến độ học tập và làm việc nhóm được game hóa theo phong cách sàn chứng khoán.',
    deadline: '2026-06-25',
    status: 'active',
    creatorId: currentUser.userId,
    creatorName: currentUser.displayName,
    members: [
      { userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 128, role: 'leader' },
      { userId: 'minh', name: 'Minh', stockCode: 'MINH', coin: 106, role: 'member' },
      { userId: 'an', name: 'An', stockCode: 'AN', coin: 92, role: 'member' }
    ],
    tasks: [
      { title: 'Dựng trang đăng nhập', assignee: currentUser.userId, deadline: '2026-06-15', impactCoin: 8, status: 'done', update: 'Đã hoàn thiện trang 1.', rating: 5 },
      { title: 'Thiết kế database', assignee: 'minh', deadline: '2026-06-18', impactCoin: 10, status: 'doing', update: 'Đã có ERD bản đầu.', rating: 4 },
      { title: 'Làm trang chi tiết dự án', assignee: 'an', deadline: '2026-06-22', impactCoin: 12, status: 'todo', update: '', rating: 0 }
    ],
    progress: 55
  }
];

function saveProjects() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(projects));
}

function formatDate(dateString) {
  if (!dateString) return 'Chưa đặt';
  const [year, month, day] = dateString.split('-');
  return day && month && year ? `${day}/${month}/${year}` : dateString;
}

function isOverdue(dateString) {
  if (!dateString) return false;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const deadline = new Date(dateString);
  deadline.setHours(0, 0, 0, 0);
  return !Number.isNaN(deadline.getTime()) && deadline < today;
}

function autoMarkLateTasks() {
  let changed = false;
  projects.forEach((project) => {
    (project.tasks || []).forEach((task) => {
      if (task.status !== 'done' && isOverdue(task.deadline)) {
        task.status = 'late';
        changed = true;
      }
    });
  });
  if (changed) saveProjects();
}

function getProjectProgress(project) {
  const tasks = project.tasks || [];
  if (!tasks.length) return Number(project.progress || 0);
  const done = tasks.filter((task) => task.status === 'done').length;
  return Math.round((done / tasks.length) * 100);
}

function getStatusLabel(status) {
  if (status === 'warning') return 'Có rủi ro';
  if (status === 'done') return 'Hoàn thành';
  return 'Đang chạy';
}

function getDetailPage() {
  return window.location.pathname.endsWith('.jsp') ? 'project-detail.jsp' : 'project-detail.html';
}

function goToProject(projectId) {
  localStorage.setItem('zc_current_project_id', String(projectId));
  window.location.href = `${getDetailPage()}?projectId=${encodeURIComponent(projectId)}`;
}

function updateStats() {
  document.getElementById('totalProjects').textContent = projects.length;
  document.getElementById('activeProjects').textContent = projects.filter((p) => p.status === 'active').length;
  document.getElementById('totalMembers').textContent = projects.reduce((sum, p) => sum + (p.members?.length || 0), 0);
  document.getElementById('totalTasks').textContent = projects.reduce((sum, p) => sum + (p.tasks?.length || 0), 0);
}


function renderSidebarProjects() {
  if (!sidebarProjectList) return;
  sidebarProjectList.innerHTML = projects.map((project) => `
    <a href="${getDetailPage()}?projectId=${encodeURIComponent(project.id)}" title="${project.name}">
      <span>${project.name}</span>
      <em>${project.members?.length || 0}</em>
    </a>
  `).join('') || '<a href="#"><span>Chưa có dự án</span></a>';
}

function renderProjects() {
  autoMarkLateTasks();
  const keyword = searchProjectInput.value.trim().toLowerCase();
  const status = statusFilter.value;

  const filtered = projects.filter((project) => {
    const desc = project.desc || project.description || '';
    const matchKeyword = project.name.toLowerCase().includes(keyword) || desc.toLowerCase().includes(keyword);
    const matchStatus = status === 'all' || project.status === status;
    return matchKeyword && matchStatus;
  });

  projectList.innerHTML = filtered.map((project) => {
    const progress = getProjectProgress(project);
    project.progress = progress;
    const isLeader = String(project.creatorId) === currentUser.userId;
    return `
      <article class="project-card" role="button" tabindex="0" data-project-id="${project.id}">
        <div class="project-top">
          <div>
            <span class="badge ${project.status}">${getStatusLabel(project.status)}</span>
            <h3>${project.name}</h3>
          </div>
          <button class="detail-link" type="button" data-project-id="${project.id}">Chi tiết</button>
        </div>
        <p>${project.desc || project.description || 'Chưa có mô tả cho dự án này.'}</p>
        <div class="progress-row"><span>Tiến độ</span><strong>${progress}%</strong></div>
        <div class="progress-bar"><div style="width:${progress}%"></div></div>
        <div class="project-meta">
          <span>${project.members?.length || 0} thành viên</span>
          <span>${project.tasks?.length || 0} task</span>
          <span>${isLeader ? 'Bạn là nhóm trưởng' : 'Bạn là thành viên'}</span>
          <span>Deadline: ${formatDate(project.deadline)}</span>
        </div>
      </article>`;
  }).join('');

  document.querySelectorAll('.project-card').forEach((card) => {
    card.addEventListener('click', (event) => {
      if (event.target.closest('.detail-link')) return;
      goToProject(card.dataset.projectId);
    });
    card.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') goToProject(card.dataset.projectId);
    });
  });
  document.querySelectorAll('.detail-link').forEach((btn) => btn.addEventListener('click', () => goToProject(btn.dataset.projectId)));

  emptyState.style.display = filtered.length ? 'none' : 'block';
  updateStats();
  renderSidebarProjects();
}

function createMemberRow(data = {}) {
  const row = document.createElement('div');
  row.className = 'dynamic-row member-row';
  row.innerHTML = `
    <input class="member-user-id" type="text" placeholder="user_id, VD: minh" value="${data.userId || ''}" required />
    <input class="member-name" type="text" placeholder="Tên thành viên" value="${data.name || ''}" required />
    <input class="member-code" type="text" placeholder="Mã coin, VD: MINH" value="${data.stockCode || ''}" required />
    <input class="member-coin" type="number" min="0" placeholder="Coin" value="${data.coin || 100}" required />
    <button class="remove-btn" type="button">×</button>
  `;
  row.querySelector('.remove-btn').addEventListener('click', () => row.remove());
  memberList.appendChild(row);
}

function createTaskRow(data = {}) {
  const row = document.createElement('div');
  row.className = 'dynamic-row task-row';
  row.innerHTML = `
    <div class="row-field"><label>Tên task</label><input class="task-title" type="text" placeholder="VD: Làm dashboard" value="${data.title || ''}" required /></div>
    <div class="row-field"><label>Người thực hiện</label><input class="task-assignee" type="text" placeholder="user_id" value="${data.assignee || ''}" required /></div>
    <div class="row-field"><label>Deadline</label><input class="task-deadline" type="date" value="${data.deadline || ''}" required /></div>
    <div class="row-field"><label>Coin thưởng/phạt</label><input class="task-impact" type="number" min="0" placeholder="VD: 5" value="${data.impactCoin || 5}" required /></div>
    <button class="remove-btn" type="button" title="Xóa task">×</button>
  `;
  row.querySelector('.remove-btn').addEventListener('click', () => row.remove());
  taskList.appendChild(row);
}

function openModal() {
  projectModal.classList.add('show');
  projectModal.setAttribute('aria-hidden', 'false');
  if (!memberList.children.length) createMemberRow({ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 120 });
  if (!taskList.children.length) createTaskRow({ assignee: currentUser.userId });
}

function closeCreateModal() {
  projectModal.classList.remove('show');
  projectModal.setAttribute('aria-hidden', 'true');
}

function collectMembers() {
  const members = [...document.querySelectorAll('.member-row')].map((row) => ({
    userId: slugify(row.querySelector('.member-user-id').value.trim()),
    name: row.querySelector('.member-name').value.trim(),
    stockCode: row.querySelector('.member-code').value.trim().toUpperCase(),
    coin: Number(row.querySelector('.member-coin').value),
    role: 'member'
  })).filter((member) => member.userId && member.stockCode && member.name);

  const leaderIndex = members.findIndex((member) => member.userId === currentUser.userId);
  if (leaderIndex >= 0) {
    members[leaderIndex].role = 'leader';
    members[leaderIndex].name = members[leaderIndex].name || currentUser.displayName;
  } else {
    members.unshift({ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 120, role: 'leader' });
  }
  return members;
}

function collectTasks() {
  return [...document.querySelectorAll('.task-row')].map((row) => ({
    title: row.querySelector('.task-title').value.trim(),
    assignee: slugify(row.querySelector('.task-assignee').value.trim()),
    deadline: row.querySelector('.task-deadline').value,
    impactCoin: Number(row.querySelector('.task-impact').value),
    status: 'todo',
    update: '',
    submission: '',
    rating: 0,
    ratings: {}
  })).filter((task) => task.title && task.assignee);
}

openCreateModal.addEventListener('click', openModal);
closeModal.addEventListener('click', closeCreateModal);
cancelCreateBtn.addEventListener('click', closeCreateModal);
addMemberBtn.addEventListener('click', () => createMemberRow());
addTaskBtn.addEventListener('click', () => createTaskRow());
if (projectMenuToggle) projectMenuToggle.addEventListener('click', () => sidebarProjectList?.classList.toggle('collapsed'));
searchProjectInput.addEventListener('input', renderProjects);
statusFilter.addEventListener('change', renderProjects);
projectModal.addEventListener('click', (event) => { if (event.target === projectModal) closeCreateModal(); });

createProjectForm.addEventListener('submit', (event) => {
  const projectNameInput = document.getElementById('projectName');
  if (!projectNameInput.value.trim()) {
    event.preventDefault();
    return alert('Vui lòng nhập tên dự án.');
  }

  // Trên JSP/Tomcat: để form POST thẳng tới GroupServlet với name="groupName".
  // Backend hiện tại chỉ nhận groupName; member/task/coin sẽ do phần backend tiếp theo xử lý.
  if (IS_JSP_PAGE && createProjectForm.getAttribute('action')) {
    return;
  }

  event.preventDefault();
  const members = collectMembers();
  const tasks = collectTasks();
  if (!members.length) return alert('Vui lòng thêm ít nhất 1 thành viên cho dự án.');
  if (!tasks.length) return alert('Vui lòng thêm ít nhất 1 task cho dự án.');

  const labels = ['IPO', 'D1', 'D2', 'D3', 'D4'];
  const series = {};
  members.forEach((member, index) => {
    const base = Number(member.coin || 100);
    series[member.userId] = [100, 100 + index * 2, Math.max(70, base - 4), base + 2, base];
  });

  const newProject = {
    id: Date.now(),
    name: document.getElementById('projectName').value.trim(),
    desc: document.getElementById('projectDesc').value.trim(),
    deadline: document.getElementById('projectDeadline').value,
    status: 'active',
    creatorId: currentUser.userId,
    creatorName: currentUser.displayName,
    members,
    tasks,
    coinHistory: { labels, series },
    progress: 0
  };

  projects.unshift(newProject);
  saveProjects();
  createProjectForm.reset();
  memberList.innerHTML = '';
  taskList.innerHTML = '';
  closeCreateModal();
  renderSidebarProjects();
  goToProject(newProject.id);
});

logoutBtn.addEventListener('click', () => {
  localStorage.removeItem('zc_logged_in');
  localStorage.removeItem('zc_user_name');
  localStorage.removeItem('zc_user_id');
  window.location.href = window.location.pathname.endsWith('.jsp') ? 'LogoutServlet' : 'index.html';
});

saveProjects();
renderProjects();
