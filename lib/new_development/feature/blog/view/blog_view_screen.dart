import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';


class BlogViewScreen extends StatefulWidget {
  const BlogViewScreen({super.key});

  @override
  State<BlogViewScreen> createState() => _BlogViewScreenState();
}

class _BlogViewScreenState extends State<BlogViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  final String blogUrl = "https://swwisho.com/all-blogs";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black) // black back
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(blogUrl));
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return;
        }

        Get.back();
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'All Blogs',
          onBackPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
              return;
            }
            Get.back();
          },
        ),
        body: Stack(
          children: [
            /// 🌐 Webview
            WebViewWidget(controller: _controller),
            /// ⏳ Loading overlay
            if (_isLoading)
              SizedBox(
                child:  Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
