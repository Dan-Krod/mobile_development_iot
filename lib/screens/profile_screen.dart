import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/auth/auth_bloc.dart';
import 'package:mobile_development_iot/blocs/flashlight/flashlight_bloc.dart';
import 'package:mobile_development_iot/models/user_model.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/widgets/common/action_button.dart';
import 'package:mobile_development_iot/widgets/common/audit_logs_tile.dart';
import 'package:mobile_development_iot/widgets/common/avatar_header.dart';
import 'package:mobile_development_iot/widgets/common/profile_info_card.dart';
import 'package:mobile_development_iot/widgets/dialogs/edit_profile_dialog.dart';
import 'package:mobile_development_iot/widgets/dialogs/exit_options_sheet.dart';
import 'package:mobile_development_iot/widgets/dialogs/unsupported_os_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashlightBloc(
        context.read<IAuthRepository>(),
        context.read<ApiClient>(),
      ),
      child: BlocListener<AuthBloc, AuthState>(
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
              BlocConsumer<FlashlightBloc, FlashlightState>(
                listener: (context, state) {
                  if (state is FlashlightUnsupportedOS) {
                    UnsupportedOsDialog.show(context);
                  }
                },
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      state.isOn
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      color: state.isOn ? Colors.yellowAccent : Colors.white54,
                    ),
                    onPressed: () => context.read<FlashlightBloc>().add(
                      ToggleProfileFlashlightEvent(),
                    ),
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
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
          body: BlocBuilder<AuthBloc, AuthState>(
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

                      const AuditLogsTile(),

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
                        'v7.0.0 - FLASHLIGHT PLUGIN ACTIVE',
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
      ),
    );
  }
}
