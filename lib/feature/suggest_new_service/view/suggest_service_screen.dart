import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class SuggestServiceScreen extends StatefulWidget {
  const SuggestServiceScreen({super.key}) ;

  @override
  State<SuggestServiceScreen> createState() => _SuggestServiceScreenState();
}

class _SuggestServiceScreenState extends State<SuggestServiceScreen> {

  @override
  void initState() {
    super.initState();
    try {
      Get.find<SuggestServiceController>().resetRequestView();
    } catch (_) {}
    try {
      Get.find<CategoryController>().getCategoryList(false);
    } catch (_) {}
  }

  Color _textColor(BuildContext context, double alpha) {
    return (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black).withValues(alpha: alpha);
  }

  void _onPressed(SuggestServiceController suggestServiceController) {
    if(!suggestServiceController.isShowInputField){
      suggestServiceController.updateShowInputField();
      return;
    }
    if(suggestServiceController.selectedCategoryName==""){
      customSnackBar('select_category'.tr,  type: ToasterMessageType.info);
    }else if(suggestServiceController.serviceNameController.text==""){
      customSnackBar('provide_your_desired_service_name'.tr,  type: ToasterMessageType.info);
    }else if(suggestServiceController.serviceDetailsController.text.isEmpty){
      customSnackBar("provide_some_details_about_your_service".tr,  type: ToasterMessageType.info);
    }else{
      suggestServiceController.submitNewServiceRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(title: "service_request".tr, actionWidget: IconButton(
        onPressed: (){
          Get.to(()=> const SuggestedServiceListScreen());
        },
        icon: const Icon(Icons.list),
      )),
      body: GetBuilder<SuggestServiceController>(builder: (suggestServiceController){
        return SafeArea(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    if(ResponsiveHelper.isDesktop(context))
                    Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Align(
                        alignment: Get.find<LocalizationController>().isLtr? Alignment.topRight: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Get.toNamed(RouteHelper.getNewSuggestedServiceList()),
                          child: Container(
                            decoration:BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).colorScheme.primary
                            ),
                            padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault,vertical:Dimensions.paddingSizeSmall-2),
                            child: Text('see_request'.tr, style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault, color: Colors.white
                            )),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Text('tell_us_more_about_your_service'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                            color: _textColor(context, 0.9),
                          )
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeSmall),
                      child: Text('suggest_more_service_that_you_willing'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: _textColor(context, 0.7),
                        ), textAlign: TextAlign.center,
                      ),
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge,),
                        child: Image.asset(
                          Images.suggestServiceIcon,
                          width: suggestServiceController.initialImageSize,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.miscellaneous_services_outlined,
                            size: suggestServiceController.initialImageSize,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),

                    if (suggestServiceController.isShowInputField)
                      const SuggestServiceInputField(),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    suggestServiceController.isLoading==false?
                    CustomButton(width: 240, fontSize: Dimensions.fontSizeDefault,
                      buttonText: suggestServiceController.isShowInputField?"send_request".tr:'request_for_service'.tr,
                      onPressed: () => _onPressed(suggestServiceController),
                    ): const CircularProgressIndicator(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
