import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/top_toast.dart';

/// شاشة "عن المطور".
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      showTopToast(context, 'تعذر فتح الرابط', title: 'تنبيه', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final whatsapp = Uri.parse(
      'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent('السلام عليكم، لدي اقتراح لتطبيق ${AppConstants.appName}: ')}',
    );
    final instagram = Uri.parse('https://instagram.com/${AppConstants.instagramUser}');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'عن المطور'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.splash,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: alpha(AppColors.splash, .25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppConstants.developerName,
                          textAlign: TextAlign.center,
                          style: AppText.heading(size: 34, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.developerRole,
                          textAlign: TextAlign.center,
                          style: AppText.body(size: 17, weight: FontWeight.w700, color: AppColors.gold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: alpha(Colors.white, .08),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppConstants.developerStatus,
                                style: AppText.body(
                                  size: 14.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFFC8493A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFF5FA575)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    radius: 30,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.navy, size: 22),
                            const SizedBox(width: 10),
                            Text('نبذة عني', style: AppText.heading(size: 20)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppConstants.developerBio,
                          style: AppText.body(size: 16, height: 2),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 24, 4, 12),
                    child: _SectionLabel('تواصل واقتراحات'),
                  ),
                  AppCard(
                    radius: 30,
                    borderColor: AppColors.greenBorder,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconBox(
                          icon: Icons.chat_rounded,
                          color: AppColors.green,
                          background: AppColors.greenTint,
                          size: 42,
                          radius: 14,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('راسلني عبر واتساب', style: AppText.body(size: 17, weight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text(
                                'يسعدني استقبال اقتراحاتك وأفكارك لتطوير التطبيق',
                                style: AppText.body(size: 13.5, color: AppColors.muted, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _open(context, whatsapp),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'إرسال',
                                    style: AppText.body(size: 14.5, weight: FontWeight.w700, color: Colors.white),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    radius: 30,
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => _open(context, instagram),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconBox(
                              icon: Icons.camera_alt_outlined,
                              color: AppColors.rose,
                              background: AppColors.roseTint,
                              size: 42,
                              radius: 14,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حساب إنستغرام',
                                    style: AppText.body(size: 17, weight: FontWeight.w800, color: AppColors.rose),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '@${AppConstants.instagramUser}',
                                    textDirection: TextDirection.ltr,
                                    style: AppText.body(size: 15.5, weight: FontWeight.w600, color: AppColors.rose),
                                  ),
                                ],
                              ),
                            ),
                            AppChevron(color: AppColors.rose),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppText.body(size: 16, weight: FontWeight.w700, color: AppColors.muted),
      );
}
