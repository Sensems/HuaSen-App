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
  static const String navNotes = '笔记';
  static const String navClipboard = '剪贴板';
  static const String navDrafts = '草稿';
  static const String navSettings = '设置';

  // --- Notes list screen ---
  static const String notesBrandTitle = '花森';
  static const String searchNotes = '搜索笔记';
  static const String searchNotesHint = '输入关键词';
  static const String notesFilterAll = '全部';
  static const String notesFilterPinned = '置顶';
  static const String notesFilterRecent = '最近';
  static const String noNotesFound = '还没有笔记';
  static const String noNotesHint = '点击右上角 + 创建第一条笔记';
  static const String noSearchResults = '没有找到相关笔记';
  static const String noSearchResultsHint = '试试其他关键词';
  static const String notesPinnedEmpty = '暂无置顶笔记';
  static const String notesPinnedEmptyHint = '置顶同步能力待后端支持';
  static const String notesLoadFailed = '加载失败，请重试';
  static const String notesRetry = '重试';
  static const String notesRefreshFailed = '刷新失败';
  static const String notesLoadMoreFailed = '加载更多失败，点击重试';
  static const String notesNoMore = '没有更多了';
  static const String notesUntitled = '无标题';
  static const String createNote = '新建笔记';

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
  static const String settings = '设置';
  static const String appearance = '外观';
  static const String darkMode = '深色模式';
  static const String darkModeHint = '切换深色配色';
  static const String syncSection = '同步设置';
  static const String draftsSync = '草稿箱同步';
  static const String draftsSyncHint = '自动同步微信草稿到本地';
  static const String clipboardSync = '剪贴板同步';
  static const String clipboardSyncHint = '跨设备同步剪贴板内容';
  static const String sizeThresholds = '同步阈值';
  static const String maxImageSize = '图片同步阈值';
  static const String maxImageSizeHint = '超过此大小的图片不同步';
  static const String maxFileSize = '文件同步阈值';
  static const String maxFileSizeHint = '超过此大小的文件不同步';
  static const String accountBinding = '账号绑定';
  static const String edit = '编辑';
  static const String bound = '已绑定';
  static const String unbind = '解绑';
  static const String emailLabel = '邮箱';
  static const String wechatLabel = '微信';
  static const String unbindComingSoon = '解绑功能即将开放';
  static const String placeholderDisplayName = '张明';
  static const String placeholderAvatarInitial = '张';
  static const String placeholderEmail = 'zhangming@example.com';

  // --- Account edit ---
  static const String accountEditTitle = '账号信息';
  static const String save = '保存';
  static const String saveChanges = '保存修改';
  static const String savedToast = '已保存';
  static const String avatarEditComingSoon = '头像编辑即将开放';
  static const String usernameLabel = '用户名';
  static const String boundEmailLabel = '绑定邮箱';
  static const String boundEmailHint = '修改邮箱请在设置页的账号绑定中操作';
  static const String tapToEditAvatar = '点击编辑头像';

  // --- WeChat bind ---
  static const String wechatBindTitle = '绑定微信';
  static const String wechatBindSubtitle = '绑定后可将公众号消息同步到草稿箱';
  static const String wechatBindCodeHint = '请输入绑定码';
  static const String wechatPaste = '粘贴';
  static const String wechatConfirmBind = '确认绑定';
  static const String wechatBindSuccess = '绑定成功，消息将同步至草稿箱';
  static const String wechatBindCodeRequired = '请输入绑定码';
  static const String wechatClipboardEmpty = '剪贴板为空';
  static const String wechatExampleCode = 'HS-8K2M-N4X';
  static const String wechatStepsTitle = '绑定步骤';
  static const String wechatStep1 = '关注花森公众号';
  static const String wechatStep2 = '发送关键词「绑定」';
  static const String wechatStep3 = '复制收到的绑定码';
  static const String wechatStep4 = '回到 App 粘贴并确认';

  // --- Drafts screen ---
  static const String draftsTitle = '草稿箱';
  static const String draftsFilterAll = '全部';
  static const String draftsFilterText = '文本';
  static const String draftsFilterImage = '图片';
  static const String draftsFilterAudio = '音频';
  static const String noDrafts = '暂无草稿';
  static const String noDraftsHint = '微信同步的草稿会出现在这里';
  static const String draftsComplete = '完善';
  static const String draftsDelete = '删除';
  static const String draftsLoadFailed = '加载失败，请重试';
  static const String draftsRetry = '重试';
  static const String draftsRefreshFailed = '刷新失败';
  static const String draftsLoadMoreFailed = '加载更多失败，点击重试';
  static const String draftsNoMore = '没有更多了';
  static const String draftsDeleteFailed = '删除失败';
  static const String draftsMediaPlaceholder = '媒体';
  static const String draft = '草稿';

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
  static const String registerCodeSent = '验证码已发送';
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

  // --- Reset password ---
  static const String resetPasswordTitle = '重置密码';
  static const String resetPasswordSubtitle = '输入注册邮箱，我们将发送验证码';
  static const String resetPasswordHint = '新密码';
  static const String resetPasswordConfirmHint = '确认新密码';
  static const String resetPasswordButton = '确认重置';
  static const String resetPasswordBackToLogin = '← 返回登录';
  static const String resetPasswordSuccess = '密码重置成功，请登录';
  static const String resetPasswordResendPrefix = '重新发送';
  static const String resetPasswordNetworkError = '网络异常，请重试';

  // --- Legal placeholders ---
  static const String legalTermsTitle = '用户协议';
  static const String legalPrivacyTitle = '隐私政策';
  static const String legalPlaceholderBody = '内容即将开放，敬请期待。';

  // --- Common ---
  static const String back = '返回';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
}
