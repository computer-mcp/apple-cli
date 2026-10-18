// Normalized full dump import surface for NotesEditor.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesEditor_h

#define NotesEditor_h



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

@import NotesUI;



@interface NSTokenAttachmentCell : NSObject

@end

@interface PKTextAttachmentDrawingView : NSObject

@end



struct CGPoint;

struct CGRect;

struct CGSize;

struct NSEdgeInsets;

struct _NSRange;



@class AVAsset, AVPlayerView, CALayer, CSSearchableItemAttributeSet, ICAbstractAttachmentViewController, ICAcceleratorDetectionResult, ICActivityStreamSelection, ICAppearanceInfo, ICAttachment, ICAttachmentBrickView, ICAttachmentGalleryModel, ICAttachmentInsertionController;

@class ICAttachmentSharingServicePickerController, ICAttachmentView, ICAttachmentViewController, ICAttachmentViewInteraction, ICAttributionLayoutManager, ICAttributionViewConfiguration, ICAttributionViewConfigurationSharedState, ICAttributionViewHighlightConfiguration, ICAttributionsUpdater, ICAudioAttachmentEditorCoordinatorBridge, ICAudioAttachmentView, ICAudioRecordingViewController;

@class ICAuthorHighlightsController, ICAuthorHighlightsUpdater, ICAutoCompleteSuggestionsItem, ICAutoCompleteSuggestionsTableCellImageView, ICAutoCompleteSuggestionsTableCellView, ICAutoCompleteSuggestionsTableView, ICAutoCompleteSuggestionsTableViewRowView, ICAutoCompleteSuggestionsTableViewScrollView, ICAutoCompleteSuggestionsViewController, ICAutoCompleteSuggestionsViewControllerWindow, ICBaseAttachmentView, ICBaseLayoutManager;

@class ICBrickTextAttachmentView, ICCalculatePreviewBehaviorMenu, ICCalculateRecognitionController, ICCalculateScrubberController, ICChecklistDragUtilities, ICChecklistInfo, ICCollaboratorAvatarView, ICCollaboratorSelectionView, ICCollaboratorStatusView, ICCollapsibleContainerView, ICCollapsibleImageView, ICDimensionSumCache;

@class ICDocCamScannedDocumentEditor, ICDrawingInlineAttachmentView, ICDrawingInlineView, ICFallbackPDFAttachmentView, ICHashtagController, ICImageAttachmentView, ICInlineAttachment, ICInlineAttachmentView, ICInlineAttachmentViewController, ICInlineTextAttachment, ICInlineTextFindingResult, ICIntentsUtilities;

@class ICInvitation, ICLayoutManager, ICLinkAcceleratorController, ICLoadingPieLayer, ICLockedTextAttachmentView, ICMAlertSheetTouchBarController, ICMAppTouchBarController, ICMAttachmentContentInspector, ICMAttachmentRenameWindowController, ICMAttachmentViewOnlyController, ICMAttachmentViewOnlyPopoverColorView, ICMAttachmentViewOnlyPopoverContainerView;

@class ICMAttachmentViewOnlyPopoverViewController, ICMAttributionsViewController, ICMBaseTouchBarController, ICMClickableTextView, ICMFilePromiseHelper, ICMForwardVerticalScrollEventsScrollView, ICMHashtagDebugViewController, ICMImageGalleryPrintController, ICMInvitationViewController, ICMLinkSuggestionsController, ICMNoteEditorCompatibilityBannerView, ICMNoteEditorController;

@class ICMNoteEditorDateView, ICMNoteEditorTouchBarController, ICMOverlayScrollView, ICMPasswordEntryViewController, ICMPrintController, ICMPrintPanelAccessoryController, ICMProgressWindowController, ICMSidebarController, ICMSidebarScrollView, ICMTK2NoteEditorController, ICMTableAccessibilityElement, ICMTableAccessibilityTextViewProxyElement;

@class ICMTableAttachmentTouchBarController, ICMTableCellGroupAccessibilityElement, ICMTableColumnAccessibilityElement, ICMTableRowAccessibilityElement, ICMTextStyleTouchBarBIUButton, ICMTextStylesCollectionView, ICMTextStylesTouchBar, ICMTextStylesTouchBarController, ICMTextViewFinderClient_Asynchronous, ICMTextViewFinderClient_Synchronous, ICMTypesetter, ICMUnsupportedNoteView;

@class ICMViewOnlyButton, ICMZoomController, ICMacBaseTextView, ICMacTableAttachmentView, ICMacTableAttachmentViewController, ICMacTextContainer, ICMacTextView, ICMacTextViewGestureRecognizerDelegate, ICMacTextViewPrintingUtilities, ICMacTextViewTodoItemProxyElement, ICManagedObjectContextChangeController, ICMentionsController;

@class ICMovieAttachmentView, ICMovieController, ICNAEventReporter, ICNAFindResultExposureReporter, ICNote, ICNoteBaseUserActivityState, ICNoteDateFormatterController, ICNoteEditorBaseViewController, ICNoteUserActivityState, ICOutlineController, ICOutlineRenderer, ICPDFAttachmentRenderOperation;

@class ICPDFAttachmentView, ICPaperCommonUtilities, ICPaperDocumentTextAttachment, ICPaperDocumentTextAttachmentView, ICPaperDocumentTextAttachmentViewProvider, ICPaperKitTextFindingResult, ICPaperMarkupController, ICPaperTextAttachmentManager, ICParagraphInfo, ICParagraphInfoSortInfo, ICPencilKitTextFindingResult, ICPrintableTableTextAttachment;

@class ICSearchResultRegexMatchFinder, ICSelectorDelayer, ICServicesRolloverView, ICSharedScrollClampingController, ICSharedWithYouController, ICSharedWithYouControllerInternal, ICSingleFileOpenPanelDelegate, ICSplitTableLayoutInformation, ICSystemPaperIndexableTextContentHelper, ICTK2InlineTextAttachmentViewProvider, ICTK2MacTextView, ICTK2TextAttachmentViewProvider;

@class ICTK2TextContainer, ICTK2TextController, ICTK2TextLayoutManager, ICTK2TextLayoutManagerDelegate, ICTK2TodoTextAttachment, ICTK2TodoTextAttachmentViewProvider, ICTTMergeableStringSelection, ICTTParagraphStyle, ICTTTextContentStorage, ICTTTextEdit, ICTTTextEditFilter, ICTTTextEditGrouper;

@class ICTTTextStorage, ICTable, ICTableAccessibilityController, ICTableAccessibilityElementProvider, ICTableAttachmentProvider, ICTableAttachmentSelection, ICTableAttachmentView, ICTableAttachmentViewController, ICTableAutoScroller, ICTableCellAccessibilityElement, ICTableClipView, ICTableColumnManager;

@class ICTableColumnNSLayoutManager, ICTableColumnRowButton, ICTableColumnRowButtonCell, ICTableColumnTextContainer, ICTableColumnTextStorage, ICTableColumnTextView, ICTableColumnWidthManager, ICTableContentView, ICTableLayoutManager, ICTableScrollView, ICTableSelectionKnob, ICTableSelectionView;

@class ICTableTextAttachment, ICTableTextFindingResult, ICTableTextViewManager, ICTableUndoTarget, ICTextAttachment, ICTextAttachmentLocationCache, ICTextAttachmentViewProvider, ICTextContentStorageDelegate, ICTextController, ICTextElementAnimator, ICTextElementLocator, ICTextFindingCoordinator;

@class ICTextFindingMatch, ICTextFindingResult, ICTextLayoutFragment, ICTextViewAccessibility, ICTextViewRenderingSurfaceView, ICTextViewScrollState, ICTodoButton, ICTrackedParagraph, ICTrackedParagraphImageInfo, ICTrackedParagraphTreeNode, ICVisualAssetImportController, LAUIAuthenticationViewController;

@class LinkEditorController, NSATSTypesetter, NSAccessibilityElement, NSBox, NSButton, NSButtonCell, NSCandidateListTouchBarItem, NSClickGestureRecognizer, NSColor, NSCustomTouchBarItem, NSDraggingSession, NSFont;

@class NSGlassView, NSImage, NSImageView, NSLayoutConstraint, NSLayoutManager, NSManagedObjectContext, NSManagedObjectID, NSMenu, NSMenuItem, NSPanel, NSPopUpButton, NSPopover;

@class NSPopoverTouchBarItem, NSPressGestureRecognizer, NSProgressIndicator, NSResponder, NSScrollView, NSSegmentedControl, NSSharingServicePicker, NSSplitViewItem, NSSplitViewItemAccessoryViewController, NSStackView, NSTableCellView, NSTableRowView;

@class NSTableView, NSTextAttachment, NSTextAttachmentViewProvider, NSTextContainer, NSTextContentStorage, NSTextField, NSTextFinder, NSTextHighlightShapeProvider, NSTextLayoutFragment, NSTextLayoutManager, NSTextParagraph, NSTextRange;

@class NSTextStorage, NSTextView, NSTokenField, NSTouchBar, NSTrackingArea, NSView, NSViewController, NSWindow, NSWindowController, PKDrawing, PKSearchQueryItem, SWAttributionView;

@class SWHighlight, _TtC11NotesEditor11LinkActions, _TtC11NotesEditor14LinkTokenField, _TtC11NotesEditor14TranscriptView, _TtC11NotesEditor15SummaryTextView, _TtC11NotesEditor16SummaryViewModel, _TtC11NotesEditor18RecordingViewModel, _TtC11NotesEditor19ICFeedbackExtension, _TtC11NotesEditor22ICPDFTextFindingResult, _TtC11NotesEditor23ICRecordButtonPresenter, _TtC11NotesEditor23ICRecordButtonViewModel, _TtC11NotesEditor23LinkTokenAttachmentCell;

@class _TtC11NotesEditor23OutlineDisclosureButton, _TtC11NotesEditor24ICMSystemPaperLinkHelper, _TtC11NotesEditor24ICRecordButtonAppFactory, _TtC11NotesEditor24ICRecordButtonRepository, _TtC11NotesEditor24LinkEditorViewController, _TtC11NotesEditor24TextCorrectionMarkerView, _TtC11NotesEditor24TranscriptViewController, _TtC11NotesEditor26ICSynapseContentItemsCache, _TtC11NotesEditor27PaperDocumentEngagementData, _TtC11NotesEditor28ICRecordButtonViewController, _TtC11NotesEditor28ICSystemPaperPreviewProvider, _TtC11NotesEditor29ICInlineDrawingFindResult_Mac;

@class _TtC11NotesEditor29LinkAcceleratorViewController, _TtC11NotesEditor32ICMSystemPaperLinkHelperDelegate, _TtC11NotesEditor32LinkAcceleratorHostingController, _TtC11NotesEditor32MacLinkAcceleratorViewController, _TtC11NotesEditor37PaperDocumentTextAttachmentHeaderView, _TtC11NotesEditorP33_0207DD35BB3512C3C1BFE341EADC3AD924SummaryViewModelObserver, _TtC8PaperKit27MarkupToolbarViewController, _TtCC11NotesEditor31PaperDocumentTextAttachmentView29ICPaperViewControllerDelegate, _TtCV11NotesEditor15AudioPlayerView20AudioPlayerViewModel;

@protocol DCDataCryptorDelegate, ICAccessibilityFocusedUIElementProvider, ICAttachmentFindable, ICAttachmentInsertionDelegate, ICAttachmentPresentationDelegate, ICAttachmentViewContentFrame, ICAttachmentViewControllerInitializing, ICAttachmentViewDelegate, ICAttachmentViewInitializing, ICAttachmentViewInteractionDelegate, ICAttachmentViewOpening, ICAudioRecordingViewControllerDelegate;

@protocol ICAutoCompleteSuggestionsTableViewDelegate, ICAutoCompleteSuggestionsViewControllerDelegate, ICAuxiliaryStyling, ICAuxiliaryTextViewHosting, ICAvailableTableWidthProviding, ICCRUndoDelegate, ICImageAttachmentPresentationDelegate, ICInlineAttachmentViewAnimationDelegate, ICLinkInsertionDelegate, ICMAppTouchBarControllerDelegate, ICMClickableTextViewDelegate, ICMFilePromiseHelperDelegate;

@protocol ICMHashtagDebugViewControllerDelegate, ICMPasswordEntryViewControllerDelegate, ICMProgressWindowControllerDelegate, ICMTableAttachmentTouchBarControllerDelegate, ICMTextStylesCollectionViewDelegate, ICMTextStylesTouchBarDelegate, ICMZoomControllerDelegate, ICMZoomableAttachmentView, ICMacTextViewEditorDelegate, ICManagedObjectContextChangeControllerDelegate, ICNoteDateFormatterControllerDelegate, ICNoteMergeObserver;

@protocol ICNoteViewContainer, ICPaperDocumentEngagementData, ICServicesRolloverViewDelegate, ICSupplementalView, ICSystemPaperTextAttachmentNotesEditorBridgeWorkaround, ICTTAttachment, ICTTModelAttributeComparable, ICTTTextStorageDelegate, ICTTTextStorageScrollClampingDelegate, ICTTTextUndoTarget, ICTableAttachmentProviderDelegate, ICTableAutoScrollerDelegate;

@protocol ICTableCellChangeObserving, ICTableColumnLayout, ICTableColumnTextViewDelegate, ICTableDelegate, ICTableSelectionDelegate, ICTableTextViewManagerDelegate, ICTableUndoHelping, ICTextControllerDelegate, ICTextFindingDataSource, ICTextPreviewProvider, ICTodoButtonDragDelegate, ICTrackedAttributeDelegate;

@protocol LAUIAuthenticationViewControllerDelegate, NSTextFinderAsynchronousDocumentFindMatch, NSTextLayoutManagerDelegatePrivate, NSTextViewportLayoutObserver, NSTokenTextFieldDelegation, PKTextAttachmentView, QLPreviewPanelDataSource, SWHighlightCenterDelegate, _TtP11NotesEditor19NSTextView_Internal_, _TtP11NotesEditor26ICMSystemPaperLinkDelegate_, _TtP11NotesEditor34PaperTextAttachmentManagerDelegate_, _TtP8PaperKit27PaperViewControllerDelegate_;

@protocol _TtP8PaperKit34PKPaperLinksViewControllerDelegate_;



@protocol DCDataCryptorDelegate <NSObject>

@required

/* required instance methods */
- (id)decryptEncryptedData:(id)data identifier:(id)identifier;
- (id)encryptData:(id)data identifier:(id)identifier;

@optional

@end


@protocol ICAccessibilityFocusedUIElementProvider <NSObject>

@required

/* required instance methods */
- (id)alternativeFocusedUIElement;

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


@protocol ICAttachmentInsertionDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)attachmentInsertionController:(id)controller didAddAttachment:(id)attachment atRange:(struct _NSRange)range;
- (void)attachmentInsertionController:(id)controller didAddInlineAttachment:(id)attachment atRange:(struct _NSRange)range textStorage:(id)storage;
- (void)attachmentInsertionController:(id)controller willAddAttachment:(id)attachment atRange:(struct _NSRange)range;
- (void)attachmentInsertionController:(id)controller willAddInlineAttachment:(id)attachment atRange:(struct _NSRange)range textStorage:(id)storage;

@end


@protocol ICAttachmentPresentationDelegate <NSObject>

@required

/* required instance methods */
- (id)attachment;
- (_Bool)isAttachmentEditable;
- (id)viewToPresentAttachmentFrom;

@optional

@end


@protocol ICAttachmentViewContentFrame

@required

/* required instance methods */
- (struct CGRect)frameForContent;

@optional

@end


@protocol ICAttachmentViewControllerInitializing <NSObject>

@required

/* required instance methods */
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager;

@optional

/* optional instance methods */
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager initialCharacterIndex:(unsigned long long)index;

@end


@protocol ICAttachmentViewDelegate

@required

/* required instance methods */
- (void)attachmentView:(id)view shouldShowAudioDetailViewForAttachment:(id)attachment animated:(_Bool)animated;

@optional

@end


@protocol ICAttachmentViewInitializing <NSObject>

@required

/* required instance methods */
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;

@optional

@end


@protocol ICAttachmentViewInteractionDelegate <NSObject>

@required

/* required instance methods */
- (void)attachmentViewInteractionDidPerformOpen:(id)open;
- (void)attachmentViewInteractionDidPerformSelect:(id)select;

@optional

/* optional instance methods */
- (_Bool)attachmentViewInteraction:(id)interaction canSelectAttachmentAtPoint:(struct CGPoint)point;
- (void)attachmentViewInteractionShouldPresentContextMenu:(id)menu;

@end


@protocol ICAttachmentViewOpening

@required

/* required instance methods */
- (void)openAttachment;

@optional

@end


@protocol ICAudioRecordingViewControllerDelegate <NSObject>

@required

@property (readonly, nonatomic) NSTextView *textView;

@optional

/* optional instance methods */
- (void)presentExportViewForAttachment:(id)attachment;
- (void)exportCallRecordingForDataCollectionForAttachment:(id)attachment;
- (void)presentCallRecordingExportViewForAttachment:(id)attachment;
- (void)presentSharingViewForAttachment:(id)attachment fromSourceView:(id)view;
- (void)recordingDetailViewShouldDismiss:(id)dismiss;
- (void)viewWasDismissed;

@end


@protocol ICAutoCompleteSuggestionsTableViewDelegate <NSObject>

@required

/* required instance methods */
- (void)tableViewDidConfirmSelection:(id)selection;

@optional

@end


@protocol ICAutoCompleteSuggestionsViewControllerDelegate <NSObject>

@required

/* required instance methods */
- (void)autoCompleteSuggestionsViewController:(id)controller didSelectItem:(id)item;

@optional

@end


@protocol ICAuxiliaryStyling <NSObject>

@required

@property (readonly, nonatomic) _Bool canStyleText;
@property (readonly, nonatomic) _Bool canToggleTodo;
@property (readonly, nonatomic) NSIndexSet *selectedStyles;
@property (readonly, nonatomic) unsigned long long selectedStyleBIUS;
@property (nonatomic) _Bool lockSelection;

/* required instance methods */
- (void)toggleUnderline:(id)underline;
- (void)toggleBoldface:(id)boldface;
- (void)toggleItalics:(id)italics;
- (void)enableBoldface:(id)boldface;
- (void)disableItalics:(id)italics;
- (void)indentByamount:(long long)byamount;
- (_Bool)canIndentByamount:(long long)byamount;
- (void)disableBoldface:(id)boldface;
- (void)disableStrikethrough:(id)strikethrough;
- (void)disableUnderline:(id)underline;
- (void)enableItalics:(id)italics;
- (void)enableStrikethrough:(id)strikethrough;
- (void)enableUnderline:(id)underline;
- (void)setSelectionAlignment:(long long)alignment;
- (void)setTextStyleForCurrentSelection:(unsigned int)selection;
- (void)toggleEmphasis:(id)emphasis onValue:(id)value;
- (void)toggleStrikethrough:(id)strikethrough;
- (void)toggleTodoStyle:(id)style;

@optional

@end


@protocol ICAuxiliaryTextViewHosting <NSObject>

@required

@property (weak, nonatomic) NSResponder *auxiliaryResponder;
@property (weak, nonatomic) id <ICAuxiliaryStyling> auxiliaryStylingController;

@optional

@end


@protocol ICAvailableTableWidthProviding <NSObject>

@required

@property (readonly, nonatomic) double availableWidth;

@optional

@end


@protocol ICCRUndoDelegate <NSObject>

@required

/* required instance methods */
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (_Bool)wantsUndoCommands;

@optional

@end


@protocol ICImageAttachmentPresentationDelegate <ICAttachmentPresentationDelegate>

@required

/* required instance methods */
- (id)attachmentImage;

@optional

@end


@protocol ICInlineAttachmentViewAnimationDelegate <NSObject>

@required

/* required instance methods */
- (void)redrawInlineAttachmentView:(id)view;
- (void)relayoutInlineAttachmentView:(id)view;

@optional

@end


@protocol ICLinkInsertionDelegate

@required

@property (nonatomic, readonly) long long writingDirection;
@property (nonatomic, readonly) _Bool languageHasSpaces;
@property (nonatomic, readonly) ICNote *note;
@property (nonatomic, readonly) NSTextView *textViewForAccelerator;
@property (nonatomic, readonly) NSString *searchString;
@property (nonatomic, readonly) NSView *acceleratorHostingView;
@property (nonatomic, readonly) NSViewController *acceleratorHostingViewController;
@property (nonatomic, readonly) ICNAEventReporter *eventReporter;
@property (nonatomic, readonly) ICAttachmentInsertionController *attachmentInsertionController;

@optional

/* optional instance methods */
- (void)removeLinksFromCurrentSelection;
- (void)acceleratorOriginNeedsUpdate;
- (void)createLink:(id)link title:(id)title textSelection:(id)selection textView:(id)view range:(struct _NSRange)range addApproach:(long long)approach;
- (void)createNoteLinkAttachment:(id)attachment textSelection:(id)selection textView:(id)view range:(struct _NSRange)range addApproach:(long long)approach;
- (void)didInsertLink:(long long)link textView:(id)view;
- (void)didSelectNoteSuggestionWithIdentifier:(id)identifier title:(id)title;
- (void)insertLinkAttachment:(id)attachment textView:(id)view range:(struct _NSRange)range addApproach:(long long)approach;
- (void)linkEditorDidDismiss:(id)dismiss;
- (void)removeLinksFromTextSelection:(id)selection textView:(id)view range:(struct _NSRange)range;

@end


@protocol ICMClickableTextViewDelegate <NSObject>

@required

/* required instance methods */
- (void)clickableTextViewDidClick:(id)click;

@optional

@end


@protocol ICMFilePromiseHelperDelegate <NSObject>

@required

/* required instance methods */
- (void)filePromiseHelper:(id)helper didRecieveFiles:(id)files dropPoint:(struct CGPoint)point;
- (void)filePromiseHelperDidCancel:(id)cancel;

@optional

@end


@protocol ICMHashtagDebugViewControllerDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)hashtagDebugViewController:(id)controller didEnterHashtagText:(id)text;

@end


@protocol ICMProgressWindowControllerDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)didTapCancelButtonInProgressWindowController:(id)controller;

@end


@protocol ICMTableAttachmentTouchBarControllerDelegate <NSObject>

@required

/* required instance methods */
- (id)currentStylesAndBIUS:(unsigned long long *)bius forTouchBarController:(id)controller;
- (void)touchBarController:(id)controller biuButtonPressedWithStyle:(unsigned long long)style toggleOn:(_Bool)on;

@optional

@end


@protocol ICMTextStylesCollectionViewDelegate <NSObject>

@required

@property (readonly, nonatomic) long long blockQuoteMenuItemState;
@property (readonly, nonatomic) long long currrentEmphasisType;

/* required instance methods */
- (_Bool)canSelectBlockQuoteInCollectionView:(id)view;
- (_Bool)textStylesCollectionView:(id)view canSelectNamedTextStyle:(id)style;
- (_Bool)textStylesCollectionView:(id)view canSelectStyleBIUS:(unsigned long long)bius;
- (void)textStylesCollectionView:(id)view shouldApplyNamedStyle:(id)style;
- (void)textStylesCollectionView:(id)view shouldApplyStyleBIUS:(unsigned long long)bius;
- (id)textStylesCollectionViewSelectedNamedStylesIndexSet:(id)set;
- (unsigned long long)textStylesCollectionViewSelectedStyleBIUS:(id)bius;
- (void)toggleBlockQuote;

@optional

@end


@protocol ICMTextStylesTouchBarDelegate

@required

/* required instance methods */
- (void)textStylesTouchBar:(id)bar didSelectStyle:(id)style sender:(id)sender;
- (void)toggleBlockQuote;

@optional

@end


@protocol ICMZoomControllerDelegate <NSObject>

@required

/* required instance methods */
- (void)didZoom:(id)zoom;

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


@protocol ICMacTextViewEditorDelegate <NSObject>

@required

/* required instance methods */
- (_Bool)isAutoCompletionViewVisible;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)returnToNoteBrowserIfPossible:(id)possible;
- (void)selectItemFromAutoCompletionMenu;
- (void)textViewDidEndFixUpAfterEditing:(id)editing;
- (void)textViewDidMouseDownWhileNotEditable:(id)editable;
- (void)textViewSelectionDidChange:(id)change stillSelecting:(_Bool)selecting;

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


@protocol ICNoteDateFormatterControllerDelegate <NSObject>

@required

/* required instance methods */
- (void)formatter:(id)formatter iconHiddenDidChange:(_Bool)change;
- (void)formatter:(id)formatter textDidChange:(id)change fullText:(id)text;

@optional

/* optional instance methods */
- (id)dateViewAttributes;
- (double)dateViewMaximumWidth;
- (void)formatter:(id)formatter iconImageDidChange:(id)change;

@end


@protocol ICNoteMergeObserver

@required

/* required instance methods */
- (void)textStorageDidPerformMerge:(id)merge;
- (void)textStorageWillPerformMerge:(id)merge;

@optional

@end


@protocol ICPaperDocumentEngagementData <NSObject>

@required

@property (readonly, nonatomic) NSString *attachmentIdentifier;
@property (readonly, nonatomic) _Bool hasActivity;
@property (readonly, nonatomic) long long startPageCount;
@property (readonly, nonatomic) long long endPageCount;
@property (readonly, nonatomic) long long startState;
@property (readonly, nonatomic) long long endState;
@property (readonly, nonatomic) _Bool hasSmallStateUsage;
@property (readonly, nonatomic) _Bool hasMediumStateUsage;
@property (readonly, nonatomic) _Bool hasLargeStateUsage;
@property (readonly, nonatomic) _Bool hasFullscreenStateUsage;
@property (readonly, nonatomic) _Bool hasGestures;
@property (readonly, nonatomic) _Bool hasScroll;
@property (readonly, nonatomic) _Bool hasPagination;
@property (readonly, nonatomic) _Bool hasPinchZoom;
@property (readonly, nonatomic) _Bool hasPinchToExpandState;
@property (readonly, nonatomic) _Bool hasCollabView;
@property (readonly, nonatomic) _Bool hasCollabEdit;

@optional

@end


@protocol ICServicesRolloverViewDelegate <NSObject>

@required

/* required instance methods */
- (id)pickerForRolloverCalloutView:(id)view;

@optional

@end


@protocol ICSupplementalView

@required

/* required instance methods */
- (id)viewIdentifier;

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


@protocol ICTTTextUndoTarget <NSObject>

@required

/* required instance methods */
- (void)applyUndoGroup:(id)group;

@optional

/* optional instance methods */
- (id)newCoalescingUndoGroup;

@end


@protocol ICTableAttachmentProviderDelegate <NSObject, ICTableDelegate, ICTTTextUndoTarget>

@required

/* required instance methods */
- (void)tableAttachmentSaveOnMainThread;

@optional

@end


@protocol ICTableAutoScrollerDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (void)tableAutoScroller:(id)scroller scrollOffsetDelta:(struct CGPoint)delta;
- (void)tableAutoScrollerWillStartScrolling:(id)scrolling;
- (void)tableAutoScrollerWillStopScrolling:(id)scrolling;

@end


@protocol ICTableCellChangeObserving <NSObject>

@required

/* required instance methods */
- (void)tableValueDidChangeAtColumnID:(id)id rowID:(id)id delta:(long long)delta;

@optional

@end


@protocol ICTableColumnLayout <NSObject>

@required

@property (readonly, weak, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (readonly, nonatomic) ICTableColumnTextStorage *columnTextStorage;
@property (readonly, nonatomic) NSTextContainer *textContainer;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (retain, nonatomic) NSArray *hiddenRows;

/* required instance methods */
- (void)ensureLayoutForCharacterRange:(struct _NSRange)range;
- (void)causeGlyphGenerationIfNecessaryForCharacterRange:(struct _NSRange)range;
- (void)ensureCellExistsAtRowID:(id)id;
- (double)heightOfCellAtRowID:(id)id;
- (void)invalidateLayoutForCharacterRange:(struct _NSRange)range;

@optional

@end


@protocol ICTableColumnTextViewDelegate <NSObject>

@required

@property (nonatomic) _Bool preventScrolling;
@property (readonly, nonatomic) _Bool isNoteEditable;

/* required instance methods */
- (id)account;
- (id)viewController;
- (id)note;
- (id)attachment;
- (_Bool)acceptsKeystrokes;
- (void)beginEditingSelectedRangeInTextView:(id)view;
- (_Bool)containedInNoteSelection;
- (void)didPasteOrDropTextForTableColumnTextView:(id)view;
- (void)extendCellRangeSelectionInDirection:(unsigned long long)direction toEnd:(_Bool)end;
- (struct CGRect)frameOfCellForColumnTextView:(id)view row:(id)row;
- (void)moveDownCell;
- (void)moveLeftCell;
- (void)moveNextCell;
- (void)movePrevCell;
- (void)moveReturnCell;
- (void)moveRightCell;
- (void)moveShiftReturnCell;
- (void)moveTabCell;
- (void)moveUpCell;
- (_Bool)pasteCellRange;
- (void)selectTable;
- (void)setNeedsSaveAfterUserEdit;
- (void)tappedTableAtLocation:(struct CGPoint)location;
- (void)updateColumnWidthForColumn:(id)column;

@optional

/* optional instance methods */
- (void)addColumnAfterSelection:(id)selection;
- (void)addColumnBeforeSelection:(id)selection;
- (void)addRowAboveSelection:(id)selection;
- (void)addRowBelowSelection:(id)selection;
- (void)clearAutoCompletionView;
- (void)currentRowSelected;
- (_Bool)isAutoCompletionViewVisible;
- (void)mouseUpOnTextView:(id)view;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)selectCell;
- (void)textView:(id)view mouseDown:(id)down;
- (id)textView:(id)view selectedRanges:(id)ranges withLocation:(struct CGPoint)location stillSelecting:(_Bool)selecting;

@end


@protocol ICTableDelegate <ICCRUndoDelegate>

@required

@optional

/* optional instance methods */
- (void)tableDidInsertColumnID:(id)id;
- (void)tableWillRemoveColumnID:(id)id;
- (void)tableDidCreateColumnTextStorage:(id)storage;
- (void)tableDidPopulateCellAtColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;

@end


@protocol ICTableSelectionDelegate <NSObject>

@required

@property (readonly, weak, nonatomic) id <ICAuxiliaryStyling> auxiliaryStylingController;

/* required instance methods */
- (void)deleteSelection:(id)selection;
- (void)copySelection:(id)selection;
- (void)cutSelection:(id)selection;
- (_Bool)acceptsKeystrokes;
- (void)extendCellRangeSelectionInDirection:(unsigned long long)direction toEnd:(_Bool)end;
- (void)pasteIntoSelection:(id)selection;
- (void)selectionDidResignFirstResponder:(id)responder;
- (void)selectionWillBecomeFirstResponder:(id)responder;

@optional

/* optional instance methods */
- (void)addColumnAfterSelection:(id)selection;
- (void)addColumnBeforeSelection:(id)selection;
- (void)addRowAboveSelection:(id)selection;
- (void)addRowBelowSelection:(id)selection;
- (id)beginEditingForSelectionView:(id)view;

@end


@protocol ICTableTextViewManagerDelegate <NSObject>

@required

@property (readonly, nonatomic) ICMacBaseTextView *noteTextView;

/* required instance methods */
- (void)setupTableTextView:(id)view;

@optional

@end


@protocol ICTableUndoHelping

@required

@property (readonly, nonatomic) ICTableUndoTarget *undoTarget;
@property (readonly, nonatomic) NSUndoManager *undoManager;
@property (retain, nonatomic) ICTableAttachmentSelection *tableSelection;
@property (readonly, nonatomic) _Bool shouldPreventUndoCommands;
@property (readonly, nonatomic) NSMapTable *coalescingUndoGroupForStringDelegate;

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


@protocol ICTextFindingDataSource <NSObject>

@required

/* required instance methods */
- (id)textView;
- (id)note;

@optional

@end


@protocol ICTextPreviewProvider <NSObject>

@required

/* required instance methods */
- (void)imageForTextPreviewUsingFindingResult:(id)result inTextView:(id)view completion:(id /* block */)completion;

@optional

@end


@protocol ICTodoButtonDragDelegate <NSObject>

@required

/* required instance methods */
- (void)todoButtonDidDrag:(id)drag;

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


@protocol LAUIAuthenticationViewControllerDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (id)localizedSubTitleForMechanisms:(unsigned long long)mechanisms;
- (void)cancelAuthentication;
- (void)authAttemptFailed;
- (void)authenticationDidSuccceed;
- (_Bool)cmdEnterOrReturnPressed;
- (_Bool)evaluateAppPassword:(id)password;

@end


@protocol NSTextFinderAsynchronousDocumentFindMatch <NSObject>

@required

@property (readonly, retain, nonatomic) NSView *containingView;
@property (readonly, retain, nonatomic) NSArray *textRects;

/* required instance methods */
- (void)generateTextImage:(id /* block */)image;

@optional

@end


@protocol NSTextLayoutManagerDelegatePrivate <NSTextLayoutManagerDelegate>

@required

@optional

/* optional instance methods */
- (id)textLayoutManager:(id)manager attributedStringForTruncatedRange:(id)range defaultAttributedString:(id)string;
- (id)textLayoutManager:(id)manager textHighlightAttributesForTextRange:(id)range highlightStyle:(id)style;
- (id)textLayoutManager:(id)manager textHighlightRenderingAttributesForTextRange:(id)range attributes:(id)attributes;

@end


@protocol NSTextViewportLayoutObserver <NSObject>

@required

@optional

/* optional instance methods */
- (void)textViewportLayoutControllerWillLayout:(id)layout;
- (void)textViewportLayoutController:(id)controller configureRenderingSurfaceForTextLayoutFragment:(id)fragment;
- (void)textViewportLayoutControllerDidLayout:(id)layout;
- (void)textViewportLayoutController:(id)controller didLayoutTextViewportElement:(id)element;

@end


@protocol NSTokenTextFieldDelegation

@required

@optional

/* optional instance methods */
- (id)tokenField:(id)field _immediateActionAnimationControllerForRepresentedObject:(id)object inTextView:(id)view;
- (id)tokenField:(id)field setUpTokenAttachmentCell:(id)cell forRepresentedObject:(id)object;
- (id)tokenField:(id)field tooltipStringForRepresentedObject:(id)object;

@end


@protocol PKTextAttachmentView <NSObject>

@required

@optional

/* optional instance methods */
- (void)drawingDataDidChange:(id)change;
- (void)resetZoom;

@end


@protocol QLPreviewPanelDataSource

@required

/* required instance methods */
- (id)previewPanel:(id)panel previewItemAtIndex:(long long)index;
- (long long)numberOfPreviewItemsInPreviewPanel:(id)panel;

@optional

@end


@protocol SWHighlightCenterDelegate <NSObject>

@required

/* required instance methods */
- (void)highlightCenterHighlightsDidChange:(id)change;

@optional

@end


@protocol _TtP11NotesEditor19NSTextView_Internal_

@required

@optional

/* optional instance methods */
- (id)_dragSelectionWithGesture:(id)gesture slideBack:(_Bool)back;

@end


@protocol _TtP11NotesEditor26ICMSystemPaperLinkDelegate_

@required

/* required instance methods */
- (void)addSystemPaperLink:(id)link;
- (void)updateLinkAvailability:(_Bool)availability;
- (void)userActivitiesToExcludeWithCompletion:(id /* block */)completion;

@optional

@end


@protocol _TtP11NotesEditor34PaperTextAttachmentManagerDelegate_

@required

/* required instance methods */
- (void)paperTextAttachmentManager:(id)manager beginTrackingUndoManager:(id)manager;
- (void)paperTextAttachmentManager:(id)manager endTrackingUndoManager:(id)manager;

@optional

@end


@protocol _TtP8PaperKit27PaperViewControllerDelegate_

@required

@optional

/* optional instance methods */
- (void)paperDidScroll:(id)scroll;
- (id)decryptData:(id)data;
- (void)invalidated:(id)invalidated;
- (void)openLink:(id)link;
- (void)paperBounds:(id)bounds;
- (void)paperDidFailToLoad:(id)load error:(id)error;
- (void)paperDidSave:(id)save;
- (void)paperIsInDrawingMode:(id)mode;
- (void)receiveMulticastData:(id)data;
- (void)reportDidChangeSelection:(id)selection;
- (void)reportMathExpressions:(id)expressions;

@end


@protocol _TtP8PaperKit34PKPaperLinksViewControllerDelegate_

@required

/* required instance methods */
- (void)paperLinksViewController:(id)controller didSelectSynapseLinkItem:(id)item;
- (id)paperLinksViewControllerExcludedUserActivities:(id)activities;

@optional

/* optional instance methods */
- (void)paperLinksViewControllerLinksMightHaveChanged:(id)changed;

@end


@interface ICAbstractAttachmentViewController : NSViewController

@property (readonly, nonatomic) _Bool isInResponderChain;
@property (readonly) _Bool forManualRendering;
@property (nonatomic) double foregroundAlpha;
@property (copy, nonatomic) NSColor *highlightColor;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;

/* instance methods */
- (void)contentSizeCategoryDidChange;
- (void)prepareForPrinting;
- (void)zoomFactorOrInsetsDidChange;

@end


@interface ICAcceleratorDetectionResult : NSObject

/* instance methods */
- (id)init;

@end


@interface ICAttachmentSharingServicePickerController : NSObject <NSGestureRecognizerDelegate, NSSharingServicePickerDelegate, NSSharingServiceDelegate, ICServicesRolloverViewDelegate>

@property (weak, nonatomic) NSView *view;
@property (retain, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) ICServicesRolloverView *servicesRolloverView;
@property (nonatomic) struct CGSize rolloverViewInset;
@property (readonly, nonatomic) NSSharingServicePicker *sharingServicePicker;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)pickerForRolloverCalloutView:(id)view;
- (void)sharingService:(id)service didShareItems:(id)items;
- (struct CGRect)sharingService:(id)service sourceFrameOnScreenForShareItem:(id)item;
- (id)sharingService:(id)service sourceWindowForShareItems:(id)items sharingContentScope:(long long *)scope;
- (id)sharingService:(id)service transitionImageForShareItem:(id)item contentRect:(struct CGRect *)rect;
- (id)sharingServicePicker:(id)picker delegateForSharingService:(id)service;
- (id)sharingServicePicker:(id)picker sharingServicesForItems:(id)items mask:(unsigned long long)mask proposedSharingServices:(id)services;
- (id)initWithView:(id)view attachment:(id)attachment;
- (id)initWithView:(id)view attachment:(id)attachment rolloverViewInset:(struct CGSize)inset;
- (id)rolloverView;
- (void)setupForMarkup;

@end


@interface ICAttachmentView : ICBaseAttachmentView <NSAccessibilityImage, NSGestureRecognizerDelegate, ICAttachmentViewInteractionDelegate, ICAttachmentViewContentFrame, ICAttachmentViewInitializing, ICAttachmentViewOpening>

@property (readonly, nonatomic) NSString *icaxAttachmentViewTypeDescription;
@property (readonly, nonatomic) NSString *icaxTypeDescription;
@property (readonly, nonatomic) _Bool shouldIncludeAttachmentTitleInAXLabel;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) NSWindow *actionWindow;
@property (readonly, nonatomic) ICMacBaseTextView *editingTextView;
@property (retain, nonatomic) ICAttachmentSharingServicePickerController *sharingServicePickerController;
@property (retain, nonatomic) ICMAttachmentViewOnlyController *viewOnlyController;
@property (retain, nonatomic) NSDraggingSession *draggingSession;
@property (retain, nonatomic) ICAttachmentViewInteraction *attachmentViewInteraction;
@property (retain, nonatomic) ICServicesRolloverView *icaxServicesRolloverView;
@property (readonly, nonatomic) NSSharingServicePicker *icaxSharingServicePicker;
@property (readonly, weak, nonatomic) NSTextContainer *textContainer;
@property (weak, nonatomic) id <ICAttachmentViewDelegate> delegate;
@property (weak, nonatomic) ICMacTextView *textView;
@property (readonly) _Bool forManualRendering;
@property (readonly, nonatomic) _Bool insideSystemPaper;
@property (nonatomic) _Bool finishedInit;

/* instance methods */
- (id)accessibilityLabel;
- (void)setupConstraints;
- (id)previewPanel:(id)panel previewItemAtIndex:(long long)index;
- (void)endPreviewPanelControl:(id)control;
- (long long)numberOfPreviewItemsInPreviewPanel:(id)panel;
- (_Bool)isAccessibilityElement;
- (_Bool)acceptsPreviewPanelControl:(id)control;
- (void)dealloc;
- (id)menuForEvent:(id)event;
- (id)accessibilityIdentifier;
- (id)accessibilityRole;
- (void)beginPreviewPanelControl:(id)control;
- (id)initWithCoder:(id)coder;
- (_Bool)accessibilityPerformPress;
- (_Bool)accessibilityPerformShowMenu;
- (id)accessibilityRoleDescription;
- (id)accessibilitySubrole;
- (void)resetCursorRects;
- (void)_performStandardShareMenuItem:(id)item;
- (void)didChangeAttachment;
- (void)didChangeMedia;
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (struct CGRect)frameForContent;
- (void)_selectAttachmentViewWithPoint:(struct CGPoint)point flags:(unsigned long long)flags;
- (_Bool)alertAboutUnsupportedAttachmentIfNecessary;
- (_Bool)attachmentViewInteraction:(id)interaction canSelectAttachmentAtPoint:(struct CGPoint)point;
- (void)attachmentViewInteractionDidPerformOpen:(id)open;
- (void)attachmentViewInteractionDidPerformSelect:(id)select;
- (struct CGRect)boundsToUseForCursorRect;
- (void)changeCreationDate:(id)date;
- (void)changeModificationDate:(id)date;
- (void)copyUUID:(id)uuid;
- (void)didChooseAttachmentViewSize:(id)size;
- (void)didChoosePlainLink:(id)link;
- (void)didTapAttachment:(id)attachment;
- (void)divergeCryptoKey:(id)key;
- (void)icaxActivate;
- (void)icaxShowServicesMenu;
- (id)initWithAttachment:(id)attachment textContainer:(id)container actionWindow:(id)window;
- (id)initWithFrame:(struct CGRect)frame textAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)inspectAttachment:(id)attachment;
- (void)macPresentReportAConcernFor:(id)_for withPositiveFeedback:(_Bool)feedback withVC:(id)vc;
- (void)openAttachment;
- (void)openAttachmentInPreview;
- (void)prepareForPrinting;
- (void)regeneratePreview:(id)preview;
- (void)reportNegativeConcern:(id)concern;
- (void)reportPositiveConcern:(id)concern;
- (void)selectAttachmentView:(id)view;
- (void)selectAttachmentViewWithGestureRecognizer:(id)recognizer;
- (void)setupEventHandling;
- (void)setupForMarkup;
- (void)sharedInit:(_Bool)init;
- (void)updatePreferredAttachmentViewSize:(short)size;

@end


@interface ICAttachmentViewController : ICAbstractAttachmentViewController <ICAttachmentViewControllerInitializing>

@property (nonatomic) _Bool forManualRendering;
@property (readonly, weak, nonatomic) NSLayoutManager *layoutManager;
@property (readonly, weak, nonatomic) NSTextLayoutManager *textLayoutManager;
@property (readonly, weak, nonatomic) ICAttachment *attachment;
@property (weak, nonatomic) ICTextAttachment *textAttachment;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)_canShowWhileLocked;
- (void)loadView;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)initWithCoder:(id)coder;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering textLayoutManager:(id)manager;

@end


@interface ICAttachmentViewInteraction : NSObject <NSGestureRecognizerDelegate>

/* instance methods */
- (_Bool)gestureRecognizer:(id)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)recognizer;
- (_Bool)gestureRecognizer:(id)recognizer shouldBeRequiredToFailByGestureRecognizer:(id)recognizer;
- (id)initWithDelegate:(id)delegate;
- (id)removeFromView;
- (_Bool)gestureRecognizer:(id)recognizer shouldRequireFailureOfGestureRecognizer:(id)recognizer;
- (id)init;
- (_Bool)gestureRecognizer:(id)recognizer shouldAttemptToRecognizeWithEvent:(id)event;
- (void)doubleClick:(id)click;
- (void)immediatePress:(id)press;
- (void)addToView:(id)view;
- (void)press:(id)press;
- (void)singleClick:(id)click;

@end


@interface ICAttributionLayoutManager : NSObject

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic) NSArray *viewConfigurations;
@property (readonly, nonatomic) NSArray *visibleConfigurations;
@property (retain, nonatomic) ICTTTextEditGrouper *editGrouper;
@property (nonatomic) double currentTextViewOffset;
@property (nonatomic) double appliedHorizontalAdjustment;
@property (readonly, copy, nonatomic) NSDate *noteLastOpenedDate;
@property (readonly, weak, nonatomic) ICMacBaseTextView *textView;
@property (copy, nonatomic) ICTTTextEditFilter *filter;
@property (nonatomic) double panelWidth;
@property (nonatomic) double previewPanelWidth;
@property (nonatomic) double visiblePanelWidth;
@property (copy, nonatomic) NSNumber *overrideZoomFactor;
@property (readonly, nonatomic) double appliedHorizontalAdjustmentRatio;
@property (readonly, nonatomic) double preferredHighlightValue;
@property (copy, nonatomic) id /* block */ updatedConfigurationHandler;

/* class methods */
+ (id)reloadQueue;

/* instance methods */
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)scrollBoundsDidChange:(id)change;
- (void)removeObservers;
- (void)addObservers;
- (id)initWithTextView:(id)view managedObjectContext:(id)context panelWidth:(double)width previewPanelWidth:(double)width;
- (void)reloadConfigurationsWithCompletion:(id /* block */)completion;
- (void)reloadViewConfigurationsSynchronously;
- (void)updateViewConfigurationsForTextViewOffset;

@end


@interface ICAttributionViewConfiguration : NSObject <NSCopying>

@property (nonatomic) struct CGRect associatedTextFrame;
@property (copy, nonatomic) NSAttributedString *attribution;
@property (retain, nonatomic) id attributionTextStorage;
@property (copy, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSDate *explicitTimestamp;
@property (copy, nonatomic) NSAttributedString *formattedTimestamp;
@property (copy, nonatomic) NSAttributedString *formattedTimestampForAccessibility;
@property (retain, nonatomic) id formattedTimestampTextStorage;
@property (copy, nonatomic) NSImage *statusImage;
@property (retain, nonatomic) NSMutableArray *highlightConfigurations;
@property (readonly, nonatomic) NSString *attributionUserID;
@property (readonly, nonatomic) NSOrderedSet *userIDs;
@property (readonly, nonatomic) NSArray *unreadUserIDs;
@property (nonatomic) _Bool forceVisible;
@property (nonatomic) _Bool dataLoaded;
@property (readonly, nonatomic) ICAttributionViewConfigurationSharedState *sharedState;
@property (readonly, nonatomic) NSArray *editGroups;
@property (readonly, nonatomic) ICTTTextEdit *textEdit;
@property (readonly, nonatomic) struct _NSRange range;
@property (readonly, nonatomic) struct _NSRange trimmedRange;
@property (readonly, nonatomic) struct CGRect attributionFrame;
@property (readonly, nonatomic) struct CGRect formattedTimestampFrame;
@property (readonly, nonatomic) struct CGRect disclosureImageFrame;
@property (readonly, copy, nonatomic) NSImage *disclosureImage;
@property (readonly, nonatomic) struct CGRect statusImageFrame;
@property (nonatomic) struct CGRect frame;
@property (nonatomic) struct CGRect adjustedFrame;
@property (nonatomic) struct CGRect adjustedFormattedTimestampFrame;
@property (nonatomic) double appliedHorizontalAdjustmentRatio;
@property (nonatomic) double preferredHighlightValue;
@property (nonatomic) _Bool forcesAttributionHidden;
@property (readonly, nonatomic) _Bool isAttributionHidden;
@property (nonatomic) _Bool forcesTimestampHidden;
@property (readonly, nonatomic) _Bool isTimestampHidden;
@property (readonly, nonatomic) _Bool isDisclosureImageHidden;
@property (readonly, nonatomic) _Bool isStatusImageHidden;
@property (nonatomic) _Bool preview;
@property (nonatomic) _Bool focused;
@property (nonatomic) _Bool blurred;
@property (readonly, nonatomic) NSArray *childConfigurations;
@property (weak, nonatomic) ICAttributionViewConfiguration *parentConfiguration;

/* class methods */
+ (id)loadDataQueue;

/* instance methods */
- (_Bool)isFocused;
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (void)updateTimestamp;
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)isPreview;
- (unsigned long long)hash;
- (id)initWithConfiguration:(id)configuration;
- (void)loadDataWithCompletion:(id /* block */)completion;
- (void)addEditGroup:(id)group;
- (void)commonInitWithSharedState:(id)state range:(struct _NSRange)range;
- (void)drawStatusImageInContext:(struct CGContext *)context canvasSize:(struct CGSize)size;
- (id)editGroupForRange:(struct _NSRange)range;
- (_Bool)hasValidRange;
- (id)initWithSharedState:(id)state editGroups:(id)groups parentConfiguration:(id)configuration;
- (id)initWithSharedState:(id)state textEdit:(id)edit parentConfiguration:(id)configuration;
- (_Bool)isBlurred;
- (_Bool)isDataLoaded;
- (_Bool)isEqualToAttributionViewConfiguration:(id)configuration;
- (struct CGRect)rectForRange:(struct _NSRange)range;
- (void)synchronouslyLoadData;
- (void)updateAttribution;
- (void)updateAttributionTextStorage;
- (void)updateChildConfigurations;
- (void)updateFormattedTimestampTextStorage;
- (void)updateFrames;
- (void)updateHighlightAlpha;
- (void)updateHighlightFrames;
- (void)updateStatusImage;
- (void)updateUnreadUserIDs;

@end


@interface ICAttributionViewConfigurationSharedState : NSObject

@property (copy, nonatomic) NSFont *primaryFont;
@property (retain, nonatomic) id primaryFontStorage;
@property (copy, nonatomic) NSFont *secondaryFont;
@property (retain, nonatomic) id secondaryFontStorage;
@property (copy, nonatomic) NSImage *expandedDisclosureImage;
@property (copy, nonatomic) NSImage *collapsedDisclosureImage;
@property (retain, nonatomic) NSMutableDictionary *userIDToHighlightColor;
@property (retain, nonatomic) NSMutableDictionary *userIDToShortName;
@property (readonly, weak, nonatomic) ICMacBaseTextView *textView;
@property (readonly, nonatomic) ICNote *note;
@property (readonly, nonatomic) ICTTTextStorage *noteTextStorage;
@property (copy, nonatomic) NSDate *noteLastOpenedDate;
@property (nonatomic) double panelWidth;
@property (nonatomic) _Bool isRTL;
@property (nonatomic) double topTextViewInset;
@property (nonatomic) double zoomFactor;

/* instance methods */
- (void)updateFonts;
- (void)updateImages;
- (id)highlightColorForUserID:(id)id;
- (id)disclosureImageWithSymbolName:(id)name;
- (id)initWithTextView:(id)view note:(id)note;
- (_Bool)isTimestampUnread:(id)unread forUserID:(id)id;
- (id)shortNameForUserID:(id)id;
- (void)synchronouslyLoadDataForEditGroups:(id)groups;
- (void)updateFontStorages;
- (void)updateHighlightColorsForUserIDs:(id)ids;
- (void)updateShortNamesForUserIDs:(id)ids;

@end


@interface ICAttributionViewHighlightConfiguration : NSObject <NSCopying>

@property (copy, nonatomic) NSString *identifier;
@property (nonatomic) struct CGRect frame;
@property (nonatomic) struct CGRect adjustedFrame;
@property (copy, nonatomic) NSColor *color;
@property (nonatomic) double alpha;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)isEqualToICAttributionViewHighlightConfiguration:(id)configuration;

@end


@interface ICAttributionsUpdater : NSObject

@property (nonatomic, readonly) ICAttributionLayoutManager *layoutManager;
@property (nonatomic) _Bool isSidebarHidden;

/* class methods */
+ (double)sidebarClosedRenderDelay;
+ (double)sidebarOpenedRenderDelay;

/* instance methods */
- (id)init;

@end


@interface ICAudioAttachmentEditorCoordinatorBridge : NSObject

@end


@interface ICAudioAttachmentView : ICAttachmentView

@property (nonatomic, retain) ICAttachment *attachment;
@property (nonatomic, retain) NSColor *highlightColor;
@property (nonatomic, readonly) NSObject *icaxAudioPlayerViewAccessibilityElement;

/* instance methods */
- (void)viewDidMoveToSuperview;
- (id)accessibilityLabel;
- (id)accessibilityCustomActions;
- (id)accessibilityValue;
- (id)menuForEvent:(id)event;
- (id)accessibilityUserInputLabels;
- (id)initWithCoder:(id)coder;
- (void)viewDidMoveToWindow;
- (id)accessibilityCustomContent;
- (void)saveAttachment:(id)attachment;
- (void)_performStandardShareMenuItem:(id)item;
- (void)deleteAttachment:(id)attachment;
- (void)didChangeMedia;
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (id)_playerViewAccessibilityElement;
- (void)appendRecording:(id)recording;
- (id)initWithFrame:(struct CGRect)frame textAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)viewSummary:(id)summary;

@end


@interface ICAudioRecordingViewController : NSObject

/* class methods */
+ (_Bool)presentedViewControllerIsAudio:(id)audio;
+ (id)audioAttachmentInsideViewController:(id)controller;
+ (void)containerViewDidResize:(id)resize;
+ (id)getHostingViewForAttachmentModel:(id)model delegate:(id)delegate;
+ (id)getHostingViewForAttachmentModel:(id)model delegate:(id)delegate autoStartRecording:(_Bool)recording;

/* instance methods */
- (id)init;

@end


@interface ICAuthorHighlightsUpdater : NSObject

@property (nonatomic, retain) NSValue *focusedRangeValue;
@property (nonatomic, readonly) NSValue *highlightedRangeValue;
@property (nonatomic, readonly) ICAuthorHighlightsController *authorHighlightsController;
@property (nonatomic, readonly) ICTK2TextLayoutManager *textLayoutManager;
@property (nonatomic) double highlightedValue;
@property (nonatomic, retain) ICTTTextEditFilter *filter;
@property (nonatomic, readonly) _Bool showsCollaboratorStatuses;
@property (nonatomic, retain) ICSearchResultRegexMatchFinder *searchHighlightRegexFinder;
@property (nonatomic, readonly) _Bool hasHighlights;
@property (nonatomic, readonly) _Bool didScheduleUpdate;
@property (nonatomic) _Bool updatesVisibleRangesOnly;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)updateAnimated:(_Bool)animated;
- (void)flashHighlightsForFilter:(id)filter;
- (void)flashHighlightsForRanges:(id)ranges inTextStorage:(id)storage;
- (id)initWithAuthorHighlightsController:(id)controller textLayoutManager:(id)manager;
- (void)noteShowsCollaboratorCursorsDidChange:(id)change;
- (void)scheduleUpdateAnimated:(_Bool)animated;
- (void)scheduleUpdateAnimated:(_Bool)animated force:(_Bool)force;
- (void)updateAnimated:(_Bool)animated force:(_Bool)force;

@end


@interface ICAutoCompleteSuggestionsTableCellImageView : ICCollapsibleImageView

/* instance methods */
- (id)accessibilityLabel;
- (_Bool)isAccessibilityElement;
- (_Bool)allowsVibrancy;
- (id)appearance;
- (id)accessibilityRoleDescription;
- (_Bool)wantsLayer;

@end


@interface ICAutoCompleteSuggestionsTableCellView : NSTableCellView

@property (weak, nonatomic) NSTextField *label;
@property (weak, nonatomic) ICCollapsibleImageView *iconView;
@property (weak, nonatomic) ICCollapsibleContainerView *collapsibleRightLabelContainer;
@property (weak, nonatomic) NSTextField *rightLabel;
@property (weak, nonatomic) NSLayoutConstraint *rightLabelMinWidthConstraint;
@property (retain, nonatomic) ICAutoCompleteSuggestionsItem *item;
@property (nonatomic) double rightLabelWidth;

/* instance methods */
- (void)prepareForReuse;
- (_Bool)allowsVibrancy;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)awakeFromNib;
- (_Bool)isSelectable;
- (_Bool)wantsLayer;
- (void)updateToMatchItem:(id)item;

@end


@interface ICAutoCompleteSuggestionsTableView : NSTableView

@property (weak, nonatomic) id <ICAutoCompleteSuggestionsTableViewDelegate> autoCompleteSuggestionsTableViewDelegate;

/* instance methods */
- (void)tap:(id)tap;
- (void)mouseExited:(id)exited;
- (_Bool)canBecomeKeyView;
- (_Bool)allowsVibrancy;
- (void)mouseDragged:(id)dragged;
- (_Bool)acceptsFirstResponder;
- (_Bool)acceptsFirstMouse:(id)mouse;
- (void)awakeFromNib;
- (void)mouseMoved:(id)moved;
- (void)selectRowForEvent:(id)event;

@end


@interface ICAutoCompleteSuggestionsTableViewRowView : NSTableRowView

@property (nonatomic) _Bool isHeaderRow;

/* instance methods */
- (_Bool)isEmphasized;
- (_Bool)allowsVibrancy;
- (_Bool)isGroupRowStyle;
- (void)drawBackgroundInRect:(struct CGRect)rect;
- (_Bool)wantsLayer;

@end


@interface ICMOverlayScrollView : NSScrollView

@property (retain, nonatomic) NSTrackingArea *mouseEnteredExitedTrackingArea;
@property (nonatomic) _Bool flashesScrollersOnMouseMoved;
@property (nonatomic) _Bool forceOverlayScrollers;

/* instance methods */
- (void)dealloc;
- (void)mouseMoved:(id)moved;
- (long long)scrollerStyle;
- (void)setScrollerStyle:(long long)style;

@end


@interface ICAutoCompleteSuggestionsTableViewScrollView : ICMOverlayScrollView

@end


@interface ICAutoCompleteSuggestionsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, ICAutoCompleteSuggestionsTableViewDelegate>

@property (weak, nonatomic) ICAutoCompleteSuggestionsTableView *tableView;
@property (weak, nonatomic) ICAutoCompleteSuggestionsTableViewScrollView *scrollView;
@property (weak, nonatomic) NSGlassView *glassView;
@property (weak, nonatomic) NSLayoutConstraint *scrollViewHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *visualEffectLeadingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *visualEffectTopConstraint;
@property (weak, nonatomic) NSLayoutConstraint *visualEffectTrailingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *visualEffectBottomConstraint;
@property (nonatomic) _Bool isEmptyState;
@property (weak, nonatomic) id <ICAutoCompleteSuggestionsViewControllerDelegate> delegate;
@property (copy, nonatomic) NSArray *items;
@property (nonatomic) double maxHeight;
@property (readonly, nonatomic) double heightForContent;
@property (retain, nonatomic) NSWindow *window;
@property (retain, nonatomic) NSDictionary *customTableViewNibs;
@property (readonly, nonatomic) _Bool isVisible;
@property (readonly, nonatomic) long long selectedRow;
@property (nonatomic) _Bool showDividerAfterFirstRow;
@property (nonatomic) _Bool hasNotesSectionHeader;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)windowDidResignKey:(id)key;
- (void)viewDidLoad;
- (void)reset;
- (_Bool)shouldShowSectionHeaders;
- (_Bool)acceptsFirstResponder;
- (void)tableView:(id)view didAddRowView:(id)view forRow:(long long)row;
- (void)hide;
- (long long)numberOfRowsInTableView:(id)view;
- (void)showForView:(id)view;
- (double)tableView:(id)view heightOfRow:(long long)row;
- (_Bool)tableView:(id)view isGroupRow:(long long)row;
- (id)tableView:(id)view rowViewForRow:(long long)row;
- (_Bool)tableView:(id)view shouldSelectRow:(long long)row;
- (id)tableView:(id)view viewForTableColumn:(id)column row:(long long)row;
- (void)showForView:(id)view width:(double)width offset:(struct CGPoint)offset isRTL:(_Bool)rtl;
- (void)adjustScrollViewHeightConstraintIfNecessary;
- (struct CGRect)autoCompleteWindowFrameForView:(id)view width:(double)width offset:(struct CGPoint)offset isRTL:(_Bool)rtl;
- (_Bool)confirmSelectionIfPossible;
- (_Bool)confirmSelectionInTableView:(id)view;
- (void)ensureConsistentWidthForRightLabelIfNecessary;
- (struct CGRect)insetRect:(struct CGRect)rect withInsets:(struct NSEdgeInsets)insets;
- (void)loadCustomTableViewNibsIfNecessary;
- (void)presentWindow:(_Bool)window offset:(struct CGPoint)offset view:(id)view width:(double)width;
- (_Bool)selectItemIfPossible:(id)possible;
- (_Bool)selectNextValidRowIfPossible;
- (_Bool)selectPreviousValidRowIfPossible;
- (_Bool)shouldShowDivider;
- (void)showForView:(id)view width:(double)width;
- (void)showForView:(id)view width:(double)width offset:(struct CGPoint)offset;
- (void)showPlaceholder:(id)placeholder forView:(id)view width:(double)width offset:(struct CGPoint)offset;
- (void)tableViewDidConfirmSelection:(id)selection;

@end


@interface ICAutoCompleteSuggestionsViewControllerWindow : NSPanel

@property (readonly, nonatomic) _Bool shouldShowDivider;
@property (readonly, nonatomic) _Bool shouldShowSectionHeaders;

/* instance methods */
- (_Bool)isOpaque;
- (_Bool)canBecomeKeyWindow;
- (void)awakeFromNib;
- (unsigned long long)shadowOptions;

@end


@interface ICBrickTextAttachmentView : ICAttachmentView <ICMZoomableAttachmentView>

@property (retain, nonatomic) ICAttachmentBrickView *attachmentBrickView;
@property (retain, nonatomic) ICMZoomController *zoomController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)setupConstraints;
- (void)setHighlightColor:(id)color;
- (void)dealloc;
- (id)accessibilityValueDescription;
- (void)cacheDisplayInRect:(struct CGRect)rect toBitmapImageRep:(id)rep;
- (void)updateCornerRadius;
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (void)setHighlightPatternRegexFinder:(id)finder;
- (void)didChangeAttachment;
- (void)didChangeAttachmentTitle;
- (void)hostViewDidZoom:(id)zoom;
- (id)imageForPrinting;
- (id)icaxTypeDescription;
- (void)prepareForPrinting;
- (void)requestAttachmentContentUpdate;
- (void)sharedInit:(_Bool)init;

@end


@interface ICChecklistDragUtilities : NSObject

/* class methods */
+ (struct CGRect)insertionRectForTrackedTodoParagraph:(id)paragraph drawAbove:(_Bool)above inTextView:(id)view;
+ (_Bool)shouldDropAboveForTrackedTodoParagraph:(id)paragraph forPoint:(struct CGPoint)point textView:(id)view;
+ (unsigned long long)tabIndentationEqualivantForString:(id)string;

@end


@interface ICChecklistInfo : NSObject

@property (nonatomic) unsigned long long numberOfItems;
@property (nonatomic) unsigned long long numberOfCheckedItems;
@property (nonatomic) unsigned long long numberOfUncheckedItems;

@end


@interface ICCollaboratorAvatarView : NSView

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSColor *color;
@property (nonatomic, readonly) NSView *boundingSuperview;
@property (nonatomic) struct CGPoint frameAnchorPoint;
@property (nonatomic) _Bool frameAnchorIsInverted;
@property (nonatomic) _Bool isExpanded;

/* class methods */
+ (double)animationDuration;
+ (double)contentHeight;
+ (double)animationSpringDamping;

/* instance methods */
- (void)mouseExited:(id)exited;
- (void)mouseEntered:(id)entered;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)viewDidMoveToWindow;
- (void)removeFromSuperviewAnimatedWithCompletion:(id /* block */)completion;
- (void)setIsExpanded:(_Bool)expanded animated:(_Bool)animated;
- (void)updateWithoutAnimation;

@end


@interface ICCollaboratorSelectionView : NSImageView

/* instance methods */
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;

@end


@interface ICCollaboratorStatusView : NSView

@property (nonatomic, readonly) _Bool flipped;

/* instance methods */
- (_Bool)isFlipped;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)viewDidMoveToWindow;

@end


@interface ICDocCamScannedDocumentEditor : NSObject

@property (retain, nonatomic) ICAttachment *galleryAttachment;
@property (readonly, nonatomic) ICAttachmentGalleryModel *galleryModel;
@property (retain, nonatomic) NSUndoManager *undoManager;

/* instance methods */
- (void)applyFilter:(short)filter forAttachmentAtIndex:(unsigned long long)index;
- (void)applyFilter:(short)filter forAttachmentWithIdentifier:(id)identifier;
- (void)deletePagesAtIndexes:(id)indexes;
- (unsigned long long)indexForAttachmentWithIdentifier:(id)identifier;
- (id)initWithGalleryAttachment:(id)attachment;
- (_Bool)moveObjectWithIdentifier:(id)identifier toIndex:(unsigned long long)index;
- (void)movePageFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)saveAndUpdatePreview:(_Bool)preview;
- (void)setMarkupData:(id)data forAttachmentWithIdentifier:(id)identifier;
- (_Bool)setOrientation:(long long)orientation forAttachment:(id)attachment;
- (void)setOrientation:(long long)orientation forAttachmentAtIndex:(unsigned long long)index;
- (void)setQuad:(id)quad forAttachment:(id)attachment;
- (void)setQuad:(id)quad forAttachmentWithIdentifier:(id)identifier;
- (id)subAttachmentWithIdentifier:(id)identifier;
- (void)undeleteSubAttachment:(id)attachment;
- (void)undoablyDeleteSubAttachments:(id)attachments actionName:(id)name;
- (void)undoablyMoveAttachmentWithIdentifier:(id)identifier toIndex:(unsigned long long)index;
- (void)undoablySetOrientation:(long long)orientation forAttachmentIdentifier:(id)identifier;
- (void)undoablySetQuad:(id)quad forAttachment:(id)attachment;
- (void)undoablyUndeleteSubAttachments:(id)attachments actionName:(id)name;
- (void)undoablyUpdateTitle:(id)title forAttachmentWithIdentifier:(id)identifier isUserDefined:(_Bool)defined;
- (void)updateDocumentTitle:(id)title isUserDefined:(_Bool)defined;
- (_Bool)updateTitle:(id)title forSubAttachment:(id)attachment;

@end


@interface ICDrawingInlineAttachmentView : ICAttachmentView

@property (retain, nonatomic) ICDrawingInlineView *drawingInlineView;
@property (readonly, nonatomic) struct CGRect boundsForDisplay;

/* instance methods */
- (void)setFrame:(struct CGRect)frame;
- (void)dealloc;
- (id)accessibilityHelp;
- (void)setAttachment:(id)attachment;
- (_Bool)cancelDidScrollIntoVisibleRange;
- (void)didChangeSize;
- (void)didScrollIntoVisibleRange;
- (void)didScrollOutOfVisibleRange;
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)setAttachmentContentSize:(struct CGSize)size;
- (void)didTapAttachment:(id)attachment;
- (id)icaxTypeDescription;
- (void)sharedInit:(_Bool)init;
- (_Bool)shouldAddPanGesture;
- (_Bool)shouldIncludeAttachmentTitleInAXLabel;

@end


@interface ICDrawingInlineView : NSView <ICImageAttachmentPresentationDelegate>

@property (nonatomic) _Bool fullscreen;
@property (retain, nonatomic) CALayer *imageLayer;
@property (nonatomic) _Bool forManualRendering;
@property (copy, nonatomic) id /* block */ imageLoadingCancelBlock;
@property (readonly, nonatomic) _Bool hasImage;
@property (nonatomic) _Bool needsToUpdateImage;
@property (retain, nonatomic) ICSelectorDelayer *previewImageUpdateDelayer;
@property (weak, nonatomic) ICLoadingPieLayer *loadingProgressLayer;
@property (readonly, nonatomic) NSColor *drawingBackgroundColor;
@property (readonly, nonatomic) _Bool shouldUseLightDrawingBackground;
@property (nonatomic) _Bool thumbnailDisplay;
@property (nonatomic) _Bool hideLoadingProgress;
@property (nonatomic) _Bool editable;
@property (nonatomic) _Bool showGotoNote;
@property (nonatomic) struct CGSize attachmentContentSize;
@property (nonatomic) _Bool isInAttachmentBrowser;
@property (retain, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) struct CGRect imageFrame;
@property (readonly, nonatomic) struct CGRect boundsForDisplay;
@property (retain, nonatomic) NSColor *borderColor;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)commonInit;
- (_Bool)isEditable;
- (void)setFrame:(struct CGRect)frame;
- (void)viewDidChangeEffectiveAppearance;
- (void)viewDidChangeBackingProperties;
- (void)updateLayer;
- (_Bool)isFlipped;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)previewImage;
- (id)attachmentImage;
- (void)attachmentPreviewImagesDidUpdate:(id)update;
- (_Bool)isReadyToPresent;
- (_Bool)cancelDidScrollIntoVisibleRange;
- (void)didScrollIntoVisibleRange;
- (void)didScrollOutOfVisibleRange;
- (void)animateImageArrivalWithAnimationDuration:(double)duration;
- (void)attachmentPreviewDidStart:(id)start;
- (void)delayedPreviewImageChanged;
- (id)initWithFrame:(struct CGRect)frame forManualRendering:(_Bool)rendering;
- (_Bool)isAttachmentEditable;
- (_Bool)isVisibleWithinScrollView;
- (void)observePreviewGenerationProgress:(id)progress;
- (void)updateBorderWidth;
- (void)updateImageWithAnimation:(_Bool)animation;
- (void)updateLayerImage:(id)image animation:(_Bool)animation;
- (id)viewToPresentAttachmentFrom;

@end


@interface ICPDFAttachmentView : ICAttachmentView

@property (weak, nonatomic) NSOperation *renderOperation;
@property (retain, nonatomic) NSProgressIndicator *progressView;
@property (retain) ICSelectorDelayer *startProgressSelectorDelayer;
@property (nonatomic) _Bool isManaullyGeneratingImage;
@property (retain, nonatomic) NSImage *image;
@property (nonatomic) _Bool rendering;
@property (readonly, nonatomic) _Bool availableImageIsAcceptable;
@property (readonly, nonatomic) struct CGPDFPage * page;

/* class methods */
+ (id)renderingQueue;

/* instance methods */
- (void)viewDidChangeBackingProperties;
- (void)setHighlightColor:(id)color;
- (void)dealloc;
- (void)startProgress;
- (void)viewDidMoveToWindow;
- (id)accessibilityHelp;
- (void)setAttachment:(id)attachment;
- (void)setFrameSize:(struct CGSize)size;
- (_Bool)isRendering;
- (void)stopProgress;
- (_Bool)cancelDidScrollIntoVisibleRange;
- (void)didChangeMedia;
- (void)didScrollIntoVisibleRange;
- (void)didScrollOutOfVisibleRange;
- (id)pdfURL;
- (_Bool)cancelRenderingIfPossible;
- (void)cleanupPDFDocument;
- (id)icaxTypeDescription;
- (id)initWithFrame:(struct CGRect)frame textAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (_Bool)needToStartRender;
- (void)prepareForPrinting;
- (void)setupBorderForLayer:(id)layer;
- (void)startImageRenderIfNeeded;
- (void)updateLayerContentsWithFade:(_Bool)fade;

@end


@interface ICFallbackPDFAttachmentView : ICPDFAttachmentView

/* instance methods */
- (id)pdfURL;
- (_Bool)needToStartRender;

@end


@interface ICImageAttachmentView : ICAttachmentView

@property (retain) CALayer *imageLayer;
@property (weak, nonatomic) NSImage *image;
@property (nonatomic) _Bool shouldUpdateLayoutInImageDidLoad;
@property (nonatomic) _Bool shouldTryToReloadImageIfLoadingFails;
@property (copy, nonatomic) id /* block */ imageLoadingCancelBlock;
@property (readonly, nonatomic) NSImage *placeholderImage;
@property (nonatomic) _Bool shouldShowLoadingImage;
@property (retain, nonatomic) NSView *loadingImageView;
@property (readonly, nonatomic) _Bool isThumbnailView;

/* class methods */
+ (id)ICLoadingPlaceholderBackgroundColor;
+ (double)ICLoadingPlaceholderIconSize;
+ (id)ICLoadingPlaceholderIconColor;

/* instance methods */
- (void)setFrame:(struct CGRect)frame;
- (struct CGSize)imageSize;
- (void)setHighlightColor:(id)color;
- (void)updateLayer;
- (void)dealloc;
- (id)accessibilityHelp;
- (struct CGRect)imageFrame;
- (_Bool)cancelDidScrollIntoVisibleRange;
- (void)didChangeAttachment;
- (void)didChangeMedia;
- (void)didScrollIntoVisibleRange;
- (void)didScrollOutOfVisibleRange;
- (void)didUpdatePreviewImages;
- (id)imageForPrinting;
- (void)updateImageSize;
- (struct CGRect)frameForContent;
- (void)animateImageArrival;
- (id)icaxTypeDescription;
- (id)imageContentsGravity;
- (void)imageDidLoad:(id)load shouldFade:(_Bool)fade;
- (_Bool)isAttachmentEditable;
- (void)prepareForPrinting;
- (void)refreshLoadingImage;
- (void)setShowLoadingImage:(_Bool)image;
- (void)setupBorderForLayer:(id)layer;
- (void)setupImagePlaceholder;
- (void)setupImagePlaceholderIfNecessary;
- (void)sharedInit:(_Bool)init;
- (_Bool)shouldIncludeAttachmentTitleInAXLabel;
- (_Bool)showLoadingImage;
- (void)updateImageInView:(_Bool)view;
- (void)updateImageInViewIfNecessary;

@end


@interface ICInlineAttachmentViewController : ICAbstractAttachmentViewController <ICAttachmentFindable, ICInlineAttachmentViewAnimationDelegate, ICAttachmentViewControllerInitializing>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (nonatomic) _Bool forManualRendering;
@property (weak, nonatomic) NSLayoutManager *layoutManager;
@property (nonatomic) unsigned long long initialCharIndex;
@property (readonly, nonatomic) NSTextContainer *displayTextTextContainer;
@property (readonly, nonatomic) NSLayoutManager *displayTextLayoutManager;
@property (readonly, nonatomic) NSTextStorage *displayTextTextStorage;
@property (nonatomic) struct _NSRange selectedSearchRange;
@property (readonly, weak, nonatomic) ICInlineAttachment *attachment;
@property (weak, nonatomic) ICInlineTextAttachment *textAttachment;

/* instance methods */
- (_Bool)_canShowWhileLocked;
- (void)loadView;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)initWithCoder:(id)coder;
- (struct _NSRange)attachmentRange;
- (id)rectsForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)scrollToRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setHighlightPatternRegexFinder:(id)finder;
- (void)drawCharactersInRange:(struct _NSRange)range inFindableString:(id)string forContentView:(id)view;
- (void)redrawInlineAttachmentView:(id)view;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string inFindableString:(id)string;
- (struct _NSRange)selectedRangeWithinRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setSelectedRange:(struct _NSRange)range inFindableString:(id)string;
- (id)viewForRange:(struct _NSRange)range inFindableString:(id)string;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager initialCharacterIndex:(unsigned long long)index;
- (id)inlineAttachmentView;
- (void)layoutWithStyleAttributesOfCharacterIndex:(unsigned long long)index;
- (void)relayoutInlineAttachmentView:(id)view;
- (void)updateDisplayTextTextStorage;

@end


@interface ICTextFindingResult : NSObject

@property (nonatomic) struct _NSRange range;
@property (nonatomic) _Bool attachmentResult;

/* instance methods */
- (long long)compare:(id)compare;
- (id)containingViewInTextView:(id)view;
- (id)framesForHighlightInTextView:(id)view;
- (_Bool)isAttachmentResult;
- (void)scrollToVisibleInTextView:(id)view;
- (void)selectInTextView:(id)view;

@end


@interface ICInlineTextFindingResult : ICTextFindingResult

@property (weak, nonatomic) ICInlineAttachment *attachment;
@property (retain, nonatomic) NSAttributedString *findableString;
@property (nonatomic) struct _NSRange displayTextRange;

/* instance methods */
- (long long)compare:(id)compare;
- (id)framesForHighlightInTextView:(id)view;
- (void)imageUsingPreviewProvider:(id)provider inTextView:(id)view completion:(id /* block */)completion;
- (id)inlineAttachmentViewControllerInTextView:(id)view;
- (id)inlineTextAttachmentViewProviderInTextView:(id)view;

@end


@interface ICIntentsUtilities : NSObject

/* class methods */
+ (void)donateInteraction:(id)interaction;
+ (id)interactionForAppendToNote:(id)note withAppendedText:(id)text;
+ (id)interactionForCreateNote:(id)note;
+ (id)interactionForDeleteNote:(id)note;
+ (id)interactionForSearchString:(id)string;

@end


@interface ICLayoutManager : ICBaseLayoutManager <ICTodoButtonDragDelegate, ICTrackedAttributeDelegate>

@property (retain, nonatomic) NSMutableDictionary *todoButtonsByTrackingUUID;
@property (nonatomic) struct CGPoint cachedOrigin;
@property (retain, nonatomic) NSMutableDictionary *activeSupplementalViews;
@property (retain, nonatomic) NSMutableDictionary *hiddenSupplementalViews;
@property (retain, nonatomic) NSMutableDictionary *supplementalViewControllers;
@property (retain, nonatomic) ICTextAttachmentLocationCache *inlineAttachmentLocationCache;
@property (retain, nonatomic) NSMutableDictionary *supplementalViewProviders;
@property (nonatomic) struct CGSize cachedTextContainerSize;
@property (retain, nonatomic) ICSelectorDelayer *updateHiddenViewsSelectorDelayer;
@property (retain, nonatomic) NSMutableDictionary *delayedScrollOutViewDictionary;
@property (retain, nonatomic) NSManagedObjectContext *workerContext;
@property (retain, nonatomic) NSSet *hiddenTodosForManualLayout;
@property (nonatomic) _Bool isZooming;
@property (nonatomic) _Bool isUpdatingForAttachmentViewTypeChange;
@property (nonatomic) _Bool lineHeightIncludeParagraphSpacing;
@property (nonatomic) _Bool shouldManuallyRenderSeparateSubviews;
@property (nonatomic) _Bool shouldAdjustTodoButtonFramesForPrinting;
@property (nonatomic) _Bool isRenderingPreviewForDragAndDrop;
@property (nonatomic) _Bool shouldIgnoreCachedOriginUpdates;
@property (nonatomic) _Bool isRenderingImageForPrint;
@property (copy, nonatomic) NSDictionary *trackedToDoParagraphs;
@property (weak, nonatomic) id <ICAttachmentViewDelegate> attachmentViewDelegate;
@property (nonatomic) _Bool isDraggingChecklistItem;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (nonatomic) double checklistZoomFactor;
@property (nonatomic) _Bool needsClearRemovedAttachments;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)linkAttributesForLink:(id)link forCharacterAtIndex:(unsigned long long)index;
- (id)textView;
- (id)init;
- (void)setTextView:(id)view;
- (void)dealloc;
- (struct CGRect)boundingRectForGlyphRange:(struct _NSRange)range inTextContainer:(id)container;
- (void)drawGlyphsForGlyphRange:(struct _NSRange)range atPoint:(struct CGPoint)point;
- (void)enumerateLineFragmentsForGlyphRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)replaceTextStorage:(id)storage;
- (id)textContainerForGlyphAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (void)textStorage:(id)storage edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length invalidatedRange:(struct _NSRange)range;
- (void)fillBackgroundRectArray:(const struct CGRect *)array count:(unsigned long long)count forCharacterRange:(struct _NSRange)range color:(id)color;
- (void)textContainerChangedGeometry:(id)geometry;
- (void)contentSizeCategoryDidChange;
- (void)attachmentDidLoad:(id)load;
- (void)icReplaceTextStorage:(id)storage;
- (void)mediaDidLoad:(id)load;
- (void)textController:(id)controller addedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller removedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller updatedTrackedAttribute:(id)attribute;
- (id)viewForTextAttachmentNoCreate:(id)create;
- (void)clearRemovedAttachmentsIfNeeded;
- (id)editingTextView;
- (void)cleanupStaleTodoButtonsAndUpdateSupplementalViewsForDictionary:(id)dictionary;
- (void)_clearRemovedAttachments;
- (void)attachmentInlineDrawingMergeableDataDidChange:(id)change;
- (void)cleanUpAfterScreenshot;
- (void)cleanupStaleTodoButtons;
- (void)clearAllSupplementalViews;
- (void)clearAllTodoSupplementalViews;
- (void)clearAllTodos;
- (void)clearSupplementalViewForIdentifier:(id)identifier;
- (void)clearViewForTextAttachment:(id)attachment;
- (void)clearViewsForAllTextAttachmentsThatSupportThumbnailMode;
- (void)didAddViewForTextAttachment:(id)attachment;
- (void)didPressTodoButton:(id)button;
- (void)drawGlyphsForGlyphRange:(struct _NSRange)range atPoint:(struct CGPoint)point updateAttachments:(_Bool)attachments;
- (id)drawTodoViewForListRange:(struct _NSRange)range paragraphStyle:(id)style checkmarkHighlightValue:(id)value atPoint:(struct CGPoint)point;
- (void)ensureViewIsAddedForAttachment:(id)attachment inCharacterRange:(struct _NSRange)range;
- (void)enumerateAttachmentViewsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)filterAttachmentsInTextStorage:(id)storage range:(struct _NSRange)range targetAttachment:(id)attachment;
- (id)glyphIndexesForMatchesInTextStorage:(id)storage regexFinder:(id)finder glyphRange:(struct _NSRange)range;
- (void)handleTodoButtonPress:(id)press;
- (void)hideSupplementalView:(id)view forIdentifier:(id)identifier;
- (void)hideVisibleTodoButtons;
- (id)icTextView;
- (id)icaxTodoButtonForParagraphStyle:(id)style;
- (id)initForTemporaryProcessing:(_Bool)processing;
- (void)invalidateLayoutAfterAttachmentViewTypeChange;
- (void)invalidateLayoutAfterAttachmentViewTypeChangeIfNecessary;
- (void)invalidateLayoutForAttachment:(id)attachment;
- (void)layoutViewForInlineTextAttachment:(id)attachment atCharacterIndex:(unsigned long long)index;
- (unsigned long long)lineCountForCharacterRange:(struct _NSRange)range;
- (struct CGRect)lineRectForRange:(struct _NSRange)range;
- (void)manuallyRenderSubviewsForCharacterRange:(struct _NSRange)range;
- (id)paragraphStyleForCharacterIndex:(unsigned long long)index;
- (void)prepareForScreenshotWithVisibleRange:(struct _NSRange)range;
- (struct _NSRange)rangeForAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (struct _NSRange)rangeForBaseAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (void)removeClearingControllerForView:(id)view;
- (void)removeClearingControllerForView:(id)view viewIdentifier:(id)identifier;
- (_Bool)selectedRangesIntersectWithRange:(struct _NSRange)range;
- (id)supplementalViewForIdentifier:(id)identifier allowHiddenViews:(_Bool)views;
- (void)textStorageDidEndEditingNotification:(id)notification;
- (void)todoButtonDidDrag:(id)drag;
- (id)todoButtonForTrackedParagraphIfExists:(id)exists;
- (id)todoButtonsForCharacterRange:(struct _NSRange)range;
- (id)trackedTodoParagraphAtIndexIfExists:(unsigned long long)exists;
- (void)unHideVisibleTodoButtons;
- (_Bool)unhideSupplementalView:(id)view forIdentifier:(id)identifier;
- (void)updateHiddenSupplementalViews;
- (void)updateInlineDrawingViews;
- (void)updateSubviewsForCharacterRange:(struct _NSRange)range;
- (void)updateSubviewsForCharacterRange:(struct _NSRange)range atPoint:(struct CGPoint)point;
- (void)updateVisibleSupplementalViews;
- (struct CGRect)usedLineRectForRange:(struct _NSRange)range;
- (id)viewControllerForTextAttachment:(id)attachment;
- (id)viewControllerForTextAttachment:(id)attachment createIfNeeded:(_Bool)needed;
- (id)viewControllerForTextAttachmentNoCreate:(id)create;
- (id)viewForBaseTextAttachmentNoCreate:(id)create;
- (id)viewForTextAttachment:(id)attachment;
- (id)viewForTextAttachment:(id)attachment initialCharacterIndex:(unsigned long long)index;
- (id)viewProviderForTextAttachment:(id)attachment parentView:(id)view characterIndex:(unsigned long long)index;
- (void)willPlaceView:(id)view forTextAttachment:(id)attachment;
- (void)zoomFactorOrInsetsDidChange;

@end


@interface ICLinkAcceleratorController : NSObject

@property (nonatomic, weak) id <ICLinkInsertionDelegate> delegate;
@property (nonatomic, weak) id <ICLinkInsertionDelegate> linkDelegate;
@property (nonatomic) _Bool isShowing;
@property (nonatomic) _Bool isReadyToShowParagraphLinks;
@property (nonatomic, copy) NSString *lastNoteLinkID;
@property (nonatomic, readonly) ICMLinkSuggestionsController *linkSuggestionsController;

/* class methods */
+ (id)didAppear;
+ (id)didDisappear;

/* instance methods */
- (id)init;
- (_Bool)handleArrowDown;
- (void)hideAccelerator;
- (void)clearParagraphLinkHintText;
- (void)didSelectAutocompleteItem:(id)item;
- (_Bool)handleArrowUp;
- (_Bool)handleUseCurrentSuggestion;
- (id)initWithCloudConfiguration:(id)configuration mode:(long long)mode;
- (void)presentLinkAcceleratorIfNecessaryWithCompletionHandler:(id /* block */)handler;
- (void)updateAcceleratorOriginWith:(struct CGRect)with;

@end


@interface ICLockedTextAttachmentView : ICAttachmentView

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithTextAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)didTapAttachment:(id)attachment;
- (id)initWithFrame:(struct CGRect)frame textAttachment:(id)attachment textContainer:(id)container forManualRendering:(_Bool)rendering;
- (void)openAttachment;

@end


@interface ICMAppTouchBarController : ICMBaseTouchBarController

@property (weak, nonatomic) NSObject<ICMAppTouchBarControllerDelegate> *touchBarControllerDelegate;
@property (readonly, nonatomic) NSButton *addNoteButton;
@property (readonly, nonatomic) NSButton *checklistButton;
@property (readonly, nonatomic) NSButton *deleteButton;
@property (readonly, nonatomic) NSString *addNoteCustomizationLabel;
@property (readonly, nonatomic) NSString *checklistCustomizationLabel;
@property (readonly, nonatomic) NSString *deleteCustomizationLabel;

/* instance methods */
- (void)dealloc;
- (void)addFolderButtonPressed:(id)pressed;
- (void)addNoteButtonPressed:(id)pressed;
- (void)checklistButtonPressed:(id)pressed;
- (void)deleteButtonPressed:(id)pressed;
- (id)initWithTouchBarDelegate:(id)delegate;
- (void)tableButtonPressed:(id)pressed;
- (id)tableCustomizationLabel;

@end


@interface ICMAttachmentContentInspector : NSWindowController <NSWindowRestoration>

@property (weak, nonatomic) NSView *contentView;
@property (retain, nonatomic) NSString *overrideMediaURLString;
@property (weak, nonatomic) NSTextField *attachmentTitleLabel;
@property (weak, nonatomic) NSTextField *attachmentIdentifierLabel;
@property (weak, nonatomic) NSTextField *attachmentUserTitleLabel;
@property (weak, nonatomic) NSImageView *imageView;
@property (weak, nonatomic) NSImageView *noteTitleImageView;
@property (weak, nonatomic) NSTextField *noteTitleLabel;
@property (weak, nonatomic) NSImageView *noteIdentifierImageView;
@property (weak, nonatomic) NSTextField *noteIdentifierLabel;
@property (weak, nonatomic) NSTextField *utiLabel;
@property (weak, nonatomic) NSTextField *typeLabel;
@property (weak, nonatomic) NSTextField *rectLabel;
@property (weak, nonatomic) NSTextField *orientationLabel;
@property (weak, nonatomic) NSTextField *quadLabel;
@property (weak, nonatomic) NSTextView *summaryTextView;
@property (weak, nonatomic) NSBox *handwritingSummaryBox;
@property (weak, nonatomic) NSTextView *handwritingSummaryTextView;
@property (weak, nonatomic) NSBox *imageClassificationSummaryBox;
@property (weak, nonatomic) NSTextView *imageClassificationSummaryTextView;
@property (weak, nonatomic) NSBox *ocrSummaryBox;
@property (weak, nonatomic) NSTextView *ocrSummaryTextView;
@property (weak, nonatomic) NSTextView *additionalIndexableTextView;
@property (weak, nonatomic) NSTextField *parentTitleLabel;
@property (weak, nonatomic) NSTextField *parentIdLabel;
@property (weak, nonatomic) NSPopUpButton *subAttachmentsPopupButton;
@property (weak, nonatomic) NSButton *generatePKDrawingDataButton;
@property (retain, nonatomic) ICAttachment *tempAttachment;
@property (weak, nonatomic) NSTextField *urlLabel;
@property (weak, nonatomic) NSButton *urlButton;
@property (weak, nonatomic) NSButton *clearSummaryButton;
@property (weak, nonatomic) NSButton *clearHandwritingSummaryButton;
@property (weak, nonatomic) NSButton *clearImageClassificationSummaryButton;
@property (weak, nonatomic) NSButton *clearOcrSummaryButton;
@property (retain, nonatomic) NSTimer *timer;
@property (weak, nonatomic) NSButton *inspectButton;
@property (nonatomic) _Bool regenerateMetadataOnClose;
@property (retain, nonatomic) ICAttachment *attachment;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)restoreWindowWithIdentifier:(id)identifier state:(id)state completionHandler:(id /* block */)handler;
+ (id)sharedAttachmentContentInspector;

/* instance methods */
- (void)windowDidLoad;
- (void)windowWillClose:(id)close;
- (void)window:(id)window willEncodeRestorableState:(id)state;
- (void)urlButtonPressed:(id)pressed;
- (void)savePKDrawingDataButtonPressed:(id)pressed;
- (void)attachmentViewDidDropAttachment:(id)attachment;
- (void)clearHandwritingSummaryButtonPressed:(id)pressed;
- (void)clearImageClassificationSummaryButtonPressed:(id)pressed;
- (void)clearOcrSummaryButtonPressed:(id)pressed;
- (void)clearSummaryButtonPressed:(id)pressed;
- (void)inspectParentButtonPressed:(id)pressed;
- (void)setUpSubAttachmentsButtonForAttachment:(id)attachment;
- (void)subAttachmentsPopupButtonDidChange:(id)change;
- (void)updateViewsToMatchAttachment;

@end


@interface ICMAttachmentRenameWindowController : NSWindowController <NSTextFieldDelegate>

@property (retain, nonatomic) ICAttachment *attachment;
@property (weak, nonatomic) NSTextField *textField;
@property (weak, nonatomic) NSButton *doneButton;
@property (weak, nonatomic) NSButton *cancelButton;
@property (retain, nonatomic) ICMAlertSheetTouchBarController *touchBarController;
@property (retain, nonatomic) NSString *originalTitle;
@property (readonly, nonatomic) NSString *currentTitle;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)renameWindowControllerWithAttachment:(id)attachment;

/* instance methods */
- (void)controlTextDidChange:(id)change;
- (_Bool)control:(id)control textView:(id)view doCommandBySelector:(SEL)selector;
- (void)windowDidLoad;
- (id)touchBar;
- (void)cancelButtonPressed:(id)pressed;
- (void)doneButtonPressed:(id)pressed;

@end


@interface ICMAttachmentViewOnlyController : NSObject <NSPopoverDelegate>

@property (weak, nonatomic) NSView *attachmentView;
@property (weak, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) NSButton *viewOnlyButton;
@property (retain, nonatomic) NSPopover *viewOnlyPopover;
@property (retain, nonatomic) ICSelectorDelayer *hideViewOnlyDocumentButtonSelectorDelayer;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)shouldShowForAttachment:(id)attachment;

/* instance methods */
- (void)popoverDidShow:(id)show;
- (void)popoverWillClose:(id)close;
- (void)hideViewOnlyButton;
- (id)initWithAttachmentView:(id)view attachment:(id)attachment;
- (void)viewOnlyButtonClicked:(id)clicked;

@end


@interface ICMAttachmentViewOnlyPopoverColorView : NSView

/* instance methods */
- (void)drawRect:(struct CGRect)rect;

@end


@interface ICMAttachmentViewOnlyPopoverContainerView : NSView

/* instance methods */
- (void)viewDidMoveToWindow;

@end


@interface ICMAttachmentViewOnlyPopoverViewController : NSViewController

@property (retain, nonatomic) NSTextField *label;

/* instance methods */
- (struct CGSize)preferredContentSize;
- (void)loadView;

@end


@interface ICMAttributionsViewController : NSViewController

@property (nonatomic, weak) ICMacTextView *textView;
@property (nonatomic, weak) ICMSidebarController *sidebarController;
@property (nonatomic, weak) ICAuthorHighlightsUpdater *authorHighlightsUpdater;
@property (nonatomic, copy) NSArray *configurations;
@property (nonatomic, retain) ICAttributionViewConfiguration *focusedConfiguration;
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic) _Bool isSidebarVisible;
@property (nonatomic, retain) ICTTTextEditFilter *filter;

/* instance methods */
- (void)loadView;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)initWithCoder:(id)coder;
- (void)observeAttributions;
- (void)stopObservingAttributions;

@end


@interface ICMFilePromiseHelper : NSObject <ICMProgressWindowControllerDelegate>

@property (retain, nonatomic) NSURL *directoryURL;
@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (retain, nonatomic) NSObject *internalQueue;
@property (retain, nonatomic) NSSet *allPromises;
@property (retain, nonatomic) NSMutableSet *processedPromises;
@property (retain, nonatomic) NSMutableSet *processedURLs;
@property (nonatomic) _Bool complete;
@property (retain, nonatomic) NSError *error;
@property (nonatomic) _Bool cancelled;
@property (nonatomic) struct CGPoint dropPoint;
@property (weak, nonatomic) NSWindow *window;
@property (retain, nonatomic) ICMProgressWindowController *progressWindowController;
@property (weak, nonatomic) id <ICMFilePromiseHelperDelegate> delegate;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)purgeTempDirectory;

/* instance methods */
- (void)updateProgress;
- (id)initWithDelegate:(id)delegate;
- (id)init;
- (void)dealloc;
- (void)invalidate;
- (void)didTapCancelButtonInProgressWindowController:(id)controller;
- (void)cancelProgressWindow;
- (id)createTempDirectory;
- (void)receiveFilePromises:(id)promises dropPoint:(struct CGPoint)point window:(id)window;
- (void)removeTempDirectory:(id)directory;
- (void)showProgressWindowWithProgress:(double)progress title:(id)title subTitle:(id)title;
- (void)updateProgressIfNecessary;

@end


@interface ICMForwardVerticalScrollEventsScrollView : ICMOverlayScrollView

@property (nonatomic) _Bool scrolling;
@property (nonatomic) _Bool scrollingDisabled;

/* instance methods */
- (_Bool)isScrolling;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)scrollWheel:(id)wheel;
- (_Bool)isScrollingDisabled;
- (void)icmDidEndScrolling:(id)scrolling;
- (void)icmListemForScrollGestures;
- (void)icmWillStartScrolling:(id)scrolling;

@end


@interface ICMHashtagDebugViewController : NSViewController

@property (weak, nonatomic) id <ICMHashtagDebugViewControllerDelegate> delegate;
@property (weak) NSTextField *textField;

/* instance methods */
- (void)addHashtag:(id)hashtag;

@end


@interface ICMImageGalleryPrintController : NSObject

@property (retain, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) ICAttachmentGalleryModel *galleryModel;
@property (retain, nonatomic) NSURL *pdfURL;
@property (retain, nonatomic) NSString *printJobTitle;
@property (nonatomic) _Bool shouldSaveDirectoryToUserDefaults;

/* instance methods */
- (id)initWithAttachment:(id)attachment;
- (void)printOperationDidRun:(id)run success:(_Bool)success contextInfo:(void *)info;
- (void)exportToPDFModalForWindow:(id)window;
- (void)printModalForWindow:(id)window;

@end


@interface ICMInvitationViewController : NSViewController

@property (weak, nonatomic) NSView *backgroundView;
@property (weak, nonatomic) NSImageView *invitationImageView;
@property (weak, nonatomic) NSTextField *titleLabel;
@property (weak, nonatomic) NSTextField *subtitleLabel;
@property (weak, nonatomic) NSButton *viewButton;
@property (weak, nonatomic) NSProgressIndicator *progressIndicator;
@property (weak, nonatomic) SWAttributionView *attributionView;
@property (retain, nonatomic) ICInvitation *invitation;
@property (retain, nonatomic) SWHighlight *highlight;
@property (nonatomic) _Bool showsActivityIndicator;
@property (copy, nonatomic) id /* block */ didClickViewButton;

/* instance methods */
- (void)viewDidLoad;
- (void)viewButtonDidClick:(id)click;

@end


@interface ICMLinkSuggestionsController : NSObject <ICAutoCompleteSuggestionsViewControllerDelegate>

@property (retain, nonatomic) ICAutoCompleteSuggestionsViewController *autoCompleteController;
@property (weak, nonatomic) ICLinkAcceleratorController *linkAcceleratorController;
@property (readonly, nonatomic) _Bool allowsLinks;
@property (nonatomic) _Bool isUpdatingKeyboard;
@property (weak, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;
@property (readonly, weak, nonatomic) ICNote *note;
@property (weak, nonatomic) ICTableColumnTextView *tableTextView;
@property (nonatomic) struct _NSRange editedRange;
@property (weak, nonatomic) NSTextView *textView;
@property (readonly, nonatomic) long long selectedRow;
@property (readonly, nonatomic) _Bool isAutoCompletionViewVisible;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)hasAcceleratorTextInTextStorage:(id)storage inRange:(struct _NSRange)range;
+ (struct _NSRange)rangeOfAcceleratorTextInTextStorage:(id)storage;

/* instance methods */
- (void)tableCellFirstResponderChangedInNote:(id)note;
- (_Bool)attemptSelectionConfirmation;
- (void)autoCompleteSuggestionsViewController:(id)controller didSelectItem:(id)item;
- (void)clearAutoCompletionView;
- (void)clearInProcessAcceleratorTextInTextStorage:(id)storage;
- (id)initWithLinkAcceleratorController:(id)controller;
- (void)insertLink:(id)link toTextView:(id)view atRange:(struct _NSRange)range viaAutoComplete:(_Bool)complete;
- (void)insertLinkAttachment:(id)attachment atRange:(struct _NSRange)range viaAutoComplete:(_Bool)complete;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)updateAutoCompletionView:(id)view range:(struct _NSRange)range textView:(id)view requiredWidth:(double)width showDividerAfterFirstRow:(_Bool)row hasNotesSectionHeader:(_Bool)header acceleratorString:(id)string writingDirection:(long long)direction;
- (double)widthForItems:(id)items;

@end


@interface ICMNoteEditorCompatibilityBannerView : NSView <ICMClickableTextViewDelegate, ICMZoomableAttachmentView>

@property (weak, nonatomic) ICMClickableTextView *clickableTextView;
@property (weak, nonatomic) NSLayoutConstraint *clickableTextViewHeightConstraint;
@property (retain, nonatomic) ICMZoomController *zoomController;
@property (readonly, nonatomic) double heightOfBanner;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)checkShouldShowCompatibilityBannerViewForNote:(id)note completion:(id /* block */)completion;
+ (id)newCompatibilityBannerView;

/* instance methods */
- (id)accessibilityLabel;
- (_Bool)isAccessibilityElement;
- (id)accessibilityRole;
- (id)accessibilityHelp;
- (id)accessibilityParent;
- (_Bool)accessibilityPerformPress;
- (void)awakeFromNib;
- (void)clickableTextViewDidClick:(id)click;
- (void)hostViewDidZoom:(id)zoom;
- (void)setupStringsWithZoomFactor:(double)factor;
- (void)updateHeightOfBannerView;

@end


@interface ICNoteEditorBaseViewController : NSViewController

@property (nonatomic) long long viewAppearanceState;
@property (readonly, nonatomic) long long editorIdentifier;
@property (readonly, nonatomic) unsigned long long options;
@property (readonly, nonatomic) _Bool auxiliaryEditor;
@property (readonly, nonatomic) _Bool editingOnSecureScreen;
@property (readonly, nonatomic) _Bool editingOnSystemPaper;
@property (retain, nonatomic) ICNote *note;
@property (readonly, nonatomic) NSString *identifierDescription;

/* instance methods */
- (void)viewDidAppear;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)description;
- (void)viewWillDisappear;
- (id)initWithCoder:(id)coder;
- (void)viewDidDisappear;
- (void)viewWillAppear;
- (id)initWithIdentifier:(long long)identifier options:(unsigned long long)options;
- (void)noteWillAppear:(id)appear;
- (void)groupActivityDidChange;
- (id)initWithIdentifier:(long long)identifier options:(unsigned long long)options nibName:(id)name bundle:(id)bundle;
- (_Bool)isAuxiliaryEditor;
- (_Bool)isEditingOnSecureScreen;
- (_Bool)isEditingOnSystemPaper;
- (void)noteDidAppear:(id)appear;
- (void)noteDidDisappear:(id)disappear;
- (void)noteWillDisappear:(id)disappear;

@end


@interface ICMNoteEditorController : ICNoteEditorBaseViewController <ICLinkInsertionDelegate, ICAttachmentInsertionDelegate, ICMacTextViewEditorDelegate, ICAttachmentViewDelegate, ICMTextStylesCollectionViewDelegate, NSCollectionViewDelegate, NSMenuDelegate, NSUserActivityDelegate, NSOpenSavePanelDelegate, NSPopoverDelegate, ICMHashtagDebugViewControllerDelegate, _TtP11NotesEditor26ICMSystemPaperLinkDelegate_, ICManagedObjectContextChangeControllerDelegate, ICLinkInsertionDelegate, ICAuxiliaryTextViewHosting, ICTextFindingDataSource, ICMZoomControllerDelegate, NSTextViewDelegate, NSUserInterfaceValidations>

@property (nonatomic, readonly) NSView *acceleratorHostingView;
@property (nonatomic, readonly) NSViewController *acceleratorHostingViewController;
@property (nonatomic, readonly) long long writingDirection;
@property (nonatomic, readonly) _Bool languageHasSpaces;
@property (nonatomic, readonly) NSTextView *textViewForAccelerator;
@property (nonatomic, readonly) NSString *searchString;
@property (readonly, nonatomic) ICLayoutManager *layoutManager;
@property (retain, nonatomic) NSArray *lastSelectedRanges;
@property (nonatomic) struct _NSRange lastSelectedRange;
@property (nonatomic) struct _NSRange lastCompletedSelectedRange;
@property (retain, nonatomic) ICPaperTextAttachmentManager *paperTextAttachmentManager;
@property (retain, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;
@property (retain, nonatomic) ICVisualAssetImportController *visualAssetImportController;
@property (retain, nonatomic) NSNumber *archivedContentOffsetYToApply;
@property (retain, nonatomic) ICMacTextView *textView;
@property (nonatomic) _Bool isShowingPasswordScreen;
@property (nonatomic) _Bool isFadingOutPasswordScreen;
@property (weak, nonatomic) NSImageView *passwordChangeTempImageView;
@property (retain, nonatomic) NSArray *passwordChangeSelectedRanges;
@property (nonatomic) struct CGRect passwordChangeDocumentVisibleRect;
@property (nonatomic) long long passwordChangeLocalZoomFactorIndex;
@property (nonatomic) _Bool shouldBeginEditingAfterNoteUnlock;
@property (nonatomic) _Bool isSettingNote;
@property (nonatomic) _Bool isReloadingNote;
@property (nonatomic) _Bool didEditNote;
@property (readonly, nonatomic) _Bool isSingleAttachmentSelected;
@property (readonly, nonatomic) NSArray *selectedAttachments;
@property (readonly, nonatomic) _Bool isInMainWindow;
@property (readonly, nonatomic) _Bool canEditChecklistItems;
@property (readonly, nonatomic) _Bool canCheckAll;
@property (readonly, nonatomic) _Bool canUncheckAll;
@property (readonly, nonatomic) _Bool canMoveCheckedChecklistItemsToBottom;
@property (readonly, nonatomic) _Bool canRemoveCheckedChecklistItems;
@property (readonly, nonatomic) _Bool canMoveSelectedListItemUp;
@property (readonly, nonatomic) _Bool canMoveSelectedListItemDown;
@property (nonatomic) _Bool hasLinksAvailable;
@property (nonatomic) _Bool isConvertToTag;
@property (retain) ICNoteUserActivityState *noteUserActivityState;
@property (nonatomic) struct CGRect savedVisibleRect;
@property (weak, nonatomic) NSMenu *indentItemMenu;
@property (retain, nonatomic) ICSelectorDelayer *updateNoteUserActivityStateDelayer;
@property (retain, nonatomic) ICSelectorDelayer *updateTouchBarDelayer;
@property (retain, nonatomic) NSMenuItem *checklistMenuItem;
@property (retain, nonatomic) NSMenuItem *moveChecklistMenuItem;
@property (retain, nonatomic) NSMenuItem *toggleTodoDoneMenuItem;
@property (retain, nonatomic) NSMenuItem *tableMenuItem;
@property (retain, nonatomic) NSMenuItem *dividerLineMenuItem;
@property (retain, nonatomic) NSMenuItem *linkMenuItem;
@property (retain, nonatomic) NSMenuItem *openLinkMenuItem;
@property (retain, nonatomic) NSMenuItem *openLinkInNewWindowMenuItem;
@property (retain, nonatomic) NSMenuItem *scrubMenuItem;
@property (retain, nonatomic) NSMenuItem *editChecklistMenuItem;
@property (retain, nonatomic) NSMenuItem *convertToTextMenuItem;
@property (retain, nonatomic) NSMenuItem *convertToTagMenuItem;
@property (retain, nonatomic) NSMenuItem *convertLinkToAttachmentMenuItem;
@property (retain, nonatomic) NSMenuItem *addToTagsMenuItem;
@property (retain, nonatomic) NSView *styleView;
@property (weak, nonatomic) ICMTextStylesCollectionView *styleCollectionView;
@property (retain, nonatomic) ICCalculatePreviewBehaviorMenu *calculatePreviewBehaviorMenu;
@property (retain, nonatomic) ICMNoteEditorTouchBarController *touchBarController;
@property (readonly, nonatomic) ICSearchResultRegexMatchFinder *displayedSearchRegexFinder;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *searchRegexFinder;
@property (readonly, nonatomic) NSString *indentLeftKeyboardShortcut;
@property (readonly, nonatomic) NSString *indentRightKeyboardShortcut;
@property (nonatomic) _Bool isValidatingRequestor;
@property (weak, nonatomic) ICMacBaseTextView *previousTextViewToResignFirstResponder;
@property (weak, nonatomic) ICMacBaseTextView *firstResponderBeforeStyleMenu;
@property (retain, nonatomic) ICAuthorHighlightsController *authorHighlightsController;
@property (retain, nonatomic) ICAuthorHighlightsUpdater *authorHighlightsUpdater;
@property (readonly, nonatomic) NSClickGestureRecognizer *releaseActivityStreamSelectionClickGestureRecognizer;
@property (retain, nonatomic) ICMHashtagDebugViewController *hastagDebugViewController;
@property (retain, nonatomic) _TtC11NotesEditor24ICMSystemPaperLinkHelper *paperLinkHelper;
@property (retain, nonatomic) NSViewController *linkPopoverViewController;
@property (retain, nonatomic) ICManagedObjectContextChangeController *inlineAttachmentChangeController;
@property (retain, nonatomic) ICManagedObjectContextChangeController *noteChangeController;
@property (retain, nonatomic) ICMUnsupportedNoteView *unsupportedNoteView;
@property (retain, nonatomic) NSClickGestureRecognizer *unsupportedNoteClickGestureRecognizer;
@property (retain, nonatomic) ICPaperMarkupController *paperMarkupController;
@property (weak, nonatomic) NSSplitViewItem *splitViewItem;
@property (copy, nonatomic) NSDate *noteLastModificationDate;
@property (retain, nonatomic) ICNAEventReporter *audioEventReporter;
@property (readonly, nonatomic) ICTextController *icaxTextController;
@property (readonly, nonatomic) ICTTTextStorage *icaxTextStorage;
@property (readonly, nonatomic) _Bool icaxUserHasInteractedWithCurrentNote;
@property (retain, nonatomic) ICInvitation *invitation;
@property (readonly, nonatomic) _Bool hasListOrFixedWidthSelection;
@property (readonly, nonatomic) long long currentWritingDirection;
@property (readonly, nonatomic) _Bool canToggleTodo;
@property (readonly, nonatomic) _Bool canAddTable;
@property (readonly, nonatomic) _Bool canAddPhoto;
@property (nonatomic) _Bool isTogglingCurrentNoteLock;
@property (readonly, nonatomic) _Bool wantsNoteUndoManager;
@property (readonly, nonatomic) _Bool isChecklistSelected;
@property (readonly, nonatomic) _Bool isEditingTableCell;
@property (readonly, nonatomic) _Bool canMoveSelectedListItem;
@property (readonly, nonatomic) _Bool canScrubNumber;
@property (readonly, nonatomic) long long uniqueCollapsibleSectionAffordanceExposures;
@property (readonly, nonatomic) long long uniqueCollapsibleSectionAffordanceUsages;
@property (nonatomic) _Bool ignoreSetNote;
@property (readonly, nonatomic) _Bool isFrozen;
@property (retain, nonatomic) ICActivityStreamSelection *activityStreamSelection;
@property (retain, nonatomic) ICHashtagController *hashtagController;
@property (retain, nonatomic) ICMentionsController *mentionsController;
@property (retain, nonatomic) ICLinkAcceleratorController *linkAcceleratorController;
@property (retain, nonatomic) ICCalculateRecognitionController *calculateRecognitionController;
@property (retain, nonatomic) ICCalculateScrubberController *calculateScrubberController;
@property (retain, nonatomic) ICMLinkSuggestionsController *linkSuggestionsController;
@property (retain, nonatomic) ICNAEventReporter *eventReporter;
@property (nonatomic) _Bool shouldCallUpdateTouchBarItemsAfterAppearing;
@property (nonatomic) _Bool doNotAdvanceInsertionPointAfterInsertingAttachment;
@property (retain, nonatomic) NSPopover *stylePopover;
@property (retain, nonatomic) NSMenuItem *attributionSidebarMenuItem;
@property (retain, nonatomic) NSMenuItem *paragraphStylesMenuItem;
@property (retain, nonatomic) NSMenuItem *fontMenuItem;
@property (retain, nonatomic) ICMPasswordEntryViewController *passwordViewController;
@property (retain, nonatomic) ICMInvitationViewController *invitationViewController;
@property (retain, nonatomic) ICTextController *textController;
@property (readonly, nonatomic) ICTextViewScrollState *currentScrollState;
@property (retain, nonatomic) NSMutableDictionary *scrollStates;
@property (retain, nonatomic) ICTableColumnTextView *tableColumnTextView;
@property (readonly, nonatomic) _Bool passwordViewControllerViewIsInHierarchy;
@property (readonly, copy, nonatomic) NSImageView *snapshotImageView;
@property (readonly, nonatomic) unsigned long long selectedTagsCount;
@property (copy, nonatomic) NSManagedObjectID *noteViewEventSourceObjectID;
@property (readonly, nonatomic) _Bool canRecordAudio;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long blockQuoteMenuItemState;
@property (readonly, nonatomic) long long currrentEmphasisType;
@property (readonly, nonatomic) ICNote *note;
@property (weak, nonatomic) NSResponder *auxiliaryResponder;
@property (weak, nonatomic) id <ICAuxiliaryStyling> auxiliaryStylingController;

/* class methods */
+ (id)editorControllerWithIdentifier:(long long)identifier options:(unsigned long long)options;
+ (id)keyPathsForValuesAffectingCanAddDrawing;
+ (id)keyPathsForValuesAffectingCanAddPhoto;
+ (id)keyPathsForValuesAffectingCanAddTable;
+ (id)keyPathsForValuesAffectingCanIndent;
+ (id)keyPathsForValuesAffectingCanIndentOrCanOutdent;
+ (id)keyPathsForValuesAffectingCanOutdent;
+ (id)keyPathsForValuesAffectingCanRecordAudio;
+ (id)keyPathsForValuesAffectingCanStyleText;
+ (id)keyPathsForValuesAffectingCanToggleTodo;
+ (id)keyPathsForValuesAffectingCurrentWritingDirection;
+ (id)keyPathsForValuesAffectingDfrBIUEnabled;
+ (id)keyPathsForValuesAffectingDisplayedSearchRegexFinder;
+ (id)keyPathsForValuesAffectingIsEditingTableCell;
+ (id)keyPathsForValuesAffectingIsFrozen;
+ (id)keyPathsForValuesAffectingIsSingleAttachmentSelected;
+ (id)keyPathsForValuesAffectingTextViewIsEditable;
+ (id)keyPathsForValuesAffectingTextViewIsFirstResponder;

/* instance methods */
- (_Bool)menuHasKeyEquivalent:(id)equivalent forEvent:(id)event target:(id *)target action:(SEL *)action;
- (void)commonInit;
- (id)touchBar;
- (id)undoManager;
- (void)userActivityWillSave:(id)save;
- (void)viewDidAppear;
- (void)mouseDown:(id)down;
- (id)textStorage;
- (void)textDidChange:(id)change;
- (void)applicationWillTerminate;
- (void)viewDidLoad;
- (void)setTextStyle:(id)style;
- (void)updateUserActivityState:(id)state;
- (void)keyDown:(id)down;
- (_Bool)validateUserInterfaceItem:(id)item;
- (void)setTimestamp:(id)timestamp;
- (void)fetchAll;
- (void)dealloc;
- (struct CGRect)selectionRect;
- (void)viewWillDisappear;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)addLink:(id)link;
- (id)initWithCoder:(id)coder;
- (void)userActivity:(id)activity didReceiveInputStream:(id)stream outputStream:(id)stream;
- (void)popoverDidShow:(id)show;
- (id)textView:(id)view menu:(id)menu forEvent:(id)event atIndex:(unsigned long long)index;
- (void)indent:(id)indent;
- (void)_openLinkFromMenu:(id)menu;
- (void)awakeFromNib;
- (void)menuWillOpen:(id)open;
- (_Bool)panel:(id)panel validateURL:(id)url error:(id *)error;
- (void)popoverDidClose:(id)close;
- (void)popoverWillShow:(id)show;
- (void)textDidBeginEditing:(id)editing;
- (void)textDidEndEditing:(id)editing;
- (_Bool)textShouldBeginEditing:(id)editing;
- (id)textView:(id)view URLForContentsOfTextAttachment:(id)attachment atIndex:(unsigned long long)index;
- (id)textView:(id)view didCheckTextInRange:(struct _NSRange)range types:(unsigned long long)types options:(id)options results:(id)results orthography:(id)orthography wordCount:(long long)count;
- (_Bool)textView:(id)view shouldChangeTextInRanges:(id)ranges replacementStrings:(id)strings;
- (id)textView:(id)view shouldChangeTypingAttributes:(id)attributes toAttributes:(id)attributes;
- (id)textView:(id)view willDisplayToolTip:(id)tip forCharacterAtIndex:(unsigned long long)index;
- (id)textView:(id)view willShowSharingServicePicker:(id)picker forItems:(id)items;
- (id)textView:(id)view writingToolsIgnoredRangesInEnclosingRange:(struct _NSRange)range;
- (void)textViewWritingToolsDidEnd:(id)end;
- (void)textViewWritingToolsWillBegin:(id)begin;
- (id)validRequestorForSendType:(id)type returnType:(id)type;
- (void)viewDidDisappear;
- (void)viewWillAppear;
- (void)addTable:(id)table;
- (_Bool)canZoomIn;
- (_Bool)canZoomOut;
- (void)outdent:(id)outdent;
- (void)updateTouchBar;
- (void)printOperationDidRun:(id)run success:(_Bool)success contextInfo:(void *)info;
- (struct _NSRange)visibleRange;
- (id)zoomController;
- (void)openLink:(id)link;
- (_Bool)canIndent;
- (void)showPhotosBrowser:(id)browser;
- (void)_performStandardShareMenuItem:(id)item;
- (void)zoomOut;
- (void)zoomIn;
- (void)didZoom:(id)zoom;
- (void)textViewDidChange:(id)change;
- (void)boundsDidChange:(id)change;
- (void)alwaysShowLightContentDidChange:(id)change;
- (void)analyticsSessionWillEnd:(id)end;
- (void)attachmentInsertionController:(id)controller didAddAttachment:(id)attachment atRange:(struct _NSRange)range;
- (void)attachmentInsertionController:(id)controller didAddInlineAttachment:(id)attachment atRange:(struct _NSRange)range textStorage:(id)storage;
- (void)attachmentInsertionController:(id)controller willAddAttachment:(id)attachment atRange:(struct _NSRange)range;
- (void)didSelectCalculatePreviewBehavior:(id)behavior;
- (void)insertBulletedList:(id)list;
- (void)insertDashedList:(id)list;
- (void)insertOrderedList:(id)list;
- (id)managedObjectContextChangeController:(id)controller managedObjectIDsToUpdateForUpdatedManagedObjects:(id)objects;
- (void)managedObjectContextChangeController:(id)controller performUpdatesForManagedObjectIDs:(id)ids;
- (_Bool)managedObjectContextChangeControllerShouldUpdateImmediately:(id)immediately;
- (void)updateAppearanceIfNecessary;
- (void)zoomResetToGlobalDefault;
- (id)initWithIdentifier:(long long)identifier options:(unsigned long long)options;
- (void)enableUnderline;
- (void)eventReporterLostSession:(id)session;
- (void)attachmentView:(id)view shouldShowAudioDetailViewForAttachment:(id)attachment animated:(_Bool)animated;
- (void)disableBoldface;
- (void)insertOpenLinkMenuItemIntoMenu:(id)menu;
- (void)openLinkEditor:(id)editor;
- (void)toggleForceLightContentPerNote:(id)note;
- (void)toggleTodoDone:(id)done;
- (_Bool)canConvertToTag;
- (void)insertTodoList:(id)list;
- (void)noteWillAppear:(id)appear;
- (void)setIconsForSystemLinkMenuItems:(id)items;
- (void)toggleUnderline;
- (void)warnUserAttachmentLimitExceeded;
- (void)acceleratorOriginNeedsUpdate;
- (void)addAILabelingFlagToExportedPDFIfNecessaryForPrintOperation:(id)operation;
- (void)addDrawing:(id)drawing;
- (void)addSystemPaperLink:(id)link;
- (void)addSystemPaperLink:(id)link atEnd:(_Bool)end;
- (void)addToTags:(id)tags;
- (void)adjustTextSelectionForPaperBecomingActive;
- (void)analyticsSessionDidResume:(id)resume;
- (void)analyticsSessionWillResign:(id)resign;
- (void)announceCurrentIndentationLevelForAccessibility;
- (void)applyContentOffsetIfAvailable;
- (void)applyContentOffsetY:(double)y;
- (void)applyEmphasisColor:(id)color;
- (void)applySavedScrollStateAfterReload;
- (void)attachmentBrickDidChangeSize;
- (void)attachmentsExceeded:(id)exceeded;
- (void)attemptToAddNewNote:(id)note;
- (void)audioEventReporterLostSession:(id)session;
- (void)audioFindInTranscript:(id)transcript;
- (void)audioRecordingStarted:(id)started;
- (void)audioRecordingStopped:(id)stopped;
- (void)audioTranscriptInteraction:(id)interaction;
- (void)beginEditingAndAddTodoAtEndOfNote:(id)note;
- (void)beginEditingAtEndOfDocument:(id)document;
- (void)calculateDocumentControllerDidUpdateHighlights:(id)highlights;
- (_Bool)canAddDrawing;
- (_Bool)canAddToTags;
- (_Bool)canConvertToText;
- (_Bool)canIndentByDelta:(long long)delta;
- (_Bool)canOutdent;
- (_Bool)canRenameAttachmentForAttachmentOrSelectionIfNil:(id)value;
- (_Bool)canSelectBlockQuoteInCollectionView:(id)view;
- (_Bool)canStyleText;
- (_Bool)canStyleTextForFomatter:(_Bool)fomatter;
- (_Bool)canZoomReset;
- (void)cancelTextViewSearchField;
- (void)checkAllChecklistItems:(id)items;
- (void)closeLinkMenu;
- (void)closeLinkMenuIfNecessary;
- (void)closeStylePopoverIfNecessary;
- (void)convertLinkToAttachment:(id)attachment;
- (void)convertToTag:(id)tag;
- (void)convertToText:(id)text;
- (id)createEmphasisMenuItemWithTitle:(id)title color:(id)color tag:(unsigned long long)tag;
- (id)createSharingServicePicker;
- (id)createSharingServicePickerWithNote:(id)note anchorView:(id)view;
- (_Bool)deleteEmptyNoteForAppTermination;
- (void)deleteHashtag:(id)hashtag;
- (_Bool)dfrBIUEnabled;
- (void)didAddAttachmentForNoteNotification:(id)notification;
- (void)didDeleteAttachmentForNoteNotification:(id)notification;
- (void)didInsertLink:(long long)link textView:(id)view;
- (void)didInvokePasteWithAttributedString:(id)string;
- (void)disableItalics;
- (void)disableStrikethrough;
- (void)disableUnderline;
- (void)dismissAutoCompleteUI;
- (void)dismissTouchBarStylePopoverIfNecessary;
- (void)enableBoldface;
- (void)enableItalics;
- (void)enableStrikethrough;
- (void)exportNoteAsPDF:(id)pdf;
- (id)findMenuItemForAction:(SEL)action inMenu:(id)menu;
- (void)freezeView;
- (void)globalZoomIndexDidChange:(id)change;
- (void)hashtagDebugViewController:(id)controller didEnterHashtagText:(id)text;
- (void)hideAcceleratorIfNecessary:(id)necessary;
- (void)highlightSearchMatchesForRegexFinder:(id)finder;
- (id)ic_aigcDictionaryForPDF;
- (void)insertAddToTagsMenuItemIntoMenu:(id)menu;
- (void)insertAudioAttachment:(id)attachment;
- (void)insertAudioAttachmentMenuItemIntoMenu:(id)menu;
- (void)insertConvertLinkToAttachmentMenuItemIntoMenuIfNecessary:(id)necessary;
- (void)insertConvertToTagMenuItemIntoMenu:(id)menu;
- (void)insertConvertToTextMenuItemIntoMenu:(id)menu;
- (void)insertDebugHashtag:(id)hashtag;
- (void)insertDebugItemsInMenu:(id)menu textView:(id)view atIndex:(unsigned long long)index;
- (void)insertDividerLine:(id)line;
- (void)insertDrawing:(id)drawing;
- (void)insertDrawingAttachmentMenuItemIntoMenu:(id)menu;
- (void)insertDrawingFromPasteboard:(id)pasteboard;
- (void)insertFile:(id)file;
- (void)insertForceLightContentIntoMenuIfNecessary:(id)necessary;
- (void)insertImageFromPasteboard:(id)pasteboard;
- (void)insertLinkMenuItemIntoMenu:(id)menu;
- (void)insertParagraphStylesMenuItemIntoMenu:(id)menu;
- (void)insertPhotoFromService:(id)service;
- (void)insertScanFromPasteboard:(id)pasteboard;
- (void)insertScrubMenuItemIntoMenu:(id)menu;
- (id)insertSystemPaperAttachmentAtLocation:(unsigned long long)location;
- (void)insertToggleAttributionSidebarMenuItemIntoMenu:(id)menu;
- (void)inspectAttachment:(id)attachment;
- (void)invalidateCanIndentOrOutdent;
- (_Bool)isAnalyticsSessionActive;
- (_Bool)isAutoCompletionViewVisible;
- (void)mergeRelatedOperationsDidEnd:(id)end;
- (void)moveCheckedChecklistItemsToBottom:(id)bottom;
- (void)moveSelectedListItemDown:(id)down;
- (void)moveSelectedListItemUp:(id)up;
- (void)movieWillPlay:(id)play;
- (id)newPrintController;
- (void)noteDecryptedStatusDidChange:(id)change;
- (void)noteDidAppear:(id)appear;
- (void)noteDidChangeCalculatePreviewBehaviorNotification:(id)notification;
- (void)noteDidDeauthenticateAfterMerge:(id)merge;
- (void)noteDidDisappear:(id)disappear;
- (void)noteShouldShowAsLightContentDidChange:(id)change;
- (void)noteWillBeDeleted:(id)deleted;
- (void)noteWillDisappear:(id)disappear;
- (void)notesContextRefreshNotification:(id)notification;
- (void)notifyZoomToViewIfPossible:(id)possible withZoomController:(id)controller;
- (void)openLinkInNewWindow:(id)window;
- (void)openLinkWithSender:(id)sender openNewWindow:(_Bool)window;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)prepareForLocalOrGlobalZoom;
- (void)presentRecordingStoppedAlertForNoteIfNeeded:(id)needed;
- (void)printNote:(id)note;
- (void)releaseActivityStreamSelectionClickGestureRecognizerAction:(id)action;
- (void)reloadCurrentNote;
- (void)removeAndClearPasswordScreen;
- (void)removeCheckedChecklistItems:(id)items;
- (void)removeTimestamp:(id)timestamp;
- (void)renameAttachment:(id)attachment;
- (void)replaceFontMenuItemInMenu:(id)menu;
- (void)requestTouchBarUpdate;
- (void)resetCollapsibleSectionAffordanceUsageData;
- (void)returnToNoteBrowserIfPossible:(id)possible;
- (void)saveScrollStateBeforeReload;
- (void)saveScrollStateForCurrentNoteIfNecessary;
- (void)scrollToFirstSearchMatchIfNecessaryForSearchResult:(id)result;
- (void)scrollToHighlights;
- (void)selectItemFromAutoCompletionMenu;
- (unsigned long long)selectedBIUS;
- (id)selectedStyles;
- (void)setTextStyleForCurrentSelection:(unsigned int)selection;
- (void)setupTextView:(id)view;
- (void)setupWindowObserversForLinkAccelerator;
- (void)showEmphasisColorPicker;
- (void)showInsertAttachmentOpenSheet:(id)sheet;
- (void)showLinkEditorWithText:(id)text url:(id)url attachment:(id)attachment stringSelection:(id)selection textView:(id)view range:(struct _NSRange)range addApproach:(long long)approach;
- (void)showLinkMenu:(id)menu;
- (void)showOrHidePasswordScreenIfNecessaryAnimated:(_Bool)animated;
- (void)showRecentlyDeletedRecoverMessage;
- (void)showRecentlyDeletedRecoverMessageIfNecessaryOrPerformBlock:(id /* block */)block;
- (void)showScrubber:(id)scrubber;
- (void)showStyleMenu:(id)menu;
- (id)snapshotImageInRect:(struct CGRect)rect;
- (void)submitNoteEditEventIfNecessary;
- (void)submitNoteViewEventForNote:(id)note;
- (void)tableCellFirstResponderChanged;
- (void)textStorageDiscardStyler;
- (_Bool)textStylesCollectionView:(id)view canSelectNamedTextStyle:(id)style;
- (_Bool)textStylesCollectionView:(id)view canSelectStyleBIUS:(unsigned long long)bius;
- (void)textStylesCollectionView:(id)view shouldApplyNamedStyle:(id)style;
- (void)textStylesCollectionView:(id)view shouldApplyStyleBIUS:(unsigned long long)bius;
- (id)textStylesCollectionViewSelectedNamedStylesIndexSet:(id)set;
- (unsigned long long)textStylesCollectionViewSelectedStyleBIUS:(id)bius;
- (void)textViewDidEndFixUpAfterEditing:(id)editing;
- (void)textViewDidMouseDownWhileNotEditable:(id)editable;
- (_Bool)textViewIsEditable;
- (_Bool)textViewIsFirstResponder;
- (void)textViewSelectionDidChange:(id)change stillSelecting:(_Bool)selecting;
- (void)textViewWillBecomeFirstResponder:(id)responder;
- (void)textViewWillResignFirstResponder:(id)responder;
- (void)toggleBlockQuote;
- (void)toggleBlockQuote:(id)quote;
- (void)toggleBoldface;
- (void)toggleCompatibilityBanner:(id)banner;
- (void)toggleEmphasis;
- (void)toggleEmphasisWithType:(long long)type;
- (void)toggleItalics;
- (void)toggleMarkupToolbarVisibility:(id)visibility;
- (void)toggleStrikethrough;
- (void)toggleStyleBIUS:(unsigned long long)bius;
- (void)toggleTodoStyle:(id)style;
- (void)unCheckAllChecklistItems:(id)items;
- (void)unfreezeViewIfNecessaryAnimated:(_Bool)animated;
- (void)updateAuthorHighlightsIfNeeded;
- (void)updateChecklistButtonAccessibilityForSelection;
- (void)updateEditableIfNeeded;
- (void)updateLastOpenedDate;
- (void)updateLastViewedMetadata;
- (void)updateLastViewedMetadataAfterDelay;
- (void)updateLinkAvailability:(_Bool)availability;
- (void)updateNoteEditorViewAccessibilityChildren;
- (void)updateNoteUserActivityState;
- (void)updatePencilKitPaperStyleType;
- (void)updateTextStorage;
- (void)updateTextViewTypingAttributesForSettingTextStyleInRange:(struct _NSRange)range;
- (void)updateTextViewTypingAttributesInRange:(struct _NSRange)range forSelectionChange:(_Bool)change;
- (void)updateTextViewTypingAttributesInRange:(struct _NSRange)range forSelectionChange:(_Bool)change forSettingTextStyle:(_Bool)style;
- (void)updateUnsupportedNoteView;
- (void)userActivitiesToExcludeWithCompletion:(id /* block */)completion;
- (void)warnUserAttachmentSizeExceededWithAttachmentCount:(unsigned long long)count;
- (void)warnUserNoteLengthExceeded;
- (void)willAddAttachmentForNoteNotification:(id)notification;

@end


@interface ICMNoteEditorDateView : NSView <ICNoteDateFormatterControllerDelegate, ICMZoomableAttachmentView>

@property (weak, nonatomic) NSTextField *dateLabel;
@property (copy, nonatomic) NSString *dateString;
@property (nonatomic) _Bool iconIsHidden;
@property (retain, nonatomic) ICNoteDateFormatterController *formatterController;
@property (retain, nonatomic) ICMZoomController *zoomController;
@property (retain, nonatomic) ICNote *note;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (double)dateViewLabelAlpha;
+ (id)newDateView;

/* instance methods */
- (void)mouseDown:(id)down;
- (void)update;
- (_Bool)isAccessibilityElement;
- (void)reset;
- (id)accessibilityValue;
- (id)accessibilityRole;
- (id)accessibilityParent;
- (_Bool)accessibilityPerformPress;
- (void)awakeFromNib;
- (void)hostViewDidZoom:(id)zoom;
- (id)attributedStringForLabel;
- (void)formatter:(id)formatter iconHiddenDidChange:(_Bool)change;
- (void)formatter:(id)formatter textDidChange:(id)change fullText:(id)text;

@end


@interface ICMTextStylesTouchBarController : ICMAppTouchBarController <ICMTextStylesTouchBarDelegate, NSTouchBarDelegate>

@property (retain, nonatomic) NSButton *indentButton;
@property (retain, nonatomic) NSButton *outdentButton;
@property (retain, nonatomic) ICMTextStylesTouchBar *stylesTouchBar;
@property (retain, nonatomic) NSStackView *indentStackView;
@property (retain, nonatomic) NSCustomTouchBarItem *addNoteBarItem;
@property (retain, nonatomic) NSPopoverTouchBarItem *stylesBarItem;
@property (retain, nonatomic) NSCustomTouchBarItem *checklistBarItem;
@property (retain, nonatomic) NSCustomTouchBarItem *indentTextBarItem;
@property (retain, nonatomic) NSCandidateListTouchBarItem *candidateBarItem;
@property (readonly, nonatomic) NSSet *textViewProvidedIdentifiers;
@property (readonly, nonatomic) _Bool isRTL;
@property (retain, nonatomic) NSTouchBar *editingTouchBar;
@property (retain, nonatomic) NSView *textViewBIUButton;
@property (weak, nonatomic) ICMacBaseTextView *textView;
@property (retain, nonatomic) NSIndexSet *manualSelectedStyles;
@property (readonly, nonatomic) NSString *customizationIdentifier;
@property (readonly, nonatomic) NSArray *defaultItemIdentifiers;
@property (readonly, nonatomic) NSArray *customizationAllowedItemIdentifiers;
@property (readonly, nonatomic) NSArray *customizationRequiredItemIdentifiers;
@property (readonly, nonatomic) id dfrBIUEnabledBindingObject;
@property (readonly, nonatomic) id canStyleTextEnabledBindingObject;
@property (readonly, nonatomic) id canIndentEnabledBindingObject;
@property (readonly, nonatomic) id canOutdentEnabledBindingObject;
@property (readonly, nonatomic) id canToggleTodoEnabledBindingObject;
@property (readonly, nonatomic) NSWindowController *windowController;
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
- (void)updateTextTouchBarItems;
- (id)textViewProvidedItemIdentifiers;
- (void)addNoteButtonPressed:(id)pressed;
- (void)checklistButtonPressed:(id)pressed;
- (void)dismissStylePopoverIfNecessary;
- (void)handleStyleButtonPressed:(id)pressed;
- (void)indentButtonPressed:(id)pressed;
- (id)initWithTextView:(id)view touchBarDelegate:(id)delegate;
- (void)outdentButtonPressed:(id)pressed;
- (void)styleButtonPressed:(id)pressed;
- (void)styleCollapsedButtonPressed:(id)pressed;
- (void)textStylesTouchBar:(id)bar didSelectStyle:(id)style sender:(id)sender;
- (void)toggleBlockQuote;
- (void)updateChecklistButtonAccessibilityValue;
- (void)updateStyleButtons;
- (void)updateStyleButtonsIfNecessary;

@end


@interface ICMNoteEditorTouchBarController : ICMTextStylesTouchBarController <NSTouchBarDelegate>

@property (weak, nonatomic) ICMNoteEditorController *editorController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)customizationIdentifier;
- (id)init;
- (id)customizationAllowedItemIdentifiers;
- (id)customizationRequiredItemIdentifiers;
- (id)defaultItemIdentifiers;
- (void)addNoteButtonPressed:(id)pressed;
- (id)canIndentEnabledBindingObject;
- (id)canOutdentEnabledBindingObject;
- (id)canStyleTextEnabledBindingObject;
- (id)canToggleTodoEnabledBindingObject;
- (void)checklistButtonPressed:(id)pressed;
- (id)dfrBIUEnabledBindingObject;
- (void)indentButtonPressed:(id)pressed;
- (id)initWithEditorController:(id)controller touchBarDelegate:(id)delegate;
- (void)outdentButtonPressed:(id)pressed;
- (void)styleButtonPressed:(id)pressed;

@end


@interface ICMPasswordEntryViewController : NSViewController <LAUIAuthenticationViewControllerDelegate, ICMClickableTextViewDelegate>

@property (retain, nonatomic) LAUIAuthenticationViewController *localAuthVC;
@property (weak, nonatomic) NSView *backgroundView;
@property (weak, nonatomic) NSView *authVCContainerView;
@property (retain, nonatomic) ICMClickableTextView *learnMoreTextView;
@property (copy, nonatomic) NSString *authSubtitle;
@property (copy, nonatomic) NSString *authSubtitleNoBiometry;
@property (nonatomic) long long incorrectPasswordAttempts;
@property (retain, nonatomic) NSString *accountPassword;
@property (retain, nonatomic) NSString *overrideSubtitle;
@property (nonatomic) _Bool correctPasswordEntered;
@property (nonatomic) _Bool isShowingDivergedDialogue;
@property (nonatomic) _Bool shouldPasswordFieldBecomeFirstResponderAfterFolderExpansion;
@property (retain, nonatomic) id retainedSelf;
@property (nonatomic) _Bool biometricInhibitUpdateScheduled;
@property (retain, nonatomic) NSTouchBar *emptyTouchBar;
@property (weak, nonatomic) id <ICMPasswordEntryViewControllerDelegate> passwordEntryDelegate;
@property (retain, nonatomic) ICNote *note;
@property (weak, nonatomic) ICMNoteEditorController *editorController;
@property (nonatomic) _Bool isAuxiliaryEditor;
@property (nonatomic) _Bool inhibitTouchID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)windowDidBecomeKey:(id)key;
- (void)doCommandBySelector:(SEL)selector;
- (void)viewDidLoad;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)init;
- (void)reset;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)initWithCoder:(id)coder;
- (id)localizedSubTitleForMechanisms:(unsigned long long)mechanisms;
- (void)cancelAuthentication;
- (void)authAttemptFailed;
- (void)authenticationDidSuccceed;
- (_Bool)cmdEnterOrReturnPressed;
- (void)focusPasswordField;
- (void)setupAccessibility;
- (void)clickableTextViewDidClick:(id)click;
- (void)showUpdateDivergedPasswordSheetForNotePassword:(id)password accountPassword:(id)password;
- (void)_icaxRecursivelySetLinkedUIElements:(id)uielements forElement:(id)element;
- (_Bool)attemptToUnlockWithPassword:(id)password;
- (void)folderListDidExpand:(id)expand;
- (void)folderListWillExpand:(id)expand;
- (void)hideLearnMoreLink;
- (id)initWithNote:(id)note isAuxiliaryEditor:(_Bool)editor passwordEntryDelegate:(id)delegate;
- (void)setUpForPasswordEntry;
- (_Bool)shouldInhibitBiometrics;
- (void)showLearnMoreLink;
- (void)touchIDEnabledDidChange:(id)change;
- (void)updateInhibitBiometrics;
- (void)updateLocalAuthController;

@end


@interface ICMPrintController : NSObject

@property (retain, nonatomic) ICTextController *textController;
@property (retain, nonatomic) ICMacTextView *textView;
@property (retain, nonatomic) ICNote *note;

/* instance methods */
- (id)PDFRepresentation;
- (id)printJobTitle;
- (id)configuredPrintOperationWithPrintInfo:(id)info isForPrintingPDFToData:(id)data;
- (void)exportToPDFModalForWindow:(id)window delegate:(id)delegate;
- (id)initWithNote:(id)note frame:(struct CGRect)frame;
- (id)paginatedPDFRepresentation;
- (void)postPrintCleanup;
- (void)printModalForWindow:(id)window delegate:(id)delegate;

@end


@interface ICMPrintPanelAccessoryController : NSViewController <NSPrintPanelAccessorizing>

@property (nonatomic) _Bool pageNumbering;
@property (nonatomic) _Bool wrappingToFit;
@property (nonatomic) _Bool showsWrappingToFit;

/* instance methods */
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)setRepresentedObject:(id)object;
- (id)keyPathsForValuesAffectingPreview;
- (id)localizedSummaryItems;

@end


@interface ICMSidebarController : NSObject

@property (nonatomic) _Bool isSwipeGestureEnabled;
@property (nonatomic) _Bool isSidebarHidden;
@property (nonatomic) _Bool isSidebarExpanded;
@property (nonatomic, weak) NSView *containerView;
@property (nonatomic, weak) NSView *sidebarView;
@property (nonatomic) double expandedSidebarWidth;
@property (nonatomic) double previewSidebarWidth;
@property (nonatomic) _Bool isTrackingSwipeGesture;
@property (nonatomic) double currentSwipeGestureAmount;
@property (nonatomic, copy) id /* block */ didClickContent;

/* instance methods */
- (id)init;
- (_Bool)handleScrollWheelEvent:(id)event;
- (void)didClickContentWithSender:(id)sender;
- (void)setSidebarHidden:(_Bool)hidden animated:(_Bool)animated;

@end


@interface ICMSidebarScrollView : NSScrollView

/* class methods */
+ (_Bool)isCompatibleWithResponsiveScrolling;

/* instance methods */
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)hitTest:(struct CGPoint)test;
- (void)scrollWheel:(id)wheel;

@end


@interface ICMTK2NoteEditorController : ICMNoteEditorController <ICAttachmentInsertionDelegate, ICLinkInsertionDelegate>

@property (retain, nonatomic) ICMSidebarScrollView *scrollView;
@property (retain, nonatomic) ICTK2MacTextView *tk2TextView;
@property (readonly, nonatomic) ICTextViewScrollState *savedScrollStateForCurrentNote;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long writingDirection;
@property (readonly, nonatomic) _Bool languageHasSpaces;
@property (readonly, nonatomic) ICNote *note;
@property (readonly, nonatomic) NSTextView *textViewForAccelerator;
@property (readonly, copy, nonatomic) NSString *searchString;
@property (readonly, nonatomic) NSView *acceleratorHostingView;
@property (readonly, nonatomic) NSViewController *acceleratorHostingViewController;
@property (readonly, nonatomic) ICNAEventReporter *eventReporter;
@property (readonly, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;

/* instance methods */
- (id)textStorage;
- (id)textView;
- (struct CGRect)selectionRect;
- (void)awakeFromNib;
- (id)textController;
- (void)setAuthorHighlightsController:(id)controller;
- (void)acceleratorOriginNeedsUpdate;
- (void)authorHighlightsControllerDidPerformHighlightUpdates:(id)updates;
- (void)renderAuthorHighlights;
- (void)resetCollapsibleSectionAffordanceUsageData;
- (_Bool)shouldRenderAuthorHighlights;
- (long long)uniqueCollapsibleSectionAffordanceExposures;
- (long long)uniqueCollapsibleSectionAffordanceUsages;
- (void)updateTextStorage;
- (void)updateTextViewTypingAttributesInRange:(struct _NSRange)range forSelectionChange:(_Bool)change forSettingTextStyle:(_Bool)style;

@end


@interface ICMTableAccessibilityElement : NSAccessibilityElement <NSAccessibilityTable>

@property (weak, nonatomic) id parent;
@property (retain, nonatomic) NSAccessibilityElement *columnHeaderContainerElement;
@property (retain, nonatomic) NSAccessibilityElement *rowHeaderContainerElement;
@property (weak, nonatomic) ICTableAccessibilityController *tableAXController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)accessibilityLabel;
- (_Bool)isAccessibilityElement;
- (struct CGRect)accessibilityFrame;
- (id)accessibilityRole;
- (id)accessibilityCellForColumn:(long long)column row:(long long)row;
- (id)accessibilityAttributeNames;
- (id)accessibilityAttributeValue:(id)value;
- (id)accessibilityChildren;
- (long long)accessibilityColumnCount;
- (id)accessibilityColumnHeaderUIElements;
- (id)accessibilityColumns;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityParent;
- (long long)accessibilityRowCount;
- (id)accessibilityRowHeaderUIElements;
- (id)accessibilityRows;
- (id)accessibilitySelectedCells;
- (void)setAccessibilitySelectedCells:(id)cells;
- (id)initWithTableAccessibilityController:(id)controller parent:(id)parent;

@end


@interface ICMTableAccessibilityTextViewProxyElement : NSAccessibilityElement

@property (readonly, nonatomic) ICTableAccessibilityController *tableAXController;

/* instance methods */
- (_Bool)isAccessibilityElement;
- (struct CGRect)accessibilityFrame;
- (long long)accessibilityNumberOfCharacters;
- (id)accessibilitySelectedTextRanges;
- (id)accessibilityAttributeNames;
- (id)accessibilityAttributeValue:(id)value;
- (id)accessibilityAttributeValue:(id)value forParameter:(id)parameter;
- (id)accessibilityAttributedStringForRange:(struct _NSRange)range;
- (struct CGRect)accessibilityFrameForRange:(struct _NSRange)range;
- (_Bool)accessibilityIsAttributeSettable:(id)settable;
- (id)accessibilityParameterizedAttributeNames;
- (id)accessibilityParent;
- (id)accessibilityRTFForRange:(struct _NSRange)range;
- (struct _NSRange)accessibilityRangeForIndex:(long long)index;
- (struct _NSRange)accessibilityRangeForPosition:(struct CGPoint)position;
- (struct _NSRange)accessibilitySelectedTextRange;
- (void)accessibilitySetValue:(id)value forAttribute:(id)attribute;
- (id)accessibilityStringForRange:(struct _NSRange)range;
- (struct _NSRange)accessibilityStyleRangeForIndex:(long long)index;
- (struct _NSRange)accessibilityVisibleCharacterRange;
- (struct _NSRange)cellTextRangeInTextView;
- (id)initWithTableAccessibilityController:(id)controller;
- (struct _NSRange)rangeInSelectedCellFromRangeInTextView:(struct _NSRange)view;
- (struct _NSRange)rangeInTextViewFromRangeInSelectedCell:(struct _NSRange)cell;
- (id)tableColumnTextView;

@end


@interface ICMTableAttachmentTouchBarController : ICMTextStylesTouchBarController <NSTouchBarDelegate>

@property (readonly, nonatomic) ICMNoteEditorController *editorController;
@property (retain, nonatomic) NSCustomTouchBarItem *biuBarItem;
@property (retain, nonatomic) ICMTextStyleTouchBarBIUButton *biuSegmentedControl;
@property (weak, nonatomic) id <ICMTableAttachmentTouchBarControllerDelegate> delegate;
@property (weak, nonatomic) ICMacTableAttachmentViewController *tableController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)keyPathsForValuesAffectingEditorController;
+ (id)keyPathsForValuesAffectingWindowController;

/* instance methods */
- (id)customizationIdentifier;
- (id)init;
- (id)touchBar:(id)bar makeItemForIdentifier:(id)identifier;
- (id)customizationAllowedItemIdentifiers;
- (id)customizationRequiredItemIdentifiers;
- (id)defaultItemIdentifiers;
- (void)updateTextTouchBarItems;
- (id)windowController;
- (void)addNoteButtonPressed:(id)pressed;
- (void)biuButtonPressed:(id)pressed;
- (id)canIndentEnabledBindingObject;
- (id)canOutdentEnabledBindingObject;
- (id)canStyleTextEnabledBindingObject;
- (id)canToggleTodoEnabledBindingObject;
- (void)checklistButtonPressed:(id)pressed;
- (id)dfrBIUEnabledBindingObject;
- (void)indentButtonPressed:(id)pressed;
- (id)initWithTableController:(id)controller touchBarDelegate:(id)delegate;
- (void)outdentButtonPressed:(id)pressed;
- (void)styleButtonPressed:(id)pressed;

@end


@interface ICMTableCellGroupAccessibilityElement : NSAccessibilityElement

@property (copy, nonatomic) NSUUID *rowOrColumnIdentifier;
@property (weak, nonatomic) ICTableAccessibilityController *tableAXController;
@property (readonly, nonatomic) long long index;
@property (readonly, nonatomic) NSArray *cellElements;

/* instance methods */
- (id)description;
- (struct CGRect)accessibilityFrame;
- (id)accessibilityRole;
- (id)accessibilityChildren;
- (id)accessibilityParent;
- (id)initWithID:(id)id tableAXController:(id)axcontroller;

@end


@interface ICMTableColumnAccessibilityElement : ICMTableCellGroupAccessibilityElement

/* instance methods */
- (id)accessibilityLabel;
- (id)accessibilityRole;
- (id)accessibilityHeader;
- (long long)accessibilityIndex;
- (id)cellElements;

@end


@interface ICMTableRowAccessibilityElement : ICMTableCellGroupAccessibilityElement <NSAccessibilityRow>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)accessibilityLabel;
- (struct CGRect)accessibilityFrame;
- (id)accessibilityRole;
- (id)accessibilityHeader;
- (long long)accessibilityIndex;
- (id)accessibilityParent;
- (id)accessibilitySubrole;
- (id)cellElements;

@end


@interface ICMTextStyleTouchBarBIUButton : NSSegmentedControl

@property (nonatomic) unsigned long long styleBIUS;

/* class methods */
+ (id)newBIUButton;

@end


@interface ICMTextStylesTouchBar : NSTouchBar

@property (weak, nonatomic) NSView *view;
@property (retain, nonatomic) NSArray *allButtons;
@property (weak, nonatomic) id <ICMTextStylesTouchBarDelegate> textStylesDelegate;
@property (retain, nonatomic) NSIndexSet *selectedStyles;
@property (weak, nonatomic) NSButton *titleButton;
@property (weak, nonatomic) NSButton *headingButton;
@property (weak, nonatomic) NSButton *subHeadingButton;
@property (weak, nonatomic) NSButton *bodyButton;
@property (weak, nonatomic) NSButton *monospaceButton;
@property (weak, nonatomic) NSButton *bulletButton;
@property (weak, nonatomic) NSButton *dashButton;
@property (weak, nonatomic) NSButton *numberedButton;
@property (weak, nonatomic) NSButton *blockQuoteButton;

/* class methods */
+ (id)newTouchBar;

/* instance methods */
- (void)awakeFromNib;
- (void)buttonPressed:(id)pressed;
- (id)buttonSafeAttributesForStyle:(id)style;
- (void)setTitleAttributesForButton:(id)button;

@end


@interface ICMTextViewFinderClient_Asynchronous : NSObject <NSTextFinderClient>

@property (weak, nonatomic) id <ICTextFindingDataSource> dataSource;
@property (retain, nonatomic) ICTextFindingCoordinator *findingCoordinator;
@property (retain, nonatomic) ICNAFindResultExposureReporter *reporter;
@property (readonly) _Bool selectable;
@property (readonly) _Bool allowsMultipleSelection;
@property (readonly) _Bool editable;
@property (readonly) NSString *string;
@property (readonly) struct _NSRange firstSelectedRange;
@property (copy) NSArray *selectedRanges;
@property (readonly, copy) NSArray *visibleCharacterRanges;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)textView;
- (id)documentContainerView;
- (void)findMatchesForString:(id)string relativeToMatch:(id)match findOptions:(unsigned long long)options maxResults:(unsigned long long)results resultCollector:(id /* block */)collector;
- (id)firstResponderWhenDeactivated;
- (void)getSelectedText:(id /* block */)text;
- (void)replaceMatches:(id)matches withString:(id)string inSelectionOnly:(_Bool)only resultCollector:(id /* block */)collector;
- (void)scrollFindMatchToVisible:(id)visible;
- (void)selectFindMatch:(id)match completionHandler:(id /* block */)handler;
- (_Bool)shouldReplaceCharactersInRanges:(id)ranges withStrings:(id)strings;
- (_Bool)supportsFullWordOption;
- (_Bool)supportsPatternOption;
- (id)initWithDataSource:(id)source reporter:(id)reporter;

@end


@interface ICMTextViewFinderClient_Synchronous : NSObject <NSTextFinderClient>

@property (retain, nonatomic) NSAttributedString *searchableString;
@property (weak, nonatomic) id <ICTextFindingDataSource> dataSource;
@property (readonly, nonatomic) ICNote *note;
@property (readonly, nonatomic) NSTextView<NSTextFinderClient> *textView;
@property (nonatomic) struct _NSRange selectedRangeForReplace;
@property (readonly) _Bool selectable;
@property (readonly) _Bool allowsMultipleSelection;
@property (readonly) _Bool editable;
@property (readonly) NSString *string;
@property (readonly) struct _NSRange firstSelectedRange;
@property (copy) NSArray *selectedRanges;
@property (readonly, copy) NSArray *visibleCharacterRanges;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isEditable;
- (id)initWithDataSource:(id)source;
- (_Bool)respondsToSelector:(SEL)selector;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (void)scrollRangeToVisible:(struct _NSRange)visible;
- (id)forwardingTargetForSelector:(SEL)selector;
- (id)contentViewAtIndex:(unsigned long long)index effectiveCharacterRange:(struct _NSRange *)range;
- (void)drawCharactersInRange:(struct _NSRange)range forContentView:(id)view;
- (id)rectsForCharacterRange:(struct _NSRange)range;
- (_Bool)shouldReplaceCharactersInRanges:(id)ranges withStrings:(id)strings;
- (id)findableForAttachment:(id)attachment;
- (_Bool)rangesAreInlineAttachments:(id)attachments;
- (void)refreshSearchableString;

@end


@interface ICMTypesetter : NSATSTypesetter

@property (readonly, nonatomic) ICTextController *textController;

/* instance methods */
- (void)getLineFragmentRect:(struct CGRect *)rect usedRect:(struct CGRect *)rect remainingRect:(struct CGRect *)rect forStartingGlyphAtIndex:(unsigned long long)index proposedRect:(struct CGRect)rect lineSpacing:(double)spacing paragraphSpacingBefore:(double)before paragraphSpacingAfter:(double)after;

@end


@interface ICMUnsupportedNoteView : NSView

@property (nonatomic, readonly) long long reason;
@property (nonatomic, retain) NSStackView *stackView;
@property (nonatomic, retain) NSTextField *titleLabel;
@property (nonatomic, retain) NSTextField *summaryLabel;
@property (nonatomic, retain) NSButton *actionButton;
@property (nonatomic, copy) id /* block */ didClickActionButton;

/* instance methods */
- (id)init;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithReason:(long long)reason;
- (id)initWithCoder:(id)coder;
- (void)didClickActionButton:(id)button;

@end


@interface ICMViewOnlyButton : NSButton

/* instance methods */
- (void)drawRect:(struct CGRect)rect;
- (void)commonInit;
- (void)setFrame:(struct CGRect)frame;
- (id)initWithFrame:(struct CGRect)frame;
- (struct CGSize)intrinsicContentSize;
- (id)initWithCoder:(id)coder;

@end


@interface ICMacBaseTextView : NSTextView

@property (retain, nonatomic) CALayer *insertionCursorLayer;
@property (nonatomic) _Bool previouslyHadMarkedText;
@property (nonatomic) _Bool needsDidChangeTextAfterPastingEnds;
@property (nonatomic) _Bool languageHasSpaces;
@property (readonly, nonatomic) ICTextController *textController;
@property (readonly, nonatomic) ICTTTextStorage *TTTextStorage;
@property (readonly, nonatomic) ICLayoutManager *icLayoutManager;
@property (readonly, nonatomic) ICTK2TextLayoutManager *icTextLayoutManager;
@property (retain, nonatomic) NSTextHighlightShapeProvider *highlightShapeProvider;
@property (weak, nonatomic) ICMNoteEditorController *editorController;
@property (readonly, nonatomic) id <ICNoteViewContainer> editorContainer;
@property (readonly, nonatomic) NSView *containerViewForAttachments;
@property (readonly, nonatomic) ICMZoomController *zoomController;
@property (readonly, nonatomic) double zoomFactor;
@property (readonly, nonatomic) _Bool supportsAttachments;
@property (nonatomic) _Bool textSelectionHidden;
@property (nonatomic) _Bool shouldHideCaret;
@property (nonatomic) _Bool didUpdateTextViewSelectedRange;
@property (nonatomic) unsigned long long previousSelectedRangeLength;
@property (nonatomic) _Bool isPasting;
@property (nonatomic) _Bool shouldCallUpdateTouchBarItemsAfterPaste;
@property (nonatomic) _Bool isSettingTextStyle;
@property (retain, nonatomic) CALayer *tempHighlightLayer;
@property (readonly, nonatomic) CALayer *tempHighlightLayerIfExists;
@property (nonatomic) _Bool isDraggingChecklistItem;
@property (readonly, nonatomic) _Bool isDraggingOverChecklistItem;
@property (retain, nonatomic) ICTextViewRenderingSurfaceView *renderingSurfaceView;
@property (readonly, nonatomic) ICInlineTextAttachment *selectionLinkTextAttachment;
@property (readonly, nonatomic) _Bool selectionContainsLink;
@property (readonly, nonatomic) _Bool selectionContainsNonLinkAttachments;
@property (readonly, copy, nonatomic) NSArray *selectedAttachments;

/* instance methods */
- (id)typingAttributes;
- (void)makeTextWritingDirectionRightToLeft:(id)left;
- (void)alignLeft:(id)left;
- (void)alignRight:(id)right;
- (void)unmarkText;
- (void)commonInit;
- (id)touchBar;
- (void)setTypingAttributes:(id)attributes;
- (void)alignCenter:(id)center;
- (void)alignJustified:(id)justified;
- (void)makeTextWritingDirectionLeftToRight:(id)right;
- (void)makeTextWritingDirectionNatural:(id)natural;
- (_Bool)resignFirstResponder;
- (void)paste:(id)paste;
- (_Bool)becomeFirstResponder;
- (void)setInitialDirection;
- (_Bool)validateUserInterfaceItem:(id)item;
- (void)dealloc;
- (void)pasteFont:(id)font;
- (id)initWithCoder:(id)coder;
- (id)acceptableDragTypes;
- (void)changeAttributes:(id)attributes;
- (void)changeAttributesWithModifier:(id /* block */)modifier;
- (void)changeColor:(id)color;
- (void)changeFont:(id)font;
- (void)didChangeText;
- (void)drawInsertionPointInRect:(struct CGRect)rect color:(id)color turnedOn:(_Bool)on;
- (void)handleTextCheckingResults:(id)results forRange:(struct _NSRange)range types:(unsigned long long)types options:(id)options orthography:(id)orthography wordCount:(long long)count;
- (id)initWithFrame:(struct CGRect)frame textContainer:(id)container;
- (void)insertText:(id)text replacementRange:(struct _NSRange)range;
- (void)makeBaseWritingDirectionLeftToRight:(id)right;
- (void)makeBaseWritingDirectionNatural:(id)natural;
- (void)makeBaseWritingDirectionRightToLeft:(id)left;
- (void)pasteAsPlainText:(id)text;
- (void)pasteAsRichText:(id)text;
- (void)pasteRuler:(id)ruler;
- (_Bool)readSelectionFromPasteboard:(id)pasteboard type:(id)type;
- (id)readablePasteboardTypes;
- (void)removeStyle:(id)style;
- (void)setMarkedText:(id)text selectedRange:(struct _NSRange)range replacementRange:(struct _NSRange)range;
- (_Bool)shouldDrawInsertionPoint;
- (void)subscript:(id)subscript;
- (void)superscript:(id)superscript;
- (void)underline:(id)underline;
- (void)unscript:(id)unscript;
- (id)writablePasteboardTypes;
- (_Bool)writeSelectionToPasteboard:(id)pasteboard type:(id)type;
- (_Bool)shouldBeginEditing;
- (void)accentColorDidChange:(id)change;
- (void)strikethrough:(id)strikethrough;
- (void)resetWritingDirectionToNatural:(id)natural;
- (unsigned long long)ic_selectedBIUS;
- (id)attachmentsInRange:(struct _NSRange)range;
- (id)attributedStringByRemovingUnsupportedAttachments:(id)attachments;
- (id)attributedSubstringForCopying;
- (id)attributedSubstringForCopyingWithInlineAttachmentFlatten;
- (id)customPasteboardData;
- (void)drawBlockQuoteAndCleanup:(_Bool *)cleanup pendingBlockQuoteLevelToDraw:(unsigned long long *)draw pendingBlockQuoteRectToDraw:(struct CGRect *)draw ps:(id)ps;
- (void)drawBlockQuoteLayerInRectForTK2:(struct CGRect)tk2 blockQuoteLevel:(long long)level isMonostyled:(_Bool)monostyled;
- (void)drawMonostyledLayerInRect:(struct CGRect)rect;
- (void)drawTextInRect:(struct CGRect)rect attributes:(id)attributes inContext:(struct CGContext *)context;
- (unsigned long long)firstValidEmphasisLocationWithinSelection:(struct _NSRange)selection;
- (void)fontPanelDidChangeFont:(id)font;
- (void)fontPanelWillChangeFont:(id)font;
- (_Bool)ic_allSelectedRangesContainAttributeName:(id)name withValue:(id)value;
- (_Bool)ic_allSelectedRangesContainFontHintOrEquivalentSymbolicTrait:(unsigned int)trait;
- (_Bool)ic_canChangeStyle;
- (_Bool)ic_canIndentByDelta:(long long)delta;
- (long long)ic_currentWritingDirection;
- (void)ic_disableBoldface;
- (void)ic_disableItalics;
- (void)ic_disableStrikethrough;
- (void)ic_disableUnderline;
- (void)ic_editAttributesInSelectedRanges:(id /* block */)ranges;
- (void)ic_editAttributesInSelectedRanges:(id /* block */)ranges shouldSkipAttachments:(_Bool)attachments;
- (void)ic_enableBoldface;
- (void)ic_enableItalics;
- (void)ic_enableStrikethrough;
- (void)ic_enableUnderline;
- (void)ic_enumerateAttributesInSelectedRanges:(id /* block */)ranges;
- (void)ic_enumerateTableAttachmentViewControllersInRanges:(id)ranges usingBlock:(id /* block */)block;
- (unsigned int)ic_getTextStyleForCurrentSelection;
- (void)ic_indentByAmount:(long long)amount;
- (void)ic_performBlock:(id /* block */)block;
- (id)ic_selectedStyles;
- (id)ic_selectedStylesIgnoreTypingAttributes:(_Bool)attributes;
- (void)ic_setAttributeWithName:(id)name enabled:(_Bool)enabled;
- (void)ic_setAttributeWithName:(id)name enabled:(_Bool)enabled withEmphasisColorType:(long long)type;
- (void)ic_setFontHint:(unsigned int)hint enabled:(_Bool)enabled;
- (void)ic_setTextAlignmentForCurrentSelection:(long long)selection;
- (void)ic_setTextStyleForCurrentSelection:(unsigned int)selection;
- (void)ic_toggleAttributeWithName:(id)name;
- (void)ic_toggleAttributeWithName:(id)name withEmphasisColorType:(long long)type;
- (void)ic_toggleBoldface;
- (void)ic_toggleEmphasisWithType:(long long)type;
- (void)ic_toggleFontHint:(unsigned int)hint;
- (void)ic_toggleItalics;
- (void)ic_toggleStrikethrough;
- (void)ic_toggleUnderline;
- (void)keyboardLocaleChanged:(id)changed;
- (_Bool)nsWriteSelectionToPasteboard:(id)pasteboard type:(id)type;
- (void)pasteMarkdown:(id)markdown selectedRangeBeforePaste:(struct _NSRange)paste;
- (void)setupLinkTextAttributes;
- (void)showDeleteInlineDrawingAlertWithType:(unsigned long long)type attachments:(id)attachments completionHandler:(id /* block */)handler;
- (void)showRemoveAttachmentAlertIfNecessaryForOperation:(unsigned long long)operation selectedRange:(struct _NSRange)range completionHandler:(id /* block */)handler;
- (void)showRemoveAttachmentAlertWithTitle:(id)title message:(id)message primaryActionTitle:(id)title completionHandler:(id /* block */)handler;
- (void)showRemoveInProgressRecordingAlertWithOperation:(unsigned long long)operation type:(unsigned long long)type attachments:(id)attachments completionHandler:(id /* block */)handler;
- (id)textAttachmentsInRange:(struct _NSRange)range;
- (void)updateBlockQuoteLayerForParagraphStyle:(id)style inRange:(struct _NSRange)range ioPreviousBlockQuoteRect:(struct CGRect *)rect;
- (void)updateMonostyledLayerForParagraphStyle:(id)style inRange:(struct _NSRange)range ioPreviousMonoRect:(struct CGRect *)rect ioPreviousBlockQuoteLevel:(unsigned long long *)level;
- (void)updateStyleLayersInRange:(struct _NSRange)range;
- (void)updateTypingAttributesWithSuperscript:(id /* block */)superscript;

@end


@interface ICTableAttachmentView : ICAttachmentView <ICTextPreviewProvider>

@property (retain, nonatomic) NSMutableArray *outsideViews;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)updateHighlights;
- (void)setupEventHandling;
- (void)sharedInit:(_Bool)init;

@end


@interface ICMacTableAttachmentView : ICTableAttachmentView

/* instance methods */
- (void)viewDidMoveToSuperview;
- (_Bool)isAccessibilityElement;
- (void)setHighlightColor:(id)color;
- (_Bool)isFlipped;
- (id)menuForEvent:(id)event;
- (void)setHidden:(_Bool)hidden;
- (void)viewDidMoveToWindow;
- (id)accessibilityChildren;
- (id)hitTest:(struct CGPoint)test;
- (_Bool)wantsDefaultClipping;
- (void)setHighlightPatternRegexFinder:(id)finder;
- (void)didChangeSize;
- (id)axTableElement;
- (id)icaxTypeDescription;
- (void)imageForTextPreviewUsingFindingResult:(id)result inTextView:(id)view completion:(id /* block */)completion;
- (void)sharedInit:(_Bool)init;
- (id)tableAttachmentViewController;

@end


@interface ICTableAttachmentViewController : ICAttachmentViewController <ICAttachmentFindable, ICTableAttachmentProviderDelegate, ICTableAutoScrollerDelegate, ICTableCellChangeObserving, ICTableDelegate, ICTTTextStorageDelegate, ICTableColumnTextViewDelegate, ICTableTextViewManagerDelegate, ICAvailableTableWidthProviding, ICTTTextUndoTarget, ICAuxiliaryStyling, ICTableSelectionDelegate, ICTableUndoHelping>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) ICTableAttachmentProvider *tableAttachmentProvider;
@property (retain, nonatomic) ICTableScrollView *scrollView;
@property (readonly, nonatomic) NSMutableDictionary *visibleEmptyCellsBeforeMerge;
@property (readonly, nonatomic) NSMutableOrderedSet *columnsBeforeMerge;
@property (readonly, nonatomic) NSMutableOrderedSet *rowsBeforeMerge;
@property (retain, nonatomic) ICTableAttachmentSelection *tableSelectionBeforeMerge;
@property (retain, nonatomic) NSArray *stringSelectionBeforeMerge;
@property (nonatomic) struct CGPoint initialDragOffset;
@property (nonatomic) unsigned long long currentDragIndex;
@property (retain, nonatomic) NSArray *stringSelectionBeforeDrag;
@property (retain, nonatomic) NSMutableArray *undoCommands;
@property (nonatomic) unsigned long long editingCount;
@property (nonatomic) struct CGPoint currentDragGestureLocation;
@property (readonly, nonatomic) NSMutableSet *columnsNeedingWidthUpdate;
@property (nonatomic) _Bool updatingTiles;
@property (nonatomic) _Bool didRecentlyAutoAddRow;
@property (nonatomic) unsigned long long lastDraggedOverColumnOrRowIndex;
@property (retain, nonatomic) ICTableAttachmentSelection *previousAXTableSelection;
@property (nonatomic) _Bool isPerformingInitialLayout;
@property (weak, nonatomic) ICLayoutManager *noteLayoutManager;
@property (weak, nonatomic) ICTK2TextLayoutManager *noteTextLayoutManager;
@property (nonatomic) double previousAvailableWidth;
@property (nonatomic) _Bool shouldPreventUndoCommands;
@property (retain, nonatomic) NSDictionary *cellTimestampsBeforeMerge;
@property (retain, nonatomic) ICAppearanceInfo *draggingAppearance;
@property (readonly, nonatomic) ICSelectorDelayer *saveDelayer;
@property (readonly, nonatomic) struct CGRect viewport;
@property (readonly, nonatomic) struct CGRect editingViewport;
@property (nonatomic) struct CGRect transitionViewport;
@property (readonly, nonatomic) ICTableAttachmentView *view;
@property (readonly, nonatomic) ICTableContentView *tableContentView;
@property (readonly, nonatomic) NSScrollView *noteScrollView;
@property (readonly, weak, nonatomic) NSObject<ICAuxiliaryTextViewHosting> *auxiliaryTextViewHost;
@property (readonly, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (retain, nonatomic) ICDimensionSumCache *columnWidthCache;
@property (retain, nonatomic) ICDimensionSumCache *rowHeightCache;
@property (readonly, nonatomic) NSMutableDictionary *cellHeightCache;
@property (readonly, nonatomic) ICTableClipView *headerClipView;
@property (retain, nonatomic) ICTableColumnRowButton *columnButton;
@property (retain, nonatomic) ICTableColumnRowButton *rowButton;
@property (readonly, nonatomic) ICTableSelectionView *selectionHighlightView;
@property (readonly, nonatomic) ICTableSelectionKnob *startKnob;
@property (readonly, nonatomic) ICTableSelectionKnob *endKnob;
@property (retain, nonatomic) NSUUID *rangeSelectionAnchorColumn;
@property (retain, nonatomic) NSUUID *rangeSelectionAnchorRow;
@property (retain, nonatomic) NSView *dragView;
@property (readonly, nonatomic) double scrollerOutset;
@property (nonatomic) _Bool performedInitialLayout;
@property (nonatomic) _Bool makingCellFirstResponder;
@property (nonatomic) struct CGRect proposedLineFragmentRect;
@property (retain, nonatomic) ICTableAccessibilityController *tableAXController;
@property (retain, nonatomic) ICTableAutoScroller *tableAutoScroller;
@property (readonly, nonatomic) ICTableTextViewManager *textViewManager;
@property (readonly, nonatomic) ICTable *table;
@property (readonly, nonatomic) ICTableColumnTextView *activeTextView;
@property (readonly, nonatomic) struct CGSize intrinsicSize;
@property (nonatomic) _Bool shouldBeginInitialEditing;
@property (retain, nonatomic) ICTTTextStorage *currentlyEditingTextStorage;
@property (retain, nonatomic) ICTableColumnTextView *currentlyEditingTextView;
@property (nonatomic) _Bool preventScrolling;
@property (readonly, nonatomic) _Bool isNoteEditable;
@property (readonly, nonatomic) ICMacBaseTextView *noteTextView;
@property (readonly, nonatomic) double availableWidth;
@property (readonly, nonatomic) _Bool canStyleText;
@property (readonly, nonatomic) _Bool canToggleTodo;
@property (readonly, nonatomic) NSIndexSet *selectedStyles;
@property (readonly, nonatomic) unsigned long long selectedStyleBIUS;
@property (nonatomic) _Bool lockSelection;
@property (readonly, weak, nonatomic) id <ICAuxiliaryStyling> auxiliaryStylingController;
@property (readonly, nonatomic) ICTableUndoTarget *undoTarget;
@property (readonly, nonatomic) NSUndoManager *undoManager;
@property (retain, nonatomic) ICTableAttachmentSelection *tableSelection;
@property (readonly, nonatomic) NSMapTable *coalescingUndoGroupForStringDelegate;

/* instance methods */
- (void)toggleUnderline:(id)underline;
- (void)commonInit;
- (void)toggleBoldface:(id)boldface;
- (void)toggleItalics:(id)italics;
- (id)account;
- (id)viewController;
- (void)loadView;
- (void)endEditing;
- (void)setHighlightColor:(id)color;
- (void)dealloc;
- (void)beginEditing;
- (void)save;
- (void)updateContentSize;
- (id)note;
- (void)removeFromParentViewController;
- (void)textStorage:(id)storage didProcessEditing:(unsigned long long)editing range:(struct _NSRange)range changeInLength:(long long)length;
- (void)setSelectionDirection:(long long)direction;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (_Bool)canIndent;
- (_Bool)wantsUndoCommands;
- (void)deleteSelection:(id)selection;
- (void)redraw;
- (void)contentSizeCategoryDidChange;
- (void)tableAttachmentSaveOnMainThread;
- (_Bool)allowsNewTextLength:(unsigned long long)length;
- (id)insertColumns:(unsigned long long)columns atIndex:(unsigned long long)index;
- (void)tableDidInsertColumnID:(id)id;
- (void)tableValueDidChangeAtColumnID:(id)id rowID:(id)id delta:(long long)delta;
- (void)tableWillRemoveColumnID:(id)id;
- (id)rectsForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)applyUndoGroup:(id)group;
- (void)scrollToRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setHighlightPatternRegexFinder:(id)finder;
- (void)drawCharactersInRange:(struct _NSRange)range inFindableString:(id)string forContentView:(id)view;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string inFindableString:(id)string;
- (void)saveAfterDelay;
- (struct _NSRange)selectedRangeWithinRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setSelectedRange:(struct _NSRange)range inFindableString:(id)string;
- (void)tableDidCreateColumnTextStorage:(id)storage;
- (void)tableDidPopulateCellAtColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (void)textStorage:(id)storage didReplace:(id)replace with:(id)with;
- (id)viewForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)copySelection:(id)selection;
- (void)cutSelection:(id)selection;
- (void)enableBoldface:(id)boldface;
- (struct CGRect)selectionFrameFromContentFrame:(struct CGRect)frame;
- (void)setSelectionBIUSStyle:(unsigned long long)biusstyle toggleOn:(_Bool)on;
- (void)updateHeightCacheForColumn:(id)column row:(id)row;
- (id)RTFDataForSelection;
- (void)disableItalics:(id)italics;
- (void)indentByamount:(long long)byamount;
- (_Bool)isUpdatingTiles;
- (void)moveCurrentColumnOrRow:(_Bool)row toIndex:(unsigned long long)index;
- (void)setTypingAttributesForTextView:(id)view;
- (_Bool)acceptsKeystrokes;
- (void)addColumnAfterSelection:(id)selection;
- (void)addColumnAtIndex:(unsigned long long)index;
- (void)addColumnBeforeSelection:(id)selection;
- (void)addRowAboveSelection:(id)selection;
- (void)addRowAtIndex:(unsigned long long)index;
- (void)addRowBelowSelection:(id)selection;
- (void)adjustScrollPositionByOffset:(struct CGPoint)offset;
- (void)announceCellRangeSelectionChangeForAccessibilityIfNecessary;
- (id)attributedStringForTableSelectionInContext:(id)context;
- (id)attributedStringFromPasteboard;
- (_Bool)becomeFirstResponderForAuxStyling;
- (void)beginEditingCellWithColumnID:(id)id andRowID:(id)id location:(unsigned long long)location;
- (void)beginEditingCellWithColumnID:(id)id andRowID:(id)id textRange:(id /* block */)range;
- (void)beginEditingCellWithColumnID:(id)id andRowID:(id)id touchPoint:(struct CGPoint)point;
- (void)beginEditingInitialCell;
- (void)beginEditingNoteAtOffset:(long long)offset;
- (void)beginEditingNoteAtRange:(struct _NSRange)range;
- (void)beginEditingSelectedRangeInTextView:(id)view;
- (_Bool)canIndentByamount:(long long)byamount;
- (_Bool)canOutdent;
- (void)cellFirstResponderChanged;
- (void)cellRangeDragBeganOnView:(id)view;
- (void)cellRangeDraggedAtLocation:(struct CGPoint)location;
- (struct _NSRange)characterRangeForRange:(struct _NSRange)range inString:(id)string forLayoutManager:(id)manager;
- (void)cleanDeletedColumn:(id)column;
- (void)cleanDeletedRow:(id)row;
- (struct _NSRange)columnGlyphRangeForRange:(struct _NSRange)range inString:(id)string forLayoutManager:(id)manager;
- (_Bool)containedInNoteSelection;
- (void)convertTableToText:(id)text;
- (void)convertUnconfirmedHashtagsMentionsIfNecessary;
- (void)copyTable:(id)table;
- (unsigned long long)cursorPositionForLocation:(struct CGPoint)location inTextView:(id)view;
- (_Bool)cursorPrefersWordBoundary;
- (id)customPasteboardDataForSelection;
- (id)dataForSelectionOfType:(id)type;
- (id)dataForSelectionWithDocumentAttributes:(id)attributes;
- (void)deleteColumns:(id)columns;
- (void)deleteRows:(id)rows;
- (void)deleteSelectedColumns:(id)columns;
- (void)deleteSelectedRows:(id)rows;
- (void)deleteSelectionCellContents;
- (void)deleteTable:(id)table;
- (void)didBeginEditingWithTextView:(id)view;
- (void)didPasteOrDropTextForTableColumnTextView:(id)view;
- (void)didUpdateContentSize;
- (void)disableBoldface:(id)boldface;
- (void)disableStrikethrough:(id)strikethrough;
- (void)disableUnderline:(id)underline;
- (void)dragBeganOnColumnOrRow:(_Bool)row atLocation:(struct CGPoint)location;
- (void)dragEndedOnColumnOrRow:(_Bool)row atLocation:(struct CGPoint)location;
- (void)dragMovedOnColumnOrRow:(_Bool)row atLocation:(struct CGPoint)location;
- (id)dragSnapshotFromRect:(struct CGRect)rect afterScreenUpdates:(_Bool)updates;
- (void)enableItalics:(id)italics;
- (void)enableStrikethrough:(id)strikethrough;
- (void)enableUnderline:(id)underline;
- (void)endCellEditingSessionWithTextView:(id)view;
- (void)extendCellRangeSelectionInDirection:(unsigned long long)direction toEnd:(_Bool)end;
- (void)flashAuthorHighlightsIfNeeded;
- (struct CGRect)frameOfCellForColumnTextView:(id)view row:(id)row;
- (void)hideColumnRowButtons;
- (id)htmlDataForSelection;
- (id)icTableDataForSelection;
- (id)icTableDataFromPasteboard;
- (id)icTableFromPasteboard;
- (void)ic_makeFirstResponder:(id)responder;
- (void)ic_resignFirstResponder:(id)responder;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering layoutManager:(id)manager;
- (id)initWithTextAttachment:(id)attachment forManualRendering:(_Bool)rendering textLayoutManager:(id)manager;
- (void)initializeTableAccessibilityControllerIfNecessary;
- (void)initializeTableLayout;
- (_Bool)isInResponderChain;
- (void)makeDelegateOfTextView:(id)view;
- (_Bool)makeSpaceToPasteSourceTable:(id)table;
- (void)moveDownCell;
- (void)moveDownCellAtLocation:(unsigned long long)location;
- (void)moveIntoTableWithDirection:(unsigned long long)direction;
- (void)moveLeftCell;
- (void)moveNextCell;
- (void)moveNextCellAtLocation:(unsigned long long)location;
- (void)moveNextLineAtLocation:(unsigned long long)location;
- (void)movePrevCell;
- (void)movePrevCellAtLocation:(unsigned long long)location;
- (void)moveReturnCell;
- (void)moveRightCell;
- (void)moveShiftReturnCell;
- (void)moveTabCell;
- (void)moveUpCell;
- (void)moveUpCellAtLocation:(unsigned long long)location;
- (id)namedStylesForCurrentSelectionAndBIUS:(unsigned long long *)bius;
- (id)namedStylesForCurrentSelectionAndBIUS:(unsigned long long *)bius emphasisColorType:(long long *)type;
- (id)notesDataFromPasteboard;
- (_Bool)pasteCellRange;
- (void)pasteIntoSelection:(id)selection;
- (void)pasteTable:(id)table atColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index shouldSetSelectionToPastedRange:(_Bool)range;
- (id)pasteboardItemsForSelection;
- (void)performInitialLayoutIfNeeded;
- (id)plainTextDataForSelection;
- (void)populateAllRowsAndColumnsForPrinting;
- (void)postChangeNotification:(unsigned long long)notification columnOrRowUUIDs:(id)uuids;
- (unsigned long long)preferredNavigationSelection;
- (void)prepareForPrinting;
- (void)redrawAndSave;
- (_Bool)resignFirstResponderForAuxStyling;
- (void)reverseTableColumnDirection:(id)direction;
- (void)saveAttachmentChanges;
- (void)saveAttachmentChangesInBackground:(_Bool)background;
- (void)saveOnMainThread;
- (void)scrollToCaretIfNeededForTextView:(id)view;
- (void)scrollToRect:(struct CGRect)rect animated:(_Bool)animated completion:(id /* block */)completion;
- (void)scrollToSelectionInTextView:(id)view animated:(_Bool)animated completion:(id /* block */)completion;
- (void)selectCurrentColumnForAccessibility;
- (void)selectCurrentRowForAccessibility;
- (void)selectTable;
- (void)selectionDidResignFirstResponder:(id)responder;
- (void)selectionWillBecomeFirstResponder:(id)responder;
- (void)setHidden:(_Bool)hidden forColumn:(id)column;
- (void)setHidden:(_Bool)hidden forRow:(id)row;
- (void)setNeedsSaveAfterUserEdit;
- (void)setSelectionAlignment:(long long)alignment;
- (void)setSelectionBIUSStyle:(unsigned long long)biusstyle toggleOn:(_Bool)on onValue:(id)value;
- (void)setSelectionBIUSStyle:(unsigned long long)biusstyle toggleOn:(_Bool)on onValue:(id)value withSelection:(id)selection;
- (void)setSelectionNamedStyle:(unsigned int)style;
- (void)setSelectionNamedStyle:(unsigned int)style withColumns:(id)columns rows:(id)rows;
- (void)setTextStyleForCurrentSelection:(unsigned int)selection;
- (void)setupEventHandling;
- (void)setupTableTextView:(id)view;
- (void)shareTable:(id)table;
- (void)showButtonsAtColumns:(id)columns rows:(id)rows;
- (void)showColumnRowButtons;
- (id)soloPlainTextStringFromPasteboard;
- (void)speakAccessibilityAnnouncementForMoveToCellWithColumnID:(id)id rowID:(id)id;
- (void)speakAccessibilityExitedTableAnnouncementAndDidRemoveRow:(_Bool)row;
- (void)tableAttachmentDidChange;
- (void)tableAttachmentProviderDidMergeTable:(id)table;
- (void)tableAttachmentProviderWillMergeTable:(id)table;
- (void)tableAttachmentSelectionDidChange:(id)change;
- (void)tableAttachmentViewControllerDidChange:(id)change;
- (void)tableAttachmentWillChange;
- (void)tableAutoScroller:(id)scroller scrollOffsetDelta:(struct CGPoint)delta;
- (void)tappedTableAtLocation:(struct CGPoint)location;
- (long long)textAlignmentForCurrentSelection;
- (long long)textDirectionForCurrentSelection;
- (void)textRangeDragEnded;
- (void)textRangeDraggedAtLocation:(struct CGPoint)location;
- (void)toggleBIUS:(unsigned long long)bius;
- (void)toggleBIUS:(unsigned long long)bius onValue:(id)value;
- (void)toggleEmphasis:(id)emphasis onValue:(id)value;
- (void)toggleStrikethrough:(id)strikethrough;
- (void)toggleTodoStyle:(id)style;
- (void)unselectColumnRow;
- (_Bool)updateAllColumnWidths;
- (void)updateAllColumnWidthsAndRedraw;
- (void)updateAttachmentParagraphForWritingDirection:(long long)direction;
- (void)updateAvailableWidth;
- (void)updateButtonFrames;
- (void)updateCellSizeAtColumn:(id)column row:(id)row immediateWidthUpdate:(_Bool)update;
- (void)updateChrome;
- (void)updateColumnWidthForColumn:(id)column;
- (_Bool)updateEditedColumnWidths;
- (void)updateEditedColumnWidthsAfterDelay;
- (void)updateTableCellsWithDirection:(long long)direction columnIndexes:(id)indexes rowIndexes:(id)indexes;
- (void)updateTableColumnDirectionForWritingDirection:(long long)direction;
- (void)updateTiles;
- (void)updateWidthsForChangeInColumn:(id)column;
- (id)webArchiveDataForSelection;
- (void)willAddRow;
- (void)willBeginEditingWithTextView:(id)view;
- (void)willFlashAuthorHighlights;
- (void)zoomFactorOrInsetsDidChange;

@end


@interface ICMacTableAttachmentViewController : ICTableAttachmentViewController <NSTextViewDelegate, NSLayoutManagerDelegate, NSGestureRecognizerDelegate, NSMenuItemValidation, ICMTableAttachmentTouchBarControllerDelegate, NSTextLayoutManagerDelegate>

@property (retain, nonatomic) ICMTableAttachmentTouchBarController *tableTouchBarController;
@property (retain, nonatomic) ICMTableAttachmentTouchBarController *textViewTouchBarController;
@property (readonly, nonatomic) _Bool dfrBIUEnabled;
@property (retain, nonatomic) ICTableColumnTextView *activeTextView;
@property (nonatomic) unsigned long long textSelectionAnchorIndex;
@property (nonatomic) _Bool isSelectingTextWithMouse;
@property (nonatomic) struct CGPoint previousViewOrigin;
@property (nonatomic) unsigned long long menuTemporarySelectedBIUS;
@property (retain, nonatomic) NSIndexSet *menuTemporarySelectedStyles;
@property (nonatomic) _Bool isChangingFont;
@property (nonatomic) _Bool isChangingTypingAttributeFontByFontPanel;
@property (retain, nonatomic) ICMSidebarController *sidebarController;
@property (readonly, nonatomic) ICMNoteEditorController *noteEditorController;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)keyPathsForValuesAffectingTouchBar;
+ (id)keyPathsForValuesAffectingDfrBIUEnabled;
+ (id)keyPathsForValuesAffectingNoteEditorController;

/* instance methods */
- (void)alignLeft:(id)left;
- (void)alignRight:(id)right;
- (id)touchBar;
- (void)alignCenter:(id)center;
- (_Bool)validateMenuItem:(id)item;
- (void)windowDidResize:(id)resize;
- (void)alignJustified:(id)justified;
- (_Bool)gestureRecognizer:(id)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)recognizer;
- (_Bool)gestureRecognizer:(id)recognizer shouldBeRequiredToFailByGestureRecognizer:(id)recognizer;
- (void)viewDidAppear;
- (void)textDidChange:(id)change;
- (void)viewDidLoad;
- (void)setTextStyle:(id)style;
- (_Bool)gestureRecognizer:(id)recognizer shouldRequireFailureOfGestureRecognizer:(id)recognizer;
- (void)loadView;
- (void)viewDidLayout;
- (void)dealloc;
- (void)layoutManager:(id)manager didCompleteLayoutForTextContainer:(id)container atEnd:(_Bool)end;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)textView:(id)view menu:(id)menu forEvent:(id)event atIndex:(unsigned long long)index;
- (void)addFontTrait:(id)trait;
- (void)changeColor:(id)color;
- (void)changeFont:(id)font;
- (_Bool)gestureRecognizer:(id)recognizer shouldAttemptToRecognizeWithEvent:(id)event;
- (void)makeBaseWritingDirectionLeftToRight:(id)right;
- (void)makeBaseWritingDirectionNatural:(id)natural;
- (void)makeBaseWritingDirectionRightToLeft:(id)left;
- (void)scrollWheel:(id)wheel;
- (void)textDidEndEditing:(id)editing;
- (_Bool)textShouldBeginEditing:(id)editing;
- (id)textView:(id)view shouldChangeTypingAttributes:(id)attributes toAttributes:(id)attributes;
- (id)textView:(id)view willChangeSelectionFromCharacterRanges:(id)ranges toCharacterRanges:(id)ranges;
- (id)textView:(id)view willDisplayToolTip:(id)tip forCharacterAtIndex:(unsigned long long)index;
- (id)textView:(id)view willShowSharingServicePicker:(id)picker forItems:(id)items;
- (void)textViewDidChangeSelection:(id)selection;
- (void)underline:(id)underline;
- (void)viewDidDisappear;
- (void)viewFrameChanged:(id)changed;
- (void)viewWillLayout;
- (void)deleteSelection:(id)selection;
- (void)applyUndoGroup:(id)group;
- (void)accentColorDidChange:(id)change;
- (void)strikethrough:(id)strikethrough;
- (void)copySelection:(id)selection;
- (void)cutSelection:(id)selection;
- (struct CGRect)editingViewport;
- (void)tableDidScroll:(id)scroll;
- (void)adjustScrollPositionByOffset:(struct CGPoint)offset;
- (id)auxiliaryTextViewHost;
- (unsigned long long)beginEditingAtLocation:(struct CGPoint)location;
- (id)beginEditingForSelectionView:(id)view;
- (void)beginEditingNoteAtRange:(struct _NSRange)range;
- (_Bool)canStyleText;
- (void)cellFirstResponderChanged;
- (unsigned long long)characterIndexForPoint:(struct CGPoint)point columnID:(id *)id rowID:(id *)id;
- (void)clearAutoCompletionView;
- (void)columnButtonPressed:(id)pressed;
- (void)columnRowDisclosurePressed:(id)pressed;
- (void)convertUnconfirmedHashtagsMentionsIfNecessary;
- (void)currentRowSelected;
- (id)currentStylesAndBIUS:(unsigned long long *)bius forTouchBarController:(id)controller;
- (_Bool)cursorPrefersWordBoundary;
- (void)didClickEmptyTable:(id)table;
- (void)didUpdateContentSize;
- (void)dragCellRange:(id)range;
- (id)dragSnapshotFromRect:(struct CGRect)rect afterScreenUpdates:(_Bool)updates;
- (void)draggedColumnOrRow:(id)row;
- (void)emphasis:(id)emphasis;
- (void)endCellEditingSessionWithTextView:(id)view;
- (void)fontPanelDidChangeFont:(id)font;
- (void)fontPanelWillChangeFont:(id)font;
- (void)handleFontChangeWithBlock:(id /* block */)block;
- (id)icTableDataFromPasteboard;
- (void)ic_makeFirstResponder:(id)responder;
- (void)ic_resignFirstResponder:(id)responder;
- (_Bool)isAutoCompletionViewVisible;
- (void)makeDelegateOfTextView:(id)view;
- (void)mouseUpOnTextView:(id)view;
- (id)noteScrollView;
- (id)notesDataFromPasteboard;
- (void)pasteIntoSelection:(id)selection;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)performInitialLayoutIfNeeded;
- (unsigned long long)preferredNavigationSelection;
- (void)preferredScrollerStyleChanged:(id)changed;
- (void)rowButtonPressed:(id)pressed;
- (void)scrollToCaretIfNeededForTextView:(id)view;
- (void)scrollToRect:(struct CGRect)rect animated:(_Bool)animated completion:(id /* block */)completion;
- (double)scrollerOutset;
- (void)selectCurrentColumnForAccessibility;
- (void)selectCurrentRowForAccessibility;
- (void)selectItemFromAutoCompletionMenu;
- (void)setTextViewWritingDirection:(long long)direction;
- (void)setupColumnRowButtons;
- (void)setupColumnRowButtonsAccessibility;
- (void)setupColumnRowButtonsEventHandling;
- (void)setupEventHandling;
- (void)setupTableTextView:(id)view;
- (void)shiftSelectCellRange:(id)range;
- (void)showButtonsAtColumns:(id)columns rows:(id)rows;
- (id)soloPlainTextStringFromPasteboard;
- (void)splitViewDidResize:(id)resize;
- (void)tableAttachmentDidChange;
- (void)tableAttachmentSelectionDidChange:(id)change;
- (void)textView:(id)view mouseDown:(id)down;
- (id)textView:(id)view selectedRanges:(id)ranges withLocation:(struct CGPoint)location stillSelecting:(_Bool)selecting;
- (void)touchBarController:(id)controller biuButtonPressedWithStyle:(unsigned long long)style toggleOn:(_Bool)on;
- (void)unselectColumnRow;
- (void)updateAccentColor;
- (void)updateChrome;
- (void)updateTableTouchBarControllerIfNecessary;
- (void)willBeginEditingWithTextView:(id)view;

@end


@interface ICMacTextContainer : NSTextContainer

/* instance methods */
- (_Bool)containsPoint:(struct CGPoint)point;

@end


@interface ICMacTextView : ICMacBaseTextView <ICNoteMergeObserver, QLPreviewPanelDataSource, NSLayoutManagerDelegate, ICTextControllerDelegate, ICMFilePromiseHelperDelegate, NSMenuItemValidation, ICTTTextStorageScrollClampingDelegate>

@property (nonatomic) struct CGRect savedVisibleRect;
@property (nonatomic) struct _NSRange savedSelectedRange;
@property (nonatomic) _Bool isEndingLiveResize;
@property (nonatomic) struct _NSRange visibleCharacterRangeBeforeResize;
@property (retain, nonatomic) NSTextRange *visibleTextRangeBeforeResize;
@property (nonatomic) struct CGSize previousValueOfDocumentSizeInPage;
@property (copy, nonatomic) NSNumber *previousValueOfWrappingToFit;
@property (retain, nonatomic) NSArray *quickLookAttachments;
@property (retain, nonatomic) NSClickGestureRecognizer *clickBetweenAttachmentViewsGestureRecognizer;
@property (retain, nonatomic) NSClickGestureRecognizer *emptyNoteEditorClickGestureRecognizer;
@property (retain, nonatomic) NSPressGestureRecognizer *checklistDragLongPressGestureRecognizer;
@property (retain, nonatomic) ICMacTextViewGestureRecognizerDelegate *gestureRecognizerDelegate;
@property (retain, nonatomic) NSArray *dragAttachments;
@property (retain, nonatomic) NSLayoutConstraint *baselineConstraint;
@property (readonly, nonatomic) NSObject<NSTextFinderClient> *textFinderClient;
@property (retain, nonatomic) ICNAFindResultExposureReporter *findResultReporter;
@property (retain, nonatomic) ICMFilePromiseHelper *filePromiseHelper;
@property (nonatomic) _Bool isDraggingChecklistItem;
@property (retain, nonatomic) ICTrackedParagraph *draggedChecklistTrackedParagraph;
@property (retain, nonatomic) ICTrackedParagraph *trackedParagraphCurrentlyUnderDraggedChecklist;
@property (nonatomic) _Bool isDraggingOverChecklistItem;
@property (nonatomic) _Bool isDraggingChecklistFromDifferentNote;
@property (retain, nonatomic) CALayer *checklistDragInsertionLayer;
@property (weak, nonatomic) ICMacTextView *originatingChecklistDragTextview;
@property (nonatomic) _Bool isHitTestingForDragging;
@property (retain, nonatomic) NSArray *compatBannerLayoutContraints;
@property (copy, nonatomic) id /* block */ observeAttributionsDispatchBlock;
@property (nonatomic) _Bool isTemporarilyPausingSpellCheck;
@property (nonatomic) _Bool suppressAccessibilitySelectedTextChangedNotifications;
@property (weak, nonatomic) id <ICMacTextViewEditorDelegate> editorDelegate;
@property (weak, nonatomic) id <ICAttachmentViewDelegate> attachmentViewDelegate;
@property (retain, nonatomic) ICMNoteEditorDateView *dateView;
@property (retain, nonatomic) ICMNoteEditorCompatibilityBannerView *compatibilityBannerView;
@property (readonly, nonatomic) _Bool isFindBarVisible;
@property (readonly, nonatomic) _Bool isFindBarFirstResponder;
@property (nonatomic) _Bool matchFrameToClipView;
@property (nonatomic) _Bool shouldLockScrollWhenFixupAfterEditingAtEndOfRunLoop;
@property (readonly, nonatomic) NSTextFinder *textFinder;
@property (nonatomic) struct CGSize originalPrintingSize;
@property (retain, nonatomic) ICMPrintPanelAccessoryController *printPanelAccessoryController;
@property (retain, nonatomic) ICSharedScrollClampingController *scrollClampingController;
@property (readonly, nonatomic) ICMSidebarController *attributionSidebarController;
@property (readonly, nonatomic) ICMAttributionsViewController *attributionsViewController;
@property (readonly, copy, nonatomic) NSString *toggleAttributionSidebarHiddenMenuItemTitle;
@property (readonly, nonatomic) _Bool isCompatibilityBannerShowing;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;
+ (void)overrideMouseMethodsIfNecessary;
+ (void)enablePaperKitAttachmentViews;

/* instance methods */
- (void)doCommandBySelector:(SEL)selector;
- (void)setTextContainer:(id)container;
- (_Bool)validateMenuItem:(id)item;
- (void)didBeginWritingToolsSession:(id)session contexts:(id)contexts;
- (void)writingToolsSession:(id)session didReceiveAction:(long long)action;
- (void)copy:(id)copy;
- (_Bool)resignFirstResponder;
- (void)cut:(id)cut;
- (_Bool)becomeFirstResponder;
- (void)setFrame:(struct CGRect)frame;
- (void)insertNewline:(id)newline;
- (void)adjustWritingDirectionIfNeeded;
- (void)layout;
- (void)keyDown:(id)down;
- (id)previewPanel:(id)panel previewItemAtIndex:(long long)index;
- (void)endPreviewPanelControl:(id)control;
- (long long)numberOfPreviewItemsInPreviewPanel:(id)panel;
- (void)insertTab:(id)tab;
- (_Bool)acceptsPreviewPanelControl:(id)control;
- (void)didEndWritingToolsSession:(id)session accepted:(_Bool)accepted;
- (void)dealloc;
- (_Bool)supportsAttachments;
- (id)accessibilityIdentifier;
- (id)initWithFrame:(struct CGRect)frame;
- (void)setEditable:(_Bool)editable;
- (void)layoutManager:(id)manager didCompleteLayoutForTextContainer:(id)container atEnd:(_Bool)end;
- (void)beginPreviewPanelControl:(id)control;
- (id)initWithCoder:(id)coder;
- (void)delete:(id)_delete;
- (_Bool)knowsPageRange:(struct _NSRange *)range;
- (id)accessibilityActionDescription:(id)description;
- (void)deleteBackward:(id)backward;
- (void)toggleAutomaticTextReplacement:(id)replacement;
- (unsigned long long)_insertionCharacterIndexForDrag:(id)drag;
- (id)acceptableDragTypes;
- (id)accessibilityActionNames;
- (id)accessibilityAttributedStringForRange:(struct _NSRange)range;
- (id)accessibilityChildren;
- (id)accessibilityElementForAttachment:(id)attachment;
- (void)accessibilityPerformAction:(id)action;
- (_Bool)accessibilityPerformShowMenu;
- (void)accessibilityPostNotification:(id)notification withNotificationElement:(id)element;
- (void)adjustPageHeightNew:(double *)_new top:(double)top bottom:(double)bottom limit:(double)limit;
- (struct CGRect)adjustScroll:(struct CGRect)scroll;
- (void)changeFont:(id)font;
- (void)cursorUpdate:(id)update;
- (void)deleteWordBackward:(id)backward;
- (id)dragImageForSelectionWithEvent:(id)event origin:(struct CGPoint *)origin;
- (unsigned long long)dragOperationForDraggingInfo:(id)info type:(id)type;
- (_Bool)dragSelectionWithEvent:(id)event offset:(struct CGSize)offset slideBack:(_Bool)back;
- (void)draggingEnded:(id)ended;
- (unsigned long long)draggingEntered:(id)entered;
- (unsigned long long)draggingUpdated:(id)updated;
- (void)drawDragInsertionIndicatorWithRect:(struct CGRect)rect;
- (id)firstResponderWhenDeactivated;
- (id)initWithFrame:(struct CGRect)frame textContainer:(id)container;
- (void)insertBacktab:(id)backtab;
- (void)insertTabIgnoringFieldEditor:(id)editor;
- (void)insertText:(id)text replacementRange:(struct _NSRange)range;
- (void)insertTextPlaceholderAtLocation:(id)location length:(double)length animated:(_Bool)animated completion:(id /* block */)completion;
- (void)makeBaseWritingDirectionLeftToRight:(id)right;
- (void)makeBaseWritingDirectionNatural:(id)natural;
- (void)makeBaseWritingDirectionRightToLeft:(id)left;
- (void)mouseMoved:(id)moved;
- (void)moveLeft:(id)left;
- (void)moveRight:(id)right;
- (void)moveWordLeft:(id)left;
- (void)moveWordRight:(id)right;
- (_Bool)performDragOperation:(id)operation;
- (void)performTextFinderAction:(id)action;
- (_Bool)readSelectionFromPasteboard:(id)pasteboard type:(id)type;
- (id)readablePasteboardTypes;
- (id)rectsForCharacterRange:(struct _NSRange)range;
- (void)removeTextPlaceholderAnimated:(_Bool)animated completion:(id /* block */)completion;
- (void)setSelectedRanges:(id)ranges affinity:(unsigned long long)affinity stillSelecting:(_Bool)selecting;
- (id)sharingServicePicker:(id)picker sharingServicesForItems:(id)items mask:(unsigned long long)mask proposedSharingServices:(id)services;
- (struct _NSRange)smartDeleteRangeForProposedRange:(struct _NSRange)range;
- (void)toggleAutomaticDashSubstitution:(id)substitution;
- (void)toggleAutomaticDataDetection:(id)detection;
- (void)toggleAutomaticLinkDetection:(id)detection;
- (void)toggleAutomaticQuoteSubstitution:(id)substitution;
- (void)toggleAutomaticSpellingCorrection:(id)correction;
- (void)toggleContinuousSpellChecking:(id)checking;
- (void)toggleGrammarChecking:(id)checking;
- (void)toggleQuickLookPreviewPanel:(id)panel;
- (void)toggleSmartInsertDelete:(id)_delete;
- (void)underline:(id)underline;
- (void)updateTextTouchBarItems;
- (unsigned long long)validModesForFontPanel:(id)panel;
- (void)viewDidEndLiveResize;
- (void)viewWillStartLiveResize;
- (id)writablePasteboardTypes;
- (_Bool)writeSelectionToPasteboard:(id)pasteboard type:(id)type;
- (id)persistenceHelper;
- (void)unclampTextView;
- (void)clampTextView;
- (void)didEndPostLayoutFixupAfterEditing;
- (_Bool)isLinkAcceleratorShowing;
- (void)strikethrough:(id)strikethrough;
- (void)textControllerDidHandleSpecialCaseEditing:(id)editing;
- (void)textStorageDidPerformMerge:(id)merge;
- (void)textStorageWillPerformMerge:(id)merge;
- (void)willBeginPostLayoutFixupAfterEditing;
- (void)copyAsMarkdown:(id)markdown;
- (id)markdownDataForSelectionOfType:(id)type;
- (void)textViewWillBeginChecklistDrag:(id)drag;
- (void)beginQuickLook:(id)look;
- (id)filePathsForSelectedAttachments;
- (id)markdownForHTMLDataForSelection;
- (void)toggleAttributionSidebarHidden:(id)hidden;
- (void)_icaxAddParticipantEditHighlightsToString:(id)string forRange:(struct _NSRange)range;
- (void)_icaxAddPrettifiedMathematicalSymbolsToString:(id)string forRange:(struct _NSRange)range;
- (void)_icaxAddStyleAttributesToString:(id)string forRange:(struct _NSRange)range;
- (void)_icaxAddTodoProxyAttachmentElementsToString:(id)string forRange:(struct _NSRange)range;
- (id)_icaxAllTodoButtonCells;
- (id)_icaxParagraphStringForTodoInRange:(struct _NSRange)range;
- (id)_icaxProxyAttachmentElementForTodo:(id)todo;
- (void)addChecklistDragLongPressGestureRecognizer;
- (void)addClickBetweenAttachmentViewsGestureRecognizer;
- (void)addEmptyNoteEditorClickGestureRecognizer;
- (id)attachmentViewForViewIfExists:(id)exists;
- (void)attachmentWasDeleted:(id)deleted;
- (void)beginDragForChecklistButton:(id)button;
- (void)beginDragForTrackedChecklistParagraph:(id)paragraph sender:(id)sender;
- (void)beginEditingNewNoteForAccessibilityIfNecessary;
- (_Bool)canDragChecklistAtPoint:(struct CGPoint)point outTrackedParagraph:(id *)paragraph;
- (void)commonMacTextViewInit;
- (void)customDeleteBackwardWithBlock:(id /* block */)block;
- (void)customDeleteWordBackwardWithBlock:(id /* block */)block;
- (id)customPasteboardMarkdownDataForSelection;
- (void)didClickBetweenAttachments:(id)attachments;
- (void)didClickEmptyNoteEditor:(id)editor;
- (void)didLongPressForChecklistDrag:(id)drag;
- (void)didMoveInDirection:(unsigned long long)direction previousSelectedRanges:(id)ranges;
- (void)drawChecklistDragInsertionIndicatorForTrackedTodoParagraph:(id)paragraph drawAbove:(_Bool)above;
- (void)emphasis:(id)emphasis;
- (void)filePromiseHelper:(id)helper didRecieveFiles:(id)files dropPoint:(struct CGPoint)point;
- (void)filePromiseHelperDidCancel:(id)cancel;
- (void)handleChecklistDragForDraggingInfo:(id)info dragOperation:(unsigned long long)operation resultValue:(_Bool *)value operationHandled:(_Bool *)handled;
- (void)hideCompatibilityBanner;
- (id)icTextLayoutManager;
- (id)icaxFirstAttachmentInRange:(struct _NSRange)range;
- (void)icaxPostSilentValueChangedNotification;
- (_Bool)icaxTodoItemProxyElementWasPressed:(id)pressed;
- (_Bool)icaxToggleTodoWithAnnouncementForRange:(struct _NSRange)range;
- (void)insertAttachmentFromData:(id)data fileName:(id)name dropPoint:(struct CGPoint)point;
- (void)insertAttachmentsFromURLs:(id)urls dropPoint:(struct CGPoint)point;
- (void)insertAttachmentsFromURLs:(id)urls insertionIndex:(unsigned long long)index;
- (_Bool)isBetweenAttachmentsForWindowLocation:(struct CGPoint)location outCharIndex:(unsigned long long *)index;
- (_Bool)isFilePromiseDrag:(id)drag;
- (_Bool)isUnsupportedDrag:(id)drag;
- (void)linkAcceleratorDidHide:(id)hide;
- (void)linkAcceleratorDidShow:(id)show;
- (void)loadUserTextViewOptions;
- (id)markdownDataForSelectionWithDocumentAttributes:(id)attributes;
- (id)markdownForMarkdownDataForSelection;
- (id)markdownForPlainTextDataForSelection;
- (id)markdownForRTFDataForSelection;
- (id)markdownForWebArchiveDataForSelection;
- (id)markdownPasteboardItemsForSelection;
- (_Bool)needToWriteFilePathsToPasteboard;
- (_Bool)needToWriteFilePromisesToPasteboard;
- (void)openPKAttachmentIfPossible:(id)possible;
- (id)preferredPasteboardTypeFromArray:(id)array restrictedToTypesFromArray:(id)array fromPasteboard:(id)pasteboard;
- (void)prepareForCrossWindowChecklistDrop;
- (id)quickLookableAttachmentsFromAttachments:(id)attachments;
- (_Bool)readPaperKitArchiveFromPasteboard:(id)pasteboard;
- (void)removeFromTextStorage;
- (void)resetScrollLockingFlags;
- (void)setCurrentTodoItemCompleted:(_Bool)completed;
- (void)setSelectedRangeToEndOfTodoTrackedParagraph:(id)paragraph;
- (void)setupTextViewDateField;
- (void)setupTextViewLayout;
- (_Bool)shouldSuppressCursorChangeForEvent:(id)event;
- (void)showCompatibilityBanner;
- (void)speakAccessibilityAutoListItemIfNecessary;
- (void)textViewDidEndChecklistDrag:(id)drag;
- (void)toggleAutomaticListInsertion:(id)insertion;
- (void)toggleAutomaticTagDetection:(id)detection;
- (unsigned long long)totalSelectionLength;
- (void)updateAttributionsSidebar;
- (void)updateCompatibilityBannerForNote:(id)note;
- (void)updateQuickLookAttachments;
- (void)updateQuickLookAttachmentsIfNecessary;
- (void)updateTextViewDateFieldConstraint;
- (id)visibleTopLevelAttachmentsInNote;
- (void)writeAttachmentFilePathsToPasteboard:(id)pasteboard;
- (void)writeFilePromisesToPasteboard:(id)pasteboard;

@end


@interface ICMacTextViewGestureRecognizerDelegate : NSObject <NSGestureRecognizerDelegate>

@property (weak, nonatomic) ICMacTextView *textView;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)gestureRecognizer:(id)recognizer shouldBeRequiredToFailByGestureRecognizer:(id)recognizer;
- (id)initWithTextView:(id)view;
- (_Bool)gestureRecognizer:(id)recognizer shouldReceiveTouch:(id)touch;
- (_Bool)gestureRecognizer:(id)recognizer shouldAttemptToRecognizeWithEvent:(id)event;

@end


@interface ICMacTextViewPrintingUtilities : NSObject

/* class methods */
+ (double)defaultTextPadding;
+ (void)doForegroundLayoutForTextView:(id)view;
+ (struct CGSize)documentSizeForPrintInfo:(id)info;

@end


@interface ICMacTextViewTodoItemProxyElement : NSAccessibilityElement <NSAccessibilityButton>

@property (nonatomic) ICMacTextView *textView;
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

@end


@interface ICMovieAttachmentView : ICImageAttachmentView <NSAccessibilityGroup>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) CALayer *playButtonLayer;
@property (retain, nonatomic) NSImage *playButtonImage;
@property (nonatomic) struct CGRect playButtonFrame;
@property (nonatomic) _Bool playerWasVisibleDuringMouseDown;
@property (nonatomic) _Bool icaxIsShowingPlayer;

/* instance methods */
- (void)removeFromSuperview;
- (id)accessibilityChildren;
- (id)accessibilityHelp;
- (_Bool)accessibilityPerformPress;
- (id)placeholderImageSystemName;
- (void)didChangeAttachment;
- (void)didChangeMedia;
- (void)willDeleteAttachment;
- (void)updateImageSize;
- (void)_selectAttachmentViewWithPoint:(struct CGPoint)point flags:(unsigned long long)flags;
- (void)didTapAttachment:(id)attachment;
- (id)icaxTypeDescription;
- (void)makePlayerViewFirstResponderIfNecessary;
- (_Bool)pointIsOverPlayButton:(struct CGPoint)button;
- (void)setShowLoadingImage:(_Bool)image;
- (void)sharedInit:(_Bool)init;
- (_Bool)shouldIncludeAttachmentTitleInAXLabel;

@end


@interface ICMovieController : NSObject <NSGestureRecognizerDelegate>

@property (retain, nonatomic) AVAsset *activeAsset;
@property (retain, nonatomic) NSPressGestureRecognizer *touchEaterGestureRecognizer;
@property (retain, nonatomic) AVPlayerView *moviePlayerView;
@property (retain, nonatomic) ICMovieAttachmentView *activeMovieAttachmentView;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedController;
+ (void)pauseIfPlaying;
+ (void)stopIfPlaying;

/* instance methods */
- (_Bool)gestureRecognizer:(id)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)recognizer;
- (_Bool)gestureRecognizer:(id)recognizer shouldBeRequiredToFailByGestureRecognizer:(id)recognizer;
- (void)dealloc;
- (void)play;
- (void)pauseIfPlaying;
- (void)moviePlayerTapped;
- (_Bool)prepareForPlayback;
- (void)stopIfPlaying;
- (void)touchEaterRecognized:(id)recognized;
- (_Bool)touchEaterShouldPermitOtherGestureRecognizer:(id)recognizer;
- (void)updatePlayer;

@end


@interface ICNoteBaseUserActivityState : NSObject

@property (retain, nonatomic) CSSearchableItemAttributeSet *attributeSet;
@property (readonly, copy, nonatomic) NSDictionary *contentAttributes;

/* instance methods */
- (id)initWithNote:(id)note;
- (void)updateUserActivity:(id)activity;

@end


@interface ICNoteDateFormatterController : NSObject

@property (retain, nonatomic) NSDateFormatter *dateFormatter;
@property (retain, nonatomic) NSDateFormatter *shortDateFormatter;
@property (retain, nonatomic) NSDate *date;
@property (nonatomic) long long currentSortType;
@property (nonatomic) _Bool didManuallyChangeDateType;
@property (nonatomic) _Bool showAlternateDateView;
@property (readonly, nonatomic) _Bool shouldShowDateModified;
@property (nonatomic) _Bool shouldShowSharedNoteTitle;
@property (nonatomic) _Bool iconHidden;
@property (weak, nonatomic) id <ICNoteDateFormatterControllerDelegate> delegate;
@property (weak, nonatomic) ICNote *note;

/* instance methods */
- (void)setUp;
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)updateDate;
- (id)dateStringForDate:(id)date dateFormatter:(id)formatter;
- (void)noteDecryptedStatusDidChange:(id)change;
- (void)timeFormatChanged:(id)changed;
- (void)toggleVisibleDateType;
- (void)updateDateLabelAccessibilityHint;
- (void)updateLockIcon;

@end


@interface ICNoteUserActivityState : ICNoteBaseUserActivityState

@property (copy, nonatomic) NSString *noteID;
@property (copy, nonatomic) NSDate *modificationDate;
@property (copy, nonatomic) NSDate *creationDate;
@property (nonatomic) _Bool editing;
@property (nonatomic) _Bool wantsContinuationStreams;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSData *contentHash;
@property (copy, nonatomic) NSString *folderID;
@property (copy, nonatomic) NSString *folderName;
@property (retain, nonatomic) ICTextViewScrollState *scrollState;
@property (nonatomic) struct _NSRange visibleRange;
@property (copy, nonatomic) NSData *visibleRangeData;
@property (nonatomic) struct _NSRange selectionRange;
@property (copy, nonatomic) NSData *selectionRangeData;

/* instance methods */
- (_Bool)isEditing;
- (id)initWithNote:(id)note;
- (void)updateUserActivity:(id)activity;

@end


@interface ICOutlineRenderer : NSObject

@property (nonatomic, readonly) ICOutlineController *outlineController;
@property (nonatomic) _Bool selectionVisibilityRequiresEditing;
@property (nonatomic, readonly) long long collapsibleSectionAffordanceExposures;
@property (nonatomic, readonly) long long collapsibleSectionAffordanceUsages;

/* instance methods */
- (id)init;
- (id)initWithTextView:(id)view;
- (void)dealloc;
- (void)horizontalSizeClassDidChange;
- (void)resetCollapsibleSectionsAffordanceExposures;
- (void)resetCollapsibleSectionsAffordanceUsageData;
- (void)resetCollapsibleSectionsAffordanceUsages;
- (void)textViewLayoutDidChangeWithNotification:(id)notification;

@end


@interface ICPDFAttachmentRenderOperation : NSOperation

@property (weak) ICPDFAttachmentView *view;
@property struct CGSize size;
@property double scale;
@property (readonly, weak) ICAttachment *attachment;
@property (readonly) double width;

/* instance methods */
- (id)initWithView:(id)view;
- (void)main;
- (id)generateImageForPrinting;

@end


@interface ICPaperCommonUtilities : NSObject // (Swift)

/* class methods */
+ (id)activitiesToExcludeForNote:(id)note currentUserActivity:(id)activity;
+ (_Bool)shouldResumeLastQuickNote;
+ (_Bool)shouldShowLinksWhenComposingQuickNote;

/* instance methods */
- (id)init;

@end


@interface ICPaperDocumentTextAttachmentView : NSView <NSSharingServiceDelegate, ICAttachmentViewInteractionDelegate, ICTextPreviewProvider, NSMenuItemValidation, ICAttachmentViewOpening>

@property (nonatomic, readonly) ICPaperDocumentTextAttachment *textAttachment;

/* instance methods */
- (_Bool)validateMenuItem:(id)item;
- (void)copy:(id)copy;
- (id)accessibilityLabel;
- (void)viewWillMoveToWindow:(id)window;
- (void)layout;
- (id)accessibilityValue;
- (void)dealloc;
- (void)unload;
- (id)menuForEvent:(id)event;
- (id)accessibilityIdentifier;
- (id)initWithFrame:(struct CGRect)frame;
- (void)share:(id)share;
- (id)initWithCoder:(id)coder;
- (void)viewDidMoveToWindow;
- (void)resetCursorRects;
- (void)sharingService:(id)service didShareItems:(id)items;
- (struct CGRect)sharingService:(id)service sourceFrameOnScreenForShareItem:(id)item;
- (id)sharingService:(id)service sourceWindowForShareItems:(id)items sharingContentScope:(long long *)scope;
- (void)openAttachment:(id)attachment;
- (void)quickLook:(id)look;
- (void)deleteAttachment:(id)attachment;
- (void)markup:(id)markup;
- (void)beginQuickLook:(id)look;
- (_Bool)attachmentViewInteraction:(id)interaction canSelectAttachmentAtPoint:(struct CGPoint)point;
- (void)attachmentViewInteractionDidPerformOpen:(id)open;
- (void)attachmentViewInteractionDidPerformSelect:(id)select;
- (void)changeSize:(id)size;
- (void)imageForTextPreviewUsingFindingResult:(ICTextFindingResult *)result inTextView:(ICMacBaseTextView *)view completion:(id /* block */)completion;
- (void)openAttachment;
- (void)paperDidSaveDidQuiesce;
- (void)renameAttachment:(id)attachment;
- (void)toggleThumbnails:(id)thumbnails;

@end


@interface ICPaperDocumentTextAttachmentViewProvider : NSTextAttachmentViewProvider // (Swift)

@property (nonatomic, retain) id <NSTextLocation> location;
@property (nonatomic, retain) id <NSTextLocation> updatedLocationForRecycledViewProvider;

/* class methods */
+ (void)registerIfNecessary;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(long long)index;
- (void)loadView;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)initWithTextAttachment:(id)attachment parentView:(id)view textLayoutManager:(id)manager location:(id)location;

@end


@interface ICPaperKitTextFindingResult : ICTextFindingResult

@property (nonatomic) unsigned long long order;
@property (nonatomic) struct CGRect searchResultRect;

/* class methods */
+ (double)scaleForDrawingBounds:(struct CGRect)bounds;

/* instance methods */
- (long long)compare:(id)compare;
- (struct CGRect)frameForHighlightInTextView:(id)view;
- (id)framesForHighlightInTextView:(id)view;
- (void)generateFindPreviewImageForPaperKitAttachment:(id)attachment completion:(id /* block */)completion;
- (void)selectInTextView:(id)view;

@end


@interface ICPaperMarkupController : NSObject // (Swift)

@property (nonatomic, weak) NSSplitViewItem *splitViewItem;
@property (nonatomic, retain) _TtC8PaperKit27MarkupToolbarViewController *toolbar;
@property (nonatomic, retain) NSSplitViewItemAccessoryViewController *accessoryVC;
@property (nonatomic) _Bool toolbarVisible;

/* instance methods */
- (id)init;
- (void)clearSelections;
- (id)initWithSplitViewItem:(id)item;
- (void)markupToolbarViewController:(id)controller insertNewLineWithStartMarker:(_Bool)marker endMarker:(_Bool)marker;
- (void)markupToolbarViewControllerInsertNewTextbox:(id)textbox;
- (void)markupToolbarViewControllerSelectedDrawingToolChanged:(id)changed;
- (void)markupToolbarViewControllerSelectedIndirectPointerTouchModeChanged:(id)changed;
- (void)paperViewDidAppear:(id)appear;

@end


@interface ICPaperTextAttachmentManager : NSObject

/* instance methods */
- (void)mouseExited:(id)exited;
- (id)init;
- (void)mouseEntered:(id)entered;
- (void)mouseMoved:(id)moved;
- (void)noteDidChangeCalculatePreviewBehavior:(id)behavior;
- (id)initWithNote:(id)note textView:(id)view delegate:(id)delegate;
- (void)paperKitViewDidAppear:(id)appear;
- (void)paperKitViewWillDisappear:(id)disappear;

@end


@interface ICParagraphInfo : NSObject

@property (retain, nonatomic) ICTTParagraphStyle *paragraphStyle;
@property (nonatomic) struct _NSRange characterRange;
@property (nonatomic) struct _NSRange rangeIncludingChildren;
@property (retain, nonatomic) NSMutableArray *children;
@property (readonly, nonatomic) unsigned int style;
@property (readonly, nonatomic) unsigned long long indent;
@property (readonly, nonatomic) unsigned long long blockQuoteLevel;

/* instance methods */

@end


@interface ICParagraphInfoSortInfo : NSObject

@property (retain, nonatomic) ICTrackedParagraph *trackedParagraph;
@property (retain, nonatomic) NSAttributedString *attributedString;
@property (nonatomic) struct _NSRange characterRange;

/* instance methods */

@end


@interface ICPencilKitTextFindingResult : ICTextFindingResult

@property (nonatomic) unsigned long long order;
@property (nonatomic) struct CGSize drawingSize;
@property (retain, nonatomic) PKSearchQueryItem *searchQueryItem;

/* instance methods */
- (long long)compare:(id)compare;
- (double)cornerRadius;
- (id)framesForHighlightInTextView:(id)view;
- (void)selectInTextView:(id)view;

@end


@interface ICPrintableTableTextAttachment : ICTableTextAttachment

@property (retain, nonatomic) ICSplitTableLayoutInformation *splitTableLayoutInformation;
@property (retain, nonatomic) ICTableTextAttachment *origialTextAttachment;
@property (readonly, nonatomic) _Bool isSplit;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (void)drawInAlignedRect:(struct CGRect)rect attributes:(id)attributes location:(id)location textContainer:(id)container isFlipped:(_Bool)flipped destinationContext:(struct CGContext *)context defaultRenderer:(id /* block */)renderer;
- (id)viewIdentifier;
- (struct CGRect)adjustedBounds:(struct CGRect)bounds proposedLineFragment:(struct CGRect)fragment textContainer:(id)container;
- (id)initWithOriginalTextAttachment:(id)attachment splitTableLayoutInformation:(id)information;

@end


@interface ICServicesRolloverView : NSView

@property (retain) NSTrackingArea *rolloverTrackingArea;
@property (weak, nonatomic) id <ICServicesRolloverViewDelegate> delegate;
@property (nonatomic) long long style;
@property (nonatomic) struct CGSize rolloverViewInset;

/* instance methods */
- (void)viewWillMoveToWindow:(id)window;
- (void)updateTrackingAreas;
- (void)mouseExited:(id)exited;
- (void)setFrame:(struct CGRect)frame;
- (void)mouseDown:(id)down;
- (void)mouseEntered:(id)entered;
- (_Bool)isFlipped;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)viewDidMoveToWindow;
- (id)hitTest:(struct CGPoint)test;
- (void)_servicesRolloverViewCommonInit;
- (void)_hideServicePickerWithoutAnimation;
- (void)_showServicePicker;
- (double)_showServicesPickerDelay;
- (void)_viewDidChangeBounds:(id)bounds;
- (void)icaxShowServicePicker;
- (struct CGRect)insetVisibleRect;

@end


@interface ICSharedScrollClampingController : NSObject

@property (nonatomic) double scrollClampingTopOffsetLineFragmentHeight;
@property long long userInitiatedSaveCount;
@property long long scrollClampingTopTextIndex;
@property double scrollClampingTopOffsetFactor;
@property (readonly) long long scrollClampingStack;
@property (readonly, weak, nonatomic) ICMacTextView *textView;
@property (readonly, nonatomic) double scrollClampingTurnOffDelay;

/* instance methods */
- (_Bool)isClamped;
- (void)dealloc;
- (void)clamp;
- (void)unclamp;
- (id)clampedYValue;
- (void)contextDidSaveUserInitiatedChange:(id)change;
- (void)contextWillSaveUserInitiatedChange:(id)change;
- (id)initWithTextView:(id)view listensToMergeNotifications:(_Bool)notifications;
- (id)initWithTextView:(id)view listensToMergeNotifications:(_Bool)notifications clampingTurnOffDelay:(double)delay;
- (void)mergeRelatedOperationsDidEnd:(id)end;
- (void)mergeRelatedOperationsWillBegin:(id)begin;
- (_Bool)notificationObjectMatchesTextViewNote:(id)note;
- (void)textStorageWillEndEditingNotification:(id)notification;
- (void)topTextIndex:(unsigned long long *)index topTextOffset:(double *)offset topTextFragmentHeight:(double *)height;
- (void)unclampWithMergeUpdates:(_Bool)updates;

@end


@interface ICSharedWithYouController : NSObject

@property (readonly, nonatomic) ICSharedWithYouControllerInternal *controller;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

/* class methods */
+ (id)sharedController;

/* instance methods */
- (id)initWithController:(id)controller;
- (void)fetchShareMetadataWithURLs:(id)urls completion:(id /* block */)completion;
- (id)highlightForURL:(id)url;
- (void)userAcceptedInvitationWithShareMetadata:(id)metadata associatedObjectID:(id)id;

@end


@interface ICSharedWithYouControllerInternal : NSObject <SWHighlightCenterDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

/* class methods */
+ (id)sharedController;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)highlightCenterHighlightsDidChange:(id)change;
- (void)fetchShareMetadataWithURLs:(id)urls completion:(id /* block */)completion;
- (id)highlightForURL:(id)url;
- (void)userAcceptedInvitationWithShareMetadata:(id)metadata associatedObjectID:(id)id;

@end


@interface ICSingleFileOpenPanelDelegate : NSObject

@property (retain, nonatomic) NSURL *singleFileURL;

/* instance methods */
- (id)initWithURL:(id)url;
- (_Bool)panel:(id)panel shouldEnableURL:(id)url;

@end


@interface ICSplitTableLayoutInformation : NSObject

@property (nonatomic) unsigned long long startRowIndex;
@property (nonatomic) unsigned long long endRowIndex;
@property (nonatomic) _Bool isFirstChunk;
@property (nonatomic) _Bool isLastChunk;

/* instance methods */
- (id)description;
- (id)initWithStartRowIndex:(unsigned long long)index endRowIndex:(unsigned long long)index isFirstChunk:(_Bool)chunk isLastChunk:(_Bool)chunk;

@end


@interface ICSystemPaperIndexableTextContentHelper : NSObject

@property (nonatomic, copy) PKDrawing *drawing;

/* instance methods */
- (id)init;
- (id)searchWithQuery:(id)query;
- (id)initWithPaperAttachment:(id)attachment;

@end


@interface ICTK2TextAttachmentViewProvider : NSTextAttachmentViewProvider

@property (readonly, nonatomic) ICAttachmentView *attachmentViewIfLoaded;
@property (nonatomic) _Bool viewLoaded;
@property (retain, nonatomic) id <NSTextLocation> updatedLocationForRecycledViewProvider;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;

/* instance methods */
- (void)setLocation:(id)location;
- (id)location;
- (void)loadView;
- (id)initWithTextAttachment:(id)attachment parentView:(id)view textLayoutManager:(id)manager location:(id)location;

@end


@interface ICTK2InlineTextAttachmentViewProvider : ICTK2TextAttachmentViewProvider <ICAttachmentFindable>

@property (readonly, nonatomic) ICInlineTextAttachment *inlineTextAttachment;
@property (readonly, nonatomic) ICInlineAttachmentView *inlineAttachmentView;
@property (nonatomic) struct _NSRange selectedSearchRange;
@property (readonly, nonatomic) NSTextContentStorage *tk2displayTextContentStorage;
@property (readonly, nonatomic) NSTextLayoutManager *tk2displayTextLayoutManager;
@property (readonly, nonatomic) NSTextContainer *displayTextTextContainer;
@property (readonly, nonatomic) NSLayoutManager *displayTextLayoutManager;
@property (readonly, nonatomic) NSTextStorage *displayTextTextStorage;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)loadView;
- (void)dealloc;
- (id)initWithTextAttachment:(id)attachment parentView:(id)view textLayoutManager:(id)manager location:(id)location;
- (id)rectsForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)scrollToRange:(struct _NSRange)range inFindableString:(id)string;
- (void)attachmentDataChanged:(id)changed;
- (void)drawCharactersInRange:(struct _NSRange)range inFindableString:(id)string forContentView:(id)view;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string inFindableString:(id)string;
- (struct _NSRange)selectedRangeWithinRange:(struct _NSRange)range inFindableString:(id)string;
- (void)setSelectedRange:(struct _NSRange)range inFindableString:(id)string;
- (id)viewForRange:(struct _NSRange)range inFindableString:(id)string;
- (void)updateDisplayTextTextStorage;

@end


@interface ICTK2MacTextView : ICMacTextView <NSTextViewportLayoutObserver>

@property (retain, nonatomic) ICTK2TextLayoutManagerDelegate *textLayoutManagerDelegate;
@property (retain, nonatomic) ICTextContentStorageDelegate *textContentStorageDelegate;
@property (retain, nonatomic) ICTK2TextController *tk2TextController;
@property (retain, nonatomic) ICOutlineRenderer *outlineRenderer;
@property (nonatomic) long long hoveredCharacterIndex;
@property (nonatomic) struct CGSize previousValueOfDocumentSizeInPage;
@property (copy, nonatomic) NSNumber *previousValueOfWrappingToFit;
@property (retain, nonatomic) ICNote *note;
@property (copy) id /* block */ renderingAttributesProvider;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;
+ (void)swizzleTextViewportElementHitTest;

/* instance methods */
- (id)layoutManager;
- (void)mouseExited:(id)exited;
- (id)accessibilityCustomActions;
- (id)init;
- (void)mouseEntered:(id)entered;
- (id)accessibilityValue;
- (void)textViewportLayoutControllerDidLayout:(id)layout;
- (_Bool)knowsPageRange:(struct _NSRange *)range;
- (id)accessibilityAttributedStringForRange:(struct _NSRange)range;
- (id)accessibilityChildren;
- (void)adjustPageHeightNew:(double *)_new top:(double)top bottom:(double)bottom limit:(double)limit;
- (void)cursorUpdate:(id)update;
- (void)flagsChanged:(id)changed;
- (void)mouseMoved:(id)moved;
- (void)writingToolsCoordinator:(id)coordinator finishTextAnimation:(long long)animation forRange:(struct _NSRange)range inContext:(id)context completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator prepareForTextAnimation:(long long)animation forRange:(struct _NSRange)range inContext:(id)context completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator replaceRange:(struct _NSRange)range inContext:(id)context proposedText:(id)text reason:(long long)reason animationParameters:(id)parameters completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator requestsBoundingBezierPathsForRange:(struct _NSRange)range inContext:(id)context completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator requestsContextsForScope:(long long)scope completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator requestsPreviewForTextAnimation:(long long)animation ofRange:(struct _NSRange)range inContext:(id)context completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator requestsUnderlinePathsForRange:(struct _NSRange)range inContext:(id)context completion:(id /* block */)completion;
- (void)writingToolsCoordinator:(id)coordinator selectRanges:(id)ranges inContext:(id)context completion:(id /* block */)completion;
- (void)textViewportLayoutController:(id)controller didLayoutTextViewportElement:(id)element;
- (id)initWithNote:(id)note size:(struct CGSize)size insideSystemPaper:(_Bool)paper insideSiriSnippet:(_Bool)snippet isForPrint:(_Bool)print;
- (id)attachmentViewDelegate;
- (void)icaxAddContainsParagraphsAttributesToAttributedString:(id)string atRange:(struct _NSRange)range;
- (id)initWithNote:(id)note size:(struct CGSize)size insideSystemPaper:(_Bool)paper insideSiriSnippet:(_Bool)snippet;
- (void)removeFromTextStorage;
- (void)scrollRangeToVisible:(struct _NSRange)visible withHeightPercentageAdjustment:(double)adjustment;
- (void)setAttachmentViewDelegate:(id)delegate;
- (void)setCursorForOutlineDisclosure:(id)disclosure;
- (void)setNote:(id)note isForPrint:(_Bool)print;
- (void)setupTextViewLayout;

@end


@interface ICTK2TextContainer : NSTextContainer <ICSystemPaperTextAttachmentNotesEditorBridgeWorkaround>

@property (nonatomic) _Bool inPreviewMode;
@property (nonatomic) _Bool insideSystemPaper;
@property (nonatomic) _Bool insideSiriSnippet;
@property (readonly, nonatomic) ICTK2MacTextView *tk2TextView;

/* instance methods */
- (id)layoutManager;

@end


@interface ICTK2TextLayoutManager : NSTextLayoutManager <ICTrackedAttributeDelegate>

@property (retain, nonatomic) NSMutableDictionary *tableAttachmentViewControllers;
@property (retain, nonatomic) NSMutableDictionary *viewProviderCache;
@property (readonly, nonatomic) NSDictionary *trackedToDoParagraphs;
@property (readonly, nonatomic) ICTK2TextController *textController;
@property (readonly, nonatomic) NSTextContentStorage *textContentStorage;
@property (weak, nonatomic) id <ICAttachmentViewDelegate> attachmentViewDelegate;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (nonatomic) _Bool suppressLocationUpdatesForRecycledViewProviders;

/* instance methods */
- (void)setTextContainer:(id)container;
- (void)setNeedsLayout;
- (long long)characterIndexForPoint:(struct CGPoint)point;
- (id)init;
- (void)dealloc;
- (void)invalidateLayoutForRange:(id)range;
- (void)setTextContentManager:(id)manager;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)renderingAttributesForLink:(id)link atLocation:(id)location;
- (void)attachmentWillBeDeleted:(id)deleted;
- (id)existingAttachmentViewForIdentifier:(id)identifier;
- (void)textController:(id)controller addedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller removedTrackedAttribute:(id)attribute;
- (void)textController:(id)controller updatedTrackedAttribute:(id)attribute;
- (void)attachmentPreferredSizeDidChange:(id)change;
- (_Bool)canReuseMismatchedViewProviderForTextAttachment:(id)attachment;
- (struct _NSRange)characterRangeForBoundingRect:(struct CGRect)rect;
- (void)clearCachedViewProvidersMatchingPredicate:(id /* block */)predicate;
- (void)enumerateAttachmentViewsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)enumerateInlineAttachmentViewsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (id)existingAttachmentViewProviderForIdentifier:(id)identifier;
- (void)invalidateLayoutForRanges:(id)ranges;
- (unsigned long long)lineCountForCharacterRange:(struct _NSRange)range;
- (id)newViewProviderForTextAttachment:(id)attachment parentView:(id)view location:(id)location;
- (void)noteEditorControllerSelectionDidChange:(id)change;
- (id)paragraphStyleForCharacterIndex:(unsigned long long)index;
- (struct _NSRange)rangeForAttachment:(id)attachment withTextAttachment:(id *)attachment;
- (void)reloadInlineAttachments;
- (id)tableViewControllerForAttachment:(id)attachment createIfNeeded:(_Bool)needed;
- (id)todoButtonAtCharacterIndex:(unsigned long long)index;
- (id)todoButtonForTrackedParagraph:(id)paragraph;
- (id)todoButtonsForCharacterRange:(struct _NSRange)range;
- (id)trackedTodoParagraphAtIndex:(unsigned long long)index;
- (id)trackedTodoParagraphForTrackingUUID:(id)uuid;
- (void)updateExistingTodoViewProviderForTrackedParagraph:(id)paragraph;
- (void)updateParentForTableAttachmentViewController:(id)controller;
- (Class)viewProviderClassForTextAttachment:(id)attachment;
- (id)viewProviderForTextAttachment:(id)attachment parentView:(id)view location:(id)location;
- (id)viewProviderForTextAttachment:(id)attachment parentView:(id)view location:(id)location ignoreCache:(_Bool)cache;
- (void)zoomFactorOrInsetsDidChange;

@end


@interface ICTK2TextLayoutManagerDelegate : NSObject <NSTextLayoutManagerDelegatePrivate>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)textLayoutManager:(id)manager textLayoutFragmentForLocation:(id)location inTextElement:(id)element;

@end


@interface ICTK2TodoTextAttachmentViewProvider : ICTK2TextAttachmentViewProvider <ICTodoButtonDragDelegate>

@property (readonly, nonatomic) ICTK2MacTextView *textView;
@property (readonly, nonatomic) ICTodoButton *todoButton;
@property (readonly, nonatomic) ICTK2TodoTextAttachment *todoTextAttachment;
@property (readonly, nonatomic) ICTextController *textController;
@property (readonly, nonatomic) ICTTTextStorage *textStorage;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)loadView;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)didPressTodoButton:(id)button;
- (_Bool)selectedRangesIntersectWithRange:(struct _NSRange)range;
- (void)todoButtonDidDrag:(id)drag;

@end


@interface ICTableAccessibilityController : NSObject

@property (weak, nonatomic) ICTableAttachmentViewController *tableAttachmentViewController;
@property (readonly, nonatomic) ICTableAccessibilityElementProvider *elementProvider;
@property (readonly, nonatomic) unsigned long long rowCount;
@property (readonly, nonatomic) unsigned long long columnCount;
@property (readonly, nonatomic) ICTableAttachmentView *hostingTableAttachmentView;
@property (readonly, nonatomic) NSScrollView *tableScrollView;
@property (readonly, nonatomic) NSScrollView *noteScrollView;
@property (readonly, nonatomic) _Bool isTableRightToLeft;
@property (readonly, nonatomic) struct _NSRange attachmentRangeInNote;
@property (readonly, nonatomic) ICTableSelectionKnob *startSelectionKnob;
@property (readonly, nonatomic) ICTableSelectionKnob *endSelectionKnob;
@property (retain, nonatomic) ICMTableAccessibilityElement *tableElement;
@property (retain, nonatomic) ICMTableAccessibilityTextViewProxyElement *textViewProxyElement;

/* instance methods */
- (_Bool)isEditable;
- (id)table;
- (id)selectedCells;
- (void)addColumnBefore;
- (void)moveCurrentColumnOrRow:(_Bool)row toIndex:(unsigned long long)index;
- (void)addColumnAfter;
- (void)addRowAbove;
- (void)addRowBelow;
- (id)attributedContentStringForColumnID:(id)id rowID:(id)id;
- (void)beginEditingCellWithColumnID:(id)id rowID:(id)id;
- (struct CGRect)boundingRectForCellWithColumnID:(id)id rowID:(id)id;
- (id)cellElementForColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (id)cellElementsForColumnID:(id)id;
- (id)cellElementsForRowID:(id)id;
- (_Bool)cellIsEditingAtColumnID:(id)id rowID:(id)id;
- (id)columnElementForID:(id)id;
- (id)columnHeaderElement;
- (id)columnIDForColumnIndex:(unsigned long long)index;
- (unsigned long long)columnIndexForColumnID:(id)id;
- (void)convertTableToText;
- (void)deleteSelectedColumns;
- (void)deleteSelectedRows;
- (struct CGRect)frameInScreenSpaceForCellWithColumnID:(id)id rowID:(id)id;
- (id)initWithTableAttachmentViewController:(id)controller;
- (void)invalidateAXElementsForColumnID:(id)id;
- (void)invalidateAXElementsForRowID:(id)id;
- (_Bool)isHeaderCellAtColumnID:(id)id rowID:(id)id;
- (void)reverseTableDirection;
- (id)rowElementForID:(id)id;
- (id)rowHeaderElement;
- (id)rowIDForRowIndex:(unsigned long long)index;
- (unsigned long long)rowIndexForRowID:(id)id;
- (void)scrollColumnIDToVisible:(id)visible rowID:(id)id;
- (void)selectCellForColumnID:(id)id rowID:(id)id;
- (void)selectCellRangeForCurrentCell;
- (void)selectColumnWithID:(id)id;
- (void)selectCurrentColumn;
- (void)selectCurrentRow;
- (void)selectRowWithID:(id)id;
- (id)selectedColumnIDs;
- (id)selectedRowIDs;
- (void)speakCellRangeSelection:(id)selection;
- (id)textViewForColumnID:(id)id;
- (id)titleForColumnID:(id)id;
- (id)titleForRowID:(id)id;

@end


@interface ICTableAccessibilityElementProvider : NSObject

@property (weak, nonatomic) ICTableAccessibilityController *tableAXController;
@property (readonly, nonatomic) ICTable *tableModel;
@property (retain, nonatomic) NSMutableDictionary *cellCache;
@property (retain, nonatomic) NSMutableDictionary *columnCache;
@property (retain, nonatomic) NSMutableDictionary *rowCache;

/* instance methods */
- (id)cellElementForColumnID:(id)id rowID:(id)id;
- (id)cellElementsForColumnID:(id)id;
- (id)cellElementsForRowID:(id)id;
- (id)columnElementForID:(id)id;
- (id)initWithTableAccessibilityController:(id)controller;
- (void)removeElementsForColumnID:(id)id;
- (void)removeElementsForRowID:(id)id;
- (id)rowElementForID:(id)id;

@end


@interface ICTableAutoScroller : NSObject

@property (weak, nonatomic) ICTableAttachmentViewController *tableAttachmentViewController;
@property (weak, nonatomic) NSScrollView *verticalScrollView;
@property (weak, nonatomic) ICTableScrollView *horizontalScrollView;
@property (nonatomic) unsigned long long scrollDirectionMode;
@property (nonatomic) _Bool isScrolling;
@property (retain, nonatomic) NSTimer *autoscrollTimer;
@property (readonly, weak, nonatomic) NSScrollView *targetScrollView;
@property (weak, nonatomic) id <ICTableAutoScrollerDelegate> delegate;
@property (nonatomic) double topThresholdDistance;
@property (nonatomic) double bottomThresholdDistance;
@property (nonatomic) struct CGRect targetFrame;

/* instance methods */
- (void)stopAndInvalidate;
- (void)autoScrollWithScrollFactor:(double)factor scrollDirectionMode:(unsigned long long)mode;
- (id)initWithTableAttachmentViewController:(id)controller scrollDirectionMode:(unsigned long long)mode;
- (double)scrollFactorForScrollDirectionMode:(unsigned long long)mode;
- (void)stopAutoscrollTimer;
- (void)updateAutoscrollTimer:(id)timer;

@end


@interface ICTableCellAccessibilityElement : NSObject <NSAccessibilityElement>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) struct CGRect boundingRect;
@property (weak, nonatomic) ICTableAccessibilityController *tableAXController;
@property (readonly, nonatomic) NSUUID *rowID;
@property (readonly, nonatomic) NSUUID *columnID;
@property (readonly, nonatomic) unsigned long long rowIndex;
@property (readonly, nonatomic) unsigned long long columnIndex;
@property (readonly, nonatomic) NSAttributedString *attributedContentString;
@property (readonly, nonatomic) struct CGRect frameInScreenSpace;
@property (readonly, nonatomic) _Bool isEditing;

/* instance methods */
- (id)accessibilityTitle;
- (_Bool)isAccessibilityElement;
- (struct CGRect)accessibilityFrame;
- (id)accessibilityRole;
- (id)accessibilityActionDescription:(id)description;
- (id)accessibilityActionNames;
- (id)accessibilityChildren;
- (struct _NSRange)accessibilityColumnIndexRange;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityParent;
- (void)accessibilityPerformAction:(id)action;
- (id)accessibilityRoleDescription;
- (struct _NSRange)accessibilityRowIndexRange;
- (id)initWithTableAccessibilityController:(id)controller columnID:(id)id rowID:(id)id;
- (id)parentTableElement;

@end


@interface ICTableClipView : NSView

/* instance methods */
- (_Bool)isFlipped;
- (id)initWithFrame:(struct CGRect)frame;
- (id)hitTest:(struct CGPoint)test;

@end


@interface ICTableColumnManager : NSObject <ICTableColumnLayout>

@property (retain, nonatomic) NSTextStorage *textStorage;
@property (readonly, nonatomic) NSMutableSet *currentlyHiddenSubviews;
@property (weak, nonatomic) ICTableColumnNSLayoutManager *tk1Provider;
@property (retain, nonatomic) ICTK2TextLayoutManager *textLayoutManager;
@property (retain, nonatomic) ICTTTextContentStorage *textContentStorage;
@property (retain, nonatomic) ICTableColumnTextContainer *textContainer;
@property (retain, nonatomic) ICTextContentStorageDelegate *textContentStorageDelegate;
@property (retain, nonatomic) ICTK2TextLayoutManagerDelegate *textLayoutManagerDelegate;
@property (readonly, weak, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (readonly, nonatomic) NSUUID *columnID;
@property (readonly, nonatomic) ICTableColumnTextStorage *columnTextStorage;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (retain, nonatomic) NSArray *hiddenRows;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (double)width;
- (void)ensureLayoutForCharacterRange:(struct _NSRange)range;
- (void)removeRow:(id)row;
- (_Bool)usesTextKit2;
- (void)causeGlyphGenerationIfNecessaryForCharacterRange:(struct _NSRange)range;
- (void)ensureCellExistsAtRowID:(id)id;
- (double)heightOfCellAtRowID:(id)id;
- (id)initWithTableLayoutManager:(id)manager columnID:(id)id textStorage:(id)storage;
- (id)initWithTableLayoutManager:(id)manager columnID:(id)id textStorage:(id)storage tk1Provider:(id)provider;
- (void)invalidateLayoutForCharacterRange:(struct _NSRange)range;
- (struct _NSRange)rangeForRowID:(id)id;
- (id)rangesForRows:(id)rows;
- (void)setupTextKit2IfNeeded;

@end


@interface ICTableColumnNSLayoutManager : ICLayoutManager <ICTableColumnLayout>

@property (readonly) double width;
@property (retain, nonatomic) ICTableColumnManager *columnManager;
@property (readonly) NSUUID *columnID;
@property (readonly, nonatomic) ICTableColumnTextStorage *columnTextStorage;
@property (readonly, nonatomic) NSTextContainer *textContainer;
@property (retain, nonatomic) NSArray *hiddenRows;
@property (readonly, weak, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)invalidateLayoutForRange:(struct _NSRange)range;
- (void)drawGlyphsForGlyphRange:(struct _NSRange)range atPoint:(struct CGPoint)point;
- (struct _NSRange)glyphRangeForBoundingRect:(struct CGRect)rect inTextContainer:(id)container;
- (void)removeRow:(id)row;
- (void)causeGlyphGenerationIfNecessaryForCharacterRange:(struct _NSRange)range;
- (void)ensureCellExistsAtRowID:(id)id;
- (void)filterAttachmentsInTextStorage:(id)storage range:(struct _NSRange)range targetAttachment:(id)attachment;
- (struct _NSRange)glyphRangeForRowID:(id)id;
- (id)glyphRangesForRows:(id)rows;
- (double)heightOfCellAtRowID:(id)id;
- (id)initWithTableLayoutManager:(id)manager columnID:(id)id textStorage:(id)storage;
- (void)invalidateLayoutForCharacterRange:(struct _NSRange)range;
- (id)rectsForGlyphRange:(struct _NSRange)range;

@end


@interface ICTableColumnRowButton : NSButton

@property (retain, nonatomic) NSTrackingArea *mouseTrackingArea;
@property (retain, nonatomic) NSArray *columnOrRowIdentifiers;
@property (readonly, nonatomic) _Bool isColumn;
@property (readonly, nonatomic) _Bool isLTR;
@property (readonly, nonatomic) NSButton *disclosureButton;

/* class methods */
+ (_Bool)clipsToBounds;

/* instance methods */
- (void)drawRect:(struct CGRect)rect;
- (void)updateTrackingAreas;
- (void)mouseExited:(id)exited;
- (struct CGRect)hitRect;
- (void)layout;
- (void)mouseEntered:(id)entered;
- (id)menuForEvent:(id)event;
- (id)initWithFrame:(struct CGRect)frame;
- (void)setState:(long long)state;
- (id)initWithCoder:(id)coder;
- (void)cursorUpdate:(id)update;
- (id)hitTest:(struct CGPoint)test;
- (void)mouseMoved:(id)moved;
- (id)initAsColumn:(_Bool)column isLeftToRight:(_Bool)right;
- (id)tableAXController;
- (void)updateAccentColor;

@end


@interface ICTableColumnRowButtonCell : NSButtonCell

@property (weak, nonatomic) ICTableColumnRowButton *parentButton;

/* instance methods */
- (id)accessibilityActionDescription:(id)description;
- (id)accessibilityActionNames;
- (void)accessibilityPerformAction:(id)action;
- (void)swapCurrentColumnOrRowAXAction:(_Bool)axaction forwards:(_Bool)forwards;

@end


@interface ICTableColumnTextContainer : NSTextContainer

@property (weak, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (weak, nonatomic) ICTableColumnTextStorage *columnTextStorage;

/* instance methods */
- (struct CGRect)lineFragmentRectForProposedRect:(struct CGRect)rect atIndex:(unsigned long long)index writingDirection:(long long)direction remainingRect:(struct CGRect *)rect;
- (void)setSize:(struct CGSize)size;
- (_Bool)isSimpleRectangularTextContainer;

@end


@interface ICTableColumnTextView : ICMacBaseTextView <ICAccessibilityFocusedUIElementProvider, NSMenuItemValidation, ICMHashtagDebugViewControllerDelegate>

@property (nonatomic) _Bool isMouseDown;
@property (nonatomic) _Bool shouldSuppressSelectionChanges;
@property (retain, nonatomic) ICMHashtagDebugViewController *hastagDebugViewController;
@property (retain, nonatomic) NSUUID *columnID;
@property (readonly, nonatomic) ICTableColumnTextStorage *columnTextStorage;
@property (weak, nonatomic) id <ICTableColumnTextViewDelegate> cellDelegate;
@property (weak, nonatomic) id <ICTableSelectionDelegate> selectionDelegate;
@property (weak, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (nonatomic) _Bool isChangingFont;
@property (nonatomic) _Bool isResigningFirstResponder;
@property (nonatomic) struct _NSRange previousSelectedRange;
@property (retain) id <ICMacTextViewEditorDelegate> editorDelegate;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)mouseUp:(id)up;
- (_Bool)validateMenuItem:(id)item;
- (void)selectAll:(id)all;
- (_Bool)resignFirstResponder;
- (void)paste:(id)paste;
- (_Bool)becomeFirstResponder;
- (void)setFrame:(struct CGRect)frame;
- (_Bool)respondsToSelector:(SEL)selector;
- (void)mouseDown:(id)down;
- (void)cancelOperation:(id)operation;
- (void)keyDown:(id)down;
- (_Bool)isAccessibilityElement;
- (void)moveDown:(id)down;
- (void)moveToEndOfDocument:(id)document;
- (void)dealloc;
- (struct CGRect)selectionRect;
- (void)moveToBeginningOfDocument:(id)document;
- (id)menuForEvent:(id)event;
- (_Bool)supportsAttachments;
- (void)mouseDragged:(id)dragged;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (_Bool)acceptsFirstResponder;
- (void)moveUp:(id)up;
- (id)acceptableDragTypes;
- (void)accessibilityPostNotification:(id)notification;
- (void)changeFont:(id)font;
- (unsigned long long)draggingEntered:(id)entered;
- (unsigned long long)draggingUpdated:(id)updated;
- (id)initWithFrame:(struct CGRect)frame textContainer:(id)container;
- (void)moveLeft:(id)left;
- (void)moveRight:(id)right;
- (void)moveToBeginningOfDocumentAndModifySelection:(id)selection;
- (void)moveToEndOfDocumentAndModifySelection:(id)selection;
- (void)moveToLeftEndOfLine:(id)line;
- (void)moveToRightEndOfLine:(id)line;
- (void)moveWordLeft:(id)left;
- (void)moveWordRight:(id)right;
- (id)nextValidKeyView;
- (void)performTextFinderAction:(id)action;
- (_Bool)readSelectionFromPasteboard:(id)pasteboard type:(id)type;
- (void)setSelectedRanges:(id)ranges affinity:(unsigned long long)affinity stillSelecting:(_Bool)selecting;
- (void)underline:(id)underline;
- (id)alternativeFocusedUIElement;
- (void)strikethrough:(id)strikethrough;
- (_Bool)atCellBoundaryForDirection:(unsigned long long)direction;
- (id)attributedStringByRemovingUnsupportedAttachments:(id)attachments;
- (void)emphasis:(id)emphasis;
- (void)hashtagDebugViewController:(id)controller didEnterHashtagText:(id)text;
- (void)insertDebugHashtag:(id)hashtag;
- (void)insertInlineAttachment:(id)attachment;
- (void)insertInlineAttachment:(id)attachment saveAndResumeEditingForAttachment:(id)attachment inNote:(id)note;
- (unsigned long long)modifierFlagAffectingSelection;
- (_Bool)moveInDirection:(unsigned long long)direction;
- (void)moveToBeginningOfCell:(id)cell;
- (void)moveToBeginningOfCellAndModifySelection:(id)selection;
- (void)moveToEndOfCell:(id)cell;
- (void)moveToEndOfCellAndModifySelection:(id)selection;
- (void)moveWordInDirection:(unsigned long long)direction withPreviousLocation:(unsigned long long)location;
- (void)selectRangesForRows:(id)rows;
- (void)setEditorController:(id)controller;
- (struct CGRect)tk1_selectionRect;
- (struct CGRect)tk2_selectionRect;

@end


@interface ICTableContentView : NSView

@property (retain, nonatomic) NSMutableDictionary *horizontalStrokes;
@property (retain, nonatomic) NSMutableDictionary *verticalStrokes;
@property (retain, nonatomic) NSView *topBorder;
@property (retain, nonatomic) NSView *bottomBorder;
@property (retain, nonatomic) NSView *leftBorder;
@property (retain, nonatomic) NSView *rightBorder;
@property (nonatomic) struct CGRect exclusionRect;
@property (copy, nonatomic) NSColor *highlightColor;
@property (readonly, nonatomic) double innerBorderWidth;
@property (readonly, nonatomic) NSColor *innerBorderColor;

/* instance methods */
- (void)layout;
- (void)updateLayout;
- (void)viewDidChangeEffectiveAppearance;
- (void)updateLayer;
- (_Bool)isFlipped;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)updateColors;
- (id)outerBorderColor;
- (id)addSubstrokeWithFrame:(struct CGRect)frame toStroke:(id)stroke;
- (void)setVerticalLinePosition:(id)position forKey:(id)key;
- (double)alignedPosition:(double)position;
- (id)createStroke;
- (void)drawStrokeLinesInContext:(struct CGContext *)context;
- (double)outerBorderWidth;
- (void)recursivelyUpdateLayer:(id)layer toColor:(CGColorRef)color ignoreIfClear:(_Bool)clear;
- (void)setHorizontalLinePosition:(id)position forKey:(id)key;
- (void)sharedInit;
- (_Bool)splitStroke:(id)stroke atRect:(struct CGRect)rect;
- (void)unsplitStroke:(id)stroke;

@end


@interface ICTableLayoutManager : NSObject <ICAvailableTableWidthProviding>

@property (readonly) NSMutableDictionary *columnLayoutManagers;
@property (readonly) NSMutableDictionary *columnManagers;
@property double emptyCellLineHeight;
@property (nonatomic) double emptyCellLineSpacing;
@property (readonly, weak, nonatomic) ICTable *table;
@property (readonly, weak, nonatomic) NSObject<ICAvailableTableWidthProviding> *delegate;
@property (readonly) ICTableColumnWidthManager *columnWidthManager;
@property (readonly, nonatomic) NSMutableDictionary *rowPositions;
@property (readonly, nonatomic) double emptyCellHeight;
@property (readonly, nonatomic) _Bool forManualRendering;
@property (retain, nonatomic) ICSearchResultRegexMatchFinder *highlightPatternRegexFinder;
@property (readonly, nonatomic) double availableWidth;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)removeRow:(id)row;
- (id)columnIDs;
- (id)columnLayoutForColumn:(id)column;
- (id)initWithTable:(id)table delegate:(id)delegate forManualRendering:(_Bool)rendering;
- (id)newTextStorageForColumn:(id)column;
- (void)removeColumnLayoutForColumn:(id)column;
- (void)setYPosition:(double)yposition forRow:(id)row shouldInvalidate:(_Bool)invalidate;
- (id)tk1_columnLayoutForColumn:(id)column;
- (id)tk2_columnLayoutForColumn:(id)column;
- (void)updateColorsForPrintingInAllColumns;
- (void)updateForMovedRow:(id)row;

@end


@interface ICTableScrollView : ICMForwardVerticalScrollEventsScrollView

/* class methods */
+ (_Bool)isCompatibleWithResponsiveScrolling;

/* instance methods */
- (void)commonInit;
- (_Bool)isAccessibilityElement;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (void)contentViewBoundsDidChange:(id)change;

@end


@interface ICTableSelectionKnob : NSView

@property (nonatomic) _Bool hovering;
@property (retain, nonatomic) NSTrackingArea *mouseTrackingArea;
@property (weak, nonatomic) ICTableAttachmentViewController *tableAttachmentViewController;
@property (readonly, nonatomic) _Bool isStart;
@property (readonly, nonatomic) _Bool isEnd;

/* instance methods */
- (void)drawRect:(struct CGRect)rect;
- (void)updateTrackingAreas;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)frame;
- (void)cursorUpdate:(id)update;
- (id)hitTest:(struct CGPoint)test;
- (void)mouseMoved:(id)moved;
- (struct CGRect)circleRect;
- (_Bool)isHovering;
- (id)initWithTableAttachmentViewController:(id)controller;
- (void)updateAccentColor;

@end


@interface ICTableSelectionView : NSView

@property (weak, nonatomic) id <ICTableSelectionDelegate> delegate;

/* instance methods */
- (void)copy:(id)copy;
- (_Bool)resignFirstResponder;
- (void)paste:(id)paste;
- (void)cut:(id)cut;
- (_Bool)becomeFirstResponder;
- (void)keyDown:(id)down;
- (id)initWithFrame:(struct CGRect)frame;
- (void)delete:(id)_delete;
- (id)hitTest:(struct CGPoint)test;
- (void)updateAccentColor;

@end


@interface ICTableTextFindingResult : ICTextFindingResult

@property (weak, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) NSAttributedString *findableString;
@property (nonatomic) struct _NSRange rangeInFindableString;
@property (retain, nonatomic) NSString *queryString;
@property (nonatomic) unsigned long long row;
@property (nonatomic) unsigned long long column;
@property (nonatomic) _Bool ignoreCase;
@property (retain, nonatomic) ICInlineTextFindingResult *inlineTextFindingResult;

/* instance methods */
- (long long)compare:(id)compare;
- (id)init;
- (id)framesForHighlightInTextView:(id)view;
- (void)selectInTextView:(id)view;
- (id)tableAttachmentViewControllerForTextView:(id)view;

@end


@interface ICTableTextViewManager : NSObject

@property (readonly, nonatomic) NSMutableArray *columnIdentifiers;
@property (readonly, nonatomic) NSMutableArray *rowIdentifiers;
@property (readonly, nonatomic) NSMutableSet *prepopulatedColumns;
@property (readonly, nonatomic) NSMutableDictionary *columnTextViews;
@property (readonly, nonatomic) ICTableLayoutManager *tableLayoutManager;
@property (readonly, weak, nonatomic) ICTableContentView *contentView;
@property (readonly, nonatomic) ICDimensionSumCache *cachedColumnWidths;
@property (readonly, nonatomic) ICDimensionSumCache *cachedRowHeights;
@property (readonly, nonatomic) NSMutableDictionary *cachedCellHeights;
@property (retain, nonatomic) NSArray *previousRowIdentifiers;
@property (retain, nonatomic) NSMutableSet *columnsNeedingRestyle;
@property (nonatomic) _Bool updatingTiles;
@property (nonatomic) unsigned long long anchorColumn;
@property (nonatomic) unsigned long long anchorRow;
@property (nonatomic) struct CGPoint anchorPoint;
@property (retain, nonatomic) NSSet *draggedColumns;
@property (retain, nonatomic) NSSet *draggedRows;
@property (readonly, nonatomic) struct CGRect boundingRect;
@property (readonly, nonatomic) NSArray *columnIDs;
@property (readonly, nonatomic) NSArray *rowIDs;
@property (weak, nonatomic) id <ICTableTextViewManagerDelegate> delegate;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)removeColumn:(id)column;
- (struct CGRect)frameOfCellAtColumn:(id)column row:(id)row;
- (struct CGRect)frameOfColumn:(id)column;
- (struct CGRect)frameOfRow:(id)row;
- (void)moveColumnAtIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)moveRowAtIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (_Bool)isUpdatingTiles;
- (id)rowContainingY:(double)y;
- (double)addColumn:(id)column atEnd:(_Bool)end;
- (double)addRow:(id)row atEnd:(_Bool)end;
- (void)adjustOnscreenPositions;
- (_Bool)cellContainingPoint:(struct CGPoint)point columnID:(id *)id rowID:(id *)id;
- (void)clearColumn:(id)column;
- (void)clearColumnsOutsideFrame:(struct CGRect)frame;
- (void)clearRow:(id)row;
- (void)clearRowsOutsideFrame:(struct CGRect)frame;
- (id)columnContainingX:(double)x;
- (void)ensureCellPositionForColumn:(id)column andRow:(id)row;
- (double)ensureChunkOfPopulatedColumnsForColumn:(id)column;
- (double)ensureChunkOfPopulatedRowsForRow:(id)row shouldForce:(_Bool)force;
- (void)enumerateTextViewsWithBlock:(id /* block */)block;
- (void)heightChangedForRow:(id)row by:(double)by;
- (id)initWithTableLayoutManager:(id)manager view:(id)view cachedWidths:(id)widths cachedRowHeights:(id)heights cachedCellHeights:(id)heights;
- (struct CGPoint)initialScrollPointForViewport:(struct CGRect)viewport;
- (void)parentViewDidChange;
- (double)preAddColumn:(id)column;
- (double)preAddRow:(id)row atYPosition:(double)yposition;
- (struct CGPoint)redrawAllWithViewport:(struct CGRect)viewport;
- (void)restyleCells;
- (void)restyleTextView:(id)view;
- (id)textViewForColumn:(id)column;
- (id)textViewForColumn:(id)column createIfNeeded:(_Bool)needed;
- (void)updateAuthorHighlights;
- (struct CGPoint)updateTilesWithViewport:(struct CGRect)viewport redrawAll:(_Bool)all;
- (void)validateRowHeightsForColumn:(id)column;

@end


@interface ICTableUndoTarget : NSObject <ICTTTextUndoTarget>

@property (retain, nonatomic) ICTableAttachmentProvider *provider;
@property (weak, nonatomic) ICTableAttachmentViewController *tableAttachmentViewController;
@property (readonly, nonatomic) ICTableAttachmentViewController *tableAttachmentViewControllerForUndo;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (void)applyUndoGroup:(id)group;
- (id)initWithProvider:(id)provider viewController:(id)controller;

@end


@interface ICTextAttachmentLocationCache : NSObject

@property (nonatomic) unsigned long long previousScanHaltLocation;
@property (readonly, nonatomic) NSMutableDictionary *locationByTextAttachmentIdentifier;
@property (weak, nonatomic) ICLayoutManager *layoutManager;
@property (retain, nonatomic) Class cachedTextAttachmentType;

/* instance methods */
- (void)clear;
- (void)enumerateTextAttachmentsInRangeUsingBlock:(id /* block */)block;
- (void)enumerateTextAttachmentsInRangeWithFirstEnumerateRangeResult:(struct _NSRange *)result secondEnumerateRangeResult:(struct _NSRange *)result usingBlock:(id /* block */)block;
- (void)forgetLocationForViewIdentifier:(id)identifier;
- (id)initWithLayoutManager:(id)manager cachedTextAttachmentType:(Class)type;
- (unsigned long long)locationForTextAttachmentOfViewIdentifier:(id)identifier;
- (unsigned long long)locationForTextAttachmentOfViewIdentifier:(id)identifier keyExistsBeforeEnumeration:(_Bool *)enumeration validationSuccessful:(_Bool *)successful stepsOfEnumeration:(unsigned long long *)enumeration;
- (unsigned long long)nextLocationForRange:(struct _NSRange)range;
- (void)setLocation:(unsigned long long)location forTextAttachmentOfViewIdentifier:(id)identifier;
- (_Bool)validateLocation:(unsigned long long)location againstViewIdentifier:(id)identifier;

@end


@interface ICTextAttachmentViewProvider : NSTextAttachmentViewProvider

/* instance methods */
- (void)loadView;
- (_Bool)tracksTextAttachmentViewBounds;

@end


@interface ICTextContentStorageDelegate : NSObject <NSTextContentStorageDelegate>

@property (nonatomic) _Bool insideSiriSnippet;
@property (nonatomic) _Bool supportsOutlining;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (_Bool)textContentManager:(id)manager shouldEnumerateTextElement:(id)element options:(unsigned long long)options;
- (id)textContentStorage:(id)storage textParagraphWithRange:(struct _NSRange)range;

@end


@interface ICTextElementAnimator : NSObject

/* instance methods */
- (id)init;
- (void)animateWithCompletion:(id /* block */)completion;
- (id)initWithTextView:(id)view originTrackedParagraphs:(id)paragraphs destinationTrackedParagraphs:(id)paragraphs;

@end


@interface ICTextElementLocator : NSObject

/* instance methods */
- (id)init;
- (id)initWithTextView:(id)view;
- (void)enumerateTextElementsUsingBlock:(id /* block */)block;

@end


@interface ICTextFindingCoordinator : NSObject

/* instance methods */
- (id)initWithDataSource:(id)source;
- (id)init;
- (void)matchesForString:(NSString *)string inTextStorage:(NSTextStorage *)storage note:(ICNote *)note relativeTo:(<NSTextFinderAsynchronousDocumentFindMatch> *)to options:(unsigned long long)options maxResults:(unsigned long long)results resultsAggregator:(id /* block */)aggregator;
- (void)replaceMatches:(NSArray *)matches withString:(NSString *)string selectionOnly:(_Bool)only completion:(id /* block */)completion;

@end


@interface ICTextFindingMatch : NSObject <NSTextFinderAsynchronousDocumentFindMatch>

@property (nonatomic, readonly) NSView *containingView;
@property (nonatomic, readonly) NSArray *textRects;
@property (nonatomic, readonly) ICTextFindingResult *findingResult;
@property (nonatomic, readonly) struct _NSRange rangeInNote;
@property (nonatomic, readonly) struct CGRect unionizedFrame;
@property (nonatomic, readonly) _Bool isAttachment;

/* instance methods */
- (id)init;
- (void)select;
- (void)generateTextImage:(id /* block */)image;

@end


@interface ICTextLayoutFragment : NSTextLayoutFragment

@property (readonly, nonatomic) NSTextAttachment *textAttachment;
@property (readonly, nonatomic) NSTextParagraph *textParagraph;
@property (readonly, nonatomic) ICTTTextContentStorage *textContentStorage;

/* instance methods */
- (double)topMargin;
- (id)initWithTextElement:(id)element range:(id)range;
- (double)trailingPadding;
- (double)leadingPadding;
- (double)bottomMargin;
- (double)marginForTop:(_Bool)top;
- (struct _NSRange)nsRangeInTextStorage:(id)storage;

@end


@interface ICTextViewAccessibility : NSObject

/* class methods */
+ (id)icaxEmphasisStyleNameFromAttributes:(id)attributes;

@end


@interface ICTextViewRenderingSurfaceView : NSView <NSTextViewportRenderingSurface>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isFlipped;
- (id)hitTest:(struct CGPoint)test;

@end


@interface ICTextViewScrollState : NSObject

@property (retain, nonatomic) ICTTMergeableStringSelection *topLeftStringSelection;
@property (nonatomic) double topLeftTextAttachmentScrollHeightOffsetRatio;
@property (weak, nonatomic) ICNote *note;
@property (copy, nonatomic) NSString *noteIdentifier;
@property (retain, nonatomic) NSDate *date;
@property (nonatomic) _Bool fromArchive;
@property (nonatomic) _Bool loadingFromDictionaryFailed;
@property (nonatomic) _Bool isApplying;
@property (nonatomic) unsigned long long topLeftCharIndexAtCapture;
@property (readonly, nonatomic) unsigned long long topLeftTextCharacterIndex;
@property (readonly, nonatomic) _Bool captureIsWithinTimeThreshold;
@property (readonly, nonatomic) _Bool isValid;
@property (readonly, nonatomic) double timeIntervalSinceCapture;
@property (readonly, nonatomic) NSDictionary *dictionaryRepresentation;
@property (readonly, nonatomic) NSData *dataRepresentation;

/* class methods */
+ (id)scrollStateForAttachment:(id)attachment inNote:(id)note;
+ (id)scrollStateForParagraphID:(id)id inNote:(id)note;
+ (id)scrollStateForRange:(struct _NSRange)range inNote:(id)note;
+ (id)scrollStateForTextView:(id)view;
+ (void)setupDateFormatter;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)hash;
- (_Bool)applyToTextView:(id)view;
- (id)initWithData:(id)data managedObjectContext:(id)context;
- (id)initWithDictionary:(id)dictionary note:(id)note;
- (_Bool)isFromArchive;

@end


@interface ICTrackedParagraphImageInfo : NSObject

@property (retain, nonatomic) ICTrackedParagraph *trackedParagraph;
@property (retain, nonatomic) NSString *uuid;
@property (retain, nonatomic) NSImage *image;
@property (nonatomic) struct CGRect boundingRect;
@property (nonatomic) struct CGRect rect;
@property (retain, nonatomic) NSImageView *imageViewIfExists;
@property (nonatomic) _Bool estimated;

/* instance methods */

@end


@interface ICTrackedParagraphTreeNode : NSObject

@property (retain, nonatomic) ICTrackedParagraph *trackedParagraph;
@property (retain, nonatomic) NSMutableArray *children;
@property (weak, nonatomic) ICTrackedParagraphTreeNode *parent;
@property (nonatomic) _Bool checked;
@property (nonatomic) long long indent;
@property (retain, nonatomic) NSString *string;
@property (readonly, nonatomic) NSString *recurisiveDescription;

/* class methods */
+ (id)placeholderNodeWithIndentation:(unsigned long long)indentation;
+ (id)nodeFromTrackedParagraph:(id)paragraph textView:(id)view;

/* instance methods */
- (id)description;
- (void)addChild:(id)child;
- (id)linerizedRepresentation;
- (void)recursivlyAddDescriptionToString:(id)string;
- (void)recursivlyAddTrackedParagraphsToArray:(id)array;
- (void)recursivlySortCheckedItemsToBottom;

@end


@interface ICVisualAssetImportController : NSObject

@property (nonatomic) _Bool isShowing;

/* instance methods */
- (id)init;
- (id)initWithCoder:(id)coder;
- (void)addImageData:(id)data typeIdentifier:(id)identifier;
- (void)addImageData:(id)data typeIdentifier:(id)identifier forceAddToPaper:(_Bool)paper;
- (id)initWithNote:(id)note textView:(id)view;
- (void)presentVisualAssetPickerController;

@end


@interface LinkEditorController : NSObject <ICLinkInsertionDelegate>

@property (nonatomic, readonly) _Bool languageHasSpaces;
@property (nonatomic, readonly) long long writingDirection;
@property (nonatomic, readonly) ICNote *note;
@property (nonatomic, readonly) NSViewController *acceleratorHostingViewController;
@property (nonatomic, readonly) NSView *acceleratorHostingView;
@property (nonatomic, readonly) ICNAEventReporter *eventReporter;
@property (nonatomic, readonly) NSString *searchString;
@property (nonatomic, readonly) NSTextView *textViewForAccelerator;
@property (nonatomic, readonly) ICAttachmentInsertionController *attachmentInsertionController;
@property (nonatomic, retain) _TtC11NotesEditor24LinkEditorViewController *viewController;
@property (nonatomic, weak) id <ICLinkInsertionDelegate> delegate;
@property (nonatomic) long long addApproach;
@property (nonatomic, retain) NSTextView *textView;
@property (nonatomic, retain) ICLinkAcceleratorController *linkAcceleratorController;

/* class methods */
+ (id)noteFor:(id)_for;
+ (id)noteForNoteID:(id)id;
+ (id)noteIDFor:(id)idfor;

/* instance methods */
- (void)setupObservers;
- (id)init;
- (void)cancel;
- (id)initWithCoder:(id)coder;
- (void)cancelAction:(id)action;
- (void)hideAccelerator;
- (void)acceleratorOriginNeedsUpdate;
- (void)didSelectNoteSuggestionWithIdentifier:(id)identifier title:(id)title;
- (void)dismissIn:(id)in completion:(id /* block */)completion;
- (void)dismissWithActionWithCompletion:(id /* block */)completion;
- (void)doneAction:(id)action;
- (void)insertLinkURLWithUrl:(id)url;
- (void)insertTextNoteLinkWithNoteSelection:(id)selection note:(id)note;
- (void)insertTokenizedNoteLinkWithNoteSelection:(id)selection;
- (void)removeLink;
- (id)sanitizedWithString:(id)string;
- (void)selectedSuggestionWithSelection:(id)selection;
- (void)updateParagraphsFor:(id)_for;
- (void)updateParagraphsWithSelection:(id)selection;
- (void)validateSelection;

@end


@interface _TtC11NotesEditor11LinkActions : NSObject // (Swift)

/* class methods */
+ (void)removeLinkAttachment:(id)attachment from:(id)from at:(struct _NSRange)at;
+ (void)removeLinkFromTextStorage:(id)storage range:(struct _NSRange)range;
+ (void)removeLinksFromTextStorage:(id)storage range:(struct _NSRange)range;

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesEditor14LinkTokenField : NSTokenField // (Swift)

/* instance methods */
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC11NotesEditor14TranscriptView : NSTextView <NSGestureRecognizerDelegate>

/* instance methods */
- (_Bool)gestureRecognizer:(id)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)recognizer;
- (void)layout;
- (_Bool)validateUserInterfaceItem:(id)item;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)initWithFrame:(struct CGRect)frame textContainer:(id)container;
- (void)performTextFinderAction:(id)action;
- (void)clickToSeek:(id)seek;

@end


@interface _TtC11NotesEditor15SummaryTextView : NSTextView // (Swift)

/* instance methods */
- (id)init;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)initWithFrame:(struct CGRect)frame textContainer:(id)container;

@end


@interface _TtC11NotesEditor16SummaryViewModel : _TtCs12_SwiftObject

@end


@interface _TtC11NotesEditor18RecordingViewModel : _TtCs12_SwiftObject

/* instance methods */
- (void)audioControllerPlaybackStateChanged:(id)changed;
- (void)handleBackgroundTranscriptionFinished:(id)finished;
- (void)handleBackgroundTranscriptionStarted:(id)started;
- (void)handleDownloadFinishedNotification:(id)notification;
- (void)handleDownloadStartedNotification:(id)notification;
- (void)handleTimeNotificationWithNotification:(id)notification;

@end


@interface _TtC11NotesEditor19ICFeedbackExtension : _TtCs12_SwiftObject

@end


@interface _TtC11NotesEditor22ICPDFTextFindingResult : ICTextFindingResult

/* class methods */
+ (void)resultsInAttachment:(ICAttachment *)attachment matchingString:(NSString *)string textView:(ICMacTextView *)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

/* instance methods */
- (long long)compare:(id)compare;
- (id)init;
- (id)containingViewInTextView:(id)view;
- (id)framesForHighlightInTextView:(id)view;
- (void)scrollToVisibleInTextView:(id)view;
- (void)selectInTextView:(id)view;

@end


@interface _TtC11NotesEditor23ICRecordButtonPresenter : _TtCs12_SwiftObject

@end


@interface _TtC11NotesEditor23ICRecordButtonViewModel : _TtCs12_SwiftObject

@end


@interface _TtC11NotesEditor23LinkTokenAttachmentCell : NSTokenAttachmentCell

/* instance methods */
- (id)initWithCoder:(id)coder;
- (void)drawTokenWithFrame:(struct CGRect)frame inView:(id)view;
- (id)initTextCell:(id)cell;
- (struct CGRect)titleRectForBounds:(struct CGRect)bounds;
- (id)tokenTintColor;

@end


@interface _TtC11NotesEditor23OutlineDisclosureButton : NSButton

@property (nonatomic) long long writingDirection;

/* instance methods */
- (id)accessibilityLabel;
- (id)initWithFrame:(struct CGRect)frame;
- (id)accessibilityRole;
- (id)accessibilityUserInputLabels;
- (id)initWithCoder:(id)coder;
- (void)scrollWheel:(id)wheel;
- (void)buttonPressedWithSender:(id)sender;

@end


@interface _TtC11NotesEditor24ICMSystemPaperLinkHelper : NSObject

@property (nonatomic, readonly) NSViewController *linkPopover;

/* instance methods */
- (id)initWithDelegate:(id)delegate;
- (id)init;
- (void)fetchLinkableItems;

@end


@interface _TtC11NotesEditor24ICRecordButtonAppFactory : NSObject

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesEditor24ICRecordButtonRepository : NSObject

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesEditor24LinkEditorViewController : NSObject <NSTokenFieldDelegate, NSTokenTextFieldDelegation>

/* instance methods */
- (void)controlTextDidEndEditing:(id)editing;
- (void)controlTextDidChange:(id)change;
- (_Bool)control:(id)control textView:(id)view doCommandBySelector:(SEL)selector;
- (id)init;
- (id)tokenField:(id)field displayStringForRepresentedObject:(id)object;
- (_Bool)tokenField:(id)field hasMenuForRepresentedObject:(id)object;
- (id)tokenField:(id)field setUpTokenAttachmentCell:(id)cell forRepresentedObject:(id)object;
- (id)tokenField:(id)field shouldAddObjects:(id)objects atIndex:(long long)index;
- (unsigned long long)tokenField:(id)field styleForRepresentedObject:(id)object;
- (void)cancelActionWithSender:(id)sender;
- (void)doneActionWithSender:(id)sender;
- (void)noteDecryptedStatusDidChange;
- (void)removeLinkWithSender:(id)sender;

@end


@interface _TtC11NotesEditor24TextCorrectionMarkerView : NSView

@property (nonatomic, readonly) _Bool flipped;
@property (nonatomic) struct CGRect frame;

/* instance methods */
- (void)drawRect:(struct CGRect)rect;
- (_Bool)isFlipped;
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)hitTest:(struct CGPoint)test;
- (void)textViewLayoutDidChange:(id)change;

@end


@interface _TtC11NotesEditor24TranscriptViewController : NSViewController <NSTextContentManagerDelegate, NSTextViewDelegate, NSGestureRecognizerDelegate>

/* instance methods */
- (void)scrollViewDidScroll:(id)scroll;
- (void)loadView;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (void)dealloc;
- (void)viewWillDisappear;
- (id)initWithCoder:(id)coder;
- (struct _NSRange)textView:(id)view willChangeSelectionFromCharacterRange:(struct _NSRange)range toCharacterRange:(struct _NSRange)range;
- (void)viewWillAppear;
- (void)audioDidStopWithNotification:(id)notification;
- (void)audioPlaybackTimeDidChangeWithNotification:(id)notification;

@end


@interface _TtC11NotesEditor26ICSynapseContentItemsCache : NSObject <ICManagedObjectContextChangeControllerDelegate>

/* instance methods */
- (id)init;
- (id)managedObjectContextChangeController:(id)controller managedObjectIDsToUpdateForUpdatedManagedObjects:(id)objects;
- (void)managedObjectContextChangeController:(id)controller performUpdatesForManagedObjectIDs:(id)ids;
- (_Bool)managedObjectContextChangeControllerShouldUpdateImmediately:(id)immediately;

@end


@interface _TtC11NotesEditor27PaperDocumentEngagementData : NSObject <ICPaperDocumentEngagementData>

@property (nonatomic, readonly) NSString *attachmentIdentifier;
@property (nonatomic) _Bool hasActivity;
@property (nonatomic) _Bool hasSmallStateUsage;
@property (nonatomic) _Bool hasMediumStateUsage;
@property (nonatomic) _Bool hasLargeStateUsage;
@property (nonatomic) _Bool hasFullscreenStateUsage;
@property (nonatomic) long long startPageCount;
@property (nonatomic) long long endPageCount;
@property (nonatomic) _Bool hasGestures;
@property (nonatomic) _Bool hasScroll;
@property (nonatomic) _Bool hasPagination;
@property (nonatomic) _Bool hasPinchZoom;
@property (nonatomic) _Bool hasPinchToExpandState;
@property (nonatomic) _Bool hasCollabView;
@property (nonatomic) _Bool hasCollabEdit;
@property (nonatomic, readonly) long long startState;
@property (nonatomic, readonly) long long endState;

/* instance methods */
- (id)init;
- (void)reset;

@end


@interface _TtC11NotesEditor28ICRecordButtonViewController : _TtCs12_SwiftObject

@end


@interface _TtC11NotesEditor28ICSystemPaperPreviewProvider : NSObject <ICTextPreviewProvider>

/* instance methods */
- (id)init;
- (void)imageForTextPreviewUsingFindingResult:(ICTextFindingResult *)result inTextView:(ICMacBaseTextView *)view completion:(id /* block */)completion;

@end


@interface _TtC11NotesEditor29ICInlineDrawingFindResult_Mac : ICTextFindingResult

/* instance methods */
- (id)init;
- (id)containingViewInTextView:(id)view;
- (id)framesForHighlightInTextView:(id)view;
- (void)selectInTextView:(id)view;

@end


@interface _TtC11NotesEditor29LinkAcceleratorViewController : NSViewController

/* instance methods */
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)init;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC11NotesEditor32ICMSystemPaperLinkHelperDelegate : _TtCs12_SwiftObject <_TtP8PaperKit34PKPaperLinksViewControllerDelegate_>

/* instance methods */
- (void)paperLinksViewController:(id)controller didSelectSynapseLinkItem:(id)item;
- (id)paperLinksViewControllerExcludedUserActivities:(id)activities;
- (void)paperLinksViewControllerLinksMightHaveChanged:(id)changed;

@end


@interface _TtC11NotesEditor32LinkAcceleratorHostingController : NSViewController

/* instance methods */
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC11NotesEditor32MacLinkAcceleratorViewController : _TtC11NotesEditor29LinkAcceleratorViewController

/* instance methods */
- (id)init;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC11NotesEditor37PaperDocumentTextAttachmentHeaderView : NSView

/* instance methods */
- (id)initWithFrame:(struct CGRect)frame;
- (id)initWithCoder:(id)coder;
- (id)hitTest:(struct CGPoint)test;
- (void)more:(id)more;
- (void)toggleThumbnails:(id)thumbnails;

@end


@interface _TtC11NotesEditorP33_0207DD35BB3512C3C1BFE341EADC3AD924SummaryViewModelObserver : NSObject

/* instance methods */
- (id)init;
- (void)viewModelDidUpdate:(id)update;

@end


@interface _TtCC11NotesEditor31PaperDocumentTextAttachmentView29ICPaperViewControllerDelegate : _TtCs12_SwiftObject <_TtP8PaperKit27PaperViewControllerDelegate_>

/* instance methods */
- (void)paperDidScroll:(id)scroll;
- (id)decryptData:(id)data;
- (void)invalidated:(id)invalidated;
- (void)openLink:(id)link;
- (void)paperDidFailToLoad:(id)load error:(id)error;
- (void)paperDidSave:(id)save;

@end


@interface _TtCV11NotesEditor15AudioPlayerView20AudioPlayerViewModel : _TtCs12_SwiftObject

/* instance methods */
- (void)audioControllerPlayPauseToggled:(id)toggled;
- (void)audioControllerStopped:(id)stopped;
- (void)audioControllerTimeChanged:(id)changed;
- (void)takeValuesViaNotification;

@end


@interface ICAbstractTextAttachment (App)

/* instance methods */
- (id)newlyCreatedViewControllerForManualRendering:(_Bool)rendering layoutManager:(id)manager initialCharacterIndex:(unsigned long long)index;
- (id)viewForLayoutManager:(id)manager;

@end


@interface ICAttachmentInlineDrawingModel (TextFinding)

/* class methods */
+ (id)inlineDrawingTextFindingQueue;

/* instance methods */
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICAttachmentModel (TextFinding)

/* instance methods */
- (void)replaceAllOccurrencesOfQueryString:(id)string ignoreCase:(_Bool)_case wholeWords:(_Bool)words withText:(id)text;
- (void)replaceTextFindingResult:(id)result withReplacementString:(id)string;
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICAttachmentPDFModel (TextFinding)

/* instance methods */
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICAttachmentPaperDocumentModel (TextFinding)

/* instance methods */
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICAttachmentSystemPaperModel (TextFinding)

/* class methods */
+ (id)systemPaperTextFindingQueue;

/* instance methods */
- (_Bool)_supportsFastHandwrittenTextFind;
- (void)_textFindingResultsMatching:(NSString *)matching textView:(ICMacTextView *)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words completionHandler:(id /* block */)handler;
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICAttachmentTableModel (TextFinding)

/* instance methods */
- (void)replaceTextFindingResult:(id)result withReplacementString:(id)string tableViewController:(id)controller;
- (id)textFindingResultForMatchingRange:(struct _NSRange)range findableAttributedString:(id)string queryString:(id)string ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with row:(unsigned long long)row column:(unsigned long long)column;
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;
- (void)undoablyReplaceAllOccurrencesOfQueryString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with withText:(id)text tableViewController:(id)controller;
- (void)undoablyReplaceTextFindingResult:(id)result withReplacementString:(id)string tableViewController:(id)controller;

@end


@interface ICAudioTextAttachment (NotesEditor)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICBaseAttachmentView (SupplementalViewSupport) <ICSupplementalView>

/* instance methods */
- (id)viewIdentifier;

@end


@interface ICBrickTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICCalculateGraphExpressionTextAttachment (UI)

/* instance methods */
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICCalculateResultTextAttachment (UI)

/* instance methods */
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICDataCryptor (DCDataCryptorDelegate) <DCDataCryptorDelegate>

/* instance methods */
- (id)decryptEncryptedData:(id)data identifier:(id)identifier;
- (id)encryptData:(id)data identifier:(id)identifier;

@end


@interface ICDrawingTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;
- (id)newlyCreatedViewForManualRenderingInTextContainer:(id)container;

@end


@interface ICHashtagController (App) <ICAutoCompleteSuggestionsViewControllerDelegate>

/* class methods */
+ (void)addUnconfirmedAttributeToTextStorage:(id)storage atRange:(struct _NSRange)range;
+ (struct _NSRange)rangeOfUnconfirmedHashtagInTextStorage:(id)storage;

/* instance methods */
- (_Bool)isValidElement:(unsigned short)element;
- (_Bool)isValidPostfixCharacter:(unsigned short)character;
- (_Bool)range:(struct _NSRange)range hasValidPostfixCharacterForString:(id)string;
- (void)_checkForHashtagInEditedRange:(struct _NSRange)range ofTextStorage:(id)storage note:(id)note textView:(id)view allowAutoExplicitHashtag:(_Bool)hashtag isEndingEditing:(_Bool)editing languageHasSpaces:(_Bool)spaces parentAttachment:(id)attachment;
- (struct _NSRange)rangeToCheckForHashtagCreation:(struct _NSRange)creation;
- (void)autoCompleteSuggestionsViewController:(id)controller didSelectItem:(id)item;
- (void)clearAutoCompletionView;
- (void)clearUnconfirmedHashtagInTextStorage:(id)storage;
- (void)createNewHashtagIfNecessary:(struct _NSRange)necessary textStorage:(id)storage ignoreDelimiter:(_Bool)delimiter parentAttachment:(id)attachment;
- (void)currentRowSelected;
- (id)currentUnconfirmedHashtagString:(id)string textStorage:(id)storage;
- (void)dismissAutoCompletionView;
- (void)insertHashtagAttachment:(id)attachment toTextView:(id)view range:(struct _NSRange)range viaAutoComplete:(_Bool)complete delimiter:(id)delimiter;
- (void)insertHashtagWithText:(id)text viaAutoComplete:(_Bool)complete delimiter:(id)delimiter parentAttachment:(id)attachment;
- (void)insertHashtagWithText:(id)text viaAutoComplete:(_Bool)complete parentAttachment:(id)attachment;
- (_Bool)isAutoCompletionViewVisible;
- (_Bool)isEmoji:(id)emoji;
- (_Bool)isExistingHashtag:(id)hashtag hashtagSuggestionsArray:(id)array;
- (_Bool)isValidPostfixString:(id)string;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)updateAutoCompletionView:(id)view range:(struct _NSRange)range textView:(id)view ofTextStorage:(id)storage;
- (void)updateUIWhenAutoConversionOff:(id)off textStorage:(id)storage;
- (double)widthForItems:(id)items;

@end


@interface ICHashtagTextAttachment (UI)

/* instance methods */
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICImageTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICInlineAttachment (TextFinding)

/* instance methods */
- (id)textFindingResultsMatchingExpression:(id)expression ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with;
- (void)textFindingResultsMatchingString:(id)string textView:(id)view ignoreCase:(_Bool)_case wholeWords:(_Bool)words startsWith:(_Bool)with usePattern:(_Bool)pattern completion:(id /* block */)completion;

@end


@interface ICInlineAttachmentView (ICTextPreviewProvider) <ICSupplementalView, ICTextPreviewProvider>

/* instance methods */
- (id)viewIdentifier;
- (void)imageForTextPreviewUsingFindingResult:(id)result inTextView:(id)view completion:(id /* block */)completion;

@end


@interface ICInlineCanvasTextAttachment (MultiSceneSupport)

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;

@end


@interface ICInlineTextAttachment (UI)

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)viewProviderForParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;
- (Class)attachmentViewControllerClass;

@end


@interface ICInvitation (App)

/* instance methods */
- (id)highlight;

@end


@interface ICLinkTextAttachment (UI)

/* instance methods */
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICLockedTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICMentionTextAttachment (UI)

/* instance methods */
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICMentionsController (App) <ICAutoCompleteSuggestionsViewControllerDelegate>

/* instance methods */
- (void)insertMentionAttachment:(id)attachment atRange:(struct _NSRange)range viaAutoComplete:(_Bool)complete;
- (void)updateAutoCompletionView:(id)view range:(struct _NSRange)range textView:(id)view mentionString:(id)string;
- (id)autoCompleteController;
- (void)autoCompleteSuggestionsViewController:(id)controller didSelectItem:(id)item;
- (void)clearAutoCompletionView;
- (void)currentRowSelected;
- (void)insertMention:(id)mention toTextView:(id)view atRange:(struct _NSRange)range viaAutoComplete:(_Bool)complete;
- (_Bool)isAutoCompletionViewVisible;
- (id)moveCurrentUserToLast:(id)last;
- (void)performArrowDown;
- (void)performArrowUp;
- (void)performEscapeKey;
- (void)setAutoCompleteController:(id)controller;
- (double)widthForItems:(id)items;

@end


@interface ICMovieTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICNote (NotesEditor)

/* instance methods */
- (id)textStoragesFor:(id)_for;
- (id)visibleAttachmentTextStoragesForTextLayoutManager:(id)manager;

@end


@interface ICPDFTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;

@end


@interface ICPaperAttachmentCreationHelper (NotesEditor)

/* class methods */
+ (void)createPaperBundleForAttachment:(id)attachment fromDocCamInfoCollection:(id)collection imageCache:(id)cache completion:(id /* block */)completion;

@end


@interface ICPaperDocumentTextAttachment (App)

/* instance methods */
- (id)imageForBounds:(struct CGRect)bounds attributes:(id)attributes location:(id)location textContainer:(id)container;
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;
- (double)viewCornerRadius;

@end


@interface ICSearchIndexer (App)

/* instance methods */
- (id)mainContextObjectForObjectIDURIString:(id)iduristring;
- (void)reindexIfNecessaryWithDelegate:(id)delegate;
- (void)startBackgroundTaskIfNecessaryWithDelegate:(id)delegate block:(id /* block */)block;

@end


@interface ICTableTextAttachment (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (struct CGSize)attachmentSizeForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment;
- (Class)attachmentViewClassForTextContainer:(id)container;
- (Class)attachmentViewControllerClass;
- (id)printableTextContentForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (id)printableTextAttachmentsForAppearanceType:(unsigned long long)type textContainer:(id)container;
- (_Bool)supportsDraggingWithoutSelecting;

@end


@interface ICTextAttachment (App)

/* instance methods */
- (id)imageForBounds:(struct CGRect)bounds textContainer:(id)container characterIndex:(unsigned long long)index;
- (id)imageForBounds:(struct CGRect)bounds attributes:(id)attributes location:(id)location textContainer:(id)container;
- (void)placeView:(id)view withFrame:(struct CGRect)frame inParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (id)viewProviderForParentView:(id)view characterIndex:(unsigned long long)index layoutManager:(id)manager;
- (id)viewProviderForParentView:(id)view location:(id)location textContainer:(id)container;
- (struct CGSize)attachmentSizeForImageInTextContainer:(id)container intrinsicImageSize:(struct CGSize)size;
- (double)attachmentThumbnailViewHeight;
- (id)viewForLayoutManager:(id)manager;

@end


@interface ICTextController (Checklist)

/* class methods */
+ (_Bool)checklistAutoSortEnabled;
+ (_Bool)checklistAutoAlertShown;
+ (_Bool)needsToShowFirstTimeAutoSortChecklistAlert;
+ (void)setChecklistAutoAlertShown:(_Bool)shown;
+ (void)setChecklistAutoSortEnabled:(_Bool)enabled;

/* instance methods */
- (void)addImageViewsAfterSortIfNecessaryForTrackedInfos:(id)infos existingInfos:(id)infos textView:(id)view textContainerOrigin:(struct CGPoint)origin todoUUIDsToImageViews:(id)views;
- (void)addImageViewsBeforeSortIfNecessaryForTrackedInfos:(id)infos textView:(id)view textContainerOrigin:(struct CGPoint)origin todoUUIDsToImageViews:(id)views;
- (id)adjacentTrackedParagraphFromTrackedParagraph:(id)paragraph inDirection:(unsigned long long)direction inTextView:(id)view;
- (id)analyticsInfoForChecklistAtIndex:(unsigned long long)index textView:(id)view;
- (void)applySortFromOriginalParagraphs:(id)paragraphs sortedTrackedParagraphs:(id)paragraphs forTextView:(id)view checklistRange:(struct _NSRange)range;
- (void)autoSortChecklistForUnitTestAtIndex:(unsigned long long)index textView:(id)view;
- (void)autoSortChecklistIfNecessaryForTrackedParagraph:(id)paragraph textView:(id)view analyticsHandler:(id /* block */)handler;
- (_Bool)canMoveCheckedChecklistsToBottomInTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)canMoveListItemInDirection:(unsigned long long)direction inTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)checklistItemExistsMarkedCompleted:(_Bool)completed inTextView:(id)view forRanges:(id)ranges;
- (_Bool)containsAnyTodoItemMarkedCompleted:(_Bool)completed inRange:(struct _NSRange)range textStorage:(id)storage;
- (_Bool)containsOnlyChecklistItemsInTextView:(id)view forRange:(struct _NSRange)range;
- (id)createTreeFromTrackedParagraphs:(id)paragraphs textView:(id)view;
- (id)expandedChecklistTrackedParagraphsInTextView:(id)view forIndex:(long long)index;
- (struct _NSRange)expandedRangeForContiguousTodosForRange:(struct _NSRange)range textView:(id)view;
- (void)getTodoSelected:(_Bool *)selected andAtLeastOneTodoUnchecked:(_Bool *)unchecked inTextView:(id)view;
- (id)imageInfoForTrackedParagraph:(id)paragraph textView:(id)view characterRangeToRender:(struct _NSRange)render visibleRectToRender:(struct CGRect)render;
- (void)markAllChecklistItemsCompleted:(_Bool)completed inTextview:(id)textview forSelectedRanges:(id)ranges;
- (_Bool)moveCheckedChecklistsToBottomInTextView:(id)view forRange:(struct _NSRange)range;
- (_Bool)moveCheckedChecklistsToBottomInTextView:(id)view forRange:(struct _NSRange)range animated:(_Bool)animated;
- (_Bool)moveListItemInDirection:(unsigned long long)direction inTextView:(id)view forRange:(struct _NSRange)range;
- (id)paragraphInfoForCharacterAtIndex:(unsigned long long)index includeChildren:(_Bool)children textStorage:(id)storage;
- (void)performAnimatedSortForTrackedParagraphs:(id)paragraphs expandedRange:(struct _NSRange)range textView:(id)view sortChecklistsBlock:(id /* block */)block;
- (id)rangeForChecklistItemInRange:(struct _NSRange)range textStorage:(id)storage;
- (id)rangesForTodosInRange:(struct _NSRange)range markedCompleted:(_Bool)completed textStorage:(id)storage;
- (void)removeChecklistItemsMarkedCompleted:(_Bool)completed inTextView:(id)view forRanges:(id)ranges;
- (void)sendTextDidChangeNotificationForTextView:(id)view;
- (void)setFinalFramesForSortedInfos:(id)infos textView:(id)view textContainerOrigin:(struct CGPoint)origin todoUUIDsToImageViews:(id)views;
- (void)showFirstTimeAutoSortEnabledAlertIfNecessaryWithTextView:(id)view completionHandler:(id /* block */)handler analyticsHandler:(id /* block */)handler;
- (void)showFirstTimeAutoSortEnabledAlertWithTextView:(id)view completionHandler:(id /* block */)handler analyticsHandler:(id /* block */)handler;
- (id)sortTrackedParagraphsMovingCheckedItemsToBottom:(id)bottom;
- (id)trackedParagraphsForTodosInRange:(struct _NSRange)range textStorage:(id)storage;
- (id)validAdjacentParagraphInfoFromParagraphInfo:(id)info inDirection:(unsigned long long)direction inTextView:(id)view;

@end


@interface ICTodoButton (SupplementalViewSupport) <ICSupplementalView>

/* instance methods */
- (id)viewIdentifier;

@end


@interface ICUnsupportedTextAttachmentWithFallbackImage (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;

@end


@interface ICUnsupportedTextAttachmentWithFallbackPDF (UI)

/* instance methods */
- (struct CGSize)attachmentSizeForTextContainer:(id)container;
- (Class)attachmentViewClassForTextContainer:(id)container;
- (short)effectiveAttachmentViewSizeForTextContainer:(id)container;

@end


@interface NSTextAttachmentCell (ICAccessibility_OSX)

/* instance methods */
- (_Bool)isAccessibilityElement;

@end


@interface NSTextContainer (NotesEditor)

/* instance methods */
- (id)tk2TextView;

@end


@interface NSView (ICAccessibility) <ICSupplementalView>

/* instance methods */
- (id)viewIdentifier;
- (id)icaxAncestorViewPassingTest:(id /* block */)test;

@end


@interface PKTextAttachmentDrawingView (ICAccessibility_OSX)

/* instance methods */
- (id)accessibilityLabel;
- (_Bool)isAccessibilityElement;
- (id)icmAccessibilityLabel;
- (id)icmAccessibilityValue;

@end


#endif /* NotesEditor_h */
