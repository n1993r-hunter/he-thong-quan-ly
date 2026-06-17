// Project Hub: JSP/Tomcat dùng dữ liệu backend render sẵn; HTML preview dùng localStorage rỗng, không có demo/mock.
const IS_JSP_PAGE = window.location.pathname.endsWith('.jsp');
const IS_STATIC_PREVIEW = ['file:', 'blob:'].includes(window.location.protocol) || window.location.pathname.endsWith('.html');
const STORAGE_KEY = 'zc_projects';

(function protectPage() {
  if (!IS_STATIC_PREVIEW || IS_JSP_PAGE) return;
  const isLoggedIn = localStorage.getItem('zc_logged_in') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  if (!isLoggedIn) window.location.href = 'index.html';
})();

function cleanOldDemoProjects() {
  try {
    const old = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
    const cleaned = old.filter(p => String(p.id) !== 'demo-web-tracking' && !/Web Tracking Behavior/i.test(String(p.name || '')));
    if (cleaned.length !== old.length) localStorage.setItem(STORAGE_KEY, JSON.stringify(cleaned));
  } catch { localStorage.setItem(STORAGE_KEY, '[]'); }
}
cleanOldDemoProjects();

const projectModal = document.getElementById('projectModal');
const joinModal = document.getElementById('joinModal');
const openCreateModal = document.getElementById('openCreateModal');
const closeModal = document.getElementById('closeModal');
const cancelCreateBtn = document.getElementById('cancelCreateBtn');
const openJoinModal = document.getElementById('openJoinModal');
const closeJoinModal = document.getElementById('closeJoinModal');
const createProjectForm = document.getElementById('createProjectForm');
const joinProjectForm = document.getElementById('joinProjectForm');
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
    .replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'user';
}
function getCurrentUser() {
  const be = window.ZC_BACKEND_USER || {};
  const displayName = be.fullName || be.username || localStorage.getItem('zc_user_name') || 'Team Member';
  const userId = String(be.id || localStorage.getItem('zc_user_id') || slugify(displayName));
  localStorage.setItem('zc_user_id', userId);
  localStorage.setItem('zc_user_name', displayName);
  return { userId, displayName };
}
const currentUser = getCurrentUser();
if (currentUserName) currentUserName.textContent = currentUser.displayName;

function getDetailPage(groupId) {
  return IS_JSP_PAGE ? `GroupDetailServlet?groupId=${encodeURIComponent(groupId)}` : `project-detail.html?projectId=${encodeURIComponent(groupId)}`;
}
function goToProject(groupId) {
  localStorage.setItem('zc_current_project_id', String(groupId));
  window.location.href = getDetailPage(groupId);
}
function attachProjectClicks(root = document) {
  root.querySelectorAll('.project-card').forEach(card => {
    card.addEventListener('click', e => { if (!e.target.closest('.detail-link')) goToProject(card.dataset.projectId); });
    card.addEventListener('keydown', e => { if (e.key === 'Enter') goToProject(card.dataset.projectId); });
  });
  root.querySelectorAll('.detail-link').forEach(btn => btn.addEventListener('click', () => goToProject(btn.dataset.projectId)));
}

function filterBackendCards() {
  if (!projectList) return;
  const keyword = (searchProjectInput?.value || '').trim().toLowerCase();
  let shown = 0;
  projectList.querySelectorAll('.project-card').forEach(card => {
    const text = card.textContent.toLowerCase();
    const ok = !keyword || text.includes(keyword);
    card.style.display = ok ? '' : 'none';
    if (ok) shown++;
  });
  if (emptyState) emptyState.style.display = shown ? 'none' : 'block';
}

function renderStaticProjects() {
  if (!projectList || IS_JSP_PAGE) return;
  let projects = [];
  try { projects = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); } catch { projects = []; }
  const keyword = (searchProjectInput?.value || '').trim().toLowerCase();
  const filtered = projects.filter(p => String(p.name || '').toLowerCase().includes(keyword) || String(p.desc || '').toLowerCase().includes(keyword));
  projectList.innerHTML = filtered.map(p => `
    <article class="project-card" role="button" tabindex="0" data-project-id="${p.id}">
      <div class="project-top"><div><span class="badge active">Đang chạy</span><h3>${p.name}</h3></div><button class="detail-link" type="button" data-project-id="${p.id}">Chi tiết</button></div>
      <p>${p.desc || 'Chưa có mô tả.'}</p><div class="project-meta"><span>ID: ${p.id}</span><span>${(p.members || []).length} thành viên</span></div>
    </article>`).join('');
  if (emptyState) emptyState.style.display = filtered.length ? 'none' : 'block';
  document.getElementById('totalProjects') && (document.getElementById('totalProjects').textContent = projects.length);
  document.getElementById('activeProjects') && (document.getElementById('activeProjects').textContent = projects.length);
  attachProjectClicks(projectList);
}

openCreateModal?.addEventListener('click', () => { projectModal?.classList.add('show'); projectModal?.setAttribute('aria-hidden', 'false'); });
closeModal?.addEventListener('click', () => { projectModal?.classList.remove('show'); projectModal?.setAttribute('aria-hidden', 'true'); });
cancelCreateBtn?.addEventListener('click', () => { projectModal?.classList.remove('show'); projectModal?.setAttribute('aria-hidden', 'true'); });
projectModal?.addEventListener('click', e => { if (e.target === projectModal) projectModal.classList.remove('show'); });

openJoinModal?.addEventListener('click', () => { joinModal?.classList.add('show'); joinModal?.setAttribute('aria-hidden', 'false'); });
closeJoinModal?.addEventListener('click', () => { joinModal?.classList.remove('show'); joinModal?.setAttribute('aria-hidden', 'true'); });
joinModal?.addEventListener('click', e => { if (e.target === joinModal) joinModal.classList.remove('show'); });

createProjectForm?.addEventListener('submit', event => {
  const name = document.getElementById('projectName')?.value.trim();
  if (!name) { event.preventDefault(); alert('Vui lòng nhập tên dự án.'); return; }
  if (IS_JSP_PAGE) return; // POST thẳng tới GroupServlet trên Tomcat.
  event.preventDefault();
  let projects = [];
  try { projects = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); } catch { projects = []; }
  const newProject = { id: Date.now(), name, desc: '', members: [{ userId: currentUser.userId, name: currentUser.displayName, role: 'leader', coin: 100, stockCode: 'LEAD' }], tasks: [], progress: 0 };
  projects.unshift(newProject);
  localStorage.setItem(STORAGE_KEY, JSON.stringify(projects));
  goToProject(newProject.id);
});

joinProjectForm?.addEventListener('submit', event => {
  const groupId = document.getElementById('joinGroupId')?.value.trim();
  if (!groupId) { event.preventDefault(); alert('Vui lòng nhập Group ID.'); return; }
  if (IS_JSP_PAGE) return; // POST tới JoinGroupRequestServlet nếu backend có.
  event.preventDefault();
  goToProject(groupId);
});

logoutBtn?.addEventListener('click', () => {
  localStorage.removeItem('zc_logged_in');
  localStorage.removeItem('isLoggedIn');
  localStorage.removeItem('zc_user_name');
  localStorage.removeItem('zc_user_id');
  window.location.href = IS_JSP_PAGE ? 'LogoutServlet' : 'index.html';
});
projectMenuToggle?.addEventListener('click', () => sidebarProjectList?.classList.toggle('collapsed'));
searchProjectInput?.addEventListener('input', () => IS_JSP_PAGE ? filterBackendCards() : renderStaticProjects());
statusFilter?.addEventListener('change', () => IS_JSP_PAGE ? filterBackendCards() : renderStaticProjects());

attachProjectClicks();
if (!IS_JSP_PAGE) renderStaticProjects();
