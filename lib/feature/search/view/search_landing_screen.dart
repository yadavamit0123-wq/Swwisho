import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/search/widget/recommended_search.dart';

class SearchLandingScreen extends StatelessWidget {
  const SearchLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: SearchInputBoxApp(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecentSearch(),
            SizedBox(height: Dimensions.paddingSizeLarge),
            RecommendedSearch(),
          ],
        ),
      ),
    );
  }
}
