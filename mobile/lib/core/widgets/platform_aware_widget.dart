import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class PlatformAwareWidget extends StatelessWidget {
  const PlatformAwareWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Platform-aware button
        _buildPlatformButton(),
        const SizedBox(height: 20),
        
        // Platform-aware dialog
        ElevatedButton(
          onPressed: () => _showPlatformDialog(context),
          child: const Text('Show Platform Dialog'),
        ),
        const SizedBox(height: 20),
        
        // Platform-aware loading indicator
        _buildPlatformLoadingIndicator(),
        const SizedBox(height: 20),
        
        // Platform-aware switch
        _buildPlatformSwitch(),
      ],
    );
  }

  Widget _buildPlatformButton() {
    if (Platform.isIOS) {
      return CupertinoButton.filled(
        onPressed: () {},
        child: const Text('iOS Cupertino Button'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {},
        child: const Text('Android Material Button'),
      );
    }
  }

  Widget _buildPlatformLoadingIndicator() {
    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget _buildPlatformSwitch() {
    return Platform.isIOS
        ? CupertinoSwitch(
            value: true,
            onChanged: (value) {},
          )
        : Switch(
            value: true,
            onChanged: (value) {},
          );
  }

  void _showPlatformDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('iOS Dialog'),
          content: const Text('This is a Cupertino-style dialog'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              isDefaultAction: true,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Android Dialog'),
          content: const Text('This is a Material Design dialog'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Alternative: Using conditional rendering for cleaner code
class PlatformSelectExample extends StatelessWidget {
  const PlatformSelectExample({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const Text('This shows on iOS');
    } else if (Platform.isAndroid) {
      return const Text('This shows on Android');
    } else {
      return const Text('This shows on other platforms');
    }
  }
}

// Using Theme.of(context).platform for theme-based detection
class ThemePlatformExample extends StatelessWidget {
  const ThemePlatformExample({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    
    return Column(
      children: [
        if (platform == TargetPlatform.iOS) 
          const Text('iOS UI'),
        if (platform == TargetPlatform.android) 
          const Text('Android UI'),
        
        // Or using switch
        Builder(
          builder: (context) {
            switch (platform) {
              case TargetPlatform.iOS:
                return const CupertinoButton(
                  onPressed: null,
                  child: Text('iOS Button'),
                );
              case TargetPlatform.android:
                return ElevatedButton(
                  onPressed: () {},
                  child: const Text('Android Button'),
                );
              default:
                return ElevatedButton(
                  onPressed: () {},
                  child: const Text('Default Button'),
                );
            }
          },
        ),
      ],
    );
  }
}
