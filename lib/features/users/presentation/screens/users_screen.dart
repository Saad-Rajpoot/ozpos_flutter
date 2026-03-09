import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../bloc/user_management_bloc.dart';
import '../bloc/user_management_event.dart';
import '../bloc/user_management_state.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import '../../domain/entities/user_entity.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    // Load users if not already loaded
    final bloc = context.read<UserManagementBloc>();
    final currentState = bloc.state;
    if (currentState is! UserManagementLoaded &&
        currentState is! UserManagementLoading) {
      bloc.add(const LoadUsersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.1,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: context.bgPrimary,
        body: Row(
          children: [
            // Sidebar navigation
            if (MediaQuery.of(context).size.width >= 768)
              const SidebarNav(activeRoute: AppRouter.users),

            // Main content
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: BlocBuilder<UserManagementBloc, UserManagementState>(
                      builder: (context, state) {
                        if (state is UserManagementLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is UserManagementError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<UserManagementBloc>()
                                        .add(const LoadUsersEvent());
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is UserManagementLoaded) {
                          return _buildUsersList(state.users);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    const lightBorder = Color(0xFFE5E7EB);
    final borderColor =
        colorScheme.brightness == Brightness.light ? lightBorder : context.borderLight;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.bgSurface,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage users',
                  style: TextStyle(fontSize: 14, color: context.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: context.read<UserManagementBloc>(),
                  child: const AddUserDialog(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserEntity> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserEntity user) {
    final colorScheme = Theme.of(context).colorScheme;
    const lightBorder = Color(0xFFE5E7EB);
    final borderColor =
        colorScheme.brightness == Brightness.light ? lightBorder : context.borderLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
                if (user.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: context.read<UserManagementBloc>(),
                  child: EditUserDialog(user: user),
                ),
              );
            },
            tooltip: 'Edit User',
          ),
        ],
      ),
    );
  }
}
