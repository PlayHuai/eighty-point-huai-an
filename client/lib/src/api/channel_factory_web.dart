import 'package:grpc/grpc_web.dart';

GrpcWebClientChannel createClientChannel(Uri endpoint) =>
    GrpcWebClientChannel.xhr(endpoint);
