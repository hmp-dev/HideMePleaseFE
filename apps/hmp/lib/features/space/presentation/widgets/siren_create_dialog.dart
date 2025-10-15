import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SirenCreateDialog extends StatefulWidget {
  final String spaceId;
  final String spaceName;
  final Function(String message, int hours, int points) onConfirm;

  const SirenCreateDialog({
    Key? key,
    required this.spaceId,
    required this.spaceName,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<SirenCreateDialog> createState() => _SirenCreateDialogState();
}

class _SirenCreateDialogState extends State<SirenCreateDialog> {
  final TextEditingController _messageController = TextEditingController();
  int _selectedHours = 9; // Default: 9시간
  final int _maxLength = 40;

  // 시간별 포인트 정책
  int _getPointsForHours(int hours) {
    switch (hours) {
      case 3:
        return 1;
      case 9:
        return 2;
      case 24:
        return 3;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPoints = _getPointsForHours(_selectedHours);
    final isMessageEmpty = _messageController.text.trim().isEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFE8F7FF),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF132E41),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/ico_siren_create.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.siren_create_title.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 입력 필드
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF132E41),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                    maxLength: _maxLength,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.siren_create_placeholder.tr(),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontFamily: 'LINESeedKR',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterText: '',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF132E41),
                      fontFamily: 'LINESeedKR',
                    ),
                    onChanged: (value) {
                      setState(() {}); // 글자 수 업데이트
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '(${_messageController.text.length}/$_maxLength)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'LINESeedKR',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 시간 선택 버튼
            Row(
              children: [
                Expanded(
                  child: _buildTimeButton(3, LocaleKeys.siren_hour_3.tr()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeButton(9, LocaleKeys.siren_hour_9.tr()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeButton(24, LocaleKeys.siren_hour_24.tr()),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 하단 버튼
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          LocaleKeys.cancel.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'LINESeedKR',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: isMessageEmpty
                        ? null
                        : () {
                            widget.onConfirm(
                              _messageController.text.trim(),
                              _selectedHours,
                              currentPoints,
                            );
                            Navigator.of(context).pop();
                          },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isMessageEmpty
                            ? Colors.grey[300]
                            : const Color(0xFF00A3FF),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocaleKeys.siren_use_sav.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isMessageEmpty
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontFamily: 'LINESeedKR',
                              ),
                            ),
                            const SizedBox(width: 6),
                            SvgPicture.asset(
                              'assets/icons/ico_sav_black.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                isMessageEmpty
                                    ? Colors.grey[500]!
                                    : Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$currentPoints',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isMessageEmpty
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontFamily: 'LINESeedKR',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(int hours, String label) {
    final isSelected = _selectedHours == hours;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHours = hours;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132E41) : Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF000000),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white,
              fontFamily: 'LINESeedKR',
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
