abstract interface class LogSink {
  void write(String line);
  void close();
}
