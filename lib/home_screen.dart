import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simoni/all_reports.dart';
import 'package:simoni/task_list.dart';

enum TaskStatus { completed, pending, cancelled, inProgress }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryColor = const Color(0xFF00D1C1);
  final Color darkBlue = const Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.0),
                    _Header(),
                    SizedBox(height: 24.0),
                    _SearchBar(),
                    SizedBox(height: 32.0),
                    _TaskSummaryHeader(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _TaskSummaryCards(),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _ActionButtons(
                  primaryColor: primaryColor,
                  darkBlue: darkBlue,
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _PerformanceSimpleSection(darkBlue: darkBlue),
              ),
              const SizedBox(height: 32.0),
              _BestEmployeesSection(
                darkBlue: darkBlue,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 32.0),
              _AllTasksSection(darkBlue: darkBlue),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00D1C1);
    const Color darkBlue = Color(0xFF1F2937);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo!',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Zaza Safira',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor, width: 2.0),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile_avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1F2937);
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari',
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.0,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        style: GoogleFonts.poppins(fontSize: 16.0, color: darkBlue),
      ),
    );
  }
}

class _TaskSummaryHeader extends StatefulWidget {
  const _TaskSummaryHeader();

  @override
  State<_TaskSummaryHeader> createState() => _TaskSummaryHeaderState();
}

class _TaskSummaryHeaderState extends State<_TaskSummaryHeader> {
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        _formattedDate = DateFormat(
          'd MMMM yyyy',
          'id_ID',
        ).format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1F2937);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hari Ini',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16.0, color: Colors.grey[600]),
            const SizedBox(width: 8.0),
            Text(
              _formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskSummaryCards extends StatelessWidget {
  const _TaskSummaryCards();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.7,
      children: [
        _buildSummaryCard(
          backgroundColor: const Color(0xFF01314A),
          icon: Icons.pending_actions_outlined,
          iconColor: Colors.white,
          title: 'Sedang Berjalan',
          count: 10,
          textColor: Colors.white,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFF95D925),
          icon: Icons.assignment_late_outlined,
          iconColor: Colors.black,
          title: 'Tertunda',
          count: 26,
          textColor: Colors.black,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFF8CC2FF),
          icon: Icons.history_toggle_off_outlined,
          iconColor: Colors.black,
          title: 'Selesai',
          count: 10,
          textColor: Colors.black,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFFFE8180),
          icon: Icons.unpublished_outlined,
          iconColor: Colors.black,
          title: 'Dibatalkan',
          count: 20,
          textColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(icon, color: iconColor, size: 28.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count Tugas',
                style: GoogleFonts.poppins(fontSize: 12.0, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.primaryColor, required this.darkBlue});

  final Color primaryColor;
  final Color darkBlue;

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Color(0xFF43A895);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.task_alt_outlined,
          title: 'Tugas',
          iconColor: iconColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LihatTugasScreen()),
            );
          },
        ),
        const SizedBox(width: 16.0),
        _buildActionButton(
          context: context,
          icon: Icons.snippet_folder_outlined,
          title: 'Laporan',
          iconColor: iconColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllReportsPage()),
            );
          },
        ),
        const SizedBox(width: 16.0),
        _buildActionButton(
          context: context,
          icon: Icons.assignment_outlined,
          title: 'lorem ipsum',
          iconColor: iconColor,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(width: 1, color: const Color(0xFFD3D3D3)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(134, 134, 134, 0.1),
                  spreadRadius: 0,
                  blurRadius: 19.83,
                  offset: Offset(0, 2.48),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32.0),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceSimpleSection extends StatelessWidget {
  const _PerformanceSimpleSection({required this.darkBlue});

  final Color darkBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 145,
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFF43A895),
                size: 24.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Performa Terbaik',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
            ],
          ),
          Text(
            '5',
            style: GoogleFonts.poppins(
              fontSize: 38.0,
              fontWeight: FontWeight.bold,
              color: darkBlue,
              height: 1.0,
            ),
          ),
          Text(
            'Diapresiasi atas kontribusi dan kinerja luar biasa bulan ini',
            style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BestEmployeesSection extends StatelessWidget {
  const _BestEmployeesSection({
    required this.darkBlue,
    required this.primaryColor,
  });

  final Color darkBlue;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = darkBlue;
    final Color employeeNameColorTop = Colors.grey[600]!;
    final Color employeeNameColorRanked = darkBlue;
    final Color scoreColor = darkBlue;
    final Color roleColor = Colors.grey[600]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Row(
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  color: primaryColor,
                  size: 28.0,
                ),
                const SizedBox(width: 12.0),
                Text(
                  'Pegawai Terbaik Bulan Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTopEmployee(
                rank: 2,
                avatarPath: 'assets/images/profile_avatar.png',
                name: 'Justin Bibir',
                nameColor: employeeNameColorTop,
                scoreColor: scoreColor,
              ),
              _buildTopEmployee(
                rank: 1,
                avatarPath: 'assets/images/profile_avatar.png',
                name: 'Santan Kayra',
                isCenter: true,
                nameColor: employeeNameColorTop,
                scoreColor: scoreColor,
              ),
              _buildTopEmployee(
                rank: 3,
                avatarPath: 'assets/images/profile_avatar.png',
                name: 'Bruno Venus',
                nameColor: employeeNameColorTop,
                scoreColor: scoreColor,
              ),
            ],
          ),
          const SizedBox(height: 28.0),
          _buildRankedEmployeeTile(
            rank: 4,
            avatarPath: 'assets/images/profile_avatar.png',
            name: 'Angeline Jolei',
            role: 'Staf Sub Bagian Program',
            nameColor: employeeNameColorRanked,
            roleColor: roleColor,
            scoreColor: scoreColor,
          ),
          const SizedBox(height: 12.0),
          _buildRankedEmployeeTile(
            rank: 5,
            avatarPath: 'assets/images/profile_avatar.png',
            name: 'Tailor Swipe',
            role: 'Staf Sub Bagian Program',
            nameColor: employeeNameColorRanked,
            roleColor: roleColor,
            scoreColor: scoreColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTopEmployee({
    required int rank,
    required String avatarPath,
    required String name,
    required Color nameColor,
    required Color scoreColor,
    bool isCenter = false,
  }) {
    final double avatarSize = isCenter ? 80.0 : 64.0;
    return Column(
      children: [
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: AssetImage(avatarPath),
              ),
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: _buildRankBadge(rank: rank, isTop: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: nameColor,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Color(0xFFFACC15), size: 16.0),
            const SizedBox(width: 4.0),
            Text(
              '5.0',
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankedEmployeeTile({
    required int rank,
    required String avatarPath,
    required String name,
    required String role,
    required Color nameColor,
    required Color roleColor,
    required Color scoreColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(avatarPath),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: _buildRankBadge(rank: rank),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
              ),
              Text(
                role,
                style: GoogleFonts.poppins(fontSize: 12.0, color: roleColor),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.star, color: Color(0xFFFACC15), size: 16.0),
          const SizedBox(width: 4.0),
          Text(
            '5.0',
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge({required int rank, bool isTop = false}) {
    Color badgeColor;
    Widget child;
    final Color darkBlue = const Color(0xFF1F2937);

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFACC15);
        child = const Icon(
          Icons.workspace_premium_rounded,
          color: Colors.white,
          size: 16,
        );
        break;
      case 2:
        badgeColor = const Color(0xFF4ADE80);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
        break;
      case 3:
        badgeColor = const Color(0xFFF79090);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
        break;
      default:
        badgeColor = const Color(0xFF90D0F7);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
    }

    return Container(
      width: isTop ? 28 : 20,
      height: isTop ? 28 : 20,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(child: child),
    );
  }
}

class _AllTasksSection extends StatelessWidget {
  const _AllTasksSection({required this.darkBlue});

  final Color darkBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 0.5, color: Color(0xFFD3D3D3))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Tugas',
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildTaskTile(
            status: TaskStatus.completed,
            title: 'Uji Sampel Sayuran',
            time: '09:15',
          ),
          const SizedBox(height: 5.0),
          _buildTaskTile(
            status: TaskStatus.pending,
            title: 'Uji Sampel Sayuran',
            time: '09:15',
          ),
          const SizedBox(height: 5.0),
          _buildTaskTile(
            status: TaskStatus.cancelled,
            title: 'Uji Sampel Sayuran',
            time: '09:15',
          ),
          const SizedBox(height: 5.0),
          _buildTaskTile(
            status: TaskStatus.inProgress,
            title: 'Uji Sampel Sayuran',
            time: '09:15',
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildTaskTile({
    required TaskStatus status,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          _getTaskIcon(status),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStackedAvatars(),
        ],
      ),
    );
  }

  Widget _getTaskIcon(TaskStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case TaskStatus.completed:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF4ADE80);
        break;
      case TaskStatus.pending:
        icon = Icons.refresh_rounded;
        color = const Color(0xFF90D0F7);
        break;
      case TaskStatus.cancelled:
        icon = Icons.cancel_rounded;
        color = const Color(0xFFF79090);
        break;
      case TaskStatus.inProgress:
        icon = Icons.access_time_filled_rounded;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 28.0);
  }

  Widget _buildStackedAvatars() {
    return SizedBox(
      width: 48,
      height: 32,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: const AssetImage(
              'assets/images/profile_avatar.png',
            ),
            backgroundColor: Colors.grey[200],
          ),
          Positioned(
            left: 16,
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage(
                'assets/images/profile_avatar.png',
              ),
              backgroundColor: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
