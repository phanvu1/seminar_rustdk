import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/network/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification_model.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const TopBar({
    Key? key,
    required this.onToggleSidebar,
    required this.onToggleTheme,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final api = Provider.of<ApiService>(context);
    final user = auth.currentUser;
    final activeRole = auth.activeRole;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Mobile Hamburger toggle
          IconButton(
            onPressed: onToggleSidebar,
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            tooltip: 'Đóng/Mở thanh điều hướng',
          ),
          const SizedBox(width: 8),

          // API Status Indicator Pill
          InkWell(
            onTap: () {
              api.checkHealth();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: api.isBackendConnected
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: api.isBackendConnected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: api.isBackendConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    api.isBackendConnected ? 'Backend Live' : 'Demo Fallback',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: api.isBackendConnected
                          ? const Color(0xFF047857)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // --- ROLE SWITCHER (Demo Feature) ---
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoleOption(
                  context,
                  role: UserRole.admin,
                  label: 'Admin',
                  icon: Icons.admin_panel_settings_rounded,
                  isActive: activeRole == UserRole.admin,
                  onSelect: () => auth.switchRole(UserRole.admin),
                ),
                _buildRoleOption(
                  context,
                  role: UserRole.it,
                  label: 'IT Staff',
                  icon: Icons.support_agent_rounded,
                  isActive: activeRole == UserRole.it,
                  onSelect: () => auth.switchRole(UserRole.it),
                ),
                _buildRoleOption(
                  context,
                  role: UserRole.employee,
                  label: 'Nhân viên',
                  icon: Icons.badge_rounded,
                  isActive: activeRole == UserRole.employee,
                  onSelect: () => auth.switchRole(UserRole.employee),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Theme Toggle
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
              size: 20,
            ),
            tooltip: isDark ? 'Chuyển sang giao diện Sáng' : 'Chuyển sang giao diện Tối',
          ),
          const SizedBox(width: 8),

          // Notification Bell (Phân quyền 3 vai trò theo Lỗi 2.2)
          FutureBuilder<List<NotificationModel>>(
            future: api.getNotifications(userId: user.userId, role: activeRole),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final unreadCount = list.where((n) => !n.isRead).length;

              return PopupMenuButton<String>(
                tooltip: 'Thông báo',
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      enabled: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thông báo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              api.markAllNotificationsAsRead(
                                userId: activeRole == UserRole.admin ? null : user.userId,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Đọc tất cả', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    if (list.isEmpty)
                      const PopupMenuItem(
                        enabled: false,
                        child: Center(
                          child: Text('Không có thông báo mới', style: TextStyle(fontSize: 13)),
                        ),
                      )
                    else
                      ...list.take(6).map((n) {
                        return PopupMenuItem(
                          onTap: () {
                            api.markNotificationAsRead(n.notificationId);
                          },
                          child: Container(
                            width: 320,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: n.isRead
                                        ? Colors.grey.withOpacity(0.1)
                                        : (n.type == 'permission_request'
                                            ? const Color(0xFFF59E0B).withOpacity(0.15)
                                            : AppConstants.primaryBlue.withOpacity(0.15)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    n.type == 'support_request'
                                        ? Icons.support_agent_rounded
                                        : (n.type == 'permission_granted'
                                            ? Icons.vpn_key_rounded
                                            : (n.type == 'permission_request'
                                                ? Icons.lock_clock_rounded
                                                : Icons.info_outline_rounded)),
                                    size: 16,
                                    color: n.isRead
                                        ? Colors.grey
                                        : (n.type == 'permission_request'
                                            ? const Color(0xFFF59E0B)
                                            : AppConstants.primaryBlue),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: TextStyle(
                                          fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ];
                },
              );
            },
          ),
          const SizedBox(width: 16),

          // User Profile Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppConstants.primaryBlue,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      activeRole.shortName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
