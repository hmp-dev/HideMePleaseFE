import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:mobile/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/presentation/screens/user_profile_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsListScreen(),
      ),
    );
  }

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load friends list on init
    final friendsCubit = getIt<FriendsCubit>();
    friendsCubit.getFriendsList(page: 1, limit: 100); // Load first page with 100 items
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      body: SafeArea(
        child: Column(
          children: [
            // App bar with back button and title
            _buildAppBar(),

            // Search bar
            _buildSearchBar(),

            // Friends list
            Expanded(
              child: BlocBuilder<FriendsCubit, FriendsState>(
                bloc: getIt<FriendsCubit>(),
                builder: (context, state) {
                  if (state.submitStatus == RequestStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF19BAFF),
                      ),
                    );
                  }

                  final friends = state.friendsList;

                  // Filter friends based on search query
                  final filteredFriends = _searchQuery.isEmpty
                      ? friends
                      : friends.where((friendship) {
                          final nickname = friendship.friend.nickName.toLowerCase();
                          return nickname.contains(_searchQuery);
                        }).toList();

                  // Show empty state if no friends
                  if (friends.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Show no results state if search returns nothing
                  if (filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNoResultsState();
                  }

                  // Show friends list
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friendship = filteredFriends[index];
                      return _buildFriendItem(friendship);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button (left aligned)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF132E41),
                  size: 20,
                ),
              ),
            ),
          ),

          // Title with icon (center aligned)
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/ico_friend_request.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.friends.tr(),
                style: const TextStyle(
                  color: Color(0xFF132E41),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF132E41).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: const Color(0xFF132E41).withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: LocaleKeys.search.tr(),
                hintStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.3),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: Icon(
                Icons.close,
                color: const Color(0xFF132E41).withValues(alpha: 0.5),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(friendship) {
    final friend = friendship.friend;

    // Get current user's checked-in space ID
    final currentSpaceId = getIt<SpaceCubit>().state.currentCheckedInSpaceId;

    // Determine dot color based on check-in status
    Color? dotColor;
    if (friend.activeCheckIn != null) {
      if (currentSpaceId != null && friend.activeCheckIn!.spaceId == currentSpaceId) {
        // Same space - blue dot
        dotColor = const Color(0xFF19BAFF);
      } else {
        // Different space - orange dot
        dotColor = const Color(0xFFFF9500);
      }
    }

    return GestureDetector(
      onTap: () {
        UserProfileScreen.push(context, userId: friend.userId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF132E41).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile avatar
            ProfileAvatarWidget(
              profilePartsString: null,
              imageUrl: friend.profileImageUrl,
              size: 56,
              borderRadius: 28,
              placeholderPath: 'assets/images/profile_img.png',
              fit: BoxFit.cover,
            ),

            const SizedBox(width: 16),

            // Name and intro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        friend.nickName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (dotColor != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friend.introduction ?? '올지로에 출몰하는 맛잘알',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        LocaleKeys.add_friends_message.tr(),
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Text(
        LocaleKeys.no_search_results.tr(),
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
