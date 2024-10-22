import 'package:flutter/material.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class UserDrawer extends StatefulWidget {
  final String userEmail;
  final WepinLifeCycle wepinStatus;
  final String selectedLanguage;
  final String? selectedMode;
  final List<Map<String, dynamic>> sdkConfigs;
  final Map<String, String> currency;
  final Function(String?) onModeChanged;
  final Function(String?) onLanguageChanged;
  final List<LoginProvider> socialLogins; // List of available social logins
  final List<LoginProvider> selectedSocialLogins; // Initially selected social logins
  final Function(List<LoginProvider>) onSocialLoginsChanged; // Callback for changes in social logins

  const UserDrawer({
    Key? key,
    required this.userEmail,
    required this.wepinStatus,
    required this.selectedLanguage,
    required this.selectedMode,
    required this.sdkConfigs,
    required this.currency,
    required this.onModeChanged,
    required this.onLanguageChanged,
    required this.socialLogins,
    required this.selectedSocialLogins,
    required this.onSocialLoginsChanged,
  }) : super(key: key);

  @override
  UserDrawerState createState() => UserDrawerState();
}

class UserDrawerState extends State<UserDrawer> {
  late List<LoginProvider> _selectedSocialLogins; // Store selected social logins
  late List<LoginProvider> _socialLogins; // Store all social logins

  @override
  void initState() {
    super.initState();
    // Initialize with the initially selected social logins
    _selectedSocialLogins = List.from(widget.selectedSocialLogins);
    _socialLogins = List.from(widget.socialLogins);
  }

  void _onSocialLoginChanged(bool? isSelected, LoginProvider loginProvider) {
    setState(() {
      if (isSelected == true) {
        _selectedSocialLogins.add(loginProvider);
      } else {
        _selectedSocialLogins.remove(loginProvider);
      }
      // Notify about the changes
      widget.onSocialLoginsChanged(_selectedSocialLogins);
    });
  }

  void _handleModeChanged(String? newMode) {
    setState(() {
      // Update the mode
      widget.onModeChanged(newMode);
      // Find the new social logins for the selected mode
      final selectedConfig = widget.sdkConfigs.firstWhere((config) => config['name'] == newMode);
      _socialLogins = List.from(selectedConfig['loginProviders']);
      _selectedSocialLogins = List.from(_socialLogins);
      // Notify about the changes
      widget.onSocialLoginsChanged(_selectedSocialLogins);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[700],
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Email: ${widget.userEmail}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Status: ${widget.wepinStatus}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blueAccent),
            title: const Text('Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: DropdownButton<String>(
              value: widget.selectedMode,
              onChanged: _handleModeChanged, //widget.onModeChanged,
              underline: Container(),
              style: const TextStyle(color: Colors.blueAccent),
              items: widget.sdkConfigs.map((config) {
                return DropdownMenuItem<String>(
                  value: config['name'],
                  child: Text(config['name']!),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blueAccent),
            title: const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: DropdownButton<String>(
              value: widget.selectedLanguage,
              onChanged: widget.onLanguageChanged,
              underline: Container(),
              style: const TextStyle(color: Colors.blueAccent),
              items: ['ko', 'en', 'ja'].map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
            ),
          ),
          const Divider(thickness: 1),
          // Social Login Section
          const ListTile(
            title: Text('Social Logins', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._socialLogins.map((loginProvider) {
            return CheckboxListTile(
              title: Text(loginProvider.provider),
              value: _selectedSocialLogins.contains(loginProvider),
              onChanged: (bool? isSelected) {
                _onSocialLoginChanged(isSelected, loginProvider);
              },
            );
          }).toList(),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
