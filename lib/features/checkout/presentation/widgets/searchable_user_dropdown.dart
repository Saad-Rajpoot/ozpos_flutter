import 'package:flutter/material.dart';
import '../../../users/domain/entities/user_entity.dart';

/// A searchable dropdown widget for selecting users
/// Shows 4 users by default, with scrolling and search functionality
class SearchableUserDropdown extends StatefulWidget {
  final UserEntity? selectedUser;
  final List<UserEntity> users;
  final ValueChanged<UserEntity?> onChanged;
  final String hintText;
  final bool isRequired;

  const SearchableUserDropdown({
    super.key,
    required this.selectedUser,
    required this.users,
    required this.onChanged,
    this.hintText = 'Select User',
    this.isRequired = false,
  });

  @override
  State<SearchableUserDropdown> createState() => _SearchableUserDropdownState();
}

class _SearchableUserDropdownState extends State<SearchableUserDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<UserEntity> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
  }

  @override
  void didUpdateWidget(SearchableUserDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _filterUsers(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = widget.users;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredUsers = widget.users.where((user) {
          return user.name.toLowerCase().contains(lowerQuery) ||
              user.email.toLowerCase().contains(lowerQuery) ||
              (user.phone != null &&
                  user.phone!.toLowerCase().contains(lowerQuery));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCustomDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(
            color: widget.selectedUser == null && widget.isRequired
                ? const Color(0xFFEF4444)
                : const Color(0xFFD1D5DB),
            width: widget.selectedUser == null && widget.isRequired ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline,
                size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.selectedUser?.name ?? widget.hintText,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.selectedUser == null
                      ? (widget.isRequired
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF9CA3AF))
                      : const Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  void _showCustomDropdown(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Reset search when opening
    _searchController.clear();
    _filterUsers('');

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
            // Dropdown menu
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  // Show ~4 users by default (56px per user + search field + padding = ~280px)
                  // Allow scrolling if more users exist
                  constraints: BoxConstraints(
                    maxHeight: _filteredUsers.length <= 4
                        ? (56.0 * _filteredUsers.length + 100)
                            .clamp(200.0, 400.0)
                        : 280.0, // Fixed height for 4 users, scrollable for more
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search field
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                          ),
                          onChanged: _filterUsers,
                        ),
                      ),
                      const Divider(height: 1),
                      // User list - Show 4 users by default, scrollable for more
                      Flexible(
                        child: _filteredUsers.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? 'No users available'
                                      : 'No users found',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                // Limit initial height to show ~4 users (56px per user = 224px)
                                // But allow scrolling if more users exist
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  final isSelected =
                                      widget.selectedUser?.id == user.id;

                                  return InkWell(
                                    onTap: () {
                                      widget.onChanged(user);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF3B82F6)
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                const Color(0xFF3B82F6)
                                                    .withOpacity(0.1),
                                            child: Text(
                                              user.name.isNotEmpty
                                                  ? user.name[0].toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? const Color(0xFF3B82F6)
                                                  : const Color(0xFF111827),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      // Reset search when dialog closes
      _searchController.clear();
      _filterUsers('');
    });
  }
}
