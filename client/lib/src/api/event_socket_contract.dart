abstract interface class EventSocket {
  Stream<String> get messages;
  Future<void> close();
}
