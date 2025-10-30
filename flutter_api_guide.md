# Flutter Integration Guide for lasotuvi FastAPI Backend

## Backend Overview
- Base URL (local development): `http://127.0.0.1:8000`
- Endpoints:
  - `POST /charts`: Generate a new chart and persist it.
  - `GET /charts/{id}`: Retrieve a chart by ID.
  - `GET /charts?limit=20`: List recent charts.

## Example Payload (`POST /charts`)
```json
{
  "day": 24,
  "month": 10,
  "year": 1991,
  "hour_branch": 7,
  "gender": 1,
  "name": "Test User",
  "solar_calendar": true,
  "timezone": 7
}
```
- `gender`: `1` for male, `-1` for female.
- `hour_branch`: 1–12 (traditional Earthly Branch indices).

## Flutter HTTP Client Example
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'http://127.0.0.1:8000';

Future<Map<String, dynamic>> createChart() async {
  final response = await http.post(
    Uri.parse('$baseUrl/charts'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'day': 24,
      'month': 10,
      'year': 1991,
      'hour_branch': 7,
      'gender': 1,
      'name': 'Test User',
      'solar_calendar': true,
      'timezone': 7,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create chart: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> fetchChart(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/charts/$id'));

  if (response.statusCode != 200) {
    throw Exception('Chart not found: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<List<dynamic>> listCharts({int limit = 20}) async {
  final response = await http.get(Uri.parse('$baseUrl/charts?limit=$limit'));

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch chart list: ${response.body}');
  }

  return jsonDecode(response.body) as List<dynamic>;
}
```

## Common Issues
- Ensure the backend is running: use `python -m uvicorn lasotuvi.api.main:app --reload`.
- Verify mobile emulator/device can access host machine; replace `127.0.0.1` with host IP if needed.
- Endpoint paths must match the backend (`/charts`, not `/tu-vi/calculate`).
