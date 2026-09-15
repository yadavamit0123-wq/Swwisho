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

  Future<void> _loadCategories() async {
    try {
      // Category/sub-category lists are zone filtered, so make sure the zone
      // header exists before firing the requests.
      await HomeScreen.ensureZoneHeader();
      final categoryController = Get.find<CategoryController>();
      categoryController.getCategoryList(false);
      await categoryController.getSubCategoryList(widget.categoryID, shouldUpdate: false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (categoryController) {
        return Scaffold(
          endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
          appBar: CustomAppBar(title: 'available_service'.tr,),
          body: FooterBaseView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: CustomScrollView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeExtraSmall,),),
                  SliverToBoxAdapter(
                    child: (categoryController.categoryList != null && !(categoryController.isSearching ?? false)) ?
                    Center(
                      child: Container(
                        height:ResponsiveHelper.isDesktop(context) ? 140 : ResponsiveHelper.isTab(context)? 140 : 130,
                        margin: EdgeInsets.only(
                          left: ResponsiveHelper.isDesktop(context)? 0 : Dimensions.paddingSizeDefault,
                        ),
                        width: Dimensions.webMaxWidth,
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraSmall,
                            top: Dimensions.paddingSizeDefault
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryController.categoryList!.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            CategoryModel categoryModel = categoryController.categoryList!.elementAt(index);
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
                                  Get.find<CategoryController>().getSubCategoryList(id);
                                  try {
                                    await scrollController?.scrollToIndex(index, preferPosition: AutoScrollPosition.middle,
                                      duration: const Duration(milliseconds: 250),
                                    );
                                    await scrollController?.highlight(index);
                                  } catch (_) {}
                                },
                                hoverColor: Colors.transparent,
                                child: Container(
                                  width: ResponsiveHelper.isDesktop(context) ? 140 : ResponsiveHelper.isTab(context)?140 :100,

                                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: index != _selectedIndex ? Theme.of(context).primaryColorLight : Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault), ),
                                  ),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          child: CustomImage(
                                            fit: BoxFit.cover,
                                            height: ResponsiveHelper.isDesktop(context) ? 50 : ResponsiveHelper.isTab(context)?40 :30,
                                            width: ResponsiveHelper.isDesktop(context) ? 50 : ResponsiveHelper.isTab(context)?40 :30,
                                            image: categoryModel.imageFullPath ?? '',
                                          ),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeSmall,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                          child: Text(categoryModel.name ?? '',
                                            style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color:index==_selectedIndex? Colors.white:Colors.black
                                            ),
                                            maxLines: 2,textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ) : ResponsiveHelper.isDesktop(context)?
                    const CategoryShimmer(fromHomeScreen: false,):const SizedBox(),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(width: Dimensions.webMaxWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                        child: Center(
                          child: Text(
                            'sub_categories'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary),
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
          ),
        );
      },
    );
  }
}
