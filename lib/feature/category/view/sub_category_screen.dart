import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class SubCategoryScreen extends StatefulWidget {
  final String? categoryTitle;
  final String? categoryID;
  final int? subCategoryIndex;
  const SubCategoryScreen({
    super.key,
    this.categoryTitle,
    this.categoryID,
    this.subCategoryIndex,
  }) ;

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    try {
      await HomeScreen.ensureZoneHeader();
      final id = widget.categoryID ?? '';
      if (id.isNotEmpty) {
        await Get.find<CategoryController>().getSubCategoryList(id);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        appBar: CustomAppBar(title: widget.categoryTitle,),
      body: GetBuilder<CategoryController>(
        builder: (categoryController){

          return FooterBaseView(
            isScrollView: false,
            isCenter: (categoryController.subCategoryList != null &&  categoryController.subCategoryList!.isEmpty),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height:
                  ResponsiveHelper.isDesktop(context)?Dimensions.paddingSizeExtraLarge:0,
                  ),
                ),
                const SubCategoryView(isScrollable: true,),
              ],
            ),
          );
        }
      )
    );
  }
}
