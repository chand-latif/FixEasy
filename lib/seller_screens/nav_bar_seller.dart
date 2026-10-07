import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import 'my_services_screen.dart';

class NavBarSeller extends StatelessWidget {
  final int currentIndex;
  const NavBarSeller({super.key, this.currentIndex = 0});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
            context, '/sellerHome', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/sellerBookingRequests');
        break;
      case 2:
        final companyId =
            Provider.of<AuthViewModel>(context, listen: false).companyId;
        if (companyId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyServicesScreen(companyId: companyId),
            ),
          );
        }
        break;
      case 3:
        Navigator.pushNamed(context, '/sellerProfile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, 0, Icons.home_rounded, 'Home'),
              _navItem(context, 1, Icons.book_online_rounded, 'Bookings'),
              _navItem(context, 2, Icons.miscellaneous_services_rounded, 'Services'),
              _navItem(context, 3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _onTap(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : Colors.grey, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
