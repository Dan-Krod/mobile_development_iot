import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/auth_cubit.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/screens/audit_logs_screen.dart';
import 'package:mobile_development_iot/widgets/common/action_button.dart';
import 'package:mobile_development_iot/widgets/common/avatar_header.dart';
import 'package:mobile_development_iot/widgets/common/profile_info_card.dart';
import 'package:mobile_development_iot/widgets/dialogs/edit_profile_dialog.dart';
import 'package:mobile_development_iot/widgets/dialogs/exit_options_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ENGINEER PROFILE'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          EditProfileDialog(currentUser: state.user),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            UserModel? user;
            if (state is AuthAuthenticated) user = state.user;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    const AvatarHeader(),
                    const SizedBox(height: 30),
                    ProfileInfoCard(user: user),
                    const SizedBox(height: 30),
                    ListTile(
                      leading: const Icon(
                        Icons.list_alt_rounded,
                        color: Colors.blueAccent,
                      ),
                      title: const Text(
                        'VIEW AUDIT LOGS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => const AuditLogsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ActionButton(
                        text: 'TERMINATE SESSION',
                        onPressed: () => ExitOptionsSheet.show(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'v6.0.0 - BLOC ARCHITECTURE ACTIVE',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
