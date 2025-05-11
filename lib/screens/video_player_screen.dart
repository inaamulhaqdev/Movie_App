import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    // Configure Android-specific settings
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Updated for newer webview_flutter_android API
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(false);
    }

    _setupWebView();

    // Set the default orientation to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Reset orientation when the screen is closed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _setupWebView() {
    final Uri uri = Uri.parse(widget.videoUrl);
    final videoId = uri.queryParameters['v'];

    if (videoId == null) {
      Navigator.pop(context);
      return;
    }

    final String html = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            html, body { 
              margin: 0; 
              padding: 0; 
              width: 100%; 
              height: 100%; 
              overflow: hidden;
            }
            #player { 
              width: 100%; 
              height: 100%;
              position: absolute;
              top: 0;
              left: 0;
            }
          </style>
        </head>
        <body>
          <div id="player"></div>
          <script src="https://www.youtube.com/iframe_api"></script>
          <script>
            var player;
            var isFullScreen = false;
            var videoEnded = false;
            var orientationChangeInProgress = false;
            
            function onYouTubeIframeAPIReady() {
              player = new YT.Player('player', {
                videoId: '$videoId',
                playerVars: {
                  'autoplay': 1,
                  'playsinline': 1,
                  'controls': 1,
                  'modestbranding': 1,
                  'rel': 0,
                  'fs': 1  // Enable fullscreen button
                },
                events: {
                  'onReady': onPlayerReady,
                  'onStateChange': onPlayerStateChange,
                  'onFullscreenChange': onFullscreenChange
                }
              });
            }
            
            function onPlayerReady(event) {
              event.target.playVideo();
            }
            
            function onPlayerStateChange(event) {
              if (event.data == YT.PlayerState.ENDED) {
                videoEnded = true;
                // Notify the Flutter app immediately that the video has ended
                VideoStatus.postMessage('ended');
              }
            }
            
            function onFullscreenChange(event) {
              if (event && typeof event.data !== 'undefined') {
                const newFullScreenState = !!event.data;
                
                if (newFullScreenState !== isFullScreen) {
                  isFullScreen = newFullScreenState;
                  
                  // Prevent sending too many fullscreen change events in quick succession
                  if (!orientationChangeInProgress) {
                    orientationChangeInProgress = true;
                    
                    VideoStatus.postMessage('fullscreen:' + isFullScreen);
                    
                    // Reset flag after a delay to allow orientation to complete
                    setTimeout(function() {
                      orientationChangeInProgress = false;
                    }, 500);
                  }
                  
                  // If exiting fullscreen and video has ended
                  if (!isFullScreen && videoEnded) {
                    setTimeout(function() {
                      VideoStatus.postMessage('ended');
                    }, 300);
                  }
                }
              }
            }
            
            // Add event listeners for fullscreen changes directly on document
            document.addEventListener('fullscreenchange', handleDocumentFullscreenChange);
            document.addEventListener('webkitfullscreenchange', handleDocumentFullscreenChange);
            document.addEventListener('mozfullscreenchange', handleDocumentFullscreenChange);
            document.addEventListener('MSFullscreenChange', handleDocumentFullscreenChange);
            
            // Consolidated function for handling fullscreen change events
            function handleDocumentFullscreenChange() {
              const newFullScreenState = !!(
                document.fullscreenElement || 
                document.webkitFullscreenElement || 
                document.mozFullscreenElement || 
                document.msFullscreenElement
              );
              
              if (newFullScreenState !== isFullScreen) {
                isFullScreen = newFullScreenState;
                
                // Prevent sending too many fullscreen change events in quick succession
                if (!orientationChangeInProgress) {
                  orientationChangeInProgress = true;
                  
                  VideoStatus.postMessage('fullscreen:' + isFullScreen);
                  
                  // Reset flag after a delay to allow orientation to complete
                  setTimeout(function() {
                    orientationChangeInProgress = false;
                  }, 500);
                }
                
                // If exiting fullscreen and video has ended
                if (!isFullScreen && videoEnded) {
                  setTimeout(function() {
                    VideoStatus.postMessage('ended');
                  }, 300);
                }
              }
            }
          </script>
        </body>
      </html>
    ''';

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'VideoStatus',
        onMessageReceived: (message) {
          if (message.message == 'ended') {
            Navigator.pop(context);
          } else if (message.message.startsWith('fullscreen:')) {
            final isFullScreen = message.message.split(':')[1] == 'true';
            _handleFullscreenChange(isFullScreen);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(html);
  }

  void _handleFullscreenChange(bool isFullScreen) {
    if (isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = isFullScreen;
      });

      // Change the device orientation based on fullscreen state
      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }

      // Wait a moment to let the orientation change complete
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _isFullScreen
              ? null
              : AppBar(
                backgroundColor: Colors.transparent,
                leadingWidth: ResponsiveSizeUtil.adaptiveWidth(100),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: ResponsiveSizeUtil.adaptiveHeight(30),
                    width: ResponsiveSizeUtil.adaptiveWidth(50),
                    margin: EdgeInsets.only(
                      left: ResponsiveSizeUtil.adaptiveWidth(16),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveSizeUtil.adaptiveWidth(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: ResponsiveSizeUtil.adaptiveFontSize(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF57B8FF)),
            ),
        ],
      ),
    );
  }
}
