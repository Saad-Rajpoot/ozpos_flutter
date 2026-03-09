# OzPOS Flutter — Current Status

## 1. Feature Status Table

| PRD Area | Feature | Status | Notes |
|----------|---------|--------|------|
| **A. POS & Ordering** | Menu grid, categories, search, modifiers | ✅ Implemented | MenuBloc, modifier modal, categories |
| | Cart pane (notes, upsells, discounts, tips) | ✅ Implemented | CartBloc, cart_pane, discount_section |
| | Checkout (cash, card, split, pay later, voucher, loyalty) | ✅ Implemented | CheckoutBloc, payment options, split tenders |
| | Split bill (by person/item/equal/custom) | ⚠️ Partial | Split payment in checkout; tables screen has “Split Bill” dialog but full drag-assign/per-split reconcile not fully aligned with PRD |
| **B. Loyalty** | Customer link/lookup, points, earn/redeem | ⚠️ Partial | Redeem in checkout; customer display loyalty; no dedicated loyalty API use case or balance/preview from server |
| **C. Table Management** | Move/Merge, zone/level, table sessions | ✅ Implemented | Move table screen, merge; table sessions present |
| **D. Order History** | Unified order cards, source badges, tabs | ⚠️ Partial | Orders screen, order cards, payment status; third-party source badges/tabs may be partial |
| **E. Printer Management** | Dashboard, role/routing, Test Print | ✅ Implemented | Printing module, add/edit, test print |
| **F. Menu Editing** | Category rail, inline edits, Item Wizard, Pricing Matrix | ⚠️ Partial | Menu editor, item wizard exist; pricing matrix and reusable add-on sets per PRD need verification |
| **G. Delivery/Driver** | Orders panel tabs, Driver panel, third-party adapter | ⚠️ Partial | Delivery screen, drivers; UberDirect/adapter behind feature flag not verified in code |
| **H. Reservations** | Lists, smart suggestions, statuses, table integration | ⚠️ Partial | Lists, form; statuses only pending/confirmed/seated/cancelled (missing Early, Late, No-show, Completed) |
| **I. Reporting** | KPIs, trends, funnel, export | ⚠️ Partial | Reports screen, KPI cards, payment methods; export PDF/XLS may be stub |
| **J. Settings** | System/User/Operations/Customization, Stripe read-only | ⚠️ Partial | Settings screen; Stripe Connect onboarding/status read-only not found in client |
| **—** | Offline read-through + write-behind outbox | ❌ Not implemented | No ETag, no outbox, no idempotency keys |
| **—** | Payments (Stripe Connect server-driven) | ❌ Not implemented | SimulatedPaymentProcessor only; no Stripe in client |
| **—** | KDS ticket lanes | ⚠️ Partial | Docket designer for templates; no dedicated KDS lanes UI |

**Legend:** ✅ Implemented | ⚠️ Partial | ❌ Not implemented

---

## 2. JSON Rules Status (json_rules.md)

| Rule | Status | Notes |
|------|--------|------|
| Feature structure (data/domain/presentation) | ✅ Followed | Features use data/datasources, models, repositories; domain entities, usecases; presentation bloc, screens, widgets |
| Entity: extend Equatable | ✅ Mostly | Entities checked use Equatable |
| Model: fromJson, toJson, toEntity, fromEntity, copyWith | ✅ Mostly | Models across features follow this pattern |
| Data sources: Remote + Mock + Local | ⚠️ Inconsistent | Many features have remote + mock; **local** exists for: menu, tables, orders, delivery, reports, addons, combos, customer_display, checkout, reservations, settings. **Users** (and possibly auth) have no local datasource |
| Repository: implement domain interface, return entities | ✅ Followed | RepositoryImpl pattern used |
| Use case: single responsibility, Either&lt;Failure, T&gt; | ✅ Followed | Dartz Either used in use cases |
| BLoC: loading/success/error | ✅ Followed | Blocs extend BaseBloc, handle loading/error |
| DI: register in injection_container / modules | ✅ Followed | CoreModule + feature modules (menu, cart, checkout, combo, addon, table, reservation, report, order, delivery, printing, settings, customer_display, user) |
| API endpoints in app_constants | ✅ Followed | Endpoints defined |
| File naming (snake_case), class (PascalCase) | ✅ Followed | Consistent with json_rules |

**Gaps:**  
- **Local datasource “REQUIRED”** in json_rules is not satisfied for **users** (and possibly others).  
- Some features use **Bloc** directly; json_rules mention BaseBloc—alignment is fine but not every bloc may extend a shared base.

---

## 3. Checklist Audit Summary (LIVING_CHECKLIST.md)

### Section 0 — Objectives (v1)

| Item | Status |
|------|--------|
| Cross-platform Flutter >90% shared code | ✅ Assumed (single codebase) |
| Plugin-light, cross-platform packages | ✅ |
| Offline read-through cache + write-behind outbox | ❌ Not implemented |
| Payments server-driven Stripe Connect; no client fee math | ❌ Client uses SimulatedPaymentProcessor |
| Unified error envelope, Sentry parity, redaction | ⚠️ Sentry present; unified envelope partial |
| FormRequest + OpenAPI for new/changed endpoints | N/A client | Backend concern |

### Section 1 — Golden Rules

| Item | Status |
|------|--------|
| No secrets in client/repo; .env / keychains | ✅ Tokens in secure storage; baseUrl from config |
| Sanctum tokens in secure storage; never logged | ✅ |
| Respect server state machines; client never force-transitions | ⚠️ Assumed; not fully audited |
| Server source of truth for pricing/fees/taxes/loyalty | ⚠️ Client has local calculation; server alignment TBD |
| Additive DB migrations only | ⚠️ Client DB (database_helper) — no formal migration system seen |
| Security headers middleware | N/A client |
| User-facing errors → standardized envelope | ⚠️ Partial |

### Section 2 — Pre-Commit / Pre-PR

| Item | Status |
|------|--------|
| PHP pint, Pest, PHPStan | N/A (Flutter-only repo) |
| Flutter analyze, test, golden | ⚠️ Only one test file (widget_test.dart) |
| OpenAPI updated, Postman regenerated | N/A client |
| New env vars in README/example.env | N/A client |
| Sentry tags (vendor_id, user_role, order_id, etc.) | ⚠️ SentryService has some tags; full set not verified |
| Accessibility (labels, keyboard/focus) | ⚠️ Not audited |

### Sections 4–13 (Feature & Quality)

| Section | Summary |
|---------|---------|
| **4. Offline & Sync** | ❌ ETag/watermark, outbox, idempotency, conflict policy, simulated offline tests — none found |
| **5. Printing** | ✅ LAN ESC/POS, OS fallback, category routing, Test Print; no sensitive data on docket (assumed) |
| **6. Payments (Stripe)** | ❌ Client does not delegate to backend Stripe; refunds/voids, webhooks, Connect onboarding — backend only / not in client |
| **7. Reservations & Tables** | ⚠️ Overlap warnings/suggestions, status set (Early/Late/No-show/Completed missing), move/merge, reconciliation — partial |
| **8. Delivery & Dispatch** | ⚠️ Orders tabs, driver panel; third-party adapter/UberDirect, geofencing — partial or not found |
| **9. Menu Editing & Pricing Matrix** | ⚠️ Add-on sets, per-item/size overrides, bulk/duplicate, POS/Online toggles — partial |
| **10. Reporting** | ⚠️ KPI/trends/funnel; export PDF/XLS — partial |
| **11. Performance Budgets** | ❌ Not measured (95th %ile, 2k items load test) |
| **12. Security Gates** | ⚠️ Rate limits, CORS, CSRF — backend; client has cert pinning, secure storage |
| **13–14. Release / Rollback** | ⚠️ Version/changelog, feature flags, rollback — not fully documented in repo |

---

## 4. PRD vs Implementation (Selected)

| PRD Requirement | Implementation |
|-----------------|----------------|
| Single Flutter codebase Web/iOS/Android/Windows | ✅ Single app |
| Offline: read-through cache + write-behind outbox | ❌ Not present |
| Payments & payouts server-driven (Stripe Connect) | ❌ Simulated only |
| Unified error envelope + Sentry | ⚠️ Sentry yes; envelope partial |
| State: Riverpod or Bloc | ✅ BLoC |
| Routing: GoRouter | ❌ Custom AppRouter |
| Storage: Isar/Drift + Hive | ❌ SQLite + SharedPreferences |
| Realtime: Laravel Echo/SSE | ❌ Not seen in client |
| API contracts (FormRequest, OpenAPI) | Backend; client uses AppConstants endpoints |

---

## 5. LIVING_CHECKLIST vs Reality

- **Items marked [ ] (unchecked)** in LIVING_CHECKLIST correctly reflect that **offline, Stripe, full reservation statuses, and several DoD items are not done**.
- **No items are ticked** in the checklist; many can remain unchecked until offline, Stripe integration, and tests are added.
- **Suggested corrections:**  
  - Add an explicit “Client: Stripe not integrated (simulated payment only).”  
  - Add “Client: Offline outbox/ETag not implemented.”  
  - Reservation status enum: document gap (Early, Late, No-show, Completed) in entity vs PRD.

---

## 6. json_rules.md vs Code

- **Aligned:** Feature folders, entity/model/repository/use case/BLoC patterns, DI, naming, API constants.
- **Gaps:**  
  - **Local datasource** required for every feature in json_rules — **users** (and any other feature without local) should get a local datasource or the rule should be relaxed.  
  - **BaseBloc** is used in some places; ensure all feature blocs that should follow json_rules extend it where applicable.
