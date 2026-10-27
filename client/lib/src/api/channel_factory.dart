import 'package:grpc/grpc.dart';

import 'channel_factory_stub.dart'
    if (dart.library.html) 'channel_factory_web.dart' as implementation;

ClientChannel createClientChannel(Uri endpoint) =>
    implementation.createClientChannel(endpoint);
