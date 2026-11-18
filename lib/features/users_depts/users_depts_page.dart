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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    await Future.wait([
      api.getUsers(),
      api.getDepartments(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- DIALOG: THÊM NGƯỜI DÙNG ---
  void _showAddUserDialog(BuildContext context) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final usernameController = TextEditingController();
    final passwordController = TextEditingController(text: '123');
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.employee;
    int selectedDept = mock.departments.isNotEmpty ? mock.departments.first.departmentId : 1;

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
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Tên đăng nhập (Username) *',
                                hintText: 'it_nam, kt_hoa',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu khởi tạo *',
                                hintText: 'Mặc định: 123',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên đầy đủ *',
                          hintText: 'Ví dụ: Nguyễn Văn Bảo',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserRole>(
                              value: selectedRole,
                              decoration: const InputDecoration(labelText: 'Vai trò (Role)', isDense: true),
                              items: const [
                                DropdownMenuItem(value: UserRole.admin, child: Text('Admin (Quản trị)')),
                                DropdownMenuItem(value: UserRole.it, child: Text('IT Support (Kỹ thuật)')),
                                DropdownMenuItem(value: UserRole.employee, child: Text('Nhân viên (Client)')),
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
                              decoration: const InputDecoration(labelText: 'Phòng ban', isDense: true),
                              items: mock.departments.map((d) {
                                return DropdownMenuItem(
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
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'Email công ty', hintText: 'user@vynex.vn', isDense: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'Số điện thoại', hintText: '09xx xxx xxx', isDense: true),
                            ),
                          ),
                        ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (usernameController.text.trim().isEmpty || fullNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập Tên đăng nhập và Họ tên!')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final ok = await api.createUser({
                      'username': usernameController.text.trim(),
                      'password_hash': passwordController.text.trim().isNotEmpty ? passwordController.text.trim() : '123',
                      'full_name': fullNameController.text.trim(),
                      'role_id': selectedRole.roleId,
                      'department_id': selectedDept,
                      'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                      'phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    });
                    if (!mounted) return;
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Tạo tài khoản người dùng thành công!' : 'Tạo thất bại')),
                    );
                  },
                  child: const Text('Tạo Người Dùng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG: SỬA THÔNG TIN NGƯỜI DÙNG ---
  void _showEditUserDialog(BuildContext context, UserModel user) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');
    UserRole selectedRole = user.role;
    int selectedDept = user.departmentId ?? (mock.departments.isNotEmpty ? mock.departments.first.departmentId : 1);

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppConstants.primaryBlue),
                  const SizedBox(width: 10),
                  Text('Sửa Thông Tin: @${user.username}'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(labelText: 'Họ và tên *', isDense: true),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserRole>(
                              value: selectedRole,
                              decoration: const InputDecoration(labelText: 'Vai trò (Role)', isDense: true),
                              items: const [
                                DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                                DropdownMenuItem(value: UserRole.it, child: Text('IT Support')),
                                DropdownMenuItem(value: UserRole.employee, child: Text('Nhân viên')),
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
                              decoration: const InputDecoration(labelText: 'Phòng ban', isDense: true),
                              items: mock.departments.map((d) {
                                return DropdownMenuItem(
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
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email', isDense: true),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Số điện thoại', isDense: true),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final deptName = mock.departments.firstWhere((d) => d.departmentId == selectedDept, orElse: () => mock.departments.first).name;
                    await api.updateUser(user.userId, {
                      'full_name': fullNameController.text.trim(),
                      'role_id': selectedRole.roleId,
                      'department_id': selectedDept,
                      'department_name': deptName,
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                    });
                    if (!mounted) return;
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật thông tin người dùng thành công!')),
                    );
                  },
                  child: const Text('Lưu Thay Đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG: ĐẶT LẠI MẬT KHẨU ---
  void _showResetPasswordDialog(BuildContext context, UserModel user) {
    final api = Provider.of<ApiService>(context, listen: false);
    final passController = TextEditingController(text: '123');

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.key_rounded, color: Colors.amber),
              const SizedBox(width: 10),
              Text('Đặt Lại Mật Khẩu: @${user.username}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Người dùng: ${user.fullName}'),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới *',
                  hintText: 'Nhập mật khẩu mới',
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
              onPressed: () async {
                if (passController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await api.updateUser(user.userId, {
                  'password_hash': passController.text.trim(),
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã đặt lại mật khẩu cho @${user.username} thành công!')),
                );
              },
              child: const Text('Xác Nhận Đổi'),
            ),
          ],
        );
      },
    );
  }

  // --- TOGGLE STATUS (KHÓA / MỞ KHÓA) ---
  void _toggleUserStatus(UserModel user) async {
    final api = Provider.of<ApiService>(context, listen: false);
    final newStatus = user.status == 'active' ? 'inactive' : 'active';
    await api.updateUser(user.userId, {'status': newStatus});
    if (!mounted) return;
    _fetchData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newStatus == 'active' ? 'Đã kích hoạt lại tài khoản @${user.username}' : 'Đã tạm khóa tài khoản @${user.username}')),
    );
  }

  // --- CONFIRM XÓA NGƯỜI DÙNG ---
  void _confirmDeleteUser(BuildContext context, UserModel user) {
    if (user.role == UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa tài khoản Quản trị viên tối cao (Admin)!')),
      );
      return;
    }
    final api = Provider.of<ApiService>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa Người Dùng'),
          content: Text('Bạn có chắc chắn muốn xóa tài khoản "${user.fullName}" (@${user.username}) khỏi hệ thống?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await api.deleteUser(user.userId);
                if (!mounted) return;
                _fetchData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa người dùng "${user.fullName}" thành công!')),
                );
              },
              child: const Text('Xác Nhận Xóa'),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOG: THÊM PHÒNG BAN ---
  void _showAddDeptDialog(BuildContext context) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final nameController = TextEditingController();
    final descController = TextEditingController();
    int? selectedManagerId = mock.users.isNotEmpty ? mock.users.first.userId : null;

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
                  Icon(Icons.domain_add_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Thêm Phòng Ban Mới'),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên phòng ban *',
                        hintText: 'Ví dụ: Phòng Nhân sự & Hành chính',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả nhiệm vụ',
                        hintText: 'Quản lý tuyển dụng, chế độ nhân viên...',
                        isDense: true,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int?>(
                      value: selectedManagerId,
                      decoration: const InputDecoration(labelText: 'Trưởng phòng (Người quản lý)', isDense: true),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Chưa chỉ định')),
                        ...mock.users.map((u) {
                          return DropdownMenuItem(value: u.userId, child: Text('${u.fullName} (@${u.username})'));
                        }),
                      ],
                      onChanged: (v) => setDialogState(() => selectedManagerId = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final mgrName = selectedManagerId != null
                        ? mock.users.firstWhere((u) => u.userId == selectedManagerId).fullName
                        : null;
                    await api.createDepartment({
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'manager_id': selectedManagerId,
                      'manager_name': mgrName,
                    });
                    if (!mounted) return;
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã tạo phòng ban mới thành công!')),
                    );
                  },
                  child: const Text('Lưu Phòng Ban'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG: SỬA PHÒNG BAN ---
  void _showEditDeptDialog(BuildContext context, DepartmentModel dept) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final nameController = TextEditingController(text: dept.name);
    final descController = TextEditingController(text: dept.description ?? '');
    int? selectedManagerId = dept.managerId;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.edit_location_alt_rounded, color: AppConstants.primaryBlue),
                  const SizedBox(width: 10),
                  Text('Sửa Phòng Ban: ${dept.name}'),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên phòng ban *', isDense: true),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Mô tả nhiệm vụ', isDense: true),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int?>(
                      value: selectedManagerId,
                      decoration: const InputDecoration(labelText: 'Trưởng phòng (Người quản lý)', isDense: true),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Chưa chỉ định')),
                        ...mock.users.map((u) {
                          return DropdownMenuItem(value: u.userId, child: Text('${u.fullName} (@${u.username})'));
                        }),
                      ],
                      onChanged: (v) => setDialogState(() => selectedManagerId = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final mgrName = selectedManagerId != null
                        ? mock.users.firstWhere((u) => u.userId == selectedManagerId).fullName
                        : null;
                    await api.updateDepartment(dept.departmentId, {
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'manager_id': selectedManagerId,
                      'manager_name': mgrName,
                    });
                    if (!mounted) return;
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật phòng ban thành công!')),
                    );
                  },
                  child: const Text('Lưu Thay Đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- CONFIRM XÓA PHÒNG BAN ---
  void _confirmDeleteDept(BuildContext context, DepartmentModel dept) {
    final api = Provider.of<ApiService>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa Phòng Ban'),
          content: Text('Bạn có chắc muốn xóa "${dept.name}"? Các nhân viên thuộc phòng ban này sẽ được chuyển thành Chưa phân bổ.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await api.deleteDepartment(dept.departmentId);
                if (!mounted) return;
                _fetchData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa phòng ban "${dept.name}"!')),
                );
              },
              child: const Text('Xác Nhận Xóa'),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOG: XEM DANH SÁCH THÀNH VIÊN TRONG PHÒNG BAN ---
  void _showDeptMembersDialog(BuildContext context, DepartmentModel dept) {
    final mock = MockDataService();
    final members = mock.users.where((u) => u.departmentId == dept.departmentId).toList();
    final devices = mock.devices.where((d) => d.departmentId == dept.departmentId).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: AppConstants.primaryBlue),
              const SizedBox(width: 10),
              Text('${dept.name} (${members.length} nhân sự)'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trưởng phòng: ${dept.managerName ?? "Chưa chỉ định"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Danh sách nhân sự:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  if (members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Chưa có nhân viên nào trong phòng ban này', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF94A3B8))),
                    )
                  else
                    ...members.map((u) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppConstants.primaryBlue.withOpacity(0.2),
                            child: Text(u.fullName.isNotEmpty ? u.fullName[0] : 'U', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text('@${u.username} • ${u.role.displayName}', style: const TextStyle(fontSize: 11)),
                          trailing: StatusBadge(status: u.status),
                        )),
                  const Divider(height: 24),
                  Text('Thiết bị thuộc quyền quản lý (${devices.length}):', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  if (devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Chưa có máy tính nào được đăng ký', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF94A3B8))),
                    )
                  else
                    ...devices.map((d) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(d.deviceType == 'laptop' ? Icons.laptop_mac_rounded : Icons.desktop_windows_rounded, size: 20, color: AppConstants.primaryBlue),
                          title: Text(d.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          subtitle: Text('ID: ${d.vynexId} • IP: ${d.ipAddress ?? "N/A"}', style: const TextStyle(fontSize: 11)),
                          trailing: StatusBadge(status: d.status),
                        )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
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
                    'Quản lý danh sách nhân viên, tài khoản IT, phân quyền RBAC và cơ cấu tổ chức',
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
                    onPressed: _isLoading ? null : () => _fetchData(),
                    icon: _isLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(_isLoading ? 'Đang đồng bộ...' : 'Làm Mới'),
                  ),
                  const SizedBox(width: 10),
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
            tabs: [
              Tab(text: 'Danh Sách Người Dùng (${mock.users.length})'),
              Tab(text: 'Cơ Cấu Phòng Ban (${mock.departments.length})'),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          SearchFilterBar(
            hintText: 'Tìm kiếm theo tên, username, email, phòng ban...',
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 16),

          // Tab Content
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                // USERS LIST
                List<UserModel> users = List.from(mock.users);
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  users = users.where((u) {
                    return u.fullName.toLowerCase().contains(q) ||
                        u.username.toLowerCase().contains(q) ||
                        (u.email ?? '').toLowerCase().contains(q) ||
                        (u.departmentName ?? '').toLowerCase().contains(q);
                  }).toList();
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppConstants.primaryBlue.withOpacity(0.15),
                              foregroundColor: AppConstants.primaryBlue,
                              radius: 18,
                              child: Text(
                                u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // User Info
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: u.role == UserRole.admin
                                              ? const Color(0xFFEDE9FE)
                                              : (u.role == UserRole.it ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          u.role.displayName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: u.role == UserRole.admin
                                              ? const Color(0xFF6D28D9)
                                              : (u.role == UserRole.it ? const Color(0xFF0284C7) : const Color(0xFF475569)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('@${u.username} • ${u.email ?? "Chưa có email"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            // Dept & Phone
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
                            // Status Badge
                            StatusBadge(status: u.status),
                            const SizedBox(width: 12),
                            // Action Icons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Sửa thông tin',
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    onPressed: () => _showEditUserDialog(context, u),
                                    splashRadius: 18,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Đặt lại mật khẩu',
                                  child: IconButton(
                                    icon: const Icon(Icons.key_outlined, size: 18, color: Colors.amber),
                                    onPressed: () => _showResetPasswordDialog(context, u),
                                    splashRadius: 18,
                                  ),
                                ),
                                Tooltip(
                                  message: u.status == 'active' ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                                  child: IconButton(
                                    icon: Icon(
                                      u.status == 'active' ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                                      size: 18,
                                      color: u.status == 'active' ? Colors.orange : Colors.green,
                                    ),
                                    onPressed: () => _toggleUserStatus(u),
                                    splashRadius: 18,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Xóa tài khoản',
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                    onPressed: () => _confirmDeleteUser(context, u),
                                    splashRadius: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                // DEPARTMENTS LIST
                final depts = mock.departments;
                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: depts.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = depts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            // Dept info
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(d.description ?? 'Chưa có mô tả', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            // Manager
                            Expanded(
                              flex: 3,
                              child: Text('Trưởng phòng: ${d.managerName ?? "Chưa chỉ định"}', style: const TextStyle(fontSize: 13)),
                            ),
                            // Members & Devices count
                            Text(
                              '${d.memberCount} thành viên  •  ${d.deviceCount} máy tính',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryBlue),
                            ),
                            const SizedBox(width: 16),
                            // Dept Action Icons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Xem danh sách nhân sự',
                                  child: IconButton(
                                    icon: const Icon(Icons.people_alt_outlined, size: 18, color: AppConstants.primaryBlue),
                                    onPressed: () => _showDeptMembersDialog(context, d),
                                    splashRadius: 18,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Sửa phòng ban',
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    onPressed: () => _showEditDeptDialog(context, d),
                                    splashRadius: 18,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Xóa phòng ban',
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                    onPressed: () => _confirmDeleteDept(context, d),
                                    splashRadius: 18,
                                  ),
                                ),
                              ],
                            ),
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
