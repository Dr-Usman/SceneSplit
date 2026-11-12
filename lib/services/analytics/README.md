# SceneSplit Analytics Catalog

This directory houses the product telemetry architecture for SceneSplit using [Mixpanel](https://mixpanel.com/).

## Architecture Overview

```
lib/services/analytics/
├── analytics_events.dart   # Canonical string constants & domain-organized catalog
├── analytics_service.dart  # Strongly-typed tracking API, user identification, super properties
└── README.md               # This documentation
```

### Key Principles
1. **Zero Personally Identifiable Information (PII) / Sensitive Content**: We never log receipt notes, item titles, search queries, or personal emails. Categorical metadata (e.g. `split_type`, `format`, `source`, `person_id`) is used instead.
2. **Standardized Currency & Amounts**: All monetary amounts are recorded in integer cents (`amount_cents`) with their associated `currency_code` (e.g. `USD`, `EUR`, `PKR`). This avoids client-side locale dependencies and ensures unambiguous mathematical precision.
3. **Super Properties**: Automatically attached to every single event:
   - `platform`: `ios`, `android`, `macos`, `windows`, `linux`, `web`
   - `locale_code`: Active language setting (e.g. `en`, `es`, `fr`, `de`, `hi`, `ar`, `ja`)

---

## Complete Event Catalog

### 1. App Lifecycle & Onboarding
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [App Opened](#app_opened) | `app_opened` | `platform` | Calculates DAU/MAU, session frequency, and day-N retention cohorts. |
| [Sign Up Completed](#sign_up_completed) | `sign_up_completed` | `user_id`, `name`, `sign_up_method`, `default_currency`, `platform` | Measures onboarding completion and top-of-funnel conversion. |
| [Tab Selected](#tab_selected) | `tab_selected` | `tab` | Tracks navigation traffic distribution across primary app sections. |
| [Language Changed](#language_changed) | `language_changed` | `locale_code`, `previous_locale_code` | Measures localization adoption and helps prioritize translation resources. |
| [Currency Changed](#currency_changed) | `currency_changed` | `currency_code`, `previous_currency_code` | Measures changes to app base currency preference across user regions. |

### 2. Groups / Scenes (CRUD)
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Group Created](#group_created) | `group_created` | `group_id`, `group_name`, `currency_code`, `member_count`, `show_decimals` | Primary activation milestone; tracks scene creation rate and average group size. |
| [Group Edited](#group_edited) | `group_edited` | `group_id`, `group_name`, `currency_code`, `member_count`, `show_decimals` | Tracks modifications to group metadata, currency switches, and member list changes. |
| [Group Deleted](#group_deleted) | `group_deleted` | `group_id`, `group_name` | Measures group churn, cancellation rates, and scene cleanup frequency. |
| [Group Detail Opened](#group_detail_opened) | `group_detail_opened` | `group_id`, `group_name`, `currency_code`, `member_count`, `expense_count`, `settlement_count` | The denominator for every scene-level interaction, and the natural slice for scene size (how many expenses before a scene feels "full"). |
| [Group Form Opened](#group_form_opened) | `group_form_opened` | `mode`, `group_id`, `group_name` | Separates creation intent from edit intent, so `group_form_opened` → `group_created` gives a real creation conversion rate. |

### 3. Expenses & Split (CRUD) & Calculator
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Expense Created](#expense_created) | `expense_created` | `group_id`, `group_name`, `split_type`, `paid_by_mode`, `amount_cents`, `currency_code`, `member_count` | Core value delivery; reveals split mode preferences, expense sizes, and multi-payer bill frequency. |
| [Expense Edited](#expense_edited) | `expense_edited` | `group_id`, `group_name`, `split_type`, `paid_by_mode`, `amount_cents`, `currency_code`, `member_count` | Measures error corrections, split rebalancing, and post-creation bill updates. |
| [Expense Deleted](#expense_deleted) | `expense_deleted` | `group_id`, `group_name`, `amount_cents`, `currency_code` | Captures transaction cancellation rates and mistakenly logged expenses. |
| [Calculator Used](#calculator_used) | `calculator_used` | `group_id`, `group_name` | Validates adoption of the in-app bill calculator keypad over external apps. |
| [Expenses Shared](#expenses_shared) | `expenses_shared` | `expense_count`, `format`, `range`, `platform` | Tracks quick-share usage directly from the expenses list sheet. |
| [Expense Shared](#expense_shared) | `expense_shared` | `group_id`, `group_name`, `expense_id`, `amount_cents`, `currency_code`, `format`, `split_type`, `payer_count`, `participant_count`, `debt_count`, `platform` | Tracks single-expense sharing directly from the Expense Detail screen. |
| [Expense List Expanded](#expense_list_expanded) | `expense_list_expanded` | `group_id`, `group_name`, `expense_count`, `member_count`, `shown_count`, `source` | Measures how far users expand the truncated expense list and whether the initial item cap (5) is too aggressive. |
| [Expense List View All](#expense_list_view_all) | `expense_list_view_all` | `group_id`, `group_name`, `expense_count`, `member_count`, `source` | Compares in-place expansion against navigation to the full expense list, so the two controls can be tuned or merged. |
| [Expense Detail Opened](#expense_detail_opened) | `expense_detail_opened` | `group_id`, `group_name`, `expense_id`, `amount_cents`, `currency_code`, `participant_count`, `source` | Closes the funnel started by `expense_list_expanded` / `expense_list_view_all` — shows which entry point actually leads to a real expense lookup. |
| [Expense Form Opened](#expense_form_opened) | `expense_form_opened` | `group_id`, `group_name`, `mode`, `source` | Captures add/edit intent before the save, exposing form abandonment that `expense_created` can never show. |
| [Member Breakdown Opened](#member_breakdown_opened) | `member_breakdown_opened` | `group_id`, `group_name`, `member_name`, `share_cents`, `expense_count`, `percent` | Measures adoption of the scene breakdown chart and which members' spending users drill into. |

### 4. Settlements (CRUD)
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Settlement Created](#settlement_created) | `settlement_created` | `group_id`, `group_name`, `amount_cents`, `currency_code`, `source`, `had_prefill`, `is_custom_date` | Measures debt closure rates, navigation paths, and custom date adoption. |
| [Settlement Edited](#settlement_edited) | `settlement_edited` | `group_id`, `group_name`, `amount_cents`, `currency_code`, `is_custom_date` | Monitors debt correction rates and date adjustments after settlement. |
| [Settlement Deleted](#settlement_deleted) | `settlement_deleted` | `group_id`, `group_name`, `amount_cents`, `currency_code` | Tracks settlement reversals or accidental debt clearance undo actions. |
| [Settlement Form Opened](#settlement_form_opened) | `settlement_form_opened` | `group_id`, `group_name`, `mode`, `source`, `had_prefill` | Shows how often users start a settlement (and how often it is pre-filled from an open debt) before saving it. |
| [Settlement List Expanded](#settlement_list_expanded) | `settlement_list_expanded` | `group_id`, `group_name`, `settlement_count`, `member_count`, `shown_count`, `source` | Mirrors `expense_list_expanded` for settlements, so list-length pressure can be judged on both lists. |
| [Settlement List View All](#settlement_list_view_all) | `settlement_list_view_all` | `group_id`, `group_name`, `settlement_count`, `member_count`, `source` | Tracks navigation to the full settlement list, the settlement counterpart of `expense_list_view_all`. |

### 5. Scene Reports
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Report Opened](#report_opened) | `report_opened` | `group_id`, `group_name`, `source`, `default_preset`, `expense_count`, `settlement_count` | Measures engagement and discovery of the reporting dashboard across entrypoints. |
| [Report Shared](#report_shared) | `report_shared` | `group_id`, `group_name`, `format`, `range_preset`, `is_single_member`, `selected_member_name`, `expense_count`, `settlement_count`, `platform` | Key viral loop metric; identifies preferred export formats (image vs text) and date filters. |
| [Report Filter Applied](#report_filter_applied) | `report_filter_applied` | `group_id`, `group_name`, `filter_type`, `filter_value` | Shows how deeply users segment report data by member or date ranges. |
| [Report Sort Changed](#report_sort_changed) | `report_sort_changed` | `group_id`, `group_name`, `sort_order` | Captures user consumption preference (chronological vs reverse-chronological). |

### 6. Balances & Debts
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Balance Shared](#balance_shared) | `balance_shared` | `debt_count`, `member_share_count`, `platform` | Measures viral behavior when users broadcast who-owes-whom to group chats. |
| [Balances Pair Opened](#balances_pair_opened) | `balances_pair_opened` | `has_who_filter`, `has_whom_filter`, `currency_count` | Tracks user interest in 1-on-1 pairwise net balance breakdowns across scenes. |
| [Balances Filter Applied](#balances_filter_applied) | `balances_filter_applied` | `who_set`, `whom_set`, `whom_is_you` | Measures multi-party filter usage and validates "Owed to You" shortcut demand. |
| [Balances Filter Cleared](#balances_filter_cleared) | `balances_filter_cleared` | *(None)* | Measures filter reset frequency in the Balances tab. |

### 7. People & Contacts (CRUD)
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Person Created](#person_created) | `person_created` | `source` | Tracks contact expansion channels (group creation, group edit, or profile people screen). |
| [Person Edited](#person_edited) | `person_edited` | `person_id` | Monitors contact name adjustments and profile directory maintenance. |
| [Person Deleted](#person_deleted) | `person_deleted` | `person_id` | Tracks contact deletions and orphan contact pruning frequency. |
| [Person Detail Opened](#person_detail_opened) | `person_detail_opened` | `open_debt_count`, `scene_count`, `is_self` | Shows how often users inspect person-centric balances vs group-centric balances. |
| [Profile Name Updated](#profile_name_updated) | `profile_name_updated` | *(None - PII free)* | Tracks when users update their display name; sets `$name` in Mixpanel People. |

### 8. System, Store & Maintenance
| Event Name | Mixpanel Identifier | Event Properties | Why It’s Useful |
|---|---|---|---|
| [Share App Clicked](#share_app_clicked) | `share_app_clicked` | `platform` | Tracks user intent to share the app via the system share sheet. |
| [Rate App Clicked](#rate_app_clicked) | `rate_app_clicked` | `available`, `platform` | Tracks taps on Rate SceneSplit to open store review listing. |
| [Update Prompted](#update_prompted) | `update_prompted` | `platform` | Tracks flexible Google Play update impressions. |
| [Update Started](#update_started) | `update_started` | `platform` | Measures conversion from update prompt to actual download initiation. |
| [Backup Exported](#backup_exported) | `backup_exported` | `method`, `platform` | Tracks local database export frequency and preferred storage methods. |
| [Backup Imported](#backup_imported) | `backup_imported` | `platform` | Tracks database restore events for device migration or data recovery. |
| [Feedback Initiated](#feedback_initiated) | `feedback_initiated` | `type`, `platform` | Tracks user reachouts via Contact Us, Send Feedback, and Suggest Feature. |
| [Privacy Policy Opened](#privacy_policy_opened) | `privacy_policy_opened` | `platform` | Measures engagement with data protection policies and legal compliance. |
| [Terms of Service Opened](#terms_of_service_opened) | `terms_of_service_opened` | `platform` | Measures user review of legal terms and usage conditions. |
| [More Apps Clicked](#more_apps_clicked) | `more_apps_clicked` | `platform` | Tracks cross-promotional interest and developer portfolio discovery. |

---

## Detailed Event Breakdown

### 1. App Lifecycle & Onboarding

#### `app_opened`
* **Trigger**: Triggered once per app process cold start on app launch.
* **Code Location**: `AnalyticsService.trackAppOpened()` via `analyticsServiceProvider` initialization in [analytics_provider.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/providers/analytics_provider.dart).
* **Properties**:
  * `platform` (`String`): Current OS/platform (`ios`, `android`, etc.).
* **What it does & Why it helps**: Essential baseline metric for calculating Daily Active Users (DAU), Monthly Active Users (MAU), session frequency, and day-N retention cohorts.

#### `sign_up_completed`
* **Trigger**: Fires immediately after the user finishes onboarding and the primary profile is persisted.
* **Code Location**: [onboarding_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/onboarding/onboarding_screen.dart).
* **Properties**:
  * `user_id` (`String`): UUID of the newly generated local device user.
  * `name` (`String`): User's profile display name.
  * `sign_up_method` (`String`): `'local'` (indicates local-first database).
  * `default_currency` (`String`): Chosen currency code (e.g. `USD`, `EUR`, `PKR`).
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Marks the top of the activation funnel. Measures how effectively the onboarding flow converts first-time visitors into active users.

#### `tab_selected`
* **Trigger**: Fired when switching bottom navigation tabs (Scenes, Balances, Profile).
* **Code Location**: [home_scaffold.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/home/home_scaffold.dart).
* **Properties**:
  * `tab` (`String`): `'scenes'`, `'balances'`, or `'profile'`.
* **What it does & Why it helps**: Tracks overall feature discovery and traffic distribution across primary screens.

#### `language_changed`
* **Trigger**: Fired when the user explicitly changes the app language in Profile.
* **Code Location**: [language_picker_sheet.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/widgets/language_picker_sheet.dart).
* **Properties**:
  * `locale_code` (`String`): Newly chosen BCP-47 locale (e.g. `es`, `fr`, `de`, `hi`, `ar`, `ja`).
  * `previous_locale_code` (`String?`): Previous active locale code.
* **What it does & Why it helps**: Shows language adoption and validates internationalization priorities.

#### `currency_changed`
* **Trigger**: Fired when the user selects a new app-wide default currency in Profile.
* **Code Location**: [profile_currency_section.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/widgets/profile_currency_section.dart).
* **Properties**:
  * `currency_code` (`String`): Newly selected ISO currency code (e.g. `USD`, `EUR`, `PKR`).
  * `previous_currency_code` (`String?`): Previously selected currency code.
* **What it does & Why it helps**: Measures changes to global base currency preference and synchronizes user profiles in Mixpanel People.

---

### 2. Groups / Scenes (CRUD)

#### `group_created`
* **Trigger**: Fires when a new Scene / Group is successfully saved.
* **Code Location**: [create_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/create_group_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Title of the created group.
  * `currency_code` (`String`): Group currency code (e.g. `USD`, `GBP`).
  * `member_count` (`int`): Total initial members in the scene (including creator).
  * `show_decimals` (`bool`): Whether fractional cents / decimal formatting is enabled.
* **What it does & Why it helps**: Key activation milestone. Allows tracking whether users create 1-to-1 groups vs large travel/trip scenes, and calculates average group size.

#### `group_edited`
* **Trigger**: Fires when existing Scene details (name, currency, or members) are updated.
* **Code Location**: [edit_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/edit_group_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Updated group title.
  * `currency_code` (`String`): Updated group currency code.
  * `member_count` (`int`): New total member count.
  * `show_decimals` (`bool`): Group decimal display preference.
* **What it does & Why it helps**: Measures post-creation adjustments such as adding members mid-trip or changing default currency.

#### `group_deleted`
* **Trigger**: Fires when a user confirms group deletion from the Scene detail menu.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Title of the deleted group.
* **What it does & Why it helps**: Tracks group churn, abandonment rates, and scene completion lifecycle.

#### `group_detail_opened`
* **Trigger**: Fired once each time the scene detail screen opens and its data loads.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `currency_code` (`String`): Scene currency code.
  * `member_count` (`int`): Number of members in the scene.
  * `expense_count` (`int`): Number of expenses in the scene.
  * `settlement_count` (`int`): Number of settlements in the scene.
* **What it does & Why it helps**: The denominator for every scene-level interaction (expense opens, list expansions, share actions). Because it carries scene size, it also answers "at how many expenses does a scene stop feeling browsable".

#### `group_form_opened`
* **Trigger**: Fired when the create or edit scene form is opened.
* **Code Location**: [create_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/create_group_screen.dart) and [edit_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/edit_group_screen.dart).
* **Properties**:
  * `mode` (`String`): `create` or `edit`.
  * `group_id` (`String?`): Group UUID — null when creating.
  * `group_name` (`String?`): Scene name — null when creating.
* **What it does & Why it helps**: Separates creation intent from edit intent. `group_form_opened` (mode `create`) → `group_created` gives an honest creation conversion rate instead of one inflated by edits.

---

### 3. Expenses & Split (CRUD) & Calculator

#### `expense_created`
* **Trigger**: Fired when a new expense is saved with splits.
* **Code Location**: [add_expense_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/add_expense_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Title of the parent group.
  * `split_type` (`String`): Distribution type (`equal`, `exact`, `percentage`).
  * `paid_by_mode` (`String`): Payment arrangement (`single`, `multiple`).
  * `amount_cents` (`int`): Total expense value stored in integer cents.
  * `currency_code` (`String`): Group currency code (e.g. `USD`, `EUR`, `PKR`).
  * `member_count` (`int`): Number of participants sharing this expense.
* **What it does & Why it helps**: The core value proposition of SceneSplit. Reveals what split mechanisms are most popular (e.g. equal vs percentage) and how often multi-payer bills occur.

#### `expense_edited`
* **Trigger**: Fired when an existing expense is modified and saved.
* **Code Location**: [add_expense_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/add_expense_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Title of the parent group.
  * `split_type` (`String`): Distribution type (`equal`, `exact`, `percentage`).
  * `paid_by_mode` (`String`): Payment arrangement (`single`, `multiple`).
  * `amount_cents` (`int`): Updated expense value in cents.
  * `currency_code` (`String`): Group currency code (e.g. `USD`, `EUR`).
  * `member_count` (`int`): Updated participant count.
* **What it does & Why it helps**: Evaluates error correction rates, split rebalancing, and post-creation bill adjustments.

#### `expense_deleted`
* **Trigger**: Fired when an expense is deleted from either the expense detail screen or the activity feed dialog.
* **Code Location**: [expense_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/expense_detail_screen.dart) and [group_activity_dialogs.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_activity_dialogs.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Group title.
  * `amount_cents` (`int`): Amount of the deleted expense in cents.
  * `currency_code` (`String?`): Group currency code.
* **What it does & Why it helps**: Captures transaction cancellation rates, mistake frequencies, and average deleted expense size.

#### `calculator_used`
* **Trigger**: Fired when the user evaluates an equation in the in-app calculator and taps "Use Result".
* **Code Location**: [add_expense_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/add_expense_screen.dart) in `_openCalculator`.
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Title of the current scene.
* **What it does & Why it helps**: Validates feature adoption for the in-app calculator keypad sheet over external calculator apps.

#### `expenses_shared`
* **Trigger**: Fired when sharing expenses directly from the expenses list sheet.
* **Code Location**: [share_expenses_sheet.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/widgets/share_expenses_sheet.dart).
* **Properties**:
  * `expense_count` (`int`): Total expenses included.
  * `format` (`String`): Export format (`image` or `text`).
  * `range` (`String`): Selected preset range (`all`, `month`, `7d`, `custom`).
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures quick-share usage directly from the expenses list sheet.

#### `expense_shared`
* **Trigger**: Fired when sharing an individual expense directly from the Expense Detail screen.
* **Code Location**: [expense_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/expense_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Name of the scene.
  * `expense_id` (`String`): Expense UUID.
  * `amount_cents` (`int`): Total expense amount in cents.
  * `currency_code` (`String`): Currency code for the expense.
  * `format` (`String`): Export format (`image` or `text`).
  * `split_type` (`String`): Split method (`equal`, `exact`, `percentage`).
  * `payer_count` (`int`): Number of payers who contributed.
  * `participant_count` (`int`): Number of participants in the split.
  * `debt_count` (`int`): Number of debt rows resulting from this single expense.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures viral loop and direct-message receipt sharing for individual expenses.

#### `expense_list_expanded`
* **Trigger**: Fired when the user taps "Show more" to expand the truncated expense list on the group detail screen.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `expense_count` (`int`): Total expenses in the scene (not just the visible ones).
  * `member_count` (`int`): Number of members in the scene.
  * `shown_count` (`int`): Expense rows visible **after** the expansion.
  * `source` (`String`): Origin screen (`group_detail`).
* **What it does & Why it helps**: Reveals whether long scenes need more than the initial 5 visible rows, and how deep users actually go before giving up. A rising `shown_count` per tap sequence indicates the cap should be higher.

#### `expense_list_view_all`
* **Trigger**: Fired when the user taps "See all" to open the full expense list screen from the group detail screen.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `expense_count` (`int`): Total expenses in the scene.
  * `member_count` (`int`): Number of members in the scene.
  * `source` (`String`): Origin screen (`group_detail`).
* **What it does & Why it helps**: Directly comparable to `expense_list_expanded`. If "See all" wins consistently over in-place expansion, the redundant control should be removed; if expansion wins, the dedicated screen is over-engineered.

#### `expense_detail_opened`
* **Trigger**: Fired once each time an expense detail screen opens and the expense resolves.
* **Code Location**: [expense_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/expense_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `expense_id` (`String`): Expense UUID.
  * `amount_cents` (`int`): Expense value in integer cents.
  * `currency_code` (`String`): Scene currency code.
  * `participant_count` (`int`): Number of members sharing this expense.
  * `source` (`String`): Entry point (`group_detail`, `group_expenses`, `member_breakdown`, `pair_balance`, `group_report`, `person_detail`).
* **What it does & Why it helps**: Closes the funnel opened by `expense_list_expanded` / `expense_list_view_all`. It answers whether users actually open expenses after expanding a list, and which entry point drives real lookups.

#### `expense_form_opened`
* **Trigger**: Fired once each time the add / edit expense form opens.
* **Code Location**: [add_expense_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/expenses/add_expense_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `mode` (`String`): `create` or `edit`.
  * `source` (`String`): Entry point (`group_detail`, `expense_detail`).
* **What it does & Why it helps**: Captures intent before the save. `expense_form_opened` (mode `create`) → `expense_created` exposes abandonment that the create event alone hides.

#### `member_breakdown_opened`
* **Trigger**: Fired when a member slice is tapped in the scene breakdown chart.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart) in the pie-chart `onSliceTap`.
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `member_name` (`String`): Display name of the tapped member.
  * `share_cents` (`int`): That member's share of scene spending, in cents.
  * `expense_count` (`int`): Number of expenses behind that share.
  * `percent` (`double?`): The member's share as a percentage of the total.
* **What it does & Why it helps**: Measures adoption of the visual breakdown and reveals which members' spending users care enough to drill into.

---

### 4. Settlements (CRUD)

#### `settlement_created`
* **Trigger**: Fired when a debt payoff/settlement is recorded between two users.
* **Code Location**: [record_settlement_sheet.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/settlements/record_settlement_sheet.dart) in `_save`.
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Name of the scene settled in.
  * `amount_cents` (`int`): Paid debt amount in cents.
  * `currency_code` (`String`): Currency of the settlement.
  * `source` (`String`): Origin sheet/screen (`scene_detail`, `balances_pair`, `person_detail`, `group_report`).
  * `had_prefill` (`bool`): `true` if launched by tapping an existing debt tile; `false` if manual entry.
  * `is_custom_date` (`bool`): `true` if user selected a custom or past date via the date picker.
* **What it does & Why it helps**: Tracks debt closure rates, navigation origin, and adoption of custom settlement dates.

#### `settlement_edited`
* **Trigger**: Fired when an existing recorded settlement is updated.
* **Code Location**: [record_settlement_sheet.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/settlements/record_settlement_sheet.dart) in `_save`.
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Name of the scene settled in.
  * `amount_cents` (`int`): Updated settlement amount in cents.
  * `currency_code` (`String`): Currency of the settlement.
  * `is_custom_date` (`bool`): `true` if custom date is active.
* **What it does & Why it helps**: Monitors debt correction rates and date adjustments after initial recording.

#### `settlement_deleted`
* **Trigger**: Fired when a recorded settlement is deleted from the group activity dialog.
* **Code Location**: [group_activity_dialogs.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_activity_dialogs.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Group name.
  * `amount_cents` (`int`): Amount of the deleted settlement in cents.
  * `currency_code` (`String`): Currency code of the settlement.
* **What it does & Why it helps**: Tracks settlement reversals or accidental debt clearance undo actions.

#### `settlement_form_opened`
* **Trigger**: Fired when the record settlement sheet opens.
* **Code Location**: [record_settlement_sheet.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/settlements/record_settlement_sheet.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String?`): Name of the scene.
  * `mode` (`String`): `create` or `edit`.
  * `source` (`String`): Entry point (`scene_detail`, `balances_pair`, `person_detail`).
  * `had_prefill` (`bool`): `true` if the sheet was opened from an existing open debt.
* **What it does & Why it helps**: Shows settlement intent before the save, and quantifies how often the one-tap "settle this debt" path is used versus manual entry.

#### `settlement_list_expanded`
* **Trigger**: Fired when the user taps "Show more" to expand the truncated settlement list on the scene screen.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `settlement_count` (`int`): Total settlements in the scene.
  * `member_count` (`int`): Number of members in the scene.
  * `shown_count` (`int`): Settlement rows visible **after** the expansion.
  * `source` (`String`): Origin screen (`group_detail`).
* **What it does & Why it helps**: The settlement counterpart of `expense_list_expanded`, so list-length pressure can be judged across both lists.

#### `settlement_list_view_all`
* **Trigger**: Fired when the user opens the full settlement list screen from the scene screen.
* **Code Location**: [group_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/group_detail_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the scene.
  * `settlement_count` (`int`): Total settlements in the scene.
  * `member_count` (`int`): Number of members in the scene.
  * `source` (`String`): Origin screen (`group_detail`).
* **What it does & Why it helps**: Tracks navigation to the full settlement list — the settlement counterpart of `expense_list_view_all`.

---

### 5. Scene Reports

#### `report_opened`
* **Trigger**: Fired once on initial data load of the Scene Reports screen.
* **Code Location**: [group_report_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/reports/group_report_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Name of the group.
  * `source` (`String`): Navigation entrypoint (`group_detail` or `group_expenses`).
  * `default_preset` (`String`): Default active date filter preset (`all`).
  * `expense_count` (`int`): Total expenses in the group.
  * `settlement_count` (`int`): Total settlements in the group.
* **What it does & Why it helps**: Measures discovery and engagement with the reporting dashboard across entrypoints.

#### `report_shared`
* **Trigger**: Fired after the user successfully exports and opens the system share sheet from Scene Reports.
* **Code Location**: [group_report_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/reports/group_report_screen.dart) in `_shareReport`.
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Group name.
  * `format` (`String`): Export medium (`image` or `text`).
  * `range_preset` (`String`): Applied date range (`all`, `today`, `1d`, `this_week`, `month`, `7d`, `custom`).
  * `is_single_member` (`bool`): Whether this was a filtered personal breakdown or whole-group summary.
  * `selected_member_name` (`String?`): Name of the specific member if single-member filtered.
  * `expense_count` (`int`): Number of included expense line items.
  * `settlement_count` (`int`): Number of included settlement line items.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Key viral and retention loop indicator. Tells you whether users prefer branded image summary cards or itemized text receipts, and what date ranges are most frequently exported.

#### `report_filter_applied`
* **Trigger**: Fired whenever a date preset, custom date range, or member filter is selected in Scene Reports.
* **Code Location**: [group_report_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/reports/group_report_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Group name.
  * `filter_type` (`String`): Filter category (`date` or `member`).
  * `filter_value` (`String`): Applied value (e.g. `'thisWeek'`, `'month'`, or member's name).
* **What it does & Why it helps**: Demonstrates how deeply users interact with report data (e.g. isolating single members or specific weeks of a trip).

#### `report_sort_changed`
* **Trigger**: Fired when the sort order button is toggled in Scene Reports.
* **Code Location**: [group_report_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/reports/group_report_screen.dart).
* **Properties**:
  * `group_id` (`String`): Group UUID.
  * `group_name` (`String`): Group name.
  * `sort_order` (`String`): Selected sort order (`dateDesc` or `dateAsc`).
* **What it does & Why it helps**: Understands user consumption preferences (chronological vs reverse-chronological).

---

### 6. Balances & Debts

#### `balance_shared`
* **Trigger**: Fired after the user opens the system share sheet for the Balances summary.
* **Code Location**: [balances_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/balances/balances_screen.dart).
* **Properties**:
  * `debt_count` (`int`): Total outstanding debts included in the share.
  * `member_share_count` (`int`): Total members involved.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures viral/collaborative behavior. Shows how often users broadcast "who owes who" to group chats.

#### `balances_pair_opened`
* **Trigger**: Fired when tapping on a 1-to-1 person balance card in the Balances tab.
* **Code Location**: [balances_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/balances/balances_screen.dart).
* **Properties**:
  * `has_who_filter` (`bool`): Was the "Who" debtor filter active?
  * `has_whom_filter` (`bool`): Was the "Whom" creditor filter active?
  * `currency_count` (`int`): Number of distinct currencies active between this pair.
* **What it does & Why it helps**: Tracks user interest in pairwise settlement details across multiple scenes.

#### `balances_filter_applied` & `balances_filter_cleared`
* **Trigger**: Fired when applying or clearing "Who" / "Whom" filters in the Balances overview.
* **Code Location**: [balances_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/balances/balances_screen.dart).
* **Properties** (on apply):
  * `who_set` (`bool`): `true` if filtering by specific debtor.
  * `whom_set` (`bool`): `true` if filtering by specific creditor.
  * `whom_is_you` (`bool`): `true` if user tapped the "Owed to You" shortcut.
* **What it does & Why it helps**: Measures use of the multi-party filtering tools and validates whether "Owed to You" is the dominant user query.

---

### 7. People & Contacts (CRUD)

#### `person_created`
* **Trigger**: Fired when a new person is created from group creation, group editing, or the Profile People screen.
* **Code Location**: [create_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/create_group_screen.dart), [edit_group_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/groups/edit_group_screen.dart), and [people_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/people_screen.dart).
* **Properties**:
  * `source` (`String`): Origin flow (`'group_create'`, `'group_edit'`, `'profile_people'`).
* **What it does & Why it helps**: Tracks which touchpoints generate the most new contacts in the user's local network.

#### `person_edited`
* **Trigger**: Fired when a person's name is updated in the People list.
* **Code Location**: [person_row.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/widgets/person_row.dart).
* **Properties**:
  * `person_id` (`String`): Anonymized user UUID.
* **What it does & Why it helps**: Tracks contact management activity and name corrections without logging personal names.

#### `person_deleted`
* **Trigger**: Fired when a contact with no financial activity is deleted from the People list.
* **Code Location**: [person_row.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/widgets/person_row.dart).
* **Properties**:
  * `person_id` (`String`): Anonymized user UUID.
* **What it does & Why it helps**: Measures directory cleanup rate and contact pruning behavior.

#### `person_detail_opened`
* **Trigger**: Fired when navigating to an individual contact's detail screen.
* **Code Location**: [person_detail_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/person_detail_screen.dart).
* **Properties**:
  * `open_debt_count` (`int`): Count of open debts involving this person.
  * `scene_count` (`int`): Number of scenes this person shares with the current user.
  * `is_self` (`bool`): `true` if the user is inspecting their own profile.
* **What it does & Why it helps**: Measures interest in person-centric accounting vs scene-centric accounting.

#### `profile_name_updated`
* **Trigger**: Fired when the active device user edits and saves their own display name in Profile.
* **Code Location**: [profile_name_section.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/widgets/profile_name_section.dart).
* **Properties**: *(None - 0 PII in event payload; sets `$name` in Mixpanel People)*.
* **What it does & Why it helps**: Tracks user identity engagement while strictly respecting privacy in analytical events.

---

### 8. System, Store & Maintenance

#### `share_app_clicked`
* **Trigger**: Fired when tapping "Share SceneSplit" from the Profile or About screen.
* **Code Location**: [app_link_launcher.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/core/utils/app_link_launcher.dart).
* **Properties**:
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures user intent to share and referral engagement.

#### `rate_app_clicked`
* **Trigger**: Fired when tapping "Rate SceneSplit" in About/Profile to open the store listing.
* **Code Location**: [app_link_launcher.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/core/utils/app_link_launcher.dart).
* **Properties**:
  * `available` (`bool`): Whether a store listing URL is configured for the active platform.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Tracks user conversion to leave an app store rating/review.

#### `update_prompted` & `update_started`
* **Trigger**: In-app Android Play update dialog is displayed or initiated.
* **Code Location**: [app_update_service.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/services/app_update_service.dart).
* **Properties**:
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Verifies that the Google Play flexible update pipeline is working as intended.

#### `backup_exported` & `backup_imported`
* **Trigger**: Fired after a JSON database backup is saved/shared or restored.
* **Code Location**: [profile_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/profile/profile_screen.dart).
* **Properties**:
  * `method` (`String` for export): `'save'` or `'share'`.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures user reliance on manual local data portability and backup health.

#### `feedback_initiated`
* **Trigger**: Fired when a user taps Contact Us, Send Feedback, or Suggest Feature in About / App Info screen.
* **Code Location**: [app_info_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/app_info/app_info_screen.dart).
* **Properties**:
  * `type` (`String`): `'support'`, `'feedback'`, or `'feature_request'`.
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Quantifies feedback channels and support demand directly from the app.

#### `privacy_policy_opened`
* **Trigger**: Fired when the user views the Privacy Policy in the About / App Info screen.
* **Code Location**: [app_info_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/app_info/app_info_screen.dart).
* **Properties**:
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures engagement with data protection policies and legal compliance.

#### `terms_of_service_opened`
* **Trigger**: Fired when the user views the Terms of Service in the About / App Info screen.
* **Code Location**: [app_info_screen.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/features/app_info/app_info_screen.dart).
* **Properties**:
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Measures user review of legal terms and usage conditions.

#### `more_apps_clicked`
* **Trigger**: Fired when tapping More Apps to open the developer portfolio on Google Play.
* **Code Location**: [app_link_launcher.dart](file:///Users/usman/Development/Projects/Others/scene_split/lib/core/utils/app_link_launcher.dart).
* **Properties**:
  * `platform` (`String`): Host OS.
* **What it does & Why it helps**: Tracks cross-promotional discovery and interest in developer's other applications.

---

## Adding New Events Workflow

When adding a new product event to SceneSplit, follow these 4 steps:

1. **Declare the Constant** in `analytics_events.dart` under the appropriate domain:
   ```dart
   static const expenseEdited = 'expense_edited';
   ```
   Add it to the `AnalyticsEvents.all` list.

2. **Add a Typed Method** in `analytics_service.dart`:
   ```dart
   Future<void> trackExpenseEdited({
     required String groupId,
     required String groupName,
     required int amountCents,
   }) async {
     await _track(
       AnalyticsEvents.expenseEdited,
       properties: {
         'group_id': groupId,
         'group_name': groupName,
         'amount_cents': amountCents,
       },
     );
   }
   ```

3. **Call from UI / Service**:
   ```dart
   ref.read(analyticsServiceProvider).trackExpenseEdited(...);
   ```

4. **Verify in Tests**:
   Update `test/services/analytics_service_test.dart` to assert presence in the catalog and run `flutter test`.
