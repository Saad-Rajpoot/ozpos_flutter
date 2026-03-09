import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../../domain/entities/payment_method_type.dart';
import '../constant/checkout_constants.dart';

/// Payment Options Panel - Right column
/// Simplified version focusing on essential features
class PaymentOptionsPanel extends StatelessWidget {
  const PaymentOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final viewState = state.viewState;
        if (viewState == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Scrollable: order notes + payment methods
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOrderNotes(context, viewState),
                    const SizedBox(height: CheckoutConstants.gapNormal),
                    _buildPaymentMethods(context, viewState),
                    const SizedBox(height: CheckoutConstants.gapNormal),
                  ],
                ),
              ),
            ),
            // Action buttons (sticky at bottom)
            _buildActionButtons(context, viewState),
          ],
        );
      },
    );
  }

  Widget _buildOrderNotes(BuildContext context, CheckoutLoaded state) {
    return _OrderNotesField(
      initialNotes: state.cart.orderNotes,
      onChanged: (value) {
        context.read<CheckoutBloc>().add(SetOrderNotes(notes: value));
      },
    );
  }

  List<PaymentMethodType> _checkoutPaymentMethods(OrderType orderType) {
    final methods = <PaymentMethodType>[
      PaymentMethodType.cash,
      PaymentMethodType.card,
      PaymentMethodType.digitalWallet,
      PaymentMethodType.bankTransfer,
    ];

    // Pay Later is only available for Dine-In orders.
    if (orderType == OrderType.dineIn) {
      methods.add(PaymentMethodType.payLater);
    }

    if (orderType == OrderType.delivery) {
      methods.add(PaymentMethodType.cod);
    }

    return methods;
  }

  Widget _buildPaymentMethods(BuildContext context, CheckoutLoaded state) {
    final methods = _checkoutPaymentMethods(state.cart.orderType);
    return Container(
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: CheckoutConstants.textTitle),
          const SizedBox(height: CheckoutConstants.gapNormal),

          // Payment method grid
          Wrap(
            spacing: CheckoutConstants.gapSmall,
            runSpacing: CheckoutConstants.gapSmall,
            children: methods.map((method) {
              final isSelected = state.selectedMethod == method;
              return _buildMethodTile(context, method, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(
    BuildContext context,
    PaymentMethodType method,
    bool isSelected,
  ) {
    final width = (CheckoutConstants.rightWidth -
            CheckoutConstants.cardPadding * 2 -
            CheckoutConstants.gapSmall) /
        2;

    return GestureDetector(
      onTap: () {
        context.read<CheckoutBloc>().add(SelectPaymentMethod(method: method));
      },
      child: Container(
        width: width,
        height: CheckoutConstants.methodTileHeight,
        decoration: BoxDecoration(
          color: isSelected
              ? CheckoutConstants.primaryLight
              : CheckoutConstants.surface,
          borderRadius: BorderRadius.circular(CheckoutConstants.radiusButton),
          border: Border.all(
            color: isSelected
                ? CheckoutConstants.primary
                : CheckoutConstants.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? CheckoutConstants.shadowSelected : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              method.icon,
              size: 28,
              color: isSelected
                  ? CheckoutConstants.primary
                  : CheckoutConstants.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              method.label,
              style: CheckoutConstants.textBody.copyWith(
                fontWeight: isSelected
                    ? CheckoutConstants.weightSemiBold
                    : CheckoutConstants.weightMedium,
                color: isSelected
                    ? CheckoutConstants.primary
                    : CheckoutConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CheckoutLoaded state) {
    return Column(
      children: [
        // PAY button
        SizedBox(
          width: double.infinity,
          height: CheckoutConstants.inputHeight,
          child: ElevatedButton(
            onPressed: state.canPay
                ? () => context.read<CheckoutBloc>().add(ProcessPayment())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckoutConstants.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CheckoutConstants.border,
              disabledForegroundColor: CheckoutConstants.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CheckoutConstants.radiusButton,
                ),
              ),
            ),
            child: Text(
              'PAY \$${state.grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: CheckoutConstants.fontSizeTitle,
                fontWeight: CheckoutConstants.weightBold,
              ),
            ),
          ),
        ),
        if (state.cart.orderType == OrderType.dineIn) ...[
          const SizedBox(height: CheckoutConstants.gapSmall),
          // Pay Later button (Dine-In only)
          SizedBox(
            width: double.infinity,
            height: CheckoutConstants.tabHeight,
            child: OutlinedButton(
              onPressed: () => context.read<CheckoutBloc>().add(PayLater()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CheckoutConstants.primary),
                foregroundColor: CheckoutConstants.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    CheckoutConstants.radiusButton,
                  ),
                ),
              ),
              child: const Text(
                'Pay Later',
                style: TextStyle(
                  fontSize: CheckoutConstants.fontSizeBody,
                  fontWeight: CheckoutConstants.weightSemiBold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderNotesField extends StatefulWidget {
  final String? initialNotes;
  final ValueChanged<String> onChanged;

  const _OrderNotesField({
    required this.initialNotes,
    required this.onChanged,
  });

  @override
  State<_OrderNotesField> createState() => _OrderNotesFieldState();
}

class _OrderNotesFieldState extends State<_OrderNotesField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void didUpdateWidget(_OrderNotesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotes != oldWidget.initialNotes &&
        widget.initialNotes != _controller.text) {
      _controller.text = widget.initialNotes ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order notes', style: CheckoutConstants.textTitle),
          const SizedBox(height: CheckoutConstants.gapSmall),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Add notes for this order...',
              hintStyle: CheckoutConstants.textMutedSmall,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CheckoutConstants.radiusButton),
                borderSide: BorderSide(color: CheckoutConstants.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: CheckoutConstants.textBody,
          ),
        ],
      ),
    );
  }
}
