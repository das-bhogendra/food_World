# TODO - Fix Order Status Validation Issue

## Issue
Backend returns error: "Order validation failed: status: `complete` is not a valid enum value for path `status`."

## Root Cause
User types "complete" (without 'd') but backend expects "completed" (with 'd').

## Plan

### Step 1: Add "completed" status to OrderStatusConstants
- [x] Add completed status in lib/features/order/domain/entities/order_entity.dart
- [x] Add auto-correction for "complete" -> "completed"

### Step 2: Fix admin_fooditems_pages_test.dart
- [x] Fix overrideWith parameter error (ref) -> ()

### Step 3: Fix Order Usecase Tests
- [x] Add registerFallbackValue for OrderEntity in create_order_usecase_test.dart
- [x] Add registerFallbackValue for OrderEntity in update_order_usecase_test.dart

## Changes Made

### 1. order_entity.dart
- Added `completed` to validStatuses list
- Added auto-correction for "complete" -> "completed" in normalizeStatus function

### 2. admin_fooditems_pages_test.dart
- Using `overrideWithValue(mockRepository)` correctly for ProviderContainer

### 3. create_order_usecase_test.dart
- Added FakeOrderEntity class
- Added registerFallbackValue(FakeOrderEntity()) in setUpAll

### 4. update_order_usecase_test.dart
- Added FakeOrderEntity class
- Added registerFallbackValue(FakeOrderEntity()) in setUpAll

## Test Results
✅ All tests passing:
- create_order_usecase_test.dart: 2 tests passed
- update_order_usecase_test.dart: 2 tests passed  
- admin_fooditems_pages_test.dart: 2 tests passed

### Current Status: COMPLETED ✅
