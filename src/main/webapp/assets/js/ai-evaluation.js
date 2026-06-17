document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.ai-evaluate-btn').forEach(function (button) {
    button.addEventListener('click', function () {
      evaluateSubmission(button);
    });
  });
});

async function evaluateSubmission(button) {
  const submissionId = button.dataset.submissionId;
  const resultBox = document.getElementById('aiResult-' + submissionId);

  if (!submissionId || !resultBox) {
    alert('Không tìm thấy submissionId.');
    return;
  }

  const oldText = button.textContent;
  button.disabled = true;
  button.textContent = 'AI đang chấm...';

  resultBox.innerHTML = `
    <div class="ai-result-card">
      <h4>Đang xử lý</h4>
      <p>AI đang đọc file bài nộp và mô tả task. Vui lòng chờ...</p>
    </div>
  `;

  try {
    const response = await fetch('EvaluateSubmissionServlet', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
      },
      body: new URLSearchParams({
        submissionId: submissionId
      })
    });

    const data = await response.json();

    if (!response.ok || !data.success) {
      throw new Error(data.message || 'AI đánh giá thất bại.');
    }

    resultBox.innerHTML = renderAiResult(data);

    const updatedMessage = document.createElement('div');
    updatedMessage.className = 'ai-result-card';
    updatedMessage.style.marginTop = '12px';
    updatedMessage.innerHTML = `
      <h4>Đã cập nhật</h4>
      <p>AI đã chấm xong. Hệ thống đang tải lại trang để cập nhật giá coin và bảng thành viên...</p>
    `;

    resultBox.appendChild(updatedMessage);

    button.textContent = 'Đã chấm xong';

    setTimeout(function () {
      window.location.reload();
    }, 1200);

  } catch (error) {
    resultBox.innerHTML = `
      <div class="ai-result-card" style="border-color:rgba(248,113,113,.3);background:rgba(248,113,113,.08)">
        <h4 style="color:#fecaca">Lỗi AI đánh giá</h4>
        <p>${escapeHtml(error.message)}</p>
      </div>
    `;

    button.textContent = oldText;
    button.disabled = false;
  }
}

function renderAiResult(data) {
  return `
    <div class="ai-result-card">
      <h4>Kết quả AI vừa chấm</h4>
      <p class="ai-star">${renderStars(Number(data.aiStar))}</p>
      <p><b>Điểm quy đổi:</b> ${escapeHtml(data.convertedPoint)}</p>
      <p><b>Nhận xét:</b> ${escapeHtml(data.summary)}</p>
      <p><b>Điểm mạnh:</b> ${escapeHtml(data.strengths)}</p>
      <p><b>Điểm yếu:</b> ${escapeHtml(data.weaknesses)}</p>
      <p><b>Yêu cầu còn thiếu:</b> ${escapeHtml(data.missingRequirements)}</p>
      <p><b>Dẫn chứng:</b> ${escapeHtml(data.evidence)}</p>
    </div>
  `;
}

function renderStars(star) {
  if (!star || star < 1) {
    return 'Chưa chấm';
  }

  let output = '';

  for (let i = 1; i <= 5; i++) {
    output += i <= star ? '★' : '☆';
  }

  return output;
}

function escapeHtml(value) {
  if (value === null || value === undefined) {
    return '';
  }

  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}