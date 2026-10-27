import 'package:grpc/grpc.dart';

ClientChannel createClientChannel(Uri endpoint) {
  final credentials = endpoint.scheme == 'https'
      ? const ChannelCredentials.secure()
      : const ChannelCredentials.insecure();
  return ClientChannel(
    endpoint.host,
    port: endpoint.hasPort
        ? endpoint.port
        : endpoint.scheme == 'https'
        ? 443
        : 80,
    options: ChannelOptions(credentials: credentials),
  );
}
