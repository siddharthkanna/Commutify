import 'package:flutter/material.dart';
import 'package:mlritpool/components/navbar.dart';
import 'package:mlritpool/screens/home_screen.dart';
import 'package:mlritpool/screens/myactivity_screen.dart';
import 'package:mlritpool/screens/profile_screen.dart';

class PageViewScreen extends StatefulWidget {
  final int initialPage;
  const PageViewScreen({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen>
    with AutomaticKeepAliveClientMixin<PageViewScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentPage = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldMessenger(
      child: Scaffold(
        resizeToAvoidBottomInset:
            false, // Disable automatic resizing to avoid the screen moving up with the keyboard
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.metrics.axis == Axis.vertical) {
                  // Disable scrolling when the keyboard is open
                  return true;
                }
                return false;
              },
              child: SingleChildScrollView(
                // Wrap PageView with SingleChildScrollView
                child: SizedBox(
                  height: MediaQuery.of(context)
                      .size
                      .height, // Set container height
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: const [
                      KeepAlivePage(child: HomeScreen()),
                      KeepAlivePage(child: MyActivity()),
                      KeepAlivePage(
                          child:
                              ProfileScreen()), // Wrap ProfileScreen with KeepAlivePage
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: NavBar(
                selectedIndex: _currentPage,
                onTabChanged: _onNavItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({Key? key, required this.child}) : super(key: key);

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin<KeepAlivePage> {
  @override
  bool get wantKeepAlive =>
      true; // Return true to indicate that the page should be kept alive

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
