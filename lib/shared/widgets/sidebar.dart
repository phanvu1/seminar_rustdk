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
  final bool isDark;

  const Sidebar({
    Key? key,
    required this.activeRoute,
    required this.onSelectRoute,
    this.isCollapsed = false,
    this.isDark = true,
  }) : super(key: key);

  static const List<SidebarItem> menuItems = [
    SidebarItem(
      id: 'overview',
      title: 'Tổng quan & Kết nối',
      icon: Icons.dashboard_rounded,
      allowedRoles: [UserRole.admin, UserRole.it, UserRole.employee],
    ),
    SidebarItem(
      id: 'tickets',
      title: 'Yêu cầu Hỗ trợ',
      icon: Icons.support_agent_rounded,
      allowedRoles: [UserRole.admin, UserRole.it, UserRole.employee],
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final activeRole = auth.activeRole;
    final width = isCollapsed ? 76.0 : 260.0;

    final visibleItems = menuItems.where((item) => item.allowedRoles.contains(activeRole)).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B), // Modern Deep Navy
        border: const Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
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
                ? const VynexLogo(size: 32, showText: false, isDark: true)
                : const VynexLogo(size: 32, showText: true, isDark: true),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),

          const SizedBox(height: 12),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                final isSelected = activeRoute == item.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelectRoute(item.id),
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: const Color(0xFF1E293B),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCollapsed ? 16 : 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppConstants.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
                color: const Color(0xFF16203A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF263353)),
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
                      const Text(
                        'Vynex Relay Server',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'HBBS: 21116 • HBBR: 21117',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Color(0xFF1E293B), height: 1),

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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              auth.activeRole.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8), size: 18),
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
