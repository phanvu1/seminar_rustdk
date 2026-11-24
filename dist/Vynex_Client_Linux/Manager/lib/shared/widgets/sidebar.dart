import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import 'vynex_logo.dart';

class SidebarItem {
  final String id;
  final String title;
  final IconData icon;
  final List<UserRole> allowedRoles;

  const SidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.allowedRoles,
  });
}

class Sidebar extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String> onSelectRoute;
  final bool isCollapsed;
  final bool? isDark;

  const Sidebar({
    Key? key,
    required this.activeRoute,
    required this.onSelectRoute,
    this.isCollapsed = false,
    this.isDark,
  }) : super(key: key);

  static List<SidebarItem> getMenuItemsForRole(UserRole role) {
    if (role == UserRole.employee) {
      // THEO LỖI 2.4: Thanh điều hướng (Sidebar) của Nhân viên CHỈ ĐƯỢC PHÉP có 2 danh mục chính:
      // 1. "Yêu cầu hỗ trợ" (Tạo yêu cầu hỗ trợ mới)
      // 2. "Lịch sử yêu cầu của tôi" (Xem danh sách, hủy pending, đánh giá sao completed)
      // XÓA BỎ HOÀN TOÀN "Tổng quan & Kết nối"
      return const [
        SidebarItem(
          id: 'employee_create_ticket',
          title: 'Yêu cầu hỗ trợ',
          icon: Icons.add_circle_outline_rounded,
          allowedRoles: [UserRole.employee],
        ),
        SidebarItem(
          id: 'employee_my_tickets',
          title: 'Lịch sử yêu cầu của tôi',
          icon: Icons.history_rounded,
          allowedRoles: [UserRole.employee],
        ),
      ];
    }

    const allItems = [
      SidebarItem(
        id: 'overview',
        title: 'Tổng quan & Kết nối',
        icon: Icons.dashboard_rounded,
        allowedRoles: [UserRole.admin, UserRole.it],
      ),
      SidebarItem(
        id: 'tickets',
        title: 'Yêu cầu Hỗ trợ',
        icon: Icons.support_agent_rounded,
        allowedRoles: [UserRole.admin, UserRole.it],
      ),
      SidebarItem(
        id: 'devices',
        title: 'Quản lý Thiết bị',
        icon: Icons.devices_rounded,
        allowedRoles: [UserRole.admin, UserRole.it],
      ),
      SidebarItem(
        id: 'permissions',
        title: 'Phân quyền IT - Thiết bị',
        icon: Icons.vpn_key_rounded,
        allowedRoles: [UserRole.admin],
      ),
      SidebarItem(
        id: 'users',
        title: 'Nhân sự & Phòng ban',
        icon: Icons.people_alt_rounded,
        allowedRoles: [UserRole.admin],
      ),
      SidebarItem(
        id: 'reports',
        title: 'Báo cáo & Lịch sử',
        icon: Icons.insights_rounded,
        allowedRoles: [UserRole.admin],
      ),
      SidebarItem(
        id: 'settings',
        title: 'Cấu hình Hệ thống',
        icon: Icons.settings_rounded,
        allowedRoles: [UserRole.admin, UserRole.it],
      ),
    ];

    return allItems.where((item) => item.allowedRoles.contains(role)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final activeRole = auth.activeRole;
    final width = isCollapsed ? 76.0 : 260.0;

    // Tự động đồng bộ theo Theme hiện tại hoặc cờ isDark (Lỗi 2)
    final themeIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    final visibleItems = getMenuItemsForRole(activeRole);

    // Bảng màu phân định rạch ròi theo Light Mode vs Dark Mode chuẩn theo yêu cầu Lỗi 2
    final bgColor = themeIsDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = themeIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor = themeIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final hoverColor = themeIsDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 18 : 20),
            alignment: Alignment.centerLeft,
            child: isCollapsed
                ? VynexLogo(size: 32, showText: false, isDark: themeIsDark)
                : VynexLogo(size: 32, showText: true, isDark: themeIsDark),
          ),
          Divider(color: dividerColor, height: 1),

          const SizedBox(height: 12),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                final isSelected = activeRoute == item.id;

                // Màu sắc menu item động theo trạng thái theme chuẩn Lỗi 2:
                // Light: Active nền #EFF6FF, text/icon #0066FF; Unselected icon #475569, text #475569
                // Dark: Active nền #0066FF.withOpacity(0.15), text sáng, icon #38BDF8; Unselected #94A3B8
                final Color itemBgColor;
                final Color itemIconColor;
                final Color itemTextColor;

                if (isSelected) {
                  itemBgColor = themeIsDark
                      ? const Color(0xFF0066FF).withOpacity(0.15)
                      : const Color(0xFFEFF6FF); // Xanh nhạt khi light
                  itemIconColor = themeIsDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0066FF); // Xanh Vynex khi light
                  itemTextColor = themeIsDark
                      ? Colors.white
                      : const Color(0xFF0066FF); // Xanh Vynex khi light
                } else {
                  itemBgColor = Colors.transparent;
                  itemIconColor = themeIsDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569); // Xám đậm khi light
                  itemTextColor = themeIsDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF475569); // Xám đậm khi light
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelectRoute(item.id),
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: hoverColor,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCollapsed ? 16 : 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: itemBgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: themeIsDark
                                      ? const Color(0xFF0066FF).withOpacity(0.3)
                                      : const Color(0xFFBFDBFE),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: itemIconColor,
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: itemTextColor,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Server Status Mini Card (HBBS & Relay)
          if (!isCollapsed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeIsDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vynex Relay Server',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeIsDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HBBS: 21116 • HBBR: 21117',
                    style: TextStyle(
                      color: themeIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

          Divider(color: dividerColor, height: 1),

          // User info footer
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 16 : 16,
              vertical: 12,
            ),
            child: isCollapsed
                ? IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                    onPressed: () => auth.logout(),
                    tooltip: 'Đăng xuất',
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppConstants.primaryBlue,
                        child: Text(
                          auth.currentUser.fullName.isNotEmpty
                              ? auth.currentUser.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.currentUser.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeIsDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              auth.activeRole.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.logout_rounded,
                          color: themeIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          size: 18,
                        ),
                        onPressed: () => auth.logout(),
                        tooltip: 'Đăng xuất',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
