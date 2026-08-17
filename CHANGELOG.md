## 0.1.3

- Merge Flutter widgets into this package — one dependency for API client and UI lists.
- Remove separate `manatal_flutter` package.

## 0.1.2

- Send `X-Manatal-SDK`, `X-Manatal-SDK-Version`, and `X-Manatal-SDK-Language` on every request for server-side analytics.

## 0.1.1

- Return `ManatalObject` responses with property access (`job.id`) and map access (`job['id']`).
- Public docs no longer mention internal pacing or API limit details.

## 0.1.0

- Initial release: Manatal Open API v3 client for Dart/Flutter.
- Token auth, pagination, retries, and core resources.
