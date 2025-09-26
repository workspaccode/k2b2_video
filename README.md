# K2B2 Video Streaming App

A Flutter-based video streaming application with modern UI and advanced features.

## Features

### Home Screen
- **New Videos Slider**: Carousel showcasing the latest releases
- **Continue Watching**: Resume videos from where you left off
- **Current Video**: Highlighted currently playing video with progress
- **Most Watched**: Popular content based on view counts
- **Categories Section**: Browse by genre (Anime, Action, Drama, Comedy, Horror, Documentary)
- **120x120 Category Icons**: Visual category browsing with video counts
- **Download Support**: Offline viewing capability
- **4K Quality Indicators**: Premium quality content marking
- **Progress Tracking**: Visual progress bars for partially watched content

### Technical Features
- **Carousel Slider**: Smooth horizontal scrolling for video collections
- **Cached Network Images**: Optimized image loading and caching
- **Shimmer Loading**: Beautiful loading animations
- **Dark Theme**: Modern dark UI design
- **Responsive Design**: Adapts to different screen sizes
- **Shorebird Updates**: Over-the-air app updates

## Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/k2b2_video.git
cd k2b2_video
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Shorebird Setup (Over-the-Air Updates)

### Installation

1. Install Shorebird CLI:
```bash
# Install Shorebird CLI globally
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

2. Add Shorebird to your PATH (restart terminal after this):
```bash
echo 'export PATH=\"$HOME/.shorebird/bin:$PATH\"' >> ~/.bashrc
source ~/.bashrc
```

3. Login to Shorebird:
```bash
shorebird login
```

4. Initialize Shorebird in your project:
```bash
shorebird init
```

### Creating Releases

1. Create a release (first time):
```bash
shorebird release android
```

2. Create patches (subsequent updates):
```bash
shorebird patch android
```

### Configuration

The app includes `shorebird.yaml` with the following features:
- Auto-update checking every hour
- Development and production flavors
- Configurable update policies

## Project Structure

```
lib/
├── core/
│   └── di.dart                 # Dependency injection
├── features/
│   └── auth/
│       └── cubit/              # Authentication state management
├── models/
│   ├── video_model.dart        # Video data model
│   └── category_model.dart     # Category data model
├── screens/
│   ├── home_screen.dart        # Main home screen
│   ├── login_screen.dart       # User authentication
│   ├── profile_screen.dart     # User profile
│   ├── splash_screen.dart      # App launch screen
│   ├── subscription_screen.dart # Premium features
│   └── video_screen.dart       # Video playback
├── services/
│   ├── mock_data_service.dart  # Sample data provider
│   └── shorebird_update_service.dart # OTA updates
└── main.dart                   # App entry point
```

## Key Dependencies

- `carousel_slider`: Horizontal video carousels
- `cached_network_image`: Optimized image loading
- `shimmer`: Loading animations
- `video_player`: Video playback functionality
- `flutter_bloc`: State management
- `dio`: HTTP networking
- `path_provider`: Local storage access
- `permission_handler`: Device permissions

## Features Roadmap

- [ ] Video player implementation
- [ ] User authentication with Firebase
- [ ] Download manager for offline content
- [ ] Search functionality
- [ ] User favorites and playlists
- [ ] Push notifications
- [ ] Content recommendation engine
- [ ] Chromecast support
- [ ] Subtitle support
- [ ] Multiple language support

## Development Tips

### Adding New Categories

Edit `lib/services/mock_data_service.dart` and add new categories to the `getCategories()` method:

```dart
CategoryModel(
  id: 'new_category',
  name: 'New Category',
  iconUrl: 'https://via.placeholder.com/120x120',
  coverImageUrl: 'https://via.placeholder.com/300x200',
  description: 'Description here',
  subCategories: ['Sub1', 'Sub2'],
  videoCount: 50,
  isPopular: true,
),
```

### Customizing the UI

The app uses a dark theme with these primary colors:
- Background: `Color(0xFF0F0F23)`
- Accent: `Colors.amber`
- Cards: Semi-transparent overlays
- Text: White and white70 variants

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue on GitHub or contact the development team.

---

**Note**: This is a mini project implementation. For production use, replace mock data with real API endpoints and implement proper user authentication and content management systems.