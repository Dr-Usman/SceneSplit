import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/services/analytics/analytics_events.dart';
import 'package:scene_split/services/analytics/analytics_service.dart';

void main() {
  group('AnalyticsEvents', () {
    test(
      'contains all expected report, calculator, settlement, and CRUD events',
      () {
        expect(AnalyticsEvents.reportOpened, equals('report_opened'));
        expect(AnalyticsEvents.reportShared, equals('report_shared'));
        expect(
          AnalyticsEvents.reportFilterApplied,
          equals('report_filter_applied'),
        );
        expect(
          AnalyticsEvents.reportSortChanged,
          equals('report_sort_changed'),
        );
        expect(AnalyticsEvents.calculatorUsed, equals('calculator_used'));
        expect(AnalyticsEvents.settlementCreated, equals('settlement_created'));
        expect(AnalyticsEvents.groupEdited, equals('group_edited'));
        expect(AnalyticsEvents.groupDeleted, equals('group_deleted'));
        expect(AnalyticsEvents.expenseEdited, equals('expense_edited'));
        expect(AnalyticsEvents.expenseDeleted, equals('expense_deleted'));
        expect(AnalyticsEvents.personCreated, equals('person_created'));
        expect(AnalyticsEvents.personEdited, equals('person_edited'));
        expect(AnalyticsEvents.personDeleted, equals('person_deleted'));
        expect(AnalyticsEvents.settlementEdited, equals('settlement_edited'));
        expect(AnalyticsEvents.settlementDeleted, equals('settlement_deleted'));
        expect(AnalyticsEvents.currencyChanged, equals('currency_changed'));
        expect(
          AnalyticsEvents.profileNameUpdated,
          equals('profile_name_updated'),
        );
        expect(AnalyticsEvents.feedbackInitiated, equals('feedback_initiated'));
        expect(
          AnalyticsEvents.privacyPolicyOpened,
          equals('privacy_policy_opened'),
        );
        expect(
          AnalyticsEvents.termsOfServiceOpened,
          equals('terms_of_service_opened'),
        );
        expect(AnalyticsEvents.moreAppsClicked, equals('more_apps_clicked'));
        expect(AnalyticsEvents.shareAppClicked, equals('share_app_clicked'));
        expect(AnalyticsEvents.rateAppClicked, equals('rate_app_clicked'));
        expect(AnalyticsEvents.expensesShared, equals('expenses_shared'));
        expect(AnalyticsEvents.expenseShared, equals('expense_shared'));
        expect(
          AnalyticsEvents.expenseListExpanded,
          equals('expense_list_expanded'),
        );
        expect(
          AnalyticsEvents.expenseListViewAll,
          equals('expense_list_view_all'),
        );
        expect(
          AnalyticsEvents.expenseDetailOpened,
          equals('expense_detail_opened'),
        );
        expect(
          AnalyticsEvents.expenseFormOpened,
          equals('expense_form_opened'),
        );
        expect(
          AnalyticsEvents.memberBreakdownOpened,
          equals('member_breakdown_opened'),
        );
        expect(
          AnalyticsEvents.groupDetailOpened,
          equals('group_detail_opened'),
        );
        expect(AnalyticsEvents.groupFormOpened, equals('group_form_opened'));
        expect(
          AnalyticsEvents.settlementFormOpened,
          equals('settlement_form_opened'),
        );
        expect(
          AnalyticsEvents.settlementListExpanded,
          equals('settlement_list_expanded'),
        );
        expect(
          AnalyticsEvents.settlementListViewAll,
          equals('settlement_list_view_all'),
        );
      },
    );

    test(
      'AnalyticsEvents.all contains every event constant without duplicates',
      () {
        final all = AnalyticsEvents.all;
        expect(all.length, equals(50));
        expect(all.toSet().length, equals(all.length));
        expect(all, contains(AnalyticsEvents.reportOpened));
        expect(all, contains(AnalyticsEvents.reportShared));
        expect(all, contains(AnalyticsEvents.reportFilterApplied));
        expect(all, contains(AnalyticsEvents.reportSortChanged));
        expect(all, contains(AnalyticsEvents.calculatorUsed));
        expect(all, contains(AnalyticsEvents.settlementCreated));
        expect(all, contains(AnalyticsEvents.expensesShared));
        expect(all, contains(AnalyticsEvents.expenseShared));
        expect(all, contains(AnalyticsEvents.groupEdited));
        expect(all, contains(AnalyticsEvents.groupDeleted));
        expect(all, contains(AnalyticsEvents.expenseEdited));
        expect(all, contains(AnalyticsEvents.expenseDeleted));
        expect(all, contains(AnalyticsEvents.personCreated));
        expect(all, contains(AnalyticsEvents.personEdited));
        expect(all, contains(AnalyticsEvents.personDeleted));
        expect(all, contains(AnalyticsEvents.settlementEdited));
        expect(all, contains(AnalyticsEvents.settlementDeleted));
        expect(all, contains(AnalyticsEvents.currencyChanged));
        expect(all, contains(AnalyticsEvents.profileNameUpdated));
        expect(all, contains(AnalyticsEvents.feedbackInitiated));
        expect(all, contains(AnalyticsEvents.privacyPolicyOpened));
        expect(all, contains(AnalyticsEvents.termsOfServiceOpened));
        expect(all, contains(AnalyticsEvents.moreAppsClicked));
        expect(all, contains(AnalyticsEvents.shareAppClicked));
        expect(all, contains(AnalyticsEvents.rateAppClicked));
        expect(all, contains(AnalyticsEvents.expenseListExpanded));
        expect(all, contains(AnalyticsEvents.expenseListViewAll));
        expect(all, contains(AnalyticsEvents.expenseDetailOpened));
        expect(all, contains(AnalyticsEvents.expenseFormOpened));
        expect(all, contains(AnalyticsEvents.memberBreakdownOpened));
        expect(all, contains(AnalyticsEvents.groupDetailOpened));
        expect(all, contains(AnalyticsEvents.groupFormOpened));
        expect(all, contains(AnalyticsEvents.settlementFormOpened));
        expect(all, contains(AnalyticsEvents.settlementListExpanded));
        expect(all, contains(AnalyticsEvents.settlementListViewAll));
      },
    );
  });

  group('AnalyticsService', () {
    test('platformLabel returns valid platform identifier', () {
      final label = AnalyticsService.platformLabel();
      expect([
        'ios',
        'android',
        'macos',
        'windows',
        'linux',
        'web',
        'fuchsia',
      ], contains(label));
    });
  });
}
