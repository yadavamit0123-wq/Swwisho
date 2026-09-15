import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class CategorySubCategoryScreen extends StatefulWidget {
  final String categoryID;
  final String categoryIndex;
   const CategorySubCategoryScreen({super.key, required this.categoryID, required this.categoryIndex}) ;

  @override
  State<CategorySubCategoryScreen> createState() => _CategorySubCategoryScreenState();
}

class _CategorySubCategoryScreenState extends State<CategorySubCategoryScreen> {
  AutoScrollController? scrollController;
  String? categoryIndex;

  int get _selectedIndex => int.tryParse(categoryIndex ?? '0') ?? 0;

  @override
  void initState() {
    super.initState();
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    categoryIndex = widget.categoryIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await scrollController?.scrollToIndex(_selectedIndex, preferPosition: AutoScrollPosition.middle);
        await scrollController?.highlight(_selectedIndex);
      } catch (_) {}
    });

    _loadCategories();
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      await HomeScreen.ensureZoneHeader();
      final categoryController = Get.find<CategoryController>();

      if (categoryController.categoryList == null || categoryController.categoryList!.isEmpty) {
        await categoryController.getCategoryList(true);
      }

      if (widget.categoryID.isNotEmpty) {
        await categoryController.getSubCategoryList(widget.categoryID);
      }
    } catch (_) {
      try {
        if (widget.categoryID.isNotEmpty) {
          await Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
        }
      } catch (_) {}
    }
  }

  Widget _buildCategoryStrip(CategoryController categoryController) {
    final categories = categoryController.categoryList ?? [];
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        height: ResponsiveHelper.isDesktop(context) ? 140 : ResponsiveHelper.isTab(context) ? 140 : 130,
        margin: EdgeInsets.only(
          left: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
        ),
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.only(
          bottom: Dimensions.paddingSizeExtraSmall,
          top: Dimensions.paddingSizeDefault,
        ),
        child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final categoryModel = categories[index];
            return AutoScrollTag(
              controller: scrollController!,
              key: ValueKey(index),
              index: index,
              child: InkWell(
                onTap: () async {
                  final id = categoryModel.id;
                  if (id == null || id.isEmpty) {
                    return;
                  }
                  setState(() => categoryIndex = index.toString());
                  await Get.find<CategoryController>().getSubCategoryList(id);
                  try {
                    await scrollController?.scrollToIndex(
                      index,
                      preferPosition: AutoScrollPosition.middle,
                      duration: const Duration(milliseconds: 250),
                    );
                    await scrollController?.highlight(index);
                  } catch (_) {}
                },
                hoverColor: Colors.transparent,
                child: Container(
                  width: ResponsiveHelper.isDesktop(context) ? 140 : ResponsiveHelper.isTab(context) ? 140 : 100,
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: index != _selectedIndex
                        ? Theme.of(context).primaryColorLight
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          fit: BoxFit.cover,
                          height: ResponsiveHelper.isDesktop(context) ? 50 : ResponsiveHelper.isTab(context) ? 40 : 30,
                          width: ResponsiveHelper.isDesktop(context) ? 50 : ResponsiveHelper.isTab(context) ? 40 : 30,
                          image: categoryModel.imageFullPath ?? '',
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Text(
                          categoryModel.name ?? '',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: index == _selectedIndex ? Colors.white : Colors.black,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (categoryController) {
        final categories = categoryController.categoryList;
        final loadingCategories = categories == null && !(categoryController.isSearching ?? false);

        return Scaffold(
          endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
          appBar: CustomAppBar(title: 'available_service'.tr),
          body: FooterBaseView(
            isScrollView: false,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtraLarge
                        : Dimensions.paddingSizeExtraSmall,
                  ),
                ),
                SliverToBoxAdapter(
                  child: loadingCategories
                      ? const CategoryShimmer(fromHomeScreen: false)
                      : _buildCategoryStrip(categoryController),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                      child: Center(
                        child: Text(
                          'sub_categories'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Get.isDarkMode
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SubCategoryView(
                  noDataText: "no_subcategory_found".tr,
                  isScrollable: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
