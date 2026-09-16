// ignore_for_file: deprecated_member_use
import 'package:demandium/feature/search/widget/already_filtered_widget.dart';
import 'package:demandium/feature/search/widget/search_filter_button_widget.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class SearchResultScreen extends StatefulWidget {
  final String? queryText;
  final String? fromPage;

  const SearchResultScreen({super.key, required this.queryText, this.fromPage}) ;

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {

  @override
  void initState() {
    _loadDart();
    super.initState();
  }

  _loadDart() async {
    try {
      Get.find<AllSearchController>().clearAllFilterValue(shouldUpdate: false);
      Get.find<AllSearchController>().updateSortByType(widget.fromPage, shouldUpdate: false);
      Get.find<AllSearchController>().searchData(query:widget.queryText ?? '', offset: 1, shouldUpdate: false);
      await Get.find<CategoryController>().getCategoryList(false);
      Get.find<AllSearchController>().resetCategoryCheckedList(shouldUpdate: false);
      Get.find<AllSearchController>().populatedSearchController(widget.queryText ?? "", shouldUpdate: false);
    } catch (_) {}
  }

  String _price(Service service) {
    try {
      num lowest = service.variationsAppFormat?.defaultPrice ?? 0;
      final variations = service.variationsAppFormat?.zoneWiseVariations ?? [];
      for (final variation in variations) {
        final price = variation.price ?? 0;
        if (lowest == 0 || price < lowest) {
          lowest = price;
        }
      }
      if (lowest <= 0) {
        return '';
      }
      return PriceConverter.convertPrice(lowest.toDouble());
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()  => _exitApp(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        appBar: const SearchAppBar(backButton: true),
        body: GetBuilder<AllSearchController>(builder: (searchController){
          final services = searchController.searchServiceList;
          if (services == null) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).hoverColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                child: Text(
                  "${services.length} ${'results_found'.tr}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              const SearchFilterButtonWidget(),
              if (searchController.sortedByList.isNotEmpty && !ResponsiveHelper.isDesktop(context))
                const AlreadyFilteredWidget(),
              Expanded(
                child: services.isEmpty
                    ? Center(child: Text('no_service_found'.tr))
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: services.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 230,
                        ),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final price = _price(service);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final id = service.id;
                                    if (id == null || id.isEmpty) {
                                      return;
                                    }
                                    RouteHelper.toServiceDetails(id, fromPage: "search_page");
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: SizedBox(
                                          height: 110,
                                          width: double.infinity,
                                          child: CustomImage(
                                            image: service.thumbnailFullPath ?? service.coverImageFullPath ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                                        child: Text(
                                          service.name ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                      if (price.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            price,
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => ServiceCenterDialog(service: service),
                                      );
                                    },
                                    icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<bool> _exitApp() async {
    try {
      Get.find<AllSearchController>().clearSearchController();
    } catch (_) {}
    return true;
  }
}
