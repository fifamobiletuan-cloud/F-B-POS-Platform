/**
 * ====================================================================
 * CHOUX CHIN F&B - KITCHEN DISPLAY SYSTEM (KDS) JAVASCRIPT
 * Tự động hóa chế biến món trong bếp, đồng bộ real-time với QR bàn
 * và App Quản lý Choux Chin.
 * ====================================================================
 */

const KdsState = {
    orders: [],
    recalledOrders: [],
    tables: [],
    products: [],
    previousOrderIds: new Set(),
    soundEnabled: true,
    audioCtx: null
};

// Khởi tạo Audio Context khi người dùng tương tác lần đầu
function getAudioContext() {
    if (!KdsState.audioCtx) {
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        if (AudioCtx) KdsState.audioCtx = new AudioCtx();
    }
    if (KdsState.audioCtx && KdsState.audioCtx.state === 'suspended') {
        KdsState.audioCtx.resume();
    }
    return KdsState.audioCtx;
}

// Âm thanh chuông báo có đơn mới từ QR Bàn ("Ting ting!")
function playNewOrderChime() {
    if (!KdsState.soundEnabled) return;
    try {
        const ctx = getAudioContext();
        if (!ctx) return;
        const now = ctx.currentTime;

        const osc1 = ctx.createOscillator();
        const osc2 = ctx.createOscillator();
        const gain = ctx.createGain();

        osc1.type = 'sine';
        osc1.frequency.setValueAtTime(587.33, now); // D5
        osc1.frequency.setValueAtTime(880, now + 0.12); // A5

        osc2.type = 'triangle';
        osc2.frequency.setValueAtTime(1174.66, now); // D6
        osc2.frequency.setValueAtTime(1760, now + 0.12); // A6

        gain.gain.setValueAtTime(0.3, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.8);

        osc1.connect(gain);
        osc2.connect(gain);
        gain.connect(ctx.destination);

        osc1.start(now);
        osc2.start(now);
        osc1.stop(now + 0.8);
        osc2.stop(now + 0.8);
    } catch (e) {
        console.warn('Audio error:', e);
    }
}

// Âm thanh khi đầu bếp BUMP ORDER thành công ("Ding-pop!")
function playBumpSound() {
    if (!KdsState.soundEnabled) return;
    try {
        const ctx = getAudioContext();
        if (!ctx) return;
        const now = ctx.currentTime;

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(523.25, now); // C5
        osc.frequency.exponentialRampToValueAtTime(1046.50, now + 0.1); // C6

        gain.gain.setValueAtTime(0.35, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(now);
        osc.stop(now + 0.35);
    } catch (e) {
        console.warn('Bump audio error:', e);
    }
}

// ====================================================================
// KHỞI ĐỘNG ỨNG DỤNG
// ====================================================================
document.addEventListener('DOMContentLoaded', () => {
    initKdsApp();
});

async function initKdsApp() {
    // Đăng ký mở audio khi bấm phím hoặc click chuột bất kỳ
    window.addEventListener('click', () => getAudioContext(), { once: true });
    window.addEventListener('keydown', () => getAudioContext(), { once: true });

    await fetchProductsAndTables();
    await loadKitchenOrders();

    // Vòng lặp cập nhật đồng hồ đếm giây thời gian thực (1 giây/lần)
    setInterval(updateTimersAndHeaderStats, 1000);

    // Vòng lặp tự động kéo đơn mới từ CSDL PostgreSQL (1 giây/lần cực nhanh)
    setInterval(loadKitchenOrders, 1000);
}

async function fetchProductsAndTables() {
    try {
        const [prodRes, tabRes] = await Promise.all([
            fetch('/api/v1/owner/products'),
            fetch('/api/v1/store/tables')
        ]);
        if (prodRes.ok) {
            const pData = await prodRes.json();
            KdsState.products = pData.data || [];
            populateTestOrderProducts();
        }
        if (tabRes.ok) {
            const tData = await tabRes.json();
            KdsState.tables = tData.data || [];
            populateTestOrderTables();
        }
    } catch (e) {
        console.error('Lỗi nạp danh mục sản phẩm/bàn:', e);
    }
}

// ====================================================================
// NẠP ĐƠN HÀNG ĐANG NẤU (COOKING) TỪ CSDL POSTGRESQL
// ====================================================================
async function loadKitchenOrders() {
    try {
        const res = await fetch('/api/v1/kds/orders');
        if (!res.ok) return;

        const data = await res.json();
        const incomingOrders = data.data || [];

        // Kiểm tra xem có đơn mới chưa từng xuất hiện không
        let hasNewOrder = false;
        const currentIds = new Set();
        incomingOrders.forEach(o => {
            currentIds.add(o.id);
            if (!KdsState.previousOrderIds.has(o.id) && KdsState.previousOrderIds.size > 0) {
                hasNewOrder = true;
            }
        });

        if (hasNewOrder) {
            playNewOrderChime();
        }

        KdsState.previousOrderIds = currentIds;
        KdsState.orders = incomingOrders;

        renderKitchenTickets();
        renderProductionSummary();
        updateTimersAndHeaderStats();
    } catch (e) {
        console.error('Lỗi nạp đơn bếp:', e);
    }
}

// ====================================================================
// RENDER CÁC PHIẾU GỌI MÓN (TICKETS) CHUẨN 100% THEO ẢNH
// ====================================================================
function renderKitchenTickets() {
    const grid = document.getElementById('kdsGridContainer');
    if (!grid) return;

    if (KdsState.orders.length === 0) {
        grid.innerHTML = `
            <div class="kds-empty-state">
                <div class="kds-empty-icon">🍳</div>
                <div class="kds-empty-text">Hiện tại không có đơn nào đang chờ chế biến</div>
                <div style="font-size: 12px; margin-top: 6px; color: #94A3B8;">Khi khách quét mã QR tại bàn, đơn hàng sẽ tự động hiện lên đây!</div>
            </div>
        `;
        return;
    }

    // Nhóm các đơn thành các cột (tối đa 3 bill mỗi cột như trong ảnh)
    const columns = [];
    const maxPerColumn = 3;

    for (let i = 0; i < KdsState.orders.length; i += maxPerColumn) {
        columns.push(KdsState.orders.slice(i, i + maxPerColumn));
    }

    let globalIndex = 1;
    grid.innerHTML = columns.map(col => `
        <div class="kds-ticket-column">
            ${col.map(order => renderSingleTicket(order, globalIndex++)).join('')}
        </div>
    `).join('');
}

function renderSingleTicket(order, index) {
    const elapsedSec = getElapsedSeconds(order.createdAt || order.created_at);
    const timeFormatted = formatKitchenTimer(elapsedSec);
    const timerClass = elapsedSec > 600 ? 'danger' : (elapsedSec > 300 ? 'warning' : '');

    const tableLabel = (order.tableNumber || order.table_number || 'Bàn 01').toUpperCase();
    const serviceType = order.customerNotes && order.customerNotes.includes('Mang về') ? 'MANG VỀ' : 'ĂN TẠI BÀN';
    const orderCode = order.orderCode || order.order_code || `#CC-${order.id}`;

    // Tên combo hoặc phân nhóm hiển thị in đậm xanh dương ở đầu bill
    const summaryTitle = getTicketSummaryTitle(order);

    const items = order.items || [];
    const itemsHtml = items.map(it => `
        <li class="kds-ticket-item">
            <span class="item-qty">${it.quantity}</span>
            <span class="item-name">${escapeHtml(it.productName || it.name)}</span>
            ${it.note ? `<div class="item-note">↳ ${escapeHtml(it.note)}</div>` : ''}
        </li>
    `).join('');

    return `
        <div class="kds-ticket" id="ticket-${order.id}" data-id="${order.id}">
            <!-- DÒNG XANH LÁ CÂY TRÊN CÙNG: NHẤN ĐỂ BUMP ORDER -->
            <div class="kds-ticket-header" onclick="bumpOrder(${order.id})" title="Nhấn vào dòng xanh để hoàn thành (BUMP ORDER)">
                <div class="kds-ticket-header-top">
                    <span class="kds-ticket-index">${index}</span>
                    <div class="kds-ticket-channel">
                        <div class="kds-ticket-channel-name">${escapeHtml(tableLabel)}</div>
                        <div class="kds-ticket-service-type">${escapeHtml(serviceType)}</div>
                    </div>
                </div>
                <div class="kds-ticket-header-bottom">
                    <span class="kds-ticket-code">${escapeHtml(orderCode)}</span>
                    <span class="kds-ticket-timer ${timerClass}" id="timer-${order.id}">${timeFormatted}</span>
                </div>
            </div>

            <!-- PHẦN BODY MÀU TRẮNG CHỨA CHI TIẾT MÓN CẦN NẤU -->
            <div class="kds-ticket-body">
                <div class="kds-ticket-summary-title">${escapeHtml(summaryTitle)}</div>
                <ul class="kds-ticket-items-list">
                    ${itemsHtml}
                </ul>
            </div>

            <!-- DÒNG XANH LÁ CÂY ĐÁY BILL: BUMP ORDER DÀNH CHO MÀN HÌNH CẢM ỨNG BẾP -->
            <div class="kds-ticket-bump-bar" onclick="bumpOrder(${order.id})" title="Nhấn để hoàn tất chế biến">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
                <span>BUMP ORDER</span>
            </div>
        </div>
    `;
}

function getTicketSummaryTitle(order) {
    const items = order.items || [];
    if (items.length === 0) return 'ĐƠN GỌI MÓN';
    if (items.length === 1) return (items[0].productName || items[0].name || 'MÓN ĂN').toUpperCase();
    return `DANH SÁCH MÓN (${items.length} MÓN)`;
}

// ====================================================================
// RENDER BẢNG TỔNG HỢP MÓN BÊN PHẢI (PRODUCTION ITEM SUMMARY)
// ====================================================================
function renderProductionSummary() {
    const tbody = document.getElementById('kdsSummaryBody');
    if (!tbody) return;

    // Đếm tổng số lượng từng món đang cần làm trong toàn bộ các bill đang mở
    const itemCounts = {};

    (KdsState.orders || []).forEach(o => {
        (o.items || []).forEach(it => {
            const name = it.productName || it.name;
            if (name) {
                itemCounts[name] = (itemCounts[name] || 0) + Number(it.quantity || 1);
            }
        });
    });

    // Các món đang có khách gọi -> ưu tiên đưa lên đầu bảng
    const activeDishes = Object.keys(itemCounts).sort((a, b) => itemCounts[b] - itemCounts[a]);

    // Các món phổ biến khác (để hiển thị các dòng 0 như trong ảnh)
    const defaultDishes = [
        'Cá viên chiên giòn rụm',
        'Mẹt Trà Sữa Khổng Lồ Full 12 Topping',
        'Lẩu Tokbokki Phô Mai Kéo Sợi Khổng Lồ',
        'Xúc xích nướng',
        'Khoai tây chiên',
        'Phô mai que',
        'Nem chua rán',
        'Trà đào truyền thống',
        'Trà sữa trân châu đường đen',
        'Bánh tráng trộn',
        'Chân gà cay'
    ];

    const displayList = [...activeDishes];
    defaultDishes.forEach(d => {
        if (!displayList.includes(d)) displayList.push(d);
    });

    tbody.innerHTML = displayList.map(name => {
        const qty = itemCounts[name] || 0;
        const hasQtyClass = qty > 0 ? 'has-qty' : '';
        return `
            <div class="kds-summary-row ${hasQtyClass}">
                <div class="kds-summary-name" title="${escapeHtml(name)}">${escapeHtml(name)}</div>
                <div class="kds-summary-qty">${qty}</div>
            </div>
        `;
    }).join('');
}

// ====================================================================
// CẬP NHẬT CÁC ĐỒNG HỒ ĐẾM THỜI GIAN & CHỈ SỐ HEADER
// ====================================================================
function updateTimersAndHeaderStats() {
    if (!KdsState.orders || KdsState.orders.length === 0) {
        document.getElementById('kdsAvgOrderTime').innerText = '0:00:00';
        document.getElementById('kdsMaxOrderTime').innerText = '0:00:00';
        return;
    }

    let totalSeconds = 0;
    let maxSeconds = 0;

    KdsState.orders.forEach(o => {
        const elapsed = getElapsedSeconds(o.createdAt || o.created_at);
        totalSeconds += elapsed;
        if (elapsed > maxSeconds) maxSeconds = elapsed;

        const timerEl = document.getElementById(`timer-${o.id}`);
        if (timerEl) {
            timerEl.innerText = formatKitchenTimer(elapsed);
            if (elapsed > 600) {
                timerEl.className = 'kds-ticket-timer danger';
            } else if (elapsed > 300) {
                timerEl.className = 'kds-ticket-timer warning';
            } else {
                timerEl.className = 'kds-ticket-timer';
            }
        }
    });

    const avgSeconds = Math.round(totalSeconds / KdsState.orders.length);

    document.getElementById('kdsAvgOrderTime').innerText = formatClockHms(avgSeconds);
    document.getElementById('kdsMaxOrderTime').innerText = formatClockHms(maxSeconds);
}

// ====================================================================
// CHỨC NĂNG BUMP ORDER (CLICK DÒNG XANH ĐỂ HOÀN TẤT MÓN)
// ====================================================================
async function bumpOrder(orderId) {
    const ticketEl = document.getElementById(`ticket-${orderId}`);
    if (ticketEl) {
        ticketEl.classList.add('bumping');
    }

    playBumpSound();

    try {
        const res = await fetch(`/api/v1/kds/orders/${orderId}/bump`, {
            method: 'POST'
        });

        if (res.ok) {
            // Xóa khỏi danh sách client ngay để mượt mà
            KdsState.orders = KdsState.orders.filter(o => o.id !== orderId);
            setTimeout(() => {
                renderKitchenTickets();
                renderProductionSummary();
                updateTimersAndHeaderStats();
            }, 200);
        } else {
            console.error('Lỗi khi bump order');
            if (ticketEl) ticketEl.classList.remove('bumping');
        }
    } catch (e) {
        console.error('Lỗi API bump order:', e);
        if (ticketEl) ticketEl.classList.remove('bumping');
    }
}

// ====================================================================
// CHỨC NĂNG RECALL (XEM LẠI CÁC ĐƠN ĐÃ LÀM VÀ KHÔI PHỤC)
// ====================================================================
async function openRecallModal() {
    const modal = document.getElementById('kdsRecallModal');
    const list = document.getElementById('kdsRecallList');
    if (!modal || !list) return;

    list.innerHTML = `<p style="text-align: center; color: #94A3B8; padding: 20px;">Đang tải lịch sử đơn đã hoàn thành...</p>`;
    modal.classList.add('show');

    try {
        const res = await fetch('/api/v1/kds/recalled');
        if (res.ok) {
            const data = await res.json();
            const recalled = data.data || [];
            KdsState.recalledOrders = recalled;

            if (recalled.length === 0) {
                list.innerHTML = `<p style="text-align: center; color: #94A3B8; padding: 20px;">Chưa có đơn nào được hoàn tất gần đây</p>`;
                return;
            }

            list.innerHTML = recalled.map(o => {
                const itemsSummary = (o.items || []).map(i => `${i.productName || i.name} x${i.quantity}`).join(', ');
                const time = o.updatedAt || o.updated_at ? new Date(o.updatedAt || o.updated_at).toLocaleTimeString('vi-VN') : '';
                return `
                    <div class="kds-recall-item">
                        <div class="kds-recall-info">
                            <strong>${escapeHtml(o.tableNumber || o.table_number || 'Bàn 01')} • ${escapeHtml(o.orderCode || '#' + o.id)}</strong>
                            <div class="sub">${escapeHtml(itemsSummary || 'Không có chi tiết')}</div>
                            <div class="sub" style="color: #22C55E;">Hoàn thành lúc: ${time}</div>
                        </div>
                        <button class="kds-btn" style="background:#0F172A; border-color:#22C55E; color:#22C55E;" onclick="unbumpOrder(${o.id})">
                            ↩ Khôi Phục (Unbump)
                        </button>
                    </div>
                `;
            }).join('');
        }
    } catch (e) {
        list.innerHTML = `<p style="color: #EF4444; padding: 20px;">Lỗi tải dữ liệu: ${e.message}</p>`;
    }
}

async function unbumpOrder(orderId) {
    try {
        const res = await fetch(`/api/v1/kds/orders/${orderId}/unbump`, { method: 'POST' });
        if (res.ok) {
            closeModal('kdsRecallModal');
            await loadKitchenOrders();
        }
    } catch (e) {
        alert('Lỗi khôi phục đơn: ' + e.message);
    }
}

// ====================================================================
// CHỨC NĂNG THỬ ĐẶT MÓN TẠI BÀN (MÔ PHỎNG QR BÀN GỬI ĐƠN VÀO BẾP)
// ====================================================================
function openTestOrderModal() {
    const modal = document.getElementById('kdsTestOrderModal');
    if (modal) modal.classList.add('show');
}

function populateTestOrderTables() {
    const select = document.getElementById('testTableSelect');
    if (!select) return;
    select.innerHTML = (KdsState.tables || []).map(t => `
        <option value="${t.tableNumber}">${t.tableNumber} (${t.status === 'OCCUPIED' ? 'Đang có khách' : 'Trống'})</option>
    `).join('') + `
        <option value="Mang về (Takeaway)">Mang về (Takeaway - #31)</option>
        <option value="GrabFood GF651">GrabFood (GF651)</option>
    `;
}

function populateTestOrderProducts() {
    const container = document.getElementById('testProductsChecklist');
    if (!container) return;

    container.innerHTML = (KdsState.products || []).slice(0, 16).map(p => `
        <label style="display: flex; align-items: center; justify-content: space-between; padding: 6px 8px; background: #334155; border-radius: 4px; margin-bottom: 6px; font-size: 12px; cursor: pointer;">
            <div style="display: flex; align-items: center; gap: 8px;">
                <input type="checkbox" name="testDish" value="${p.id}" data-name="${escapeHtml(p.name)}" data-price="${p.price}" style="cursor: pointer;">
                <span>${escapeHtml(p.name)}</span>
            </div>
            <strong style="color: #00E5FF;">${Number(p.price).toLocaleString('vi-VN')} ₫</strong>
        </label>
    `).join('');
}

async function submitTestOrder() {
    const tableNumber = document.getElementById('testTableSelect')?.value || 'Bàn 01';
    const notes = document.getElementById('testOrderNotes')?.value || 'Khách đặt qua mã QR tại bàn';

    const checkedDishes = Array.from(document.querySelectorAll('input[name="testDish"]:checked'));
    if (checkedDishes.length === 0) {
        alert('Vui lòng chọn ít nhất 1 món để đặt!');
        return;
    }

    const items = checkedDishes.map(chk => ({
        productId: Number(chk.value),
        productName: chk.getAttribute('data-name'),
        quantity: 1,
        unitPrice: Number(chk.getAttribute('data-price') || 0),
        note: ''
    }));

    try {
        const res = await fetch('/api/v1/kds/orders/create', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                tableNumber: tableNumber,
                items: items,
                customerNotes: notes
            })
        });

        if (res.ok) {
            closeModal('kdsTestOrderModal');
            // Bỏ tick
            checkedDishes.forEach(c => c.checked = false);
            // Nạp lại dữ liệu ngay lập tức
            await loadKitchenOrders();
        } else {
            alert('Lỗi tạo đơn thử nghiệm');
        }
    } catch (e) {
        alert('Lỗi: ' + e.message);
    }
}

// ====================================================================
// CHỨC NĂNG TABLES & CALIBRATE
// ====================================================================
function openTablesModal() {
    const modal = document.getElementById('kdsTablesModal');
    const grid = document.getElementById('kdsTablesGrid');
    if (!modal || !grid) return;

    grid.innerHTML = (KdsState.tables || []).map(t => {
        const isOccupied = t.status === 'OCCUPIED';
        return `
            <div style="background: ${isOccupied ? '#854D0E' : '#334155'}; border: 1px solid ${isOccupied ? '#FACC15' : '#64748B'}; border-radius: 6px; padding: 12px; text-align: center;">
                <div style="font-size: 16px; font-weight: 800; color: #FFFFFF;">${t.tableNumber}</div>
                <div style="font-size: 11px; margin-top: 4px; color: ${isOccupied ? '#FEF08A' : '#94A3B8'};">
                    ${isOccupied ? '🔴 Đang có khách' : '🟢 Bàn trống'}
                </div>
            </div>
        `;
    }).join('');

    modal.classList.add('show');
}

function openCalibrateModal() {
    const modal = document.getElementById('kdsCalibrateModal');
    if (modal) modal.classList.add('show');
}

function toggleSound() {
    KdsState.soundEnabled = !KdsState.soundEnabled;
    const btn = document.getElementById('btnSoundToggle');
    if (btn) {
        btn.innerText = KdsState.soundEnabled ? '🔊 Âm Thanh: BẬT' : '🔇 Âm Thanh: TẮT';
        btn.style.color = KdsState.soundEnabled ? '#22C55E' : '#EF4444';
    }
}

function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.warn('Không thể mở toàn màn hình:', err);
        });
    } else {
        if (document.exitFullscreen) document.exitFullscreen();
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.remove('show');
}

// ====================================================================
// TIỆN ÍCH FORMAT THỜI GIAN
// ====================================================================
function getElapsedSeconds(isoString) {
    if (!isoString) return 0;
    const start = new Date(isoString).getTime();
    const now = Date.now();
    const diff = Math.floor((now - start) / 1000);
    return diff > 0 ? diff : 0;
}

function formatKitchenTimer(totalSec) {
    const m = Math.floor(totalSec / 60);
    const s = totalSec % 60;
    return `${m}:${s < 10 ? '0' : ''}${s}`;
}

function formatClockHms(totalSec) {
    const h = Math.floor(totalSec / 3600);
    const m = Math.floor((totalSec % 3600) / 60);
    const s = totalSec % 60;
    return `${h}:${m < 10 ? '0' : ''}${m}:${s < 10 ? '0' : ''}${s}`;
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}
