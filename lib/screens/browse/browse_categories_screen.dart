import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:k2b2_video/models/category_model.dart';
import 'package:k2b2_video/models/video_model.dart';
import 'package:k2b2_video/services/mock_data_service.dart';
import 'package:shimmer/shimmer.dart';

class BrowseCategoriesScreen extends StatefulWidget {
  const BrowseCategoriesScreen({super.key});

  @override
  State<BrowseCategoriesScreen> createState() => _BrowseCategoriesScreenState();
}

class _BrowseCategoriesScreenState extends State<BrowseCategoriesScreen>
    with TickerProviderStateMixin {
  List<CategoryModel?> _categories = [];
  List<VideoModel> _selectedCategoryVideos = [];
  CategoryModel? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isLoadingVideos = false;

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _filterController;

  final List<String> _sortOptions = ['Popular', 'Recent', 'A-Z', 'Rating'];
  String _selectedSort = 'Popular';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadCategories();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCategories() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    _categories = MockDataService.getCategories();

    setState(() => _isLoading = false);
  }

  void _loadCategoryVideos(CategoryModel category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingVideos = true;
    });

    try {
      final videos = await MockDataService.getVideosByCategory(category.id);
      setState(() {
        _selectedCategoryVideos = videos;
        _isLoadingVideos = false;
      });
    } catch (e) {
      setState(() => _isLoadingVideos = false);
    }
  }

  List<CategoryModel?> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where(
          (category) =>
              category!.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              category.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
              const Color(0xFF16213E).withValues(alpha: 0.95),
              const Color(0xFF0F172A).withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with search
              _buildHeader()
                  .animate(controller: _animationController)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

              // Filter and sort bar
              _buildFilterBar()
                  .animate(controller: _animationController)
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: -0.2, end: 0),

              // Content
              Expanded(
                child: _selectedCategory == null
                    ? _buildCategoriesGrid()
                    : _buildCategoryDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_selectedCategory != null)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = null;
                    _selectedCategoryVideos.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      IconlyLight.arrow_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

              if (_selectedCategory != null) const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                      ).createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory?.name ?? 'Browse Categories',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _selectedCategory?.description ??
                          'Discover amazing content',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search bar
          GlassmorphicContainer(
            width: double.infinity,
            height: 50,
            borderRadius: 15,
            blur: 15,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                const Color(0xFFFFFFFF).withValues(alpha: 0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _selectedCategory == null
                    ? 'Search categories...'
                    : 'Search in ${_selectedCategory!.name}...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  IconlyLight.search,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Icon(
                          IconlyLight.close_square,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    if (_selectedCategory == null) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Video count
          Text(
            '${_selectedCategoryVideos.length} videos',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Sort dropdown
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyLight.filter,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedSort,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    IconlyLight.arrow_down_2,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    if (_isLoading) {
      return _buildCategoriesShimmer();
    }

    final filteredCategories = _filteredCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final category = filteredCategories[index];
          return _buildCategoryCard(category!, index);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int index) {
    return GestureDetector(
      onTap: () => _loadCategoryVideos(category),
      child:
          GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
                blur: 15,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: category.coverImageUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withValues(alpha: 0.3),
                          colorBlendMode: BlendMode.darken,
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0xFF4ECDC4,
                                  ).withValues(alpha: 0.3),
                                  const Color(
                                    0xFFFF6B6B,
                                  ).withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Popular badge
                          if (category.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Category icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              IconlyBold.category,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Category name
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Video count
                          Text(
                            '${category.videoCount} videos',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 100).ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
    );
  }

  Widget _buildCategoryDetails() {
    if (_isLoadingVideos) {
      return _buildVideosShimmer();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Subcategories chips
          if (_selectedCategory!.subCategories.isNotEmpty) ...[
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedCategory!.subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = _selectedCategory!.subCategories[index];
                  return Container(
                    margin: EdgeInsets.only(
                      right: 12,
                      left: index == 0 ? 0 : 0,
                    ),
                    child: Chip(
                      label: Text(
                        subCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Videos grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: _selectedCategoryVideos.length,
              itemBuilder: (context, index) {
                final video = _selectedCategoryVideos[index];
                return _buildVideoCard(video, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video, int index) {
    return GestureDetector(
      onTap: () => _handleVideoPlay(video),
      child:
          GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
                blur: 15,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: video.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF4ECDC4,
                                              ).withValues(alpha: 0.5),
                                              const Color(
                                                0xFFFF6B6B,
                                              ).withValues(alpha: 0.5),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          IconlyBold.play,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                ),
                              ),
                            ),

                            // Play button overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                child: const Center(
                                  child: Icon(
                                    IconlyBold.play,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),

                            // Quality badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video.quality,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Video info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${_formatDuration(video.duration)} • ${_formatViews(video.views)} views',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 100).ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideosShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 300,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.9),
            const Color(0xFF16213E).withValues(alpha: 0.9),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.2),
            const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sort by',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _sortOptions.length,
                itemBuilder: (context, index) {
                  final option = _sortOptions[index];
                  final isSelected = option == _selectedSort;

                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF4ECDC4)
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            IconlyBold.tick_square,
                            color: Color(0xFF4ECDC4),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedSort = option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVideoPlay(VideoModel video) {
    // Show login dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassmorphicContainer(
          width: 300,
          height: 200,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.9),
              const Color(0xFF16213E).withValues(alpha: 0.9),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(IconlyBold.lock, color: Color(0xFF4ECDC4), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Login Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in to watch "${video.title}"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }
}
