import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/scryfall_image_service.dart';

class CardImageDialog extends StatelessWidget {
  final String cardName;

  const CardImageDialog({super.key, required this.cardName});

  static void show(BuildContext context, String cardName) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => CardImageDialog(cardName: cardName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ScryfallImageService.imageUrlFromName(cardName);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () {},
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: 488.0 / 680.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => AspectRatio(
                  aspectRatio: 488.0 / 680.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image_outlined,
                            size: 48, color: Colors.white38),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            cardName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Image not available',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
