import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userProfile != null) {
      Provider.of<MovieProvider>(context, listen: false).fetchWatchlist(auth.userProfile!.watchlist);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/250px-Netflix_2015_logo.svg.png',
          height: 25,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Grid
            _buildProfileGrid(auth),
            const SizedBox(height: 40),
            
            _buildActionItem(Icons.check, 'My List', onTap: () {}),
            if (movieProvider.watchlist.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movieProvider.watchlist.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: movieProvider.watchlist[index]);
                  },
                ),
              ),
            
            const SizedBox(height: 20),
            _buildActionItem(Icons.settings_outlined, 'App Settings', onTap: () => _showAppSettings(context)),
            _buildActionItem(Icons.account_circle_outlined, 'Account', onTap: () => _showAccount(context)),
            _buildActionItem(Icons.help_outline, 'Help', onTap: () => _showHelp(context)),
            
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => auth.logout(),
              child: const Text('Sign Out', style: TextStyle(color: AppTheme.greyText, fontSize: 16)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileGrid(AuthProvider auth) {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _buildProfileAvatar(auth.userProfile?.name ?? 'User', 'https://via.placeholder.com/80x80/333333/ffffff?text=U', isSelected: true),
          _buildProfileAvatar('Kids', 'https://via.placeholder.com/80x80/E50914/ffffff?text=K'),
          _buildAddProfile(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String name, String imageUrl, {bool isSelected = false}) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {},
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(color: isSelected ? Colors.white : AppTheme.greyText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildAddProfile() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.greyText, width: 1),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 8),
        const Text('Add Profile', style: TextStyle(color: AppTheme.greyText)),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: Colors.white, size: 28),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.greyText, size: 16),
      ),
    );
  }

  void _showAppSettings(BuildContext context) {
    bool notificationsEnabled = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('App Settings', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Dark Theme', style: TextStyle(color: Colors.white)),
                value: true,
                onChanged: null,
                activeThumbColor: AppTheme.primaryRed,
              ),
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                value: notificationsEnabled,
                onChanged: (value) => setState(() => notificationsEnabled = value),
                activeThumbColor: AppTheme.primaryRed,
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.white),
                title: const Text('Language', style: TextStyle(color: Colors.white)),
                trailing: const Text('English', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.greyText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings updated!')),
                );
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.primaryRed)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccount(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = auth.userProfile;
    
    final nameController = TextEditingController(text: profile?.name ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Manage Account', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    profile != null && profile.name.isNotEmpty 
                        ? profile.name.substring(0, 1).toUpperCase() 
                        : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: const TextStyle(color: AppTheme.greyText),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  title: Text(profile?.email ?? 'demo@netflix.com', style: const TextStyle(color: Colors.white)),
                  subtitle: const Text('Email • Verified', style: TextStyle(color: AppTheme.greyText)),
                  leading: const Icon(Icons.email, color: AppTheme.greyText),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Basic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  subtitle: Text('Plan expires in 30 days', style: TextStyle(color: AppTheme.greyText)),
                  leading: const Icon(Icons.credit_card, color: AppTheme.greyText),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.greyText)),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != profile?.name) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name changed to $newName (demo mode)')),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update', style: TextStyle(color: AppTheme.primaryRed)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Help Center', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _helpFAQ('Search movies?', 'Tap search icon at home, type title.'),
                _helpFAQ('Add to My List?', 'Tap + icon on movie cards.'),
                _helpFAQ('Login problems?', 'Use demo credentials or setup Firebase.'),
                _helpFAQ('Watchlist empty?', 'Add movies first from Home.'),
                _helpFAQ('Change profile name?', 'Profile > Account > Update.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Contact Support', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _helpFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(answer, style: TextStyle(fontSize: 14, color: AppTheme.greyText)),
        ],
      ),
    );
  }
}

