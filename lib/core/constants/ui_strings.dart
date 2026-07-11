/// Centralized UI string constants.
///
/// This class acts as a single source of truth for all user-facing strings
/// in the app. When internationalization is added, replace the constant
/// lookups with `AppLocalizations.of(context)` calls that return the same
/// keys.
abstract final class UiStrings {
  // --- App-level ---
  static const String appTitle = 'Sebhua Notes';

  // --- Navigation ---
  static const String navNotes = 'Notes';
  static const String navClipboard = 'Clipboard';
  static const String navDrafts = 'Drafts';
  static const String navSettings = 'Settings';

  // --- Notes list screen ---
  static const String searchNotes = 'Search notes...';
  static const String noNotesFound = 'No notes yet';
  static const String noNotesHint =
      'Tap the + button to create your first note';
  static const String createNote = 'Create note';

  // --- Note editor screen ---
  static const String noteTitleHint = 'Note title';
  static const String noteContentHint = 'Start writing...';
  static const String mediaAttachments = 'Media Attachments';
  static const String mediaAttachmentsHint =
      'Photos, images, and files will appear here';
  static const String attachMedia = 'Attach Media';
  static const String saveNote = 'Save';
  static const String deleteNote = 'Delete';

  // --- Clipboard screen ---
  static const String clipboardHistory = 'Clipboard History';
  static const String noClipboardEntries = 'No clipboard entries';
  static const String noClipboardHint = 'Copied items will appear here';
  static const String pin = 'Pin';
  static const String unpin = 'Unpin';

  // --- Settings screen ---
  static const String settings = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String darkModeHint = 'Toggle dark color scheme';
  static const String syncSection = 'Sync';
  static const String clipboardSync = 'Clipboard Sync';
  static const String clipboardSyncHint =
      'Automatically capture clipboard items';
  static const String sizeThresholds = 'Size Thresholds';
  static const String maxImageSize = 'Max Image Size';
  static const String maxImageSizeHint = 'Skip images larger than this';
  static const String maxFileSize = 'Max File Size';
  static const String maxFileSizeHint = 'Skip files larger than this';

  // --- Drafts screen ---
  static const String wechatDrafts = 'WeChat Drafts';
  static const String noDrafts = 'No drafts';
  static const String noDraftsHint = 'WeChat drafts will appear here';
  static const String convertToNote = 'Convert to Note';
  static const String draft = 'Draft';

  // --- Login ---
  static const String loginBrandTitle = '花森';
  static const String loginBrandSlogan = '记录，以编辑的方式';
  static const String loginEmailHint = '邮箱地址';
  static const String loginPasswordHint = '密码';
  static const String loginShowPassword = '显示密码';
  static const String loginHidePassword = '隐藏密码';
  static const String loginButton = '登录';
  static const String loginForgotPassword = '忘记密码?';
  static const String loginNoAccount = '还没有账号? ';
  static const String loginRegisterNow = '立即注册';
  static const String loginComingSoon = '即将开放';
  static const String loginNetworkError = '网络异常，请重试';
  static const String loginEmailRequired = '请输入邮箱地址';
  static const String loginEmailInvalid = '邮箱格式不正确';
  static const String loginPasswordRequired = '请输入密码';

  // --- Register ---
  static const String registerTitle = '创建账号';
  static const String registerSubtitle = '使用邮箱注册 花森';
  static const String registerCodeHint = '验证码';
  static const String registerGetCode = '获取验证码';
  static const String registerPasswordHint = '设置密码';
  static const String registerConfirmPasswordHint = '确认密码';
  static const String registerButton = '注册';
  static const String registerHasAccount = '已有账号？';
  static const String registerBackToLogin = '返回登录';
  static const String registerSuccess = '注册成功，请登录';
  static const String registerAgreePrefix = '我已阅读并同意';
  static const String registerUserAgreement = '《用户协议》';
  static const String registerAnd = '和';
  static const String registerPrivacyPolicy = '《隐私政策》';
  static const String registerCodeRequired = '请输入验证码';
  static const String registerCodeInvalid = '请输入6位数字验证码';
  static const String registerPasswordWeak = '密码至少8位，且须包含字母和数字';
  static const String registerPasswordMismatch = '两次输入的密码不一致';
  static const String registerTermsRequired = '请先阅读并同意用户协议和隐私政策';
  static const String registerNetworkError = '网络异常，请重试';

  // --- Legal placeholders ---
  static const String legalTermsTitle = '用户协议';
  static const String legalPrivacyTitle = '隐私政策';
  static const String legalPlaceholderBody = '内容即将开放，敬请期待。';

  // --- Common ---
  static const String back = 'Back';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
}
