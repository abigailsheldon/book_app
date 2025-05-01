import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

/* UI for writing & submitting a review for one book. */


class ReviewScreen extends StatefulWidget {
  final Book book;
  const ReviewScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  String _content = '';
  bool _loading = false;
  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Review: ${widget.book.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            
            // Rating dropdown 1–5
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Rating'),
              value: _rating,
              items: List.generate(5, (i) => i + 1)
                  .map((r) => DropdownMenuItem(value: r, child: Text('$r')))
                  .toList(),
              onChanged: (v) => setState(() => _rating = v!),
            ),
            const SizedBox(height: 16),
            
            // Review text
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Your review',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (v) =>
                  v != null && v.isNotEmpty ? null : 'Enter review text',
              onSaved: (v) => _content = v!,
            ),
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() => _loading = true);
                        final review = Review(
                          id: '', // auto-generated
                          bookId: widget.book.id,
                          reviewerId: userProv.user!.uid,
                          reviewerName: userProv.user!.email ?? '',
                          rating: _rating,
                          content: _content,
                          createdAt: DateTime.now(),
                        );
                        await _fs.addReview(review);
                        setState(() => _loading = false);
                        Navigator.pop(context);
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)
                  : const Text('Submit'),
            ),
          ]),
        ),
      ),
    );
  }
}
