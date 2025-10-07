import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';
import '../../../addons/presentation/bloc/addon_management_bloc.dart';
import '../../../addons/presentation/bloc/addon_management_event.dart';
import '../../domain/entities/menu_item_edit_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../widgets/wizard_stepper.dart';
import '../widgets/wizard_nav_bar.dart';
import '../widgets/summary_sidebar.dart';
import '../widgets/step1_item_details.dart';
import '../widgets/step2_sizes_addons.dart';
import '../widgets/step3_upsells.dart';
import '../widgets/step4_availability.dart';
import '../widgets/step5_review.dart';

/// Main Menu Item Wizard Screen - 5-step editing process
class MenuItemWizardScreen extends StatelessWidget {
  final MenuItemEditEntity? existingItem;
  final bool isDuplicate;

  const MenuItemWizardScreen({
    super.key,
    this.existingItem,
    this.isDuplicate = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get the menu repository from GetIt
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MenuEditBloc(menuRepository: GetIt.instance<MenuRepository>())
                ..add(InitializeMenuEdit(existingItem: existingItem)),
        ),
        BlocProvider(
          create: (context) {
            final bloc = AddonManagementBloc()
              ..add(const LoadAddonCategoriesEvent());

            // Load attachments if editing existing item
            if (existingItem?.id != null) {
              bloc.add(LoadItemAddonAttachmentsEvent(existingItem!.id!));
            }

            return bloc;
          },
        ),
      ],
      child: const _MenuItemWizardView(),
    );
  }
}

class _MenuItemWizardView extends StatefulWidget {
  const _MenuItemWizardView();

  @override
  State<_MenuItemWizardView> createState() => _MenuItemWizardViewState();
}

class _MenuItemWizardViewState extends State<_MenuItemWizardView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuEditBloc, MenuEditState>(
      listener: (context, state) {
        // Handle save success
        if (state.status == MenuEditStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu item saved successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(state.item);
        }

        // Handle save error
        if (state.status == MenuEditStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.errorMessage}'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              state.item.id != null ? 'Edit Menu Item' : 'New Menu Item',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Save draft button
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save as Draft',
                onPressed: state.status == MenuEditStatus.saving
                    ? null
                    : () => context.read<MenuEditBloc>().add(SaveDraft()),
              ),

              // Close button
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: () => _handleClose(context, state),
              ),
            ],
          ),
          body: Column(
            children: [
              // Wizard stepper
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                child: WizardStepper(
                  currentStep: state.currentStep,
                  onStepTap: (step) {
                    context.read<MenuEditBloc>().add(NavigateToStep(step));
                  },
                ),
              ),

              // Main content area
              Expanded(
                child: Row(
                  children: [
                    // Left content - step screens
                    Expanded(
                      child: Column(
                        children: [
                          // Navigation bar with step title
                          WizardNavBar(
                            currentStep: state.currentStep,
                            stepTitle: _getStepTitle(state.currentStep),
                            stepDescription: _getStepDescription(
                              state.currentStep,
                            ),
                            onBack: state.currentStep > 1
                                ? () {
                                    final newStep = state.currentStep - 1;
                                    context.read<MenuEditBloc>().add(
                                      NavigateToStep(newStep),
                                    );
                                  }
                                : null,
                            onNext: () {
                              final newStep = state.currentStep + 1;
                              context.read<MenuEditBloc>().add(
                                NavigateToStep(newStep),
                              );
                            },
                            onSave: () =>
                                context.read<MenuEditBloc>().add(SaveItem()),
                            canProceed:
                                state.validation.isValid ||
                                state.currentStep < 5,
                            isSaving: state.status == MenuEditStatus.saving,
                          ),

                          // Step content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: _buildStepContent(state.currentStep),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right sidebar - summary
                    SummarySidebar(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return const Step1ItemDetails();
      case 2:
        return const Step2SizesAddOns();
      case 3:
        return const Step3Upsells();
      case 4:
        return const Step4Availability();
      case 5:
        return const Step5Review();
      default:
        return const SizedBox();
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Item Details';
      case 2:
        return 'Sizes & Add-ons';
      case 3:
        return 'Upsells & Suggestions';
      case 4:
        return 'Availability & Settings';
      case 5:
        return 'Review & Save';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 1:
        return 'Set basic information and category';
      case 2:
        return 'Configure sizes and add-on categories';
      case 3:
        return 'Add related items and recommendations';
      case 4:
        return 'Set channel availability and options';
      case 5:
        return 'Review all details before saving';
      default:
        return '';
    }
  }

  void _handleClose(BuildContext context, MenuEditState state) {
    if (state.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to save as draft before closing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<MenuEditBloc>().add(SaveDraft());
              },
              child: const Text('Save Draft'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Continue Editing'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
