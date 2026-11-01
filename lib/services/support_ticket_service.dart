import 'package:flutter/material.dart';
import '../core/network/api_service.dart';
import '../models/support_request_model.dart';
import '../models/remote_session_model.dart';
import 'mock_data_service.dart';

class SupportTicketService extends ChangeNotifier {
  static final SupportTicketService _instance = SupportTicketService._internal();
  factory SupportTicketService() => _instance;
  SupportTicketService._internal();

  List<SupportRequestModel> _tickets = [];
  bool _isLoading = false;

  List<SupportRequestModel> get tickets => _tickets;
  bool get isLoading => _isLoading;

  Future<void> fetchTickets() async {
    _isLoading = true;
    notifyListeners();
    _tickets = await ApiService().getSupportRequests();
    _isLoading = false;
    notifyListeners();
  }

  // Employee creates new ticket
  Future<bool> createTicket({
    required int employeeId,
    required String employeeName,
    required int deviceId,
    required String deviceName,
    required String vynexId,
    required String title,
    String? description,
    String priority = 'normal',
  }) async {
    final newId = 100 + MockDataService().supportRequests.length + 1;
    final ticket = SupportRequestModel(
      requestId: newId,
      employeeId: employeeId,
      employeeName: employeeName,
      deviceId: deviceId,
      deviceName: deviceName,
      vynexId: vynexId,
      title: title,
      description: description,
      priority: priority,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await ApiService().createSupportRequest(ticket);
    await fetchTickets();
    return success;
  }

  // IT Staff accepts ticket
  Future<bool> acceptTicket(int requestId, int itId, String itName) async {
    final idx = _tickets.indexWhere((t) => t.requestId == requestId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: 'accepted',
        assignedItId: itId,
        assignedItName: itName,
        acceptedAt: DateTime.now(),
      );
      // Synchronize in mock data
      final mockIdx = MockDataService().supportRequests.indexWhere((t) => t.requestId == requestId);
      if (mockIdx != -1) {
        MockDataService().supportRequests[mockIdx] = _tickets[idx];
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // IT Staff rejects ticket
  Future<bool> rejectTicket(int requestId, String reason) async {
    final idx = _tickets.indexWhere((t) => t.requestId == requestId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: 'rejected',
        feedback: 'Lý do từ chối: $reason',
      );
      final mockIdx = MockDataService().supportRequests.indexWhere((t) => t.requestId == requestId);
      if (mockIdx != -1) {
        MockDataService().supportRequests[mockIdx] = _tickets[idx];
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Start remote session
  Future<RemoteSessionModel> startSession({
    required SupportRequestModel ticket,
    required int itUserId,
    required String itName,
  }) async {
    final idx = _tickets.indexWhere((t) => t.requestId == ticket.requestId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(status: 'in_progress');
      notifyListeners();
    }

    final newSession = RemoteSessionModel(
      sessionId: 500 + MockDataService().sessions.length + 1,
      requestId: ticket.requestId,
      itUserId: itUserId,
      itName: itName,
      targetUserId: ticket.employeeId,
      targetName: ticket.employeeName,
      deviceId: ticket.deviceId,
      deviceName: ticket.deviceName,
      vynexId: ticket.vynexId,
      connectionType: 'direct',
      itIpAddress: '192.168.1.102',
      startedAt: DateTime.now(),
      status: 'started',
    );

    await ApiService().logSession(newSession);
    return newSession;
  }

  // Complete ticket & session
  Future<bool> completeSession({
    required int requestId,
    required int sessionId,
    String? sessionNotes,
    int qualityScore = 5,
  }) async {
    final now = DateTime.now();
    // Update ticket
    final idx = _tickets.indexWhere((t) => t.requestId == requestId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: 'completed',
        completedAt: now,
      );
      final mockIdx = MockDataService().supportRequests.indexWhere((t) => t.requestId == requestId);
      if (mockIdx != -1) {
        MockDataService().supportRequests[mockIdx] = _tickets[idx];
      }
    }

    // Update session
    final sessIdx = MockDataService().sessions.indexWhere((s) => s.sessionId == sessionId);
    if (sessIdx != -1) {
      final s = MockDataService().sessions[sessIdx];
      MockDataService().sessions[sessIdx] = RemoteSessionModel(
        sessionId: s.sessionId,
        requestId: s.requestId,
        itUserId: s.itUserId,
        itName: s.itName,
        targetUserId: s.targetUserId,
        targetName: s.targetName,
        deviceId: s.deviceId,
        deviceName: s.deviceName,
        vynexId: s.vynexId,
        connectionType: s.connectionType,
        qualityScore: qualityScore,
        itIpAddress: s.itIpAddress,
        notes: sessionNotes,
        startedAt: s.startedAt,
        endedAt: now,
        durationSeconds: now.difference(s.startedAt).inSeconds,
        status: 'ended',
      );
    }

    notifyListeners();
    return true;
  }

  // Employee rates ticket
  Future<bool> rateTicket(int requestId, int rating, String feedback) async {
    final idx = _tickets.indexWhere((t) => t.requestId == requestId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        rating: rating,
        feedback: feedback,
      );
      final mockIdx = MockDataService().supportRequests.indexWhere((t) => t.requestId == requestId);
      if (mockIdx != -1) {
        MockDataService().supportRequests[mockIdx] = _tickets[idx];
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}
