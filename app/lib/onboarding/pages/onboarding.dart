import 'package:auto_route/auto_route.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/module.dart';
import '../../../common/routing/router.dart';

const pagesCount = 3;
List<Widget> getPages(
  PageController pageController,
  ValueNotifier<int> currentPage,
) {
  final pages = [
    OnboardingSubPage(
      pageController: pageController,
      currentPage: currentPage,
      imagePath: 'assets/images/onboarding_welcome.svg',
      getHeader: (context) => {context.l10n.onboarding_welcome_page_header},
      getText: (context) => {context.l10n.onboarding_welcome_page_text},
    ),
    OnboardingSubPage(
      pageController: pageController,
      currentPage: currentPage,
      imagePath: 'assets/images/onboarding_medicine.svg',
      getHeader: (context) => {context.l10n.onboarding_medicine_page_header},
      getText: (context) => {context.l10n.onboarding_medicine_page_text},
    ),
    OnboardingSubPage(
      pageController: pageController,
      currentPage: currentPage,
      imagePath: 'assets/images/onboarding_security.svg',
      getHeader: (context) => {context.l10n.onboarding_security_page_header},
      getText: (context) => {context.l10n.onboarding_security_page_text},
    ),
  ];

  assert(pages.length == pagesCount);
  return pages;
}

class OnboardingPage extends HookWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: 0);
    final currentPage = useState(0);

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (newPage) => currentPage.value = newPage,
        children: getPages(pageController, currentPage),
      ),
    );
  }
}

class OnboardingSubPage extends StatelessWidget {
  const OnboardingSubPage({
    Key? key,
    required this.pageController,
    required this.currentPage,
    required this.imagePath,
    required this.getHeader,
    required this.getText,
  }) : super(key: key);

  final PageController pageController;
  final ValueNotifier<int> currentPage;
  final String imagePath;
  final Set<String> Function(BuildContext) getHeader;
  final Set<String> Function(BuildContext) getText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.theme.colorScheme.primary,
            context.theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              top: 40,
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      imagePath,
                      width: 256,
                      height: 256,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    getHeader(context).single,
                    style: context.textTheme.headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    getText(context).single,
                    style: context.textTheme.bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(context, currentPage.value),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildNextButton(
                context,
                pageController,
                currentPage.value == pagesCount - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator(BuildContext context, int currentPage) {
    final list = <Widget>[];
    for (var i = 0; i < pagesCount; ++i) {
      list.add(i == currentPage
          ? _indicator(context, true)
          : _indicator(context, false));
    }
    return list;
  }

  Widget _indicator(BuildContext context, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : context.theme.disabledColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    PageController pageController,
    bool isLastPage,
  ) {
    return TextButton(
      onPressed: () {
        if (isLastPage) {
          context.router.replace(const LoginRouter());
        } else {
          pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLastPage
                ? context.l10n.onboarding_get_started
                : context.l10n.onboarding_next,
            style:
                context.textTheme.headlineSmall!.copyWith(color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }
}
