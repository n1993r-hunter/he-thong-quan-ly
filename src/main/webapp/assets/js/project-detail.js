const IS_JSP_PAGE = window.location.pathname.endsWith('.jsp');
const STORAGE_KEY = 'zc_projects';
let projects = [];
let currentProject = null;
let selectedMemberIndex = null;

const backendUser = window.ZC_BACKEND_USER || null;
const backendGroup = window.ZC_BACKEND_GROUP || null;
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
  const displayName = backendUser?.fullName || backendUser?.username || localStorage.getItem('zc_user_name') || 'Team Member';
  const userId = String(backendUser?.id || localStorage.getItem('zc_user_id') || slugify(displayName));
  localStorage.setItem('zc_user_id', userId);
  localStorage.setItem('zc_user_name', displayName);
  return { userId, displayName };
}

const currentUser = getCurrentUser();

function requireLogin() {
  const loggedIn = localStorage.getItem('zc_logged_in') === 'true' || localStorage.getItem('isLoggedIn') === 'true' || !!backendUser;
  if (!loggedIn && !IS_JSP_PAGE) window.location.href = 'index.html';
}

function stripDemoProjects(list) {
  return (Array.isArray(list) ? list : []).filter(p => {
    const id = String(p?.id || '').toLowerCase();
    const name = String(p?.name || '').toLowerCase();
    return !id.includes('demo') && !name.includes('web tracking behavior');
  });
}
function saveProjects() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(stripDemoProjects(projects)));
}

function loadProjects() {
  try { projects = stripDemoProjects(JSON.parse(localStorage.getItem(STORAGE_KEY)) || []); }
  catch { projects = []; }
  saveProjects();
}

function getProjectId() {
  const params = new URLSearchParams(window.location.search);
  return String(params.get('groupId') || params.get('projectId') || params.get('id') || backendGroup?.id || localStorage.getItem('zc_current_project_id') || '');
}

function makeBackendProject() {
  const id = String(backendGroup?.id || getProjectId() || Date.now());
  const isLead = backendGroup?.isLeader === true || String(backendGroup?.createdBy || '') === String(currentUser.userId);
  return {
    id,
    groupId: id,
    name: backendGroup?.name || `Dự án #${id}`,
    desc: `Group ID: ${id}`,
    deadline: '',
    status: 'active',
    creatorId: isLead ? currentUser.userId : String(backendGroup?.createdBy || ''),
    creatorName: isLead ? currentUser.displayName : 'Nhóm trưởng',
    members: [
      { userId: currentUser.userId, name: currentUser.displayName, stockCode: isLead ? 'LEAD' : 'ME', coin: 100, role: isLead ? 'leader' : 'member' }
    ],
    tasks: [],
    coinHistory: { labels: ['IPO'], series: { [currentUser.userId]: [100] } },
    progress: 0,
    fromBackendShell: true
  };
}

function normalizeProject(project) {
  project.id = String(project.id || project.groupId || getProjectId() || Date.now());
  project.groupId = String(project.groupId || project.id);
  project.name = project.name || project.groupName || backendGroup?.name || `Dự án #${project.id}`;
  project.desc = project.desc || project.description || `Group ID: ${project.groupId}`;
  project.creatorId = String(project.creatorId || project.ownerId || project.createdBy || backendGroup?.createdBy || currentUser.userId);
  project.creatorName = project.creatorName || project.ownerName || project.createdByName || 'Nhóm trưởng';
  project.members = Array.isArray(project.members) ? project.members : [];
  project.tasks = Array.isArray(project.tasks) ? project.tasks : [];

  if (!project.members.length) {
    const isLead = backendGroup?.isLeader === true || String(project.creatorId) === String(currentUser.userId);
    project.members = [{ userId: currentUser.userId, name: currentUser.displayName, stockCode: isLead ? 'LEAD' : 'ME', coin: 100, role: isLead ? 'leader' : 'member' }];
  }

  project.members.forEach((member, index) => {
    member.userId = String(member.userId || member.user_id || member.id || slugify(member.username || member.name || `u${index + 1}`));
    member.username = member.username || member.userId;
    member.name = member.name || member.fullName || member.username || member.userId;
    member.stockCode = String(member.stockCode || member.code || member.username || member.name || member.userId).toUpperCase().slice(0, 6);
    member.coin = Number(member.coin ?? member.initialCoin ?? 100);
    member.role = String(member.userId) === String(project.creatorId) || member.role === 'leader' ? 'leader' : (member.role || 'member');
  });

  project.members.forEach(member => {
    if (Array.isArray(member.tasks)) {
      member.tasks.forEach(task => {
        if (!project.tasks.some(t => t.title === task.title && String(t.assignee) === String(member.userId))) {
          project.tasks.push({ ...task, assignee: member.userId });
        }
      });
    }
  });

  project.tasks.forEach((task) => {
    task.assignee = String(task.assignee || task.userId || task.memberId || project.members[0]?.userId || currentUser.userId);
    task.title = task.title || task.name || 'Task chưa đặt tên';
    task.deadline = task.deadline || '';
    task.status = task.status || 'todo';
    task.update = task.update || '';
    task.submission = task.submission || '';
    task.rating = Number(task.rating || 0);
    task.ratings = task.ratings || {};
  });

  project.members.forEach(member => { member.tasks = project.tasks.filter(task => String(task.assignee) === String(member.userId)); });

  if (!project.coinHistory || !project.coinHistory.series) project.coinHistory = { labels: ['IPO'], series: {} };
  if (!Array.isArray(project.coinHistory.labels) || !project.coinHistory.labels.length) project.coinHistory.labels = ['IPO'];
  project.members.forEach(member => {
    if (!project.coinHistory.series[member.userId]) project.coinHistory.series[member.userId] = [Number(member.coin || 100)];
  });

  autoMarkLateTasks(project);
  recalcProjectProgress(project);
  return project;
}

function findCurrentProject() {
  const id = getProjectId();
  currentProject = projects.find(p => String(p.id) === String(id) || String(p.groupId) === String(id));
  if (!currentProject && backendGroup) {
    currentProject = makeBackendProject();
    projects.unshift(currentProject);
  }
  if (!currentProject && projects.length) currentProject = projects[0];
  if (!currentProject) currentProject = makeBackendProject();
  currentProject = normalizeProject(currentProject);
  saveProjects();
}

function isLeader() { return backendGroup?.isLeader === true || String(currentProject.creatorId) === String(currentUser.userId); }
function canEditMember(member) { return String(member.userId) === String(currentUser.userId) || isLeader(); }
function canSubmitWork(member) { return String(member.userId) === String(currentUser.userId); }
function canUpdateProjectProgress() { return isLeader() || currentProject.tasks.some(task => String(task.assignee) === String(currentUser.userId)); }

function shortCode(name) { return String(name || 'PJ').split(/\s+/).map(w => w[0]).join('').slice(0, 5).toUpperCase() || 'PJ'; }
function formatDate(date) { if (!date) return '--'; const d = new Date(date); return Number.isNaN(d.getTime()) ? date : d.toLocaleDateString('vi-VN'); }
function isOverdue(dateString) { if (!dateString) return false; const today = new Date(); today.setHours(0,0,0,0); const d = new Date(dateString); d.setHours(0,0,0,0); return !Number.isNaN(d.getTime()) && d < today; }
function autoMarkLateTasks(project = currentProject) { (project.tasks || []).forEach(task => { if (task.status !== 'done' && isOverdue(task.deadline)) task.status = 'late'; }); }
function recalcProjectProgress(project = currentProject) { const tasks = project.tasks || []; project.progress = tasks.length ? Math.round(tasks.filter(t => t.status === 'done').length / tasks.length * 100) : 0; return project.progress; }
function calcMemberChange(member) { const values = currentProject.coinHistory.series[member.userId] || [member.coin]; const last = Number(values.at(-1) || member.coin || 0); const prev = Number(values.at(-2) || values[0] || 100); const diff = last - prev; const pct = prev ? diff / prev * 100 : 0; return { diff, pct, last, prev }; }

function renderHeader() {
  document.getElementById('currentUserName') && (document.getElementById('currentUserName').textContent = currentUser.displayName);
  document.getElementById('currentUserRole') && (document.getElementById('currentUserRole').textContent = isLeader() ? 'Bạn là nhóm trưởng' : 'Bạn là thành viên');
  document.getElementById('roleNote') && (document.getElementById('roleNote').textContent = `Group ID: ${currentProject.groupId || currentProject.id}`);
  document.getElementById('projectName') && (document.getElementById('projectName').textContent = currentProject.name);
  document.getElementById('projectDesc') && (document.getElementById('projectDesc').innerHTML = `Group ID: <strong id="groupIdText">${currentProject.groupId || currentProject.id}</strong> <button class="secondary-btn" id="copyGroupIdBtn" type="button" style="padding:8px 10px;margin-left:8px">Copy Group ID</button>`);
  document.getElementById('sidebarProjectCode') && (document.getElementById('sidebarProjectCode').textContent = `#${currentProject.groupId || currentProject.id}`);

  const memberCount = currentProject.members.length;
  const taskCount = currentProject.tasks.length;
  const avgCoin = Math.round(currentProject.members.reduce((sum, m) => sum + Number(m.coin || 0), 0) / Math.max(memberCount, 1));
  const firstAvg = currentProject.members.reduce((sum, m) => sum + Number((currentProject.coinHistory.series[m.userId] || [100])[0]), 0) / Math.max(memberCount, 1);
  const marketChange = firstAvg ? ((avgCoin - firstAvg) / firstAvg) * 100 : 0;

  document.getElementById('memberCount') && (document.getElementById('memberCount').textContent = memberCount);
  document.getElementById('taskCount') && (document.getElementById('taskCount').textContent = taskCount);
  document.getElementById('deadlineText') && (document.getElementById('deadlineText').textContent = currentProject.deadline ? formatDate(currentProject.deadline) : (isLeader() ? 'Leader' : 'Member'));
  document.getElementById('marketIndex') && (document.getElementById('marketIndex').textContent = avgCoin.toFixed(2));
  const marketChangeEl = document.getElementById('marketChange');
  if (marketChangeEl) { marketChangeEl.textContent = `${marketChange >= 0 ? '▲' : '▼'} ${Math.abs(marketChange).toFixed(2)}%`; marketChangeEl.className = marketChange >= 0 ? 'up' : 'down'; }

  const updateBtn = document.getElementById('simulateMarketBtn');
  if (updateBtn) { const allowed = canUpdateProjectProgress(); updateBtn.disabled = !allowed; updateBtn.title = allowed ? 'Nhóm trưởng hoặc người thực hiện task có thể cập nhật tiến độ.' : 'Bạn chỉ có quyền xem và đánh giá dự án này.'; }
  setTimeout(() => document.getElementById('copyGroupIdBtn')?.addEventListener('click', copyGroupId), 0);
}

function renderSidebarProjects() {
  if (!sidebarProjectList) return;
  sidebarProjectList.innerHTML = projects.map(project => {
    const active = String(project.id) === String(currentProject?.id) ? 'active' : '';
    const href = IS_JSP_PAGE ? `GroupDetailServlet?groupId=${encodeURIComponent(project.groupId || project.id)}` : `project-detail.html?projectId=${encodeURIComponent(project.id)}`;
    return `<a class="${active}" href="${href}" title="${project.name}"><span>${project.name}</span><em>#${project.groupId || project.id}</em></a>`;
  }).join('') || '<a href="MyGroupsServlet"><span>Chưa có dự án</span></a>';
}

function renderTickerAndBoard() {
  const board = document.getElementById('marketBoard');
  if (!board) return;
  board.innerHTML = currentProject.members.map(member => {
    const change = calcMemberChange(member);
    const cls = change.diff >= 0 ? 'up' : 'down';
    return `<div class="board-row"><div><div class="board-code">${member.stockCode}</div><div class="board-name">${member.name}${member.role === 'leader' ? ' · Nhóm trưởng' : ''}</div></div><div class="board-price">${change.last}</div><div class="board-change ${cls}">${change.diff >= 0 ? '+' : ''}${change.diff}</div></div>`;
  }).join('');
}

function renderMembers() {
  const grid = document.getElementById('memberGrid');
  if (!grid) return;
  grid.innerHTML = currentProject.members.map((member, index) => {
    const tasks = member.tasks && member.tasks.length ? member.tasks.slice(0, 3).map(task => `<div class="task-line"><div><strong>${task.title}</strong><span>Deadline: ${formatDate(task.deadline)}</span></div></div>`).join('') : '<div class="task-line"><div><strong>Chưa có task</strong><span>Backend chưa gửi dữ liệu task cho thành viên này.</span></div></div>';
    const kickForm = isLeader() && String(member.userId) !== String(currentUser.userId)
      ? `<form action="KickMemberServlet" method="post" style="margin:10px 0"><input type="hidden" name="groupId" value="${currentProject.groupId || currentProject.id}"><input type="hidden" name="username" value="${member.username || member.userId}"><button class="ghost-btn" type="submit" style="width:100%">Kick thành viên</button></form>` : '';
    return `<article class="member-card ${member.role === 'leader' ? 'leader' : ''}"><div class="member-top"><div class="member-info"><div class="avatar">${shortCode(member.name).slice(0,2)}</div><div><h3>${member.name}</h3><p>${member.stockCode} · ${member.tasks?.length || 0} task được giao</p></div></div><span class="coin-pill">${member.coin} COIN</span></div>${member.role === 'leader' ? '<span class="role-pill">Nhóm trưởng</span>' : ''}<div class="task-list">${tasks}</div>${kickForm}<button class="detail-btn" type="button" data-member-index="${index}">Chi tiết</button></article>`;
  }).join('');
  document.querySelectorAll('.detail-btn').forEach(btn => btn.addEventListener('click', () => openTaskModal(Number(btn.dataset.memberIndex))));
}

function drawChart() {
  const canvas = document.getElementById('coinChart');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  ctx.clearRect(0, 0, width, height);

  const padding = { left: 76, right: 34, top: 42, bottom: 64 };
  const labels = currentProject.coinHistory.labels || ['IPO'];
  const allValues = Object.values(currentProject.coinHistory.series || {}).flat().map(Number);
  const minValue = Math.floor(Math.min(...allValues, 80) / 10) * 10 - 10;
  const maxValue = Math.ceil(Math.max(...allValues, 130) / 10) * 10 + 10;
  const plotW = width - padding.left - padding.right;
  const plotH = height - padding.top - padding.bottom;
  const colors = ['#22c55e', '#38bdf8', '#facc15', '#fb7185', '#a78bfa', '#f97316', '#2dd4bf'];

  const bg = ctx.createLinearGradient(0, 0, 0, height);
  bg.addColorStop(0, '#07111f');
  bg.addColorStop(1, '#020617');
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, width, height);

  ctx.lineWidth = 1;
  ctx.strokeStyle = 'rgba(148,163,184,.10)';
  for (let i = 0; i <= 10; i++) { const x = padding.left + (plotW / 10) * i; ctx.beginPath(); ctx.moveTo(x, padding.top); ctx.lineTo(x, height - padding.bottom); ctx.stroke(); }
  ctx.font = '13px Inter';
  for (let i = 0; i <= 6; i++) { const y = padding.top + (plotH / 6) * i; const value = Math.round(maxValue - ((maxValue - minValue) / 6) * i); ctx.strokeStyle = i === 6 ? 'rgba(148,163,184,.24)' : 'rgba(148,163,184,.12)'; ctx.beginPath(); ctx.moveTo(padding.left, y); ctx.lineTo(width - padding.right, y); ctx.stroke(); ctx.fillStyle = '#94a3b8'; ctx.fillText(value, 24, y + 4); }

  const refY = padding.top + plotH - ((100 - minValue) / (maxValue - minValue)) * plotH;
  ctx.setLineDash([8, 8]); ctx.strokeStyle = 'rgba(250,204,21,.28)'; ctx.beginPath(); ctx.moveTo(padding.left, refY); ctx.lineTo(width - padding.right, refY); ctx.stroke(); ctx.setLineDash([]);
  ctx.fillStyle = '#fde68a'; ctx.fillText('IPO 100', width - padding.right - 58, refY - 8);

  labels.forEach((label, i) => { const x = padding.left + (plotW / Math.max(labels.length - 1, 1)) * i; ctx.fillStyle = '#94a3b8'; ctx.fillText(label, x - 12, height - 24); });
  ctx.fillStyle = '#cbd5e1'; ctx.font = '800 13px Inter'; ctx.fillText('Phiên cập nhật', width / 2 - 48, height - 8); ctx.save(); ctx.translate(18, height / 2 + 30); ctx.rotate(-Math.PI / 2); ctx.fillText('Số coin', 0, 0); ctx.restore();

  currentProject.members.forEach((member, idx) => {
    const values = currentProject.coinHistory.series[member.userId] || [member.coin];
    const color = colors[idx % colors.length];
    const points = values.map((value, i) => ({ x: padding.left + (plotW / Math.max(values.length - 1, 1)) * i, y: padding.top + plotH - ((Number(value) - minValue) / (maxValue - minValue)) * plotH, value: Number(value) }));
    ctx.strokeStyle = color; ctx.lineWidth = 3.5; ctx.beginPath(); points.forEach((p, i) => i === 0 ? ctx.moveTo(p.x, p.y) : ctx.lineTo(p.x, p.y)); ctx.stroke();
    points.forEach((p, i) => { const prev = values[i - 1] ?? p.value; const candleColor = p.value >= prev ? '#22c55e' : '#fb7185'; ctx.strokeStyle = candleColor; ctx.lineWidth = 2; ctx.beginPath(); ctx.moveTo(p.x, p.y - 11); ctx.lineTo(p.x, p.y + 11); ctx.stroke(); ctx.fillStyle = candleColor; ctx.fillRect(p.x - 4, Math.min(p.y, p.y + (p.value >= prev ? -7 : 7)), 8, 14); });
    const last = points.at(-1); ctx.fillStyle = color; ctx.font = '900 13px Inter'; ctx.fillText(`${member.stockCode} ${values.at(-1)}`, Math.min(last.x + 10, width - 110), last.y - 8);
  });

  const legend = document.getElementById('chartLegend');
  if (legend) legend.innerHTML = currentProject.members.map((member, idx) => { const change = calcMemberChange(member); const cls = change.diff >= 0 ? 'up' : 'down'; return `<span class="legend-item"><i class="legend-dot" style="background:${colors[idx % colors.length]}"></i>${member.stockCode} · ${member.name} <b class="${cls}">${change.diff >= 0 ? '+' : ''}${change.diff}</b></span>`; }).join('');
}

function renderAll() { renderSidebarProjects(); renderHeader(); renderTickerAndBoard(); renderMembers(); drawChart(); }

function openTaskModal(index) {
  selectedMemberIndex = index;
  const member = currentProject.members[index];
  const editable = canEditMember(member);
  const submitEditable = canSubmitWork(member);
  document.getElementById('modalMemberName').textContent = `${member.name} - ${member.stockCode}`;
  document.getElementById('modalMemberMeta').textContent = editable ? (submitEditable ? 'Bạn có thể cập nhật bài làm, trạng thái và deadline của task này.' : 'Nhóm trưởng có thể cập nhật trạng thái/deadline và theo dõi bài làm.') : 'Bạn đang xem bài làm của thành viên khác: có thể xem chi tiết và đánh giá sao.';

  const tasks = member.tasks && member.tasks.length ? member.tasks : [{ title: 'Chưa có task', assignee: member.userId, deadline: '', status: 'todo', submission: '', update: '', rating: 0, ratings: {} }];
  member.tasks = tasks;
  document.getElementById('modalTaskBody').innerHTML = tasks.map((task, taskIndex) => {
    const myRating = Number(task.ratings?.[currentUser.userId] || task.rating || 0);
    return `<tr><td><strong>${task.title}</strong></td><td>${editable ? `<input type="date" data-task-index="${taskIndex}" data-field="deadline" value="${task.deadline || ''}">` : formatDate(task.deadline)}</td><td><select data-task-index="${taskIndex}" data-field="status" ${editable ? '' : 'disabled'}><option value="todo" ${task.status==='todo'?'selected':''}>Chưa làm</option><option value="doing" ${task.status==='doing'?'selected':''}>Đang làm</option><option value="done" ${task.status==='done'?'selected':''}>Hoàn thành</option><option value="late" ${task.status==='late'?'selected':''}>Trễ hạn</option></select></td><td><textarea rows="3" data-task-index="${taskIndex}" data-field="submission" placeholder="Dán link bài làm hoặc ghi chú cập nhật..." ${submitEditable ? '' : 'readonly'}>${task.submission || task.update || ''}</textarea></td><td><div class="rating-box"><div class="stars" data-task-index="${taskIndex}">${[1,2,3,4,5].map(star => `<button class="star ${myRating>=star?'active':''}" type="button" data-star="${star}" aria-label="${star} sao">★</button>`).join('')}</div><small>${myRating ? myRating + '/5' : 'Chưa chấm'}</small></div></td></tr>`;
  }).join('');

  document.querySelectorAll('.stars').forEach(group => {
    group.querySelectorAll('.star').forEach(starBtn => {
      starBtn.addEventListener('click', () => {
        const rating = Number(starBtn.dataset.star);
        const taskIndex = Number(group.dataset.taskIndex);
        const task = member.tasks[taskIndex];
        task.ratings = task.ratings || {};
        task.ratings[currentUser.userId] = rating;
        const ratings = Object.values(task.ratings).map(Number);
        task.rating = ratings.length ? Math.round(ratings.reduce((a,b) => a + b, 0) / ratings.length) : rating;
        group.querySelectorAll('.star').forEach(btn => btn.classList.toggle('active', Number(btn.dataset.star) <= rating));
        group.parentElement.querySelector('small').textContent = `${rating}/5`;
      });
    });
  });
  document.getElementById('saveTaskUpdates').textContent = editable ? 'Lưu thay đổi' : 'Lưu đánh giá';
  document.getElementById('taskModal').classList.add('show');
}

function saveTaskUpdates() {
  const member = currentProject.members[selectedMemberIndex];
  const editable = canEditMember(member);
  if (editable) {
    document.querySelectorAll('#modalTaskBody [data-field]').forEach(field => {
      const task = member.tasks[Number(field.dataset.taskIndex)];
      task[field.dataset.field] = field.value;
      if (!currentProject.tasks.includes(task) && task.title !== 'Chưa có task') currentProject.tasks.push(task);
    });
  }
  autoMarkLateTasks(currentProject);
  recalcProjectProgress(currentProject);
  let coinChange = 0;
  member.tasks.forEach(task => { if (task.status === 'done' && Number(task.rating) >= 4) coinChange += 2; if (task.status === 'late') coinChange -= 2; });
  member.coin = Math.max(0, Number(member.coin) + coinChange);
  const series = currentProject.coinHistory.series[member.userId] || [];
  series.push(member.coin);
  currentProject.coinHistory.series[member.userId] = series;
  if (currentProject.coinHistory.labels.length < series.length) currentProject.coinHistory.labels.push(`D${currentProject.coinHistory.labels.length}`);
  saveProjects();
  document.getElementById('taskModal').classList.remove('show');
  renderAll();
}

function simulateMarket() {
  if (!canUpdateProjectProgress()) { alert('Chỉ nhóm trưởng hoặc người thực hiện task trong dự án mới có thể cập nhật tiến độ.'); return; }
  autoMarkLateTasks(currentProject);
  recalcProjectProgress(currentProject);
  currentProject.coinHistory.labels.push(`D${currentProject.coinHistory.labels.length}`);
  currentProject.members.forEach(member => {
    const done = member.tasks.filter(t => t.status === 'done').length;
    const late = member.tasks.filter(t => t.status === 'late').length;
    const random = Math.floor(Math.random() * 9) - 3;
    const delta = random + done * 2 - late * 2;
    member.coin = Math.max(0, Number(member.coin) + delta);
    currentProject.coinHistory.series[member.userId] = currentProject.coinHistory.series[member.userId] || [100];
    currentProject.coinHistory.series[member.userId].push(member.coin);
  });
  saveProjects();
  renderAll();
}

function copyGroupId() {
  const groupId = String(currentProject.groupId || currentProject.id);
  navigator.clipboard?.writeText(groupId).then(() => alert(`Đã copy Group ID: ${groupId}`)).catch(() => prompt('Copy Group ID:', groupId));
}

function init() {
  requireLogin();
  loadProjects();
  findCurrentProject();
  renderAll();
  document.getElementById('logoutBtn')?.addEventListener('click', () => { localStorage.removeItem('zc_logged_in'); localStorage.removeItem('isLoggedIn'); localStorage.removeItem('zc_user_name'); localStorage.removeItem('zc_user_id'); window.location.href = IS_JSP_PAGE ? 'LogoutServlet' : 'index.html'; });
  document.getElementById('closeTaskModal')?.addEventListener('click', () => document.getElementById('taskModal').classList.remove('show'));
  document.getElementById('taskModal')?.addEventListener('click', e => { if (e.target.id === 'taskModal') e.currentTarget.classList.remove('show'); });
  document.getElementById('saveTaskUpdates')?.addEventListener('click', saveTaskUpdates);
  document.getElementById('simulateMarketBtn')?.addEventListener('click', simulateMarket);
  if (projectMenuToggle) projectMenuToggle.addEventListener('click', () => sidebarProjectList?.classList.toggle('collapsed'));
}

document.addEventListener('DOMContentLoaded', init);
