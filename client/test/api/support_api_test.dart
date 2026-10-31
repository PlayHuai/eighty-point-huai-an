@TestOn('vm')
library;

import 'package:eighty_point_huai_an/src/api/api_client.dart';
import 'package:eighty_point_huai_an/src/generated/huai/v1/api.pbgrpc.dart'
    as proto;
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';

void main() {
  test(
    'support client sends authenticated generated Protobuf requests',
    () async {
      final service = _SupportService();
      final server = Server.create(services: [service]);
      await server.serve(address: '127.0.0.1', port: 0);
      final client = GrpcApiClient(
        Uri.parse('http://127.0.0.1:${server.port}'),
      );
      addTearDown(() async {
        await client.close();
        await server.shutdown();
      });
      final info = await client.getServerInfo(accessToken: 'test-token');
      expect(info.version, '1.2.3');
      expect(info.commitId, 'abc123');
      expect(info.changelist, '# 更新记录\n- 新增反馈');
      await client.submitFeedback(
        accessToken: 'test-token',
        kind: proto.FeedbackKind.FEEDBACK_KIND_BUG,
        body: '反馈内容',
        requestId: '00000000-0000-4000-8000-000000000001',
      );
      expect(service.authorization, ['Bearer test-token', 'Bearer test-token']);
      expect(service.request?.kind, proto.FeedbackKind.FEEDBACK_KIND_BUG);
      expect(service.request?.body, '反馈内容');
      expect(
        service.request?.requestId,
        '00000000-0000-4000-8000-000000000001',
      );
      service.failure = true;
      await expectLater(
        client.getServerInfo(accessToken: 'test-token'),
        throwsA(isA<GrpcError>()),
      );
    },
  );
}

class _SupportService extends proto.SupportServiceBase {
  final authorization = <String?>[];
  proto.SubmitFeedbackRequest? request;
  bool failure = false;

  @override
  Future<proto.ServerInfo> getServerInfo(
    ServiceCall call,
    proto.Empty request,
  ) async {
    authorization.add(call.clientMetadata?['authorization']);
    if (failure) throw GrpcError.unavailable('offline');
    return proto.ServerInfo(
      version: '1.2.3',
      commitId: 'abc123',
      changelist: '# 更新记录\n- 新增反馈',
    );
  }

  @override
  Future<proto.Empty> submitFeedback(
    ServiceCall call,
    proto.SubmitFeedbackRequest request,
  ) async {
    authorization.add(call.clientMetadata?['authorization']);
    this.request = request;
    return proto.Empty();
  }
}
