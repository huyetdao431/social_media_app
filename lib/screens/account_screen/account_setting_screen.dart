import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_cubit/main_cubit.dart';

class AccountSettingScreen extends StatelessWidget {
  static const String route = 'AccountSettingScreen';

  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Cài đặt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'Chỉnh sửa trang cá nhân',
                onTap: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Mật khẩu và bảo mật',
                onTap: () {
                  Navigator.pushNamed(context, '/security');
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Switch Theme',
                onTap: () {
                  context.read<MainCubit>().switchTheme();
                },
              ),
              Divider(
                thickness: 4,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
              ),
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                isLogout: true,
                onTap: () {
                  _showLogoutConfirm(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: isLogout ? color.error : color.onSurface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? color.error : color.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Xử lý đăng xuất
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
