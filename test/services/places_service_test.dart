import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/places_service.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class _NoopAsyncStorage extends GotrueAsyncStorage {
  const _NoopAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.responsePayload);

  List<Map<String, dynamic>> responsePayload;
  final List<http.BaseRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final bodyBytes = Uint8List.fromList(
      utf8.encode(jsonEncode(responsePayload)),
    );

    return http.StreamedResponse(
      Stream.value(bodyBytes),
      200,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingClient recordingClient;
  var responsePayload = <Map<String, dynamic>>[];

  Map<String, dynamic> placeRow({
    required String id,
    required String name,
    required (int, int) pricepp,
  }) {
    return {
      'id': id,
      'name': name,
      'address': 'Main Street 1',
      'profile_picture': 'https://example.com/$id.png',
      'desc': 'Cozy place',
      'pricepp_first': pricepp.$1,
      'pricepp_second': pricepp.$2,
      'menu': {'groups': []},
      'category': 'cafe',
      'phone_number': '+48123123123',
      'email_address': 'contact@example.com',
      'url_link': null,
      'ig_link': null,
      'fb_link': null,
      'coordinates_first': 52.1,
      'coordinates_second': 21.0,
      'location': 'Warsaw',
      'is_active': true,
      'paid_until': null,
      'rate': 4.5,
      'owner_id': 'owner-1',
      'is_new': false,
      'tags': ['board_games'],
      'date_props': [],
    };
  }

  setUpAll(() async {
    recordingClient = _RecordingClient(responsePayload);

    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'test-anon-key',
      httpClient: recordingClient,
      authOptions: FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: _NoopAsyncStorage(),
      ),
    );
  });

  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  setUp(() {
    responsePayload = [
      placeRow(id: 'place-1', name: 'Cafe Luna', pricepp: (20, 40)),
      placeRow(id: 'place-2', name: 'Bistro Sol', pricepp: (50, 100)),
    ];
    recordingClient.responsePayload = responsePayload;
    recordingClient.requests.clear();
  });

  testWidgets('fetches places ordered by price descending', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );

    final context = tester.element(find.byType(SizedBox));
    final service = PlacesServiceSupabase();
    final filter =
        FilterViewModel()
          ..setOrderBy('price', notify: false)
          ..setSortAsc(false, notify: false);

    final response = await service.fetchFilteredPlaces(
      filter: filter,
      context: context,
      pageSize: 20,
      pageNumber: 2,
    );

    expect(response, isA<FetchListSuccess<Place>>());
    final items = (response as FetchListSuccess<Place>).items;
    expect(items, hasLength(2));
    expect(items[0].name, 'Cafe Luna');

    expect(recordingClient.requests, hasLength(1));
    final requestUri = recordingClient.requests[0].url.toString();
    expect(requestUri, contains('/rest/v1/places_tags_agg'));
    expect(requestUri, contains('pricepp_first.desc'));
    expect(requestUri, contains('offset=20'));
  });
}
