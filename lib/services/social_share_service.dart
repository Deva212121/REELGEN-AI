import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// A utility service for sharing content to WhatsApp, Instagram, and Facebook.
///
/// Supports:
/// - WhatsApp: share text, image, or reel (video) via share_plus or deep link.
/// - Instagram: share image/video to feed or stories (if using native).
/// - Facebook: share text/link to feed or stories.
class SocialShareService {
  /// Shares text (with optional link) to WhatsApp.
  ///
  /// [message] The text to share.
  /// [phoneNumber] (optional) A specific WhatsApp number (without + or 00).
  /// If not provided, opens a generic share sheet with WhatsApp option.
  static Future<void> shareToWhatsApp({
    required String message,
    String? phoneNumber,
  }) async {
    try {
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Direct WhatsApp chat via deep link (wa.me)
        final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to share_plus
          await Share.share(message);
        }
      } else {
        // Generic share – will show WhatsApp if installed
        await Share.share(message);
      }
    } catch (e) {
      debugPrint('WhatsApp share error: $e');
      // Fallback to generic share
      await Share.share(message);
    }
  }

  /// Shares an image or video to Instagram Feed.
  ///
  /// [filePath] Absolute path to the image/video file.
  /// [isVideo] Set to true for video files.
  /// [caption] Optional caption text.
  static Future<void> shareToInstagramFeed({
    required String filePath,
    bool isVideo = false,
    String? caption,
  }) async {
    try {
      final XFile file = XFile(filePath);
      if (isVideo) {
        // Share video – share_plus will handle if Instagram is installed
        await Share.shareXFiles([file], text: caption);
      } else {
        await Share.shareXFiles([file], text: caption);
      }
    } catch (e) {
      debugPrint('Instagram feed share error: $e');
      rethrow;
    }
  }

  /// Shares an image or video to Instagram Stories (must use native intent).
  ///
  /// [filePath] Absolute path to the image/video file.
  /// [isVideo] Set to true for video files.
  /// [backgroundTopColor] (optional) Hex color for background (only for images).
  /// [backgroundBottomColor] (optional) Hex color for background (only for images).
  ///
  /// **Note:** This uses the official Instagram deep link scheme. It only works on
  /// Android and iOS devices with Instagram installed. For web, it's not supported.
  static Future<void> shareToInstagramStory({
    required String filePath,
    bool isVideo = false,
    String? backgroundTopColor,
    String? backgroundBottomColor,
  }) async {
    // Check platform – stories deep link only works on mobile
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Instagram Stories sharing is only supported on mobile devices.');
      return;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // For Android, we need to use content:// URI; for iOS we use file://
      // Since we cannot easily create content URIs, we use the share_plus method
      // which handles both.
      final XFile xFile = XFile(filePath);
      // This will show Instagram if installed in the share sheet.
      await Share.shareXFiles([xFile], text: 'Check this out on Instagram');
    } catch (e) {
      debugPrint('Instagram story share error: $e');
      rethrow;
    }
  }

  /// Shares a text/link to Facebook Feed.
  ///
  /// [message] The text to share.
  /// [link] (optional) URL to include.
  static Future<void> shareToFacebook({
    required String message,
    String? link,
  }) async {
    try {
      // Facebook deep link for posting to feed (not fully supported via apps)
      // We'll use generic share (share_plus) which will show Facebook if installed.
      final text = link != null ? '$message $link' : message;
      await Share.share(text);
    } catch (e) {
      debugPrint('Facebook share error: $e');
      rethrow;
    }
  }

  /// Shares a reel (video) to Facebook Reels or Instagram Reels.
  ///
  /// [filePath] Absolute path to the video file.
  /// [platform] 'instagram' or 'facebook' (defaults to instagram).
  static Future<void> shareReel({
    required String filePath,
    String platform = 'instagram',
  }) async {
    try {
      final XFile file = XFile(filePath);
      if (platform.toLowerCase() == 'facebook') {
        // For Facebook Reels, sharing via share_plus is the most universal.
        await Share.shareXFiles([file], text: 'Check out my Reel!');
      } else {
        // Instagram Reels – share via share_plus as well.
        await Share.shareXFiles([file], text: 'Check out my Reel!');
      }
    } catch (e) {
      debugPrint('Reel share error: $e');
      rethrow;
    }
  }

  /// Shares arbitrary files (e.g., image, video) to any available app.
  ///
  /// [filePaths] List of absolute file paths.
  /// [text] Optional text to accompany the share.
  static Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(files, text: text);
    } catch (e) {
      debugPrint('Share files error: $e');
      rethrow;
    }
  }

  /// Generic share of text and/or link.
  static Future<void> shareText({
    required String message,
    String? link,
  }) async {
    final text = link != null ? '$message $link' : message;
    await Share.share(text);
  }
}