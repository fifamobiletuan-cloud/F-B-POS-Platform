import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  List<ExpenseModel> _expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _refreshData();
  }

  Future<void> _refreshData() async {
    final orders = await ApiService.getOrders();
    final expenses = await ApiService.getExpenses();
    if (mounted) {
      setState(() {
        _orders = orders;
        _expenses = expenses;
      });
    }
  }

  double get _totalRevenue {
    return _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  double get _totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _netProfit => _totalRevenue - _totalExpenses;

  // Dialog nhập phiếu chi tiêu mới
  void _openAddExpenseModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'NGUYEN_LIEU';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập Phiếu Chi Tiêu Quán', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tên khoản chi (Ví dụ: Mua đá lạnh, Mua sữa)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền chi (đ)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(labelText: 'Danh mục chi', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'NGUYEN_LIEU', child: Text('Nguyên liệu (Trà, sữa, trân châu)')),
                DropdownMenuItem(value: 'VAT_TU', child: Text('Vật tư tiêu hao (Ly, ống hút)')),
                DropdownMenuItem(value: 'DIEN_NUOC', child: Text('Vận hành (Đá lạnh, điện nước)')),
                DropdownMenuItem(value: 'KHAC', child: Text('Chi phí khác')),
              ],
              onChanged: (val) => selectedCategory = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final newExpense = ExpenseModel(
                  id: 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                  createdBy: 'Nguyễn Huỳnh Anh Tuấn (Admin)',
                );
                await ApiService.addExpense(newExpense);
                if (ctx.mounted) Navigator.pop(ctx);
                _refreshData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm phiếu chi thành công!')));
                }
              }
            },
            child: const Text('Lưu Phiếu Chi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.storefront, color: Colors.amber),
            SizedBox(width: 8),
            Text('App Quản Lý Cửa Hàng (Admin & Staff)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.soup_kitchen), text: 'Bếp / Pha Chế'),
            Tab(icon: Icon(Icons.grid_view), text: 'Sơ Đồ Bàn'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Chi Tiêu & Thu'),
            Tab(icon: Icon(Icons.badge), text: 'Chấm Công'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKitchenDisplay(),
          _buildTableGrid(),
          _buildExpenseAndReports(),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  // 1. Màn hình Bếp & Pha Chế (Kitchen Display System)
  Widget _buildKitchenDisplay() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blueGrey.shade50,
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Text('Đơn hàng mới từ bàn khách: ${_orders.length} đơn', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              final isCompleted = order.status == 'COMPLETED';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: isCompleted ? Colors.green : Colors.deepOrange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.brown, borderRadius: BorderRadius.circular(6)),
                            child: Text(order.tableNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Text('Mã đơn: ${order.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Chip(
                            label: Text(
                              isCompleted ? 'Đã xong' : 'Đang pha chế',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: isCompleted ? Colors.green : Colors.deepOrange,
                          ),
                        ],
                      ),
                      const Divider(),
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(
                                      '• ${item.size} | ${item.sugar} | ${item.ice}\n'
                                      '• Topping: ${item.toppings.isEmpty ? 'Không' : item.toppings.join(', ')}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Text('${item.unitPrice.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thanh toán: ${order.paymentMethod}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text('Tổng tiền: ${order.totalAmount.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isCompleted)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () async {
                                await ApiService.updateOrderStatus(order.id, 'COMPLETED');
                                _refreshData();
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Đã Làm Xong Món'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Màn hình Sơ Đồ Bàn (Table Management)
  Widget _buildTableGrid() {
    final tables = List.generate(12, (i) => 'Bàn ${(i + 1).toString().padLeft(2, '0')}');

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final tableName = tables[index];
        final hasOrder = _orders.any((o) => o.tableNumber == tableName && o.status != 'COMPLETED');

        return Card(
          color: hasOrder ? Colors.red.shade100 : Colors.green.shade100,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: hasOrder ? Colors.red : Colors.green, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasOrder ? Icons.table_restaurant : Icons.event_seat,
                size: 36,
                color: hasOrder ? Colors.red.shade900 : Colors.green.shade900,
              ),
              const SizedBox(height: 4),
              Text(tableName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                hasOrder ? 'Đang có khách' : 'Bàn trống',
                style: TextStyle(fontSize: 12, color: hasOrder ? Colors.red.shade900 : Colors.green.shade900),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. Quản lý Chi Tiêu & Doanh Thu Lợi Nhuận
  Widget _buildExpenseAndReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thống kê Doanh Thu - Chi Phí - Lợi Nhuận
          Card(
            color: Colors.blueGrey.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('BÁO CÁO TÀI CHÍNH QUÁN (TỰ ĐỘNG)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildReportStat('Tổng Doanh Thu', '${_totalRevenue.toStringAsFixed(0)}đ', Colors.lightGreenAccent),
                      _buildReportStat('Tổng Chi Phí', '${_totalExpenses.toStringAsFixed(0)}đ', Colors.orangeAccent),
                      _buildReportStat('Lợi Nhuận Ròng', '${_netProfit.toStringAsFixed(0)}đ', Colors.cyanAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Danh Sách Phiếu Chi Tiêu Quán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                onPressed: _openAddExpenseModal,
                icon: const Icon(Icons.add),
                label: const Text('Nhập Phiếu Chi'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final expense = _expenses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Người chi: ${expense.createdBy}'),
                  trailing: Text(
                    '-${expense.amount.toStringAsFixed(0)}đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 4. Quản lý Ca Làm & Chấm Công
  Widget _buildAttendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danh Sách Phân Ca & Chấm Công Nhân Viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Nguyễn Huỳnh Anh Tuấn (Part-time)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ca Tối: 17:30 - 22:30 (Lương: 25.000đ/giờ)'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chấm công [VÀO CA] thành công vào lúc 17:30!')));
                },
                child: const Text('Check-in Vào Ca'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: const Text('Trần Thị Thu Ngân (Part-time)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ca Sáng: 07:30 - 12:30 (Đã hoàn thành 5 giờ)'),
              trailing: const Chip(label: Text('Đã Check-out'), backgroundColor: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}
