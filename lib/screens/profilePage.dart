import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pub/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _username = '';
  late String _userEmail = '';
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    getUserDetails();
    _checkPermissions();
  }

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
      _userEmail = prefs.getString('userEmail') ?? 'Unknown';
    });
  }

  Future<void> _checkPermissions() async {
    List<Permission> permissions = [ Permission.microphone];
    List<PermissionStatus> statuses = await Future.wait(
      permissions.map((permission) => _requestPermission(permission)),
    );

    Map<Permission, PermissionStatus> permissionStatusMap = {};
    for (int i = 0; i < permissions.length; i++) {
      permissionStatusMap[permissions[i]] = statuses[i];
    }

    setState(() {
      _permissionStatuses = permissionStatusMap;
    });
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      await _showPermanentlyDeniedDialog(permission);
    }
    return status;
  }

  Future<void> _showPermanentlyDeniedDialog(Permission permission) async {
    bool openSettings = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${permission.toString().split('.').last} Permission'),
          content: Text(
            'This app needs ${permission.toString().split('.').last} permission to function properly. You can grant the permission in the app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
    if (openSettings == true) {
      await openAppSettings();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('userEmail');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Lottie.asset(
                  height: 150,
                  "assets/animations/profile.json",
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "User Details",
                style: TextStyle(color: Colors.grey),
              ),
              _buildUserDetailTile(
                icon: Icons.account_circle,
                label: 'Username',
                value: _username,
              ),
              _buildUserDetailTile(
                icon: Icons.email,
                label: 'Email',
                value: _userEmail,
              ),
              const SizedBox(height: 32),
              const Text(
                "Permissions",
                style: TextStyle(color: Colors.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPermissionRow(Permission.microphone),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: const TextStyle(color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPermissionRow(Permission permission) {
    String permissionName = permission.toString().split('.').last;
    PermissionStatus? status = _permissionStatuses[permission];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          permissionName.capitalize(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            if (status?.isGranted == true) {
              // Permission granted
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Permission for $permissionName already granted.'),
              ));
            } else {
              // Permission not granted
              _requestPermission(permission);
            }
          },
          child: Text(
            status?.isPermanentlyDenied == true
                ? 'Open Settings'
                : status?.isGranted == true
                    ? 'Granted'
                    : 'Request',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
