import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/firebase_service.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/theme/app_colors.dart';

// --- CommentsSheet widget at true top-level ---
class CommentsSheet extends StatefulWidget {
  final String reelId;
  const CommentsSheet({super.key, required this.reelId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  String? _error;
  var languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reels')
          .doc(widget.reelId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      setState(() {
        _comments = snap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = languageProvider.translate('commentsLoadError');
        _loading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(widget.reelId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? languageProvider.translate('user'),
        'userAvatar': user.photoURL ?? '',
        'text': _controller.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      _controller.clear();
      await _fetchComments();
    } catch (e) {
      setState(() => _error = languageProvider.translate('commentSendError'));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    languageProvider.translate('comments'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : _error != null
                    ? Text(_error!, style: const TextStyle(color: Colors.white))
                    : _comments.isEmpty
                        ? Text(languageProvider.translate('noComments'),
                            style: TextStyle(color: Colors.white70))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _comments.length,
                              itemBuilder: (context, i) {
                                final c = _comments[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(c['userAvatar'] ?? ''),
                                  ),
                                  title: Text(c['userName'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  subtitle: Text(c['text'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                );
                              },
                            ),
                          ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: languageProvider.translate('addComment'),
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator(color: AppColors.accent)
                      : const Icon(Icons.send, color: AppColors.accent),
                  onPressed: _isSending ? null : _sendComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  // Add your state variables here
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _reels = [];
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    try {
      final reels = await FirebaseService().getReels(limit: 20);
      final controllers = <VideoPlayerController>[];
      for (final reel in reels) {
        final url = reel['videoUrl'];
        if (url is String && url.isNotEmpty) {
          final controller = VideoPlayerController.networkUrl(Uri.parse(url));
          await controller.initialize();
          controller.setLooping(true);
          controllers.add(controller);
        }
      }
      setState(() {
        _reels = reels;
        _controllers = controllers;
      });
    } catch (e) {
      // keep empty UI, could add error banner
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _reels.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _reels.length,
              itemBuilder: (context, index) => _buildReelItem(index),
            ),
    );
  }

  Widget _buildReelItem(int index) {
    final reel = _reels[index];
    final controller = _controllers[index];
    final userId = _auth.currentUser?.uid;
    final isLiked =
        userId != null && (reel['likes'] as List?)?.contains(userId) == true;
    final likeCount = reel['likeCount'] ?? 0;
    final commentCount = reel['commentCount'] ?? 0;

    var languageProvider = context.read<LanguageProvider>();
    return Stack(
      children: [
        // Video Player
        if (controller.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
            ),
          ),

        // Play/Pause Overlay
        if (controller.value.isInitialized && !controller.value.isPlaying)
          Center(
            child: GestureDetector(
              onTap: () => controller.play(),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

        // Tap to pause/play
        GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
        ),

        // Bottom content
        Positioned(
          bottom: 0,
          left: 0,
          right: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(reel['authorAvatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reel['author'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${reel['likes']} ${languageProvider.translate('addComment')}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    reel['description'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress indicators
                  Row(
                    children: List.generate(
                      _reels.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        height: 2,
                        width: 20,
                        decoration: BoxDecoration(
                          color: i == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: '$likeCount',
                color: isLiked ? Colors.red : Colors.white,
                onTap: () async {
                  if (userId == null) return;
                  setState(() {
                    _reels[index]['isLiking'] = true;
                  });
                  bool success;
                  if (isLiked) {
                    success =
                        await FirebaseService().unlikeReel(reel['id'], userId);
                  } else {
                    success =
                        await FirebaseService().likeReel(reel['id'], userId);
                  }
                  if (success) {
                    // Refresh reels
                    await _fetchReels();
                  } else {
                    setState(() {
                      _reels[index]['isLiking'] = false;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Comment button
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: '$commentCount',
                onTap: () {
                  _showCommentsModal(context, reel['id']);
                },
              ),

              const SizedBox(height: 24),

              // Share button
              _buildActionButton(
                icon: Icons.share_outlined,
                label: languageProvider.translate('share'),
                onTap: () {
                  final url = reel['videoUrl'] ?? '';
                  final desc = reel['description'] ?? '';
                  Share.share(
                      '${languageProvider.translate('watchReelMessage')}$desc\n$url');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCommentsModal(BuildContext context, String reelId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CommentsSheet(reelId: reelId),
    );
  }
}
