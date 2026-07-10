# API Client Architecture Plan

## Overview
Organize the backend API (OpenAPI 3.0) into a clean, typed Flutter client layer with Dio, interceptors, data models, and service classes grouped by domain module.

## TODOs

1. [x] Create Dio client configuration with base URL, interceptors (auth token, logging, error handling)
2. [x] Create API data models (DTOs) from OpenAPI schemas using freezed + json_serializable
3. [x] Create Auth API service (wechat login, refresh token, logout)
4. [x] Create Notes API service (CRUD, publish, archive, media, share)
5. [x] Create Categories API service (tree, CRUD, reorder)
6. [x] Create Tags API service (list, create, delete)
7. [x] Create Storage API service (upload token, upload, delete)
8. [x] Create Wechat API service (callback verification, message receive)
9. [x] Create API response wrapper and error handling types
10. [x] Create repository layer abstracting API services for features
11. [x] Verify all files compile with `flutter analyze`

## Final Verification Wave

F1. [x] `flutter analyze` passes with zero issues on all API layer files
F2. [x] All DTOs have correct freezed/json_serializable annotations
F3. [x] API services cover all documented endpoints
F4. [x] Repository layer provides clean abstraction for feature modules

## Success Criteria
- [x] Dio client handles JWT auth automatically via interceptor
- [x] All API endpoints have typed request/response models
- [x] Error handling converts HTTP errors to domain exceptions
- [x] Repository layer is ready for Riverpod providers to consume
