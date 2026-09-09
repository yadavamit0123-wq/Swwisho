import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class SearchServiceWidget extends StatelessWidget {
  const SearchServiceWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall,),
      decoration: BoxDecoration(
        boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
      alignment: Alignment.topCenter,
      child: Column( mainAxisSize: MainAxisSize.min, children: [

        ResponsiveHelper.isDesktop(context) ? const WebMenuBar(openSearchDialog: false,) : const SearchInputBoxApp(),
      ]),
    );
  }
}

class SearchInputBoxApp extends StatefulWidget {
  const SearchInputBoxApp({super.key});

  @override
  State<SearchInputBoxApp> createState() => _SearchInputBoxAppState();
}

class _SearchInputBoxAppState extends State<SearchInputBoxApp> {

  @override
  void initState() {
    super.initState();
    // requestFocus();
  }

  requestFocus() async{
    Timer(const Duration(milliseconds: 200), () {
      if(!ResponsiveHelper.isWeb()) {
        Get.find<ServiceController>().searchFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ServiceController>(
      builder: (searchController){
        return Center(child: TextField(
          controller: searchController.searchController,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          cursorColor: Theme.of(context).colorScheme.primary,
          autofocus: false,
          focusNode: searchController.searchFocus,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,

          decoration: InputDecoration(
            // contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(50,),left: Radius.circular(50)),
              borderSide: BorderSide(style: BorderStyle.none, width: 0),
            ),
            fillColor: Get.isDarkMode? Theme.of(context).primaryColorDark:const Color(0xffFEFEFE),
            isDense: true,
            hintText: 'search_services'.tr,
            hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
            filled: true,
            suffixIcon: InkWell(
              onTap: () {
                if(searchController.searchController.text.isNotEmpty && searchController.searchController.text.length > 255){
                  customSnackBar('search_text_length_message'.tr,  showDefaultSnackBar: false, type: ToasterMessageType.info);
                }else{
                  searchController.updateSearchServiceList(searchController.searchController.text);
                  // Get.back();
                  FocusScope.of(context).unfocus();
                  // Get.toNamed(RouteHelper.getSearchResultRoute(queryText: searchController.searchController.text));
                  // FocusScope.of(context).unfocus();
                }
              },
              child: Container(height: 40, width: 40,
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Image.asset(Images.searchIcon),
              ),
            ) ,
          ),
          onChanged: (text) {
            searchController.updateSearchServiceList(text);
            // searchController.showSuffixIcon(context,text);
            // if(text.trim().isNotEmpty) {
            //   searchController.getSearchSuggestion(text);
            // }
          },
          onSubmitted: (text) {
            searchController.updateSearchServiceList(text);
            if(text.isNotEmpty) {
              if(text.length > 255){
                customSnackBar('search_text_length_message'.tr, type: ToasterMessageType.info);
              }else{
                // Get.back();
                FocusScope.of(context).unfocus();
                // Get.toNamed(RouteHelper.getSearchResultRoute(queryText: text));
              }
            }
          },
        ));
      },
    );
  }
}
