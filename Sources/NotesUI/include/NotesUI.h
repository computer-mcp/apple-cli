// Normalized full dump import surface for NotesUI.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesUI_h

#define NotesUI_h



#import <Foundation/Foundation.h>

@import Accounts;

@import AppKit;

@import AVFoundation;

@import CloudKit;

@import CoreData;

@import CoreGraphics;

@import CoreLocation;

@import CoreMedia;

@import CoreSpotlight;

@import Contacts;

@import Dispatch;

@import MapKit;

@import PDFKit;

@import PencilKit;

@import QuartzCore;

@import Speech;

@import UniformTypeIdentifiers;

@import UserNotifications;

@import WebKit;

@import NotesSupport;

@import NotesHTML;

@import NotesShared;


// Exported by NotesUI but omitted from the class-dump header surface.
FOUNDATION_EXPORT const double ICMZoomBaseFontPointSize;


@interface PKTitleQuery : NSObject

@end



struct CAFrameRateRange;

struct CGAffineTransform;

struct CGPoint;

struct CGRect;

struct CGSize;

struct CLLocationCoordinate2D;

struct _NSRange;



@class AVAsset, AVPlayer, ActivityEventResolver, CADisplayLink, CALayer, CAShapeLayer, CKShare, CNAvatarImageRenderer, CSSearchableItemAttributeSet, DOMHTMLElement, ICAbstractTextAttachment, ICAccessibility;

@class ICAccessibilityCustomizableTextFieldCell, ICAccount, ICAccountPassphraseManager, ICActivityStreamSelection, ICAddAttachmentsManager, ICAddAttachmentsManagerAttachmentInfo, ICAppGroupDefaultsController, ICAppearanceInfo, ICArcLayer, ICAssetThumbnailCache, ICAttachment, ICAttachmentBrickMapAnnotationV2;

@class ICAttachmentBrickView, ICAttachmentImageLoadingOperation, ICAttachmentInsertionController, ICAttachmentModel, ICAttachmentPreviewGenerator, ICAttachmentPreviewGeneratorImageClassificationOperation, ICAttachmentPreviewGeneratorOCROperation, ICAttachmentPreviewGeneratorOperation, ICAttachmentPreviewGeneratorOperationQueue, ICAttachmentPreviewImageLoader, ICAttachmentSizeMenu, ICAttachmentThumbnailOperation;

@class ICAttachmentThumbnailOperationQueue, ICAttachmentWebModelIcon, ICAttributedStringRippler, ICAudioController, ICAudioRecordingManager, ICAudioTextAttachment, ICAuthentication, ICAuthenticationAlert, ICAuthenticationPrompt, ICAuthorHighlightAnimation, ICAuthorHighlightAnimationAttribute, ICAuthorHighlightValue;

@class ICAuthorHighlightValueAttribute, ICAuthorHighlightsController, ICBaseAttachment, ICBaseAttachmentView, ICBaseLayoutManager, ICBaseTextAttachment, ICBrickTextAttachment, ICButtonItemIdentifier, ICCalculateAccessibilityController, ICCalculateDocumentController, ICCalculateGraphExpressionAttachmentView, ICCalculateGraphExpressionTextAttachment;

@class ICCalculateGraphExpressionUIModel, ICCalculateHighlightAttribute, ICCalculatePreviewBehaviorMenu, ICCalculateRecognitionController, ICCalculateResultAttachmentView, ICCalculateResultTextAttachment, ICCalculateResultUIModel, ICCalculateScrubberController, ICCalculateStringScanner, ICCheckmarkAuthorHighlightValueAttribute, ICCircleLayer, ICCloudSyncingObject;

@class ICCollaborationAnalyticsTracker, ICCollaborationAnalyticsTrackerInternal, ICCollaborationColorManager, ICCollaborationController, ICCollaboratorAvatarsView, ICCollapsibleActivityView, ICCollapsibleBaseView, ICCollapsibleContainerView, ICCollapsibleImageView, ICCollapsibleThumbnailView, ICColorDummyClass, ICCompatibilityAlertHelper;

@class ICConstantAvailableTableWidthProvider, ICCopyModernNotesToLegacyAccountOperation, ICCoreDataIndexer, ICCreateHTMLNoteAction, ICCreateModernNoteAction, ICCreateNoteAction, ICDidMoveToWindowSpy, ICDividerLineTextAttachment, ICDividerLineTextAttachmentView, ICDividerLineTextAttachmentViewProvider, ICDocCamPDFGenerator, ICDocumentMergeController;

@class ICDrawingConversionOperation, ICDrawingHashtagsAndMentionsController, ICDrawingPencilKitConverter, ICDrawingTextAttachment, ICExpansionState, ICFlippedView, ICFolder, ICFolderCoreDataIndexer, ICFolderCustomNoteSortType, ICFolderListSectionIdentifier, ICGalleryAttachmentUtilities, ICHTMLConverterClient;

@class ICHashtagAttachmentView, ICHashtagController, ICHashtagTextAttachment, ICHashtagUIModel, ICHelp, ICImageAndMovieThumbnailView, ICImageTextAttachment, ICIndexHandwritingOperation, ICInlineAttachment, ICInlineAttachmentUIModel, ICInlineAttachmentView, ICInlineCanvasTextAttachment;

@class ICInlineDrawingChangeCoalescer, ICInlineDrawingTextAttachment, ICInlineTextAttachment, ICInvitationsCoreDataIndexer, ICLabel, ICLegacyNoteUtilities, ICLinkAttachmentView, ICLinkConverter, ICLinkSnapshotGenerator, ICLinkTextAttachment, ICLinkUIModel, ICLoadingPieLayer;

@class ICLocalizationUtilities, ICLockedNotesModeMigrator, ICLockedTextAttachment, ICLongRunningTaskController, ICMAlertSheetTouchBarController, ICMBaseTouchBarController, ICMClickableTextView, ICMDatePickerDebugWindowController, ICMFontManager, ICMPasswordChangeSheetViewController, ICMPasswordEntrySheetViewController, ICMProgressWindowController;

@class ICMUnscrollableScrollView, ICMWindow, ICMZoomController, ICManagedObjectContextChangeController, ICMarkdownRepresentation, ICMarkdownString, ICMediaTime, ICMediaTimeFormatter, ICMediaTimeLabel, ICMentionAttachmentView, ICMentionNotificationController, ICMentionTextAttachment;

@class ICMentionUIModel, ICMentionsController, ICMenuIconHelper, ICMoveAlertUtilities, ICMoveDecision, ICMovieTextAttachment, ICNote, ICNoteContext, ICNoteEditorIconImageView, ICNoteLockManager, ICNoteSectionIdentifier, ICNoteTimelineController;

@class ICNoteTimelineSection, ICNoteTimelineSectionIdentifier, ICNotesCrossProcessChangeCoordinator, ICNotesImporterClient, ICNumberLiteral, ICOutlineController, ICPDFEncryptionStateChecker, ICPDFPreviewHelper, ICPDFTextAttachment, ICPaperDocumentTextAttachment, ICPaperSearchIndexer, ICPaperSearchIndexerBackgroundTask;

@class ICPaperStyle, ICPasswordUtilities, ICPressableAttachmentAccessibilityElement, ICPreviewDeviceContext, ICPreviewLayoutManager, ICPrintableTextAttachment, ICQuery, ICRecentNotesCoreDataIndexer, ICSearchIndexProgressCoordinator, ICSearchResult, ICSearchResultConfiguration, ICSearchResultRegexMatchFinder;

@class ICSearchResultSection, ICSearchTextCheckingResult, ICSearchUserInput, ICSectionedSearchResults, ICSelectorDelayer, ICShareNoteExporter, ICSortableSearchableItem, ICSwiftSystemPaperImageGenerator, ICSystemPaperImageGenerator, ICSystemPaperTextAttachment, ICSystemPaperThumbnailService, ICSystemPaperThumbnailServiceInternal;

@class ICTK2BulletTextAttachment, ICTK2BulletTextAttachmentView, ICTK2BulletTextAttachmentViewProvider, ICTK2TextController, ICTK2TodoTextAttachment, ICTTMergeableAttributedString, ICTTMergeableStringUndoGroup, ICTTMergeableStringVersionedDocument, ICTTParagraphStyle, ICTTTextContentStorage, ICTTTextController, ICTTTextEditFilter;

@class ICTTTextEditGrouper, ICTTTextStorage, ICTTTodo, ICTTUndoManager_135534566, ICTTZoomController, ICTable, ICTableAttachmentSelection, ICTableCellEditingUndoGroup, ICTableCellMergeableStringDelegate, ICTableCellTextStorage, ICTableColumnTextStorage, ICTableColumnWidthManager;

@class ICTableTextAttachment, ICTableTextController, ICTableTextStorage, ICTableUndoTarget, ICTagAllTagsItemIdentifier, ICTagContainerItemIdentifier, ICTagCoreDataIndexer, ICTagDetailItemIdentifier, ICTagNewTagItemIdentifier, ICTagOperatorItemIdentifier, ICTextAttachment, ICTextAttachmentCell;

@class ICTextContainer, ICTextController, ICTextStyle, ICThumbnailCache, ICThumbnailConfiguration, ICThumbnailDataCache, ICThumbnailDescription, ICThumbnailGenerator, ICThumbnailGeneratorAttachment, ICThumbnailGeneratorAvatar, ICThumbnailGeneratorNote, ICThumbnailGeneratorNoteAttachments;

@class ICThumbnailKey, ICThumbnailService, ICTintedLayer, ICTodoButton, ICTodoButtonNonVibrantImageView, ICTrackedParagraph, ICUnifiedNoteContext, ICUnsupportedTextAttachmentWithFallbackImage, ICUnsupportedTextAttachmentWithFallbackPDF, ICViewTrackingDisplayLink, ICVirtualSmartFolderItemIdentifier, ICWritingToolsContext;

@class LPLinkMetadata, LPLinkSnapshotConfiguration, LPLinkSnapshotGenerator, LPLinkView, NFFolder, NPNotePreviewProviderInternal, NSAccessibilityElement, NSButton, NSClickGestureRecognizer, NSColor, NSDatePicker, NSFetchedResultsController;

@class NSFont, NSFontManager, NSGroupTouchBarItem, NSImage, NSImageView, NSLayoutConstraint, NSLayoutManager, NSManagedObject, NSManagedObjectContext, NSManagedObjectID, NSPersistentStoreCoordinator, NSPopover;

@class NSProgressIndicator, NSScrollView, NSSecureTextField, NSStackView, NSTextAttachment, NSTextAttachmentCell, NSTextAttachmentViewProvider, NSTextContainer, NSTextContentStorage, NSTextField, NSTextFieldCell, NSTextLayoutManager;

@class NSTextStorage, NSTextView, NSTouchBar, NSTrackingArea, NSURLProtocol, NSView, NSViewController, NSWindow, NSWindowController, NSWritingToolsCoordinatorContext, NoteAttachmentPresentation, NoteAttachmentPresentationOccurence;

@class NoteHTMLEditorView, NoteHTMLEditorViewScriptMessageHandler, NoteHTMLEditorViewURLSchemeHandler, NoteWKWebView, NotesCIDURLProtocol, OutlineController, PKDrawing, PKTitleQuery, TTBulletTextAttributesCacheKey, UITraitCollection, UserStyleSheetGenerator, WKWebView;

@class WebArchive, _TtC7NotesUI13NoteSelection, _TtC7NotesUI16AudioAssetWriter, _TtC7NotesUI19AudioWaveformSource, _TtC7NotesUI19LinkEditorViewModel, _TtC7NotesUI21AudioRecordingManager, _TtC7NotesUI22AudioWaveformGenerator, _TtC7NotesUI23PersistedThumbnailCache, _TtC7NotesUI25AudioRecordingCoordinator, _TtC7NotesUI25WidgetNotePreviewProvider, _TtC7NotesUI28AVAudioEngineRecordingMethod, _TtC7NotesUI32ICNoteTimelineControllerInternal;

@class _TtC7NotesUIP33_0937A1AF2A2827E2462B0E48FD7819BC22OutlineUpdateOperation, _TtC7NotesUIP33_7B61C87D5F1EF51EE56142734628054A12ShareMetrics, _TtC7NotesUIP33_D37299C035145D658E3B6DC04AF9ADBF19ResourceBundleClass, _TtC7NotesUIP33_F897AB263D3561CA5D296CCFF5C5FDF512ICTitleQuery, _TtCC7NotesUI17OutlineControllerP33_0937A1AF2A2827E2462B0E48FD7819BC5Cache, _TtCE7NotesUICSo29ICCalculateDocumentController11Highlighter, _TtCE7NotesUICSo29ICCalculateDocumentController14CanvasDocument, _TtCE7NotesUICSo29ICCalculateDocumentController5Index, _TtCE7NotesUICSo29ICCalculateDocumentController7Scanner, _TtCE7NotesUICSo29ICCalculateScrubberController15HoverController, _TtCV7NotesUI14ActivityStream7Updater;

@protocol ICAccessibilityExtras, ICAccessibilityFocusedUIElementProvider, ICAccountObject, ICAttachmentFindable, ICAttachmentInsertionDelegate, ICAttachmentObject, ICAttachmentPreviewGenerating, ICAttachmentThumbnailOperation, ICAttachmentViewInitializing, ICAvailableTableWidthProviding, ICBackgroundTask, ICCalculateRecognitionControllerSuggestionsDelegate;

@protocol ICCollaborationAnalyticsDelegate, ICCollaborationControllerDelegate, ICCoreDataIndexerDelegate, ICCreateNoteAction, ICDocumentMergeControlling, ICFolderObject, ICInlineAttachmentViewAnimationDelegate, ICItemIdentifier, ICLegacyAccount, ICLegacyAttachment, ICLegacyContext, ICLegacyFolder;

@protocol ICLegacyNote, ICLegacyNoteUI, ICMClickableTextViewDelegate, ICMProgressWindowControllerDelegate, ICMZoomControllerProviding, ICMZoomableAttachmentView, ICManagedObjectContextChangeControllerDelegate, ICMentionsControllerApp, ICNoteMergeObserver, ICProgressIndicatorTrackerDelegate, ICSearchIndexable, ICSearchIndexerAppDataSource;

@protocol ICSearchIndexerDataSource, ICSectionIdentifier, ICSystemPaperTextAttachmentNotesEditorBridgeWorkaround, ICTTAttachment, ICTTMergeableStringDelegate, ICTTModelAttributeComparable, ICTTTextStorageDelegate, ICTTTextStorageScrollClampingDelegate, ICTTTextStorageStyler, ICTTTextUndoTarget, ICTableCellMergeableStringObserving, ICTableUndoHelping;

@protocol ICTextControllerDelegate, ICThumbnailCaching, ICTodoButtonDragDelegate, ICTrackedAttributeDelegate, LPAudioPlayer, LPLinkViewDelegate, NoteHTMLEditorViewActionDelegate, NoteHTMLEditorViewDelegate, NoteHTMLEditorViewLayoutDelegate, NotesCIDDataProvider, NotesImporterProtocol, PKPaperTextAttachment;

@protocol PKTextAttachment, PKTitleQueryDelegate, WKUIDelegatePrivate, _WKInputDelegate;



@protocol ICAccessibilityExtras

@required

/* required instance methods */
- (_Bool)needsAccessibilityElements;
- (void)postAnnouncement:(id)announcement withSender:(id)sender priority:(long long)priority;

@optional

@end


@protocol ICAccessibilityFocusedUIElementProvider <NSObject>

@required

/* required instance methods */
- (id)alternativeFocusedUIElement;

@optional

@end


@protocol ICAccountObject <NSObject>

@required

@property (readonly, nonatomic) NSString *localizedName;
@property (readonly, nonatomic) _Bool isLocalAccount;
@property (readonly, nonatomic) NSString *emailAddress;

/* required instance methods */
- (id)ic_accessibilityIdentifier;

@optional

@end


@protocol ICAttachmentFindable <NSObject>

@required

/* required instance methods */
- (id)rectsForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)scrollToRange:(struct _NSRange)range inFindableString:(id)string;
- (void)drawCharactersInRange:(struct _NSRange)range inFindableString:(id)string forContentView:(id)view;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string inFindableString:(id)string;
- (struct _NSRange)selectedRangeWithinRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setSelectedRange:(struct _NSRange)range inFindableString:(id)string;
- (id)viewForRange:(struct _NSRange)range inFindableString:(id)string;

@optional

@end


@protocol ICAttachmentObject <NSObject>

@required

@property (copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *typeUTI;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;

@optional

@end


@protocol ICAttachmentPreviewGenerating <NSObject>

@required

/* required instance methods */
- (void)generatePreviewIfNeededForAttachment:(id)attachment;
- (void)cancelIfNeededForAttachment:(id)attachment;
- (void)generatePreviewIfNeededForAttachmentWithObjectID:(id)id;
- (void)generatePreviewsIfNeeded;

@optional

@end


@protocol ICAttachmentThumbnailOperation

@required

/* required instance methods */
- (void)addCompletionBlock:(id /* block */)block;
- (_Bool)isMatchingOperationForCacheKey:(id)key cache:(id)cache;

@optional

@end


@protocol ICAttachmentViewInitializing <NSObject>

@required

/* required instance methods */
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;

@optional

@end


@protocol ICAvailableTableWidthProviding <NSObject>

@required

@property (readonly, nonatomic) double availableWidth;

@optional

@end


@protocol ICBackgroundTask <NSObject>

@required

/* class methods */
+ (id)makeActivityScheduler;

/* required instance methods */
- (void)runTaskWithCompletion:(id /* block */)completion;

@optional

/* optional instance methods */
- (void)didRegister:(_Bool)_register;
- (void)handleTaskExpiration;

@end


@protocol ICCollaborationAnalyticsDelegate

@required

/* required instance methods */
- (void)trackCollaborationActionSecondCancelForObject:(id)object share:(id)share isInviting:(_Bool)inviting;
- (void)trackCollaborationActionAddPeopleForObject:(id)object share:(id)share isInviting:(_Bool)inviting;
- (void)trackCollaborationActionFirstShareForObject:(id)object share:(id)share isInviting:(_Bool)inviting;
- (void)trackCollaborationActionSecondShareForObject:(id)object share:(id)share isInviting:(_Bool)inviting;
- (void)trackCollaborationNotificationAcceptanceForObject:(id)object shareURL:(id)url;
- (void)trackShareActionForNote:(id)note activityType:(id)type collaborationSelected:(_Bool)selected countOfCollaboratorsAdded:(long long)added countOfCollaboratorsRemoved:(long long)removed startInvitedCount:(long long)count startAcceptedCount:(long long)count endInvitedCount:(long long)count endAcceptedCount:(long long)count;

@optional

@end


@protocol ICCreateNoteAction <NSObject>

@required

/* required instance methods */
- (id)performWithTitle:(id)title contents:(id)contents pinned:(_Bool)pinned error:(id *)error;

@optional

@end


@protocol ICDocumentMergeControlling <NSObject>

@required

@property (weak, nonatomic) id <ICDocumentMergeControlling> parentController;
@property (readonly, copy, nonatomic) NSSet *textViews;
@property (readonly, nonatomic) _Bool isBlockingMerge;

/* required instance methods */
- (void)requestMergeWithBlock:(id /* block */)block;
- (void)removeTextView:(id)view;
- (void)addTextView:(id)view;
- (void)beginBlockingMergeForReason:(unsigned long long)reason textView:(id)view;
- (void)blockingMergeForReason:(unsigned long long)reason textView:(id)view block:(id /* block */)block;
- (void)endBlockingMergeForReason:(unsigned long long)reason textView:(id)view;

@optional

@end


@protocol ICFolderObject <NSObject>

@required

@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSString *localizedTitle;
@property (readonly, retain, nonatomic) NSManagedObject<ICAccountObject> *account;
@property (readonly, copy, nonatomic) NSManagedObject<ICFolderObject> *parentFolder;

@optional

@end


@protocol ICItemIdentifier <NSObject, NSCopying>

@required

@optional

@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;

@end


@protocol ICLegacyAccount <ICAccountObject>

@required

@property (readonly, nonatomic) _Bool enabled;
@property (nonatomic) _Bool didChooseToMigrate;
@property (readonly, nonatomic) _Bool isIMAPAccount;
@property (readonly, nonatomic) _Bool isExchangeAccount;
@property (readonly, nonatomic) _Bool isLocalAccount;
@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *allItemsFolderLocalizedTitle;
@property (readonly, copy, nonatomic) NSString *objectIdentifier;
@property (readonly, copy, nonatomic) NSString *accountIdentifier;
@property (readonly, nonatomic) long long legacyAccountType;
@property (readonly, copy, nonatomic) NSString *emailAddress;
@property (readonly, nonatomic) NSSet *folders;
@property (readonly, nonatomic) NSManagedObject<ICLegacyFolder> *defaultFolder;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) _Bool supportsAttachments;
@property (readonly, nonatomic) _Bool isManaged;
@property (readonly, nonatomic) _Bool preventMovingNotesToOtherAccounts;
@property (readonly, copy, nonatomic) NSString *localizedAttachmentsNotSupportedReason;
@property (readonly, nonatomic) _Bool hasAnyCustomFolders;

/* required instance methods */
- (long long)compare:(id)compare;

@optional

@end


@protocol ICLegacyAttachment <ICAttachmentObject>

@required

@property (readonly, copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *mimeType;
@property (copy, nonatomic) NSString *typeUTI;
@property (readonly, copy, nonatomic) NSString *contentID;
@property (readonly, copy, nonatomic) NSURL *cidURL;
@property (readonly, nonatomic) _Bool isHiddenFromIndexing;
@property (readonly, nonatomic) _Bool isHiddenFromSearch;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

/* required instance methods */
- (_Bool)persistAttachmentData:(id)data error:(id *)error;

@optional

@end


@protocol ICLegacyFolder <ICFolderObject>

@required

@property (readonly, nonatomic) id <ICLegacyAccount> account;
@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, nonatomic) id <ICLegacyFolder> parentFolder;
@property (readonly, nonatomic) NSArray *ancestorFolders;
@property (readonly, nonatomic) long long depth;
@property (readonly, nonatomic) NSSet *changes;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;
@property (readonly, nonatomic) _Bool isDefaultFolder;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) _Bool isCustomFolder;

/* required instance methods */
- (long long)compare:(id)compare;
- (void)addNotesObject:(id)object;
- (id)newNoteInContext:(id)context;

@optional

@end


@protocol ICLegacyNote <NSObject>

@required

@property (copy, nonatomic) NSString *htmlString;
@property (readonly, nonatomic) NSString *contentAsPlainText;
@property (readonly, nonatomic) id <ICLegacyAccount> account;
@property (readonly, nonatomic) id <ICLegacyFolder> folder;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) NSDate *modificationDate;
@property (readonly, nonatomic) NSSet *attachments;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) _Bool isPlainText;
@property (readonly, nonatomic) _Bool isMarkedForDeletion;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;

/* class methods */
+ (id)predicateForVisibleNotes;

/* required instance methods */
- (void)markForDeletion;
- (id)createAttachmentWithName:(id)name;

@optional

@end


@protocol ICLegacyNoteUI <NSObject>

@required

/* required instance methods */
- (_Bool)appendAttributedString:(id)string error:(id *)error;

@optional

@end


@protocol ICMClickableTextViewDelegate <NSObject>

@required

/* required instance methods */
- (void)clickableTextViewDidClick:(id)click;

@optional

@end


@protocol ICMProgressWindowControllerDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)didTapCancelButtonInProgressWindowController:(id)controller;

@end


@protocol ICMZoomControllerProviding <NSObject>

@required

@property (readonly, nonatomic) ICMZoomController *zoomController;

@optional

@end


@protocol ICMZoomableAttachmentView <NSObject>

@required

/* required instance methods */
- (void)setZoomController:(id)controller;
- (id)zoomController;
- (void)hostViewDidZoom:(id)zoom;

@optional

@end


@protocol ICManagedObjectContextChangeControllerDelegate <NSObject>

@required

/* required instance methods */
- (id)managedObjectContextChangeController:(id)controller managedObjectIDsToUpdateForUpdatedManagedObjects:(id)objects;
- (void)managedObjectContextChangeController:(id)controller performUpdatesForManagedObjectIDs:(id)ids;
- (_Bool)managedObjectContextChangeControllerShouldUpdateImmediately:(id)immediately;

@optional

@end


@protocol ICMentionsControllerApp <NSObject>

@required

@optional

/* optional instance methods */
- (void)insertMentionAttachment:(id)attachment atRange:(struct _NSRange)range viaAutoComplete:(_Bool)complete;
- (void)updateAutoCompletionView:(id)view range:(struct _NSRange)range textView:(id)view mentionString:(id)string;

@end


@protocol ICNoteMergeObserver

@required

/* required instance methods */
- (void)textStorageDidPerformMerge:(id)merge;
- (void)textStorageWillPerformMerge:(id)merge;

@optional

@end


@protocol ICProgressIndicatorTrackerDelegate <NSObject>

@required

/* required instance methods */
- (void)progressIndicatorTrackerStartAnimation;
- (void)progressIndicatorTrackerStopAnimation;

@optional

@end


@protocol ICSearchIndexable <NSObject>

@required

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly, nonatomic) long long visibilityTestingType;
@property (readonly, copy, nonatomic) NSString *searchIndexingIdentifier;
@property (readonly, copy, nonatomic) NSString *contentIdentifier;
@property (readonly, copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) NSDate *modificationDate;
@property (readonly, nonatomic) unsigned long long searchResultsSection;
@property (readonly, nonatomic) unsigned long long searchResultType;
@property (readonly, nonatomic) _Bool searchResultCanBeDeletedFromNoteContext;
@property (readonly, nonatomic) _Bool isHiddenFromIndexing;
@property (readonly, nonatomic) _Bool isHiddenFromSearch;
@property (readonly, nonatomic) _Bool isMovable;
@property (readonly, nonatomic) _Bool isDeletable;
@property (readonly, copy, nonatomic) NSString *dataSourceIdentifier;
@property (readonly, copy, nonatomic) NSString *searchDomainIdentifier;
@property (readonly, nonatomic) CSSearchableItemAttributeSet *searchableItemAttributeSet;
@property (readonly, nonatomic) CSSearchableItemAttributeSet *userActivityContentAttributeSet;

@optional

@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;

/* optional instance methods */
- (id)additionalSearchIndexablesForChangedKeys:(id)keys;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)fileURLForTypeIdentifier:(id)identifier;

@end


@protocol ICSearchIndexerAppDataSource <ICSearchIndexerDataSource>

@required

/* required instance methods */
- (id)mainThreadContext;

@optional

@end


@protocol ICSearchIndexerDataSource <NSObject>

@required

@property (readonly, nonatomic) ICSearchIndexProgressCoordinator *progressCoordinator;

/* required instance methods */
- (id)persistentStoreCoordinator;
- (id)allIndexableObjectIDsInReversedReindexingOrderWithContext:(id)context;
- (void)stopObservingChanges;
- (id)dataSourceIdentifier;
- (unsigned long long)indexingPriority;
- (void)startObservingChanges;
- (_Bool)isObservingChanges;
- (id)uuid;
- (id)newManagedObjectContext;
- (id)objectForSearchableItem:(id)item context:(id)context;
- (_Bool)needsReindexing;
- (void)clearObjectIDsToProcess;
- (long long)decisionOnObjectID:(id)id searchableItemToIndex:(id *)index additionalItemsToIndex:(id *)index objectIDURIToDelete:(id *)_delete additionalUniqueIdentifiersToDelete:(id *)_delete context:(id)context;
- (id)indexableObjectIDsWithURIs:(id)uris context:(id)context;
- (id)objectForManagedObjectIDURI:(id)iduri context:(id)context;
- (id)objectIDsNeedingProcessing;
- (void)searchIndexerDidFinishDeletingSearchableItemsWithObjectIDURIs:(id)iduris error:(id)error;
- (void)searchIndexerDidFinishIndexingObjectIDs:(id)ids searchableItems:(id)items error:(id)error;
- (void)searchIndexerWillDeleteSearchableItemsWithObjectIDURIs:(id)iduris;
- (void)searchIndexerWillIndexObjectIDs:(id)ids;
- (void)stageForReindexingWithContext:(id)context;
- (void)stageObjectIDURIsForIndexing:(id)indexing context:(id)context;

@optional

@end


@protocol ICSectionIdentifier <ICItemIdentifier>

@required

@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, nonatomic) _Bool collapsible;
@property (readonly, copy, nonatomic) NSString *expansionStateContext;

@property (class, readonly, copy, nonatomic) NSArray *sortDescriptors;

/* class methods */
+ (id)sortDescriptors;

/* required instance methods */
- (_Bool)isCollapsible;

@optional

@end


@protocol ICSystemPaperTextAttachmentNotesEditorBridgeWorkaround

@required

@property (readonly, nonatomic) _Bool insideSystemPaper;

@optional

@end


@protocol ICTTAttachment <ICTTModelAttributeComparable, NSObject>

@required

@property (readonly, copy, nonatomic) NSString *attachmentIdentifier;
@property (readonly, copy, nonatomic) NSString *attachmentUTI;

/* required instance methods */
- (id)attachmentInContext:(id)context;
- (id)inlineAttachmentInContext:(id)context;

@optional

@end


@protocol ICTTMergeableStringDelegate <NSObject>

@required

/* required instance methods */
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (void)endEditing;
- (void)beginEditing;
- (void)addUndoCommand:(id)command;
- (_Bool)wantsUndoCommands;

@optional

@end


@protocol ICTTModelAttributeComparable <NSObject>

@required

/* required instance methods */
- (_Bool)isEqualToModelComparable:(id)comparable;

@optional

@end


@protocol ICTTTextStorageDelegate <NSTextStorageDelegate>

@required

@optional

/* optional instance methods */
- (void)textStorage:(id)storage didReplace:(id)replace with:(id)with;
- (void)textStorageDidChange:(id)change;
- (void)textStorageDidPerformUndo:(id)undo;
- (void)textStorageWillChange:(id)change;

@end


@protocol ICTTTextStorageScrollClampingDelegate <NSObject>

@required

/* required instance methods */
- (void)unclampTextView;
- (void)clampTextView;
- (void)didEndPostLayoutFixupAfterEditing;
- (void)willBeginPostLayoutFixupAfterEditing;

@optional

@end


@protocol ICTTTextStorageStyler <NSObject>

@required

@property (nonatomic) _Bool isForPrint;
@property (nonatomic) _Bool isForSiri;

/* required instance methods */
- (void)guessFontSizeThresholdsForTTStylesInAttributedString:(id)string;
- (id)modelForStyleAttributes:(id)attributes filterAttributes:(_Bool)attributes;
- (id)modelForStyleAttributes:(id)attributes filterAttributes:(_Bool)attributes pasteboardAttributedString:(id)string;
- (void)prepareIndentInformationInAttributedString:(id)string;
- (void)resetGuessedFontSizes;
- (void)resetIndentInformation;
- (id)styleForModelAttributes:(id)attributes;
- (void)styleText:(id)text inRange:(struct _NSRange)range fixModelAttributes:(_Bool)attributes;

@optional

@property (nonatomic) _Bool disableAddingExtraLinesIfNeeded;
@property (retain, nonatomic) ICTTZoomController *zoomController;

/* optional instance methods */
- (void)convertNSTablesToICTables:(id)ictables pasteboardTypes:(id)types filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (void)fixTextStorage:(id)storage afterProcessingEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (void)updateHighlightsInRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)updateTrackingInTextStorage:(id)storage range:(struct _NSRange)range changeInLength:(long long)length;

@end


@protocol ICTTTextUndoTarget <NSObject>

@required

/* required instance methods */
- (void)applyUndoGroup:(id)group;

@optional

/* optional instance methods */
- (id)newCoalescingUndoGroup;

@end


@protocol ICTableCellMergeableStringObserving <NSObject>

@required

@property (readonly, nonatomic) id <ICTableUndoHelping> undoHelper;
@property (readonly, nonatomic) _Bool shouldPreventUndoCommands;

/* required instance methods */
- (void)tableCellWasEditedAtColumnID:(id)id rowID:(id)id edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;

@optional

@end


@protocol ICTextControllerDelegate <NSObject>

@required

/* required instance methods */
- (_Bool)isLinkAcceleratorShowing;

@optional

/* optional instance methods */
- (void)textControllerDidHandleSpecialCaseEditing:(id)editing;

@end


@protocol ICThumbnailCaching

@required

/* required instance methods */
- (id)objectForKeyedSubscript:(id)subscript;
- (void)setObject:(id)object forKeyedSubscript:(id)subscript;
- (void)invalidateForObjectIdentifiers:(id)identifiers;
- (id)creationDateFor:(id)_for;

@optional

@end


@protocol ICTrackedAttributeDelegate

@required

/* required instance methods */
- (void)textController:(id)controller addedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller removedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller updatedTrackedAttribute:(id)attribute;

@optional

@end


@protocol LPAudioPlayer

@required

@property (readonly, nonatomic) float progress;
@property (readonly, nonatomic) unsigned long long state;

/* required instance methods */
- (void)pause;
- (void)removeClient:(id)client;
- (void)reset;
- (void)addClient:(id)client;
- (void)play;

@optional

@end


@protocol LPLinkViewDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)_linkView:(id)view didTapCaptionButtonWithType:(long long)type;
- (id)_linkView:(id)view overrideURLForOpeningURL:(id)url;
- (id)_linkView:(id)view playerForAudio:(id)audio;
- (void)_linkView:(id)view willOpenURL:(id)url;
- (void)_linkViewMetadataDidBecomeComplete:(id)complete;
- (void)linkView:(id)view didFetchMetadata:(id)metadata;
- (void)linkViewNeedsResize:(id)resize;

@end


@protocol NotesCIDDataProvider <NSObject>

@required

/* required instance methods */
- (_Bool)getData:(id *)data mimeType:(id *)type error:(id *)error;

@optional

@end


@protocol NotesImporterProtocol

@required

/* required instance methods */
- (void)archiveEvernoteNotesFromFileURL:(id)url completionBlock:(id /* block */)block;
- (void)cleanupArchiveId:(id)id completionBlock:(id /* block */)block;
- (void)countEvernoteNotesFromFileURL:(id)url completionBlock:(id /* block */)block;
- (void)parseHTMLStringFromEvernoteContentString:(id)string completionBlock:(id /* block */)block;
- (void)parseTitleFromHTMLString:(id)htmlstring completionBlock:(id /* block */)block;
- (void)unarchiveEvernoteNoteFromArchiveId:(id)id noteArchiveId:(id)id completionBlock:(id /* block */)block;
- (void)unarchiveEvernoteResourceFromArchiveId:(id)id resourceArchiveId:(id)id completionBlock:(id /* block */)block;

@optional

@end


@protocol PKPaperTextAttachment

@required

@property (readonly, nonatomic) NSString *_paperIdentifier;
@property (readonly, nonatomic) NSURL *_paperBundleURL;
@property (readonly, nonatomic) NSURL *_encryptionDelegateCRContextURL;

/* required instance methods */
- (id)initWithPaperIdentifier:(id)identifier;

@optional

@property (readonly, nonatomic) NSURL *_nonEncryptedContentCRContextURL;

/* optional instance methods */
- (void)_linkCanvasElementsDidChange;
- (struct CGRect)_paperBoundsHint;
- (void)_paperDidChangeLocally;
- (struct CGSize)_paperSizeHint;

@end


@protocol PKTextAttachment <NSObject>

@required

@optional

/* optional instance methods */
- (void)drawingDataDidChange:(id)change view:(id)view;
- (void)resetZoom;

@end


@protocol PKTitleQueryDelegate <NSObject>

@required

/* required instance methods */
- (void)titleQuery:(id)query didUpdateWithItem:(id)item;

@optional

/* optional instance methods */
- (id)titleQueryDrawingDispatchQueue:(id)queue;

@end


@protocol WKUIDelegatePrivate <WKUIDelegate>

@required

@optional

/* optional instance methods */
- (void)_webView:(id)view shouldAllowPDFAtURL:(id)url toOpenFromFrame:(id)frame completionHandler:(id /* block */)handler;
- (_Bool)_focusWebViewFromServiceWorker:(id)worker;
- (void)_cancelImmediateActionAnimationForWebView:(id)view;
- (void)_completeImmediateActionAnimationForWebView:(id)view;
- (id)_dataDetectionContextForWebView:(id)view;
- (void)_focusWebView:(id)view;
- (void)_prepareForImmediateActionAnimationForWebView:(id)view;
- (id)_presentingViewControllerForWebView:(id)view;
- (void)_showWebView:(id)view;
- (void)_unfocusWebView:(id)view;
- (id)_webView:(id)view adjustedColorForTopContentInsetColor:(id)color;
- (void)_webView:(id)view checkUserMediaPermissionForURL:(id)url mainFrameURL:(id)url frameIdentifier:(unsigned long long)identifier decisionHandler:(id /* block */)handler;
- (id)_webView:(id)view configurationForLocalInspector:(id)inspector;
- (id)_webView:(id)view contextMenu:(id)menu forElement:(id)element;
- (id)_webView:(id)view contextMenu:(id)menu forElement:(id)element userInfo:(id)info;
- (void)_webView:(id)view createWebViewWithConfiguration:(id)configuration forNavigationAction:(id)action windowFeatures:(id)features completionHandler:(id /* block */)handler;
- (void)_webView:(id)view decideDatabaseQuotaForSecurityOrigin:(id)origin currentQuota:(unsigned long long)quota currentOriginUsage:(unsigned long long)usage currentDatabaseUsage:(unsigned long long)usage expectedUsage:(unsigned long long)usage decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view decideDatabaseQuotaForSecurityOrigin:(id)origin databaseName:(id)name displayName:(id)name currentQuota:(unsigned long long)quota currentOriginUsage:(unsigned long long)usage currentDatabaseUsage:(unsigned long long)usage expectedUsage:(unsigned long long)usage decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view decidePolicyForScreenCaptureUnmutingForOrigin:(id)origin initiatedByFrame:(id)frame decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view didAdjustVisibilityWithSelectors:(id)selectors;
- (void)_webView:(id)view didAttachLocalInspector:(id)inspector;
- (void)_webView:(id)view didChangeFontAttributes:(id)attributes;
- (void)_webView:(id)view didClickAutoFillButtonWithUserInfo:(id)info;
- (void)_webView:(id)view didInsertAttachment:(id)attachment withSource:(id)source;
- (void)_webView:(id)view didInvalidateDataForAttachment:(id)attachment;
- (void)_webView:(id)view didNotHandleWheelEvent:(id)event;
- (void)_webView:(id)view didPerformDragOperation:(_Bool)operation;
- (void)_webView:(id)view didReceiveConsoleLogForTesting:(id)testing;
- (void)_webView:(id)view didRemoveAttachment:(id)attachment;
- (void)_webView:(id)view didResignInputElementStrongPasswordAppearanceWithUserInfo:(id)info;
- (unsigned long long)_webView:(id)view dragDestinationActionMaskForDraggingInfo:(id)info;
- (void)_webView:(id)view drawFooterInRect:(struct CGRect)rect forPageWithTitle:(id)title URL:(id)url;
- (void)_webView:(id)view drawHeaderInRect:(struct CGRect)rect forPageWithTitle:(id)title URL:(id)url;
- (void)_webView:(id)view editorStateDidChange:(id)change;
- (void)_webView:(id)view getContextMenuFromProposedMenu:(id)menu forElement:(id)element userInfo:(id)info completionHandler:(id /* block */)handler;
- (void)_webView:(id)view getWindowFrameWithCompletionHandler:(id /* block */)handler;
- (void)_webView:(id)view handleAutoplayEvent:(long long)event withFlags:(unsigned long long)flags;
- (void)_webView:(id)view hasVideoInPictureInPictureDidChange:(_Bool)change;
- (void)_webView:(id)view imageOrMediaDocumentSizeChanged:(struct CGSize)changed;
- (void)_webView:(id)view includeSensitiveMediaDeviceDetails:(id /* block */)details;
- (void)_webView:(id)view mediaCaptureStateDidChange:(unsigned long long)change;
- (void)_webView:(id)view mouseDidMoveOverElement:(id)element withFlags:(unsigned long long)flags userInfo:(id)info;
- (void)_webView:(id)view printFrame:(id)frame;
- (void)_webView:(id)view printFrame:(id)frame pdfFirstPageSize:(struct CGSize)size completionHandler:(id /* block */)handler;
- (void)_webView:(id)view queryPermission:(id)permission forOrigin:(id)origin completionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestDisplayCapturePermissionForOrigin:(id)origin initiatedByFrame:(id)frame withSystemAudio:(_Bool)audio decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestGeolocationPermissionForFrame:(id)frame decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestGeolocationPermissionForOrigin:(id)origin initiatedByFrame:(id)frame decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestNotificationPermissionForSecurityOrigin:(id)origin decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestPermissionForXRSessionOrigin:(id)origin mode:(long long)mode grantedFeatures:(unsigned long long)features consentRequiredFeatures:(unsigned long long)features consentOptionalFeatures:(unsigned long long)features completionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestPermissionForXRSessionOrigin:(id)origin mode:(long long)mode grantedFeatures:(unsigned long long)features consentRequiredFeatures:(unsigned long long)features consentOptionalFeatures:(unsigned long long)features requiredFeaturesRequested:(unsigned long long)requested optionalFeaturesRequested:(unsigned long long)requested completionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestSpeechRecognitionPermissionForOrigin:(id)origin decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestStorageAccessPanelForDomain:(id)domain underCurrentDomain:(id)domain completionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestStorageAccessPanelForDomain:(id)domain underCurrentDomain:(id)domain forQuirkDomains:(id)domains completionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestUserMediaAuthorizationForDevices:(unsigned long long)devices url:(id)url mainFrameURL:(id)url decisionHandler:(id /* block */)handler;
- (void)_webView:(id)view requestWebAuthenticationConditionalMediationRegistrationForUser:(id)user completionHandler:(id /* block */)handler;
- (void)_webView:(id)view runBeforeUnloadConfirmPanelWithMessage:(id)message initiatedByFrame:(id)frame completionHandler:(id /* block */)handler;
- (void)_webView:(id)view runWebAuthenticationPanel:(id)panel initiatedByFrame:(id)frame completionHandler:(id /* block */)handler;
- (void)_webView:(id)view saveDataToFile:(id)file suggestedFilename:(id)filename mimeType:(id)type originatingURL:(id)url;
- (void)_webView:(id)view setResizable:(_Bool)resizable;
- (void)_webView:(id)view setWindowFrame:(struct CGRect)frame;
- (void)_webView:(id)view startXRSessionWithCompletionHandler:(id /* block */)handler;
- (void)_webView:(id)view supportedXRSessionFeatures:(unsigned long long *)features arFeatures:(unsigned long long *)features;
- (void)_webView:(id)view takeFocus:(long long)focus;
- (void)_webView:(id)view unavailablePlugInButtonClickedWithReason:(long long)reason plugInInfo:(id)info;
- (void)_webView:(id)view updatedAppBadge:(id)badge fromSecurityOrigin:(id)origin;
- (void)_webView:(id)view willCloseLocalInspector:(id)inspector;
- (void)_webView:(id)view willShareActivityItems:(id)items;
- (void)_webViewClose:(id)close;
- (void)_webViewDidDisableInspectorBrowserDomain:(id)domain;
- (void)_webViewDidEnableInspectorBrowserDomain:(id)domain;
- (void)_webViewDidEnterFullscreen:(id)fullscreen;
- (void)_webViewDidExitFullscreen:(id)fullscreen;
- (void)_webViewDidLosePointerLock:(id)lock;
- (void)_webViewDidRequestPointerLock:(id)lock completionHandler:(id /* block */)handler;
- (void)_webViewDidScroll:(id)scroll;
- (void)_webViewDidShowSafeBrowsingWarning:(id)warning;
- (void)_webViewEndXRSession:(id)xrsession;
- (void)_webViewEndXRSession:(id)xrsession withReason:(long long)reason;
- (double)_webViewFooterHeight:(id)height;
- (void)_webViewFullscreenMayReturnToInline:(id)_inline;
- (double)_webViewHeaderHeight:(id)height;
- (void)_webViewRecentlyAccessedGamepadsForTesting:(id)testing;
- (void)_webViewRequestPointerLock:(id)lock;
- (void)_webViewRunModal:(id)modal;
- (void)_webViewStoppedAccessingGamepadsForTesting:(id)testing;
- (void)_webViewWillEnterFullscreen:(id)fullscreen;

@end


@protocol _WKInputDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)_webView:(id)view willSubmitFormValues:(id)values frameInfo:(id)info sourceFrameInfo:(id)info userObject:(id)object requestURL:(id)url method:(id)method submissionHandler:(id /* block */)handler;
- (void)_webView:(id)view willSubmitFormValues:(id)values frameInfo:(id)info sourceFrameInfo:(id)info userObject:(id)object submissionHandler:(id /* block */)handler;
- (void)_webView:(id)view willSubmitFormValues:(id)values userObject:(id)object submissionHandler:(id /* block */)handler;
- (void)_webView:(id)view didStartInputSession:(id)session;

@end


@interface ActivityEventResolver : NSObject

/* instance methods */
- (id)init;
- (id)initWithObject:(id)object error:(id *)error;

@end


@interface ICAbstractTextAttachment : NSTextAttachment <ICTTAttachment>

@property (retain, nonatomic) ICBaseAttachment *attachment;
@property (readonly, copy, nonatomic) NSString *viewIdentifier;
@property (readonly, nonatomic) _Bool unsupported;
@property (nonatomic) double foregroundAlpha;
@property (copy, nonatomic) NSColor *highlightColor;
@property (readonly, nonatomic) _Bool containsFindableText;
@property (readonly, nonatomic) _Bool supportsMultiplePresentationSizes;
@property (readonly, nonatomic) NSArray *supportedPresentationSizes;
@property (readonly, nonatomic) _Bool supportsMultipleThumbnailsOnSameLine;
@property (readonly, copy, nonatomic) NSString *attachmentIdentifier;
@property (readonly, copy, nonatomic) NSString *attachmentUTI;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)textAttachmentWithBaseAttachment:(id)attachment;

/* instance methods */
- (_Bool)isUnsupported;
- (id)initWithData:(id)data ofType:(id)type;
- (_Bool)usesTextAttachmentView;
- (_Bool)allowsTextAttachmentView;
- (_Bool)isEqualToModelComparable:(id)comparable;
- (id)attachmentInContext:(id)context;
- (id)inlineAttachmentInContext:(id)context;
- (Class)attachmentViewClassForTextContainer:(id)container;
- (Class)attachmentViewControllerClass;
- (void)fixAttachmentForAttributedString:(id)string range:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text;
- (id)newlyCreatedViewForManualRendering:(_Bool)rendering textContainer:(id)container;
- (id)newlyCreatedViewForManualRenderingInTextContainer:(id)container;
- (id)newlyCreatedViewForTextContainer:(id)container;
- (_Bool)supportsUserConfigurablePresentationSizeForTextContainer:(id)container;

@end


@interface ICAccessibility : NSObject <ICAccessibilityExtras>

/* class methods */
+ (id)sharedInstance;
+ (id)synthesizeAccessibilityRightClickEventAtCenterOfView:(id)view;

/* instance methods */
- (_Bool)needsAccessibilityElements;
- (void)postAnnouncement:(id)announcement withSender:(id)sender priority:(long long)priority;
- (_Bool)shouldPerformLoggingForSwitchControl;
- (_Bool)shouldPerformLoggingForVoiceOver;

@end


@interface ICAccessibilityCustomizableTextFieldCell : NSTextFieldCell

/* instance methods */
- (id)accessibilityRole;
- (id)accessibilityAttributeValue:(id)value;
- (id)accessibilityAttributedStringForRange:(struct _NSRange)range;
- (struct _NSRange)accessibilityVisibleCharacterRange;

@end


@interface ICAccountPassphraseManager : NSObject

@property (readonly, nonatomic) ICAccount *account;
@property (weak, nonatomic) NSWindow *window;

/* instance methods */
- (id)initWithAccount:(id)account;
- (_Bool)removePassphrase;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;
- (void)changePassphrase:(id)passphrase toPassphrase:(id)passphrase hint:(id)hint completion:(id /* block */)completion;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint isReset:(_Bool)reset;
- (void)updateDivergedNotesFromPassphrase:(id)passphrase toAccountPassphrase:(id)passphrase completion:(id /* block */)completion;
- (void)updateDivergedNotesWithConfiguration:(id)configuration completion:(id /* block */)completion;

@end


@interface ICActivityStreamSelection : NSObject <NSCopying>

@property (copy, nonatomic) NSSet *itemIDs;
@property (copy, nonatomic) ICTTTextEditFilter *filter;
@property (copy, nonatomic) NSDate *displayDate;
@property (readonly, copy, nonatomic) NSData *encodedData;

/* class methods */
+ (id)objc_selectionFromData:(id)data;
+ (id)selectionFromData:(id)data;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithFilter:(id)filter displayDate:(id)date;
- (id)initWithItemIDs:(id)ids filter:(id)filter displayDate:(id)date;
- (id)initWithMentions:(id)mentions;
- (id)objc_encodedData;
- (id)objc_initWithMentions:(id)mentions;

@end


@interface ICAddAttachmentsManager : NSObject

/* class methods */
+ (id)sharedManager;

/* instance methods */
- (void)saveAttachments:(id)attachments toNote:(id)note textBefore:(id)before textAfter:(id)after;
- (void)saveAttachments:(id)attachments toNote:(id)note textBefore:(id)before textAfter:(id)after fetchFirst:(_Bool)first;
- (id)saveAttachmentsToNewNote:(id)note inFolder:(id)folder isSystemPaper:(_Bool)paper textBefore:(id)before textAfter:(id)after;
- (unsigned int)styleForTitleLength:(long long)length;

@end


@interface ICAddAttachmentsManagerAttachmentInfo : NSObject

@property (retain, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *mediaURL;
@property (retain, nonatomic) NSString *mediaUTI;
@property (retain, nonatomic) NSData *mediaData;
@property (retain, nonatomic) NSDictionary *metadata;
@property (retain, nonatomic) NSString *mediaFilenameExtension;
@property (retain, nonatomic) NSImage *image;
@property (retain, nonatomic) NSAttributedString *attributedContentText;
@property (readonly, nonatomic) _Bool isPhoto;
@property (readonly, nonatomic) _Bool isVideo;
@property (nonatomic) _Bool usesTemporaryFile;

/* instance methods */
- (id)description;
- (id)initWithFileURL:(id)url;
- (unsigned long long)mediaSize;
- (id)attachmentIfExistsForAccount:(id)account;
- (void)deleteTemporaryImageFileIfNecessary;

@end


@interface ICAppGroupDefaultsController : NSObject

/* class methods */
+ (id)sharedAppGroupDefaultsController;

@end


@interface ICCircleLayer : CALayer

@property double strokeWidth;
@property (nonatomic) CGColorRef strokeColor;
@property (nonatomic) CGColorRef fillColor;

/* instance methods */
- (void)drawInContext:(struct CGContext *)context;

@end


@interface ICArcLayer : ICCircleLayer

@property (nonatomic) double startAngle;
@property (nonatomic) double endAngle;
@property (nonatomic) _Bool drawClockwise;

/* instance methods */
- (void)drawInContext:(struct CGContext *)context;

@end


@interface ICAssetThumbnailCache : NSObject <ICThumbnailCaching> // (Swift)

/* class methods */
+ (id)currentVersionDate;
+ (id)shared;

/* instance methods */
- (id)objectForKeyedSubscript:(id)subscript;
- (id)init;
- (void)setObject:(id)object forKeyedSubscript:(id)subscript;
- (void)invalidateForObjectIdentifiers:(id)identifiers;
- (id)creationDateFor:(id)_for;

@end


@interface ICAttachmentBrickMapAnnotationV2 : NSObject <MKAnnotation>

@property (nonatomic) struct CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithAttachment:(id)attachment;

@end


@interface ICAttachmentBrickView : NSView <LPLinkViewDelegate, LPAudioPlayer>

@property (retain, nonatomic) NSHashTable *audioPlayerClients;
@property (nonatomic) unsigned long long playerState;
@property (nonatomic) float playbackProgress;
@property (retain, nonatomic) LPLinkView *linkView;
@property (readonly, nonatomic) unsigned long long type;
@property (retain, nonatomic) NSLayoutConstraint *widthConstraint;
@property (retain, nonatomic) NSLayoutConstraint *heightConstraint;
@property (nonatomic) _Bool waitingForMetadata;
@property (readonly, nonatomic) _Bool isMetadataComplete;
@property (nonatomic) _Bool hasPerformedInitialLayout;
@property (nonatomic) _Bool inDidFailFetchingMetadataNotification;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (weak, nonatomic) ICAttachment *attachment;
@property (weak, nonatomic) ICAddAttachmentsManagerAttachmentInfo *shareExtensionAttachmentInfo;
@property (nonatomic) _Bool selected;
@property (nonatomic) _Bool insideSystemPaper;
@property (copy, nonatomic) NSColor *highlightColor;
@property (readonly, nonatomic) double effectiveLayoutCornerRadius;
@property (readonly, nonatomic) struct CGSize computedSize;
@property (readonly, nonatomic) NSString *typeDescriptionForAccessibility;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) float progress;
@property (readonly, nonatomic) unsigned long long state;

/* class methods */
+ (id)standardBackgroundColor;
+ (_Bool)usesSmallSizeForAttachment:(id)attachment withMetadata:(id)metadata type:(unsigned long long)type insideSystemPaper:(_Bool)paper;
+ (struct CGSize)defaultBrickSize;
+ (struct CGSize)sizeForAttachment:(id)attachment usesSmallSize:(_Bool)size;

/* instance methods */
- (void)prepareForReuse;
- (id)accessibilityLabel;
- (void)pause;
- (void)removeClient:(id)client;
- (void)layout;
- (id)initWithType:(unsigned long long)type;
- (_Bool)isAccessibilityElement;
- (void)viewDidChangeEffectiveAppearance;
- (void)reset;
- (id)accessibilityValue;
- (void)reloadData;
- (void)addClient:(id)client;
- (id)accessibilityElements;
- (id)hitTest:(struct CGPoint)test;
- (void)play;
- (void)updateTitle;
- (id)_linkView:(id)view playerForAudio:(id)audio;
- (void)linkView:(id)view didFetchMetadata:(id)metadata;
- (void)linkViewNeedsResize:(id)resize;
- (void)togglePlayPause;
- (void)displaySynapseAttachmentPreview;
- (void)accentColorDidChange;
- (void)adjustSizeIfNecessary;
- (void)attachmentDidLoadNotification:(id)notification;
- (void)attachmentPreviewImagesDidUpdateNotification:(id)notification;
- (void)constrainViews;
- (void)didFailFetchingMetadataNotification:(id)notification;
- (void)displayFilePreview;
- (void)displayGenericURLPreview;
- (void)displayRemoteAttachmentPreview;
- (void)displayScannedDocumentsPreview;
- (void)displayUnsupportedAttachmentPreview;
- (void)initialAttachmentPreviewDidLoad:(id)load;
- (_Bool)isInsideSystemPaper;
- (void)mediaDidLoadNotification:(id)notification;
- (void)notifyClientsAboutSizeChangesIfNecessary;
- (void)playbackPausedNotification:(id)notification;
- (void)playbackStartedNotification:(id)notification;
- (void)playbackStoppedNotification:(id)notification;
- (void)progressChangedNotification:(id)notification;
- (struct CGRect)quickLookSourceFrameOnScreen;
- (id)quickLookTransitionImageWithContentRect:(struct CGRect *)rect;
- (void)resetPlaybackProgressAndState;
- (void)updateAttachmentBackgroundColorIfNecessary;
- (void)updateAudioClientsProgress:(float)progress;
- (void)updateAudioClientsState:(unsigned long long)state;
- (void)updateSearchHighlighting;
- (void)updateSelectionColor;
- (void)updateUIWithMetadata:(id)metadata;

@end


@interface ICAttachmentImageLoadingOperation : NSOperation

@property (retain, nonatomic) NSCache *cache;
@property (retain, nonatomic) NSManagedObjectID *attachmentObjectID;
@property (retain, nonatomic) NSURL *mediaURL;
@property (copy, nonatomic) NSString *cacheKey;
@property (nonatomic) short attachmentType;
@property (nonatomic) _Bool forceFullSizeImage;
@property (retain, nonatomic) NSMutableArray *completionHandlers;

/* instance methods */
- (void)main;
- (id /* block */)addCompletionHandler:(id /* block */)handler;
- (id)initWithCache:(id)cache attachment:(id)attachment attachmentType:(short)type forceFullSizeImage:(_Bool)image completionHandler:(id /* block */)handler;
- (void)removeCompletionHandler:(id /* block */)handler cancelIfNoneLeft:(_Bool)left;

@end


@interface ICAttachmentInsertionController : NSObject

@property (weak, nonatomic) id <ICAttachmentInsertionDelegate> attachmentDelegate;
@property (readonly, weak, nonatomic) ICNote *note;

/* instance methods */
- (id)init;
- (id)initWithNote:(id)note;
- (id)addAttachment:(id)attachment;
- (id)addAttachment:(id)attachment atTextLocation:(unsigned long long)location;
- (id)addAttachment:(id)attachment atTextRange:(struct _NSRange)range;
- (id)addInlineAttachment:(id)attachment;
- (id)addInlineAttachment:(id)attachment atTextRange:(struct _NSRange)range;
- (id)addInlineAttachment:(id)attachment atTextRange:(struct _NSRange)range textView:(id)view;
- (id)addInlineAttachment:(id)attachment inTextStorage:(id)storage atTextRange:(struct _NSRange)range;

@end


@interface ICAttachmentPreviewGenerator : NSObject <ICProgressIndicatorTrackerDelegate, ICAttachmentPreviewGenerating>

@property (retain, nonatomic) ICAttachmentPreviewGeneratorOperationQueue *asyncGeneratorQueue;
@property (retain, nonatomic) ICAttachmentPreviewGeneratorOperationQueue *costlyGeneratorQueue;
@property (retain, nonatomic) ICAttachmentPreviewGeneratorOperationQueue *generatorQueue;
@property (retain, nonatomic) NSMapTable *lastOperationForAttachmentID;
@property (retain, nonatomic) NSMutableSet *attachmentIDsPending;
@property (retain, nonatomic) NSMutableDictionary *attachmentIDsProgress;
@property (retain, nonatomic) ICAttachmentPreviewGeneratorOperationQueue *postProcessingQueue;
@property (retain, nonatomic) NSMutableOrderedSet *postProcessingIDsPending;
@property unsigned long long postProcessingRequestIndex;
@property unsigned long long previewGenerationState;
@property (retain, nonatomic) NSObject *previewQueue;
@property (retain, nonatomic) NSObject *previewProgressQueue;
@property (nonatomic) _Atomic _Bool shouldGenerateAttachmentsWhenReachable;
@property (readonly, nonatomic) _Bool previewOperationsIdle;
@property (readonly, nonatomic) NSManagedObjectContext *workerManagedObjectContext;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedGenerator;
+ (_Bool)docCamOCRGenerationEnabled;
+ (_Bool)imageClassificationEnabled;
+ (_Bool)imageOCRGenerationEnabled;
+ (void)purgeImageClassificationsInContext:(id)context;
+ (void)purgeOCRInContext:(id)context;
+ (void)setImageClassificationTemporarilyDisabled:(_Bool)disabled;
+ (_Bool)universalSearchProcessingLibraryEnabled;

/* instance methods */
- (void)suspend;
- (void)didReceiveMemoryWarning;
- (void)managedObjectContextDidSave:(id)save;
- (id)init;
- (void)reachabilityChanged:(id)changed;
- (void)dealloc;
- (void)resume;
- (void)generatePreviewIfNeededForAttachment:(id)attachment;
- (void)adjustUserTitleIfNecessaryForAttachment:(id)attachment;
- (void)attachmentDidLoad:(id)load;
- (void)attachmentNeedsPostProcessingNotification:(id)notification;
- (void)attachmentNeedsPreviewGenerationNotification:(id)notification;
- (void)attachmentWillBeDeleted:(id)deleted;
- (void)beginPostProcessingAfterDelayIfNecessaryWithForceDelay:(_Bool)delay;
- (void)cancelGenerationOfPendingPreviews;
- (void)cancelIfNeededForAttachment:(id)attachment;
- (void)disableAutomaticPreviewGeneration;
- (void)enableAutomaticPreviewGeneration;
- (void)fetchMissingOrOutdatedImageClassificationSummaryAttachmentIDsInContext:(id)context completion:(id /* block */)completion;
- (void)fetchMissingOrOutdatedMetaDataAttachmentIDsInContext:(id)context completion:(id /* block */)completion;
- (void)fetchMissingOrOutdatedOCRSummaryAttachmentIDsInContext:(id)context completion:(id /* block */)completion;
- (void)generateMissingOrOutdatedAttachmentMetaDataIfNeededInContext:(id)context;
- (void)generatePendingPreviewForAttachment:(id)attachment;
- (void)generatePendingPreviews;
- (void)generatePreviewIfNeededForAttachmentWithObjectID:(id)id;
- (void)generatePreviewsIfNeeded;
- (_Bool)isPreviewGenerationSupported;
- (void)mediaDidLoad:(id)load;
- (void)operationComplete:(id)complete;
- (void)postProcessIfNeededForAttachment:(id)attachment;
- (void)postProcessPendingPreviews;
- (void)postProcessPreviewForAttachment:(id)attachment;
- (id)progressForObjectID:(id)id;
- (void)progressIndicatorTrackerStartAnimation;
- (void)progressIndicatorTrackerStopAnimation;
- (void)setProgress:(id)progress forObjectID:(id)id;

@end


@interface ICAttachmentPreviewGeneratorOperation : NSOperation

@property (retain) NSManagedObjectID *attachmentID;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) ICAttachmentModel *attachmentModel;
@property (readonly, nonatomic) unsigned long long type;

/* instance methods */
- (void)main;
- (void)cancel;
- (id)initWithAttachmentManagedObjectID:(id)id;

@end


@interface ICAttachmentPreviewGeneratorImageClassificationOperation : ICAttachmentPreviewGeneratorOperation

@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) ICAttachmentModel *attachmentModel;

/* instance methods */
- (void)main;
- (unsigned long long)type;

@end


@interface ICAttachmentPreviewGeneratorOCROperation : ICAttachmentPreviewGeneratorOperation

@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) ICAttachmentModel *attachmentModel;

/* instance methods */
- (void)main;
- (unsigned long long)type;

@end


@interface ICAttachmentPreviewGeneratorOperationQueue : NSOperationQueue

@property (nonatomic) unsigned long long suspendCount;

/* instance methods */
- (void)suspend;
- (void)resume;
- (void)cancelOperationsForAttachment:(id)attachment;

@end


@interface ICAttachmentPreviewImageLoader : NSObject

@property (retain, nonatomic) NSImage *image;
@property (retain, nonatomic) NSImage *originalImage;
@property (retain, nonatomic) NSImage *orientedImage;
@property (retain, nonatomic) NSData *data;
@property (nonatomic) double scale;
@property (copy, nonatomic) NSArray *previewImageURLs;
@property (nonatomic) _Bool delayLoadingURLs;
@property (nonatomic) struct CGAffineTransform orientedImageTransform;
@property (copy, nonatomic) id /* block */ imageDidLoadBlock;

/* class methods */
+ (id)orientedImage:(id)image withBackground:(int)background;
+ (id)orientedImage:(id)image withTransform:(struct CGAffineTransform)transform background:(int)background backgroundTransform:(struct CGAffineTransform)transform;

/* instance methods */
- (void)loadData;
- (_Bool)canLoadImage;
- (id)initWithOriginalImage:(id)image orientedImage:(id)image data:(id)data scale:(double)scale previewImageURLs:(id)urls delayLoadingURLs:(_Bool)urls;
- (id)loadImage;
- (id)loadOrientedImage;

@end


@interface ICAttachmentSizeMenu : NSObject

@property (copy, nonatomic) NSString *title;
@property (nonatomic) short preferredViewSize;
@property (copy, nonatomic) NSArray *supportedSizes;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL selectedSizeAction;
@property (nonatomic) SEL selectedPlainLinkAction;
@property (readonly, nonatomic) _Bool supportsPlainLink;
@property (readonly, nonatomic) _Bool isOverrideVariant;

/* instance methods */
- (id)createMenuItem;
- (id)initWithTitle:(id)title preferredViewSize:(short)size supportedSizes:(id)sizes supportsPlainLink:(_Bool)link isOverrideVariant:(_Bool)variant target:(id)target selectedSizeAction:(SEL)action selectedPlainLinkAction:(SEL)action;
- (id)localizedTitleForPlainLink;
- (id)localizedTitleForSize:(short)size;
- (id)menuItemForPlainLink;
- (id)menuItemForSize:(short)size;

@end


@interface ICAttachmentThumbnailOperation : NSOperation <ICAttachmentThumbnailOperation>

@property (nonatomic) struct CGSize minSize;
@property (nonatomic) double scale;
@property (retain, nonatomic) ICAppearanceInfo *appearanceInfo;
@property (retain, nonatomic) ICThumbnailDataCache *cache;
@property (retain, nonatomic) NSString *cacheKey;
@property (copy, nonatomic) id /* block */ fallbackBlock;
@property (copy, nonatomic) id /* block */ processingBlock;
@property (weak, nonatomic) ICAttachmentThumbnailOperationQueue *queue;
@property (retain, nonatomic) NSMutableArray *completionBlocks;
@property (retain, nonatomic) NSManagedObjectID *attachmentID;
@property (nonatomic) _Bool attachmentPropertiesCaptured;
@property (retain, nonatomic) ICAttachmentPreviewImageLoader *attachmentPreviewImageLoader;
@property (retain, nonatomic) NSURL *mediaURL;
@property (nonatomic) unsigned long long imageScaling;
@property (nonatomic) _Bool showAsFileIcon;
@property (nonatomic) _Bool isMovie;

/* instance methods */
- (void)main;
- (void)addCompletionBlock:(id /* block */)block;
- (void)capturePropertiesFromAttachment:(id)attachment;
- (id)initWithAttachment:(id)attachment size:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info cache:(id)cache cacheKey:(id)key processingBlock:(id /* block */)block completionBlock:(id /* block */)block fallbackBlock:(id /* block */)block queue:(id)queue;
- (_Bool)isMatchingOperationForCacheKey:(id)key cache:(id)cache;

@end


@interface ICAttachmentThumbnailOperationQueue : NSOperationQueue

/* instance methods */
- (void)addOperationWithAttachment:(id)attachment size:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info cache:(id)cache cacheKey:(id)key processingBlock:(id /* block */)block completionBlock:(id /* block */)block fallbackBlock:(id /* block */)block;
- (id)checkPreviewImagesIntegrityOperationForAttachment:(id)attachment;

@end


@interface ICAttachmentWebModelIcon : NSObject

@property (retain, nonatomic) NSURL *url;
@property (nonatomic) _Bool scaleImageToIconSize;
@property (nonatomic) struct CGSize size;
@property (nonatomic) double scale;
@property (retain, nonatomic) NSImage *image;

/* instance methods */
- (id)description;
- (id)initWithImageURL:(id)url;
- (id)initWithFallbackURL:(id)url withSize:(struct CGSize)size;
- (id)initWithURL:(id)url withSize:(struct CGSize)size;

@end


@interface ICAttributedStringRippler : NSObject

@property (copy, nonatomic) NSAttributedString *string;
@property (nonatomic) struct _NSRange animatedRange;
@property (copy, nonatomic) NSArray *colors;
@property (copy, nonatomic) NSArray *shadowColors;
@property (copy, nonatomic) NSArray *scales;
@property (nonatomic) double startTime;
@property (nonatomic) unsigned long long preFrames;
@property (nonatomic) unsigned long long animateFrames;
@property (nonatomic) unsigned long long postFrames;
@property (nonatomic) unsigned long long delayFrames;
@property (nonatomic) _Bool reduceMotion;
@property (retain, nonatomic) NSFont *initialFont;
@property (nonatomic) double initialFontSize;
@property (readonly, nonatomic) unsigned long long currentTimeIndex;
@property (readonly, nonatomic) unsigned long long finishedTimeIndex;

/* class methods */
+ (double)refreshInterval;
+ (unsigned long long)framesPerSecond;
+ (_Bool)canAnimateString:(id)string;

/* instance methods */
- (void)start;
- (id)currentColorForGlyphIndex:(unsigned long long)index numberOfGlyphs:(unsigned long long)glyphs timeIndex:(unsigned long long)index;
- (unsigned long long)currentIndexForGlyphIndex:(unsigned long long)index numberOfGlyphs:(unsigned long long)glyphs timeIndex:(unsigned long long)index isFinished:(_Bool *)finished;
- (double)currentScaleForGlyphIndex:(unsigned long long)index numberOfGlyphs:(unsigned long long)glyphs timeIndex:(unsigned long long)index;
- (id)currentShadowColorForGlyphIndex:(unsigned long long)index numberOfGlyphs:(unsigned long long)glyphs timeIndex:(unsigned long long)index;
- (void)generateValues;
- (id)attributedStringForTimeIndex:(unsigned long long)index;
- (_Bool)finishedForTimeIndex:(unsigned long long)index;
- (id)initWithAttributedString:(id)string animatedRange:(struct _NSRange)range;

@end


@interface ICAudioController : NSObject

@property (retain, nonatomic) AVPlayer *currentPlayer;
@property (retain, nonatomic) ICAttachment *currentAttachment;
@property (retain, nonatomic) AVAsset *currentAsset;
@property (retain, nonatomic) NSObject *playbackTimeObserver;
@property (nonatomic) double pendingSeekTime;
@property (nonatomic) _Bool registeredForRemoteControlEvents;
@property (readonly, nonatomic) _Bool isPlaying;

/* class methods */
+ (void)pauseIfPlaying;
+ (id)sharedAudioController;

/* instance methods */
- (void)play:(id)play;
- (void)stop;
- (void)pause;
- (id)init;
- (void)play;
- (void)playerItemDidPlayToEndTime:(id)time;
- (void)updateNowPlayingInfo;
- (void)togglePlayPause;
- (void)skipAheadByInterval:(double)interval completion:(id /* block */)completion;
- (void)attachmentWillBeDeletedNotification:(id)notification;
- (void)notifyPaused;
- (void)notifyPlaying;
- (void)notifyStopped;
- (void)prepareToPlayAttachment:(id)attachment;
- (void)prepareToPlayAttachment:(id)attachment completion:(id /* block */)completion;
- (void)registerForRemoteControlEvents;
- (long long)remoteChangePlaybackPosition:(id)position;
- (long long)remoteChangeRate:(id)rate;
- (long long)remotePause:(id)pause;
- (long long)remotePlay:(id)play;
- (long long)remoteSkipBackward:(id)backward;
- (long long)remoteSkipForward:(id)forward;
- (long long)remoteStop:(id)stop;
- (long long)remoteTogglePlayPause:(id)pause;
- (void)seekToTime:(double)time completion:(id /* block */)completion;
- (void)skipBackByInterval:(double)interval completion:(id /* block */)completion;
- (void)unregisterForRemoteControlEvents;
- (void)updateTime:(double)time duration:(double)duration;

@end


@interface ICAudioRecordingManager : NSObject

/* class methods */
+ (_Bool)isRecording;
+ (_Bool)isPaused;
+ (id)currentAttachment;
+ (void)cancelCurrentAudioRecordingSessionWithCompletionHandler:(id /* block */)handler;

/* instance methods */
- (id)init;

@end


@interface ICBaseTextAttachment : ICAbstractTextAttachment

@property (retain, nonatomic) ICAttachment *attachment;

/* instance methods */
- (id)image;
- (_Bool)isUnsupported;
- (id)initWithAttachment:(id)attachment;
- (id)attachmentIdentifier;
- (id)attachmentInContext:(id)context;
- (id)attachmentUTI;
- (id)inlineAttachmentInContext:(id)context;
- (id)attachmentAttributesForAttributedString;
- (_Bool)canDragWithoutSelecting;
- (short)effectiveAttachmentViewSizeForTextContainer:(id)container;
- (void)fixAttachmentForAttributedString:(id)string range:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text;
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (_Bool)supportsUserConfigurablePresentationSizeForTextContainer:(id)container;
- (double)viewCornerRadius;

@end


@interface ICTextAttachment : ICBaseTextAttachment

/* class methods */
+ (double)defaultAttachmentThumbnailViewHeight;
+ (Class)textAttachmentClassForAttachment:(id)attachment;
+ (_Bool)textAttachmentIsContent:(id)content;
+ (id)textAttachmentWithAttachment:(id)attachment;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (_Bool)isUnsupported;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)initWithData:(id)data ofType:(id)type;
- (double)availableWidthForTextContainer:(id)container;
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (id)attachmentAsNSTextAttachment;
- (struct CGRect)attachmentBoundsIncludingMarginsFromAttachmentBounds:(struct CGRect)bounds;
- (struct { double x0; double x1; double x2; double x3; })attachmentBoundsMargins;
- (id)attachmentFileWrapper;
- (struct CGSize)attachmentSizeForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment;
- (_Bool)requiresSpaceAfterAttachmentForPrinting;

@end


@interface ICBrickTextAttachment : ICTextAttachment

/* instance methods */
- (id)supportedPresentationSizes;
- (double)viewCornerRadius;

@end


@interface ICAudioTextAttachment : ICBrickTextAttachment

@property (nonatomic, readonly) NSArray *supportedPresentationSizes;

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithData:(id)data ofType:(id)type;
- (id)initWithAttachment:(id)attachment;

@end


@interface ICAuthentication : NSObject

@property (retain, nonatomic) id currentAuthenticationController;
@property (readonly, nonatomic) _Bool authenticating;

/* class methods */
+ (id)shared;

/* instance methods */
- (_Bool)isAuthenticating;
- (void)authenticateBiometricsWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)authenticateCloudPasswordWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)authenticateCustomPasswordWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)authenticateDevicePasswordWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)authenticateWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)didAuthenticateBiometricsWithPrompt:(id)prompt error:(id)error displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)didAuthenticateCloudPasswordWithPrompt:(id)prompt result:(unsigned long long)result displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)didAuthenticateCustomPasswordWithPrompt:(id)prompt result:(unsigned long long)result displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)didAuthenticateDevicePasswordWithPrompt:(id)prompt error:(id)error displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)didAuthenticateWithPrompt:(id)prompt result:(unsigned long long)result displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)setBiometricsEnabled:(_Bool)enabled account:(id)account;
- (void)setCustomPasswordWithPrompt:(id)prompt displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)updateUserRecordForAccount:(id)account completionHandler:(id /* block */)handler;

@end


@interface ICAuthenticationAlert : NSObject

@property (nonatomic) _Bool prefersSheet;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *actionTitle;
@property (nonatomic) _Bool actionIsDestructive;
@property (copy, nonatomic) NSString *dismissTitle;
@property (copy, nonatomic) id /* block */ shouldPresentHandler;
@property (copy, nonatomic) id /* block */ actionHandler;
@property (copy, nonatomic) id /* block */ dismissHandler;
@property (readonly, nonatomic) _Bool shouldPresent;

/* class methods */
+ (id)customPasswordConfirmationAlert;
+ (id)aboutLockedNotesInfoAlert;
+ (id)cannotAddAttachmentsInfoAlertWithAttachmentCount:(unsigned long long)count;
+ (id)cannotLockInfoAlertWithReason:(unsigned long long)reason;
+ (id)cannotSetCustomPasswordInfoAlert;
+ (id)cannotUnlockInfoAlert;
+ (id)customAccountNameForAccount:(id)account;
+ (id)devicePasswordIncompatibleConfirmationAlertWithAccount:(id)account incompatibilityMessage:(id)message;
+ (id)enableBiometricsActionAlertShownKeyWithAccount:(id)account;
+ (id)enableBiometricsActionAlertWithAccount:(id)account;
+ (id)enableKeychainActionAlert;
+ (id)forgotCustomPasswordSwitchAnywayConfirmationAlert;
+ (id)incorrectCustomPasswordInfoAlertWithObject:(id)object showHint:(_Bool)hint;
+ (id)keychainItemMissingInfoAlert;
+ (void)markSwitchToDevicePasswordPromptPresentedForAccount:(id)account;
+ (id)messageForPreventLockReason:(unsigned long long)reason;
+ (id)mismatchedCustomPasswordInfoAlert;
+ (id)missingCustomPasswordInfoAlert;
+ (void)presentAlertsIfNeeded:(id)needed window:(id)window completionHandler:(id /* block */)handler;
+ (id)rememberCustomPasswordInfoAlertPresentedKeyForAccount:(id)account;
+ (id)rememberCustomPasswordInfoAlertWithAccount:(id)account;
+ (id)resetCustomPasswordConfirmationAlertWithAccount:(id)account;
+ (id)resetCustomPasswordInfoAlertWithAccount:(id)account;
+ (void)resetPresentationsForAccount:(id)account;
+ (id)setDevicePasswordActionAlert;
+ (id)setDevicePasswordInfoAlert;
+ (_Bool)shouldPresentSwitchToDevicePasswordPromptForAccount:(id)account;
+ (id)signIntoCloudAccountActionAlertWithAccount:(id)account;
+ (id)switchToDevicePasswordInSettingsInfoAlertWithAccount:(id)account;
+ (id)switchToDevicePasswordPromptPresentedCountKeyForAccount:(id)account;
+ (id)switchedModeInfoAlertWithAccount:(id)account;
+ (id)switchedToCustomPasswordModeInfoAlertWithAccount:(id)account;
+ (id)switchedToDevicePasswordModeInfoAlertWithAccount:(id)account;
+ (id)updateDivergedCustomPasswordAttachmentsActionAlert;
+ (id)updateDivergedCustomPasswordModeActionAlertWithAccount:(id)account incompatibilityMessage:(id)message;
+ (id)updateDivergedCustomPasswordNotesActionAlert;
+ (id)updateDivergedDevicePasswordModeActionAlertWithAccount:(id)account;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (unsigned long long)hash;
- (void)presentInWindow:(id)window completionHandler:(id /* block */)handler;

@end


@interface ICAuthenticationPrompt : NSObject

@property (readonly, copy, nonatomic) NSString *customAccountName;
@property (readonly, copy, nonatomic) NSString *deviceAccountName;
@property (readonly, copy, nonatomic) NSString *cloudAccountName;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) NSString *touchBarReason;
@property (copy, nonatomic) NSString *fallbackButtonTitle;
@property (nonatomic) _Bool internetReachable;
@property (copy, nonatomic) NSArray *notes;
@property (readonly, copy, nonatomic) NSArray *unauthenticatedNotes;
@property (nonatomic) _Bool biometricAuthenticationEnabled;
@property (nonatomic) long long biometricAuthenticationType;
@property (nonatomic) _Bool keychainAvailable;
@property (nonatomic) _Bool hasKeychainItem;
@property (nonatomic) _Bool hasCloudAccount;
@property (nonatomic) _Bool hasDevicePassword;
@property (nonatomic) unsigned long long authenticationAction;
@property (nonatomic) unsigned long long authenticationMechanism;
@property (copy, nonatomic) NSArray *successAlerts;
@property (copy, nonatomic) NSArray *failureAlerts;
@property (readonly, nonatomic) unsigned long long intent;
@property (nonatomic) short secondaryAuthenticationMode;
@property (readonly, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) ICAccount *account;
@property (readonly, nonatomic) ICNote *note;
@property (nonatomic) _Bool usesSecondaryAuthenticationIfAvailable;
@property (nonatomic) _Bool usesAlternativeAuthenticationIfAvailable;
@property (nonatomic) _Bool usesBiometricAuthenticationIfAvailable;
@property (nonatomic) _Bool updatesUserRecordIfNeeded;
@property (readonly, nonatomic) ICCloudSyncingObject *authenticationObject;
@property (readonly, nonatomic) _Bool allowsAuthentication;
@property (readonly, nonatomic) _Bool needsAuthentication;
@property (readonly, nonatomic) _Bool needsSecondaryAuthentication;
@property (readonly, nonatomic) _Bool needsUserRecordUpdate;
@property (readonly, nonatomic) _Bool allowsAlternativeAuthentication;
@property (readonly, nonatomic) _Bool allowsCustomPasswordAuthentication;
@property (readonly, nonatomic) _Bool allowsDevicePasswordAuthentication;
@property (readonly, nonatomic) _Bool allowsBiometricAuthentication;
@property (readonly, nonatomic) _Bool unlocksNotes;

/* class methods */
+ (id)promptForChangingMode:(short)mode account:(id)account;
+ (id)promptForDeletingNotes:(id)notes;
+ (id)promptForIntent:(unsigned long long)intent object:(id)object;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)update;
- (id)description;
- (unsigned long long)hash;
- (_Bool)isInternetReachable;
- (void)updateStrings;
- (_Bool)forcesAlternativeAuthentication;
- (_Bool)forcesBiometricAuthentication;
- (_Bool)forcesSecondaryAuthentication;
- (_Bool)hasDivergedKey;
- (_Bool)hasPassphrase;
- (id)initWithIntent:(unsigned long long)intent object:(id)object;
- (_Bool)isBiometricAuthenticationEnabled;
- (_Bool)isKeychainAvailable;
- (_Bool)needsCloudAccount;
- (_Bool)needsDevicePassword;
- (_Bool)needsKeychain;
- (void)updateStringsForAddLock;
- (void)updateStringsForChangeMode;
- (void)updateStringsForChangeModeFrom;
- (void)updateStringsForChangeModeTo;
- (void)updateStringsForChangePassword;
- (void)updateStringsForDeleteMixedNotes;
- (void)updateStringsForDeleteMultipleNotes;
- (void)updateStringsForDeleteNotes;
- (void)updateStringsForDeleteSingleNote;
- (void)updateStringsForRemoveLock;
- (void)updateStringsForResetPassword;
- (void)updateStringsForToggleBiometrics;
- (void)updateStringsForViewAttachment;
- (void)updateStringsForViewNote;

@end


@interface ICAuthorHighlightAnimation : NSObject

@property (copy, nonatomic) NSNumber *duration;
@property (copy, nonatomic) NSNumber *fromValue;
@property (copy, nonatomic) NSNumber *toValue;
@property (copy, nonatomic) NSColor *color;
@property (nonatomic) _Bool aboveExistingHighlights;
@property (nonatomic) _Bool removedOnCompletion;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (_Bool)isRemovedOnCompletion;
- (_Bool)isAboveExistingHighlights;

@end


@interface ICAuthorHighlightAnimationAttribute : NSObject <NSCopying>

@property (copy, nonatomic) NSDate *startDate;
@property (nonatomic) double duration;
@property (nonatomic) double fromValue;
@property (nonatomic) double toValue;
@property (copy, nonatomic) NSColor *color;
@property (nonatomic) _Bool aboveExistingHighlights;
@property (nonatomic) _Bool removedOnCompletion;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)isRemovedOnCompletion;
- (id)initWithStartDate:(id)date;
- (_Bool)isAboveExistingHighlights;

@end


@interface ICAuthorHighlightValue : NSObject

@property (copy, nonatomic) NSNumber *value;
@property (copy, nonatomic) NSColor *color;
@property (nonatomic) _Bool aboveImplicitHighlights;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (_Bool)isAboveImplicitHighlights;

@end


@interface ICAuthorHighlightValueAttribute : NSObject <NSCopying>

@property (nonatomic) double value;
@property (copy, nonatomic) NSColor *color;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICAuthorHighlightsController : NSObject

@property (nonatomic) double fadedMultiplier;
@property (nonatomic) double highlightedMultiplier;
@property (readonly, nonatomic) ICTTTextEditGrouper *editGrouper;
@property (readonly, nonatomic) NSMutableSet *textStorageDocumentsBeingUpdated;
@property (readonly, nonatomic) NSCache *editGroupsForTextStorageDocument;
@property (copy, nonatomic) NSDate *now;
@property (readonly, nonatomic) NSMutableSet *textStorageDocumentsNeedingHighlightUpdates;
@property (readonly, nonatomic) NSView *targetView;
@property (readonly, nonatomic) ICViewTrackingDisplayLink *highlightAnimationsDisplayLink;
@property (nonatomic) struct _NSRange invalidHighlightsRange;
@property (weak, nonatomic) ICTTTextStorage *invalidHighlightsTextStorage;
@property (readonly, nonatomic) ICNote *note;
@property (readonly, nonatomic) NSTextLayoutManager *textLayoutManager;
@property (nonatomic) _Bool allowsAnimations;
@property (nonatomic) _Bool coalesceAuthorHighlightUpdates;

/* instance methods */
- (_Bool)isAnimating;
- (void)dealloc;
- (id)attributesForHighlightingTextLineFragment:(id)fragment characterRange:(struct _NSRange)range defaultRenderingAttributes:(id)attributes effectiveRange:(struct _NSRange *)range textView:(id)view;
- (id)editGroupsForTextStorage:(id)storage;
- (void)extendHighlightsForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)extendHighlightsForRange:(struct _NSRange)range inTextStorage:(id)storage reverse:(_Bool)reverse;
- (void)flashHighlightsForRange:(struct _NSRange)range withDuration:(id)duration inTextStorage:(id)storage;
- (id)highlightColorForUserID:(id)id;
- (id)highlightsAttributedStringForTextStorage:(id)storage;
- (id)initWithNote:(id)note targetView:(id)view;
- (id)initWithNote:(id)note targetView:(id)view textLayoutManager:(id)manager;
- (_Bool)isPerformingHighlightUpdatesForTextStorage:(id)storage;
- (void)performHighlightUpdatesForRange:(struct _NSRange)range inTextStorage:(id)storage updates:(id /* block */)updates;
- (_Bool)rangeHasOrNeedsHighlights:(struct _NSRange)highlights inTextStorage:(id)storage;
- (void)removeHighlightAnimationsForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)removeHighlightValuesForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setAttachmentHighlightValue:(double)value highlightColor:(id)color forRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setCheckmarkHighlightValue:(double)value highlightColor:(id)color forRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setHighlightAnimation:(id)animation forRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setHighlightAttributesForHighlightValue:(double)value highlightColor:(id)color forRange:(struct _NSRange)range inTextStorage:(id)storage editGroups:(id)groups;
- (void)setHighlightValue:(id)value forRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setTextHighlightValue:(double)value highlightColor:(id)color blendsTextColor:(_Bool)color forRange:(struct _NSRange)range inTextStorage:(id)storage;
- (_Bool)shouldAnimateInTextStorage:(id)storage;
- (void)textStorageDidProcessEndEditing:(id)editing;
- (void)updateDerivedConfiguration;
- (void)updateHighlightAnimationsIfNeeded;
- (void)updateHighlightAttributesForRange:(struct _NSRange)range inTextStorage:(id)storage;

@end


@interface ICBaseAttachmentView : NSView

@property (retain, nonatomic) ICAttachment *attachment;
@property (weak, nonatomic) ICTextAttachment *textAttachment;
@property (nonatomic) _Bool selected;
@property (nonatomic) struct CGSize attachmentContentSize;
@property (nonatomic) double foregroundAlpha;
@property (copy, nonatomic) NSColor *highlightColor;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (readonly, nonatomic) NSImage *imageForPrinting;

/* instance methods */
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)updateHighlights;
- (void)contentSizeCategoryDidChange;
- (void)attachmentPreviewImagesDidUpdate:(id)update;
- (_Bool)cancelDidScrollIntoVisibleRange;
- (void)addKVObserversForAttachment:(id)attachment;
- (void)attachmentDidChangeSize:(id)size;
- (void)attachmentDidLoad:(id)load;
- (void)attachmentWillBeDeleted:(id)deleted;
- (void)didChangeAttachment;
- (void)didChangeAttachmentTitle;
- (void)didChangeMedia;
- (void)didChangeMergeableData;
- (void)didChangeSize;
- (void)didScrollIntoVisibleRange;
- (void)didScrollOutOfVisibleRange;
- (void)didUpdatePreviewImages;
- (void)mediaDidLoad:(id)load;
- (void)removeKVOObserversForAttachment:(id)attachment;
- (void)willChangeAttachment;
- (void)willDeleteAttachment;

@end


@interface ICBaseLayoutManager : NSLayoutManager

@property (weak, nonatomic) NSTextView *textView;

/* class methods */
+ (id)defaultLinkTextAttributes;

/* instance methods */
- (id)textContainer;
- (id)textController;
- (double)bulletYOffsetForCharacterAtIndex:(unsigned long long)index;
- (void)drawBulletsForListRange:(struct _NSRange)range paragraphStyle:(id)style atPoint:(struct CGPoint)point;
- (void)drawDividerLinesForCharacterRange:(struct _NSRange)range atPoint:(struct CGPoint)point;
- (void)drawListStylesForCharacterRange:(struct _NSRange)range atPoint:(struct CGPoint)point;

@end


@interface ICButtonItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly, copy, nonatomic) NSString *displayText;
@property (readonly, copy, nonatomic) NSString *systemImageName;
@property (readonly, nonatomic) long long style;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithType:(long long)type parentIdentifier:(id)identifier;

@end


@interface ICCalculateAccessibilityController : NSObject

@property (nonatomic, weak) ICNote *note;

/* instance methods */
- (id)init;
- (id)initWithNote:(id)note;
- (id)getValueForPencilKitAttachmentAtRange:(struct _NSRange)range;

@end


@interface ICCalculateDocumentController : NSObject

@property (nonatomic, weak) ICNote *note;
@property (nonatomic, readonly) _Bool isUpdating;
@property (nonatomic, readonly) _Bool hasExpressions;
@property (nonatomic, readonly) NSIndexSet *expressionsIndexSet;
@property (nonatomic) _Bool isExpressionFormattingEnabled;
@property (nonatomic, readonly) _Bool isCalculateMathEnabled;

/* instance methods */
- (void)performUpdate;
- (void)cancelUpdate;
- (id)init;
- (id)initWithNote:(id)note;
- (_Bool)updateHighlights;
- (void)formatExpressionsInAttributedString:(id)string range:(struct _NSRange)range textStorageOffset:(long long)offset skipStaleExpressions:(_Bool)expressions;
- (void)resetHighlights;
- (id)errorFailureReasonForResultAttachment:(id)attachment;
- (id)errorFullStringForResultAttachment:(id)attachment;
- (id)errorNameForResultAttachment:(id)attachment;
- (struct _NSRange)expressionRangeForResultAttachment:(id)attachment;
- (id)expressionStringForResultAttachment:(id)attachment;
- (void)noteDidChangeCalculatePreviewBehavior:(id)behavior;
- (void)noteDidPerformMerge:(id)merge;
- (id)numberLiteralAtLocation:(long long)location;
- (void)scheduleUpdateAffectingChangeCounts:(_Bool)counts isHighPriority:(_Bool)priority;
- (void)textStorageDidProcessEndEditing:(id)editing;
- (void)undoManagerDidRedo:(id)redo;
- (void)undoManagerDidUndo:(id)undo;
- (_Bool)updateAffectingChangeCounts:(_Bool)counts;
- (void)updateAffectingChangeCounts:(_Bool)counts completion:(id /* block */)completion;

@end


@interface ICInlineAttachmentView : NSView <NSGestureRecognizerDelegate, ICAttachmentViewInitializing>

@property (retain, nonatomic) NSTextField *textField;
@property (retain, nonatomic) ICViewTrackingDisplayLink *rippleAnimationDisplayLink;
@property (retain, nonatomic) ICAttributedStringRippler *rippler;
@property (readonly, nonatomic) NSColor *searchHighlightColor;
@property (retain, nonatomic) NSTrackingArea *trackingArea;
@property (readonly, nonatomic) NSClickGestureRecognizer *clickGestureRecognizer;
@property (weak, nonatomic) ICInlineTextAttachment *textAttachment;
@property (nonatomic) double textContainerWidth;
@property (nonatomic) _Bool selected;
@property (readonly, nonatomic) _Bool isLinkAttachmentView;
@property (readonly, nonatomic) _Bool isCalculateResultAttachmentView;
@property (copy, nonatomic) NSDictionary *surroundingAttributes;
@property (readonly, nonatomic) double baselineOffsetFromBottom;
@property (readonly, nonatomic) NSImage *imageForPrinting;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (weak, nonatomic) id <ICInlineAttachmentViewAnimationDelegate> delegate;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)gestureRecognizer:(id)recognizer shouldBeRequiredToFailByGestureRecognizer:(id)recognizer;
- (id)accessibilityLabel;
- (_Bool)isSelected;
- (void)updateTrackingAreas;
- (void)viewDidChangeEffectiveAppearance;
- (void)dealloc;
- (id)accessibilityIdentifier;
- (id)accessibilityRole;
- (struct CGSize)intrinsicContentSize;
- (void)viewDidMoveToWindow;
- (id)accessibilityHelp;
- (void)cursorUpdate:(id)update;
- (_Bool)gestureRecognizer:(id)recognizer shouldAttemptToRecognizeWithEvent:(id)event;
- (void)updateLabel;
- (void)updateHighlightsWithAttributes:(id)attributes;
- (void)animateInsertionIfNecessary;
- (void)attachmentDataChanged:(id)changed;
- (void)beginRippleAnimation;
- (void)didClick:(id)click;
- (void)endRippleAnimation;
- (id)imageForTextPreviewInRange:(struct _NSRange)range;
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)updateRippleAnimation;
- (void)updateStyleWithAttributes:(id)attributes;

@end


@interface ICCalculateGraphExpressionAttachmentView : ICInlineAttachmentView

@end


@interface ICInlineTextAttachment : ICAbstractTextAttachment

@property (retain, nonatomic) ICInlineAttachment *attachment;

/* class methods */
+ (id)imageCache;
+ (Class)textAttachmentClassForAttachment:(id)attachment;
+ (id)textAttachmentWithAttachment:(id)attachment;

/* instance methods */
- (id)accessibilityLabel;
- (_Bool)isUnsupported;
- (id)displayText;
- (id)imageForBounds:(struct CGRect)bounds attributes:(id)attributes location:(id)location textContainer:(id)container;
- (id)altText;
- (id)initWithAttachment:(id)attachment;
- (id)attachmentIdentifier;
- (id)attachmentInContext:(id)context;
- (id)attachmentUTI;
- (id)inlineAttachmentInContext:(id)context;
- (id)attachmentAttributesForAttributedString;
- (Class)attachmentViewClassForTextContainer:(id)container;
- (void)fixAttachmentForAttributedString:(id)string range:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text;
- (id)printableTextContentForAppearanceType:(unsigned long long)type styleAttributes:(id)attributes textContainer:(id)container;

@end


@interface ICCalculateGraphExpressionTextAttachment : ICInlineTextAttachment

@end


@interface ICInlineAttachmentUIModel : NSObject

@property (readonly, weak, nonatomic) ICInlineAttachment *attachment;
@property (readonly, nonatomic) NSColor *labelColor;
@property (readonly, nonatomic) _Bool fadesColorDuringHighlight;
@property (nonatomic) _Bool selected;

/* class methods */
+ (id)attributesForInlineAttachmentUIModel;
+ (id)filteredStyleAttributes:(id)attributes;

/* instance methods */
- (_Bool)isSelected;
- (id)initWithAttachment:(id)attachment;
- (id)attributedStringWithSurroundingAttributes:(id)attributes formatter:(id /* block */)formatter;
- (id)highlightingAttributedString:(id)string withRegexMatches:(id)matches;
- (id)highlightingAttributedString:(id)string withSurroundingAttributes:(id)attributes;

@end


@interface ICCalculateGraphExpressionUIModel : ICInlineAttachmentUIModel

/* instance methods */
- (id)labelColor;
- (id)attributedStringWithSurroundingAttributes:(id)attributes formatter:(id /* block */)formatter;

@end


@interface ICCalculateHighlightAttribute : NSObject <NSCopying>

@property (nonatomic) unsigned long long type;
@property (retain, nonatomic) NSArray *errors;
@property (readonly, copy, nonatomic) NSColor *color;
@property (readonly, nonatomic) long long underlineStyle;
@property (readonly, copy, nonatomic) NSColor *underlineColor;
@property (readonly, copy, nonatomic) NSString *tooltip;
@property (readonly, copy, nonatomic) NSArray *suggestions;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICCalculatePreviewBehaviorMenu : NSObject

@property (nonatomic, weak) ICNote *note;
@property (nonatomic, readonly) _Bool isMathEnabled;

/* instance methods */
- (id)init;
- (void)didSelectCalculatePreviewBehavior:(id)behavior;
- (id)initWithNote:(id)note isMathEnabled:(_Bool)enabled;
- (id)makeMenuItem;

@end


@interface ICCalculateRecognitionController : NSObject

@property (nonatomic, weak) ICNote *note;
@property (nonatomic, weak) NSTextView *textView;
@property (nonatomic, weak) ICAttachmentInsertionController *attachmentInsertionController;
@property (nonatomic, weak) id <ICCalculateRecognitionControllerSuggestionsDelegate> suggestionsDelegate;
@property (nonatomic) _Bool insertsResults;
@property (nonatomic) long long previewBehavior;
@property (nonatomic, readonly) _Bool isPreviewingResult;

/* instance methods */
- (id)init;
- (id)initWithNote:(id)note;
- (void)commitPreviewedResultAtRange:(struct _NSRange)range asLiteral:(_Bool)literal;
- (void)didInsertString:(id)string atRange:(struct _NSRange)range;
- (void)didUnmarkString:(id)string atRange:(struct _NSRange)range;
- (void)discardPreviewedResult;
- (void)insertLiteralResultAtRange:(struct _NSRange)range;
- (void)insertResultAtRange:(struct _NSRange)range;
- (void)previewResultAtRange:(struct _NSRange)range;
- (void)willUpdateMarkedText:(id)text;

@end


@interface ICCalculateResultAttachmentView : ICInlineAttachmentView

/* instance methods */
- (id)accessibilityRole;
- (id)accessibilityHelp;
- (id)accessibilityValueDescription;
- (id)axValue;
- (id)calculateResultTextAttachment;

@end


@interface ICCalculateResultTextAttachment : ICInlineTextAttachment

@property (readonly, copy, nonatomic) NSString *expression;
@property (readonly, nonatomic) struct _NSRange expressionRangeInTextStorage;
@property (readonly, copy, nonatomic) NSString *localizedError;

/* instance methods */
- (id)calculateDocumentController;

@end


@interface ICCalculateResultUIModel : ICInlineAttachmentUIModel

/* instance methods */
- (id)labelColor;
- (id)attributedStringWithSurroundingAttributes:(id)attributes formatter:(id /* block */)formatter;

@end


@interface ICCalculateScrubberController : NSObject

@property (nonatomic, retain) ICNumberLiteral *numberLiteral;
@property (nonatomic, readonly) NSTextView *textView;
@property (nonatomic, retain) ICNote *note;
@property (nonatomic, readonly) _Bool isScrubbing;
@property (nonatomic, retain) NSView *scrubberView;
@property (nonatomic, retain) _TtCE7NotesUICSo29ICCalculateScrubberController15HoverController *hoverController;
@property (nonatomic) _Bool isBlockingMerge;
@property (nonatomic) _Bool isPausingUndoActions;
@property (nonatomic, readonly) _Bool isShowing;
@property (nonatomic, retain) NSPopover *popover;

/* instance methods */
- (id)init;
- (id)initWithTextView:(id)view;
- (void)dealloc;
- (void)updateText:(id)text;
- (void)hideScrubber;
- (void)resetHoverTimer;
- (void)deselectText;
- (void)didBeginScrub;
- (void)didEndScrub;
- (void)endBlockingMerge;
- (void)endPausingUndoActions;
- (void)hideIfNotScrubbing;
- (void)outlineControllerCollapsedStateDidChange:(id)change;
- (void)setHoveredCharacterIndex:(long long)index;
- (void)showScrubberForNumberLiteral:(id)literal isCompact:(_Bool)compact;
- (void)startBlockingMerge;
- (void)startPausingUndoActions;

@end


@interface ICCalculateStringScanner : NSObject

@property (weak, nonatomic) ICTTTextStorage *textStorage;

/* instance methods */
- (id)initWithTextStorage:(id)storage;
- (id)offsetsForInlineAttachment:(id)attachment;
- (id)replacementForAttachment:(id)attachment;
- (id)scanStringforRange:(struct _NSRange)range previewedExpressionString:(id)string;

@end


@interface ICCheckmarkAuthorHighlightValueAttribute : NSObject <NSCopying>

@property (nonatomic) double foregroundAlpha;
@property (copy, nonatomic) NSColor *highlightColor;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICCollaborationAnalyticsTracker : NSObject

@property (retain, nonatomic) ICCollaborationAnalyticsTrackerInternal *collaborationAnalyticsTracker;

/* instance methods */
- (id)initWithDelegate:(id)delegate;
- (void)saveActivityType:(id)type isCollaborationSelected:(_Bool)selected error:(id)error completed:(_Bool)completed forNote:(id)note;
- (void)saveNewShare:(id)share forNote:(id)note;
- (void)trackShare:(id)share forNote:(id)note;
- (void)unshareNote:(id)note;

@end


@interface ICCollaborationAnalyticsTrackerInternal : NSObject

/* instance methods */
- (id)initWithDelegate:(id)delegate;
- (id)init;
- (void)dealloc;
- (void)saveActivityType:(id)type isCollaborationSelected:(_Bool)selected error:(id)error completed:(_Bool)completed forNote:(id)note;
- (void)saveNewShare:(id)share forNote:(id)note;
- (void)trackShare:(id)share forNote:(id)note;
- (void)unshareNote:(id)note;

@end


@interface ICCollaborationColorManager : NSObject

@property (retain, nonatomic) NSMutableDictionary *userIDToColorsDict;
@property (retain, nonatomic) NSMutableArray *colorUsageCounts;
@property (nonatomic) unsigned long long colorUsageCountMinimum;

/* class methods */
+ (id)defaultColor;
+ (id)participantColors;

/* instance methods */
- (id)init;
- (id)baseColorValuesForUserID:(id)id;
- (id)containerScopedUserRecordNameForAccount:(id)account;
- (id)highlightColorForUserID:(id)id note:(id)note;
- (id)participantAXDisplayNameForUserID:(id)id forNote:(id)note;

@end


@interface ICCollaborationController : NSObject

@property (retain, nonatomic) ICCollaborationAnalyticsTracker *collaborationAnalyticsTracker;
@property (readonly, nonatomic) ICSelectorDelayer *updateSharesDelayer;
@property (retain, nonatomic) NSMutableDictionary *ckShareIDToRootRecordID;
@property (nonatomic) _Bool isDaemonProcess;
@property (weak, nonatomic) id <ICCollaborationControllerDelegate> collaborationControllerDelegate;
@property (weak, nonatomic) id <ICCollaborationAnalyticsDelegate> collaborationAnalyticsDelegate;

/* class methods */
+ (id)sharedInstance;
+ (void)didFailToUpdateShareWithError:(id)error;
+ (void)genericShareErrorAlert:(id /* block */)alert;
+ (id)highlightColorForUserID:(id)id inNote:(id)note isDark:(_Bool)dark;
+ (id)newShareForObject:(id)object;
+ (void)postDidUpdateShareNotificationForObject:(id)object;
+ (void)presentExportViewForAttachment:(id)attachment window:(id)window;
+ (id)rootRecordForObject:(id)object;
+ (void)saveActivityType:(id)type isCollaborationSelected:(_Bool)selected error:(id)error completed:(_Bool)completed forNote:(id)note;
+ (id)serverShareCheckingParent:(id)parent managedObjectContext:(id)context;
+ (id)serverShareIfRootObject:(id)object managedObjectContext:(id)context;
+ (id)shareSheetFolderThumbnailImage;
+ (id)shareSheetNoteThumbnailImage;
+ (long long)shareStatusOfFolder:(id)folder objectsForMakingDecision:(id)decision;
+ (_Bool)showCloudKitShareAcceptancePartialFailureAlertForError:(id)error alertBlock:(id /* block */)block;
+ (void)showQuotaExceededAlertIfNeededWithRecordID:(id)id accountID:(id)id;
+ (_Bool)supportRequestShareAccessForAccountIdentifier:(id)identifier;
+ (void)trackShare:(id)share forNote:(id)note;
+ (id)updatedShareForObject:(id)object includeHierarchicalShare:(_Bool)share managedObjectContext:(id)context;

/* instance methods */
- (id)initWithDelegate:(id)delegate;
- (id)viewContext;
- (id)containerForAccountID:(id)id;
- (id)backgroundContext;
- (void)managedObjectContextObjectsDidChange:(id)change;
- (void)updateShares;
- (id)cloudContext;
- (void)acceptShareWithMetadata:(id)metadata managedObjectContext:(id)context completionHandler:(id /* block */)handler;
- (void)acceptShareWithMetadata:(id)metadata attemptNumber:(id)number container:(id)container accountID:(id)id fetchObjectWithCompletionHandler:(id /* block */)handler;
- (void)acceptShareWithMetadata:(id)metadata container:(id)container accountID:(id)id fetchObjectWithCompletionHandler:(id /* block */)handler;
- (id)containerForUserRecordID:(id)id;
- (void)didSaveShare:(id)share accountID:(id)id;
- (void)didStopSharing:(id)sharing recordID:(id)id accountID:(id)id;
- (void)fetchAndAcceptShareMetadataWithURL:(id)url managedObjectContext:(id)context alertBlock:(id /* block */)block showObjectBlock:(id /* block */)block;
- (void)fetchShareIfNecessaryForObject:(id)object completionHandler:(id /* block */)handler;
- (id)objectForCKShareRecordID:(id)id accountID:(id)id context:(id)context;
- (id)objectForShare:(id)share accountID:(id)id context:(id)context;
- (void)prepareShare:(id)share forObject:(id)object qualityOfService:(long long)service completionHandler:(id /* block */)handler;
- (void)processShareAcceptanceWithMetadata:(id)metadata managedObjectContext:(id)context alertBlock:(id /* block */)block showObjectBlock:(id /* block */)block;
- (void)registerShareForObject:(id)object itemProvider:(id)provider generateThumbnails:(_Bool)thumbnails;
- (void)registerShareForObject:(id)object itemProvider:(id)provider generateThumbnails:(_Bool)thumbnails sharePreparationHandler:(id /* block */)handler;
- (void)removeShareIfNeededWithOwnedObjectID:(id)id countParticipants:(_Bool)participants completionHandler:(id /* block */)handler;
- (void)saveServerShare:(id)share persistParticipantEvents:(_Bool)events accountID:(id)id;
- (void)saveShare:(id)share attemptNumber:(id)number forObject:(id)object accountID:(id)id container:(id)container qualityOfService:(long long)service retryPrepHandler:(id /* block */)handler completionHandler:(id /* block */)handler;
- (void)saveShare:(id)share forObject:(id)object accountID:(id)id container:(id)container qualityOfService:(long long)service retryPrepHandler:(id /* block */)handler completionHandler:(id /* block */)handler;
- (void)saveShare:(id)share forObject:(id)object qualityOfService:(long long)service completionHandler:(id /* block */)handler;
- (void)saveShare:(id)share withRootRecord:(id)record object:(id)object accountID:(id)id container:(id)container qualityOfService:(long long)service completionHandler:(id /* block */)handler;
- (void)updatePendingInvitationsInAccountWithID:(id)id receivedSince:(id)since;
- (void)updateRootRecordMapWithShare:(id)share;

@end


@interface ICCollaboratorAvatarsView : NSView

@property (retain, nonatomic) NSArray *avatarContainerViews;
@property (retain, nonatomic) NSStackView *avatarStackView;
@property (nonatomic) double borderWidth;
@property (nonatomic) double dimension;
@property (retain, nonatomic) NSArray *participants;
@property (weak, nonatomic) CKShare *share;
@property (nonatomic) struct CGSize shadowOffset;
@property (nonatomic) double shadowOpacity;
@property (nonatomic) double shadowRadius;
@property (nonatomic) double spacing;
@property (readonly, nonatomic) unsigned long long displayedAvatarCount;
@property (nonatomic) _Bool reverseZIndexing;

/* instance methods */
- (void)commonInit;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)updateUI;
- (id)avatarViews;
- (id)defaultAvatarImageViewWithSize:(struct CGSize)size;
- (id)createAvatarContainerView;
- (void)setUpAvatarContainerViews;
- (void)updateShadows;

@end


@interface ICCollapsibleBaseView : NSView

@property (retain, nonatomic) NSView *contentView;
@property (retain, nonatomic) NSLayoutConstraint *zeroWidthConstraint;
@property (retain, nonatomic) NSLayoutConstraint *leadingConstraint;
@property (retain, nonatomic) NSLayoutConstraint *trailingConstraint;
@property (nonatomic) _Bool setupComplete;
@property (nonatomic) double leadingSpace;
@property (nonatomic) double trailingSpace;
@property (nonatomic) _Bool collapsed;

/* instance methods */
- (_Bool)isCollapsed;
- (void)awakeFromNib;
- (void)performSetup;
- (_Bool)wantsLayer;
- (void)ic_setNeedsUpdateConstraints;
- (void)performSetUpWithContentView:(id)view;
- (void)setUpIfNeeded;

@end


@interface ICCollapsibleActivityView : ICCollapsibleBaseView

@property (retain, nonatomic) NSProgressIndicator *activityIndicator;
@property (readonly, nonatomic) _Bool isAnimating;

/* instance methods */
- (void)commonInit;
- (void)setCollapsed:(_Bool)collapsed;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)performSetup;

@end


@interface ICCollapsibleContainerView : ICCollapsibleBaseView

@property (retain, nonatomic) NSView *containedView;

/* instance methods */
- (void)performSetup;

@end


@interface ICCollapsibleImageView : ICCollapsibleBaseView

@property (retain, nonatomic) NSImageView *imageView;
@property (retain, nonatomic) NSImage *image;

/* instance methods */
- (void)performSetup;
- (void)setAccessibilityElement:(_Bool)element;

@end


@interface ICCollapsibleThumbnailView : ICCollapsibleBaseView

@property (retain, nonatomic) ICImageAndMovieThumbnailView *thumbnailView;
@property (retain, nonatomic) NSImage *image;
@property (nonatomic) unsigned long long imageScaling;
@property (nonatomic) _Bool showAsMovie;

/* instance methods */
- (_Bool)accessibilityIgnoresInvertColors;
- (void)performSetup;

@end


@interface ICColorDummyClass : NSObject

@end


@interface ICCompatibilityAlertHelper : NSObject

/* class methods */
+ (id)oneTimeAlertKeyForAccount:(id)account;
+ (void)showAttachmentCompatibilityAlertInAccountIfNeeded:(id)needed completion:(id /* block */)completion;
+ (void)showCompatibilityAlertForAccountIfNeeded:(id)needed title:(id)title alertMessage:(id)message defaultButtonTitle:(id)title secondaryButtonTitle:(id)title postscript:(id)postscript hasShownAlertKey:(id)key minimumNotesVersion:(long long)version completion:(id /* block */)completion;
+ (void)showCompatibilityAlertForInlineAttachmentsInAccountIfNeeded:(id)needed completion:(id /* block */)completion;
+ (void)showCompatibilityAlertWithDeviceMessage:(id)message title:(id)title alertMessage:(id)message defaultButtonTitle:(id)title secondaryButtonTitle:(id)title postscript:(id)postscript completion:(id /* block */)completion;
+ (void)suppressOneTimeAttachmentUpgradeAlertForAcccount:(id)acccount;

@end


@interface ICConstantAvailableTableWidthProvider : NSObject <ICAvailableTableWidthProviding>

@property (nonatomic) double availableWidth;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

@end


@interface ICCopyModernNotesToLegacyAccountOperation : NSOperation

@property (copy, nonatomic) NSArray *sourceNotes;
@property (retain, nonatomic) id <ICLegacyFolder> destinationFolder;
@property (retain, nonatomic) id <ICLegacyContext> legacyContext;
@property (copy, nonatomic) id /* block */ didCopyBlock;

/* instance methods */
- (void)main;
- (id)init;
- (id)copyNote:(id)note toFolder:(id)folder;
- (id)dataForAttachment:(id)attachment outFilename:(id *)filename outMimeType:(id *)type;
- (id)ensureLegacyFolderIsValid:(id)valid;
- (id)htmlAttributesForAttachment:(id)attachment legacyContentID:(id)id tagName:(id *)name;
- (id)initWithNotes:(id)notes toFolder:(id)folder legacyContext:(id)context didCopyBlock:(id /* block */)block;

@end


@interface ICCoreDataIndexer : NSObject <NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) NSObject *reloadDataSerialQueue;
@property (nonatomic) _Bool needsFetchedResultsControllerUpdate;
@property (retain, nonatomic) id stopIndexingToken;
@property _Bool stopIndexing;
@property (weak, nonatomic) id <ICCoreDataIndexerDelegate> delegate;
@property (readonly, nonatomic) NSManagedObjectContext *legacyManagedObjectContext;
@property (readonly, nonatomic) NSManagedObjectContext *modernManagedObjectContext;
@property (readonly, nonatomic) id <ICItemIdentifier> firstRelevantItemIdentifier;
@property (nonatomic) _Bool shouldIncludeOutlineParentItems;
@property (readonly, copy, nonatomic) NSString *expansionStateContext;
@property (readonly, nonatomic) NSSet *activeFetchedResultsControllers;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (unsigned long long)indexerCount;

/* instance methods */
- (void)dealloc;
- (void)controller:(id)controller didChangeContentWithDifference:(id)difference;
- (void)deleteWithDecisionController:(id)controller completion:(id /* block */)completion;
- (void)didIndex;
- (id)indexObjectsInSection:(id)section sectionIndex:(unsigned long long)index fetchedResultsController:(id)controller;
- (void)indexObjectsWithCompletion:(id /* block */)completion;
- (id)initWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)newSnapshotFromIndex;
- (id)newSnapshotFromIndexWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)nextRelevantItemIdentifierAfter:(id)after;
- (void)performAndWaitForFetchedResultsControllers:(id)controllers block:(id /* block */)block;
- (void)reloadData:(id /* block */)data;
- (void)reloadDataAndWait;
- (id)sectionIdentifierForHeaderInSection:(long long)section;
- (id)sectionIdentifiersForSectionType:(unsigned long long)type;
- (void)unsafelyIndexAllObjectsForFetchedResultsController:(id)controller;
- (void)unsafelyReloadData;
- (void)updateLegacyFetchedResultsControllers;
- (void)updateModernFetchedResultsControllers;
- (void)willIndex;

@end


@interface ICCreateHTMLNoteAction : NSObject <ICCreateNoteAction>

@property (readonly, nonatomic) id <ICLegacyContext> context;
@property (readonly, nonatomic) id <ICLegacyFolder> folder;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithHTMLNoteContext:(id)context folder:(id)folder;
- (id)performWithTitle:(id)title contents:(id)contents pinned:(_Bool)pinned error:(id *)error;

@end


@interface ICCreateModernNoteAction : NSObject <ICCreateNoteAction>

@property (readonly, nonatomic) NSManagedObjectContext *context;
@property (readonly, nonatomic) ICFolder *folder;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithManagedObjectContext:(id)context folder:(id)folder;
- (id)performWithTitle:(id)title contents:(id)contents pinned:(_Bool)pinned error:(id *)error;

@end


@interface ICCreateNoteAction : NSObject

@property (readonly, nonatomic) ICUnifiedNoteContext *noteContext;
@property (nonatomic) _Bool allowsNoContent;

/* instance methods */
- (id)initWithNoteContext:(id)context;
- (id)performWithTitle:(id)title contents:(id)contents pinned:(_Bool)pinned container:(id)container error:(id *)error;

@end


@interface ICDidMoveToWindowSpy : NSView

@property (readonly, weak, nonatomic) id owner;
@property (readonly, nonatomic) id /* block */ handler;

/* instance methods */
- (void)viewDidMoveToWindow;
- (void)callHandler;
- (id)initWithOwner:(id)owner handler:(id /* block */)handler;
- (void)scheduleCallHandler;

@end


@interface ICDividerLineTextAttachmentView : NSView

@property (nonatomic) double width;
@property (nonatomic) double yOffset;
@property (retain, nonatomic) NSColor *color;
@property (weak, nonatomic) NSView *parentView;
@property (weak, nonatomic) ICDividerLineTextAttachment *textAttachment;

/* class methods */
+ (_Bool)wantsUpdateLayer;

/* instance methods */
- (id)accessibilityLabel;
- (void)viewDidChangeEffectiveAppearance;
- (void)updateLayer;
- (id)accessibilityIdentifier;
- (double)lineHeight;
- (void)_updateLineLayerFrame;
- (id)initWithColor:(id)color parentView:(id)view;

@end


@interface ICDividerLineTextAttachmentViewProvider : NSTextAttachmentViewProvider

@property (retain, nonatomic) ICDividerLineTextAttachmentView *lineView;
@property (weak, nonatomic) NSTextContainer *textContainer;
@property (retain, nonatomic) NSColor *color;
@property (weak, nonatomic) NSView *parentView;

/* instance methods */
- (void)loadView;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (void)createLineView;
- (id)initWithTextAttachment:(id)attachment parentView:(id)view textLayoutManager:(id)manager location:(id)location textContainer:(id)container;

@end


@interface ICDocCamPDFGenerator : NSObject

/* class methods */
+ (id)fileManager;
+ (id)fileQueue;
+ (void)deletePDFForAttachmentIfExists:(id)exists;
+ (id)versionFolderPathForAttachment:(id)attachment;
+ (id)blockingGeneratePDFDataForAttachment:(id)attachment withProgress:(id)progress queue:(id)queue error:(id *)error;
+ (id)blockingGeneratePDFURLForAttachment:(id)attachment withProgress:(id)progress error:(id *)error;
+ (void)createEmptyPDFFileAtURLIFNecessaryForAttachment:(id)attachment;
+ (void)deleteAllDocCamPDFs;
+ (void)deleteAllDocCamPasswordProtectedPDFs;
+ (void)deletePDFFolderIfExistsForAttachment:(id)attachment;
+ (id)folderPathForAttachment:(id)attachment;
+ (id)folderPathForAttachmentIdentifier:(id)identifier passwordProtected:(_Bool)_protected;
+ (id)generatePDFURLForAttachment:(id)attachment;
+ (void)generatePDFsIfNecessaryForGalleryAttachments:(id)attachments displayWindow:(id)window completionHandler:(id /* block */)handler;
+ (id)pdfURLForAttachment:(id)attachment;
+ (void)performPDFGenerationWithGenerator:(id)generator galleryModel:(id)model progress:(id)progress;
+ (id)rootPDFFolderPath;
+ (id)rootPDFFolderPathForPWAttachments;
+ (id)syncGeneratorQueue;
+ (id)versionPDFPathForAttachment:(id)attachment;

@end


@interface ICDocumentMergeController : NSObject <ICDocumentMergeControlling>

@property (nonatomic, weak) id <ICDocumentMergeControlling> parentController;
@property (nonatomic, readonly) NSSet *textViews;
@property (nonatomic, readonly) _Bool isBlockingMerge;

/* instance methods */
- (id)init;
- (void)requestMergeWithBlock:(id /* block */)block;
- (void)removeTextView:(id)view;
- (void)addTextView:(id)view;
- (void)beginBlockingMergeForReason:(unsigned long long)reason textView:(id)view;
- (void)blockingMergeForReason:(unsigned long long)reason textView:(id)view block:(id /* block */)block;
- (void)endBlockingMergeForReason:(unsigned long long)reason textView:(id)view;

@end


@interface ICDrawingConversionOperation : NSOperation

@property (retain, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) _Bool isAutomatic;
@property (readonly, nonatomic) NSManagedObjectID *attachmentID;
@property (readonly, nonatomic) NSManagedObjectID *finalAttachmentID;
@property (retain, nonatomic) ICBaseTextAttachment *textAttachment;

/* instance methods */
- (void)main;
- (id)initWithAttachment:(id)attachment textAttachment:(id)attachment automatic:(_Bool)automatic;

@end


@interface ICDrawingHashtagsAndMentionsController : NSObject

@property (weak, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) ICNote *note;
@property (readonly, nonatomic) CKShare *share;
@property (readonly, nonatomic) NSArray *eligibleShareParticipants;
@property (copy, nonatomic) NSDictionary *mentionTokensForParticipants;

/* instance methods */
- (id)initWithAttachment:(id)attachment;
- (void)fetchMentionTokensForParticipants:(id)participants completion:(id /* block */)completion;

@end


@interface ICDrawingPencilKitConverter : NSObject

@property (retain, nonatomic) NSOperationQueue *converterQueue;
@property (retain, nonatomic) NSMapTable *lastOperationForAttachmentID;
@property (retain, nonatomic) NSObject *convertDispatchQueue;
@property (retain, nonatomic) NSMutableArray *mutableFailedSketches;
@property (nonatomic) _Bool isThrowaway;
@property (readonly, nonatomic) NSArray *failedSketches;

/* class methods */
+ (id)sharedConverter;
+ (unsigned long long)countOfUpdatableDrawingsInNote:(id)note;
+ (_Bool)canUpdateFullscreenSketchAttachment:(id)attachment;
+ (_Bool)canUpdateInlineDrawingAttachment:(id)attachment;
+ (id)newThrowawayConverter;

/* instance methods */
- (id)init;
- (void)convertAllSketchesWithProgress:(id)progress;
- (id)addOperationForAttachment:(id)attachment automatic:(_Bool)automatic;
- (void)canAutoUpdateDrawingsInAccount:(id)account completion:(id /* block */)completion;
- (_Bool)compareDrawingAttachment:(id)attachment withConvertedDrawing:(id)drawing;
- (void)convertAllDrawingsIfNeededInContext:(id)context;
- (unsigned long long)convertAllSketchesInNote:(id)note;
- (void)convertAllSketchesWithProgress:(id)progress completion:(id /* block */)completion;
- (void)convertDrawingsInNote:(id)note inWindow:(id)window message:(id)message completion:(id /* block */)completion;
- (void)convertDrawingsInNote:(id)note waitUntilFinished:(_Bool)finished;
- (void)convertDrawingsInNoteIfNeeded:(id)needed;
- (id)convertSketch:(id)sketch;
- (id)convertSketchAttachment:(id)attachment toInlineDrawingAtRange:(struct _NSRange)range inNote:(id)note;
- (unsigned long long)countOfDrawingsNeedingConversionInNote:(id)note;
- (void)operationComplete:(id)complete;
- (_Bool)shouldAutoConvertNote:(id)note;
- (_Bool)shouldConvertAllDrawingsIfNeeded;
- (id)updateInlineDrawingAttachment:(id)attachment;

@end


@interface ICDrawingTextAttachment : ICTextAttachment

/* instance methods */
- (struct { double x0; double x1; double x2; double x3; })attachmentBoundsMargins;
- (id)attachmentFileWrapper;
- (id)printableTextAttachment;
- (_Bool)requiresSpaceAfterAttachmentForPrinting;
- (_Bool)supportsMultipleThumbnailsOnSameLine;
- (double)viewCornerRadius;

@end


@interface ICExpansionState : NSObject

@property (retain, nonatomic) NSMutableDictionary *expansionState;
@property (retain, nonatomic) NSManagedObjectContext *modernViewContext;
@property (retain, nonatomic) NSManagedObjectContext *legacyViewContext;
@property (readonly, nonatomic) NSDictionary *archiveDictionary;

/* class methods */
+ (id)sharedExpansionState;

/* instance methods */
- (id)description;
- (id)init;
- (void)applyArchiveDictionary:(id)dictionary;
- (void)collapseItemIdentifier:(id)identifier context:(id)context;
- (id)archivableIdentifierForItemIdentifier:(id)identifier;
- (void)collapseItemIdentifier:(id)identifier itemType:(long long)type context:(id)context;
- (void)collapseItemIdentifiers:(id)identifiers itemType:(long long)type context:(id)context;
- (id)collapsedItemIdentifiersWithItemType:(long long)type context:(id)context;
- (id)collapsedObjectIDsInContext:(id)context;
- (void)expandItemIdentifier:(id)identifier context:(id)context;
- (void)expandItemIdentifier:(id)identifier itemType:(long long)type context:(id)context;
- (void)expandItemIdentifiers:(id)identifiers itemType:(long long)type context:(id)context;
- (id)expandedItemIdentifiersWithItemType:(long long)type context:(id)context;
- (id)expandedObjectIDsInContext:(id)context;
- (id)identifierForArchivableIdentifier:(id)identifier itemType:(long long)type;
- (_Bool)isSectionIdentiferExpanded:(id)expanded inContext:(id)context;
- (id)itemIdentifiersExpanded:(_Bool)expanded itemType:(long long)type context:(id)context;
- (long long)itemTypeForItemIdentifier:(id)identifier;
- (id)normalizedContext:(id)context;
- (id)normalizedItemIdentifier:(id)identifier;
- (void)setExpanded:(_Bool)expanded itemIdentifier:(id)identifier itemType:(long long)type context:(id)context;

@end


@interface ICFlippedView : NSView

/* instance methods */
- (_Bool)isFlipped;
- (_Bool)wantsLayer;

@end


@interface ICFolderCoreDataIndexer : ICCoreDataIndexer

@property (retain, nonatomic) NSFetchedResultsController *legacyFetchedResultsController;
@property (retain, nonatomic) NSFetchedResultsController *modernFetchedResultsController;
@property (retain, nonatomic) NSObject *indexAccessQueue;
@property (retain, nonatomic) NSMutableDictionary *folderListSectionIdentifiersToButtonIdentifiers;
@property (retain, nonatomic) NSMutableDictionary *folderListSectionIdentifiersToVirtualSmartFolderIdentifiers;
@property (retain, nonatomic) NSMutableDictionary *folderListSectionIdentifiersToFolderItemIdentifiers;
@property (retain, nonatomic) NSMutableDictionary *folderItemIdentifiersToParentFolderItemIdentifier;
@property (retain, nonatomic) NSMutableDictionary *folderItemIdentifiersToChildFolderItemIdentifiers;
@property (retain, nonatomic) NSMutableOrderedSet *folderListSectionIdentifiers;
@property (retain, nonatomic) NSMutableSet *legacyAccountManagedObjectIDs;
@property (retain, nonatomic) NSMutableSet *modernAccountManagedObjectIDs;
@property (retain, nonatomic) NSMutableSet *smartFolderManagedObjectIDs;
@property (retain, nonatomic) NSMutableSet *virtualSmartFolderIdentifiers;
@property (readonly, nonatomic) _Bool includeMigratedLocalLegacyAccounts;
@property (readonly, nonatomic) _Bool hideUnmigratedLocalLegacyAccounts;
@property (readonly, nonatomic) _Bool includeMigratedICloudLegacyAccounts;
@property (retain, nonatomic) ICTagCoreDataIndexer *tagIndexer;
@property (readonly, nonatomic) unsigned long long countOfLegacyAccounts;
@property (readonly, nonatomic) unsigned long long countOfModernAccounts;
@property (retain, nonatomic) NSManagedObjectID *ancestorObjectID;
@property (retain, nonatomic) NSManagedObjectID *accountObjectID;
@property (readonly, nonatomic) unsigned long long totalFolderCount;
@property (nonatomic) _Bool shouldIncludeLegacyAccounts;
@property (nonatomic) _Bool shouldIncludeTags;
@property (nonatomic) _Bool shouldIncludeTagOperator;
@property (nonatomic) long long shouldIncludeSystemPaper;
@property (nonatomic) long long shouldIncludeMathNotes;
@property (nonatomic) long long shouldIncludeCallNotes;
@property (nonatomic) _Bool shouldIncludeSmartFolders;
@property (nonatomic) long long shouldIncludeSharedWithYou;
@property (nonatomic) long long shouldIncludeAccount;
@property (nonatomic) _Bool shouldIncludeDefaultFolder;
@property (nonatomic) _Bool shouldIncludeTrash;
@property (nonatomic) _Bool shouldIncludeNewFolderButton;
@property (nonatomic) _Bool shouldIncludeSubfolders;
@property (nonatomic) _Bool shouldAutoExpandSingleSection;
@property (retain, nonatomic) id <ICItemIdentifier> overrideContainerIdentifier;
@property (readonly, nonatomic) NSSet *allSmartFolderObjectIDs;
@property (readonly, nonatomic) NSSet *allVirtualSmartFolderIdentifiers;

/* instance methods */
- (id)activeFetchedResultsControllers;
- (_Bool)isCustomFolder:(id)folder;
- (void)addAccountItemsIfNeededForFolderSectionIdentifier:(id)identifier;
- (void)addSystemSectionIfNeeded;
- (void)deleteObjectWithIDFromIndex:(id)index inSection:(id)section;
- (void)deleteWithDecisionController:(id)controller completion:(id /* block */)completion;
- (void)didIndex;
- (id)expansionStateContext;
- (id)firstRelevantItemIdentifier;
- (id)indexObjectsInSection:(id)section sectionIndex:(unsigned long long)index fetchedResultsController:(id)controller;
- (id)initWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)initWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context overrideContainerIdentifier:(id)identifier;
- (_Bool)isDefaultFolder:(id)folder;
- (_Bool)itemIdentifiersContainCustomFolder:(id)folder;
- (id)legacyFolderFetchPredicate;
- (id)modernDescendantsPredicate;
- (id)modernFolderFetchPredicate;
- (id)newSnapshotFromIndexWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)nextRelevantItemIdentifierAfter:(id)after;
- (id)rootFolderListSectionIdentifiersForSection:(id)section;
- (id)sectionIdentifierForHeaderInSection:(long long)section;
- (id)sectionIdentifiersForSectionType:(unsigned long long)type;
- (void)sortIdentifiersWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)sortedFolderItemIdentifiersForItemIdentifiers:(id)identifiers legacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (void)willIndex;

@end


@interface ICFolderListSectionIdentifier : NSObject <ICSectionIdentifier>

@property (retain, nonatomic) NSManagedObjectID *accountObjectID;
@property (nonatomic) long long sectionType;
@property (copy, nonatomic) NSString *title;
@property (readonly, nonatomic) _Bool hasHeader;
@property (readonly, nonatomic) _Bool collapsible;
@property (readonly, copy, nonatomic) NSString *expansionStateContext;
@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sortDescriptors;
+ (id)systemSectionIdentifier;
+ (id)tagSectionIdentifier;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObject:(id)object;
- (_Bool)isCollapsible;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithSectionType:(long long)type;
- (id)accountAccessibilityIdentifier;
- (long long)accountSectionTypeForLegacyAccount:(id)account;
- (long long)accountSectionTypeForModernAccount:(id)account;
- (_Bool)isEqualToICFolderListSectionIdentifier:(id)identifier;

@end


@interface ICGalleryAttachmentUtilities : NSObject

/* class methods */
+ (id)createAndAddSubAttachmentsToGalleryAttachment:(id)attachment fromDocuments:(id)documents imageCache:(id)cache context:(id)context;
+ (id)createSubAttachmentFromDocument:(id)document imageCache:(id)cache galleryAttachment:(id)attachment;
+ (id)imageForSubAttachment:(id)attachment;
+ (id)imageForSubAttachment:(id)attachment allowCached:(_Bool)cached;
+ (id)imageForSubAttachment:(id)attachment rotateForMacImageGallery:(_Bool)gallery allowCached:(_Bool)cached;
+ (double)requiredWidthForAttachment:(id)attachment viewHeight:(double)height maxWidth:(double)width;
+ (struct CGSize)sizeOfSubAttachment:(id)attachment forHeight:(double)height;
+ (struct CGSize)sizeOfViewForAttachment:(id)attachment textViewContentWidth:(double)width;

@end


@interface ICHTMLConverterClient : NSObject

@property (retain, nonatomic) NSObject *requestCountQueue;
@property (nonatomic) unsigned long long requestCount;

/* class methods */
+ (id)sharedClient;

/* instance methods */
- (id)init;
- (void)dealloc;
- (id)attributedStringFromHTMLString:(id)htmlstring;
- (void)attributedStringFromHTMLString:(id)htmlstring baseURL:(id)url timeoutDate:(id)date completionBlock:(id /* block */)block;
- (void)resumeConnectionIfNeeded;
- (void)suspendConnectionIfNeeded;

@end


@interface ICHashtagAttachmentView : ICInlineAttachmentView

@end


@interface ICHashtagTextAttachment : ICInlineTextAttachment

@end


@interface ICHashtagUIModel : ICInlineAttachmentUIModel

/* instance methods */
- (id)labelColor;

@end


@interface ICHelp : NSObject

/* class methods */
+ (id)lockedNotesSupportURL;
+ (id)notesHelpURL;
+ (void)presentWithTopic:(id)topic;
+ (id)smartFoldersSupportURL;

@end


@interface ICImageAndMovieThumbnailView : NSView

@property (retain, nonatomic) NSImageView *imageView;
@property (retain, nonatomic) NSLayoutConstraint *imageViewLeftLayoutConstraint;
@property (retain, nonatomic) NSLayoutConstraint *imageViewRightLayoutConstraint;
@property (retain, nonatomic) NSLayoutConstraint *imageViewBottomLayoutConstraint;
@property (retain, nonatomic) NSLayoutConstraint *imageViewTopLayoutConstraint;
@property (retain, nonatomic) NSView *movieFooter;
@property (retain, nonatomic) ICLabel *movieDurationLabel;
@property (retain, nonatomic) NSMutableDictionary *hairlineLayers;
@property (retain, nonatomic) NSMutableDictionary *hairlineColors;
@property (nonatomic) _Bool showMovieDuration;
@property (retain, nonatomic) NSImage *image;
@property (nonatomic) unsigned long long imageScaling;
@property (nonatomic) double imageInset;
@property (nonatomic) _Bool showAsMovie;
@property (nonatomic) struct { long long x0; int x1; unsigned int x2; long long x3; } movieDuration;
@property (nonatomic) double cornerRadius;
@property (retain, nonatomic) NSColor *borderColor;
@property (nonatomic) _Bool hairlineWidthUnitIsInPoint;
@property (nonatomic) unsigned long long hairlineEdges;
@property (nonatomic) unsigned long long edgesToRemoveStartPoint;
@property (nonatomic) unsigned long long edgesToRemoveEndPoint;
@property (nonatomic) double mininumScaleFactor;
@property (nonatomic) _Bool forceSquareImageAspectRatio;

/* instance methods */
- (void)commonInit;
- (id)initWithFrame:(struct CGRect)frame;
- (double)pixelWidth;
- (void)setBounds:(struct CGRect)bounds;
- (double)backingScale;
- (struct CGRect)frameByApplyingHorizontalReductionTo:(struct CGRect)to edge:(unsigned long long)edge;
- (struct CGRect)frameByApplyingVerticalReductionTo:(struct CGRect)to edge:(unsigned long long)edge;
- (id)hairlineLayerForEdge:(unsigned long long)edge;
- (double)hairlineWidthInPoint;
- (id)initWithFrame:(struct CGRect)frame showMovieDuration:(_Bool)duration;
- (void)setHairlineColor:(id)color forEdges:(unsigned long long)edges;
- (void)setupMovieFooter;
- (void)updateDurationLabel;
- (void)updateHairline;
- (void)updateHairlineFrames;
- (_Bool)usesSeparateLayerForHairlineEdge:(unsigned long long)edge;
- (_Bool)usesSeparateLayersForHairlines;

@end


@interface ICImageTextAttachment : ICTextAttachment

/* instance methods */
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (_Bool)requiresSpaceAfterAttachmentForPrinting;
- (id)supportedPresentationSizes;
- (_Bool)supportsMultipleThumbnailsOnSameLine;

@end


@interface ICIndexHandwritingOperation : NSOperation

@property (retain, nonatomic) NSManagedObjectID *attachmentObjectID;
@property (retain, nonatomic) NSManagedObjectContext *context;

/* class methods */
+ (id)sharedOperationQueue;

/* instance methods */
- (void)main;
- (id)initWithAttachmentObjectID:(id)id context:(id)context;

@end


@interface ICInlineCanvasTextAttachment : ICBaseTextAttachment

@property (readonly, nonatomic) NSArray *inlineViews;
@property (readonly, nonatomic) NSArray *attachmentViews;

/* instance methods */
- (id)imageForBounds:(struct CGRect)bounds attributes:(id)attributes location:(id)location textContainer:(id)container;
- (void)updatePaletteVisibility;
- (void)updatePaletteVisibilityToVisible:(_Bool)visible;

@end


@interface ICInlineDrawingChangeCoalescer : NSObject

@property (retain, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) ICSelectorDelayer *processChangesSelectorDelayer;
@property (retain, nonatomic) PKDrawing *latestDrawing;
@property (nonatomic) unsigned long long numberOfChanges;
@property (retain, nonatomic) NSManagedObjectContext *workerContext;
@property (retain, nonatomic) NSManagedObjectContext *mainContext;
@property (retain, nonatomic) NSManagedObjectContext *handwritingRecognitionContext;

/* instance methods */
- (_Bool)hasChanges;
- (void)dealloc;
- (id)initWithAttachment:(id)attachment;
- (void)drawingDataDidChange:(id)change;
- (void)mergeDrawingChanges;
- (void)mergeDrawingWithDrawing:(id)drawing;
- (void)processIndexableContentWithCompletion:(id /* block */)completion;
- (id)retrieveAndClearLatestDrawingToMerge;
- (void)updateNowIfNecessary;
- (void)updateVersionIfNeededForAttachment:(id)attachment withDrawing:(id)drawing;

@end


@interface ICInlineDrawingTextAttachment : ICInlineCanvasTextAttachment <PKTextAttachment>

@property (retain, nonatomic) ICInlineDrawingChangeCoalescer *changeCoalescer;
@property (retain, nonatomic) NSHashTable *inlineDrawingViews;
@property (nonatomic) _Bool isHandlingDrawingDidChange;
@property (retain, nonatomic) ICDrawingHashtagsAndMentionsController *hashtagsAndMentionsController;
@property (weak, nonatomic) NSView *cachedDrawingViewForPlaceView;
@property (weak, nonatomic) NSView *cachedControlViewForPlaceView;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (id)contents;
- (id)_image;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (void)detachView:(id)view fromParentView:(id)view;
- (void)placeView:(id)view withFrame:(struct CGRect)frame inParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (void)saveIfNeeded;
- (void)drawingDataDidChange:(id)change view:(id)view;
- (id)attachmentViews;
- (id)attachmentAsNSTextAttachment;
- (_Bool)canDragWithoutSelecting;
- (void)detachView;
- (id)inlineViews;
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;

@end


@interface ICInvitationsCoreDataIndexer : ICCoreDataIndexer

@property (readonly, nonatomic) NSObject *indexAccessQueue;
@property (readonly, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSMutableOrderedSet *invitationObjectIDs;
@property (readonly, nonatomic) id <ICSectionIdentifier> sectionIdentifier;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) ICFolderCustomNoteSortType *sortType;
@property (copy, nonatomic) NSDate *receivedSince;
@property (copy, nonatomic) NSString *expansionStateContext;
@property (readonly, nonatomic) unsigned long long totalInvitationsCount;

/* class methods */
+ (id)defaultReceivedSince;

/* instance methods */
- (id)activeFetchedResultsControllers;
- (void)deleteObjectWithIDFromIndex:(id)index inSection:(id)section;
- (id)firstRelevantItemIdentifier;
- (id)indexObjectsInSection:(id)section sectionIndex:(unsigned long long)index fetchedResultsController:(id)controller;
- (id)initWithModernManagedObjectContext:(id)context sectionIdentifier:(id)identifier;
- (id)newSnapshotFromIndexWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)nextRelevantItemIdentifierAfter:(id)after;
- (id)sectionIdentifierForHeaderInSection:(long long)section;
- (id)sectionIdentifiersForSectionType:(unsigned long long)type;
- (void)willIndex;

@end


@interface ICLabel : NSTextField

@property (retain, nonatomic) NSLayoutConstraint *minimumHeightConstraint;
@property (retain, nonatomic) NSLayoutConstraint *heightConstraint;
@property (copy, nonatomic) NSString *string;
@property (copy, nonatomic) NSAttributedString *attributedString;
@property (nonatomic) long long numberOfLines;
@property (nonatomic) double spacing;
@property (nonatomic) double paragraphSpacing;
@property (nonatomic) double lineHeight;

/* instance methods */
- (void)textDidChange:(id)change;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)frame;
- (struct CGSize)intrinsicContentSize;
- (void)updateText;
- (void)updatePreferredMaxLayoutWidth:(id)width;
- (void)updateHeightConstraint;

@end


@interface ICLegacyNoteUtilities : NSObject

/* class methods */
+ (void)copyValuesFromLegacyNote:(id)note toNote:(id)note styler:(id)styler attachmentPreviewGenerator:(id)generator;
+ (void)importLegacyNote:(id)note temporaryTextStorage:(id)storage toNote:(id)note attachmentPreviewGenerator:(id)generator;
+ (id)temporaryTextStorageWithAttributedString:(id)string replicaID:(id)id styler:(id)styler;

@end


@interface ICLinkAttachmentView : ICInlineAttachmentView

@end


@interface ICLinkConverter : NSObject

@property (readonly, nonatomic) ICTTTextStorage *textStorage;
@property (weak, nonatomic) ICAttachmentInsertionController *insertionController;

/* class methods */
+ (id)convertAttachmentToLinkActionTitle;
+ (id)convertAttachmentToLinkSystemImageName;
+ (id)convertLinkToAttachmentActionTitle;
+ (id)convertLinkToAttachmentSystemImageName;

/* instance methods */
- (_Bool)canConvertAttachmentToLink:(id)link;
- (_Bool)canConvertLinkAtLocationToAttachment:(unsigned long long)attachment;
- (void)convertAttachmentToLink:(id)link;
- (void)convertLinkAtLocationToAttachment:(unsigned long long)attachment;
- (id)initWithInsertionController:(id)controller;

@end


@interface ICLinkSnapshotGenerator : NSObject

@property (readonly, nonatomic) LPLinkSnapshotGenerator *generator;
@property (readonly, nonatomic) LPLinkMetadata *metadata;
@property (readonly, nonatomic) LPLinkSnapshotConfiguration *configuration;
@property (readonly, nonatomic) ICAttachment *attachment;
@property (nonatomic) _Bool forcesSmallSize;
@property (nonatomic) _Bool forcesLightMode;
@property (nonatomic) _Bool insideSystemPaper;

/* instance methods */
- (id)snapshot;
- (void)invalidate;
- (id)initWithAttachment:(id)attachment;
- (_Bool)isInsideSystemPaper;

@end


@interface ICLinkTextAttachment : ICInlineTextAttachment

@end


@interface ICLinkUIModel : ICInlineAttachmentUIModel

@property (nonatomic, readonly) NSColor *labelColor;
@property (nonatomic, readonly) NSString *paragraphStyleAttributeName;
@property (nonatomic, readonly) NSString *foregroundColorAttributeName;
@property (nonatomic, readonly) NSString *ttforegroundColorAttributeName;
@property (nonatomic, readonly) NSString *ttEmphasisAttributeName;
@property (nonatomic, readonly) NSString *ttAttributeNameDerivedAuthorHighlight;
@property (nonatomic, readonly) NSString *ttAttributeNameAcceleratorLinkUnconfirmed;

/* instance methods */
- (id)init;
- (id)initWithAttachment:(id)attachment;
- (id)attributedStringWithSurroundingAttributes:(id)attributes formatter:(id /* block */)formatter;
- (id)colorFor:(id)_for;
- (id)highlightingAttributedString:(id)string withSurroundingAttributes:(id)attributes;
- (id)noteGlyphTextAttachmentWithSurroundingAttributes:(id)attributes;

@end


@interface ICLoadingPieLayer : CALayer

@property (retain, nonatomic) CAShapeLayer *pieLayer;
@property (retain, nonatomic) CAShapeLayer *backgroundLayer;
@property (readonly, nonatomic) double progress;
@property (retain, nonatomic) NSProgress *observedProgress;
@property (nonatomic) _Bool removeOnCompletion;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (struct CGPath *)newPathForProgress:(double)progress;

@end


@interface ICLocalizationUtilities : NSObject

/* class methods */
+ (_Bool)supportsRTL;
+ (_Bool)isArabic;

@end


@interface ICLockedNotesModeMigrator : NSObject

@property (readonly, nonatomic) NSObject *queue;
@property (copy, nonatomic) NSDate *authenticatedAt;
@property (readonly, nonatomic) NSManagedObjectContext *workerContext;

/* class methods */
+ (id)sharedMigrator;

/* instance methods */
- (void)authenticationStateDidDeauthenticate:(id)deauthenticate;
- (id)initWithWorkerContext:(id)context;
- (_Bool)account:(id)account hasNotesLockedWithMode:(short)mode;
- (_Bool)account:(id)account supportsMode:(short)mode;
- (void)authenticationStateDidAuthenticate:(id)authenticate;
- (id)lockedNotesInAccount:(id)account;
- (void)migrateLockedNotesInAccount:(id)account toMode:(short)mode window:(id)window completionHandler:(id /* block */)handler;
- (void)migrateNote:(id)note completionHandler:(id /* block */)handler;
- (void)migrateNoteToV1NeoIfNeeded:(id)needed completionHandler:(id /* block */)handler;
- (void)presentBackwardsCompatibilityAlertIfNeededForAccount:(id)account mode:(short)mode window:(id)window confirmHandler:(id /* block */)handler cancelHandler:(id /* block */)handler;
- (void)presentDivergedModeAlertForNote:(id)note mode:(short)mode window:(id)window completionHandler:(id /* block */)handler;
- (void)presentLockedNotesLearnMoreViewForAccount:(id)account window:(id)window;
- (void)presentLockedNotesMigrationPromptIfNeededForAccount:(id)account window:(id)window completionHandler:(id /* block */)handler;
- (void)presentLockedNotesSwitchMigrationPromptIfSupportedForAccount:(id)account window:(id)window completionHandler:(id /* block */)handler;
- (void)presentLockedNotesWelcomeMigrationPromptIfSupportedForAccount:(id)account window:(id)window completionHandler:(id /* block */)handler;
- (void)showMigrationPromptAndMigrateIfNeededForAccount:(id)account window:(id)window;
- (id)unsafelyMigrateNote:(id)note;
- (id)unsafelyMigrateNotes:(id)notes progress:(id)progress;

@end


@interface ICLockedTextAttachment : ICTextAttachment

@property (readonly, nonatomic) long long lockedAttachmentViewLayout;

@end


@interface ICLongRunningTaskController : NSObject <ICMProgressWindowControllerDelegate>

@property (retain, nonatomic) NSWindow *window;
@property (nonatomic) double intervalBeforeOpeningProgressDialog;
@property (retain, nonatomic) id keepAlive;
@property (copy, nonatomic) id /* block */ completionBlock;
@property (copy, nonatomic) id /* block */ updateProgressUIBlock;
@property (retain, nonatomic) NSProgress *progress;
@property (retain, nonatomic) NSDate *lastAccessibilityAnnouncementDate;
@property (retain, nonatomic) NSDate *openProgressDate;
@property (nonatomic) _Bool isCancelled;
@property (retain, nonatomic) ICMProgressWindowController *progressWindowController;
@property (readonly, nonatomic) NSString *progressText;
@property (nonatomic) _Bool shouldShowCancelButton;
@property (nonatomic) _Bool indeterminate;
@property (copy, nonatomic) NSString *customCancelButtonTitle;
@property (copy, nonatomic) NSString *progressString;
@property (copy, nonatomic) id /* block */ progressStringBlock;
@property (nonatomic) _Bool shouldShowSpinner;
@property (nonatomic) _Bool allowSingleUnitProgress;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)setMainWindow:(id)window;

/* instance methods */
- (void)updateProgress;
- (id)init;
- (_Bool)isIndeterminate;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)closeProgressDialog;
- (void)completeTaskIfNecessary;
- (void)didTapCancelButtonInProgressWindowController:(id)controller;
- (id)initWithShouldShowSpinner:(_Bool)spinner progressText:(id)text;
- (id)initWithWindow:(id)window intervalBeforeOpeningProgressDialog:(double)dialog;
- (void)openProgressDialog;
- (void)startTask:(id /* block */)task completionBlock:(id /* block */)block;

@end


@interface ICMBaseTouchBarController : NSObject <NSTouchBarProvider>

@property (retain, nonatomic) NSMutableSet *enabledBindingObjectSet;
@property (readonly) NSTouchBar *touchBar;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)dealloc;
- (id)buttonWithImage:(id)image target:(id)target action:(SEL)action;
- (id)buttonWithTitle:(id)title image:(id)image target:(id)target action:(SEL)action;
- (id)buttonWithTitle:(id)title target:(id)target action:(SEL)action;
- (void)addEnabledBindingWithObject:(id)object toObject:(id)object keyPath:(id)path;

@end


@interface ICMAlertSheetTouchBarController : ICMBaseTouchBarController <NSTouchBarDelegate>

@property (retain, nonatomic) NSTouchBar *groupTouchBar;
@property (retain, nonatomic) NSGroupTouchBarItem *groupTouchBarItem;
@property (retain, nonatomic) NSTouchBar *alertTouchBar;
@property (retain, nonatomic) NSMutableOrderedSet *buttonIdentifiers;
@property (retain, nonatomic) NSMutableDictionary *buttonIdentifiersToButtons;
@property (retain, nonatomic) NSMutableDictionary *buttonIdentifiersToTouchBarItems;
@property (readonly, nonatomic) NSArray *currentIdentifiers;
@property (retain, nonatomic) NSMutableSet *observedButtons;
@property (retain, nonatomic) NSSet *observableProperties;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)touchBar;
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)touchBar:(id)bar makeItemForIdentifier:(id)identifier;
- (void)addButton:(id)button;
- (void)updateButton:(id)button;
- (void)removeAllButtons;
- (void)removeButton:(id)button;
- (void)stopObservingButtonIfNecessary:(id)necessary;
- (void)copyValuesFromButton:(id)button toButton:(id)button;
- (id)dfrButtonFromButton:(id)button;
- (void)invalidateCurrentIdentifiers;
- (void)startObservingButtonIfNecessary:(id)necessary;

@end


@interface ICMClickableTextView : NSTextView

@property (weak, nonatomic) id <ICMClickableTextViewDelegate> clickDelegate;
@property (retain, nonatomic) NSAttributedString *nonHighlightedClickableAttributedString;
@property (retain, nonatomic) NSAttributedString *highlightedClickableAttributedString;
@property (nonatomic) struct _NSRange clickableRange;
@property (nonatomic) _Bool isHighlighted;
@property (retain, nonatomic) ICPressableAttachmentAccessibilityElement *accessibilityLearnMoreProxyElement;

/* instance methods */
- (void)mouseUp:(id)up;
- (void)mouseDown:(id)down;
- (_Bool)isAccessibilityElement;
- (void)mouseDragged:(id)dragged;
- (_Bool)acceptsFirstMouse:(id)mouse;
- (id)accessibilityAttributedStringForRange:(struct _NSRange)range;
- (id)accessibilityHelp;
- (_Bool)accessibilityPerformPress;
- (_Bool)mouseDownCanMoveWindow;
- (_Bool)isInsideClickableRangeForEvent:(id)event;
- (void)adjustHeightConstraintToFitCurrentText:(id)text;
- (void)resetHighlightedState;

@end


@interface ICMDatePickerDebugWindowController : NSWindowController

@property (nonatomic) unsigned char windowType;
@property (retain, nonatomic) id representedObject;
@property (weak) NSDatePicker *datePicker;
@property (weak) NSTextField *dateLabel;
@property (readonly, nonatomic) struct _NSRange selectedRange;

/* class methods */
+ (id)datePickerWindowWithType:(unsigned char)type representedObject:(id)object;
+ (id)datePickerWindowWithType:(unsigned char)type representedObject:(id)object selectedRange:(struct _NSRange)range;

/* instance methods */
- (void)cancel:(id)cancel;
- (void)windowDidLoad;
- (void)setDate:(id)date;
- (void)datePickerAction:(id)action;
- (id)initWithWindowType:(unsigned char)type representedObject:(id)object selectedRange:(struct _NSRange)range;

@end


@interface ICMFontManager : NSFontManager <NSMenuItemValidation>

@property (nonatomic) _Bool isTogglingBoldface;
@property (nonatomic) _Bool isTogglingItalics;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)isMenuItemToggleBold:(id)bold;
+ (_Bool)isMenuItemToggleItalics:(id)italics;

/* instance methods */
- (_Bool)validateMenuItem:(id)item;
- (void)addFontTrait:(id)trait;
- (void)modifyFontViaPanel:(id)panel;
- (void)setSelectedFont:(id)font isMultiple:(_Bool)multiple;

@end


@interface ICMPasswordChangeSheetViewController : NSViewController <ICMClickableTextViewDelegate>

@property (retain, nonatomic) ICAccountPassphraseManager *passphraseManager;
@property (weak, nonatomic) NSTextField *titleLabel;
@property (weak, nonatomic) NSTextField *oldPasswordLabel;
@property (weak, nonatomic) NSTextField *passwordLabel;
@property (weak, nonatomic) NSTextField *verifyLabel;
@property (weak, nonatomic) NSTextField *hintLabel;
@property (weak, nonatomic) NSTextField *passwordAndVerifyDoNotMatchLabel;
@property (weak, nonatomic) NSTextField *passwordHintWarningLabel;
@property ICMClickableTextView *disclaimerTextView;
@property (weak, nonatomic) NSView *oldPasswordContainer;
@property NSTextView *oldPasswordIncorrectTextView;
@property (weak, nonatomic) NSLayoutConstraint *oldPasswordIncorrectTextViewHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *disclaimerHeightConstraint;
@property (weak, nonatomic) NSSecureTextField *oldPasswordTextField;
@property (weak, nonatomic) NSSecureTextField *passwordTextField;
@property (weak, nonatomic) NSSecureTextField *verifyTextField;
@property (weak, nonatomic) NSTextField *hintTextField;
@property (weak, nonatomic) NSButton *confirmButton;
@property (weak, nonatomic) NSButton *resetNotesButton;
@property (weak, nonatomic) NSButton *cancelButton;
@property (nonatomic) _Bool isSetupForChangePassword;
@property (nonatomic) _Bool didAuthenticateWithBiometrics;
@property (readonly, nonatomic) _Bool isSetupForInitialPassword;
@property (readonly, nonatomic) _Bool passwordAndVerifyTextFieldsMatch;
@property (nonatomic) _Bool didAttemptToSubmitWithoutHint;
@property (weak, nonatomic) NSLayoutConstraint *firstFieldHeightLayoutConstraint;
@property (nonatomic) long long incorrectPasswordAttempts;
@property (weak, nonatomic) NSScrollView *oldPasswordIncorrectTextViewScrollView;
@property (retain, nonatomic) ICMAlertSheetTouchBarController *touchBarController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)touchBar;
- (void)viewDidAppear;
- (void)viewDidLoad;
- (void)cancelButtonPressed:(id)pressed;
- (void)viewWillAppear;
- (_Bool)validateInput;
- (void)setupAccessibility;
- (void)resetTextFields;
- (void)calcAndResizeHintTextView;
- (void)clickableTextViewDidClick:(id)click;
- (void)closeSheetWithResponse:(long long)response;
- (void)confirmButtonPressed:(id)pressed;
- (id)disclaimerWarningStringAndHasMultiplePasswordCapableAccounts:(_Bool)accounts;
- (void)resetNotesPressed:(id)pressed;
- (void)setOldPasswordIncorrectString:(id)string withColor:(id)color;
- (void)setUpDisclaimerTextView;
- (void)setUpForAddingPasswordWithAccount:(id)account;
- (void)setUpForChangePasswordWithAccount:(id)account didAuthenticateWithBiometrics:(_Bool)biometrics;

@end


@interface ICMPasswordEntrySheetViewController : NSViewController <NSTextFieldDelegate, NSTouchBarProvider, ICMClickableTextViewDelegate>

@property (weak, nonatomic) NSButton *okButton;
@property (weak, nonatomic) NSButton *cancelButton;
@property (weak, nonatomic) NSButton *resetPasswordButton;
@property (weak, nonatomic) NSImageView *iconImageView;
@property (weak, nonatomic) NSTextField *titleLabel;
@property (weak, nonatomic) ICMClickableTextView *subtitleClickableTextView;
@property (nonatomic) _Bool shouldDisplayLearnMoreLink;
@property (weak, nonatomic) NSSecureTextField *secureTextField;
@property (weak, nonatomic) NSTextField *passwordLabel;
@property (weak, nonatomic) NSTextView *hintTextView;
@property (weak, nonatomic) NSLayoutConstraint *hintTextViewHeightConstraint;
@property (nonatomic) unsigned long long authenticationResult;
@property (nonatomic) long long failedAttempts;
@property (readonly, nonatomic) NSString *hintStringForCurrentIntent;
@property (weak, nonatomic) NSLayoutConstraint *subtitleTextViewHeightConstraint;
@property (retain, nonatomic) NSString *subtitleText;
@property (retain, nonatomic) ICMAlertSheetTouchBarController *touchBarController;
@property (readonly, nonatomic) ICAuthenticationPrompt *prompt;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly) NSTouchBar *touchBar;

/* class methods */
+ (id)preferredHintAccount;

/* instance methods */
- (void)viewDidLoad;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)init;
- (void)dealloc;
- (id)initWithCoder:(id)coder;
- (void)cancelButtonPressed:(id)pressed;
- (void)okButtonPressed:(id)pressed;
- (void)setupAccessibility;
- (id)initWithPrompt:(id)prompt;
- (void)applySubtitleTextToSubtitleClickableTextView:(id)view;
- (void)calcAndResizeHintTextView;
- (void)clickableTextViewDidClick:(id)click;
- (void)closeSheetWithReturnCode:(long long)code;
- (void)resetNotesPasswordPressed:(id)pressed;
- (void)setHintString:(id)string withColor:(id)color;
- (void)setUpWithPrompt:(id)prompt;
- (void)showHint;

@end


@interface ICMProgressWindowController : NSWindowController

@property (nonatomic) _Bool isVisible;
@property (weak) NSProgressIndicator *progressIndicator;
@property (weak) NSTextField *progressLabel;
@property (weak) NSButton *stopButton;
@property (retain) NSWindow *containingWindow;
@property (retain, nonatomic) ICSelectorDelayer *showSelectorDelayer;
@property (weak, nonatomic) id <ICMProgressWindowControllerDelegate> delegate;
@property (nonatomic) double showHideThreshold;
@property (nonatomic) _Bool shouldShowSpinner;
@property (nonatomic) _Bool indeterminate;
@property (retain, nonatomic) NSString *progressText;
@property (nonatomic) double progressValue;
@property (nonatomic) _Bool shouldHideStopButton;
@property (retain, nonatomic) NSString *stopButtonTitle;

/* class methods */
+ (id)progressWindowControllerWithDelegate:(id)delegate;

/* instance methods */
- (void)windowDidLoad;
- (void)commonInit;
- (id)initWithWindow:(id)window;
- (_Bool)isIndeterminate;
- (id)initWithCoder:(id)coder;
- (void)hide;
- (void)didTapCancelButton:(id)button;
- (void)hideStopButton;
- (void)showInWindow:(id)window;
- (void)showWithDelayInWindow;

@end


@interface ICMUnscrollableScrollView : NSScrollView

/* instance methods */
- (void)scrollClipView:(id)view toPoint:(struct CGPoint)point;
- (void)scrollWheel:(id)wheel;

@end


@interface ICMWindow : NSWindow

@property (readonly, nonatomic) NSMutableSet *activeCorrectionPanels;
@property (readonly, nonatomic) _Bool hasActiveCorrectionPanel;
@property (nonatomic) _Bool disableFirstResponderChanges;

/* instance methods */
- (id)accessibilityFocusedUIElement;
- (void)addChildWindow:(id)window ordered:(long long)ordered;
- (_Bool)makeFirstResponder:(id)responder;
- (void)removeChildWindow:(id)window;

@end


@interface ICTTZoomController : NSObject

@property (nonatomic) double zoomFactor;
@property (nonatomic) double checklistZoomFactor;

/* instance methods */
- (id)init;
- (id)zoomAttributes:(id)attributes;
- (id)reallyZoomAttributedString:(id)string zoomDirection:(_Bool)direction;
- (id)reallyZoomAttributes:(id)attributes zoomDirection:(_Bool)direction;
- (id)reallyZoomFontInAttributes:(id)attributes zoomDirection:(_Bool)direction;
- (id)unzoomAttributedString:(id)string;
- (id)unzoomAttributes:(id)attributes;
- (id)unzoomFont:(id)font;
- (id)unzoomFontInAttributes:(id)attributes;
- (id)zoomAttributedString:(id)string;
- (id)zoomFont:(id)font;
- (id)zoomFontInAttributes:(id)attributes;

@end


@interface ICMZoomController : ICTTZoomController

@property (retain, nonatomic) NSHashTable *delegates;
@property (readonly, nonatomic) double localZoomFactor;
@property (nonatomic) long long savedZoomFactorIndex;
@property (nonatomic) double attachmentBrickZoomFactor;
@property (nonatomic) long long localZoomFactorIndex;
@property (nonatomic) _Bool onlyAcceptsCustomZooms;

/* class methods */
+ (double)attachmentBrickZoomFactor;
+ (id)attachmentBrickZoomFactors;
+ (double)checklistZoomFactor;
+ (id)checklistZoomFactors;
+ (id)convertFontSizeArrayToMultipliersFromArray:(id)array;
+ (double)globalZoomFactor;
+ (long long)globalZoomFactorIndex;
+ (id)globalZoomFactors;
+ (id)localZoomFactors;
+ (double)maxAttachmentBrickZoomFactor;
+ (double)noteListZoomFactor;
+ (id)noteListZoomFactors;
+ (void)setGlobalZoomFactorIndex:(long long)index;

/* instance methods */
- (void)removeDelegate:(id)delegate;
- (id)init;
- (void)addDelegate:(id)delegate;
- (_Bool)canZoomIn;
- (_Bool)canZoomOut;
- (_Bool)zoomOut;
- (_Bool)zoomIn;
- (void)notifyDelegates;
- (void)applyZoomFactorIndex;
- (_Bool)zoomResetToGlobalDefault;
- (_Bool)zoomToCustomFactor:(double)factor;

@end


@interface ICManagedObjectContextChangeController : NSObject

@property (retain, nonatomic) NSSet *managedObjectContexts;
@property (retain, nonatomic) NSMutableSet *needsUpdateManagedObjectIDs;
@property (retain, nonatomic) NSObject *needsUpdateManagedObjectIDsSerialQueue;
@property (readonly, nonatomic) NSSet *objectTypeKeys;
@property (retain, nonatomic) ICSelectorDelayer *updateSelectorDelayer;
@property (weak, nonatomic) id <ICManagedObjectContextChangeControllerDelegate> delegate;
@property (nonatomic) unsigned long long objectTypes;
@property (nonatomic) double updateInterval;

/* instance methods */
- (id)initWithDelegate:(id)delegate;
- (void)dealloc;
- (void)removeObservers;
- (void)managedObjectContextObjectsDidChange:(id)change;
- (void)addObservers;
- (void)_performUpdatesIfNeeded;
- (id)initWithManagedObjectContexts:(id)contexts delegate:(id)delegate;
- (void)performUpdatesIfNeeded;
- (void)performUpdatesIfNeededAndWait;

@end


@interface ICMarkdownRepresentation : NSObject

@property (retain, nonatomic) NSAttributedString *markdown;
@property (nonatomic) _Bool keepOriginalAttributes;
@property (nonatomic) _Bool filterConflictingAttributes;

/* class methods */
+ (id)attributedMarkdownStringFromPlainMarkdown:(id)markdown error:(id *)error;
+ (id)attributedStringFromPossibleMarkdown:(id)markdown fallback:(id)fallback;
+ (id)createMarkdownStringFrom:(id)from context:(id)context rangeMapping:(id *)mapping;
+ (_Bool)isMarkdownAttributedString:(id)string;
+ (_Bool)markdownAttributedStringContainsStyling:(id)styling;
+ (id)parseExtendedAttribute:(id)attribute token:(id)token markdown:(id)markdown;
+ (id)parseExtendedAttributes:(id)attributes;

/* instance methods */
- (id)createRenderableAttributedString;
- (id)initWithMarkdown:(id)markdown;
- (id)initWithPlainMarkdown:(id)markdown error:(id *)error;

@end


@interface ICMarkdownString : NSObject

/* class methods */
+ (id)attachmentStringFromTopoTextAttachment:(id)attachment withContext:(id)context;
+ (id)stringWithMarkdownStylesFromAttributedString:(id)string withContext:(id)context;

/* instance methods */
- (id)init;

@end


@interface ICMediaTime : NSObject <NSCopying>

@property (nonatomic) unsigned char days;
@property (nonatomic) unsigned char hours;
@property (nonatomic) unsigned char minutes;
@property (nonatomic) unsigned char seconds;
@property (nonatomic) unsigned char centiseconds;
@property (nonatomic) _Bool negative;
@property (readonly, nonatomic) _Bool isZero;
@property (readonly, nonatomic) NSString *durationDescription;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)isNegative;
- (id)initWithCMTime:(struct { long long x0; int x1; unsigned int x2; long long x3; })cmtime;
- (id)initWithSeconds:(double)seconds;
- (id)initWithSeconds:(double)seconds ignoreFractionalSeconds:(_Bool)seconds;
- (_Bool)isEqualToMediaTime:(id)time;

@end


@interface ICMediaTimeFormatter : NSDateComponentsFormatter

/* class methods */
+ (id)timecodeFormatter;
+ (id)wordyFormatter;

/* instance methods */
- (id)stringForObjectValue:(id)value;
- (id)stringFromTimeInterval:(double)interval;

@end


@interface ICMediaTimeLabel : NSTextField

@property (copy, nonatomic) ICMediaTime *mediaTimeValue;

/* instance methods */
- (void)commonInit;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;

@end


@interface ICMentionAttachmentView : ICInlineAttachmentView

@end


@interface ICMentionNotificationController : NSObject

@property (readonly, nonatomic) NSObject *notificationSerialQueue;

/* class methods */
+ (id)sharedController;
+ (struct _NSRange)rangeOfMention:(id)mention;
+ (id)coalesceMentions:(id)mentions;
+ (id)noteTitleForMentions:(id)mentions;
+ (id)pendingMentionsInContext:(id)context createdBeforeDate:(id)date;
+ (id)predicateForMentionsInState:(int)state inContext:(id)context;
+ (struct _NSRange)rangeOfParagraphForMention:(id)mention;
+ (struct _NSRange)rangeOfSentenceAfterMention:(id)mention;
+ (struct _NSRange)rangeOfSentenceBeforeMention:(id)mention;
+ (struct _NSRange)rangeOfSentenceForMention:(id)mention;
+ (struct _NSRange)rangeOfSnippetForMentions:(id)mentions;
+ (id)sameNoteMentionsFrom:(id)from;
+ (id)senderNameForMentions:(id)mentions;
+ (id)snippetForMentions:(id)mentions;
+ (void)triggerNotificationForMentionAttachments:(id)attachments context:(id)context;

/* instance methods */
- (void)reachabilityChanged:(id)changed;
- (void)applicationDidEnterBackground;
- (void)listenForReachabilityChange;
- (void)sendPendingNotifications;
- (void)sendPendingNotificationsCreatedBefore:(id)before;

@end


@interface ICMentionTextAttachment : ICInlineTextAttachment

@end


@interface ICMentionUIModel : ICInlineAttachmentUIModel

/* instance methods */
- (id)labelColor;
- (_Bool)fadesColorDuringHighlight;

@end


@interface ICMenuIconHelper : NSObject

/* class methods */
+ (id)imageForIcon:(long long)icon;
+ (id)symbolNameForIcon:(long long)icon;

@end


@interface ICMoveAlertUtilities : NSObject

/* class methods */
+ (void)postAlertForFolderDepthLimitWithCompletionHandler:(id /* block */)handler;
+ (void)postAlertForMovingFolderWithSharedNotes:(id)notes sharedSubfolders:(id)subfolders destination:(id)destination shareHandler:(id /* block */)handler cancelHandler:(id /* block */)handler;
+ (void)postAlertForMovingLockedNotesToOtherAccountIsCopy:(_Bool)copy completionHandler:(id /* block */)handler;
+ (void)postAlertForMovingLockedOrSingleJoinedNotesToSharedFolderWithCountOfNotes:(unsigned long long)notes guiltyObjects:(id)objects completionHandler:(id /* block */)handler;
+ (void)postAlertForMovingNotesContainingSharedNotesToSharedFolder:(id)folder destination:(id)destination shareHandler:(id /* block */)handler cancelHandler:(id /* block */)handler;
+ (void)postAlertForMovingSharedNotesToAnotherAccountWithCompletionHandler:(id /* block */)handler;
+ (void)postAlertForMovingSmartFolderWithRestrictedFilterToLocalAccount:(id)account;
+ (void)postAlertForOwnerStoppedSharingCurrentFolderWithCompletionHandler:(id /* block */)handler;
+ (void)postAlertForSharingFolderContainingLockedOrJoinedRootObjectsWithGuiltyObjects:(id)objects completionHandler:(id /* block */)handler;
+ (void)postAlertForSharingFolderWithSharedNotes:(id)notes sharedSubfolders:(id)subfolders shareHandler:(id /* block */)handler cancelHandler:(id /* block */)handler;
+ (void)postAlertForUnsupportedAttachmentsInLegacyAccount:(id)account;
+ (void)postAlertWithOKButtonWithTitle:(id)title message:(id)message completionHandler:(id /* block */)handler;
+ (void)postAlertWithProceedAndCancelButtonsWithTitle:(id)title message:(id)message proceedTitle:(id)title proceedHandler:(id /* block */)handler cancelHandler:(id /* block */)handler;
+ (void)setSuppressesAlerts:(_Bool)alerts;
+ (_Bool)suppressesAlerts;

@end


@interface ICMoveDecision : NSObject

@property (retain, nonatomic) NSMutableSet *filteredModernSourceObjects;
@property (retain, nonatomic) NSMutableArray *sanitizedFilteredModernSourceObjects;
@property (retain, nonatomic) NSMutableArray *ownedSharedRootObjectsInSource;
@property (retain, nonatomic) NSMutableArray *joinedSharedRootObjectsInSource;
@property (retain, nonatomic) NSMutableArray *readWriteSharedSubObjectsInSource;
@property (retain, nonatomic) NSMutableArray *readOnlySharedSubObjectsInSource;
@property (retain, nonatomic) NSMutableArray *lockedObjectsInSource;
@property (retain, nonatomic) NSMutableArray *unsupportedObjectsInSource;
@property (retain, nonatomic) NSArray *modernFoldersInSource;
@property (retain, nonatomic) NSMutableSet *accountsOfModernSourceObjects;
@property (retain, nonatomic) NSMutableSet *accountsOfHTMLSourceObjects;
@property (retain, nonatomic) NSMutableArray *privateModernNoteWithAttachmentsInSource;
@property (retain, nonatomic) NSMutableArray *sharedObjectsNotFromDestinationFolderInSource;
@property (retain, nonatomic) NSMutableArray *sharedObjectsInSource;
@property (retain, nonatomic) NSMutableArray *systemPaperNotesInSource;
@property (retain, nonatomic) NSMutableArray *nonSystemPaperNotesInSource;
@property (retain, nonatomic) NSMutableArray *mathNotesNotesInSource;
@property (retain, nonatomic) NSMutableArray *nonMathNotesNotesInSource;
@property (retain, nonatomic) NSMutableArray *callNotesInSource;
@property (retain, nonatomic) NSMutableArray *nonCallNotesInSource;
@property (nonatomic) _Bool hasSharedObjectsNotFromDestinationAccountInSource;
@property (nonatomic) _Bool hasLockedNotesNotFromDestinationAccountInSource;
@property (nonatomic) _Bool hasSanitizedAndScreenedModernSourceObjects;
@property (nonatomic) _Bool allowsManagedToUnmanagedMove;
@property (nonatomic) _Bool allowsUnmanagedToManagedMove;
@property (retain, nonatomic) NSArray *modernNotes;
@property (retain, nonatomic) NSArray *htmlNotes;
@property (readonly, nonatomic) _Bool shouldContinueDecisionMaking;
@property (readonly, nonatomic) NSArray *modernSourceObjects;
@property (readonly, nonatomic) NSArray *htmlSourceObjects;
@property (readonly, nonatomic) ICCloudSyncingObject *modernDestination;
@property (readonly, nonatomic) NFFolder *htmlDestinationFolder;
@property (readonly, nonatomic) ICVirtualSmartFolderItemIdentifier *virtualDestinationFolder;
@property (readonly, nonatomic) unsigned long long type;
@property (readonly, nonatomic) unsigned long long additionalStep;
@property (readonly, nonatomic) NSArray *guiltyObjects;
@property (readonly, nonatomic) _Bool shouldMove;
@property (readonly, nonatomic) _Bool shouldProceed;
@property (readonly, nonatomic) NSMutableArray *lockedObjectInSource;
@property (readonly, nonatomic) _Bool hasLockedObjects;
@property (readonly, nonatomic) ICFolder *modernDestinationFolder;
@property (readonly, nonatomic) ICAccount *modernDestinationAccount;

/* class methods */
+ (_Bool)isValidModernDestinationObject:(id)object;
+ (_Bool)isValidHTMLDestinationObject:(id)object;
+ (_Bool)isValidHTMLSourceObject:(id)object;
+ (_Bool)isValidModernSourceObject:(id)object;
+ (_Bool)isValidVirtualDestinationObject:(id)object;
+ (id)objectsForMakingDecisionForNonSharedFolder:(id)folder;
+ (_Bool)shouldCopyThenDeleteWhenMovingObject:(id)object toNoteContainer:(id)container;

/* instance methods */
- (id)typeString;
- (id)description;
- (void)_makeDecisionForMovingBetweenManagedAndUnmanagedAccounts;
- (void)_makeDecisionForMovingHTMLObjectsToHTMLDestination;
- (void)_makeDecisionForMovingHTMLObjectsToModernDestination;
- (void)_makeDecisionForMovingHTMLObjectsToVirtualDestination;
- (void)_makeDecisionForMovingModernObjectsToHTMLDestination;
- (void)_makeDecisionForMovingModernObjectsToModernDestination;
- (void)_makeDecisionForMovingModernObjectsToVirtualDestination;
- (void)_sanitizeAndScreenFilteredModernSourceObjectsIfNecessary;
- (void)_setDecisionWithType:(unsigned long long)type additionalStep:(unsigned long long)step guiltyObjects:(id)objects;
- (void)_setDecisionWithType:(unsigned long long)type guiltyObjects:(id)objects;
- (id)accountForObject:(id)object;
- (id)htmlAccountForObject:(id)object;
- (id)initWithSourceObjects:(id)objects destination:(id)destination;
- (id)initWithSourceObjects:(id)objects destination:(id)destination allowsManagedToUnmanagedMove:(_Bool)move allowsUnmanagedToManagedMove:(_Bool)move;

@end


@interface ICMovieTextAttachment : ICTextAttachment

@end


@interface ICNoteEditorIconImageView : NSImageView <ICMZoomableAttachmentView>

@property (retain, nonatomic) ICMZoomController *zoomController;
@property (nonatomic) double maxZoomFactor;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (struct CGSize)intrinsicContentSize;
- (void)hostViewDidZoom:(id)zoom;

@end


@interface ICNoteLockManager : NSObject

@property (retain, nonatomic) ICNote *updatedNote;
@property (readonly, nonatomic) ICAccount *account;
@property (readonly, nonatomic) ICNote *note;
@property (weak, nonatomic) NSWindow *window;

/* instance methods */
- (id)initWithNote:(id)note;
- (void)addLockWithCompletionHandler:(id /* block */)handler;
- (void)removeLockWithCompletionHandler:(id /* block */)handler;
- (void)toggleLockWithCompletionHandler:(id /* block */)handler;
- (void)unsafelyToggleLockWithCompletionHandler:(id /* block */)handler;
- (void)updateDivergedAttachmentsWithConfiguration:(id)configuration completion:(id /* block */)completion;
- (void)updateDivergedAttachmentsWithPassphrase:(id)passphrase completion:(id /* block */)completion;

@end


@interface ICNoteSectionIdentifier : NSObject <ICSectionIdentifier>

@property (nonatomic) long long sectionType;
@property (readonly, nonatomic) _Bool containsRelevantIdentifiers;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, nonatomic) _Bool collapsible;
@property (readonly, copy, nonatomic) NSString *expansionStateContext;
@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sortDescriptors;
+ (id)titles;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)isCollapsible;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithNoteSectionType:(long long)type;
- (_Bool)isEqualToICNoteSectionIdentifier:(id)identifier;

@end


@interface ICNoteTimelineController : NSObject

/* class methods */
+ (void)setTimeZone:(id)zone;
+ (id)timelineSectionsForNoteObjectIDs:(id)ids dates:(id)dates referenceDate:(id)date direction:(long long)direction;
+ (id)adjustedDateForReferenceDate:(id)date;
+ (id)invitationsTimelineSectionIdentifierWithTitle:(id)title referenceDate:(id)date;
+ (id)pinnedTimelineSectionIdentifierWithTitle:(id)title referenceDate:(id)date;
+ (id)sanitizedDatesForDates:(id)dates referenceDate:(id)date;
+ (id)timelineSectionIdentifierForNoteObjectID:(id)id date:(id)date referenceDate:(id)date;
+ (id)timelineSectionIdentifierForNoteObjectID:(id)id date:(id)date sectionIdentifiersToManagedObjectIDs:(id)ids;

@end


@interface ICNoteTimelineSection : NSObject

@property (retain, nonatomic) ICNoteTimelineSectionIdentifier *identifier;
@property (retain, nonatomic) NSArray *objectIDs;

/* instance methods */
- (id)initWithIdentifier:(id)identifier objectIDs:(id)ids;

@end


@interface ICNoteTimelineSectionIdentifier : ICNoteSectionIdentifier

@property (nonatomic) long long timelineSectionType;
@property (copy, nonatomic) NSDate *referenceDate;
@property (copy, nonatomic) NSString *sectionTitle;
@property (nonatomic) unsigned long long sortOrder;

/* class methods */
+ (id)sortDescriptorsWithDirection:(long long)direction;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)typeString;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)title;
- (id)initWithTimelineSectionType:(long long)type referenceDate:(id)date title:(id)title sortOrder:(unsigned long long)order;
- (_Bool)isEqualToICNoteTimelineSectionIdentifier:(id)identifier;

@end


@interface ICNotesImporterClient : NSObject

@property (retain, nonatomic) NSObject *requestCountQueue;
@property (nonatomic) unsigned long long requestCount;

/* instance methods */
- (id)init;
- (void)archiveEvernoteNotesFromFileURL:(id)url completionBlock:(id /* block */)block;
- (void)cleanupArchiveId:(id)id completionBlock:(id /* block */)block;
- (void)countEvernoteNotesFromFileURL:(id)url completionBlock:(id /* block */)block;
- (void)parseHTMLStringFromEvernoteContentString:(id)string completionBlock:(id /* block */)block;
- (void)parseTitleFromHTMLString:(id)htmlstring completionBlock:(id /* block */)block;
- (void)resumeConnectionIfNeeded;
- (void)suspendConnectionIfNeeded;
- (void)unarchiveEvernoteNoteFromArchiveId:(id)id noteArchiveId:(id)id completionBlock:(id /* block */)block;
- (void)unarchiveEvernoteResourceFromArchiveId:(id)id resourceArchiveId:(id)id completionBlock:(id /* block */)block;

@end


@interface ICNumberLiteral : NSObject

@property (nonatomic) struct _NSRange range;
@property (nonatomic, copy) NSString *string;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)initWithRange:(struct _NSRange)range string:(id)string;

@end


@interface ICOutlineController : NSObject

@property (retain, nonatomic) OutlineController *outlineControllerObject;
@property (readonly, nonatomic) ICTTTextStorage *textStorage;
@property (nonatomic) _Bool isAsynchronous;
@property (retain, nonatomic) NSSet *collapsedUUIDs;
@property (readonly, nonatomic) long long collapsibleSectionAffordanceUsages;
@property (readonly, nonatomic) struct _NSRange visibleRange;
@property (readonly, nonatomic) NSArray *visibleRangeValues;
@property (readonly, nonatomic) NSArray *invisibleRangeValues;
@property (readonly, nonatomic) NSArray *rangesValuesContainingCollapsedRanges;
@property (readonly, nonatomic) NSArray *rangesValuesContainingExpandedRanges;

/* instance methods */
- (void)requestUpdate;
- (id)ancestorsForUUID:(id)uuid;
- (_Bool)canCollapseAnyUUIDs:(id)uuids;
- (_Bool)canExpandAnyUUIDs:(id)uuids;
- (id)closestVisibleAncestorForUUID:(id)uuid;
- (void)collapseAll;
- (void)collapseUUIDs:(id)uuids;
- (void)collapsibleSectionAffordanceUsedForUUIDs:(id)uuids;
- (struct _NSRange)descendantRangeForUUID:(id)uuid;
- (id)descendantsForUUID:(id)uuid;
- (void)expandAll;
- (void)expandAncestorsOfRange:(struct _NSRange)range;
- (void)expandUUIDs:(id)uuids;
- (id)initWithTextStorage:(id)storage collapsedUUIDs:(id)uuids asynchronous:(_Bool)asynchronous;
- (_Bool)isUUIDCollapsed:(id)uuidcollapsed;
- (_Bool)isUUIDCollapsible:(id)uuidcollapsible;
- (_Bool)isUUIDHidden:(id)uuidhidden;
- (struct _NSRange)rangeForUUID:(id)uuid;
- (void)resetCollapsibleSectionAffordanceUsages;
- (_Bool)toggleCollapsedAtRange:(struct _NSRange)range;
- (void)toggleUUIDCollapsed:(id)uuidcollapsed;

@end


@interface ICPDFEncryptionStateChecker : NSObject <NSCopying>

@property (nonatomic) unsigned long long encryptionState;
@property (readonly, copy, nonatomic) NSURL *pdfURL;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithPDFURL:(id)pdfurl;

@end


@interface ICPDFPreviewHelper : NSObject

/* class methods */
+ (_Bool)drawPreviewOfPDFDocument:(id)pdfdocument inRect:(struct CGRect)rect;

@end


@interface ICPDFTextAttachment : ICTextAttachment

@property (copy, nonatomic) ICPDFEncryptionStateChecker *encryptionStateChecker;

/* instance methods */
- (short)effectiveAttachmentViewSizeForTextContainer:(id)container;
- (id)supportedPresentationSizes;

@end


@interface ICSystemPaperTextAttachment : ICInlineCanvasTextAttachment <PKPaperTextAttachment>

@property (readonly, nonatomic) NSString *_paperIdentifier;
@property (readonly, nonatomic) NSURL *_paperBundleURL;
@property (readonly, nonatomic) NSURL *_encryptionDelegateCRContextURL;
@property (readonly, nonatomic) NSURL *_nonEncryptedContentCRContextURL;
@property (retain, nonatomic) NSHashTable *systemPaperViews;
@property (copy, nonatomic) NSString *paperIdentifierBeforeAttachmentIsSet;
@property (retain, nonatomic) ICDrawingHashtagsAndMentionsController *hashtagsAndMentionsController;
@property (weak, nonatomic) NSView *cachedDrawingViewForPlaceView;
@property (weak, nonatomic) NSView *cachedControlViewForPlaceView;
@property (retain, nonatomic) ICSelectorDelayer *paperChangeSelectorDelayer;
@property (nonatomic) _Bool placeholder;

/* class methods */
+ (_Bool)isEnabled;

/* instance methods */
- (id)fileType;
- (_Bool)isPlaceholder;
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (id)contents;
- (id)_image;
- (void)dealloc;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)initWithData:(id)data ofType:(id)type;
- (void)detachView:(id)view fromParentView:(id)view;
- (void)placeView:(id)view withFrame:(struct CGRect)frame inParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (id)viewProviderForParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;
- (id)attachmentViews;
- (void)_linkCanvasElementsDidChange;
- (struct CGRect)_paperBoundsHint;
- (void)_paperDidChangeLocally;
- (struct CGSize)_paperSizeHint;
- (id)attachmentAsNSTextAttachment;
- (_Bool)canDragWithoutSelecting;
- (void)configureHashtagAndMentionsForView:(id)view;
- (id)initWithPaperIdentifier:(id)identifier;
- (id)inlineViews;
- (void)paperDidChange;
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (void)updateAttachmentChangeCountAndSave:(id)save;

@end


@interface ICPaperDocumentTextAttachment : ICSystemPaperTextAttachment

@property (copy, nonatomic) ICPDFEncryptionStateChecker *encryptionStateChecker;
@property (readonly, nonatomic) _Bool isLegacyMediaType;
@property (readonly, nonatomic) NSURL *pdfURL;
@property (nonatomic) _Bool viewportShouldSnapToAttachmentView;

/* class methods */
+ (void)initialize;
+ (_Bool)isEnabled;

/* instance methods */
- (id)fileType;
- (id)initWithData:(id)data ofType:(id)type;
- (id)_paperBundleURL;
- (void)attachmentView:(id)view didMoveToWindow:(id)window;
- (id)attachmentAsNSTextAttachment;
- (void)attachmentView:(id)view willMoveToWindow:(id)window;
- (_Bool)canDragWithoutSelecting;
- (short)effectiveAttachmentViewSizeForTextContainer:(id)container;
- (void)paperDidChange;
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (id)supportedPresentationSizes;

@end


@interface ICPaperSearchIndexer : NSObject

/* class methods */
+ (id)shared;

/* instance methods */
- (id)init;
- (void)cancelEverythingWithCompletion:(id /* block */)completion;
- (void)needsToUpdateIndexWithManagedObjectContext:(NSManagedObjectContext *)context completionHandler:(id /* block */)handler;
- (void)updateIndexForAttachment:(NSManagedObjectID *)attachment userInitiated:(_Bool)initiated managedObjectContext:(NSManagedObjectContext *)context completionHandler:(id /* block */)handler;
- (void)updateIndexForAttachments:(NSSet *)attachments userInitiated:(_Bool)initiated managedObjectContext:(NSManagedObjectContext *)context completionHandler:(id /* block */)handler;
- (void)updateIndexWithManagedObjectContext:(NSManagedObjectContext *)context completionHandler:(id /* block */)handler;

@end


@interface ICPaperSearchIndexerBackgroundTask : NSObject <ICBackgroundTask>

@property (readonly, nonatomic) ICNoteContext *noteContext;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)makeActivityScheduler;

/* instance methods */
- (void)didRegister:(_Bool)_register;
- (void)handleTaskExpiration;
- (void)runTaskWithCompletion:(id /* block */)completion;
- (id)initWithNoteContext:(id)context;

@end


@interface ICPaperStyle : NSObject

/* class methods */
+ (void)drawPaperStyleType:(unsigned long long)type inRect:(struct CGRect)rect;
+ (id)linedPaperWithPaperStyleType:(unsigned long long)type;

@end


@interface ICPasswordUtilities : NSObject

@property (retain, nonatomic) id displayedSheet;

/* class methods */
+ (id)sharedInstance;
+ (id)defaultAccountForPasswordProtectedNotes;
+ (id)imageForCurrentDecryptedStatusForNote:(id)note imageType:(unsigned long long)type;
+ (void)resetTimeoutTimer;
+ (void)rewrapCryptoKeyForObject:(id)object window:(id)window;
+ (void)setTouchIDEnabledForSharedPassword:(_Bool)password account:(id)account displayWindow:(id)window completionHandler:(id /* block */)handler;
+ (void)showReauthenticateTouchIDSheetInWindow:(id)window completionHandler:(id /* block */)handler;

/* instance methods */
- (void)offerDevicePasswordOrResetPasswordForAccount:(id)account displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)showPasswordChangeSheetForAccount:(id)account didAuthenticateWithBiometrics:(_Bool)biometrics displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)showPasswordChangeSheetForAccount:(id)account displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)showPasswordSetUpSheetForAccount:(id)account displayWindow:(id)window completionHandler:(id /* block */)handler;
- (void)showReauthenticateTouchIDSheetInWindow:(id)window completionHandler:(id /* block */)handler;
- (void)showResetPasswordSheetForAccount:(id)account displayWindow:(id)window completionHandler:(id /* block */)handler;

@end


@interface ICPressableAttachmentAccessibilityElement : NSAccessibilityElement <NSAccessibilityButton>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)accessibilityLabel;
- (id)initWithTextView:(id)view;
- (struct CGRect)accessibilityFrame;
- (id)accessibilityParent;
- (_Bool)accessibilityPerformPress;
- (id)accessibilityRoleDescription;

@end


@interface ICPreviewDeviceContext : NSObject

@property (copy) NSArray *scalableDeviceInfo;
@property (copy) NSArray *nonScalableDeviceInfo;
@property (readonly) NSArray *deviceScales;
@property (readonly) double maxDeviceScale;

/* class methods */
+ (id)sharedContext;

/* instance methods */
- (id)init;
- (void)dealloc;
- (double)maxSizeOfPreviewDeviceInfoImage;
- (id)deviceInfoScalable:(_Bool)scalable;
- (void)screensChangedNotification:(id)notification;

@end


@interface ICPreviewLayoutManager : ICBaseLayoutManager

@property (nonatomic) unsigned long long maxCharacterCount;
@property (retain, nonatomic) NSTextStorage *strongTextStorage;
@property (nonatomic) _Bool insideSystemPaper;

/* instance methods */
- (id)linkAttributesForLink:(id)link forCharacterAtIndex:(unsigned long long)index;
- (void)drawGlyphsForGlyphRange:(struct _NSRange)range atPoint:(struct CGPoint)point;
- (void)drawTodoItemForListRange:(struct _NSRange)range paragraphStyle:(id)style atOrigin:(struct CGPoint)origin;
- (void)drawTodosForCharacterRange:(struct _NSRange)range atOrigin:(struct CGPoint)origin;
- (id)initWithNote:(id)note maxCharacterCount:(unsigned long long)count textContainer:(id)container textController:(id)controller;
- (_Bool)isInsideSystemPaper;
- (id)todoImageForParagraphStyle:(id)style;

@end


@interface ICPrintableTextAttachment : NSTextAttachment

@property (nonatomic) struct CGPoint frameOffset;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (struct CGRect)adjustedBounds:(struct CGRect)bounds forProposedLineFragment:(struct CGRect)fragment textContainer:(id)container;

@end


@interface ICRecentNotesCoreDataIndexer : ICCoreDataIndexer

@property (readonly, nonatomic) NSObject *indexAccessQueue;
@property (readonly, nonatomic) NSFetchedResultsController *modernNoteFetchedResultsController;
@property (readonly, nonatomic) NSFetchedResultsController *legacyNoteFetchedResultsController;
@property (readonly, nonatomic) NSArray *sortedSectionIdentifiers;
@property (readonly, nonatomic) NSMutableDictionary *sectionIdentifiersToManagedObjectIDs;
@property (nonatomic) long long sortType;
@property (nonatomic) unsigned long long maximumNumberOfNotesPerAccount;
@property (nonatomic) _Bool checklistsOnly;
@property (nonatomic) _Bool pinnedOnly;
@property (nonatomic) _Bool passwordProtectedOnly;
@property (nonatomic) _Bool nonPasswordProtectedOnly;
@property (nonatomic) _Bool sharedOnly;

/* instance methods */
- (id)activeFetchedResultsControllers;
- (id)firstRelevantItemIdentifier;
- (id)indexObjectsInSection:(id)section sectionIndex:(unsigned long long)index fetchedResultsController:(id)controller;
- (id)initWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)newSnapshotFromIndexWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)nextRelevantItemIdentifierAfter:(id)after;
- (id)sectionIdentifierForHeaderInSection:(long long)section;
- (id)sectionIdentifiersForSectionType:(unsigned long long)type;
- (void)setShouldIncludeOutlineParentItems:(_Bool)items;
- (void)willIndex;

@end


@interface ICSearchResult : NSObject <ICItemIdentifier>

@property (retain, nonatomic) id <ICSearchIndexable> currentContextObject;
@property (readonly, nonatomic) NSDictionary *decomposedHighlightInfo;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (retain, nonatomic) NSValue *firstMatchingRangeInNote;
@property (retain, nonatomic) NSRegularExpression *tipKitCheckRegex;
@property (retain, nonatomic) NSString *displayingTitle;
@property (retain, nonatomic) NSAttributedString *displayingAttributedTitle;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *titleHighlightRegexMatchFinder;
@property (retain, nonatomic) NSTextCheckingResult *displayingTitleCheckingResult;
@property (retain, nonatomic) NSAttributedString *titleAttributedString;
@property (nonatomic) struct CGRect titleAttributedStringInsideFrame;
@property (retain, nonatomic) NSString *displayingSnippet;
@property (retain, nonatomic) NSAttributedString *displayingAttributedSnippet;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *snippetHighlightRegexMatchFinder;
@property (retain, nonatomic) NSTextCheckingResult *displayingSnippetCheckingResult;
@property (retain, nonatomic) NSAttributedString *snippetAttributedString;
@property (nonatomic) struct CGRect snippetAttributedStringInsideFrame;
@property (nonatomic) _Bool isDisplayingParticipantMatch;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *participantHighlightRegexMatchFinder;
@property (readonly, nonatomic) id <ICSearchIndexable> object;
@property (nonatomic) _Bool mathNote;
@property (readonly, nonatomic) ICSearchResultConfiguration *configuration;
@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)attributedStringWithMatchHighlighted:(id)highlighted optionalAttributedHighlightedString:(id)string textCheckingResult:(id)result highlightColor:(id)color insideFrame:(struct CGRect)frame finishingUpRegexMatchFinder:(id)finder;
+ (id)attributedStringWithMatchHighlighted:(id)highlighted optionalAttributedHighlightedString:(id)string textCheckingResult:(id)result usingAttributes:(id)attributes highlightColor:(id)color insideFrame:(struct CGRect)frame isSnippetForParticipantMatch:(_Bool)match finishingUpRegexMatchFinder:(id)finder;
+ (id)attributedStringWithMatchHighlighted:(id)highlighted textCheckingResult:(id)result highlightColor:(id)color insideFrame:(struct CGRect)frame finishingUpRegexMatchFinder:(id)finder;
+ (id)attributesByHighlightingAttributes:(id)attributes withHighlightColor:(id)color;
+ (id)authorNameToHighlightForNote:(id)note fromSearchResult:(id)result textCheckingResult:(id *)result;
+ (struct CGRect)boundingRectForAttributedString:(id)string fittingSize:(struct CGSize)size;
+ (_Bool)canFitAttributedString:(id)string ellipses:(id)ellipses shouldPrefixWithEllipses:(_Bool)ellipses insideFrame:(struct CGRect)frame centered:(_Bool)centered;
+ (id)finishUpHighlightingWithMatchFinder:(id)finder forAttributedString:(id)string inRange:(struct _NSRange)range highlightedAttributes:(id)attributes;
+ (id)firstTextCheckingResultOfRegex:(id)regex inDocumentText:(id)text;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)isMathNote;
- (id)attributedSummaryWithBaseAttributes:(id)attributes highlightColor:(id)color insideFrame:(struct CGRect)frame;
- (id)attributedTitleWithBaseAttributes:(id)attributes highlightColor:(id)color insideFrame:(struct CGRect)frame;
- (long long)compareByModificationDate:(id)date;
- (id)initWithMainContextObject:(id)object currentContextObject:(id)object configuration:(id)configuration;
- (id)initWithObject:(id)object configuration:(id)configuration;
- (void)initializeRegexes;
- (void)prepareDisplayingSnippetWithAccessingObject:(id)object;
- (void)prepareDisplayingTitleWithAccessingObject:(id)object;
- (void)prepareFirstMatchingRangeWithAccessingObject:(id)object;
- (void)refetchObjectFromContext:(id)context;
- (void)refreshDisplaySnippet;
- (void)refreshDisplayTitle;
- (void)refreshFirstMatchingRange;
- (id)snippetWithBaseAttributes:(id)attributes highlightColor:(id)color insideFrame:(struct CGRect)frame;

@end


@interface ICSearchResultConfiguration : NSObject

@property (readonly, nonatomic) NSString *searchString;
@property (readonly, nonatomic) unsigned long long searchStringLength;
@property (readonly, nonatomic) unsigned long long searchSuggestionType;
@property (readonly, nonatomic) _Bool isTopHit;
@property (readonly, nonatomic) NSManagedObjectID *foundAttachmentObjectID;
@property (readonly, nonatomic) ICSortableSearchableItem *sortableSearchableItem;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)hash;
- (id)initWithSearchString:(id)string searchSuggestionType:(unsigned long long)type isTopHit:(_Bool)hit foundAttachmentObjectID:(id)id sortableSearchableItem:(id)item;

@end


@interface ICSearchResultRegexMatchFinder : NSObject

@property (retain, nonatomic) NSSet *prefixMatchingTokens;
@property (retain, nonatomic) NSSet *substringMatchingTokens;
@property (retain, nonatomic) NSString *searchString;
@property (retain, nonatomic) NSRegularExpression *normalRegex;
@property (retain, nonatomic) NSRegularExpression *fallbackRegex;

/* class methods */
+ (id)matchesForToken:(id)token inDocument:(id)document checkPrefixBeforeFallingBack:(_Bool)back;
+ (_Bool)textCheckingResultsAreValid:(id)valid;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithSearchString:(id)string;
- (unsigned long long)hash;
- (id)firstMatchInDocumentWithGlobalFallback:(id)fallback;
- (id)initWithPrefixMatchingTokens:(id)tokens substringMatchingTokens:(id)tokens searchString:(id)string;
- (id)matchesInDocumentWithPerTokenFallback:(id)fallback;

@end


@interface ICSearchResultSection : NSObject

@property (retain, nonatomic) NSMutableOrderedSet *searchResults;
@property (retain, nonatomic) NSMutableDictionary *identifierToSearchResult;
@property (retain, nonatomic) NSMutableDictionary *hiddenSearchResults;
@property (retain, nonatomic) NSMutableDictionary *unhiddenSearchResults;

/* instance methods */
- (id)identifiers;
- (id)description;
- (id)init;
- (void)addSearchResults:(id)results;
- (id)hiddenIdentifiers;
- (_Bool)removeSearchResultForIdentifier:(id)identifier forHiding:(_Bool)hiding;
- (void)resetToSearchResults:(id)results;

@end


@interface ICSearchTextCheckingResult : NSTextCheckingResult

@property (nonatomic) struct _NSRange ic_range;
@property (retain, nonatomic) NSString *csEvaluatorMatchString;

/* instance methods */
- (struct _NSRange)range;
- (id)initWithRange:(struct _NSRange)range;
- (id)initWithRange:(struct _NSRange)range csEvaluatorMatchString:(id)string;

@end


@interface ICSearchUserInput : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSString *searchString;
@property (readonly, nonatomic) NSArray *tokens;
@property (readonly, copy, nonatomic) NSString *keyboardLanguage;
@property (readonly, nonatomic) _Bool isEmpty;
@property (readonly, copy, nonatomic) NSString *displayString;

/* class methods */
+ (id)emptyInput;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)_configureEmptyInput;
- (id)initWithSearchString:(id)string tokens:(id)tokens keyboardLanguage:(id)language;

@end


@interface ICSectionedSearchResults : NSObject

@property (retain, nonatomic) NSMutableDictionary *searchResultsBySection;
@property (readonly, nonatomic) NSArray *allSearchResults;
@property (nonatomic) _Bool disableAutomaticUpdates;

/* class methods */
+ (id)newSearchResultsBySection;

/* instance methods */
- (_Bool)hasSearchResults;
- (void)clear;
- (id)description;
- (id)init;
- (void)dealloc;
- (void)noteWillBeUndeletedOrUntrashed:(id)untrashed;
- (_Bool)hideSearchResultsForIdentifier:(id)identifier;
- (void)addSearchResult:(id)result toSection:(unsigned long long)section atIndex:(unsigned long long)index;
- (unsigned long long)addSearchResults:(id)results removingFoundIdentifiers:(id)identifiers passingVisibilityTesting:(id)testing;
- (void)addSearchResults:(id)results toSection:(unsigned long long)section;
- (unsigned long long)addSearchResultsBySection:(id)section;
- (unsigned long long)countForSection:(unsigned long long)section;
- (void)filterSearchResultsUsingVisiblityTesting:(id)testing;
- (_Bool)hideSearchResultsForObjects:(id)objects;
- (id)indexPathOfObject:(id)object;
- (id)indexPathOfSearchResult:(id)result;
- (void)noteWillBeDeletedOrTrashed:(id)trashed;
- (void)objectsDidChange:(id)change;
- (_Bool)passesVisibilityTesting:(id)testing forSearchResult:(id)result;
- (id)removeSearchResultAtRow:(long long)row section:(unsigned long long)section;
- (_Bool)removeSearchResultWithIdentifier:(id)identifier forHiding:(_Bool)hiding;
- (_Bool)removeSearchResultWithIdentifier:(id)identifier fromSection:(unsigned long long)section forHiding:(_Bool)hiding;
- (unsigned long long)removeSearchResultsWithIdentifiers:(id)identifiers forHiding:(_Bool)hiding;
- (_Bool)replaceSearchResultObject:(id)object withObject:(id)object;
- (id)searchResultAtRow:(long long)row section:(unsigned long long)section;
- (id)searchResultObjectsInSection:(unsigned long long)section;
- (id)searchResultSectionForSectionIndex:(unsigned long long)index;
- (id)searchResultWithObject:(id)object;
- (id)searchResultsBySectionForSearchResults:(id)results passingVisibilityTesting:(id)testing;
- (id)searchResultsInSection:(unsigned long long)section;
- (unsigned long long)sectionForSearchResult:(id)result;
- (void)setSearchResults:(id)results forSection:(unsigned long long)section;
- (void)updateForSortTypeChange;

@end


@interface ICShareNoteExporter : NSObject

@property (retain, nonatomic) NSURL *exportDirectory;

/* instance methods */
- (void)cleanUpExportedFiles;
- (id)exportRTFDFileFromNote:(id)note;
- (id)fileWrapperForNote:(id)note;
- (id)filenameFromTitle:(id)title;

@end


@interface ICSystemPaperImageGenerator : NSObject

@property (nonatomic) _Bool sixChannelBlendingEnabled;
@property (readonly, nonatomic) struct CGRect paperContentBounds;
@property (readonly, nonatomic) _Bool hasDeepLink;

/* class methods */
+ (id)imageGeneratorWithPaperAttachment:(id)attachment;
+ (id)imageGeneratorWithPaperAttachment:(id)attachment useActivePaper:(_Bool)paper;

/* instance methods */
- (id)init;
- (id)initWithPaperAttachment:(id)attachment;
- (_Bool)drawPaperInRect:(struct CGRect)rect;
- (void)imageWithBounds:(struct CGRect)bounds completion:(id /* block */)completion;
- (id)imageWithFullResolution:(_Bool)resolution inverted:(_Bool)inverted;
- (id)initWithPaperAttachment:(id)attachment useActivePaper:(_Bool)paper;
- (_Bool)isSixChannelBlendingEnabled;
- (_Bool)validatePaperBounds:(struct CGRect)bounds;

@end


@interface ICSwiftSystemPaperImageGenerator : ICSystemPaperImageGenerator

@property (nonatomic, readonly) struct CGRect paperContentBounds;
@property (nonatomic, readonly) _Bool hasDeepLink;

/* instance methods */
- (_Bool)drawPaperInRect:(struct CGRect)rect;
- (void)imageWithBounds:(struct CGRect)bounds completion:(id /* block */)completion;
- (id)imageWithFullResolution:(_Bool)resolution inverted:(_Bool)inverted;
- (id)initWithPaperAttachment:(id)attachment useActivePaper:(_Bool)paper;

@end


@interface ICSystemPaperThumbnailService : NSObject

@property (retain, nonatomic) ICSystemPaperThumbnailServiceInternal *systemPaperThumbnailService;
@property (retain, nonatomic) UITraitCollection *traitCollection;

/* class methods */
+ (id)sharedService;

/* instance methods */
- (void)cancel;
- (void)invalidate;
- (void)observe;
- (id)initWithSystemPaperThumbnailService:(id)service;
- (void)invalidateForNote:(id)note;
- (void)updateIfNeededForNote:(id)note completion:(id /* block */)completion;
- (void)updateIfNeededWithCompletion:(id /* block */)completion;

@end


@interface ICSystemPaperThumbnailServiceInternal : NSObject

@property (nonatomic, readonly) ICThumbnailService *thumbnailService;

/* class methods */
+ (id)sharedService;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)cancel;
- (void)invalidate;
- (void)observe;
- (void)immediatelyClearPaperSystemPaperPreview;
- (void)invalidateForNote:(id)note;
- (void)invalidateForNoteIDs:(id)ids;
- (void)invalidateForNotes:(id)notes;
- (void)updateIfNeededForNote:(id)note completion:(id /* block */)completion;
- (void)updateIfNeededForNoteIDs:(id)ids completion:(id /* block */)completion;
- (void)updateIfNeededForNotes:(id)notes completion:(id /* block */)completion;
- (void)updateIfNeededWithCompletion:(id /* block */)completion;
- (void)updateRecentSystemPaperNote;

@end


@interface ICTK2BulletTextAttachment : ICTextAttachment

@property (readonly, nonatomic) NSAttributedString *marker;

/* instance methods */
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (id)initWithMarker:(id)marker;

@end


@interface ICTK2BulletTextAttachmentView : NSView

@property (retain, nonatomic) NSAttributedString *marker;

/* instance methods */
- (void)drawRect:(struct CGRect)rect;
- (_Bool)isFlipped;
- (id)initWithMarker:(id)marker;

@end


@interface ICTK2BulletTextAttachmentViewProvider : NSTextAttachmentViewProvider

/* instance methods */
- (void)loadView;
- (id)initWithTextAttachment:(id)attachment parentView:(id)view textLayoutManager:(id)manager location:(id)location textContainer:(id)container;

@end


@interface ICTTTextController : NSObject <ICTTTextStorageStyler>

@property (nonatomic) _Bool showsEditorDebugTooltips;
@property (nonatomic) double bodyStyleFontSizeThreshold;
@property (nonatomic) double headingStyleFontSizeThreshold;
@property (nonatomic) unsigned long long defaultTabInterval;
@property (retain, nonatomic) NSDictionary *indentForHeadIndent;
@property (retain, nonatomic) ICTTZoomController *zoomController;
@property (nonatomic) _Bool keepNSTextTableAttributes;
@property (nonatomic) _Bool disableSingleLineA;
@property (nonatomic) _Bool inPreviewMode;
@property (nonatomic) _Bool isForPrint;
@property (nonatomic) _Bool isForSiri;
@property (nonatomic) _Bool disableAddingExtraLinesIfNeeded;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (double)attachmentParagraphSpacing;
+ (double)attachmentParagraphSpacingBefore;
+ (double)bodyParagraphSpacing;
+ (double)bodyParagraphSpacingBefore;
+ (id)preferredFontForICTTTextStyle:(unsigned int)style;
+ (double)superscriptScaleFactor;

/* instance methods */
- (id)titleAttributes;
- (id)init;
- (_Bool)isInPreviewMode;
- (void)styleFontInTextStorage:(id)storage inRange:(struct _NSRange)range;
- (void)addBIToStyle:(id)style;
- (id)bodyAttributes;
- (id)bodyAttributesWithContentSizeCategory:(id)category;
- (id)captionAttributes;
- (id)captionAttributesWithContentSizeCategory:(id)category;
- (id)checklistAttributes;
- (id)checklistAttributesWithContentSizeCategory:(id)category;
- (id)copyAttribute:(id)attribute fromAttributes:(id)attributes toAttributes:(id)attributes;
- (id)copyNSParagraphStylefromAttributes:(id)attributes toAttributes:(id)attributes;
- (id)defaultListAttributes;
- (id)defaultListAttributesWithContentSizeCategory:(id)category;
- (id)defaultParagraphStyleWithWritingDirection:(long long)direction;
- (unsigned long long)defaultTabIntervalInAttributedString:(id)string;
- (id)defaultTypingAttributesForEmptyDocument;
- (id)filterStyleAttributes:(id)attributes range:(struct _NSRange)range;
- (void)fixModelAttributesInTextStorage:(id)storage inRange:(struct _NSRange)range;
- (id)fixedWidthAttributes;
- (id)fixedWidthAttributesWithContentSizeCategory:(id)category;
- (void)guessFontSizeThresholdsForTTStylesInAttributedString:(id)string;
- (id)headingAttributes;
- (id)headingAttributesWithContentSizeCategory:(id)category;
- (id)indentsForIndividualParagraphHeadIndentsInAttributedString:(id)string;
- (id)modelForStyleAttributes:(id)attributes filterAttributes:(_Bool)attributes;
- (id)modelForStyleAttributes:(id)attributes filterAttributes:(_Bool)attributes pasteboardAttributedString:(id)string;
- (id)preferredAttributesForICTTTextStyle:(unsigned int)style;
- (void)prepareIndentInformationInAttributedString:(id)string;
- (id)referenceAttributesForLocation:(unsigned long long)location textStorage:(id)storage currentParagraphStart:(unsigned long long)start;
- (id)removeAttribute:(id)attribute ifInconsistentAtLocation:(unsigned long long)location inTextStorage:(id)storage forNewTypingAttributes:(id)attributes;
- (void)resetGuessedFontSizes;
- (void)resetIndentInformation;
- (id)strippedTypingAttributesAtStartOfParagraph:(id)paragraph atTheEndOfDocument:(_Bool)document isTyping:(_Bool)typing;
- (void)styleFontInAttributedString:(id)string inRange:(struct _NSRange)range contentSizeCategory:(id)category;
- (id)styleForModelAttributes:(id)attributes;
- (id)styleForModelAttributes:(id)attributes contentSizeCategory:(id)category;
- (void)styleListsAndIndentsInAttributedString:(id)string inRange:(struct _NSRange)range;
- (void)styleText:(id)text inExactRange:(struct _NSRange)range fixModelAttributes:(_Bool)attributes;
- (void)styleText:(id)text inRange:(struct _NSRange)range fixModelAttributes:(_Bool)attributes;
- (id)subheadingAttributes;
- (id)subheadingAttributesWithContentSizeCategory:(id)category;
- (id)titleAttributesWithContentSizeCategory:(id)category;
- (id)typingAttributesForRange:(struct _NSRange)range forSelectionChange:(_Bool)change currentTypingAttributes:(id)attributes inTextStorage:(id)storage;
- (id)typingAttributesForRange:(struct _NSRange)range forSelectionChange:(_Bool)change forSettingTextStyle:(_Bool)style currentTypingAttributes:(id)attributes inTextStorage:(id)storage;
- (id)typingAttributesForSettingTextStyleForRange:(struct _NSRange)range currentTypingAttributes:(id)attributes inTextStorage:(id)storage;
- (id)writingToolsIgnoredRangesForTextStorage:(id)storage inEnclosingRange:(struct _NSRange)range note:(id)note;

@end


@interface ICTextController : ICTTTextController

@property (nonatomic) unsigned long long pauseMergeForScrollingCounter;
@property (nonatomic) _Bool shouldMergeNoteAfterScrolling;
@property (nonatomic) _Bool isAutoListInsertionDisabled;
@property (retain, nonatomic) ICTTTextStorage *emptyTextStorage;
@property (weak, nonatomic) ICNote *note;
@property (weak, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;
@property (readonly, nonatomic) NSMutableDictionary *trackedToDoParagraphs;
@property (retain, nonatomic) NSDictionary *paragraphLinksToNote;
@property _Bool userChangedWritingDirection;
@property (nonatomic) _Bool disableAddingExtraLinesIfNeeded;
@property (retain, nonatomic) NSMutableArray *trackedRangesForAddedExtraNewlines;
@property (nonatomic) _Bool trackAddedExtraNewlineRanges;
@property (nonatomic) _Bool isConvertingTables;
@property (nonatomic) unsigned long long overrideAppearanceType;
@property (weak, nonatomic) ICAuthorHighlightsController *authorHighlightsController;
@property (weak, nonatomic) ICMentionsController *mentionsController;
@property (weak, nonatomic) ICHashtagController *hashtagController;

/* class methods */
+ (id)attributedStringToPasteWithAdaptedParagraphStyles:(id)styles pasteRange:(struct _NSRange)range textStorage:(id)storage;
+ (double)extraBulletWidthForNumberedListWithMaxItemNumber:(id)number textFont:(id)font;
+ (double)extraWidthNeededForStyle:(id)style range:(struct _NSRange)range attributedString:(id)string textView:(id)view;
+ (double)indentForStyle:(id)style range:(struct _NSRange)range attributedString:(id)string textView:(id)view;
+ (double)indentForStyle:(id)style range:(struct _NSRange)range attributedString:(id)string textView:(id)view todoZoomFactor:(double)factor;
+ (id)removeBeginningListStyleIfNecessaryForAttributedString:(id)string fromTextStorage:(id)storage andRange:(struct _NSRange)range;
+ (_Bool)shouldRetainFirstListStyleForFilteredAttributedSubstring:(id)substring fromRange:(struct _NSRange)range;

/* instance methods */
- (id)init;
- (_Bool)applyListStyle:(id)style paragraphStyle:(id)style pStart:(unsigned long long)start pEnd:(unsigned long long)end pContentEnd:(unsigned long long)end range:(struct _NSRange)range tv:(id)tv;
- (void)ensureUniqueParagraphStyleUUIDsInTextStorage:(id)storage range:(struct _NSRange)range editedRange:(struct _NSRange)range;
- (void)setSelectionToIndex:(unsigned long long)index onTextView:(id)view;
- (long long)setTextStyle:(unsigned int)style removeExtraStyling:(_Bool)styling range:(struct _NSRange)range inTextStorage:(id)storage inTextView:(id)view;
- (struct _NSRange)addExtraLinesIfNeededToTextStorage:(id)storage editedRange:(struct _NSRange)range actualLengthIncrease:(long long *)increase;
- (void)addNewlineIfParagraphStyleToTextStorage:(id)storage pStart:(unsigned long long)start pEnd:(unsigned long long)end pContentEnd:(unsigned long long)end;
- (id)addTableAttachmentWithNSTextTable:(id)table attributedString:(id)string filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (void)addToTagsInTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)applyDividerLine:(id)line paragraphStyle:(id)style pStart:(unsigned long long)start pEnd:(unsigned long long)end pContentEnd:(unsigned long long)end range:(struct _NSRange)range tv:(id)tv;
- (_Bool)attachmentsExistInRange:(struct _NSRange)range textStorage:(id)storage;
- (_Bool)canAddToTagsInTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)canChangeStyleForSelectedRanges:(id)ranges inTextStorage:(id)storage;
- (_Bool)canConvertInlineAttachmentToTextInTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)canIndentTextView:(id)view byDelta:(long long)delta;
- (_Bool)canIndentTextView:(id)view byDelta:(long long)delta forRanges:(id)ranges;
- (void)checkforSectionLinkTitleUpdatesinTextStorage:(id)storage atRange:(struct _NSRange)range;
- (struct _NSRange)cleanupTextStorage:(id)storage afterProcessingEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length changeInLengthAfterCleanup:(long long *)cleanup;
- (_Bool)containsOnlyStyle:(unsigned int)style inRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)convertInlineAttachmentToTextInTextView:(id)view forRange:(struct _NSRange)range;
- (void)convertNSTablesToICTables:(id)ictables pasteboardTypes:(id)types filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (void)createToDoItemForCharacterRange:(struct _NSRange)range paragraphStyle:(id)style textStorage:(id)storage;
- (_Bool)deleteBackwardForSpecialCasesInTextView:(id)view;
- (_Bool)deleteWordBackwardForSpecialCasesInTextView:(id)view;
- (_Bool)dividerLineExistInRange:(struct _NSRange)range textStorage:(id)storage;
- (struct _NSRange)expandRangeToIncludeFullList:(struct _NSRange)list inAttributedString:(id)string;
- (struct _NSRange)extendedSelectionRangeForCollapsedSectionHeadingWithRange:(struct _NSRange)range textView:(id)view;
- (void)filterAttachmentsForPrintingInAttributedString:(id)string textContainer:(id)container;
- (struct _NSRange)firstParagraphForSetListStyleRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)fixListWritingDirectionInAttributedString:(id)string forListItemsInRange:(struct _NSRange)range;
- (void)fixModelAttributesInTextStorage:(id)storage inRange:(struct _NSRange)range;
- (void)fixTextStorage:(id)storage afterProcessingEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (id)indentParagraphStyle:(id)style byAmount:(long long)amount;
- (void)indentRange:(struct _NSRange)range byAmount:(long long)amount inTextStorage:(id)storage textView:(id)view;
- (void)indentRange:(struct _NSRange)range byAmount:(long long)amount inTextStorage:(id)storage textView:(id)view forceUpdateAttributes:(_Bool)attributes;
- (_Bool)inlineAttachmentInTextView:(id)view atIndex:(unsigned long long)index outAttachment:(id *)attachment;
- (void)insertNewlineAtCharacterIndex:(unsigned long long)index textStorage:(id)storage;
- (_Bool)insertNewlineForSpecialCasesInTextView:(id)view;
- (_Bool)insertedSpaceInTextView:(id)view replacementRange:(struct _NSRange)range;
- (void)insertedText:(id)text replacementRange:(struct _NSRange)range inTextView:(id)view hashtagController:(id)controller mentionsController:(id)controller languageHasSpaces:(_Bool)spaces parentAttachment:(id)attachment;
- (void)insertedText:(id)text replacementRange:(struct _NSRange)range inTextView:(id)view languageHasSpaces:(_Bool)spaces;
- (_Bool)isForPrint;
- (_Bool)isTodoDoneRange:(struct _NSRange)range inTextStorage:(id)storage;
- (id)keyboardLanguageForTextView:(id)view;
- (void)notifyInlineAttachmentsDeletedInRange:(struct _NSRange)range ofTextStorage:(id)storage;
- (id)nsParagraphStyleForICTTParagraphStyle:(id)style range:(struct _NSRange)range attributedString:(id)string textView:(id)view;
- (struct _NSRange)numberListsInAttributedString:(id)string inRange:(struct _NSRange)range;
- (void)p_populateTable:(id)table withNSTextTable:(id)table attributedString:(id)string filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (struct { unsigned long long x0; unsigned long long x1; })p_setCellsInTable:(id)table fromAttributedString:(id)string textTable:(id)table atCellOffset:(struct { unsigned long long x0; unsigned long long x1; })offset filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (unsigned int)paragraphStyleForRange:(struct _NSRange)range inTextView:(id)view inTextStorage:(id)storage;
- (unsigned int)paragraphStyleForRange:(struct _NSRange)range inTextView:(id)view inTextStorage:(id)storage ignoreTypingAttributes:(_Bool)attributes;
- (void)refreshTextStylingForTextStorage:(id)storage withTextController:(id)controller;
- (void)refreshTypingAttributesForAllTextViewsOfTextStorage:(id)storage;
- (void)refreshTypingAttributesForTextView:(id)view textStorage:(id)storage;
- (_Bool)removeFontsAndColorsForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (_Bool)removeListStyleBeforeDeletingParagraphContentIfNecessaryForTextView:(id)view textStorage:(id)storage rangeToBeDeleted:(struct _NSRange)deleted blockBeforeEndEditing:(id /* block */)editing;
- (_Bool)removeListStyleForDeletingEmptyParagrahIfNecessaryForTextView:(id)view textStorage:(id)storage paragraphRange:(struct _NSRange)range andLocation:(unsigned long long)location;
- (void)resetTrackedToDoParagraphs;
- (id)scaleFont:(id)font withScale:(double)scale;
- (void)scaleFontPointSize:(double)size range:(struct _NSRange)range inTextStorage:(id)storage;
- (_Bool)selectionContainsBlockQuoteAndOthers:(id)others;
- (_Bool)setDone:(_Bool)done range:(struct _NSRange)range inTextStorage:(id)storage;
- (_Bool)setDone:(_Bool)done range:(struct _NSRange)range inTextStorage:(id)storage isInlineMarkdown:(_Bool)markdown;
- (void)setIsForPrint:(_Bool)print;
- (void)setNote:(id)note stylingTextUsingSeparateTextStorageForRendering:(_Bool)rendering withLayoutManager:(id)manager;
- (void)setNote:(id)note stylingTextUsingSeparateTextStorageForRendering:(_Bool)rendering withLayoutManager:(id)manager firstVisibleCharLocation:(unsigned long long)location;
- (void)setParagraphWritingDirectionInRange:(struct _NSRange)range toDirection:(long long)direction inTextView:(id)view;
- (void)setTextAlignment:(long long)alignment range:(struct _NSRange)range inTextStorage:(id)storage inTextView:(id)view;
- (long long)setTextStyle:(unsigned int)style range:(struct _NSRange)range inTextStorage:(id)storage;
- (long long)setTextStyle:(unsigned int)style range:(struct _NSRange)range inTextStorage:(id)storage inTextView:(id)view;
- (long long)setTextStyle:(unsigned int)style removeExtraStyling:(_Bool)styling range:(struct _NSRange)range inTextStorage:(id)storage;
- (void)setTypingAttributesForUndo:(id)undo;
- (void)setTypingTextStyle:(unsigned int)style textView:(id)view;
- (_Bool)shouldChangeTextInTextStorage:(id)storage range:(struct _NSRange)range replacementString:(id)string;
- (_Bool)shouldHighlightStyleAsLink:(unsigned int)link;
- (_Bool)shouldUpdateIndentFor:(id)_for;
- (id)strippedTypingAttributesAtStartOfParagraph:(id)paragraph atTheEndOfDocument:(_Bool)document isTyping:(_Bool)typing;
- (void)styleDataDetectorTypesForPreviewInTextStorage:(id)storage;
- (void)styleListsAndIndentsInAttributedString:(id)string inRange:(struct _NSRange)range;
- (void)superscriptDelta:(long long)delta range:(struct _NSRange)range inTextStorage:(id)storage;
- (void)superscriptUpdate:(id /* block */)update range:(struct _NSRange)range inTextStorage:(id)storage;
- (id)tabStopsForAttributedString:(id)string inRange:(struct _NSRange)range;
- (id)todoForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)toggleBlockQuoteInTextView:(id)view;
- (void)trackExtraNewLineRangeIfNecessary:(struct _NSRange)necessary;
- (void)uniqueParagraphStylesInTextStorage:(id)storage inRange:(struct _NSRange)range;
- (void)unscriptRange:(struct _NSRange)range inTextStorage:(id)storage;
- (void)updateAttachmentsInNote;
- (void)updateAttachmentsSelectionStateInTextStorage:(id)storage forSelectedRanges:(id)ranges layoutManager:(id)manager textView:(id)view;
- (void)updateCellInTable:(id)table atColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index fromAttributedString:(id)string andTextTableBlock:(id)block filterPastedAttributes:(_Bool)attributes isReadingSelectionFromPasteboard:(_Bool)pasteboard;
- (void)updateParagraphLinkCache;
- (void)updateParagraphWritingDirectionToKeyboardWritingDirectionInRange:(struct _NSRange)range textStorage:(id)storage textView:(id)view;
- (void)updateTrackedAttributesInTextStorage:(id)storage range:(struct _NSRange)range changeInLength:(long long)length;
- (void)updateTrackedToDoParagraphsAfterIndex:(unsigned long long)index byDelta:(long long)delta excludingSeenParagraphs:(id)paragraphs;
- (void)updateTrackingInTextStorage:(id)storage range:(struct _NSRange)range changeInLength:(long long)length;
- (void)workAroundSageTables:(id)tables;
- (long long)writingDirectionForRange:(struct _NSRange)range inTextStorage:(id)storage;
- (long long)writingDirectionForRange:(struct _NSRange)range inTextView:(id)view inTextStorage:(id)storage;

@end


@interface ICTK2TextController : ICTextController

/* instance methods */
- (void)setNote:(id)note firstVisibleLocation:(unsigned long long)location;
- (void)updateAttachmentsSelectionStateInTextStorage:(id)storage forSelectedRanges:(id)ranges textView:(id)view;
- (void)updateHighlightsInRange:(struct _NSRange)range inTextStorage:(id)storage;

@end


@interface ICTK2TodoTextAttachment : ICTextAttachment

@property (readonly, nonatomic) ICTTTodo *todo;

/* instance methods */
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)viewIdentifier;
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (id)initWithTodo:(id)todo;

@end


@interface ICTTTextContentStorage : NSTextContentStorage

@property (retain, nonatomic) ICOutlineController *outlineController;
@property (readonly, nonatomic) NSTextStorage *textStorage;
@property (readonly, nonatomic) ICTTTextStorage *icTextStorage;

/* instance methods */
- (void)addTextLayoutManager:(id)manager;
- (void)removeTextLayoutManager:(id)manager;
- (id)init;
- (void)dealloc;
- (void)setExpanded:(_Bool)expanded forSectionsInRange:(struct _NSRange)range;
- (_Bool)canCollapseSectionsInRange:(struct _NSRange)range;
- (_Bool)canExpandSectionsInRange:(struct _NSRange)range;
- (void)collapseAllSections;
- (void)expandAllSections;
- (id)initWithTextStorage:(id)storage outlineState:(id)state;
- (_Bool)isUUIDHidden:(id)uuidhidden;
- (struct _NSRange)rangeForParagraphID:(id)id;

@end


@interface ICTTTextStorage : NSTextStorage <ICTTMergeableStringDelegate, ICTTTextUndoTarget>

@property (nonatomic) unsigned long long attributeOptions;
@property (retain, nonatomic) NSMutableArray *undoCommands;
@property (retain, nonatomic) ICTTMergeableStringUndoGroup *coalescingUndoGroup;
@property (nonatomic) unsigned long long editingCount;
@property (nonatomic) _Bool isEditingTemporaryAttributes;
@property (nonatomic) _Bool isFixing;
@property (nonatomic) _Bool isApplyingUndoCommand;
@property (nonatomic) _Bool pendingFixupAfterEditing;
@property (nonatomic) struct _NSRange beforeEndEditedRange;
@property (nonatomic) struct _NSRange ttEditedRange;
@property (nonatomic) unsigned long long ttEditedMask;
@property (nonatomic) long long ttChangeInLength;
@property (nonatomic) _Bool delayedFixupAfterEditingWantsUndoCommand;
@property (retain, nonatomic) NSMutableSet *textLayoutManagerReferences;
@property (nonatomic) long long skipTimestampUpdatesCount;
@property (copy, nonatomic) NSDate *now;
@property (nonatomic) _Bool directlyEditing;
@property (nonatomic) _Bool previouslyHadMarkedText;
@property (nonatomic) _Bool hasUserEditSinceFixupAfterEditing;
@property (retain, nonatomic) NSMutableAttributedString *attributedString;
@property (readonly, nonatomic) NSObject<ICTTTextUndoTarget> *undoTarget;
@property (nonatomic) struct _NSRange lastUndoEditRange;
@property (copy, nonatomic) NSNumber *currentTimestamp;
@property (readonly, nonatomic) _Bool forTextKit2;
@property (weak) id <ICTTTextStorageDelegate> delegate;
@property (weak, nonatomic) ICOutlineController *outlineController;
@property (retain, nonatomic) NSUndoManager *undoManager;
@property (weak) NSObject<ICTTTextUndoTarget> *overrideUndoTarget;
@property (nonatomic) _Bool wantsUndoCommands;
@property (nonatomic) _Bool shouldInhibitAddingExtraNewlinesAtEndDuringFixup;
@property (nonatomic) _Bool alwaysEnumerateTrailingParagraph;
@property (readonly, copy, nonatomic) NSSet *textLayoutManagers;
@property (readonly, copy, nonatomic) NSSet *textViews;
@property (readonly, nonatomic) NSAttributedString *highlightsAttributedString;
@property (readonly, nonatomic) _Bool hasAnyTextViewWithDarkAppearance;
@property (retain, nonatomic) id <ICTTTextStorageStyler> styler;
@property (readonly, nonatomic) NSMutableArray *deletedRanges;
@property (readonly, copy, nonatomic) NSUUID *replicaID;
@property (readonly, nonatomic) ICTTMergeableAttributedString *mergeableString;
@property (readonly, nonatomic) ICTTMergeableStringVersionedDocument *document;
@property (nonatomic) _Bool convertAttributes;
@property (nonatomic) _Bool parsePresentationIntents;
@property (nonatomic) _Bool shouldConvertTablesToTabs;
@property (copy, nonatomic) NSArray *pasteboardTypes;
@property (nonatomic) _Bool retainOriginalFormatting;
@property (nonatomic) _Bool filterSubstringAttributes;
@property (nonatomic) _Bool filterPastedAttributes;
@property (nonatomic) _Bool filterSubstringAttributesForPlainText;
@property (nonatomic) _Bool disableUndoCoalesceBreaking;
@property (nonatomic) _Bool isPausingUndoActions;
@property (nonatomic) _Bool isPerformingAccessibilityUndoableTextInsertion;
@property (nonatomic) _Bool isHandlingTextCheckingResults;
@property (nonatomic) _Bool isTypingOrMarkingText;
@property (nonatomic) _Bool isSelectingText;
@property (nonatomic) _Bool hasEditedCharactersAfterTextSelection;
@property (nonatomic) _Bool isDragging;
@property (nonatomic) _Bool isDropping;
@property (nonatomic) _Bool isResettingBaseWritingDirection;
@property (nonatomic) _Bool isReadingSelectionFromPasteboard;
@property (nonatomic) _Bool isEditingViaWritingTools;
@property (nonatomic) _Bool isUndoCoalescingForWritingTools;
@property (nonatomic) _Bool isEditingPlaceholderForWritingTools;
@property (retain, nonatomic) NSUUID *writingToolsSessionUUID;
@property (nonatomic) _Bool isMarkingTextForHeadingRename;
@property (nonatomic) _Bool mustZoomTextBeforeReplacingCharactersInRange;
@property (nonatomic) _Bool isChangingNoteContentFontByFontPanel;
@property (nonatomic) _Bool isChangingTypingAttributeFontByFontPanel;
@property (nonatomic) _Bool isPastingStyle;
@property (nonatomic) _Bool isDroppingChecklistItem;
@property (nonatomic) _Bool isDroppingChecklistItemInsideChecklist;
@property (nonatomic) _Bool isDroppingLastChecklistItem;
@property (nonatomic) _Bool isDeletingBackwards;
@property (nonatomic) _Bool isEndingEditing;
@property (nonatomic) _Bool isZombie;
@property (readonly, nonatomic) _Bool wantsTimestampUpdates;
@property (readonly, nonatomic) _Bool isSkippingTimestampUpdates;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)bulletTextAttributesWithTextFont:(id)font paragraphStyle:(id)style zoomFactor:(double)factor;
+ (id)filteredAttributedSubstring:(id)substring fromRange:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text fixAttachments:(_Bool)attachments insertListMarkers:(_Bool)markers;
+ (id)filteredAttributedSubstring:(id)substring fromRange:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text fixAttachments:(_Bool)attachments insertListMarkers:(_Bool)markers context:(id)context;
+ (void)fixAttachmentsForRenderingInAttributedString:(id)string forPlainText:(_Bool)text forStandardizedText:(_Bool)text;
+ (double)listItemGlyphPointSizeForUnorderedListStyle:(unsigned int)style zoomFactor:(double)factor;
+ (id)removeDataDetectorLinksForAttributedString:(id)string;
+ (id)removeTextAttachmentsForAttributedString:(id)string translateICTTFont:(_Bool)icttfont;
+ (id)standardizedAttributedStringFromAttributedString:(id)string withStyler:(id)styler fixAttachments:(_Bool)attachments translateICTTFont:(_Bool)icttfont context:(id)context;

/* instance methods */
- (_Bool)isEditing;
- (void)setAttributes:(id)attributes range:(struct _NSRange)range;
- (id)attributesAtIndex:(unsigned long long)index longestEffectiveRange:(struct _NSRange *)range inRange:(struct _NSRange)range;
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (id)attribute:(id)attribute atIndex:(unsigned long long)index longestEffectiveRange:(struct _NSRange *)range inRange:(struct _NSRange)range;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (void)addTextLayoutManager:(id)manager;
- (unsigned long long)length;
- (void)removeTextLayoutManager:(id)manager;
- (void)replaceCharactersInRange:(struct _NSRange)range withAttributedString:(id)string;
- (id)initWithDocument:(id)document;
- (id)attributesAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)attribute:(id)attribute atIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)string;
- (void)endEditing;
- (id)attributedSubstringFromRange:(struct _NSRange)range;
- (void)beginEditing;
- (id)dataFromRange:(struct _NSRange)range documentAttributes:(id)attributes error:(id *)error;
- (void)breakUndoCoalescing;
- (void)restoreSelection:(id)selection;
- (void)addUndoCommand:(id)command;
- (unsigned long long)mergeWithDocument:(id)document;
- (id)editAtIndex:(unsigned long long)index;
- (void)enumerateEditsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (id)initWithData:(id)data replicaID:(id)id;
- (void)redactAuthorAttributionsToCurrentUser;
- (void)replaceWithDocument:(id)document;
- (void)setTimestamp:(id)timestamp range:(struct _NSRange)range;
- (id)_icaxUnfilteredAttributedString;
- (void)executeDelayedFixupAfterEditing;
- (void)forceFixupAfterEditingIfDelayed;
- (void)resetHighlightsAttributedString;
- (void)applyUndoGroup:(id)group;
- (void)applyUndoWithBlock:(id /* block */)block;
- (void)beginSkippingTimestampUpdates;
- (void)beginTemporaryAttributeEditing;
- (void)beginTemporaryAttributes;
- (void)convertNSTablesToTabs:(id)tabs;
- (id)copyDataForUTI:(id)uti range:(struct _NSRange)range persistenceHelper:(id)helper;
- (id)copyDataForUTI:(id)uti range:(struct _NSRange)range persistenceHelper:(id)helper isMarkdownCopy:(_Bool)copy;
- (id)customPasteboardDataFromRange:(struct _NSRange)range persistenceHelper:(id)helper;
- (void)editWithAttributeOptions:(unsigned long long)options usingBlock:(id /* block */)block;
- (void)editedAttributeRange:(struct _NSRange)range;
- (void)editedRange:(struct _NSRange)range changeInLength:(long long)length;
- (void)endSkippingTimestampUpdates;
- (void)endTemporaryAttributeEditing;
- (void)endTemporaryAttributes;
- (id)filteredAttributedStringForUTI:(id)uti range:(struct _NSRange)range;
- (id)filteredAttributedSubstringFromRange:(struct _NSRange)range;
- (id)filteredAttributedSubstringFromRange:(struct _NSRange)range insertListMarkers:(_Bool)markers;
- (void)fixupAfterEditing;
- (void)fixupAfterEditingDelayedToEndOfRunLoop;
- (id)formattedStringFromPastingMarkdown:(id)markdown range:(struct _NSRange)range;
- (_Bool)hasNamedStyle:(unsigned int)style inRange:(struct _NSRange)range;
- (id)initWithAttributedString:(id)string replicaID:(id)id;
- (id)initWithAttributedString:(id)string replicaID:(id)id sourceZoomController:(id)controller keepSourceZoomController:(_Bool)controller existingStyler:(id)styler;
- (_Bool)isDeletingContentAttachmentWithReplacementRange:(struct _NSRange)range replacementLength:(unsigned long long)length;
- (_Bool)isDeletingDictationAttachmentWithReplacementRange:(struct _NSRange)range replacementLength:(unsigned long long)length;
- (_Bool)isEditingOrConvertingMarkedText:(_Bool)text;
- (_Bool)isForTextKit2;
- (_Bool)isRightToLeftAtIndex:(long long)index;
- (_Bool)isStringMarkdown:(id)markdown;
- (struct _NSRange)logicalRangeForLocation:(unsigned long long)location;
- (id)markdownDataFromRange:(struct _NSRange)range documentAttributes:(id)attributes error:(id *)error;
- (id)markdownPasteboardDataFromRange:(struct _NSRange)range persistenceHelper:(id)helper;
- (_Bool)mergeableStringIsEqualAfterSerialization:(id)serialization;
- (id)newCoalescingUndoGroup;
- (id)plainTextParagraphsFromRange:(struct _NSRange)range;
- (void)preReplaceCharactersInRange:(struct _NSRange)range withStringLength:(unsigned long long)length;
- (void)refreshAllAttributes;
- (void)resetTTEdits;
- (void)resetUndoManager;
- (void)restoreAttributedString:(id)string;
- (struct _NSRange)safeCharacterRangeForRange:(struct _NSRange)range;
- (void)saveSelectionDuringBlock:(id /* block */)block;
- (void)saveSelectionDuringBlock:(id /* block */)block affinity:(unsigned long long)affinity;
- (id)savedSelectionWithSelectionAffinity:(unsigned long long)affinity;
- (_Bool)shouldBreakUndoCoalescingWithReplacementRange:(struct _NSRange)range replacementLength:(unsigned long long)length;
- (_Bool)shouldUseMarkdownFromPasteboard:(id)pasteboard;
- (id)standardizedAttributedStringFixingTextAttachmentsForRange:(struct _NSRange)range context:(id)context;
- (id)standardizedAttributedStringFixingTextAttachmentsForRange:(struct _NSRange)range styler:(id)styler context:(id)context;
- (id)standardizedAttributedStringFixingTextAttachmentsInContext:(id)context;
- (void)styleTextInRange:(struct _NSRange)range;
- (_Bool)textViewHasMarkedText:(id)text;
- (_Bool)validateIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;

@end


@interface ICTTUndoManager_135534566 : NSUndoManager

@property (weak, nonatomic) ICTTTextStorage *textStorage;

/* instance methods */
- (void)undo;
- (void)redo;
- (id)initWithTextStorage:(id)storage;
- (_Bool)_shouldIgnoreUndoRedoBecauseWritingToolsIsActiveWithOpenGroup;

@end


@interface ICTableAttachmentSelection : NSObject

@property (nonatomic) unsigned long long type;
@property (copy, nonatomic) NSArray *columns;
@property (copy, nonatomic) NSArray *rows;
@property (readonly, nonatomic) _Bool isRangeOrSpanningSelection;
@property (nonatomic) _Bool moving;
@property (nonatomic) _Bool draggingText;
@property (readonly, nonatomic) _Bool valid;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)selectRows:(id)rows;
- (void)unselect;
- (_Bool)removeColumns:(id)columns rows:(id)rows;
- (_Bool)removeColumns:(id)columns rows:(id)rows previousColumns:(id)columns previousRows:(id)rows;
- (void)selectCellAtColumn:(id)column row:(id)row;
- (void)selectCellRangeAtColumns:(id)columns rows:(id)rows;
- (void)selectColumns:(id)columns;
- (void)setSelectionEqualTo:(id)to;

@end


@interface ICTableCellEditingUndoGroup : ICTTMergeableStringUndoGroup

@property (readonly, nonatomic) NSUUID *columnID;
@property (readonly, nonatomic) NSUUID *rowID;
@property (readonly, nonatomic) ICTableAttachmentSelection *tableSelection;
@property (readonly, nonatomic) ICTableUndoTarget *undoTarget;

/* instance methods */
- (id)init;
- (id)initWithColumn:(id)column row:(id)row selection:(id)selection undoTarget:(id)target;

@end


@interface ICTableCellMergeableStringDelegate : NSObject <ICTTMergeableStringDelegate>

@property (readonly, weak, nonatomic) id <ICTableCellMergeableStringObserving> changeObserver;
@property (readonly, nonatomic) NSUUID *columnID;
@property (readonly, nonatomic) NSUUID *rowID;
@property (nonatomic) unsigned long long editingCount;
@property (retain, nonatomic) NSMutableArray *undoCommands;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (id)init;
- (void)endEditing;
- (void)beginEditing;
- (void)addUndoCommand:(id)command;
- (_Bool)wantsUndoCommands;
- (id)initWithTableCellChangeObserver:(id)observer columnID:(id)id rowID:(id)id;

@end


@interface ICTableTextStorage : ICTTTextStorage

/* instance methods */
- (void)replaceCharactersInRange:(struct _NSRange)range withAttributedString:(id)string;
- (id)initWithDocument:(id)document;
- (void)textStorage:(id)storage didProcessEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;

@end


@interface ICTableCellTextStorage : ICTableTextStorage

/* instance methods */
- (id)initWithDocument:(id)document;

@end


@interface ICTableColumnTextStorage : ICTableTextStorage <ICTableCellMergeableStringObserving>

@property (readonly, weak, nonatomic) ICTable *table;
@property (readonly, nonatomic) NSMutableArray *rows;
@property (readonly, nonatomic) NSMutableDictionary *mergeableStringDelegates;
@property (readonly, nonatomic) NSMutableIndexSet *rowStartIndexes;
@property (nonatomic) unsigned long long preventEditingUpdatesCount;
@property (readonly) NSUUID *columnID;
@property (weak, nonatomic) id <ICTableUndoHelping> undoHelper;
@property (readonly, nonatomic) NSArray *populatedRows;
@property (nonatomic) _Bool shouldPreventUndoCommands;
@property (readonly, nonatomic) _Bool preventEditingUpdates;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (id)init;
- (void)breakUndoCoalescing;
- (unsigned long long)indexOfRow:(id)row;
- (void)removeRow:(id)row;
- (void)textStorage:(id)storage didProcessEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (void)restoreSelection:(id)selection;
- (_Bool)wantsUndoCommands;
- (id)editAtIndex:(unsigned long long)index;
- (void)enumerateEditsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)closeUndoGroups;
- (void)tableCellWasEditedAtColumnID:(id)id rowID:(id)id edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (void)beginPreventEditingUpdates;
- (struct _NSRange)characterRangeForRowID:(id)id;
- (void)endPreventEditingUpdates;
- (unsigned long long)indexOfRowAtLocation:(unsigned long long)location;
- (id)initWithTable:(id)table columnID:(id)id replicaID:(id)id;
- (unsigned long long)insertionIndexForRow:(id)row;
- (struct _NSRange)logicalRangeForLocation:(unsigned long long)location;
- (id)mergeableStringForRowID:(id)id;
- (unsigned long long)nextLocationAfterRowLocation:(unsigned long long)location;
- (void)removeTextForRow:(id)row;
- (void)resetUndoManager;
- (id)rowAtIndex:(unsigned long long)index rowRange:(out struct _NSRange *)range;
- (unsigned long long)rowLocationForRowID:(id)id;
- (unsigned long long)rowLocationForRowIndex:(unsigned long long)index;
- (id)savedSelectionWithSelectionAffinity:(unsigned long long)affinity;
- (void)updateStorageForMovedRow:(id)row;
- (_Bool)wantsTimestampUpdates;

@end


@interface ICTableColumnWidthManager : NSObject

@property (readonly, nonatomic) NSMutableDictionary *cachedIdealColumnWidths;
@property (readonly, nonatomic) NSMutableDictionary *cachedActualColumnWidths;
@property (readonly, nonatomic) NSMutableDictionary *cachedMinimumColumnWidths;
@property (readonly, weak, nonatomic) ICTable *table;
@property (readonly, weak, nonatomic) NSObject<ICAvailableTableWidthProviding> *delegate;
@property (readonly, nonatomic) ICTextController *styler;
@property (readonly, nonatomic) double singleColumnTableWidth;

/* instance methods */
- (double)widthOfColumn:(id)column;
- (double)calculateIdealWidthOfColumn:(id)column;
- (double)comfortableColumnWidth;
- (double)comfortableNumberOfColumnsOnscreen;
- (id)initWithTable:(id)table delegate:(id)delegate;
- (id)invalidateAvailableWidth;
- (id)invalidateWidthForColumns:(id)columns;
- (id)recalculateActualWidths;

@end


@interface ICTableTextAttachment : ICTextAttachment

@property (nonatomic) double lastAvailableWidth;
@property (nonatomic) struct CGSize lastAttachmentSize;

/* instance methods */
- (struct { double x0; double x1; double x2; double x3; })attachmentBoundsMargins;
- (_Bool)canDragWithoutSelecting;
- (void)fixAttachmentForAttributedString:(id)string range:(struct _NSRange)range forPlainText:(_Bool)text forStandardizedText:(_Bool)text;

@end


@interface ICTableTextController : ICTextController

/* instance methods */
- (id)init;
- (id)defaultTypingAttributesForEmptyDocument;
- (void)styleText:(id)text inRange:(struct _NSRange)range fixModelAttributes:(_Bool)attributes;

@end


@interface ICTagAllTagsItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)displayText;
+ (id)archiveIdentifier;
+ (id)sharedItemIdentifier;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICTagContainerItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedItemIdentifier;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICTagCoreDataIndexer : ICCoreDataIndexer

@property (retain, nonatomic) NSObject *accessQueue;
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) NSArray *hashtags;
@property (retain, nonatomic) NSArray *objectIDs;
@property (retain, nonatomic) NSArray *leadingVisibleObjectIDs;
@property (retain, nonatomic) id <ICSectionIdentifier> sectionIdentifier;
@property (nonatomic) _Bool includesAllTagsItem;
@property (nonatomic) _Bool includesNewTagItem;
@property (nonatomic) unsigned long long visibleTagLimit;
@property (readonly, nonatomic) unsigned long long hiddenTagCount;

/* class methods */
+ (_Bool)isTagItemIdentifier:(id)identifier;

/* instance methods */
- (id)activeFetchedResultsControllers;
- (id)indexObjectsInSection:(id)section sectionIndex:(unsigned long long)index fetchedResultsController:(id)controller;
- (id)initWithModernManagedObjectContext:(id)context sectionIdentifier:(id)identifier;
- (id)newSnapshotFromIndexWithLegacyManagedObjectContext:(id)context modernManagedObjectContext:(id)context;
- (id)nextRelevantItemIdentifierAfter:(id)after;
- (id)sectionIdentifierForHeaderInSection:(long long)section;
- (id)sectionIdentifiersForSectionType:(unsigned long long)type;
- (void)willIndex;

@end


@interface ICTagDetailItemIdentifier : NSObject

/* class methods */
+ (id)sharedItemIdentifier;

@end


@interface ICTagNewTagItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedItemIdentifier;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICTagOperatorItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedItemIdentifier;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICTextAttachmentCell : NSTextAttachmentCell <NSTextAttachmentCell>

@property NSTextAttachment *attachment;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (struct CGRect)cellFrameForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (_Bool)wantsToTrackMouse;

@end


@interface ICTextContainer : NSTextContainer

@property (nonatomic) _Bool inPreviewMode;

/* instance methods */
- (struct CGRect)lineFragmentRectForProposedRect:(struct CGRect)rect atIndex:(unsigned long long)index writingDirection:(long long)direction remainingRect:(struct CGRect *)rect;

@end


@interface ICTextStyle : NSObject

@property (retain) NSDictionary *attributes;
@property (retain) NSString *name;
@property unsigned int ttStyle;
@property (readonly, copy, nonatomic) NSAttributedString *attributedName;
@property (readonly, copy, nonatomic) NSString *styleID;
@property (readonly) _Bool isTextList;

/* class methods */
+ (id)titleStyle;
+ (id)dashStyle;
+ (id)fixedWidthStyle;
+ (id)subheadingStyle;
+ (_Bool)autoListInsertionEnabled;
+ (id)bodyStyle;
+ (id)bulletStyle;
+ (id)defaultTextStyles;
+ (id)headingStyle;
+ (id)icaxStyleDescriptionForBIUSStyle:(unsigned long long)biusstyle;
+ (id)icaxStyleDescriptionForNamedStyle:(unsigned int)style;
+ (unsigned int)namedStyleFromStyleID:(id)id;
+ (unsigned int)noteDefaultNamedStyle;
+ (id)numberedStyle;
+ (void)setAutoListInsertionEnabled:(_Bool)enabled;
+ (void)setNoteDefaultNamedStyle:(unsigned int)style;
+ (id)settingsDescriptionForNamedStyle:(unsigned int)style;
+ (id)styleForNamedStyle:(unsigned int)style;
+ (id)titleForNamedStyle:(unsigned int)style;
+ (unsigned int)validatedNamedStyle:(unsigned int)style;

/* instance methods */
- (id)icaxStyleDescription;

@end


@interface ICThumbnailCache : NSObject <ICThumbnailCaching>

/* class methods */
+ (id)shared;

/* instance methods */
- (id)objectForKeyedSubscript:(id)subscript;
- (id)init;
- (void)setObject:(id)object forKeyedSubscript:(id)subscript;
- (void)invalidateForObjectIdentifiers:(id)identifiers;
- (id)creationDateFor:(id)_for;

@end


@interface ICThumbnailConfiguration : NSObject

@property (copy, nonatomic) id associatedObject;
@property (readonly, copy, nonatomic) NSString *associatedObjectIdentifier;
@property (copy, nonatomic) NSString *associatedObjectTitle;
@property (readonly, nonatomic) long long thumbnailType;
@property (readonly, copy) ICThumbnailKey *uniqueKey;
@property (readonly, nonatomic) long long cacheLevel;
@property (readonly, nonatomic) struct CGSize preferredSize;
@property (readonly, nonatomic) double scale;
@property (readonly, nonatomic) ICAppearanceInfo *appearanceInfo;
@property (readonly, copy, nonatomic) NSColor *backgroundColor;
@property (readonly, nonatomic) _Bool hasBorder;
@property (copy, nonatomic) id /* block */ fallbackBlock;
@property (readonly, nonatomic) _Bool prepareThumbnail;

/* instance methods */
- (id)debugDescription;
- (id)initForAttachment:(id)attachment preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info;
- (id)initForAvatarWithParticipants:(id)participants preferredSize:(struct CGSize)size hasBorder:(_Bool)border;
- (id)initForNoteGalleryWithNote:(id)note preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info;
- (id)initForNoteListWithFoundAttachment:(id)attachment preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info;
- (id)initForNoteListWithNote:(id)note preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info;
- (id)initForSharePreviewThumbnailWithNote:(id)note appearanceInfo:(id)info;
- (id)initForShareThumbnailWithNote:(id)note appearanceInfo:(id)info;
- (id)initForShortcutsWithNote:(id)note preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info;
- (id)initForSystemPaperPreviewWithNote:(id)note appearanceInfo:(id)info;
- (id)initWithThumbnailType:(long long)type associatedObject:(id)object associatedObjectIdentifier:(id)identifier associatedObjectTitle:(id)title accountIdentifier:(id)identifier cacheLevel:(long long)level preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info backgroundColor:(id)color hasBorder:(_Bool)border;
- (id)initWithThumbnailType:(long long)type uniqueKey:(id)key associatedObject:(id)object associatedObjectIdentifier:(id)identifier associatedObjectTitle:(id)title accountIdentifier:(id)identifier cacheLevel:(long long)level preferredSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info backgroundColor:(id)color hasBorder:(_Bool)border;
- (void)performAsCurrentAppearance:(id /* block */)appearance;

@end


@interface ICThumbnailDescription : NSObject

@property (readonly, nonatomic) ICThumbnailConfiguration *configuration;
@property (copy, nonatomic) NSDate *creationDate;
@property (nonatomic) _Bool cached;
@property (nonatomic) double fetchDuration;
@property (retain, nonatomic) NSError *error;
@property (retain, nonatomic) NSImage *image;
@property (nonatomic) unsigned long long imageScaling;
@property (readonly, nonatomic) long long preferredLayerContentsPlacement;
@property (nonatomic) long long thumbnailDecorationType;
@property (retain, nonatomic) NSSet *associatedObjectIdentifiers;

/* instance methods */
- (_Bool)isCached;
- (id)initWithConfiguration:(id)configuration;

@end


@interface ICThumbnailGenerator : NSObject

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

/* instance methods */
- (id)initWithManagedObjectContext:(id)context;
- (void)generateThumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;

@end


@interface ICThumbnailGeneratorAttachment : ICThumbnailGenerator

/* instance methods */
- (void)generateThumbnailForMediaURL:(id)url configuration:(id)configuration completion:(id /* block */)completion;
- (void)generateThumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;

@end


@interface ICThumbnailGeneratorAvatar : ICThumbnailGenerator

@property (readonly, nonatomic) CNAvatarImageRenderer *renderer;
@property (readonly, nonatomic) _Bool RTL;

/* instance methods */
- (_Bool)isRTL;
- (id)initWithManagedObjectContext:(id)context;
- (void)drawWithBorderIntoContext:(struct CGContext *)context avatarImage:(id)image;
- (void)generateThumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;

@end


@interface ICThumbnailGeneratorNote : ICThumbnailGenerator

@property (readonly, nonatomic) NSObject *completionQueue;
@property (nonatomic) double maximumWidth;
@property (nonatomic) double margin;

/* instance methods */
- (id)initWithManagedObjectContext:(id)context;
- (id)generateThumbnailImageWithNote:(id)note configuration:(id)configuration;
- (void)generateThumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;
- (_Bool)isInsideSystemPaperWithConfiguration:(id)configuration;

@end


@interface ICThumbnailGeneratorNoteAttachments : ICThumbnailGenerator

/* instance methods */
- (void)generateThumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;
- (void)postProcessThumbnail:(id)thumbnail configuration:(id)configuration;

@end


@interface ICThumbnailKey : NSObject <NSCopying> // (Swift)

@property (nonatomic, readonly) NSString *accountId;
@property (nonatomic, readonly) NSString *objectId;
@property (nonatomic, readonly) NSString *thumbnailId;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) long long hash;
@property (nonatomic, readonly) NSURL *containerUrl;
@property (nonatomic, readonly) NSURL *descriptionUrl;
@property (nonatomic, readonly) NSURL *imageUrl;

/* class methods */
+ (id)recentObjectId;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)copyWithZone:(void *)zone;
- (id)initWithType:(long long)type accountId:(id)id objectId:(id)id preferredSize:(struct CGSize)size scale:(double)scale appearance:(unsigned long long)appearance;
- (id)initWithAccountId:(id)id objectId:(id)id;
- (id)initWithAccountId:(id)id objectId:(id)id thumbnailId:(id)id;
- (id)initWithType:(long long)type accountId:(id)id objectId:(id)id preferredSize:(struct CGSize)size scale:(double)scale appearance:(unsigned long long)appearance isRTL:(_Bool)rtl contentSizeCategory:(id)category hasBoldText:(_Bool)text hasButtonShapes:(_Bool)shapes hasDarkerSystemColors:(_Bool)colors hasBorder:(_Bool)border;

@end


@interface ICThumbnailService : NSObject <ICManagedObjectContextChangeControllerDelegate>

@property (retain, nonatomic) ICManagedObjectContextChangeController *managedObjectChangeController;
@property (retain, nonatomic) NSMutableDictionary *callbacks;
@property (retain, nonatomic) NSObject *schedulingSerialQueue;
@property (retain, nonatomic) NSObject *backgroundQueue;
@property (retain, nonatomic) NSOperationQueue *thumbnailGenerationQueue;
@property (readonly, nonatomic) NSManagedObjectContext *workerContext;
@property (readonly, nonatomic) NSManagedObjectContext *viewContext;
@property (readonly, nonatomic) id <ICThumbnailCaching> cache;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedThumbnailService;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)attachmentPreviewImagesDidUpdate:(id)update;
- (id)initWithViewContext:(id)context workerContext:(id)context;
- (id)managedObjectContextChangeController:(id)controller managedObjectIDsToUpdateForUpdatedManagedObjects:(id)objects;
- (void)managedObjectContextChangeController:(id)controller performUpdatesForManagedObjectIDs:(id)ids;
- (_Bool)managedObjectContextChangeControllerShouldUpdateImmediately:(id)immediately;
- (void)processThumbnailDescriptionResult:(id)result;
- (id)thumbnailGeneratorForConfiguration:(id)configuration;
- (id)thumbnailWithConfiguration:(id)configuration;
- (void)thumbnailWithConfiguration:(id)configuration completion:(id /* block */)completion;
- (void)thumbnailsWithConfigurations:(id)configurations completion:(id /* block */)completion;

@end


@interface ICTintedLayer : CALayer

@property (retain, nonatomic) id originalContents;
@property (retain, nonatomic) NSColor *tintColor;

/* instance methods */
- (void)setContents:(id)contents;
- (void)updateContents;

@end


@interface ICTodoButton : NSButton

@property (nonatomic) struct CGSize defaultImageSize;
@property (nonatomic) _Bool trackedParagraphIsRTL;
@property (nonatomic) _Bool useConstraintBasedRendering;
@property (retain, nonatomic) NSImage *doneImage;
@property (retain, nonatomic) NSImage *undoneImage;
@property (retain) NSImageView *undoneImageView;
@property (retain) NSImageView *doneImageView;
@property (retain) NSTrackingArea *cursorTrackingArea;
@property (retain, nonatomic) NSLayoutConstraint *doneEdgeConstraint;
@property (retain, nonatomic) NSLayoutConstraint *undoneEdgeConstraint;
@property (retain, nonatomic) NSLayoutConstraint *doneWidthConstraint;
@property (retain, nonatomic) NSLayoutConstraint *doneHeightConstraint;
@property (retain, nonatomic) NSLayoutConstraint *undoneWidthConstraint;
@property (retain, nonatomic) NSLayoutConstraint *undoneHeightConstraint;
@property (nonatomic) _Bool done;
@property (weak, nonatomic) ICTrackedParagraph *trackedParagraph;
@property (weak, nonatomic) ICNote *note;
@property (copy, nonatomic) NSColor *highlightColor;
@property (copy, nonatomic) NSColor *overrideTintColor;
@property (nonatomic) double zoomFactor;
@property (weak, nonatomic) id <ICTodoButtonDragDelegate> dragDelegate;

/* class methods */
+ (struct CGSize)defaultSize;
+ (struct CGSize)defaultImageSize;

/* instance methods */
- (void)commonInit;
- (id)debugDescription;
- (void)mouseDown:(id)down;
- (id)init;
- (_Bool)isDone;
- (void)dealloc;
- (_Bool)allowsVibrancy;
- (id)initWithFrame:(struct CGRect)frame;
- (void)cursorUpdate:(id)update;
- (id)hitTest:(struct CGPoint)test;
- (struct CGRect)imageFrame;
- (void)updateTintColor;
- (id)initWithZoomFactor:(double)factor;
- (void)accentColorDidChange;
- (id)initWithFrame:(struct CGRect)frame zoomFactor:(double)factor;
- (void)setDone:(_Bool)done animated:(_Bool)animated;
- (void)setFrame:(struct CGRect)frame leftToRight:(_Bool)right;
- (struct CGSize)sizeForImage;
- (void)trackedParagraphDidChange;
- (void)updateEdgeConstraints;
- (void)updateImagesAnimated:(_Bool)animated;
- (void)updateSizeConstraints;
- (void)wasPressed;
- (void)zoomFactorDidChange;

@end


@interface ICTodoButtonNonVibrantImageView : NSImageView

/* instance methods */
- (_Bool)allowsVibrancy;

@end


@interface ICTrackedParagraph : NSObject

@property (retain, nonatomic) ICTTParagraphStyle *paragraph;
@property (nonatomic) struct _NSRange characterRange;

/* instance methods */
- (id)description;

@end


@interface ICUnifiedNoteContext : NSObject

@property (readonly, nonatomic) ICNoteContext *modernNoteContext;
@property (readonly, nonatomic) NSManagedObjectContext *htmlNoteContext;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *modernStoreCoordinator;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *htmlStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *modernManagedObjectContext;
@property (nonatomic, readonly) ICNotesCrossProcessChangeCoordinator *modernCrossProcessChangeCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *htmlManagedObjectContext;
@property (nonatomic, readonly) _Bool resolvedPrefersViewContext;
@property (nonatomic, readonly) NSManagedObjectID *defaultAccountObjectID;
@property (nonatomic, readonly) id <ICLegacyAccount> legacyAccountForLocalAccount;
@property (readonly, nonatomic) unsigned long long options;

/* instance methods */
- (id)managedObjectIDForURIRepresentation:(id)urirepresentation;
- (id)legacyAttachmentWithIdentifier:(id)identifier;
- (id)initWithModernNoteContext:(id)context htmlNoteContext:(id)context;
- (id)initWithModernNoteContext:(id)context htmlNoteContext:(id)context options:(unsigned long long)options;
- (id)legacyAccountForEmailAddress:(id)address;
- (id)legacyFolderWithIdentifier:(id)identifier;
- (id)legacyNoteWithIdentifier:(id)identifier;
- (id)managedObjectContextForObject:(id)object error:(id *)error;
- (id)managedObjectContextForObjectID:(id)id;
- (id)managedObjectIDForURIString:(id)uristring;

@end


@interface ICUnsupportedTextAttachmentWithFallbackImage : ICImageTextAttachment

/* instance methods */
- (id)fileType;
- (id)attachmentAsNSTextAttachment;
- (_Bool)supportsMultipleThumbnailsOnSameLine;

@end


@interface ICUnsupportedTextAttachmentWithFallbackPDF : ICPDFTextAttachment

/* instance methods */
- (id)attachmentAsNSTextAttachment;
- (_Bool)supportsMultipleThumbnailsOnSameLine;

@end


@interface ICViewTrackingDisplayLink : NSObject

@property (retain, nonatomic) CADisplayLink *displayLink;
@property (nonatomic) _Bool paused;
@property (nonatomic) struct CAFrameRateRange preferredFrameRateRange;

/* class methods */
+ (id)displayLinkForView:(id)view target:(id)target selector:(SEL)selector addingToRunLoop:(id)loop runLoopMode:(id)mode;

/* instance methods */
- (_Bool)isPaused;
- (void)dealloc;
- (id)initWithDisplayLink:(id)link;

@end


@interface ICVirtualSmartFolderItemIdentifier : NSObject <ICItemIdentifier>

@property (readonly, nonatomic) NSString *type;
@property (readonly, nonatomic) id <ICItemIdentifier> parentIdentifier;
@property (readonly, nonatomic) NSManagedObjectID *accountObjectID;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *defaultTitle;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *systemImageName;
@property (readonly, nonatomic) NSColor *iconSymbolColor;
@property (readonly, nonatomic) NSColor *iconBackgroundColor;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) ICQuery *query;
@property (readonly, copy, nonatomic) NSString *visibilityUserDefaultsKey;
@property (nonatomic) long long visibility;
@property (readonly, copy, nonatomic) NSString *noteSortTypeUserDefaultsKey;
@property (copy, nonatomic) ICFolderCustomNoteSortType *noteSortType;
@property (readonly, copy, nonatomic) NSString *dateHeadersTypeUserDefaultsKey;
@property (nonatomic) long long dateHeadersType;
@property (readonly, nonatomic) _Bool supportsDateHeaders;
@property (readonly, nonatomic) _Bool showingDateHeaders;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)allTypes;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)isShowingDateHeaders;
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)noteIsVisible:(id)visible;
- (_Bool)isType:(id)type;
- (_Bool)hasVisibleInvitationsInContext:(id)context;
- (_Bool)hasVisibleNotesInContext:(id)context;
- (id)initWithIdentifier:(id)identifier parentIdentifier:(id)identifier context:(id)context;
- (id)initWithType:(id)type parentIdentifier:(id)identifier;
- (id)initWithType:(id)type parentIdentifier:(id)identifier accountObjectID:(id)id;
- (_Bool)isEmptyInContext:(id)context;
- (_Bool)isHiddenInContext:(id)context;
- (id)predicateForContext:(id)context;
- (unsigned long long)visibleInvitationCountInContext:(id)context;
- (unsigned long long)visibleItemCountInContext:(id)context;
- (unsigned long long)visibleNoteCountInContext:(id)context;

@end


@interface ICWritingToolsContext : NSWritingToolsCoordinatorContext

@property (retain, nonatomic) NSDictionary *rangeMapping;
@property (retain, nonatomic) NSAttributedString *originalString;

/* instance methods */
- (void)updateRangeMapping:(id)mapping withinRange:(struct _NSRange)range;
- (id)initWithAttributedString:(id)string originalString:(id)string originalRange:(struct _NSRange)range rangeMapping:(id)mapping;
- (struct _NSRange)rangeInOriginalStringCorrespondingToRange:(struct _NSRange)range;

@end


@interface NPNotePreviewProviderInternal : NSObject

/* class methods */
+ (id)shared;

/* instance methods */
- (id)init;
- (id)previewForUserActivity:(id)activity error:(id *)error;

@end


@interface NoteAttachmentPresentation : NSObject <NotesCIDDataProvider>

@property (copy, nonatomic) NSString *contentID;
@property (copy, nonatomic) NSURL *dataFileURL;
@property (copy, nonatomic) NSURL *contentIDURL;
@property (retain, nonatomic) NSError *dataFileURLError;
@property (copy, nonatomic) NSString *contentIDURLAbsoluteString;
@property (copy, nonatomic) NSString *mimeType;
@property (nonatomic) _Bool image;
@property (retain, nonatomic) NSData *data;
@property (nonatomic) struct CGSize iconSize;
@property (readonly, nonatomic) NSNumber *dataSizeNumber;
@property (readonly, copy, nonatomic) NSString *filename;
@property (readonly, nonatomic) _Bool sourceIsManaged;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)attachmentPresentationsForAttachments:(id)attachments;
+ (void)prepareDocumentForPresentationWithAttachmentContentIDs:(id)ids withAttachmentPresentations:(id)presentations occurences:(id *)occurences;
+ (void)prepareDocumentForSerializationWithAttachmentContentIDs:(id)ids withAttachmentPresentations:(id)presentations newPresentationProvider:(id /* block */)provider leftoverPresentations:(id *)presentations;
+ (id)presentationSelector;

/* instance methods */
- (void)clearCache;
- (_Bool)isImage;
- (_Bool)getData:(id *)data mimeType:(id *)type error:(id *)error;
- (_Bool)getPresentationData:(id *)data mimeType:(id *)type error:(id *)error;
- (id)initWithData:(id)data contentID:(id)id mimeType:(id)type filename:(id)filename;
- (id)initWithNoteAttachmentObject:(id)object;
- (void)updateContentIDURL;

@end


@interface NoteAttachmentPresentationOccurence : NSObject

@property (readonly, nonatomic) NoteAttachmentPresentation *presentation;
@property (readonly, nonatomic) DOMHTMLElement *element;

/* instance methods */
- (id)init;
- (id)previewItemTitle;
- (id)previewItemURL;
- (id)initWithPresentation:(id)presentation element:(id)element;

@end


@interface NoteHTMLEditorView : NSView <WKUIDelegatePrivate, _WKInputDelegate, WKNavigationDelegate>

@property (copy, nonatomic) NSString *htmlStringToLoad;
@property (copy, nonatomic) NSArray *attachmentsToLoad;
@property (retain, nonatomic) ICSelectorDelayer *updateContentDelayer;
@property (nonatomic) _Bool updatingContent;
@property (nonatomic) _Bool setSelectionToEndAfterLoad;
@property (nonatomic) _Bool startEditingAfterLoad;
@property (retain, nonatomic) NoteHTMLEditorViewURLSchemeHandler *urlSchemeHandler;
@property (retain, nonatomic) NoteHTMLEditorViewScriptMessageHandler *scriptMessageHandler;
@property (retain, nonatomic) NSLayoutConstraint *webViewBottomConstraint;
@property (weak, nonatomic) id <NoteHTMLEditorViewDelegate> delegate;
@property (weak, nonatomic) id <NoteHTMLEditorViewActionDelegate> actionDelegate;
@property (weak, nonatomic) id <NoteHTMLEditorViewLayoutDelegate> layoutDelegate;
@property (retain, nonatomic) NSLayoutConstraint *contentSizeHeightConstraint;
@property (retain, nonatomic) NSLayoutConstraint *contentSizeWidthConstraint;
@property (retain, nonatomic) NoteWKWebView *webView;
@property (copy, nonatomic) NSString *htmlString;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSArray *attachmentContentIDs;
@property (nonatomic) _Bool hasAttachments;
@property (readonly, nonatomic) WebArchive *webArchive;
@property (nonatomic) _Bool editable;
@property (nonatomic) _Bool editing;
@property (nonatomic) long long selectionLength;
@property (nonatomic) double textZoomFactor;
@property (nonatomic) unsigned short listStyle;
@property (nonatomic) _Bool insideSiriSnippet;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)baseHTMLString;

/* instance methods */
- (void)scrollSelectionToVisible:(_Bool)visible;
- (_Bool)isEditing;
- (void)updateContent;
- (_Bool)isEditable;
- (void)webView:(id)view didFinishNavigation:(id)navigation;
- (void)webView:(id)view decidePolicyForNavigationAction:(id)action decisionHandler:(id /* block */)handler;
- (void)insertImage:(id)image;
- (id)initWithFrame:(struct CGRect)frame;
- (void)webViewWebContentProcessDidTerminate:(id)terminate;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)initWithCoder:(id)coder;
- (void)removeStyle:(id)style;
- (void)_webView:(id)view didInsertAttachment:(id)attachment withSource:(id)source;
- (id)webViewConfiguration;
- (void)stopEditing;
- (void)_webView:(id)view didStartInputSession:(id)session;
- (void)startEditing;
- (void)setSelectionToEnd;
- (void)setSelectionToStart;
- (_Bool)_webView:(id)view focusShouldStartInputSession:(id)session;
- (id)initWithFrame:(struct CGRect)frame siriSnippetWidth:(double)width;
- (void)accentColorDidChange:(id)change;
- (void)adoptEditableState;
- (void)alwaysShowLightContentDidChange:(id)change;
- (id)attachmentInfoDictionaryForAttachmentPresentation:(id)presentation;
- (void)didReceiveScriptMessage:(id)message;
- (void)getRectForSelectionWithCompletion:(id /* block */)completion;
- (void)insertBulletedList:(id)list;
- (void)insertDashedList:(id)list;
- (void)insertHTMLString:(id)htmlstring;
- (void)insertLinkWithURL:(id)url title:(id)title;
- (void)insertLinksWithURLs:(id)urls titles:(id)titles;
- (void)insertOrderedList:(id)list;
- (_Bool)isInsideSiriSnippet;
- (id)jsonStringFromDictionaryOrArray:(id)array;
- (void)loadAttachmentContentForURLSchemeTask:(id)task;
- (void)removeScriptHandlers;
- (void)replaceContentIDs:(id)ids;
- (void)replaceSelectionWithAttachmentPresentation:(id)presentation;
- (void)setEnableAttachments:(_Bool)attachments;
- (void)setEnableShiftNewlinesInSmartLists:(_Bool)lists;
- (void)setEnableSmartLists:(_Bool)lists;
- (void)setHtmlString:(id)string attachments:(id)attachments;
- (void)setSourceURLForAttachmentIdentifier:(id)identifier;
- (void)setupWebView;
- (void)stopEditingWithCompletion:(id /* block */)completion;
- (void)stopLoadingAttachmentContentForURLSchemeTask:(id)task;
- (void)undoablyRemoveAttachmentPresentations:(id)presentations undoManager:(id)manager;
- (void)undoablyReplaceSelectionWithAttachmentPresentations:(id)presentations undoManager:(id)manager;
- (void)updateAppearanceIfNecessary;
- (void)updateDataDetectors;
- (void)updateWebViewEditability;
- (void)updateWebViewObscuredContentInsets;

@end


@interface NoteHTMLEditorViewScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (weak, nonatomic) NoteHTMLEditorView *noteHTMLEditorView;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)userContentController:(id)controller didReceiveScriptMessage:(id)message;
- (id)initWithNoteHMLEditorView:(id)view;

@end


@interface NoteHTMLEditorViewURLSchemeHandler : NSObject <WKURLSchemeHandler>

@property (weak, nonatomic) NoteHTMLEditorView *noteHTMLEditorView;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)webView:(id)view startURLSchemeTask:(id)task;
- (void)webView:(id)view stopURLSchemeTask:(id)task;
- (id)initWithNoteHMLEditorView:(id)view;

@end


@interface NoteWKWebView : WKWebView

@property (weak, nonatomic) NoteHTMLEditorView *noteHTMLEditorView;

/* instance methods */
- (_Bool)supportsTextReplacement;
- (void)paste:(id)paste;
- (_Bool)becomeFirstResponder;
- (_Bool)canBecomeFirstResponder;
- (void)pasteAsPlainText:(id)text;
- (_Bool)performDragOperation:(id)operation;
- (void)ic_evaluateJavaScript:(id)script;
- (void)strikethrough:(id)strikethrough;

@end


@interface NotesCIDURLProtocol : NSURLProtocol

/* class methods */
+ (_Bool)canInitWithRequest:(id)request;
+ (id)canonicalRequestForRequest:(id)request;
+ (void)registerDataProvider:(id)provider forCIDURL:(id)cidurl;
+ (void)unregisterDataProviderForCIDURL:(id)cidurl;

/* instance methods */
- (void)startLoading;
- (void)stopLoading;

@end


@interface OutlineController : NSObject

@property (nonatomic, weak) ICTTTextStorage *textStorage;
@property (nonatomic, copy) NSSet *collapsedUUIDs;
@property (nonatomic, copy) NSSet *interactedUUIDs;
@property (nonatomic) _Bool isAsynchronous;
@property (nonatomic, readonly) long long collapsibleSectionAffordanceUsages;
@property (nonatomic, readonly) struct _NSRange visibleRange;
@property (nonatomic, readonly) NSArray *visibleRangeValues;
@property (nonatomic, readonly) NSArray *invisibleRangeValues;
@property (nonatomic, readonly) NSArray *rangesValuesContainingCollapsedRanges;
@property (nonatomic, readonly) NSArray *rangesValuesContainingExpandedRanges;
@property (nonatomic, readonly) NSString *debugDescription;

/* instance methods */
- (void)requestUpdate;
- (void)update;
- (id)init;
- (void)dealloc;
- (id)ancestorsForUUID:(id)uuid;
- (_Bool)canCollapseAnyUUIDs:(id)uuids;
- (_Bool)canExpandAnyUUIDs:(id)uuids;
- (id)closestVisibleAncestorForUUID:(id)uuid;
- (void)collapseAll;
- (void)collapseUUIDs:(id)uuids;
- (void)collapsibleSectionAffordanceUsedForUUIDs:(id)uuids;
- (struct _NSRange)descendantRangeForUUID:(id)uuid;
- (id)descendantsForUUID:(id)uuid;
- (void)expandAll;
- (void)expandAncestorsOfRange:(struct _NSRange)range;
- (void)expandUUIDs:(id)uuids;
- (id)initWithTextStorage:(id)storage collapsedUUIDs:(id)uuids asynchronous:(_Bool)asynchronous;
- (_Bool)isUUIDCollapsed:(id)uuidcollapsed;
- (_Bool)isUUIDCollapsible:(id)uuidcollapsible;
- (_Bool)isUUIDHidden:(id)uuidhidden;
- (void)mergingDidEndWithNotification:(id)notification;
- (void)mergingWillBeginWithNotification:(id)notification;
- (struct _NSRange)rangeForUUID:(id)uuid;
- (void)resetCollapsibleSectionAffordanceUsages;
- (void)textStorageDidProcessEndEditingWithNotification:(id)notification;
- (_Bool)toggleCollapsedAtRange:(struct _NSRange)range;
- (void)toggleUUIDCollapsed:(id)uuidcollapsed;

@end


@interface TTBulletTextAttributesCacheKey : NSObject

@property (nonatomic) unsigned long long hashValue;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithTextFont:(id)font paragraphStyle:(id)style zoomFactor:(double)factor;

@end


@interface UserStyleSheetGenerator : NSObject

@property (readonly, nonatomic) NSString *userStyleSheetStringForMainWindow;
@property (readonly, nonatomic) NSURL *userStyleSheetURLForMainWindow;
@property (readonly, nonatomic) NSURL *userStyleSheetURLForSingleNoteWindow;

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)sharedInstance;

/* instance methods */
- (id)init;
- (void)dealloc;
- (id)archiveStyleSheet;
- (id)userStyleSheetStringWithTopMargin:(double)margin bottomMargin:(double)margin;
- (id)userStyleSheetWithTopMargin:(double)margin bottomMargin:(double)margin;

@end


@interface _TtC7NotesUI13NoteSelection : NSObject

/* instance methods */
- (id)init;

@end


@interface _TtC7NotesUI16AudioAssetWriter : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI19AudioWaveformSource : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI19LinkEditorViewModel : _TtCs12_SwiftObject

@property (nonatomic, readonly) _Bool hasParagraphSelection;

@end


@interface _TtC7NotesUI21AudioRecordingManager : NSObject

/* instance methods */
- (id)init;
- (void)analyticsSessionWillEnd:(id)end;

@end


@interface _TtC7NotesUI22AudioWaveformGenerator : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI23PersistedThumbnailCache : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI25AudioRecordingCoordinator : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI25WidgetNotePreviewProvider : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI28AVAudioEngineRecordingMethod : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUI32ICNoteTimelineControllerInternal : NSObject // (Swift)

/* class methods */
+ (void)setTimeZone:(id)zone;
+ (id)ascendingTimelineSectionsForNoteObjectIds:(id)ids dates:(id)dates referenceDate:(id)date direction:(long long)direction;

/* instance methods */
- (id)init;

@end


@interface _TtC7NotesUIP33_0937A1AF2A2827E2462B0E48FD7819BC22OutlineUpdateOperation : NSOperation

/* instance methods */
- (void)main;
- (id)init;

@end


@interface _TtC7NotesUIP33_7B61C87D5F1EF51EE56142734628054A12ShareMetrics : _TtCs12_SwiftObject

@end


@interface _TtC7NotesUIP33_D37299C035145D658E3B6DC04AF9ADBF19ResourceBundleClass : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC7NotesUIP33_F897AB263D3561CA5D296CCFF5C5FDF512ICTitleQuery : PKTitleQuery <PKTitleQueryDelegate>

/* instance methods */
- (void)start;
- (id)init;
- (id)initWithDrawing:(id)drawing;
- (void)titleQuery:(id)query didUpdateWithItem:(id)item;

@end


@interface _TtCC7NotesUI17OutlineControllerP33_0937A1AF2A2827E2462B0E48FD7819BC5Cache : _TtCs12_SwiftObject

@end


@interface _TtCE7NotesUICSo29ICCalculateDocumentController11Highlighter : _TtCs12_SwiftObject

/* instance methods */
- (void)calculateDocumentControllerDidUpdateDocument:(id)document;
- (void)noteDidChangeCalculatePreviewBehavior:(id)behavior;
- (void)performHighlightsUpdate;
- (void)textStorageDidProcessEndEditing:(id)editing;

@end


@interface _TtCE7NotesUICSo29ICCalculateDocumentController14CanvasDocument : _TtCs12_SwiftObject

@end


@interface _TtCE7NotesUICSo29ICCalculateDocumentController5Index : _TtCs12_SwiftObject

@end


@interface _TtCE7NotesUICSo29ICCalculateDocumentController7Scanner : _TtCs12_SwiftObject

@end


@interface _TtCE7NotesUICSo29ICCalculateScrubberController15HoverController : NSObject

/* instance methods */
- (id)init;
- (void)showScrubber;

@end


@interface _TtCV7NotesUI14ActivityStream7Updater : _TtCs12_SwiftObject

@end


@interface AVAsset (IC_UI)

/* instance methods */
- (id)ic_previewImage;

@end


@interface CKShare (UI)

/* class methods */
+ (void)ic_cacheThumbnailsForObject:(id)object;
+ (id)ic_fallbackThumbnail;
+ (void)ic_updateThumbnailsForObject:(id)object share:(id)share completion:(id /* block */)completion;

/* instance methods */
- (void)ic_updateFromObject:(id)object;
- (void)ic_updateFromObject:(id)object generateThumbnails:(_Bool)thumbnails;
- (void)ic_updateThumbnailsFromObject:(id)object completion:(id /* block */)completion;

@end


@interface ICAccount (UI)

/* class methods */
+ (id)globalVirtualCallNotesFolder;
+ (id)globalVirtualMathNotesFolder;
+ (id)globalVirtualRecentlyDeletedMathNotesFolder;
+ (id)globalVirtualSharedWithYouFolder;
+ (id)globalVirtualSystemPaperFolder;

/* instance methods */
- (id)virtualCallNotesFolder;
- (id)virtualMathNotesFolder;
- (id)virtualSystemPaperFolder;

@end


@interface ICActivityStreamDigest (UI)

/* instance methods */
- (id)initWithObject:(id)object;
- (id)objc_initWithObject:(id)object error:(id *)error;

@end


@interface ICAirDropDocument (LegacyUI)

/* class methods */
+ (id)legacyNoteAirDropDocumentWithWebArchive:(id)archive;

/* instance methods */
- (id)webArchiveFromLegacyNoteDocument;

@end


@interface ICAppURLUtilities (UI)

/* class methods */
+ (id)appURLForNote:(id)note inVirtualSmartFolder:(id)folder;
+ (id)appURLForNoteIdentifier:(id)identifier inVirtualSmartFolder:(id)folder actionName:(id)name;
+ (id)appURLForVirtualSmartFolder:(id)folder;
+ (_Bool)isShowNoteInVirtualSmartFolderURL:(id)url;
+ (_Bool)isShowVirtualSmartFolderURL:(id)url;
+ (id)notePredicateFromNoteInVirtualSmartFolderInURL:(id)url;
+ (id)virtualSmartFolderMentionedInURL:(id)url context:(id)context;

@end


@interface ICAppearanceInfo (UI)

/* class methods */
+ (id)currentInfo;

/* instance methods */
- (id)defaultAppearance;
- (void)performAsDefaultAppearance:(id /* block */)appearance;

@end


@interface ICAttachment (LinkPresentation) <NSPasteboardWriting>

/* class methods */
+ (id)imageCache;
+ (id)ic_accessibilityIdentifierForAttachment:(id)attachment;
+ (id)imageLoadingOperationQueue;
+ (id)thumbnailOperationQueue;

/* instance methods */
- (id)attributedString;
- (id)image;
- (void)setCachedImage:(id)image;
- (id)cachedImage;
- (id)pasteboardPropertyListForType:(id)type;
- (id)writableTypesForPasteboard:(id)pasteboard;
- (unsigned long long)writingOptionsForType:(id)type pasteboard:(id)pasteboard;
- (id)activityItems;
- (id)imageCacheKey;
- (id)pasteboardData;
- (id)croppingQuad;
- (id)unprocessedDocumentImage;
- (id)fileMetadata;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)documentMergeController;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (id)inlineAttachmentWithICTTAttachment:(id)icttattachment;
- (void)notifyDocCamFrameworkAttachmentWasDeleted;
- (void)redactAuthorAttributionsToCurrentUser;
- (_Bool)usesLinkPresentation;
- (void)addPreviewImageToMetadata:(id)metadata;
- (_Bool)alwaysUsesSmallSize;
- (id)archiveLinkmetadata:(id)linkmetadata;
- (id)deviceInfosWithoutPreviewImagesFromDeviceInfos:(id)infos;
- (long long)docCamPDFVersion;
- (id)fallbackMapMetadata;
- (id)fallbackRemoteAttachmentMetadata;
- (id)fallbackWebMetadata;
- (_Bool)fetchThumbnailImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceInfo:(id)info cache:(id)cache cacheKey:(id)key processingBlock:(id /* block */)block completionBlock:(id /* block */)block fallbackBlock:(id /* block */)block aboutToLoadHandler:(id /* block */)handler;
- (id)filePreviewGenerationQueue;
- (void)filterInlineAttachmentsInTableColumnTextStorage:(id)storage range:(struct _NSRange)range;
- (id)inlineAttachmentFromObject:(id)object createIfNecessary:(_Bool)necessary;
- (_Bool)isUnsupportedOnCurrentPlatform;
- (id /* block */)loadImage:(id /* block */)image;
- (id /* block */)loadImage:(id /* block */)image aboutToLoadHandler:(id /* block */)handler forceFullSizeImage:(_Bool)image;
- (id)loadingAttachmentsMetadata;
- (id)lpImageFromFallbackPDF;
- (id)lpImageFromPreviewImage:(id)image;
- (id)mapPreviewGenerationQueue;
- (_Bool)metadataExists;
- (id)modificationDateForSpeaking;
- (id)movieDurationForSpeaking;
- (void)persistLinkMetadata:(id)metadata;
- (id)plainURLMetadata;
- (void)requestFileMetadataIfNecessary;
- (void)requestRemoteMetadata;
- (id)retrieveLinkMetadata;
- (id)scannedDocumentsMetadata;
- (void)setCroppingQuad:(id)quad;
- (_Bool)thumbnailImage:(id *)image minSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type requireAppearance:(_Bool)appearance imageScaling:(unsigned long long *)scaling showAsFileIcon:(_Bool *)icon isMovie:(_Bool *)movie movieDuration:(struct { long long x0; int x1; unsigned int x2; long long x3; } *)duration;
- (_Bool)thumbnailImage:(id *)image minSize:(struct CGSize)size scale:(double)scale imageScaling:(unsigned long long *)scaling showAsFileIcon:(_Bool *)icon isMovie:(_Bool *)movie movieDuration:(struct { long long x0; int x1; unsigned int x2; long long x3; } *)duration;
- (id)updateAttachmentPreviewImageWithImage:(id)image scale:(double)scale appearanceType:(unsigned long long)type scaleWhenDrawing:(_Bool)drawing metadata:(id)metadata sendNotification:(_Bool)notification;
- (id)updateAttachmentPreviewImageWithImage:(id)image scale:(double)scale scaleWhenDrawing:(_Bool)drawing metadata:(id)metadata sendNotification:(_Bool)notification;
- (id)webPreviewGenerationQueue;

@end


@interface ICAttachmentAudioModel (UI)

/* instance methods */
- (_Bool)hasPreviews;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (_Bool)needToGeneratePreviews;
- (_Bool)synchronouslyGenerateFallbackMediaDataIfNecessaryAndReturnError:(id *)error;

@end


@interface ICAttachmentDrawingModel (UI)

/* instance methods */
- (id)pasteboardPropertyListForType:(id)type;
- (id)writableTypesForPasteboard:(id)pasteboard;
- (id)providerDataTypes;
- (id)providerFileTypes;
- (id)activityItem;
- (id)activityItems;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (id)imageForActivityItem;
- (_Bool)needToGeneratePreviews;
- (void)saveDrawing:(id)drawing withImage:(id)image forImageDrawing:(id)drawing;

@end


@interface ICAttachmentGalleryModel (UI) <NSFilePromiseProviderDelegate>

/* instance methods */
- (id)itemProvider;
- (id)filePromiseProvider:(id)provider fileNameForType:(id)type;
- (void)filePromiseProvider:(id)provider writePromiseToURL:(id)url completionHandler:(id /* block */)handler;
- (id)pasteboardPropertyListForType:(id)type;
- (id)previewItemURL;
- (id)writableTypesForPasteboard:(id)pasteboard;
- (id)providerFileTypes;
- (id)activityItems;
- (id)filePromiseProvider;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (id)blockingGeneratePDFURL;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (_Bool)needToGeneratePreviews;
- (id)quicklookPreviewItems;
- (_Bool)requiresFilePromiseForDrags;

@end


@interface ICAttachmentGenericModel (PreviewGeneration)

/* instance methods */
- (_Bool)generateAsynchronousPreviews;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (_Bool)needToGeneratePreviews;

@end


@interface ICAttachmentImageModel (UI)

/* instance methods */
- (id)pasteboardPropertyListForType:(id)type;
- (id)activityItems;
- (id)classificationsForImage:(id)image;
- (void)classifyImageInOperation:(id)operation;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (id)generateFullSizePreviewWithAttachmentIdentifier:(id)identifier existingPreviewImage:(id)image markupModelData:(id)data imageOrientation:(long long)orientation imageFilterType:(short)type mediaDecryptedData:(id)data mediaURL:(id)url mediaSize:(struct CGSize)size croppingQuad:(id)quad;
- (void)generateOCRInOperation:(id)operation;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (id)labelsForClassificationObservations:(id)observations;
- (_Bool)needToGeneratePreviews;
- (_Bool)needToPostProcessAttachment;

@end


@interface ICAttachmentInlineDrawingModel (CoreHandwritingPrivate)

/* class methods */
+ (_Bool)handwritingRecognitionSupported;
+ (unsigned short)drawingPreviewVersion;
+ (id)generateImageForAttachment:(id)attachment fromDrawing:(id)drawing fullResolution:(_Bool)resolution appearanceInfo:(id)info;
+ (void)generatePreviewsForAttachment:(id)attachment fromDrawing:(id)drawing;
+ (id)previewImageFromDrawing:(id)drawing fullImage:(struct CGImage *)image scale:(double)scale;

/* instance methods */
- (id)filePromiseProvider:(id)provider fileNameForType:(id)type;
- (void)filePromiseProvider:(id)provider writePromiseToURL:(id)url completionHandler:(id /* block */)handler;
- (id)activityItem;
- (id)activityItems;
- (void)setTitleQuery:(id)query;
- (id)titleQueryDrawingDispatchQueue:(id)queue;
- (_Bool)mergeWithDrawing:(id)drawing;
- (id)titleQuery;
- (void)titleQuery:(id)query didUpdateWithItem:(id)item;
- (id)filePromiseProvider;
- (void)attachmentModelDealloc;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (id)mergeableDataForCopying:(id *)copying;
- (void)updateAfterLoadWithSubAttachmentIdentifierMap:(id)map;
- (_Bool)isHandwritingRecognitionEnabled;
- (_Bool)actuallyMergeWithDrawing:(id)drawing;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id)handwritingRecognitionDrawingQueue;
- (id)imageForActivityItem;
- (_Bool)isTitleQueryEnabled;
- (_Bool)needToGeneratePreviews;
- (void)setHandwritingRecognitionDrawingQueue:(id)queue;
- (void)setHandwritingRecognitionEnabled:(_Bool)enabled;
- (void)setTitleQueryEnabled:(_Bool)enabled;

@end


@interface ICAttachmentMapModel (UI)

/* instance methods */
- (_Bool)generateAsynchronousPreviews;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (_Bool)needToGeneratePreviews;
- (_Bool)requiresNetworkToGeneratePreview;

@end


@interface ICAttachmentModel (UI) <NSPasteboardWriting, NSFilePromiseProviderDelegate>

/* class methods */
+ (id)fileIconForURL:(id)url withPreferredSize:(struct CGSize)size;
+ (id)fileIconForURL:(id)url withPreferredSize:(struct CGSize)size uti:(id)uti;

/* instance methods */
- (id)itemProvider;
- (id)filePromiseProvider:(id)provider fileNameForType:(id)type;
- (void)filePromiseProvider:(id)provider writePromiseToURL:(id)url completionHandler:(id /* block */)handler;
- (id)pasteboardPropertyListForType:(id)type;
- (id)writableTypesForPasteboard:(id)pasteboard;
- (unsigned long long)writingOptionsForType:(id)type pasteboard:(id)pasteboard;
- (id)activityItems;
- (id)filePromiseProvider;
- (void)classifyImageInOperation:(id)operation;
- (void)didCancelPreviewGeneratorOperation;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (id)fileIconWithPreferredSize:(struct CGSize)size;
- (id)forceCreateFilePromiseProvider;
- (_Bool)generateAsynchronousPreviews;
- (void)generateOCRInOperation:(id)operation;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickLargeThumbnailCreator;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (_Bool)needToGeneratePreviews;
- (_Bool)needToPostProcessAttachment;
- (id)quicklookPreviewItems;
- (_Bool)requiresFilePromiseForDrags;
- (_Bool)requiresNetworkToGeneratePreview;
- (_Bool)tooLargeForPreviewGeneration;

@end


@interface ICAttachmentMovieModel (UI)

/* instance methods */
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;

@end


@interface ICAttachmentPDFModel (UI)

/* instance methods */
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;

@end


@interface ICAttachmentPaperBundleModel (UI)

/* class methods */
+ (_Bool)fallbackPDFGenerationEnabled;
+ (_Bool)generateImagePreviewsForAttachment:(id)attachment withFallbackPDFData:(id)pdfdata;

/* instance methods */
- (id)activityItem;
- (id)activityItems;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generateFallbackPDF;
- (_Bool)generateFallbackPDFIfNecessary;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (_Bool)needToGeneratePreviews;

@end


@interface ICAttachmentPaperDocumentModel (PreviewGeneration)

/* instance methods */
- (_Bool)tooLargeForPreviewGeneration;

@end


@interface ICAttachmentPreviewImage (UI)

/* class methods */
+ (id)imageCache;
+ (id)orientedImage:(id)image withTransform:(struct CGAffineTransform)transform background:(int)background backgroundTransform:(struct CGAffineTransform)transform;

/* instance methods */
- (id)image;
- (void)setCachedImage:(id)image;
- (id)cachedImage;
- (void)clearCachedImage;
- (void)clearCachedOrientedImage;
- (_Bool)hasCachedImage;
- (struct CGAffineTransform)orientedImageTransform;
- (void)writeOrientedPreviewToDisk;
- (id)orientedImageID;
- (id /* block */)asyncImage:(id /* block */)image aboutToLoadHandler:(id /* block */)handler;
- (id)cachedOrientedImage;
- (id)imageWithBackground:(int)background;
- (id)newImageLoaderForUpdatingImageOnCompletion:(_Bool)completion;
- (id)newImageLoaderForUpdatingImageOnCompletion:(_Bool)completion asyncDataLoading:(_Bool)loading;
- (id)orientedImage;
- (id)orientedImageWithBackground:(int)background;
- (void)setCachedOrientedImage:(id)image;

@end


@interface ICAttachmentSystemPaperModel (UI)

/* class methods */
+ (id)generateEmptyImage;
+ (id)generateImageForAttachment:(id)attachment fullResolution:(_Bool)resolution appearanceInfo:(id)info;
+ (_Bool)generatePreviewsForAttachment:(id)attachment paperIdentifier:(id)identifier;
+ (id)previewImageForAttachment:(id)attachment fullImage:(struct CGImage *)image scale:(double)scale appearanceInfo:(id)info;

/* instance methods */
- (id)filePromiseProvider:(id)provider fileNameForType:(id)type;
- (void)filePromiseProvider:(id)provider writePromiseToURL:(id)url completionHandler:(id /* block */)handler;
- (id)activityItem;
- (id)activityItems;
- (id)filePromiseProvider;
- (void)attachmentModelDealloc;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (_Bool)generatePreviewsDuringCloudActivity;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id)imageForActivityItem;
- (_Bool)needToGeneratePreviews;

@end


@interface ICAttachmentTableModel (UI)

/* instance methods */
- (id)activityItems;
- (id)htmlString;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (void)redactAuthorAttributionsToCurrentUser;
- (void)drawPreviewInRect:(struct CGRect)rect;
- (struct CGSize)previewInAvailableSize:(struct CGSize)size shouldDraw:(_Bool)draw;
- (id)quicklookPreviewItems;

@end


@interface ICAttachmentWebModel (UI)

/* class methods */
+ (id)genericBrickThumbnailWithSize:(struct CGSize)size scale:(double)scale;

/* instance methods */
- (_Bool)downloadPreviewForAttachmentURL:(id)url;
- (_Bool)extractPreviewImagesFromSynapseData:(id)data;
- (_Bool)generateAsynchronousPreviews;
- (_Bool)generatePreviewsInOperation:(id)operation;
- (id /* block */)genericBrickLargeThumbnailCreator;
- (id /* block */)genericBrickThumbnailCreator;
- (id /* block */)genericListThumbnailCreator;
- (_Bool)needToGeneratePreviews;
- (void)saveImagesFromLinkMetadata:(id)metadata;
- (_Bool)updateAttachmentPreviewImagesMetadata;
- (void)updateAttachmentWithPreviewImage:(id)image;
- (void)updateTitle:(id)title andDescription:(id)description;

@end


@interface ICCloudSyncingObject (UI)

/* class methods */
+ (_Bool)isInlineAttachment:(id)attachment;

/* instance methods */
- (id)shareViaICloudManageActionTitle;
- (id)participantsInfoDescription;
- (id)shareViaICloudAddPeopleActionTitle;
- (id)shareViaICloudSystemImageName;

@end


@interface ICDividerLineTextAttachment (UI)

/* instance methods */
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;

@end


@interface ICFolder (UI)

/* class methods */
+ (id)foldersWithHashtagAsOnlyFilter:(id)filter;
+ (id)defaultFilledSystemImageName;
+ (id)defaultSystemImageName;
+ (void)removeUsageOfHashtag:(id)hashtag;
+ (id)smartFoldersThatWillBeDeletedAfterDeletingHashtags:(id)hashtags;

/* instance methods */
- (id)systemImageName;
- (id)filledSystemImageName;

@end


@interface ICFolderCustomNoteSortType (UI)

/* class methods */
+ (_Bool)isTagADirection:(long long)adirection;
+ (_Bool)isTagAnOrder:(long long)order;
+ (long long)sortTypeDirectionForTag:(unsigned long long)tag;
+ (long long)sortTypeOrderForTag:(unsigned long long)tag;
+ (unsigned long long)tagForSortTypeDirection:(long long)direction;
+ (unsigned long long)tagForSortTypeOrder:(long long)order;

/* instance methods */
- (void)configureMenuItemForCustomSorting:(id)sorting;

@end


@interface ICHashtag (UI)

/* instance methods */
- (void)removeUsage;

@end


@interface ICHashtagController (App)

/* instance methods */
- (void)checkForHashtagInEditedRange:(struct _NSRange)range ofTextStorage:(id)storage note:(id)note textView:(id)view allowAutoExplicitHashtag:(_Bool)hashtag isEndingEditing:(_Bool)editing languageHasSpaces:(_Bool)spaces parentAttachment:(id)attachment;

@end


@interface ICInlineAttachment (UI)

/* class methods */
+ (_Bool)canInsertInlineAttachmentType:(short)type intoNote:(id)note parentAttachment:(id)attachment;
+ (id)createHashtagAttachmentIfApplicableWithHashtagText:(id)text creatingHashtagIfNecessary:(_Bool)necessary note:(id)note parentAttachment:(id)attachment;
+ (id)createHashtagAttachmentIfApplicableWithHashtagText:(id)text forHashtag:(id)hashtag note:(id)note parentAttachment:(id)attachment;
+ (id)createInlineAttachmentIfApplicableWithTypeUTI:(id)uti altText:(id)text tokenContentIdentifier:(id)identifier note:(id)note parentAttachment:(id)attachment;
+ (id)createMentionAttachmentIfApplicableWithMentionText:(id)text userRecordName:(id)name note:(id)note parentAttachment:(id)attachment;
+ (id)newLinkAttachmentToNote:(id)note fromNote:(id)note parentAttachment:(id)attachment;
+ (id)newLinkAttachmentToNote:(id)note paragraphID:(id)id paragraphName:(id)name fromNote:(id)note parentAttachment:(id)attachment;

/* instance methods */
- (id)uiModel;
- (void)_announceAttachmentChangeWithString:(id)string;
- (_Bool)_checkIsVoiceOverRunning;
- (unsigned long long)_linkSubtype;
- (void)accessibilityAnnounceCreationWithVoiceOver;
- (void)accessibilityAnnounceDeletionWithVoiceOver;
- (id)ic_accessibilityLabel;
- (id)ic_accessibilityTypeString;

@end


@interface ICInvitation (UI)

/* instance methods */
- (id)contentDescription;
- (_Bool)hasThumbnail;
- (id)typeDescription;
- (id)joinDescription;
- (id)joinActionTitle;
- (id)participantsInfoDescription;
- (id)removeActionTitle;
- (id)thumbnailImageForAppearance:(id)appearance size:(struct CGSize)size;
- (void)updateFromShare:(id)share;

@end


@interface ICMarkupUtilities (UI)

/* class methods */
+ (id)dataToEditForAttachment:(id)attachment includeMarkupModelData:(_Bool)data;
+ (id)dataToEditForAttachment:(id)attachment includeMarkupModelData:(_Bool)data embedMarkupModelDataInImage:(_Bool)image;

@end


@interface ICMentionsController (UI) <ICMentionsControllerApp>

/* class methods */
+ (_Bool)hasMentionInTextStorage:(id)storage inRange:(struct _NSRange)range;
+ (struct _NSRange)rangeOfUnconfirmedMentionInTextStorage:(id)storage;

/* instance methods */
- (id)fetchContactNamesForParticipants:(id)participants;
- (void)registerForContactsChangedNotification;
- (void)applyUnconfirmedMentionToTextStorage:(id)storage participants:(id)participants range:(struct _NSRange)range textView:(id)view mentionString:(id)string;
- (_Bool)checkForMentionInEditedRange:(struct _NSRange)range ofTextStorage:(id)storage note:(id)note textView:(id)view allowAutoExplicitMention:(_Bool)mention isEndingEditing:(_Bool)editing languageHasSpaces:(_Bool)spaces parentAttachment:(id)attachment;
- (void)clearUnconfirmedMentionInTextStorage:(id)storage;
- (void)insertMentionWithText:(id)text uuidString:(id)string parentAttachment:(id)attachment;
- (void)newlineEnteredInNote:(id)note;
- (void)sendPendingNotificationsAfterDelay:(unsigned long long)delay forNote:(id)note;
- (void)tableCellFirstResponderChangedInNote:(id)note;

@end


@interface ICNote (AirDropDocumentUI) <ICTTTextStorageDelegate>

/* class methods */
+ (id)attributedStringFromHTMLString:(id)htmlstring;
+ (_Bool)isDefaultColor:(id)color;
+ (void)_styleTitleIfNeededForNote:(id)note;
+ (id)attributedStringFromHTMLString:(id)htmlstring baseURL:(id)url readerDelegate:(id)delegate;
+ (id)attributedStringFromHTMLString:(id)htmlstring readerDelegate:(id)delegate;
+ (void)createNoteForAirDropDocument:(id)document legacyContext:(id)context completion:(id /* block */)completion;
+ (id)duplicateNote:(id)note intoFolder:(id)folder isPasswordProtected:(_Bool)_protected removeOriginalNote:(_Bool)note;
+ (id)duplicateNote:(id)note isPasswordProtected:(_Bool)_protected removeOriginalNote:(_Bool)note;
+ (void)fixDashedListsInAttributedString:(id)string;
+ (void)fixFontsInAttributedString:(id)string;
+ (void)fixHorizontalRulesInAttributedString:(id)string;
+ (void)fixTextColorsInAttributedString:(id)string;
+ (void)fixUnwantedCharactersInAttributedString:(id)string;
+ (id)hexStringForColor:(id)color;
+ (id)htmlObjectAttributesForAttachmentWithContentID:(id)id;
+ (id)htmlStringByFixingDashedListsInHTMLString:(id)htmlstring;
+ (id)htmlStringByReplacingHorizontalRulesWithMarker:(id)marker;
+ (id)htmlStringFromAttributedString:(id)string attachmentConversionHandler:(id /* block */)handler;
+ (id)ic_accessibilityIdentifierForNote:(id)note;
+ (id)mutableAttributedStringFromHTMLString:(id)htmlstring baseURL:(id)url;
+ (id)mutableAttributedStringFromHTMLString:(id)htmlstring readerDelegate:(id)delegate;
+ (id)newNoteWithAttributedString:(id)string inFolder:(id)folder error:(id *)error;
+ (id)newNoteWithAttributedString:(id)string inFolder:(id)folder styleTitle:(_Bool)title error:(id *)error;
+ (id)newNoteWithString:(id)string inFolder:(id)folder error:(id *)error;
+ (void)redactNote:(id)note;
+ (void)removeUsageOfHashtag:(id)hashtag;
+ (id)tagDictionariesForAttributes:(id)attributes attachmentConversionHandler:(id /* block */)handler;
+ (id)tagDictionaryForWrapperAroundParagraphStyle:(id)style;
+ (id)thumbnailImageForAttachment:(id)attachment minSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type requireAppearance:(_Bool)appearance imageScaling:(unsigned long long *)scaling showAsFileIcon:(_Bool *)icon isMovie:(_Bool *)movie movieDuration:(struct { long long x0; int x1; unsigned int x2; long long x3; } *)duration;

/* instance methods */
- (id)textStorage;
- (double)saveDelayMaxTime;
- (void)save;
- (id)textContentStorage;
- (void)textStorage:(id)storage didProcessEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (void)textStorage:(id)storage willProcessEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (_Bool)removeHashtag:(id)hashtag;
- (id)htmlString;
- (void)setSelectedInk:(id)ink;
- (id)selectedInk;
- (void)createMissingAttachmentsInTextStorage;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)documentMergeController;
- (void)formatExpressionsInAttributedString:(id)string range:(struct _NSRange)range textStorageOffset:(long long)offset skipStaleExpressions:(_Bool)expressions;
- (void)noteDidApplyAttachmentViewTypeToAllAttachments;
- (void)noteDidClearDecryptedData;
- (void)noteDidMergeNoteDocumentWithUserInfo:(id)info;
- (void)noteDidReplaceDocument;
- (void)noteWillMergeDocumentWithUserInfo:(id)info;
- (void)noteWillReleaseTextStorage;
- (void)noteWillTurnIntoFault;
- (void)redactAuthorAttributionsToCurrentUser;
- (id)searchableItemViewAttributeSet;
- (_Bool)shouldReleaseTextStorageWhenTurningIntoFault;
- (id)uiAttributedString;
- (id)attributedStringForUTI:(id)uti inRange:(struct _NSRange)range;
- (_Bool)convertTextInNoteBodyToHashtag:(id)hashtag;
- (_Bool)isDrawingStroke;
- (_Bool)isHandwritingRecognitionEnabled;
- (void)_delayedSave;
- (id)_icaxGalleryViewDescriptionForAttachment:(id)attachment fromAttachments:(id)attachments orInlineAttachments:(id)attachments;
- (unsigned long long)_icaxItemNumberForParagraphAtLocation:(unsigned long long)location withStyle:(id)style inAttrString:(id)string;
- (void)_updateTextViewToPaperIfNecessary;
- (id)addHashtagToNoteBody:(id)body onlyIfMissing:(_Bool)missing;
- (id)addHashtagToNoteBodyIfMissing:(id)missing;
- (void)announceAccessibilitySelectionChangedByMerge;
- (void)announceAccessibilitySelectionChangedByMergeWithSavedSelections:(id)selections beforeMergeTimestamp:(id)timestamp;
- (_Bool)appendAttributedString:(id)string error:(id *)error;
- (_Bool)appendAttributedString:(id)string options:(unsigned long long)options error:(id *)error;
- (void)applyOutlineState;
- (id)attachmentActivityItemsForSharing;
- (id)attachmentActivityItemsForSharingForRange:(struct _NSRange)range;
- (id)attachmentFromInlineDrawingAttachment:(id)attachment;
- (id)attachmentFromLegacyAttachmentFileWrapper:(id)wrapper;
- (id)attachmentFromObject:(id)object createIfNecessary:(_Bool)necessary;
- (id)attachmentFromRemoteFileWrapper:(id)wrapper;
- (id)attachmentFromStandardFileWrapper:(id)wrapper;
- (id)attachmentFromSystemPaperAttachment:(id)attachment;
- (id)attachmentFromTableData:(id)data;
- (id)calculateAccessibilityController;
- (id)calculateDocumentController;
- (long long)calculatePreviewBehavior;
- (id)calculatePreviewBehaviorUserDefaultsKey;
- (id)checklistStyleAccessibilityDescriptionForRange:(struct _NSRange)range;
- (id)collaborationColorManager;
- (_Bool)copyValuesToNote:(id)note;
- (void)createInlineAttachmentsForDividerLinesInAttributedString:(id)string;
- (void)discardCalculateDocumentController;
- (id)emphasisStyleAccessibilityDescriptionForRange:(struct _NSRange)range;
- (id)expandedNameForParagraphID:(id)id;
- (void)filterAttachmentsInTextStorage:(id)storage range:(struct _NSRange)range;
- (id)firstAttachmentInTextStorage;
- (id)folderSystemImageName;
- (_Bool)hasMentionForParticipant:(id)participant;
- (id)htmlStringWithAttachmentConversionHandler:(id /* block */)handler;
- (id)htmlStringWithAttachments:(_Bool)attachments;
- (id)htmlStringWithHTMLAttachments;
- (unsigned long long)ic_characterCountIncludingSpaces:(_Bool)spaces;
- (_Bool)ic_hasLightBackground;
- (unsigned long long)ic_lineCount;
- (unsigned long long)ic_wordCount;
- (id)icaxGalleryViewCustomContentDescription;
- (id)indentationStyleAccessibilityDescriptionForRange:(struct _NSRange)range;
- (_Bool)isCalculateMathEnabled;
- (_Bool)isFastSyncSessionActive;
- (_Bool)isHashtagRowAtRange:(struct _NSRange)range outRangeForAppending:(struct _NSRange *)appending outIndex:(long long *)index forHashtagAttachment:(id)attachment outHashtagCount:(long long *)count;
- (double)lastSaveDuration;
- (void)markBlockAndInlineAttachmentsForDeletion:(_Bool)deletion inAttributedString:(id)string;
- (id)noteActivityItemsForSharingWithNoteExporter:(id)exporter;
- (void)notifyTextViewsNoteDidMerge;
- (void)notifyTextViewsNoteWillMerge;
- (void)outlineControllerCollapsedStateDidChange:(id)change;
- (unsigned long long)preventLockReason;
- (long long)primaryWritingDirection;
- (id)rangesModifiedAfterTimestamp:(id)timestamp inTextStorage:(id)storage;
- (_Bool)replaceCharactersInRange:(struct _NSRange)range withAttributedString:(id)string options:(unsigned long long)options error:(id *)error;
- (void)saveAfterDelay;
- (double)saveDelayDebounceTime;
- (id)saveDelayer;
- (id)saveDelayerNoCreate;
- (void)saveOutlineState;
- (void)setCalculatePreviewBehavior:(long long)behavior;
- (void)setHandwritingRecognitionEnabled:(_Bool)enabled;
- (void)setIsDrawingStroke:(_Bool)stroke;
- (void)setIsFastSyncSessionActive:(_Bool)active;
- (void)setLastSaveDuration:(double)duration;
- (id)textContentStorageCreateIfNeeded;
- (void)textStorageDidChange:(id)change;
- (void)textStorageDidPerformUndo:(id)undo;
- (void)textStorageWillChange:(id)change;
- (id)textStorageWithoutCreating;
- (id)thumbnailImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type requireAppearance:(_Bool)appearance imageScaling:(unsigned long long *)scaling showAsFileIcon:(_Bool *)icon isMovie:(_Bool *)movie movieDuration:(struct { long long x0; int x1; unsigned int x2; long long x3; } *)duration;
- (id)thumbnailImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type requireAppearance:(_Bool)appearance imageScaling:(unsigned long long *)scaling showAsFileIcon:(_Bool *)icon isMovie:(_Bool *)movie movieDuration:(struct { long long x0; int x1; unsigned int x2; long long x3; } *)duration attachment:(id *)attachment;
- (void)updateLinkReferencesFromNote:(id)note toNote:(id)note;
- (void)updateModificationDateAndChangeCount;
- (void)updateModificationDateAndChangeCountAndSaveAfterDelay;
- (void)updateModificationDateAndChangeCountAndSaveImmediately;
- (void)updatePKDrawingsWithHandwritingRecognitionEnabled:(_Bool)enabled;
- (_Bool)updateThumbnailAttachmentIdentifier;

@end


@interface ICSearchQueryOperation (UI)

/* instance methods */
- (id)initWithSearchSuggestionsResponder:(id)responder searchString:(id)string performNLSearch:(_Bool)nlsearch tokens:(id)tokens;
- (id)initWithSearchSuggestionsResponder:(id)responder userInput:(id)input performNLSearch:(_Bool)nlsearch modernResultsOnly:(_Bool)only;

@end


@interface ICTTAttachment (UI)

/* instance methods */
- (long long)embeddingType;

@end


@interface ICTTFont (UI)

/* class methods */
+ (id)convertFont:(id)font toBold:(_Bool)bold toItalic:(_Bool)italic;
+ (void)font:(id)font isBold:(_Bool *)bold isItalic:(_Bool *)italic isMonospace:(_Bool *)monospace;

/* instance methods */
- (id)nativeFontForStyle:(unsigned int)style;
- (id)nativeFontForStyle:(unsigned int)style contentSizeCategory:(id)category isForPrint:(_Bool)print;

@end


@interface ICTTParagraphStyle (UI)

/* instance methods */
- (long long)layoutWritingDirection;

@end


@interface ICTable (NSTextTableAdditions)

/* instance methods */
- (id)attributedStringWithNSTextTablesForColumns:(id)columns rows:(id)rows context:(id)context;
- (id)attributedStringWithNSTextTablesForColumns:(id)columns rows:(id)rows context:(id)context forPrinting:(_Bool)printing;
- (id)documentForCellAtColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (void)enumerateTextStoragesForColumnIndexes:(id)indexes rowIndexes:(id)indexes undoTarget:(id)target undoManager:(id)manager usingBlock:(id /* block */)block;
- (id)joinedAttributedStringForColumns:(id)columns rows:(id)rows;
- (id)joinedAttributedStringForColumns:(id)columns rows:(id)rows deepCopyInlineAttachments:(_Bool)attachments note:(id)note parentAttachment:(id)attachment;
- (id)mergeableStringForColumnID:(id)id rowID:(id)id createIfNeeded:(_Bool)needed;
- (id)p_attributedStringForCell:(id)cell inTable:(id)table atColumn:(unsigned long long)column row:(unsigned long long)row shouldFilter:(_Bool)filter context:(id)context;
- (id)textStorageForCellAtColumnID:(id)id rowID:(id)id;
- (id)textStorageForCellAtColumnID:(id)id rowID:(id)id undoTarget:(id)target undoManager:(id)manager;
- (id)textStorageForCellAtColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (id)textStorageForCellAtColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index undoTarget:(id)target undoManager:(id)manager;
- (id)textStorageForColumn:(id)column;
- (id)textStorageForColumn:(id)column forPrinting:(_Bool)printing;

@end


@interface ICTagSelection (UI)

/* instance methods */
- (id)boldFontForTextStyle:(id)style;
- (id)fontForTextStyle:(id)style;
- (id)summaryWithJoinOperatorMenu:(_Bool)menu usingTextStyle:(id)style foregroundColor:(id)color;

@end


@interface ICWidget (TimelineReloader)

/* instance methods */
- (_Bool)objc_reloadsTimelinesAutomatically;
- (_Bool)reloadsTimelinesAutomatically;
- (void)setObjc_reloadsTimelinesAutomatically:(_Bool)automatically;
- (void)setReloadsTimelinesAutomatically:(_Bool)automatically;

@end


@interface NFNote (AirDropDocumentUI) <ICLegacyNoteUI>

/* class methods */
+ (void)importLegacyNoteFromWebArchive:(id)archive withContent:(id)content intoLegacyNote:(id)note context:(id)context;
+ (id)newNoteForAirDropDocument:(id)document inContext:(id)context;
+ (id)noteByImportingLegacyNoteFromWebArchive:(id)archive withContent:(id)content context:(id)context;
+ (id)titleForHTMLString:(id)htmlstring;

/* instance methods */
- (_Bool)appendAttributedString:(id)string error:(id *)error;

@end


@interface NSAlert (IC)

/* class methods */
+ (void)ic_showAlertWithMessage:(id)message;
+ (void)ic_showAlertWithMessage:(id)message informativeText:(id)text;
+ (void)ic_showAlertWithMessage:(id)message informativeText:(id)text window:(id)window;
+ (void)ic_showAlertWithMessage:(id)message informativeText:(id)text window:(id)window alertStyle:(unsigned long long)style;

@end


@interface NSAppearance (IC)

/* class methods */
+ (_Bool)ic_alwaysShowLightContent;
+ (_Bool)ic_darkModeEnabled;
+ (void)setIc_alwaysShowLightContent:(_Bool)content;

/* instance methods */
- (id)ic_appearanceInfo;
- (id)ic_appearanceInfoForContent;
- (_Bool)ic_isDark;
- (void)ic_performAsCurrent:(id /* block */)current;

@end


@interface NSApplication (IC)

/* class methods */
+ (id)xmlStringFromDictionary:(id)dictionary;
+ (void)ic_openICloudPreferencePaneWithActions:(id)actions;
+ (void)ic_openICloudStoragePreferencePane;

@end


@interface NSArrayController (IC)

/* instance methods */
- (id)ic_arrangedObjectAfterObjects:(id)objects;
- (void)ic_interpolateSelectedObjectsWithArrangedObject:(id)object;

@end


@interface NSAttributedString (IC_UI)

/* class methods */
+ (id)ic_attributedStringWithString:(id)string font:(id)font;
+ (id)ic_blockQuoteMenuItemAttributedString;

/* instance methods */
- (id)ic_attributedStringByFlatteningCalculateAttachmentsWithContext:(id)context;
- (id)_ic_attributedStringByHighlightingRegexMatches:(id)matches withHighlightColor:(id)color attributeName:(id)name;
- (id)ic_attributedStringByCopyingInlineAttachmentsAndUpdatingChangeCountWithContext:(id)context;
- (id)ic_attributedStringByFlatteningInlineAttachmentsWithContext:(id)context formatter:(id /* block */)formatter;
- (id)ic_attributedStringByHighlightingRegex:(id)regex withHighlightColor:(id)color;
- (id)ic_attributedStringByHighlightingRegex:(id)regex withHighlightColor:(id)color attributeName:(id)name;
- (id)ic_attributedStringByHighlightingRegexFinderMatches:(id)matches withHighlightColor:(id)color;
- (id)ic_attributedStringByHighlightingRegexFinderMatches:(id)matches withHighlightColor:(id)color attributeName:(id)name;
- (id)ic_attributedSubstringUntilLine:(unsigned int)line;
- (id)ic_attributesByHighlightingAttributes:(id)attributes withHighlightColor:(id)color attributeName:(id)name;
- (_Bool)ic_containsBlockAttachmentsInRange:(struct _NSRange)range;
- (_Bool)ic_containsTextAttachment:(id)attachment;
- (id)ic_nextTableStringFromIndex:(unsigned long long)index tableRange:(struct _NSRange *)range;
- (unsigned long long)ic_numRowsForTextTable:(id)table outNumColumns:(out unsigned long long *)columns;
- (unsigned long long)ic_numberOfTables;
- (struct _NSRange)ic_rangeForAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (struct _NSRange)ic_rangeForBaseAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (struct _NSRange)ic_rangeForInlineAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (struct _NSRange)ic_rangeofNextTableFromIndex:(unsigned long long)index;
- (id)ic_sanitizedAttributedString;
- (id)ic_stringByTrimmingLeadingTrailingWhitespace;
- (id)ic_stringWithoutAttachments;
- (struct { unsigned long long x0; unsigned long long x1; })ic_tableSizeForTextTable:(id)table inRange:(struct _NSRange)range;
- (id)ic_textTablesInRange:(struct _NSRange)range;
- (long long)ic_writingDirectionAtIndex:(unsigned long long)index;

@end


@interface NSBezierPath (IC)

/* instance methods */
- (struct CGPath *)ic_createCGPath;

@end


@interface NSCollectionView (IC)

/* class methods */
+ (long long)numberOfItemsInItemsPerSection:(id)section;
+ (long long)ic_indexOfObjectAtIndexPath:(id)path in:(id)in itemsPerSection:(id)section;
+ (id)ic_indexPathOfObjectAtIndex:(long long)index in:(id)in itemsPerSection:(id)section;

/* instance methods */
- (void)ic_animateFromArrangedObjects:(id)objects fromArrangedObjectsItemsPerSection:(id)section toArrangedObjects:(id)objects toArrangedObjectsItemsPerSection:(id)section duration:(double)duration completion:(id /* block */)completion;
- (id)ic_firstItemIndexPath;
- (id)ic_lastItemIndexPath;
- (unsigned long long)ic_maxSectionItems;
- (unsigned long long)ic_numberOfItemsInAllSections;
- (_Bool)ic_numberOfItemsPerSectionEquals:(id)equals;
- (void)ic_reloadVisibleItems;

@end


@interface NSColor (ICAccessibility)

/* class methods */
+ (id)tintColor;
+ (id)ICBackgroundColor;
+ (id)ICControlAccentColor;
+ (id)ICFindInNoteHighlightColor;
+ (id)ICGroupedBackgroundColor;
+ (id)ICLearnMoreButtonPressedColor;
+ (id)ICLinkAcceleratorUnconfirmedColor;
+ (id)ICMentionUnconfirmedColor;
+ (id)ICMonostyledBorderColor;
+ (id)ICSelectedAttachmentBrickHighlightColor;
+ (id)ICUnknownInlineAttachmentTextColor;
+ (id)ICLearnMoreButtonUnpressedColor;
+ (id)ICBlockQuoteBackgroundColor;
+ (id)ICGrayTodoButtonColor;
+ (id)ICHashtagUnconfirmedColor;
+ (id)ICLearnMoreLinkColor;
+ (id)ICListStatusIndicatorColor;
+ (id)ICMonostyledBackgroundColor;
+ (id)ICTintColor;
+ (id)ic_attachmentBackgroundColor;
+ (id)ic_baseIconTintColor;
+ (id)ic_colorFromString:(id)string;
+ (id)ic_colorWith256Red:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
+ (id)ic_colorWith256Red:(double)red green:(double)green blue:(double)blue unitAlpha:(double)alpha;
+ (id)ic_darkerAccessibilityColorForColor:(id)color;
+ (id)ic_emphasisBackgroudColorFromColor:(id)color;
+ (id)ic_imageFromColor:(id)color size:(struct CGSize)size;
+ (id)ic_lightAttachmentBackgroundColor;
+ (id)ic_noteEditorBackgroundColor;
+ (id)ic_noteEditorLabelColor;
+ (id)ic_noteEditorPreviewColorForceLightContent:(_Bool)content;
+ (id)ic_noteEditorSecondaryLabelColor;
+ (id)ic_notePreviewBackgroundLightContent:(_Bool)content;
+ (id)ic_notesListSelectionColor;
+ (_Bool)ic_shouldUseNotesAccentColor;
+ (id)ic_systemGray2Color;
+ (id)ic_systemGray3Color;
+ (id)ic_systemGray4Color;
+ (id)ic_systemGray5Color;
+ (id)icaxHueNameForValue:(double)value;
+ (id)preferredDefaultFontColor;

/* instance methods */
- (id)icaxApproximateColorDescription;
- (double)icaxHue;
- (id)_icaxCachedApproximateColorDescription;
- (id)_icaxColorDescriptionForHue:(id)hue saturation:(id)saturation lightness:(id)lightness;
- (void)_icaxSetCachedApproximateColorDescription:(id)description;
- (id)ic_colorBlendedWithColor:(id)color;
- (id)ic_colorBlendedWithColor:(id)color fraction:(double)fraction;
- (id)ic_colorString;
- (_Bool)ic_isBlack;
- (_Bool)ic_isWhite;
- (id)icaxDescriptionWithLuma;
- (id)icaxHueName;
- (id)icaxLightnessModifier;
- (double)icaxLuma;
- (double)icaxSaturation;
- (id)icaxSaturationModifier;

@end


@interface NSError (ICCollaborationControllerRetryCloudKitOperations)

/* instance methods */
- (_Bool)ic_shouldRetryCloudKitError;

@end


@interface NSEvent (NSEvent_IC)

/* class methods */
+ (_Bool)ic_isCurrentEventTabOrBackTab;

/* instance methods */
- (unsigned short)ic_keyCharacter;
- (_Bool)ic_isTabPressed;
- (_Bool)ic_isCommandPressed;
- (_Bool)ic_isControlPressed;
- (_Bool)ic_isDeleteOrForwardDeletePressed;
- (_Bool)ic_isDeletePressed;
- (_Bool)ic_isDoubleClick;
- (_Bool)ic_isDownArrowPressed;
- (_Bool)ic_isEnterPressed;
- (_Bool)ic_isEscapePressed;
- (_Bool)ic_isForwardDeletePressed;
- (_Bool)ic_isLeftArrowPressed;
- (_Bool)ic_isOptionKeyPressed;
- (_Bool)ic_isOptionKeyPressedWithoutOtherModifiers;
- (_Bool)ic_isReturnEnterOrSpacePressed;
- (_Bool)ic_isReturnOrEnterPressed;
- (_Bool)ic_isReturnPressed;
- (_Bool)ic_isRightArrowPressed;
- (_Bool)ic_isShiftPressed;
- (_Bool)ic_isSpacePressed;
- (_Bool)ic_isUpArrowPressed;
- (_Bool)isKeyPressed:(unsigned short)pressed;
- (_Bool)isModifierPressed:(long long)pressed;

@end


@interface NSFont (IC)

/* class methods */
+ (id)ic_preferredFontForTitleTextWithContentSizeCategory:(id)category isForPrint:(_Bool)print;
+ (id)ic_fontDescriptorForSystemFontOfSize:(double)size useSingleLineA:(_Bool)a bold:(_Bool)bold;
+ (double)ic_fontSizeForHeaderImport;
+ (double)ic_fontSizeForSubheaderImport;
+ (id)ic_preferredFontAndLineHeight:(double *)height forAttachmentBoldTextWithZoomController:(id)controller;
+ (id)ic_preferredFontAndLineHeight:(double *)height forAttachmentRegularTextWithZoomController:(id)controller;
+ (id)ic_preferredFontForBodyText;
+ (id)ic_preferredFontForBodyTextWithContentSizeCategory:(id)category;
+ (id)ic_preferredFontForBodyTextWithContentSizeCategory:(id)category isForPrint:(_Bool)print;
+ (id)ic_preferredFontForBodyTextWithContentSizeCategory:(id)category useSingleLineA:(_Bool)a;
+ (id)ic_preferredFontForDateText;
+ (id)ic_preferredFontForDateTextWithZoomFactor:(double)factor;
+ (id)ic_preferredFontForFixedWidthText;
+ (id)ic_preferredFontForFixedWidthTextWithContentSizeCategory:(id)category;
+ (id)ic_preferredFontForHeadingText;
+ (id)ic_preferredFontForHeadingTextWithContentSizeCategory:(id)category;
+ (id)ic_preferredFontForHeadingTextWithContentSizeCategory:(id)category isForPrint:(_Bool)print;
+ (id)ic_preferredFontForSectionHeaders;
+ (id)ic_preferredFontForStyle:(id)style;
+ (id)ic_preferredFontForStyle:(unsigned int)style contentSizeCategory:(id)category isForPrint:(_Bool)print;
+ (id)ic_preferredFontForStyle:(id)style fontWeight:(double)weight;
+ (id)ic_preferredFontForStyle:(id)style symbolicTraits:(unsigned int)traits;
+ (id)ic_preferredFontForSubheadingText;
+ (id)ic_preferredFontForSubheadingTextWithContentSizeCategory:(id)category;
+ (id)ic_preferredFontForSubheadingTextWithContentSizeCategory:(id)category isForPrint:(_Bool)print;
+ (id)ic_preferredFontForTitleText;
+ (id)ic_preferredFontForTitleTextWithContentSizeCategory:(id)category;
+ (id)ic_preferredFontForTitleTextWithContentSizeCategory:(id)category isForPrint:(_Bool)print isReducedSize:(_Bool)size;
+ (double)ic_preferredPointSizeForDateTextWithZoomFactor:(double)factor maxZoomFactor:(double)factor;
+ (id)ic_preferredSingleLineAFontForTextStyle:(id)style;

/* instance methods */
- (double)lineHeight;
- (id)ic_fontByAddingSymbolicTraits:(unsigned int)traits;
- (id)ic_fontConvertedToSize:(double)size;
- (_Bool)ic_fontHasSingleLineA;
- (id)ic_fontScaledByFactor:(double)factor;
- (double)ic_fontWeight;
- (id)ic_fontWithRoundedDesign;
- (id)ic_fontWithSingleLineA;
- (id)ic_fontWithSize:(double)size;
- (id)ic_fontWithSymbolicBoldTrait;
- (id)ic_fontWithTabularNumbers;
- (id)ic_fontWithoutSingleLineA;
- (_Bool)ic_hasSymbolicBoldTrait;
- (_Bool)ic_hasSymbolicItalicTrait;
- (_Bool)ic_hasSymbolicTrait:(unsigned int)trait;

@end


@interface NSImage (IC)

/* class methods */
+ (id)ic_symbolsNeedingPrivateCatalog;
+ (struct CGRect)ic_aspectFitImageFrameForViewWithFrame:(struct CGRect)frame imageSize:(struct CGSize)size;
+ (void)ic_cacheSystemImages;
+ (id)ic_fileIconForURL:(id)url withPreferredSize:(struct CGSize)size;
+ (id)ic_hierarchicalSystemImageNamed:(id)named colors:(id)colors;
+ (id)ic_imageNamed:(id)named withTint:(id)tint;
+ (id)ic_imageNamed:(id)named withTint:(id)tint size:(struct CGSize)size;
+ (id)ic_imageWithCGImage:(struct CGImage *)cgimage;
+ (id)ic_imageWithCGImage:(struct CGImage *)cgimage scale:(double)scale orientation:(long long)orientation;
+ (id)ic_imageWithColor:(id)color size:(struct CGSize)size;
+ (id)ic_imageWithContentsOfURL:(id)url;
+ (id)ic_imageWithData:(id)data;
+ (id)ic_makeCircularImageWithColor:(id)color diameter:(double)diameter;
+ (id)ic_orientationMetadataFromImageOrientation:(long long)orientation;
+ (id)ic_orientedImageFromCGImage:(struct CGImage *)cgimage scale:(double)scale transform:(struct CGAffineTransform)transform;
+ (id)ic_orientedImageFromImage:(id)image fromOrientation:(long long)orientation;
+ (id)ic_orientedImageFromImage:(id)image toOrientation:(long long)orientation;
+ (id)ic_symbolGraphicNamed:(id)named size:(struct CGSize)size symbolColor:(id)color backgroundColor:(id)color;
+ (id)ic_symbolsNeedingUIAsset;
+ (id)ic_systemImageNamed:(id)named;
+ (id)ic_systemImageNamed:(id)named pointSize:(double)size;
+ (id)ic_systemImageNamed:(id)named systemSymbolFontPointSize:(double)size;
+ (id)ic_systemImageNamed:(id)named systemSymbolFontPointSize:(double)size fontWeight:(double)weight systemSymbolScale:(long long)scale;
+ (id)ic_systemImageNamed:(id)named systemSymbolFontPointSize:(double)size systemSymbolScale:(long long)scale;
+ (id)ic_systemImageNamed:(id)named usePrivateCatalog:(_Bool)catalog;
+ (id)imageNamed:(id)named withTint:(id)tint;

/* instance methods */
- (struct CGImage *)ic_CGImage;
- (id)ic_JPEGData;
- (id)ic_JPEGDataWithOrientation:(long long)orientation;
- (id)ic_PDFData;
- (id)ic_PNGData;
- (id)ic_PNGDataWithOrientation:(long long)orientation;
- (struct CGRect)ic_cropRectZeroAlpha;
- (id)ic_decodeInBackground;
- (void)ic_decodeWithCompletion:(id /* block */)completion;
- (id)ic_imageDataWithUTType:(id)uttype;
- (id)ic_imageDataWithUTType:(id)uttype metadata:(id)metadata;
- (id)ic_imageFlippedForRightToLeftLayoutDirection;
- (id)ic_imageFromRect:(struct CGRect)rect;
- (long long)ic_imageOrientation;
- (id)ic_imageScaledToMinSize:(struct CGSize)size;
- (id)ic_imageTintedWithColor:(id)color;
- (id)ic_imageWithBackgroundColor:(id)color;
- (id)ic_imageWithTint:(id)tint;
- (id)ic_imageWithTint:(id)tint size:(struct CGSize)size;
- (struct CGContext *)ic_newARGB8BitmapContextFromImage:(struct CGImage *)image;
- (id)ic_scaledImageMaxDimension:(double)dimension scale:(double)scale;
- (id)ic_scaledImageMinDimension:(double)dimension scale:(double)scale;
- (id)ic_scaledImageWithSize:(struct CGSize)size scale:(double)scale;

@end


@interface NSImageView (IC)

/* instance methods */
- (void)ic_setImageWithSystemImageName:(id)name symbolFont:(id)font symbolScale:(long long)scale;
- (void)replaceImageWith:(id)with;

@end


@interface NSLayoutConstraint (IC)

/* class methods */
+ (id)ic_constraintWithItem:(id)item attribute:(long long)attribute relatedBy:(long long)by toItem:(id)item attribute:(long long)attribute multiplier:(double)multiplier constant:(double)constant priority:(float)priority;
+ (id)ic_constraints:(id)ic_constraints affectingViews:(id)views;
+ (id)ic_widthLayoutConstraintsForView:(id)view minValue:(double)value;
+ (id)ic_widthLayoutConstraintsForView:(id)view minValue:(double)value maxValue:(double)value;

@end


@interface NSManagedObjectID (ItemIdentifier) <ICItemIdentifier>

@end


@interface NSMenu (IC)

/* class methods */
+ (id)ic_menuTitleForSharingSyncingObject:(id)object;

/* instance methods */
- (void)ic_popUpBelowView:(id)view extraSpacing:(struct CGPoint)spacing;
- (void)ic_addItems:(id)items;
- (void)ic_addNonNilItem:(id)item;
- (void)ic_popUpBelowView:(id)view;

@end


@interface NSMenuItem (IC)

/* class methods */
+ (id)ic_genericMenuItemWithTarget:(id)target title:(id)title action:(SEL)action icon:(long long)icon;

/* instance methods */
- (void)ic_copyTitleToGeneralPasteboard;
- (void)setIc_menuIcon:(long long)icon;
- (void)ic_copyTitleToPasteboard:(id)pasteboard;
- (id)ic_image;
- (long long)ic_menuIcon;

@end


@interface NSMutableAttributedString (IC_UI)

/* instance methods */
- (void)ic_convertParagraphStyleToBodyInRange:(struct _NSRange)range;
- (void)ic_addForegroundColorInRangesWhereNoColorAlreadyExists:(id)exists;
- (void)ic_addOrUpdateNSParagraphStyleAtRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)ic_addOrUpdateParagraphStyleAtRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)ic_addTextBlocks:(id)blocks range:(struct _NSRange)range;
- (void)ic_setFontHint:(unsigned int)hint atRange:(struct _NSRange)range;
- (void)ic_setParagraphStyleForWritingDirection:(long long)direction andAlignment:(_Bool)alignment;

@end


@interface NSNotification (NotesUI)

/* class methods */
+ (id)ICEditingTextViewWillSetMarkedTextNotificationMarkedTextKey;
+ (id)ICEditingTextViewWillSetMarkedTextNotification;
+ (id)ICEditingTextViewWillSetMarkedTextNotificationSelectedRangeKey;
+ (id)ICOutlineControllerCollapsedStateDidChange;

@end


@interface NSNumberFormatter (ICAccessibility)

/* class methods */
+ (id)icaxLocalizedDouble:(double)_double maximumNumberOfDigitsAfterDecimalSeparator:(unsigned long long)separator;
+ (id)icaxLocalizedNumber:(id)number maximumNumberOfDigitsAfterDecimalSeparator:(unsigned long long)separator;
+ (id)icaxLocalizedDouble:(double)_double;
+ (id)icaxLocalizedNumber:(id)number;
+ (id)icaxLocalizedNumber:(id)number numberStyle:(unsigned long long)style;
+ (id)icaxLocalizedNumber:(id)number numberStyle:(unsigned long long)style maximumNumberOfDigitsAfterDecimalSeparator:(unsigned long long)separator;
+ (id)icaxLocalizedPercentage:(double)percentage;
+ (id)icaxLocalizedPercentage:(double)percentage maximumNumberOfDigitsAfterDecimalSeparator:(unsigned long long)separator;
+ (id)icaxLocalizedUnsignedInteger:(unsigned long long)integer;

@end


@interface NSObject (ICAccessibility)

/* instance methods */
- (_Bool)icaxRespondsToSelector:(SEL)selector fromExtrasProtocol:(id)protocol;
- (id)icaxValueForKey:(id)key;
- (id)icaxValueForKeyPath:(id)path;

@end


@interface NSParagraphStyle (IC)

/* class methods */
+ (id)ic_mutableDefaultParagraphStyle;
+ (_Bool)ic_isRTL;

@end


@interface NSScreen (IC)

/* class methods */
+ (double)ic_scale;

@end


@interface NSString (ICLinguistics)

/* instance methods */
- (id)ic_guessedWords;

@end


@interface NSTableView (IC)

/* instance methods */
- (_Bool)ic_scrollToArrangedObject:(id)object arrayController:(id)controller animated:(_Bool)animated;

@end


@interface NSTextField (IC)

/* instance methods */
- (id)ic_stringValueDisplayAttributes;
- (id)ic_attributedStringFromStringValue;
- (double)ic_fittingHeight;
- (_Bool)ic_isFirstResponder;
- (_Bool)ic_isTruncated;

@end


@interface NSTextLayoutManager (IC)

/* instance methods */
- (struct _NSRange)ic_rangeForTextRange:(id)range;
- (struct CGRect)ic_rectForRange:(struct _NSRange)range;
- (id)ic_textRangeForRange:(struct _NSRange)range;

@end


@interface NSTextStorage (NotesUI)

/* instance methods */
- (id)paragraphUUIDsInRange:(struct _NSRange)range;

@end


@interface NSTextView (IC)

/* instance methods */
- (struct _NSRange)ic_visibleRange;
- (struct _NSRange)ic_characterRangeForRect:(struct CGRect)rect;
- (void)ic_discardMarkedText;
- (id)ic_imageForRange:(struct _NSRange)range;
- (id)ic_markedTextAttributes;
- (struct _NSRange)ic_markedTextRange;
- (struct CGRect)ic_rectForRange:(struct _NSRange)range;
- (void)ic_scrollRangeToVisible:(struct _NSRange)visible animated:(_Bool)animated completionHandler:(id /* block */)handler;
- (void)ic_scrollRectToVisible:(struct CGRect)visible animated:(_Bool)animated completionHandler:(id /* block */)handler;
- (id)ic_selectedRanges;
- (_Bool)ic_shouldEnableBlockQuoteForAttachmentsOnlySelection;
- (struct CGPoint)ic_textContainerOrigin;
- (id)ic_tk2ContentView;
- (void)setIc_selectedRanges:(id)ranges;

@end


@interface NSToolbar (IC)

/* instance methods */
- (_Bool)ic_containsItemWithIdentifier:(id)identifier;
- (unsigned long long)ic_indexOfItemWithIdentifier:(id)identifier;
- (void)ic_insertItemWithIdentifier:(id)identifier atIndex:(long long)index;
- (void)ic_insertItemsWithIdentifiers:(id)identifiers;
- (id)ic_itemWithIdentifier:(id)identifier;
- (_Bool)ic_removeItemWithIdentifier:(id)identifier;

@end


@interface NSView (IC)

/* class methods */
+ (void)ic_animateWithDuration:(double)duration animations:(id /* block */)animations;
+ (void)ic_animateWithDuration:(double)duration animations:(id /* block */)animations completion:(id /* block */)completion;
+ (void)ic_animateWithDuration:(double)duration timingFunction:(id)function animations:(id /* block */)animations completion:(id /* block */)completion;
+ (_Bool)ic_isRTL;
+ (void)ic_performWithoutAnimation:(id /* block */)animation;

/* instance methods */
- (struct CGRect)ic_contentFrame;
- (struct CGRect)ic_rectInScreen;
- (void)ic_addAnchorsToFillSuperview;
- (void)ic_addAnchorsToFillSuperviewLayoutMargins;
- (void)ic_addAnchorsToFillSuperviewWithPadding:(double)padding;
- (void)ic_addAnchorsToFillSuperviewWithPadding:(double)padding usesSafeAreaLayoutGuide:(_Bool)guide;
- (void)ic_addConstraintsToFillSuperview;
- (void)ic_addDidMoveToWindowHandler:(id /* block */)handler;
- (id)ic_animator;
- (id)ic_appearanceInfo;
- (id)ic_appearanceInfoForContent;
- (void)ic_applyRoundedCornersWithRadius:(double)radius;
- (void)ic_applyShadowWithRadius:(double)radius opacity:(double)opacity offset:(struct CGSize)offset;
- (id)ic_backgroundColor;
- (double)ic_backingScaleFactor;
- (_Bool)ic_becomeFirstResponder;
- (void)ic_bringSubviewToFront:(id)front;
- (_Bool)ic_containsFirstResponder;
- (struct CGRect)ic_contentBounds;
- (id)ic_firstConstraintWithAttribute:(long long)attribute;
- (void)ic_forceRenderSubviews;
- (double)ic_hairlineWidth;
- (void)ic_insertSubview:(id)subview belowSubview:(id)subview;
- (_Bool)ic_isFirstResponder;
- (_Bool)ic_isFrontSubview:(id)subview;
- (_Bool)ic_isOrContainsFirstResponder;
- (_Bool)ic_isRTL;
- (_Bool)ic_isVisible;
- (id)ic_platformAppearanceObject;
- (id)ic_renderImageFromViewBackingStore;
- (id)ic_renderImageFromViewBackingStoreWithScale:(double)scale;
- (id)ic_renderImageViewFromViewBackingStore;
- (void)ic_setAlpha:(double)alpha;
- (void)ic_setNeedsDisplay;
- (void)ic_setNeedsLayout;
- (id)ic_viewOrSuperviewOfClass:(Class)_class;
- (void)setIc_backgroundColor:(id)color;

@end


@interface NSViewController (IC)

/* class methods */
+ (id)loadFromNib;

/* instance methods */
- (_Bool)ic_applicationHasKeyWindow;
- (_Bool)ic_isViewVisible;

@end


@interface NSWindow (IC)

/* instance methods */
- (_Bool)ic_isFullScreen;
- (void)ic_cascadeIfNeededWithExistingWindows:(id)windows;
- (void)ic_endAttachedSheet;
- (double)ic_toolbarHeight;

@end


@interface PKDrawing (IC)

/* instance methods */
- (id)ic_drawingUUID;

@end


#endif /* NotesUI_h */
