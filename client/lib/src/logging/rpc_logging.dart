import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:protobuf/protobuf.dart';

import 'app_log.dart';

class RpcLoggingInterceptor extends ClientInterceptor {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final context = '${method.path}${requestLogContext(request)}';
    final timer = Stopwatch()..start();
    AppLog.info('rpc.start $context');
    try {
      final response = invoker(method, request, options);
      unawaited(
        response.then<void>(
          (_) => AppLog.info(
            'rpc.complete $context code=0 elapsed_ms=${timer.elapsedMilliseconds}',
          ),
          onError: (Object error, StackTrace stack) {
            AppLog.failure(
              'rpc.complete $context elapsed_ms=${timer.elapsedMilliseconds}',
              error,
            );
          },
        ),
      );
      return response;
    } catch (error) {
      AppLog.failure('rpc.start $context', error);
      rethrow;
    }
  }
}

String requestLogContext(Object? request) {
  if (request is! GeneratedMessage) return '';
  final fields = <String>[];
  for (final name in [
    'requestId',
    'expectedVersion',
    'roomId',
    'gameSessionId',
    'lastSeenSeq',
  ]) {
    final field = request.info_.byName[name];
    if (field == null) continue;
    final value = request.getField(field.tagNumber);
    if (value == null || value.toString().isEmpty) continue;
    final safe = value.toString().replaceAll(RegExp(r'[^a-zA-Z0-9_.:-]'), '_');
    fields.add('$name=${safe.length > 128 ? safe.substring(0, 128) : safe}');
  }
  return fields.isEmpty ? '' : ' ${fields.join(' ')}';
}
