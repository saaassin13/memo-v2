/// Route path constants
abstract class Routes {
  // Main tabs
  static const home = '/';
  static const todo = '/todo';
  static const calendar = '/calendar';
  static const profile = '/profile';

  // Settings
  static const settings = '/settings';

  // Memo
  static const memoList = '/apps/memo';
  static const memoNew = '/apps/memo/new';
  static String memoDetail(String id) => '/apps/memo/$id';

  // Diary
  static const diaryList = '/apps/diary';
  static const diaryNew = '/apps/diary/new';
  static const diaryManagement = '/apps/diary/management';
  static String diaryDetail(String id) => '/apps/diary/$id';

  // Countdown
  static const countdown = '/apps/countdown';

  // Accounting
  static const accounting = '/apps/accounting';

  // Goals
  static const goalsList = '/apps/goals';
  static String goalDetail(String id) => '/apps/goals/$id';

  // Weight
  static const weight = '/apps/weight';

  // Calendar event
  static String calendarEvent(String id) => '/calendar/event/$id';
}
