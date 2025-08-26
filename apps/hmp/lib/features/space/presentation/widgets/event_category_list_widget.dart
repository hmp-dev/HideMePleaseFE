import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/presentation/cubit/event_category_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/event_category_state.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class EventCategoryListWidget extends StatelessWidget {
  final Function(EventCategoryEntity?) onCategorySelected;

  const EventCategoryListWidget({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCategoryCubit, EventCategoryState>(
      builder: (context, state) {
        print('🚨🚨🚨 EVENT CATEGORY WIDGET: state=${state.submitStatus}, categories=${state.eventCategories.length}');
        
        if (state.submitStatus == RequestStatus.loading) {
          return const SizedBox(
            height: 38,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3FF)),
              ),
            ),
          );
        }

        if (state.eventCategories.isEmpty) {
          print('🚨🚨🚨 EVENT CATEGORY WIDGET: No event categories to display - returning empty widget');
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.eventCategories.length,
            itemBuilder: (context, index) {
              final category = state.eventCategories[index];
              final isSelected = state.selectedEventCategory?.id == category.id;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                ),
                child: _buildEventCategoryButton(
                  category: category,
                  isSelected: isSelected,
                  context: context,
                  onTap: () {
                    context.read<EventCategoryCubit>().selectEventCategory(
                          isSelected ? null : category,
                        );
                    onCategorySelected(isSelected ? null : category);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventCategoryButton({
    required EventCategoryEntity category,
    required bool isSelected,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final backgroundColor = category.colorCode != null
        ? _parseColorCode(category.colorCode!)
        : const Color(0xFF3A3A3A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00A3FF)
                : const Color(0xFF5A5A5A),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.iconUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category.iconUrl!,
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              EasyLocalization.of(context)!.locale.languageCode == 'ko'
                  ? category.name
                  : (category.nameEn ?? category.name),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF9A9A9A),
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColorCode(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF3A3A3A);
    } catch (e) {
      return const Color(0xFF3A3A3A);
    }
  }
}