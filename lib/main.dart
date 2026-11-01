import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/network/api_service.dart';
import 'services/auth_service.dart';
import 'services/permission_service.dart';
import 'services/support_ticket_service.dart';
import 'shared/widgets/sidebar.dart';
import 'shared/widgets/top_bar.dart';
import 'features/auth/login_page.dart';
import 'features/overview_connect/overview_page.dart';
import 'features/devices/devices_page.dart';
import 'features/support_tickets/support_tickets_page.dart';
import 'features/permissions/permissions_page.dart';
import 'features/users_depts/users_depts_page.dart';
import 'features/reports_logs/reports_logs_page.dart';
import 'features/settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VynexApp());
}

class VynexApp extends StatefulWidget {
  const VynexApp({Key? key}) : super(key: key);

  @override
  State<VynexApp> createState() => _VynexAppState();
}

class _VynexAppState extends State<VynexApp> {
  bool _isDark = true; // Default dark theme inspired by modern RustDesk

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()..checkHealth()),
        ChangeNotifierProvider(create: (_) => PermissionService()),
        ChangeNotifierProvider(create: (_) => SupportTicketService()),
      ],
      child: MaterialApp(
        title: AppConstants.appFullName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        home: DashboardShell(
          isDark: _isDark,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}

class DashboardShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DashboardShell({
    Key? key,
    required this.isDark,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String _activeRoute = 'overview';
  bool _isSidebarCollapsed = false;

  void _navigateTo(String route) {
    setState(() {
      _activeRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // If logged out -> show LoginPage
    if (!auth.isAuthenticated) {
      return const LoginPage();
    }

    Widget activePage;
    switch (_activeRoute) {
      case 'overview':
        activePage = OverviewPage(onNavigate: _navigateTo);
        break;
      case 'tickets':
        activePage = const SupportTicketsPage();
        break;
      case 'devices':
        activePage = const DevicesPage();
        break;
      case 'permissions':
        activePage = const PermissionsPage();
        break;
      case 'users':
        activePage = const UsersDeptsPage();
        break;
      case 'reports':
        activePage = const ReportsLogsPage();
        break;
      case 'settings':
        activePage = const SettingsPage();
        break;
      default:
        activePage = OverviewPage(onNavigate: _navigateTo);
    }

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Sidebar(
            activeRoute: _activeRoute,
            onSelectRoute: _navigateTo,
            isCollapsed: _isSidebarCollapsed,
            isDark: widget.isDark,
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // TopBar Header
                TopBar(
                  onToggleSidebar: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                  onToggleTheme: widget.onToggleTheme,
                  isDark: widget.isDark,
                ),

                // Active Page View
                Expanded(
                  child: Container(
                    color: widget.isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    child: activePage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
