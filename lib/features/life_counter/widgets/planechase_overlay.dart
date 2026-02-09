import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/scryfall_image_service.dart';
import '../models/planechase_model.dart';
import '../providers/planechase_provider.dart';

class PlanechaseOverlay extends ConsumerStatefulWidget {
  const PlanechaseOverlay({super.key});

  @override
  ConsumerState<PlanechaseOverlay> createState() => _PlanechaseOverlayState();
}

class _PlanechaseOverlayState extends ConsumerState<PlanechaseOverlay> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final pcState = ref.read(planechaseProvider);
    if (!pcState.isInitialized) {
      ref.read(planechaseProvider.notifier).initializeDeck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pcState = ref.watch(planechaseProvider);

    if (!pcState.isInitialized) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _expanded ? 320 : 56,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(
              top: BorderSide(
                color: _dieResultColor(pcState.lastDieRoll).withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header bar (always visible)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: Colors.purple.shade200,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pcState.currentPlane?.name ?? 'No plane',
                        style: TextStyle(
                          color: Colors.purple.shade100,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Die roll button
                    _PlanarDieButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(planechaseProvider.notifier).rollPlanarDie();
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ],
                ),
              ),
              // Expanded content
              if (_expanded) ...[
                const Divider(height: 1, color: Colors.white12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Plane card image
                        if (pcState.currentPlane != null)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Transform.rotate(
                                angle: math.pi / 2,
                                child: CachedNetworkImage(
                                imageUrl: ScryfallImageService.imageUrlFromName(
                                    pcState.currentPlane!.name),
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.purple.shade200,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        pcState.currentPlane!.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade100,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pcState.currentPlane!.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade100,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pcState.currentPlane!.typeLine,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.5),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Last die result
                        if (pcState.lastDieRoll != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: _dieResultColor(pcState.lastDieRoll)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _dieResultColor(pcState.lastDieRoll)
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _dieResultText(pcState.lastDieRoll!),
                              style: TextStyle(
                                color: _dieResultColor(pcState.lastDieRoll),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ref
                                    .read(planechaseProvider.notifier)
                                    .planeswalk();
                              },
                              icon: const Icon(Icons.flight_takeoff, size: 16),
                              label: const Text('Planeswalk'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple.shade200,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(planechaseProvider.notifier)
                                    .reshuffleDeck();
                              },
                              icon: const Icon(Icons.shuffle, size: 16),
                              label: const Text('Reshuffle'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        // Deck info
                        Text(
                          '${pcState.deck.length} in deck \u2022 ${pcState.discard.length} discarded',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _dieResultColor(PlanarDieResult? result) {
    switch (result) {
      case PlanarDieResult.planeswalk:
        return Colors.blue.shade300;
      case PlanarDieResult.chaos:
        return Colors.red.shade300;
      case PlanarDieResult.blank:
      case null:
        return Colors.white38;
    }
  }

  String _dieResultText(PlanarDieResult result) {
    switch (result) {
      case PlanarDieResult.planeswalk:
        return 'PLANESWALK';
      case PlanarDieResult.chaos:
        return 'CHAOS';
      case PlanarDieResult.blank:
        return 'BLANK';
    }
  }
}

class _PlanarDieButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlanarDieButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino, size: 14, color: Colors.purple.shade200),
            const SizedBox(width: 4),
            Text(
              'Roll',
              style: TextStyle(
                color: Colors.purple.shade200,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
