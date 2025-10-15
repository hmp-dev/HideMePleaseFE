import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class FriendRequestButton extends StatelessWidget {
  final FriendshipStatus? friendshipStatus;
  final VoidCallback onPressed;
  final bool isLoading;

  const FriendRequestButton({
    super.key,
    required this.friendshipStatus,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 56,
        decoration: BoxDecoration(
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF132E41),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            else ...[
              Image.asset(
                'assets/icons/ico_friend_request.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getButtonText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (friendshipStatus) {
      case FriendshipStatus.PENDING:
        return LinearGradient(
          colors: [
            const Color(0xFFE0E0E0),
            const Color(0xFFF5F5F5),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case FriendshipStatus.ACCEPTED:
        return LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return LinearGradient(
          colors: [
            const Color(0xff00A3FF),
            const Color(0xff5FC5FF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  String _getButtonText() {
    switch (friendshipStatus) {
      case FriendshipStatus.PENDING:
        return LocaleKeys.friend_request_pending.tr();
      case FriendshipStatus.ACCEPTED:
        return LocaleKeys.friends.tr();
      default:
        return LocaleKeys.friend_request.tr();
    }
  }
}
