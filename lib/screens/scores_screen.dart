import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/score_service.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  String _filterMode = 'all'; // all, classic, math, spelling

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF47E1B),
        title: Text(
          'SCORE RECORDS',
          style: GoogleFonts.vt323(fontSize: 28, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterButton('ALL', 'all'),
                  _buildFilterButton('CLASSIC', 'classic'),
                  _buildFilterButton('MATH', 'math'),
                  _buildFilterButton('SPELLING', 'spelling'),
                ],
              ),
            ),
            // Score Records List
            _buildScoresList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String mode) {
    final isActive = _filterMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterMode = mode),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF47E1B) : Colors.transparent,
            border: Border.all(
              color: isActive ? Colors.black : const Color(0xFFA68340),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.vt323(
              fontSize: 14,
              color: isActive ? Colors.white : const Color(0xFFA68340),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoresList() {
    List<ScoreRecord> records;

    if (_filterMode == 'all') {
      records = ScoreService.getTopRecords(limit: 50);
    } else {
      records = ScoreService.getRecordsByMode(_filterMode);
      records.sort((a, b) => b.score.compareTo(a.score));
    }

    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.inbox, size: 80, color: Colors.white30),
              const SizedBox(height: 16),
              Text(
                'NO RECORDS YET',
                style: GoogleFonts.vt323(
                  fontSize: 24,
                  color: Colors.white30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start playing to earn records!',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.white30),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          records.length,
          (index) => _buildScoreCard(records[index], index + 1),
        ),
      ),
    );
  }

  Widget _buildScoreCard(ScoreRecord record, int rank) {
    final modeLabel = record.mode == 'classic'
        ? '🎮 CLASSIC'
        : record.mode == 'math'
        ? '🔢 MATH'
        : '📝 SPELLING';

    final diffIcon = record.difficulty == 'easy'
        ? '😊'
        : record.difficulty == 'medium'
        ? '😎'
        : '🔥';

    final formattedDate =
        '${record.timestamp.month}/${record.timestamp.day}/${record.timestamp.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF8DC),
        border: Border.all(color: const Color(0xFFD69736), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rank Medal
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank <= 3 ? _getRankMedal(rank) : '#$rank',
                style: GoogleFonts.vt323(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Score Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modeLabel,
                  style: GoogleFonts.vt323(
                    fontSize: 16,
                    color: const Color(0xFFF47E1B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$diffIcon ${record.difficulty.toUpperCase()}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedDate,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score
          Text(
            '${record.score}',
            style: GoogleFonts.vt323(
              fontSize: 28,
              color: const Color(0xFFF47E1B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFFE8DCB0);
  }

  String _getRankMedal(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }
}
