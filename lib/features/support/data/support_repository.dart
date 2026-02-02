import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/features/support/domain/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(Supabase.instance.client);
});

class SupportRepository {
  final SupabaseClient _supabase;

  SupportRepository(this._supabase);

  Future<void> createTicket({
    required String subject,
    required String message,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('support_tickets').insert({
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': 'open',
      'channel': 'in-app',
    });
  }

  Future<List<SupportTicket>> getUserTickets() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('support_tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SupportTicket.fromJson(json))
        .toList();
  }

  Stream<List<SupportTicket>> watchUserTickets() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    return _supabase
        .from('support_tickets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SupportTicket.fromJson(json)).toList());
  }
}
