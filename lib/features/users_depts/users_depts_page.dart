import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/network/api_service.dart';
import '../../models/user_model.dart';
import '../../models/department_model.dart';
import '../../services/mock_data_service.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../shared/widgets/status_badge.dart';

class UsersDeptsPage extends StatefulWidget {
  const UsersDeptsPage({Key? key}) : super(key: key);

  @override
  State<UsersDeptsPage> createState() => _UsersDeptsPageState();
}

class _UsersDeptsPageState extends State<UsersDeptsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddUserDialog(BuildContext context) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.employee;
    int selectedDept = mock.departments.first.departmentId;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.person_add_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Tạo Tài Khoản Người Dùng Mới'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập (Username)',
                          hintText: 'Ví dụ: it_linh, kt_hoa',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nguyễn Văn B',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserRole>(
                              value: selectedRole,
                              decoration: const InputDecoration(labelText: 'Vai trò (Role)', isDense: true),
                              items: const [
                                DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                                DropdownMenuItem(value: UserRole.it, child: Text('IT Staff')),
                                DropdownMenuItem(value: UserRole.employee, child: Text('Nhân viên (Employee)')),
                              ],
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedRole = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedDept,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Phòng ban', isDense: true),
                              items: mock.departments.map((d) {
                                return DropdownMenuItem<int>(
                                  value: d.departmentId,
                                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setDialogState(() => selectedDept = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email công ty', hintText: 'user@vynex.vn', isDense: true),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Số điện thoại', hintText: '09xx xxx xxx', isDense: true),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (usernameController.text.trim().isEmpty) return;
                    await api.createUser({
                      'username': usernameController.text.trim(),
                      'full_name': fullNameController.text.trim(),
                      'role_id': selectedRole.roleId,
                      'department_id': selectedDept,
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                    });
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã tạo tài khoản người dùng thành công!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tạo Tài Khoản'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDeptDialog(BuildContext context) {
    final mock = MockDataService();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm Phòng Ban Mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên phòng ban', isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả nhiệm vụ', isDense: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final newDept = DepartmentModel(
                  departmentId: mock.departments.length + 1,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  memberCount: 1,
                  deviceCount: 1,
                );
                mock.departments.add(newDept);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm phòng ban mới thành công!')),
                );
              },
              child: const Text('Lưu Phòng Ban'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mock = MockDataService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhân sự & Phòng ban (Users & Departments)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý danh sách nhân viên, tài khoản IT và cơ cấu tổ chức',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showAddDeptDialog(context),
                    icon: const Icon(Icons.domain_add_rounded, size: 16),
                    label: const Text('Thêm Phòng Ban'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.person_add_rounded, size: 16),
                    label: const Text('Thêm Người Dùng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppConstants.primaryBlue,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            indicatorColor: AppConstants.primaryBlue,
            tabs: const [
              Tab(text: 'Danh Sách Người Dùng (Users)'),
              Tab(text: 'Cơ Cấu Phòng Ban (Departments)'),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          SearchFilterBar(
            hintText: 'Tìm kiếm theo tên, username, email...',
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 16),

          // Tab content
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                // Users list
                List<UserModel> users = mock.users;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  users = users.where((u) => u.fullName.toLowerCase().contains(q) || u.username.toLowerCase().contains(q)).toList();
                }

                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppConstants.primaryBlue.withOpacity(0.15),
                              foregroundColor: AppConstants.primaryBlue,
                              radius: 18,
                              child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('@${u.username}  •  ${u.email ?? "Chưa có email"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u.departmentName ?? 'Chưa phân bổ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('SĐT: ${u.phone ?? "N/A"}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: u.role == UserRole.admin
                                    ? const Color(0xFFEDE9FE)
                                    : (u.role == UserRole.it ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.role.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: u.role == UserRole.admin
                                      ? const Color(0xFF6D28D9)
                                      : (u.role == UserRole.it ? const Color(0xFF0284C7) : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            StatusBadge(status: u.status),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                // Departments list
                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mock.departments.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = mock.departments[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.corporate_fare_rounded, color: AppConstants.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(d.description ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('Trưởng phòng: ${d.managerName ?? "Chưa chỉ định"}', style: const TextStyle(fontSize: 13)),
                            ),
                            Text('${d.memberCount} thành viên  •  ${d.deviceCount} thiết bị', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryBlue)),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
