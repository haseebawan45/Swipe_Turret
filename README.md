# 🎮 Swipe Turret - Neon Cyberpunk Edition

A visually stunning Flutter-based 2D game featuring breathtaking neon-futuristic aesthetics inspired by *Geometry Wars*, *Tron*, and *Beat Saber*. Experience intense missile defense gameplay with cutting-edge visual effects, advanced particle systems, and immersive cyberpunk atmosphere.

## ✨ Visual Features

### 🌟 Advanced Neon Effects
- **Multi-layered Glow Systems**: Each game entity features multiple glow layers for incredible depth
- **Dynamic Particle Systems**: Real-time particle effects for trails, explosions, and ambient atmosphere
- **Cyberpunk Grid Background**: Animated grid with scanlines, radar sweeps, and floating particles
- **Shader-like Effects**: Advanced gradient systems and blur effects for authentic neon aesthetics

### 🎯 Enhanced Game Entities

#### Turret
- **Pulsating Core**: Dynamic energy core with rotation and scaling effects
- **Charge Indicator**: Animated ring showing ammo cooldown with neon glow
- **Energy Field**: Ambient particle system when fully charged
- **Hexagonal Details**: Rotating geometric patterns for sci-fi authenticity

#### Bullets
- **Comet Trails**: Multi-layered particle trails with smooth bezier curves
- **Energy Corona**: Pulsing energy field around projectiles
- **Leading Sparks**: Directional spark effects in movement direction
- **Advanced Gradients**: Radial gradients from white core to neon edges

#### Missiles (3 Types)
- **Standard Missiles**: Classic red neon with diamond shape
- **Fast Missiles**: White-hot arrows with speed line effects
- **Heavy Missiles**: Purple hexagonal tanks requiring 2 hits
- **Smart Homing**: Smooth steering with curved trajectories
- **Warning Systems**: Proximity alerts with pulsing red indicators

#### Explosions
- **Type-Specific Effects**: Different explosion styles for each entity
- **Shockwave Systems**: Expanding energy rings with multiple layers
- **Star Particles**: Rotating star-shaped debris for larger explosions
- **Central Flash**: Intense white-hot core flash effects

### 🎨 Cyberpunk Atmosphere
- **Animated Grid**: Pulsing grid lines with wave distortions
- **Radar Sweep**: Rotating radar effect at screen center
- **Scanlines**: Moving scan effects across the screen
- **Floating Particles**: Ambient neon particles throughout the environment

## 🎮 Gameplay Features

### Core Mechanics
- **Swipe to Shoot**: Intuitive gesture controls with haptic feedback
- **Missile Defense**: Protect your turret from incoming homing missiles
- **Progressive Difficulty**: Increasing speed and spawn rates over time
- **Score System**: Points based on missile type and survival time

### Advanced Features
- **Multiple Missile Types**: Standard, Fast, and Heavy variants
- **Health System**: Heavy missiles require multiple hits
- **Visual Feedback**: Charge indicators, warning systems, and particle effects
- **Smooth Performance**: Optimized for 60 FPS on mobile devices

## 🛠️ Technical Implementation

### Architecture
- **Custom Painters**: Advanced rendering with Flutter's CustomPainter
- **Particle Systems**: Efficient particle management with object pooling
- **Vector Mathematics**: Smooth movement and collision detection
- **State Management**: Clean separation of game logic and rendering

### Performance Optimizations
- **Object Pooling**: Reuse particles and effects to minimize garbage collection
- **Efficient Rendering**: Layered rendering system for optimal performance
- **Smooth Animations**: 60 FPS target with optimized update loops
- **Memory Management**: Careful resource management for mobile devices

### Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  shared_preferences: ^2.2.2  # Save high scores
  audioplayers: ^5.2.1        # Sound effects
  vector_math: ^2.1.4         # Mathematical operations
  flame: ^1.18.0              # Game engine features
  rive: ^0.13.1               # Advanced animations
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code
- Android device or emulator

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd swipe_turret
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the game:
   ```bash
   flutter run
   ```

## 🎯 Game Controls

- **Swipe**: Fire bullets in swipe direction
- **Swipe Length**: Affects bullet speed slightly
- **Pause**: Tap pause button during gameplay
- **Menu Navigation**: Tap buttons to navigate

## 🏆 Scoring System

- **Standard Missile**: 100 points
- **Fast Missile**: 150 points  
- **Heavy Missile**: 200 points (requires 2 hits)
- **Survival Bonus**: Points increase over time

## 🎨 Visual Customization

The game features a comprehensive visual effects system that can be easily customized:

### Color Schemes
- **Turret**: Cyan (#00FFFF) with white core
- **Bullets**: Green (#00FF00) with energy trails
- **Standard Missiles**: Red (#FF0040) with warning indicators
- **Fast Missiles**: White (#FFFFFF) with speed effects
- **Heavy Missiles**: Purple (#8000FF) with energy fields

### Effect Intensity
All visual effects support intensity scaling for performance optimization on different devices.

## 🔧 Development

### Project Structure
```
lib/
├── entities/           # Game objects (Turret, Bullet, Missile, Explosion)
├── effects/           # Advanced visual effects and particle systems
├── screens/           # Game screens (Menu, Game, etc.)
├── utils/             # Utilities (Constants, Vector math, Game state)
└── main.dart          # Application entry point
```

### Adding New Effects
1. Create effect classes in `lib/effects/`
2. Integrate with entity rendering systems
3. Add configuration options in `GameConstants`
4. Test performance on target devices

## 🎵 Audio (Planned)
- **Cyberpunk Soundtrack**: Looping electronic music
- **Sound Effects**: Laser shots, explosions, warnings
- **Spatial Audio**: Directional sound effects
- **Volume Controls**: Adjustable audio settings

## 📱 Platform Support
- **Android**: Primary target platform
- **iOS**: Compatible (requires iOS-specific testing)
- **Web**: Potential future support
- **Desktop**: Potential future support

## 🚀 Performance Tips
- **Target Device**: Optimized for mid-range Android devices
- **Frame Rate**: Maintains 60 FPS on Snapdragon 720G and above
- **Memory Usage**: Efficient particle pooling and resource management
- **Battery Life**: Optimized rendering to minimize power consumption

## 🎮 Future Enhancements
- **Power-ups**: Shield, rapid fire, time slow
- **Boss Battles**: Large enemy encounters
- **Achievements**: Unlock system with rewards
- **Leaderboards**: Global score competition
- **Customization**: Turret skins and effect themes

## 🤝 Contributing
Contributions are welcome! Please feel free to submit pull requests for:
- New visual effects
- Performance optimizations
- Bug fixes
- Feature enhancements

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments
- Inspired by classic arcade games like Geometry Wars
- Visual style influenced by Tron and cyberpunk aesthetics
- Flutter community for excellent documentation and support

---

**Experience the future of mobile gaming with Swipe Turret's stunning neon-cyberpunk visuals! 🌟**