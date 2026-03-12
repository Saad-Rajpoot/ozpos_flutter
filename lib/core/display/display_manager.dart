import 'package:presentation_displays/displays_manager.dart';

DisplayManager? _sharedDisplayManager;

DisplayManager get sharedDisplayManager {
  _sharedDisplayManager ??= DisplayManager();
  return _sharedDisplayManager!;
}

