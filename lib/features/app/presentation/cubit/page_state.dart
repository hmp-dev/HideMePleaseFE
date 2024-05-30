part of 'page_cubit.dart';

class PageState extends BaseState {
  final PreloadPageController pageController;

  @override
  final RequestStatus submitStatus;

  const PageState({
    required this.pageController,
    this.submitStatus = RequestStatus.initial,
  });

  factory PageState.initial() => PageState(
      submitStatus: RequestStatus.initial,
      pageController: PreloadPageController(initialPage: 2));

  @override
  List<Object?> get props => [pageController, submitStatus];

  @override
  PageState copyWith({
    RequestStatus? status,
  }) {
    return PageState(
      pageController: pageController,
      submitStatus: status ?? submitStatus,
    );
  }
}
