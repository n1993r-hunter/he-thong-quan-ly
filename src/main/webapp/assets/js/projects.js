// Trang Project Hub. JSP/Tomcat để backend kiểm tra session; bản HTML tĩnh dùng localStorage.
const IS_JSP_PAGE = window.location.pathname.endsWith('.jsp');
const IS_STATIC_PREVIEW = ['file:', 'blob:'].includes(window.location.protocol) || window.location.pathname.endsWith('.html');
const STORAGE_KEY = 'zc_projects';

(function protectPage() {
  if (!IS_STATIC_PREVIEW || IS_JSP_PAGE) return;
  const isLoggedIn = localStorage.getItem('zc_logged_in') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  if (!isLoggedIn) {
    alert('Bạn cần đăng nhập trước khi vào trang quản lý dự án.');
    window.location.href = 'index.html';
  }
})();

const projectModal = document.getElementById('projectModal');
const joinProjectModal = document.getElementById('joinProjectModal');
const openCreateModal = document.getElementById('openCreateModal');
const openJoinModal = document.getElementById('openJoinModal');
const closeModal = document.getElementById('closeModal');
const closeJoinModal = document.getElementById('closeJoinModal');
const cancelCreateBtn = document.getElementById('cancelCreateBtn');
const cancelJoinBtn = document.getElementById('cancelJoinBtn');
const createProjectForm = document.getElementById('createProjectForm');
const joinProjectForm = document.getElementById('joinProjectForm');
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
  return String(value || 'user').trim().toLowerCase().normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') || 'user';
}

function getCurrentUser() {
  const displayName = localStorage.getItem('zc_user_name') || localStorage.getItem('currentUserName') || 'Team Member';
  const userId = localStorage.getItem('zc_user_id') || slugify(displayName);
  localStorage.setItem('zc_user_id', userId);
  return { userId, displayName };
}

const currentUser = getCurrentUser();
if (currentUserName) currentUserName.textContent = currentUser.displayName;


function isDemoProject(project) {
  const id = String(project?.id || '').toLowerCase();
  const name = String(project?.name || '').toLowerCase();
  return id === 'demo-web-tracking' || name.includes('web tracking behavior') || name.includes('dự án mẫu') || name.includes('du an mau');
}

function removeDemoProjectsFromStorage() {
  let list = [];
  try { list = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]') || []; } catch { list = []; }
  const clean = list.filter(project => !isDemoProject(project));
  if (clean.length !== list.length) localStorage.setItem(STORAGE_KEY, JSON.stringify(clean));
  return clean;
}

// ĐÃ XÓA PROJECT MẪU: user mới vào sẽ thấy danh sách trống.
// Nếu browser từng lưu demo cũ trong localStorage, tự dọn để không hiện lại.
let projects = removeDemoProjectsFromStorage();

function saveProjects() { localStorage.setItem(STORAGE_KEY, JSON.stringify(projects)); }
function formatDate(dateString) {
  if (!dateString) return 'Chưa đặt';
  const [year, month, day] = String(dateString).split('-');
  return day && month && year ? `${day}/${month}/${year}` : dateString;
}
function isOverdue(dateString) {
  if (!dateString) return false;
  const today = new Date(); today.setHours(0,0,0,0);
  const deadline = new Date(dateString); deadline.setHours(0,0,0,0);
  return !Number.isNaN(deadline.getTime()) && deadline < today;
}
function autoMarkLateTasks() {
  let changed = false;
  projects.forEach(project => (project.tasks || []).forEach(task => {
    if (task.status !== 'done' && isOverdue(task.deadline)) { task.status = 'late'; changed = true; }
  }));
  if (changed) saveProjects();
}
function getProjectProgress(project) {
  const tasks = project.tasks || [];
  if (!tasks.length) return Number(project.progress || 0);
  const done = tasks.filter(task => task.status === 'done').length;
  return Math.round((done / tasks.length) * 100);
}
function getProjectStatus(project) {
  if ((project.tasks || []).some(task => task.status === 'late')) return 'warning';
  if (getProjectProgress(project) >= 100) return 'done';
  return project.status || 'active';
}
function getStatusLabel(status) {
  if (status === 'warning') return 'Có rủi ro';
  if (status === 'done') return 'Hoàn thành';
  return 'Đang chạy';
}
function getDetailPage(projectId) {
  if (window.location.pathname.endsWith('.jsp')) return `GroupDetailServlet?groupId=${encodeURIComponent(projectId)}`;
  return `project-detail.html?projectId=${encodeURIComponent(projectId)}`;
}
function goToProject(projectId) {
  localStorage.setItem('zc_current_project_id', String(projectId));
  window.location.href = getDetailPage(projectId);
}
function updateStats() {
  document.getElementById('totalProjects').textContent = projects.length;
  document.getElementById('activeProjects').textContent = projects.filter(p => getProjectStatus(p) === 'active').length;
  document.getElementById('totalMembers').textContent = projects.reduce((sum, p) => sum + (p.members?.length || 0), 0);
  document.getElementById('totalTasks').textContent = projects.reduce((sum, p) => sum + (p.tasks?.length || 0), 0);
}
function renderSidebarProjects() {
  if (!sidebarProjectList) return;
  sidebarProjectList.innerHTML = projects.map(project => `
    <a href="${getDetailPage(project.id)}" title="${project.name}">
      <span>${project.name}</span><em>${project.members?.length || 0}</em>
    </a>`).join('') || '<a href="#"><span>Chưa có dự án</span></a>';
}
function renderProjects() {
  autoMarkLateTasks();
  const keyword = (searchProjectInput?.value || '').trim().toLowerCase();
  const status = statusFilter?.value || 'all';
  const filtered = projects.filter(project => {
    project.status = getProjectStatus(project);
    const desc = project.desc || project.description || '';
    const matchKeyword = String(project.name || '').toLowerCase().includes(keyword) || desc.toLowerCase().includes(keyword) || String(project.id).includes(keyword);
    const matchStatus = status === 'all' || project.status === status;
    return matchKeyword && matchStatus;
  });
  projectList.innerHTML = filtered.map(project => {
    const progress = getProjectProgress(project);
    project.progress = progress;
    const isLeader = String(project.creatorId) === String(currentUser.userId);
    return `
      <article class="project-card" role="button" tabindex="0" data-project-id="${project.id}">
        <div class="project-top">
          <div><span class="badge ${project.status}">${getStatusLabel(project.status)}</span><h3>${project.name}</h3></div>
          <button class="detail-link" type="button" data-project-id="${project.id}">Chi tiết</button>
        </div>
        <p>${project.desc || project.description || 'Chưa có mô tả cho dự án này.'}</p>
        <div class="progress-row"><span>Tiến độ</span><strong>${progress}%</strong></div>
        <div class="progress-bar"><div style="width:${progress}%"></div></div>
        <div class="project-meta">
          <span>ID: ${project.id}</span>
          <span>${project.members?.length || 0} thành viên</span>
          <span>${project.tasks?.length || 0} task</span>
          <span>${isLeader ? 'Bạn là nhóm trưởng' : 'Bạn là thành viên'}</span>
          <span>Deadline: ${formatDate(project.deadline)}</span>
        </div>
      </article>`;
  }).join('');
  document.querySelectorAll('.project-card').forEach(card => {
    card.addEventListener('click', event => { if (!event.target.closest('.detail-link')) goToProject(card.dataset.projectId); });
    card.addEventListener('keydown', event => { if (event.key === 'Enter') goToProject(card.dataset.projectId); });
  });
  document.querySelectorAll('.detail-link').forEach(btn => btn.addEventListener('click', () => goToProject(btn.dataset.projectId)));
  emptyState.style.display = filtered.length ? 'none' : 'block';
  updateStats();
  renderSidebarProjects();
  saveProjects();
}
function createMemberRow(data = {}) {
  const row = document.createElement('div');
  row.className = 'dynamic-row member-row';
  row.innerHTML = `
    <input class="member-user-id" type="text" placeholder="user_id, VD: minh" value="${data.userId || ''}" required />
    <input class="member-name" type="text" placeholder="Tên thành viên" value="${data.name || ''}" required />
    <input class="member-code" type="text" placeholder="Mã coin, VD: MINH" value="${data.stockCode || ''}" required />
    <input class="member-coin" type="number" min="0" placeholder="Coin" value="${data.coin || 100}" required />
    <button class="remove-btn" type="button">×</button>`;
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
    <button class="remove-btn" type="button" title="Xóa task">×</button>`;
  row.querySelector('.remove-btn').addEventListener('click', () => row.remove());
  taskList.appendChild(row);
}
function openModal() {
  projectModal.classList.add('show'); projectModal.setAttribute('aria-hidden', 'false');
  if (!memberList.children.length) createMemberRow({ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 120 });
  if (!taskList.children.length) createTaskRow({ assignee: currentUser.userId });
}
function closeCreateModal() { projectModal.classList.remove('show'); projectModal.setAttribute('aria-hidden', 'true'); }
function openJoinProjectModal() { joinProjectModal.classList.add('show'); joinProjectModal.setAttribute('aria-hidden', 'false'); }
function closeJoinProjectModal() { joinProjectModal.classList.remove('show'); joinProjectModal.setAttribute('aria-hidden', 'true'); }
function collectMembers() {
  const members = [...document.querySelectorAll('.member-row')].map(row => ({
    userId: slugify(row.querySelector('.member-user-id').value.trim()),
    name: row.querySelector('.member-name').value.trim(),
    stockCode: row.querySelector('.member-code').value.trim().toUpperCase(),
    coin: Number(row.querySelector('.member-coin').value),
    role: 'member'
  })).filter(member => member.userId && member.stockCode && member.name);
  const leaderIndex = members.findIndex(member => member.userId === currentUser.userId);
  if (leaderIndex >= 0) members[leaderIndex].role = 'leader';
  else members.unshift({ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 120, role: 'leader' });
  return members;
}
function collectTasks() {
  return [...document.querySelectorAll('.task-row')].map(row => ({
    title: row.querySelector('.task-title').value.trim(),
    assignee: slugify(row.querySelector('.task-assignee').value.trim()),
    deadline: row.querySelector('.task-deadline').value,
    impactCoin: Number(row.querySelector('.task-impact').value),
    status: 'todo', update: '', submission: '', rating: 0, ratings: {}
  })).filter(task => task.title && task.assignee);
}

openCreateModal?.addEventListener('click', openModal);
openJoinModal?.addEventListener('click', openJoinProjectModal);
closeModal?.addEventListener('click', closeCreateModal);
closeJoinModal?.addEventListener('click', closeJoinProjectModal);
cancelCreateBtn?.addEventListener('click', closeCreateModal);
cancelJoinBtn?.addEventListener('click', closeJoinProjectModal);
addMemberBtn?.addEventListener('click', () => createMemberRow());
addTaskBtn?.addEventListener('click', () => createTaskRow());
projectMenuToggle?.addEventListener('click', () => sidebarProjectList?.classList.toggle('collapsed'));
searchProjectInput?.addEventListener('input', renderProjects);
statusFilter?.addEventListener('change', renderProjects);
projectModal?.addEventListener('click', event => { if (event.target === projectModal) closeCreateModal(); });
joinProjectModal?.addEventListener('click', event => { if (event.target === joinProjectModal) closeJoinProjectModal(); });

createProjectForm?.addEventListener('submit', event => {
  const projectName = document.getElementById('projectName').value.trim();
  if (!projectName) { event.preventDefault(); alert('Vui lòng nhập tên dự án.'); return; }

  // JSP/Tomcat: backend GroupServlet hiện nhận groupName; các trường khác giữ để UI không vỡ.
  if (IS_JSP_PAGE) return;

  event.preventDefault();
  const members = collectMembers();
  const tasks = collectTasks();
  if (!members.length) return alert('Vui lòng thêm ít nhất 1 thành viên cho dự án.');
  if (!tasks.length) return alert('Vui lòng thêm ít nhất 1 task cho dự án.');
  const labels = ['IPO'];
  const series = {};
  members.forEach(member => { const base = Number(member.coin || 100); series[member.userId] = [base]; });
  const newProject = {
    id: Date.now(), name: projectName, desc: document.getElementById('projectDesc').value.trim(),
    deadline: document.getElementById('projectDeadline').value, status: 'active',
    creatorId: currentUser.userId, creatorName: currentUser.displayName,
    members, pendingRequests: [], tasks, coinHistory: { labels, series }, progress: 0
  };
  projects.unshift(newProject); saveProjects();
  createProjectForm.reset(); memberList.innerHTML = ''; taskList.innerHTML = '';
  closeCreateModal(); goToProject(newProject.id);
});

joinProjectForm?.addEventListener('submit', event => {
  const groupId = document.getElementById('joinGroupId').value.trim();
  if (!groupId) { event.preventDefault(); alert('Vui lòng nhập Group ID.'); return; }

  // JSP/Tomcat: gửi request cho backend xử lý duyệt vào nhóm.
  if (IS_JSP_PAGE) return;

  event.preventDefault();
  const project = projects.find(p => String(p.id) === String(groupId));
  if (!project) return alert('Không tìm thấy dự án trong bản preview localStorage. Khi chạy JSP, backend sẽ xử lý Group ID này.');
  project.pendingRequests = project.pendingRequests || [];
  if ((project.members || []).some(m => String(m.userId) === currentUser.userId)) return alert('Bạn đã là thành viên của dự án này.');
  if (project.pendingRequests.some(r => String(r.userId) === currentUser.userId)) return alert('Bạn đã gửi yêu cầu tham gia, hãy chờ nhóm trưởng duyệt.');
  project.pendingRequests.push({ userId: currentUser.userId, name: currentUser.displayName, requestedAt: new Date().toLocaleString('vi-VN') });
  saveProjects(); closeJoinProjectModal();
  alert('Đã gửi yêu cầu tham gia. Hãy chờ nhóm trưởng duyệt.');
});

logoutBtn?.addEventListener('click', () => {
  localStorage.removeItem('zc_logged_in'); localStorage.removeItem('isLoggedIn');
  localStorage.removeItem('zc_user_name'); localStorage.removeItem('zc_user_id');
  window.location.href = IS_JSP_PAGE ? 'LogoutServlet' : 'index.html';
});

saveProjects();
renderProjects();
