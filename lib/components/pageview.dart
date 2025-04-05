import 'package:flutter/material.dart';
import 'package:commutify/components/navbar.dart';
import 'package:commutify/screens/home_screen.dart';
import 'package:commutify/screens/myrides/myrides_screen.dart';
import 'package:commutify/screens/profile_screen.dart';
import 'package:commutify/Themes/app_theme.dart';

class PageViewScreen extends StatefulWidget {
  final int initialPage;
  const PageViewScreen({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen>
    with AutomaticKeepAliveClientMixin<PageViewScreen> {
  late PageController _pageController;
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Get the bottom safe area padding for devices with notches
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      // Use the background color of your screens (usually ivory or white)
      backgroundColor: Apptheme.surface,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: const [
          HomeScreen(),
          MyRides(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0.0 : 0.0),
        child: NavBar(
          selectedIndex: _currentPage,
          onTabChanged: _onNavItemTapped,
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
