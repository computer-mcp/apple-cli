// Normalized full dump import surface for NotesSupport.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesSupport_h

#define NotesSupport_h



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



@interface _TtCs12_SwiftObject : NSObject

@end





struct CGRect;

struct _NSRange;

struct _opaque_pthread_rwlock_t;

struct sockaddr_in;



@class ACAccount, ACAccountStore, CSSearchableIndex, CSSearchableItem, CSSearchableItemAttributeSet, ICAccountUtilities, ICAppGroupDefaults, ICArchive, ICArchiveReader, ICArchiveWriter, ICAssert, ICAtomicLRUCache;

@class ICBackoffTimer, ICBaseSearchIndexerDataSource, ICCDCSIReindexer, ICCFTypeWrapper, ICCache, ICClearOnNotificationLRUCache, ICCoreDataCoreSpotlightDelegate, ICDateHeadersUtilities, ICDebugTimer, ICDeviceSupport, ICDispatchAfterBlocks, ICDispatchAfterHandler;

@class ICDistributedLock, ICErrors, ICExclusiveLock, ICFileBasedIndexProgessDataSource, ICFolderCustomNoteSortType, ICImageAnalysisController, ICIndexItemsByIdentifiersOperation, ICIndexItemsOperation, ICIndexerStateHandler, ICLRUCache, ICLaunchConfiguration, ICLocalization;

@class ICManagedObjectContextSaveAssertion, ICManagedObjectContextUpdater, ICModelAvailabilityManager, ICMutableBool, ICNoCopyDictionary, ICNoteListSortUtilities, ICNoteSnippetUtilities, ICPaths, ICPersistenceConfiguration, ICPersistentContainer, ICRWLock, ICRadarUtilities;

@class ICReachability, ICReindexAllItemsOperation, ICSearchIndexConfiguration, ICSearchIndexImplementation, ICSearchIndexProgress, ICSearchIndexProgressCoordinator, ICSearchIndexer, ICSearchableItemResult, ICSelectorDelayer, ICSettingsUtilities, ICSpotlightUtilities, ICStateHandler;

@class ICTelemetryManager, ICTuple, ICUtilities, ICWeakObject, ICWidget, NSCoreDataCoreSpotlightDelegate, NSManagedObjectContext, NSManagedObjectID, NSMergePolicy, NSPersistentContainer, NSPersistentHistoryToken, NSPersistentStore;

@class OS_dispatch_queue, RBSAssertion, _TtC12NotesSupport18AsyncPriorityQueue, _TtC12NotesSupport36GreymatterManagedProfileAvailability;

@protocol ICLRUCacheDelegate, ICLoggable, ICReindexAllItemsOperationDelegate, ICReindexing, ICSearchIndex, ICSearchIndexProgressCoordinatorDataSource, ICSearchIndexable, ICSearchIndexableTarget, ICSearchIndexerDataSource, ICStateHandlerProvider, OS_dispatch_source, RBSAssertionObserving;

// Exported by NotesSupport but omitted from the class-dump header surface.
FOUNDATION_EXPORT NSString * const ICMentionNotificationsPrefIdentifier;
FOUNDATION_EXPORT NSString * const ICResumeLastQuickNotePrefIdentifier;



@protocol ICLoggable <NSObject>

@required

/* required instance methods */
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;

@optional

@end


@protocol ICReindexAllItemsOperationDelegate <NSObject>

@required

/* required instance methods */
- (void)reindexOperationSuccessfullyStagedAllDataSources:(id)sources;

@optional

@end


@protocol ICReindexing <NSObject>

@required

@property (readonly, nonatomic) _Bool fullyStagedSinceLastReindex;

/* required instance methods */
- (void)reindexSearchableItemsWithObjectIDURIs:(id)iduris completionHandler:(id /* block */)handler;
- (void)reindexAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)forceDeleteAllProgressState;

@optional

@end


@protocol ICSearchIndex <NSObject>

@required

/* required instance methods */
- (void)beginIndexBatch;
- (void)fetchLastClientStateWithCompletionHandler:(id /* block */)handler;
- (void)slowFetchAttributes:(id)attributes protectionClass:(id)_class bundleID:(id)id identifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)endIndexBatchWithClientState:(id)state completionHandler:(id /* block */)handler;
- (void)deleteSearchableItemsWithIdentifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)deleteSearchableItemsWithDomainIdentifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)indexSearchableItems:(id)items progress:(id)progress completionHandler:(id /* block */)handler;
- (void)reportProgress:(id)progress completionHandler:(id /* block */)handler;

@optional

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


@protocol ICSearchIndexableTarget <NSObject>

@required

@property (readonly, nonatomic) id <ICSearchIndexable> targetSearchIndexable;

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


@protocol ICStateHandlerProvider <NSObject>

@required

/* class methods */
+ (void)registerStateHandler;

@optional

@end


@protocol RBSAssertionObserving <NSObject>

@required

@optional

/* optional instance methods */
- (void)assertionWillInvalidate:(id)invalidate;
- (void)assertion:(id)assertion didInvalidateWithError:(id)error;

@end


@interface ICAccountUtilities : NSObject <ICStateHandlerProvider>

@property (retain, nonatomic) ACAccountStore *accountStore;
@property (copy, nonatomic) NSDictionary *currentICloudAccountState;
@property (retain, nonatomic) NSMutableDictionary *accountByIdentifier;
@property (retain, nonatomic) NSMutableDictionary *accountIsManagedByIdentifier;
@property (nonatomic) _Bool primaryICloudACAccountValid;
@property (readonly) ACAccount *primaryICloudACAccount;
@property (readonly, nonatomic) _Bool primaryICloudAccountEnabled;
@property (readonly, nonatomic) _Bool didChooseToMigratePrimaryICloudAccount;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)sharedInstance;
+ (void)registerStateHandler;

/* instance methods */
- (void)accountStoreDidChange:(id)change;
- (id)allICloudACAccounts;
- (_Bool)hasSyncingAccount;
- (id)applicationDocumentsURLForAccountIdentifier:(id)identifier;
- (id)applicationDataContainerURLForAccountIdentifier:(id)identifier;
- (_Bool)isManagedACAccountWithIdentifier:(id)identifier;
- (void)performBlockInPersonaContext:(id /* block */)context forAccountIdentifier:(id)identifier;
- (id)initForObservingAccountStoreChanges:(_Bool)changes;
- (void)updateICloudACAccountFromStore;
- (void)invalidateCache;
- (id)init;
- (id)iCloudACAccountWithIdentifier:(id)identifier;
- (void)createDirectoryIfNecessaryUsingURL:(id)url;
- (void)internalInvalidatePrimaryICloudACAccount;
- (void)dealloc;
- (_Bool)isPrimaryICloudACAccountValid;
- (id)temporaryDirectoryURLForAccountIdentifier:(id)identifier;

@end


@interface ICAppGroupDefaults : NSObject

/* class methods */
+ (id)sharedAppGroupDefaults;

@end


@interface ICArchive : NSObject

/* class methods */
+ (id)userDefaultsKey;
+ (id)universalTypeIdentifier;
+ (id)demoModeUserDefaultsKey;

@end


@interface ICArchiveReader : NSObject

@property (copy, nonatomic) NSString *sourcePath;
@property (copy, nonatomic) NSString *destinationPath;
@property (nonatomic) _Bool overwrite;
@property (nonatomic) _Bool writesTemporaryFilesInsideDestination;
@property (nonatomic) _Bool skipsInvisibleHeaders;

/* instance methods */
- (id)initWithSourceURL:(id)url destinationURL:(id)url;
- (id)incrementalPathInDirectory:(id)directory withFilename:(id)filename andExtension:(id)extension;
- (_Bool)moveContentsOfDirectory:(id)directory toDirectory:(id)directory resultURLs:(id *)urls error:(id *)error;
- (_Bool)unarchiveResultURLs:(id *)urls error:(id *)error;
- (_Bool)unarchiveSourcePath:(id)path toDestinationPath:(id)path error:(id *)error;
- (id)temporaryDirectoryWithError:(id *)error;

@end


@interface ICArchiveWriter : NSObject

@property (retain, nonatomic) NSURL *destinationURL;
@property (retain, nonatomic) NSString *basePath;
@property (nonatomic) _Bool usesCompression;
@property (nonatomic) _Bool flatten;
@property (copy, nonatomic) NSString *flattenFolderName;

/* instance methods */
- (_Bool)finish:(id *)finish;
- (void)dealloc;
- (_Bool)open:(id *)open;
- (id)initWithDestinationURL:(id)url baseURL:(id)url;
- (_Bool)writeURL:(id)url isDirectory:(_Bool)directory error:(id *)error;
- (_Bool)writeURLs:(id)urls error:(id *)error;

@end


@interface ICAssert : NSObject

/* class methods */
+ (void)handleFailedAssertWithCondition:(const char *)condition functionName:(const char *)name simulateCrash:(_Bool)crash showAlert:(_Bool)alert alertMessage:(id)message format:(id)format;
+ (void)handleFailedAssertWithCondition:(const char *)condition functionName:(const char *)name simulateCrash:(_Bool)crash showAlert:(_Bool)alert format:(id)format;

@end


@interface ICLRUCache : NSObject

@property (readonly, nonatomic) unsigned long long maxSize;
@property (readonly, nonatomic) NSArray *allKeys;
@property (weak, nonatomic) id <ICLRUCacheDelegate> delegate;

/* class methods */
+ (id)cacheCollection;
+ (void)purgeAllCaches;

/* instance methods */
- (id)initWithMaxSize:(unsigned long long)size;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (void)p_removeOldestObject;

@end


@interface ICAtomicLRUCache : ICLRUCache

/* instance methods */
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (id)allKeys;
- (void)setObject:(id)object forKey:(id)key;

@end


@interface ICBackoffTimer : NSObject

@property (nonatomic) double initialTimeInterval;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL selector;
@property (retain, nonatomic) id userInfo;
@property (nonatomic) unsigned long long backoffCount;
@property (nonatomic) double maxTimeInterval;
@property (retain) NSTimer *timer;

/* instance methods */
- (void)fire;
- (id)init;
- (_Bool)isScheduled;
- (void)dealloc;
- (void)invalidate;
- (void)fire:(id)fire;
- (double)nextTimeInterval;
- (id)initWithInitialInterval:(double)interval maxInterval:(double)interval target:(id)target selector:(SEL)selector userInfo:(id)info;
- (void)scheduleToFire;

@end


@interface ICBaseSearchIndexerDataSource : NSObject <ICSearchIndexerDataSource>

@property (retain, nonatomic) NSObject *processingQueue;
@property (readonly, copy, nonatomic) NSString *stateFilename;
@property (readonly, nonatomic) NSURL *stateFileURL;
@property (retain, nonatomic) NSMutableOrderedSet *objectIDsToProcess;
@property (retain, nonatomic) NSMutableOrderedSet *objectIDsBeingProcessed;
@property (readonly, nonatomic) NSString *uuid;
@property (nonatomic) _Bool observingChanges;
@property _Bool needsReindexing;
@property (retain, nonatomic) ICSearchIndexProgressCoordinator *progressCoordinator;
@property (retain, nonatomic) id <ICSearchIndexProgressCoordinatorDataSource> fallbackProgressDataSource;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)persistentStoreCoordinator;
- (id)allIndexableObjectIDsInReversedReindexingOrderWithContext:(id)context;
- (void)stopObservingChanges;
- (_Bool)isFolderWithServerShareChanged:(id)changed;
- (id)init;
- (id)dataSourceIdentifier;
- (void)contextWillSave:(id)save;
- (unsigned long long)indexingPriority;
- (id)addNotesFromSubtree:(id)subtree;
- (void)startObservingChanges;
- (_Bool)isObservingChanges;
- (id)newManagedObjectContext;
- (id)objectForSearchableItem:(id)item context:(id)context;
- (id)additionalItemsForObject:(id)object;
- (id)additionalUniqueIdentifiersToDeleteForObject:(id)object;
- (_Bool)isPaperKitOrSynapseAttachment:(id)attachment;
- (id)progressDataSource;
- (id)searchableItemResultForObject:(id)object;
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
- (_Bool)_loadStateDictionaryWithFileManager:(id *)manager fileURL:(id *)url NSError:(id *)nserror fileExists:(_Bool *)exists savedDictionary:(id *)dictionary;
- (_Bool)addNewObjectsForProcessing:(id)processing;
- (void)clearObjectIDsToIgnoreAndStageForReindexing;
- (void)loadOrClearStateIfNecessary;
- (id)loadStateDictionary;
- (void)logFileSizeForFileAtPath:(id)path fileManager:(id)manager;
- (id)moveIndexingTrackingFromUserDefaultsToFileIfNecessary;
- (id)objectIDsFromSearchableItems:(id)items;
- (void)resetContextObservers;
- (_Bool)saveStateDictionary:(id)dictionary;
- (void)saveStateIfNecessary;
- (_Bool)shouldIndexableObjectExistInIndexing:(id)indexing;

@end


@interface ICCDCSIReindexer : NSObject <ICReindexing>

@property (retain, nonatomic) NSMutableArray *registeredDelegates;
@property (readonly, nonatomic) _Bool fullyStagedSinceLastReindex;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)searchableIndex;
+ (id)sharedReindexer;

/* instance methods */
- (void)reindexSearchableItemsWithObjectIDURIs:(id)iduris completionHandler:(id /* block */)handler;
- (id)init;
- (void)reindexAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)forceDeleteAllProgressState;
- (void)registerCoreDataCoreSpotlightDelegate:(id)delegate;
- (void)stopIndexing;
- (void)_reindexSearchableItemsWithIdentifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)unregisterCoreDataCoreSpotlightDelegate:(id)delegate;

@end


@interface ICCFTypeWrapper : NSObject

@property (nonatomic) void * cfTypeRef;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)dealloc;
- (unsigned long long)hash;
- (void *)ref;
- (id)initWithCFTypeRef:(void *)ref;

@end


@interface ICCache : NSCache

@property (retain, nonatomic) NSObject *memoryWarningEventSource;
@property (retain, nonatomic) NSMutableSet *mutableKeys;
@property (retain, nonatomic) NSObject *mutableKeysAccessQueue;
@property (readonly, nonatomic) NSSet *allKeys;

/* class methods */
+ (id)cacheCollection;
+ (void)purgeAllCaches;

/* instance methods */
- (void)removeAllObjects;
- (id)init;
- (void)removeObjectForKey:(id)key;
- (void)dealloc;
- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)object forKey:(id)key cost:(unsigned long long)cost;
- (void)receivedMemoryWarning;
- (void)registerForMemoryWarnings;
- (void)unregisterForMemoryWarnings;
- (void)removeObjectsWithKeyContainingString:(id)string;

@end


@interface ICClearOnNotificationLRUCache : ICAtomicLRUCache

@property (retain, nonatomic) id <NSObject> notificationToken;

/* instance methods */
- (void)dealloc;
- (id)initWithMaxSize:(unsigned long long)size notificationName:(id)name;

@end


@interface ICCoreDataCoreSpotlightDelegate : NSCoreDataCoreSpotlightDelegate

@property (nonatomic) _Bool isCheckingObjectConsistency;
@property (readonly, nonatomic) _Bool shouldPerformConsistencyCheck;
@property (nonatomic) unsigned long long indexingPriority;

/* instance methods */
- (id)indexName;
- (void)dealloc;
- (id)bundleIdentifier;
- (id)attributeSetForObject:(id)object;
- (void)startSpotlightIndexing;
- (void)stopSpotlightIndexing;
- (id)initForStoreWithDescription:(id)description coordinator:(id)coordinator indexingPriority:(unsigned long long)priority;
- (_Bool)shouldIndexableObjectExistInIndexing:(id)indexing;

@end


@interface ICDateHeadersUtilities : NSObject

/* class methods */
+ (void)clearCache;
+ (id)menuTitle;
+ (long long)defaultDateHeadersType;
+ (id)actionItemTitleWithDateHeadersType:(long long)type;
+ (_Bool)currentDateHeadersOn;
+ (_Bool)isShowingQueryDateHeadersForDateHeadersType:(long long)type;
+ (long long)queryDateHeadersType;
+ (void)setDateHeadersOn:(_Bool)on;
+ (void)setDateHeadersUserPreference:(long long)preference forKey:(id)key postNotificationName:(id)name;
+ (void)setDefaultDateHeadersType:(long long)type;
+ (void)setQueryDateHeadersType:(long long)type;
+ (_Bool)showsQueryDateHeaders;
+ (id)stringForDateHeadersType:(long long)type;
+ (_Bool)supportsQueryDateHeaders;

@end


@interface ICDebugTimer : NSObject

@property (retain) NSDate *startingDate;
@property double elapsedTime;

/* class methods */
+ (id)debugTimerForClass:(Class)_class;
+ (void)enableTimersForClass:(Class)_class;

/* instance methods */
- (void)stop;
- (void)pause;
- (void)start;
- (void)resume;

@end


@interface ICDeviceSupport : NSObject

/* class methods */
+ (id)productName;
+ (_Bool)isLowPowerModeEnabled;
+ (id)productVersion;
+ (id)deviceName;
+ (_Bool)deviceIsVision;
+ (id)productBuildVersion;
+ (_Bool)isRunningUnitTests;
+ (_Bool)deviceIsMac;
+ (_Bool)deviceIsWAPICapable;
+ (_Bool)isRunningInApp;
+ (_Bool)deviceSupportsMetal;
+ (_Bool)isDeviceHot;
+ (_Bool)processIsSiri;
+ (_Bool)isRunningDuoTests;

@end


@interface ICDispatchAfterBlocks : NSObject

@property (copy, nonatomic) id <NSCopying> identifier;

/* instance methods */
- (void)performBlock:(id /* block */)block;
- (id)initWithIdentifier:(id)identifier;
- (void)dealloc;
- (void)cancelAll;
- (void)dispatchAfter:(double)after withBlock:(id /* block */)block;

@end


@interface ICDispatchAfterHandler : NSObject

@property (retain, nonatomic) NSMutableDictionary *identifierBlockMap;

/* class methods */
+ (id)appLifeCycleHandler;

/* instance methods */
- (id)init;
- (void)cancelAll;
- (void)cancelBlocksWithStringIdentifier:(id)identifier;
- (void)dispatchAfter:(double)after stringIdentifier:(id)identifier withBlock:(id /* block */)block;
- (id)identifierForStringIdentifier:(id)identifier;

@end


@interface ICDistributedLock : NSObject

@property (readonly, copy) NSDate *lockDate;

/* class methods */
+ (id)lockWithPath:(id)path;

/* instance methods */
- (id)initWithPath:(id)path;
- (_Bool)tryLock;
- (void)unlock;
- (id)description;
- (id)init;
- (void)dealloc;
- (void)invalidate;
- (void)breakLock;

@end


@interface ICErrors : NSObject

/* class methods */
+ (id)performBlockByCatchingExceptionsAsError:(id /* block */)error;

@end


@interface ICExclusiveLock : NSObject <NSLocking>

/* instance methods */
- (_Bool)tryLock;
- (void)unlock;
- (void)lock;
- (id)name;
- (id)init;
- (void)dealloc;
- (void)setName:(id)name;
- (id)initWithName:(id)name cachePath:(id)path;

@end


@interface ICFileBasedIndexProgessDataSource : NSObject <ICSearchIndexProgressCoordinatorDataSource>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, copy) NSSet *pendingNew;
@property (nonatomic, copy) NSSet *pendingUpdate;
@property (nonatomic, copy) NSSet *completed;
@property (nonatomic) long long batchDepth;
@property (nonatomic) _Bool batchDirty;
@property (nonatomic, readonly) OS_dispatch_queue *queue;
@property (nonatomic, readonly) NSURL *persistenceURL;

/* instance methods */
- (void)flush;
- (void)update:(id)update;
- (id)init;
- (void)reset;
- (id)initWithIdentifier:(id)identifier;
- (void)adoptIndexState:(unsigned long long)state forItemWithIdentifier:(id)identifier updatingProgress:(id)progress;
- (id)allItemIdentifiersForState:(unsigned long long)state;
- (void)beginBatchPersistence;
- (void)endBatchPersistence;
- (void)fullProgressUpdateWithCompletionHandler:(id /* block */)handler;
- (void)revertStagingWithItemIdentifier:(id)identifier;
- (void)stageForProcessingWithItemIdentifier:(id)identifier updatingProgress:(id)progress;
- (unsigned long long)stateOfItemWithIdentifier:(id)identifier;
- (void)flushIfNotBatching;

@end


@interface ICFolderCustomNoteSortType : NSObject

@property (nonatomic) long long order;
@property (nonatomic) long long direction;
@property (readonly, nonatomic) NSNumber *valueRepresentation;
@property (readonly, nonatomic) _Bool isDefault;
@property (readonly, nonatomic) long long resolvedCustomSortTypeOrder;
@property (readonly, nonatomic) NSString *buttonTitleDescription;

/* class methods */
+ (id)touchBarItemTitleForOrder:(long long)order;
+ (id)querySortType;
+ (long long)customOrderForGlobalSortType:(long long)type;
+ (void)setQuerySortType:(id)type;
+ (id)sortTypeOrderValues;
+ (long long)customOrderForCurrentNoteListSortType;
+ (id)noteSortTypeDefaultAscending;
+ (id)actionItemTitleForOrder:(long long)order;
+ (id)folderNoteSortTypeWithOrder:(long long)order direction:(long long)direction;
+ (id)currentDefaultMenuItemString;
+ (id)stringNameForDirection:(long long)direction order:(long long)order;
+ (id)folderNoteSortTypeFromValue:(id)value;

/* instance methods */
- (id)folderNoteSortTypeByChangingOrder:(long long)order;
- (_Bool)isEqual:(id)equal;
- (id)debugStringNameForOrder:(long long)order;
- (_Bool)isAscending;
- (id)description;
- (id)folderNoteSortTypeByChangingDirection;

@end


@interface ICImageAnalysisController : NSObject

@property (readonly, nonatomic) NSObject *photoLibraryQueue;

/* class methods */
+ (id)sharedController;

/* instance methods */
- (id)init;
- (void)analyzeSearchableItems:(id)items completion:(id /* block */)completion;

@end


@interface ICIndexItemsOperation : NSOperation

@property (retain, nonatomic) id <ICSearchIndex> searchableIndex;
@property (copy, nonatomic) NSArray *dataSources;
@property (retain, nonatomic) NSError *error;
@property (retain, nonatomic) NSMutableArray *objectIDsToIndex;
@property (retain, nonatomic) NSMutableArray *searchableItemsToIndex;
@property (nonatomic) unsigned long long totalSizeOfSearchableItemsToIndex;
@property (retain, nonatomic) NSMutableArray *objectIDURIsToDelete;
@property (retain, nonatomic) NSMutableDictionary *contextCache;

/* instance methods */
- (void)main;
- (id)init;
- (void)_commitObjectIDURIsToDeleteForDataSource:(id)source;
- (void)_commitObjectIDsToIndexForDataSource:(id)source;
- (_Bool)_shouldCommitDeletionWithHasItemsToDeleteThenUpdate:(_Bool)update shouldForceCommit:(_Bool)commit;
- (_Bool)_shouldCommitIndexingWithHasItemsToDeleteThenUpdate:(_Bool)update shouldForceCommit:(_Bool)commit;
- (void)commitIfNecessaryForDataSource:(id)source hasItemsToDeleteThenUpdate:(_Bool)update forceCommit:(_Bool)commit;
- (id)currentCombinedProgress;
- (id)initWithSearchableIndex:(id)index dataSources:(id)sources;
- (id)managedObjectContextForDataSource:(id)source;
- (void)processItems;

@end


@interface ICIndexItemsByIdentifiersOperation : ICIndexItemsOperation

@property (copy, nonatomic) NSArray *objectIDURIsToIndex;

/* instance methods */
- (void)main;
- (id)initWithSearchableIndex:(id)index dataSources:(id)sources;
- (id)initWithSearchableIndex:(id)index dataSources:(id)sources objectIDURIsToIndex:(id)index;

@end


@interface ICIndexerStateHandler : NSObject <ICStateHandlerProvider>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)setStateDictionary:(id)dictionary;
+ (void)registerStateHandler;
+ (id)stateDictionary;
+ (void)logMethodCall:(unsigned long long)call;

@end


@interface ICLaunchConfiguration : NSObject

@property (nonatomic) unsigned long long environment;
@property (copy, nonatomic) NSString *container;
@property (nonatomic) _Bool resetsCloud;
@property (nonatomic) _Bool resetsContainer;
@property (nonatomic) _Bool resetsState;
@property (copy, nonatomic) NSString *localAccountArchiveName;
@property (copy, nonatomic) NSString *cloudAccountArchiveName;
@property (readonly, nonatomic) NSArray *launchArguments;

/* class methods */
+ (id)userInterfaceTesting;
+ (id)currentConfiguration;
+ (id)nonDefaultValueForValue:(id)value;

/* instance methods */
- (id)initWithDictionary:(id)dictionary;
- (id)initWithEnvironment:(unsigned long long)environment container:(id)container resetsContainer:(_Bool)container resetsCloud:(_Bool)cloud resetsState:(_Bool)state localAccountArchive:(id)archive cloudAccountArchive:(id)archive;

@end


@interface ICLocalization : NSObject

/* class methods */
+ (id)localizedFrameworkStringForKey:(id)key value:(id)value table:(id)table allowSiri:(_Bool)siri;

@end


@interface ICManagedObjectContextSaveAssertion : NSObject <RBSAssertionObserving>

@property (weak) NSManagedObjectContext *context;
@property (retain) RBSAssertion *assertion;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)assertion:(id)assertion didInvalidateWithError:(id)error;
- (void)dealloc;
- (void)invalidate;
- (id)initWithManagedObjectContext:(id)context;

@end


@interface ICManagedObjectContextUpdater : NSObject

@property (weak, nonatomic) NSPersistentStore *store;
@property (weak, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSPersistentHistoryToken *previousHistoryToken;
@property (retain, nonatomic) NSDate *previousHistoryDate;
@property (nonatomic) _Bool listening;
@property (retain, nonatomic) NSObject *queue;
@property (nonatomic) unsigned long long numberOfCoalescedNotifications;
@property (retain, nonatomic) ICSelectorDelayer *delayer;

/* class methods */
+ (id)contextSaveNotificationFromPersistentHistoryResult:(id)result ignoringContextName:(id)name fromTransactionAuthor:(id)author latestToken:(id *)token latestTimestamp:(id *)timestamp;

/* instance methods */
- (_Bool)isListening;
- (void)requestUpdate;
- (id)persistentStoreCoordinator;
- (_Bool)mergeWithDictionary:(id)dictionary;
- (id)initWithStore:(id)store context:(id)context;
- (void)startListeningForRemoteContextDidChangeNotifications;
- (void)handlePersistentStoreRemoteChangeNotification:(id)notification;
- (id)init;
- (void)stopListeningForRemoteContextDidChangeNotifications;
- (void)fetchChangeHistory;
- (void)dealloc;

@end


@interface ICModelAvailabilityManager : NSObject

@property (nonatomic, readonly) _Bool useAILabeling;
@property (nonatomic, readonly) _Bool supportsCallRecording;
@property (nonatomic, readonly) _Bool supportsCallTranscription;
@property (nonatomic, readonly) _Bool supportsPrivateCloudComputeSummary;
@property (nonatomic, readonly) _Bool supportsOnDeviceSummary;
@property (nonatomic, readonly) _Bool supportsGeneralASR;

/* class methods */
+ (id)sharedInstance;

/* instance methods */
- (id)init;
- (void)fetchAndCacheAsyncAvailabilities:(id /* block */)availabilities;

@end


@interface ICMutableBool : NSObject

@property (nonatomic) _Bool value;

@end


@interface ICNoCopyDictionary : NSMutableDictionary

/* class methods */
+ (Class)classForKeyedUnarchiver;

/* instance methods */
- (id)keyEnumerator;
- (void)getObjects:(id *)objects andKeys:(id *)keys count:(unsigned long long)count;
- (unsigned long long)count;
- (void)removeAllObjects;
- (id)objectEnumerator;
- (id)init;
- (unsigned long long)countByEnumeratingWithState:(struct { unsigned long long x0; id *x1; unsigned long long *x2; unsigned long long x3[5]; } *)state objects:(id *)objects count:(unsigned long long)count;
- (void)removeObjectForKey:(id)key;
- (void)dealloc;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)allValues;
- (void)getObjects:(id *)objects andKeys:(id *)keys;
- (id)objectForKey:(id)key;
- (id)allKeys;
- (void)setObject:(id)object forKey:(id)key;
- (id)initWithCapacity:(unsigned long long)capacity;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (id)initWithCFDictionary:(struct __CFDictionary *)cfdictionary;
- (void)setObject:(id)object forUncopiedKey:(id)key;

@end


@interface ICNoteListSortUtilities : NSObject

/* class methods */
+ (void)clearCache;
+ (id)sortDescriptorsForType:(long long)type;
+ (id)sortDescriptorsForCurrentType;
+ (long long)currentNoteListSortType;
+ (id)legacySortDescriptorsForType:(long long)type ascending:(_Bool)ascending;
+ (id)descriptionForNoteListSortType:(long long)type;
+ (long long)sortTypeForFolderNoteOrder:(long long)order;
+ (long long)sortTypeForTag:(long long)tag;
+ (void)setCurrentNoteListSortType:(long long)type;
+ (long long)tagForSortType:(long long)type;
+ (id)dateForCurrentSortTypeForNote:(id)note folderNoteSortType:(id)type;
+ (void)upgradeLegacySortTypeToNewSortTypeIfNecessary;
+ (id)sortDescriptorsForCurrentTypeIncludingPinnedNotes:(_Bool)notes;
+ (id)sortDescriptorsForType:(long long)type ascending:(_Bool)ascending;
+ (long long)folderSortOrderForNoteListSortType:(long long)type;
+ (id)sortDescriptorsForCurrentTypeIncludingPinnedNotes:(_Bool)notes folderNoteSortType:(id)type;
+ (long long)sortTypeFromLegacyDefaultString:(id)string;
+ (_Bool)isMenuItemCurrentSortTypeForTag:(long long)tag;
+ (id)sortDescriptorsForPinnedNotes;
+ (id)dateForCurrentSortTypeAccessibilityStringForNote:(id)note folderNoteSortType:(id)type;
+ (id)legacySortDescriptorsForType:(long long)type;
+ (void)setCurrentNoteListSortTypeByTag:(long long)tag;

@end


@interface ICNoteSnippetUtilities : NSObject

/* class methods */
+ (id)snippetAndTitleTrimCharacterSet;
+ (id)attributedStringByRemovingTitle:(id)title fromAttributedString:(id)string;
+ (struct _NSRange)rangeForTitleInContent:(id)content truncated:(_Bool *)truncated;
+ (id)snippetForContent:(id)content;
+ (id)stringByRemovingTitle:(id)title fromString:(id)string;
+ (id)widgetSnippetForContent:(id)content;

@end


@interface ICPaths : NSObject

/* class methods */
+ (void)resetApplicationDocumentsURL;
+ (id)importDocumentsURL;
+ (_Bool)isReadOnlyPersistentStore;
+ (id)oldManagedObjectModelURL;
+ (id)defaultPreviewImageDirectoryURL;
+ (id)managedObjectModelURL;
+ (id)persistentStoreURL;
+ (void)setApplicationDocumentsURL:(id)url;
+ (id)attributesForGroupContainerDirectory;
+ (id)URLForGroupContainerWithIdentifier:(id)identifier;
+ (void)setIsReadOnlyPersistentStore:(_Bool)store;
+ (id)applicationDataContainerURL;
+ (id)applicationDocumentsURL;

@end


@interface ICPersistenceConfiguration : NSObject

@property (retain, nonatomic) NSManagedObjectContext *modernViewContext;
@property (readonly, nonatomic) NSManagedObjectContext *modernBackgroundContext;
@property (copy, nonatomic) id /* block */ makeModernBackgroundContext;
@property (retain, nonatomic) NSManagedObjectContext *legacyViewContext;
@property (readonly, nonatomic) NSManagedObjectContext *legacyBackgroundContext;
@property (copy, nonatomic) id /* block */ makeLegacyBackgroundContext;

/* instance methods */

@end


@interface ICPersistentContainer : NSPersistentContainer

@property (retain, nonatomic) NSURL *storeURL;
@property (retain, nonatomic) NSString *storeType;
@property (retain, nonatomic) NSDictionary *storeOptions;
@property (retain, nonatomic) NSMergePolicy *mergePolicy;
@property (readonly, nonatomic) NSURL *backupsDirectoryURL;
@property (nonatomic) unsigned long long fakeFreeDiskSpace;
@property (nonatomic) _Bool abortAfterReplacingDatabase;

/* class methods */
+ (id)managedObjectModel;
+ (id)oldManagedObjectModel;
+ (_Bool)isDatabaseMissingError:(id)error;
+ (_Bool)isDataProtectionError:(id)error;
+ (id)standardStoreOptions;
+ (id)databaseOpenLock;

/* instance methods */
- (_Bool)isReadOnly;
- (void)setupPersistentStoreDescriptions;
- (id)performBlockWithDatabaseOpenLock:(id /* block */)lock;
- (id)newBackgroundContext;
- (_Bool)isTooLowOnDiskSpace;
- (void)vacuumStoreWithCompletionHandler:(id /* block */)handler;
- (_Bool)loadPersistentStore:(id *)store storeCreatedHandler:(id /* block */)handler;
- (_Bool)allowsCoreDataMigration;
- (void)backupPersistentStoreWithError:(id)error;
- (_Bool)loadPersistentStore:(id *)store;
- (id)initWithStoreURL:(id)url storeType:(id)type options:(id)options mergePolicy:(id)policy managedObjectModel:(id)model;
- (id)initWithStoreURL:(id)url storeType:(id)type options:(id)options mergePolicy:(id)policy;
- (_Bool)migrateFromOldDataModel:(id *)model;
- (void)vacuumStore;
- (void)setupViewContext;

@end


@interface ICRWLock : NSObject

/* instance methods */
- (void)unlock;
- (id)init;
- (void)dealloc;
- (void)writeLock;
- (void)readLock;
- (int)tryReadLock;

@end


@interface ICRadarUtilities : NSObject

/* class methods */
+ (void)createRadarWithTitle:(id)title description:(id)description;
+ (void)promptUserToFileBugWithAlertMessage:(id)message bugTitle:(id)title bugDescription:(id)description;

@end


@interface ICReachability : NSObject

@property (copy, nonatomic) NSNumber *overrideReachabilityStatus;

/* class methods */
+ (id)reachabilityWithAddress:(const struct sockaddr_in *)address;
+ (id)reachabilityWithHostName:(id)name;
+ (id)reachabilityForInternetConnection;
+ (id)sharedReachabilityForInternetConnection;
+ (id)reachabilityForLocalWiFi;

/* instance methods */
- (_Bool)connectionRequired;
- (void)stopNotifier;
- (long long)currentReachabilityStatus;
- (void)dealloc;
- (long long)networkStatusForFlags:(unsigned int)flags;
- (_Bool)startNotifier;
- (long long)localWiFiStatusForFlags:(unsigned int)flags;

@end


@interface ICReindexAllItemsOperation : ICIndexItemsOperation

@property (readonly) NSData *clientStateData;
@property (weak, nonatomic) id <ICReindexAllItemsOperationDelegate> delegate;

/* instance methods */
- (void)main;
- (id)initWithSearchableIndex:(id)index dataSources:(id)sources delegate:(id)delegate;

@end


@interface ICSearchIndexConfiguration : NSObject

@end


@interface ICSearchIndexImplementation : NSObject <ICSearchIndex>

@property (retain, nonatomic) CSSearchableIndex *searchableIndex;
@property (retain, nonatomic) ICSearchIndexProgress *lastReportedProgress;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)beginIndexBatch;
- (void)fetchLastClientStateWithCompletionHandler:(id /* block */)handler;
- (void)slowFetchAttributes:(id)attributes protectionClass:(id)_class bundleID:(id)id identifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)endIndexBatchWithClientState:(id)state completionHandler:(id /* block */)handler;
- (void)deleteSearchableItemsWithIdentifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (void)deleteSearchableItemsWithDomainIdentifiers:(id)identifiers completionHandler:(id /* block */)handler;
- (id)csProgressForSearchIndexProgress:(id)progress;
- (void)indexSearchableItems:(id)items progress:(id)progress completionHandler:(id /* block */)handler;
- (void)reportProgress:(id)progress completionHandler:(id /* block */)handler;

@end


@interface ICSearchIndexProgress : NSObject

@property (nonatomic, readonly) long long totalItemCount;
@property (nonatomic) long long pendingItemCount;
@property (nonatomic) long long completedItemCount;
@property (nonatomic, readonly) NSString *description;

/* class methods */
+ (id)keyPathsForValuesAffectingValueForKey:(id)key;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (id)initWithPending:(long long)pending completed:(long long)completed;

@end


@interface ICSearchIndexProgressCoordinator : NSObject

@property (nonatomic, weak) id <ICSearchIndexProgressCoordinatorDataSource> dataSource;
@property (nonatomic, retain) ICSearchIndexProgress *progress;

/* class methods */
+ (id)contextName;

/* instance methods */
- (id)initWithDataSource:(id)source;
- (id)init;
- (void)reset;
- (long long)willIndexItems:(id)items;
- (void)didIndexItems:(id)items willIndexState:(long long)state;
- (void)finishBatch;
- (void)revertStaging:(id)staging;
- (void)stageForProcessing:(id)processing;
- (void)stageForReindex:(id)reindex;
- (void)willDeleteItems:(id)items;

@end


@interface ICSearchIndexer : NSObject <ICReindexAllItemsOperationDelegate, ICReindexing>

@property (retain, nonatomic) NSObject *indexingQueue;
@property (readonly, nonatomic) NSArray *_dataSources;
@property (retain, nonatomic) NSOperationQueue *operationQueue;
@property (copy, nonatomic) NSDictionary *dataSourcesByIdentifier;
@property (retain, nonatomic) id <ICSearchIndex> searchableIndex;
@property (retain, nonatomic) ICSelectorDelayer *changeProcessingDelayer;
@property (nonatomic) _Bool observingChanges;
@property (nonatomic) _Bool activelyReindexing;
@property (retain, nonatomic) NSMutableDictionary *retryTimers;
@property (nonatomic) _Bool allDataSourcesSuccessfullyStagedSinceLastReindex;
@property (nonatomic) _Bool disabled;
@property (nonatomic) _Bool retryOnErrors;
@property (readonly, nonatomic) NSArray *dataSources;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) _Bool fullyStagedSinceLastReindex;

/* class methods */
+ (id)sharedIndexer;

/* instance methods */
- (_Bool)isDisabled;
- (void)finishRemainingOperationsWithCompletionHandler:(id /* block */)handler;
- (void)reindexSearchableItemsWithObjectIDURIs:(id)iduris completionHandler:(id /* block */)handler;
- (id)pendingReindexingOperation;
- (void)dataSourceDidChange:(id)change;
- (void)stopObservingChanges;
- (void)cancelIndexingOperationsWithCompletionHandler:(id /* block */)handler;
- (void)reindexAllSearchableItemsInIndex:(id)index completionHandler:(id /* block */)handler;
- (void)removeDataSource:(id)source;
- (void)clearRetryForSelector:(SEL)selector;
- (void)reindexAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (id)dataSourceWithIdentifier:(id)identifier;
- (id)initWithSearchIndex:(id)index;
- (void)reindexSearchableItemsWithObjectIDURIs:(id)iduris inIndex:(id)index completionHandler:(id /* block */)handler;
- (void)reindexOperationSuccessfullyStagedAllDataSources:(id)sources;
- (void)startObservingChanges;
- (_Bool)isObservingChanges;
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)clearObjectIDsToProcessAndResetProgress;
- (void)processChanges;
- (void)retrySelector:(SEL)selector;
- (_Bool)isActivelyReindexing;
- (id)objectForSearchableItem:(id)item context:(id)context;
- (id)objectForManagedObjectIDURI:(id)iduri inContexts:(id)contexts;
- (id)objectsDictionaryForSearchableItems:(id)items inContexts:(id)contexts;
- (void)reindexAllSearchableItemsInIndex;
- (id)newContextsForAllDataSources;
- (void)forceDeleteAllProgressState;
- (void)addDataSource:(id)source;
- (id)objectsForSearchableItems:(id)items inContexts:(id)contexts;

@end


@interface ICSearchableItemResult : NSObject

@property (retain, nonatomic) CSSearchableItem *searchableItem;
@property (retain, nonatomic) NSArray *additionalSearchableItems;

/* instance methods */

@end


@interface ICSelectorDelayer : NSObject

@property (weak, nonatomic) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) _Bool waitToFireUntilRequestsStop;
@property (nonatomic) _Bool callOnMainThread;
@property (retain) NSDate *requestFireDate;
@property (retain, nonatomic) NSObject *backgroundQueue;
@property (retain, nonatomic) NSObject *requestQueue;
@property (copy, nonatomic) id /* block */ fireBlock;
@property double delay;
@property double maximumDelay;
@property (readonly, nonatomic) _Bool isScheduledToFire;

/* instance methods */
- (void)fireImmediately;
- (void)_cancelFireRequests;
- (void)cancelPreviousFireRequests;
- (void)dealloc;
- (id)initWithTarget:(id)target selector:(SEL)selector delay:(double)delay waitToFireUntilRequestsStop:(_Bool)stop callOnMainThread:(_Bool)thread;
- (void)requestFire;
- (id)initWithTarget:(id)target selector:(SEL)selector delay:(double)delay maximumDelay:(double)delay callOnMainThread:(_Bool)thread;
- (void)callTargetSelector;
- (id)initWithTarget:(id)target selector:(SEL)selector delay:(double)delay maximumDelay:(double)delay waitToFireUntilRequestsStop:(_Bool)stop callOnMainThread:(_Bool)thread;

@end


@interface ICSettingsUtilities : NSObject

/* class methods */
+ (_Bool)boolForKey:(id)key;
+ (void)setBool:(_Bool)_bool forKey:(id)key;
+ (void)synchronizeSettingsWithUserDefaultsForKeys:(id)keys;
+ (id)objectForKey:(id)key;
+ (void)setObject:(id)object forKey:(id)key;

@end


@interface ICSpotlightUtilities : NSObject

/* class methods */
+ (id)stringByEscapingSearchString:(id)string;
+ (id)queryFields;
+ (id)rankingQueryFieldsForGenericHighlighting;
+ (id)rankingQueryFieldsForSorting;
+ (id)rankingQueryFieldsForWordSpecificHighlighting;
+ (unsigned long long)rankingQueryLimit;
+ (id)userActivityPersistentIdentifierForNote:(id)note;

@end


@interface ICStateHandler : NSObject

/* class methods */
+ (void)addStateHandlerWithName:(const char *)name stateBlock:(id /* block */)block;
+ (void)addStateHandlerWithName:(const char *)name sysdiagnoseOnly:(_Bool)only stateBlock:(id /* block */)block;

@end


@interface ICTelemetryManager : NSObject

/* class methods */
+ (id)sharedManager;
+ (void)postBasicEvent:(unsigned long long)event;
+ (void)postFetchDatabaseChangesTelemetryWithReason:(id)reason;
+ (void)postFetchZoneChangesTelemetryWithReason:(id)reason;
+ (void)postFullSyncTelemetryWithReason:(id)reason;
+ (id)telemetryTuples;
+ (void)postOneTimeBasicEvent:(unsigned long long)event;
+ (id)telemetryQueue;
+ (void)waitUntilAllPendingTelemetryHasBeenSent;

/* instance methods */
- (void)postOneTimeTelemetryEvent:(unsigned long long)event serviceName:(id)name payload:(id)payload token:(id)token;
- (void)postTelemetryEvent:(unsigned long long)event serviceName:(id)name payload:(id)payload;

@end


@interface ICTuple : NSObject

@property (readonly, nonatomic) id firstObject;
@property (readonly, nonatomic) id secondObject;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)initWithFirstObject:(id)object secondObject:(id)object;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICUtilities : NSObject

/* class methods */
+ (_Bool)isInternalInstall;
+ (_Bool)showInternalInstallUI;
+ (struct _NSRange)range:(struct _NSRange)range liesWithinRange:(struct _NSRange)range assert:(_Bool)assert;
+ (_Bool)isInternetReachable;
+ (_Bool)isSeedInstall;

@end


@interface ICWeakObject : NSObject <NSCopying>

@property (nonatomic) unsigned long long cachedHash;
@property (readonly, weak, nonatomic) id object;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObject:(id)object;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;

@end


@interface ICWidget : NSObject

/* class methods */
+ (id)sharedWidget;

/* instance methods */
- (void)reloadTimelinesWithReason:(id)reason;
- (void)reloadTimelineForKind:(id)kind reason:(id)reason;

@end


@interface _TtC12NotesSupport18AsyncPriorityQueue : _TtCs12_SwiftObject

@end


@interface _TtC12NotesSupport36GreymatterManagedProfileAvailability : _TtCs12_SwiftObject // (Swift)

/* class methods */
+ (_Bool)summarizationIsAvailable;
+ (_Bool)transcriptionIsAvailable;

@end


@interface ACAccount (IC)

/* instance methods */
- (_Bool)ic_isManagedAppleID;
- (_Bool)ic_isNotesEnabled;
- (_Bool)ic_isNotesMigrated;
- (_Bool)ic_isPrimaryAppleAccount;
- (_Bool)ic_shouldCreateSeparatePersistentStore;
- (_Bool)ic_hasICloudEmailAddress;
- (_Bool)ic_hasPersonaIdentifier;
- (_Bool)ic_isBasicAccountClass;
- (_Bool)ic_isFullAccountClass;
- (_Bool)ic_isICloudNotesAccount;
- (_Bool)ic_supportsHTMLNotes;
- (_Bool)ic_supportsModernNotes;

@end


@interface AVAsset (IC)

/* instance methods */
- (id)previewImageDataWithUTType:(id)uttype;
- (struct CGImageSource *)newPreviewImageSource;

@end


@interface AVURLAsset (IC)

/* class methods */
+ (id)ic_safeURLAssetWithURL:(id)url;

/* instance methods */
- (double)ic_durationInSeconds;

@end


@interface CSSearchableItemAttributeSet (IC)

/* class methods */
+ (id)ic_customAttributeKeyDictionary;
+ (id)ic_accountNameCustomKey;
+ (id)ic_customAttributeKeyWithName:(id)name searchable:(_Bool)searchable searchableByDefault:(_Bool)_default unique:(_Bool)unique multiValued:(_Bool)valued;
+ (id)ic_dataSourceIdentifierCustomKey;
+ (id)ic_folderNameCustomKey;
+ (id)ic_itemHasAttachmentsCustomKey;
+ (id)ic_itemHasChecklistsCustomKey;
+ (id)ic_itemHasDrawingsCustomKey;
+ (id)ic_itemHasScannedDocumentsCustomKey;
+ (id)ic_itemHasTagsCustomKey;
+ (id)ic_itemIsLockedCustomKey;
+ (id)ic_itemIsSharedCustomKey;
+ (id)ic_relatedModernNoteUniqueIdentifierCustomKey;
+ (id)ic_searchResultTypeCustomKey;
+ (id)ic_specializedIndexFieldAttributeKeyForStringField:(id)field;

/* instance methods */
- (void)setIc_isLocked:(_Bool)locked;
- (void)setIc_isShared:(_Bool)shared;
- (id)ic_dataSourceIdentifier;
- (_Bool)ic_hasDrawings;
- (_Bool)ic_hasScannedDocuments;
- (void)ic_populateValuesForSpecializedFields;
- (id)ic_relatedModernNoteUniqueIdentifier;
- (unsigned long long)ic_relevance;
- (unsigned long long)ic_searchResultType;
- (void)ic_setURLString:(id)urlstring;
- (void)setIc_accountName:(id)name;
- (void)setIc_dataSourceIdentifier:(id)identifier;
- (void)setIc_folderName:(id)name;
- (void)setIc_hasAttachments:(_Bool)attachments;
- (void)setIc_hasChecklists:(_Bool)checklists;
- (void)setIc_hasDrawings:(_Bool)drawings;
- (void)setIc_hasScannedDocuments:(_Bool)documents;
- (void)setIc_hasTags:(_Bool)tags;
- (void)setIc_relatedModernNoteUniqueIdentifier:(id)identifier;
- (void)setIc_searchResultType:(unsigned long long)type;
- (id)ic_accountName;
- (id)ic_folderName;
- (_Bool)ic_hasAttachments;
- (_Bool)ic_hasChecklists;
- (_Bool)ic_hasTags;
- (_Bool)ic_isLocked;
- (_Bool)ic_isShared;
- (id)ic_urlString;

@end


@interface NSArray (IC)

/* class methods */
+ (id)ic_arrayFromNonNilObject:(id)object;
+ (id)ic_repeating:(id)ic_repeating count:(unsigned long long)count;

/* instance methods */
- (id)ic_map:(id /* block */)ic_map;
- (_Bool)ic_allSatisfy:(id /* block */)satisfy;
- (id)ic_arrayByGroupingIntoArraysWithMaxCount:(unsigned long long)count;
- (id)ic_arrayBySplittingIntoTwoArraysWithMaxPrefixCount:(unsigned long long)count;
- (id)ic_compactMap:(id /* block */)map;
- (_Bool)ic_containsObjectMatchingPredicate:(id)predicate;
- (_Bool)ic_containsObjectPassingTest:(id /* block */)test;
- (id)ic_flatMap:(id /* block */)map;
- (unsigned long long)ic_indexOfSortedObject:(id)object insertionIndex:(out unsigned long long *)index usingComparator:(id /* block */)comparator;
- (id)ic_objectPassingTest:(id /* block */)test;
- (id)ic_objectsPassingTest:(id /* block */)test;
- (id)ic_objectAfter:(id)after;
- (id)ic_dictionaryByHashingContentWithFunction:(id /* block */)function;
- (id)ic_firstObjectOfClass:(Class)_class;
- (_Bool)ic_indexIsValid:(long long)valid;
- (id)ic_objectsOfClass:(Class)_class;
- (id)ic_subarrayFromIndex:(unsigned long long)index;
- (id)ic_attributedStringByJoiningComponents;
- (id)ic_reduceStartingWithState:(id)state usingBlock:(id /* block */)block;
- (id)ic_objectsConformingToProtocol:(id)protocol;
- (id)ic_randomObject;
- (id)ic_arrayByAddingNonNilObject:(id)object;
- (id)ic_arrayByAddingObjectsFromNonNilArray:(id)array;
- (id)ic_arrayBySplittingIntoTwoArraysWithMaxPrefixCount:(unsigned long long)count prefixMatchingPredicate:(id /* block */)predicate;
- (id)ic_attributedStringByJoiningComponentsUsingSeparator:(id)separator;
- (_Bool)ic_containsObjectOfClass:(Class)_class;
- (id)ic_firstObjectConformingToProtocol:(id)protocol;
- (id)ic_objectAfter:(id)after wrap:(_Bool)wrap;
- (id)ic_objectBefore:(id)before;
- (id)ic_objectBefore:(id)before wrap:(_Bool)wrap;

@end


@interface NSAttributedString (IC)

/* class methods */
+ (id)ic_emptyAttributedString;

/* instance methods */
- (id)ic_attributedStringByAppendingString:(id)string;
- (id)ic_attributedStringByReplacingCharactersInSet:(id)set withString:(id)string;
- (id)ic_attributedStringByTrimmingCharactersInSet:(id)set;
- (id)ic_attributedSubstringFromRange:(struct _NSRange)range;
- (_Bool)ic_containsAttribute:(id)attribute inRange:(struct _NSRange)range;
- (struct _NSRange)ic_range;
- (id)ic_whitespaceAndNewlineCoalescedAttributedString;
- (id)ic_attributedStringByReplacingNewlineCharactersWithWhiteSpace;
- (id)ic_componentRangesSeparatedByPredicate:(id /* block */)predicate inRange:(struct _NSRange)range;
- (struct _NSRange)ic_enclosingRangeContainingCharactersInSet:(id)set forRange:(struct _NSRange)range;
- (void)ic_enumerateClampedAttribute:(id)attribute inRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (void)ic_enumerateUnclampedAttribute:(id)attribute inRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (struct _NSRange)ic_rangeByTrimmingCharactersInSet:(id)set inRange:(struct _NSRange)range;
- (_Bool)ic_containsAttribute:(id)attribute;
- (void)ic_enumerateAttributesInClampedRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (id)ic_allRangesContainingAttribute:(id)attribute;
- (id)ic_attributedStringByAppendingAttributedString:(id)string;
- (id)ic_attributedStringByPrependingAttributedString:(id)string;
- (id)ic_attributedStringByPrependingString:(id)string;
- (id)ic_attributedStringByRemovingAllAttributesExcept:(id /* block */)except;

@end


@interface NSBundle (IC)

/* instance methods */
- (_Bool)ic_canEditNotes;
- (_Bool)ic_isAppExtension;

@end


@interface NSCharacterSet (IC)

/* class methods */
+ (id)ic_hashtagAllowedCharacterSet;
+ (id)ic_hashtagTokenizingCharacterSet;
+ (id)ic_uriIdentifierAllowedCharacterSet;
+ (id)ic_animatableTokenCharacterSet;
+ (id)ic_emojiCharacterSet;
+ (id)ic_attachmentCharacterSet;
+ (id)ic_illegalFilenameCharacterSet;

@end


@interface NSData (Gzip)

/* class methods */
+ (id)ic_dataFromHexString:(id)string;
+ (id)ic_dataWithBoolean:(_Bool)boolean;
+ (id)ic_dataWithUnsignedInteger:(unsigned long long)integer;
+ (id)ic_random128BitData:(id *)data;
+ (id)ic_random256BitData:(id *)data;
+ (id)ic_randomDataOfLength:(unsigned long long)length error:(id *)error;
+ (_Bool)ic_nullableData:(id)data isEqualToNullableData:(id)data;

/* instance methods */
- (_Bool)ic_boolValue;
- (id)ic_gzipDeflate;
- (id)ic_gzipInflate;
- (id)ic_md5;
- (id)ic_sha256;
- (id)ic_stringValue;
- (unsigned long long)ic_unsignedIntegerValue;
- (_Bool)ic_isZipArchive;

@end


@interface NSDate (IC)

/* instance methods */
- (id)ic_endOfDay;
- (_Bool)ic_isEarlierThanDate:(id)date;
- (_Bool)ic_isLaterThanDate:(id)date;
- (_Bool)ic_isLaterThanUnitsAgo:(unsigned long long)ago value:(unsigned long long)value;
- (_Bool)ic_isSameDayAsDate:(id)date;
- (id)ic_iso8601Date;
- (id)ic_startOfDay;
- (id)ic_truncated;
- (id)ic_briefFormattedDate;
- (id)ic_briefFormattedDateForAccessibility;
- (id)ic_briefFormattedDate:(_Bool)date locale:(id)locale;
- (id)ic_briefFormattedDateForSiriLocale:(id)locale forAccessibility:(_Bool)accessibility;
- (_Bool)ic_isToday;
- (_Bool)ic_isWithinInclusiveDayIntervalBeginning:(id)beginning ending:(id)ending;
- (_Bool)ic_isWithinSameMonth:(id)month;
- (_Bool)ic_isWithinSameYear:(id)year;
- (_Bool)ic_isYesterday;
- (id)ic_localDateWithSeconds;
- (unsigned long long)ic_numberOfDaysFromDate:(id)date;
- (id)ic_shortFormattedDate;
- (id)ic_shortFormattedDateForAccessibility;
- (id)ic_shortFormattedDateForAccessibility:(_Bool)accessibility;

@end


@interface NSDictionary (IC)

/* instance methods */
- (id)ic_md5;
- (id)ic_objectForNonNilKey:(id)key;
- (id)ic_prettyDescriptionWithTabLevel:(unsigned long long)level;

@end


@interface NSFileManager (IC)

/* instance methods */
- (id)ic_temporaryDirectoryAppropriateForDestination:(id)destination;
- (id)ic_temporaryDirectoryPathAppropriateForDestinationPath:(id)path;

@end


@interface NSFileVersion (IC)

/* class methods */
+ (id)ic_addVersionOfItemAtURL:(id)url withContentsOfURL:(id)url options:(unsigned long long)options error:(id *)error;

@end


@interface NSIndexSet (IC)

/* instance methods */
- (id)ic_rangeArray;

@end


@interface NSLocale (IC)

/* instance methods */
- (_Bool)ic_localeIsArabic;
- (id)ic_numberingSystem;
- (_Bool)ic_numberingSystemIsArabic;
- (_Bool)ic_numberingSystemIsDevanagari;
- (_Bool)ic_timeUsesDotSeparator;

@end


@interface NSManagedObject (IC)

/* class methods */
+ (void)ic_enumerateObjectsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors relationshipKeyPathsForPrefetching:(id)prefetching context:(id)context batchSize:(unsigned long long)size saveAfterBatch:(_Bool)batch usingBlock:(id /* block */)block;
+ (id)ic_existingObjectWithID:(id)id context:(id)context;
+ (_Bool)ic_hasObjectMatchingPredicate:(id)predicate context:(id)context;
+ (id)ic_objectIDsFromObjects:(id)objects;
+ (id)ic_objectIDsMatchingPredicate:(id)predicate context:(id)context;
+ (id)ic_objectIDsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors context:(id)context;
+ (id)ic_objectsFromObjectIDs:(id)ids context:(id)context;
+ (id)ic_objectsFromObjectIDs:(id)ids relationshipKeyPathsForPrefetching:(id)prefetching context:(id)context;
+ (id)ic_objectsMatchingPredicate:(id)predicate context:(id)context;
+ (id)ic_objectsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors context:(id)context;
+ (id)ic_objectsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors relationshipKeyPathsForPrefetching:(id)prefetching fetchLimit:(unsigned long long)limit context:(id)context;
+ (_Bool)ic_containsFaultingManagedObjects:(id)objects;
+ (id)ic_objectIDsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors fetchLimit:(unsigned long long)limit context:(id)context;
+ (id)ic_permanentObjectIDsFromObjects:(id)objects;
+ (id)ic_resultsMatchingPredicate:(id)predicate sortDescriptors:(id)descriptors resultType:(unsigned long long)type relationshipKeyPathsForPrefetching:(id)prefetching fetchLimit:(unsigned long long)limit context:(id)context;

/* instance methods */
- (_Bool)ic_isTransitioning;
- (_Bool)ic_obtainPermanentObjectIDIfNecessary;
- (id)ic_permanentObjectID;
- (id)ic_postNotificationOnMainThreadAfterSaveWithName:(id)name;
- (void)ic_postNotificationOnMainThreadWithName:(id)name;

@end


@interface NSManagedObjectContext (IC)

/* instance methods */
- (_Bool)ic_save;
- (id)ic_existingObjectWithID:(id)id;
- (id)ic_objectIDFromURL:(id)url;
- (id)ic_objectsWithIDs:(id)ids;
- (void)ic_refreshObject:(id)object mergeChanges:(_Bool)changes;
- (_Bool)ic_saveWithLogDescription:(id)description;
- (_Bool)ic_saveWithLogDescription:(id)description arguments:(char *)arguments;
- (_Bool)ic_isMainThreadContext;
- (void)setIc_debugName:(id)name;
- (void)ic_acquireSaveAssertionIfNecessary;
- (id)ic_debugName;
- (void)ic_invalidateSaveAssertion;
- (void)ic_performBlock:(id /* block */)block andPerformBlockOnMainThread:(id /* block */)thread;
- (void)ic_performBlockAndWait:(id /* block */)wait andPerformBlockAndWaitOnMainThread:(id /* block */)thread;
- (void)ic_saveWithAssertionIfNecessary:(id /* block */)necessary;

@end


@interface NSManagedObjectID (IC)

/* instance methods */
- (_Bool)ic_isEntityOfClass:(Class)_class;
- (id)ic_uriString;
- (Class)ic_entityClass;

@end


@interface NSManagedObjectModel (IC)

/* instance methods */
- (id)ic_versionHash;

@end


@interface NSMutableArray (IC)

/* class methods */
+ (id)ic_arrayFromNonNilObject:(id)object;

/* instance methods */
- (void)ic_addNonNilObject:(id)object;
- (void)ic_addObjectsFromNonNilArray:(id)array;
- (void)ic_insertNonNilObject:(id)object atIndex:(long long)index;

@end


@interface NSMutableAttributedString (IC)

/* instance methods */
- (void)ic_appendAttributedSubstring:(id)substring fromRange:(struct _NSRange)range;
- (void)ic_replaceCharactersInRange:(struct _NSRange)range withAttributedSubstring:(id)substring fromRange:(struct _NSRange)range;
- (void)ic_appendString:(id)string;

@end


@interface NSMutableDictionary (IC)

/* class methods */
+ (id)ic_dictionaryFromNonNilDictionary:(id)dictionary;

/* instance methods */
- (void)ic_setNonNilObject:(id)object forKey:(id)key;
- (void)ic_setNonNilObject:(id)object forNonNilKey:(id)key;
- (void)ic_addKey:(id)key forNonNilObject:(id)object;
- (void)ic_removeObjectForNonNilKey:(id)key;

@end


@interface NSMutableOrderedSet (IC)

/* instance methods */
- (void)ic_addNonNilObject:(id)object;
- (void)ic_sortUsingSelector:(SEL)selector;

@end


@interface NSMutableSet (IC)

/* instance methods */
- (void)ic_addNonEmptyString:(id)string;
- (void)ic_addNonNilObject:(id)object;
- (void)ic_addObjectsFromNonNilArray:(id)array;
- (void)ic_removeNonNilObject:(id)object;
- (void)ic_removeObjectsFromNonNilArray:(id)array;

@end


@interface NSObject (IC)

/* class methods */
+ (id)ic_loggingDescriptionFromLoggable:(id)loggable isPretty:(_Bool)pretty;

/* instance methods */
- (void)ic_addObserver:(id)observer forKeyPath:(id)path context:(struct { char *x0; char *x1; } *)context;
- (_Bool)ic_didAddObserverForContext:(void *)context inScope:(char *)scope;
- (_Bool)ic_isDeallocating;
- (id)ic_loggingDescription;
- (id)ic_loggingIdentifier;
- (void)ic_removeObserver:(id)observer forKeyPath:(id)path context:(void *)context;
- (_Bool)ic_shouldIgnoreObserveValue:(id)value ofObject:(id)object forKeyPath:(id)path;
- (void)ic_addObserver:(id)observer forKeyPath:(id)path context:(struct { char *x0; char *x1; } *)context explicitOptions:(unsigned long long)options;
- (id)ic_prettyLoggingDescription;

@end


@interface NSOperation (IC) <ICLoggable>

/* instance methods */
- (id)ic_loggingIdentifier;
- (id)ic_loggingValues;
- (void)ic_setCloudSessionIdentifier:(id)identifier;
- (void)ic_setResistsCancellation:(_Bool)cancellation;
- (id)ic_cloudSessionIdentifier;
- (_Bool)ic_resistsCancellation;

@end


@interface NSOperationQueue (CloudKit)

/* instance methods */
- (id)iterativelyCancelDependentOperations:(id)operations;
- (_Bool)containsOperationToDeleteRecordID:(id)id;
- (_Bool)containsOperationToFetchRecordID:(id)id;
- (_Bool)containsOperationToSaveRecordID:(id)id;
- (id)existingOperationToDeleteRecordID:(id)id;
- (id)existingOperationToFetchRecordID:(id)id;
- (id)existingOperationToSaveRecordID:(id)id;

@end


@interface NSOrderedSet (IC)

/* instance methods */
- (_Bool)ic_containsObjectMatchingPredicate:(id)predicate;
- (_Bool)ic_containsObjectPassingTest:(id /* block */)test;
- (id)ic_objectPassingTest:(id /* block */)test;
- (id)ic_objectsMovedFromOrderedSet:(id)set;

@end


@interface NSPersistentStoreCoordinator (IC)

/* instance methods */
- (id)ic_managedObjectIDForURIString:(id)uristring;
- (id)ic_managedObjectIDForURIRepresentation:(id)urirepresentation;
- (_Bool)ic_containsStoreForObjectID:(id)id;

@end


@interface NSPersonNameComponents (IC)

/* instance methods */
- (id)ic_localizedNameWithDefaultFormattingStyle;
- (id)ic_componentsForSearchHighlighting;

@end


@interface NSRegularExpression (IC)

/* class methods */
+ (id)ic_regexForPrefixMatchingTokens:(id)tokens substringMatchingTokens:(id)tokens;
+ (id)ic_regexForSearchStrings:(id)strings;
+ (id)ic_regexForSearchStrings:(id)strings matchWordBoundaries:(_Bool)boundaries;
+ (id)ic_patternForTokens:(id)tokens matchWordBoundaries:(_Bool)boundaries;
+ (id)ic_uuidRegex;

/* instance methods */
- (id)ic_attributedStringByReplacingMatchesInAttributedString:(id)string options:(unsigned long long)options range:(struct _NSRange)range withTemplate:(id)_template;
- (_Bool)ic_matchesString:(id)string;

@end


@interface NSSet (IC)

/* class methods */
+ (id)ic_setFromNonNilObject:(id)object;
+ (id)ic_setFromNonNilArray:(id)array;

/* instance methods */
- (id)ic_map:(id /* block */)ic_map;
- (id)ic_compactMap:(id /* block */)map;
- (_Bool)ic_containsObjectMatchingPredicate:(id)predicate;
- (_Bool)ic_containsObjectPassingTest:(id /* block */)test;
- (id)ic_objectPassingTest:(id /* block */)test;
- (id)ic_objectsPassingTest:(id /* block */)test;
- (id)ic_objectsOfClass:(Class)_class;
- (id)ic_objectsConformingToProtocol:(id)protocol;
- (id)ic_objectOfClass:(Class)_class;

@end


@interface NSString (ICAttributedString)

/* class methods */
+ (id)ic_attachmentCharacterString;
+ (id)ic_calculateEqualsSignString;
+ (id)ic_calculateGraphExpressionString;
+ (id)ic_ellipsisCharacterString;
+ (id)ic_hashtagCharacterString;
+ (id)ic_mentionCharacterString;
+ (id)ic_shortNameFromGivenName:(id)name familyName:(id)name;
+ (id)ic_thinSpaceCharacterString;
+ (id)ic_equalsSignCharacterString;
+ (id)ic_fullWidthEqualsSignCharacterString;
+ (_Bool)ic_isCharacterInlineAttachmentPrefix:(unsigned short)prefix;
+ (id)ic_newURLForContentID:(id)id percentEscaped:(_Bool)escaped;
+ (id)ic_leftToRightCharacterString;
+ (id)ic_nonDelimeterSet;
+ (id)ic_rightToLeftCharacterString;

/* instance methods */
- (_Bool)ic_containsWhitespaceCharacters;
- (id)ic_nilWhenEmpty;
- (id)ic_attributedString;
- (_Bool)ic_containsHashtagPrefix;
- (_Bool)ic_containsNonWhitespaceAndAttachmentCharacters;
- (_Bool)ic_containsNonWhitespaceCharacters;
- (id)ic_dataValue;
- (void)ic_enumerateParagraphsInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (id)ic_hashtagDisplayText;
- (_Bool)ic_isCaseInsensitiveEqualToString:(id)string;
- (id)ic_leftToRightString;
- (id)ic_md5;
- (id)ic_mentionString;
- (struct _NSRange)ic_range;
- (_Bool)ic_range:(struct _NSRange)ic_range onlyContainsCharacterSet:(id)set;
- (_Bool)ic_rangeIsValid:(struct _NSRange)valid;
- (id)ic_rightToLeftString;
- (id)ic_sanitizedFilenameString;
- (id)ic_sha256;
- (id)ic_stringByRemovingLanguageDirectionCharacters;
- (id)ic_stringByTrimmingLeadingCharactersInSet:(id)set;
- (id)ic_stringWithoutSuffix:(id)suffix;
- (id)ic_substringToIndex:(unsigned long long)index;
- (id)ic_substringWithRange:(struct _NSRange)range;
- (id)ic_tokenSafeText;
- (id)ic_trailingTrimmedString;
- (id)ic_trimmedString;
- (id)ic_whitespaceAndNewlineCoalescedString;
- (id)ic_withHashtagPrefix;
- (id)ic_withoutHashtagPrefix;
- (unsigned long long)ic_HTMLInsertionPoint;
- (id)ic_checkedSubstringWithRange:(struct _NSRange)range;
- (void)ic_enumerateContentLineRangesInRange:(struct _NSRange)range usingBlock:(id /* block */)block;
- (id)ic_htmlStringEscapingQuotesAndLineBreaks;
- (_Bool)ic_isLastCharacterInRangeANewlineForRange:(struct _NSRange)range;
- (unsigned long long)ic_lengthOfLongestLine;
- (struct _NSRange)ic_paragraphRangeForRange:(struct _NSRange)range contentEnd:(unsigned long long *)end;
- (struct _NSRange)ic_safeCharacterRangeForRange:(struct _NSRange)range;
- (struct _NSRange)ic_sentenceRangeForRange:(struct _NSRange)range;
- (id)ic_stringByRemovingWhitespaceOnlyLines;
- (id)ic_stringByReplacingCharactersInSet:(id)set withString:(id)string;
- (id)ic_stringReplacingUnsafeHTMLCharacters;
- (id)ic_stringReplacingUnsafeXMLCharacters;
- (id)ic_truncatedStringWithMaxLength:(unsigned long long)length truncated:(_Bool *)truncated;
- (unsigned long long)ic_numberOfLines;
- (_Bool)ic_canConvertToTag;
- (unsigned long long)ic_countOfCharactersInSet:(id)set;
- (_Bool)ic_isLastCharacterANewline;
- (_Bool)ic_isNumeric;
- (id)ic_leadingTrimmedString;
- (struct _NSRange)ic_lineRangeIgnoringLineBreakCharactersForIndex:(unsigned long long)index;
- (_Bool)ic_rangeEncapsulatesWord:(struct _NSRange)word;
- (_Bool)ic_startsWithDelimeter:(struct _NSRange)delimeter;
- (id)ic_stringByReplacingLeadingFullWidthHashSignIfPossible;
- (id)ic_stringByReplacingNewlineCharactersWithWhiteSpace;
- (struct _NSRange)_HTMLRangeOfLastTagBeforeIndex:(unsigned long long)index;
- (id)_HTMLTagNameClosing:(_Bool *)closing;
- (id)ic_attributedStringByAppendingAttributedString:(id)string;
- (_Bool)ic_containsAlphanumericCharacters;
- (_Bool)ic_endsWithDelimeter:(struct _NSRange)delimeter;
- (id)ic_stringByRemovingAttachmentCharacters;
- (id)ic_stringByReplacingCharactersInStringMap:(id)map;
- (id)ic_substringFromIndex:(unsigned long long)index;
- (id)ic_uniqueWordsWithMinLength:(unsigned long long)length;

@end


@interface NSURL (IC)

/* class methods */
+ (id)ic_urlFromWeblocFileAtURL:(id)url;

/* instance methods */
- (_Bool)ic_isAppStoreURL;
- (_Bool)ic_isMapURL;
- (_Bool)ic_isNewsURL;
- (_Bool)ic_isPodcastsURL;
- (_Bool)ic_isReachable;
- (_Bool)ic_isURLAnInternetLocator;
- (_Bool)ic_isiTunesURL;
- (void)ic_updateFlagToExcludeFromBackup:(_Bool)backup;
- (long long)ic_fileOrDirectorySize;
- (long long)ic_fileSize;
- (_Bool)ic_isWebURL;
- (id)ic_UTI;
- (id)ic_dedupedURLWithProhibitedNames:(id)names;
- (_Bool)ic_isBooksURL;
- (_Bool)ic_isExcludedFromBackups;
- (_Bool)ic_isExcludedFromCloudBackups;
- (_Bool)ic_isSafeFileURLForAttachment;
- (_Bool)ic_isSupportedAsAttachment;
- (id)ic_uniquedURL;
- (void)ic_updateFlagToExcludeFromBackupNow:(_Bool)now;

@end


@interface NSURLComponents (IC)

/* instance methods */
- (_Bool)ic_boolValueForQueryItemWithKey:(id)key;
- (id)ic_queryItemWithKey:(id)key;
- (id)ic_stringValueForQueryItemWithKey:(id)key;

@end


@interface NSUndoManager (IC)

/* class methods */
+ (id)shared;

/* instance methods */
- (_Bool)ic_isUndoingOrRedoing;

@end


@interface NSValue (IC)

/* class methods */
+ (id)ic_valueWithRect:(struct CGRect)rect;

/* instance methods */
- (struct CGRect)ic_rectValue;

@end


#endif /* NotesSupport_h */
