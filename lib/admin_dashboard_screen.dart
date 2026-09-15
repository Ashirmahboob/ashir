import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'login_screen.dart';
import 'admin_support_chat_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Admin Dashboard",
    "Driver Management",
    "Ride History",
    "Support Chats",
    "SOS Configuration",
  ];

  Future<void> _logout(BuildContext context) async {
    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text(
                "Are you sure you want to log out of the Admin Portal?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B)),
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error logging out: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFC2185B),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFC2185B)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings,
                    color: Color(0xFFC2185B), size: 40),
              ),
              accountName: const Text(
                "Admin Management Portal",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "admin@portal.com",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFC2185B)),
              title: const Text("Users"),
              selected: _selectedIndex == 0,
              selectedTileColor: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi, color: Color(0xFFC2185B)),
              title: const Text("Drivers"),
              selected: _selectedIndex == 1,
              selectedTileColor: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFFC2185B)),
              title: const Text("Rides"),
              selected: _selectedIndex == 2,
              selectedTileColor: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFFC2185B)),
              title: const Text("Support"),
              selected: _selectedIndex == 3,
              selectedTileColor: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield, color: Color(0xFFC2185B)),
              title: const Text("SOS Config"),
              selected: _selectedIndex == 4,
              selectedTileColor: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFC2185B)),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingsScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? const PassengerAdminPanel()
          : _selectedIndex == 1
              ? const PassengerAdminPanel(isDriver: true)
              : Column(
                  children: [
                    if (_selectedIndex != 4) const AdminSOSConfigCard(),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: const [
                          SizedBox.shrink(),
                          UserListStream(
                              key: PageStorageKey('driver_view'),
                              role: 'driver'),
                          AllRideHistoryStream(
                              key: PageStorageKey('rides_view')),
                          AdminSupportChatListScreen(
                              key: PageStorageKey('chats_view')),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                AdminSOSConfigCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class PassengerAdminPanel extends StatefulWidget {
  final bool isDriver;

  const PassengerAdminPanel({super.key, this.isDriver = false});

  @override
  State<PassengerAdminPanel> createState() => _PassengerAdminPanelState();
}

class _PassengerAdminPanelState extends State<PassengerAdminPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 6;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? _timestampFrom(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
    }
    return null;
  }

  bool _isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return !date.isBefore(start);
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _exportCsv(List<QueryDocumentSnapshot> users) async {
    try {
      final rows = <List<String>>[
        ['ID', 'Name', 'Email', 'Phone'],
        ...users.asMap().entries.map((entry) {
          final data = entry.value.data() as Map<String, dynamic>;

          final rawPhone = '${data['phone'] ?? 'N/A'}';
          final formattedPhone = rawPhone == 'N/A' ? 'N/A' : '="$rawPhone"';

          return [
            '${entry.key + 1}',
            '${data['name'] ?? 'No Name'}',
            '${data['email'] ?? 'N/A'}',
            formattedPhone,
          ];
        }),
      ];

      final csv = rows
          .map((row) =>
              row.map((value) => '"${value.replaceAll('"', '""')}"').join(','))
          .join('\n');

      final directory = await getTemporaryDirectory();
      final fileName = widget.isDriver
          ? 'registered_drivers.csv'
          : 'registered_passengers.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      final xFile = XFile(file.path, mimeType: 'text/csv');
      final result = await Share.shareXFiles(
        [xFile],
        subject: widget.isDriver
            ? 'Registered Drivers CSV'
            : 'Registered Passengers CSV',
        text:
            'Exported CSV file for registered ${widget.isDriver ? 'drivers' : 'passengers'}.',
      );

      if (mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _stat(BuildContext context, String label, int value, IconData icon, Color accentColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF666666),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('women_safety_data')
          .doc(widget.isDriver ? 'riders_data' : 'users_data')
          .collection('profiles')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Error fetching ${widget.isDriver ? 'driver' : 'passenger'} data: ${snapshot.error}'));
        }

        final isDriver = widget.isDriver;
        final users = snapshot.data?.docs ?? <QueryDocumentSnapshot>[];
        final filteredUsers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final searchText =
              '${data['name'] ?? ''} ${data['email'] ?? ''} ${data['phone'] ?? ''}'
                  .toLowerCase();
          return searchText.contains(_searchQuery);
        }).toList();
        final pageCount = (filteredUsers.length / _pageSize).ceil();
        if (pageCount > 0 && _currentPage >= pageCount) {
          _currentPage = pageCount - 1;
        }
        final pageStart = _currentPage * _pageSize;
        final pageUsers =
            filteredUsers.skip(pageStart).take(_pageSize).toList();
        final newThisWeek = users
            .where((doc) => _isThisWeek(
                  _timestampFrom(doc.data() as Map<String, dynamic>,
                      ['createdAt', 'registeredAt']),
                ))
            .length;
        final activeToday = users
            .where((doc) => _isToday(
                  _timestampFrom(doc.data() as Map<String, dynamic>,
                      ['lastActive', 'lastLogin', 'updatedAt']),
                ))
            .length;

        return Container(
          color: theme.scaffoldBackgroundColor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              Row(
                children: [
                  Icon(
                    isDriver ? Icons.local_taxi_rounded : Icons.people_alt_rounded,
                    color: const Color(0xFFC2185B),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDriver ? 'DRIVER MANAGEMENT' : 'USER MANAGEMENT',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: theme.textTheme.bodyLarge?.color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                  height: 1),
              const SizedBox(height: 16),
              Text('QUICK STATS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white54 : Colors.grey.shade700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat(
                    context, 
                    isDriver ? 'Total Drivers' : 'Total Passengers',
                    users.length,
                    isDriver ? Icons.drive_eta : Icons.group,
                    const Color(0xFFC2185B)
                  ),
                  const SizedBox(width: 10),
                  _stat(
                    context, 
                    'New This Week', 
                    newThisWeek,
                    Icons.person_add_alt_1,
                    Colors.purple
                  ),
                  const SizedBox(width: 10),
                  _stat(
                    context, 
                    'Active Today', 
                    activeToday,
                    Icons.bolt,
                    Colors.orange
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(isDriver ? 'REGISTERED DRIVERS' : 'REGISTERED PASSENGERS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white54 : Colors.grey.shade700)),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onChanged: (value) => setState(() {
                  _searchQuery = value.trim().toLowerCase();
                  _currentPage = 0;
                }),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone...',
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                      fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      size: 20,
                      color: Color(0xFFC2185B)),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear,
                              color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _currentPage = 0;
                          }),
                        ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFC2185B).withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFC2185B).withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFFC2185B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        isDark 
                            ? const Color(0xFF2C2C2C) 
                            : const Color(0xFFC2185B).withOpacity(0.05),
                      ),
                      dataRowColor: WidgetStateProperty.all(theme.cardColor),
                      columnSpacing: 28,
                      horizontalMargin: 16,
                      columns: [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Email',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Phone',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: pageUsers.asMap().entries.map((entry) {
                        final data = entry.value.data() as Map<String, dynamic>;
                        final textStyle =
                            TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13);
                        return DataRow(cells: [
                          DataCell(
                              Text('${pageStart + entry.key + 1}', style: textStyle)),
                          DataCell(Text('${data['name'] ?? 'No Name'}',
                              style: textStyle.copyWith(fontWeight: FontWeight.w600))),
                          DataCell(
                              Text('${data['email'] ?? 'N/A'}', style: textStyle)),
                          DataCell(
                              Text('${data['phone'] ?? 'N/A'}', style: textStyle)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              if (pageUsers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      isDriver ? 'No drivers found.' : 'No passengers found.',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('PAGINATION:',
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Previous page',
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: Icon(Icons.chevron_left,
                        color: _currentPage > 0 
                            ? const Color(0xFFC2185B) 
                            : Colors.grey.shade400),
                  ),
                  Text(
                    pageCount == 0 ? '0' : '${_currentPage + 1} / $pageCount',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next page',
                    onPressed: _currentPage + 1 < pageCount
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: Icon(Icons.chevron_right,
                        color: _currentPage + 1 < pageCount 
                            ? const Color(0xFFC2185B) 
                            : Colors.grey.shade400),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2185B),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => _exportCsv(filteredUsers),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Export CSV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminSOSConfigCard extends StatefulWidget {
  const AdminSOSConfigCard({super.key});

  @override
  State<AdminSOSConfigCard> createState() => _AdminSOSConfigCardState();
}

class _AdminSOSConfigCardState extends State<AdminSOSConfigCard> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentEmergencyNumber();
  }

  Future<void> _fetchCurrentEmergencyNumber() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('women_safety_data')
          .doc('admin_settings')
          .collection('sos_config')
          .doc('emergency_contact')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _phoneController.text = data['emergency_phone'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveEmergencyNumber() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid phone number"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('women_safety_data')
          .doc('admin_settings')
          .collection('sos_config')
          .doc('emergency_contact')
          .set({
        'emergency_phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Admin Emergency SOS Number Updated!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to update number: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF381423) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC2185B).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFC2185B)),
              SizedBox(width: 8),
              Text(
                "Login/Signup SOS Destination Number",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC2185B),
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: "Enter emergency number (e.g. 03001234567)",
                    hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 13),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: theme.cardColor,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2185B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _isLoading ? null : _saveEmergencyNumber,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserListStream extends StatefulWidget {
  final String role;
  const UserListStream({super.key, required this.role});

  @override
  State<UserListStream> createState() => _UserListStreamState();
}

class _UserListStreamState extends State<UserListStream> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getDocPath() {
    return widget.role == 'driver' ? 'riders_data' : 'users_data';
  }

  Future<void> _deleteUser(
      BuildContext context, String docId, String userName) async {
    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: Text("Are you sure you want to delete '$userName'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('women_safety_data')
            .doc(_getDocPath())
            .collection('profiles')
            .doc(docId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$userName deleted successfully."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete user: $e"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool isDriver = widget.role == 'driver';
    String roleTitle = isDriver ? 'Drivers' : 'Users';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('women_safety_data')
          .doc(_getDocPath())
          .collection('profiles')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(
                  "Error fetching ${widget.role} data: ${snapshot.error}"));
        }

        final allUsers = snapshot.data?.docs ?? [];
        final int totalCount = allUsers.length;

        final filteredUsers = allUsers.where((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          final email = (userData['email'] ?? '').toString().toLowerCase();
          final name = (userData['name'] ?? '').toString().toLowerCase();
          final phone = (userData['phone'] ?? '').toString().toLowerCase();

          return email.contains(_searchQuery) ||
              name.contains(_searchQuery) ||
              phone.contains(_searchQuery);
        }).toList();

        return Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF381423)
                    : const Color(0xFFC2185B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Registered $roleTitle",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFC2185B),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2185B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$totalCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by email, name, or phone...",
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFC2185B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: const Color(0xFFC2185B).withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: const Color(0xFFC2185B).withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFFC2185B)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDriver
                                ? Icons.local_taxi_outlined
                                : Icons.person_search_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Type to search for a specific ${isDriver ? 'driver' : 'user'}",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            "No ${isDriver ? 'driver' : 'user'} matches '$_searchQuery'.",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final doc = filteredUsers[index];
                            final userData = doc.data() as Map<String, dynamic>;
                            final String name = userData['name'] ?? 'No Name';

                            return Card(
                              elevation: 3,
                              color: theme.cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isDriver
                                      ? (isDark
                                          ? Colors.purple.shade900
                                          : Colors.purple.shade100)
                                      : (isDark
                                          ? Colors.pink.shade900
                                          : Colors.pink.shade100),
                                  child: Icon(
                                    isDriver ? Icons.local_taxi : Icons.person,
                                    color: const Color(0xFFC2185B),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Email: ${userData['email'] ?? 'N/A'}",
                                        style: TextStyle(
                                            color: theme
                                                .textTheme.bodyMedium?.color)),
                                    Text("Phone: ${userData['phone'] ?? 'N/A'}",
                                        style: TextStyle(
                                            color: theme
                                                .textTheme.bodyMedium?.color)),
                                    if (isDriver) ...[
                                      Text(
                                          "Vehicle: ${userData['vehicleType'] ?? 'N/A'}",
                                          style: TextStyle(
                                              color: theme.textTheme.bodyMedium
                                                  ?.color)),
                                      if (userData.containsKey('cnic_status'))
                                        Text(
                                            "CNIC Status: ${userData['cnic_status']}",
                                            style: TextStyle(
                                                color: theme.textTheme
                                                    .bodyMedium?.color)),
                                    ],
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteUser(context, doc.id, name),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class AllRideHistoryStream extends StatelessWidget {
  const AllRideHistoryStream({super.key});

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return {
          'color': Colors.green,
          'text': 'Completed',
          'icon': Icons.check_circle
        };
      case 'cancelled':
        return {'color': Colors.red, 'text': 'Cancelled', 'icon': Icons.cancel};
      case 'accepted':
        return {
          'color': Colors.blue,
          'text': 'In Progress',
          'icon': Icons.directions_car
        };
      case 'rejected':
        return {
          'color': Colors.orange,
          'text': 'Declined',
          'icon': Icons.block
        };
      case 'pending':
      default:
        return {
          'color': Colors.amber.shade800,
          'text': 'Pending',
          'icon': Icons.hourglass_empty
        };
    }
  }

  Future<void> _deleteRideRecord(BuildContext context, String rideId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Ride Record"),
            content: const Text(
                "Are you sure you want to permanently remove this ride log?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Ride log deleted."),
                backgroundColor: Colors.redAccent),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error deleting ride: $e"),
                backgroundColor: Colors.orange),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rides').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error fetching rides: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No ride history records found."));
        }

        var rides = snapshot.data!.docs;

        rides.sort((a, b) {
          var dataA = a.data() as Map<String, dynamic>;
          var dataB = b.data() as Map<String, dynamic>;
          Timestamp? timeA = dataA['createdAt'] as Timestamp?;
          Timestamp? timeB = dataB['createdAt'] as Timestamp?;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          return timeB.compareTo(timeA);
        });

        return ListView.builder(
          itemCount: rides.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final doc = rides[index];
            final ride = doc.data() as Map<String, dynamic>;
            final status = ride['status'] ?? 'pending';
            final statusStyle = _getStatusStyle(status);

            return Card(
              elevation: 3,
              color: theme.cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin,
                                color: Color(0xFFC2185B)),
                            const SizedBox(width: 6),
                            Text(
                              ride['passengerName'] ?? 'Passenger',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.textTheme.bodyLarge?.color),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (statusStyle['color'] as Color)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(statusStyle['icon'],
                                  size: 14, color: statusStyle['color']),
                              const SizedBox(width: 4),
                              Text(
                                statusStyle['text'],
                                style: TextStyle(
                                  color: statusStyle['color'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.drive_eta,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "Driver: ${ride['driverName'] ?? 'Not Assigned'} (${ride['vehicleType'] ?? 'N/A'})",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.my_location,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              "Pickup: ${ride['pickupLocation'] ?? 'N/A'}",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              "Dropoff: ${ride['dropoffLocation'] ?? 'N/A'}",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color)),
                        ),
                      ],
                    ),
                    if (status == 'cancelled') ...[
                      const SizedBox(height: 8),
                      Text(
                        "Cancelled By: ${ride['cancelledBy'] ?? 'N/A'} • Reason: ${ride['cancellationReason'] ?? 'None'}",
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                    const Divider(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fare: Rs. ${ride['fare'] ?? '0'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFC2185B)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: "Delete Ride Record",
                          onPressed: () => _deleteRideRecord(context, doc.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}