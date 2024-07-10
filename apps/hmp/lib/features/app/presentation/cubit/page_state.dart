part of 'page_cubit.dart';

class PageState extends BaseState {
  final PreloadPageController pageController;
  final MenuType menuType;

  @override
  final RequestStatus submitStatus;

  const PageState({
    required this.pageController,
    required this.menuType,
    this.submitStatus = RequestStatus.initial,
  });

  factory PageState.initial() => PageState(
      submitStatus: RequestStatus.initial,
      menuType: MenuType.home,
      pageController: PreloadPageController(initialPage: 2));

  @override
  List<Object?> get props => [pageController, menuType, submitStatus];

  @override
  PageState copyWith({
    RequestStatus? status,
    MenuType? menuType,
  }) {
    return PageState(
      pageController: pageController,
      menuType: menuType ?? this.menuType,
      submitStatus: status ?? submitStatus,
    );
  }
}
