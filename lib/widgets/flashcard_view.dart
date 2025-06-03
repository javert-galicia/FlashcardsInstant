import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardView extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onDelete;

  const FlashcardView({
    super.key,
    required this.flashcard,
    this.onDelete,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  bool _showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _flipAnimation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showAnswer) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Card(
              elevation: 8,              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: GestureDetector(
                onTap: _toggleCard,                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {                      final isFlipped = _flipAnimation.value >= 0.5;
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(3.14159 * _flipAnimation.value);
                      
                      if (isFlipped) {
                        transform.rotateY(3.14159);
                      }
                      
                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                        child: Card(
                          color: isFlipped ?
                            Theme.of(context).colorScheme.primaryContainer :
                            Theme.of(context).colorScheme.surface,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: Text(
                              isFlipped ? widget.flashcard.answer : widget.flashcard.question,                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: isFlipped ?
                                  Theme.of(context).colorScheme.onPrimaryContainer :
                                  Theme.of(context).colorScheme.onSurface,
                                fontSize: 32,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (widget.onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: _toggleCard,
          icon: Icon(
            _showAnswer ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: Text(
            _showAnswer ? 'Ocultar Respuesta' : 'Mostrar Respuesta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
