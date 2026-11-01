import 'package:flutter/material.dart';
import '../../core/constants.dart';

class VynexLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const VynexLogo({
    Key? key,
    this.size = 36,
    this.showText = true,
    this.isDark = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Icon (Blue hexagon shield with V monogram)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryBlue.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: size * 0.65,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VYNEX',
                style: TextStyle(
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Remote Control & Support',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
