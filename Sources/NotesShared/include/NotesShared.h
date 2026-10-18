// Normalized full dump import surface for NotesShared.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesShared_h

#define NotesShared_h



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





struct CGAffineTransform;

struct CGPoint;

struct CGRect;

struct CGSize;

struct Document;

struct ICDeviceHardwareInfo;

struct ICDrawingCommandID;

struct TopoID;

struct TopoIDRange;

struct _NSRange;

struct os_unfair_lock_s;



@class ACAccount, AVAsset, AVAssetTrack, CKContainer, CKRecord, CKRecordID, CKRecordSystemFieldsTransformer, CKRecordZoneID, CKServerChangeToken, CKShare, CKShareSystemFieldsTransformer, CLGeocoder;

@class CLLocationManager, CLPlacemark, CRContext, CRTable, CSSearchQuery, CSSearchableItem, CSSearchableItemAttributeSet, CSSuggestion, CloudSessionChanges, ICAESCipherUtils, ICAccount, ICAccountCryptoStrategyProxy;

@class ICAccountCryptoStrategyV1, ICAccountCryptoStrategyV1Neo, ICAccountCryptoStrategyV2, ICAccountData, ICAccountProxy, ICAccountUtilities, ICActivityStreamDigest, ICAirDropDocument, ICAppContext, ICAppURLRequestShareAccessDeeplinkMetadata, ICAppURLUtilities, ICAppearanceInfo;

@class ICAssetGeneration, ICAssetGenerationManager, ICAssetSignature, ICAttachment, ICAttachmentAudioModel, ICAttachmentAudioModelCompositionInfo, ICAttachmentCryptoStrategyV1, ICAttachmentCryptoStrategyV1Neo, ICAttachmentCryptoStrategyV2, ICAttachmentDrawingModel, ICAttachmentGalleryModel, ICAttachmentGenericModel;

@class ICAttachmentImageModel, ICAttachmentInlineDrawingModel, ICAttachmentInsertionController, ICAttachmentLocation, ICAttachmentMapModel, ICAttachmentMigrationPolicy, ICAttachmentModel, ICAttachmentMovieModel, ICAttachmentPDFModel, ICAttachmentPaperBundleModel, ICAttachmentPaperDocumentModel, ICAttachmentPreviewImage;

@class ICAttachmentPreviewImageCache, ICAttachmentPreviewImageCryptoStrategyV1, ICAttachmentPreviewImageCryptoStrategyV1Neo, ICAttachmentPreviewImageCryptoStrategyV2, ICAttachmentSystemPaperModel, ICAttachmentTableModel, ICAttachmentWebModel, ICAttachmentsFilterTypeSelection, ICAttributedStringSecureUnarchiveFromDataTransformer, ICAuthenticationState, ICAutoCompleteSuggestionsItem, ICAutoCompleteSuggestionsViewController;

@class ICAutoFormatMarkdownController, ICBackgroundTaskScheduler, ICBackgroundTranscriptionHelper, ICBaseAttachment, ICBaseSearchIndexerDataSource, ICBundleChangeFilePresenter, ICBundleChangeObserver, ICBundleContainerFilePresenter, ICCKShareUnknownParticipant, ICCRArray, ICCRCoder, ICCRCoderArchiver;

@class ICCRCoderUnarchiver, ICCRCoderUnarchiverCompletionHandler, ICCRConstant, ICCRDictionary, ICCRDictionaryElement, ICCRDocument, ICCRIndex, ICCRIndexElement, ICCRObject, ICCROneOf, ICCROrderedSet, ICCROrderedSetElement;

@class ICCRRegister, ICCRRegisterGreatest, ICCRRegisterLatest, ICCRRegisterLeast, ICCRRegisterMultiValue, ICCRRegisterMultiValueLeast, ICCRSet, ICCRTTCompatibleDocument, ICCRTimestamp, ICCRTombstoneOrderedSet, ICCRTree, ICCRTreeNode;

@class ICCRTuple, ICCRVectorTimestamp, ICCRVectorTimestampElement, ICCRWeakReference, ICCache, ICChecklistsFilterTypeSelection, ICCipherV1, ICCipherV1Neo, ICCipherV2, ICCloudConfiguration, ICCloudContext, ICCloudKitSyncer;

@class ICCloudNotificationsController, ICCloudOperationObserver, ICCloudSession, ICCloudState, ICCloudSyncBackgroundTask, ICCloudSyncingObject, ICCloudSyncingObjectActivityEvent, ICCloudSyncingObjectCryptoStrategyV1, ICCloudSyncingObjectCryptoStrategyV1Neo, ICCloudSyncingObjectCryptoStrategyV2, ICCloudSyncingObjectMigrationPolicy, ICCloudThrottlingLevel;

@class ICCloudThrottlingPolicy, ICCompatibilityController, ICCompatibilityControllerDevice, ICCriticalActivityPerformer, ICCrossAppHashtagManager, ICCryptoConvergenceController, ICCryptoConvergenceControllerConfiguration, ICCryptoStrategyBase, ICCryptoStrategyFactory, ICDataCryptor, ICDataPersister, ICDatabaseStateHandler;

@class ICDateCreatedFilterTypeSelection, ICDateEditedFilterTypeSelection, ICDateFilterTypeSelection, ICDefaultAccountUtilities, ICDeviceListRequest, ICDeviceManagementRestrictionsManager, ICDeviceMigrationState, ICDimensionMaxCache, ICDimensionSumCache, ICDistributedLock, ICDividerLineTextAttachment, ICDrawing;

@class ICDrawingCommand, ICDrawingCommandData, ICDrawingOutputPoint, ICDrawingVersionedDocument, ICEncryptedData, ICEncryptionKey, ICEncryptionMetadata, ICEncryptionObject, ICEvernoteContentParser, ICEvernoteNote, ICEvernoteNoteParser, ICEvernoteResource;

@class ICFallbackSystemTextAttachment, ICFileUtilities, ICFilterSelection, ICFilterTypeSelection, ICFolder, ICFolderCustomNoteSortType, ICFoldersFilterTypeSelection, ICFullDeviceInfo, ICHandoffController, ICHashtag, ICHashtagController, ICHashtagSuggestionItem;

@class ICHashtagsCheckResults, ICHashtagsNode, ICImageCache, ICInclusionFilterTypeSelection, ICInlineAttachment, ICInlineAttachmentCryptoStrategyV1, ICInlineAttachmentCryptoStrategyV1Neo, ICInlineAttachmentCryptoStrategyV2, ICInvitation, ICKeychain, ICLRUCache, ICLegacyAccountUtilities;

@class ICLegacyAttachmentFileWrapper, ICLegacyAttachmentUtilities, ICLegacyContentUtilities, ICLegacyTombstone, ICLinkSuggestionQuery, ICLocalAuthentication, ICLocalFileWrapper, ICLocation, ICLocationContext, ICLocationMigrationPolicy, ICLockedNotesFilterTypeSelection, ICMacLocalizedStrings;

@class ICManagedObjectContextUpdater, ICMarkupUtilities, ICMedia, ICMediaCryptoStrategyV1, ICMediaCryptoStrategyV1Neo, ICMediaCryptoStrategyV2, ICMentionCheckResults, ICMentionsController, ICMentionsFilterTypeSelection, ICMentionsParticipantNode, ICMergeableDictionary, ICMigrationDeviceInfo;

@class ICMigrationUtilities, ICMinimalDeviceInfo, ICModernSearchIndexProgressDataSource, ICModernSearchIndexerDataSource, ICNote, ICNoteAllAccountVisibilityTesting, ICNoteContainer, ICNoteContext, ICNoteCryptoStrategyV1, ICNoteCryptoStrategyV1Neo, ICNoteCryptoStrategyV2, ICNoteData;

@class ICNoteMergePolicy, ICNoteParticipant, ICNotePasteboardData, ICNotesCrossProcessChangeCoordinator, ICNotesInvernessClient, ICNotesInvernessClientObjc, ICOCRGenerator, ICOperationQueueObserver, ICOutlineState, ICPDFGenerator, ICPDFUtilities, ICPaperAttachmentCreationHelper;

@class ICPaperSynapseContentItemProvider, ICParticipantBaseColorValues, ICParticipantUpdater, ICParticipantsFilterTypeSelection, ICPasswordReaskController, ICPeerInputStream, ICPeerMessageController, ICPeerOutputStream, ICPersistentContainer, ICPinnedNotesFilterTypeSelection, ICPreviewDeviceInfo, ICQuery;

@class ICQueryObjC, ICQueryResultsController, ICQueryResultsControllerObjC, ICQuickNotesFilterTypeSelection, ICRandomNumberGenerator, ICRandomTextGenerator, ICRankingQueriesDefinition, ICRankingQueryDescriptor, ICReaderDelegateUtilities, ICRealtimeCollaborationSelectionState, ICReindexer, ICRemoteFileAttachmentDownloader;

@class ICRemoteFileWrapper, ICSearchIndexDiagnosticsStateHandler, ICSearchIndexState, ICSearchProfiler, ICSearchQuery, ICSearchQueryOperation, ICSearchQueryParser, ICSearchQuerySegment, ICSearchQueryTokenizer, ICSearchRankingStrategySwitch, ICSearchResultsQuery, ICSearchSuggestion;

@class ICSearchSuggestionsContext, ICSearchSuggestionsQuery, ICSearchToken, ICSelectorDelayer, ICServerChangeToken, ICServerChangeTokenMigrationPolicy, ICSettingsCloudContextDelegate, ICShareNotifier, ICShareParticipantCacheEntry, ICSharedFilterTypeSelection, ICSharedRecentlyDeletedSharedNoteUtilities, ICSortableSearchableItem;

@class ICSynapseLinkPreviewLoadingOperation, ICSystemPaperDrawingsHelper, ICSystemPaperSyncArchive, ICTTArray, ICTTAttachment, ICTTAudioDocument, ICTTAudioRecording, ICTTCRVectorTimestamp, ICTTFont, ICTTMergeableAttributedString, ICTTMergeableString, ICTTMergeableStringSelection;

@class ICTTMergeableStringUndoAttributeCommand, ICTTMergeableStringUndoEditCommand, ICTTMergeableStringUndoGroup, ICTTMergeableStringVersionedDocument, ICTTMergeableUndoString, ICTTMergeableWallClockValue, ICTTMutableParagraphStyle, ICTTOrderedSetVersionedDocument, ICTTParagraphStyle, ICTTTextEdit, ICTTTextEditFilter, ICTTTextEditGroup;

@class ICTTTextEditGrouper, ICTTTodo, ICTTVectorMultiTimestamp, ICTTVectorTimestamp, ICTTVectorTimestampElement, ICTTVersionedDocument, ICTable, ICTableAttachmentProvider, ICTableCellChangeNotifier, ICTableColumnTextView, ICTableVersionedDocument, ICTagSelection;

@class ICThumbnailData, ICThumbnailDataCache, ICTranscription, ICUTType, ICUnsupportedObjectPredicateHelper, ICUserSpecificRecordIDParser, NSEntityMigrationPolicy, NSImage, NSManagedObject, NSManagedObjectContext, NSManagedObjectID, NSMergePolicy;

@class NSPersistentStore, NSPersistentStoreCoordinator, NSTextAttachment, NSTextView, NotesAssistantAccountManager, NotesAssistantFolderOption, NotesAssistantMainThreadContext, NotesAssistantUtilities, PDSRegistrar, PKDrawing, SYContentItem, TTICCRVectorMultiTimestamp;

@class TopoID, TopoSubstring, _CSSuggestionToken, _TtC11NotesShared15ArgumentDecoder, _TtC11NotesShared15BufferConverter, _TtC11NotesShared16NotesDataManager, _TtC11NotesShared18TranscriptMetadata, _TtC11NotesShared20CancellableTaskQueue, _TtC11NotesShared20SummarizationManager, _TtC11NotesShared21CallRecordingSplitter, _TtC11NotesShared21ICSystemPaperDocument, _TtC11NotesShared21ICTTTranscriptSegment;

@class _TtC11NotesShared22ICModernObjectProvider, _TtC11NotesShared23SiriTranscriptionMethod, _TtC11NotesShared23TranscriptPostProcessor, _TtC11NotesShared24CallRecordingTranscriber, _TtC11NotesShared26NotesServiceAPIAsyncClient, _TtC11NotesShared28LiveTranscriptionCoordinator, _TtC11NotesShared28SiriSpeechRecognitionManager, _TtC11NotesShared29TranscriptPauseTextAttachment, _TtC11NotesShared34ICAttachmentSystemPaperModelHelper, _TtC11NotesShared38RealtimeCollaborationSelectionDocument, _TtC11NotesSharedP33_062F6D09343CCB133320AB174EF013C433ICCloudingSyncingObjectUndoTarget, _TtC11NotesSharedP33_452BF3924CAE69326F83BAE5FEEBFB4234CustomReplacementRegularExpression;

@class _TtCC11NotesShared12CloudSession12PhaseMetrics, _TtCC11NotesShared15ArgumentDecoder7Decoder, _TtCC11NotesShared21ICSystemPaperDocument17PaperBundleReader, _TtCC11NotesShared38RealtimeCollaborationSelectionDocument5State, _TtCE11NotesSharedCSo18ICTTAudioRecording8Fragment;

@protocol ICAccountCryptoStrategy, ICAccountObject, ICActivityEventResolving, ICAirDropDocument, ICAttachmentCryptoStrategy, ICAttachmentModelUI, ICAttachmentObject, ICAttachmentPreviewImageCryptoStrategy, ICAttachmentPreviewImageUI, ICBackgroundTask, ICCRCoding, ICCRDataType;

@protocol ICCREquatable, ICCRIdentifiable, ICCRUndoDelegate, ICCloudAnalyticsDelegate, ICCloudContextDelegate, ICCloudKitSyncerDelegate, ICCloudObject, ICCloudSessionDelegate, ICCloudSyncingObjectCryptoStrategy, ICCriticalActivityPerforming, ICDataPersister, ICDerivedAttributeProviding;

@protocol ICDocumentMergeControlling, ICFolderObject, ICHasDatabaseScope, ICHashtagAnalyticsDelegate, ICHashtagKeyboardDelegate, ICInlineAttachmentCryptoStrategy, ICLegacyAccount, ICLegacyAttachment, ICLegacyContext, ICLegacyFolder, ICLegacyNote, ICLoggable;

@protocol ICMediaCryptoStrategy, ICMentionsAnalyticsDelegate, ICMentionsControllerUI, ICMentionsKeyboardDelegate, ICNFMCAccountProxyManager, ICNoteContainer, ICNoteCryptoStrategy, ICNoteUI, ICNoteVisibilityTesting, ICPeerInputStreamDelegate, ICPeerMessageControllerDelegate, ICReaderDelegate;

@protocol ICSearchIndexProgressCoordinatorDataSource, ICSearchIndexable, ICSearchIndexableNote, ICSearchIndexableTarget, ICSearchSuggestionsResponder, ICStateHandlerProvider, ICTTAttachment, ICTTMergeableStringDelegate, ICTTMergeableStringIDTracker, ICTTMergeableStringUndoCommand, ICTTModelAttributeComparable, ICTableAttachmentProviderDelegate;

@protocol ICTableDelegate, ICTableObject, OS_dispatch_semaphore, OS_dispatch_source;



@protocol ICAccountCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

/* required instance methods */
- (void)removePassphrase;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;

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


@protocol ICAirDropDocument

@required

@property (readonly, nonatomic) id activityItem;

@optional

@end


@protocol ICAttachmentCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

/* required instance methods */
- (id)decryptedFallbackImageData;
- (id)decryptedFallbackPDFData;
- (_Bool)writeEncryptedFallbackImageData:(id)data;
- (_Bool)writeEncryptedFallbackPDFData:(id)pdfdata;

@optional

@end


@protocol ICAttachmentModelUI <NSObject>

@required

@optional

/* optional instance methods */
- (void)attachmentModelDealloc;

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


@protocol ICAttachmentPreviewImageCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

/* required instance methods */
- (id)decryptedImageData;
- (id)decryptedMetadata;
- (_Bool)writeEncryptedImageData:(id)data;
- (_Bool)writeEncryptedMetadata:(id)metadata;

@optional

@end


@protocol ICAttachmentPreviewImageUI <NSObject>

@required

@optional

/* optional instance methods */
- (void)clearCachedImage;
- (void)clearCachedOrientedImage;
- (_Bool)hasCachedImage;
- (void)writeOrientedPreviewToDisk;

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


@protocol ICCRCoding <ICCRDataType>

@required

/* required instance methods */
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@optional

@end


@protocol ICCRDataType <NSObject>

@required

/* required instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;

@optional

@end


@protocol ICCREquatable <ICCRDataType>

@required

@optional

@end


@protocol ICCRIdentifiable <ICCREquatable>

@required

/* required instance methods */
- (id)identity;

@optional

@end


@protocol ICCRUndoDelegate <NSObject>

@required

/* required instance methods */
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (_Bool)wantsUndoCommands;

@optional

@end


@protocol ICCloudContextDelegate <NSObject>

@required

/* required instance methods */
- (_Bool)cloudContext:(id)context hasContextOptions:(unsigned long long)options;
- (_Bool)isDaemonProcessForCloudContext:(id)context;
- (id)accountIDsForCloudContext:(id)context managedObjectContext:(id)context;
- (id)backgroundContextForCloudContext:(id)context;
- (void)cloudContext:(id)context didExceedQuotaForRecordID:(id)id accountID:(id)id;
- (void)cloudContext:(id)context didFetchShare:(id)share accountID:(id)id;
- (void)cloudContext:(id)context didFetchUserRecord:(id)record accountID:(id)id;
- (void)cloudContext:(id)context didPushRecordID:(id)id accountID:(id)id;
- (void)cloudContext:(id)context receivedZoneNotFound:(id)found accountID:(id)id;
- (void)cloudContext:(id)context sharedZoneWasDeleted:(id)deleted accountID:(id)id;
- (void)cloudContext:(id)context userDidDeleteRecordZoneWithID:(id)id accountID:(id)id;
- (id)persistentStoreCoordinatorForCloudContext:(id)context;
- (_Bool)supportsDeferredAssetDownloadForCloudContext:(id)context;
- (id)viewContextForCloudContext:(id)context;

@optional

/* optional instance methods */
- (_Bool)shouldSuppressUpdatingParticipantsOnShareChangeForCloudContext:(id)context;
- (void)cloudContext:(id)context didExceedQuotaRecoveringFromTrashWithCount:(unsigned long long)count;
- (_Bool)cloudContext:(id)context supportsOnDemandFetchForCloudObject:(id)object context:(id)context;
- (id)containersByAccountIDForCloudContext:(id)context;
- (id)overrideAccountIDForCloudContext:(id)context;
- (_Bool)shouldIgnoreNotificationsForCloudContext:(id)context;
- (_Bool)shouldSimulateQuotaExceededOnTrashRecoveryForCloudContext:(id)context;
- (_Bool)shouldSuppressShareNotificationsForCloudContext:(id)context;

@end


@protocol ICCloudObject <NSObject, ICHasDatabaseScope>

@required

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;

@property (class, readonly, nonatomic) _Bool supportsUserSpecificRecords;

/* class methods */
+ (void)enumerateAllCloudObjectsInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)allCloudObjectIDsInContext:(id)context passingTest:(id /* block */)test;
+ (void)enumerateAllCloudObjectsInContext:(id)context predicate:(id)predicate sortDescriptors:(id)descriptors relationshipKeyPathsForPrefetching:(id)prefetching batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)newPlaceholderObjectForRecordName:(id)name accountID:(id)id context:(id)context;
+ (_Bool)supportsUserSpecificRecords;

/* required instance methods */
- (void)deleteFromLocalDatabase;
- (id)descendantsNeedingOnDemandAssetFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;
- (void)didDeleteUserSpecificRecordID:(id)id;
- (_Bool)didFailToSaveUserSpecificRecordWithID:(id)id accountID:(id)id error:(id)error;
- (void)didFetchUserSpecificRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)didSaveUserSpecificRecord:(id)record;
- (void)fixBrokenReferencesWithError:(id)error;
- (id)makeCloudKitRecordForApproach:(long long)approach;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)makeUserSpecificCloudKitRecordForApproach:(long long)approach;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeDataFromUserSpecificRecord:(id)record accountID:(id)id;
- (void)moveBackToTrashAfterQuotaExceededErrorOnRecovery;
- (id)newlyCreatedRecord;
- (_Bool)objectFailedToBePushedToCloudWithOperation:(id)operation recordID:(id)id error:(id)error;
- (void)objectWasDeletedFromCloud;
- (void)objectWasDeletedFromCloudByAnotherDevice;
- (void)objectWasFetchedButDoesNotExistInCloud;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)objectWasPushedToCloudWithOperation:(id)operation serverRecord:(id)record;
- (void)objectWillBePushedToCloudWithOperation:(id)operation;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)updateFetchFlagsAndReturnRecordIDsNeedingFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;

@optional

@end


@protocol ICCloudSessionDelegate

@required

/* required instance methods */
- (void)operationEndedFor:(long long)_for in:(id)in metrics:(id)metrics error:(id)error;
- (void)phaseDidBegin:(long long)begin for:(id)_for;
- (void)phaseDidEnd:(long long)end for:(id)_for;
- (void)sessionDidBegin:(id)begin;
- (void)sessionDidEnd:(id)end with:(id)with;

@optional

@end


@protocol ICCloudSyncingObjectCryptoStrategy <NSObject>

@required

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;

/* required instance methods */
- (id)encryptData:(id)data;
- (id)decryptData:(id)data;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (id)decryptSidecarData:(id)data;
- (id)decryptedDataFromFileURL:(id)url;
- (id)decryptedSidecarDataFromFileURL:(id)url;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (id)encryptSidecarData:(id)data;
- (_Bool)encryptSidecarFileFromURL:(id)url toURL:(id)url;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (_Bool)hasSameKeyAsObject:(id)object;
- (id)initWithCloudSyncingObject:(id)object;
- (void)initializeCryptoPropertiesFromObject:(id)object;
- (void)invalidateStrategy;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isRecordAuthenticated:(id)authenticated;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (_Bool)rewrapDataAtURL:(id)url withMainKey:(id)key;
- (_Bool)rewrapFile:(id /* block */)file withMainKey:(id)key generationManager:(id)manager;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;
- (_Bool)serialize:(id)serialize toURL:(id)url;

@optional

@end


@protocol ICCriticalActivityPerforming <NSObject>

@required

@property (readonly) _Bool hasPendingCriticalActivities;

/* required instance methods */
- (void)performCriticalBackgroundActivityWithReason:(id)reason block:(id /* block */)block;

@optional

@end


@protocol ICDataPersister

@required

/* required instance methods */
- (id)loadDataForIdentifier:(id)identifier;
- (_Bool)saveData:(id)data identifier:(id)identifier;

@optional

@end


@protocol ICDerivedAttributeProviding

@required

@property (readonly, nonatomic) _Bool needsInitialDerivedAttributesUpdate;

/* required instance methods */
- (void)updateDerivedAttributesIfNeeded;

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


@protocol ICHasDatabaseScope <NSObject>

@required

@property (readonly, nonatomic) long long databaseScope;

@optional

@end


@protocol ICInlineAttachmentCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

@optional

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


@protocol ICLegacyContext <NSObject>

@required

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

/* required instance methods */
- (void)performBlockAndWait:(id /* block */)wait;
- (id)existingObjectWithID:(id)id error:(id *)error;
- (void)performBlock:(id /* block */)block;
- (id)allAccounts;
- (void)reset;
- (id)objectWithID:(id)id;
- (id)allVisibleNoteObjectIDsForAccountWithObjectID:(id)id;
- (id)allVisibleNotesForAccountWithObjectID:(id)id;
- (id)allVisibleNotesInFolder:(id)folder;
- (id)attachmentForIdentifier:(id)identifier;
- (unsigned long long)countOfVisibleNotesForAccount:(id)account;
- (id)folderForIdentifier:(id)identifier;
- (id)ic_objectsWithIDs:(id)ids;
- (_Bool)nonEmptyNoteExistsForLegacyAccountWithObjectID:(id)id;
- (id)noteForIdentifier:(id)identifier;

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


@protocol ICLoggable <NSObject>

@required

/* required instance methods */
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;

@optional

@end


@protocol ICMediaCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

/* required instance methods */
- (id)decryptedData;

@optional

@end


@protocol ICMentionsControllerUI <NSObject>

@required

@optional

/* optional instance methods */
- (id)fetchContactNamesForParticipants:(id)participants;
- (void)registerForContactsChangedNotification;

@end


@protocol ICNFMCAccountProxyManager <NSObject>

@required

/* required instance methods */
- (id)accountProxyForAccount:(id)account;

@optional

@end


@protocol ICNoteContainer <ICNoteVisibilityTesting>

@required

@property (readonly, nonatomic) ICAccount *noteContainerAccount;
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) ICFolderCustomNoteSortType *customNoteSortType;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) _Bool isAllNotesContainer;
@property (readonly, nonatomic) _Bool canBeSharedViaICloud;
@property (readonly, nonatomic) _Bool supportsEditingNotes;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) _Bool isModernCustomFolder;
@property (readonly, nonatomic) NSString *containerIdentifier;
@property (readonly, nonatomic) NSArray *visibleNotes;
@property (readonly, nonatomic) _Bool supportsDateHeaders;
@property (readonly, nonatomic) long long dateHeadersType;
@property (readonly, nonatomic) _Bool isShowingDateHeaders;
@property (readonly, nonatomic) unsigned long long visibleNotesCount;
@property (readonly, nonatomic) _Bool hasVisibleNotes;
@property (readonly, copy, nonatomic) NSString *titleForNavigationBar;
@property (readonly, copy, nonatomic) NSString *titleForTableViewCell;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, nonatomic) NSArray *visibleSubFolders;
@property (copy, nonatomic) NSData *subFolderOrderMergeableData;
@property (readonly, nonatomic) _Bool deleted;

/* required instance methods */
- (id)predicateForVisibleNotes;
- (void)saveSubFolderMergeableDataIfNeeded;
- (_Bool)isDeleted;
- (id)noteVisibilityTestingForSearchingAccount;
- (id)predicateForPinnedNotes;
- (_Bool)noteIsVisible:(id)visible;
- (void)applyDateHeadersType:(long long)type;
- (void)updateSubFolderMergeableDataChangeCount;
- (_Bool)mergeWithSubFolderMergeableData:(id)data;
- (id)ic_accessibilityIdentifier;

@optional

@end


@protocol ICNoteCryptoStrategy <ICCloudSyncingObjectCryptoStrategy>

@required

/* required instance methods */
- (_Bool)decrypt;
- (id)decryptNotePrimitiveData;
- (id)decryptTextDataOrSaveAsUnappliedRecordIfNotAuthenticated:(id)authenticated;
- (void)mergeEncryptedData:(id)data mergeConflict:(id)conflict;
- (_Bool)writeEncryptedNoteData:(id)data;

@optional

@end


@protocol ICNoteUI <NSObject>

@required

@optional

/* optional instance methods */
- (void)createMissingAttachmentsInTextStorage;
- (void)formatExpressionsInAttributedString:(id)string range:(struct _NSRange)range textStorageOffset:(long long)offset skipStaleExpressions:(_Bool)expressions;
- (void)noteDidApplyAttachmentViewTypeToAllAttachments;
- (void)noteDidClearDecryptedData;
- (void)noteDidMergeNoteDocumentWithUserInfo:(id)info;
- (void)noteDidReplaceDocument;
- (void)noteWillMergeDocumentWithUserInfo:(id)info;
- (void)noteWillReleaseTextStorage;
- (void)noteWillTurnIntoFault;
- (_Bool)shouldReleaseTextStorageWhenTurningIntoFault;
- (id)uiAttributedString;

@end


@protocol ICNoteVisibilityTesting <NSObject>

@required

/* required instance methods */
- (id)predicateForSearchableAttachments;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (id)predicateForSearchableNotes;

@optional

@end


@protocol ICPeerInputStreamDelegate <NSObject>

@required

/* required instance methods */
- (void)didDisconnectInputStream:(id)stream;
- (void)handleMessage:(id)message fromInputStream:(id)stream;

@optional

@end


@protocol ICPeerMessageControllerDelegate <NSObject>

@required

/* required instance methods */
- (_Bool)sendMessage:(id)message toSource:(id)source error:(id *)error;

@optional

@end


@protocol ICReaderDelegate <NSObject>

@required

@optional

/* optional instance methods */
- (id)fileWrapperForURL:(id)url;

@end


@protocol ICSearchIndexProgressCoordinatorDataSource <NSObject>

@required

@property (readonly, nonatomic) NSURL *persistenceURL;

/* required instance methods */
- (void)reset;
- (void)adoptIndexState:(unsigned long long)state forItemWithIdentifier:(id)identifier updatingProgress:(id)progress;
- (id)allItemIdentifiersForState:(unsigned long long)state;
- (void)fullProgressUpdateWithCompletionHandler:(id /* block */)handler;
- (void)revertStagingWithItemIdentifier:(id)identifier;
- (void)stageForProcessingWithItemIdentifier:(id)identifier updatingProgress:(id)progress;
- (unsigned long long)stateOfItemWithIdentifier:(id)identifier;

@optional

/* optional instance methods */
- (void)beginBatchPersistence;
- (void)endBatchPersistence;

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


@protocol ICSearchIndexableNote <ICSearchIndexable>

@required

@property (readonly, nonatomic) _Bool isSearchIndexableNote;
@property (readonly, nonatomic) _Bool isModernNote;
@property (readonly, nonatomic) NSSet *noteCellKeyPaths;
@property (readonly, nonatomic) _Bool hasUnreadChanges;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;
@property (readonly, nonatomic) _Bool isPinned;
@property (readonly, nonatomic) _Bool isPinnable;
@property (readonly, nonatomic) long long currentStatus;
@property (readonly, nonatomic) _Bool isPasswordProtected;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSAttributedString *attributedTitle;
@property (readonly, copy, nonatomic) NSString *trimmedTitle;
@property (readonly, copy, nonatomic) NSAttributedString *trimmedAttributedTitle;
@property (readonly, copy, nonatomic) NSString *noteAsPlainTextWithoutTitle;
@property (readonly, copy, nonatomic) NSAttributedString *noteWithoutTitle;
@property (readonly, copy, nonatomic) NSString *contentInfoText;
@property (readonly, copy, nonatomic) NSAttributedString *attributedContentInfoText;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedViaICloudFolder;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) NSArray *authorsExcludingCurrentUser;
@property (readonly, nonatomic) _Bool isUnsupported;
@property (readonly, copy, nonatomic) NSString *folderName;
@property (readonly, copy, nonatomic) NSString *folderNameForNoteList;
@property (readonly, nonatomic) id <ICFolderObject> folder;
@property (readonly, nonatomic) NSString *folderManagedIdentifier;
@property (readonly, nonatomic) NSArray *hashtagContentIdentifiers;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, copy, nonatomic) NSString *identifier;

@optional

@property (readonly, copy, nonatomic) NSString *widgetInfoText;

@end


@protocol ICSearchIndexableTarget <NSObject>

@required

@property (readonly, nonatomic) id <ICSearchIndexable> targetSearchIndexable;

@optional

@end


@protocol ICStateHandlerProvider <NSObject>

@required

/* class methods */
+ (void)registerStateHandler;

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


@protocol ICTTMergeableStringIDTracker <NSObject>

@required

/* required instance methods */
- (_Bool)hasTopoIDsThatCanChange;

@optional

@end


@protocol ICTTMergeableStringUndoCommand <NSObject, ICTTMergeableStringIDTracker>

@required

/* required instance methods */
- (_Bool)addToGroup:(id)group;
- (void)applyToString:(id)string;

@optional

@end


@protocol ICTTModelAttributeComparable <NSObject>

@required

/* required instance methods */
- (_Bool)isEqualToModelComparable:(id)comparable;

@optional

@end


@protocol ICTableObject <NSObject>

@required

@property (copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *typeUTI;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;

@optional

@end


@interface CKRecordSystemFieldsTransformer : NSValueTransformer

/* class methods */
+ (Class)transformedValueClass;

/* instance methods */
- (id)reverseTransformedValue:(id)value;
- (id)transformedValue:(id)value;

@end


@interface CKShareSystemFieldsTransformer : CKRecordSystemFieldsTransformer

/* class methods */
+ (Class)transformedValueClass;

/* instance methods */
- (id)reverseTransformedValue:(id)value;

@end


@interface ICCRObject : NSObject <ICCRDataType, ICCREquatable, ICCRIdentifiable, ICCRCoding>

@property (weak, nonatomic) ICCRDocument *document;
@property (readonly, nonatomic) NSUUID *identity;
@property (readonly, nonatomic) NSDictionary *fields;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)resolveInstanceMethod:(SEL)method;
+ (id)CRProperties;
+ (id)keyFromSelector:(SEL)selector;
+ (_Bool)allowsUnknownProperties;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)mergeWithObject:(id)object;
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (void)setFieldKey:(id)key value:(id)value;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithDocument:(id)document identity:(id)identity;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface CRTable : ICCRObject <ICCRUndoDelegate>

@property (retain, nonatomic) NSString *columnDirection;
@property (readonly, nonatomic) ICCRTombstoneOrderedSet *crColumns;
@property (readonly, nonatomic) ICCRTombstoneOrderedSet *crRows;
@property (readonly, nonatomic) ICCRDictionary *cellColumns;
@property (weak, nonatomic) NSObject<ICCRUndoDelegate> *delegate;
@property (readonly, nonatomic) unsigned long long columnCount;
@property (readonly, nonatomic) unsigned long long rowCount;
@property (readonly, nonatomic) _Bool isRightToLeft;
@property (readonly, nonatomic) _Bool isLeftToRight;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)CRProperties;
+ (void)registerWithICCRCoder;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithDocument:(id)document;
- (id)identity;
- (void)enumerateRowsWithBlock:(id /* block */)block;
- (id)insertColumnAtIndex:(unsigned long long)index;
- (id)insertRowAtIndex:(unsigned long long)index;
- (void)moveColumnAtIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)moveRowAtIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)removeColumnAtIndex:(unsigned long long)index;
- (void)removeRowAtIndex:(unsigned long long)index;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (_Bool)wantsUndoCommands;
- (_Bool)containsColumn:(id)column;
- (id)columnsIntersectingWithColumns:(id)columns;
- (id)initWithDocument:(id)document isRightToLeft:(_Bool)left;
- (void)setObject:(id)object columnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (void)undoablyRemoveContentsOfColumn:(id)column;
- (unsigned long long)columnIndexForIdentifier:(id)identifier;
- (id)columnIndexesForIdentifiers:(id)identifiers;
- (_Bool)containsRow:(id)row;
- (unsigned long long)countOfPopulatedCells;
- (id)crTableColumnDirection;
- (id)defaultContentAtColumn:(id)column row:(id)row;
- (void)enumerateCellObjectsInCellSelectionContainingColumnIndices:(id)indices rowIndices:(id)indices copyItems:(_Bool)items usingBlock:(id /* block */)block;
- (void)enumerateColumnsWithBlock:(id /* block */)block;
- (id)identifierForColumnAtIndex:(unsigned long long)index;
- (id)identifierForRowAtIndex:(unsigned long long)index;
- (id)identifiersForColumnIndexes:(id)indexes;
- (id)identifiersForRowIndexes:(id)indexes;
- (id)initWithDocument:(id)document columnDirection:(id)direction;
- (id)initWithDocument:(id)document columnDirection:(id)direction crColumns:(id)columns crRows:(id)rows cellColumns:(id)columns;
- (id)insertColumns:(unsigned long long)columns atIndex:(unsigned long long)index;
- (id)insertRows:(unsigned long long)rows atIndex:(unsigned long long)index;
- (id)objectForColumnID:(id)id rowID:(id)id;
- (id)objectForColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (void)reverseColumnDirection;
- (unsigned long long)rowIndexForIdentifier:(id)identifier;
- (id)rowIndexesForIdentifiers:(id)identifiers;
- (id)rowsIntersectingWithRows:(id)rows;
- (void)setObject:(id)object columnID:(id)id rowID:(id)id;
- (id)subtableWithDocument:(id)document forSelectionContainingColumnIndices:(id)indices rowIndices:(id)indices;
- (void)undoablyInsertContents:(id)contents atColumn:(id)column;
- (void)undoablyInsertContents:(id)contents atRow:(id)row;
- (void)undoablyRemoveContentsOfRow:(id)row;

@end


@interface CloudSessionChanges : NSObject

/* instance methods */
- (id)init;

@end


@interface ICAESCipherUtils : NSObject

/* class methods */
+ (id)_ic_decrypt:(id)_ic_decrypt withCipherKey:(id)key standardKeyLength:(unsigned long long)length additionalAuthenticatedData:(id)data inputTag:(id)tag standardTagLength:(unsigned long long)length inputInitializationVector:(id)vector standardInitializationVectorLength:(unsigned long long)length error:(id *)error;
+ (id)_ic_encrypt:(id)_ic_encrypt withCipherKey:(id)key standardKeyLength:(unsigned long long)length additionalAuthenticatedData:(id)data outputTag:(id *)tag standardTagLength:(unsigned long long)length outputInitializationVector:(id *)vector standardInitializationVectorLength:(unsigned long long)length error:(id *)error;
+ (id)_ic_unwrap:(id)_ic_unwrap withWrapper:(id)wrapper standardKeyLength:(unsigned long long)length standardWrappedKeyLength:(unsigned long long)length error:(id *)error;
+ (id)_ic_wrap:(id)_ic_wrap withWrapper:(id)wrapper standardKeyLength:(unsigned long long)length standardWrappedKeyLength:(unsigned long long)length error:(id *)error;

@end


@interface ICCloudSyncingObject : NSManagedObject <ICCloudObject, ICLoggable>

@property (readonly, copy, nonatomic) NSDate *shareTimestamp;
@property (nonatomic, readonly) NSDate *objc_shareTimestamp;
@property (nonatomic) _Bool didAddAuthenticationStateObservers;
@property (nonatomic) _Bool needsToSaveUserSpecificRecord;
@property long long failedToSyncCount;
@property long long numberOfPushAttemptsToWaitCount;
@property (copy, nonatomic) NSString *lastUpdateChangeCountReason;
@property (nonatomic) long long minimumSupportedNotesVersion;
@property (readonly, nonatomic) ICMergeableDictionary *replicaIDToNotesVersion;
@property (readonly, nonatomic) NSMutableDictionary *participantHandlesToParticipants;
@property (readonly, nonatomic) NSMutableDictionary *mutableDecryptedValues;
@property (retain, nonatomic) ICAppContext *appContext;
@property (retain, nonatomic) NSData *serverRecordData;
@property (retain, nonatomic) CKRecord *serverRecord;
@property (retain, nonatomic) NSData *serverShareData;
@property (retain, nonatomic) CKShare *serverShare;
@property (retain, nonatomic) NSData *userSpecificServerRecordData;
@property (retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (retain, nonatomic) NSString *zoneOwnerName;
@property (retain, nonatomic) NSString *primitiveZoneOwnerName;
@property (readonly, nonatomic) _Bool shouldBeIgnoredForSync;
@property (retain, nonatomic) NSData *encryptedValuesJSON;
@property (nonatomic) _Bool mergingRecord;
@property (nonatomic) _Bool mergingUnappliedEncryptedRecord;
@property (readonly, nonatomic) CKShare *serverShareCheckingParent;
@property (readonly, copy, nonatomic) NSString *recordName;
@property (readonly, copy, nonatomic) NSString *recordZoneName;
@property (readonly, nonatomic) id <ICCloudSyncingObjectCryptoStrategy> cryptoStrategy;
@property (retain, nonatomic) id <ICCloudSyncingObjectCryptoStrategy> cryptoStrategyForMergingEncryptedData;
@property (readonly, nonatomic) _Bool canHaveCryptoStrategy;
@property (readonly, nonatomic) _Bool cryptoStrategyIsTransient;
@property (readonly, nonatomic) Protocol *cryptoStrategyProtocol;
@property (readonly, nonatomic) NSDictionary *decryptedValues;
@property (nonatomic) _Bool needsToLoadDecryptedValues;
@property (copy, nonatomic) NSData *primaryEncryptedData;
@property (retain, nonatomic) CKRecord *unappliedEncryptedRecord;
@property (readonly, copy, nonatomic) NSArray *ancestorCloudObjects;
@property (readonly, copy, nonatomic) NSArray *childCloudObjects;
@property (readonly, copy, nonatomic) NSArray *allChildCloudObjects;
@property (retain, nonatomic) NSData *activityEventsData;
@property (readonly, nonatomic) ICTTOrderedSetVersionedDocument *activityEventsDocument;
@property (retain, nonatomic) id persistedActivityEventsStorage;
@property (retain, nonatomic) id checklistItemToActivityEventsStorage;
@property (retain, nonatomic) NSData *replicaIDToNotesVersionData;
@property (retain, nonatomic) ICCloudState *cloudState;
@property (retain, nonatomic) NSString *identifier;
@property (retain, nonatomic) NSString *originalCloudIdentifier;
@property (retain, nonatomic) NSSet *assetSignatures;
@property (nonatomic) _Bool needsToBeFetchedFromCloud;
@property (nonatomic) _Bool needsInitialFetchFromCloud;
@property (nonatomic) _Bool markedForDeletion;
@property (nonatomic) _Bool needsToFetchUserSpecificRecordAssets;
@property (nonatomic) _Bool needsToUpdateUserSpecificRecordReferenceActions;
@property (nonatomic) _Bool isRecoveringFromTrash;
@property (readonly, copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) NSDate *modificationDate;
@property (nonatomic) _Bool isPasswordProtected;
@property (readonly, nonatomic) _Bool isPasswordProtectedAndLocked;
@property (nonatomic) long long cryptoIterationCount;
@property (retain, nonatomic) NSData *cryptoSalt;
@property (retain, nonatomic) NSData *cryptoInitializationVector;
@property (retain, nonatomic) NSData *cryptoTag;
@property (retain, nonatomic) NSData *cryptoWrappedKey;
@property (retain, nonatomic) NSString *passwordHint;
@property (retain, nonatomic) NSData *unappliedEncryptedRecordData;
@property (nonatomic) _Bool hasMissingKeychainItem;
@property (readonly, nonatomic) _Bool shouldSyncMinimumSupportedNotesVersion;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (retain, nonatomic) ICInvitation *invitation;
@property (nonatomic) _Bool isShareDirty;
@property (readonly, nonatomic) _Bool isDeprecated;
@property (readonly, nonatomic) _Bool isUnsupported;
@property (readonly, nonatomic) _Bool isVisible;
@property (readonly, nonatomic) _Bool needsInitialFetchFromCloudCheckingParent;
@property (readonly, copy, nonatomic) NSSet *deviceReplicaIDs;
@property (readonly, copy, nonatomic) NSUUID *currentReplicaID;
@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;

/* class methods */
+ (void)enumerateAllCloudObjectsInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)temporaryAssets;
+ (id)mergeableWallClockValueKeyPaths;
+ (id)allCloudObjectIDsInContext:(id)context passingTest:(id /* block */)test;
+ (id)allPasswordProtectedObjectsInContext:(id)context;
+ (id)assetForData:(id)data;
+ (id)assetForTemporaryURL:(id)url;
+ (id)assetForURL:(id)url;
+ (id)bundleIdentifiersWithReplicaID;
+ (id)cloudObjectWithIdentifier:(id)identifier context:(id)context;
+ (long long)currentNotesVersion;
+ (id)dataForAsset:(id)asset;
+ (void)deleteAllTemporaryAssetFilesForAllObjects;
+ (void)deleteTemporaryAssetFilesForOperation:(id)operation;
+ (void)deleteTemporaryFilesForAsset:(id)asset;
+ (id)deletedByThisDeviceOperationQueue;
+ (id)deletedByThisDeviceSet;
+ (void)enumerateAllCloudObjectsInContext:(id)context predicate:(id)predicate sortDescriptors:(id)descriptors relationshipKeyPathsForPrefetching:(id)prefetching batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)failedToSyncCountsByIdentifier;
+ (id)failureCountQueue;
+ (_Bool)hasAnySharedObjectInContext:(id)context;
+ (_Bool)identifierContainsInvalidCharacters:(id)characters;
+ (id)keyPathsForValuesAffectingCanBeSharedViaICloud;
+ (id)keyPathsForValuesAffectingCloudAccount;
+ (id)keyPathsForValuesAffectingIsSharedReadOnly;
+ (id)keyPathsForValuesAffectingIsSharedViaICloud;
+ (id)keyPathsForValuesAffectingNeedsToBeDeletedFromCloud;
+ (id)keyPathsForValuesAffectingNeedsToBePushedToCloud;
+ (id)keyPathsForValuesAffectingServerShareCheckingParent;
+ (id)keyPathsForValuesAffectingZoneOwnerName;
+ (id)mergeUnappliedEncryptedRecordsQueue;
+ (_Bool)needsToReFetchServerRecordValue:(id)value;
+ (id)newObjectWithIdentifier:(id)identifier context:(id)context;
+ (id)newPlaceholderObjectForRecordName:(id)name accountID:(id)id context:(id)context;
+ (id)numberOfPushAttemptsToWaitByIdentifier;
+ (void)objc_removeAllCloudSyncingObjectActivityEventsForUnsharedObjectsInContext:(id)context;
+ (id)objectIDForShareRecordID:(id)id context:(id)context;
+ (id)objectWithRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)objectsWithRecordID:(id)id context:(id)context;
+ (id)predicateForDeprecatedObjects;
+ (id)predicateForFetchedFromCloudObjects;
+ (id)predicateForInCloudObjects;
+ (id)predicateForObjectsWithIdentifiers:(id)identifiers;
+ (id)predicateForPasswordProtectedObjects;
+ (id)predicateForUnmarkedForDeletionObjects;
+ (id)predicateForVisibleObjects;
+ (id)recordSystemFieldsTransformer;
+ (void)removeAllCloudSyncingObjectActivityEventsForUnsharedObjectsInContext:(id)context;
+ (void)resetAllDeletedByThisDeviceProperties;
+ (id)shareSystemFieldsTransformer;
+ (_Bool)supportsActivityEvents;
+ (_Bool)supportsNotesVersionTracking;
+ (_Bool)supportsUserSpecificRecords;
+ (id)temporaryAssetDirectoryURL;
+ (id)versionsByOperationQueue;
+ (id)versionsByRecordIDByOperation;

/* instance methods */
- (void)willSave;
- (_Bool)supportsDeletionByTTL;
- (id)viewContext;
- (id)sharedOwnerName;
- (_Bool)isSharedReadOnly;
- (_Bool)isSharedViaICloud;
- (_Bool)hasContextOptions:(unsigned long long)options;
- (id)cloudAccount;
- (_Bool)isOwnedByCurrentUser;
- (void)didTurnIntoFault;
- (_Bool)isAuthenticated;
- (void)awakeFromInsert;
- (id)workerManagedObjectContext;
- (_Bool)isInCloud;
- (_Bool)canAuthenticate;
- (void)awakeFromFetch;
- (id)initWithEntity:(id)entity insertIntoManagedObjectContext:(id)context;
- (_Bool)canBeSharedViaICloud;
- (_Bool)isDeletable;
- (id)shareType;
- (_Bool)validateIdentifier:(inout id *)identifier error:(out id *)error;
- (void)setInCloud:(_Bool)cloud;
- (id)shareDescription;
- (_Bool)allowsImporting;
- (id)ownerRecordName;
- (id)primaryEncryptedDataFromRecord:(id)record;
- (_Bool)allowsExporting;
- (void)didAcceptShare:(id)share;
- (_Bool)isMergingRecord;
- (void)markForDeletion;
- (void)addAuthenticationStateObserversIfNeeded;
- (void)addEmailAddressesAndPhoneNumbersToAttributeSet:(id)set;
- (void)applyRandomCryptoGooIfNeeded;
- (void)assignToPersistentStore:(id)store;
- (id)associatedNoteParticipants;
- (void)authenticationStateDidDeauthenticate:(id)deauthenticate;
- (void)authenticationStateWillDeauthenticate:(id)deauthenticate;
- (_Bool)canBeRootShareObject;
- (_Bool)canCurrentUserShare;
- (id)childCloudObjectsForMinimumSupportedVersionPropagation;
- (void)clearChangeCountWithReason:(id)reason;
- (void)clearDecryptedData;
- (void)clearReplicaIDsToNotesVersion;
- (void)clearServerRecords;
- (id)cloudContext;
- (void)decrementFailureCounts;
- (id)decryptedValueForKey:(id)key;
- (void)deleteChangeTokensAndReSync;
- (void)deleteFromLocalDatabase;
- (id)descendantsNeedingOnDemandAssetFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;
- (void)deserializeAndMergeValues:(id)values;
- (id)deviceManagementRestrictionsManager;
- (void)didDeleteUserSpecificRecordID:(id)id;
- (_Bool)didFailToSaveUserSpecificRecordWithID:(id)id accountID:(id)id error:(id)error;
- (void)didFetchUserSpecificRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)didSaveUserSpecificRecord:(id)record;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (void)findAndResaveUserSpecificRecordThrowingReferenceViolationForDeletionWithError:(id)error;
- (void)fixBrokenReferencesWithError:(id)error;
- (_Bool)hasAllMandatoryFields;
- (_Bool)hasAssetSignaturesForUserSpecific:(_Bool)specific;
- (_Bool)hasCommonAssetSignatures;
- (_Bool)hasExpectedReferenceActionsInUserSpecificRecord:(id)record;
- (_Bool)hasInvitees;
- (_Bool)hasOutOfDateCommonAssetSignatures;
- (_Bool)hasOutOfDateUserSpecificAssetSignatures;
- (_Bool)hasPassphraseSet;
- (_Bool)hasSuccessfullyPushedLatestVersionToCloud;
- (_Bool)hasUserSpecificAssetSignatures;
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;
- (void)incrementFailureCounts;
- (void)initializeCryptoProperties;
- (void)inlineAssetsForRecord:(id)record;
- (long long)intrinsicNotesVersionForScenario:(unsigned long long)scenario;
- (_Bool)isEncryptableKeyBinaryData:(id)data;
- (_Bool)isMergingUnappliedEncryptedRecord;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isPubliclyShared;
- (_Bool)isPubliclySharedOrHasInvitees;
- (long long)isPushingSameOrLaterThanVersion:(long long)version;
- (_Bool)isSharedRootObject;
- (_Bool)isSharedThroughParent;
- (id)makeCloudKitRecordForApproach:(long long)approach;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)makeUserSpecificCloudKitRecordForApproach:(long long)approach;
- (void)markShareDirtyIfNeededWithReason:(id)reason;
- (unsigned long long)mergeActivityEventsDocument:(id)document;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (void)mergeCryptoFieldsFromRecord:(id)record;
- (void)mergeCryptoTagAndInitializationVectorFromRecord:(id)record;
- (_Bool)mergeDataFromUserSpecificRecord:(id)record accountID:(id)id;
- (id)mergeDecryptedValue:(id)value withOldValue:(id)value forKey:(id)key;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (unsigned long long)mergeReplicaIDToNotesVersion:(id)version;
- (_Bool)mergeUnappliedEncryptedRecord;
- (_Bool)mergeUnappliedEncryptedRecordRecursively;
- (void)mergeUnappliedEncryptedRecordRecursivelyInBackground;
- (void)moveBackToTrashAfterQuotaExceededErrorOnRecovery;
- (_Bool)needsToDeleteShare;
- (_Bool)needsToFetchAfterServerRecordChanged:(id)changed;
- (id)newlyCreatedRecord;
- (id)notesVersionForReplicaID:(id)id;
- (unsigned long long)numberOfAssetsInTemporaryRecord:(id)record;
- (void)objc_removeAllCloudSyncingObjectActivityEvents;
- (id)objc_timestampForChecklistItemWithIdentifier:(id)identifier;
- (id)objc_userIDForChecklistItemWithIdentifier:(id)identifier;
- (_Bool)objectFailedToBePushedToCloudWithOperation:(id)operation recordID:(id)id error:(id)error;
- (void)objectWasDeletedFromCloud;
- (void)objectWasDeletedFromCloudByAnotherDevice;
- (void)objectWasFetchedButDoesNotExistInCloud;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)objectWasPushedToCloudWithOperation:(id)operation serverRecord:(id)record;
- (void)objectWillBePushedToCloudWithOperation:(id)operation;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)outOfDateAssetSignaturesForUserSpecific:(_Bool)specific;
- (id)outOfDateCommonAssetSignatures;
- (id)outOfDateUserSpecificAssetSignatures;
- (id)parentCloudObject;
- (id)parentCloudObjectForMinimumSupportedVersionPropagation;
- (id)parentCloudObjectModificationDate;
- (id)parentEncryptableObject;
- (id)participantForHandle:(id)handle;
- (id)participantForUserID:(id)id;
- (id)persistAddParticipantActivityEventForObject:(id)object participant:(id)participant;
- (id)persistCopyActivityEventForObject:(id)object originalObject:(id)object fromParentObject:(id)object toParentObject:(id)object;
- (id)persistCreateActivityEventForObject:(id)object inParentObject:(id)object;
- (id)persistDeleteActivityEventForObject:(id)object fromParentObject:(id)object;
- (id)persistMentionActivityEventForObject:(id)object mentionAttachments:(id)attachments;
- (id)persistMoveActivityEventForObject:(id)object fromParentObject:(id)object toParentObject:(id)object;
- (void)persistPendingChanges;
- (void)persistPendingChangesRecursively;
- (id)persistRemoveParticipantActivityEventForObject:(id)object participant:(id)participant;
- (id)persistRenameActivityEventForObject:(id)object;
- (id)persistToggleChecklistItemActivityEventForObject:(id)object todo:(id)todo;
- (id)primitiveValueForEncryptableKey:(id)key;
- (void)redactAuthorAttributionsToCurrentUser;
- (void)removeAllCloudSyncingObjectActivityEvents;
- (void)requireMinimumSupportedVersionAndPropagateToChildObjects:(long long)objects;
- (void)resetFailureCounts;
- (void)resetToIntrinsicNotesVersionAndPropagateToChildObjects;
- (id)serializedValuesToEncrypt;
- (void)setDecryptedValue:(id)value forKey:(id)key;
- (void)setNotesVersion:(id)version forReplicaID:(id)id;
- (void)setPrimitiveValue:(id)value forEncryptableKey:(id)key;
- (void)setServerShareIfNewer:(id)newer;
- (void)setValue:(id)value forEncryptableKey:(id)key;
- (void)setVersion:(long long)version forOperation:(id)operation;
- (void)setWasRecentlyDeletedByThisDevice:(_Bool)device;
- (id)shareDescriptionForShareParticipants:(id)participants;
- (_Bool)shareMatchesRecord;
- (id)shareTitle;
- (id)sharedOwnerRecordName;
- (id)sharedRootObject;
- (id)shortLoggingDescription;
- (_Bool)shouldBeDeletedFromLocalDatabase;
- (_Bool)supportsEncryptedValuesDictionary;
- (id)timestampForChecklistItemWithIdentifier:(id)identifier;
- (_Bool)trustsTimestampsFromReplicaID:(id)id;
- (void)unitTest_injectCryptoStrategy:(id)strategy;
- (void)unitTest_setMinimumSupportedNotesVersion:(long long)version;
- (void)unmarkForDeletion;
- (void)unsafelyClearChangeCountWithReason:(id)reason;
- (void)unsafelyUpdateChangeCountWithReason:(id)reason;
- (void)updateChangeCountWithReason:(id)reason;
- (void)updateChangeCountsForUnsavedParentReferences;
- (_Bool)updateDeviceReplicaIDsToCurrentNotesVersionIfNeeded;
- (id)updateFetchFlagsAndReturnRecordIDsNeedingFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;
- (void)updateNeedsToSaveUserSpecificRecordToUpdateReferenceActionsIfNeeded;
- (void)updateParentReferenceIfNecessary;
- (void)updateUserSpecificChangeCountWithReason:(id)reason;
- (id)userIDForChecklistItemWithIdentifier:(id)identifier;
- (id)validatedCreateCryptoStrategy;
- (id)valueForEncryptableKey:(id)key;
- (long long)versionForOperation:(id)operation;
- (_Bool)wasCreatedByCurrentUser;
- (_Bool)wasRecentlyDeletedByThisDevice;
- (void)willUpdateDeviceReplicaIDsToNotesVersion:(long long)version;

@end


@interface ICNoteContainer : ICCloudSyncingObject <ICNoteContainer>

@property (retain, nonatomic) ICAccount *owner;
@property (retain, nonatomic) NSString *accountNameForAccountListSorting;
@property (retain, nonatomic) NSString *nestedTitleForSorting;
@property (retain, nonatomic) ICTTOrderedSetVersionedDocument *subFolderIdentifiersOrderedSetDocument;
@property (readonly, copy, nonatomic) NSString *cacheKey;
@property (nonatomic) int sortOrder;
@property (readonly, nonatomic) ICCROrderedSet *subFolderIdentifiersOrderedSet;
@property (nonatomic) _Bool subFolderOrderMergeableDataDirty;
@property (nonatomic) long long dateHeadersType;
@property (readonly, nonatomic) ICAccount *noteContainerAccount;
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) ICFolderCustomNoteSortType *customNoteSortType;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) _Bool isAllNotesContainer;
@property (readonly, nonatomic) _Bool canBeSharedViaICloud;
@property (readonly, nonatomic) _Bool supportsEditingNotes;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) _Bool isModernCustomFolder;
@property (readonly, nonatomic) NSString *containerIdentifier;
@property (readonly, nonatomic) NSArray *visibleNotes;
@property (readonly, nonatomic) _Bool supportsDateHeaders;
@property (readonly, nonatomic) _Bool isShowingDateHeaders;
@property (readonly, nonatomic) unsigned long long visibleNotesCount;
@property (readonly, nonatomic) _Bool hasVisibleNotes;
@property (readonly, copy, nonatomic) NSString *titleForNavigationBar;
@property (readonly, copy, nonatomic) NSString *titleForTableViewCell;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, nonatomic) NSArray *visibleSubFolders;
@property (copy, nonatomic) NSData *subFolderOrderMergeableData;
@property (readonly, nonatomic) _Bool deleted;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)keyPathsForValuesAffectingCloudAccount;

/* instance methods */
- (void)willSave;
- (id)predicateForVisibleNotes;
- (id)predicateForSearchableAttachments;
- (void)willTurnIntoFault;
- (void)saveSubFolderMergeableDataIfNeeded;
- (id)noteVisibilityTestingForSearchingAccount;
- (id)cloudAccount;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (id)predicateForPinnedNotes;
- (_Bool)noteIsVisible:(id)visible;
- (void)applyDateHeadersType:(long long)type;
- (void)updateSubFolderMergeableDataChangeCount;
- (_Bool)mergeWithSubFolderMergeableData:(id)data;
- (id)predicateForSearchableNotes;
- (void)willRefresh:(_Bool)refresh;
- (_Bool)isSubFolderOrderMergeableDataDirty;
- (void)writeSubFolderMergeableData;

@end


@interface ICAccount : ICNoteContainer <ICSearchIndexable, ICCloudObject, ICAccountObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (retain, nonatomic) NSPersonNameComponents *fullName;
@property (retain, nonatomic) NSString *primaryEmail;
@property (retain, nonatomic) ICFolder *defaultFolder;
@property (retain, nonatomic) ICFolder *trashFolder;
@property (retain, nonatomic) ICFolder *recoveredItemsFolder;
@property (retain, nonatomic) NSDictionary *replicaIDToBundleIdentifier;
@property (retain, nonatomic) ICAccountProxy *accountProxy;
@property (nonatomic) _Bool didAddObservers;
@property (retain, nonatomic) NSSet *ownerInverse;
@property (readonly, nonatomic) ICAccountCryptoStrategyProxy *cryptoStrategy;
@property (retain, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *localizedName;
@property (readonly, nonatomic) NSPersistentStore *persistentStore;
@property (retain, nonatomic) NSSet *folders;
@property (retain, nonatomic) NSSet *notes;
@property (retain, nonatomic) NSSet *serverChangeTokens;
@property (retain, nonatomic) NSSet *deviceMigrationStates;
@property (retain, nonatomic) NSSet *legacyTombstones;
@property (retain, nonatomic) NSSet *hashtags;
@property (retain, nonatomic) NSSet *invitations;
@property (retain, nonatomic) NSSet *attachments;
@property (retain, nonatomic) NSSet *inlineAttachments;
@property (retain, nonatomic) NSSet *media;
@property (nonatomic) int accountType;
@property (nonatomic) _Bool didChooseToMigrate;
@property (nonatomic) _Bool didFinishMigration;
@property (nonatomic) _Bool didMigrateOnMac;
@property (nonatomic) _Bool storeDataSeparately;
@property (copy, nonatomic) NSDate *lastSyncDate;
@property (retain, nonatomic) NSData *cryptoVerifier;
@property (retain, nonatomic) ICAccountData *accountData;
@property (readonly, nonatomic) _Bool isManaged;
@property (readonly, nonatomic) _Bool isDataSeparated;
@property (readonly, nonatomic) _Bool isLocalAccount;
@property (copy, nonatomic) NSString *serverSideUpdateTaskLastAttemptedBuild;
@property (copy, nonatomic) NSString *serverSideUpdateTaskLastAttemptedVersion;
@property (nonatomic) unsigned short serverSideUpdateTaskFailureCount;
@property (copy, nonatomic) NSData *serverSideUpdateTaskContinuationToken;
@property (copy, nonatomic) NSString *serverSideUpdateTaskLastCompletedBuild;
@property (copy, nonatomic) NSString *serverSideUpdateTaskLastCompletedVersion;
@property (readonly, nonatomic) NSString *dsid;
@property (readonly, nonatomic) NSString *altDSID;
@property (readonly, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *userRecordName;
@property (readonly, nonatomic) NSString *emailAddress;

/* class methods */
+ (void)initialize;
+ (id)accountUtilities;
+ (void)setAccountUtilities:(id)utilities;
+ (void)enumerateAllCloudObjectsInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (_Bool)isCloudKitAccountAvailable;
+ (void)localeDidChange:(id)change;
+ (void)deleteAccount:(id)account;
+ (id)allAccountIdentifiersInContext:(id)context;
+ (id)accountWithIdentifier:(id)identifier context:(id)context;
+ (id)accountsMatchingPredicate:(id)predicate context:(id)context;
+ (id)accountsWithAccountType:(int)type context:(id)context;
+ (id)activeAccountWithUserRecordName:(id)name context:(id)context;
+ (id)allAccountsInContext:(id)context;
+ (id)allActiveAccountsInContext:(id)context;
+ (id)allActiveAccountsInContext:(id)context sortDescriptors:(id)descriptors relationshipKeyPathsForPrefetching:(id)prefetching;
+ (id)allActiveAccountsInContextSortedByAccountType:(id)type;
+ (id)allActiveAccountsInContextWithDefaultBeingFirstIfApplicable:(id)applicable;
+ (id)allActiveCloudKitAccountsInContext:(id)context;
+ (id)allCloudKitAccountsInContext:(id)context;
+ (id)allCloudObjectIDsInContext:(id)context passingTest:(id /* block */)test;
+ (_Bool)clearAccountForAppleCloudKitTable;
+ (id)cloudKitAccountInContext:(id)context;
+ (id)cloudKitAccountWithIdentifier:(id)identifier context:(id)context;
+ (id)cloudKitIfMigratedElseLocalAccountInContext:(id)context;
+ (id)defaultAccountInContext:(id)context;
+ (void)deleteAccountWithBatchDelete:(id)_delete;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (_Bool)hasActiveCloudKitAccountInContext:(id)context;
+ (_Bool)hasModernAccountInContext:(id)context;
+ (_Bool)hidesCallNotesInCustomFolders;
+ (_Bool)hidesMathNotesInCustomFolders;
+ (_Bool)hidesSystemPaperNotesInCustomFolders;
+ (id)inMemoryAccountInContext:(id)context;
+ (void)initializeLocalAccountNamesInBackground;
+ (_Bool)isCloudKitAccountAvailableInContext:(id)context;
+ (id)keyPathsForValuesAffectingCanBeSharedViaICloud;
+ (id)keyPathsForValuesAffectingLocalizedName;
+ (id)keyPathsForValuesAffectingVisibleNoteContainerChildren;
+ (id)localAccountInContext:(id)context;
+ (id)localizedLocalAccountName;
+ (id)localizedLocalAccountNameMidSentence;
+ (id)mostRecentSystemPaperNoteInManagedObjectContext:(id)context;
+ (id)newAccountWithIdentifier:(id)identifier type:(int)type context:(id)context;
+ (id)newAccountWithIdentifier:(id)identifier type:(int)type context:(id)context persistentStore:(id)store;
+ (id)newLocalAccountInContext:(id)context;
+ (unsigned long long)numberOfCloudKitAccountsInContext:(id)context onlyMigrated:(_Bool)migrated;
+ (id)passwordProtectedNoteIdentifiersInAccountIdentifier:(id)identifier context:(id)context;
+ (void)setHidesCallNotesInCustomFolders:(_Bool)folders;
+ (void)setHidesMathNotesInCustomFolders:(_Bool)folders;
+ (void)setHidesSystemPaperNotesInCustomFolders:(_Bool)folders;
+ (id)standardFolderIdentifierWithPrefix:(id)prefix accountIdentifier:(id)identifier accountType:(int)type;

/* instance methods */
- (id)containerIdentifier;
- (_Bool)supportsDateHeaders;
- (id)predicateForVisibleNotes;
- (id)predicateForSearchableAttachments;
- (_Bool)isShowingDateHeaders;
- (void)willTurnIntoFault;
- (id)visibleSubFolders;
- (id)visibleNotes;
- (_Bool)isAllNotesContainer;
- (void)setSubFolderOrderMergeableData:(id)data;
- (long long)compare:(id)compare;
- (id)temporaryDirectoryURL;
- (id)noteVisibilityTestingForSearchingAccount;
- (id)cacheKey;
- (id)customNoteSortTypeValue;
- (id)titleForTableViewCell;
- (id)predicateForPinnedNotes;
- (void)dealloc;
- (id)titleForNavigationBar;
- (void)awakeFromInsert;
- (id)accountName;
- (void)prepareForDeletion;
- (id)subFolderOrderMergeableData;
- (unsigned long long)visibleNotesCount;
- (_Bool)supportsEditingNotes;
- (id)recordName;
- (void)updateSubFolderMergeableDataChangeCount;
- (void)awakeFromFetch;
- (id)recordZoneName;
- (id)predicateForSearchableNotes;
- (_Bool)canBeSharedViaICloud;
- (_Bool)isLeaf;
- (void)setMarkedForDeletion:(_Bool)deletion;
- (_Bool)isPrimaryiCloudAccount;
- (_Bool)allowsImporting;
- (unsigned long long)visibleNotesIncludingTrashCount;
- (id)allChildObjects;
- (_Bool)allowsExporting;
- (_Bool)hasVisibleNotes;
- (id)accountDataCreateIfNecessary;
- (id)accountFilesDirectoryURL;
- (id)accountFilesDirectoryURLInApplicationDataContainer;
- (id)allItemsFolderLocalizedTitle;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (_Bool)canHaveCryptoStrategy;
- (_Bool)canPasswordProtectNotes;
- (_Bool)containsSharedFolders;
- (void)createDefaultFolder;
- (void)createRecoveredItemsFolder;
- (void)createStandardFolders;
- (void)createTrashFolder;
- (_Bool)cryptoStrategyIsTransient;
- (id)cryptoStrategyProtocol;
- (id)customRootLevelFolders;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)defaultFolderIdentifier;
- (void)deleteUnusedHashtagsWithStandardizedContent:(id)content;
- (void)ensureCriticalPaperDirectoriesExist;
- (id)exportableMediaDirectoryURL;
- (id)fallbackImageDirectoryURL;
- (id)fallbackPDFDirectoryURL;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (id)folderWithIdentifier:(id)identifier;
- (_Bool)hasAnyCustomFoldersIncludingSystem:(_Bool)system;
- (_Bool)hasLocalUnsyncedData;
- (id)ic_accessibilityIdentifier;
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;
- (unsigned long long)indexOfCustomRootLevelFolder:(id)folder;
- (id)localizedNameMidSentence;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)mediaDirectoryURL;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (id)passwordProtectedNotes;
- (void)performBlockInPersonaContext:(id /* block */)context;
- (void)performBlockInPersonaContextIfNecessary:(id /* block */)necessary;
- (id)predicateForAttachmentsInAccount;
- (id)predicateForCustomFolders;
- (id)predicateForFolders;
- (id)predicateForNotesInAccount;
- (id)predicateForVisibleAttachments;
- (id)predicateForVisibleAttachmentsIncludingTrash;
- (id)predicateForVisibleFolders;
- (id)predicateForVisibleNotesIncludingTrash;
- (id)previewImageDirectoryURL;
- (id)recoveredItemsFolderIdentifier;
- (id)replicaIDForBundleIdentifier:(id)identifier;
- (id)reservedAccountFolderTitles;
- (short)resolvedLockedNotesMode;
- (id)searchableTextContent;
- (void)setResolvedLockedNotesMode:(short)mode;
- (_Bool)shouldBeDeletedFromLocalDatabase;
- (_Bool)shouldExcludeFilesFromCloudBackup;
- (id)standardFolderIdentifierWithPrefix:(id)prefix;
- (id)subFolderIdentifiersOrderedSet;
- (_Bool)supportsLegacyTombstones;
- (id)systemPaperBundlesDirectoryURL;
- (id)systemPaperDirectoryURL;
- (id)systemPaperNotes;
- (id)systemPaperTemporaryDirectoryURL;
- (id)trashFolderIdentifier;
- (id)uniqueUserParticipants;
- (void)updateAccountNameForAccountListSorting;
- (void)updateFullNameAndEmail:(id /* block */)email;
- (unsigned long long)visibleAttachmentsIncludingTrashCount;
- (unsigned long long)visibleCustomFoldersCount;
- (id)visibleFolders;
- (id)visibleFoldersWithParent:(id)parent;
- (unsigned long long)visibleInCloudNotesIncludingTrashCount;
- (id)visibleNoteContainerChildren;
- (id)visibleNoteContainers;
- (id)visibleRootFolderWithTitle:(id)title;
- (_Bool)visibleRootFoldersContainFolderWithTitle:(id)title;

@end


@interface ICCryptoStrategyBase : NSObject <ICCloudSyncingObjectCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)encryptData:(id)data;
- (id)decryptData:(id)data;
- (void)performBlockIfAttachmentExists:(id /* block */)exists;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (id)decryptSidecarData:(id)data;
- (id)decryptedDataFromFileURL:(id)url;
- (id)decryptedSidecarDataFromFileURL:(id)url;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (id)encryptSidecarData:(id)data;
- (_Bool)encryptSidecarFileFromURL:(id)url toURL:(id)url;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (_Bool)hasSameKeyAsObject:(id)object;
- (id)initWithCloudSyncingObject:(id)object;
- (void)initializeCryptoPropertiesFromObject:(id)object;
- (void)invalidateStrategy;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isRecordAuthenticated:(id)authenticated;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)performBlockIfAccountExists:(id /* block */)exists;
- (void)performBlockIfMediaExists:(id /* block */)exists;
- (void)performBlockIfNoteExists:(id /* block */)exists;
- (void)performBlockIfObjectExists:(id /* block */)exists;
- (void)performBlockIfPreviewImageExists:(id /* block */)exists;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (_Bool)rewrapDataAtURL:(id)url withMainKey:(id)key;
- (_Bool)rewrapFile:(id /* block */)file withMainKey:(id)key generationManager:(id)manager;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;
- (_Bool)serialize:(id)serialize toURL:(id)url;

@end


@interface ICAccountCryptoStrategyProxy : ICCryptoStrategyBase <ICAccountCryptoStrategy>

@property (readonly, nonatomic) ICAccountCryptoStrategyV1 *v1Strategy;
@property (readonly, nonatomic) ICAccountCryptoStrategyV1Neo *v1NeoStrategy;
@property (readonly, nonatomic) ICAccountCryptoStrategyV2 *v2Strategy;
@property (readonly, nonatomic) id <ICAccountCryptoStrategy> customPasswordStrategy;
@property (readonly, nonatomic) id <ICAccountCryptoStrategy> devicePasswordStrategy;
@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)currentStrategy;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (id)decryptSidecarData:(id)data;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (id)encryptSidecarData:(id)data;
- (_Bool)encryptSidecarFileFromURL:(id)url toURL:(id)url;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (_Bool)hasSameKeyAsObject:(id)object;
- (id)initWithCloudSyncingObject:(id)object;
- (void)initializeCryptoPropertiesFromObject:(id)object;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (void)removePassphrase;
- (_Bool)rewrapDataAtURL:(id)url withMainKey:(id)key;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;

@end


@interface ICCloudSyncingObjectCryptoStrategyV1 : ICCryptoStrategyBase <ICCloudSyncingObjectCryptoStrategy>

@property (readonly) NSData *fileURLEncryptionCryptoTag;
@property (readonly) NSData *fileURLEncryptionCryptoInitialzationVector;
@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)decryptWithMainKeyOfObject:(id)object encryptedData:(id)data fallbackAttemptSuccessCleanupHandler:(id /* block */)handler;
+ (id)decryptWithMainKeyOfObject:(id)object encryptedDataPreparationBlock:(id /* block */)block fallbackAttemptSuccessCleanupHandler:(id /* block */)handler;
+ (void)encryptWithMainKeyOfObject:(id)object dataPreparationBlock:(id /* block */)block failureHandler:(id /* block */)handler successHandler:(id /* block */)handler;
+ (void)encryptWithMainKeyOfObject:(id)object dataToEncrypt:(id)encrypt failureHandler:(id /* block */)handler successHandler:(id /* block */)handler;

/* instance methods */
- (id)encryptData:(id)data;
- (id)decryptData:(id)data;
- (id)unwrappedKey;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (_Bool)canMainKey:(id)key decryptObject:(id)object;
- (void)decryptAndMergeEncryptedJSON:(id)json;
- (id)decryptSidecarData:(id)data;
- (id)decryptedDataFromFileURL:(id)url;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url setTagAndIVHandler:(id /* block */)ivhandler;
- (id)encryptSidecarData:(id)data;
- (_Bool)encryptSidecarFileFromURL:(id)url toURL:(id)url;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (id)encryptionObjectWithData:(id)data;
- (_Bool)hasSameKeyAsObject:(id)object;
- (void)initializeCryptoPropertiesFromObject:(id)object;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isRecordAuthenticated:(id)authenticated;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (void)rewrapAndDivergeKeyUsingPassphrase:(id)passphrase;
- (_Bool)rewrapDataAtURL:(id)url withMainKey:(id)key;
- (void)rewrapKeyWithNewMainKey:(id)key salt:(id)salt iterationCount:(unsigned long long)count hint:(id)hint;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;

@end


@interface ICAccountCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICAccountCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)removePassphrase;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;

@end


@interface ICCloudSyncingObjectCryptoStrategyV1Neo : ICCryptoStrategyBase <ICCloudSyncingObjectCryptoStrategy>

@property (readonly, copy, nonatomic) ICEncryptionKey *sidecarMainKey;
@property (readonly, copy, nonatomic) ICEncryptionKey *fallbackSidecarMainKey;
@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)encryptData:(id)data;
- (id)decryptData:(id)data;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (id)decryptObject:(id)object encryptionKey:(id)key mainKey:(id)key;
- (id)decryptSidecarData:(id)data;
- (id)encryptData:(id)data encryptionKey:(id)key mainKey:(id)key;
- (id)encryptSidecarData:(id)data;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (_Bool)hasSameKeyAsObject:(id)object;
- (void)initializeCryptoPropertiesFromObject:(id)object;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isRecordAuthenticated:(id)authenticated;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;
- (id)sidecarMainKeyCreateIfNeeded;

@end


@interface ICAccountCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICAccountCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)removePassphrase;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;

@end


@interface ICCloudSyncingObjectCryptoStrategyV2 : ICCryptoStrategyBase <ICCloudSyncingObjectCryptoStrategy>

@property (readonly, nonatomic) NSString *accountDsid;
@property (readonly, nonatomic) NSString *accountKeyIdentifier;
@property (readonly, nonatomic) NSString *currentAccountKeyIdentifier;
@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)accountKeyByIdentifier;

/* instance methods */
- (id)accountIdentifier;
- (id)encryptData:(id)data;
- (id)decryptData:(id)data;
- (void)serializeToEncryptedValuesJSON:(id)json;
- (id)accountKeyWithIdentifier:(id)identifier createIfNotExist:(_Bool)exist;
- (_Bool)authenticateWithPassphrase:(id)passphrase;
- (_Bool)canAuthenticateRecord:(id)record;
- (void)decryptAndMergeEncryptedJSON:(id)json;
- (id)decryptObject:(id)object;
- (id)decryptSidecarData:(id)data;
- (id)decryptedDataFromFileURL:(id)url;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (id)encryptSidecarData:(id)data;
- (_Bool)encryptSidecarFileFromURL:(id)url toURL:(id)url;
- (id)encryptedData:(id)data rewrappedWithMainKey:(id)key;
- (id)encryptedDataFromRecord:(id)record;
- (void)fetchKeychainItemsForAccountKeyIdentifier:(id)identifier accountDsid:(id)dsid;
- (_Bool)hasSameKeyAsObject:(id)object;
- (_Bool)isInICloudAccount;
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)isRecordAuthenticated:(id)authenticated;
- (_Bool)loadDecryptedValuesIfNecessary;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (id)mainKeyForPassphrase:(id)passphrase;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)recordHasChangedPassphrase:(id)passphrase;
- (_Bool)rewrapDataAtURL:(id)url withMainKey:(id)key;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)saveEncryptedJSON;
- (_Bool)serialize:(id)serialize toURL:(id)url;
- (_Bool)shouldSpoofAccountKey;

@end


@interface ICAccountCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICAccountCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isPassphraseCorrect:(id)correct;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)removePassphrase;
- (_Bool)setPassphrase:(id)passphrase hint:(id)hint;

@end


@interface ICAccountData : ICCloudSyncingObject <ICCloudObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) NSData *mergeableData;
@property (nonatomic) short lockedNotesMode;
@property (nonatomic) _Bool supportsV1Neo;
@property (copy, nonatomic) NSData *cryptoPassphraseVerifier;
@property (readonly, copy, nonatomic) ICTTMergeableWallClockValue *mergeableCryptoPassphraseVerifier;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)accountDataWithIdentifier:(id)identifier context:(id)context;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)newAccountDataForAccount:(id)account;
+ (id)newAccountDataWithIdentifier:(id)identifier account:(id)account;

/* instance methods */
- (id)cloudAccount;
- (id)recordName;
- (id)recordZoneName;
- (_Bool)isDeletable;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeWithMergeableData:(id)data;
- (void)saveMergeableDataIfNeeded;
- (void)updateChangeCountWithReason:(id)reason;
- (void)updateSupportsV1Neo:(id /* block */)neo;
- (void)updateSupportsV1NeoWithAccountDevices:(id)devices;

@end


@interface ICAccountProxy : NSObject <ICNoteContainer>

@property (retain) ICAccount *account;
@property (readonly, nonatomic) ICAccount *noteContainerAccount;
@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) ICFolderCustomNoteSortType *customNoteSortType;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) _Bool isAllNotesContainer;
@property (readonly, nonatomic) _Bool canBeSharedViaICloud;
@property (readonly, nonatomic) _Bool supportsEditingNotes;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) _Bool isModernCustomFolder;
@property (readonly, nonatomic) NSString *containerIdentifier;
@property (readonly, nonatomic) NSArray *visibleNotes;
@property (readonly, nonatomic) _Bool supportsDateHeaders;
@property (readonly, nonatomic) long long dateHeadersType;
@property (readonly, nonatomic) _Bool isShowingDateHeaders;
@property (readonly, nonatomic) unsigned long long visibleNotesCount;
@property (readonly, nonatomic) _Bool hasVisibleNotes;
@property (readonly, copy, nonatomic) NSString *titleForNavigationBar;
@property (readonly, copy, nonatomic) NSString *titleForTableViewCell;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, nonatomic) NSArray *visibleSubFolders;
@property (copy, nonatomic) NSData *subFolderOrderMergeableData;
@property (readonly, nonatomic) _Bool deleted;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)accountProxyWithAccount:(id)account;
+ (id)keyPathsForValuesAffectingVisibleNotesCount;

/* instance methods */
- (id)predicateForVisibleNotes;
- (id)predicateForSearchableAttachments;
- (id)initWithAccount:(id)account;
- (id)objectID;
- (void)saveSubFolderMergeableDataIfNeeded;
- (_Bool)isDeleted;
- (long long)compare:(id)compare;
- (id)noteVisibilityTestingForSearchingAccount;
- (id)customNoteSortTypeValue;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (id)predicateForPinnedNotes;
- (_Bool)noteIsVisible:(id)visible;
- (void)applyDateHeadersType:(long long)type;
- (void)updateSubFolderMergeableDataChangeCount;
- (_Bool)mergeWithSubFolderMergeableData:(id)data;
- (id)predicateForSearchableNotes;
- (_Bool)isLeaf;
- (id)ic_accessibilityIdentifier;
- (id)visibleNoteContainerChildren;

@end


@interface ICActivityStreamDigest : NSObject

@property (nonatomic, readonly) ICTTTextEditFilter *objc_recentUpdatesFilter;
@property (nonatomic, readonly) _Bool objc_hasUnseenHighlights;
@property (nonatomic, readonly) _Bool objc_hasUnseenSummary;
@property (nonatomic, readonly) _Bool objc_hasRecentUpdates;
@property (nonatomic, readonly) NSValue *objc_recentUpdatesRangeValue;
@property (nonatomic, readonly) _Bool objc_isCurrentUserMentionedInRecentSummary;
@property (readonly, nonatomic) id <ICActivityEventResolving> resolverStorage;
@property (copy, nonatomic) NSDate *lastActivitySummaryViewedDate;
@property (copy, nonatomic) NSDate *recentUpdatesGenerationDate;
@property (retain, nonatomic) id recentActivityEventsStorage;
@property (readonly, nonatomic) ICTTTextEditFilter *recentUpdatesFilter;
@property (readonly, nonatomic) _Bool hasUnseenHighlights;
@property (readonly, nonatomic) _Bool hasUnseenSummary;
@property (readonly, nonatomic) _Bool hasRecentUpdates;
@property (readonly, nonatomic) NSValue *recentUpdatesRangeValue;
@property (readonly, nonatomic) _Bool isCurrentUserMentionedInRecentSummary;

/* instance methods */
- (id)initWithResolver:(id)resolver;
- (_Bool)isCurrentUserMentionedInFilter:(id)filter;
- (_Bool)objc_isCurrentUserMentionedInFilter:(id)filter;

@end


@interface ICAirDropDocument : NSObject <ICAirDropDocument>

@property (readonly, nonatomic) _Bool hasDocumentForNote;
@property (readonly, nonatomic) _Bool hasDocumentForLegacyNote;
@property (readonly, nonatomic) id activityItem;

/* class methods */
+ (_Bool)canAirDropImportIntoAccount:(id)account context:(id)context;
+ (id)documentAtURL:(id)url;
+ (id)legacyNoteAirDropDocumentWithData:(id)data;

/* instance methods */
- (void *)document;
- (id)initWithData:(id)data;
- (id)dataFromLegacyNoteDocument;

@end


@interface ICAppContext : NSObject

@property (nonatomic) unsigned long long contextOptions;
@property (copy, nonatomic) id /* block */ backgroundContextCreator;
@property (readonly, nonatomic) ICCloudContext *cloudContext;
@property (readonly, nonatomic) NSManagedObjectContext *viewContext;
@property (readonly, nonatomic) ICDeviceManagementRestrictionsManager *deviceManagementRestrictionsManager;

/* instance methods */
- (_Bool)hasContextOptions:(unsigned long long)options;
- (id)initWithCloudContext:(id)context contextOptions:(unsigned long long)options viewContext:(id)context backgroundContextCreator:(id /* block */)creator deviceManagementRestrictionsManager:(id)manager;
- (id)makeBackgroundContext;

@end


@interface ICAppURLRequestShareAccessDeeplinkMetadata : NSObject

@property (retain, nonatomic) NSString *shareRecordId;
@property (retain, nonatomic) NSString *ownerRecordName;
@property (nonatomic) long long action;

/* class methods */
+ (id)URLWithShareRecordName:(id)name ownerRecordName:(id)name action:(long long)action;
+ (id)metadataFromURL:(id)url;

/* instance methods */

@end


@interface ICAppURLUtilities : NSObject

/* class methods */
+ (id)folderIdentifierForShowNoteURL:(id)url;
+ (_Bool)isShowPaperURL:(id)url;
+ (id)noteIdentifierFromQuickNoteURL:(id)url;
+ (_Bool)isShowRecentlyDeletedFolderURL:(id)url;
+ (id)URLForAttributedString:(id)string range:(struct _NSRange)range;
+ (id)URLWithSchemeForString:(id)string;
+ (id)accountFromACAccountIDInURL:(id)url context:(id)context;
+ (id)appURLForContainingFolderWithNoteFocused:(id)focused;
+ (id)appURLForDefaultFolder;
+ (id)appURLForFolder:(id)folder;
+ (id)appURLForFolderList;
+ (id)appURLForHTMLFolder:(id)htmlfolder;
+ (id)appURLForHTMLNote:(id)htmlnote;
+ (id)appURLForNote:(id)note;
+ (id)appURLForNote:(id)note contentOffsetY:(id)y;
+ (id)appURLForNote:(id)note inFolder:(id)folder;
+ (id)appURLForNote:(id)note paragraphID:(id)id;
+ (id)appURLForShowPaper;
+ (id)appURLForShowSmartFoldersHelp;
+ (id)appURLForTranscriptionDonationForAttachmentIdentifier:(id)identifier isPositive:(_Bool)positive;
+ (id)attachmentForTranscriptionDonationURL:(id)url managedObjectContext:(id)context;
+ (id)attachmentIdentifierFromQuickNoteURL:(id)url;
+ (id)contentOffsetFromQuickNoteURL:(id)url;
+ (id)contentOffsetFromShowNoteURL:(id)url;
+ (id)defaultCloudFolderForACAccountInURL:(id)url context:(id)context;
+ (id)defaultCloudFolderURLForACAccountID:(id)id;
+ (id)detectedURLInString:(id)string allowNonLinkCharacters:(_Bool)characters;
+ (id)entityURIForNote:(id)note;
+ (id)firstQueryItemInURL:(id)url andHost:(id)host andQueryItemName:(id)name;
+ (_Bool)isHTMLFolderEntityURI:(id)uri;
+ (_Bool)isHTMLNoteEntityURI:(id)uri;
+ (_Bool)isLaunchingQuickNoteViaPencil:(id)pencil;
+ (_Bool)isModernFolderEntityURI:(id)uri;
+ (_Bool)isModernNoteEntityURI:(id)uri;
+ (_Bool)isNewNoteURL:(id)url;
+ (_Bool)isNoteParagraphURL:(id)url;
+ (_Bool)isQuickNoteModeURL:(id)url;
+ (_Bool)isShowDefaultCloudFolderURL:(id)url;
+ (_Bool)isShowDefaultFolderURL:(id)url;
+ (_Bool)isShowFolderListURL:(id)url;
+ (_Bool)isShowFolderURL:(id)url;
+ (_Bool)isShowFolderURL:(id)url options:(unsigned long long)options;
+ (_Bool)isShowHTMLFolderURL:(id)url;
+ (_Bool)isShowHTMLFolderURL:(id)url options:(unsigned long long)options;
+ (_Bool)isShowHTMLNoteURL:(id)url;
+ (_Bool)isShowLegacyNoteURL:(id)url;
+ (_Bool)isShowNoteFocusedInFolderURL:(id)url;
+ (_Bool)isShowNoteURL:(id)url;
+ (_Bool)isShowNoteURL:(id)url options:(unsigned long long)options;
+ (_Bool)isShowSmartFoldersHelpURL:(id)url;
+ (_Bool)isSystemPaperURL:(id)url;
+ (_Bool)isTranscriptionDonationURL:(id)url;
+ (_Bool)isTranscriptionDonationURLPositive:(id)urlpositive;
+ (id)modernNoteIdentifierFromEntityURI:(id)uri;
+ (id)noteIdentifierFromNotesAppURL:(id)url;
+ (id)objectIDForHTMLFolderEntityURI:(id)uri context:(id)context;
+ (id)objectIDForHTMLFolderMentionedInURL:(id)url context:(id)context;
+ (id)objectIDForHTMLFolderMentionedInURL:(id)url options:(unsigned long long)options context:(id)context;
+ (id)objectIDForModernFolderEntityURI:(id)uri noteContext:(id)context;
+ (id)objectIDForModernFolderMentionedInURL:(id)url noteContext:(id)context;
+ (id)objectIDForModernFolderMentionedInURL:(id)url options:(unsigned long long)options noteContext:(id)context;
+ (id)objectIDURIRepresentationForFolderMentionedInLegacyShowFolderURL:(id)url;
+ (id)objectIDURIRepresentationForFolderMentionedInLegacyShowHTMLFolderURL:(id)url;
+ (id)objectIDURIRepresentationForHTMLNoteEntityURI:(id)uri context:(id)context;
+ (id)objectIDURIRepresentationForHTMLNoteMentionedInURL:(id)url;
+ (id)paragraphIDForURL:(id)url;
+ (id)predicateForFolderWithNoteFocusedInURL:(id)url;
+ (id)predicateForNotesMentionedInURL:(id)url;
+ (id)predicateForNotesMentionedInURL:(id)url action:(id)action;
+ (id)predicateForNotesMentionedInURL:(id)url action:(id)action queryItemName:(id)name;
+ (id)predicateForNotesWithIdentifier:(id)identifier;
+ (id)predicateForVisibleNotesMentionedInURL:(id)url;
+ (_Bool)quickNoteURLIsContinuing:(id)continuing;
+ (_Bool)quickNoteURLShouldShowList:(id)list;
+ (_Bool)quickNoteURLShouldShowShareSheet:(id)sheet;
+ (_Bool)quickNoteURLShouldShowiCloudShareSheet:(id)sheet;
+ (id)recentlyDeletedFolderForACAccountInURL:(id)url context:(id)context;
+ (id)recentlyDeletedFolderURLForACAccountID:(id)id;
+ (id)referralURLForSnapshotBackgroundTask;
+ (id)requestShareAccessDeeplinkMetadataFromURL:(id)url;
+ (id)urlByAppendingACAccountIDToURL:(id)url acAccountID:(id)id;
+ (id)urlForNewNote;
+ (id)urlForQuickNoteWithOptions:(id)options;

@end


@interface ICAppearanceInfo : NSObject

@property (nonatomic) unsigned long long type;
@property (readonly, nonatomic) _Bool isDark;

/* class methods */
+ (id)appearanceInfoWithType:(unsigned long long)type;
+ (void)enumerateAppearanceTypesUsingBlock:(id /* block */)block;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (unsigned long long)hash;

@end


@interface ICAssetGeneration : NSObject <NSCopying>

@property (readonly, nonatomic) long long number;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *rawValue;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithRawValue:(id)value;
- (id)initWithNumber:(long long)number identifier:(id)identifier;
- (id)nextGeneration;

@end


@interface ICAssetGenerationManager : NSObject

@property (copy, nonatomic) ICAssetGeneration *currentGeneration;
@property (copy, nonatomic) ICAssetGeneration *nextGeneration;
@property (retain, nonatomic) ICDistributedLock *nextGenerationLock;
@property (nonatomic) _Bool advancing;
@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, copy, nonatomic) NSString *generationKeyPath;
@property (readonly, copy, nonatomic) NSURL *containerURL;
@property (copy, nonatomic) NSArray *fallbackURLs;
@property (nonatomic) double generationTimeout;
@property (readonly, copy, nonatomic) NSURL *generationURL;

/* instance methods */
- (id)description;
- (void)dealloc;
- (void)managedObjectContextObjectsDidChange:(id)change;
- (_Bool)beginGeneration;
- (_Bool)commitGeneration;
- (id)initWithObject:(id)object generationKeyPath:(id)path containerURL:(id)url;
- (_Bool)isAdvancing;
- (void)managedObjectContextDidSaveObjectIDs:(id)ids;
- (void)removeStaleGenerations;
- (_Bool)rollbackGeneration;
- (void)updateCurrentGeneration;

@end


@interface ICAssetSignature : NSManagedObject

@property (retain, nonatomic) NSString *cloudKitRecordKey;
@property (retain, nonatomic) NSString *fetchedLocalAssetSignatureHash;
@property (retain, nonatomic) NSString *lastKnownServerAssetSignatureHash;
@property (nonatomic) _Bool isUserSpecificRecordKey;
@property (retain, nonatomic) ICCloudSyncingObject *cloudSyncingObject;
@property (readonly, nonatomic) _Bool outOfDate;

/* class methods */
+ (id)allAssetSignaturesForCloudSyncingObject:(id)object context:(id)context;
+ (id)assetSignatureForCloudKitRecordKey:(id)key isUserSpecificRecordKey:(_Bool)key cloudSyncingObject:(id)object context:(id)context;
+ (id)assetSignatureHashFromAssets:(id)assets;
+ (id)assetSignaturesMatchingPredicate:(id)predicate context:(id)context;
+ (id)commonAssetSignaturesForCloudSyncingObject:(id)object context:(id)context;
+ (_Bool)hasFetchedAssets:(id)assets;
+ (_Bool)hasLocallyStoredAssetsInObject:(id)object context:(id)context;
+ (id)makeAssetSignatureIfNeededWithCloudKitRecordKey:(id)key isUserSpecificRecordKey:(_Bool)key cloudSyncingObject:(id)object account:(id)account context:(id)context;
+ (id)makeAssetSignatureWithCloudKitRecordKey:(id)key fetchedLocalAssetSignatureHash:(id)hash lastKnownServerAssetSignatureHash:(id)hash isUserSpecificRecordKey:(_Bool)key cloudSyncingObject:(id)object account:(id)account context:(id)context;
+ (void)mergeIncomingAssetsFromRecord:(id)record forObject:(id)object account:(id)account context:(id)context;
+ (_Bool)shouldWriteAssetIfNeededToKey:(id)key inRecord:(id)record forObject:(id)object context:(id)context;
+ (id)userSpecificAssetSignaturesForCloudSyncingObject:(id)object context:(id)context;

@end


@interface ICBaseAttachment : ICCloudSyncingObject

@property (copy, nonatomic) NSString *typeUTI;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) ICNote *note;
@property (retain, nonatomic) ICAttachment *parentAttachment;
@property (readonly, nonatomic) ICBaseAttachment *rootParentAttachment;
@property (readonly, nonatomic) struct _NSRange rangeInNote;
@property (readonly, nonatomic) _Bool used;

/* class methods */
+ (id)attachmentWithIdentifier:(id)identifier context:(id)context;
+ (id)attachmentWithIdentifier:(id)identifier includeDeleted:(_Bool)deleted context:(id)context;
+ (id)attachmentsMatchingPredicate:(id)predicate context:(id)context;
+ (void)deleteAttachment:(id)attachment;
+ (id)newAttachmentWithIdentifier:(id)identifier note:(id)note;
+ (id)notDeletedPredicate;
+ (id)predicateForUnsupportedAttachmentsInContext:(id)context;
+ (id)predicateForVisibleAttachmentsInContext:(id)context;
+ (id)predicateForVisibleAttachmentsIncludingTrash:(_Bool)trash inContext:(id)context;
+ (id)predicateForVisibleAttachmentsIncludingTrashInContext:(id)context;
+ (id)predicateForVisibleObjects;
+ (void)purgeAttachment:(id)attachment;
+ (void)undeleteAttachment:(id)attachment;

/* instance methods */
- (_Bool)isUsed;
- (_Bool)isVisible;
- (id)cloudAccount;
- (id)parentCloudObject;
- (id)parentCloudObjectForMinimumSupportedVersionPropagation;

@end


@interface ICAttachment : ICBaseAttachment <ICSearchIndexable, ICCloudObject, ICAttachmentObject, ICTableObject>

@property (readonly, nonatomic) _Bool willShowFallbackImage;
@property (readonly, nonatomic) _Bool hasUnfetchedFallbackImage;
@property (readonly, nonatomic) _Bool hasUnfetchedLinkPresentationMetadata;
@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) _Bool isVisibleTable;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (readonly, nonatomic) NSString *quotedText;
@property (retain, nonatomic) id <ICDocumentMergeControlling> documentMergeController;
@property (retain, nonatomic) NSURL *URL;
@property (nonatomic) _Bool settingMergeableData;
@property (retain, nonatomic) NSData *mergeablePreferredViewSize;
@property (nonatomic) long long minimumSupportedNotesVersion;
@property (nonatomic) _Bool suppressesFileDeletion;
@property (readonly, nonatomic) id <ICAttachmentCryptoStrategy> cryptoStrategy;
@property (retain, nonatomic) NSString *handwritingSummary;
@property (nonatomic) short handwritingSummaryVersion;
@property (nonatomic) double sizeHeight;
@property (nonatomic) double sizeWidth;
@property (nonatomic) double originX;
@property (nonatomic) double originY;
@property (readonly, nonatomic) _Bool hasOrientation;
@property (nonatomic) short orientation;
@property (retain, nonatomic) NSString *urlString;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *userTitle;
@property (retain, nonatomic) NSString *additionalIndexableText;
@property (retain, nonatomic) ICAttachmentLocation *location;
@property (retain, nonatomic) ICMedia *media;
@property (retain, nonatomic) NSData *mergeableData;
@property (nonatomic) _Bool needsInitialRelationshipSetup;
@property (retain, nonatomic) ICNote *noteUsingTitleForNoteTitle;
@property (retain, nonatomic) NSSet *previewImages;
@property (retain, nonatomic) NSDate *previewUpdateDate;
@property (retain, nonatomic) NSSet *subAttachments;
@property (retain, nonatomic) NSSet *inlineAttachments;
@property (readonly, nonatomic) NSSet *visibleInlineAttachments;
@property (readonly, nonatomic) _Bool hasVisibleInlineAttachments;
@property (retain, nonatomic) NSString *remoteFileURLString;
@property (retain, nonatomic) NSURL *remoteFileURL;
@property (retain, nonatomic) NSData *temporaryTranscriptData;
@property (nonatomic) short preferredViewSize;
@property (retain, nonatomic) NSDictionary *metadata;
@property (retain, nonatomic) NSData *metadataData;
@property (readonly, nonatomic) _Bool hasMetadata;
@property (nonatomic) short section;
@property (nonatomic) _Bool checkedForLocation;
@property (nonatomic) _Bool hasMarkupData;
@property (retain, nonatomic) NSData *markupModelData;
@property (nonatomic) long long fileSize;
@property (nonatomic) double duration;
@property (readonly, nonatomic) _Bool hasImageFilterType;
@property (nonatomic) short imageFilterType;
@property (nonatomic) double croppingQuadBottomLeftX;
@property (nonatomic) double croppingQuadBottomLeftY;
@property (nonatomic) double croppingQuadBottomRightX;
@property (nonatomic) double croppingQuadBottomRightY;
@property (nonatomic) double croppingQuadTopLeftX;
@property (nonatomic) double croppingQuadTopLeftY;
@property (nonatomic) double croppingQuadTopRightX;
@property (nonatomic) double croppingQuadTopRightY;
@property (readonly, nonatomic) _Bool hasCroppingQuad;
@property (readonly, nonatomic) NSString *fallbackImageGeneration;
@property (readonly, nonatomic) ICAssetGenerationManager *fallbackImageGenerationManager;
@property (retain, nonatomic) NSData *fallbackImageCryptoTag;
@property (retain, nonatomic) NSData *fallbackImageCryptoInitializationVector;
@property (readonly, nonatomic) NSString *fallbackPDFGeneration;
@property (readonly, nonatomic) ICAssetGenerationManager *fallbackPDFGenerationManager;
@property (retain, nonatomic) NSData *fallbackPDFCryptoTag;
@property (retain, nonatomic) NSData *fallbackPDFCryptoInitializationVector;
@property (retain, nonatomic) NSData *linkPresentationArchivedMetadata;
@property (nonatomic) _Bool needsTranscription;
@property (readonly, nonatomic) _Bool shouldShowInlineFormFillingBanner;
@property (nonatomic) _Bool hasPaperForm;
@property (nonatomic) _Bool didRunPaperFormDetection;
@property (retain, nonatomic) NSData *synapseData;
@property (retain, nonatomic) NSString *summary;
@property (retain, nonatomic) NSString *imageClassificationSummary;
@property (nonatomic) short imageClassificationSummaryVersion;
@property (retain, nonatomic) NSString *ocrSummary;
@property (nonatomic) short ocrSummaryVersion;
@property (retain, nonatomic) NSString *fallbackTitle;
@property (retain, nonatomic) NSString *fallbackSubtitleIOS;
@property (retain, nonatomic) NSString *fallbackSubtitleMac;
@property (readonly, nonatomic) _Bool isReadOnly;
@property (nonatomic) _Bool urlExpired;
@property (readonly, nonatomic) NSString *accessibilityDescriptionForType;
@property (copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *typeUTI;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;

/* class methods */
+ (void)initialize;
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (_Bool)isTypeUTISupportedInExtensions:(id)extensions;
+ (id)isBeingEditedLocallyOnDeviceSet;
+ (id)mergeableWallClockValueKeyPaths;
+ (_Bool)typeUTIIsImage:(id)image;
+ (void)addPreviewImages:(id)images toRecord:(id)record;
+ (id)allAttachmentsInContext:(id)context;
+ (id)attachmentIdentifiersForAccount:(id)account;
+ (id)attachmentSectionSortOrder;
+ (id)attachmentTypeUTIsToHideFromAttachmentBrowser;
+ (unsigned long long)countOfAttachmentsMatchingPredicate:(id)predicate context:(id)context;
+ (id)defaultTitleForAttachmentType:(short)type;
+ (void)deleteAttachment:(id)attachment;
+ (void)enumerateAttachmentsInContext:(id)context batchSize:(unsigned long long)size visibleOnly:(_Bool)only saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)fallbackImageContainerURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackImageEncryptedFallbackURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackImageFallbackURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackImageUTI;
+ (id)fallbackPDFContainerURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackPDFEncryptedFallbackURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackPDFFallbackURLForIdentifier:(id)identifier account:(id)account;
+ (id)fallbackPDFUTI;
+ (id)filenameExtensionForUTI:(id)uti;
+ (id)filenameFromUTI:(id)uti;
+ (_Bool)isPathExtensionSupportedForPasswordProtectedNotes:(id)notes;
+ (_Bool)isTypeUTISupportedForPasswordProtectedNotes:(id)notes;
+ (_Bool)isTypeUTISupportedForWatch:(id)watch;
+ (id)keyPathsForValuesAffectingIsSharedViaICloud;
+ (id)keyPathsForValuesAffectingParentCloudObject;
+ (id)mentionNotificationSnippetForAttachmentType:(short)type;
+ (id)mimeTypeFromUTI:(id)uti;
+ (id)newFetchRequestForAttachments;
+ (id)noteFromAttachmentRecord:(id)record accountID:(id)id context:(id)context;
+ (id)noteFromAttachmentUserSpecificRecord:(id)record accountID:(id)id context:(id)context;
+ (id)predicateForAllPaperKitBackedAttachments;
+ (id)predicateForAttachmentBrowserWithContext:(id)context;
+ (id)predicateForInlineDrawing;
+ (id)predicateForOutdatedOrMissingHandwritingSummary;
+ (id)predicateForPasswordProtected:(_Bool)_protected;
+ (id)predicateForSearchableAttachmentsInContext:(id)context;
+ (id)predicateForUnsupportedAttachmentsInContext:(id)context;
+ (id)predicateForVisibleAttachmentsWithTypeUTI:(id)uti inContext:(id)context;
+ (void)purgeAttachment:(id)attachment;
+ (void)purgeAttachmentFilesForIdentifiers:(id)identifiers account:(id)account;
+ (void)purgeHandwritingSummariesInContext:(id)context;
+ (short)sectionFromTypeUTI:(id)uti url:(id)url;
+ (void)setSuppressWritingPaperKitBundles:(_Bool)bundles;
+ (_Bool)supportsNotesVersionTracking;
+ (_Bool)supportsUserSpecificRecords;
+ (_Bool)suppressWritingPaperKitBundles;
+ (id)temporaryPaperBundleURLForIdentifier:(id)identifier account:(id)account;
+ (_Bool)typeUTIIsDrawing:(id)drawing;
+ (_Bool)typeUTIIsInlineDrawing:(id)drawing;
+ (_Bool)typeUTIIsPlayableAudio:(id)audio;
+ (_Bool)typeUTIIsPlayableMovie:(id)movie;
+ (_Bool)typeUTIIsSystemPaper:(id)paper;
+ (void)undeleteAttachment:(id)attachment;

/* instance methods */
- (void)willSave;
- (_Bool)isFolder;
- (void)willTurnIntoFault;
- (_Bool)supportsDeletionByTTL;
- (_Bool)isTable;
- (void)setNote:(id)note;
- (_Bool)isUnsupported;
- (short)attachmentType;
- (void)didTurnIntoFault;
- (void)dealloc;
- (struct CGRect)bounds;
- (_Bool)isImage;
- (void)prepareForDeletion;
- (id)tableModel;
- (struct CGSize)intrinsicContentSize;
- (void)awakeFromFetch;
- (void)setBounds:(struct CGRect)bounds;
- (id)recordZoneName;
- (_Bool)isDrawing;
- (id)previewItemTitle;
- (id)previewItemURL;
- (void)didRefresh:(_Bool)refresh;
- (void)willRefresh:(_Bool)refresh;
- (id)defaultTitle;
- (void)setMarkedForDeletion:(_Bool)deletion;
- (_Bool)isMap;
- (_Bool)hasDeepLink;
- (_Bool)isAudio;
- (_Bool)isiTunes;
- (id)fileSizeString;
- (void)undeleteAttachmentPreviewImages;
- (id)attachmentModel;
- (id)fallbackPDFData;
- (void)markForDeletion;
- (void)regenerateTitle;
- (id)_accessibilityDescriptionForGenericType;
- (void)accountWillChangeToAccount:(id)account;
- (id)addInlineAttachmentWithIdentifier:(id)identifier;
- (void)addLocationIfNeeded;
- (id)addLocationWithLatitude:(double)latitude longitude:(double)longitude;
- (id)addMediaWithData:(id)data filename:(id)filename;
- (id)addMediaWithData:(id)data filename:(id)filename updateFileBasedAttributes:(_Bool)attributes;
- (id)addMediaWithFileWrapper:(id)wrapper;
- (id)addMediaWithURL:(id)url;
- (id)addMediaWithURL:(id)url filename:(id)filename updateFileBasedAttributes:(_Bool)attributes;
- (id)addMediaWithURL:(id)url updateFileBasedAttributes:(_Bool)attributes;
- (void)addPaperBundleToRecordIfAppropriate:(id)appropriate;
- (unsigned long long)approximateArchiveSizeIncludingPreviews:(_Bool)previews;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (void)attachmentDidChange;
- (id)attachmentPreviewImageCreatingIfNecessaryWithWidth:(double)width height:(double)height scale:(double)scale appearanceType:(unsigned long long)type scaleWhenDrawing:(_Bool)drawing metadata:(id)metadata;
- (id)attachmentPreviewImageWithMinSize:(struct CGSize)size scale:(double)scale;
- (id)attachmentPreviewImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type;
- (id)attachmentPreviewImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type matchScale:(_Bool)scale matchAppearance:(_Bool)appearance;
- (id)attachmentPreviewImageWithMinSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type requireAppearance:(_Bool)appearance;
- (short)attachmentTypeFromTypeUTI;
- (short)attachmentTypeFromURL;
- (short)attachmentTypeIgnoringSupport;
- (id)audioModel;
- (_Bool)checkPreviewImagesIntegrity;
- (id)childCloudObjects;
- (id)childCloudObjectsForMinimumSupportedVersionPropagation;
- (void)clearDecryptedData;
- (id)cryptoStrategyProtocol;
- (id)dataForTypeIdentifier:(id)identifier;
- (void)deleteAttachmentPreviewImages;
- (void)deleteFromLocalDatabase;
- (id)descendantsNeedingOnDemandAssetFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;
- (void)deserializeAndMergeValues:(id)values;
- (id)drawingModel;
- (id)fallbackImageData;
- (id)fallbackImageEncryptedURL;
- (id)fallbackImageURL;
- (id)fallbackPDFEncryptedURL;
- (id)fallbackPDFURL;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (void)fixBrokenReferencesWithError:(id)error;
- (void)fixMarkedForDeletionForScannedDocuments;
- (id)galleryModel;
- (_Bool)hasAllMandatoryFields;
- (_Bool)hasAnyPNGPreviewImageFiles;
- (_Bool)hasFallbackImage;
- (_Bool)hasFallbackPDF;
- (_Bool)hasSynapseLink;
- (_Bool)hasUnfetchedAssetForRecordKey:(id)key;
- (_Bool)hasVisualFallbackMedia;
- (id)ic_loggingValues;
- (id)inlineDrawingModel;
- (unsigned long long)inlineFormFillingBannerDismissalCountForDevice;
- (unsigned long long)inlineFormFillingBannerDismissalCountForDeviceIdentifier:(id)identifier;
- (void)inlineFormFillingBannerWasDismissedByDeviceIdentifier:(id)identifier;
- (void)inlineFormFillingBannerWasDismissedByUser;
- (id)inlineFormFillingDismissalCountForAllDevices;
- (long long)intrinsicNotesVersionForScenario:(unsigned long long)scenario;
- (void)invalidateAttachmentPreviewImages;
- (_Bool)isAppStore;
- (_Bool)isBeingEditedLocallyOnDevice;
- (_Bool)isChildOfDocumentGallery;
- (_Bool)isEncryptableKeyBinaryData:(id)data;
- (_Bool)isInNoteTitleOrSnippet;
- (_Bool)isLoadingFromCloud;
- (_Bool)isNews;
- (_Bool)isPencilKitDrawing;
- (_Bool)isPodcasts;
- (_Bool)isScannedDocument;
- (_Bool)isSettingMergeableData;
- (_Bool)isURL;
- (_Bool)isUnviewableOnDevice;
- (void)loadFromArchive:(const void *)archive dataPersister:(id)persister withIdentifierMap:(id)map;
- (void)loadLinkPreviewForSynapseItem:(id)item;
- (void)loadPreviewArchive:(const void *)archive previewDataIdentifier:(id)identifier dataPersister:(id)persister;
- (_Bool)locationNeedsUpdate;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)makeUserSpecificCloudKitRecordForApproach:(long long)approach;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state newAttachment:(_Bool)attachment;
- (_Bool)mergeDataFromUserSpecificRecord:(id)record accountID:(id)id;
- (id)mergeDecryptedValue:(id)value withOldValue:(id)value forKey:(id)key;
- (void)mergeFallbackImageAndPDFFromRecord:(id)record;
- (void)mergePaperBundleFromRecord:(id)record;
- (_Bool)needsToBeRequested;
- (void)noteWillMoveToRecentlyDeletedFolder;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)paperBundleAssetsSubdirectoryURL;
- (id)paperBundleDatabaseSubdirectoryURL;
- (id)paperBundleModel;
- (id)paperBundleURL;
- (id)paperCoherenceContextURL;
- (id)parentAttachmentFromRecord:(id)record accountID:(id)id context:(id)context;
- (id)parentEncryptableObject;
- (void)persistPendingChanges;
- (_Bool)preferLocalPreviewImages;
- (_Bool)previewsSupportMultipleAppearances;
- (_Bool)processFallbackAsset:(id)asset fallbackAssetType:(long long)type;
- (void)purgeAttachmentPreviewImages;
- (void)recursivelyAddSubAttachments:(id)attachments;
- (void)regenerateTitleWithInferredTitle:(id)title;
- (void)removeTemporaryPaperBundle;
- (void)resetPreferredViewSizeIfNecessary;
- (void)saveMergeableDataIfNeeded;
- (void)savePreview:(id)preview toArchive:(void *)archive previewDataIdentifier:(id)identifier dataPersister:(id)persister;
- (_Bool)saveToArchive:(void *)archive dataPersister:(id)persister stripImageMarkupMetadata:(_Bool)metadata error:(id *)error;
- (id)searchableTextContent;
- (id)searchableTextContentWithoutTitle;
- (void)setIsBeingEditedLocallyOnDevice:(_Bool)device;
- (void)setParentAttachment:(id)attachment;
- (void)setTypeUTI:(id)uti resetToIntrinsicNotesVersion:(_Bool)version;
- (_Bool)shouldEmbedMarkupDataInMedia;
- (_Bool)shouldShowInContentInfoText;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;
- (_Bool)showsLoadingPlaceholder;
- (_Bool)supportsEncryptedValuesDictionary;
- (_Bool)supportsPhotosProcessing;
- (_Bool)supportsQuickLook;
- (_Bool)supportsRenaming;
- (_Bool)supportsSavingAttachmentToExternalFile;
- (void)suppressFileDeletion;
- (id)synapseBasedMetadata;
- (id)systemPaperModel;
- (id)temporaryPaperBundleURL;
- (void)unmarkForDeletion;
- (id)unsupportedAttachmentSubtitle;
- (id)unsupportedAttachmentTitle;
- (void)updateAfterMediaChange;
- (void)updateAttachmentMetadataWithBlock:(id /* block */)block;
- (id)updateAttachmentPreviewImageWithImageData:(id)data size:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type scaleWhenDrawing:(_Bool)drawing metadata:(id)metadata sendNotification:(_Bool)notification;
- (id)updateAttachmentPreviewImageWithImageSrc:(struct CGImageSource *)src maxDimension:(double)dimension scale:(double)scale appearanceType:(unsigned long long)type scaleWhenDrawing:(_Bool)drawing metadata:(id)metadata sendNotification:(_Bool)notification;
- (void)updateAttachmentSectionWithTypeUTI:(id)uti;
- (void)updateCombinedSummary;
- (_Bool)updateHandwritingSummary:(id)summary;
- (void)updateMarkedForDeletionStateAttachmentIsInUse:(_Bool)use;
- (void)updateParentReferenceIfNecessary;
- (void)updatePlaceInLocationIfNeededHandler:(id /* block */)handler;
- (void)updatePreviewsFromRecord:(id)record;
- (void)willUpdateDeviceReplicaIDsToNotesVersion:(long long)version;
- (_Bool)writeFallbackImageData:(id)data;
- (_Bool)writeFallbackPDFData:(id)pdfdata;

@end


@interface ICAttachmentModel : NSObject <ICAttachmentModelUI>

@property _Bool previewGenerationOperationCancelled;
@property (readonly, nonatomic) double placeholderWidth;
@property (readonly, nonatomic) double placeholderHeight;
@property (readonly, weak, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) _Bool shouldShowInContentInfoText;
@property (readonly, nonatomic) _Bool isIncludedInGenericAttachmentCount;
@property (nonatomic) _Bool mergeableDataDirty;
@property (readonly, copy, nonatomic) NSUUID *currentReplicaID;
@property (readonly, nonatomic) struct CGSize intrinsicContentSize;
@property (readonly, nonatomic) _Bool hasPreviews;
@property (readonly, nonatomic) _Bool previewsSupportMultipleAppearances;
@property (readonly, nonatomic) _Bool preferLocalPreviewImages;
@property (readonly, nonatomic) _Bool needsFullSizePreview;
@property (readonly, nonatomic) _Bool requiresPostProcessing;
@property (readonly, nonatomic) _Bool supportsOCR;
@property (readonly, nonatomic) _Bool supportsImageClassification;
@property (readonly, nonatomic) NSString *previewImageTypeUTI;
@property (readonly, nonatomic) NSString *hardLinkVersion;
@property (readonly, nonatomic) _Bool hasThumbnailImage;
@property (readonly, nonatomic) _Bool showThumbnailInNoteList;
@property (readonly, nonatomic) _Bool canMarkup;
@property (readonly, nonatomic) _Bool supportsQuickLook;
@property (readonly, nonatomic) NSURL *saveURL;
@property (readonly, nonatomic) _Bool canSaveURL;
@property (readonly, nonatomic) _Bool canSaveURLWithOtherAttachments;
@property (nonatomic) _Bool generatingPreviews;
@property (nonatomic) _Bool hasDeepLink;
@property (readonly, nonatomic) _Bool shouldUsePlaceholderBoundsIfNecessary;
@property (readonly, nonatomic) NSString *placeholderImageSystemName;
@property (readonly, nonatomic) AVAsset *asset;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)contentInfoTextForAttachmentType:(short)type withCount:(unsigned long long)count;
+ (void)deletePreviewItemHardLinkURLsWithContext:(id)context;
+ (Class)modelClassForAttachmentType:(short)type;

/* instance methods */
- (void)dealloc;
- (id)localizedFallbackTitle;
- (id)previewItemTitle;
- (id)previewItemURL;
- (id)providerDataTypes;
- (id)providerFileTypes;
- (id)initWithAttachment:(id)attachment;
- (_Bool)shouldCropImage;
- (void)addLocation;
- (void)addMergeableDataToCloudKitRecord:(id)record approach:(long long)approach mergeableFieldState:(id)state;
- (id)additionalIndexableTextContentInNote;
- (void)assetWithCompletion:(id /* block */)completion;
- (void)attachmentAwakeFromFetch;
- (void)attachmentDidRefresh:(_Bool)refresh;
- (void)attachmentIsDeallocating:(id)deallocating;
- (void)attachmentWillRefresh:(_Bool)refresh;
- (void)attachmentWillTurnIntoFault;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (id)correctedHardlinkURLFileExtensionForExtension:(id)extension;
- (id)dataForQuickLook;
- (id)dataForTypeIdentifier:(id)identifier;
- (void)deleteChildAttachments;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (id)generateHardLinkURLIfNecessaryForURL:(id)url;
- (id)generateHardLinkURLIfNecessaryForURL:(id)url withFileName:(id)name;
- (id)generateTemporaryURLWithExtension:(id)extension;
- (id)hardLinkFolderURL;
- (_Bool)hidesSubAttachmentsInAttachmentBrowser;
- (_Bool)isGeneratingPreviews;
- (_Bool)isMergeableDataDirty;
- (_Bool)isReadyToPresent;
- (id)localizedFallbackSubtitleIOS;
- (id)localizedFallbackSubtitleMac;
- (void)mergeMergeableDataFromCloudKitRecord:(id)record approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeWithMergeableData:(id)data;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (id)mergeableDataForCopying;
- (id)mergeableDataForCopying:(id *)copying;
- (void)persistPendingChanges;
- (struct CGAffineTransform)previewImageOrientationTransform;
- (_Bool)providesStandaloneTitleForNote;
- (_Bool)providesTextContentInNote;
- (void)redactAuthorAttributionsToCurrentUser;
- (void)regenerateTextContentInNote;
- (void)removeTimestampsForReplicaID:(id)id;
- (void)replaceChildInlineAttachment:(id)attachment withText:(id)text;
- (id)searchableTextContent;
- (id)searchableTextContentForLocation;
- (id)searchableTextContentInNote;
- (short)sectionForSubAttachments;
- (_Bool)shouldGeneratePreviewAfterChangeInSubAttachmentWithIdentifier:(id)identifier;
- (_Bool)shouldSyncPreviewImageToCloud:(id)cloud;
- (id)standaloneTitleForNote;
- (id)textContentInNote;
- (id)titleForSubAttachment:(id)attachment;
- (void)undeleteChildAttachments;
- (void)updateAfterLoadWithInlineAttachmentIdentifierMap:(id)map;
- (void)updateAfterLoadWithSubAttachmentIdentifierMap:(id)map;
- (void)updateAttachmentMarkedForDeletionStateAttachmentIsInUse:(_Bool)use;
- (void)updateAttachmentSize;
- (void)updateFileBasedAttributes;
- (_Bool)usesChildAttachment:(id)attachment;
- (void)willMarkAttachmentForDeletion;
- (void)writeMergeableData;

@end


@interface ICAttachmentAudioModel : ICAttachmentModel

@property (nonatomic, readonly) _Bool needsTranscription;
@property (nonatomic) _Bool recordedInNotes;
@property (readonly, copy, nonatomic) NSArray *composedAudioAssetURLs;
@property (retain, nonatomic) ICTTAudioDocument *audioDocument;

/* instance methods */
- (id)asset;
- (id)initWithAttachment:(id)attachment;
- (void)assetWithCompletion:(id /* block */)completion;
- (void)attachmentDidRefresh:(_Bool)refresh;
- (void)attachmentWillRefresh:(_Bool)refresh;
- (void)attachmentWillTurnIntoFault;
- (id)bitFlippeddUUIDWithUuid:(id)uuid;
- (id)createSubattachmentForRecordingAndReturnError:(id *)error;
- (_Bool)deleteSummaryAndReturnError:(id *)error;
- (_Bool)hidesSubAttachmentsInAttachmentBrowser;
- (_Bool)isReadyToPresent;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (_Bool)providesStandaloneTitleForNote;
- (_Bool)saveAttachmentAndReturnError:(id *)error;
- (id)searchableTextContent;
- (id)standaloneTitleForNote;
- (void)transformNewlyAddedMediaAttachment;
- (void)updateAfterLoadWithSubAttachmentIdentifierMap:(id)map;
- (void)updateFileBasedAttributes;
- (void)writeMergeableData;

@end


@interface ICAttachmentAudioModelCompositionInfo : NSObject

@property (copy, nonatomic) NSURL *url;
@property (retain, nonatomic) AVAsset *asset;
@property (retain, nonatomic) AVAssetTrack *track;

/* instance methods */
- (id)initWithURL:(id)url asset:(id)asset;

@end


@interface ICAttachmentCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedFallbackAssetDataForFallbackAssetType:(long long)type;
- (id)decryptedFallbackImageData;
- (id)decryptedFallbackPDFData;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)writeEncryptedFallbackAssetData:(id)data fallbackAssetType:(long long)type;
- (_Bool)writeEncryptedFallbackImageData:(id)data;
- (_Bool)writeEncryptedFallbackPDFData:(id)pdfdata;

@end


@interface ICAttachmentCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedFallbackImageData;
- (id)decryptedFallbackPDFData;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)writeEncryptedFallbackImageData:(id)data;
- (_Bool)writeEncryptedFallbackPDFData:(id)pdfdata;

@end


@interface ICAttachmentCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedFallbackAssetDataForFallbackAssetType:(long long)type;
- (id)decryptedFallbackImageData;
- (id)decryptedFallbackPDFData;
- (_Bool)writeEncryptedFallbackAssetData:(id)data fallbackAssetType:(long long)type;
- (_Bool)writeEncryptedFallbackImageData:(id)data;
- (_Bool)writeEncryptedFallbackPDFData:(id)pdfdata;

@end


@interface ICAttachmentDrawingModel : ICAttachmentModel

@property (nonatomic) _Bool observingAttachment;
@property (readonly, nonatomic) ICDrawing *drawing;

/* instance methods */
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)previewItemTitle;
- (id)previewItemURL;
- (id)saveURL;
- (id)initWithAttachment:(id)attachment;
- (id)drawingDocument;
- (id)previewImageURL;
- (void)attachmentIsDeallocating:(id)deallocating;
- (_Bool)canSaveURL;
- (void)drawingPreviewIsUpToDate;
- (_Bool)hasPreviews;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (_Bool)preferLocalPreviewImages;
- (struct CGAffineTransform)previewImageOrientationTransform;
- (_Bool)previewsSupportMultipleAppearances;
- (_Bool)shouldSyncPreviewImageToCloud:(id)cloud;
- (_Bool)showThumbnailInNoteList;
- (void)startObservingAttachment;
- (void)stopObservingAttachment:(id)attachment;
- (_Bool)supportsQuickLook;
- (void)writeMergeableData;

@end


@interface ICAttachmentGalleryModel : ICAttachmentModel

@property (retain, nonatomic) ICTTOrderedSetVersionedDocument *attachmentIdentifiersOrderedSetDocument;
@property (readonly, nonatomic) ICCROrderedSet *attachmentIdentifiersOrderedSet;
@property (readonly, nonatomic) unsigned long long subAttachmentCount;
@property (readonly, copy, nonatomic) NSArray *subAttachmentIdentifiers;

/* instance methods */
- (_Bool)hasThumbnailImage;
- (id)subAttachmentIdentifierAtIndex:(unsigned long long)index;
- (void)addSubAttachment:(id)attachment;
- (void)attachmentDidRefresh:(_Bool)refresh;
- (_Bool)attachmentHasMergeableData;
- (void)attachmentWillRefresh:(_Bool)refresh;
- (void)attachmentWillTurnIntoFault;
- (_Bool)canSaveURL;
- (_Bool)canSaveURLWithOtherAttachments;
- (void)enumerateSubAttachmentsWithBlock:(id /* block */)block;
- (id)firstSubAttachment;
- (_Bool)hasPreviews;
- (unsigned long long)indexOfSubAttachmentWithIdentifier:(id)identifier;
- (void)insertSubAttachment:(id)attachment atIndex:(unsigned long long)index;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (id)previewImageTypeUTI;
- (_Bool)providesStandaloneTitleForNote;
- (void)removeSubAttachment:(id)attachment;
- (id)searchableStringArray;
- (id)searchableTextContent;
- (short)sectionForSubAttachments;
- (_Bool)shouldGeneratePreviewAfterChangeInSubAttachmentWithIdentifier:(id)identifier;
- (_Bool)showThumbnailInNoteList;
- (id)singleSubAttachmentAtIndex:(unsigned long long)index;
- (id)standaloneTitleForNote;
- (id)titleForSubAttachment:(id)attachment;
- (void)undeleteSubAttachments;
- (void)updateAfterLoadWithSubAttachmentIdentifierMap:(id)map;
- (void)updateAttachmentMarkedForDeletionStateAttachmentIsInUse:(_Bool)use;
- (void)writeMergeableData;

@end


@interface ICAttachmentGenericModel : ICAttachmentModel

/* instance methods */
- (_Bool)hasPreviews;

@end


@interface ICAttachmentImageModel : ICAttachmentModel

/* instance methods */
- (id)previewItemTitle;
- (id)saveURL;
- (_Bool)hasThumbnailImage;
- (double)placeholderHeight;
- (double)placeholderWidth;
- (_Bool)shouldCropImage;
- (void)addLocation;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (_Bool)canMarkup;
- (_Bool)canSaveURL;
- (id)generateHardLinkURLIfNecessaryForURL:(id)url;
- (_Bool)hasPreviews;
- (_Bool)needsFullSizePreview;
- (id)placeholderImageSystemName;
- (struct CGAffineTransform)previewImageOrientationTransform;
- (id)previewImageTypeUTI;
- (_Bool)shouldUsePlaceholderBoundsIfNecessary;
- (_Bool)showThumbnailInNoteList;
- (struct CGSize)sizeByCroppingSize:(struct CGSize)size;
- (_Bool)supportsImageClassification;
- (_Bool)supportsOCR;
- (_Bool)supportsQuickLook;
- (void)updateAttachmentSize;
- (void)updateFileBasedAttributes;

@end


@interface ICAttachmentInlineDrawingModel : ICAttachmentModel

@property (readonly, nonatomic) PKDrawing *handwritingRecognitionDrawing;

/* instance methods */
- (id)additionalIndexableTextContentInNote;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (id)correctedHardlinkURLFileExtensionForExtension:(id)extension;
- (id)generateHardLinkURLIfNecessaryForURL:(id)url;
- (_Bool)hasPreviews;
- (_Bool)isIncludedInGenericAttachmentCount;
- (id)newDrawingFromMergeableData;
- (_Bool)preferLocalPreviewImages;
- (_Bool)previewsSupportMultipleAppearances;
- (_Bool)providesStandaloneTitleForNote;
- (id)searchableTextContentInNote;
- (_Bool)shouldShowInContentInfoText;
- (_Bool)shouldSyncPreviewImageToCloud:(id)cloud;
- (_Bool)showThumbnailInNoteList;
- (id)standaloneTitleForNote;

@end


@interface ICLocation : NSManagedObject

@property (nonatomic) _Bool updatingPlace;
@property (readonly, nonatomic) NSString *formattedAddress;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (retain, nonatomic) NSData *placemarkData;
@property (retain, nonatomic) CLPlacemark *placemark;

/* class methods */
+ (id)searchStringsForPlacemark:(id)placemark;

/* instance methods */
- (id)searchStrings;
- (void)didTurnIntoFault;
- (void)setLocationFromPlacemark:(id)placemark;
- (void)setLocationFromURL:(id)url;

@end


@interface ICAttachmentLocation : ICLocation <ICSearchIndexableTarget>

@property (readonly, nonatomic) id <ICSearchIndexable> targetSearchIndexable;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (nonatomic) _Bool placeUpdated;
@property (retain, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) NSString *formattedAddressWithoutAttachmentTitle;

/* class methods */
+ (id)newAttachmentLocationForAttachment:(id)attachment;

@end


@interface ICAttachmentMapModel : ICAttachmentModel

/* instance methods */
- (id)MKMapItem;
- (void)addLocation;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (_Bool)hasPreviews;
- (_Bool)preferLocalPreviewImages;
- (_Bool)previewsSupportMultipleAppearances;
- (_Bool)shouldSyncPreviewImageToCloud:(id)cloud;

@end


@interface ICCloudSyncingObjectMigrationPolicy : NSEntityMigrationPolicy

/* instance methods */
- (_Bool)createDestinationInstancesForSourceInstance:(id)instance entityMapping:(id)mapping manager:(id)manager error:(id *)error;

@end


@interface ICAttachmentMigrationPolicy : ICCloudSyncingObjectMigrationPolicy

/* instance methods */
- (_Bool)createDestinationInstancesForSourceInstance:(id)instance entityMapping:(id)mapping manager:(id)manager error:(id *)error;

@end


@interface ICAttachmentMovieModel : ICAttachmentModel

/* instance methods */
- (id)asset;
- (struct CGSize)intrinsicContentSize;
- (_Bool)hasThumbnailImage;
- (double)placeholderHeight;
- (double)placeholderWidth;
- (void)addLocation;
- (_Bool)hasPreviews;
- (id)placeholderImageSystemName;
- (_Bool)shouldUsePlaceholderBoundsIfNecessary;
- (_Bool)showThumbnailInNoteList;
- (void)updateAttachmentSize;
- (void)updateFileBasedAttributes;

@end


@interface ICAttachmentPDFModel : ICAttachmentModel

/* class methods */
+ (id)contentTextFromPDFAtURL:(id)url;

/* instance methods */
- (_Bool)canMarkup;
- (_Bool)hasPreviews;
- (_Bool)providesStandaloneTitleForNote;
- (id)searchableTextContent;
- (_Bool)showThumbnailInNoteList;
- (id)standaloneTitleForNote;

@end


@interface ICAttachmentPaperBundleModel : ICAttachmentModel

@property (readonly, nonatomic) ICAccount *account;
@property (readonly, nonatomic) NSURL *paperCoherenceContextURL;
@property (readonly, nonatomic) NSURL *paperBundleURL;
@property (readonly, nonatomic) NSURL *paperBundleDatabaseSubdirectoryURL;
@property (readonly, nonatomic) NSURL *paperBundleAssetsSubdirectoryURL;
@property (nonatomic) _Bool paperHasEnhancedCanvas;
@property (nonatomic) _Bool paperHasNewInks2022;
@property (nonatomic) _Bool paperHasNewInks2023;
@property (nonatomic) _Bool paperHasNewInksSpring2024;
@property (nonatomic) _Bool paperHasMath;
@property (nonatomic) _Bool paperHasNewInks2025;

/* class methods */
+ (long long)baseNotesVersion;
+ (_Bool)canDisplayPaperAtURL:(id)url;
+ (id)generateFallbackPDFDataForAttachment:(id)attachment;
+ (id)paperBundleURLForAttachmentIdentifier:(id)identifier inAccount:(id)account;

/* instance methods */
- (void)removeStrokesFromStyleInventory;
- (id)archivePaperBundleToDiskWithError:(id *)error;
- (_Bool)hasPreviews;
- (_Bool)providesStandaloneTitleForNote;
- (_Bool)restorePaperBundleFromArchiveURL:(id)url error:(id *)error;
- (_Bool)showThumbnailInNoteList;
- (id)standaloneTitleForNote;
- (void)updateMinimumSupportedVersionIfNeededWithCompletionHandler:(id /* block */)handler;

@end


@interface ICAttachmentPaperDocumentModel : ICAttachmentPaperBundleModel

@property (nonatomic) unsigned long long paperPageCount;

/* class methods */
+ (long long)baseNotesVersion;

/* instance methods */
- (id)additionalIndexableTextContentInNote;
- (_Bool)supportsQuickLook;

@end


@interface ICAttachmentPreviewImage : ICCloudSyncingObject <ICAttachmentPreviewImageUI>

@property (weak, nonatomic) ICAccount *placeholderAccount;
@property (nonatomic) unsigned long long imageID;
@property (readonly) NSObject *fileQueue;
@property (nonatomic) _Bool suppressesFileDeletion;
@property (readonly, nonatomic) id <ICAttachmentPreviewImageCryptoStrategy> cryptoStrategy;
@property (retain, nonatomic) NSData *encryptedMetadata;
@property (retain, nonatomic) NSData *cryptoMetadataInitializationVector;
@property (retain, nonatomic) NSData *cryptoMetadataTag;
@property (nonatomic) double width;
@property (nonatomic) double height;
@property (nonatomic) double scale;
@property (nonatomic) short appearanceType;
@property (nonatomic) short version;
@property (nonatomic) _Bool versionOutOfDate;
@property (retain, nonatomic) NSDate *modifiedDate;
@property (retain, nonatomic) ICAttachment *attachment;
@property (nonatomic) _Bool scaleWhenDrawing;
@property (retain, nonatomic) NSData *metadata;
@property (copy, nonatomic) NSString *generation;
@property (readonly, nonatomic) ICAssetGenerationManager *generationManager;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)fileGlobalQueue;
+ (id)allAttachmentPreviewImagesInContext:(id)context;
+ (id)attachmentPreviewImageIdentifiersForAccount:(id)account;
+ (id)attachmentPreviewImageWithIdentifier:(id)identifier inContext:(id)context;
+ (id)attachmentPreviewImagesMatchingPredicate:(id)predicate inContext:(id)context;
+ (id)concurrentFileLoadLimitSemaphore;
+ (void)deleteStrandedAttachmentPreviewImagesInContext:(id)context;
+ (void)enumerateAttachmentPreviewImagesInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)fileQueueGroup;
+ (id)identifierForContentIdentifier:(id)identifier scale:(double)scale width:(double)width height:(double)height appearanceType:(unsigned long long)type;
+ (id)newAttachmentPreviewImageWithIdentifier:(id)identifier attachment:(id)attachment;
+ (id)previewImageURLsForIdentifier:(id)identifier account:(id)account;
+ (void)purgeAllAttachmentPreviewImagesInContext:(id)context;
+ (void)purgePreviewImageFilesForIdentifiers:(id)identifiers account:(id)account;
+ (long long)updateFileWriteCounterBy:(long long)by identifier:(id)identifier;
+ (void)waitUntilAllFileWritesAreFinished;

/* instance methods */
- (struct CGSize)size;
- (void)willTurnIntoFault;
- (void)removeItemAtURL:(id)url;
- (void)invalidateCache;
- (id)cloudAccount;
- (id)urls;
- (void)prepareForDeletion;
- (void)awakeFromFetch;
- (id)initWithEntity:(id)entity insertIntoManagedObjectContext:(id)context;
- (_Bool)shouldSyncToCloud;
- (void)invalidateImage;
- (id)primaryEncryptedDataFromRecord:(id)record;
- (id)previewImageURL;
- (void)accountWillChangeToAccount:(id)account;
- (void)clearDecryptedData;
- (id)containerAccount;
- (id)containerDirectoryURL;
- (void)createOrientedPreviewIfNeeded;
- (id)cryptoStrategyProtocol;
- (id)decryptedImageData;
- (void)deleteFromLocalDatabase;
- (id)encryptedPreviewImageFallbackURL;
- (id)encryptedPreviewImageURL;
- (_Bool)hasAnyPNGPreviewImageFiles;
- (id)ic_loggingValues;
- (_Bool)imageIsValid;
- (_Bool)imageIsWriting;
- (void)invalidateOrientedImage;
- (_Bool)makeSurePreviewImageDirectoryExists:(id *)exists;
- (long long)minimumSupportedNotesVersion;
- (_Bool)needsInitialFetchFromCloud;
- (_Bool)needsToBeDeletedFromCloud;
- (_Bool)needsToBeFetchedFromCloud;
- (_Bool)needsToBePushedToCloud;
- (struct CGAffineTransform)orientedImageTransform;
- (id)orientedPreviewImageFallbackURLWithoutCreating;
- (id)orientedPreviewImageURL;
- (id)orientedPreviewImageURLWithoutCreating;
- (id)parentEncryptableObject;
- (id)previewImageDirectoryURL;
- (id)previewImageFallbackURL;
- (id)previewImagePathExtension;
- (id)primaryEncryptedData;
- (_Bool)setImageData:(id)data withSize:(struct CGSize)size scale:(double)scale appearanceType:(unsigned long long)type;
- (void)setPrimaryEncryptedData:(id)data;
- (_Bool)setScaledImageFromImageSrc:(struct CGImageSource *)src typeUTI:(struct __CFString *)uti;
- (void)suppressFileDeletion;
- (void)updateFlagToExcludeFromCloudBackup;

@end


@interface ICThumbnailDataCache : NSObject

@property (retain, nonatomic) ICCache *imageCache;

/* instance methods */
- (id)init;
- (id)thumbnailDataForKey:(id)key;
- (void)removeAllThumbnailData;
- (void)removeThumbnailDataForKey:(id)key;
- (void)setThumbnailData:(id)data forKey:(id)key;

@end


@interface ICAttachmentPreviewImageCache : ICThumbnailDataCache

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)attachmentPreviewImagesDidUpdate:(id)update;

@end


@interface ICAttachmentPreviewImageCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICAttachmentPreviewImageCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)_decryptedImageData;
- (id)decryptedImageData;
- (id)decryptedMetadata;
- (_Bool)writeEncryptedImageData:(id)data;
- (_Bool)writeEncryptedMetadata:(id)metadata;

@end


@interface ICAttachmentPreviewImageCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICAttachmentPreviewImageCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedImageData;
- (id)decryptedMetadata;
- (void)serializeEncryptedMetadata:(id)metadata;
- (_Bool)writeEncryptedImageData:(id)data;
- (_Bool)writeEncryptedMetadata:(id)metadata;

@end


@interface ICAttachmentPreviewImageCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICAttachmentPreviewImageCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)_decryptedImageData;
- (id)decryptedImageData;
- (id)decryptedMetadata;
- (_Bool)serializeToEncryptedMetadata:(id)metadata;
- (_Bool)writeEncryptedImageData:(id)data;
- (_Bool)writeEncryptedMetadata:(id)metadata;

@end


@interface ICAttachmentSystemPaperModel : ICAttachmentPaperBundleModel

@property (nonatomic) struct CGRect paperContentBoundsHint;
@property (nonatomic) _Bool hasDeepLink;

/* instance methods */
- (id)account;
- (void)addMergeableDataToCloudKitRecord:(id)record approach:(long long)approach mergeableFieldState:(id)state;
- (id)additionalIndexableTextContentInNote;
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (id)correctedHardlinkURLFileExtensionForExtension:(id)extension;
- (void)fixupMetadataAndMinimumSupportedNotesVersion;
- (id)generateHardLinkURLIfNecessaryForURL:(id)url;
- (_Bool)isIncludedInGenericAttachmentCount;
- (_Bool)preferLocalPreviewImages;
- (_Bool)previewsSupportMultipleAppearances;
- (id)searchableTextContentInNote;
- (_Bool)shouldShowInContentInfoText;
- (_Bool)shouldSyncPreviewImageToCloud:(id)cloud;
- (void)updateAfterLoadWithInlineAttachmentIdentifierMap:(id)map;

@end


@interface ICAttachmentTableModel : ICAttachmentModel

@property (retain, nonatomic) ICTableVersionedDocument *tableDocument;
@property (readonly, nonatomic) ICTable *table;

/* class methods */
+ (id)tableFromAttributedString:(id)string managedObjectContext:(id)context replicaID:(id)id;

/* instance methods */
- (id)localizedFallbackTitle;
- (void)addMergeableDataToCloudKitRecord:(id)record approach:(long long)approach mergeableFieldState:(id)state;
- (void)attachmentAwakeFromFetch;
- (void)attachmentDidRefresh:(_Bool)refresh;
- (void)attachmentWillRefresh:(_Bool)refresh;
- (void)attachmentWillTurnIntoFault;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (_Bool)isReadyToPresent;
- (id)localizedFallbackSubtitleIOS;
- (id)localizedFallbackSubtitleMac;
- (void)mergeTablePrimitiveData;
- (_Bool)mergeWithMergeableData:(id)data mergeableFieldState:(id)state;
- (id)mergeableDataForCopying:(id *)copying;
- (void)persistPendingChanges;
- (_Bool)providesStandaloneTitleForNote;
- (_Bool)providesTextContentInNote;
- (void)regenerateTextContentInNote;
- (void)removeTimestampsForReplicaID:(id)id;
- (void)replaceChildInlineAttachment:(id)attachment withText:(id)text;
- (id)searchableTextContent;
- (id)searchableTextContentInNote;
- (id)stringsAtRow:(unsigned long long)row;
- (id)textContentInNote;
- (void)updateAfterLoadWithInlineAttachmentIdentifierMap:(id)map;
- (void)updateAttachmentByMergingWithTableData:(id)data;
- (_Bool)usesChildAttachment:(id)attachment;
- (void)willMarkAttachmentForDeletion;
- (void)writeCurrentTimestampToMergeableFieldStateIfNecessary:(id)necessary;
- (void)writeMergeableData;

@end


@interface ICAttachmentWebModel : ICAttachmentModel

@property (copy) id /* block */ pendingFetchCompletionHandler;

/* instance methods */
- (id)attributesForSharingHTMLWithTagName:(id *)name textContent:(id *)content;
- (_Bool)canConvertToHTMLForSharing;
- (_Bool)hasPreviews;
- (id)searchableTextContent;
- (_Bool)showThumbnailInNoteList;

@end


@interface ICFilterTypeSelection : NSObject <NSCopying>

@property (readonly, nonatomic) long long filterType;
@property (readonly, nonatomic) NSString *filterName;
@property (readonly, nonatomic) NSString *rawFilterValue;
@property (retain, nonatomic) NSManagedObjectID *accountObjectID;
@property (readonly, nonatomic) _Bool isEmpty;
@property (readonly, nonatomic) NSString *emptySummaryTitle;
@property (readonly, nonatomic) NSString *emptySummary;
@property (readonly, nonatomic) NSString *shortEmptySummary;
@property (readonly, nonatomic) _Bool isValid;

/* class methods */
+ (id)keyPathsForValuesAffectingIsValid;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICAttachmentsFilterTypeSelection : ICFilterTypeSelection

@property (nonatomic) unsigned long long selectionType;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)debugDescription;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (unsigned long long)hash;
- (id)initWithAttachmentSection:(short)section;
- (id)initWithSelectionType:(unsigned long long)type;
- (_Bool)isEqualToICAttachmentsFilterTypeSelection:(id)selection;
- (id)rawFilterValue;

@end


@interface ICAttributedStringSecureUnarchiveFromDataTransformer : NSSecureUnarchiveFromDataTransformer

/* class methods */
+ (id)allowedTopLevelClasses;

@end


@interface ICAuthenticationState : NSObject <NSCopying>

@property (nonatomic) _Bool authenticatedWithDevicePassword;
@property (retain, nonatomic) NSMutableDictionary *objectIDsToMainKey;
@property (nonatomic) long long blockingDeauthenticationCount;
@property (retain, nonatomic) NSTimer *deauthenticationTimer;
@property (nonatomic) _Bool didAttemptToDeauthenticateWhileBlocked;
@property (retain, nonatomic) id <NSObject> passphraseChangeObserver;
@property (readonly, nonatomic) _Bool authenticated;
@property (readonly, nonatomic) _Bool blockingDeauthentication;
@property (readonly, nonatomic) _Bool hasAuthenticatedObject;
@property (nonatomic) double deauthenticationTimeInterval;
@property (retain, nonatomic) NSArray *deauthenticationTimerRunLoopModes;

/* class methods */
+ (id)sharedState;
+ (void)setSharedState:(id)state;
+ (double)defaultDeauthenticationTimeInterval;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (void)dealloc;
- (_Bool)isAuthenticated;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (void)deauthenticate;
- (_Bool)authenticateObjectWithKeychain:(id)keychain;
- (void)setCachedMainKey:(id)key forIdentifier:(id)identifier;
- (_Bool)setMainKeyInKeychain:(id)keychain forObject:(id)object;
- (id)mainKeyFromKeychainForKeyObject:(id)object decryptingObject:(id)object cipherVersion:(long long)version;
- (_Bool)addMainKeyToKeychainForObject:(id)object;
- (_Bool)authenticateAllNotesInAccount:(id)account withPassphrase:(id)passphrase;
- (_Bool)authenticateObject:(id)object withPassphrase:(id)passphrase;
- (void)authenticateWithDevicePassword;
- (void)beginBlockingDeauthentication;
- (_Bool)biometricsEnabledForAccount:(id)account;
- (id)cachedMainKeyForIdentifier:(id)identifier;
- (id)cachedMainKeyForKeyObject:(id)object decryptingObject:(id)object;
- (id)cachedMainKeyForObject:(id)object;
- (_Bool)checkSupportsBiometrics;
- (void)deauthenticateAllObjects;
- (void)deauthenticateWithDevicePassword;
- (void)endBlockingDeauthentication;
- (void)extendDeauthenticationTimer;
- (id)faceIDEnabledKeyForAccountIdentifier:(id)identifier;
- (_Bool)isAuthenticatedWithDevicePassword;
- (_Bool)isBlockingDeauthentication;
- (void)localAuthenticationDidChangeBiometricsPolicyState:(id)state;
- (id)mainKeyFromKeychainForObject:(id)object;
- (id)mainKeyFromKeychainForObject:(id)object cipherVersion:(long long)version;
- (id)mainKeyIdentifierForKeyObject:(id)object cipherVersion:(long long)version;
- (_Bool)removeAllMainKeysFromKeychain;
- (_Bool)removeMainKeyFromKeychainForObject:(id)object;
- (_Bool)removeMainKeysFromKeychainForAccount:(id)account;
- (void)setBiometricsEnabled:(_Bool)enabled forAccount:(id)account;
- (_Bool)setCachedMainKey:(id)key forObject:(id)object;
- (id)touchIDEnabledKeyForAccountIdentifier:(id)identifier;

@end


@interface ICAutoCompleteSuggestionsItem : NSObject

@property (readonly, copy, nonatomic) NSString *displayText;
@property (readonly, copy, nonatomic) NSString *shortText;
@property (readonly, copy, nonatomic) NSString *rightText;
@property (readonly, copy, nonatomic) NSString *uuidString;
@property (readonly, copy, nonatomic) NSString *parentNoteIdentifier;
@property (readonly, copy, nonatomic) NSURL *URL;
@property (readonly, nonatomic) _Bool isEmptyPlaceholder;
@property (readonly, nonatomic) _Bool isParagraph;
@property (readonly, nonatomic) _Bool isCreationSuggestion;
@property (readonly, nonatomic) _Bool isBoldText;
@property (readonly, nonatomic) NSNumber *leadingPadding;
@property (readonly, nonatomic) _Bool isSectionHeader;
@property (readonly, nonatomic) NSObject *representedObject;
@property (retain, nonatomic) NSImage *iconImage;
@property (copy, nonatomic) id /* block */ iconGenerator;

/* instance methods */
- (id)initWithDisplayText:(id)text isSectionHeader:(_Bool)header;
- (id)initWithDisplayText:(id)text representedObject:(id)object isEmptyPlaceholder:(_Bool)placeholder;
- (id)initWithDisplayText:(id)text shortText:(id)text representedObject:(id)object;
- (id)initWithDisplayText:(id)text shortText:(id)text rightText:(id)text uuidString:(id)string isEmptyPlaceholder:(_Bool)placeholder isParagraph:(_Bool)paragraph isBoldText:(_Bool)text isSectionHeader:(_Bool)header isCreationSuggestion:(_Bool)suggestion iconImage:(id)image parentNoteIdentifier:(id)identifier URL:(id)url leadingPadding:(id)padding representedObject:(id)object;
- (id)initWithDisplayText:(id)text shortText:(id)text rightText:(id)text uuidString:(id)string isEmptyPlaceholder:(_Bool)placeholder isSectionHeader:(_Bool)header isCreationSuggestion:(_Bool)suggestion iconImage:(id)image parentNoteIdentifier:(id)identifier URL:(id)url representedObject:(id)object;
- (id)initWithDisplayText:(id)text shortText:(id)text uuidString:(id)string iconImage:(id)image;
- (id)initWithDisplayText:(id)text shortText:(id)text uuidString:(id)string isEmptyPlaceholder:(_Bool)placeholder iconImage:(id)image representedObject:(id)object;
- (id)initWithDisplayText:(id)text shortText:(id)text uuidString:(id)string isEmptyPlaceholder:(_Bool)placeholder isSectionHeader:(_Bool)header iconImage:(id)image representedObject:(id)object;

@end


@interface ICAutoFormatMarkdownController : NSObject

/* class methods */
+ (void)setShouldAutoFormatMarkdown:(_Bool)markdown;
+ (_Bool)shouldAutoFormatMarkdown;

@end


@interface ICBackgroundTaskScheduler : NSObject

@property (retain, nonatomic) NSMutableDictionary *registeredTasks;
@property (retain, nonatomic) NSMutableSet *scheduledTasks;

/* class methods */
+ (id)sharedScheduler;

/* instance methods */
- (id)init;
- (void)registerTask:(id)task;
- (void)scheduleTask:(Class)task completion:(id /* block */)completion;

@end


@interface ICBackgroundTranscriptionHelper : NSObject

/* class methods */
+ (id)sharedInstance;

/* instance methods */
- (void)addAudioTranscriptionTaskToQueueWithIdentifier:(id)identifier;
- (void)addCallRecordingTranscriptionTaskToQueueOnLaunch:(id)launch;

@end


@interface ICBundleChangeFilePresenter : NSObject <NSFilePresenter>

@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (copy, nonatomic) NSManagedObjectID *objectID;
@property (retain, nonatomic) ICSelectorDelayer *applyChangesSelectorDelayer;
@property (copy, nonatomic) NSURL *url;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic) id /* block */ presentedItemDidApplyChanges;
@property (readonly, copy) NSURL *presentedItemURL;
@property (readonly, retain) NSOperationQueue *presentedItemOperationQueue;
@property (readonly, copy) NSURL *primaryPresentedItemURL;
@property (readonly) NSSet *observedPresentedItemUbiquityAttributes;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)presentedItemDidChange;
- (void)applyChanges;
- (id)initWithObjectID:(id)id url:(id)url managedObjectContext:(id)context;

@end


@interface ICBundleChangeObserver : NSObject

@property (nonatomic) _Bool isObserving;
@property (nonatomic) _Bool didAddForExistingPaperAttachments;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) NSMutableDictionary *mutableFilePresenters;
@property (retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) NSObject *processingQueue;
@property (copy, nonatomic) id /* block */ didChangeFilePresenters;
@property (copy, nonatomic) id /* block */ attachmentDidChange;

/* instance methods */
- (void)stop;
- (void)start;
- (void)contextDidSave:(id)save;
- (id)filePresenters;
- (id)init;
- (void)removeObserverForBundleWithURL:(id)url;
- (void)addManagedObjectContextDidSaveObserver;
- (void)addObserverForBundleWithObjectID:(id)id url:(id)url;
- (void)addObserversForExistingPaperAttachments;
- (void)addObserversForObjects:(id)objects;
- (id)initWithPersistentStoreCoordinator:(id)coordinator managedObjectContext:(id)context;
- (void)processObjectIDs:(id)ids completion:(id /* block */)completion;
- (void)removeManagedObjectContextDidSaveObserver;
- (void)stopAndNotifyObservers:(_Bool)observers;

@end


@interface ICBundleContainerFilePresenter : NSObject <NSFilePresenter>

@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (copy, nonatomic) NSURL *url;
@property (copy, nonatomic) id /* block */ subitemBundleDidChange;
@property (readonly, copy) NSURL *presentedItemURL;
@property (readonly, retain) NSOperationQueue *presentedItemOperationQueue;
@property (readonly, copy) NSURL *primaryPresentedItemURL;
@property (readonly) NSSet *observedPresentedItemUbiquityAttributes;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithURL:(id)url;
- (void)presentedSubitemDidChangeAtURL:(id)url;

@end


@interface ICCKShareUnknownParticipant : NSObject

@property (readonly, nonatomic) NSString *participantUserID;
@property (readonly, nonatomic) NSString *displayName;

/* instance methods */
- (id)initWithParticipantUserID:(id)id;

@end


@interface ICCRArray : NSObject <ICCRUndoDelegate, ICCRDataType>

@property (retain, nonatomic) ICTTArray *array;
@property (retain, nonatomic) ICCRDictionary *contents;
@property (nonatomic) _Bool moveClock;
@property (weak, nonatomic) ICCRDocument *document;
@property (weak, nonatomic) NSObject<ICCRUndoDelegate> *delegate;
@property (readonly, nonatomic) NSArray *allObjects;
@property (readonly, nonatomic) unsigned long long count;
@property (readonly, nonatomic) NSUUID *replicaUUID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)addObject:(id)object;
- (id)initWithDocument:(id)document;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)replaceObjectAtIndex:(unsigned long long)index withObject:(id)object;
- (id)_addObject:(id)object;
- (void)removeObjectAtIndex:(unsigned long long)index;
- (void)insertObject:(id)object atIndex:(unsigned long long)index;
- (void)removeLastObject;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (id)_insertObject:(id)object atIndex:(unsigned long long)index;
- (id)_insertObject:(id)object withIdentifier:(id)identifier atIndex:(unsigned long long)index forUndo:(_Bool)undo;
- (unsigned long long)firstIndexOf:(id)of fromIndex:(unsigned long long)index;
- (void)moveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)removeObjectAtIndex:(unsigned long long)index forUndo:(_Bool)undo;
- (_Bool)wantsUndoCommands;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (void)encodeWithICCRCoder:(id)iccrcoder array:(void *)array;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder array:(const void *)array;
- (id)initWithICTTArray:(id)icttarray contents:(id)contents document:(id)document;

@end


@interface ICCRCoder : NSObject

@property (retain, nonatomic) NSMutableOrderedSet *encodedObjects;
@property (nonatomic) void * currentDocument;
@property (readonly, nonatomic) NSOrderedSet *clusterTypeSet;
@property (readonly, nonatomic) NSDictionary *typeToClassDict;
@property (readonly, nonatomic) NSOrderedSet *typeSet;

/* class methods */
+ (void)registerCRClasses;
+ (void)registerClass:(Class)_class forType:(id)type;
+ (void)_registerClass:(Class)_class forType:(id)type cluster:(_Bool)cluster;

/* instance methods */
- (unsigned long long)typeIndexForClass:(Class)_class;

@end


@interface ICCRCoderArchiver : ICCRCoder

@property (retain, nonatomic) NSMutableOrderedSet *uuidSet;
@property (retain, nonatomic) NSMutableOrderedSet *keySet;
@property (retain, nonatomic) NSMutableOrderedSet *encodedObjects;
@property (nonatomic) void * currentDocument;

/* class methods */
+ (void)initialize;
+ (id)encodedDataWithDocument:(id)document;

/* instance methods */
- (void)encodeInt64:(long long)int64 forKey:(id)key;
- (void)encodeInt32:(int)int32 forKey:(id)key;
- (void)encodeDouble:(double)_double forKey:(id)key;
- (void)encodeObject:(id)object forKey:(id)key;
- (void)encodeUInt64:(unsigned long long)uint64 forKey:(id)key;
- (int)indexForKey:(id)key;
- (void)encodeString:(id)string forKey:(id)key;
- (id)encodeDocument:(id)document;
- (void *)currentCustomObjectForEncoding;
- (void *)currentDocumentObjectForEncoding;
- (void)encodeObject:(id)object forObjectID:(void *)id;
- (void)encodeUInt32:(unsigned int)uint32 forKey:(id)key;
- (void)encodeUUID:(id)uuid forKey:(id)key;
- (unsigned long long)encodeUUIDIndexFromUUID:(id)uuid;
- (void *)mutableObjectIDForKey:(id)key;
- (void)setTypeIndexForCurrentCustomObjectIfNecessary:(id)necessary;
- (void)encodeData:(id)data forKey:(id)key;

@end


@interface ICCRCoderUnarchiver : ICCRCoder

@property (copy, nonatomic) NSUUID *replica;
@property (retain, nonatomic) ICCRDocument *document;
@property (nonatomic) void * currentDocument;
@property (retain, nonatomic) NSMutableArray *allocedDocObjects;
@property (nonatomic) const void * currentDocObjectForDecodingPtr;
@property (retain, nonatomic) NSMutableOrderedSet *typeSetForDecoding;
@property (retain, nonatomic) NSMutableOrderedSet *keySet;
@property (retain, nonatomic) NSMutableArray *uuidArray;
@property (retain, nonatomic) NSMutableArray *completionHandlers;

/* class methods */
+ (void)initialize;
+ (id)decodedDocumentFromData:(id)data replica:(id)replica;

/* instance methods */
- (id)decodeObjectForKey:(id)key;
- (double)decodeDoubleForKey:(id)key;
- (long long)decodeInt64ForKey:(id)key;
- (int)decodeInt32ForKey:(id)key;
- (unsigned long long)indexForKey:(id)key;
- (id)decodeStringForKey:(id)key;
- (unsigned long long)decodeUInt64ForKey:(id)key;
- (id)decodeDocumentFromData:(id)data replica:(id)replica;
- (void)addDecoderCompletionHandler:(id /* block */)handler dependency:(id)dependency for:(id)_for;
- (id)allocedObjectAtIndex:(unsigned long long)index outNeedsInit:(_Bool *)init;
- (const void *)currentDocumentObjectForDecoding;
- (const void *)currentObjectIDForKey:(id)key;
- (id)decodeObjectForProtobufObjectID:(const void *)id;
- (unsigned int)decodeUInt32ForKey:(id)key;
- (id)decodeUUIDForKey:(id)key;
- (id)decodeUUIDFromUUIDIndex:(unsigned long long)uuidindex;
- (_Bool)hasDecodableValueForKey:(id)key;
- (void)sortCompletionHandlers;
- (_Bool)willModifySelfInInitForClass:(Class)_class;
- (id)decodeDataForKey:(id)key;
- (id)decodeKeys;

@end


@interface ICCRCoderUnarchiverCompletionHandler : NSObject

@property (copy, nonatomic) id /* block */ block;
@property (weak, nonatomic) id dependency;
@property (weak, nonatomic) id value;

/* instance methods */

@end


@interface ICCRConstant : NSObject

/* class methods */
+ (id)constant;

/* instance methods */
- (_Bool)isEqual:(id)equal;

@end


@interface ICCRDictionary : NSObject <ICCRDataType, NSFastEnumeration, ICCRCoding>

@property (retain, nonatomic) NSMapTable *contents;
@property (nonatomic) long long removeClock;
@property (weak, nonatomic) ICCRDocument *document;
@property (readonly) unsigned long long count;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)keyEnumerator;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)objectForKeyedSubscript:(id)subscript;
- (void)mergeWithDictionary:(id)dictionary;
- (id)deltaSince:(id)since in:(id)in;
- (id)initWithDocument:(id)document;
- (void)removeAllObjects;
- (void)mergeWith:(id)with;
- (id)init;
- (unsigned long long)countByEnumeratingWithState:(struct { unsigned long long x0; id *x1; unsigned long long *x2; unsigned long long x3[5]; } *)state objects:(id *)objects count:(unsigned long long)count;
- (void)removeObjectForKey:(id)key;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)subscript;
- (void)setObject:(id)object forKey:(id)key;
- (void)enumerateKeysObjectsAndTimestampsUsingBlock:(id /* block */)block;
- (void)encodeWithICCRCoder:(id)iccrcoder dictionary:(void *)dictionary;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (void)encodeWithICCRCoder:(id)iccrcoder dictionary:(void *)dictionary elementValueCoder:(id /* block */)coder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder dictionary:(const void *)dictionary;
- (id)initWithICCRCoder:(id)iccrcoder dictionary:(const void *)dictionary elementValueDecoder:(id /* block */)decoder;

@end


@interface ICCRDictionaryElement : NSObject

@property (retain, nonatomic) id <ICCRDataType> value;
@property (retain, nonatomic) ICCRVectorTimestamp *timestamp;

/* class methods */
+ (id)temporaryElementWithValue:(id)value;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)mergeWith:(id)with;
- (id)description;
- (id)initWithValue:(id)value;
- (unsigned long long)hash;
- (id)initWithValue:(id)value timestamp:(id)timestamp;

@end


@interface ICCRDocument : NSObject

@property (readonly, nonatomic) ICCRVectorTimestamp *version;
@property (readonly, nonatomic) ICCRVectorTimestamp *startVersion;
@property (readonly, nonatomic) NSUUID *replica;
@property (retain, nonatomic) id rootObject;
@property (readonly, nonatomic) long long replicaClock;
@property (nonatomic) long long unserializedReplicaClock;
@property (readonly, nonatomic) NSMutableDictionary *objects;

/* class methods */
+ (id)documentWithRootObject:(id)object replica:(id)replica;
+ (id)documentWithReplica:(id)replica;
+ (id)unarchiveFromData:(id)data replica:(id)replica;

/* instance methods */
- (void)setDocument:(id)document;
- (id)description;
- (id)init;
- (id)archivedData;
- (void)updateObjects:(id)objects;
- (id)copyForReplica:(id)replica;
- (void)setDocumentFor:(id)_for;
- (void)walkGraph:(id /* block */)graph root:(id)root;
- (id)deltaSince:(id)since;
- (id)initWithReplica:(id)replica;
- (id)initWithVersion:(id)version rootObject:(id)object replica:(id)replica;
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica;
- (id)localObject:(id)object;
- (unsigned long long)mergeResultForMergingWithDocument:(id)document;
- (void)mergeTimestampWithDocument:(id)document;
- (unsigned long long)mergeWithData:(id)data;
- (unsigned long long)mergeWithDocument:(id)document;
- (void)realizeLocalChanges;
- (void)updateGraphDocumentPointers;
- (void)updateObjectsSet;

@end


@interface ICCRIndex : NSObject <NSCopying, ICCRDataType, ICCRCoding>

@property (retain, nonatomic) NSArray *indexPath;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)indexForReplica:(id)replica betweenIndex:(id)index andIndex:(id)index;
+ (id)indexWithPath:(id)path;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (long long)compare:(id)compare;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (unsigned long long)depth;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)indexAtDepth:(unsigned long long)depth withInteger:(long long)integer replica:(id)replica;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)nextIndexForReplica:(id)replica;
- (id)previousIndexForReplica:(id)replica;

@end


@interface ICCRIndexElement : NSObject <NSCopying>

@property (retain, nonatomic) NSUUID *replica;
@property (nonatomic) long long integer;

/* class methods */
+ (id)elementWithInteger:(long long)integer replica:(id)replica;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)compare:(id)compare;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithInteger:(long long)integer replica:(id)replica;

@end


@interface ICCROneOf : NSObject <ICCRDataType>

@property (retain, nonatomic) NSMapTable *timestamps;
@property (retain, nonatomic) ICCRSet *set;
@property (weak, nonatomic) id contents;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)setDocument:(id)document;
- (void)addItem:(id)item;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)setUpdated:(id)updated;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)timestampForNewItem;

@end


@interface ICCROrderedSet : NSObject <ICCRDataType, ICCRCoding>

@property (retain, nonatomic) ICCRSet *contents;
@property (retain, nonatomic) NSMutableArray *orderedArray;
@property (weak, nonatomic) ICCRDocument *document;
@property (readonly) unsigned long long count;
@property (readonly, copy) NSArray *allObjects;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (void)enumerateWithBlock:(id /* block */)block;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)addObjectsFromArray:(id)array;
- (void)addObject:(id)object;
- (void)setObject:(id)object atIndexedSubscript:(unsigned long long)subscript;
- (void)setObject:(id)object atIndex:(unsigned long long)index;
- (void)removeAllObjects;
- (unsigned long long)indexOfObject:(id)object;
- (void)mergeWith:(id)with;
- (_Bool)containsObject:(id)object;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)removeObject:(id)object;
- (void)removeObjectAtIndex:(unsigned long long)index;
- (void)insertObject:(id)object atIndex:(unsigned long long)index;
- (void)_sort;
- (id)_indexForIndex:(unsigned long long)index;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (void)mergeWithSet:(id)set;
- (void)moveObject:(id)object toIndex:(unsigned long long)index;

@end


@interface ICCROrderedSetElement : NSObject <ICCRDataType, NSCopying, ICCREquatable>

@property (retain, nonatomic) id <ICCRDataType, ICCRCoding> value;
@property (retain, nonatomic) ICCRRegisterLatest *index;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)temporaryElementWithValue:(id)value;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)encodeIntoProtobufSetElement:(void *)element coder:(id)coder;
- (id)initWithProtobufSetElement:(const void *)element decoder:(id)decoder;

@end


@interface ICCRRegister : NSObject <ICCRDataType, ICCRCoding>

@property (retain, nonatomic) id contents;
@property (weak, nonatomic) ICCRDocument *document;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)registerWithType:(unsigned long long)type contents:(id)contents;
+ (id)registerWithType:(unsigned long long)type contents:(id)contents document:(id)document;

/* instance methods */
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (id)initWithDocument:(id)document;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (_Bool)isEqualContents:(id)contents;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRRegisterLatest : ICCRRegister

@property (retain, nonatomic) ICCRTimestamp *timestamp;

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)setContents:(id)contents;
- (id)contents;
- (void)mergeWith:(id)with;
- (id)description;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)_setContents:(id)contents;
- (void)encodeIntoProtobufRegisterLatest:(void *)latest coder:(id)coder;
- (id)initWithContents:(id)contents document:(id)document;
- (id)initWithContents:(id)contents timestamp:(id)timestamp document:(id)document;
- (id)initWithProtobufRegisterLatest:(const void *)latest decoder:(id)decoder;
- (_Bool)isEqualContents:(id)contents;
- (void)mergeWithRegisterLatest:(id)latest;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRRegisterGreatest : ICCRRegisterLatest

/* instance methods */
- (void)setContents:(id)contents;
- (void)mergeWith:(id)with;
- (long long)compare:(id)compare with:(id)with;
- (void)mergeWithRegisterGreatest:(id)greatest;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRRegisterLeast : ICCRRegisterGreatest

/* instance methods */
- (long long)compare:(id)compare with:(id)with;

@end


@interface ICCRRegisterMultiValue : ICCRRegister

@property (retain, nonatomic) ICCRSet *values;
@property (retain, nonatomic) NSSet *cachedValues;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)deltaSince:(id)since in:(id)in;
- (void)setContents:(id)contents;
- (id)contents;
- (id)initWithValues:(id)values;
- (void)mergeWith:(id)with;
- (id)description;
- (void)walkGraph:(id /* block */)graph;
- (id)allContents;
- (id)initWithContents:(id)contents document:(id)document;
- (void)mergeWithRegisterMultiValue:(id)value;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRRegisterMultiValueLeast : ICCRRegisterMultiValue

/* instance methods */
- (id)contents;

@end


@interface ICCRSet : NSObject <ICCRDataType, NSFastEnumeration, ICCRCoding>

@property (retain, nonatomic) ICCRDictionary *dictionary;
@property (retain, nonatomic) NSHashTable *observers;
@property (weak, nonatomic) ICCRDocument *document;
@property (readonly) unsigned long long count;
@property (readonly, copy) NSArray *allObjects;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)addObject:(id)object;
- (id)initWithDocument:(id)document;
- (void)removeObserver:(id)observer;
- (id)anyObject;
- (void)removeAllObjects;
- (void)mergeWith:(id)with;
- (_Bool)containsObject:(id)object;
- (id)init;
- (void)addObserver:(id)observer;
- (unsigned long long)countByEnumeratingWithState:(struct { unsigned long long x0; id *x1; unsigned long long *x2; unsigned long long x3[5]; } *)state objects:(id *)objects count:(unsigned long long)count;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)removeObject:(id)object;
- (void)setObject:(id)object;
- (void)setUpdated:(id)updated;
- (id)member:(id)member;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (void)encodeWithICCRCoder:(id)iccrcoder set:(void *)set;
- (void)encodeWithICCRCoder:(id)iccrcoder set:(void *)set elementValueCoder:(id /* block */)coder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder set:(const void *)set;
- (id)initWithICCRCoder:(id)iccrcoder set:(const void *)set elementValueDecoder:(id /* block */)decoder;

@end


@interface ICCRTTCompatibleDocument : ICCRDocument

@property (retain, nonatomic) TTICCRVectorMultiTimestamp *sharedTopotextTimestamp;
@property (retain, nonatomic) NSMutableArray *stringsWithClocksNeedingUpdating;
@property (retain, nonatomic) NSMutableArray *stringsWithClocksToResetAfterRealizingLocalChanges;

/* class methods */
+ (id)makeSharedTopotextTimestampFromData:(id)data;

/* instance methods */
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica;
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica topoTimestamp:(id)timestamp;
- (unsigned long long)mergeResultForMergingWithDocument:(id)document;
- (void)mergeTimestampWithDocument:(id)document;
- (void)realizeLocalChanges;

@end


@interface ICCRTimestamp : NSObject <ICCRDataType, ICCREquatable, NSCopying, ICCRCoding>

@property (retain, nonatomic) NSUUID *replica;
@property (nonatomic) long long counter;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (long long)compare:(id)compare;
- (id)shortDescription;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)isEqualToTimestamp:(id)timestamp;
- (id)laterTimestamp:(id)timestamp;
- (id)earlierTimestamp:(id)timestamp;
- (void)encodeIntoProtobufTimestamp:(void *)timestamp coder:(id)coder;
- (id)initWithProtobufTimestamp:(const void *)timestamp decoder:(id)decoder;
- (id)initWithReplica:(id)replica andCounter:(long long)counter;
- (id)nextTimestamp;
- (id)nextTimestampForReplica:(id)replica;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRTombstoneOrderedSet : NSObject <ICCRCoding, ICCRUndoDelegate, ICCRDataType>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) NSMapTable *cachedIndexMapping;
@property (readonly, nonatomic) NSMutableOrderedSet *cachedIdentifierSet;
@property (retain, nonatomic) ICCRArray *ordering;
@property (retain, nonatomic) ICCRSet *elements;
@property (weak, nonatomic) ICCRDocument *document;
@property (weak, nonatomic) NSObject<ICCRUndoDelegate> *delegate;
@property (readonly, nonatomic) unsigned long long count;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (id)objectForIdentifier:(id)identifier;
- (void)addObject:(id)object;
- (id)initWithDocument:(id)document;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)removeObjectAtIndex:(unsigned long long)index;
- (void)insertObject:(id)object atIndex:(unsigned long long)index;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (id)identifierForObjectInCachedSet:(id)set;
- (void)_removeObjectsFromOrderingAtIndices:(id)indices;
- (_Bool)containsObjectEqualTo:(id)to;
- (id)generateNSOrderedIdentifierSetWithIndexMapping:(id)mapping;
- (unsigned long long)indexOfEqualObject:(id)object;
- (id)initWithOrdering:(id)ordering elements:(id)elements document:(id)document;
- (void)moveClock;
- (void)moveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)moveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index mutableSafe:(_Bool)safe;
- (void)realizeElementMutations;
- (void)regenerateNSOrderedIdentifierSetAndIndexMapping;
- (void)reinsertIdentifier:(id)identifier withMaskedIdentifiers:(id)identifiers atIndex:(unsigned long long)index forObjectToMove:(id)move;
- (void)safeMoveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)shiftCachedIndicesStartingAtIndex:(unsigned long long)index by:(long long)by;
- (void)undoablyInsertObjectIdentifiersIntoElements:(id)elements;
- (void)undoablyRemoveObjectIdentifiersFromElements:(id)elements;
- (_Bool)wantsUndoCommands;
- (void)wipeoutCaches;
- (void)encodeWithICCRCoder:(id)iccrcoder orderedSet:(void *)set;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder orderedSet:(const void *)set;

@end


@interface ICCRTree : ICCRObject

@property (readonly, nonatomic) ICCROrderedSet *nodes;
@property (readonly, nonatomic) ICCRTreeNode *root;
@property (readonly, nonatomic) long long count;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (void)setDocument:(id)document;
- (void)mergeWith:(id)with;
- (id)init;
- (void)removeNode:(id)node;
- (void)invalidateChildren;
- (void)computeChildren;
- (id)initWithICCRCoder:(id)iccrcoder;
- (unsigned long long)insertIndexForNode:(id)node childIndex:(unsigned long long)index;
- (void)insertNode:(id)node inParent:(id)parent atIndex:(unsigned long long)index;
- (id)insertNodeWithValue:(id)value inParent:(id)parent atIndex:(unsigned long long)index;
- (void)moveNode:(id)node toParent:(id)parent atIndex:(unsigned long long)index;
- (void)setNodeTree:(id)tree insertAtIndex:(unsigned long long)index;

@end


@interface ICCRTreeNode : ICCRObject

@property (weak, nonatomic) ICCRTree *tree;
@property (weak, nonatomic) ICCRTreeNode *parent;
@property (retain, nonatomic) ICCRWeakReference *parentRef;
@property (retain, nonatomic) id value;
@property (retain, nonatomic) NSArray *children;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (id)parentReference;
- (void)removeNode:(id)node;
- (id)initWithValue:(id)value parent:(id)parent tree:(id)tree;
- (void)insertNode:(id)node atIndex:(unsigned long long)index;
- (id)insertNodeWithValue:(id)value atIndex:(unsigned long long)index;
- (_Bool)isInLoop;
- (_Bool)isLoopNode;
- (void)moveNode:(id)node toIndex:(unsigned long long)index;

@end


@interface ICCRTuple : NSObject <ICCRDataType, ICCRCoding>

@property (retain, nonatomic) NSArray *contents;
@property (readonly) unsigned long long count;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)tupleWithArray:(id)array;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (void)setDocument:(id)document;
- (id)initWithArray:(id)array;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRVectorTimestamp : NSObject <ICCRDataType, NSCopying, ICCRCoding>

@property (readonly, nonatomic) unsigned long long count;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (unsigned long long)compare:(id)compare;
- (id)shortDescription;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)removeUUID:(id)uuid;
- (id)allUUIDs;
- (id)clockElementForUUID:(id)uuid;
- (unsigned long long)clockForUUID:(id)uuid;
- (void)encodeIntoProtobufTimestamp:(void *)timestamp coder:(id)coder;
- (void)incrementClockForUUID:(id)uuid;
- (id)initWithProtobufTimestamp:(const void *)timestamp decoder:(id)decoder;
- (void)maxClock:(unsigned long long)clock forUUID:(id)uuid;
- (void)minusVectorTimestamp:(id)timestamp;
- (void)setClock:(unsigned long long)clock forUUID:(id)uuid;
- (void)setClock:(unsigned long long)clock subclock:(unsigned long long)subclock forUUID:(id)uuid;
- (id)sortedUUIDs;
- (unsigned long long)subclockForUUID:(id)uuid;
- (id)timestampForReplica:(id)replica;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCRVectorTimestampElement : NSObject

@property (nonatomic) unsigned long long clock;
@property (nonatomic) unsigned long long subclock;

@end


@interface ICCRWeakReference : NSObject <ICCRDataType, ICCRCoding>

@property (weak, nonatomic) ICCRDocument *document;
@property (retain, nonatomic) NSUUID *identifier;
@property (readonly, nonatomic) id contents;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (id)initWithContents:(id)contents;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)initWithContents:(id)contents document:(id)document;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithIdentifier:(id)identifier document:(id)document;

@end


@interface ICChecklistsFilterTypeSelection : ICFilterTypeSelection <NSCopying>

@property (readonly, nonatomic) unsigned long long selectionType;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (unsigned long long)hash;
- (id)initWithSelectionType:(unsigned long long)type;
- (_Bool)isEqualToICChecklistsFilterTypeSelection:(id)selection;
- (id)rawFilterValue;

@end


@interface ICCipherV1 : NSObject

/* class methods */
+ (id)decryptData:(id)data withKey:(id)key tag:(id)tag initializationVector:(id)vector error:(id *)error;
+ (id)encryptData:(id)data withKey:(id)key tag:(id *)tag initializationVector:(id *)vector error:(id *)error;
+ (id)keyForPassphrase:(id)passphrase salt:(id)salt iterationCount:(unsigned long long)count error:(id *)error;
+ (id)unwrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;
+ (id)wrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;

@end


@interface ICCipherV1Neo : NSObject

/* class methods */
+ (id)decryptData:(id)data withKey:(id)key additionalAuthenticatedData:(id)data error:(id *)error;
+ (id)encryptData:(id)data withKey:(id)key additionalAuthenticatedData:(id)data error:(id *)error;
+ (id)keyForPassphrase:(id)passphrase salt:(id)salt iterationCount:(unsigned long long)count error:(id *)error;
+ (id)unwrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;
+ (id)wrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;

@end


@interface ICCipherV2 : NSObject

/* class methods */
+ (id)decryptData:(id)data withKey:(id)key additionalAuthenticatedData:(id)data error:(id *)error;
+ (id)deserializedData:(id)data initializationVector:(id *)vector tag:(id *)tag;
+ (id)encryptData:(id)data withKey:(id)key additionalAuthenticatedData:(id)data error:(id *)error;
+ (id)serializedData:(id)data initializationVector:(id)vector tag:(id)tag;
+ (long long)standardWrappedKeyLength;
+ (id)unwrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;
+ (id)wrapKey:(id)key withWrapper:(id)wrapper error:(id *)error;

@end


@interface ICCloudConfiguration : NSObject

@property (readonly, copy, nonatomic) NSDictionary *configurationDictionary;
@property (readonly, nonatomic) unsigned long long appStoreRatingCohortPercentage;
@property (readonly, nonatomic) double appStoreRatingIdleTimeInterval;
@property (readonly, nonatomic) unsigned long long appStoreRatingLaunchCount;
@property (readonly, nonatomic) unsigned long long appStoreRatingOldestLaunchDayPeriod;
@property (readonly, nonatomic) unsigned long long appStoreRatingLaunchDayPeriod;
@property (readonly, nonatomic) unsigned long long appStoreRatingNoteCount;
@property (readonly, nonatomic) unsigned long long appStoreRatingRequestDayPeriod;
@property (readonly, nonatomic) ICCloudThrottlingPolicy *throttlingPolicy;
@property (readonly, nonatomic) _Bool shouldSyncWhenEnteringForeground;
@property (readonly, nonatomic) unsigned long long maxInlineAssetSizeBytes;
@property (readonly, nonatomic) unsigned long long maxAttachmentsPerNote;
@property (readonly, nonatomic) unsigned long long maxSubAttachmentsPerAttachment;
@property (readonly, nonatomic) unsigned long long resultsLimitPerSyncOperation;
@property (readonly, copy, nonatomic) NSNumber *maximumAttachmentSizeMB;
@property (readonly, copy, nonatomic) NSString *minimumClientVersion;
@property (readonly, nonatomic) unsigned long long mentionNotificationMaxRetries;
@property (readonly, nonatomic) unsigned long long launchTaskMaxRetries;
@property (readonly, nonatomic) unsigned long long serverSideUpdateTaskMaxFailureCount;
@property (readonly, nonatomic) unsigned long long durationForNextPasswordReask;
@property (readonly, nonatomic) unsigned long long unsupportedNoteDeviceCheckIntervalSeconds;
@property (readonly, nonatomic) _Bool requestUserNotificationAuthorizationAtLaunch;
@property (readonly, nonatomic) _Bool fastSyncEnabled;
@property (readonly, nonatomic) unsigned long long fastSyncMaximumMessageSizeBytes;
@property (readonly, nonatomic) _Bool fastSyncPaperKitEnablePCSEncryption;
@property (readonly, nonatomic) _Bool fastSyncPaperKitEnableEphemeralRecords;
@property (readonly, nonatomic) unsigned long long fastSyncMaximumThumbnailMessageSizeBytes;
@property (readonly, nonatomic) double fastSyncPresenceDebounceDuration;
@property (readonly, nonatomic) _Bool keychainFetchingEnabled;
@property (readonly, nonatomic) double keychainFetchErrorTimeout;
@property (readonly, nonatomic) double keychainMinimumSyncInterval;
@property (readonly, nonatomic) double keychainMaximumSyncInterval;
@property (readonly, nonatomic) _Bool usesLocalConfigurationFile;
@property (readonly, nonatomic) _Bool audioTranscriptPostProcessingEnabled;
@property (readonly, nonatomic) _Bool searchSubstringMatchingEnabled;
@property (readonly, nonatomic) double saveDelayMinDebounceTime;
@property (readonly, nonatomic) double saveDelayMaxDebounceTime;
@property (readonly, nonatomic) double saveDelayMaxTime;
@property (readonly, nonatomic) double saveDelayFastSyncMinDebounceTime;
@property (readonly, nonatomic) double saveDelayFastSyncMaxDebounceTime;
@property (readonly, nonatomic) double saveDelayFastSyncMaxTime;
@property (readonly, nonatomic) double saveDelayTableDebounceTime;
@property (readonly, nonatomic) double saveDelayTableMaxTime;

/* class methods */
+ (void)loadSharedConfigurationWithCompletionHandler:(id /* block */)handler;
+ (void)loadSharedConfigurationWithQoSClass:(unsigned int)sclass completionHandler:(id /* block */)handler;
+ (void)setDefaultConfigurationURL:(id)url;
+ (id)availableConfigurationURLs;
+ (id)cachedConfigurationURL;
+ (_Bool)isConfigurationValid:(id)valid;
+ (id)overridableValueForKey:(id)key inConfigurationDictionary:(id)dictionary userDefaults:(id)defaults;
+ (id)sharedConfiguration;
+ (id)defaultConfigurationURL;

/* instance methods */
- (id)initWithConfigurationDictionary:(id)dictionary userDefaults:(id)defaults usesLocalConfigurationFile:(_Bool)file;
- (id)overridableValueForKey:(id)key inConfigurationDictionary:(id)dictionary;
- (id)initWithUserDefaults:(id)defaults;
- (void)loadConfigurationFromURL:(id)url completionHandler:(id /* block */)handler;
- (void)dealloc;
- (void)downloadConfigurationFromRemoteURL:(id)url completionHandler:(id /* block */)handler;
- (void)setConfigurationFromDictionary:(id)dictionary;
- (void)loadConfigurationFromURL:(id)url;
- (id)initWithUserDefaults:(id)defaults usesLocalConfigurationFile:(_Bool)file;
- (void)loadLocalConfigurationFile;
- (void)downloadRemoteConfiguration:(id)configuration;

@end


@interface ICCloudContext : NSObject <ICStateHandlerProvider>

@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (retain, nonatomic) NSObject *processingQueue;
@property (retain, nonatomic) NSManagedObjectContext *processingQueueBackgroundContext;
@property (retain, nonatomic) NSObject *containersCreationQueue;
@property (retain, nonatomic) NSManagedObjectContext *containersCreationQueueBackgroundContext;
@property (nonatomic) struct os_unfair_lock_s backgroundContextLock;
@property (retain, nonatomic) NSManagedObjectContext *genericBackgroundContext;
@property (retain, nonatomic) NSMutableSet *objectIDsToRetry;
@property (retain) NSTimer *retryTimer;
@property (retain, nonatomic) NSMutableDictionary *retryCountsByOperationType;
@property (nonatomic) long long accountStatus;
@property _Bool disabledInternal;
@property (readonly, nonatomic) NSDictionary *cloudObjectClassesByRecordType;
@property (nonatomic) _Bool needsToProcessAllObjects;
@property (retain, nonatomic) NSMutableSet *objectIDsToProcess;
@property (retain) ICSelectorDelayer *processingSelectorDelayer;
@property (nonatomic) _Bool didAddObservers;
@property (nonatomic) _Bool fetchingEnabled;
@property (nonatomic) _Bool syncDisabledByServer;
@property (retain, nonatomic) NSDictionary *containersByAccountID;
@property (retain, nonatomic) NSMutableDictionary *accountZoneIDsNeedingFetchChanges;
@property (retain, nonatomic) NSMutableDictionary *accountZoneIDsFetchingChanges;
@property (retain, nonatomic) NSMutableDictionary *accountZoneIDsNeedingToBeSaved;
@property (retain) NSMutableSet *subscribedSubscriptionIDs;
@property (nonatomic) _Bool didEnqueueLongLivedOperations;
@property (nonatomic) _Bool enqueueingLongLivedOperations;
@property (retain, nonatomic) NSMutableSet *operationIDsBeforeEnqueuingLongLivedOperations;
@property (retain, nonatomic) ICCloudOperationObserver *operationObserver;
@property (retain, nonatomic) NSMutableSet *recordIdsToShowQuotaExceededErrorOnTrashRecoveryAlert;
@property (nonatomic) _Bool isDaemonProcess;
@property (nonatomic) long long lastKnownWalrusStatus;
@property (weak, nonatomic) id <ICCloudContextDelegate> cloudContextDelegate;
@property (weak, nonatomic) id <ICCloudAnalyticsDelegate> cloudAnalyticsDelegate;
@property (weak, nonatomic) id <ICCloudSessionDelegate> cloudSessionDelegate;
@property (readonly, nonatomic) _Bool fetchOperationsPending;
@property _Bool needsToUpdateSubscriptions;
@property (nonatomic) _Bool shouldResumeSyncOnForeground;
@property (readonly, nonatomic) _Bool completedInitialSync;
@property (nonatomic) long long qualityOfService;
@property (nonatomic) unsigned long long discretionaryNetworkBehavior;
@property (nonatomic) _Bool enableLongLivedOperations;
@property (nonatomic) _Bool disableAutomaticallyRetryNetworkFailures;
@property (nonatomic) _Bool disableRetryTimer;
@property (nonatomic) _Bool syncOnlyIfReachable;
@property _Bool disabled;
@property (readonly, nonatomic) _Bool hasPendingOperations;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)metadataZoneID;
+ (id)errorFromOperations:(id)operations;
+ (id)errorForDisabledCloudSyncing;
+ (_Bool)isZoneConfigurations:(id)configurations subsetOfZoneConfigurations:(id)configurations;
+ (id)sharedContext;
+ (id)zoneIDsFromZoneInfos:(id)infos;
+ (id)newNotesContainer;
+ (id)errorFromErrors:(id)errors;
+ (id)objectsByAccount:(id)account;
+ (id)newNotesContainerForAccountID:(id)id;
+ (id)notesZoneID;
+ (_Bool)shouldIgnoreErrorForBackoffTimer:(id)timer;
+ (id)allZoneIDsInAccountZoneIDs:(id)ids;
+ (id)errorsFromError:(id)error;
+ (id)errorForWaitingForRetryTimer;
+ (id)objectsByDatabaseScope:(id)scope;
+ (void)registerStateHandler;
+ (id)userRecordNameForContainer:(id)container;
+ (id)zoneInfosFromZoneIDs:(id)ids;
+ (id)sortedRecords:(id)records;
+ (void)batchRecordsToSave:(id)save delete:(id)_delete maxRecordCountPerBatch:(unsigned long long)batch maxRecordSizePerBatch:(unsigned long long)batch withBlock:(id /* block */)block;
+ (id)deduplicatedRecordsForCloudObjects:(id)objects;
+ (_Bool)haveZoneIDsInAccountZoneIDs:(id)ids;
+ (id)errorCodesToIgnoreForBackoffTimer;

/* instance methods */
- (id)_objectIDsToProcessForFullSyncInContext:(id)context;
- (void)resolveObjectIDForShareRecordID:(id)id ownerRecordName:(id)name context:(id)context timeout:(double)timeout completion:(id /* block */)completion;
- (id)subscriptionForDatabase:(id)database;
- (void)_ingestCloudKitRecord:(id)record forAccountID:(id)id forceMerge:(_Bool)merge session:(id)session context:(id)context;
- (void)addDependenciesForModifyRecordsOperation:(id)operation;
- (void)fetchAssetsOnDemandIfEnabledForNoteObjectID:(id)id;
- (_Bool)isDisabled;
- (_Bool)shouldUpdateServerRecordForObject:(id)object withRecord:(id)record;
- (id)initWithDelegate:(id)delegate;
- (void)fetchRecordZoneChangesOperation:(id)operation recordWasDeletedWithRecordID:(id)id recordType:(id)type session:(id)session context:(id)context dispatchGroup:(id)group;
- (id)operationToFetchRecordZoneChangesForZoneIDs:(id)ids database:(id)database session:(id)session dispatchGroup:(id)group;
- (_Bool)hasNoteContextOptions:(unsigned long long)options;
- (void)saveServerChangeToken:(id)token forChangedZonesInDatabase:(id)database accountID:(id)id context:(id)context;
- (void)fetchRecordZoneChangesForSession:(id)session dispatchGroup:(id)group completionHandler:(id /* block */)handler;
- (id)persistentStoreCoordinator;
- (void)deleteSharesForObjects:(id)objects completionHandler:(id /* block */)handler;
- (void)fetchUserRecordWithContainer:(id)container completionHandler:(id /* block */)handler;
- (id)viewContext;
- (void)clearRetryCountForOperationType:(id)type;
- (id)serverChangeTokenForRecordZoneID:(id)id databaseScope:(long long)scope accountID:(id)id context:(id)context;
- (id)containerForAccountID:(id)id;
- (_Bool)isInForeground;
- (void)fetchRecordZoneChangesOperation:(id)operation completedFetchForZoneID:(id)id serverChangeToken:(id)token error:(id)error context:(id)context dispatchGroup:(id)group;
- (_Bool)isDisabledInternal;
- (void)startRetryTimerIfNecessaryWithError:(id)error;
- (id)allCloudObjectIDsInContext:(id)context;
- (id)existingCloudObjectForUserSpecificRecordID:(id)id createPlaceholderIfNecessary:(_Bool)necessary accountID:(id)id context:(id)context;
- (_Bool)longLivedOperationHasMissingAssetFiles:(id)files;
- (id)backgroundContext;
- (id)invernessClientForAccountID:(id)id;
- (void)deleteRecordZonesWithZoneIDs:(id)ids accountID:(id)id markZonesAsUserPurged:(_Bool)purged completionHandler:(id /* block */)handler;
- (void)fetchDatabaseChangesForDatabases:(id)databases session:(id)session completionHandler:(id /* block */)handler;
- (void)_processCloudObjects:(id)objects inSession:(id)session completionHandler:(id /* block */)handler;
- (void)syncForSession:(id)session completedWithErrors:(id)errors;
- (void)processPendingCloudObjectsInSession:(id)session withCompletionHandler:(id /* block */)handler;
- (void)updateCloudContextState;
- (_Bool)hasCompletedInitialSync;
- (void)fetchRecordZoneChangesOperation:(id)operation zoneID:(id)id accountID:(id)id changeTokenUpdated:(id)updated context:(id)context dispatchGroup:(id)group;
- (void)informCloudAnalyticsDelegateForOperationDidEnd:(id)end recordsByRecordID:(id)id operationError:(id)error;
- (id)readinessLoggingDescription;
- (void)fetchCloudObjects:(id)objects forSession:(id)session accountID:(id)id completionHandler:(id /* block */)handler;
- (_Bool)isEnqueueingLongLivedOperations;
- (void)finishOperationsForRecordID:(id)id completionHandler:(id /* block */)handler;
- (void)processAllCloudObjectsInSession:(id)session withCompletionHandler:(id /* block */)handler;
- (void)addCallbackBlocksToModifyRecordsOperation:(id)operation rootRecordIDsByShareID:(id)id session:(id)session;
- (void)deleteServerChangeTokenForRecordZoneID:(id)id databaseScope:(long long)scope accountID:(id)id context:(id)context;
- (id)operationToSaveZonesIfNecessaryForAccountID:(id)id;
- (void)setAssetDownloadStateOnObject:(id)object withRecord:(id)record managedObjectContext:(id)context;
- (void)cancelEverythingWithCompletionHandler:(id /* block */)handler;
- (void)validateAccountZoneIDsNeedingFetchChanges;
- (id)overrideAccountID;
- (void)fetchShareRecordForResolutionWithShareRecordID:(id)id ownerRecordName:(id)name accountIDs:(id)ids completion:(id /* block */)completion;
- (void)fetchRecordZoneChangesWithReason:(id)reason completionHandler:(id /* block */)handler;
- (void)addModifyRecordsOperationsWithCloudObjectsToSave:(id)save delete:(id)_delete accountID:(id)id forSession:(id)session operationGroupName:(id)name waitForDependencies:(_Bool)dependencies completionHandler:(id /* block */)handler;
- (void)syncWithReason:(id)reason uploadUnsyncedChanges:(_Bool)changes completionHandler:(id /* block */)handler;
- (void)fetchRecordZoneChangesForZoneIDs:(id)ids accountID:(id)id reason:(id)reason completionHandler:(id /* block */)handler;
- (id)operationToFetchDatabaseChangesForDatabase:(id)database session:(id)session completionHandler:(id /* block */)handler;
- (void)modifyRecordsOperation:(id)operation recordWasDeletedWithRecordID:(id)id rootRecordIDsByShareID:(id)id session:(id)session error:(id)error context:(id)context;
- (void)deleteServerChangeTokenForChangedZonesInDatabase:(id)database accountID:(id)id context:(id)context;
- (id)serverChangeTokenForChangedZonesInDatabase:(id)database accountID:(id)id context:(id)context;
- (id)operationsToModifyRecordsToSave:(id)save delete:(id)_delete forSession:(id)session rootRecordIDsByShareID:(id)id database:(id)database;
- (void)addOperationsToFetchRecordZoneChangesForAccountZoneIDs:(id)ids session:(id)session dispatchGroup:(id)group completionHandler:(id /* block */)handler;
- (void)contextDidSaveOrMerge:(id)merge;
- (double)timeIntervalToRetryAfterFromError:(id)error;
- (void)processPendingCloudObjectsWithCompletionHandler:(id /* block */)handler;
- (void)modifyRecordsOperation:(id)operation forSession:(id)session didCompleteWithError:(id)error;
- (void)modifyRecordsOperation:(id)operation recordWasDeletedWithRecordID:(id)id rootRecordIDsByShareID:(id)id session:(id)session error:(id)error;
- (void)updateAccountStatusWithCompletionHandler:(id /* block */)handler;
- (void)processAllCloudObjectsWithCompletionHandler:(id /* block */)handler;
- (void)processPendingCloudObjects;
- (void)clearSubscribedSubscriptionIDs;
- (_Bool)isFetchingEnabled;
- (void)addOperationToProcessObjectsInSession:(id)session withCompletionHandler:(id /* block */)handler;
- (void)incrementOrClearRetryCountForOperationType:(id)type error:(id)error;
- (void)fetchCloudObjects:(id)objects accountID:(id)id completionHandler:(id /* block */)handler;
- (void)clearContainers;
- (void)loadZoneFetchState;
- (void)incrementRetryCountForOperationType:(id)type;
- (id)accountIDForContainer:(id)container;
- (id)existingCloudObjectForRecordID:(id)id recordType:(id)type accountID:(id)id context:(id)context excludingRecordTypes:(id)types;
- (void)modifyRecordsOperation:(id)operation recordWasSavedWithRecordID:(id)id record:(id)record session:(id)session error:(id)error context:(id)context;
- (void)syncWithReason:(id)reason completionHandler:(id /* block */)handler;
- (id /* block */)completionEndingProcessingSession:(id)session wrappingCompletion:(id /* block */)completion;
- (void)addFetchOperationsForRecordIDs:(id)ids forSession:(id)session accountID:(id)id qualityOfService:(long long)service operationGroupName:(id)name completionHandler:(id /* block */)handler;
- (_Bool)isReadyToSync;
- (void)cloudKitAccountChanged:(id)changed;
- (void)fetchRecordZoneChangesForZoneIDs:(id)ids accountID:(id)id session:(id)session completionHandler:(id /* block */)handler;
- (id)newSessionForReason:(id)reason;
- (_Bool)shouldAlertOnQuotaExceededErrorFromTrashRecoveryWithObject:(id)object error:(id)error;
- (_Bool)partialError:(id)error containsErrorCode:(long long)code;
- (id)operationToSaveZonesForZoneIDs:(id)ids accountID:(id)id;
- (void)handleRemoteNotificationWithUserInfo:(id)info completion:(id /* block */)completion;
- (void)fetchDatabaseChangesOperation:(id)operation changeTokenUpdated:(id)updated accountID:(id)id context:(id)context;
- (void)updateCloudContextStateWithCompletion:(id /* block */)completion;
- (id)operationsToFetchRecordZoneChangesForZoneIDs:(id)ids accountID:(id)id session:(id)session dispatchGroup:(id)group;
- (void)reachabilityChanged:(id)changed;
- (void)_syncWithReason:(id)reason uploadUnsyncedChanges:(_Bool)changes completionHandler:(id /* block */)handler;
- (void)dealloc;
- (void)_processPendingCloudObjectsInSession:(id)session withCompletionHandler:(id /* block */)handler;
- (void)clearPendingActivity;
- (void)fetchUserRecordWithAccountID:(id)id completionHandler:(id /* block */)handler;
- (id)newOperationToFetchRecordZoneChangesWithZoneConfigurations:(id)configurations database:(id)database session:(id)session dispatchGroup:(id)group;
- (void)fetchRecordZoneChangesOperationDidComplete:(id)complete session:(id)session error:(id)error dispatchGroup:(id)group;
- (void)retryOperationsIfNecessary;
- (void)fetchOperation:(id)operation progressChangedWithRecordID:(id)id progress:(double)progress;
- (void)fetchRecordZoneChangesOperation:(id)operation recordWasChangedWithRecordID:(id)id record:(id)record error:(id)error session:(id)session context:(id)context dispatchGroup:(id)group;
- (void)resetZoneForCloudAccount:(id)account withReason:(id)reason;
- (void)printOperationQueue;
- (_Bool)shouldSimulateQuotaExceededOnTrashRecovery;
- (void)fetchOperation:(id)operation didCompleteWithRecordsByRecordID:(id)id session:(id)session error:(id)error;
- (_Bool)useDispatchGroupForDaemonProcessWithGroup:(id)group;
- (void)fetchDatabaseChangesOperation:(id)operation finishedWithServerChangeToken:(id)token accountID:(id)id session:(id)session error:(id)error completionHandler:(id /* block */)handler context:(id)context;
- (void)deleteSharesForObjects:(id)objects forSession:(id)session accountID:(id)id completionHandler:(id /* block */)handler;
- (void)enumerateAllCloudObjectsInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
- (void)leaveDispatchGroupIfNeededWithGroup:(id)group;
- (id)operationToModifyRecordsToSave:(id)save delete:(id)_delete forSession:(id)session rootRecordIDsByShareID:(id)id database:(id)database;
- (id)operationsToModifyRecordsForCloudObjectsToSave:(id)save delete:(id)_delete deleteShares:(id)shares saveUserSpecificRecords:(id)records forSession:(id)session operationGroupName:(id)name addDependencies:(_Bool)dependencies accountID:(id)id;
- (id)operationsToFetchRecordIDs:(id)ids forSession:(id)session shouldDownloadAssets:(_Bool)assets database:(id)database qualityOfService:(long long)service;
- (void)receivedZoneNotFound:(id)found operation:(id)operation context:(id)context;
- (_Bool)supportsDeferredAssetDownload;
- (void)saveServerChangeToken:(id)token forRecordZoneID:(id)id databaseScope:(long long)scope accountID:(id)id context:(id)context;
- (id)operationToFetchRecordIDs:(id)ids forSession:(id)session shouldDownloadAssets:(_Bool)assets database:(id)database qualityOfService:(long long)service;
- (void)fetchDatabaseChangesOperation:(id)operation recordZoneWithIDChanged:(id)idchanged accountID:(id)id session:(id)session;
- (void)fetchDatabaseChangesOperation:(id)operation recordZoneWithIDWasDeleted:(id)deleted accountID:(id)id session:(id)session;
- (void)_addModifyRecordsOperationsWithCloudObjectsToSave:(id)save delete:(id)_delete accountID:(id)id forSession:(id)session operationGroupName:(id)name waitForDependencies:(_Bool)dependencies completionHandler:(id /* block */)handler;
- (void)fetchRecordZoneChangesForAccountZoneIDs:(id)ids session:(id)session dispatchGroup:(id)group completionHandler:(id /* block */)handler;
- (void)handleCloudKitNotification:(id)notification completionHandler:(id /* block */)handler;
- (void)pauseCloudSyncWhileSynchronouslyPerformingBlock:(id /* block */)block;
- (void)updateSelectorDelayers:(id)delayers;
- (id)allCloudObjectIDsInContext:(id)context predicate:(id)predicate;
- (void)fetchRecordIDs:(id)ids forSession:(id)session accountID:(id)id operationGroupName:(id)name completionHandler:(id /* block */)handler;
- (void)fetchOperation:(id)operation recordWasFetchedWithRecordID:(id)id record:(id)record session:(id)session error:(id)error;
- (void)saveSubscriptionsForDatabase:(id)database completionHandler:(id /* block */)handler;
- (void)deleteAllServerChangeTokens;
- (void)processObjectIDs:(id)ids inSession:(id)session completionHandler:(id /* block */)handler;
- (void)enqueueLongLivedOperationsWithIDsIfNeeded:(id)needed container:(id)container completionHandler:(id /* block */)handler;
- (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
- (_Bool)isCloudKitAccountAvailable;
- (id)accountIDForDatabase:(id)database;
- (void)pushCloudObjects:(id)objects operationGroupName:(id)name completionHandler:(id /* block */)handler;
- (void)updateSubscriptionsWithCompletionHandler:(id /* block */)handler;
- (void)fetchRootRecordForResolution:(id)resolution share:(id)share accountID:(id)id database:(id)database completion:(id /* block */)completion;
- (id)operationsToFetchRecordIDs:(id)ids forSession:(id)session shouldDownloadAssets:(_Bool)assets qualityOfService:(long long)service operationGroupName:(id)name accountID:(id)id;
- (_Bool)isInternetReachable;
- (id)newPlaceholderObjectForRecordID:(id)id recordType:(id)type accountID:(id)id context:(id)context;
- (void)_filterCloudSyncingObjects:(id)objects accountID:(id)id objectsToSave:(id *)save objectsToDelete:(id *)_delete objectsToDeleteShares:(id *)shares objectsToSaveUserSpecificRecord:(id *)record;
- (void)finishOperationsForRecordID:(id)id qualityOfService:(long long)service completionHandler:(id /* block */)handler;
- (void)ingestCloudKitRecord:(id)record forAccountID:(id)id forceMerge:(_Bool)merge context:(id)context;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)addFetchOperationsForRecordIDs:(id)ids forSession:(id)session accountID:(id)id qualityOfService:(long long)service operationGroupName:(id)name shouldDownloadAssets:(_Bool)assets completionHandler:(id /* block */)handler;
- (void)didFetchShare:(id)share accountID:(id)id context:(id)context;
- (void)enterDispatchGroupIfNeededWithGroup:(id)group;
- (void)handleGenericPartialFailuresForError:(id)error operation:(id)operation;
- (void)fetchDatabaseChangesForSession:(id)session completionHandler:(id /* block */)handler;
- (_Bool)isFetchingAllRecordZones;
- (void)clearZoneFetchState;
- (void)fetchSubscriptionsForDatabase:(id)database completionHandler:(id /* block */)handler;
- (void)disableCloudSyncingIfCurrentVersionNotSupported:(id)supported;
- (void)addOperations:(id)operations;
- (void)saveZoneFetchState;
- (void)updateConfiguration:(id)configuration;
- (id)allZoneIDs;
- (void)fetchRecordIDs:(id)ids accountID:(id)id operationGroupName:(id)name completionHandler:(id /* block */)handler;
- (id)existingCloudObjectForRecordID:(id)id recordType:(id)type accountID:(id)id context:(id)context;
- (void)modifyRecordsOperation:(id)operation recordWasSavedWithRecordID:(id)id record:(id)record session:(id)session error:(id)error;
- (void)enqueueLongLivedOperationsIfNeededWithCompletionHandler:(id /* block */)handler;

@end


@interface ICCloudKitSyncer : NSObject

@property (weak, nonatomic) id <ICCloudKitSyncerDelegate> delegate;

/* instance methods */
- (void)saveUnsyncedObjects;
- (void)saveUnsyncedObjectsWithRetryCount:(unsigned long long)count completionBlock:(id /* block */)block;

@end


@interface ICCloudNotificationsController : NSObject

@property (readonly, nonatomic) PDSRegistrar *pdsClient;

/* class methods */
+ (id)sharedController;
+ (void)registerForUserNotificationsWithCompletionHandler:(id /* block */)handler;

/* instance methods */
- (void)updateSubscriptionPreferenceForMentionNotifications:(_Bool)notifications forAccount:(id)account;
- (void)batchUpdateTopicSubscriptionsAllAccountsInContext:(id)context;
- (void)batchUpdateTopicSubscriptionsForDSIDs:(id)dsids;
- (_Bool)isSubscribedToMentionNotificationsForAccount:(id)account;
- (void)removeAllPDSRegistrationsForUser:(id)user;
- (void)removeAllTopicSubscriptionsForAccount:(id)account;
- (void)sendMentionNotificationToParticipant:(id)participant inlineAttachmentRecordName:(id)name shareRecordName:(id)name shareOwnerUserId:(id)id accountId:(id)id noteRecordName:(id)name senderName:(id)name noteTitle:(id)title mentionSnippet:(id)snippet callback:(id /* block */)callback;

@end


@interface ICCloudOperationObserver : NSObject

/* instance methods */
- (id)initWithQueue:(id)queue;
- (id)init;

@end


@interface ICCloudSession : NSObject

@property (nonatomic, readonly) _Bool didPush;
@property (nonatomic) _Bool hasCompletedInitialSync;
@property (nonatomic, readonly) _Bool sessionCompletedInitialSync;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, readonly) _Bool wasCancelled;
@property (nonatomic, readonly) _Bool hasEnded;
@property (nonatomic, readonly) _Bool hasBegun;
@property (nonatomic, copy) NSUUID *identifier;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, weak) id <ICCloudSessionDelegate> delegate;

/* instance methods */
- (id)init;
- (id)initWithReason:(id)reason;
- (void)zoneWasDeleted:(id)deleted;
- (void)zoneWasChanged:(id)changed;
- (void)beginPhaseIfNeeded:(long long)needed;
- (void)beginSessionIfNeeded;
- (void)fetchedRecordWasAdded:(id)added type:(id)type;
- (void)fetchedRecordWasChanged:(id)changed type:(id)type;
- (void)fetchedRecordWasDeleted:(id)deleted type:(id)type;
- (void)operationEndedForPhase:(long long)phase metrics:(id)metrics error:(id)error;
- (void)phaseEnded:(long long)ended;
- (void)recordAdditionWasPushed:(id)pushed type:(id)type;
- (void)recordDeletionWasPushed:(id)pushed type:(id)type;
- (void)recordModificationWasPushed:(id)pushed type:(id)type;
- (void)sessionCancelled;
- (void)sessionEndedWithError:(id)error;

@end


@interface ICCloudState : NSManagedObject

@property (nonatomic) _Bool inCloud;
@property (nonatomic) long long latestVersionSyncedToCloud;
@property (nonatomic) long long currentLocalVersion;
@property (retain, nonatomic) NSDate *localVersionDate;
@property (retain, nonatomic) ICCloudSyncingObject *cloudSyncingObject;

/* instance methods */
- (_Bool)isInCloud;

@end


@interface ICCloudSyncBackgroundTask : NSObject <ICBackgroundTask>

@property (readonly, nonatomic) ICCloudContext *cloudContext;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)taskIdentifier;
+ (id)syncReason;
+ (_Bool)requiresPower;
+ (id)makeActivityScheduler;

/* instance methods */
- (void)handleTaskExpiration;
- (id)initWithCloudContext:(id)context;
- (void)runTaskWithCompletion:(id /* block */)completion;

@end


@interface ICCloudSyncingObjectActivityEvent : NSObject <ICCRCoding, ICCRDataType>

@property (readonly, nonatomic) NSData *data;
@property (readonly, nonatomic) NSData *fallbackData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)registerWithICCRCoder;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithData:(id)data fallbackData:(id)data;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICCloudThrottlingLevel : NSObject

@property (readonly, nonatomic) double batchInterval;
@property (readonly, nonatomic) double maximumBatchIntervalFactor;
@property (readonly, nonatomic) unsigned long long numberOfBatches;

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)init;
- (id)initWithBatchInterval:(double)interval maximumBatchIntervalFactor:(double)factor numberOfBatches:(unsigned long long)batches;

@end


@interface ICCloudThrottlingPolicy : NSObject

@property (nonatomic) unsigned long long currentBatchCount;
@property (retain, nonatomic) NSArray *throttlingLevels;
@property (nonatomic) unsigned long long currentLevelIndex;
@property (readonly, nonatomic) ICCloudThrottlingLevel *currentLevel;
@property double resetInterval;
@property (retain) NSDate *policyStartDate;
@property (retain) NSTimer *policyResetTimer;
@property (readonly, nonatomic) double batchInterval;
@property (readonly, nonatomic) double maximumBatchIntervalFactor;

/* class methods */
+ (void)resetSavedPolicyState;

/* instance methods */
- (void)resetPolicy;
- (void)startPolicyResetTimer;
- (void)savePolicyState;
- (id)init;
- (void)dealloc;
- (void)loadSavedPolicyState;
- (void)changeLevelIfNecessary;
- (void)incrementBatchCount;
- (id)initWithThrottlingLevels:(id)levels resetInterval:(double)interval;

@end


@interface ICCompatibilityController : NSObject

@property (readonly, nonatomic) NSObject *queue;
@property (readonly, copy, nonatomic) NSArray *fakeDevices;
@property (retain, nonatomic) NSManagedObjectContext *workerContext;
@property (nonatomic) _Bool fakesIncompatibleDevicesForDebugging;

/* class methods */
+ (id)sharedController;

/* instance methods */
- (id)init;
- (void)cacheDevices:(id)devices forAccount:(id)account;
- (id)cachedDevicesDateForAccount:(id)account;
- (id)cachedDevicesForAccount:(id)account;
- (void)clearCachedDevicesForAccount:(id)account;
- (void)devicesForAccount:(id)account completionHandler:(id /* block */)handler;
- (id)fetchDevicesForAccount:(id)account;
- (void)messageForAccount:(id)account minimumNotesVersion:(long long)version completionHandler:(id /* block */)handler;

@end


@interface ICCompatibilityControllerDevice : NSObject <NSSecureCoding>

@property (nonatomic) long long notesVersion;
@property (nonatomic) long long maximumNotesVersion;
@property (copy, nonatomic) NSString *name;
@property (readonly, nonatomic) _Bool upgraded;
@property (readonly, nonatomic) _Bool upgradable;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (long long)maximumNotesVersionForHardwareInfo:(struct ICDeviceHardwareInfo)info;
+ (long long)notesVersionForDeviceInfo:(id)info;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (_Bool)isUpgraded;
- (id)initWithMigrationDeviceInfo:(id)info;
- (id)initWithNotesVersion:(long long)version maximumNotesVersion:(long long)version name:(id)name;
- (_Bool)isUpgradable;

@end


@interface ICCriticalActivityPerformer : NSObject

/* class methods */
+ (void)sharedPerformCriticalBackgroundActivityWithReason:(id)reason block:(id /* block */)block;

@end


@interface ICCrossAppHashtagManager : NSObject

/* class methods */
+ (id)bundleIDsForHashtagSupportingAppsOtherThanNotes;
+ (id)hashtagDisplayTextsFromOtherApps;
+ (void)prefetchHashtagDisplayTextsFromOtherApps;
+ (void)updateUserDefaultsCacheIfNecessaryWithNewlyFetchedHastags:(id)hastags;

@end


@interface ICCryptoConvergenceController : NSObject

@property (retain) NSProgress *progress;
@property (readonly, nonatomic) NSManagedObjectContext *workerContext;

/* class methods */
+ (void)setSharedController:(id)controller;
+ (id)sharedController;

/* instance methods */
- (void)authenticationStateDidDeauthenticate:(id)deauthenticate;
- (void)cancelAndWaitWithReason:(id)reason;
- (_Bool)convergeAttachmentsInNoteWithID:(id)id configuration:(id)configuration;
- (_Bool)convergeNotesInAccountWithID:(id)id configuration:(id)configuration progress:(id)progress;
- (id)initWithWorkerContext:(id)context;
- (_Bool)unsafelyConvergeAttachment:(id)attachment configuration:(id)configuration;
- (_Bool)unsafelyConvergeAttachmentsInNote:(id)note configuration:(id)configuration;
- (_Bool)unsafelyConvergeNote:(id)note configuration:(id)configuration;
- (_Bool)unsafelyConvergeNotesInAccount:(id)account configuration:(id)configuration;

@end


@interface ICCryptoConvergenceControllerConfiguration : NSObject <NSCopying>

@property (copy, nonatomic) NSString *passphrase;
@property (copy, nonatomic) ICEncryptionKey *v1MainKey;
@property (copy, nonatomic) ICEncryptionKey *v1NeoMainKey;
@property (copy, nonatomic) NSString *divergedPassphrase;
@property (copy, nonatomic) ICEncryptionKey *divergedV1MainKey;
@property (copy, nonatomic) ICEncryptionKey *divergedV1NeoMainKey;
@property (nonatomic) _Bool includeAllAuthenticatedObjects;
@property (nonatomic) _Bool userInitiated;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)isUserInitiated;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)shouldConvergeObject:(id)object;

@end


@interface ICCryptoStrategyFactory : NSObject

/* class methods */
+ (long long)cipherVersionForObject:(id)object;
+ (long long)cipherVersionForPrimaryEncryptedData:(id)data;
+ (id)makeCryptoStrategyForObject:(id)object andValidateProtocolConformance:(id)conformance;
+ (id)makeCryptoStrategyForObject:(id)object withCipherMatchingEncryptedData:(id)data andValidateProtocolConformance:(id)conformance;
+ (id)primaryEncryptedDataForObject:(id)object;
+ (_Bool)shouldAuthenticateWithCustomPasswordForObject:(id)object;
+ (_Bool)shouldAuthenticateWithDevicePasswordForObject:(id)object;
+ (id)strategyForObject:(id)object cipherVersion:(long long)version;
+ (id)unitTest_strategyForObject:(id)object cipherVersion:(long long)version;
+ (long long)userSelectedCipherVersionForObject:(id)object;

@end


@interface ICDataCryptor : NSObject <NSSecureCoding>

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSString *objectIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)encryptData:(id)data;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)decryptData:(id)data;
- (id)initWithObjectIdentifier:(id)identifier;
- (id)initWithObjectIdentifier:(id)identifier context:(id)context;

@end


@interface ICDataPersister : NSObject <ICDataPersister, NSSecureCoding>

@property (readonly, nonatomic) ICDataCryptor *dataCryptor;
@property (readonly, nonatomic) NSURL *cacheDirectoryURL;
@property (readonly, nonatomic) NSString *objectIdentifier;
@property (readonly, nonatomic) NSMutableArray *allURLs;
@property (readonly, nonatomic) NSMutableDictionary *identifierToDataDictionary;
@property (nonatomic) unsigned long long accumulatedDataSize;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (void)deletePasteboardDataFiles;
+ (id)rootCacheDirectoryPathForPasteboard:(_Bool)pasteboard;

/* instance methods */
- (id)description;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (void)deleteDataFiles;
- (_Bool)verifyDataFiles;
- (void)createDataCryptorIfNecessary;
- (id)initWithObjectIdentifier:(id)identifier forPasteboard:(_Bool)pasteboard;
- (id)loadDataForIdentifier:(id)identifier;
- (_Bool)makeSureCacheDirectoryExists;
- (_Bool)saveData:(id)data identifier:(id)identifier;

@end


@interface ICDatabaseStateHandler : NSObject <ICStateHandlerProvider>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)registerStateHandler;
+ (id)stateDictionary;
+ (void)addLoggable:(id)loggable toDictionary:(id)dictionary;
+ (id)miscState;
+ (id)modernDatabaseState;
+ (id)stateDictionaryFromLoggables:(id)loggables;

@end


@interface ICDateFilterTypeSelection : ICFilterTypeSelection <NSCopying>

@property (nonatomic) unsigned long long selectionType;
@property (retain, nonatomic) NSDate *primaryDate;
@property (retain, nonatomic) NSDate *secondaryDate;
@property (retain, nonatomic) NSNumber *relativeRangeAmount;
@property (nonatomic) unsigned long long relativeRangeSelectionType;
@property (readonly, nonatomic) double relativeRangeTimeInterval;
@property (readonly, nonatomic) NSString *primaryDateSummary;
@property (readonly, nonatomic) NSString *secondaryDateSummary;
@property (readonly, nonatomic) NSString *relativeRangeDateSummary;
@property (readonly, nonatomic) NSString *relativeRangeLabel;
@property (readonly, nonatomic) NSString *relativeRangeAmountAndTimeInterval;
@property (readonly, nonatomic) NSDictionary *relativeRangeTimeIntervalOptions;

/* class methods */
+ (id)keyPathsForValuesAffectingIsEmpty;
+ (id)keyPathsForValuesAffectingIsValid;
+ (id)relativeRangeStringComponentsForSelectionType:(unsigned long long)type number:(id)number;
+ (id)relativeRangeSummaryForSelectionType:(unsigned long long)type amount:(unsigned long long)amount;
+ (id)relativeRangeSummaryForSelectionType:(unsigned long long)type number:(id)number;
+ (id)shortDateFormatter;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)debugDescription;
- (_Bool)isEmpty;
- (_Bool)isValid;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)relativeRangeTimeIntervalString;
- (id)initWithSelectionType:(unsigned long long)type;
- (_Bool)isEqualToDateFilterSelection:(id)selection;
- (id)rawFilterValue;
- (id)relativeDateSummary;
- (id)relativeRangeAmountString;
- (void)setSpecificDateRangeFrom:(id)from to:(id)to;
- (void)updateDatesForCurrentSelectionType;

@end


@interface ICDateCreatedFilterTypeSelection : ICDateFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)shortEmptySummary;

@end


@interface ICDateEditedFilterTypeSelection : ICDateFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)shortEmptySummary;

@end


@interface ICDefaultAccountUtilities : NSObject

/* class methods */
+ (id)defaultAccountWithHTMLNoteContext:(id)context;
+ (void)setDefaultAccountIdentifier:(id)identifier;
+ (id)defaultAccount;
+ (id)accountToAddSmartFolderWithModernContext:(id)context;
+ (void)_setDefaultAccountIdentifierForTests:(id)tests;
+ (id)accountToAddNewNoteWithTagSelection:(id)selection modernContext:(id)context;
+ (id)_defaultAccountIdentifierForTests;
+ (id)defaultFolderWithHTMLNoteContext:(id)context;

@end


@interface ICDeviceListRequest : NSObject

@property (retain, nonatomic) ACAccount *account;
@property (retain) NSArray *devices;
@property (retain) NSObject *workSemaphore;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *model;
@property (copy, nonatomic) NSString *modelDisplayName;
@property (copy, nonatomic) NSString *softwareVersion;
@property _Bool didGetICloudDeviceList;

/* class methods */
+ (id)combineICloudDevices:(id)devices withCloudKitDevices:(id)devices;
+ (id)filteredDevices:(id)devices;
+ (id)setOfDeviceNamesFromDevices:(id)devices;

/* instance methods */
- (id)initWithAccount:(id)account;
- (id)init;
- (void)fetchCloudKitDevicesWithCompletionBlock:(id /* block */)block;
- (void)fetchICloudDevicesWithCompletionBlock:(id /* block */)block;
- (_Bool)anyDeviceNeedsUpgrade;
- (_Bool)anyDeviceNotUpgradable;
- (_Bool)anyOSXDeviceNotUpgraded;
- (void)fetchWithCompletionBlock:(id /* block */)block;
- (_Bool)waitForFetchWithTimeout:(double)timeout;

@end


@interface ICDeviceManagementRestrictionsManager : NSObject

@property (nonatomic, readonly) NSString *calculatorDomainID;
@property (nonatomic, readonly) _Bool isMathPaperSolvingAllowed;
@property (nonatomic) _Bool _isMathPaperSolvingAllowed;
@property (nonatomic, readonly) _Bool isKeyboardMathSolvingAllowed;
@property (nonatomic) _Bool _isKeyboardMathSolvingAllowed;
@property (nonatomic, readonly) _Bool isCalculatorModeScientificAllowed;
@property (nonatomic) _Bool _isCalculatorModeScientificAllowed;

/* class methods */
+ (id)sharedManager;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)updateRestrictions;
- (void)registerObserver;
- (void)profilePreferencesDidChangeWithNotification:(id)notification;

@end


@interface ICDeviceMigrationState : ICCloudSyncingObject

@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) NSString *deviceIdentifier;
@property (nonatomic) short state;
@property (retain, nonatomic) NSDate *stateModificationDate;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)allDeviceMigrationStatesInContext:(id)context;
+ (id)currentDeviceMigrationStateForAccount:(id)account;
+ (id)currentDeviceMigrationStateForAccount:(id)account createIfNecessary:(_Bool)necessary;
+ (id)deviceMigrationStateWithDeviceIdentifier:(id)identifier account:(id)account;
+ (id)deviceMigrationStateWithDeviceIdentifier:(id)identifier context:(id)context;
+ (id)deviceMigrationStatesByAccountIDInContext:(id)context;
+ (id)deviceMigrationStatesMatchingPredicate:(id)predicate context:(id)context;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)identifierForDeviceIdentifier:(id)identifier;
+ (id)newDeviceMigrationStateWithDeviceIdentifier:(id)identifier account:(id)account;
+ (id)stringFromMigrationState:(short)state;

/* instance methods */
- (id)recordType;
- (_Bool)isMigrating;
- (id)cloudAccount;
- (id)recordName;
- (id)recordZoneName;
- (void)deleteFromLocalDatabase;
- (id)ic_loggingValues;
- (_Bool)isInICloudAccount;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (void)objectWasDeletedFromCloud;
- (void)objectWasDeletedFromCloudByAnotherDevice;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;

@end


@interface ICDimensionMaxCache : NSObject

@property (readonly, nonatomic) NSMutableDictionary *dimensions;
@property (readonly, nonatomic) NSMutableArray *sortedDimensions;
@property (readonly, nonatomic) id /* block */ comparator;
@property (readonly, nonatomic) double max;
@property (readonly, nonatomic) unsigned long long count;

/* instance methods */
- (id)initWithComparator:(id /* block */)comparator;
- (id)init;
- (double)dimensionForKey:(id)key;
- (void)removeDimensionForKey:(id)key;
- (void)setDimension:(double)dimension forKey:(id)key;

@end


@interface ICDimensionSumCache : NSObject

@property (nonatomic) double sum;
@property (readonly, nonatomic) NSMutableDictionary *dimensions;
@property (readonly, nonatomic) unsigned long long count;
@property (readonly, nonatomic) double estimateDimension;

/* instance methods */
- (id)init;
- (double)dimensionForKey:(id)key;
- (id)initWithKeys:(id)keys andEstimateDimension:(double)dimension;
- (void)removeDimensionForKey:(id)key;
- (void)setDimension:(double)dimension forKey:(id)key;

@end


@interface ICDividerLineTextAttachment : NSTextAttachment <ICTTAttachment>

@property (readonly, nonatomic) double height;
@property (copy, nonatomic) NSString *inlineAttachmentIdentifier;
@property (readonly, copy, nonatomic) NSString *attachmentIdentifier;
@property (readonly, copy, nonatomic) NSString *attachmentUTI;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)attributedStringWithBlockQuoteLevel:(long long)level inlineAttachmentIdentifier:(id)identifier;
+ (id)attributedStringWithBlockQuoteLevel:(long long)level;

/* instance methods */
- (struct CGRect)attachmentBoundsForTextContainer:(id)container proposedLineFragment:(struct CGRect)fragment glyphPosition:(struct CGPoint)position characterIndex:(unsigned long long)index;
- (id)image;
- (id)init;
- (_Bool)isEqualToModelComparable:(id)comparable;
- (id)attachmentInContext:(id)context;
- (id)inlineAttachmentInContext:(id)context;

@end


@interface ICDrawing : NSObject <NSCopying>

@property (retain, nonatomic) ICTTVectorMultiTimestamp *timestamp;
@property (retain, nonatomic) NSDate *orientationTimestamp;
@property (readonly, nonatomic) NSUUID *replicaUUID;
@property (readonly, nonatomic) NSOrderedSet *commands;
@property (readonly, nonatomic) NSOrderedSet *visibleCommands;
@property (nonatomic) long long orientation;
@property (nonatomic) struct CGSize unrotatedSize;
@property (readonly, nonatomic) _Bool canChangeTransientOrientation;
@property (readonly, nonatomic) struct CGRect bounds;
@property (nonatomic) struct CGRect unrotatedBoundsInCommandSpace;
@property (readonly, nonatomic) struct CGRect fullBounds;

/* class methods */
+ (struct CGSize)defaultSize;
+ (struct CGSize)defaultPixelSize;
+ (struct CGAffineTransform)defaultSizeOrientationTransform:(long long)transform;
+ (struct CGSize)fullSize:(struct CGSize)size forOrientation:(long long)orientation;
+ (struct CGAffineTransform)orientationTransform:(long long)transform size:(struct CGSize)size;
+ (void)sortCommands:(id)commands;

/* instance methods */
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithReplicaID:(id)id;
- (struct CGAffineTransform)orientationTransform;
- (id)initWithDrawing:(id)drawing;
- (unsigned long long)mergeWithDrawing:(id)drawing;
- (unsigned int)saveToArchive:(void *)archive withPathData:(_Bool)data;
- (struct CGSize)fullSize;
- (id)initWithData:(id)data version:(unsigned int)version replicaID:(id)id;
- (id)mutableCommands;
- (void)addNewCommand:(id)command;
- (struct CGRect)calculateCommandBounds;
- (struct CGRect)commandBounds;
- (struct ICDrawingCommandID)commandIDForNewCommand;
- (id)initWithArchive:(const void *)archive version:(unsigned int)version replicaID:(id)id;
- (id)initWithCommands:(id)commands fromDrawing:(id)drawing;
- (id)initWithData:(id)data replicaID:(id)id;
- (id)insertNewTestCommand;
- (void)invalidateBounds;
- (id)serializeWithPathData:(_Bool)data;
- (id)serializeWithPathData:(_Bool)data toVersion:(unsigned int *)version;
- (id)setCommand:(id)command hidden:(_Bool)hidden;
- (void)setCommandIDForInsertion:(id)insertion;
- (_Bool)setTransientOrientation:(long long)orientation;
- (void)sortCommands;
- (void)takeOrientationFrom:(id)from;
- (id)visibleCommandForInsertingCommand:(id)command;

@end


@interface ICDrawingCommand : NSObject

@property (readonly, nonatomic) ICDrawingCommandData *data;
@property (readonly, nonatomic) _Bool hidden;
@property (readonly, nonatomic) struct TopoID timestamp;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (unsigned long long)hash;
- (id)initWithArchive:(const void *)archive version:(unsigned int)version sortedUUIDs:(id)uuids;
- (id)initWithCommand:(id)command hidden:(_Bool)hidden timestamp:(struct TopoID)timestamp;
- (_Bool)isEqualDrawingCommand:(id)command;
- (unsigned int)saveToArchive:(void *)archive sortedUUIDs:(id)uuids withPathData:(_Bool)data;

@end


@interface ICDrawingCommandData : NSObject

@property (nonatomic) unsigned int type;
@property (nonatomic) CGColorRef color;
@property (nonatomic) struct { struct CGPoint x0; double x1; double x2; double x3; double x4; double x5; double x6; } baseValues;
@property (nonatomic) struct { double x0; double x1; double x2; } parameters;
@property (readonly, nonatomic) unsigned int randomSeed;
@property _Bool isClipped;
@property (nonatomic) struct CGPoint clipOrigin;
@property (nonatomic) struct CGPoint clipNormal;
@property (readonly, nonatomic) struct CGRect bounds;
@property (nonatomic) struct ICDrawingCommandID commandID;
@property (readonly, nonatomic) void * points;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (void)dealloc;
- (unsigned long long)hash;
- (struct { struct CGPoint x0; double x1; double x2; double x3; double x4; double x5; double x6; })readPointFromArchive:(const void *)archive deltaFrom:(const struct { struct CGPoint x0; double x1; double x2; double x3; double x4; double x5; double x6; } *)from;
- (id)initWithArchive:(const void *)archive version:(unsigned int)version sortedUUIDs:(id)uuids;
- (void)invalidateBounds;
- (_Bool)isEqualDrawingCommandData:(id)data;
- (double)renderCost;
- (unsigned int)savePoint:(const struct { struct CGPoint x0; double x1; double x2; double x3; double x4; double x5; double x6; } *)point deltaFrom:(const struct { struct CGPoint x0; double x1; double x2; double x3; double x4; double x5; double x6; } *)from toArchive:(void *)archive;
- (unsigned int)saveToArchive:(void *)archive sortedUUIDs:(id)uuids withPathData:(_Bool)data isHidden:(_Bool)hidden;
- (struct { double x0; double x1; double x2; })version1Parameters;

@end


@interface ICTTVersionedDocument : NSObject

@property (nonatomic) void * documentArchive;
@property (readonly, nonatomic) NSUUID *replicaID;
@property (readonly, nonatomic) unsigned long long futureVersionCount;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;
+ (unsigned int)versionedDocumentSerializationVersion;

/* instance methods */
- (id)serialize;
- (void)dealloc;
- (void)loadArchive:(const void *)archive;
- (void)loadData:(id)data;
- (void)loadDocumentArchive:(void *)archive;
- (unsigned int)maxDocumentVersion;
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (unsigned long long)mergeWithVersionedDocument:(id)document;
- (void)saveCurrentVersion:(void *)version;
- (void)saveToArchive:(void *)archive;
- (id)serializeCurrentVersion:(unsigned int *)version;
- (id)initWithArchive:(const void *)archive replicaID:(id)id;
- (id)initWithData:(id)data replicaID:(id)id;

@end


@interface ICDrawingVersionedDocument : ICTTVersionedDocument

@property (readonly, nonatomic) ICDrawing *drawing;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;

/* instance methods */
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (id)serializeCurrentVersion:(unsigned int *)version;
- (unsigned long long)mergeWithDrawingVersionedDocument:(id)document;

@end


@interface ICEncryptedData : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSData *data;
@property (readonly, copy, nonatomic) NSData *tag;
@property (readonly, copy, nonatomic) NSData *initializationVector;
@property (readonly, copy, nonatomic) NSData *fallbackTag;
@property (readonly, copy, nonatomic) NSData *fallbackInitializationVector;
@property (readonly, nonatomic) _Bool valid;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)isValid;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithData:(id)data tag:(id)tag initializationVector:(id)vector;
- (id)initWithData:(id)data tag:(id)tag initializationVector:(id)vector fallbackTag:(id)tag fallbackInitializationVector:(id)vector;

@end


@interface ICEncryptionKey : NSObject <NSCopying>

@property (readonly, nonatomic) NSData *keyData;
@property (readonly, nonatomic) ICEncryptionMetadata *metadata;
@property (readonly, nonatomic) NSData *serializedData;

/* instance methods */
- (_Bool)validate;
- (_Bool)isEqual:(id)equal;
- (id)description;
- (_Bool)serialize;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)deserializeWithData:(id)data;
- (id)initWithSerializedData:(id)data;
- (id)initWithKeyData:(id)data metadata:(id)metadata;

@end


@interface ICEncryptionMetadata : NSObject <NSCopying>

@property (readonly, nonatomic) long long cipherVersion;
@property (readonly, nonatomic) NSString *objectIdentifier;
@property (readonly, nonatomic) NSData *passphraseSalt;
@property (readonly, nonatomic) unsigned long long passphraseIterationCount;
@property (readonly, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) NSString *accountKeyIdentifier;
@property (readonly, nonatomic) NSData *serializedData;
@property (readonly, nonatomic) NSData *authenticatedData;

/* class methods */
+ (id)makeForV1CipherWithObjectIdentifier:(id)identifier salt:(id)salt iterationCount:(unsigned long long)count hint:(id)hint;
+ (id)makeForV1NeoCipherWithObjectIdentifier:(id)identifier salt:(id)salt iterationCount:(unsigned long long)count hint:(id)hint;
+ (id)makeForV1NeoSidecarCipherWithObjectIdentifier:(id)identifier;
+ (id)makeForV2CipherWithObjectIdentifier:(id)identifier accountKeyIdentifier:(id)identifier;
+ (id)makeFromMetadata:(id)metadata forObjectIdentifier:(id)identifier;

/* instance methods */
- (_Bool)validate;
- (_Bool)isEqual:(id)equal;
- (id)description;
- (_Bool)serialize;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)deserializeWithData:(id)data authenticatedData:(id)data;
- (id)initWithCipherVersion:(long long)version objectIdentifier:(id)identifier passphraseSalt:(id)salt passphraseIterationCount:(unsigned long long)count passphraseHint:(id)hint accountKeyIdentifier:(id)identifier;
- (id)initWithSerializedData:(id)data authenticatedData:(id)data;

@end


@interface ICEncryptionObject : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) ICEncryptionMetadata *metadata;
@property (readonly, nonatomic) NSData *wrappedEncryptionKey;
@property (readonly, nonatomic) NSData *encryptedData;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)validate;
- (_Bool)isEqual:(id)equal;
- (id)serialized;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithSerializedData:(id)data;
- (id)initWithMetadata:(id)metadata wrappedEncryptionKey:(id)key encryptedData:(id)data;

@end


@interface ICEvernoteContentParser : NSObject <NSXMLParserDelegate>

@property (nonatomic) _Bool shouldAppendCharactersToBuffer;
@property (retain, nonatomic) NSMutableString *bufferString;
@property (retain, nonatomic) NSMutableString *htmlString;
@property (retain, nonatomic) NSXMLParser *parser;
@property (nonatomic) unsigned long long parserType;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)parser:(id)parser didStartElement:(id)element namespaceURI:(id)uri qualifiedName:(id)name attributes:(id)attributes;
- (void)parser:(id)parser foundCharacters:(id)characters;
- (void)parser:(id)parser didEndElement:(id)element namespaceURI:(id)uri qualifiedName:(id)name;
- (id)htmlStringFromEvernoteContentString:(id)string;
- (void)parseContentString:(id)string;
- (_Bool)shouldSelfCloseTagForStartElementName:(id)name;
- (id)stringFromAttributes:(id)attributes;
- (void)teardownParser;
- (id)titleFromHTMLString:(id)htmlstring;

@end


@interface ICEvernoteNote : NSObject <NSSecureCoding>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSDate *created;
@property (copy, nonatomic) NSDate *updated;
@property (copy, nonatomic) NSArray *tags;
@property (copy, nonatomic) NSArray *resources;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface ICEvernoteNoteParser : NSObject <NSXMLParserDelegate>

@property (nonatomic) _Bool shouldCountOnly;
@property (nonatomic) _Bool shouldIgnoreCurrentNote;
@property (nonatomic) unsigned long long noteCount;
@property (retain, nonatomic) NSObject *parseQueue;
@property (retain, nonatomic) NSObject *parseSemaphore;
@property (retain, nonatomic) NSError *parseError;
@property (retain, nonatomic) NSMutableString *bufferString;
@property (nonatomic) long long contentLevel;
@property (retain, nonatomic) NSMutableString *contentString;
@property (retain, nonatomic) NSMutableArray *notes;
@property (retain, nonatomic) ICEvernoteNote *currentNote;
@property (retain, nonatomic) ICEvernoteResource *currentResource;
@property (readonly, nonatomic) NSURL *importDirectory;
@property (retain, nonatomic) NSURL *currentImportDirectory;
@property (retain, nonatomic) NSMutableDictionary *currentImportItem;
@property (retain, nonatomic) NSMutableArray *importItems;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)parser:(id)parser didStartElement:(id)element namespaceURI:(id)uri qualifiedName:(id)name attributes:(id)attributes;
- (void)parser:(id)parser parseErrorOccurred:(id)occurred;
- (id)init;
- (void)parser:(id)parser foundCharacters:(id)characters;
- (void)parserDidEndDocument:(id)document;
- (void)parser:(id)parser didEndElement:(id)element namespaceURI:(id)uri qualifiedName:(id)name;
- (void)archiveEvernoteNote:(id)note;
- (void)archiveEvernoteResource:(id)resource;
- (id)archiveItemsFromFileURL:(id)url error:(id *)error;
- (void)cleanupArchiveId:(id)id;
- (unsigned long long)countEvernoteNotesFromFileURL:(id)url;
- (id)dateFromDateString:(id)string;
- (id)importDirectoryURLWithImportIdentifier:(id)identifier;
- (void)parseFileAtFileURL:(id)url shouldCountOnly:(_Bool)only;
- (id)unarchiveEvernoteNoteFromArchiveId:(id)id noteArchiveId:(id)id;
- (id)unarchiveEvernoteResourceFromArchiveId:(id)id resourceArchiveId:(id)id;

@end


@interface ICEvernoteResource : NSObject <NSSecureCoding>

@property (nonatomic) _Bool isAttachment;
@property (copy, nonatomic) NSString *mime;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSData *data;
@property (copy, nonatomic) NSString *md5Hash;
@property (nonatomic) double imageWidth;
@property (nonatomic) double imageHeight;
@property (nonatomic) double duration;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface ICFallbackSystemTextAttachment : NSTextAttachment

@property (readonly, copy, nonatomic) NSString *contentIdentifier;
@property (readonly, copy, nonatomic) NSString *systemClassName;

/* instance methods */
- (id)attachmentCell;
- (id)initWithData:(id)data type:(id)type contentIdentifier:(id)identifier systemClassName:(id)name;

@end


@interface ICFileUtilities : NSObject

/* class methods */
+ (id)coordinateDeleteItemAt:(id)at;
+ (id)coordinateDeleteItemAt:(id)at coordinator:(id)coordinator;
+ (id)coordinateMoveItemAt:(id)at to:(id)to;
+ (id)coordinateMoveItemAt:(id)at to:(id)to coordinator:(id)coordinator;

@end


@interface ICFilterSelection : NSObject <NSCopying>

@property (readonly, nonatomic) NSArray *emptyFilterTypeSelections;
@property (readonly, nonatomic) NSArray *invalidFilterTypeSelectionCombinations;
@property (readonly, nonatomic) NSArray *incompatibleLockedNotesFilterTypeSelections;
@property (nonatomic) unsigned long long joinOperator;
@property (retain, nonatomic) NSArray *filterTypeSelections;
@property (nonatomic) _Bool includeRecentlyDeleted;
@property (readonly, nonatomic) _Bool isEmpty;
@property (readonly, nonatomic) _Bool hasEmptySelection;
@property (readonly, nonatomic) NSString *emptySummaryTitle;
@property (readonly, nonatomic) NSString *emptySummary;
@property (readonly, nonatomic) _Bool isValid;
@property (readonly, nonatomic) NSString *invalidSummaryTitle;
@property (readonly, nonatomic) NSString *invalidSummary;
@property (readonly, copy, nonatomic) NSString *primaryDateSummary;
@property (readonly, copy, nonatomic) NSString *secondaryDateSummary;
@property (readonly, copy, nonatomic) NSString *summaryWithJoinOperatorMenu;

/* class methods */
+ (id)cloudSpecificFilterTypes;
+ (id)keyPathsForValuesAffectingHasEmptySelection;
+ (id)keyPathsForValuesAffectingIsEmpty;
+ (id)keyPathsForValuesAffectingIsValid;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)filterTypeSelectionForFilterType:(long long)type;
- (id)initWithFilterTypeSelection:(id)selection;
- (id)initWithFilterTypeSelections:(id)selections joinOperator:(unsigned long long)_operator;
- (_Bool)isEqualToICFilterSelection:(id)selection;
- (void)setSelection:(id)selection forFilterType:(long long)type;

@end


@interface ICFolder : ICNoteContainer <ICSearchIndexable, ICCloudObject, ICFolderObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) NSArray *visibleNotesInFolder;
@property (readonly, nonatomic) NSArray *foldersInFolder;
@property (retain, nonatomic) ICQuery *smartFolderQuery;
@property (readonly, copy, nonatomic) NSString *smartFolderDescription;
@property (readonly, copy, nonatomic) NSString *smartFolderShortDescription;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (nonatomic, retain) ICQueryObjC *smartFolderQueryObjC;
@property (nonatomic, readonly) NSString *smartFolderDescriptionObjC;
@property (nonatomic, readonly) NSString *smartFolderShortDescriptionObjC;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSDate *dateForLastTitleModification;
@property (retain, nonatomic) NSSet *notes;
@property (retain, nonatomic) ICFolder *parent;
@property (retain, nonatomic) NSSet *children;
@property (retain, nonatomic) NSDate *parentModificationDate;
@property (retain, nonatomic) ICAccount *account;
@property (readonly, nonatomic) _Bool isDefaultFolderForAccount;
@property (nonatomic) _Bool importedFromLegacy;
@property (nonatomic) short folderType;
@property (retain, nonatomic) NSData *mergeableData;
@property (retain, nonatomic) NSNumber *customNoteSortTypeValue;
@property (retain, nonatomic) NSDate *customNoteSortTypeModificationDate;
@property (readonly, nonatomic) NSArray *ancestorFolderObjectIDs;
@property (copy, nonatomic) NSString *smartFolderQueryJSON;
@property (readonly, copy, nonatomic) NSString *identifierURIPathComponent;
@property (readonly, copy, nonatomic) NSString *localizedTitle;
@property (readonly, copy, nonatomic) NSManagedObject<ICFolderObject> *parentFolder;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)shareType;
+ (void)deleteFolder:(id)folder;
+ (id)keyPathsForValuesAffectingDepth;
+ (id)allFoldersInContext:(id)context;
+ (id)ancestorFolderPredicatesWithBlock:(id /* block */)block;
+ (id)contentInfoTextWithNoteCount:(long long)count subfolderCount:(long long)count;
+ (unsigned long long)countOfFoldersMatchingPredicate:(id)predicate context:(id)context;
+ (id)deduplicatingTitle:(id)title account:(id)account;
+ (id)deduplicatingTitle:(id)title forFolder:(id)folder forNewFolderParent:(id)parent ofAccount:(id)account;
+ (id)deduplicatingTitle:(id)title forFolder:(id)folder ofAccount:(id)account;
+ (id)defaultFolderInContext:(id)context;
+ (id)defaultSmartFolderTitleWithComponents:(id)components;
+ (id)englishTitleForDefaultFolder;
+ (id)englishTitleForRecoveredItemsFolder;
+ (id)englishTitleForSystemPaperFolder;
+ (id)englishTitleForTrashFolder;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (unsigned long long)folderDepthLimit;
+ (id)folderWithIdentifier:(id)identifier context:(id)context;
+ (id)foldersMatchingPredicate:(id)predicate context:(id)context;
+ (_Bool)isTitleValid:(id)valid account:(id)account folder:(id)folder parentFolder:(id)folder error:(out id *)error;
+ (_Bool)isTitleValid:(id)valid account:(id)account parentFolder:(id)folder error:(out id *)error;
+ (id)keyPathsForValuesAffectingCanBeSharedViaICloud;
+ (id)keyPathsForValuesAffectingCustomNoteSortType;
+ (id)keyPathsForValuesAffectingIsDefaultFolderForAccount;
+ (id)keyPathsForValuesAffectingIsLeaf;
+ (id)keyPathsForValuesAffectingIsTrashFolder;
+ (id)keyPathsForValuesAffectingSupportsCustomNoteSortType;
+ (id)keyPathsForValuesAffectingSupportsEditingNotes;
+ (id)keyPathsForValuesAffectingTitleForTableViewCell;
+ (id)keyPathsForValuesAffectingVisibleNoteContainerChildren;
+ (id)keyPathsForValuesAffectingVisibleNotesCount;
+ (id)localizedNewFolderName;
+ (id)localizedTitleForDefaultFolder;
+ (id)localizedTitleForRecoveredItemsFolder;
+ (id)localizedTitleForSystemPaperFolder;
+ (id)localizedTitleForTrashFolder;
+ (unsigned long long)maximumDepthOfFolders:(id)folders;
+ (unsigned long long)maximumDistanceToLeafFolderOfFolders:(id)folders;
+ (id)newFolderInAccount:(id)account;
+ (id)newFolderInParentFolder:(id)folder;
+ (id)newFolderWithIdentifier:(id)identifier account:(id)account;
+ (id)newFolderWithIdentifier:(id)identifier account:(id)account query:(id)query;
+ (id)newFolderWithIdentifier:(id)identifier parentFolder:(id)folder;
+ (id)newPlaceholderObjectForRecordName:(id)name accountID:(id)id context:(id)context;
+ (id)objc_defaultSmartFolderTitleWithComponents:(id)components;
+ (id)objc_smartFolderWithQuery:(id)query account:(id)account;
+ (id)objc_smartFolderWithQuery:(id)query titleComponents:(id)components account:(id)account;
+ (id)predicateForDeprecatedObjects;
+ (id)predicateForFoldersInFolder:(id)folder;
+ (id)predicateForNotesInFolder:(id)folder;
+ (id)predicateForVisibleCustomFolders;
+ (id)predicateForVisibleFoldersInContext:(id)context;
+ (id)predicateForVisibleFoldersIncludingHiddenNoteContainers:(_Bool)containers inContext:(id)context;
+ (id)predicateForVisibleObjects;
+ (id)purgableFoldersFetchRequest;
+ (void)purgeFolder:(id)folder;
+ (id)reservedFolderTitles;
+ (id)rootSharingFolderForNote:(id)note;
+ (id)smartFolderWithQuery:(id)query account:(id)account;
+ (id)smartFolderWithQuery:(id)query titleComponents:(id)components account:(id)account;
+ (id)stringByScrubbingStringForFolderName:(id)name;
+ (_Bool)supportsActivityEvents;
+ (_Bool)supportsUserSpecificRecords;
+ (id)visibleFoldersInContext:(id)context;
+ (id)visibleSmartFoldersForHashtagStandardizedContent:(id)content account:(id)account;

/* instance methods */
- (_Bool)validate;
- (id)customNoteSortType;
- (_Bool)isDeprecated;
- (id)containerIdentifier;
- (_Bool)supportsDateHeaders;
- (id)predicateForVisibleNotes;
- (id)predicateForSearchableAttachments;
- (_Bool)isShowingDateHeaders;
- (id)visibleSubFolders;
- (id)visibleNotes;
- (void)setSubFolderOrderMergeableData:(id)data;
- (long long)compare:(id)compare;
- (id)noteVisibilityTestingForSearchingAccount;
- (id)cacheKey;
- (_Bool)validateForInsert:(id *)insert;
- (_Bool)validateForUpdate:(id *)update;
- (unsigned long long)depth;
- (id)titleForTableViewCell;
- (id)predicateForPinnedNotes;
- (_Bool)isModernCustomFolder;
- (id)titleForNavigationBar;
- (_Bool)isTrashFolder;
- (id)accountName;
- (id)subFolderOrderMergeableData;
- (unsigned long long)visibleNotesCount;
- (_Bool)supportsEditingNotes;
- (void)awakeFromFetch;
- (id)recordZoneName;
- (id)predicateForSearchableNotes;
- (_Bool)canBeSharedViaICloud;
- (_Bool)isLeaf;
- (_Bool)isRenamable;
- (void)setMarkedForDeletion:(_Bool)deletion;
- (id)shareType;
- (_Bool)allowsImporting;
- (_Bool)canAddSubfolder;
- (_Bool)containsSharedDescendantFolders;
- (id)predicateForPinnedNotesInFolder;
- (_Bool)allowsExporting;
- (_Bool)hasVisibleNotes;
- (void)markForDeletion;
- (id)predicateForAttachmentsInFolder;
- (void)updateSortOrder;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (id)associatedNoteParticipants;
- (_Bool)canBeRootShareObject;
- (_Bool)canMoveAddOrDeleteContents;
- (id)childCloudObjects;
- (_Bool)containsSharedDescendantFolders:(_Bool *)folders;
- (_Bool)containsSharedNotesOrSharedDescendantFolders;
- (_Bool)containsSharedNotesOrSharedDescendantFolders:(_Bool *)folders;
- (unsigned long long)countOfVisibleNotesInFolder;
- (id)dataForTypeIdentifier:(id)identifier;
- (void)deleteFromLocalDatabase;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (void)fixBrokenReferencesWithError:(id)error;
- (_Bool)hasAllMandatoryFields;
- (_Bool)hasExpectedReferenceActionsInUserSpecificRecord:(id)record;
- (_Bool)hasSharedContentsNotSharedViaSharedFolder:(id)folder;
- (_Bool)hasVisibleNotesInFolder;
- (id)ic_accessibilityIdentifier;
- (id)ic_loggingValues;
- (unsigned long long)indexOfVisibleChild:(id)child;
- (long long)intrinsicNotesVersionForScenario:(unsigned long long)scenario;
- (_Bool)isAncestorOfFolder:(id)folder;
- (_Bool)isDefaultFolderOrDescendantOfDefaultFolder;
- (_Bool)isDescendantOfFolder:(id)folder;
- (_Bool)isEditableSmartFolder;
- (_Bool)isSharedViaSharedFolder:(id)folder;
- (_Bool)isSmartFolder;
- (_Bool)isSubfolderOfReadonlyFolder;
- (_Bool)isSystemFolder;
- (_Bool)isTitleValid:(id)valid error:(out id *)error;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)makeUserSpecificCloudKitRecordForApproach:(long long)approach;
- (unsigned long long)maximumDepthIncludingChildFolders;
- (unsigned long long)maximumDistanceToLeafFolder;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeDataFromUserSpecificRecord:(id)record accountID:(id)id;
- (void)mergeParentFromRecord:(id)record;
- (_Bool)mergeWithMergeableData:(id)data;
- (void)objectWasDeletedFromCloudByAnotherDevice;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)parentCloudObject;
- (id)parentCloudObjectModificationDate;
- (id)pinnedNotesInFolder;
- (id)predicateForFoldersInFolder;
- (id)predicateForNotesInFolder;
- (id)predicateForVisibleAttachments;
- (id)predicateForVisibleAttachmentsInFolder;
- (id)predicateForVisibleNotesInFolder;
- (id)recursiveVisibleSubfolders;
- (void)recursivelyAddSubfoldersToArray:(id)array;
- (id)rootSharedFoldersInDescendantsIncludingSelf;
- (id)rootSharedNotesIncludingChildFolders;
- (id)rootSharingFolder;
- (void)saveMergeableDataIfNeeded;
- (id)searchableTextContent;
- (void)setCustomNoteSortType:(id)type;
- (void)setNeedsInitialFetchFromCloud:(_Bool)cloud;
- (id)shareTitle;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;
- (_Bool)supportsCustomNoteSortType;
- (void)unmarkForDeletionIncludingParentHierarchy;
- (void)updateChangeCountWithReason:(id)reason;
- (id)visibleChildFolderWithTitle:(id)title;
- (_Bool)visibleChildFoldersContainsFolderWithTitle:(id)title;
- (id)visibleNoteContainerChildren;
- (unsigned long long)visibleNoteContainerChildrenCount;
- (id)visibleNoteContainerChildrenUnsorted;
- (id)visibleNotesIncludingChildFolders;

@end


@interface ICFoldersFilterTypeSelection : ICFilterTypeSelection

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) unsigned long long inclusionType;
@property (retain, nonatomic) NSArray *folderIdentifiers;
@property (readonly, copy, nonatomic) NSString *folderSummaryList;
@property (readonly, nonatomic) _Bool containsSharedFolder;

/* class methods */
+ (id)keyPathsForValuesAffectingIsEmpty;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)debugDescription;
- (_Bool)isEmpty;
- (_Bool)isValid;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (unsigned long long)hash;
- (void)addFolderIdentifier:(id)identifier;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)folderTitlesForIdentifiers:(id)identifiers;
- (id)initWithManagedObjectContext:(id)context inclusionType:(unsigned long long)type folderIdentifiers:(id)identifiers;
- (_Bool)isEqualToICFoldersFilterTypeSelection:(id)selection;
- (id)rawFilterValue;
- (void)removeFolderIdentifier:(id)identifier;
- (id)shortEmptySummary;

@end


@interface ICMigrationDeviceInfo : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) _Bool upgraded;
@property (readonly, nonatomic) _Bool upgradedToIOS13;
@property (readonly, nonatomic) _Bool upgradedToIOS14EorMacOS11E;
@property (readonly, nonatomic) _Bool upgradable;
@property (readonly, nonatomic) _Bool upgradableToIOS13;
@property (readonly, nonatomic) _Bool upgradableToIOS14orMacOS11;
@property (readonly, nonatomic) _Bool isOSXDevice;
@property (readonly, nonatomic) _Bool isIOSDevice;

/* class methods */
+ (void)logDeviceList:(id)list;

/* instance methods */
- (id)init;
- (id)initWithName:(id)name;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)attributedStringWithAttributes:(id)attributes asteriskColor:(id)color;
- (id)initWithName:(id)name upgradable:(_Bool)upgradable upgraded:(_Bool)upgraded;
- (id)loggableDescription;
- (_Bool)shouldBeHidden;

@end


@interface ICFullDeviceInfo : ICMigrationDeviceInfo

@property (readonly, nonatomic) struct ICDeviceHardwareInfo hardwareInfo;
@property (readonly, nonatomic) NSString *model;
@property (readonly, nonatomic) NSString *modelDisplayName;
@property (readonly, nonatomic) NSString *softwareVersion;

/* instance methods */
- (id)description;
- (id)init;
- (_Bool)upgradedToIOS13;
- (struct ICDeviceHardwareInfo)hardwareInfoFromModelId:(id)id;
- (unsigned long long)hardwareInfoNameFromString:(id)string;
- (id)initWithName:(id)name model:(id)model modelDisplayName:(id)name softwareVersion:(id)version;
- (_Bool)isHardwareInfoUpgradable:(struct ICDeviceHardwareInfo)upgradable;
- (_Bool)isHardwareInfoUpgradableToIOS13:(struct ICDeviceHardwareInfo)ios13;
- (_Bool)isHardwareInfoUpgradableToMacOS11:(struct ICDeviceHardwareInfo)os11;
- (_Bool)isIOSDevice;
- (_Bool)isOSXDevice;
- (id)loggableDescription;
- (_Bool)shouldBeHidden;
- (_Bool)upgradable;
- (_Bool)upgradableToIOS13;
- (_Bool)upgradableToIOS14orMacOS11;
- (_Bool)upgraded;
- (_Bool)upgradedToIOS14EorMacOS11E;
- (_Bool)upgradedToMajor:(int)major minor:(int)minor;

@end


@interface ICHandoffController : NSObject <ICPeerMessageControllerDelegate, ICPeerInputStreamDelegate>

@property (retain) ICPeerMessageController *peerController;
@property (retain) ICPeerInputStream *inputStream;
@property (retain) ICPeerOutputStream *outputStream;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedController;

/* instance methods */
- (id)init;
- (void)didReceiveInputStream:(id)stream outputStream:(id)stream;
- (void)didDisconnectInputStream:(id)stream;
- (void)handleMessage:(id)message fromInputStream:(id)stream;
- (void)requestNoteWithIdentifier:(id)identifier;
- (_Bool)sendMessage:(id)message toSource:(id)source error:(id *)error;

@end


@interface ICHashtag : ICCloudSyncingObject <ICSearchIndexable, ICCloudObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (retain, nonatomic) ICAccount *account;
@property (copy, nonatomic) NSString *displayText;
@property (copy, nonatomic) NSString *standardizedContent;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (void)enumerateHashtagsInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)predicateForHashtagWithStandardizedContent:(id)content onlyVisible:(_Bool)visible account:(id)account;
+ (id)allVisibleHashtagsForAccount:(id)account;
+ (id)allVisibleHashtagsInContext:(id)context;
+ (id)canonicalHashtagsInContext:(id)context;
+ (void)dedupeHashtagsInAccount:(id)account;
+ (void)dedupeHashtagsInAccount:(id)account atomicityExploitationCallback:(id /* block */)callback;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)hashtagObjectIDWithStandardizedContent:(id)content context:(id)context;
+ (id)hashtagObjectIDsWithStandardizedContents:(id)contents context:(id)context;
+ (id)hashtagWithDisplayText:(id)text account:(id)account createIfNecessary:(_Bool)necessary;
+ (id)hashtagWithIdentifier:(id)identifier context:(id)context;
+ (id)hashtagWithStandardizedContent:(id)content account:(id)account;
+ (id)hashtagWithStandardizedContent:(id)content onlyVisible:(_Bool)visible account:(id)account;
+ (id)hashtagsWithStandardizedContent:(id)content context:(id)context;
+ (id)hashtagsWithStandardizedContent:(id)content onlyVisible:(_Bool)visible account:(id)account context:(id)context;
+ (id)localizedSectionTitle;
+ (id)newHashtagWithIdentifier:(id)identifier displayText:(id)text account:(id)account;
+ (void)purgeHashtag:(id)hashtag;
+ (_Bool)regenerateStandardizedContentForAllHashtagsInContext:(id)context hasChanges:(_Bool *)changes;
+ (id)renameHashtagsWithStandardizedContent:(id)content newDisplayText:(id)text context:(id)context;
+ (id)standardizedHashtagRepresentationForDisplayText:(id)text;

/* instance methods */
- (_Bool)supportsDeletionByTTL;
- (id)cloudAccount;
- (id)recordZoneName;
- (_Bool)canRenameTagWithNewDisplayText:(id)text;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (id)dataForTypeIdentifier:(id)identifier;
- (void)deleteFromLocalDatabase;
- (id)fileURLForTypeIdentifier:(id)identifier;
- (id)ic_loggingValues;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (id)searchableTextContent;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;

@end


@interface ICHashtagController : NSObject

@property (weak, nonatomic) ICNote *note;
@property (retain, nonatomic) NSMutableDictionary *hashtagSuggestionsDictionary;
@property (retain, nonatomic) NSMutableSet *hashtagsNames;
@property (retain, nonatomic) ICHashtagsNode *hashtagsTree;
@property (nonatomic) unsigned long long maxNameLength;
@property (retain, nonatomic) ICAutoCompleteSuggestionsViewController *controller;
@property (readonly, nonatomic) _Bool allowsHashtag;
@property (nonatomic) _Bool isUpdatingKeyboard;
@property (weak, nonatomic) id <ICHashtagKeyboardDelegate> hashtagKeyboardDelegate;
@property (weak, nonatomic) id <ICHashtagKeyboardDelegate> hashtagTableKeyboardDelegate;
@property (weak, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;
@property (nonatomic) struct _NSRange editedRange;
@property (readonly, nonatomic) unsigned long long maxLengthOfStringForCheckingHashtag;
@property (weak, nonatomic) ICTableColumnTextView *tableTextView;
@property (weak, nonatomic) NSTextView *textView;
@property (weak, nonatomic) id <ICHashtagAnalyticsDelegate> analyticsDelegate;

/* class methods */
+ (_Bool)isValidPostfixCharacter:(unsigned short)character;
+ (struct _NSRange)range:(struct _NSRange)range appendingSubstringRange:(struct _NSRange)range;
+ (_Bool)range:(struct _NSRange)range hasValidPostfixCharacterForString:(id)string;
+ (_Bool)isBeginningHashtagAtSelectionRange:(struct _NSRange)range inString:(id)string languageHasSpaces:(_Bool)spaces;
+ (_Bool)isValidPrefixCharacter:(unsigned short)character languageHasSpaces:(_Bool)spaces;
+ (_Bool)range:(struct _NSRange)range hasValidPrefixCharacterForString:(id)string languageHasSpaces:(_Bool)spaces;
+ (_Bool)range:(struct _NSRange)range isPrefixedWithHashtagForString:(id)string;
+ (struct _NSRange)rangeOfLastCharacterInRange:(struct _NSRange)range;
+ (void)setShouldAutoConvertToTag:(_Bool)tag;
+ (_Bool)shouldAutoConvertToTag;

/* instance methods */
- (void)dealloc;
- (id)initWithNote:(id)note;
- (void)accountWasDeleted:(id)deleted;
- (void)associateHashtagSuggestion:(id)suggestion withKey:(id)key;
- (id)checkForHashtagInString:(id)string inRange:(struct _NSRange)range selectionRange:(struct _NSRange)range languageHasSpaces:(_Bool)spaces;
- (void)crossAppHashtagDidChange:(id)change;
- (id)hashtagSuggestionsForKey:(id)key;
- (void)updateHashtagsAssociations;
- (void)updateNoteHashtags;

@end


@interface ICHashtagSuggestionItem : NSObject

@property (retain, nonatomic) NSString *displayText;
@property (retain, nonatomic) NSString *tokenContentIdentifier;
@property (retain, nonatomic) NSDate *lastUsedDate;

/* class methods */
+ (id)sortedItems:(id)items context:(id)context;
+ (id)sortedSuggestionItemsWithHashtagsIncludingHashtagsFromOtherApps:(id)apps context:(id)context;
+ (id)suggestionItemsWithHashtagsIncludingHashtagsFromOtherApps:(id)apps;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)compare:(id)compare;
- (unsigned long long)hash;

@end


@interface ICHashtagsCheckResults : NSObject

@property (nonatomic) struct _NSRange rangeOfHashtag;
@property (copy, nonatomic) NSSet *matchingHashtagSuggestions;

/* instance methods */
- (id)debugDescription;
- (id)init;

@end


@interface ICHashtagsNode : NSObject

@property (copy, nonatomic) NSString *key;
@property (readonly, nonatomic) NSMutableSet *hashtagSuggestions;
@property (readonly, nonatomic) NSMutableSet *possibleHashtagSuggestions;
@property (readonly, nonatomic) NSMutableDictionary *children;
@property (nonatomic) _Bool isPossibleAll;

/* instance methods */
- (void)addChild:(id)child;
- (void)addHashtagSuggestion:(id)suggestion;
- (void)addPossibleHashtagSuggestion:(id)suggestion;

@end


@interface ICImageCache : NSObject

@property (retain, nonatomic) ICCache *imageCache;
@property (retain, nonatomic) ICLRUCache *bigImageCache;
@property (retain, nonatomic) NSObject *memoryWarningEventSource;

/* class methods */
+ (double)bigImageSize;
+ (unsigned long long)maxBigImageCount;

/* instance methods */
- (id)init;
- (void)setImage:(id)image forKey:(id)key;
- (id)imageForKey:(id)key;
- (void)removeAllImages;
- (void)removeImageForKey:(id)key;
- (void)receivedMemoryWarning;
- (void)registerForMemoryWarnings;
- (void)unregisterForMemoryWarnings;

@end


@interface ICInclusionFilterTypeSelection : ICFilterTypeSelection <NSCopying>

@property (readonly, nonatomic) unsigned long long inclusionType;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)debugDescription;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithInclusionType:(unsigned long long)type;
- (_Bool)isEqualToInclusionFilterSelection:(id)selection;
- (id)rawFilterValue;

@end


@interface ICInlineAttachment : ICBaseAttachment <ICCloudObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) _Bool isCalculateResultAttachment;
@property (readonly, nonatomic) _Bool isCalculateGraphExpressionAttachment;
@property (readonly, nonatomic) _Bool isLinkAttachment;
@property (readonly, nonatomic) _Bool isParagraphLinkAttachment;
@property (readonly, nonatomic) _Bool isInternalParagraphLinkAttachment;
@property (readonly, nonatomic) _Bool isMentionAttachment;
@property (readonly, nonatomic) _Bool isHashtagAttachment;
@property (readonly, nonatomic) _Bool isDividerLineAttachment;
@property (copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) NSString *displayText;
@property (copy, nonatomic) NSString *altText;
@property (nonatomic) int mentionNotificationState;
@property (nonatomic) int mentionNotificationAttemptCount;
@property (copy, nonatomic) NSString *tokenContentIdentifier;
@property (readonly, nonatomic) NSAttributedString *searchableTextContentInNote;
@property (readonly, nonatomic) short attachmentType;
@property (nonatomic) _Bool animateInsertion;
@property (readonly, nonatomic) struct _NSRange animatableRange;
@property (nonatomic) _Bool didAddAttachmentDataChangedObservers;
@property (copy, nonatomic) NSString *calculateState;
@property (readonly, nonatomic) _Bool validCalculateAttachment;
@property (readonly, nonatomic) _Bool rightToLeftCalculateAttachment;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)canonicalHashtagAttachmentsInContext:(id)context;
+ (void)changeLinkDestinationFromNote:(id)note toNote:(id)note;
+ (id)cloneInlineAttachmentWithIdentifier:(id)identifier context:(id)context;
+ (unsigned long long)countOfNonTrashFolderVisibleInlineAttachmentsForHashtagStandardizedContent:(id)content account:(id)account;
+ (unsigned long long)countOfVisibleInlineAttachmentsForHashtagStandardizedContent:(id)content account:(id)account;
+ (unsigned long long)countOfVisibleInlineAttachmentsForHashtagStandardizedContent:(id)content includingTrash:(_Bool)trash account:(id)account;
+ (void)enumerateInlineAttachmentsInContext:(id)context typeUTI:(id)uti tokenContentIdentifier:(id)identifier batchSize:(unsigned long long)size visibleOnly:(_Bool)only saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (void)enumerateLinksToNote:(id)note batchSize:(unsigned long long)size visibleOnly:(_Bool)only saveAfterBatch:(_Bool)batch context:(id)context usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)existingInlineAttachmentsWithTokenContentIdentifier:(id)identifier typeUTI:(id)uti context:(id)context;
+ (_Bool)isHashtagStandardizedContent:(id)content usedInAccount:(id)account;
+ (id)newAttachmentWithIdentifier:(id)identifier typeUTI:(id)uti altText:(id)text tokenContentIdentifier:(id)identifier note:(id)note parentAttachment:(id)attachment;
+ (id)newCalculateGraphExpressionAttachmentWithIdentifier:(id)identifier altText:(id)text note:(id)note parentAttachment:(id)attachment rightToLeft:(_Bool)left;
+ (id)newCalculateGraphExpressionAttachmentWithIdentifier:(id)identifier note:(id)note parentAttachment:(id)attachment rightToLeft:(_Bool)left;
+ (id)newCalculateResultAttachmentWithIdentifier:(id)identifier note:(id)note parentAttachment:(id)attachment rightToLeft:(_Bool)left;
+ (id)newDividerLineAttachmentWithIdentifier:(id)identifier note:(id)note parentAttachment:(id)attachment;
+ (id)newHashtagAttachmentWithIdentifier:(id)identifier forHashtag:(id)hashtag note:(id)note parentAttachment:(id)attachment;
+ (id)newHashtagAttachmentWithIdentifier:(id)identifier hashtagText:(id)text creatingHashtagIfNecessary:(_Bool)necessary note:(id)note parentAttachment:(id)attachment;
+ (id)newLinkAttachmentWithIdentifier:(id)identifier toNote:(id)note fromNote:(id)note parentAttachment:(id)attachment;
+ (id)newLinkAttachmentWithIdentifier:(id)identifier url:(id)url altText:(id)text fromNote:(id)note parentAttachment:(id)attachment;
+ (id)newLinkAttachmentWithURL:(id)url name:(id)name currentNote:(id)note;
+ (id)newMentionAttachmentWithIdentifier:(id)identifier mentionText:(id)text userRecordName:(id)name note:(id)note parentAttachment:(id)attachment;
+ (id)newParagraphLinkAttachmentWithIdentifier:(id)identifier toNote:(id)note paragraphName:(id)name paragraphID:(id)id fromNote:(id)note parentAttachment:(id)attachment;
+ (id)noteFromAttachmentRecord:(id)record accountID:(id)id context:(id)context;
+ (id)paragraphLinkDisplayTextforURL:(id)url currentNote:(id)note;
+ (id)predicateForMentionsInContext:(id)context;
+ (id)predicateForTokenContentIdentifier:(id)identifier;
+ (id)predicateForTokenContentIdentifierContains:(id)contains;
+ (id)predicateForTypeUTI:(id)uti;
+ (id)predicateForUnsupportedAttachmentsInContext:(id)context;
+ (void)purgeAttachment:(id)attachment;
+ (id)recentlyUsedDatesForHashtagsStandardizedContents:(id)contents context:(id)context;
+ (void)regenerateDerivedDataForInlineAttachments:(id)attachments reason:(id)reason;
+ (void)regenerateTokenContentIdentifierForHashtagAttachmentsInContext:(id)context currentTokenContentIdentifier:(id)identifier save:(_Bool)save;
+ (void)reviveOrTouchHashtag:(id)hashtag;

/* instance methods */
- (void)willTurnIntoFault;
- (_Bool)supportsDeletionByTTL;
- (void)awakeFromInsert;
- (void)awakeFromFetch;
- (id)recordZoneName;
- (id)clone;
- (void)markForDeletion;
- (void)changeLinkDestinationFromNote:(id)note toNote:(id)note;
- (void)deleteFromLocalDatabase;
- (struct _NSRange)displayTextRangeForSearchRange:(struct _NSRange)range inSearchableString:(id)string;
- (id)fallbackDisplayText;
- (_Bool)hasAllMandatoryFields;
- (id)ic_loggingValues;
- (long long)intrinsicNotesVersionForScenario:(unsigned long long)scenario;
- (_Bool)isRightToLeftCalculateAttachment;
- (_Bool)isValidCalculateAttachment;
- (void)loadFromArchive:(const void *)archive dataPersister:(id)persister withIdentifierMap:(id)map;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (void)markDisplayTextNeedsUpdate;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (id)nonNilAltText;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;
- (id)parentAttachmentFromRecord:(id)record accountID:(id)id context:(id)context;
- (id)parentEncryptableObject;
- (void)propagateDeletionToHashtagForMarkForDeletion:(_Bool)deletion;
- (_Bool)saveToArchive:(void *)archive dataPersister:(id)persister error:(id *)error;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;
- (_Bool)supportsEncryptedValuesDictionary;
- (void)unmarkForDeletion;
- (_Bool)updateCalculateGraphExpressionText:(id)text;
- (_Bool)updateCalculateResult:(id)result isRightToLeft:(_Bool)left;
- (_Bool)updateCalculateText:(id)text isValid:(_Bool)valid isRightToLeft:(_Bool)left;
- (void)updateMarkedForDeletionStateInlineAttachmentIsInUse:(_Bool)use;
- (void)writeMergeableFieldStateIfNecessary:(id)necessary;

@end


@interface ICInlineAttachmentCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICInlineAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

@end


@interface ICInlineAttachmentCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICInlineAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

@end


@interface ICInlineAttachmentCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICInlineAttachmentCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

@end


@interface ICInvitation : NSManagedObject

@property (copy, nonatomic) NSURL *shareURL;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) ICCloudSyncingObject *rootObject;
@property (copy, nonatomic) NSString *rootObjectType;
@property (copy, nonatomic) NSData *serverShareData;
@property (retain, nonatomic) CKShare *serverShare;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSDate *creationDate;
@property (copy, nonatomic) NSDate *modificationDate;
@property (copy, nonatomic) NSDate *receivedDate;
@property (readonly, nonatomic) NSDate *displayDate;
@property (copy, nonatomic) NSString *snippet;
@property (nonatomic) short snippetAttachmentType;
@property (nonatomic) long long snippetAttachmentCount;
@property (copy, nonatomic) NSData *thumbnailDataLight;
@property (copy, nonatomic) NSData *thumbnailDataDark;
@property (nonatomic) long long noteCount;
@property (nonatomic) long long noteCountRecursive;
@property (nonatomic) long long subfolderCount;
@property (nonatomic) long long subfolderCountRecursive;

/* class methods */
+ (id)invitationWithShareURL:(id)url context:(id)context;
+ (id)allInvitationsInContext:(id)context;
+ (_Bool)hasInvitationMatchingPredicate:(id)predicate context:(id)context;
+ (id)invitationsMatchingPredicate:(id)predicate context:(id)context;
+ (id)makeInvitationIfNeededWithShareURL:(id)url account:(id)account context:(id)context;
+ (id)makeInvitationWithShareURL:(id)url account:(id)account context:(id)context;
+ (id)predicateForPendingInvitationsInAccount:(id)account;
+ (id)predicateForPendingInvitationsInAccount:(id)account receivedSince:(id)since;
+ (id)shareSystemFieldsTransformer;

/* instance methods */

@end


@interface ICKeychain : NSObject

/* class methods */
+ (id)accessControlObjectWithProtection:(void *)protection flags:(unsigned long long)flags error:(id *)error;
+ (_Bool)booleanForIdentifier:(id)identifier account:(id)account;
+ (id)dataForIdentifier:(id)identifier account:(id)account;
+ (id)dataForIdentifier:(id)identifier account:(id)account authenticationContext:(id)context;
+ (id)dataForIdentifier:(id)identifier account:(id)account isSynced:(_Bool)synced authenticationContext:(id)context;
+ (_Bool)deleteItemsForIdentifier:(id)identifier account:(id)account error:(id *)error;
+ (_Bool)deleteItemsForIdentifier:(id)identifier account:(id)account isSynced:(_Bool)synced error:(id *)error;
+ (_Bool)deleteItemsOfType:(unsigned long long)type account:(id)account error:(id *)error;
+ (_Bool)deleteItemsOfType:(unsigned long long)type account:(id)account isSynced:(_Bool)synced error:(id *)error;
+ (void)fetchItemsWithCompletionHandler:(id /* block */)handler;
+ (_Bool)hasItemForIdentifier:(id)identifier account:(id)account;
+ (_Bool)isSyncAvailableForAccount:(id)account;
+ (id)itemsOfType:(unsigned long long)type account:(id)account authenticationContext:(id)context;
+ (id)itemsOfType:(unsigned long long)type account:(id)account isSynced:(_Bool)synced authenticationContext:(id)context;
+ (id)queryForItemClass:(id)_class forIdentifier:(id)identifier account:(id)account isSynced:(_Bool)synced type:(unsigned long long)type authenticationContext:(id)context returnData:(_Bool)data limit:(id)limit;
+ (_Bool)setBoolean:(_Bool)boolean forIdentifier:(id)identifier account:(id)account shouldSync:(_Bool)sync error:(id *)error;
+ (_Bool)setData:(id)data forIdentifier:(id)identifier account:(id)account error:(id *)error;
+ (_Bool)setData:(id)data forIdentifier:(id)identifier account:(id)account shouldSync:(_Bool)sync error:(id *)error;
+ (_Bool)setData:(id)data forIdentifier:(id)identifier account:(id)account type:(unsigned long long)type shouldSync:(_Bool)sync accessFlags:(unsigned long long)flags accessGroup:(id)group error:(id *)error;
+ (_Bool)setString:(id)string forIdentifier:(id)identifier account:(id)account shouldSync:(_Bool)sync error:(id *)error;
+ (_Bool)setUnsignedInteger:(unsigned long long)integer forIdentifier:(id)identifier account:(id)account shouldSync:(_Bool)sync error:(id *)error;
+ (_Bool)shouldFetchItemsWithError:(id *)error;
+ (id)stringForIdentifier:(id)identifier account:(id)account isSynced:(_Bool)synced;
+ (void)tests_setLastItemsError:(id)error lastItemsErrorDate:(id)date lastItemsFetchDate:(id)date;
+ (unsigned long long)unsignedIntegerForIdentifier:(id)identifier account:(id)account;

@end


@interface ICLegacyAccountUtilities : NSObject

/* class methods */
+ (id)accountForEmailAddress:(id)address context:(id)context;
+ (id)accountForAccountIdentifier:(id)identifier context:(id)context;
+ (id)accountIdentifierForAccount:(id)account;
+ (_Bool)didChooseToMigrateAccount:(id)account context:(id)context;
+ (_Bool)didChooseToMigrateAccountsForContext:(id)context forAccountPassingTest:(id /* block */)test;
+ (_Bool)didChooseToMigrateLegacyAccountType:(long long)type;
+ (id)emailAddressForAccount:(id)account;
+ (_Bool)isLegacyLocalAccount:(id)account;
+ (id)legacyAccountForICloudACAccount:(id)acaccount context:(id)context;
+ (id)legacyAccountForICloudAccount:(id)account context:(id)context;
+ (id)legacyAccountForLegacyAccountType:(long long)type context:(id)context;
+ (id)legacyAccountForLocalAccountWithContext:(id)context;
+ (id)legacyAccountForPrimaryICloudAccountWithContext:(id)context;

@end


@interface ICLegacyAttachmentFileWrapper : NSFileWrapper <NSSecureCoding>

@property (retain, nonatomic) NSURL *cidURL;
@property (readonly, nonatomic) NSString *attachmentIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithCIDURL:(id)cidurl;

@end


@interface ICLegacyAttachmentUtilities : NSObject

/* class methods */
+ (id)attachmentWithContentID:(id)id context:(id)context;
+ (id)contentIDStringFromCIDURL:(id)cidurl;
+ (void)importFileAtURL:(id)url toAttachment:(id)attachment attachmentPreviewGenerator:(id)generator;
+ (void)importLegacyAttachment:(id)attachment toNote:(id)note attachmentPreviewGenerator:(id)generator;
+ (id)typeUTIFromFileURL:(id)url mimeType:(id)type;

@end


@interface ICLegacyContentUtilities : NSObject

/* class methods */
+ (void)addAttachmentFromWebResource:(id)resource toNote:(id)note context:(id)context;
+ (id)contentStringFromWebArchive:(id)archive;
+ (id)createAttachmentForNote:(id)note withName:(id)name context:(id)context;
+ (id)generateContentID;
+ (id)newNoteBasedOnModernNote:(id)note inFolder:(id)folder context:(id)context;
+ (id)suggestedFilenameForURL:(id)url mimeType:(id)type;

@end


@interface ICLegacyTombstone : ICCloudSyncingObject

@property (retain, nonatomic) ICAccount *account;
@property (nonatomic) short type;
@property (retain, nonatomic) NSString *contentHashAtImport;
@property (retain, nonatomic) NSDate *modificationDateAtImport;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (void)removeLegacyTombstoneForFolder:(id)folder;
+ (void)addLegacyTombstoneForFolder:(id)folder;
+ (void)addLegacyTombstoneForNote:(id)note;
+ (id)addLegacyTombstoneWithObjectIdentifier:(id)identifier type:(short)type account:(id)account;
+ (id)allLegacyTombstonesInContext:(id)context;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (_Bool)hasTombstonePrefix:(id)prefix;
+ (id)legacyTombstoneWithIdentifier:(id)identifier context:(id)context;
+ (id)legacyTombstonesMatchingPredicate:(id)predicate context:(id)context;
+ (id)newLegacyTombstoneWithIdentifier:(id)identifier type:(short)type account:(id)account;
+ (void)removeLegacyTombstoneForNote:(id)note;
+ (void)removeLegacyTombstoneWithObjectIdentifier:(id)identifier type:(short)type context:(id)context;
+ (id)tombstoneIdentifierForObjectIdentifier:(id)identifier type:(short)type;
+ (short)tombstoneTypeFromRecordName:(id)name;

/* instance methods */
- (_Bool)isEquivalentTo:(id)to;
- (id)recordType;
- (id)cloudAccount;
- (id)recordZoneName;
- (void)deleteFromLocalDatabase;
- (_Bool)hasAllMandatoryFields;
- (id)ic_loggingValues;
- (_Bool)isInICloudAccount;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (void)objectWasDeletedFromCloud;
- (void)objectWasDeletedFromCloudByAnotherDevice;

@end


@interface ICSearchQuery : NSObject

@property (retain, nonatomic) NSObject *synchronousSemaphore;
@property (nonatomic) _Bool wasForceStopped;
@property (retain, nonatomic) CSSearchQuery *searchQuery;
@property (retain, nonatomic) NSMutableDictionary *mutableQueryResults;
@property (retain, nonatomic) ICRankingQueriesDefinition *rankingQueriesDefinition;
@property (retain, nonatomic) NSArray *externalRankingQueries;
@property (readonly, nonatomic) NSDictionary *queryResults;
@property (readonly, nonatomic) _Bool modernResultsOnly;

/* class methods */
+ (id)defaultAttributesToReturnFromCoreSpotlight;

/* instance methods */
- (_Bool)run:(id *)run;
- (id)rankingQueries;
- (void)forceStop;
- (void)cancel;
- (double)timeoutInterval;
- (id)attributesToFetch;
- (id)initWithExternalRankingQueries:(id)queries;
- (id)initWithRankingQueriesDefinition:(id)definition;
- (id)newSearchQueryContext;
- (id)newSearchQueryWithContext:(id)context;
- (void)queryFinishedRunningWithError:(id)error;
- (void)setupWithAttributes:(id)attributes;

@end


@interface ICLinkSuggestionQuery : ICSearchQuery

@property (copy, nonatomic) NSString *queryString;

/* instance methods */
- (id)attributesToFetch;
- (id)initWithQueryString:(id)string;
- (id)newSearchQueryContext;
- (id)newSearchQueryWithContext:(id)context;

@end


@interface ICLocalAuthentication : NSObject

/* class methods */
+ (_Bool)hasPasscode;
+ (void)setHasPasscode:(_Bool)passcode;
+ (_Bool)biometricsAvailable;
+ (id)biometricsContext;
+ (id)biometricsContextError;
+ (_Bool)biometricsEnrolled;
+ (_Bool)biometricsLockedOut;
+ (long long)biometricsPolicy;
+ (id)biometricsPolicyState;
+ (long long)biometricsType;
+ (void)checkBiometricsPolicyState;
+ (void)refreshBiometricsContext;
+ (void)refreshHasPasscode;
+ (void)setBiometricsContext:(id)context;
+ (void)setBiometricsContextError:(id)error;

@end


@interface ICLocalFileWrapper : NSFileWrapper <NSSecureCoding>

@property (retain, nonatomic) NSURL *localURL;
@property (retain, nonatomic) NSData *cachedData;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)filename;
- (_Bool)isDirectory;
- (id)fileAttributes;
- (id)serializedRepresentation;
- (void)encodeWithCoder:(id)coder;
- (_Bool)isSymbolicLink;
- (id)initWithCoder:(id)coder;
- (id)addFileWrapper:(id)wrapper;
- (id)addRegularFileWithContents:(id)contents preferredFilename:(id)filename;
- (id)fileWrappers;
- (id)keyForFileWrapper:(id)wrapper;
- (_Bool)matchesContentsOfURL:(id)url;
- (id)preferredFilename;
- (_Bool)readFromURL:(id)url options:(unsigned long long)options error:(id *)error;
- (id)regularFileContents;
- (void)removeFileWrapper:(id)wrapper;
- (id)symbolicLinkDestinationURL;
- (_Bool)writeToURL:(id)url options:(unsigned long long)options originalContentsURL:(id)url error:(id *)error;
- (id)dataWithError:(id *)error;
- (id)initWithLocalURL:(id)url;

@end


@interface ICLocationContext : NSObject <CLLocationManagerDelegate>

@property (retain, nonatomic) CLGeocoder *geocoder;
@property (readonly, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) _Bool requestedAuthorization;
@property (readonly, nonatomic) _Bool canGetLocation;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedContext;

/* instance methods */
- (void)locationManagerDidChangeAuthorization:(id)authorization;
- (void)lookupPlaceAtLatitude:(double)latitude longitude:(double)longitude handler:(id /* block */)handler;
- (void)requestAuthorizationIfNeeded;

@end


@interface ICLocationMigrationPolicy : NSEntityMigrationPolicy

/* instance methods */
- (_Bool)createDestinationInstancesForSourceInstance:(id)instance entityMapping:(id)mapping manager:(id)manager error:(id *)error;

@end


@interface ICLockedNotesFilterTypeSelection : ICInclusionFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;

@end


@interface ICMacLocalizedStrings : NSObject

/* class methods */
+ (id)localizedLocalAccountName;
+ (id)localizedLocalAccountNameMidSentence;

@end


@interface ICMarkupUtilities : NSObject

/* class methods */
+ (id)cleanImageMetadataFromData:(id)data;
+ (_Bool)hasPrivateImageMetadata:(id)metadata;
+ (void)applyMarkupModelData:(id)data attachment:(id)attachment completionBlock:(id /* block */)block;
+ (void)applyReturnedMarkupURL:(id)url attachment:(id)attachment completionBlock:(id /* block */)block;
+ (id)createMarkupViewController;
+ (id)createProcessingMarkupViewControllerOutWindow:(id *)window;
+ (void)embedReturnedMarkupURL:(id)url attachment:(id)attachment completionBlock:(id /* block */)block;
+ (void)extractReturnedMarkupURL:(id)url attachment:(id)attachment completionBlock:(id /* block */)block;
+ (id)imageDataWithMarkupModelData:(id)data sourceImageData:(id)data;
+ (id)imageDataWithMarkupModelData:(id)data sourceImageData:(id)data embedData:(_Bool)data;
+ (id)imageDataWithMarkupModelData:(id)data sourceImageURL:(id)url;
+ (id)markupModelDataFromData:(id)data;
+ (id)markupModelDataFromDataAtURL:(id)url;

@end


@interface ICMedia : ICCloudSyncingObject <ICCloudObject>

@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (weak, nonatomic) ICAccount *placeholderAccount;
@property (nonatomic) _Bool suppressesFileDeletion;
@property (readonly, nonatomic) NSSet *urlsToConsiderForCloudBackup;
@property (readonly, nonatomic) ICAccount *containerAccount;
@property (readonly, nonatomic) id <ICMediaCryptoStrategy> cryptoStrategy;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) ICAttachment *attachment;
@property (retain, nonatomic) NSString *filename;
@property (retain, nonatomic) NSData *assetCryptoInitializationVector;
@property (retain, nonatomic) NSData *assetCryptoTag;
@property (copy, nonatomic) NSString *generation;
@property (readonly, nonatomic) ICAssetGenerationManager *generationManager;
@property (readonly, nonatomic) NSString *icaxIPTCCaptionAbstract;

/* class methods */
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)newMediaWithIdentifier:(id)identifier account:(id)account;
+ (id)allMediaInContext:(id)context;
+ (id)containerDirectoryURLForMediaWithIdentifier:(id)identifier account:(id)account;
+ (void)deleteMedia:(id)media;
+ (void)enumerateMediaInContext:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (id)exportableContainerDirectoryURLForMediaWithIdentifier:(id)identifier account:(id)account;
+ (id)keyPathsForValuesAffectingIsSharedViaICloud;
+ (id)keyPathsForValuesAffectingParentCloudObject;
+ (id)mediaIdentifiersForAccount:(id)account;
+ (id)mediaWithIdentifier:(id)identifier context:(id)context;
+ (id)newMediaWithAttachment:(id)attachment;
+ (id)newMediaWithAttachment:(id)attachment forData:(id)data filename:(id)filename error:(id *)error;
+ (id)newMediaWithAttachment:(id)attachment forFileWrapper:(id)wrapper error:(id *)error;
+ (id)newMediaWithAttachment:(id)attachment forURL:(id)url error:(id *)error;
+ (id)newMediaWithAttachment:(id)attachment forURL:(id)url filename:(id)filename error:(id *)error;
+ (id)newMediaWithIdentifier:(id)identifier attachment:(id)attachment;
+ (void)purgeMedia:(id)media;
+ (void)purgeMediaFilesForIdentifiers:(id)identifiers account:(id)account;
+ (void)undeleteMedia:(id)media;

/* instance methods */
- (_Bool)supportsDeletionByTTL;
- (_Bool)isValid;
- (id)cloudAccount;
- (void)prepareForDeletion;
- (id)mediaURL;
- (_Bool)writeData:(id)data error:(id *)error;
- (id)data;
- (void)awakeFromFetch;
- (id)recordZoneName;
- (id)decryptedData;
- (_Bool)hasFile;
- (id)dataWithoutImageMarkupMetadata:(_Bool)metadata;
- (id)exportableContainerDirectoryURL;
- (_Bool)writeDataFromFileWrapper:(id)wrapper error:(id *)error;
- (void)markForDeletion;
- (id)mediaArchiveURL;
- (void)accountWillChangeToAccount:(id)account;
- (void)applyRandomCryptoGooIfNeeded;
- (id)containerDirectoryURL;
- (id)cryptoStrategyProtocol;
- (void)deleteExportableMedia;
- (void)deleteFromLocalDatabase;
- (id)encryptedMediaFallbackURL;
- (id)encryptedMediaURL;
- (id)exportableMediaURL;
- (void)fixBrokenReferencesWithError:(id)error;
- (_Bool)hasAllMandatoryFields;
- (id)ic_loggingValues;
- (_Bool)isArchivedDirectory;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)mediaArchiveFallbackURL;
- (id)mediaFallbackURL;
- (id)mediaTarArchiveURL;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (void)objectWasPushedToCloudWithOperation:(id)operation serverRecord:(id)record;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)parentCloudObject;
- (id)parentCloudObjectForMinimumSupportedVersionPropagation;
- (id)parentEncryptableObject;
- (id)prepareExportableMediaURL;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;
- (_Bool)supportsEncryptedValuesDictionary;
- (void)suppressFileDeletion;
- (void)unmarkForDeletion;
- (void)updateFlagToExcludeFromCloudBackup;
- (_Bool)writeDataFromAsset:(id)asset accountID:(id)id isArchivedDirectory:(_Bool)directory error:(id *)error;
- (_Bool)writeDataFromFileURL:(id)url error:(id *)error;
- (void)writeDataFromItemProvider:(id)provider checkForMarkupData:(_Bool)data completionBlock:(id /* block */)block;
- (_Bool)writeDataWithBlock:(id /* block */)block error:(id *)error;

@end


@interface ICMediaCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICMediaCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedData;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (id)fileURLEncryptionCryptoInitialzationVector;
- (id)fileURLEncryptionCryptoTag;

@end


@interface ICMediaCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICMediaCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedData;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;
- (_Bool)rewrapWithMainKey:(id)key;

@end


@interface ICMediaCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICMediaCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)decryptedData;
- (_Bool)encryptFileFromURL:(id)url toURL:(id)url;

@end


@interface ICMentionCheckResults : NSObject

@property (nonatomic) struct _NSRange rangeOfMention;
@property (nonatomic) _Bool isPartialMention;
@property (nonatomic) _Bool isExplicitMention;
@property (nonatomic) _Bool isAllMention;
@property (copy, nonatomic) NSSet *matchingParticipants;
@property (copy, nonatomic) NSString *mentionString;

/* instance methods */
- (id)debugDescription;
- (id)init;

@end


@interface ICMentionsController : NSObject <ICMentionsControllerUI>

@property (weak, nonatomic) ICNote *note;
@property (retain, nonatomic) NSMutableDictionary *participantDictionary;
@property (retain, nonatomic) NSMutableSet *participantRecordNames;
@property (retain, nonatomic) NSMutableSet *participantNames;
@property (retain, nonatomic) ICMentionsParticipantNode *participantTree;
@property (nonatomic) unsigned long long maxNameLength;
@property (readonly, nonatomic) _Bool allowsMentions;
@property (nonatomic) _Bool isUpdatingKeyboard;
@property (weak, nonatomic) ICAttachmentInsertionController *attachmentInsertionController;
@property (weak, nonatomic) id <ICMentionsKeyboardDelegate> mentionsKeyboardDelegate;
@property (weak, nonatomic) id <ICMentionsKeyboardDelegate> mentionsTableKeyboardDelegate;
@property (weak, nonatomic) ICTableColumnTextView *tableTextView;
@property (nonatomic) struct _NSRange editedRange;
@property (readonly, nonatomic) unsigned long long maxLengthOfStringForCheckingMention;
@property (weak, nonatomic) NSTextView *textView;
@property (weak, nonatomic) id <ICMentionsAnalyticsDelegate> analyticsDelegate;
@property (retain, nonatomic) id <NSObject> contactsChangedObserverToken;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)isValidPostfixCharacter:(unsigned short)character;
+ (struct _NSRange)range:(struct _NSRange)range appendingSubstringRange:(struct _NSRange)range;
+ (_Bool)range:(struct _NSRange)range hasValidPostfixCharacterForString:(id)string;
+ (_Bool)range:(struct _NSRange)range isPrefixedWithAtForString:(id)string;
+ (id)allKeyword;
+ (id)allUserRecordName;
+ (_Bool)isBeginningExplicitMentionAtSelectionRange:(struct _NSRange)range inString:(id)string languageHasSpaces:(_Bool)spaces;
+ (_Bool)isValidPrefixCharacter:(unsigned short)character languageHasSpaces:(_Bool)spaces;
+ (_Bool)range:(struct _NSRange)range hasValidPrefixCharacterForString:(id)string languageHasSpaces:(_Bool)spaces;
+ (struct _NSRange)rangeOfLastCharacterInRange:(struct _NSRange)range;

/* instance methods */
- (void)dealloc;
- (id)initWithNote:(id)note;
- (void)updateMentionsAssociations;
- (void)addAllKeywordToParticipantTree;
- (void)associateParticipant:(id)participant withKey:(id)key;
- (id)checkForMentionsInString:(id)string inRange:(struct _NSRange)range selectionRange:(struct _NSRange)range languageHasSpaces:(_Bool)spaces;
- (id)participantsForKey:(id)key;
- (void)updateNoteParticipants;

@end


@interface ICParticipantsFilterTypeSelection : ICFilterTypeSelection

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) unsigned long long selectionType;
@property (nonatomic) unsigned long long joinOperator;
@property (retain, nonatomic) NSSet *participantUserIDs;
@property (readonly, nonatomic) NSArray *unresolvedParticipants;
@property (readonly, nonatomic) NSArray *participants;
@property (readonly, nonatomic) NSString *summary;
@property (readonly, nonatomic) NSString *summaryWithJoinOperatorMenu;

/* class methods */
+ (id)keyPathsForValuesAffectingIsEmpty;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (_Bool)isEmpty;
- (_Bool)isValid;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (void)addParticipantUserID:(id)id;
- (id)initWithManagedObjectContext:(id)context accountObjectID:(id)id;
- (id)initWithManagedObjectContext:(id)context accountObjectID:(id)id selectionType:(unsigned long long)type;
- (id)initWithManagedObjectContext:(id)context accountObjectID:(id)id selectionType:(unsigned long long)type joinOperator:(unsigned long long)_operator;
- (_Bool)isEqualToICParticipantsFilterTypeSelection:(id)selection;
- (id)rawFilterValue;
- (void)removeParticipantUserID:(id)id;

@end


@interface ICMentionsFilterTypeSelection : ICParticipantsFilterTypeSelection

@property (readonly, nonatomic) NSString *currentUserID;

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)shortEmptySummary;
- (id)summaryWithJoinOperatorMenu;

@end


@interface ICMentionsParticipantNode : NSObject

@property (copy, nonatomic) NSString *key;
@property (readonly, nonatomic) NSMutableSet *participants;
@property (readonly, nonatomic) NSMutableSet *possibleParticipants;
@property (readonly, nonatomic) NSMutableDictionary *children;
@property (nonatomic) _Bool isPossibleAll;
@property (nonatomic) _Bool isAll;

/* instance methods */
- (void)addChild:(id)child;
- (void)addParticipant:(id)participant;
- (void)addPossibleParticipant:(id)participant;

@end


@interface ICMergeableDictionary : NSObject

@property (readonly, nonatomic) ICCRDocument *document;
@property (readonly, nonatomic) ICCRDictionary *dictionary;
@property (readonly, copy, nonatomic) NSArray *allKeys;
@property (readonly, copy, nonatomic) NSUUID *replicaID;

/* instance methods */
- (id)encodedData;
- (id)objectForKeyedSubscript:(id)subscript;
- (unsigned long long)mergeWithDictionary:(id)dictionary;
- (void)removeAllObjects;
- (id)description;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)subscript;
- (void)setObject:(id)object forKey:(id)key;
- (id)initWithData:(id)data replicaID:(id)id;

@end


@interface ICMigrationUtilities : NSObject

/* class methods */
+ (void)clearPostIAMigrationFlagFromAccount:(id)account;
+ (void)deleteMigratedHTMLAccountIfNecessaryForModernAccount:(id)account;
+ (void)deleteMigratedHTMLAccountsInContext:(id)context;
+ (void)fetchAndSetMigrationStateForAccountID:(id)id withCompletionHandler:(id /* block */)handler;
+ (void)fetchMigrationStateAndUserRecordForAccountID:(id)id withCompletionHandler:(id /* block */)handler;
+ (void)fetchMigrationStateForAccountID:(id)id withCompletionHandler:(id /* block */)handler;
+ (_Bool)parentACAccountNeedsMigrationAfterIA:(id)ia;
+ (void)saveDidChooseToMigrate:(_Bool)migrate didFinishMigration:(_Bool)migration didMigrateOnMac:(_Bool)mac toACAccount:(id)acaccount inStore:(id)store completionHandler:(id /* block */)handler;
+ (void)updateAllLegacyAccountMigrationStatesInContext:(id)context;
+ (void)updateLegacyAccountMigrationStateForModernAccount:(id)account;

@end


@interface ICMinimalDeviceInfo : ICMigrationDeviceInfo

/* instance methods */
- (id)description;
- (id)init;
- (id)initWithName:(id)name upgradable:(_Bool)upgradable upgraded:(_Bool)upgraded;
- (id)loggableDescription;

@end


@interface ICModernSearchIndexProgressDataSource : NSObject <ICSearchIndexProgressCoordinatorDataSource>

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) long long batchDepth;
@property (nonatomic) _Bool batchDirty;
@property (nonatomic, readonly) NSURL *persistenceURL;

/* instance methods */
- (id)init;
- (void)reset;
- (id)initWithManagedObjectContext:(id)context;
- (id)indexStateCreateIfNecessaryFor:(id)_for;
- (void)adoptIndexState:(unsigned long long)state forItemWithIdentifier:(id)identifier updatingProgress:(id)progress;
- (id)allItemIdentifiersForState:(unsigned long long)state;
- (void)beginBatchPersistence;
- (void)endBatchPersistence;
- (id)existingIndexStateFor:(id)_for;
- (void)fullProgressUpdateWithCompletionHandler:(id /* block */)handler;
- (id)newIndexStateFor:(id)_for;
- (void)revertStagingWithItemIdentifier:(id)identifier;
- (void)saveIfNotBatching;
- (void)stageForProcessingWithItemIdentifier:(id)identifier updatingProgress:(id)progress;
- (unsigned long long)stateOfItemWithIdentifier:(id)identifier;

@end


@interface ICModernSearchIndexerDataSource : ICBaseSearchIndexerDataSource

@property (weak, nonatomic) ICPersistentContainer *persistentContainer;
@property (retain, nonatomic) ICModernSearchIndexProgressDataSource *progressDataSource;

/* instance methods */
- (id)persistentStoreCoordinator;
- (id)allIndexableObjectIDsInReversedReindexingOrderWithContext:(id)context;
- (_Bool)isFolderWithServerShareChanged:(id)changed;
- (id)dataSourceIdentifier;
- (void)contextWillSave:(id)save;
- (unsigned long long)indexingPriority;
- (id)addNotesFromSubtree:(id)subtree;
- (id)newManagedObjectContext;
- (id)initWithPersistentContainer:(id)container;
- (id)additionalItemsForObject:(id)object;
- (id)additionalUniqueIdentifiersToDeleteForObject:(id)object;
- (_Bool)isPaperKitOrSynapseAttachment:(id)attachment;
- (id)searchableItemForSynapseContentItem:(id)item note:(id)note attachment:(id)attachment;
- (id)searchableItemResultForObject:(id)object;
- (id)synapseItemsForObject:(id)object;

@end


@interface ICNote : ICCloudSyncingObject <ICSearchIndexableNote, ICCloudObject, ICTTMergeableStringDelegate, ICNoteUI, ICDerivedAttributeProviding>

@property (readonly, nonatomic) _Bool hasRecentExternalEdits;
@property (readonly, copy, nonatomic) CKRecordID *recordID;
@property (readonly, copy, nonatomic) NSString *recordType;
@property (readonly, nonatomic) _Bool needsToSaveUserSpecificRecord;
@property (readonly, nonatomic) _Bool wantsUserSpecificRecord;
@property (readonly, copy, nonatomic) NSString *userSpecificRecordType;
@property (readonly, copy, nonatomic) CKRecordID *userSpecificRecordID;
@property (readonly, retain, nonatomic) CKRecord *userSpecificServerRecord;
@property (readonly, nonatomic) _Bool needsToBeDeletedFromCloud;
@property (readonly, nonatomic) _Bool needsToBePushedToCloud;
@property (readonly, nonatomic) _Bool needsToBeFetchedFromCloud;
@property (readonly, nonatomic) _Bool isInICloudAccount;
@property (readonly, nonatomic) _Bool isValidObject;
@property (readonly, copy, nonatomic) NSString *loggingDescription;
@property (readonly, nonatomic) _Bool shouldAlwaysDownloadAssets;
@property (readonly, nonatomic) unsigned long long numberOfCommonRecordAssets;
@property (readonly, nonatomic) unsigned long long numberOfUserSpecificRecordAssets;
@property (readonly, nonatomic) _Bool hasPresentableContent;
@property (readonly, nonatomic) NSManagedObjectID *objectID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) long long databaseScope;
@property (readonly, nonatomic) _Bool hasTags;
@property (readonly, nonatomic) _Bool isSearchIndexableNote;
@property (readonly, nonatomic) _Bool isModernNote;
@property (readonly, nonatomic) NSSet *noteCellKeyPaths;
@property (readonly, nonatomic) _Bool hasUnreadChanges;
@property (readonly, nonatomic) _Bool isDeletedOrInTrash;
@property (readonly, nonatomic) _Bool isPinned;
@property (readonly, nonatomic) _Bool isPinnable;
@property (readonly, nonatomic) long long currentStatus;
@property (readonly, nonatomic) _Bool isPasswordProtected;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSAttributedString *attributedTitle;
@property (readonly, copy, nonatomic) NSString *trimmedTitle;
@property (readonly, copy, nonatomic) NSAttributedString *trimmedAttributedTitle;
@property (readonly, copy, nonatomic) NSString *noteAsPlainTextWithoutTitle;
@property (readonly, copy, nonatomic) NSAttributedString *noteWithoutTitle;
@property (readonly, copy, nonatomic) NSString *contentInfoText;
@property (readonly, copy, nonatomic) NSAttributedString *attributedContentInfoText;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedViaICloudFolder;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) NSArray *authorsExcludingCurrentUser;
@property (readonly, nonatomic) _Bool isUnsupported;
@property (readonly, copy, nonatomic) NSString *folderName;
@property (readonly, copy, nonatomic) NSString *folderNameForNoteList;
@property (readonly, nonatomic) id <ICFolderObject> folder;
@property (readonly, nonatomic) NSString *folderManagedIdentifier;
@property (readonly, nonatomic) NSArray *hashtagContentIdentifiers;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (readonly, copy, nonatomic) NSString *widgetInfoText;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (nonatomic, readonly) _Bool objc_hasRecentExternalEdits;
@property (retain, nonatomic) ICTTMergeableStringVersionedDocument *document;
@property (retain, nonatomic) ICFolder *primitiveFolder;
@property _Bool wasAuthenticatedBeforeTurningIntoFault;
@property (readonly, nonatomic) ICMergeableDictionary *replicaIDToUserID;
@property (retain, nonatomic) ICOutlineState *outlineState;
@property (retain, nonatomic) ICSelectorDelayer *updateLinksSelectorDelayer;
@property (retain, nonatomic) id reservedForTextContentStorage;
@property (retain, nonatomic) id reservedForCollaborationColorManager;
@property (readonly, nonatomic) ICTTMergeableStringVersionedDocument *documentWithoutCreating;
@property (retain, nonatomic) NSString *legacyManagedObjectIDURIRepresentation;
@property (copy, nonatomic) ICTTVectorMultiTimestamp *archivedTimestamp;
@property (retain, nonatomic) NSData *lastViewedTimestampData;
@property (retain, nonatomic) NSData *lastNotifiedTimestampData;
@property (retain, nonatomic) NSString *selectedInkIdentifier;
@property (retain, nonatomic) NSString *selectedInkColorString;
@property (nonatomic) _Bool needsToSaveLastViewedTimestamp;
@property (nonatomic) _Bool shouldAddMediaAsynchronously;
@property (nonatomic) _Bool preventReleasingTextStorage;
@property (retain, nonatomic) id <ICDocumentMergeControlling> documentMergeController;
@property (copy, nonatomic) NSArray *allDocumentMergeControllers;
@property (retain, nonatomic) NSData *outlineStateData;
@property (retain, nonatomic) NSData *replicaIDToUserIDDictData;
@property (readonly, nonatomic) id <ICNoteCryptoStrategy> cryptoStrategy;
@property (retain) NSData *decryptedData;
@property _Bool isRecoveringCryptoWrappedKey;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) NSDate *lastOpenedDate;
@property (retain, nonatomic) NSNumber *noteHasChanges;
@property (retain, nonatomic) NSString *snippet;
@property (retain, nonatomic) NSAttributedString *attributedSnippet;
@property (retain, nonatomic) NSString *widgetSnippet;
@property (retain, nonatomic) ICAttachment *titleSourceAttachment;
@property (retain, nonatomic) NSSet *attachments;
@property (retain, nonatomic) NSSet *inlineAttachments;
@property (retain, nonatomic) NSSet *participants;
@property (retain, nonatomic) NSDate *folderModificationDate;
@property (retain, nonatomic) ICNoteData *noteData;
@property (retain, nonatomic) NSDate *legacyModificationDateAtImport;
@property (retain, nonatomic) NSString *legacyContentHashAtImport;
@property (retain, nonatomic) NSString *legacyImportDeviceIdentifier;
@property (retain, nonatomic) NSNumber *legacyNoteWasPlainText;
@property (retain, nonatomic) NSString *thumbnailAttachmentIdentifier;
@property (nonatomic) short paperStyleType;
@property (retain, nonatomic) NSDate *lastViewedModificationDate;
@property (nonatomic) _Bool isPerformingMerge;
@property (nonatomic) _Bool isNewNoteWithHashtagsInsertedIntoBody;
@property (copy, nonatomic) NSString *hostApplicationIdentifier;
@property (nonatomic) short attachmentViewType;
@property (readonly, nonatomic) NSSet *distinctAttachmentViewTypes;
@property (retain, nonatomic) NSDate *lastActivitySummaryViewedDate;
@property (retain, nonatomic) NSDate *lastActivityRecentUpdatesViewedDate;
@property (retain, nonatomic) NSDate *recentUpdatesGenerationDate;
@property (retain, nonatomic) NSDate *recentUpdatesFirstSeenDate;
@property (retain, nonatomic) NSDate *lastAttributionsViewedDate;
@property (retain, nonatomic) NSNumber *hasChecklist;
@property (retain, nonatomic) NSNumber *hasChecklistInProgress;
@property (retain, nonatomic) NSNumber *hasSystemTextAttachments;
@property (retain, nonatomic) NSNumber *hasEmphasis;
@property (nonatomic) _Bool showsCollaboratorCursors;
@property (readonly, nonatomic) ICTTVectorMultiTimestamp *timestamp;
@property (copy, nonatomic) ICTTVectorMultiTimestamp *lastViewedTimestamp;
@property (copy, nonatomic) ICTTVectorMultiTimestamp *lastNotifiedTimestamp;
@property (retain, nonatomic) NSDate *lastNotifiedDate;
@property (nonatomic) _Bool needsRefresh;
@property (nonatomic) short preferredBackgroundType;
@property (nonatomic) _Bool isSystemPaper;
@property (readonly, nonatomic) _Bool containsAttachmentWithDeepLink;
@property (readonly, nonatomic) NSURL *paperCoherenceContextURL;
@property (readonly, nonatomic) _Bool isSharedAndEmpty;
@property (readonly, nonatomic) _Bool needsInitialDerivedAttributesUpdate;

/* class methods */
+ (id)predicateForPinnedNotes;
+ (id)newCloudObjectForRecord:(id)record accountID:(id)id context:(id)context;
+ (id)newObjectWithIdentifier:(id)identifier folder:(id)folder;
+ (id)notesMatchingPredicate:(id)predicate context:(id)context;
+ (id)predicateForNotesWithChecklists;
+ (id)accountIdentifiersOfNotes:(id)notes;
+ (id)allNotesInContext:(id)context;
+ (id)allPasswordProtectedNoteIdentifiersInContext:(id)context;
+ (_Bool)containsUndeletableNotes:(id)notes;
+ (_Bool)containsUnduplicatableNotes:(id)notes;
+ (_Bool)containsUnmovableNotes:(id)notes;
+ (id)contentInfoAttributedTextWithSnippet:(id)snippet attachmentContentInfoType:(short)type attachmentContentInfoCount:(long long)count account:(id)account;
+ (id)contentInfoTextWithSnippet:(id)snippet attachmentContentInfoType:(short)type attachmentContentInfoCount:(long long)count account:(id)account;
+ (unsigned long long)countOfAllNotesInContext:(id)context;
+ (unsigned long long)countOfNotesMatchingPredicate:(id)predicate context:(id)context;
+ (unsigned long long)countOfPasswordProtectedNotesInContext:(id)context;
+ (unsigned long long)countOfVisibleNotesInContext:(id)context;
+ (unsigned long long)countOfVisiblePasswordProtectedNotesInAccount:(id)account;
+ (void)createNoteForAirDropDocument:(id)document processAttributedString:(id /* block */)string completion:(id /* block */)completion;
+ (id)defaultTitleForEmptyNote;
+ (void)deleteEmptyNote:(id)note;
+ (void)deleteNote:(id)note;
+ (_Bool)didShowExceededStorageQuotaAlertForNoteWithIdentifier:(id)identifier;
+ (void)enumerateNotesInContext:(id)context batchSize:(unsigned long long)size visibleOnly:(_Bool)only saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)existingCloudObjectForRecordID:(id)id accountID:(id)id context:(id)context;
+ (_Bool)hasNoteMatchingPredicate:(id)predicate context:(id)context;
+ (id)keyPathsForValuesAffectingCanBeSharedViaICloud;
+ (id)keyPathsForValuesAffectingCloudAccount;
+ (id)keyPathsForValuesAffectingHasUnreadChanges;
+ (id)keyPathsForValuesAffectingIsDeletable;
+ (id)keyPathsForValuesAffectingIsEditable;
+ (id)keyPathsForValuesAffectingPrefersLightBackground;
+ (id)keyPathsForValuesAffectingRecentUpdatesGenerationDate;
+ (unsigned long long)maxNoteAttachments;
+ (unsigned long long)maxNoteTextLength;
+ (id)newEmptyNoteInContext:(id)context;
+ (id)newEmptyNoteInFolder:(id)folder;
+ (id)newEmptyNoteWithIdentifier:(id)identifier folder:(id)folder;
+ (id)newEmptyNoteWithUUID:(id)uuid folder:(id)folder;
+ (id)newFetchRequestForNotes;
+ (id)newNoteWithoutIdentifierInAccount:(id)account;
+ (id)newNoteWithoutIdentifierInFolder:(id)folder;
+ (id)newObjectWithIdentifier:(id)identifier context:(id)context;
+ (id)newPlaceholderObjectForRecordName:(id)name account:(id)account;
+ (id)newPlaceholderObjectForRecordName:(id)name accountID:(id)id context:(id)context;
+ (id)noteIdentifiersMatchingPredicate:(id)predicate context:(id)context;
+ (id)noteWithIdentifier:(id)identifier accountID:(id)id context:(id)context;
+ (id)noteWithIdentifier:(id)identifier context:(id)context;
+ (id)noteWithIdentifier:(id)identifier includeDeleted:(_Bool)deleted accountID:(id)id context:(id)context;
+ (id)noteWithIdentifier:(id)identifier includeDeleted:(_Bool)deleted context:(id)context;
+ (id)noteWithLegacyManagedObjectID:(id)id context:(id)context;
+ (id)noteWithUUID:(id)uuid context:(id)context;
+ (_Bool)notes:(id)notes containSharedNotesNotSharedViaFolder:(id)folder;
+ (id)notesContainingHashtagWithStandarizedContent:(id)content context:(id)context;
+ (id)passwordProtectedNoteIdentifiersForAccount:(id)account;
+ (id)predicateForNote:(id)note;
+ (id)predicateForNotesInAccountWithIdentifier:(id)identifier;
+ (id)predicateForSearchableNotesInContext:(id)context;
+ (id)predicateForSystemPaperNotes;
+ (id)predicateForSystemPaperNotesNotInTrash;
+ (id)predicateForVisibleNotesInContext:(id)context;
+ (id)predicateForVisibleNotesIncludingTrash:(_Bool)trash includingSystemPaper:(_Bool)paper includingMathNotes:(_Bool)notes includingCallNotes:(_Bool)notes inContext:(id)context;
+ (void)purgeNote:(id)note;
+ (id)refreshAllOfNoteWithIdentifier:(id)identifier context:(id)context;
+ (void)setDidShowExceededStorageQuotaAlert:(_Bool)alert forNoteWithIdentifier:(id)identifier;
+ (id)snippetForPasswordProtectedNote:(id)note;
+ (_Bool)supportsActivityEvents;
+ (_Bool)supportsNotesVersionTracking;
+ (_Bool)supportsUserSpecificRecords;
+ (id)systemPaperNotesFetchRequest;
+ (id)visibleNoteWithIdentifier:(id)identifier context:(id)context;
+ (id)visibleNotesInContext:(id)context;

/* instance methods */
- (void)willSave;
- (void)didSave;
- (_Bool)isSharable;
- (_Bool)isEditable;
- (_Bool)isVisible;
- (id)attributedString;
- (void)willTurnIntoFault;
- (_Bool)supportsDeletionByTTL;
- (_Bool)isEmpty;
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (unsigned long long)performMerge:(id /* block */)merge;
- (id)cloudAccount;
- (void)endEditing;
- (void)dealloc;
- (void)prepareForDeletion;
- (id)uuid;
- (void)beginEditing;
- (void)awakeFromFetch;
- (id)recordZoneName;
- (_Bool)canBeSharedViaICloud;
- (void)didRefresh:(_Bool)refresh;
- (void)willRefresh:(_Bool)refresh;
- (void)setMarkedForDeletion:(_Bool)deletion;
- (id)shareType;
- (_Bool)hasThumbnailImage;
- (void)addUndoCommand:(id)command;
- (id)mergeableString;
- (id)addURLAttachmentWithURL:(id)url;
- (_Bool)wantsUndoCommands;
- (id)allDrawings;
- (id)visibleAttachments;
- (id)addAttachmentWithData:(id)data filename:(id)filename;
- (void)mergeFoldersFromRecord:(id)record account:(id)account;
- (id)primaryEncryptedDataFromRecord:(id)record;
- (void)updateDerivedAttributesIfNeeded;
- (id)addAttachmentWithRemoteFileURL:(id)url;
- (void)addMediaToAttachment:(id)attachment withBlock:(id /* block */)block;
- (_Bool)allowsExporting;
- (void)didAcceptShare:(id)share;
- (void)markForDeletion;
- (id)noteAsPlainText;
- (id)titleForLinking;
- (unsigned long long)visibleTopLevelAttachmentsCount;
- (void)_updateLinksOnMainThreadSelectorDelayer;
- (id)abstractAttachmentsInOrder;
- (id)addAttachment;
- (id)addAttachmentWithFileURL:(id)url;
- (id)addAttachmentWithFileURL:(id)url filename:(id)filename;
- (id)addAttachmentWithFileURL:(id)url filename:(id)filename updateFileBasedAttributes:(_Bool)attributes analytics:(_Bool)analytics;
- (id)addAttachmentWithFileURL:(id)url updateFileBasedAttributes:(_Bool)attributes analytics:(_Bool)analytics;
- (id)addAttachmentWithFileWrapper:(id)wrapper;
- (id)addAttachmentWithIdentifier:(id)identifier;
- (id)addAttachmentWithUTI:(id)uti;
- (id)addAttachmentWithUTI:(id)uti data:(id)data filename:(id)filename;
- (id)addAttachmentWithUTI:(id)uti data:(id)data filename:(id)filename updateFileBasedAttributes:(_Bool)attributes analytics:(_Bool)analytics regulatoryLogging:(_Bool)logging;
- (id)addAttachmentWithUTI:(id)uti data:(id)data filenameExtension:(id)extension;
- (id)addAttachmentWithUTI:(id)uti identifier:(id)identifier urlString:(id)string analytics:(_Bool)analytics;
- (id)addAttachmentWithUTI:(id)uti identifier:(id)identifier urlString:(id)string analytics:(_Bool)analytics regulatoryLogging:(_Bool)logging;
- (id)addAttachmentWithUTI:(id)uti withURL:(id)url;
- (id)addAttachmentWithUTI:(id)uti withURL:(id)url filename:(id)filename updateFileBasedAttributes:(_Bool)attributes analytics:(_Bool)analytics;
- (id)addAttachmentWithUTI:(id)uti withURL:(id)url updateFileBasedAttributes:(_Bool)attributes analytics:(_Bool)analytics;
- (id)addAudioAttachmentWithIdentifier:(id)identifier;
- (id)addGalleryAttachmentWithIdentifier:(id)identifier;
- (id)addInlineAttachmentWithIdentifier:(id)identifier;
- (void)addInlineAttachments:(id)attachments;
- (void)addInlineAttachmentsObject:(id)object;
- (id)addInlineDrawingAttachmentWithAnalytics:(_Bool)analytics;
- (void)addNoteBodyToRecord:(id)record forApproach:(long long)approach mergeableFieldState:(id)state;
- (id)addPaperDocumentAttachmentWithIdentifier:(id)identifier subtype:(id)subtype;
- (void)addShareParticipantsToAttributeSet:(id)set;
- (id)addSynapseLinkAttachmentWithContentItem:(id)item;
- (id)addSystemPaperAttachmentWithIdentifier:(id)identifier;
- (id)addTableAttachment;
- (id)addTableAttachmentWithTableData:(id)data;
- (id)addTableAttachmentWithText:(id)text;
- (_Bool)addUserID:(id)id forReplicaID:(id)id;
- (id)additionalSearchIndexablesForChangedKeys:(id)keys;
- (id)allAttachmentsIncludingSubAttachments;
- (id)allNoteTextAttachmentsIncludingSubAttachments:(_Bool)attachments;
- (id)allNoteTextInlineAttachments;
- (_Bool)allowsNewTextLength:(unsigned long long)length;
- (id)anyVisibleInstanceOfHashtag:(id)hashtag;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (id)associatedNoteParticipants;
- (long long)attachmentContentInfoCount;
- (short)attachmentContentInfoType;
- (_Bool)attachmentCountExceeded;
- (_Bool)attachmentExceedsMaxSizeAllowed:(unsigned long long)allowed;
- (id)attachmentForWebThumbnail;
- (id)attachmentWithIdentifier:(id)identifier;
- (id)attachmentsInOrder;
- (id)attachmentsWithUTType:(id)uttype;
- (_Bool)canAddAttachment;
- (_Bool)canAddAttachments:(unsigned long long)attachments;
- (_Bool)canBeRootShareObject;
- (void)changePinStatusIfPossible;
- (id)childCloudObjects;
- (id)childCloudObjectsForMinimumSupportedVersionPropagation;
- (void)clearDecryptedData;
- (void)clearRecentUpdatesGenerationDateIfNeeded;
- (_Bool)containsAttachmentsUnsupportedInPasswordProtection;
- (_Bool)containsPlaceholderBlockOrInlineAttachments;
- (id)cryptoStrategyProtocol;
- (id)csPersonForShareParticipant:(id)participant;
- (id)decryptTextDataOrSaveAsUnappliedRecordIfNotAuthenticated:(id)authenticated;
- (void)deduplicateSelfAndCreateNewObjectFromRecord:(id)record;
- (void)deleteFromLocalDatabase;
- (id)descendantsNeedingOnDemandAssetFetchWithContext:(id)context shouldFetchObject:(id /* block */)object;
- (void)didChangeNoteText;
- (void)didFetchUserSpecificRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)ensureHashtagsExistInDestinationAccount;
- (void)enumerateAbstractAttachmentsInOrderUsingBlock:(id /* block */)block;
- (void)enumerateAttachmentsInOrderUsingBlock:(id /* block */)block;
- (void)enumerateInlineAttachmentsInOrderUsingBlock:(id /* block */)block;
- (void)fixBrokenReferencesWithError:(id)error;
- (id)folderReferenceFromRecord:(id)record;
- (_Bool)hasAllMandatoryFields;
- (_Bool)hasChecklistOnlyInProgress:(_Bool)progress;
- (_Bool)hasExpectedReferenceActionsInUserSpecificRecord:(id)record;
- (_Bool)hasLoadedDocument;
- (_Bool)hasVisibleInlineAttachments;
- (id)ic_loggingValues;
- (void)inlineAssetsForRecord:(id)record;
- (id)inlineAttachmentWithICTTAttachment:(id)icttattachment;
- (long long)intrinsicNotesVersionForScenario:(unsigned long long)scenario;
- (_Bool)isCallNote;
- (_Bool)isDuplicatable;
- (_Bool)isLockable;
- (_Bool)isMathNote;
- (id)makeCloudKitRecordForApproach:(long long)approach mergeableFieldState:(id)state;
- (id)makeUserSpecificCloudKitRecordForApproach:(long long)approach;
- (void)markActivitySummaryViewed;
- (void)markAsCallNoteIfAttachmentIsCallRecording;
- (void)markAsCallNoteIfNeeded:(_Bool)needed;
- (void)markAsMathNoteIfNeeded:(_Bool)needed;
- (void)markAsSystemPaperIfNeeded:(_Bool)needed;
- (void)markLastActivityRecentUpdatesViewed;
- (_Bool)mergeCloudKitRecord:(id)record account:(id)account approach:(long long)approach;
- (_Bool)mergeCloudKitRecord:(id)record accountID:(id)id approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeCloudKitRecord:(id)record mergePolicy:(long long)policy account:(id)account approach:(long long)approach mergeableFieldState:(id)state;
- (_Bool)mergeDataFromUserSpecificRecord:(id)record accountID:(id)id;
- (void)mergeEncryptedData:(id)data mergeConflict:(id)conflict;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)mergeNotePrimitiveData;
- (long long)mergePolicyForRecord:(id)record;
- (unsigned long long)mergeReplicaIDToUserID:(id)id;
- (void)mergeTextDataFromRecord:(id)record mergePolicy:(long long)policy mergeableFieldState:(id)state;
- (unsigned long long)mergeWithNoteData:(id)data;
- (id)minimumNotesVersionForAllParticipants;
- (id)minimumNotesVersionForUserIDs:(id)ids;
- (void)moveBackToTrashAfterQuotaExceededErrorOnRecovery;
- (_Bool)needsToDeleteShare;
- (id)newAirDropDocument;
- (id)notesVersionForParticipant:(id)participant;
- (id)notesVersionForUserID:(id)id;
- (void)notifyAttachmentsNoteWillMoveToRecentlyDeletedFolder;
- (_Bool)objectFailedToBePushedToCloudWithOperation:(id)operation recordID:(id)id error:(id)error;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id;
- (void)objectWasFetchedFromCloudWithRecord:(id)record accountID:(id)id force:(_Bool)force;
- (void)objectWasPushedToCloudWithOperation:(id)operation serverRecord:(id)record;
- (id)objectsToBeDeletedBeforeThisObject;
- (id)parentCloudObject;
- (id)parentCloudObjectModificationDate;
- (id)parentEncryptableObject;
- (id)participantForReplicaID:(id)id;
- (void)persistPendingChanges;
- (_Bool)prefersLightBackground;
- (id)primaryEncryptedData;
- (id)quotedTitle;
- (struct _NSRange)rangeForAttachment:(id)attachment;
- (struct _NSRange)rangeForSnippetWithTitleRange:(struct _NSRange)range;
- (struct _NSRange)rangeForTitle:(_Bool *)title;
- (void)refreshNoteTextFromDataStore;
- (_Bool)regenerateTitle:(_Bool)title snippet:(_Bool)snippet;
- (_Bool)regenerateTitle:(_Bool)title snippet:(_Bool)snippet isNewNote:(_Bool)note;
- (_Bool)regenerateTitleAndSnippetIfNecessaryForEdit:(unsigned long long)edit range:(struct _NSRange)range changeInLength:(long long)length;
- (void)removeInlineAttachments:(id)attachments;
- (void)removeInlineAttachmentsObject:(id)object;
- (void)replaceWithDocument:(id)document;
- (_Bool)requiresLegacyTombstoneAfterDeletion;
- (_Bool)saveNoteData;
- (id)searchableString;
- (void)setCryptoInitializationVector:(id)vector;
- (void)setCryptoTag:(id)tag;
- (void)setLegacyManagedObjectID:(id)id;
- (void)setNeedsInitialFetchFromCloud:(_Bool)cloud;
- (void)setPrimaryEncryptedData:(id)data;
- (id)shareTitle;
- (_Bool)shouldReleaseDocumentWhenTurningIntoFault;
- (_Bool)shouldSyncMinimumSupportedNotesVersion;
- (id)showsCollaboratorCursorsUserDefaultsKey;
- (id)textDataDecryptedIfNecessary;
- (unsigned long long)textOffsetAtSearchIndex:(unsigned long long)index inSearchableString:(id)string;
- (struct _NSRange)textRangeForSearchRange:(struct _NSRange)range inSearchableString:(id)string;
- (_Bool)textStorageHasAttribute:(id)attribute;
- (id)titleForParagraphID:(id)id;
- (void)turnAttachmentsIntoFaults;
- (void)unmarkForDeletion;
- (void)updateArchivedAndLastViewedTimeStampsAfterSavingNoteData;
- (void)updateAttachmentViewTypeAndPropagateToAttachments:(short)attachments;
- (void)updateChangeCountWithReason:(id)reason;
- (_Bool)updateDeviceReplicaIDsToUserIDIfNeeded;
- (_Bool)updateLastViewedTimestampWithCurrentTimestamp;
- (void)updateLinksWhenPossible;
- (void)updateTimestampWithUnserializedChanges;
- (id)userIDForReplicaID:(id)id;
- (id)visibleAttachmentsWithType:(short)type;
- (id)visibleInlineAttachments;
- (id)visibleTopLevelAttachments;
- (id)widgetSnippetByEnumeratingAttachments;
- (void)willUpdateDeviceReplicaIDsToNotesVersion:(long long)version;
- (void)writeCurrentTimestampToMergeableFieldStateIfNecessary:(id)necessary;

@end


@interface ICNoteAllAccountVisibilityTesting : NSObject <ICNoteVisibilityTesting>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedInstance;

/* instance methods */
- (id)predicateForSearchableAttachments;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (id)predicateForSearchableNotes;

@end


@interface ICNoteContext : NSObject <ICNoteContainer>

@property (nonatomic) unsigned long long contextOptions;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) ICNotesCrossProcessChangeCoordinator *crossProcessChangeCoordinator;
@property (retain, nonatomic) ICManagedObjectContextUpdater *contextUpdater;
@property _Bool saving;
@property (retain, nonatomic) ICAccountUtilities *accountUtilities;
@property (retain, nonatomic) NSTimer *trashDeletionTimer;
@property (retain, nonatomic) NSManagedObjectContext *backgroundTaskWorkerContext;
@property (nonatomic) _Bool shouldEnsureLocalAccount;
@property (retain, nonatomic) NSDictionary *persistentStoresByAccountId;
@property (nonatomic) unsigned long long countOfPerformBackgroundTask;
@property (nonatomic) _Bool delaySaving;
@property (readonly, nonatomic) _Bool isSharedContext;
@property (readonly) ICPersistentContainer *persistentContainer;
@property (retain, nonatomic) ICNote *currentNote;
@property (retain, nonatomic) NSError *databaseOpenError;
@property (nonatomic) _Bool databaseOpenFailedDueToLowDiskSpace;
@property (retain, nonatomic) NSTimer *updateAttachmentLocationsTimer;
@property (readonly, nonatomic) ICAccount *noteContainerAccount;
@property (readonly, nonatomic) ICFolderCustomNoteSortType *customNoteSortType;
@property (readonly, nonatomic) _Bool isSharedViaICloud;
@property (readonly, nonatomic) _Bool isSharedReadOnly;
@property (readonly, nonatomic) _Bool isAllNotesContainer;
@property (readonly, nonatomic) _Bool canBeSharedViaICloud;
@property (readonly, nonatomic) _Bool supportsEditingNotes;
@property (readonly, nonatomic) _Bool isTrashFolder;
@property (readonly, nonatomic) _Bool isModernCustomFolder;
@property (readonly, nonatomic) NSString *containerIdentifier;
@property (readonly, nonatomic) NSArray *visibleNotes;
@property (readonly, nonatomic) _Bool supportsDateHeaders;
@property (readonly, nonatomic) long long dateHeadersType;
@property (readonly, nonatomic) _Bool isShowingDateHeaders;
@property (readonly, nonatomic) unsigned long long visibleNotesCount;
@property (readonly, nonatomic) _Bool hasVisibleNotes;
@property (readonly, copy, nonatomic) NSString *titleForNavigationBar;
@property (readonly, copy, nonatomic) NSString *titleForTableViewCell;
@property (readonly, copy, nonatomic) NSString *accountName;
@property (readonly, nonatomic) NSArray *visibleSubFolders;
@property (copy, nonatomic) NSData *subFolderOrderMergeableData;
@property (readonly, nonatomic) _Bool deleted;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)workerManagedObjectContextForContainer:(id)container;
+ (_Bool)isActive;
+ (void)useContainerNamed:(id)named;
+ (void)crashThisApp;
+ (id)sharedContext;
+ (void)resetAppContainer;
+ (id)persistentStoreCoordinatorName;
+ (_Bool)hasContextOptions:(unsigned long long)options;
+ (void)resetAppState;
+ (id)filenameFromFileWrapper:(id)wrapper;
+ (void)startSharedContextWithOptions:(unsigned long long)options;
+ (_Bool)hasSharedContext;
+ (void)markOldTrashedNotesForDeletionInContext:(id)context;
+ (void)setLegacyNotesDisabled:(_Bool)disabled;
+ (id)performBackgroundTaskSerialQueue;
+ (_Bool)isDaemonProcess;
+ (_Bool)updateSharedStateFile:(id)file toState:(_Bool)state error:(id *)error;
+ (void)clearSharedContext;
+ (id)initializeSearchIndexerDataSourceWithPersistentContainer:(id)container;
+ (void)enableLocalAccount;
+ (id)snapshotManagedObjectContextForContainer:(id)container;
+ (_Bool)legacyNotesDisabled;

/* instance methods */
- (void)accountStoreDidChange:(id)change;
- (void)refreshAll;
- (void)refreshPersistentStoresByAccountIdFromPersistentStores:(id)stores;
- (void)purgeEverything;
- (id)snapshotManagedObjectContext;
- (id)predicateForVisibleNotes;
- (id)allICloudACAccounts;
- (_Bool)save:(id *)save;
- (id)predicateForSearchableAttachments;
- (id)persistentStoreCoordinator;
- (void)performBackgroundTask:(id /* block */)task;
- (id)persistentContainerQueue;
- (id)objectID;
- (void)managedObjectContextDidSave:(id)save;
- (void)saveSubFolderMergeableDataIfNeeded;
- (_Bool)isDeleted;
- (id)storeFilenameForAccountIdentifier:(id)identifier;
- (void)loadAdditionalPersistentStores;
- (void)applicationWillTerminate;
- (void)managedObjectContextUpdaterDidMerge:(id)merge;
- (void)setupTrashDeletionTimer;
- (void)addOrDeleteLocalAccountIfNecessary;
- (id)noteVisibilityTestingForSearchingAccount;
- (void)cleanupAdditionalPersistentStores;
- (_Bool)hasContextOptions:(unsigned long long)options;
- (void)cloudContextFetchRecordChangeOperationDidFinish:(id)finish;
- (id)customNoteSortTypeValue;
- (void)startSearchIndexerChangeObservingIfNecessary;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (_Bool)isSaving;
- (void)accountsDidChange:(id)change;
- (void)purgeDeletedObjectsInManagedObjectContext:(id)context;
- (id)predicateForPinnedNotes;
- (id)persistentStoreForAccountID:(id)id;
- (_Bool)saveImmediately;
- (void)managedObjectContextUpdaterDidChangeObjectWithID:(id)id;
- (void)dealloc;
- (id)defaultPersistentStoreFromPersistentStores:(id)stores;
- (void)performSnapshotBackgroundTask:(id /* block */)task;
- (_Bool)noteIsVisible:(id)visible;
- (id)inMemoryPersistentStoreFromPersistentStores:(id)stores;
- (id)workerManagedObjectContext;
- (id)primaryICloudACAccount;
- (void)updateAccountsIfNecessary;
- (id)initWithOptions:(unsigned long long)options;
- (void)reloadPersistentContainer;
- (void)setupCrossProcessChangeCoordinator;
- (void)startIndexingWithCoreSpotlightDelegateForDescription:(id)description coordinator:(id)coordinator;
- (_Bool)recoverFromSaveError;
- (void)ensureModernAccountExistsInContext:(id)context;
- (_Bool)hasAnyContextOptions:(unsigned long long)options;
- (void)applyDateHeadersType:(long long)type;
- (void)createAdditionalPersistentStoresWithAccountIdentifiers:(id)identifiers completionBlock:(id /* block */)block;
- (void)updateSubFolderMergeableDataChangeCount;
- (void)clearPersistentContainer;
- (_Bool)save;
- (_Bool)mergeWithSubFolderMergeableData:(id)data;
- (void)deleteEverything;
- (void)updateAccounts;
- (void)createAdditionalPersistentStoresWithAccountIdentifiers:(id)identifiers persistentContainer:(id)container;
- (void)destroyPersistentStore;
- (id)predicateForSearchableNotes;
- (void)invalidateNotificationObservers;

@end


@interface ICNoteCryptoStrategyV1 : ICCloudSyncingObjectCryptoStrategyV1 <ICNoteCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)decrypt;
- (id)unwrappedKey;
- (void)correctCryptoTagAndIVIfNecessary;
- (id)decryptNotePrimitiveData;
- (id)decryptTextDataOrSaveAsUnappliedRecordIfNotAuthenticated:(id)authenticated;
- (_Bool)mainKeyDecryptsPrimaryData:(id)data;
- (void)mergeEncryptedData:(id)data mergeConflict:(id)conflict;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)recoverMissingCryptoWrappedKeyIfNeededWithMainKey:(id)key;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)writeEncryptedNoteData:(id)data;

@end


@interface ICNoteCryptoStrategyV1Neo : ICCloudSyncingObjectCryptoStrategyV1Neo <ICNoteCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)decrypt;
- (id)decryptNotePrimitiveData;
- (id)decryptTextDataOrSaveAsUnappliedRecordIfNotAuthenticated:(id)authenticated;
- (void)mergeEncryptedData:(id)data mergeConflict:(id)conflict;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (_Bool)rewrapWithMainKey:(id)key;
- (_Bool)writeEncryptedNoteData:(id)data;

@end


@interface ICNoteCryptoStrategyV2 : ICCloudSyncingObjectCryptoStrategyV2 <ICNoteCryptoStrategy>

@property (readonly, weak, nonatomic) ICCloudSyncingObject *object;
@property (readonly, nonatomic) long long intrinsicNotesVersion;
@property (readonly, nonatomic) _Bool canAuthenticate;
@property (readonly, nonatomic) _Bool isAuthenticated;
@property (readonly, nonatomic) _Bool hasPassphraseSet;
@property (readonly, copy, nonatomic) NSString *passphraseHint;
@property (readonly, nonatomic) ICEncryptionMetadata *primaryMetadata;
@property (readonly, nonatomic) ICEncryptionKey *primaryWrappedKey;
@property (readonly, nonatomic) ICEncryptionObject *primaryEncryptionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)decrypt;
- (id)decryptNotePrimitiveData;
- (id)decryptTextDataOrSaveAsUnappliedRecordIfNotAuthenticated:(id)authenticated;
- (id)encryptedDataFromRecord:(id)record;
- (void)mergeEncryptedData:(id)data mergeConflict:(id)conflict;
- (_Bool)mergeEncryptedDataFromRecord:(id)record;
- (void)serializeToNoteDataAndUpdateArchivedAndLastViewedTimeStamps:(id)stamps;
- (_Bool)writeEncryptedNoteData:(id)data;

@end


@interface ICNoteData : NSManagedObject

@property (nonatomic) _Bool settingNoteData;
@property (retain, nonatomic) NSData *cryptoInitializationVector;
@property (retain, nonatomic) NSData *cryptoTag;
@property (nonatomic) _Bool needsToBeSaved;
@property (nonatomic) _Bool didBlockLastSave;
@property (retain, nonatomic) NSData *data;
@property (retain, nonatomic) ICNote *note;
@property (readonly, nonatomic) NSData *primitiveData;

/* instance methods */
- (void)willSave;
- (void)willAccessValueForKey:(id)key;
- (_Bool)isSettingNoteData;
- (_Bool)saveNoteDataIfNeeded;

@end


@interface ICNoteMergePolicy : NSMergePolicy

/* instance methods */
- (void)resolveConflict:(id)conflict forWallClockMergeablesInObject:(id)object;
- (_Bool)resolveConflictingFolder:(id)folder with:(id)with;
- (_Bool)resolveConflictingAttachment:(id)attachment withInlineAttachment:(id)attachment;
- (id)initWithMergeType:(unsigned long long)type;
- (_Bool)resolveConflictingAttachmentPreviewImage:(id)image with:(id)with;
- (_Bool)resolveConstraintConflict:(id)conflict;
- (_Bool)resolveConflictingDeviceMigrationState:(id)state with:(id)with;
- (_Bool)resolveConflictingLegacyTombstone:(id)tombstone with:(id)with;
- (_Bool)resolveConflictingHashtag:(id)hashtag with:(id)with;
- (id)init;
- (_Bool)resolveConflictingAccountData:(id)data with:(id)with;
- (_Bool)resolveConflictingAccount:(id)account with:(id)with;
- (_Bool)resolveConflictingMedia:(id)media with:(id)with;
- (_Bool)resolveConflictingNote:(id)note with:(id)with;
- (_Bool)resolveOptimisticLockingVersionConflicts:(id)conflicts error:(id *)error;
- (_Bool)resolveConflictingAttachment:(id)attachment with:(id)with;
- (_Bool)resolveConflictingInlineAttachment:(id)attachment with:(id)with;
- (_Bool)resolveConstraintConflicts:(id)conflicts error:(id *)error;
- (_Bool)resolveConflictingInvitation:(id)invitation with:(id)with;

@end


@interface ICNoteParticipant : NSManagedObject

@property (retain, nonatomic) ICNote *note;
@property (retain, nonatomic) NSString *participantID;
@property (retain, nonatomic) NSString *userID;

@end


@interface ICNotePasteboardData : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSData *attributedStringData;
@property (readonly, nonatomic) ICDataPersister *dataPersister;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)pasteboardDataFromPersistenceData:(id)data;

/* instance methods */
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)persistenceData;
- (id)initWithAttributedStringData:(id)data dataPersister:(id)persister;

@end


@interface ICNotesCrossProcessChangeCoordinator : NSObject

@property (retain, nonatomic) NSPersistentStoreCoordinator *sourceCoordinator;
@property (retain, nonatomic) NSManagedObjectContext *destinationContext;
@property (retain, nonatomic) id <NSObject> accountsNotificationsObserver;

/* instance methods */
- (void)removeCrossProcessNotificationObserver:(id)observer;
- (void)postCrossProcessNotificationName:(id)name;
- (id)registerForEditorExtensionDidSaveNotificationWithBlock:(id /* block */)block;
- (void)postEditorExtensionDidSaveNotification;
- (id)initWithSourceCoordinator:(id)coordinator destinationContext:(id)context;
- (id)registerForCrossProcessNotificationName:(id)name block:(id /* block */)block;
- (void)dealloc;
- (id)registerForAccountNotifications;
- (void)postAccountDidChangeNotification;

@end


@interface ICNotesInvernessClient : NSObject

@property (retain, nonatomic) ICNotesInvernessClientObjc *objcClient;

/* instance methods */
- (id)initWithContainer:(id)container;
- (void)didCompleteInstallOrUpdateWithPreviousBuildNumber:(id)number previousVersion:(id)version currentBuildNumber:(id)number currentVersion:(id)version platformName:(id)name continuationToken:(id)token callback:(id /* block */)callback;
- (void)runGarbageCollectorWithProgress:(id)progress callback:(id /* block */)callback;
- (void)sendMentionNotificationWithRecipientUserId:(id)id senderName:(id)name noteTitle:(id)title mentionSnippet:(id)snippet shareRecordName:(id)name shareOwnerUserId:(id)id noteRecordName:(id)name inlineAttachmentRecordName:(id)name callback:(id /* block */)callback;

@end


@interface ICNotesInvernessClientObjc : NSObject // (Swift)

@property (nonatomic, readonly) CKContainer *container;
@property (nonatomic, readonly) long long environment;
@property (nonatomic, readonly) NSString *localURLString;

/* instance methods */
- (id)init;
- (void)didCompleteInstallOrUpdateWithPreviousBuildNumber:(id)number previousVersion:(id)version currentBuildNumber:(id)number currentVersion:(id)version platformName:(id)name continuationToken:(id)token callback:(id /* block */)callback;
- (id)initWithContainer:(id)container environment:(long long)environment localURLString:(id)urlstring;
- (void)runGarbageCollectorWithProgress:(id)progress callback:(id /* block */)callback;
- (void)sendMentionNotificationWithRecipientUserId:(id)id senderName:(id)name noteTitle:(id)title mentionSnippet:(id)snippet shareRecordName:(id)name shareOwnerUserId:(id)id noteRecordName:(id)name inlineAttachmentRecordName:(id)name callback:(id /* block */)callback;

@end


@interface ICOCRGenerator : NSObject

/* class methods */
+ (id)ocrStringFromImage:(struct CGImage *)image title:(id *)title languages:(id)languages;
+ (id)ocrStringFromImageRequestHandler:(id)handler title:(id *)title languages:(id)languages session:(id)session;
+ (id)ocrStringFromImageURL:(id)url title:(id *)title languages:(id)languages;

@end


@interface ICOperationQueueObserver : NSObject

/* instance methods */
- (id)initWithQueue:(id)queue;
- (id)init;
- (void)dealloc;

@end


@interface ICOutlineState : NSObject

@property (readonly, copy, nonatomic) NSArray *collapsedUUIDStrings;
@property (retain, nonatomic) ICTTMergeableWallClockValue *mergeableValue;
@property (readonly, copy, nonatomic) NSData *data;
@property (readonly, copy, nonatomic) NSSet *collapsedUUIDs;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (_Bool)mergeWithState:(id)state;
- (unsigned long long)hash;
- (id)initWithCollapsedUUIDs:(id)uuids;
- (_Bool)isEqualToICOutlineState:(id)state;
- (void)updateCollapsedUUIDs;

@end


@interface ICPDFGenerator : NSObject

@property (copy, nonatomic) NSURL *fileURL;
@property (copy, nonatomic) NSString *title;
@property (nonatomic) struct CGRect pageRect;
@property (retain, nonatomic) NSMutableData *data;
@property (readonly, nonatomic) NSURL *url;

/* instance methods */
- (id)init;
- (void)dealloc;
- (_Bool)startGenerating;
- (void)addPageWithPageRect:(struct CGRect)rect renderBlock:(id /* block */)block;
- (void)addPageWithRenderBlock:(id /* block */)block;
- (void)finishGenerating;
- (id)initWithMutableData:(id)data pageRect:(struct CGRect)rect title:(id)title;
- (id)initWithURL:(id)url pageRect:(struct CGRect)rect title:(id)title;

@end


@interface ICPDFUtilities : NSObject

/* class methods */
+ (id)renderedImageForPage:(struct CGPDFPage *)page scale:(double)scale size:(struct CGSize)size colorSpace:(struct CGColorSpace *)space;

@end


@interface ICPaperAttachmentCreationHelper : NSObject

/* class methods */
+ (void)copyNewPaperBundleToAttachment:(ICAttachment *)attachment fromURL:(NSURL *)url completionHandler:(id /* block */)handler;
+ (void)createPaperDocumentForAttachment:(ICAttachment *)attachment fromLegacyMediaAtURL:(NSURL *)url completionHandler:(id /* block */)handler;
+ (_Bool)createPaperDocumentForAttachment:(id)attachment fromLegacyMediaAtURL:(id)url error:(id *)error;
+ (id)createSystemPaperAttachmentWithPKDrawing:(id)pkdrawing inNote:(id)note;

/* instance methods */
- (id)init;

@end


@interface ICPaperSynapseContentItemProvider : NSObject // (Swift)

/* class methods */
+ (id)contentItemsForAttachment:(id)attachment;

/* instance methods */
- (id)init;

@end


@interface ICParticipantBaseColorValues : NSObject

@property (nonatomic) double redValue;
@property (nonatomic) double greenValue;
@property (nonatomic) double blueValue;
@property (nonatomic) double alphaValue;

/* instance methods */
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;

@end


@interface ICParticipantUpdater : NSObject

@property (retain, nonatomic) NSObject *serialQueue;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

/* instance methods */
- (void)updateWithCompletion:(id /* block */)completion;
- (id)initWithManagedObjectContext:(id)context;
- (void)deleteOrphanedParticipantsWithCompletion:(id /* block */)completion;
- (void)insertMissingParticipantsWithCompletion:(id /* block */)completion;
- (void)insertParticipantsForNoteObjectID:(id)id;
- (id)missingNoteObjectsIDs;

@end


@interface ICPasswordReaskController : NSObject

/* class methods */
+ (id)sharedController;

/* instance methods */
- (void)enrollInReaskForAccount:(id)account;
- (_Bool)isEnrolledInReaskForAccount:(id)account;
- (id)keyForEnrolledInReask:(id)reask;
- (id)keyForLastReaskDate:(id)date;
- (id)lastReaskDateForAccount:(id)account;
- (void)reaskPasswordForAccount:(id)account;
- (void)reaskPasswordForAccountIfNecessary:(id)necessary;
- (void)setIsEnrolledInReask:(_Bool)reask forAccount:(id)account;
- (void)setLastReaskDate:(id)date forAccount:(id)account;
- (_Bool)shouldReaskForAccount:(id)account;

@end


@interface ICPeerInputStream : NSObject <NSStreamDelegate>

@property (retain, nonatomic) NSMutableData *data;
@property (nonatomic) unsigned long long length;
@property (nonatomic) unsigned long long maxLength;
@property (nonatomic) _Bool isMessage;
@property (readonly, nonatomic) NSInputStream *inputStream;
@property (weak, nonatomic) id <ICPeerInputStreamDelegate> delegate;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)stream:(id)stream handleEvent:(unsigned long long)event;
- (void)dealloc;
- (id)initWithInputStream:(id)stream;
- (void)startReadLength;
- (void)readDataFrom:(id)from;
- (void)startReadMessage:(unsigned long long)message;

@end


@interface ICPeerMessageController : NSObject

@property (weak, nonatomic) id <ICPeerMessageControllerDelegate> delegate;

/* instance methods */
- (id)init;
- (id)deviceRequestsForUUID:(id)uuid;
- (void)disconnectedFromSource:(id)source;
- (void)handleKeepAliveMessage:(const void *)message fromDevice:(id)device;
- (void)handleMessage:(id)message fromSource:(id)source;
- (void)handleNoteMessage:(const void *)message fromDevice:(id)device data:(id)data;
- (void)handleRequestNoteMessage:(const void *)message fromDevice:(id)device;
- (void)requestNote:(id)note from:(id)from;
- (void)sendKeepAlive;
- (void)sendMediaURL:(id)url toSource:(id)source;
- (id)sendMessage:(void *)message toDevices:(id)devices;
- (id)sendMessage:(void *)message toSource:(id)source completionBlock:(id /* block */)block;
- (id)sendMessage:(void *)message toSources:(id)sources;
- (id)sendNote:(id)note toDevices:(id)devices;

@end


@interface ICPeerOutputStream : NSObject <NSStreamDelegate>

@property (retain, nonatomic) NSMutableData *data;
@property (readonly, nonatomic) NSOutputStream *outputStream;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)stream:(id)stream handleEvent:(unsigned long long)event;
- (void)dealloc;
- (id)initWithOutputStream:(id)stream;
- (void)writeData;
- (void)writeMessageData:(id)data;

@end


@interface ICPinnedNotesFilterTypeSelection : ICInclusionFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;

@end


@interface ICPreviewDeviceInfo : NSObject

@property (nonatomic) double imageSize;
@property (nonatomic) double scale;
@property (retain, nonatomic) ICAppearanceInfo *appearanceInfo;

/* class methods */
+ (id)previewDeviceInfoForPreviewImage:(id)image;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (unsigned long long)hash;
- (id)deviceInfoFromAddingAppearanceInfo:(id)info;
- (id)initWithImageSize:(double)size scale:(double)scale;
- (id)initWithImageSize:(double)size scale:(double)scale appearanceInfo:(id)info;

@end


@interface ICQuery : NSObject

@property (readonly) ICQueryObjC *queryObjC;
@property (readonly, nonatomic) _Bool canBeEdited;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, copy, nonatomic) NSString *entityName;
@property (readonly, copy, nonatomic) NSPredicate *predicate;

/* class methods */
+ (id)queryForCallNotesAllowsRecentlyDeleted:(_Bool)deleted;
+ (id)queryForMathNotesAllowsRecentlyDeleted:(_Bool)deleted;
+ (id)queryForNotesMatchingFilterSelection:(id)selection;
+ (id)queryForNotesMatchingTagSelection:(id)selection;
+ (id)queryForPinnedNotes:(_Bool)notes allowsRecentlyDeleted:(_Bool)deleted;
+ (id)queryForRecentlyDeletedMathNotes;
+ (id)queryForSharedNotes:(_Bool)notes allowsRecentlyDeleted:(_Bool)deleted;
+ (id)queryForSystemPaperNotesAllowsRecentlyDeleted:(_Bool)deleted;

/* instance methods */
- (id)filterSelectionWithManagedObjectContext:(id)context account:(id)account;
- (id)removingTagIdentifier:(id)identifier;
- (id)replacingTagIdentifier:(id)identifier withNewTagIdentifier:(id)identifier;
- (id)tagSelectionWithManagedObjectContext:(id)context;

@end


@interface ICQueryObjC : NSObject

@property (nonatomic, readonly) long long minimumSupportedVersion;
@property (nonatomic, readonly) _Bool canBeEdited;
@property (nonatomic, readonly) NSString *entityName;
@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, readonly) NSString *debugDescription;

/* class methods */
+ (id)objc_queryForCallNotesAllowsRecentlyDeleted:(_Bool)deleted;
+ (id)objc_queryForMathNotesAllowsRecentlyDeleted:(_Bool)deleted;
+ (id)objc_queryForNonDeletedNotes;
+ (id)objc_queryForNotesMatchingFilterSelection:(id)selection;
+ (id)objc_queryForNotesMatchingTagSelection:(id)selection;
+ (id)objc_queryForPinnedNotes:(_Bool)notes allowsRecentlyDeleted:(_Bool)deleted;
+ (id)objc_queryForRecentlyDeletedMathNotes;
+ (id)objc_queryForSharedNotes:(_Bool)notes allowsRecentlyDeleted:(_Bool)deleted;
+ (id)objc_queryForSystemPaperNotesAllowsRecentlyDeleted:(_Bool)deleted;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)filterSelectionWithManagedObjectContext:(id)context account:(id)account;
- (id)removingTagIdentifier:(id)identifier;
- (id)replacingTagIdentifier:(id)identifier withNewTagIdentifier:(id)identifier;
- (id)tagSelectionWithManagedObjectContext:(id)context;

@end


@interface ICQueryResultsController : NSObject

@property (retain, nonatomic) ICQueryResultsControllerObjC *queryResultsControllerObjC;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) ICQuery *query;

/* instance methods */
- (id)performFetch;
- (id)initWithManagedObjectContext:(id)context query:(id)query;

@end


@interface ICQueryResultsControllerObjC : NSObject // (Swift)

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) ICQueryObjC *query;
@property (nonatomic, readonly) id fetchRequest;

/* instance methods */
- (id)init;
- (id)performFetch;
- (id)initWithManagedObjectContext:(id)context query:(id)query;

@end


@interface ICQuickNotesFilterTypeSelection : ICInclusionFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;

@end


@interface ICRandomNumberGenerator : NSObject

/* instance methods */
- (id)initWithSeed:(unsigned int)seed;
- (double)randomFloat;
- (unsigned long long)randomIndexMin:(unsigned long long)min max:(unsigned long long)max;
- (id)randomObject:(id)object;

@end


@interface ICRandomTextGenerator : NSObject

@property (retain, nonatomic) ICRandomNumberGenerator *randomNumberGenerator;
@property (nonatomic) unsigned long long language;
@property (readonly, nonatomic) _Bool isRightToLeftLanguage;

/* class methods */
+ (_Bool)hasSpacesBetweenWordsForLanguage:(unsigned long long)language;
+ (id)loadWordsForLanguage:(unsigned long long)language;
+ (id)sentencePunctuationForLanguage:(unsigned long long)language endOfParagraph:(_Bool)paragraph;
+ (id)wordsForLanguage:(unsigned long long)language;

/* instance methods */
- (id)paragraph;
- (id)word;
- (id)generateMinSentences:(unsigned long long)sentences maxSentences:(unsigned long long)sentences minWords:(unsigned long long)words maxWords:(unsigned long long)words;
- (id)generateMinWords:(unsigned long long)words maxWords:(unsigned long long)words;
- (id)generateWords:(unsigned long long)words minLength:(unsigned long long)length;
- (id)generateWordsWithMinLength:(unsigned long long)length;
- (id)initWithRandomNumberGenerator:(id)generator;
- (id)lineOfText;
- (id)sentence;

@end


@interface ICRankingQueriesDefinition : NSObject

@property (retain, nonatomic) NSArray *expandedTokens;
@property (nonatomic) long long rankingQueryType;
@property (retain, nonatomic) NSString *rankingQueryFlags;
@property (retain, nonatomic) NSMutableDictionary *matchingDescriptorsCache;
@property (readonly, nonatomic) NSArray *rankingQueryDescriptors;
@property (readonly, nonatomic) NSArray *rankingQueries;

/* class methods */
+ (unsigned long long)bucketOfTimeInterval:(double)interval;
+ (unsigned long long)maxCountOfVariantsForCountOfTokens:(unsigned long long)tokens;
+ (unsigned long long)modificationDateBucketForSearchableItem:(id)item;
+ (unsigned long long)relevanceBitFieldForSearchableItem:(id)item;

/* instance methods */
- (id)highlightInfoForSearchableItem:(id)item;
- (void)addDescriptor:(id)descriptor intoSearchResultHighlightInfoFieldElement:(id)element;
- (id)initWithExpandedTokens:(id)tokens rankingQueryType:(long long)type rankingQueryFlags:(id)flags;
- (id)initWithSearchString:(id)string rankingQueryType:(long long)type rankingQueryFlags:(id)flags;
- (id)matchingDescriptorsForBitFields:(unsigned long long)fields;
- (double)rankingScoreForSearchableItem:(id)item;

@end


@interface ICRankingQueryDescriptor : NSObject <NSCopying>

@property (retain, nonatomic) NSString *rankingQuery;
@property (readonly, nonatomic) NSArray *queryFields;
@property (readonly, nonatomic) NSArray *expandedTokens;
@property (readonly, nonatomic) long long rankingQueryType;
@property (readonly, nonatomic) NSString *rankingQueryFlags;
@property (readonly, nonatomic) unsigned long long displayedMatchedFields;
@property (readonly, nonatomic) unsigned long long purpose;
@property (readonly, nonatomic) NSArray *tokens;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithQueryFields:(id)fields expandedTokens:(id)tokens rankingQueryType:(long long)type rankingQueryFlags:(id)flags displayedMatchedFields:(unsigned long long)fields purpose:(unsigned long long)purpose;
- (id)initWithQueryFields:(id)fields expandedTokens:(id)tokens rankingQueryType:(long long)type rankingQueryFlags:(id)flags purpose:(unsigned long long)purpose;
- (id)rankingQueryForQueryField:(id)field tokenString:(id)string;
- (double)rankingScoreForSearchResultType:(unsigned long long)type;

@end


@interface ICReaderDelegateUtilities : NSObject <ICReaderDelegate>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedInstance;
+ (id)fileWrapperForURL:(id)url;

/* instance methods */
- (id)fileWrapperForURL:(id)url;

@end


@interface ICRealtimeCollaborationSelectionState : NSObject // (Swift)

/* class methods */
+ (void)registerWithICCRCoder;

/* instance methods */
- (id)init;

@end


@interface ICReindexer : NSObject

/* class methods */
+ (id)reindexer;

@end


@interface ICRemoteFileAttachmentDownloader : NSObject

@property (retain, nonatomic) NSMutableDictionary *operationsByAttachmentIdentifier;
@property (retain, nonatomic) NSOperationQueue *operationQueue;

/* class methods */
+ (id)allUndownloadedLegacyAttachmentsInContext:(id)context;
+ (void)initializeDownloaderAfterDelayIfNecessary;
+ (_Bool)needsToDownloadRemoteFileAttachments;
+ (void)releaseSharedDownloaderIfPossible;
+ (id)sharedDownloader;

/* instance methods */
- (id)init;
- (void)reachabilityChanged:(id)changed;
- (void)dealloc;
- (void)downloadRemoteFileForAttachment:(id)attachment;
- (void)downloadRemoteFileForAttachmentObjectID:(id)id;
- (void)downloadUndownloadedLegacyAttachments;
- (void)resumeDownloadsAfterDelay;

@end


@interface ICRemoteFileWrapper : NSFileWrapper <NSSecureCoding>

@property (retain, nonatomic) NSURL *remoteURL;
@property (retain, nonatomic) NSData *cachedData;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)filename;
- (_Bool)isDirectory;
- (id)fileAttributes;
- (id)serializedRepresentation;
- (void)encodeWithCoder:(id)coder;
- (_Bool)isSymbolicLink;
- (id)initWithCoder:(id)coder;
- (id)addFileWrapper:(id)wrapper;
- (id)addRegularFileWithContents:(id)contents preferredFilename:(id)filename;
- (id)fileWrappers;
- (id)keyForFileWrapper:(id)wrapper;
- (_Bool)matchesContentsOfURL:(id)url;
- (id)preferredFilename;
- (_Bool)readFromURL:(id)url options:(unsigned long long)options error:(id *)error;
- (id)regularFileContents;
- (void)removeFileWrapper:(id)wrapper;
- (id)symbolicLinkDestinationURL;
- (_Bool)writeToURL:(id)url options:(unsigned long long)options originalContentsURL:(id)url error:(id *)error;
- (id)dataWithError:(id *)error;
- (id)initWithRemoteURL:(id)url;

@end


@interface ICSearchIndexDiagnosticsStateHandler : NSObject <ICStateHandlerProvider>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)registerStateHandler;
+ (id)stateDictionary;
+ (unsigned long long)countEntity:(id)entity predicate:(id)predicate inContext:(id)context;
+ (id)indexableItemCounts;
+ (id)indexerFlags;
+ (id)progressStateCounts;

@end


@interface ICSearchIndexState : NSManagedObject

@property (nonatomic) short stateValue;
@property (retain, nonatomic) NSString *identifier;
@property (nonatomic) unsigned long long progressState;

/* instance methods */

@end


@interface ICSearchProfiler : NSObject

/* class methods */
+ (void)logProfilingWithMessage:(id)message;
+ (void)logProfilingWithMessage:(id)message searchQueryOperation:(id)operation;
+ (void)resetProfileTimer;

@end


@interface ICSearchQueryOperation : NSOperation

@property (retain, nonatomic) id <ICSearchSuggestionsResponder> searchSuggestionsResponder;
@property (retain, nonatomic) ICSearchQuery *defaultQuery;
@property (retain, nonatomic) ICSearchQuery *fuzzyQuery;
@property (retain, nonatomic) ICSearchQuery *substringQuery;
@property (retain, nonatomic) ICSearchQuery *nlQuery;
@property (retain, nonatomic) ICSearchQuery *spellingQuery;
@property (retain, nonatomic) NSMutableArray *relatedWordQueries;
@property (retain, nonatomic) NSMutableArray *results;
@property (retain, nonatomic) NSMutableDictionary *resultsDictionary;
@property (retain, nonatomic) NSMutableDictionary *uniqueIdentifiersOfAttachmentsFoundInNotes;
@property (copy, nonatomic) NSString *searchString;
@property (copy, nonatomic) NSString *tokensQueryString;
@property (copy, nonatomic) NSString *keyboardLanguage;
@property (nonatomic) _Bool performNLSearch;
@property (retain, nonatomic) NSError *error;
@property (readonly, nonatomic) _Bool allowEmptySearchString;
@property (nonatomic) _Bool modernResultsOnly;
@property (nonatomic) unsigned long long rankingStrategy;
@property (copy, nonatomic) id /* block */ foundItemsHandler;
@property (nonatomic) long long requestIndex;
@property (readonly, nonatomic) NSArray *searchTokens;

/* class methods */
+ (void)initialize;
+ (id)exactMatchingQueryStringForTitleSearchString:(id)string;
+ (id)fetchModernNoteSearchableItemAttributesFromCoreDataForObjectIDURIs:(id)iduris context:(id)context;
+ (id)fuzzyMatchingQueryStringForSearchString:(id)string;
+ (id)highlightStringForAttributedInputs:(id)inputs;
+ (id)newOperationQueueWithName:(id)name;
+ (void)nlSearchQueryWithSearchString:(id)string queryString:(id *)string rankingQueries:(id *)queries highlightString:(id *)string;
+ (void *)nlpParser;
+ (id)nlpSerialQueue;
+ (id)prefixMatchingQueryStringForSearchString:(id)string;
+ (id)prefixMatchingQueryStringTitleForSearchString:(id)string;
+ (id)searchSuggestionsQueue;
+ (id)searchableItemsFromSortableItems:(id)items;
+ (id)substringMatchingQueryStringForSearchString:(id)string;
+ (void)suggestionSearchResultsWithLinkSuggestionQuery:(ICLinkSuggestionQuery *)query completionHandler:(id /* block */)handler;
+ (id)tokensQueryStringFromTokens:(id)tokens;

/* instance methods */
- (void)main;
- (id)init;
- (void)cancel;
- (void)appendSortableSearchableItemsToResults:(id)results;
- (unsigned long long)countOfNonSpaceCharsInSearchString;
- (id)createPrefixMatchingQuery;
- (id)initWithLinkSuggestionQuery:(id)query;
- (id)initWithQueryString:(id)string rankingQueries:(id)queries;
- (id)initWithQueryString:(id)string rankingQueries:(id)queries attributes:(id)attributes;
- (id)initWithQueryString:(id)string rankingQueries:(id)queries modernResultsOnly:(_Bool)only;
- (id)initWithQueryString:(id)string rankingQueries:(id)queries modernResultsOnly:(_Bool)only attributes:(id)attributes;
- (id)initWithSearchSuggestionsResponder:(id)responder searchString:(id)string performNLSearch:(_Bool)nlsearch tokens:(id)tokens modernResultsOnly:(_Bool)only;
- (id)jointQueryWithSuggestions:(id)suggestions;
- (void)performPrefixAndFuzzyAndSubstringQueries;
- (void)performRelatedWordQueriesIfNeeded;
- (void)performSpellCheckerAPIQueryIfNeeded;
- (id)retrieveNotesOfFoundAttachmentsForSearchResults:(id)results;
- (id)runICSearchQuery:(id)query;
- (_Bool)useSearchSuggestions;

@end


@interface ICSearchQueryParser : NSObject

/* class methods */
+ (id)_queryStringForSingleTokenString:(id)string queryFields:(id)fields matchType:(unsigned char)type queryFlags:(id)flags;
+ (id)prefixMatchingQueryStringForSearchString:(id)string enableSpellCheckSPI:(_Bool)spi languageForSpellchecking:(id)spellchecking expandedTokens:(id *)tokens;
+ (id)queryStringForExpandedTokens:(id)tokens queryFields:(id)fields matchType:(unsigned char)type;
+ (id)queryStringForSearchString:(id)string queryFields:(id)fields matchType:(unsigned char)type;

@end


@interface ICSearchQuerySegment : NSObject

@property (retain, nonatomic) NSString *segmentString;
@property (nonatomic) struct _NSRange segmentRange;
@property (nonatomic) unsigned long long type;
@property (nonatomic) _Bool isExpandable;

/* instance methods */
- (id)description;
- (id)initWithSegmentString:(id)string range:(struct _NSRange)range type:(unsigned long long)type isExpandable:(_Bool)expandable;

@end


@interface ICSearchQueryTokenizer : NSObject

/* class methods */
+ (id)tokenizer;
+ (id)spellChecker;
+ (void)_combineConnectorAndTokensAndRemoveDividersInPlaceForMutableTokenArray:(id)array searchString:(id)string;
+ (id)_expandedTokensForSearchQuerySegmentArray:(id)array searchString:(id)string language:(id)language;
+ (void)_insertConnectorAndDividerSegmentsIntoMutableTokenArray:(id)array searchString:(id)string;
+ (id)_queryTokensForSearchString:(id)string language:(id)language;
+ (void)_sortMutableSearchQueryTokensInPlace:(id)place;
+ (id)connectorCharacterSet;
+ (id)expandedTokensForSearchString:(id)string language:(id)language;
+ (id)nonConnectorCharacterSet;
+ (id)spellCheckerGuessesForSearchString:(id)string inRange:(struct _NSRange)range language:(id)language;
+ (id)tokensFromString:(id)string language:(id)language;

@end


@interface ICSearchRankingStrategySwitch : NSObject

/* class methods */
+ (unsigned long long)defaultStrategy;
+ (unsigned long long)currentStrategy;
+ (id)ICSearchRankingStrategyDisplayNames;

@end


@interface ICSearchResultsQuery : ICSearchQuery

@property (copy, nonatomic) NSString *queryString;
@property (retain, nonatomic) NSArray *attributes;

/* class methods */
+ (id)queryForClassifiedImages;

/* instance methods */
- (id)attributesToFetch;
- (id)initWithQueryString:(id)string rankingQueriesDefinition:(id)definition modernResultsOnly:(_Bool)only;
- (id)initWithQueryString:(id)string externalRankingQueries:(id)queries modernResultsOnly:(_Bool)only;
- (id)initWithQueryString:(id)string externalRankingQueries:(id)queries modernResultsOnly:(_Bool)only attributes:(id)attributes;
- (_Bool)modernResultsOnly;
- (id)newSearchQueryContext;
- (id)newSearchQueryWithContext:(id)context;

@end


@interface ICSearchSuggestion : NSObject <NSCopying>

@property (retain, nonatomic) CSSuggestion *csSuggestion;
@property (readonly, nonatomic) unsigned long long type;
@property (readonly, nonatomic) NSString *suggestionItemTitle;
@property (readonly, nonatomic) ICSearchToken *token;
@property (readonly, nonatomic) NSString *subQueryString;
@property (readonly, nonatomic) NSString *iconImageName;

/* class methods */
+ (id)orderedDefaultSearchSuggestions;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithType:(unsigned long long)type;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithSuggestion:(id)suggestion;

@end


@interface ICSearchSuggestionsContext : NSObject <NSCopying>

@property (retain, nonatomic) CSSuggestion *searchSuggestion;
@property (readonly) _Bool isEmpty;

/* class methods */
+ (_Bool)supportsSearchSuggestions;

/* instance methods */
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)changeScopeOfToken:(id)token toScopeAtIndex:(unsigned long long)index;
- (id)initWithSearchSuggestion:(id)suggestion;
- (void)updateSearchSuggestion:(id)suggestion interaction:(long long)interaction;
- (void)updateTypedString:(id)string tokens:(id)tokens;

@end


@interface ICSearchSuggestionsQuery : ICSearchQuery

@property (retain, nonatomic) NSString *userSearchString;
@property (retain, nonatomic) NSString *literalSearchString;
@property (retain, nonatomic) NSString *searchString;
@property (retain, nonatomic) NSArray *searchTokens;
@property (retain, nonatomic) NSArray *filterQueries;
@property (retain, nonatomic) NSMutableArray *foundSuggestions;
@property (retain, nonatomic) id <ICSearchSuggestionsResponder> suggestionsResponder;

/* instance methods */
- (id)initWithSearchString:(id)string additionalLiteralSearchString:(id)string searchTokens:(id)tokens filterQueries:(id)queries rankingQueriesDefinition:(id)definition modernResultsOnly:(_Bool)only suggestionsResponder:(id)responder;
- (_Bool)modernResultsOnly;
- (id)newSearchQueryContext;
- (id)newSearchQueryWithContext:(id)context;
- (void)queryFinishedRunningWithError:(id)error;

@end


@interface ICSearchToken : NSObject

@property (retain, nonatomic) _CSSuggestionToken *csToken;
@property (retain, nonatomic) NSString *iconImageName;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *subQueryString;
@property (readonly, nonatomic) unsigned long long suggestionType;
@property (readonly, nonatomic) NSString *scopeName;
@property (readonly, nonatomic) unsigned long long selectedScopeIndex;
@property (readonly, nonatomic) NSArray *availableScopes;

/* class methods */
+ (id)iconImageNameForSuggestionType:(unsigned long long)type;
+ (id)iconImageNameForCSToken:(id)cstoken;
+ (unsigned long long)suggestionTypeOfFirstItemInTokens:(id)tokens;

/* instance methods */
- (_Bool)hasMultipleScopes;
- (id)initWithCSSuggestionToken:(id)token;
- (id)initWithTitle:(id)title subQueryString:(id)string suggestionType:(unsigned long long)type;

@end


@interface ICServerChangeToken : NSManagedObject <ICLoggable>

@property (retain, nonatomic) NSString *zoneName;
@property (retain, nonatomic) NSString *ownerName;
@property (retain, nonatomic) ICAccount *account;
@property (retain, nonatomic) NSData *ckServerChangeTokenData;
@property (retain, nonatomic) CKServerChangeToken *ckServerChangeToken;
@property (nonatomic) long long databaseScope;
@property (readonly, nonatomic) CKRecordZoneID *zoneID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)addServerChangeTokenForAccount:(id)account ckServerChangeToken:(id)token zoneID:(id)id databaseScope:(long long)scope context:(id)context;
+ (id)serverChangeTokenForAccount:(id)account zoneID:(id)id databaseScope:(long long)scope context:(id)context;
+ (id)serverChangeTokensMatchingPredicate:(id)predicate inContext:(id)context;

/* instance methods */
- (void)didTurnIntoFault;
- (id)ic_loggingValues;

@end


@interface ICServerChangeTokenMigrationPolicy : NSEntityMigrationPolicy

/* instance methods */
- (_Bool)createDestinationInstancesForSourceInstance:(id)instance entityMapping:(id)mapping manager:(id)manager error:(id *)error;

@end


@interface ICSettingsCloudContextDelegate : NSObject <ICCloudContextDelegate>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (_Bool)cloudContext:(id)context hasContextOptions:(unsigned long long)options;
- (_Bool)isDaemonProcessForCloudContext:(id)context;
- (id)accountIDsForCloudContext:(id)context managedObjectContext:(id)context;
- (id)backgroundContextForCloudContext:(id)context;
- (void)cloudContext:(id)context didExceedQuotaForRecordID:(id)id accountID:(id)id;
- (void)cloudContext:(id)context didFetchShare:(id)share accountID:(id)id;
- (void)cloudContext:(id)context didFetchUserRecord:(id)record accountID:(id)id;
- (void)cloudContext:(id)context didPushRecordID:(id)id accountID:(id)id;
- (void)cloudContext:(id)context receivedZoneNotFound:(id)found accountID:(id)id;
- (void)cloudContext:(id)context sharedZoneWasDeleted:(id)deleted accountID:(id)id;
- (void)cloudContext:(id)context userDidDeleteRecordZoneWithID:(id)id accountID:(id)id;
- (_Bool)deleteCloudObject:(id)object;
- (id)persistentStoreCoordinatorForCloudContext:(id)context;
- (_Bool)supportsDeferredAssetDownloadForCloudContext:(id)context;
- (id)viewContextForCloudContext:(id)context;

@end


@interface ICShareNotifier : NSObject

/* class methods */
+ (_Bool)isDaemonProcess;
+ (void)clearNotificationForRecordID:(id)id;
+ (id)defaultsKeyForPreventingNotificationsForIdentifier:(id)identifier;
+ (id)notificationTitleForEditors:(id)editors;
+ (id)participantsWithReplicaIDs:(id)ids inNote:(id)note;
+ (id)replicaIDsThatEditedTimestamp:(id)timestamp sinceTimestamp:(id)timestamp;
+ (void)setShareNotifierEnabled:(_Bool)enabled;
+ (void)setShouldPreventNotifications:(_Bool)notifications forRecordID:(id)id;
+ (_Bool)shareNotifierEnabled;
+ (_Bool)shouldPreventNotificationsForRecordID:(id)id;
+ (_Bool)shouldShowNotificationForNote:(id)note;
+ (void)showNotificationForNote:(id)note editors:(id)editors;
+ (void)showNotificationIfNecessaryForCloudObject:(id)object accountID:(id)id;
+ (void)showNotificationWithTitle:(id)title message:(id)message userInfo:(id)info;

@end


@interface ICShareParticipantCacheEntry : NSObject

@property (copy, nonatomic) NSSet *names;
@property (copy, nonatomic) NSString *givenName;
@property (copy, nonatomic) NSString *familyName;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *initials;
@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSString *activityStreamDisplayName;

/* instance methods */

@end


@interface ICSharedFilterTypeSelection : ICParticipantsFilterTypeSelection

/* instance methods */
- (long long)filterType;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)shortEmptySummary;

@end


@interface ICSharedRecentlyDeletedSharedNoteUtilities : NSObject

/* class methods */
+ (id)messageForSharedNotesType:(unsigned long long)type;
+ (id)notesSharedViaICloudFromNotes:(id)notes;
+ (unsigned long long)sharedNoteTypeForNotes:(id)notes;
+ (void)showAlertsIfNecessaryForDeletingSharedNotes:(id)notes noteDeleteType:(unsigned long long)type displayWindow:(id)window completionHandler:(id /* block */)handler;
+ (void)showDeletingSharedNotesAlertWithType:(unsigned long long)type displayWindow:(id)window completionHandler:(id /* block */)handler;
+ (id)titleForSharedNotesType:(unsigned long long)type;

@end


@interface ICSortableSearchableItem : NSObject

@property (retain, nonatomic) NSString *searchString;
@property (retain, nonatomic) ICRankingQueriesDefinition *rankingQueriesDefinition;
@property (retain, nonatomic) NSString *language;
@property (nonatomic) _Bool needsLazyInitialization;
@property (readonly, nonatomic) CSSearchableItem *searchableItem;
@property (readonly, nonatomic) NSDictionary *highlightInfo;
@property (readonly, nonatomic) double rankingScore;
@property (readonly, nonatomic) NSArray *attachmentUniqueIdentifiers;
@property (readonly, nonatomic) unsigned long long relevanceBitField;
@property (readonly, nonatomic) _Bool isPrefixMatch;
@property (readonly, nonatomic) _Bool isExactTitleMatch;
@property (readonly, nonatomic) unsigned long long modificationDateBucket;
@property (readonly, nonatomic) NSDate *modificationDate;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) unsigned long long searchResultType;

/* class methods */
+ (id)sortDescriptorsForRankingStrategy:(unsigned long long)strategy;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)hash;
- (id)initWithSearchableItem:(id)item highlightInfo:(id)info rankingScore:(double)score attachmentUniqueIdentifiers:(id)identifiers;
- (id)initWithSearchableItem:(id)item searchString:(id)string rankingQueriesDefinition:(id)definition rankingScore:(double)score attachmentUniqueIdentifiers:(id)identifiers language:(id)language;
- (void)lazilyInitializeHighlightInfoAndIsPrefixMatchIfNecessary;

@end


@interface ICSynapseLinkPreviewLoadingOperation : NSObject

/* instance methods */
- (void)loadPreviewWithCompletionBlock:(id /* block */)block;
- (id)initWithSynapseItem:(id)item;
- (void)linkPreviewDidFinishLoading:(id)loading;

@end


@interface ICSystemPaperDrawingsHelper : NSObject // (Swift)

/* class methods */
+ (id)drawingsForAttachment:(id)attachment;

/* instance methods */
- (id)init;

@end


@interface ICSystemPaperSyncArchive : NSObject // (Swift)

@property (nonatomic, readonly) NSURL *databaseArchive;
@property (nonatomic, readonly) NSArray *assetArchives;
@property (nonatomic, readonly) NSString *description;

/* instance methods */
- (id)init;
- (id)initWithDatabaseArchive:(id)archive assetArchives:(id)archives;

@end


@interface ICTTArray : NSObject <ICCRCoding, ICTTMergeableStringDelegate, ICCRDataType>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) ICTTMergeableAttributedString *contents;
@property (readonly, nonatomic) NSArray *nsArray;
@property (readonly, nonatomic) unsigned long long count;
@property (readonly, nonatomic) NSUUID *replicaUUID;
@property (weak, nonatomic) ICCRDocument *document;
@property (weak, nonatomic) NSObject<ICCRUndoDelegate> *delegate;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)addObject:(id)object;
- (id)initWithContents:(id)contents;
- (id)initWithDocument:(id)document;
- (unsigned long long)indexOfObject:(id)object;
- (void)mergeWith:(id)with;
- (id)init;
- (void)endEditing;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)replaceObjectAtIndex:(unsigned long long)index withObject:(id)object;
- (void)removeObjectAtIndex:(unsigned long long)index;
- (void)insertObject:(id)object atIndex:(unsigned long long)index;
- (void)beginEditing;
- (void)removeLastObject;
- (void)addUndoCommand:(id)command;
- (void)saveToArchive:(void *)archive;
- (id)serializeDataFromArchive:(const void *)archive;
- (id)textAttachmentAtIndex:(unsigned long long)index;
- (_Bool)wantsUndoCommands;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithArchive:(const void *)archive replicaID:(id)id;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder stringArray:(const void *)array;

@end


@interface ICTTAttachment : NSObject <ICTTAttachment>

@property (copy, nonatomic) NSString *attachmentIdentifier;
@property (copy, nonatomic) NSString *attachmentUTI;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)isAttachment:(id)attachment equalToModelComparable:(id)comparable;
+ (_Bool)isInlineAttachment:(id)attachment;
+ (_Bool)typeUTIIsInlineAttachment:(id)attachment;

/* instance methods */
- (id)fileType;
- (_Bool)isEqual:(id)equal;
- (struct CGRect)attachmentBoundsForAttributes:(id)attributes location:(id)location textContainer:(id)container proposedLineFragment:(struct CGRect)fragment position:(struct CGPoint)position;
- (id)adaptiveImageGlyph;
- (_Bool)_isEmojiImage;
- (void)_showWithBounds:(struct CGRect)bounds attributes:(id)attributes location:(id)location textContainer:(id)container applicationFrameworkContext:(long long)context acceptsViewProvider:(_Bool)provider;
- (long long)standaloneAlignment;
- (_Bool)isEqualToModelComparable:(id)comparable;
- (id)attachmentInContext:(id)context;
- (id)inlineAttachmentInContext:(id)context;

@end


@interface ICTTAudioDocument : NSObject

@property (nonatomic, readonly) _Bool hasToplineSummary;
@property (nonatomic) _Bool isCallRecording;
@property (nonatomic) unsigned long long callType;
@property (nonatomic, retain) NSString *localSpeakerHandle;
@property (nonatomic, retain) NSString *remoteSpeakerHandle;
@property (nonatomic, retain) NSDate *callRecordingStartTime;
@property (nonatomic, readonly) NSString *topLineSummaryAsPlainText;
@property (nonatomic, readonly) NSString *recordingSummaryAsPlainText;
@property (nonatomic, retain) NSString *externalModelAttributionProviderName;
@property (nonatomic, retain) NSString *externalModelAttributionSymbolName;
@property (nonatomic, retain) id document;
@property (nonatomic, readonly) NSArray *orderedFragmentUUIDs;
@property (nonatomic, readonly) NSString *transcriptAsPlainText;
@property (nonatomic, readonly) NSNumber *transcriptVersion;

/* class methods */
+ (void)registerWithICCRCoder;
+ (id)unarchiveFromData:(id)data replicaID:(id)id;

/* instance methods */
- (id)init;
- (id)archivedData;
- (id)initWithReplicaID:(id)id compatibleDocument:(id)document;
- (unsigned long long)mergeWithMergeableData:(id)data replicaID:(id)id;
- (void)updateAfterLoadWithSubAttachmentIdentifierMap:(id)map;

@end


@interface ICTTAudioRecording : ICCRObject

@property (nonatomic, retain) ICTTMergeableAttributedString *summary;
@property (nonatomic, retain) ICTTMergeableAttributedString *topLineSummary;
@property (nonatomic, retain) NSNumber *summaryVersion;
@property (nonatomic, retain) NSString *toplineSummaryModelVersionInfo;
@property (nonatomic, retain) NSString *longformSummaryModelVersionInfo;
@property (nonatomic, retain) id fragments;
@property (nonatomic, retain) NSNumber *callRecording;
@property (nonatomic, retain) NSNumber *callType;
@property (nonatomic, retain) NSString *callLocalSpeakerHandle;
@property (nonatomic, retain) NSString *callRemoteSpeakerHandle;
@property (nonatomic, retain) NSDate *callRecordingStartTime;
@property (nonatomic, retain) NSString *externalModelAttributionProviderName;
@property (nonatomic, retain) NSString *externalModelAttributionSymbolName;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface ICTTVectorTimestamp : NSObject <NSCopying>

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (id)description;
- (id)init;
- (id)serialize;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)compareTo:(id)to;
- (id)initWithArchive:(const void *)archive;
- (id)allUUIDs;
- (id)clockElementForUUID:(id)uuid;
- (unsigned long long)clockForUUID:(id)uuid;
- (void)incrementClockForUUID:(id)uuid;
- (void)mergeWithTimestamp:(id)timestamp;
- (void)saveToArchive:(void *)archive;
- (void)setClock:(unsigned long long)clock forUUID:(id)uuid;
- (void)setClock:(unsigned long long)clock subclock:(unsigned long long)subclock forUUID:(id)uuid;
- (id)sortedUUIDs;
- (unsigned long long)subclockForUUID:(id)uuid;

@end


@interface ICTTCRVectorTimestamp : ICTTVectorTimestamp

@property (retain, nonatomic) ICCRVectorTimestamp *crTimestamp;

/* instance methods */
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)allUUIDs;
- (id)clockElementForUUID:(id)uuid;
- (unsigned long long)clockForUUID:(id)uuid;
- (void)setClock:(unsigned long long)clock forUUID:(id)uuid;
- (void)setClock:(unsigned long long)clock subclock:(unsigned long long)subclock forUUID:(id)uuid;
- (id)sortedUUIDs;
- (unsigned long long)subclockForUUID:(id)uuid;

@end


@interface ICTTFont : NSObject <NSSecureCoding>

@property (retain, nonatomic) id nativeFont;
@property (readonly, nonatomic) NSString *fontName;
@property (readonly, nonatomic) double pointSize;
@property (readonly, nonatomic) unsigned int fontHints;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (id)description;
- (id)serialize;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithArchive:(const void *)archive;
- (id)initWithName:(id)name size:(double)size hints:(unsigned int)hints;
- (void)saveToArchive:(void *)archive;

@end


@interface ICTTMergeableString : NSObject <ICCRDataType, NSCopying>

@property (weak, nonatomic) ICCRTTCompatibleDocument *document;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) NSMutableAttributedString *attributedString;
@property (readonly, nonatomic) unsigned long long replicaTextClock;
@property (readonly, nonatomic) unsigned long long replicaStyleClock;
@property (retain, nonatomic) ICTTVectorMultiTimestamp *timestamp;
@property (nonatomic) _Bool hasLocalChanges;
@property (retain, nonatomic) NSUUID *replicaUUID;
@property (weak, nonatomic) NSObject<ICTTMergeableStringDelegate> *delegate;
@property (readonly, nonatomic) NSHashTable *objectsNeedingUpdatedRanges;

/* class methods */
+ (id)timestampFromData:(id)data;

/* instance methods */
- (void)deleteCharactersInRange:(struct _NSRange)range;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)insertAttributedString:(id)string atIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (unsigned long long)length;
- (void)replaceCharactersInRange:(struct _NSRange)range withAttributedString:(id)string;
- (void)invalidateCache;
- (void)mergeWith:(id)with;
- (id)string;
- (void)endEditing;
- (id)serialize;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)updateCache;
- (void)dealloc;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)beginEditing;
- (void)insertString:(id)string atIndex:(unsigned long long)index;
- (_Bool)check:(id *)check;
- (_Bool)isFragment;
- (void)dumpData;
- (void)coalesce;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)canMergeString:(id)string;
- (id)dotDescription:(unsigned long long)description;
- (void)_testSetTextTimestamp:(unsigned long long)timestamp;
- (id)characterRangesForSelection:(id)selection;
- (id)characterRangesForSelection:(id)selection selectedSubstringsBlock:(id /* block */)block;
- (void)checkTimestampLogStyleErrors:(_Bool)errors;
- (void)cleanupObjectsNeedingUpdatedRanges;
- (void)deleteSubstrings:(void *)substrings withCharacterRanges:(void *)ranges;
- (void)dumpMergeData:(id)data;
- (void *)endNodes;
- (void)enumerateSubstrings:(id /* block */)substrings;
- (void)generateIdsForLocalChanges;
- (void)generateIdsForLocalChangesSafeForSharedTimestamp:(_Bool)timestamp;
- (unsigned long long)getCharacterIndexForCharID:(struct TopoID)id;
- (void)getCharacterRanges:(void *)ranges forSubstrings:(void *)substrings;
- (void *)getSubstringBeforeTopoID:(struct TopoID)id;
- (void)getSubstrings:(void *)substrings forCharacterRange:(struct _NSRange)range;
- (void)getSubstrings:(void *)substrings forTopoIDRange:(struct TopoIDRange)idrange;
- (_Bool)graphIsEqual:(id)equal;
- (id)i_saveDeltasSinceTimestamp:(id)timestamp toArchive:(void *)archive;
- (id)initWithReplicaID:(id)id;
- (id)initWithReplicaID:(id)id asFragment:(_Bool)fragment;
- (struct TopoIDRange)insertAttributedString:(id)string after:(void *)after before:(void *)before;
- (unsigned long long)mergeWithString:(id)string;
- (unsigned long long)mergeWithString:(id)string mergeTimestamps:(_Bool)timestamps;
- (void)moveRange:(struct _NSRange)range toIndex:(unsigned long long)index;
- (void *)orderedSubstrings;
- (void)resetLocalReplicaClocksToTimestampValues;
- (void)saveDeltaSinceTimestamp:(id)timestamp toArchive:(void *)archive;
- (void)saveSubstrings:(void *)substrings archiveSet:(void *)set linkSet:(void *)set archivedString:(id *)string toArchive:(void *)archive;
- (void)saveToArchive:(void *)archive;
- (_Bool)selection:(id)selection wasModifiedAfter:(id)after;
- (id)selectionForCharacterRanges:(id)ranges;
- (id)selectionForCharacterRanges:(id)ranges selectionAffinity:(unsigned long long)affinity;
- (id)serializeDeltaSinceTimestamp:(id)timestamp;
- (void)sortSplitNodes;
- (void *)splitTopoSubstring:(void *)substring atIndex:(unsigned int)index;
- (void *)startNodes;
- (long long)substring:(void *)substring modifiedAfter:(id)after;
- (_Bool)textEitherSideOfSelectionAnchor:(struct TopoID)anchor wasModifiedAfter:(id)after;
- (void)traverseUnordered:(id /* block */)unordered;
- (void)updateAttributedStringAfterMerge;
- (void)updateClock;
- (void)updateSubstringIndexes;
- (void)updateTimestampsInRange:(struct _NSRange)range;
- (id)initWithArchive:(const void *)archive replicaID:(id)id orderedSubstrings:(void *)substrings timestamp:(id)timestamp fragment:(_Bool)fragment;
- (void)enumerateHighlightableRangesModifiedAfter:(id)after includingAttributes:(_Bool)attributes usingBlock:(id /* block */)block;
- (id)initWithArchive:(const void *)archive replicaID:(id)id;
- (id)initWithArchive:(const void *)archive replicaID:(id)id orderedSubstrings:(void *)substrings;
- (id)initWithArchive:(const void *)archive replicaID:(id)id timestamp:(id)timestamp;
- (id)initWithData:(id)data replicaID:(id)id;
- (id)initWithData:(id)data replicaID:(id)id fragment:(_Bool)fragment;
- (long long)substring:(void *)substring modifiedAfter:(id)after includeAttributes:(_Bool)attributes replicaID:(id *)id;

@end


@interface ICTTMergeableUndoString : ICTTMergeableString

/* instance methods */
- (void)addUndoCommand:(id)command;
- (void)applyUndoCommand:(id)command;
- (void)deleteSubstrings:(void *)substrings withCharacterRanges:(void *)ranges;
- (struct TopoIDRange)insertAttributedString:(id)string after:(void *)after before:(void *)before;
- (void)undeleteSubstrings:(void *)substrings;

@end


@interface ICTTMergeableAttributedString : ICTTMergeableUndoString <ICCRCoding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) NSAttributedString *editsAttributedString;
@property (readonly, copy, nonatomic) NSArray *edits;

/* class methods */
+ (id)allowedAttributesForModel;
+ (int)attributeForWritingDirection:(long long)direction;
+ (id)attributesForRun:(const void *)run;
+ (void)saveAttributes:(id)attributes toArchive:(void *)archive;
+ (void)saveAttributesOfString:(id)string toArchive:(void *)archive;
+ (long long)writingDirectionForAttribute:(int)attribute;
+ (id)allowedAttributesForStyle;
+ (id)allowedTypingAttributes;

/* instance methods */
- (void)setAttributes:(id)attributes range:(struct _NSRange)range;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (id)attributesAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (void)invalidateCache;
- (id)serialize;
- (void)insertString:(id)string atIndex:(unsigned long long)index;
- (_Bool)attributesEqual:(id)equal to:(id)to modelEqual:(_Bool *)equal;
- (_Bool)attributesEqual:(id)equal toRange:(struct _NSRange)range modelEqual:(_Bool *)equal;
- (void)saveDeltaSinceTimestamp:(id)timestamp toArchive:(void *)archive;
- (void)saveToArchive:(void *)archive;
- (void)setAttributes:(id)attributes substring:(void *)substring;
- (id)initWithArchive:(const void *)archive replicaID:(id)id orderedSubstrings:(void *)substrings timestamp:(id)timestamp fragment:(_Bool)fragment;
- (id)editAtIndex:(unsigned long long)index;
- (id)editsInRange:(struct _NSRange)range;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (void)encodeWithICCRCoder:(id)iccrcoder string:(void *)string;
- (void)enumerateEditsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (id)initWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder string:(const void *)string;
- (void)removeTimestampsForReplicaID:(id)id;
- (void)setTimestamp:(id)timestamp range:(struct _NSRange)range;

@end


@interface ICTTMergeableStringSelection : NSObject <ICTTMergeableStringIDTracker>

@property (readonly, nonatomic) struct TopoID minTopoID;
@property (nonatomic) unsigned long long selectionAffinity;
@property (readonly, nonatomic) ICTTMergeableStringSelection *locationOnlySelection;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void *)selectionRanges;
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (long long)compare:(id)compare;
- (id)serialize;
- (id)initWithArchive:(const void *)archive;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)hasTopoIDsThatCanChange;
- (void)saveToArchive:(void *)archive;

@end


@interface ICTTMergeableStringUndoAttributeCommand : NSObject <ICTTMergeableStringUndoCommand>

@property (readonly, nonatomic) void * attributeRanges;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)addToGroup:(id)group;
- (void)applyToString:(id)string;
- (_Bool)hasTopoIDsThatCanChange;

@end


@interface ICTTMergeableStringUndoEditCommand : NSObject <ICTTMergeableStringUndoCommand>

@property (readonly, nonatomic) void * deleteRanges;
@property (readonly, nonatomic) void * insertStrings;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)addToGroup:(id)group;
- (void)applyToString:(id)string;
- (_Bool)hasTopoIDsThatCanChange;
- (void)updateInsertTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;

@end


@interface ICTTMergeableStringUndoGroup : NSObject <ICTTMergeableStringUndoCommand>

@property (retain, nonatomic) NSMutableDictionary *seen;
@property (retain, nonatomic) NSMutableArray *commands;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (void)addCommand:(id)command;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)addSeenRange:(struct TopoIDRange)range;
- (_Bool)addToGroup:(id)group;
- (void)applyToString:(id)string;
- (void)closeGroup;
- (_Bool)hasTopoIDsThatCanChange;

@end


@interface ICTTMergeableStringVersionedDocument : ICTTVersionedDocument

@property (readonly, nonatomic) ICTTMergeableAttributedString *mergeableString;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;

/* instance methods */
- (id)initWithMergeableString:(id)string;
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (unsigned long long)mergeWithStringVersionedDocument:(id)document;
- (id)serializeCurrentVersion:(unsigned int *)version;

@end


@interface ICTTMergeableWallClockValue : NSObject

@property (copy, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) id <NSObject, NSCopying> value;

/* class methods */
+ (_Bool)canParseData:(id)data;
+ (id)extractContentsFromBoxedValue:(const void *)value;

/* instance methods */
- (id)initWithData:(id)data;
- (id)description;
- (unsigned long long)merge:(id)merge;
- (id)serialize;
- (id)initWithValue:(id)value timestamp:(id)timestamp;
- (id)initWithArchive:(const void *)archive;
- (void)saveToArchive:(void *)archive;

@end


@interface ICTTParagraphStyle : NSObject <NSSecureCoding, NSCopying, NSMutableCopying, ICTTModelAttributeComparable>

@property (nonatomic) unsigned int style;
@property (nonatomic) long long alignment;
@property (nonatomic) long long writingDirection;
@property (nonatomic) unsigned long long indent;
@property (nonatomic) unsigned long long blockQuoteLevel;
@property (nonatomic) unsigned long long startingItemNumber;
@property (retain, nonatomic) ICTTTodo *todo;
@property (nonatomic) unsigned int hints;
@property (nonatomic) _Bool needsParagraphCleanup;
@property (nonatomic) _Bool needsListCleanup;
@property (copy, nonatomic) NSUUID *uuid;
@property (readonly, nonatomic) _Bool canIndent;
@property (readonly, nonatomic) _Bool isList;
@property (readonly, nonatomic) _Bool isChecklist;
@property (readonly, nonatomic) _Bool isBlockQuote;
@property (readonly, nonatomic) _Bool isRTL;
@property (readonly, nonatomic) _Bool isHeader;
@property (readonly, nonatomic) _Bool uniqueToLine;
@property (readonly, nonatomic) _Bool preferSingleLine;
@property (readonly, nonatomic) _Bool wantsFollowingNewLine;
@property (readonly, nonatomic) _Bool supportsSectionLinks;
@property (readonly, nonatomic) NSUUID *todoTrackingUUID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)defaultParagraphStyle;
+ (_Bool)supportsSecureCoding;
+ (int)paragraphStyleAlignmentForTextAlignment:(long long)alignment;
+ (id)paragraphStyleNamed:(unsigned int)named;
+ (long long)textAlignmentForParagraphStyleAlignment:(int)alignment;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (id)mutableCopy;
- (id)init;
- (id)serialize;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithArchive:(const void *)archive;
- (_Bool)isEqualToModelComparable:(id)comparable;
- (_Bool)isEqualToModelParagraphStyle:(id)style;
- (_Bool)isEqualToParagraphStyle:(id)style;
- (_Bool)isUnknownStyle;
- (id)listBulletInAttributedString:(id)string atIndex:(unsigned long long)index;
- (void)saveToArchive:(void *)archive;
- (_Bool)isHierarchicallyEqualToParagraphStyle:(id)style;

@end


@interface ICTTMutableParagraphStyle : ICTTParagraphStyle

@property (nonatomic) unsigned int style;
@property (nonatomic) long long alignment;
@property (nonatomic) long long writingDirection;
@property (nonatomic) unsigned long long indent;
@property (nonatomic) unsigned long long blockQuoteLevel;
@property (nonatomic) unsigned long long startingItemNumber;
@property (retain, nonatomic) ICTTTodo *todo;
@property (nonatomic) unsigned int hints;
@property (nonatomic) _Bool needsParagraphCleanup;
@property (nonatomic) _Bool needsListCleanup;
@property (copy, nonatomic) NSUUID *uuid;

/* class methods */
+ (id)paragraphStyleNamed:(unsigned int)named;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface ICTTOrderedSetVersionedDocument : ICTTVersionedDocument

@property (readonly) ICCRDocument *document;
@property (retain, nonatomic) ICCROrderedSet *orderedSet;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;

/* instance methods */
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (id)serializeCurrentVersion:(unsigned int *)version;
- (unsigned long long)mergeWithOrderedSetVersionedDocument:(id)document;

@end


@interface ICTTTextEdit : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSDate *timestamp;
@property (readonly, copy, nonatomic) NSUUID *replicaID;
@property (readonly, nonatomic) struct _NSRange range;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithAttributes:(id)attributes range:(struct _NSRange)range;
- (id)descriptionWithNote:(id)note;
- (id)initWithTimestamp:(id)timestamp replicaID:(id)id range:(struct _NSRange)range;

@end


@interface ICTTTextEditFilter : NSObject <NSCopying>

@property (copy, nonatomic) NSSet *allowedUserIDs;
@property (copy, nonatomic) NSSet *allowedAttachmentIDs;
@property (nonatomic) _Bool allowsMissingTimestamps;
@property (nonatomic) _Bool allowsMissingUsers;
@property (copy, nonatomic) NSDate *fromDate;
@property (copy, nonatomic) NSDate *toDate;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICTTTextEditGroup : NSObject <NSCopying>

@property (readonly, nonatomic) NSArray *edits;
@property (readonly, copy, nonatomic) NSDate *latestTimestamp;
@property (readonly, copy, nonatomic) NSString *userID;
@property (readonly, nonatomic) struct _NSRange range;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithEdits:(id)edits latestTimestamp:(id)timestamp userID:(id)id range:(struct _NSRange)range;

@end


@interface ICTTTextEditGrouper : NSObject

@property (readonly, nonatomic) NSMutableDictionary *userIDForReplicaID;
@property (readonly, nonatomic) NSMutableDictionary *trustsTimestampsFromReplicaID;
@property (readonly, nonatomic) NSMutableDictionary *checkmarkReplicaIDForUserID;
@property (readonly, nonatomic) ICNote *note;
@property (copy, nonatomic) ICTTTextEditFilter *filter;
@property (nonatomic) _Bool includesTableEdits;
@property (nonatomic) _Bool includesCheckmarkEdits;
@property (nonatomic) _Bool joinsTextGaps;
@property (nonatomic) _Bool joinsWhitespaceAndNewlineGaps;

/* instance methods */
- (id)initWithNote:(id)note;
- (id)editGroupForEdits:(id)edits userID:(id)id inAttributedString:(id)string;
- (id)editsByAddingAllowedAttachmentEditsToEdit:(id)edit inAttributedString:(id)string;
- (id)editsByAddingCheckmarkEditsToEdit:(id)edit inAttributedString:(id)string;
- (id)editsByAddingTableEditsToEdit:(id)edit inAttributedString:(id)string;
- (id)filteredEditForEdit:(id)edit inAttributedString:(id)string;
- (id)groupedEdits;
- (id)groupedEditsForEdits:(id)edits inAttributedString:(id)string;
- (id)latestTimestampForEdits:(id)edits;
- (struct _NSRange)rangeForEdits:(id)edits;
- (_Bool)trustsTimestampsFromReplicaID:(id)id;
- (id)userIDForReplicaID:(id)id;

@end


@interface ICTTTodo : NSObject <NSCopying>

@property (readonly, nonatomic) NSUUID *uuid;
@property (readonly, nonatomic) _Bool done;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (id)description;
- (id)init;
- (id)serialize;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithArchive:(const void *)archive;
- (void)saveToArchive:(void *)archive;
- (id)initWithIdentifier:(id)identifier done:(_Bool)done;
- (id)todoWithDone:(_Bool)done;

@end


@interface ICTTVectorMultiTimestamp : NSObject <NSCopying>

@property (retain, nonatomic) NSArray *timestamps;
@property (readonly, nonatomic) _Bool isDocumentShared;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)serialize;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithTimestamps:(id)timestamps;
- (id)initWithCapacity:(unsigned long long)capacity;
- (unsigned long long)compareTo:(id)to;
- (id)clockElementForUUID:(id)uuid atIndex:(unsigned long long)index;
- (unsigned long long)clockForUUID:(id)uuid atIndex:(unsigned long long)index;
- (id)initWithArchive:(const void *)archive andCapacity:(unsigned long long)capacity;
- (id)initWithData:(id)data andCapacity:(unsigned long long)capacity;
- (void)mergeWithTimestamp:(id)timestamp;
- (void)saveToArchive:(void *)archive;
- (void)setClock:(unsigned long long)clock forUUID:(id)uuid atIndex:(unsigned long long)index;
- (void)setClock:(unsigned long long)clock subclock:(unsigned long long)subclock forUUID:(id)uuid atIndex:(unsigned long long)index;
- (id)sortedUUIDs;

@end


@interface ICTTVectorTimestampElement : NSObject

@property (nonatomic) unsigned long long clock;
@property (nonatomic) unsigned long long subclock;

@end


@interface ICTable : CRTable

@property (weak, nonatomic) NSObject<ICTableDelegate> *delegate;
@property (readonly, nonatomic) NSMutableDictionary *columnTextStorages;
@property (readonly, nonatomic) ICCRTTCompatibleDocument *ttDocument;
@property (readonly, nonatomic) ICTableCellChangeNotifier *cellChangeNotifier;

/* class methods */
+ (void)registerWithICCRCoder;

/* instance methods */
- (void)undoablyRemoveContentsOfColumn:(id)column;
- (_Bool)columnIsEmptyAtIndex:(unsigned long long)index;
- (id)copyIntoNewDocumentWithReplicaID:(id)id;
- (id)defaultContentAtColumn:(id)column row:(id)row;
- (_Bool)isEmptyAtColumnIdentifiers:(id)identifiers rowIdentifiers:(id)identifiers;
- (_Bool)isEmptyAtColumnIndexes:(id)indexes rowIndexes:(id)indexes;
- (id)mergeableStringForColumnID:(id)id rowID:(id)id;
- (_Bool)rowIsEmptyAtIndex:(unsigned long long)index;
- (void)setAttributedString:(id)string columnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (id)stringForColumnID:(id)id rowID:(id)id;
- (id)stringForColumnIndex:(unsigned long long)index rowIndex:(unsigned long long)index;
- (id)subtableWithDocument:(id)document forSelectionContainingColumnIndices:(id)indices rowIndices:(id)indices;
- (void)undoablyInsertContents:(id)contents atColumn:(id)column;

@end


@interface ICTableAttachmentProvider : NSObject

@property (retain, nonatomic) ICAttachment *backgroundAttachment;
@property (readonly, nonatomic) ICCRTTCompatibleDocument *tableDoc;
@property (weak, nonatomic) NSManagedObjectContext *overriddenBackgroundMOC;
@property (weak, nonatomic) id <ICTableAttachmentProviderDelegate> delegate;
@property (weak, nonatomic) ICAttachment *attachment;
@property (readonly, nonatomic) ICTable *table;
@property (nonatomic) _Bool isBeingEditedLocallyOnDevice;
@property (nonatomic) _Bool needsToUpdateTableFromBackgroundAttachment;

/* class methods */
+ (id)providerMapping;
+ (id)defaultBackgroundManagedObjectContext;
+ (id)mergeNotificationRegister;
+ (void)notifyProviderForRefreshToAttachment:(id)attachment;
+ (void)saveAttachmentOnMainThread:(id)thread;
+ (id)sharedProviderForAttachment:(id)attachment;

/* instance methods */
- (id)backgroundManagedObjectContext;
- (void)didRefreshBackgroundTableAttachment:(id)attachment;
- (void)notifyDelegateTableAttachmentDidMerge;
- (void)notifyDelegateTableAttachmentWillMerge;
- (void)refreshBackgroundAttachment;
- (void)setTableFromDocument:(id)document;
- (void)updateTableFromMOC;

@end


@interface ICTableCellChangeNotifier : NSObject

@property (retain) NSHashTable *observers;

/* instance methods */
- (void)removeObserver:(id)observer;
- (id)init;
- (void)addObserver:(id)observer;
- (void)notifyOfChangeAtColumnID:(id)id rowID:(id)id delta:(long long)delta;

@end


@interface ICTableVersionedDocument : ICTTVersionedDocument

@property (retain, nonatomic) ICTable *table;
@property (readonly) ICCRDocument *innerTableDocument;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;

/* instance methods */
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (id)serializeCurrentVersion:(unsigned int *)version;
- (id)initWithColumnCount:(unsigned long long)count rowCount:(unsigned long long)count replicaID:(id)id;
- (unsigned long long)mergeWithTableVersionedDocument:(id)document;

@end


@interface ICTagSelection : ICFilterTypeSelection <NSSecureCoding, NSCopying>

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) NSURL *accountObjectIDURL;
@property (retain, nonatomic) NSSet *includedObjectIDURLs;
@property (retain, nonatomic) NSSet *excludedObjectIDURLs;
@property (retain, nonatomic) NSSet *hashtagObjectIDURLs;
@property (nonatomic) unsigned long long mode;
@property (nonatomic) unsigned long long tagOperator;
@property (nonatomic) _Bool allowsRecentlyDeleted;
@property (nonatomic) _Bool automaticallyRemoveDeletedTags;
@property (readonly, nonatomic) _Bool isNonEmpty;
@property (readonly, nonatomic) _Bool hasMultipleTagsSelected;
@property (retain, nonatomic) NSSet *includedObjectIDs;
@property (retain, nonatomic) NSSet *excludedObjectIDs;
@property (retain, nonatomic) NSArray *tags;
@property (readonly, nonatomic) NSArray *includedTags;
@property (readonly, nonatomic) NSArray *excludedTags;
@property (readonly, nonatomic) NSSet *objectIDs;
@property (readonly, nonatomic) NSArray *includedTagIdentifiers;
@property (readonly, nonatomic) NSArray *excludedTagIdentifiers;
@property (readonly, nonatomic) NSArray *tagIdentifiers;
@property (readonly, nonatomic) NSArray *includedDisplayTexts;
@property (readonly, nonatomic) NSArray *excludedDisplayTexts;
@property (readonly, nonatomic) NSArray *displayTexts;
@property (readonly, nonatomic) NSArray *includedHashtagPrefixedDisplayTexts;
@property (readonly, nonatomic) NSArray *excludedHashtagPrefixedDisplayTexts;
@property (readonly, nonatomic) NSArray *hashtagPrefixedDisplayTexts;
@property (readonly, nonatomic) NSSet *unresolvedTagIdentifiers;
@property (retain, nonatomic) NSSet *unresolvedIncludedTagIdentifiers;
@property (retain, nonatomic) NSSet *unresolvedExcludedTagIdentifiers;
@property (readonly, nonatomic) unsigned long long selectedTagCount;
@property (readonly, nonatomic) NSString *selectedTagCountString;
@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *actionTitle;
@property (readonly, copy, nonatomic) NSString *smartFolderTitle;
@property (readonly, nonatomic) NSData *dataRepresentation;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)keyPathsForValuesAffectingIsEmpty;
+ (id)keyPathsForValuesAffectingIsNonEmpty;
+ (id)keyPathsForValuesAffectingIsValid;
+ (id)keyPathsForValuesAffectingObjectIDs;
+ (id)keyPathsForValuesAffectingSelectedTagCount;
+ (id)tagSelectionWithData:(id)data managedObjectContext:(id)context;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)filterType;
- (id)debugDescription;
- (_Bool)isEmpty;
- (_Bool)isValid;
- (void)clear;
- (void)dealloc;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)filterName;
- (unsigned long long)hash;
- (id)initWithManagedObjectContext:(id)context;
- (id)initWithCoder:(id)coder;
- (void)removeObjectIDs:(id)ids;
- (void)removeUnresolvedTagIdentifiers:(id)identifiers;
- (void)addObjectID:(id)id toExcluded:(_Bool)excluded;
- (void)addUnresolvedTagIdentifier:(id)identifier toExcluded:(_Bool)excluded;
- (void)commonInitWithManagedObjectContext:(id)context;
- (void)convertUnresolvedDisplayTextsInAccount:(id)account;
- (id)copyWithManagedObjectContext:(id)context;
- (id)displayTextsForObjectIDs:(id)ids;
- (id)emptySummary;
- (id)emptySummaryTitle;
- (id)hashtagPrefixedDisplayTexts:(id)texts;
- (id)hashtagsForObjectIDs:(id)ids;
- (id)initWithManagedObjectContext:(id)context includedObjectIDs:(id)ids;
- (id)initWithManagedObjectContext:(id)context includedObjectIDs:(id)ids excludedObjectIDs:(id)ids;
- (id)initWithManagedObjectContext:(id)context includedObjectIDs:(id)ids excludedObjectIDs:(id)ids tagOperator:(unsigned long long)_operator;
- (id)initWithManagedObjectContext:(id)context mode:(unsigned long long)mode;
- (id)initWithManagedObjectContext:(id)context mode:(unsigned long long)mode tagOperator:(unsigned long long)_operator;
- (_Bool)isEqualToTagSelection:(id)selection;
- (void)managedObjectContextObjectIDsDidSave:(id)save;
- (id)rawFilterValue;
- (void)removeObjectID:(id)id fromExcluded:(_Bool)excluded;
- (void)removeUnresolvedTagIdentifier:(id)identifier fromExcluded:(_Bool)excluded;
- (void)resolveManagedObjectsFromURLs;
- (id)shortEmptySummary;
- (id)standardizedContentsForObjectIDs:(id)ids;

@end


@interface ICThumbnailData : NSObject

@property (retain, nonatomic) NSImage *image;
@property (nonatomic) unsigned long long imageScaling;
@property (nonatomic) _Bool showAsFileIcon;
@property (nonatomic) _Bool isMovie;

/* instance methods */
- (id)initWithImage:(id)image imageScaling:(unsigned long long)scaling showAsFileIcon:(_Bool)icon isMovie:(_Bool)movie;

@end


@interface ICTranscription : NSObject

/* class methods */
+ (id)sharedInstance;
+ (void)setSharedInstance:(id)instance;

/* instance methods */
- (id)init;
- (void)addAudioTranscriptionTaskToQueueWithAttachmentIdentifier:(id)identifier;
- (void)addCallRecordingTranscriptionTaskToQueueWithSpeakers:(id)speakers attachmentIdentifier:(id)identifier;

@end


@interface ICUTType : NSObject

/* class methods */
+ (id)typeWithIdentifier:(id)identifier;
+ (id)noteSpotlightType;

@end


@interface ICUnsupportedObjectPredicateHelper : NSObject

/* class methods */
+ (id)predicateForSupportedAttachmentsInContext:(id)context;
+ (id)predicateForSupportedFoldersInContext:(id)context;
+ (id)predicateForSupportedInlineAttachmentsInContext:(id)context;
+ (id)predicateForSupportedNotesInContext:(id)context;
+ (void)recursivelyAddAttachment:(id)attachment toMutableSet:(id)set;
+ (void)recursivelyAddFolder:(id)folder toMutableSet:(id)set;
+ (id)unitTest_unsupportedAttachmentIdentifiersWithContext:(id)context;
+ (id)unitTest_unsupportedFolderIdentifiersWithContext:(id)context;
+ (id)unsupportedAttachmentIdentifiersWithContext:(id)context;
+ (id)unsupportedFolderIdentifiersWithContext:(id)context;
+ (id)unsupportedInlineAttachmentIdentifiersWithContext:(id)context;

@end


@interface ICUserSpecificRecordIDParser : NSObject <NSCopying>

@property (readonly, nonatomic) NSString *recordType;
@property (readonly, nonatomic) CKRecordID *recordID;
@property (readonly, nonatomic) NSString *sharedRecordType;
@property (readonly, nonatomic) CKRecordID *sharedRecordID;

/* class methods */
+ (_Bool)isUserSpecificRecordID:(id)id;
+ (_Bool)isUserSpecificRecordType:(id)type;
+ (id)sharedRecordTypeForUserSpecificRecordType:(id)type;
+ (id)userSpecificRecordTypeForSharedRecordType:(id)type;

/* instance methods */
- (_Bool)validate;
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithRecordName:(id)name;
- (id)initWithSharedRecordType:(id)type sharedRecordID:(id)id userRecordName:(id)name ownerName:(id)name;

@end


@interface NotesAssistantAccountManager : NSObject <ICNFMCAccountProxyManager>

@property (retain, nonatomic) NSMapTable *accounts;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)sharedInstance;

/* instance methods */
- (id)init;
- (void)_reloadAccounts;
- (void)_performFetchForAccountsWithIdentifiers:(id)identifiers;
- (id)accountProxyForAccount:(id)account;
- (void)performFetchForAccount:(id)account;

@end


@interface NotesAssistantFolderOption : NSObject

@property (retain, nonatomic) NSString *fullTitle;
@property (retain, nonatomic) NSString *accountTitle;
@property (retain, nonatomic) NSString *accountIdentifier;
@property (retain, nonatomic) NSManagedObjectID *managedObjectID;
@property (retain, nonatomic) NSString *identifierURIPathComponent;
@property (retain, nonatomic) NSString *parentTitle;
@property (retain, nonatomic) NSString *title;

/* class methods */
+ (void)disambiguateFolderOptions:(id)options;
+ (void)disambiguateSameTitleFolderOptions:(id)options;

/* instance methods */
- (id)debugDescription;
- (id)initWithLegacyFolder:(id)folder;
- (id)initWithModernFolder:(id)folder;

@end


@interface NotesAssistantMainThreadContext : NSObject

/* class methods */
+ (void)_contextDidSave:(id)save;
+ (void)_mainContextObjectsDidChange:(id)change;
+ (void)initializeSearchIndexerDataSource;
+ (_Bool)saveSharedContext;
+ (_Bool)sharedContextExists;
+ (id)sharedMainThreadContext;

@end


@interface NotesAssistantUtilities : NSObject

/* class methods */
+ (id)folderForGroupName:(id)name withNoteContext:(id)context htmlNoteContext:(id)context;
+ (id)folderOptionsForModernContext:(id)context htmlContext:(id)context;
+ (id)legacyFolderForGroupName:(id)name withContext:(id)context;
+ (id)modernFolderForGroupName:(id)name withContext:(id)context;
+ (id)objectForIDURL:(id)idurl inContext:(id)context;

@end


@interface TTICCRVectorMultiTimestamp : ICTTVectorMultiTimestamp

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCapacity:(unsigned long long)capacity;
- (_Bool)isDocumentShared;

@end


@interface _TtC11NotesShared15ArgumentDecoder : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared15BufferConverter : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared16NotesDataManager : NSObject

/* instance methods */
- (id)init;
- (void)dealloc;

@end


@interface _TtC11NotesShared18TranscriptMetadata : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared20CancellableTaskQueue : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared20SummarizationManager : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC11NotesShared21CallRecordingSplitter : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC11NotesShared21ICSystemPaperDocument : NSObject

@property (nonatomic, readonly) CRContext *coherenceContext;

/* class methods */
+ (id)assetsDirectoryAt:(id)at;
+ (void)closeContextForNote:(id)note;
+ (id)databaseDirectoryAt:(id)at;

/* instance methods */
- (id)init;
- (void)removeStrokesFromStyleInventory;
- (id)archiveBundleForSyncAndReturnError:(id *)error;
- (_Bool)copyAndArchivePaperBundleTo:(id)to error:(id *)error;
- (id)initWithPaperAttachment:(id)attachment;
- (_Bool)restorePaperBundleFrom:(id)from error:(id *)error;
- (id)toFallbackPDFData;
- (void)updateGraphDestinationsUsingInlineAttachmentIdentifierMap:(id)map completion:(id /* block */)completion;
- (_Bool)writeNewVersionFromSyncArchive:(id)archive error:(id *)error;

@end


@interface _TtC11NotesShared21ICTTTranscriptSegment : ICCRObject // (Swift)

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *timestamp;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSString *speaker;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface _TtC11NotesShared22ICModernObjectProvider : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared23SiriTranscriptionMethod : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared23TranscriptPostProcessor : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC11NotesShared24CallRecordingTranscriber : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC11NotesShared26NotesServiceAPIAsyncClient : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared28LiveTranscriptionCoordinator : _TtCs12_SwiftObject

@end


@interface _TtC11NotesShared28SiriSpeechRecognitionManager : NSObject

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesShared29TranscriptPauseTextAttachment : NSTextAttachment

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithData:(id)data ofType:(id)type;

@end


@interface _TtC11NotesShared34ICAttachmentSystemPaperModelHelper : NSObject // (Swift)

/* class methods */
+ (_Bool)canDisplayPaperAtURL:(id)url;
+ (long long)minimumSupportedNotesVersionForPaperAtURL:(id)url greaterOrEqualToVersion:(long long)version;

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesShared38RealtimeCollaborationSelectionDocument : ICCRDocument

/* instance methods */
- (id)init;
- (id)initWithReplica:(id)replica;
- (id)initWithVersion:(id)version rootObject:(id)object replica:(id)replica;
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica;
- (unsigned long long)mergeWithData:(id)data;

@end


@interface _TtC11NotesSharedP33_062F6D09343CCB133320AB174EF013C433ICCloudingSyncingObjectUndoTarget : NSObject // (Swift)

/* instance methods */
- (id)init;

@end


@interface _TtC11NotesSharedP33_452BF3924CAE69326F83BAE5FEEBFB4234CustomReplacementRegularExpression : NSRegularExpression

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithPattern:(id)pattern options:(unsigned long long)options error:(id *)error;
- (id)replacementStringForResult:(id)result inString:(id)string offset:(long long)offset template:(id)_template;

@end


@interface _TtCC11NotesShared12CloudSession12PhaseMetrics : _TtCs12_SwiftObject

@end


@interface _TtCC11NotesShared15ArgumentDecoder7Decoder : _TtCs12_SwiftObject

@end


@interface _TtCC11NotesShared21ICSystemPaperDocument17PaperBundleReader : _TtCs12_SwiftObject

@end


@interface _TtCC11NotesShared38RealtimeCollaborationSelectionDocument5State : ICCRObject // (Swift)

@property (nonatomic, retain) id participantIDsToSelectionRegisters;
@property (nonatomic, retain) id participantIDsOrder;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface _TtCE11NotesSharedCSo18ICTTAudioRecording8Fragment : ICCRObject // (Swift)

@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) id transcript;
@property (nonatomic, retain) NSNumber *transcriptVersion;

/* class methods */
+ (id)CRProperties;

/* instance methods */
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface CKAsset (IC)

/* instance methods */
- (_Bool)isFetched;
- (_Bool)isUnfetched;

@end


@interface CKDatabaseOperation (IC)

/* instance methods */
- (id)ic_loggingValues;

@end


@interface CKFetchDatabaseChangesOperation (IC)

/* instance methods */
- (id)ic_loggingValues;
- (void)ic_removeAllCompletionBlocks;

@end


@interface CKFetchRecordZoneChangesOperation (IC)

/* instance methods */
- (id)ic_loggingValues;
- (void)ic_removeAllCompletionBlocks;
- (id)ic_shortLoggingDescription;

@end


@interface CKFetchRecordsOperation (IC)

/* instance methods */
- (void)ic_removeAllCompletionBlocks;

@end


@interface CKModifyRecordsOperation (IC)

/* instance methods */
- (void)ic_removeAllCompletionBlocks;

@end


@interface CKOperation (IC) <ICLoggable>

/* instance methods */
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;
- (void)ic_removeAllCompletionBlocks;

@end


@interface CKOperationGroup (IC) <ICLoggable>

/* instance methods */
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;

@end


@interface CKRecord (IC) <ICHasDatabaseScope>

/* class methods */
+ (id)ic_encryptedDataKeyForAssetKey:(id)key;
+ (id)ic_systemFieldsValueTransformer;
+ (id)ic_assetKeyForKeyPrefix:(id)prefix;
+ (id)ic_encryptedKeyForKeyPrefix:(id)prefix;
+ (id)ic_valueKeyForKeyPrefix:(id)prefix;

/* instance methods */
- (long long)databaseScope;
- (void)ic_inlineDataAssetForKeyPrefix:(id)prefix;
- (id)assetsByKey;
- (_Bool)hasFetchedAssets;
- (_Bool)hasUnfetchedAssets;
- (id)ic_copyWithUserFields:(_Bool)fields;
- (id)ic_encryptedInlineableDataAssetForKeyPrefix:(id)prefix;
- (_Bool)ic_hasMetadata;
- (void)ic_inlineEncryptedDataAssetForKeyPrefix:(id)prefix;
- (id)ic_inlineableDataAssetForKeyPrefix:(id)prefix;
- (_Bool)ic_isOwnedByCurrentUser;
- (id)ic_loggingDescription;
- (void)ic_setEncryptedInlineableDataAsset:(id)asset forKeyPrefix:(id)prefix approach:(long long)approach withObject:(id)object;
- (void)ic_setInlineableDataAsset:(id)asset forKeyPrefix:(id)prefix approach:(long long)approach withObject:(id)object;
- (_Bool)ic_shouldUseAssetForInlineableDataAsset:(id)asset approach:(long long)approach;

@end


@interface CKRecordID (IC) <ICHasDatabaseScope>

/* instance methods */
- (long long)databaseScope;
- (_Bool)ic_hasEqualRecordNameWithRecordID:(id)id;
- (_Bool)ic_isOwnedByCurrentUser;
- (id)ic_loggingDescription;
- (id)ic_loggingDescriptionIncludingBrackets:(_Bool)brackets;

@end


@interface CKRecordZoneID (IC) <ICHasDatabaseScope>

/* instance methods */
- (long long)databaseScope;
- (_Bool)ic_isOwnedByCurrentUser;
- (id)ic_loggingDescription;

@end


@interface CKServerChangeToken (IC)

/* instance methods */
- (id)ic_loggingDescription;

@end


@interface CKShare (IC)

/* class methods */
+ (id)ic_systemFieldsValueTransformer;

/* instance methods */
- (unsigned long long)_nonOwnerParticipantsCountWithAcceptanceStatus:(long long)status;
- (unsigned long long)_nonCurrentUserParticipantsCountWithAcceptanceStatus:(long long)status;
- (id)ic_acceptedParticipants;
- (_Bool)ic_isPublicShare;
- (id)ic_nonCurrentUserAcceptedParticipants;
- (id)ic_nonCurrentUserParticipants;
- (unsigned long long)ic_nonOwnerAcceptedParticipantsCount;
- (unsigned long long)ic_nonOwnerInvitedParticipantsCount;
- (unsigned long long)ic_nonOwnerPendingParticipantsCount;
- (id)ic_participantWithHandle:(id)handle;
- (id)ic_participantWithUserRecordName:(id)name;

@end


@interface CKShareParticipant (IC)

/* class methods */
+ (id)ic_displayableNames:(id)names maximumNamesCount:(unsigned long long)count;
+ (unsigned long long)ic_mentionTokensPerParticipant;
+ (id)ic_mentionableNamesCache;
+ (id)ic_nonCurrentUserParticipants:(id)participants;
+ (id)ic_participantFallbackNameForUserRecordName:(id)name note:(id)note;
+ (id)ic_participantNameOrFallbackForUserRecordName:(id)name note:(id)note;
+ (id)ic_participantsWithDisplayableNames:(id)names maximumNamesCount:(unsigned long long)count;
+ (id)ic_shortParticipantNameOrFallbackForUserRecordName:(id)name note:(id)note;

/* instance methods */
- (id)ic_mentionableNamesFromContacts;
- (id)ic_emailAddress;
- (id)ic_activityStreamDisplayName;
- (id)ic_cachedDisplayNameFromContacts;
- (id)ic_mentionTokens;
- (id)ic_mentionTokensFromContacts;
- (id)ic_participantName;
- (id)ic_participantNameMatchingString:(id)string returnFullName:(_Bool)name;
- (id)ic_phoneNumber;
- (id)ic_shortParticipantName;
- (id)ic_userRecordNameInNote:(id)note;

@end


@interface CNContact (IC)

/* class methods */
+ (id)ic_contactFromParticipant:(id)participant;

/* instance methods */
- (id)ic_shortName;

@end


@interface CNContactStore (IC)

/* instance methods */
- (id)ic_contactForEmailAddressString:(id)string keysToFetch:(id)fetch;
- (id)ic_contactForHandleString:(id)string keysToFetch:(id)fetch;
- (id)ic_contatForPhoneNumberString:(id)string keysToFetch:(id)fetch;
- (id)ic_existingOrNewContactFromParticipant:(id)participant keysToFetch:(id)fetch;

@end


@interface ICNoteSnippetUtilities (NotesShared)

/* class methods */
+ (id)titleForAttributedContent:(id)content truncated:(_Bool *)truncated attributedTitleIfNecessary:(id *)necessary;
+ (id)snippetForAttributedContent:(id)content attributedSnippetIfNecessary:(id *)necessary;

@end


@interface ICWidget (Visibility)

/* instance methods */
- (_Bool)hidesObject:(id)object;

@end


@interface NFAccount (ICLegacyAccount) <ICLegacyAccount>

/* instance methods */
- (_Bool)isExchangeAccount;
- (_Bool)isManaged;
- (id)objectIdentifier;
- (id)accountIdentifier;
- (long long)compare:(id)compare;
- (id)name;
- (id)localizedName;
- (_Bool)supportsAttachments;
- (id)folders;
- (_Bool)isLocalAccount;
- (id)allItemsFolderLocalizedTitle;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (_Bool)hasAnyCustomFolders;
- (_Bool)isIMAPAccount;
- (long long)legacyAccountType;
- (id)localizedAttachmentsNotSupportedReason;
- (_Bool)preventMovingNotesToOtherAccounts;

@end


@interface NFAttachment (ICLegacyAttachment) <ICLegacyAttachment, ICAttachmentObject>

/* instance methods */
- (id)identifier;
- (id)title;
- (void)setMimeType:(id)type;
- (id)typeUTI;
- (id)identifierURIPathComponent;
- (_Bool)isDeletedOrInTrash;
- (_Bool)isHiddenFromIndexing;
- (_Bool)isHiddenFromSearch;
- (_Bool)persistAttachmentData:(id)data error:(id *)error;

@end


@interface NFFolder (ICLegacyFolder) <ICLegacyFolder>

/* instance methods */
- (id)changes;
- (id)localizedTitle;
- (long long)compare:(id)compare;
- (_Bool)isTrashFolder;
- (id)externalIdentifier;
- (id)parentFolder;
- (_Bool)isRootFolder;
- (_Bool)isDefaultFolder;
- (id)ancestorFolders;
- (id)identifierURIPathComponent;
- (_Bool)isCustomFolder;
- (id)newNoteInContext:(id)context;

@end


@interface NFNote (ICLegacyNote) <ICLegacyNote>

/* class methods */
+ (id)predicateForVisibleNotes;

/* instance methods */
- (id)account;
- (void)setHtmlString:(id)string;
- (id)htmlString;
- (_Bool)isPlainText;
- (void)markForDeletion;
- (void)associateAppEntityWithSearchableItemAttributeSet:(id)set;
- (id)contentAsPlainText;
- (_Bool)isMarkedForDeletion;

@end


@interface NSArray (PreviewDeviceInfoAppearanceAdditions)

/* instance methods */
- (id)ic_deviceInfosByAddingAppearances;

@end


@interface NSAttributedString (Shared)

/* class methods */
+ (void)enumerateAttachmentsInData:(id)data withBlock:(id /* block */)block;
+ (id)ic_attributedStringWithArchive:(const void *)archive dataPersister:(id)persister note:(id)note parentAttachment:(id)attachment shouldCreateNewAttachments:(_Bool)attachments error:(id *)error;
+ (id)ic_attributedStringWithArchive:(const void *)archive dataPersister:(id)persister note:(id)note shouldCreateNewAttachments:(_Bool)attachments error:(id *)error;
+ (id)ic_attributedStringWithData:(id)data dataPersister:(id)persister createNewAttachmentsInNote:(id)note error:(id *)error;
+ (id)ic_attributedStringWithData:(id)data dataPersister:(id)persister createNewAttachmentsInNote:(id)note forParentAttachment:(id)attachment error:(id *)error;
+ (id)ic_attributedStringWithData:(id)data dataPersister:(id)persister note:(id)note parentAttachment:(id)attachment shouldCreateAttachments:(_Bool)attachments error:(id *)error;
+ (id)ic_attributedStringWithData:(id)data dataPersister:(id)persister note:(id)note shouldCreateAttachments:(_Bool)attachments error:(id *)error;

/* instance methods */
- (id)edits;
- (id)ic_serializeWithFlags:(unsigned long long)flags dataPersister:(id)persister managedObjectContext:(id)context error:(id *)error;
- (id)abstractAttachmentsInContext:(id)context range:(struct _NSRange)range options:(unsigned long long)options;
- (id)editAtIndex:(unsigned long long)index;
- (id)editsInRange:(struct _NSRange)range;
- (void)enumerateEditsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (unsigned long long)ic_approximateAttachmentsSizeIncludingPreviews:(_Bool)previews;
- (id)ic_attributedStringByFlatteningInlineAttachmentsWithContext:(id)context;
- (id)ic_attributedStringByFlatteningInlineAttachmentsWithContext:(id)context flattenUnsupportedInlineAttachmentsOnly:(_Bool)only updateRangeValueToObjectMapBlock:(id /* block */)block replacementAttributedStringBlock:(id /* block */)block;
- (id)ic_attributedStringByFlatteningInlineAttachmentsWithContext:(id)context flattenUnsupportedInlineattachmentsOnly:(_Bool)only;
- (id)ic_attributedStringByFlatteningUnsupportedInlineAttachmentsWithContext:(id)context;
- (id)ic_attributedStringByRefreshingParagraphStyleUUIDs;
- (id)ic_attributedStringWithOnlyAdaptiveImageAttributeIfNecessary;
- (void)ic_enumerateAbstractAttachmentsInContext:(id)context range:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (void)ic_enumerateAttachmentsInContext:(id)context range:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (void)ic_enumerateAttachmentsInContext:(id)context range:(struct _NSRange)range usingBlock:(id /* block */)block;
- (void)ic_enumerateAttachmentsInContext:(id)context usingBlock:(id /* block */)block;
- (void)ic_enumerateInlineAttachmentsInContext:(id)context range:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (_Bool)ic_isCopyableSize;
- (_Bool)ic_saveToArchive:(void *)archive flags:(unsigned long long)flags dataPersister:(id)persister managedObjectContext:(id)context error:(id *)error;
- (id)ic_searchableStringInContext:(id)context;

@end


@interface NSData (CRDT) <ICCRDataType, ICCREquatable, ICCRCoding>

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface NSDate (CRDT) <ICCRDataType, ICCREquatable, ICCRCoding>

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface NSDictionary (ICSearchResultHighlightInfo)

/* class methods */
+ (id)decomposedHighlightInfo:(id)info;
+ (_Bool)highlightInfoContainsPrefixMatch:(id)match;
+ (id)highlightInfoForSearchStringWithPrefixMatchInAllFields:(id)fields language:(id)language;
+ (id)mergeFieldElement:(id)element withElement:(id)element;
+ (id)mergeHighlightInfo:(id)info withHighlighInfo:(id)info;

@end


@interface NSFileCoordinator (IC)

/* class methods */
+ (id)ic_fileCoordinationOperationQueue;

@end


@interface NSManagedObjectContext (Shared) <ICLegacyContext>

/* instance methods */
- (id)managedObjectContext;
- (id)allAccounts;
- (id)allVisibleNoteObjectIDsForAccountWithObjectID:(id)id;
- (id)allVisibleNotesForAccountWithObjectID:(id)id;
- (id)allVisibleNotesInFolder:(id)folder;
- (id)attachmentForIdentifier:(id)identifier;
- (unsigned long long)countOfVisibleNotesForAccount:(id)account;
- (id)folderForIdentifier:(id)identifier;
- (_Bool)ic_isHTMLAccountContext;
- (_Bool)ic_isModernAccountContext;
- (_Bool)ic_isNoteContext;
- (_Bool)nonEmptyNoteExistsForLegacyAccountWithObjectID:(id)id;
- (id)noteForIdentifier:(id)identifier;

@end


@interface NSManagedObjectID (Shared)

/* instance methods */
- (_Bool)ic_isLegacyType;
- (_Bool)ic_isFolderType;
- (_Bool)ic_isModernType;
- (_Bool)ic_isAccountType;
- (_Bool)ic_isAttachmentType;
- (_Bool)ic_isBaseAttachmentType;
- (_Bool)ic_isContainerType;
- (_Bool)ic_isHashtagType;
- (_Bool)ic_isInlineAttachmentType;
- (_Bool)ic_isInvitationType;
- (_Bool)ic_isLegacyAccountType;
- (_Bool)ic_isLegacyContainerType;
- (_Bool)ic_isLegacyFolderType;
- (_Bool)ic_isLegacyNoteType;
- (_Bool)ic_isModernAccountProxyType;
- (_Bool)ic_isModernAccountType;
- (_Bool)ic_isModernContainerType;
- (_Bool)ic_isModernFolderType;
- (_Bool)ic_isModernNoteType;
- (_Bool)ic_isNoteType;

@end


@interface NSMutableDictionary (ICCloudContext)

/* instance methods */
- (void)ic_addZoneID:(id)id forAccountID:(id)id;
- (void)ic_removeZoneID:(id)id forAccountID:(id)id;

@end


@interface NSNumber (CRDT_Additions) <ICCRDataType, ICCREquatable, ICCRCoding>

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface NSOperation (ICCloudSession)

/* instance methods */
- (id)ic_cloudSession;
- (void)setIc_cloudSession:(id)session;

@end


@interface NSString (CRDT_Additions) <ICCRDataType, ICCREquatable, ICCRCoding>

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)ic_quotedString;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface NSTextAttachment (IC)

/* instance methods */
- (_Bool)ic_isSystemTextAttachment;

@end


@interface NSURL (NotesShared)

/* instance methods */
- (id)fileSize;
- (id)URLByDeletingFragment;

@end


@interface NSUUID (CRDT_Additions) <ICCRDataType, ICCREquatable, ICCRCoding>

/* class methods */
+ (id)CR_zero;
+ (id)CR_UUIDFromStdString:(const void *)string;
+ (id)CR_repeatedCharUUID:(unsigned char)uuid;
+ (id)TTZero;
+ (id)CR_unserialized;
+ (id)CR_unknown;

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)deltaSince:(id)since in:(id)in;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void *)CR_toStdString;
- (long long)CR_compare:(id)cr_compare;
- (id)CR_shortDescription;
- (long long)TTCompare:(id)ttcompare;
- (id)TTShortDescription;
- (void)encodeWithICCRCoder:(id)iccrcoder;
- (id)initWithICCRCoder:(id)iccrcoder;

@end


@interface NSUndoManager (NotesShared)

/* instance methods */
- (void)registerUndoForCloudSyncingObjectActivityEvent:(id)event cloudSyncingObject:(id)object;

@end


#endif /* NotesShared_h */
