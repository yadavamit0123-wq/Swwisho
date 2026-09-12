import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    String label = 'Search services';
    try {
      label = 'search_services'.tr;
    } catch (_) {}

    return InkWell(
      onTap: () {
        try {
          Get.dialog(const SearchSuggestionDialog(), transitionCurve: Curves.easeIn);
        } catch (_) {}
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeExtraSmall,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeSmall,
        ),
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 14),
              ),
            ),
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverDelegate(
        extentSize: 60,
        child: const HomeSearchBar(),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget? child;
  double? extentSize;
  SliverDelegate({@required this.child, @required this.extentSize});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child!;
  }
  @override
  double get maxExtent => extentSize!;
  @override
  double get minExtent => extentSize!;
  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != maxExtent || child != oldDelegate.child;
  }
}
