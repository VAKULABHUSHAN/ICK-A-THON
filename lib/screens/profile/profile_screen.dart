import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chain_logo.dart';
import '../../widgets/family_avatar.dart';
import '../family/add_family_member_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile & Family'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Family Overview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x256516D5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Family Medicine Account',
                            style: TextStyle(fontSize: 13, color: AppColors.lavender, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${state.familyMembers.length} MEMBERS',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Shared Household Inventory',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...state.familyMembers.map(
                              (m) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FamilyAvatar(member: m, size: 44, showLabel: false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Family Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                ...state.familyMembers.map(
                  (m) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: FamilyAvatar(member: m, size: 40, showLabel: false),
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${m.relation}${m.notes != null ? " · ${m.notes}" : ""}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        state.setSelectedFamilyMember(m.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Filtered inventory for ${m.name}')),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFamilyMemberScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Add Family Member'),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Application & Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.archive_outlined, color: AppColors.primary),
                        title: const Text('Finished & Archived Medicines'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Viewing archived records')),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      ListTile(
                        leading: const Icon(Icons.storage_rounded, color: AppColors.primary),
                        title: const Text('Backend Mode'),
                        subtitle: Text(state.isMockMode ? 'Current: Mock Repository' : 'Current: Live Supabase Backend'),
                        trailing: Switch(
                          value: !state.isMockMode,
                          onChanged: (val) => state.toggleMode(!val),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        title: const Text('About ExpiryChain'),
                        subtitle: const Text('Tagline: "The identity that survives."'),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'ExpiryChain',
                            applicationVersion: '1.0.0 (ICK-A-THON 2026)',
                            applicationIcon: const ChainLogo(size: 40),
                            children: const [
                              Text('A family medicine management application for organizing medicines, photographing packaging, tracking expiry, and allocating doses across family members.'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
