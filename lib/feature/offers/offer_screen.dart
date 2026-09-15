import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

import '../../utils/appp_upgrade_wrapper.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      await HomeScreen.ensureZoneHeader();
      await Get.find<ServiceController>().getOffersList(1, true);
    } catch (_) {
      try {
        await Get.find<ServiceController>().getOffersList(1, true);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _mobileBanner() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Images.offerBanner,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ColoredBox(
            color: Colors.black54,
            child: Center(
              child: Text(
                'current_offers'.tr,
                style: robotoMedium.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      appBar: CustomAppBar(
        isBackButtonExist: false,
        title: 'offers'.tr,
      ),
      body: AppUpgradeWrapper(
        child: GetBuilder<ServiceController>(
          builder: (serviceController) {
            final offers = serviceController.offerBasedServiceList;

            return RefreshIndicator(
              onRefresh: _loadOffers,
              child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                slivers: [
                  if (ResponsiveHelper.isMobile(context))
                    SliverToBoxAdapter(child: _mobileBanner()),

                  if (!ResponsiveHelper.isMobile(context) &&
                      offers != null &&
                      offers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeSmall,
                        ),
                        child: TitleWidget(title: 'current_offers'.tr),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Dimensions.webMaxWidth,
                          minHeight: offers == null
                              ? MediaQuery.of(context).size.height * 0.5
                              : 0,
                        ),
                        child: PaginatedListView(
                          scrollController: scrollController,
                          totalSize: serviceController.offerBasedServiceContent?.total,
                          offset: serviceController.offerBasedServiceContent?.currentPage,
                          onPaginate: (int offset) async =>
                              await serviceController.getOffersList(offset, false),
                          bottomPadding: Dimensions.paddingSizeExtraLarge,
                          itemView: ServiceViewVertical(
                            service: offers,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtraSmall
                                  : Dimensions.paddingSizeDefault,
                              vertical: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtraSmall
                                  : Dimensions.paddingSizeSmall,
                            ),
                            type: 'others',
                            noDataType: NoDataType.offers,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (ResponsiveHelper.isDesktop(context))
                    const SliverToBoxAdapter(child: FooterView()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
