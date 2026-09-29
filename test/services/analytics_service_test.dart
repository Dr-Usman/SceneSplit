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
      },
    );

    test(
      'AnalyticsEvents.all contains every event constant without duplicates',
      () {
        final all = AnalyticsEvents.all;
        expect(all.length, equals(39));
        expect(all.toSet().length, equals(all.length));
        expect(all, contains(AnalyticsEvents.reportOpened));
        expect(all, contains(AnalyticsEvents.reportShared));
        expect(all, contains(AnalyticsEvents.reportFilterApplied));
        expect(all, contains(AnalyticsEvents.reportSortChanged));
        expect(all, contains(AnalyticsEvents.calculatorUsed));
        expect(all, contains(AnalyticsEvents.settlementCreated));
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
