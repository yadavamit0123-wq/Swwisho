import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ServiceCenterDialog extends StatefulWidget {
  final Service? service;
  final CartModel? cart;
  final int? cartIndex;
  final bool? isFromDetails;
  final ProviderData? providerData;

  const ServiceCenterDialog({
    super.key,
    required this.service,
    this.cart,
    this.cartIndex,
    this.isFromDetails = false,
    this.providerData,
  });

  @override
  State<ServiceCenterDialog> createState() => _ServiceCenterDialogState();
}

class _ServiceCenterDialogState extends State<ServiceCenterDialog> {
  bool _loading = true;
  String? _error;
  Service? _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      await HomeScreen.ensureZoneHeader();
      final serviceId = widget.service?.id;
      if (serviceId != null && serviceId.isNotEmpty) {
        try {
          final response = await Get.find<ApiClient>().getData('${AppConstants.serviceDetailsUri}/$serviceId');
          dynamic body = response.body;
          if (body is String && body.isNotEmpty) {
            body = jsonDecode(body);
          }
          final content = body is Map ? body['content'] : null;
          if (content is Map) {
            _service = Service.fromJson(Map<String, dynamic>.from(content));
          }
        } catch (_) {}
      }

      final service = _service;
      if (service != null) {
        Get.find<CartController>().setInitialCartList(service);
      }
    } catch (_) {
      _error = 'Service variants load nahi ho paaye';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addToCart() async {
    try {
      await Get.find<CartController>().addMultipleCartToServer(
        providerId: widget.providerData?.id ?? Get.find<CartController>().selectedProvider?.id ?? '',
      );
      if (Get.find<AuthController>().isLoggedIn()) {
        await Get.find<CartController>().getCartListFromServer(shouldUpdate: true);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        customSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: GetBuilder<CartController>(
          builder: (cartController) {
            final service = _service ?? widget.service;
            final variants = cartController.initialCartList;

            if (_loading) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (service != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 64,
                      width: 64,
                      child: CustomImage(
                        image: service.thumbnailFullPath ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.name ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    variants.isEmpty
                        ? 'no_variation_is_available'.tr
                        : '${variants.length} ${variants.length > 1 ? 'variations_available'.tr : 'variation_available'.tr}',
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 12),
                if (variants.isNotEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: variants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = variants[index];
                        String priceText = '';
                        try {
                          priceText = PriceConverter.convertPrice(item.price.toDouble(), isShowLongPrice: true);
                        } catch (_) {
                          priceText = item.price.toString();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.variantKey.replaceAll('-', ' '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      priceText,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: item.quantity > 0 ? () => cartController.updateQuantity(index, false) : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => cartController.updateQuantity(index, true),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: cartController.isButton && !cartController.isLoading ? _addToCart : null,
                    child: cartController.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('add_to_cart'.tr),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
