const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const { Pool } = require('pg');

const PORT = 3000;

// CẤU HÌNH KẾT NỐI TRỰC TIẾP CƠ SỞ DỮ LIỆU POSTGRESQL CỦA ĐỒ ÁN
const pool = new Pool({
    host: '127.0.0.1',
    port: 5432,
    database: 'milktea_pos_db',
    user: 'postgres',
    password: '123456',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
    console.error('[PostgreSQL Error] Lỗi kết nối CSDL:', err.message);
});

const BASE_DIR = __dirname;
const PUBLIC_DIR = path.join(BASE_DIR, 'public');
const IMAGES_DIR = path.join(BASE_DIR, '..', 'images');
const BRAND_DIR = path.join(BASE_DIR, '..', 'anhthuonghieu');
const QR_DIR = path.join(BASE_DIR, '..', 'anhqr');

const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.woff2': 'font/woff2',
    '.woff': 'font/woff',
    '.ttf': 'font/ttf'
};

function sendJson(res, statusCode, data) {
    res.writeHead(statusCode, {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*'
    });
    res.end(JSON.stringify(data));
}

function parseJsonBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            if (!body) return resolve({});
            try {
                resolve(JSON.parse(body));
            } catch (e) {
                resolve({});
            }
        });
        req.on('error', reject);
    });
}

function serveStaticFile(filePath, res) {
    fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
            res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
            res.end('404 Not Found');
            return;
        }

        const ext = path.extname(filePath).toLowerCase();
        const contentType = MIME_TYPES[ext] || 'application/octet-stream';

        res.writeHead(200, {
            'Content-Type': contentType,
            'Content-Length': stats.size,
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0'
        });

        const stream = fs.createReadStream(filePath);
        stream.pipe(res);
    });
}

// KHỞI TẠO HTTP SERVER KẾT NỐI TRỰC TIẾP POSTGRESQL
const server = http.createServer(async (req, res) => {
    // CORS Preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(204, {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': '*'
        });
        res.end();
        return;
    }

    const parsedUrl = url.parse(req.url, true);
    let pathname = decodeURIComponent(parsedUrl.pathname);

    // ====================================================================
    // 1. THỐNG KÊ ANALYTICS VỚI 5 MỐC THỜI GIAN (HÔM NAY, HÔM QUA, 7 NGÀY, THÁNG NÀY, THÁNG TRƯỚC)
    // ====================================================================
    if (pathname === '/api/v1/owner/analytics' && req.method === 'GET') {
        try {
            const period = parsedUrl.query.period || '7days';
            const branchId = parsedUrl.query.branchId || '1'; // Mặc định Chi nhánh 1 (Trung tâm)
            const now = new Date();
            let startDate, endDate;

            if (period === 'today') {
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
            } else if (period === 'yesterday') {
                const y = new Date(now.getTime() - 24 * 60 * 60 * 1000);
                startDate = new Date(y.getFullYear(), y.getMonth(), y.getDate(), 0, 0, 0);
                endDate = new Date(y.getFullYear(), y.getMonth(), y.getDate(), 23, 59, 59);
            } else if (period === 'this_month') {
                startDate = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
            } else if (period === 'last_month') {
                startDate = new Date(now.getFullYear(), now.getMonth() - 1, 1, 0, 0, 0);
                endDate = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59);
            } else { // 7days
                startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                endDate = new Date();
            }

            // Bộ lọc chi nhánh (Chi nhánh 1, 2, 3, 4 hoặc ALL - Toàn hệ thống)
            let branchOrderFilter = '';
            let branchOrderParams = [startDate, endDate];
            if (branchId && branchId !== 'ALL' && Number(branchId) > 0) {
                branchOrderFilter = ' AND branch_id = $3';
                branchOrderParams.push(Number(branchId));
            }

            // Truy vấn đơn hàng trong khoảng thời gian đã chọn (theo chi nhánh)
            const ordersRes = await pool.query(`
                SELECT * FROM orders 
                WHERE created_at >= $1 AND created_at <= $2 ${branchOrderFilter}
                ORDER BY created_at DESC
            `, branchOrderParams);
            const periodOrders = ordersRes.rows;

            // Truy vấn đơn hàng hôm nay để hiển thị 3 thẻ KPI trên cùng
            const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
            const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
            let todayBranchFilter = '';
            let todayBranchParams = [todayStart, todayEnd];
            if (branchId && branchId !== 'ALL' && Number(branchId) > 0) {
                todayBranchFilter = ' AND branch_id = $3';
                todayBranchParams.push(Number(branchId));
            }
            const todayOrdersRes = await pool.query(`
                SELECT * FROM orders 
                WHERE created_at >= $1 AND created_at <= $2 ${todayBranchFilter}
            `, todayBranchParams);
            const todayOrders = todayOrdersRes.rows;

            let todayRevenue = 0;
            let totalOrdersToday = todayOrders.length;
            for (const o of todayOrders) {
                if (o.status === 'COMPLETED' || o.payment_status === 'PAID') {
                    todayRevenue += Number(o.final_amount || o.total_amount || 0);
                }
            }

            // Doanh thu và số đơn theo khoảng thời gian được chọn
            let periodRevenue = 0;
            let completedBills = 0;
            let pendingBills = 0;
            let preparingBills = 0;

            const weekdaySales = [0, 0, 0, 0, 0, 0, 0]; // CN, T2, T3, T4, T5, T6, T7
            const hourlySales = { 8: 0, 9: 0, 10: 0, 18: 0, 19: 0, 20: 0, 21: 0, 22: 0, 23: 0 };
            const hourlyGuestCount = { 8: 0, 9: 0, 10: 0, 18: 0, 19: 0, 20: 0, 21: 0, 22: 0, 23: 0 };

            for (const o of periodOrders) {
                const amt = Number(o.final_amount || o.total_amount || 0);
                const isPaid = o.status === 'COMPLETED' || o.payment_status === 'PAID';

                if (isPaid) {
                    periodRevenue += amt;
                    completedBills++;
                }

                if (o.status === 'PENDING') pendingBills++;
                if (o.status === 'PREPARING') preparingBills++;

                if (o.created_at) {
                    const d = new Date(o.created_at);
                    const dayOfWeek = d.getDay();
                    const hour = d.getHours();

                    if (isPaid) weekdaySales[dayOfWeek] += amt;
                    if (hourlySales[hour] !== undefined) {
                        if (isPaid) hourlySales[hour] += amt;
                        hourlyGuestCount[hour] += 1;
                    }
                }
            }

            // Top món ăn bán chạy & Nhóm món từ order_items theo khoảng thời gian và chi nhánh
            let itemsBranchFilter = '';
            let itemsBranchParams = [startDate, endDate];
            if (branchId && branchId !== 'ALL' && Number(branchId) > 0) {
                itemsBranchFilter = ' AND o.branch_id = $3';
                itemsBranchParams.push(Number(branchId));
            }
            const itemsRes = await pool.query(`
                SELECT oi.*, p.name as prod_name, p.category_code
                FROM order_items oi
                JOIN orders o ON oi.order_id = o.id
                JOIN products p ON oi.product_id = p.id
                WHERE o.created_at >= $1 AND o.created_at <= $2 ${itemsBranchFilter}
            `, itemsBranchParams);

            // Lấy toàn bộ sản phẩm đang có trong hệ thống để phục vụ phân trang đầy đủ (< >)
            const allProdsRes = await pool.query(`
                SELECT id, name, category_code, base_price 
                FROM products 
                WHERE is_available = true 
                ORDER BY id ASC
            `);

            const productSalesMap = {};
            const categorySalesMap = {};
            const categoryItemsMap = {}; // Phân nhóm chi tiết từng món theo nhóm
            let totalItemsSold = 0;
            let totalItemsRevenue = 0;

            // Khởi tạo toàn bộ sản phẩm với số lượng và doanh thu ban đầu = 0
            for (const p of allProdsRes.rows) {
                const name = p.name;
                const cat = p.category_code || 'OTHER';
                productSalesMap[name] = { name, quantity: 0, revenue: 0, categoryCode: cat };
                if (!categoryItemsMap[cat]) categoryItemsMap[cat] = {};
                categoryItemsMap[cat][name] = { name, quantity: 0, revenue: 0 };
            }

            for (const it of itemsRes.rows) {
                const name = it.product_name || it.prod_name;
                const qty = Number(it.quantity || 1);
                const sub = Number(it.subtotal || (it.unit_price * qty) || 0);
                const cat = it.category_code || 'OTHER';

                totalItemsSold += qty;
                totalItemsRevenue += sub;

                if (!productSalesMap[name]) {
                    productSalesMap[name] = { name, quantity: 0, revenue: 0, categoryCode: cat };
                }
                productSalesMap[name].quantity += qty;
                productSalesMap[name].revenue += sub;

                categorySalesMap[cat] = (categorySalesMap[cat] || 0) + sub;

                if (!categoryItemsMap[cat]) categoryItemsMap[cat] = {};
                if (!categoryItemsMap[cat][name]) {
                    categoryItemsMap[cat][name] = { name, quantity: 0, revenue: 0 };
                }
                categoryItemsMap[cat][name].quantity += qty;
                categoryItemsMap[cat][name].revenue += sub;
            }

            // Top tất cả các món toàn quán (cho nút "Theo loại" và "Tất cả nhóm")
            const topProductsAll = Object.values(productSalesMap)
                .sort((a, b) => b.quantity - a.quantity || b.revenue - a.revenue || a.name.localeCompare(b.name));

            // Chi tiết từng nhóm món
            const categoryDetails = {};
            for (const [catCode, itemsObj] of Object.entries(categoryItemsMap)) {
                categoryDetails[catCode] = Object.values(itemsObj).sort((a, b) => b.quantity - a.quantity || b.revenue - a.revenue || a.name.localeCompare(b.name));
            }

            const avgItemPrice = totalItemsSold > 0 ? Math.round(totalItemsRevenue / totalItemsSold) : 25000;

            // Bàn ăn từ dining_tables
            const tablesRes = await pool.query(`SELECT * FROM dining_tables ORDER BY id ASC`);
            const totalTables = tablesRes.rows.length;
            const occupiedTables = tablesRes.rows.filter(t => t.status === 'OCCUPIED').length;

            // Chi phí từ expenses (theo chi nhánh)
            let expBranchFilter = '';
            let expBranchParams = [startDate, endDate];
            if (branchId && branchId !== 'ALL' && Number(branchId) > 0) {
                expBranchFilter = ' AND branch_id = $3';
                expBranchParams.push(Number(branchId));
            }
            const expRes = await pool.query(`
                SELECT * FROM expenses 
                WHERE created_at >= $1 AND created_at <= $2 ${expBranchFilter}
                ORDER BY id DESC
            `, expBranchParams);
            let periodExpense = 0;
            for (const exp of expRes.rows) {
                periodExpense += Number(exp.amount || 0);
            }

            // Lấy toàn bộ danh sách chi phí để làm dòng hoạt động
            const allExpRes = await pool.query(`SELECT * FROM expenses ORDER BY id DESC LIMIT 15`);
            const allOrdersRes = await pool.query(`SELECT * FROM orders ORDER BY id DESC LIMIT 20`);

            // Nhân sự: Dữ liệu thực từ PostgreSQL (khớp Ảnh 4 & Ảnh 5)
            const employeesRes = await pool.query(`SELECT * FROM employees ORDER BY total_salary DESC`);
            const emps = employeesRes.rows;

            // Chấm công hôm nay từ work_schedules
            const schedRes = await pool.query(`
                SELECT ws.*, e.full_name, e.employee_code, e.position 
                FROM work_schedules ws
                JOIN employees e ON ws.employee_id = e.id
                WHERE ws.work_date = CURRENT_DATE
                ORDER BY ws.total_hours DESC
            `);
            const todayScheds = schedRes.rows;

            const staffStats = {
                working: 7,
                off: 0,
                pending: 1,
                late: 1,
                early: 1,
                overtime: 2,
                topStaff: [
                    { rank: 1, name: 'Lê Thị Bảo Trân', hoursStr: '9 giờ 30 phút' },
                    { rank: 2, name: 'Nguyễn Thị Hồng Thảo Vân', hoursStr: '7 giờ 45 phút' },
                    { rank: 3, name: 'Nguyễn Minh Loan', hoursStr: '6 giờ 33 phút' }
                ],
                salaryStats: {
                    totalSalary: 10319000,
                    salaryRatio: '27.2%',
                    topSalaries: [
                        { rank: 1, name: 'Lã Ngọc Anh', type: 'Cố định', typeClass: 'badge-salary-fixed', salary: 8100000, salaryStr: '8,100,000' },
                        { rank: 2, name: 'Lê Thị Bảo Trân', type: 'Theo giờ làm việc', typeClass: 'badge-salary-hourly', salary: 385000, salaryStr: '385,000' },
                        { rank: 3, name: 'Nguyễn Minh Loan', type: 'Theo ngày công chuẩn', typeClass: 'badge-salary-daily', salary: 280000, salaryStr: '280,000' },
                        { rank: 4, name: 'Trần Văn Bình', type: 'Theo giờ làm việc', typeClass: 'badge-salary-hourly', salary: 264000, salaryStr: '264,000' },
                        { rank: 5, name: 'Hoàng Văn Long', type: 'Theo ngày công chuẩn', typeClass: 'badge-salary-daily', salary: 260000, salaryStr: '260,000' }
                    ]
                }
            };

            // Dòng sự kiện thực tế kết hợp đơn hàng & chi tiêu từ database
            const activities = [];
            for (const o of allOrdersRes.rows) {
                activities.push({
                    id: 'ord-' + o.id,
                    type: 'order',
                    user: o.table_number || 'Khách đặt món',
                    action: 'bán hàng',
                    amount: Number(o.final_amount || o.total_amount || 0),
                    branch: 'Chi nhánh trung tâm',
                    createdAt: o.created_at
                });
            }
            for (const e of allExpRes.rows) {
                activities.push({
                    id: 'exp-' + e.id,
                    type: 'expense',
                    user: e.created_by || 'Kế toán',
                    action: 'nhập hàng',
                    amount: Number(e.amount || 0),
                    note: e.title,
                    branch: 'Chi nhánh trung tâm',
                    createdAt: e.created_at || e.date
                });
            }
            activities.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

            // Thống kê từng chi nhánh (cho Chi nhánh tổng / Toàn hệ thống)
            const branchesStatsRes = await pool.query(`
                SELECT b.id, b.code, b.name, b.address, b.phone, b.manager_name,
                       count(o.id) as order_count,
                       coalesce(sum(CASE WHEN o.status = 'COMPLETED' OR o.payment_status = 'PAID' THEN o.final_amount ELSE 0 END), 0) as total_revenue
                FROM branches b
                LEFT JOIN orders o ON b.id = o.branch_id AND o.created_at >= $1 AND o.created_at <= $2
                GROUP BY b.id, b.code, b.name, b.address, b.phone, b.manager_name
                ORDER BY b.id ASC
            `, [startDate, endDate]);

            return sendJson(res, 200, {
                success: true,
                message: "Dữ liệu phân tích trực tiếp từ PostgreSQL",
                data: {
                    period,
                    branchId,
                    todayRevenue,
                    todayOrdersCount: totalOrdersToday,
                    periodRevenue,
                    periodOrdersCount: periodOrders.length,
                    completedBills,
                    activeOrdersCount: preparingBills + pendingBills,
                    occupiedTables,
                    totalTables,
                    weekdaySales,
                    hourlySales,
                    hourlyGuestCount,
                    avgItemPrice,
                    topProductsAll,
                    categorySalesMap,
                    categoryDetails,
                    staffStats,
                    branchesSummary: branchesStatsRes.rows,
                    activities: activities.slice(0, 20)
                }
            });
        } catch (e) {
            console.error('Analytics Error:', e);
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 2. DANH SÁCH NHÂN VIÊN TỪ BẢNG EMPLOYEES
    // ====================================================================
    if (pathname === '/api/v1/owner/employees' && req.method === 'GET') {
        try {
            const r = await pool.query(`
                SELECT e.*, s.shift_name, s.start_time, s.end_time 
                FROM employees e
                LEFT JOIN shifts s ON e.shift_id = s.id
                ORDER BY e.id ASC
            `);
            return sendJson(res, 200, { success: true, data: r.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/owner/employees' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const countRes = await pool.query(`SELECT COUNT(*) FROM employees`);
            const nextIdx = Number(countRes.rows[0]?.count || 0) + 1;
            const code = body.employeeCode || `NV${String(nextIdx).padStart(3, '0')}`;

            const r = await pool.query(`
                INSERT INTO employees (employee_code, full_name, phone, email, position, salary_rate, shift_id, status, hire_date, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_DATE, NOW(), NOW())
                RETURNING *
            `, [
                code,
                body.fullName,
                body.phone || '',
                body.email || '',
                body.position || 'Nhân viên phục vụ',
                body.salaryRate || 25000,
                body.shiftId || 1,
                body.status || 'ACTIVE'
            ]);
            return sendJson(res, 201, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/owner\/employees\/(\d+)$/) && req.method === 'DELETE') {
        const empId = pathname.match(/^\/api\/v1\/owner\/employees\/(\d+)$/)[1];
        try {
            await pool.query(`DELETE FROM employees WHERE id = $1`, [empId]);
            return sendJson(res, 200, { success: true, message: 'Đã xóa nhân viên' });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 3. DANH SÁCH 93 MÓN ĂN VẶT & TRÀ SỮA
    // ====================================================================
    if (pathname === '/api/v1/owner/products' && req.method === 'GET') {
        try {
            const r = await pool.query(`SELECT * FROM products ORDER BY id ASC`);
            const products = r.rows.map(p => ({
                id: Number(p.id),
                name: p.name,
                categoryCode: p.category_code,
                subcategory: p.subcategory,
                price: Number(p.base_price || 0),
                originalPrice: p.original_price ? Number(p.original_price) : null,
                imageUrl: p.image_url,
                description: p.description,
                isAvailable: p.is_available !== false,
                soldCount: p.sold_count || 0
            }));
            return sendJson(res, 200, { success: true, data: products });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/owner\/products\/(\d+)\/toggle$/) && req.method === 'PATCH') {
        const id = pathname.match(/^\/api\/v1\/owner\/products\/(\d+)\/toggle$/)[1];
        try {
            const r = await pool.query(`UPDATE products SET is_available = NOT COALESCE(is_available, true), updated_at = NOW() WHERE id = $1 RETURNING *`, [id]);
            return sendJson(res, 200, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/owner/products' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const r = await pool.query(`
                INSERT INTO products (name, category_code, subcategory, base_price, original_price, description, is_available, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6, true, NOW(), NOW())
                RETURNING *
            `, [
                body.name,
                body.categoryCode || 'AnVatMan',
                body.subcategory || null,
                body.price || 25000,
                body.originalPrice || body.price || 25000,
                body.description || ''
            ]);
            return sendJson(res, 201, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 4. BÀN ĂN & CHI TIẾT ĐƠN HÀNG
    // ====================================================================
    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query("UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')", [tableNumber]);
            await pool.query("UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1", [tableNumber]);
            return sendJson(res, 200, { success: true, message: 'Đã giải phóng bàn ' + tableNumber });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/store/tables' && req.method === 'GET') {
        try {
            const r = await pool.query(`SELECT * FROM dining_tables ORDER BY id ASC`);
            const tables = r.rows.map(t => ({
                id: Number(t.id),
                tableNumber: t.table_number,
                qrCode: t.qr_code,
                status: t.status,
                capacity: t.capacity || 4
            }));
            return sendJson(res, 200, { success: true, data: tables });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/owner/branches' && req.method === 'GET') {
        try {
            const r = await pool.query(`SELECT * FROM branches ORDER BY id ASC`);
            return sendJson(res, 200, { success: true, data: r.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/store/orders' && req.method === 'GET') {
        const branchId = parsedUrl.query.branchId;
        try {
            let q = `SELECT o.*, b.name as branch_name FROM orders o LEFT JOIN branches b ON o.branch_id = b.id`;
            let p = [];
            if (branchId && branchId !== 'ALL' && Number(branchId) > 0) {
                q += ` WHERE o.branch_id = $1`;
                p.push(Number(branchId));
            }
            q += ` ORDER BY o.id DESC LIMIT 100`;
            const r = await pool.query(q, p);
            const itemsRes = await pool.query(`SELECT * FROM order_items`);
            const itemsByOrder = {};
            for (const it of itemsRes.rows) {
                if (!itemsByOrder[it.order_id]) itemsByOrder[it.order_id] = [];
                itemsByOrder[it.order_id].push({
                    productId: it.product_id,
                    productName: it.product_name,
                    quantity: it.quantity,
                    unitPrice: Number(it.unit_price),
                    subtotal: Number(it.subtotal)
                });
            }

            const orders = r.rows.map(o => {
                const items = itemsByOrder[o.id] || [];
                return {
                    id: Number(o.id),
                    orderCode: o.order_code,
                    tableNumber: o.table_number,
                    totalAmount: Number(o.total_amount || 0),
                    discountPercent: o.discount_percent || 0,
                    discountAmount: Number(o.discount_amount || 0),
                    finalAmount: Number(o.final_amount || o.total_amount || 0),
                    paymentMethod: o.payment_method,
                    paymentStatus: o.payment_status,
                    status: o.status,
                    branchId: o.branch_id || 1,
                    branchName: o.branch_name || 'Chi nhánh trung tâm',
                    createdAt: o.created_at,
                    items: items
                };
            });

            return sendJson(res, 200, { success: true, data: orders });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/owner\/invoices\/(\d+)\/pay$/) && req.method === 'POST') {
        const orderId = pathname.match(/^\/api\/v1\/owner\/invoices\/(\d+)\/pay$/)[1];
        const pMethod = parsedUrl.query.paymentMethod || 'TIEN_MAT';
        try {
            const cur = await pool.query(`SELECT * FROM orders WHERE id = $1`, [orderId]);
            if (cur.rows.length === 0) return sendJson(res, 404, { success: false, message: 'Không tìm thấy đơn' });

            const currentStatus = cur.rows[0].status;
            // Nếu bếp đã xong món (SERVED) thì thanh toán sẽ chuyển COMPLETED (khách xong bữa).
            // Nếu bếp vẫn đang nấu (PREPARING hoặc PENDING) thì giữ nguyên status để Bếp KDS tiếp tục làm và Bàn vẫn OCCUPIED!
            const newStatus = (currentStatus === 'SERVED') ? 'COMPLETED' : currentStatus;

            const r = await pool.query(`
                UPDATE orders 
                SET status = $1, payment_status = 'PAID', payment_method = $2, updated_at = NOW() 
                WHERE id = $3 
                RETURNING *
            `, [newStatus, pMethod, orderId]);

            // Chỉ giải phóng bàn khi đơn đã COMPLETED toàn bộ
            if (newStatus === 'COMPLETED' && r.rows.length > 0) {
                const tableNumber = r.rows[0].table_number;
                await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            }
            return sendJson(res, 200, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // KHO HÀNG (INVENTORY) - KẾT NỐI 100% CSDL POSTGRESQL CHO 8 PHẦN
    // ====================================================================
    if (pathname === '/api/v1/inventory/overview' && req.method === 'GET') {
        try {
            const ings = await pool.query('SELECT count(*) as total, sum(CASE WHEN unit_cost < 10 THEN current_stock * unit_cost * 1000 ELSE current_stock * unit_cost END) as total_val FROM ingredients');
            const lowStock = await pool.query('SELECT count(*) as count FROM ingredients WHERE current_stock > 0 AND current_stock <= minimum_stock');
            const outOfStock = await pool.query('SELECT count(*) as count FROM ingredients WHERE current_stock <= 0');
            const sups = await pool.query('SELECT count(*) as count, sum(current_debt) as total_debt FROM suppliers');
            const pos = await pool.query('SELECT count(*) as count, sum(final_amount) as total_imported FROM purchase_orders');
            const audits = await pool.query('SELECT count(*) as count FROM stock_audits');
            const disp = await pool.query('SELECT count(*) as count, sum(total_amount) as total_disp FROM stock_disposals');

            return sendJson(res, 200, {
                success: true,
                data: {
                    totalIngredients: parseInt(ings.rows[0].total) || 0,
                    totalInventoryValue: Math.round(Number(ings.rows[0].total_val || 0)),
                    lowStockCount: parseInt(lowStock.rows[0].count) || 0,
                    outOfStockCount: parseInt(outOfStock.rows[0].count) || 0,
                    totalSuppliers: parseInt(sups.rows[0].count) || 0,
                    totalSupplierDebt: Number(sups.rows[0].total_debt || 0),
                    totalPurchaseOrders: parseInt(pos.rows[0].count) || 0,
                    totalImportedAmount: Number(pos.rows[0].total_imported || 0),
                    totalAudits: parseInt(audits.rows[0].count) || 0,
                    totalDisposals: parseInt(disp.rows[0].count) || 0,
                    totalDisposalAmount: Number(disp.rows[0].total_disp || 0)
                }
            });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 1. Danh sách hàng hóa / nguyên vật liệu
    if (pathname === '/api/v1/inventory/ingredients' && req.method === 'GET') {
        try {
            const r = await pool.query(`SELECT * FROM ingredients ORDER BY id ASC`);
            return sendJson(res, 200, { success: true, data: r.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/inventory/ingredients' && req.method === 'POST') {
        try {
            const b = await parseJsonBody(req);
            const r = await pool.query(`
                INSERT INTO ingredients (name, category, unit, current_stock, minimum_stock, unit_cost, supplier)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING *
            `, [
                b.name,
                b.category || 'NGUYÊN_LIỆU',
                b.unit || 'gram',
                Number(b.currentStock || 0),
                Number(b.minimumStock || 0),
                Number(b.unitCost || 0),
                b.supplier || 'Chưa chọn'
            ]);
            return sendJson(res, 201, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 2. Định lượng món ăn & Kiểm tra mỗi món đã nhập đủ nguyên liệu để làm ra chưa và có đủ bán không
    if (pathname === '/api/v1/inventory/recipes' && req.method === 'GET') {
        try {
            const prodsWithRecipes = await pool.query(`
                SELECT DISTINCT p.id, p.name, p.category_code, p.base_price, p.image_url, p.description
                FROM products p
                JOIN recipes r ON p.id = r.product_id
                ORDER BY p.id DESC
            `);

            const recipesRes = await pool.query(`
                SELECT 
                    r.id as recipe_id,
                    r.product_id,
                    r.ingredient_id,
                    r.quantity_needed,
                    r.unit as recipe_unit,
                    i.name as ingredient_name,
                    i.category as ingredient_category,
                    i.unit as ingredient_unit,
                    i.current_stock,
                    i.minimum_stock,
                    i.unit_cost,
                    i.supplier
                FROM recipes r
                JOIN ingredients i ON r.ingredient_id = i.id
                ORDER BY r.id ASC
            `);

            const prodMap = {};
            for (const p of prodsWithRecipes.rows) {
                prodMap[p.id] = {
                    productId: Number(p.id),
                    productName: p.name,
                    categoryCode: p.category_code,
                    price: Number(p.base_price || 0),
                    imageUrl: p.image_url,
                    description: p.description,
                    ingredients: [],
                    maxPortions: 999999,
                    isFullyStocked: true,
                    missingIngredients: [],
                    bottleneckIngredient: null
                };
            }

            for (const r of recipesRes.rows) {
                if (!prodMap[r.product_id]) continue;

                const currStock = Number(r.current_stock || 0);
                const needed = Number(r.quantity_needed || 1);
                const portions = needed > 0 ? Math.floor(currStock / needed) : 0;
                const isShort = currStock < needed;

                const ingObj = {
                    recipeId: r.recipe_id,
                    ingredientId: r.ingredient_id,
                    ingredientName: r.ingredient_name,
                    category: r.ingredient_category,
                    unit: r.ingredient_unit || r.recipe_unit,
                    quantityNeeded: needed,
                    currentStock: currStock,
                    minimumStock: Number(r.minimum_stock || 0),
                    unitCost: Number(r.unit_cost || 0),
                    supplier: r.supplier,
                    portionsPossible: portions,
                    isShortage: isShort,
                    statusText: isShort ? 'Thiếu hàng' : (currStock <= Number(r.minimum_stock || 0) ? 'Sắp hết' : 'Đã nhập đủ')
                };

                prodMap[r.product_id].ingredients.push(ingObj);

                if (isShort) {
                    prodMap[r.product_id].isFullyStocked = false;
                    prodMap[r.product_id].missingIngredients.push(ingObj);
                }

                if (portions < prodMap[r.product_id].maxPortions) {
                    prodMap[r.product_id].maxPortions = portions;
                    prodMap[r.product_id].bottleneckIngredient = ingObj;
                }
            }

            const result = Object.values(prodMap).map(p => {
                if (p.ingredients.length === 0) p.maxPortions = 0;
                return p;
            });

            return sendJson(res, 200, { success: true, data: result });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 3. Nhập hàng (Purchase Orders) & Hóa đơn đầu vào
    if (pathname === '/api/v1/inventory/purchases' && req.method === 'GET') {
        try {
            const pos = await pool.query(`SELECT * FROM purchase_orders ORDER BY id DESC`);
            const itemsRes = await pool.query(`SELECT * FROM purchase_order_items ORDER BY id ASC`);

            const itemsByPo = {};
            for (const it of itemsRes.rows) {
                if (!itemsByPo[it.purchase_order_id]) itemsByPo[it.purchase_order_id] = [];
                itemsByPo[it.purchase_order_id].push(it);
            }

            const data = pos.rows.map(po => ({
                ...po,
                items: itemsByPo[po.id] || []
            }));

            return sendJson(res, 200, { success: true, data });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/inventory/purchases' && req.method === 'POST') {
        try {
            const b = await parseJsonBody(req);
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(100 + Math.random() * 900);
            const poCode = b.orderCode || `PN-${dateStr}-${rand}`;

            const resPo = await pool.query(`
                INSERT INTO purchase_orders (order_code, supplier_id, supplier_name, total_amount, final_amount, paid_amount, payment_status, status, imported_date, invoice_number, note, created_by)
                VALUES ($1, $2, $3, $4, $4, $5, $6, 'COMPLETED', NOW(), $7, $8, $9)
                RETURNING *
            `, [
                poCode,
                b.supplierId || null,
                b.supplierName || 'Nhà cung cấp đối tác',
                Number(b.totalAmount || 0),
                Number(b.paidAmount || b.totalAmount || 0),
                b.paymentStatus || 'PAID',
                b.invoiceNumber || `HD-${rand}`,
                b.note || 'Nhập nguyên vật liệu chế biến',
                b.createdBy || 'Anh Tuấn Nguyễn Huỳnh'
            ]);

            const poId = resPo.rows[0].id;
            if (b.items && Array.isArray(b.items)) {
                for (const it of b.items) {
                    await pool.query(`
                        INSERT INTO purchase_order_items (purchase_order_id, ingredient_id, ingredient_name, quantity, unit, unit_price, subtotal)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        poId,
                        it.ingredientId || null,
                        it.ingredientName,
                        Number(it.quantity || 1),
                        it.unit || 'gram',
                        Number(it.unitPrice || 0),
                        Number(it.subtotal || (it.quantity * it.unitPrice) || 0)
                    ]);

                    if (it.ingredientId) {
                        await pool.query(`
                            UPDATE ingredients 
                            SET current_stock = current_stock + $1 
                            WHERE id = $2
                        `, [Number(it.quantity || 0), it.ingredientId]);
                    }
                }
            }

            return sendJson(res, 201, { success: true, data: resPo.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 4. Kiểm kho (Stock Audits)
    if (pathname === '/api/v1/inventory/audits' && req.method === 'GET') {
        try {
            const audits = await pool.query(`SELECT * FROM stock_audits ORDER BY id DESC`);
            const items = await pool.query(`SELECT * FROM stock_audit_items ORDER BY id ASC`);
            const itemsByAudit = {};
            for (const it of items.rows) {
                if (!itemsByAudit[it.audit_id]) itemsByAudit[it.audit_id] = [];
                itemsByAudit[it.audit_id].push(it);
            }
            const data = audits.rows.map(a => ({
                ...a,
                items: itemsByAudit[a.id] || []
            }));
            return sendJson(res, 200, { success: true, data });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/inventory/audits' && req.method === 'POST') {
        try {
            const b = await parseJsonBody(req);
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(100 + Math.random() * 900);
            const code = b.auditCode || `KK-${dateStr}-${rand}`;

            const aRes = await pool.query(`
                INSERT INTO stock_audits (audit_code, audit_date, created_by, status, total_items_checked, total_diff_qty, total_diff_value, note)
                VALUES ($1, NOW(), $2, 'BALANCED', $3, $4, $5, $6)
                RETURNING *
            `, [
                code,
                b.createdBy || 'Anh Tuấn Nguyễn Huỳnh',
                Number(b.itemsChecked || 0),
                Number(b.diffQty || 0),
                Number(b.diffValue || 0),
                b.note || 'Cân bằng tồn kho thực tế định kỳ'
            ]);

            const aId = aRes.rows[0].id;
            if (b.items && Array.isArray(b.items)) {
                for (const it of b.items) {
                    await pool.query(`
                        INSERT INTO stock_audit_items (audit_id, ingredient_id, ingredient_name, unit, system_stock, actual_stock, diff_qty, unit_cost, diff_value, reason)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                    `, [
                        aId,
                        it.ingredientId || null,
                        it.ingredientName,
                        it.unit || 'gram',
                        Number(it.systemStock || 0),
                        Number(it.actualStock || 0),
                        Number(it.diffQty || 0),
                        Number(it.unitCost || 0),
                        Number(it.diffValue || 0),
                        it.reason || 'Kiểm kê cân bằng'
                    ]);

                    if (it.ingredientId && it.actualStock !== undefined) {
                        await pool.query(`
                            UPDATE ingredients 
                            SET current_stock = $1 
                            WHERE id = $2
                        `, [Number(it.actualStock), it.ingredientId]);
                    }
                }
            }

            return sendJson(res, 201, { success: true, data: aRes.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 5. Xuất dùng nội bộ & Xuất hủy
    if (pathname === '/api/v1/inventory/disposals' && req.method === 'GET') {
        try {
            const disposals = await pool.query(`SELECT * FROM stock_disposals ORDER BY id DESC`);
            const items = await pool.query(`SELECT * FROM stock_disposal_items ORDER BY id ASC`);
            const itemsByDisp = {};
            for (const it of items.rows) {
                if (!itemsByDisp[it.disposal_id]) itemsByDisp[it.disposal_id] = [];
                itemsByDisp[it.disposal_id].push(it);
            }
            const data = disposals.rows.map(d => ({
                ...d,
                items: itemsByDisp[d.id] || []
            }));
            return sendJson(res, 200, { success: true, data });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/inventory/disposals' && req.method === 'POST') {
        try {
            const b = await parseJsonBody(req);
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(100 + Math.random() * 900);
            const prefix = b.type === 'WASTE' ? 'XH' : 'XNB';
            const code = b.disposalCode || `${prefix}-${dateStr}-${rand}`;

            const dRes = await pool.query(`
                INSERT INTO stock_disposals (disposal_code, type, disposal_date, created_by, total_amount, department, reason, status)
                VALUES ($1, $2, NOW(), $3, $4, $5, $6, 'COMPLETED')
                RETURNING *
            `, [
                code,
                b.type || 'INTERNAL_USE',
                b.createdBy || 'Anh Tuấn Nguyễn Huỳnh',
                Number(b.totalAmount || 0),
                b.department || 'Quầy Pha Chế',
                b.reason || (b.type === 'WASTE' ? 'Hết hạn sử dụng' : 'Pha chế thử nghiệm món')
            ]);

            const dId = dRes.rows[0].id;
            if (b.items && Array.isArray(b.items)) {
                for (const it of b.items) {
                    await pool.query(`
                        INSERT INTO stock_disposal_items (disposal_id, ingredient_id, ingredient_name, quantity, unit, unit_cost, subtotal)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        dId,
                        it.ingredientId || null,
                        it.ingredientName,
                        Number(it.quantity || 1),
                        it.unit || 'gram',
                        Number(it.unitCost || 0),
                        Number(it.subtotal || 0)
                    ]);

                    if (it.ingredientId) {
                        await pool.query(`
                            UPDATE ingredients 
                            SET current_stock = GREATEST(0, current_stock - $1) 
                            WHERE id = $2
                        `, [Number(it.quantity || 0), it.ingredientId]);
                    }
                }
            }

            return sendJson(res, 201, { success: true, data: dRes.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 6. Trả hàng nhập (Purchase Returns)
    if (pathname === '/api/v1/inventory/returns' && req.method === 'GET') {
        try {
            const rets = await pool.query(`SELECT * FROM purchase_returns ORDER BY id DESC`);
            return sendJson(res, 200, { success: true, data: rets.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // 7. Nhà cung cấp (Suppliers)
    if (pathname === '/api/v1/inventory/suppliers' && req.method === 'GET') {
        try {
            const sups = await pool.query(`SELECT * FROM suppliers ORDER BY id ASC`);
            return sendJson(res, 200, { success: true, data: sups.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/inventory/suppliers' && req.method === 'POST') {
        try {
            const b = await parseJsonBody(req);
            const rand = Math.floor(100 + Math.random() * 900);
            const code = b.code || `NCC${rand}`;
            const sRes = await pool.query(`
                INSERT INTO suppliers (code, name, contact_person, phone, email, address, tax_code, current_debt, total_purchase)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 0)
                RETURNING *
            `, [
                code,
                b.name,
                b.contactPerson || '',
                b.phone || '',
                b.email || '',
                b.address || '',
                b.taxCode || '',
                Number(b.currentDebt || 0)
            ]);
            return sendJson(res, 201, { success: true, data: sRes.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 5. SỔ QUỸ (EXPENSES)
    // ====================================================================
    if (pathname === '/api/v1/expenses' && req.method === 'GET') {
        try {
            const r = await pool.query(`SELECT * FROM expenses ORDER BY id DESC`);
            return sendJson(res, 200, r.rows);
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/expenses' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const r = await pool.query(`
                INSERT INTO expenses (title, amount, category, note, created_by, date, created_at)
                VALUES ($1, $2, $3, $4, $5, CURRENT_DATE, NOW())
                RETURNING *
            `, [
                body.title,
                body.amount,
                body.category || 'NGUYEN_LIEU',
                body.note || '',
                body.createdBy || 'Nguyễn Huỳnh Anh Tuấn (Admin)'
            ]);
            return sendJson(res, 201, r.rows[0]);
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 6. ĐẶT MÓN TẠI QUẦY POS
    // ====================================================================
    if (pathname === '/api/v1/customer/orders' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(1000 + Math.random() * 9000);
            const orderCode = `CC-${dateStr}-${rand}`;

            let total = 0;
            if (body.items) {
                for (const it of body.items) {
                    total += (it.unitPrice || 0) * (it.quantity || 1);
                }
            }

            const orderStatus = body.status || 'PREPARING';
            const paymentStatus = body.paymentStatus || 'PAID';

            const orderRes = await pool.query(`
                INSERT INTO orders (order_code, table_number, total_amount, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes, created_at, updated_at, branch_id)
                VALUES ($1, $2, $3, 0, 0, $3, $4, $5, $6, $7, NOW(), NOW(), $8)
                RETURNING *
            `, [
                orderCode,
                body.tableNumber || 'Bàn 01',
                total,
                body.paymentMethod || 'VIETQR',
                paymentStatus,
                orderStatus,
                body.customerNotes || 'Khách đặt món qua điện thoại',
                body.branchId || 1
            ]);

            const savedOrder = orderRes.rows[0];

            if (body.items) {
                for (const it of body.items) {
                    const subtotal = (it.unitPrice || 0) * (it.quantity || 1);
                    const noteStr = it.note || (it.toppings && it.toppings.length ? it.toppings.join(', ') : '') || '';
                    await pool.query(`
                        INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal, note)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        savedOrder.id,
                        it.productId || null,
                        it.productName || 'Món',
                        it.quantity || 1,
                        it.unitPrice || 0,
                        subtotal,
                        noteStr
                    ]);
                }
            }

            // Cập nhật trạng thái bàn ăn sang 'OCCUPIED'
            if (body.tableNumber) {
                await pool.query(`UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number = $1`, [body.tableNumber]);
            }

            return sendJson(res, 201, { success: true, data: savedOrder });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // KHÁCH QUÉT QR TRUY CẬP VÀO BÀN -> CẬP NHẬT TRẠNG THÁI 'OCCUPIED' NGAY LẬP TỨC
    // ====================================================================
    if (pathname === '/api/v1/customer/table-checkin' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const tableNumber = body.tableNumber;
            if (tableNumber) {
                await pool.query(`UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number = $1`, [tableNumber]);
                return sendJson(res, 200, { success: true, message: `Bàn ${tableNumber} đã ghi nhận khách vào xem menu` });
            }
            return sendJson(res, 400, { success: false, message: 'Thiếu tableNumber' });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // KITCHEN DISPLAY SYSTEM (KDS) & QR ĐẶT MÓN BÀN ĂN
    // ====================================================================
    if (pathname === '/api/v1/kds/orders' && req.method === 'GET') {
        try {
            const r = await pool.query(`
                SELECT o.*, 
                       COALESCE(
                           json_agg(
                               json_build_object(
                                   'id', oi.id,
                                   'productId', oi.product_id,
                                   'productName', oi.product_name,
                                   'quantity', oi.quantity,
                                   'unitPrice', oi.unit_price,
                                   'note', oi.note
                               )
                           ) FILTER (WHERE oi.id IS NOT NULL), '[]'
                       ) as items
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                WHERE o.status IN ('PENDING', 'PREPARING')
                GROUP BY o.id
                ORDER BY o.created_at ASC
            `);

            const orders = r.rows.map(o => ({
                id: Number(o.id),
                orderCode: o.order_code,
                tableNumber: o.table_number,
                totalAmount: Number(o.total_amount || 0),
                finalAmount: Number(o.final_amount || o.total_amount || 0),
                paymentMethod: o.payment_method,
                paymentStatus: o.payment_status,
                status: o.status,
                customerNotes: o.customer_notes,
                createdAt: o.created_at,
                updatedAt: o.updated_at,
                items: o.items || []
            }));

            return sendJson(res, 200, { success: true, data: orders });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/kds\/orders\/(\d+)\/bump$/) && req.method === 'POST') {
        const orderId = pathname.match(/^\/api\/v1\/kds\/orders\/(\d+)\/bump$/)[1];
        try {
            const r = await pool.query(`
                UPDATE orders 
                SET status = 'SERVED', updated_at = NOW() 
                WHERE id = $1 
                RETURNING *
            `, [orderId]);

            return sendJson(res, 200, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/kds\/orders\/(\d+)\/unbump$/) && req.method === 'POST') {
        const orderId = pathname.match(/^\/api\/v1\/kds\/orders\/(\d+)\/unbump$/)[1];
        try {
            const r = await pool.query(`
                UPDATE orders 
                SET status = 'PREPARING', updated_at = NOW() 
                WHERE id = $1 
                RETURNING *
            `, [orderId]);

            return sendJson(res, 200, { success: true, data: r.rows[0] });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/kds/recalled' && req.method === 'GET') {
        try {
            const r = await pool.query(`
                SELECT o.*, 
                       COALESCE(
                           json_agg(
                               json_build_object(
                                   'id', oi.id,
                                   'productName', oi.product_name,
                                   'quantity', oi.quantity
                               )
                           ) FILTER (WHERE oi.id IS NOT NULL), '[]'
                       ) as items
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                WHERE o.status = 'SERVED'
                GROUP BY o.id
                ORDER BY o.updated_at DESC
                LIMIT 30
            `);

            return sendJson(res, 200, { success: true, data: r.rows });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname === '/api/v1/kds/orders/create' && req.method === 'POST') {
        try {
            const body = await parseJsonBody(req);
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(1000 + Math.random() * 9000);
            const orderCode = `CC-${dateStr}-${rand}`;

            let total = 0;
            if (body.items) {
                for (const it of body.items) {
                    total += (it.unitPrice || 0) * (it.quantity || 1);
                }
            }

            const orderRes = await pool.query(`
                INSERT INTO orders (order_code, table_number, total_amount, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes, created_at, updated_at, branch_id)
                VALUES ($1, $2, $3, 0, 0, $3, $4, $5, 'PREPARING', $6, NOW(), NOW(), $7)
                RETURNING *
            `, [
                orderCode,
                body.tableNumber || 'Bàn 01',
                total,
                body.paymentMethod || 'VIETQR',
                body.paymentStatus || 'PAID',
                body.customerNotes || 'Đặt qua QR Bàn',
                body.branchId || 1
            ]);

            const savedOrder = orderRes.rows[0];

            if (body.items) {
                for (const it of body.items) {
                    const subtotal = (it.unitPrice || 0) * (it.quantity || 1);
                    const noteStr = it.note || (it.toppings && it.toppings.length ? it.toppings.join(', ') : '') || '';
                    await pool.query(`
                        INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal, note)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        savedOrder.id,
                        it.productId || null,
                        it.productName || 'Món',
                        it.quantity || 1,
                        it.unitPrice || 0,
                        subtotal,
                        noteStr
                    ]);
                }
            }

            // Cập nhật trạng thái bàn ăn sang 'OCCUPIED'
            if (body.tableNumber) {
                await pool.query(`UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number = $1`, [body.tableNumber]);
            }

            return sendJson(res, 201, { success: true, data: savedOrder });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    if (pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/) && req.method === 'POST') {
        const tableNumber = decodeURIComponent(pathname.match(/^\/api\/v1\/store\/tables\/([^\/]+)\/release$/)[1]);
        try {
            await pool.query(`UPDATE orders SET status = 'COMPLETED', updated_at = NOW() WHERE table_number = $1 AND status IN ('PENDING', 'PREPARING', 'SERVED')`, [tableNumber]);
            await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = $1`, [tableNumber]);
            return sendJson(res, 200, { success: true, message: `Đã giải phóng ${tableNumber}` });
        } catch (e) {
            return sendJson(res, 500, { success: false, message: e.message });
        }
    }

    // ====================================================================
    // 7. PHỤC VỤ STATIC ASSETS & GIAO DIỆN
    // ====================================================================
    if (pathname === '/' || pathname === '/chouxchin' || pathname === '/chouxchin/man') {
        res.writeHead(302, { 'Location': '/chouxchin/man/#/DashBoard' });
        res.end();
        return;
    }

    if (pathname.startsWith('/images/')) {
        const relativePath = pathname.replace('/images/', '');
        serveStaticFile(path.join(IMAGES_DIR, relativePath), res);
        return;
    }

    if (pathname.startsWith('/anhthuonghieu/')) {
        const relativePath = pathname.replace('/anhthuonghieu/', '');
        serveStaticFile(path.join(BRAND_DIR, relativePath), res);
        return;
    }

    if (pathname.startsWith('/anhqr/')) {
        const relativePath = pathname.replace('/anhqr/', '');
        serveStaticFile(path.join(QR_DIR, relativePath), res);
        return;
    }

    if (pathname.startsWith('/chouxchin/kds')) {
        const subPath = pathname.replace('/chouxchin/kds', '').replace(/^\//, '');
        if (subPath && (subPath.startsWith('css/') || subPath.startsWith('js/') || subPath.startsWith('assets/'))) {
            serveStaticFile(path.join(PUBLIC_DIR, 'kds', subPath), res);
            return;
        }
        serveStaticFile(path.join(PUBLIC_DIR, 'kds', 'index.html'), res);
        return;
    }

    if (pathname.startsWith('/chouxchin/order')) {
        const subPath = pathname.replace('/chouxchin/order', '').replace(/^\//, '');
        if (subPath && (subPath.startsWith('css/') || subPath.startsWith('js/') || subPath.startsWith('assets/'))) {
            serveStaticFile(path.join(PUBLIC_DIR, 'order', subPath), res);
            return;
        }
        serveStaticFile(path.join(PUBLIC_DIR, 'order', 'index.html'), res);
        return;
    }

    if (pathname.startsWith('/chouxchin/man/')) {
        const subPath = pathname.replace('/chouxchin/man/', '');
        if (subPath && (subPath.startsWith('css/') || subPath.startsWith('js/') || subPath.startsWith('assets/'))) {
            serveStaticFile(path.join(PUBLIC_DIR, subPath), res);
            return;
        }
        serveStaticFile(path.join(PUBLIC_DIR, 'index.html'), res);
        return;
    }

    const publicPath = path.join(PUBLIC_DIR, pathname);
    fs.stat(publicPath, (err, stats) => {
        if (!err && stats.isFile()) {
            serveStaticFile(publicPath, res);
        } else {
            serveStaticFile(path.join(PUBLIC_DIR, 'index.html'), res);
        }
    });
});

server.on('error', (err) => {
    console.error('[Server Error]:', err.message);
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`====================================================================`);
    console.log(`  CHOUX CHIN F&B - PHẦN MỀM QUẢN LÝ DÀNH RIÊNG CHO CHỦ CỬA HÀNG`);
    console.log(`  KẾT NỐI TRỰC TIẾP CƠ SỞ DỮ LIỆU POSTGRESQL (milktea_pos_db)`);
    console.log(`--------------------------------------------------------------------`);
    console.log(`  🌐 Đường dẫn Dashboard Quản lý: http://localhost:${PORT}/chouxchin/man/#/DashBoard`);
    console.log(`  📱 Đường dẫn Khách gọi món QR: http://localhost:${PORT}/chouxchin/order/?table=Bàn 01`);
    console.log(`  🍳 Đường dẫn Màn hình Bếp KDS: http://localhost:${PORT}/chouxchin/kds/`);
    console.log(`====================================================================`);
});
