const IS_JSP_PAGE = window.location.pathname.endsWith('.jsp');
const STORAGE_KEY = 'zc_projects';
let projects = [];
let currentProject = null;
let selectedMemberIndex = null;
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

function createEmptyProject(id = getProjectId()) {
  return {
    id: id || 'new-project',
    name: id ? `Dự án #${id}` : 'Dự án chưa có dữ liệu',
    desc: 'Chưa có dữ liệu chi tiết. Khi chạy JSP, GroupDetailServlet sẽ render dữ liệu thật từ database.',
    deadline: '',
    status: 'active',
    creatorId: currentUser.userId,
    creatorName: currentUser.displayName,
    members: [{ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 100, role: 'leader' }],
    pendingRequests: [],
    tasks: [],
    coinHistory: { labels: ['IPO'], series: { [currentUser.userId]: [100] } },
    progress: 0
  };
}


function addNotification(type, title, text) {
  const list = JSON.parse(localStorage.getItem('zc_notifications') || '[]');
  list.unshift({ type, title, text, time: new Date().toLocaleString('vi-VN') });
  localStorage.setItem('zc_notifications', JSON.stringify(list.slice(0, 80)));
}

function requireLogin() {
  const loggedIn = localStorage.getItem('zc_logged_in') === 'true' || localStorage.getItem('isLoggedIn') === 'true';
  const isJspRuntime = window.location.pathname.endsWith('.jsp');
  if (!loggedIn && !isJspRuntime) window.location.href = IS_JSP_PAGE ? 'LogoutServlet' : 'index.html';
}

function loadProjects() {
  projects = removeDemoProjectsFromStorage();
}
function saveProjects() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(projects));
}

function getProjectId() {
  const params = new URLSearchParams(window.location.search);
  return params.get('projectId') || params.get('groupId') || params.get('id') || localStorage.getItem('zc_current_project_id') || '';
}

function normalizeProject(project) {
  project.desc = project.desc || project.description || 'Chưa có mô tả dự án.';
  project.creatorId = project.creatorId || project.ownerId || project.createdBy || (project.members?.[0]?.userId) || currentUser.userId;
  project.creatorName = project.creatorName || project.ownerName || project.createdByName || 'Nhóm trưởng';
  project.members = project.members && project.members.length ? project.members : [{ userId: currentUser.userId, name: currentUser.displayName, stockCode: 'LEAD', coin: 100, role: 'leader' }];
  project.pendingRequests = project.pendingRequests || [];
  project.tasks = project.tasks && project.tasks.length ? project.tasks : [];

  project.members.forEach((member, index) => {
    member.userId = slugify(member.userId || member.user_id || member.name || `U0${index + 1}`);
    member.name = member.name || member.fullName || member.userId;
    member.stockCode = (member.stockCode || member.code || member.name || member.userId).toUpperCase().slice(0, 6);
    member.coin = Number(member.coin || member.initialCoin || 100);
    member.role = member.userId === project.creatorId ? 'leader' : (member.role || 'member');
  });

  // Nếu dữ liệu cũ lưu task trong từng member, gom ngược về project.tasks.
  project.members.forEach(member => {
    if (Array.isArray(member.tasks)) {
      member.tasks.forEach(task => {
        if (!project.tasks.some(t => t.title === task.title && t.assignee === member.userId)) {
          project.tasks.push({ ...task, assignee: member.userId });
        }
      });
    }
  });

  project.tasks.forEach((task) => {
    task.assignee = slugify(task.assignee || task.userId || task.memberId || project.members[0]?.userId);
    task.title = task.title || task.name || 'Task chưa đặt tên';
    task.status = task.status || 'todo';
    task.update = task.update || '';
    task.submission = task.submission || '';
    task.rating = Number(task.rating || 0);
    task.ratings = task.ratings || {};
  });

  project.members.forEach(member => {
    member.tasks = project.tasks.filter(task => task.assignee === member.userId);
    if (!member.tasks.length) {
      const task = { title: 'Task chưa đặt tên', assignee: member.userId, deadline: project.deadline || '', status: 'todo', update: '', submission: '', rating: 0, ratings: {} };
      project.tasks.push(task);
      member.tasks = [task];
    }
  });

  if (!project.coinHistory) {
    const labels = ['IPO', 'D1', 'D2', 'D3', 'D4'];
    const series = {};
    project.members.forEach((member, index) => {
      const base = Number(member.coin || 100);
      series[member.userId] = [100, 100 + index * 2, Math.round((100 + base) / 2), base - 3, base];
    });
    project.coinHistory = { labels, series };
  }
  project.members.forEach(member => {
    if (!project.coinHistory.series[member.userId]) project.coinHistory.series[member.userId] = [100, member.coin];
  });
  autoMarkLateTasks(project);
  recalcProjectProgress(project);
  return project;
}

function findCurrentProject() {
  const id = getProjectId();
  currentProject = projects.find(p => String(p.id) === String(id)) || createEmptyProject(id);
  currentProject = normalizeProject(currentProject);
  saveProjects();
}

function isLeader() {
  return String(currentProject.creatorId) === String(currentUser.userId);
}

function canEditMember(member) {
  return String(member.userId) === String(currentUser.userId) || isLeader();
}

function canSubmitWork(member) {
  return String(member.userId) === String(currentUser.userId);
}

function shortCode(name) {
  return (name || 'PJ').split(/\s+/).map(word => word[0]).join('').slice(0, 5).toUpperCase();
}

function formatDate(date) {
  if (!date) return '--';
  const d = new Date(date);
  if (Number.isNaN(d.getTime())) return date;
  return d.toLocaleDateString('vi-VN');
}

function isOverdue(dateString) {
  if (!dateString) return false;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const deadline = new Date(dateString);
  deadline.setHours(0, 0, 0, 0);
  return !Number.isNaN(deadline.getTime()) && deadline < today;
}

function autoMarkLateTasks(project = currentProject) {
  let changed = false;
  (project.tasks || []).forEach((task) => {
    if (task.status !== 'done' && isOverdue(task.deadline)) {
      task.status = 'late';
      changed = true;
    }
  });
  return changed;
}

function recalcProjectProgress(project = currentProject) {
  const tasks = project.tasks || [];
  if (!tasks.length) { project.progress = 0; return 0; }
  const done = tasks.filter((task) => task.status === 'done').length;
  project.progress = Math.round((done / tasks.length) * 100);
  return project.progress;
}

function canUpdateProjectProgress() {
  return isLeader() || currentProject.tasks.some((task) => String(task.assignee) === String(currentUser.userId));
}

function calcMemberChange(member) {
  const values = currentProject.coinHistory.series[member.userId] || [member.coin];
  const last = Number(values.at(-1) || member.coin || 0);
  const prev = Number(values.at(-2) || 100);
  const diff = last - prev;
  const pct = prev ? (diff / prev) * 100 : 0;
  return { diff, pct, last, prev };
}

function renderHeader() {
  document.getElementById('currentUserName').textContent = currentUser.displayName;
  document.getElementById('currentUserRole').textContent = isLeader() ? 'Bạn là nhóm trưởng' : 'Bạn là thành viên';
  document.getElementById('roleNote').textContent = isLeader()
    ? 'Bạn là nhóm trưởng: có ghi chú trưởng nhóm, theo dõi toàn bộ bài làm và đánh giá nhóm.'
    : 'Bạn là thành viên: được xem chi tiết, cập nhật bài cá nhân và đánh giá mọi người.';
  document.getElementById('projectName').textContent = currentProject.name;
  document.getElementById('projectDesc').textContent = currentProject.desc;
  document.getElementById('sidebarProjectCode').textContent = shortCode(currentProject.name);
  const groupIdText = document.getElementById('groupIdText');
  if (groupIdText) groupIdText.textContent = currentProject.id || '--';

  const memberCount = currentProject.members.length;
  const taskCount = currentProject.tasks.length;
  const avgCoin = Math.round(currentProject.members.reduce((sum, m) => sum + Number(m.coin || 0), 0) / Math.max(memberCount, 1));
  const firstAvg = currentProject.members.reduce((sum, m) => sum + Number((currentProject.coinHistory.series[m.userId] || [100])[0]), 0) / Math.max(memberCount, 1);
  const marketChange = firstAvg ? ((avgCoin - firstAvg) / firstAvg) * 100 : 0;

  document.getElementById('memberCount').textContent = memberCount;
  document.getElementById('taskCount').textContent = taskCount;
  document.getElementById('deadlineText').textContent = formatDate(currentProject.deadline);
  document.getElementById('marketIndex').textContent = avgCoin.toFixed(2);
  const marketChangeEl = document.getElementById('marketChange');
  marketChangeEl.textContent = `${marketChange >= 0 ? '▲' : '▼'} ${Math.abs(marketChange).toFixed(2)}%`;
  marketChangeEl.className = marketChange >= 0 ? 'up' : 'down';
  const updateBtn = document.getElementById('simulateMarketBtn');
  if (updateBtn) {
    const allowed = canUpdateProjectProgress();
    updateBtn.disabled = !allowed;
    updateBtn.title = allowed ? 'Nhóm trưởng hoặc người thực hiện task có thể cập nhật tiến độ.' : 'Bạn chỉ có quyền xem và đánh giá dự án này.';
  }
}

function statusLabel(status) {
  const map = { todo: 'Chưa làm', doing: 'Đang làm', done: 'Hoàn thành', late: 'Trễ hạn' };
  return map[status] || status;
}

function renderTickerAndBoard() {
  document.getElementById('marketBoard').innerHTML = currentProject.members.map(member => {
    const change = calcMemberChange(member);
    const cls = change.diff >= 0 ? 'up' : 'down';
    return `
      <div class="board-row">
        <div><div class="board-code">${member.stockCode}</div><div class="board-name">${member.name}${member.role === 'leader' ? ' · Nhóm trưởng' : ''}</div></div>
        <div class="board-price">${change.last}</div>
        <div class="board-change ${cls}">${change.diff >= 0 ? '+' : ''}${change.diff}</div>
      </div>`;
  }).join('');
}

function renderMembers() {
  const grid = document.getElementById('memberGrid');
  grid.innerHTML = currentProject.members.map((member, index) => {
    const tasks = member.tasks.slice(0, 3).map(task => `
      <div class="task-line">
        <div><strong>${task.title}</strong><span>Deadline: ${formatDate(task.deadline)}</span></div>
      </div>`).join('');
    return `
      <article class="member-card ${member.role === 'leader' ? 'leader' : ''}">
        <div class="member-top">
          <div class="member-info">
            <div class="avatar">${shortCode(member.name).slice(0,2)}</div>
            <div>
              <h3>${member.name}</h3>
              <p>${member.stockCode} · ${member.tasks.length} task được giao</p>
            </div>
          </div>
          <span class="coin-pill">${member.coin} COIN</span>
        </div>
        ${member.role === 'leader' ? '<span class="role-pill">Nhóm trưởng</span>' : ''}
        <div class="task-list">${tasks}</div>
        <button class="detail-btn" type="button" data-member-index="${index}">Chi tiết</button>
        ${isLeader() && member.role !== 'leader' ? `<button class="ghost-btn kick-member-btn" style="width:100%;margin-top:10px" type="button" data-member-id="${member.userId}">Kick thành viên</button>` : ''}
      </article>`;
  }).join('');
  document.querySelectorAll('.detail-btn').forEach(btn => btn.addEventListener('click', () => openTaskModal(Number(btn.dataset.memberIndex))));
  document.querySelectorAll('.kick-member-btn').forEach(btn => btn.addEventListener('click', () => kickMember(btn.dataset.memberId)));
}

function drawChart() {
  const canvas = document.getElementById('coinChart');
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  ctx.clearRect(0, 0, width, height);

  const padding = { left: 76, right: 34, top: 42, bottom: 64 };
  const labels = currentProject.coinHistory.labels?.length ? currentProject.coinHistory.labels : ['IPO'];
  const allValues = Object.values(currentProject.coinHistory.series).flat().map(Number);
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

  // Professional market grid
  ctx.lineWidth = 1;
  ctx.strokeStyle = 'rgba(148,163,184,.10)';
  for (let i = 0; i <= 10; i++) {
    const x = padding.left + (plotW / 10) * i;
    ctx.beginPath(); ctx.moveTo(x, padding.top); ctx.lineTo(x, height - padding.bottom); ctx.stroke();
  }
  ctx.font = '13px Inter';
  for (let i = 0; i <= 6; i++) {
    const y = padding.top + (plotH / 6) * i;
    const value = Math.round(maxValue - ((maxValue - minValue) / 6) * i);
    ctx.strokeStyle = i === 6 ? 'rgba(148,163,184,.24)' : 'rgba(148,163,184,.12)';
    ctx.beginPath(); ctx.moveTo(padding.left, y); ctx.lineTo(width - padding.right, y); ctx.stroke();
    ctx.fillStyle = '#94a3b8';
    ctx.fillText(value, 24, y + 4);
  }

  // Zero/IPO reference line
  const refY = padding.top + plotH - ((100 - minValue) / (maxValue - minValue)) * plotH;
  ctx.setLineDash([8, 8]);
  ctx.strokeStyle = 'rgba(250,204,21,.28)';
  ctx.beginPath(); ctx.moveTo(padding.left, refY); ctx.lineTo(width - padding.right, refY); ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = '#fde68a';
  ctx.fillText('IPO 100', width - padding.right - 58, refY - 8);

  labels.forEach((label, i) => {
    const x = padding.left + (plotW / Math.max(labels.length - 1, 1)) * i;
    ctx.fillStyle = '#94a3b8';
    ctx.fillText(label, x - 12, height - 24);
  });

  ctx.fillStyle = '#cbd5e1';
  ctx.font = '800 13px Inter';
  ctx.fillText('Phiên cập nhật', width / 2 - 48, height - 8);
  ctx.save(); ctx.translate(18, height / 2 + 30); ctx.rotate(-Math.PI / 2); ctx.fillText('Số coin', 0, 0); ctx.restore();

  currentProject.members.forEach((member, idx) => {
    const values = currentProject.coinHistory.series[member.userId] || [member.coin];
    const color = colors[idx % colors.length];
    const points = values.map((value, i) => ({
      x: padding.left + (plotW / Math.max(values.length - 1, 1)) * i,
      y: padding.top + plotH - ((Number(value) - minValue) / (maxValue - minValue)) * plotH,
      value: Number(value)
    }));

    ctx.shadowBlur = 0;
    ctx.strokeStyle = color;
    ctx.lineWidth = 3.5;
    ctx.beginPath();
    points.forEach((p, i) => i === 0 ? ctx.moveTo(p.x, p.y) : ctx.lineTo(p.x, p.y));
    ctx.stroke();

    points.forEach((p, i) => {
      const prev = values[i - 1] ?? p.value;
      const candleColor = p.value >= prev ? '#22c55e' : '#fb7185';
      ctx.strokeStyle = candleColor;
      ctx.lineWidth = 2;
      ctx.beginPath(); ctx.moveTo(p.x, p.y - 11); ctx.lineTo(p.x, p.y + 11); ctx.stroke();
      ctx.fillStyle = candleColor;
      ctx.fillRect(p.x - 4, Math.min(p.y, p.y + (p.value >= prev ? -7 : 7)), 8, 14);
    });

    const last = points.at(-1);
    ctx.fillStyle = color;
    ctx.font = '900 13px Inter';
    ctx.fillText(`${member.stockCode} ${values.at(-1)}`, Math.min(last.x + 10, width - 110), last.y - 8);
  });

  document.getElementById('chartLegend').innerHTML = currentProject.members.map((member, idx) => {
    const change = calcMemberChange(member);
    const cls = change.diff >= 0 ? 'up' : 'down';
    return `<span class="legend-item"><i class="legend-dot" style="background:${colors[idx % colors.length]};color:${colors[idx % colors.length]}"></i>${member.stockCode} · ${member.name} <b class="${cls}">${change.diff >= 0 ? '+' : ''}${change.diff}</b></span>`;
  }).join('');
}


function renderSidebarProjects() {
  if (!sidebarProjectList) return;
  sidebarProjectList.innerHTML = projects.map((project) => {
    const active = String(project.id) === String(currentProject?.id) ? 'active' : '';
    if (window.location.pathname.endsWith('.jsp')) {
      return `<a class="${active}" href="GroupDetailServlet?groupId=${encodeURIComponent(project.id)}" title="${project.name}"><span>${project.name}</span><em>${project.members?.length || 0}</em></a>`;
    }
    return `<a class="${active}" href="project-detail.html?projectId=${encodeURIComponent(project.id)}" title="${project.name}"><span>${project.name}</span><em>${project.members?.length || 0}</em></a>`;
  }).join('') || '<a href="projects.html"><span>Chưa có dự án</span></a>';
}


function renderPendingRequests() {
  const pendingList = document.getElementById('pendingRequestList');
  const pendingCount = document.getElementById('pendingCount');
  if (!pendingList || !pendingCount) return;
  const requests = currentProject.pendingRequests || [];
  pendingCount.textContent = requests.length;
  if (!isLeader()) {
    pendingList.innerHTML = '<article class="notice-card"><div><h3>Chỉ nhóm trưởng được duyệt thành viên</h3><p>Bạn có thể xem Group ID để gửi cho người khác, nhưng không thể duyệt hoặc kick thành viên.</p></div><time>Member</time></article>';
    return;
  }
  pendingList.innerHTML = requests.length ? requests.map(req => `
    <article class="notice-card warning">
      <div><h3>${req.name || req.userId}</h3><p>User ID: ${req.userId} · Gửi lúc: ${req.requestedAt || 'Chưa rõ'}</p></div>
      <div class="modal-actions" style="margin-top:0">
        <button class="secondary-btn approve-request-btn" type="button" data-user-id="${req.userId}">Duyệt</button>
        <button class="ghost-btn reject-request-btn" type="button" data-user-id="${req.userId}">Từ chối</button>
      </div>
    </article>`).join('') : '<article class="notice-card"><div><h3>Không có yêu cầu chờ duyệt</h3><p>Khi thành viên nhập Group ID để tham gia, yêu cầu sẽ xuất hiện tại đây.</p></div><time>0 request</time></article>';
  document.querySelectorAll('.approve-request-btn').forEach(btn => btn.addEventListener('click', () => approveRequest(btn.dataset.userId)));
  document.querySelectorAll('.reject-request-btn').forEach(btn => btn.addEventListener('click', () => rejectRequest(btn.dataset.userId)));
}

function approveRequest(userId) {
  if (!isLeader()) return alert('Chỉ nhóm trưởng được duyệt thành viên.');
  const req = (currentProject.pendingRequests || []).find(r => String(r.userId) === String(userId));
  if (!req) return;
  if (!(currentProject.members || []).some(m => String(m.userId) === String(userId))) {
    currentProject.members.push({ userId: req.userId, name: req.name || req.userId, stockCode: shortCode(req.name || req.userId), coin: 100, role: 'member' });
    currentProject.coinHistory.series[req.userId] = currentProject.coinHistory.series[req.userId] || [100];
  }
  currentProject.pendingRequests = currentProject.pendingRequests.filter(r => String(r.userId) !== String(userId));
  saveProjects(); renderAll();
}

function rejectRequest(userId) {
  if (!isLeader()) return alert('Chỉ nhóm trưởng được từ chối yêu cầu.');
  currentProject.pendingRequests = (currentProject.pendingRequests || []).filter(r => String(r.userId) !== String(userId));
  saveProjects(); renderAll();
}

function kickMember(userId) {
  if (!isLeader()) return alert('Chỉ nhóm trưởng được kick thành viên.');
  const member = currentProject.members.find(m => String(m.userId) === String(userId));
  if (!member || member.role === 'leader') return;
  if (!confirm(`Kick ${member.name} khỏi dự án?`)) return;
  currentProject.members = currentProject.members.filter(m => String(m.userId) !== String(userId));
  currentProject.tasks = (currentProject.tasks || []).filter(t => String(t.assignee) !== String(userId));
  if (currentProject.coinHistory?.series) delete currentProject.coinHistory.series[userId];
  saveProjects(); renderAll();
}

function copyGroupId() {
  const groupId = String(currentProject.id || '');
  if (!groupId) return alert('Chưa có Group ID để copy.');
  navigator.clipboard?.writeText(groupId).then(() => alert('Đã copy Group ID: ' + groupId)).catch(() => prompt('Copy Group ID:', groupId));
}

function renderAll() {
  renderSidebarProjects();
  renderHeader();
  renderTickerAndBoard();
  renderMembers();
  drawChart();
  renderPendingRequests();
}

function openTaskModal(index) {
  selectedMemberIndex = index;
  const member = currentProject.members[index];
  const editable = canEditMember(member);
  const submitEditable = canSubmitWork(member);
  document.getElementById('modalMemberName').textContent = `${member.name} - ${member.stockCode}`;
  document.getElementById('modalMemberMeta').textContent = editable
    ? (submitEditable ? 'Bạn có thể cập nhật bài làm, trạng thái và deadline của task này.' : 'Nhóm trưởng có thể cập nhật trạng thái/deadline và theo dõi bài làm.')
    : 'Bạn đang xem bài làm của thành viên khác: có thể xem chi tiết và đánh giá sao.';

  document.getElementById('modalTaskBody').innerHTML = member.tasks.map((task, taskIndex) => {
    const myRating = Number(task.ratings?.[currentUser.userId] || task.rating || 0);
    return `
      <tr>
        <td><strong>${task.title}</strong></td>
        <td>${editable ? `<input type="date" data-task-index="${taskIndex}" data-field="deadline" value="${task.deadline || ''}">` : formatDate(task.deadline)}</td>
        <td><select data-task-index="${taskIndex}" data-field="status" ${editable ? '' : 'disabled'}><option value="todo" ${task.status==='todo'?'selected':''}>Chưa làm</option><option value="doing" ${task.status==='doing'?'selected':''}>Đang làm</option><option value="done" ${task.status==='done'?'selected':''}>Hoàn thành</option><option value="late" ${task.status==='late'?'selected':''}>Trễ hạn</option></select></td>
        <td><textarea rows="3" data-task-index="${taskIndex}" data-field="submission" placeholder="Dán link bài làm hoặc ghi chú cập nhật..." ${submitEditable ? '' : 'readonly'}>${task.submission || task.update || ''}</textarea></td>
        <td><div class="rating-box"><div class="stars" data-task-index="${taskIndex}">${[1,2,3,4,5].map(star => `<button class="star ${myRating>=star?'active':''}" type="button" data-star="${star}" aria-label="${star} sao">★</button>`).join('')}</div><small>${myRating ? myRating + '/5' : 'Chưa chấm'}</small></div></td>
      </tr>`;
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
      });
    });
  });

  document.getElementById('saveTaskUpdates').textContent = editable ? 'Lưu thay đổi' : 'Lưu đánh giá';
  document.getElementById('taskModal').classList.add('show');
}

function saveTaskUpdates() {
  const member = currentProject.members[selectedMemberIndex];
  const editable = canEditMember(member);
  const submitEditable = canSubmitWork(member);

  if (editable) {
    document.querySelectorAll('#modalTaskBody [data-field]').forEach(field => {
      const task = member.tasks[Number(field.dataset.taskIndex)];
      task[field.dataset.field] = field.value;
      const globalTask = currentProject.tasks.find(t => t === task || (t.title === task.title && t.assignee === member.userId));
      if (globalTask) globalTask[field.dataset.field] = field.value;
    });
  }

  autoMarkLateTasks(currentProject);
  recalcProjectProgress(currentProject);

  let coinChange = 0;
  member.tasks.forEach(task => {
    if (task.status === 'done' && Number(task.rating) >= 4) coinChange += 2;
    if (task.status === 'late') coinChange -= 2;
  });
  member.coin = Math.max(0, Number(member.coin) + coinChange);
  const series = currentProject.coinHistory.series[member.userId] || [];
  series.push(member.coin);
  currentProject.coinHistory.series[member.userId] = series;
  if (currentProject.coinHistory.labels.length < series.length) currentProject.coinHistory.labels.push(`D${currentProject.coinHistory.labels.length}`);

  addNotification(editable ? 'info' : 'info', editable ? 'Có cập nhật tiến độ' : 'Có đánh giá bài làm', `${currentUser.displayName} vừa cập nhật/đánh giá task của ${member.name} trong dự án ${currentProject.name}.`);
  saveProjects();
  document.getElementById('taskModal').classList.remove('show');
  renderAll();
}

function simulateMarket() {
  if (!canUpdateProjectProgress()) {
    alert('Chỉ nhóm trưởng hoặc người thực hiện task trong dự án mới có thể cập nhật tiến độ.');
    return;
  }
  autoMarkLateTasks(currentProject);
  recalcProjectProgress(currentProject);
  currentProject.coinHistory.labels.push(`D${currentProject.coinHistory.labels.length}`);
  currentProject.members.forEach(member => {
    const done = member.tasks.filter(t => t.status === 'done').length;
    const late = member.tasks.filter(t => t.status === 'late').length;
    const random = Math.floor(Math.random() * 9) - 3;
    const delta = random + done * 2 - late * 2;
    member.coin = Math.max(0, Number(member.coin) + delta);
    currentProject.coinHistory.series[member.userId].push(member.coin);
  });
  recalcProjectProgress(currentProject);
  addNotification('info', 'Tiến độ dự án thay đổi', `Dự án ${currentProject.name} vừa được cập nhật tiến độ coin.`);
  saveProjects();
  renderAll();
}

document.addEventListener('DOMContentLoaded', () => {
  requireLogin();
  loadProjects();
  findCurrentProject();
  renderAll();
  document.getElementById('logoutBtn').addEventListener('click', () => {
    localStorage.removeItem('zc_logged_in');
    localStorage.removeItem('isLoggedIn');
    localStorage.removeItem('zc_user_name');
    localStorage.removeItem('zc_user_id');
    window.location.href = window.location.pathname.endsWith('.jsp') ? 'LogoutServlet' : 'index.html';
  });
  document.getElementById('closeTaskModal').addEventListener('click', () => document.getElementById('taskModal').classList.remove('show'));
  document.getElementById('taskModal').addEventListener('click', e => { if (e.target.id === 'taskModal') e.currentTarget.classList.remove('show'); });
  document.getElementById('saveTaskUpdates').addEventListener('click', saveTaskUpdates);
  document.getElementById('simulateMarketBtn').addEventListener('click', simulateMarket);
  document.getElementById('copyGroupIdBtn')?.addEventListener('click', copyGroupId);
  if (projectMenuToggle) projectMenuToggle.addEventListener('click', () => sidebarProjectList?.classList.toggle('collapsed'));
});
