# TODO - Fix Order Status Validation Issue

## Issue
Backend returns error: "Order validation failed: status: `complete` is not a valid enum value for path `status`."

## Root Cause
User types "complete" (without 'd') but backend expects "completed" (with 'd').

## Plan

### Step 1: Add valid order status constants
- [ ] Add OrderStatusConstants class in lib/features/order/domain/entities/order_entity.dart

### Step 2: Update order_detail_pages.dart
- [ ] Add validation for status input in order_detail_pages.dart
- [ ] Auto-correct "complete" -> "completed"
- [ ] Show error for invalid status values
