// Normalized full dump import surface for ReminderKit.

// Source: local ipsw class-dump output; normalized for Swift/Clang import.

#ifndef ReminderKit_h

#define ReminderKit_h



#import <Foundation/Foundation.h>

@import Accounts;

@import CloudKit;



@interface _TtCs12_SwiftObject : NSObject

@end



@interface ICSDate : NSObject

@end

@interface ICSTodo : NSObject

@end



struct TopoID;

struct TopoIDRange;

struct _NSRange;

struct os_unfair_lock_s;



@class ACAccount, ACAccountStore, CRArray, CRCoder, CRCoderArchiver, CRCoderUnarchiver, CRCoderUnarchiverCompletionHandler, CRConstant, CRDictionary, CRDictionaryElement, CRDocument, CRObject;

@class CRRegister, CRRegisterGreatest, CRRegisterLatest, CRRegisterLeast, CRRegisterMultiValue, CRRegisterMultiValueLeast, CRReplica, CRSet, CRTTCompatibleDocument, CRTimestamp, CRTombstoneOrderedSet, CRVectorTimestamp;

@class CRVectorTimestampElement, ICProtobufUtilities, NSManagedObjectID, NSPersistentHistoryToken, REMAccount, REMAccountCapabilities, REMAccountChangeItem, REMAccountGroupContext, REMAccountGroupContextChangeItem, REMAccountPinnedListsContextChangeItem, REMAccountSortDescriptor, REMAccountStorage;

@class REMAccountTemplatesContext, REMAccountTemplatesContextChangeItem, REMAccountTypeHost, REMAccountsDataView, REMAccountsDataViewInvocationREMObjectIDOnlyResult, REMAccountsDataViewInvocationResult, REMAccountsDataViewInvocation_fetchActiveCloudKitAccountObjectIDs, REMAccountsDataViewInvocation_fetchAll, REMAccountsDataViewInvocation_fetchByExternalIdentifier, REMAccountsDataViewInvocation_fetchByObjectID, REMAccountsDataViewInvocation_fetchPrimaryActiveCloudKitAccount, REMAlarm;

@class REMAlarmContactTrigger, REMAlarmDateTrigger, REMAlarmDueDateDeltaAlertTrigger, REMAlarmLocationTrigger, REMAlarmTimeIntervalTrigger, REMAlarmTrigger, REMAlarmVehicleTrigger, REMAppStoreDataView, REMAppStoreDataViewConfigurationsInvocationResult, REMAppStoreDataViewInvocation_fetchCreatedOrCompletedRemindersCount, REMAppStoreDataViewInvocation_fetchICCloudConfigurationProperties, REMAppleAccountUtilities;

@class REMAssignment, REMAssignmentsDataViewInvocationResult, REMAssignmentsDataViewInvocation_fetchByObjectID, REMAttachment, REMAutoCategorizationActivity, REMAuxiliaryChangeInfoFetchResult, REMAuxiliaryChangeInfoType, REMAuxiliaryReminderChangeDeleteInfo, REMAuxiliaryReminderChangeMoveInfo, REMBaseSection, REMBaseSectionChangeItem, REMBaseSectionStorage;

@class REMBundleLookupObject, REMCRMergeableOrderedSet, REMCRMergeableStringDocument, REMCRMutableAttributedString, REMCRReminderIDList, REMCRUndo, REMCalDAVNotification, REMChangeObject, REMChangeSet, REMChangeToken, REMChangeTombstone, REMChangeTracking;

@class REMChangeTrackingState, REMChangeTransaction, REMChangedKeysObserver, REMClockElementList, REMCloudContainer, REMColor, REMContactRepresentation, REMDAAssignmentTombstone, REMDAChangeTrackingHelper, REMDAHashtagTombstone, REMDAShareeTombstone, REMDaemonUserDefaults;

@class REMDataAccessBehaviorManager, REMDatabaseMigrationAccountInfo, REMDatabaseMigrationContext, REMDispatchQueue, REMDisplayDate, REMDisplayDateUtils, REMDisplayNameUtils, REMDistributedEvaluationCollectionOptions, REMDueDateDeltaAlert, REMDueDateDeltaAlertChangeItem, REMDueDateDeltaInterval, REMEnableObjectiveCpp;

@class REMError, REMEventKitBridgingDataView, REMEventKitBridgingDataViewInvocation_fetchCompletedRemindersWithCompletionDate, REMEventKitBridgingDataViewInvocation_fetchIncompleteRemindersWithDueDate, REMEventKitBridgingDataViewInvocation_fetchLists, REMEventKitBridgingDataViewInvocation_fetchReminders, REMExporting, REMExternalSyncMetadataUtils, REMFamilyChecklistDataView, REMFamilyChecklistDataViewInvocation_fetchFamilyGroceryListEligibility, REMFamilyChecklistDataViewInvocation_fetchSharedGroceryLists, REMFamilyChecklistFamilyGroceryListEligibility;

@class REMFamilyChecklistFamilyGroceryListEligibilityInvocationResult, REMFamilyChecklistSharedGroceryList, REMFamilyChecklistSharedGroceryListInvocationResult, REMFetchMetadata, REMFetchRequest, REMFetchResult, REMFetchResultToken, REMFileAttachment, REMFindMyDeviceInformation, REMGroceryClassifierResult, REMGrocerySuggestedSection, REMGrocerySuggestions;

@class REMHashtag, REMHashtagLabel, REMHashtagsDataViewInvocationResult, REMHashtagsDataViewInvocation_fetchByObjectID, REMICloudIsOffDataView, REMICloudIsOffDataViewConfigurationsInvocationResult, REMICloudIsOffDataViewFetchHasAnyCKDirtyObjectInAccountInvocationResult, REMICloudIsOffDataViewInvocation_fetchHasAnyDirtyCloudObjectInAccount, REMICloudIsOffDataViewInvocation_fetchICCloudConfigurationProperties, REMImageAttachment, REMList, REMListAppearanceContext;

@class REMListAppearanceContextChangeItem, REMListBadge, REMListCalDAVNotificationContext, REMListCalDAVNotificationContextChangeItem, REMListChangeItem, REMListFetchExecutor, REMListFetchMetadata, REMListGenerativeAutoCategorizationContext, REMListGenerativeAutoCategorizationContextChangeItem, REMListGroceryContext, REMListGroceryContextChangeItem, REMListPredicateDescriptor;

@class REMListSection, REMListSectionChangeItem, REMListSectionContext, REMListSectionContextChangeItem, REMListSectionStorage, REMListSectionsDataView, REMListSectionsDataViewInvocationResult, REMListSectionsDataViewInvocation_fetchByObjectIDs, REMListSectionsDataViewInvocation_fetchByReminderID, REMListSectionsDataViewInvocation_fetchListSectionsCountInList, REMListSectionsDataViewInvocation_fetchListSectionsInList, REMListSectionsDataViewInvocation_fetchPredefinedListSectionsInList;

@class REMListShareeContext, REMListShareeContextChangeItem, REMListSortDescriptor, REMListStorage, REMListSublistContext, REMListSublistContextChangeItem, REMListsDataView, REMListsDataViewInvocationResult, REMListsDataViewInvocation_changeTrackingFetchByObjectIDIncludingConcealed, REMListsDataViewInvocation_dataAccessFetchByExternalIdentifier, REMListsDataViewInvocation_dataAccessFetchByObjectID, REMListsDataViewInvocation_dataAccessFetchListsInAccount;

@class REMListsDataViewInvocation_debugFetchPhantomLists, REMListsDataViewInvocation_fetchAllGroceryCapableLists, REMListsDataViewInvocation_fetchByObjectIDs, REMListsDataViewInvocation_fetchByTemplateObjectID, REMListsDataViewInvocation_fetchDefaultList, REMListsDataViewInvocation_fetchDefaultListRequiringCloudKit, REMListsDataViewInvocation_fetchGroceryListsWithRequiringOneOrMoreIncompleteReminders, REMListsDataViewInvocation_fetchListsAndSublistsInAccount, REMListsDataViewInvocation_fetchListsInAccount, REMListsDataViewInvocation_fetchListsInGroup, REMListsDataViewInvocation_fetchMostRelevantGroceryCapableList, REMListsDataViewInvocation_fetchUserSelectableDefaultLists;

@class REMListsDataViewInvocation_userActivityFetchByExternalIdentifier, REMLog, REMLogStore, REMManualOrdering, REMMembership, REMMemberships, REMMigrationResult, REMMutableCRMergeableOrderedSet, REMMutableCRMergeableStringDocument, REMMutableCRUndo, REMMutableCalDAVNotification, REMNSPersistentHistoryChange;

@class REMNSPersistentHistoryChangeTombstone, REMNSPersistentHistoryToken, REMNSPersistentHistoryTransaction, REMObjectID, REMOrderedIdentifierMap, REMPaths, REMRadarUtilities, REMRecurrenceDayOfWeek, REMRecurrenceEnd, REMRecurrenceRule, REMRecurrenceRuleFormatter, REMReminder;

@class REMReminderAssignmentContext, REMReminderAssignmentContextChangeItem, REMReminderAttachmentContext, REMReminderAttachmentContextChangeItem, REMReminderChangeItem, REMReminderDueDateDeltaAlertContext, REMReminderDueDateDeltaAlertContextChangeItem, REMReminderExtractionInput, REMReminderExtractionOutput, REMReminderFetchExecutor, REMReminderFetchMetadata, REMReminderFetchMetadataDueDateCount;

@class REMReminderFetchOptions, REMReminderFlaggedContext, REMReminderFlaggedContextChangeItem, REMReminderHashtagContext, REMReminderHashtagContextChangeItem, REMReminderPredicateDescriptor, REMReminderSortDescriptor, REMReminderStorage, REMReminderSubtaskContext, REMReminderSubtaskContextChangeItem, REMReminderUrgentAlarmContext, REMReminderUrgentAlarmContextChangeItem;

@class REMRemindersDataView, REMRemindersDataViewInvocationResult, REMRemindersDataViewInvocation_fetchByBatchCreationID, REMRemindersDataViewInvocation_fetchByDACalendarItemUniqueIdentifier, REMRemindersDataViewInvocation_fetchByExternalIdentifier, REMRemindersDataViewInvocation_fetchByListID, REMRemindersDataViewInvocation_fetchByObjectID, REMRemindersDataViewInvocation_fetchByParentReminderID, REMRemindersDataViewInvocation_fetchByParentReminderIDs, REMRemindersDataViewInvocation_fetchByPredicateDescriptor, REMRemindersDataViewInvocation_fetchMostRecentLastModifiedByListID, REMRemindersDataViewInvocation_fetchReminderIDsByParentReminderID;

@class REMRemindersDataViewInvocation_fetchRemindersCountByBatchCreationID, REMRemindersDataViewInvocation_fetchRemindersCountByListID, REMRemindersDataViewInvocation_fetchRemindersCountByParentReminderID, REMRemindersDataViewInvocation_fetchRemindersWithLocationAlarms, REMRemindersDataViewInvocation_fetchSubtasksMasksByParentReminderID, REMReplicaEntry, REMReplicaIDHelper, REMReplicaIDSource, REMReplicaManager, REMReplicaManagerSerializedData, REMResolutionToken, REMResolutionTokenMap;

@class REMSaveRequest, REMSaveRequestTrackedValueContainer, REMSecondaryGroceryLocale, REMSharedEntitySyncActivity, REMSharedToMeReminderPlaceholder, REMSharee, REMSignpost, REMSiriSearchLimitedDataView, REMSiriSearchLimitedDataViewInvocation_fetchReminders, REMSmartList, REMSmartListChangeItem, REMSmartListCustomContext;

@class REMSmartListCustomContextChangeItem, REMSmartListSection, REMSmartListSectionChangeItem, REMSmartListSectionContext, REMSmartListSectionContextChangeItem, REMSmartListSectionStorage, REMSmartListSectionsDataView, REMSmartListSectionsDataViewInvocationResult, REMSmartListSectionsDataViewInvocation_fetchByObjectIDs, REMSmartListSectionsDataViewInvocation_fetchByReminderID, REMSmartListSectionsDataViewInvocation_fetchSmartListSectionsInSmartList, REMSmartListStorage;

@class REMSmartListsDataView, REMSmartListsDataViewInvocationResult, REMSmartListsDataViewInvocation_fetchAllCustomSmartLists, REMSmartListsDataViewInvocation_fetchCustomSmartListsInAccount, REMSmartListsDataViewInvocation_fetchCustomSmartListsInGroup, REMSmartListsDataViewInvocation_fetchSmartList, REMSnoozeTimeUtils, REMStore, REMStoreContainerToken, REMStoreInvocation, REMStoreInvocationResult, REMStoreInvocationValueStorage;

@class REMStoreSwiftInvocation, REMStoreSwiftInvocationResult, REMStructuredLocation, REMSuggestedAttributesPerformer, REMSystemUtilities, REMTTHashtag, REMTTParagraphStyle, REMTTStyle, REMTemplate, REMTemplateChangeItem, REMTemplateConfiguration, REMTemplateContentAttributes;

@class REMTemplatePublicLink, REMTemplatePublicLinkConfiguration, REMTemplateSection, REMTemplateSectionChangeItem, REMTemplateSectionContext, REMTemplateSectionContextChangeItem, REMTemplateSectionStorage, REMTemplateSectionsDataView, REMTemplateSectionsDataViewInvocationResult, REMTemplateSectionsDataViewInvocation_fetchByObjectIDs, REMTemplateSectionsDataViewInvocation_fetchTemplateSectionsInTemplate, REMTemplateStorage;

@class REMTemplatesDataView, REMTemplatesDataViewInvocationResult, REMTemplatesDataViewInvocation_fetchByObjectIDs, REMTemplatesDataViewInvocation_fetchTemplatesInAccount, REMTextMemberships, REMTimestampedUUID, REMTipKitDataView, REMTipKitDataViewInvocation_fetchCompletedRemindersCount, REMTipKitDataViewInvocation_fetchCompletedRemindersCountInList, REMTipKitDataViewInvocation_fetchCustomSmartListsCount, REMTipKitDataViewInvocation_fetchHashtagsCount, REMTipKitDataViewInvocation_fetchListsCount;

@class REMTipKitDataViewInvocation_fetchListsWithCustomBadgeCount, REMTipKitDataViewInvocation_fetchUncompletedRemindersCount, REMTriggersContext, REMURLAttachment, REMUrgentPresentationAlarm, REMUrgentPresentationAlarmStatePerUser, REMUserActivity, REMUserDefaults, REMUserDefaultsObserver, REMXPCChangeTrackingPerformerInterface, REMXPCClientInterface, REMXPCDaemonController;

@class REMXPCDaemonControllerExportedObject, REMXPCDaemonControllerPerformerResolver, REMXPCDaemonControllerPerformerResolver_changeTracking, REMXPCDaemonControllerPerformerResolver_debug, REMXPCDaemonControllerPerformerResolver_indexing, REMXPCDaemonControllerPerformerResolver_store, REMXPCDaemonControllerPerformerResolver_sync, REMXPCDaemonInterface, REMXPCDebugPerformerInterface, REMXPCIndexingPerformerInterface, REMXPCStorageClasses, REMXPCStorePerformerInterface;

@class REMXPCSuggestedAttributesPerformerInterface, REMXPCSyncInterfacePerformerInterface, TTArray, TTCRVectorMultiTimestamp, TTCRVectorTimestamp, TTFont, TTMergeableAttributedString, TTMergeableString, TTMergeableStringSelection, TTMergeableStringUndoAttributeCommand, TTMergeableStringUndoEditCommand, TTMergeableStringUndoGroup;

@class TTMergeableStringVersionedDocument, TTMergeableUndoString, TTMutableParagraphStyle, TTParagraphStyle, TTREMHashtag, TTVectorMultiTimestamp, TTVectorTimestamp, TTVectorTimestampElement, TTVersionedDocument, TopoID, TopoSubstring, _REMAppStoreReviewCloudConfigurationStorage;

@class _REMChangeTrackingClientID, _REMChangeUniversalToken, _REMChangedObjectIDStorage, _REMDACalDAVSyncReplicaManagerProvider, _REMDefaultReplicaManagerProvider, _REMFetchExecutor, _REMICloudIsOffCloudConfigurationStorage, _REMInProgressSaveRequestsContainer, _REMNSPersistentHistoryChangeStorage, _REMNSPersistentHistoryTransactionStorage;

@protocol CRCoding, CRDataType, CREquatable, CRIdentifiableCRDTType, CRUndoDelegate, OS_dispatch_queue, REMAppStoreReviewCloudConfiguration, REMAuxiliaryChangeInfoObject, REMAuxiliaryReminderChangeInfo, REMCRMergeableDataType, REMCRMutableAttributedStringEditObserver, REMCRReminderIDListDelegate;

@protocol REMChangeCoalesceable, REMChangeTrackingClientIdentifying, REMChangeTrackingProvider, REMChangedObjectIdentifying, REMClientConnectionsInteractable, REMConflictResolving, REMDAAccountProviding, REMDAChangeTrackableFetchableModel, REMDAChangeTrackableModel, REMDAChangedIdentifierResult, REMDAChangedModelObjectResult, REMDaemonController;

@protocol REMDisplayDateUtilsDelegate, REMExternalSyncMetadataProviding, REMExternalSyncMetadataWritableProviding, REMHashtagProtocol, REMICloudIsOffCloudConfiguration, REMMergeableOrderingNode, REMNonceGenerating, REMNullableObjectIDProviding, REMObjectIDProviding, REMObjectStorageSupportedVersionProviding, REMPersonIDProviding, REMReplicaClockProviding;

@protocol REMReplicaIDHelperOwner, REMReplicaManagerClient, REMReplicaManagerProviding, REMSaveRequestNotifyChangeDelegate, REMSaveRequestTrackedValue, REMSupportedVersionProviding, REMSupportedVersionUpdating, REMTTHashtagHosting, REMUserDefaultsObserveToken, REMXPCChangeTrackingPerformer, REMXPCClient, REMXPCDaemon;

@protocol REMXPCDaemonControllerAutoCategorizationActivityObserver, REMXPCDaemonControllerCloudKitNetworkActivityDelegate, REMXPCDebugPerformer, REMXPCIndexingPerformer, REMXPCStorePerformer, REMXPCSuggestedAttributesPerformer, REMXPCSyncInterfacePerformer, TTMergeableStringDelegate, TTMergeableStringIDTracker, TTMergeableStringUndoCommand, TTModelAttributeComparable, _REMDAChangeTrackableModel;

@protocol _REMSupportedVersionAssignableEffectiveVersion;



@protocol CRCoding <CRDataType>

@required

/* required instance methods */
- (id)initWithCRCoder:(id)crcoder;
- (void)encodeWithCRCoder:(id)crcoder;

@optional

@end


@protocol CRDataType <NSObject>

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


@protocol CREquatable <CRDataType>

@required

@optional

@end


@protocol CRIdentifiableCRDTType <CREquatable>

@required

/* required instance methods */
- (id)identity;

@optional

@end


@protocol CRUndoDelegate <NSObject>

@required

/* required instance methods */
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (_Bool)wantsUndoCommands;

@optional

@end


@protocol REMAppStoreReviewCloudConfiguration

@required

@property (readonly, nonatomic) unsigned long long appStoreReviewCreatedOrCompletedRemindersCountThreshold;
@property (readonly, nonatomic) unsigned long long appStoreReviewNumberOfForegroundsThreshold;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalOfInterest;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceInitialForeground;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceLastPrompt;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceLastFetch;

@optional

@end


@protocol REMAuxiliaryChangeInfoObject <NSObject, REMObjectIDProviding>

@required

@property (readonly, nonatomic) NSDictionary *storage;

@optional

@end


@protocol REMAuxiliaryReminderChangeInfo

@required

@property (readonly, nonatomic) NSString *reminderIdentifier;
@property (readonly, nonatomic) NSString *oldListIdentifier;
@property (readonly, nonatomic) NSString *oldExternalIdentifier;

@optional

@end


@protocol REMCRMergeableDataType <CRDataType, CREquatable, CRCoding>

@required

/* class methods */
+ (void)rem_registerClassAtCRCoderIfNeeded;

@optional

@end


@protocol REMChangeCoalesceable

@required

/* required instance methods */
- (id)updatedProperties;
- (id)coalescedChanges;
- (id)copyForCoalescing;
- (_Bool)isCoalesced;

@optional

@end


@protocol REMChangeTrackingClientIdentifying <NSObject, NSCopying, NSSecureCoding>

@required

@optional

@end


@protocol REMChangeTrackingProvider

@required

/* required instance methods */
- (id)provideChangeTrackingForAccountID:(id)id clientName:(id)name transactionAuthorKeysToExclude:(id)exclude;
- (id)provideChangeTrackingForAccountID:(id)id clientName:(id)name;

@optional

@end


@protocol REMChangedObjectIdentifying <NSObject, NSCopying>

@required

@property (readonly, nonatomic) NSUUID *uuid;
@property (readonly, nonatomic) NSString *entityName;

@optional

@end


@protocol REMClientConnectionsInteractable

@required

/* required instance methods */
- (void)requestToUpdateClientConnectionsAsynchronously:(_Bool)asynchronously shouldKeepAlive:(_Bool)alive completion:(id /* block */)completion;

@optional

@end


@protocol REMConflictResolving

@required

@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;

/* required instance methods */
- (id)changedKeys;
- (id)resolutionTokenKeyForChangedKey:(id)key;

@optional

@end


@protocol REMDAChangeTrackableFetchableModel <REMDAChangeTrackableModel>

@required

/* class methods */
+ (_Bool)isChangeTrackableFetchableModel;

@optional

@end


@protocol REMDAChangeTrackableModel

@required

/* class methods */
+ (_Bool)isChangeTrackableModel;

@optional

@end


@protocol REMDAChangedIdentifierResult <NSObject>

@required

@optional

@end


@protocol REMDAChangedModelObjectResult <NSObject>

@required

@optional

@end


@protocol REMDaemonController <NSObject>

@required

/* required instance methods */
- (void)asyncSyncInterfacePerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (id)syncSyncInterfacePerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (void)asyncDebugPerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (void)asyncStorePerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (void)invalidate;
- (id)syncStorePerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncChangeTrackingPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncDebugPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncDebugPerformerWithErrorHandler:(id /* block */)handler;
- (void)asyncIndexingPerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (id)syncIndexingPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;

@optional

@end


@protocol REMExternalSyncMetadataProviding

@required

@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSString *externalModificationTag;
@property (readonly, nonatomic) NSString *daSyncToken;
@property (readonly, nonatomic) NSString *daPushKey;

/* required instance methods */
- (id)externalIdentifierForMarkedForDeletionObject;
- (_Bool)shouldUseExternalIdentifierAsDeletionKey;

@optional

@end


@protocol REMExternalSyncMetadataWritableProviding

@required

@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;

@optional

@end


@protocol REMHashtagProtocol

@required

/* required instance methods */
- (id)objectIdentifier;

@optional

@end


@protocol REMICloudIsOffCloudConfiguration

@required

@property (readonly, nonatomic) double iCloudIsOffTimeIntervalSinceLastPrompt;

@optional

@end


@protocol REMMergeableOrderingNode <NSObject, REMObjectIDProviding>

@required

@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentOwnerID;
@property (retain, nonatomic) REMObjectID *parentSubContainerID;

/* required instance methods */
- (id)saveRequest;
- (_Bool)isSubContainer;
- (void)removeFromParentWithAccountChangeItem:(id)item;

@optional

@end


@protocol REMNonceGenerating

@required

/* required instance methods */
- (double)generateNonce;

@optional

@end


@protocol REMNullableObjectIDProviding

@required

@property (readonly, nonatomic) REMObjectID *remObjectID;

@property (class, readonly, nonatomic) NSString *cdEntityName;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

@optional

@end


@protocol REMObjectIDProviding <REMNullableObjectIDProviding>

@required

@property (readonly, nonatomic) REMObjectID *remObjectID;

@optional

@end


@protocol REMObjectStorageSupportedVersionProviding <REMSupportedVersionProviding, REMSupportedVersionUpdating, _REMSupportedVersionAssignableEffectiveVersion>

@required

@optional

@end


@protocol REMPersonIDProviding

@required

@property (copy, nonatomic) NSString *personID;
@property (copy, nonatomic) NSData *personIDSalt;

@optional

@end


@protocol REMReplicaClockProviding <NSObject>

@required

/* required instance methods */
- (id)clockElementListForReplicaUUID:(id)uuid;

@optional

@end


@protocol REMReplicaIDHelperOwner <NSObject>

@required

@property (retain, nonatomic) id <REMReplicaManagerProviding> replicaManagerProvider;

/* required instance methods */
- (void)replicaIDHelperDidAcquireReplicaUUID:(id)uuid;

@optional

@end


@protocol REMReplicaManagerClient <REMReplicaClockProviding>

@required

@property (readonly, nonatomic) NSString *crdtID;
@property (readonly, nonatomic) NSUUID *replicaUUID;

@optional

@end


@protocol REMReplicaManagerProviding <NSObject>

@required

/* required instance methods */
- (id)unsavedReplicaManagersForAccountIDs:(id)ids;
- (id)replicaManagerForAccountID:(id)id;

@optional

@end


@protocol REMSaveRequestTrackedValue <NSObject>

@required

/* required instance methods */
- (id)shallowCopyWithSaveRequest:(id)request;

@optional

@end


@protocol REMSupportedVersionProviding

@required

@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* required instance methods */
- (_Bool)isUnsupported;

@optional

@end


@protocol REMSupportedVersionUpdating

@required

@property (nonatomic) long long minimumSupportedVersion;

@optional

@end


@protocol REMTTHashtagHosting

@required

/* required instance methods */
- (void)enumerateHashtagInRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (id)hashtagAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;

@optional

@end


@protocol REMUserDefaultsObserveToken <NSObject>

@required

/* required instance methods */
- (void)stopObserving;

@optional

@end


@protocol REMXPCChangeTrackingPerformer

@required

/* required instance methods */
- (void)currentChangeToken:(id /* block */)token;
- (void)currentChangeTokenForAccountID:(id)id completion:(id /* block */)completion;
- (void)currentChangeTokenForAccountTypes:(long long)types completion:(id /* block */)completion;
- (void)deleteHistoryBeforeDate:(id)date completionHandler:(id /* block */)handler;
- (void)deleteHistoryBeforeToken:(id)token completionHandler:(id /* block */)handler;
- (void)earliestChangeTokenForAccountID:(id)id completion:(id /* block */)completion;
- (void)fetchAuxiliaryChangeInfos:(id)infos completionHandler:(id /* block */)handler;
- (void)fetchHistoryAfterDate:(id)date entityNames:(id)names transactionFetchLimit:(unsigned long long)limit completionHandler:(id /* block */)handler;
- (void)fetchHistoryAfterToken:(id)token entityNames:(id)names transactionFetchLimit:(unsigned long long)limit completionHandler:(id /* block */)handler;
- (void)getTrackingStateWithClientID:(id)id completion:(id /* block */)completion;
- (void)saveTrackingState:(id)state withClientID:(id)id completionHandler:(id /* block */)handler;

@optional

@end


@protocol REMXPCClient

@required

/* required instance methods */
- (void)autoCategorizationActivityDidUpdate:(id)update;
- (void)cloudKitNetworkActivityDidUpdate:(id)update;

@optional

@end


@protocol REMXPCDaemon

@required

/* required instance methods */
- (void)changeTrackingPerformerWithStoreContainerToken:(id)token reason:(id)reason completion:(id /* block */)completion;
- (void)debugPerformerWithStoreContainerToken:(id)token reason:(id)reason completion:(id /* block */)completion;
- (void)indexingPerformerWithReason:(id)reason completion:(id /* block */)completion;
- (void)storePerformerWithProcessName:(id)name storeContainerToken:(id)token reason:(id)reason completion:(id /* block */)completion;
- (void)syncInterfacePerformerWithReason:(id)reason completion:(id /* block */)completion;

@optional

@end


@protocol REMXPCDebugPerformer

@required

/* required instance methods */
- (void)containerStats:(id /* block */)stats;
- (void)refreshHashtagLabelsImmediately;
- (void)cloudKitStatus:(id /* block */)status;
- (void)addGeofenceWithLatitude:(double)latitude longitude:(double)longitude radius:(double)radius uuid:(id)uuid completion:(id /* block */)completion;
- (void)addSharedEntitySyncActivityWithActivity:(id)activity completion:(id /* block */)completion;
- (void)cancelCloudKitSync:(id /* block */)sync;
- (void)crashDaemonWithMessage:(id)message;
- (void)createIsolatedStoreContainerWithCompletion:(id /* block */)completion;
- (void)daemonPid:(id /* block */)pid;
- (void)daemonStatus:(_Bool)status completion:(id /* block */)completion;
- (void)daemonVersion:(id /* block */)version;
- (void)dataAccessStatusReports:(id /* block */)reports;
- (void)destroyIsolatedStoreContainerWithToken:(id)token completion:(id /* block */)completion;
- (void)downloadContainerWithAccountID:(id)id completion:(id /* block */)completion;
- (void)dumpUbKVS:(id /* block */)kvs;
- (void)executeHousekeepingActivity:(id)activity bypassThrottle:(_Bool)throttle completion:(id /* block */)completion;
- (void)fetchAccountListOrderedIdentifiersWithAccountID:(id)id completion:(id /* block */)completion;
- (void)fetchAllDueDateDeltaAlertsIncludingUnsupported:(_Bool)unsupported completion:(id /* block */)completion;
- (void)fetchAllManualSortHintsWithDetails:(_Bool)details completion:(id /* block */)completion;
- (void)fetchAllSharedEntitySyncActivities:(id /* block */)activities;
- (void)fetchContactsMatching:(id)matching completion:(id /* block */)completion;
- (void)fetchGeofencesWithCompletion:(id /* block */)completion;
- (void)fetchHousekeepingActivitiesInfo:(id /* block */)info;
- (void)fetchManualSortHintWithListType:(id)type listID:(id)id completion:(id /* block */)completion;
- (void)fireDebugNotificationWithText:(id)text identifier:(id)identifier categoryIdentifier:(id)identifier reference:(id)reference isRemove:(_Bool)remove completion:(id /* block */)completion;
- (void)handleIncompleteAutoCategorizationOperationQueueItemsImmediatelyWithTimeout:(double)timeout;
- (void)handleIncompleteGroceryOperationQueueItemsImmediatelyWithTimeout:(double)timeout;
- (void)handleIncompleteTemplateOperationQueueItemsImmediately;
- (void)immediatelyCreateOrUpdatePublicLinkOfTemplateWithTemplateObjectID:(id)id configuration:(id)configuration completion:(id /* block */)completion;
- (void)immediatelyRevokePublicLinkOfTemplateWithTemplateObjectID:(id)id completion:(id /* block */)completion;
- (void)initDummyAutoCategorizationWithCategoryByTitle:(id)title;
- (void)lowLevelMarkForDeletionWithObjectID:(id)id shouldSetDirtyFlags:(_Bool)flags shouldRemoveFromParent:(_Bool)parent completion:(id /* block */)completion;
- (void)lowLevelUnmarkForDeletionWithObjectID:(id)id shouldSetDirtyFlags:(_Bool)flags completion:(id /* block */)completion;
- (void)markAndDeleteExtraneousAlarmsFromReminderID:(id)id shouldSetDirtyFlags:(_Bool)flags completion:(id /* block */)completion;
- (void)nukeDatabase:(id /* block */)database;
- (void)persistenceStoreIDForAccountID:(id)id completion:(id /* block */)completion;
- (void)purgeCKRecordWithRecordType:(id)type identifier:(id)identifier completion:(id /* block */)completion;
- (void)purgeDeletedObjectsWithCompletionHandler:(id /* block */)handler;
- (void)registerBabysitterWith:(id)with completion:(id /* block */)completion;
- (void)removeAllSharedEntitySyncActivityWithCompletion:(id /* block */)completion;
- (void)removeFromUbKVSForKey:(id)key completion:(id /* block */)completion;
- (void)removeGeofenceWithUUID:(id)uuid completion:(id /* block */)completion;
- (void)removeManualSortHintWithIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)removeSharedEntitySyncActivitiesWithCKIdentifier:(id)ckidentifier completion:(id /* block */)completion;
- (void)removeSharedEntitySyncActivityWithUUIDForChangeTracking:(id)tracking completion:(id /* block */)completion;
- (void)resetAllManualSortHintsWithCompletion:(id /* block */)completion;
- (void)resetBabysitterWithRestrictedAccountID:(id)id completion:(id /* block */)completion;
- (void)resetHousekeepingActivityThrottle:(id)throttle completion:(id /* block */)completion;
- (void)resetManualSortHintBeforeLastAccessed:(id)accessed completion:(id /* block */)completion;
- (void)resetManualSortHintWithIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)resetManualSortHintWithListType:(id)type listID:(id)id completion:(id /* block */)completion;
- (void)retryAccountZoneIDsNeedingToBeSavedWithAccountID:(id)id completion:(id /* block */)completion;
- (void)setDueDateResolutionTokenNonceForAlarmID:(id)id nonce:(double)nonce shouldSetDirtyFlags:(_Bool)flags completion:(id /* block */)completion;
- (void)setDueDateResolutionTokenNonceForReminderID:(id)id nonce:(double)nonce shouldSetDirtyFlags:(_Bool)flags completion:(id /* block */)completion;
- (void)setupManualHashtagLabelUpdater;
- (void)simulateCoreLocationEnterRegionWithIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)simulateCoreLocationExitRegionWithIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)synchronous_revertImageAttachmentsToUnDeduped:(id)deduped completion:(id /* block */)completion;
- (void)testFlagAccountForInactivatedCalDAVDataMigrationWithAccountIdentifier:(id)identifier completionHandler:(id /* block */)handler;
- (void)testInitialSyncWithAccountName:(id)name completion:(id /* block */)completion;
- (void)testReinitializeCloudKitWithAccountIdentifier:(id)identifier completionHandler:(id /* block */)handler;
- (void)updateManualSortHintWithIdentifier:(id)identifier lastAccessed:(id)accessed completion:(id /* block */)completion;
- (void)updateMinimumSupportedVersionWithObjectID:(id)id minimumSupportedVersion:(long long)version completion:(id /* block */)completion;
- (void)updateRemCurrentRuntimeVersionDebuggingOverride:(long long)override;
- (void)validateHashtagLabelsWithConcealedHashtagsWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)validateHashtagLabelsWithoutHashtagWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)validateHashtagsWithMismatchedHashtagsWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)validateHashtagsWithSharedToMeReminderCKIdentifierAndMismatchedReminderCKIdentifierWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)validateHashtagsWithoutHashtagLabelWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)validateSharedToMeReminderPlaceholdersWithRepair:(_Bool)repair completion:(id /* block */)completion;
- (void)writeUbKVSWithKey:(id)key dateValue:(id)value completion:(id /* block */)completion;
- (void)writeUbKVSWithKey:(id)key stringValue:(id)value completion:(id /* block */)completion;

@optional

@end


@protocol REMXPCIndexingPerformer

@required

/* required instance methods */
- (void)deleteAllSearchableItemsWithCompletionHandler:(id /* block */)handler;
- (void)reindexAllSearchableItemsWithAcknowledgementHandler:(id /* block */)handler;
- (void)reindexSearchableItemsWithIdentifiers:(id)identifiers acknowledgementHandler:(id /* block */)handler;
- (void)testIndexDummyItemWithCompletion:(id /* block */)completion;
- (void)verifySpotlightIndexWithCompletionHandler:(id /* block */)handler;

@optional

@end


@protocol REMXPCStorePerformer

@required

/* required instance methods */
- (void)requestToMergeSyncDataIntoLocalDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)requestDownloadGroceryModelAssetsFromTrial;
- (void)requestToDeleteLocalDataWithCompletion:(id /* block */)completion;
- (void)requestToDeleteSyncDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)requestToMergeLocalDataIntoSyncDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)executeFetchRequest:(id)request completion:(id /* block */)completion;
- (void)stopShare:(id)share accountID:(id)id completion:(id /* block */)completion;
- (void)MCIsManagedAccountWithObjectID:(id)id completion:(id /* block */)completion;
- (void)acceptCalDAVShareWithCalendarURL:(id)url acAccountID:(id)id completion:(id /* block */)completion;
- (void)acceptShareWithMetadata:(id)metadata completion:(id /* block */)completion;
- (void)addCKShareObserverIfNeededForAccountID:(id)id completion:(id /* block */)completion;
- (void)anchoredBubbleEnabledWithCompletion:(id /* block */)completion;
- (void)batchDeleteExpiredRemindersWith:(id)with completion:(id /* block */)completion;
- (void)clearAutoCategorizationLocalCorrectionsOfListsOwnedByCurrentUserWithSupportsAutoCategorizationModels:(_Bool)models completion:(id /* block */)completion;
- (void)compressedDistributedEvaluationDataWithOptions:(id)options completion:(id /* block */)completion;
- (void)createOrUpdatePublicLinkForTemplateWithObjectID:(id)id configuration:(id)configuration completion:(id /* block */)completion;
- (void)createPublicContentPreviewOfTemplateWithObjectID:(id)id configuration:(id)configuration completion:(id /* block */)completion;
- (void)createShareForObjectWithID:(id)id appIconData:(id)data completion:(id /* block */)completion;
- (void)downloadPublicTemplateWithPublicLinkURLUUID:(id)urluuid completion:(id /* block */)completion;
- (void)fetchAutoCategorizationSuggestedSectionsForListName:(id)name reminderTitles:(id)titles existingSections:(id)sections completion:(id /* block */)completion;
- (void)fetchContentAttributesOfTemplateWithObjectID:(id)id completion:(id /* block */)completion;
- (void)fetchFindMyDeviceInformationWithCompletion:(id /* block */)completion;
- (void)fetchGroceryLocalCorrectionsOfListWithObjectID:(id)id completion:(id /* block */)completion;
- (void)fetchIntelligentFeaturesMinimumSupportedVersionWith:(long long)with isInternalInstall:(_Bool)install completion:(id /* block */)completion;
- (void)fetchMinimumSearchTermLengthByBaseLanguageWithCompletion:(id /* block */)completion;
- (void)fetchReplicaManagerForAccountID:(id)id completion:(id /* block */)completion;
- (void)fetchReplicaManagersForAccountID:(id)id bundleID:(id)id completion:(id /* block */)completion;
- (void)fetchShareForObjectWithID:(id)id completion:(id /* block */)completion;
- (void)fetchShouldSuggestConvertToGroceryWithObjectID:(id)id usingGroceryClassifierWithGroceryLocaleID:(id)id completion:(id /* block */)completion;
- (void)fetchSuggestedRemindersFromExtractionInput:(id)input completion:(id /* block */)completion;
- (void)fetchSuggestedSectionNamesFromGroceryClassifierWithGroceryLocaleID:(id)id completion:(id /* block */)completion;
- (void)fetchSuggestedSectionsForRemindersWithReminderTitles:(id)titles fromGroceryClassifierWithGroceryLocaleIDs:(id)ids maxSuggestionsCountPerReminderTitle:(id)title confidenceScoreThreshold:(id)threshold shouldUseGlobalCorrections:(_Bool)corrections completion:(id /* block */)completion;
- (void)groceryClassifierResultForString:(id)string completion:(id /* block */)completion;
- (void)notifyOfInteractionWithPeople:(id)people completion:(id /* block */)completion;
- (void)performInvocation:(id)invocation completion:(id /* block */)completion;
- (void)performSwiftInvocation:(id)invocation withParametersData:(id)data storages:(id)storages completion:(id /* block */)completion;
- (void)permanentlyHideRemindersWith:(id)with accountID:(id)id completion:(id /* block */)completion;
- (void)rejectCalDAVShareWithCalendarURL:(id)url acAccountID:(id)id completion:(id /* block */)completion;
- (void)removeOrphanedAccountWithCompletion:(id /* block */)completion;
- (void)requestShouldSuggestConvertToGroceryWithObjectID:(id)id;
- (void)requestToUpdateClientConnectionsWithShouldKeepAlive:(_Bool)alive;
- (void)revokePublicLinkForTemplateWithObjectID:(id)id completion:(id /* block */)completion;
- (void)saveAccountStorages:(id)storages listStorages:(id)storages listSectionStorages:(id)storages smartListStorages:(id)storages smartListSectionStorages:(id)storages templateStorages:(id)storages templateSectionStorages:(id)storages reminderStorages:(id)storages changedKeys:(id)keys replicaManagers:(id)managers author:(id)author mode:(unsigned long long)mode synchronously:(_Bool)synchronously syncToCloudKit:(_Bool)kit completion:(id /* block */)completion;
- (void)setOverridingGroceryCategorizationSecondaryGroceryLocales:(id)locales completion:(id /* block */)completion;
- (void)setSuggestGroceriesDismissed:(_Bool)dismissed completion:(id /* block */)completion;
- (void)uncachedSuggestedAttributesPerformerWithReason:(id)reason completion:(id /* block */)completion;
- (void)updateAccountWithACAccountID:(id)id restartDA:(_Bool)da completion:(id /* block */)completion;
- (void)updateAccountsAndFetchMigrationState:(_Bool)state completion:(id /* block */)completion;
- (void)updateShare:(id)share accountID:(id)id completion:(id /* block */)completion;
- (void)validatePhantomObjectsWith:(id)with shouldRepair:(_Bool)repair completion:(id /* block */)completion;

@optional

@end


@protocol REMXPCSuggestedAttributesPerformer <NSObject>

@required

/* required instance methods */
- (void)performSwiftInvocation:(id)invocation withParametersData:(id)data storages:(id)storages completion:(id /* block */)completion;
- (void)preWarmModels;

@optional

@end


@protocol REMXPCSyncInterfacePerformer

@required

/* required instance methods */
- (void)debugDownloadMigrationCacheWithAccountID:(id)id completion:(id /* block */)completion;
- (void)deleteApplicationDataFromCloudKitWithAccountID:(id)id completion:(id /* block */)completion;
- (void)fetchServerRecordFor:(id)_for completion:(id /* block */)completion;
- (void)fetchUserRecordWithAccountID:(id)id completion:(id /* block */)completion;
- (void)migrateICloudCalDavToCloudKitWithAccountID:(id)id disableCache:(_Bool)cache userInitiated:(_Bool)initiated completion:(id /* block */)completion;
- (void)observeAutoCategorizationActivityChanges;
- (void)observeCloudKitNetworkActivityChanges;
- (void)restartCloudKitSyncWithReason:(id)reason bypassThrottler:(_Bool)throttler completion:(id /* block */)completion;
- (void)setMigrationStateToDidChooseToMigrate:(_Bool)migrate didFinishMigration:(_Bool)migration createZoneAccountIfFinishMigration:(_Bool)migration accountID:(id)id completion:(id /* block */)completion;
- (void)syncCloudKitWithReason:(id)reason discretionary:(_Bool)discretionary bypassThrottler:(_Bool)throttler completion:(id /* block */)completion;
- (void)syncDataAccessAccountsWithAccountIDs:(id)ids bypassThrottler:(_Bool)throttler completion:(id /* block */)completion;

@optional

@end


@protocol TTMergeableStringDelegate <NSObject>

@required

/* required instance methods */
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (void)endEditing;
- (void)beginEditing;
- (void)addUndoCommand:(id)command;
- (_Bool)wantsUndoCommands;

@optional

@end


@protocol TTMergeableStringIDTracker <NSObject>

@required

/* required instance methods */
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)hasTopoIDsThatCanChange;

@optional

@end


@protocol TTMergeableStringUndoCommand <NSObject, TTMergeableStringIDTracker>

@required

/* required instance methods */
- (_Bool)addToGroup:(id)group;
- (void)applyToString:(id)string;

@optional

@end


@protocol TTModelAttributeComparable <NSObject>

@required

/* required instance methods */
- (_Bool)isEqualToModelComparable:(id)comparable;

@optional

@end


@protocol _REMDAChangeTrackableModel <NSObject>

@required

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;

@property (class, readonly, nonatomic) _Bool rem_DA_supportsFetching;
@property (class, readonly, nonatomic) _Bool rem_DA_supportsConcealedObjects;
@property (class, readonly, nonatomic) NSArray *rem_DA_propertiesAffectingIsConcealed;
@property (class, readonly, nonatomic) id /* block */ rem_DA_fetchByObjectIDBlock;
@property (class, readonly, nonatomic) id /* block */ rem_DA_fetchByObjectIDsBlock;
@property (class, readonly, nonatomic) id /* block */ rem_DA_deletedKeyFromTombstoneBlock;
@property (class, readonly, nonatomic) id /* block */ rem_DA_deletedKeyFromConcealedModelObjectBlock;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

@optional

@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;

@end


@protocol _REMSupportedVersionAssignableEffectiveVersion

@required

@property (nonatomic) long long effectiveMinimumSupportedVersion;

@optional

@end


@interface CRArray : NSObject <CRCoding, CRUndoDelegate, CRDataType>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) TTArray *array;
@property (retain, nonatomic) CRDictionary *contents;
@property (nonatomic) _Bool moveClock;
@property (weak, nonatomic) CRDocument *document;
@property (weak, nonatomic) NSObject<CRUndoDelegate> *delegate;
@property (readonly, nonatomic) unsigned long long count;
@property (readonly, nonatomic) NSUUID *replicaUUID;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)initWithCRCoder:(id)crcoder;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)addObject:(id)object;
- (id)initWithDocument:(id)document;
- (void)mergeWith:(id)with;
- (id)init;
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
- (void)encodeWithCRCoder:(id)crcoder array:(void *)array;
- (unsigned long long)firstIndexOf:(id)of fromIndex:(unsigned long long)index;
- (id)initWithCRCoder:(id)crcoder array:(const void *)array;
- (id)initWithTTArray:(id)ttarray contents:(id)contents document:(id)document;
- (void)moveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)removeObjectAtIndex:(unsigned long long)index forUndo:(_Bool)undo;
- (_Bool)wantsUndoCommands;

@end


@interface CRCoder : NSObject

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


@interface CRCoderArchiver : CRCoder

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

@end


@interface CRCoderUnarchiver : CRCoder

@property (copy, nonatomic) NSUUID *replica;
@property (retain, nonatomic) CRDocument *document;
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

@end


@interface CRCoderUnarchiverCompletionHandler : NSObject

@property (copy, nonatomic) id /* block */ block;
@property (weak, nonatomic) id dependency;
@property (weak, nonatomic) id value;

/* instance methods */

@end


@interface CRConstant : NSObject

/* class methods */
+ (id)constant;

/* instance methods */
- (_Bool)isEqual:(id)equal;

@end


@interface CRDictionary : NSObject <CRDataType, NSFastEnumeration, CRCoding>

@property (retain, nonatomic) NSMapTable *contents;
@property (nonatomic) long long removeClock;
@property (weak, nonatomic) CRDocument *document;
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
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
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
- (void)encodeWithCRCoder:(id)crcoder dictionary:(void *)dictionary;
- (void)encodeWithCRCoder:(id)crcoder dictionary:(void *)dictionary elementValueCoder:(id /* block */)coder;
- (void)enumerateKeysObjectsAndTimestampsUsingBlock:(id /* block */)block;
- (id)initWithCRCoder:(id)crcoder dictionary:(const void *)dictionary;
- (id)initWithCRCoder:(id)crcoder dictionary:(const void *)dictionary elementValueDecoder:(id /* block */)decoder;

@end


@interface CRDictionaryElement : NSObject

@property (retain, nonatomic) id <CRDataType> value;
@property (retain, nonatomic) CRVectorTimestamp *timestamp;

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


@interface CRDocument : NSObject <REMReplicaClockProviding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) CRVectorTimestamp *version;
@property (readonly, nonatomic) CRVectorTimestamp *startVersion;
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
- (id)init;
- (id)archivedData;
- (void)updateObjects:(id)objects;
- (id)clockElementListForReplicaUUID:(id)uuid;
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


@interface CRObject : NSObject <CRDataType, CREquatable, CRIdentifiableCRDTType, CRCoding>

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

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (id)init;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)mergeWithObject:(id)object;
- (id)initWithIdentity:(id)identity fields:(id)fields;
- (void)setFieldKey:(id)key value:(id)value;
- (void)setupConstraintsFor:(id)_for in:(id)in;

@end


@interface CRRegister : NSObject <CRDataType, CRCoding>

@property (retain, nonatomic) id contents;
@property (weak, nonatomic) CRDocument *document;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)registerWithType:(unsigned long long)type contents:(id)contents;
+ (id)registerWithType:(unsigned long long)type contents:(id)contents document:(id)document;

/* instance methods */
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (id)initWithDocument:(id)document;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (_Bool)isEqualContents:(id)contents;

@end


@interface CRRegisterLatest : CRRegister

@property (retain, nonatomic) CRTimestamp *timestamp;

/* instance methods */
- (void)setDocument:(id)document;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)setContents:(id)contents;
- (void)encodeWithCRCoder:(id)crcoder;
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

@end


@interface CRRegisterGreatest : CRRegisterLatest

/* instance methods */
- (id)initWithCRCoder:(id)crcoder;
- (void)setContents:(id)contents;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (long long)compare:(id)compare with:(id)with;
- (void)mergeWithRegisterGreatest:(id)greatest;

@end


@interface CRRegisterLeast : CRRegisterGreatest

/* instance methods */
- (long long)compare:(id)compare with:(id)with;

@end


@interface CRRegisterMultiValue : CRRegister

@property (retain, nonatomic) CRSet *values;
@property (retain, nonatomic) NSSet *cachedValues;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)setContents:(id)contents;
- (void)encodeWithCRCoder:(id)crcoder;
- (id)contents;
- (id)initWithValues:(id)values;
- (void)mergeWith:(id)with;
- (id)description;
- (void)walkGraph:(id /* block */)graph;
- (id)allContents;
- (id)initWithContents:(id)contents document:(id)document;
- (void)mergeWithRegisterMultiValue:(id)value;

@end


@interface CRRegisterMultiValueLeast : CRRegisterMultiValue

/* instance methods */
- (id)contents;

@end


@interface CRReplica : NSObject

/* class methods */
+ (id)unserialisedIdentifier;

@end


@interface CRSet : NSObject <CRDataType, NSFastEnumeration, CRCoding>

@property (retain, nonatomic) CRDictionary *dictionary;
@property (retain, nonatomic) NSHashTable *observers;
@property (weak, nonatomic) CRDocument *document;
@property (readonly) unsigned long long count;
@property (readonly, copy) NSArray *allObjects;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
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
- (void)encodeWithCRCoder:(id)crcoder set:(void *)set;
- (void)encodeWithCRCoder:(id)crcoder set:(void *)set elementValueCoder:(id /* block */)coder;
- (id)initWithCRCoder:(id)crcoder set:(const void *)set;
- (id)initWithCRCoder:(id)crcoder set:(const void *)set elementValueDecoder:(id /* block */)decoder;

@end


@interface CRTTCompatibleDocument : CRDocument

@property (retain, nonatomic) TTCRVectorMultiTimestamp *sharedTopotextTimestamp;
@property (retain, nonatomic) NSMutableArray *stringsWithClocksNeedingUpdating;
@property (retain, nonatomic) NSMutableArray *stringsWithClocksToResetAfterRealizingLocalChanges;

/* instance methods */
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica;
- (id)initWithVersion:(id)version startVersion:(id)version rootObject:(id)object replica:(id)replica topoTimestamp:(id)timestamp;
- (unsigned long long)mergeResultForMergingWithDocument:(id)document;
- (void)mergeTimestampWithDocument:(id)document;
- (void)realizeLocalChanges;

@end


@interface CRTimestamp : NSObject <CRDataType, CREquatable, NSCopying, CRCoding>

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
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
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

@end


@interface CRTombstoneOrderedSet : NSObject <CRCoding, CRUndoDelegate, CRDataType>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) NSMutableOrderedSet *cachedIdentifierSet;
@property (readonly, nonatomic) NSMapTable *cachedIndexMapping;
@property (retain, nonatomic) CRArray *ordering;
@property (retain, nonatomic) CRSet *elements;
@property (weak, nonatomic) CRDocument *document;
@property (weak, nonatomic) NSObject<CRUndoDelegate> *delegate;
@property (readonly, nonatomic) unsigned long long count;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)initWithCRCoder:(id)crcoder;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (id)objectForIdentifier:(id)identifier;
- (void)encodeWithCRCoder:(id)crcoder;
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
- (void)encodeWithCRCoder:(id)crcoder orderedSet:(void *)set;
- (id)generateNSOrderedIdentifierSetWithIndexMapping:(id)mapping;
- (unsigned long long)indexOfEqualObject:(id)object;
- (id)initWithCRCoder:(id)crcoder orderedSet:(const void *)set;
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

@end


@interface CRVectorTimestamp : NSObject <CRDataType, NSCopying, CRCoding>

@property (readonly, nonatomic) unsigned long long count;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
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

@end


@interface CRVectorTimestampElement : NSObject <NSSecureCoding>

@property (nonatomic) unsigned long long clock;
@property (nonatomic) unsigned long long subclock;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (long long)rem_compareToVectorTimestampElement:(id)element;

@end


@interface ICProtobufUtilities : NSObject

@end


@interface REMAccount : NSObject <REMPersonIDProviding, REMObjectIDProviding, REMExternalSyncMetadataProviding, REMSupportedVersionProviding>

@property (nonatomic) _Bool markedForRemoval;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) NSSet *listIDsToUndelete;
@property (readonly, nonatomic) NSSet *smartListIDsToUndelete;
@property (readonly, nonatomic) _Bool listsDADisplayOrderChanged;
@property (readonly, nonatomic) _Bool debugSyncDisabled;
@property (readonly, nonatomic) REMAccountTemplatesContext *templatesContext;
@property (retain, nonatomic) REMStore *store;
@property (readonly, copy, nonatomic) REMAccountStorage *storage;
@property (retain, nonatomic) REMAccountCapabilities *capabilities;
@property (retain, nonatomic) NSString *displayName;
@property (readonly, nonatomic) REMCRMergeableOrderedSet *listIDsMergeableOrdering;
@property (readonly, nonatomic) NSData *listIDsMergeableOrderingData;
@property (readonly, nonatomic) NSOrderedSet *listIDsOrdering;
@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) _Bool inactive;
@property (readonly, nonatomic) _Bool didChooseToMigrate;
@property (readonly, nonatomic) _Bool didChooseToMigrateLocally;
@property (readonly, nonatomic) _Bool didFinishMigration;
@property (readonly, nonatomic) long long persistenceCloudSchemaVersion;
@property (readonly, nonatomic) NSString *daConstraintsDescriptionPath;
@property (readonly, nonatomic) _Bool daAllowsCalendarAddDeleteModify;
@property (readonly, nonatomic) _Bool daSupportsPhoneNumbers;
@property (readonly, nonatomic) _Bool daSupportsSharedCalendars;
@property (readonly, nonatomic) _Bool daWasMigrated;
@property (readonly, nonatomic) _Bool supportsSharingLists;
@property (readonly, nonatomic) REMAccountGroupContext *groupContext;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *personID;
@property (copy, nonatomic) NSData *personIDSalt;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSString *externalModificationTag;
@property (readonly, nonatomic) NSString *daSyncToken;
@property (readonly, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)_accountTypeMaskWithBitMask:(long long)mask;
+ (id)cdEntityName;
+ (id)localInternalAccountID;
+ (id)localAccountID;
+ (_Bool)isCloudBasedAccountType:(long long)type;
+ (_Bool)canCopyReminderLosslesslyFromAccountWithType:(long long)type toAccountWithType:(long long)type accountTypeHost:(id)host;
+ (id)newObjectID;

/* instance methods */
- (id)externalIdentifierForMarkedForDeletionObject;
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)fetchListsAndSublistsWithError:(id *)error;
- (_Bool)respondsToSelector:(SEL)selector;
- (id)fetchListIncludingSpecialContainerWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)fetchCustomSmartListsWithError:(id *)error;
- (id)accountTypeHost;
- (_Bool)isConsideredEmptyWithResultPtr:(_Bool *)ptr withError:(id *)error;
- (id)description;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (_Bool)shouldUseExternalIdentifierAsDeletionKey;
- (id)initWithStore:(id)store storage:(id)storage;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)fetchListsWithError:(id *)error;
- (id)forwardingTargetForSelector:(SEL)selector;
- (unsigned long long)hash;
- (id)fetchListsIncludingSpecialContainersWithError:(id *)error;
- (_Bool)MCIsManagedWithResultPtr:(_Bool *)ptr error:(id *)error;
- (_Bool)canCopyReminderLosslesslyToAccount:(id)account;
- (id)optionalObjectID;

@end


@interface REMAccountCapabilities : NSObject

@property (readonly, nonatomic) _Bool supportsEventKitSync;
@property (readonly, nonatomic) _Bool supportsCloudKitSync;
@property (readonly, nonatomic) _Bool supportsCalDAVNotifications;
@property (readonly, nonatomic) _Bool supportsListSharees;
@property (readonly, nonatomic) _Bool supportsListShareesMutation;
@property (readonly, nonatomic) _Bool supportsMoveAcrossLists;
@property (readonly, nonatomic) _Bool supportsMoveAcrossSharedLists;
@property (readonly, nonatomic) _Bool supportsMultipleDateAlarmsOnRecurrence;
@property (readonly, nonatomic) _Bool supportsSections;
@property (readonly, nonatomic) _Bool supportsDueDateDeltaAlerts;
@property (readonly, nonatomic) long long defaultReminderPriorityLevel;
@property (readonly, nonatomic) _Bool supportsHandoff;
@property (readonly, nonatomic) _Bool supportsReminderActions;
@property (readonly, nonatomic) _Bool supportsCRDTs;
@property (readonly, nonatomic) _Bool supportsAssignments;
@property (readonly, nonatomic) _Bool supportsHashtags;
@property (readonly, nonatomic) _Bool insertsCompletedRecurrentCloneAtTail;
@property (readonly, nonatomic) _Bool supportsCustomSmartLists;
@property (readonly, nonatomic) _Bool supportsPinnedLists;
@property (readonly, nonatomic) _Bool supportsTextStyling;
@property (readonly, nonatomic) _Bool supportsDeletionByTTL;
@property (readonly, nonatomic) _Bool supportsGroceriesList;
@property (readonly, nonatomic) _Bool supportsRecentlyDeletedList;
@property (readonly, nonatomic) _Bool supportsSubtasks;
@property (readonly, nonatomic) _Bool supportsAttachments;
@property (readonly, nonatomic) _Bool supportsListAppearance;
@property (readonly, nonatomic) _Bool supportsGroups;
@property (readonly, nonatomic) _Bool supportsFlagged;
@property (readonly, nonatomic) _Bool supportsPersonTrigger;
@property (readonly, nonatomic) _Bool supportsLocation;
@property (readonly, nonatomic) _Bool supportsHourlyRecurrence;
@property (readonly, nonatomic) _Bool supportsTemplates;
@property (readonly, nonatomic) _Bool supportsUrgentAlarm;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithAccountType:(long long)type;
- (unsigned long long)hash;

@end


@interface REMAccountChangeItem : NSObject <REMConflictResolving, REMPersonIDProviding, REMSaveRequestTrackedValue, REMExternalSyncMetadataWritableProviding, REMSupportedVersionProviding, REMSupportedVersionUpdating>

@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (retain, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMAccountCapabilities *capabilities;
@property (readonly, nonatomic) REMCRMergeableOrderedSet *listIDsMergeableOrdering;
@property (readonly, nonatomic) NSData *listIDsMergeableOrderingData;
@property (retain, nonatomic) REMManualOrdering *pinnedListsManualOrdering;
@property (retain, nonatomic) REMManualOrdering *templatesManualOrdering;
@property (nonatomic) _Bool markedForRemoval;
@property (retain, nonatomic) NSSet *listIDsToUndelete;
@property (retain, nonatomic) NSSet *smartListIDsToUndelete;
@property (retain, nonatomic) NSString *displayName;
@property (nonatomic) _Bool debugSyncDisabled;
@property (nonatomic) _Bool listsDADisplayOrderChanged;
@property (nonatomic) long long type;
@property (readonly, copy, nonatomic) REMAccountStorage *storage;
@property (retain, nonatomic) NSString *name;
@property (readonly, nonatomic) REMAccountPinnedListsContextChangeItem *pinnedListsContext;
@property (nonatomic) _Bool inactive;
@property (nonatomic) _Bool didChooseToMigrate;
@property (nonatomic) _Bool didChooseToMigrateLocally;
@property (nonatomic) _Bool didFinishMigration;
@property (nonatomic) long long persistenceCloudSchemaVersion;
@property (retain, nonatomic) NSString *daConstraintsDescriptionPath;
@property (nonatomic) _Bool daAllowsCalendarAddDeleteModify;
@property (nonatomic) _Bool daSupportsSharedCalendars;
@property (nonatomic) _Bool daWasMigrated;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (readonly, nonatomic) REMAccountGroupContextChangeItem *groupContext;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (copy, nonatomic) NSString *personID;
@property (copy, nonatomic) NSData *personIDSalt;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (void)initialize;
+ (id)_emptyListIDsOrderingWithAccountID:(id)id;

/* instance methods */
- (_Bool)respondsToSelector:(SEL)selector;
- (id)accountTypeHost;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (void)addListChangeItem:(id)item;
- (void)_editListIDsOrderingUsingBlock:(id /* block */)block;
- (void)removeFromStore;
- (void)_lowLevelAddMergeableOrderingNodeToOrdering:(id)ordering atIndexOfSibling:(id)sibling isAfter:(_Bool)after withParentMergeableOrderingNode:(id)node;
- (void)_lowLevelApplyUndoToOrdering:(id)ordering;
- (void)_reassignMergeableOrderingNode:(id)node withParentListChangeItem:(id)item;
- (void)addMergeableOrderingNode:(id)node;
- (void)addSmartListChangeItem:(id)item;
- (_Bool)canCopyReminderLosslesslyToAccountChangeItem:(id)item;
- (id)initWithObjectID:(id)id type:(long long)type name:(id)name insertIntoSaveRequest:(id)request;
- (id)initWithSaveRequest:(id)request storage:(id)storage capabilities:(id)capabilities changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage capabilities:(id)capabilities observeInitialValues:(_Bool)values;
- (void)insertListChangeItem:(id)item afterListChangeItem:(id)item;
- (void)insertListChangeItem:(id)item beforeListChangeItem:(id)item;
- (void)insertMergeableOrderingNode:(id)node adjacentToMergeableOrderingNode:(id)node isAfter:(_Bool)after withParentMergeableOrderingNode:(id)node;
- (void)insertMergeableOrderingNode:(id)node afterMergeableOrderingNode:(id)node;
- (void)insertMergeableOrderingNode:(id)node beforeMergeableOrderingNode:(id)node;
- (void)insertSmartListChangeItem:(id)item afterSmartListChangeItem:(id)item;
- (void)insertSmartListChangeItem:(id)item beforeSmartListChangeItem:(id)item;
- (void)lowLevelAddMergeableOrderingNodeIDToOrdering:(id)ordering withParentMergeableOrderingNode:(id)node;
- (id)lowLevelRemoveMergeableOrderingNodeIDFromOrdering:(id)ordering;
- (id)mergeableOrderingNodesByOrderingMergeableOrderingNodes:(id)nodes;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (id)shallowCopyWithSaveRequest:(id)request;
- (id)templatesContextChangeItem;
- (void)test_lowLevelEditOrderingByMovingListObjectID:(id)id toTarget:(unsigned long long)target;
- (void)undeleteListWithID:(id)id usingUndo:(id)undo;
- (void)undeleteSmartListWithID:(id)id usingUndo:(id)undo;

@end


@interface REMAccountGroupContext : NSObject

@property (retain, nonatomic) REMAccount *account;

/* instance methods */
- (id)initWithAccount:(id)account;
- (id)fetchGroupsWithError:(id *)error;

@end


@interface REMAccountGroupContextChangeItem : NSObject

@property (retain, nonatomic) REMAccountChangeItem *accountChangeItem;

/* instance methods */
- (id)initWithAccountChangeItem:(id)item;

@end


@interface REMAccountPinnedListsContextChangeItem : NSObject

@property (retain, nonatomic) REMAccountChangeItem *accountChangeItem;
@property (readonly, nonatomic) REMManualOrdering *unsavedManualOrdering;

/* instance methods */
- (id)initWithAccountChangeItem:(id)item;
- (void)updateManualOrdering:(id)ordering;

@end


@interface REMAccountSortDescriptor : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) _Bool ascending;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithType:(long long)type ascending:(_Bool)ascending;

@end


@interface REMAccountStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMExternalSyncMetadataWritableProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) REMObjectID *objectID;
@property (nonatomic) long long type;
@property (retain, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *displayName;
@property (retain, nonatomic) REMCRMergeableOrderedSet *listIDsMergeableOrdering;
@property (retain, nonatomic) NSData *listIDsMergeableOrderingData;
@property (retain, nonatomic) REMManualOrdering *pinnedListsManualOrdering;
@property (retain, nonatomic) REMManualOrdering *templatesManualOrdering;
@property (nonatomic) _Bool markedForRemoval;
@property (retain, nonatomic) NSSet *listIDsToUndelete;
@property (retain, nonatomic) NSSet *smartListIDsToUndelete;
@property (nonatomic) _Bool listsDADisplayOrderChanged;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (copy, nonatomic) NSString *personID;
@property (copy, nonatomic) NSData *personIDSalt;
@property (nonatomic) _Bool inactive;
@property (nonatomic) _Bool didChooseToMigrate;
@property (nonatomic) _Bool didChooseToMigrateLocally;
@property (nonatomic) _Bool didFinishMigration;
@property (nonatomic) long long persistenceCloudSchemaVersion;
@property (nonatomic) _Bool debugSyncDisabled;
@property (copy, nonatomic) NSString *daConstraintsDescriptionPath;
@property (nonatomic) _Bool daAllowsCalendarAddDeleteModify;
@property (nonatomic) _Bool daSupportsSharedCalendars;
@property (nonatomic) _Bool daWasMigrated;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)listIDsMergeableOrderingReplicaIDSourceWithAccountID:(id)id;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)storeGeneration;
- (id)debugDescription;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)accountTypeHost;
- (id)listIDsMergeableOrderingReplicaIDSource;
- (id)initWithObjectID:(id)id type:(long long)type name:(id)name;
- (id)initWithObjectID:(id)id type:(long long)type name:(id)name nullableListIDsMergeableOrdering:(id)ordering;
- (id)description;
- (void)_setIsAddingExtraPrimaryCKAccountForTesting:(_Bool)testing;
- (_Bool)hasDeserializedListIDsMergeableOrdering;
- (_Bool)isUnsupported;
- (id)serializedListIDsMergeableOrdering;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithObjectID:(id)id type:(long long)type name:(id)name listIDsMergeableOrdering:(id)ordering;
- (_Bool)_isAddingExtraPrimaryCKAccountForTesting;
- (id)optionalObjectID;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountTemplatesContext : NSObject

@property (retain, nonatomic) REMAccount *account;

/* instance methods */
- (id)initWithAccount:(id)account;
- (id)fetchTemplatesWithError:(id *)error;

@end


@interface REMAccountTemplatesContextChangeItem : NSObject

@property (retain, nonatomic) REMAccountChangeItem *accountChangeItem;
@property (readonly, nonatomic) REMManualOrdering *unsavedManualOrdering;

/* instance methods */
- (id)addTemplateWithName:(id)name configuration:(id)configuration;
- (id)initWithAccountChangeItem:(id)item;
- (void)updateManualOrdering:(id)ordering;

@end


@interface REMAccountTypeHost : NSObject

@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* instance methods */
- (id)internalDescription;
- (_Bool)isEqual:(id)equal;
- (_Bool)isLocal;
- (_Bool)isPrimaryCloudKit;
- (long long)_accountType;
- (_Bool)isValid;
- (_Bool)isLocalInternal;
- (id)initWithType:(long long)type;
- (id)description;
- (unsigned long long)hash;
- (_Bool)isExchange;
- (_Bool)isNonPrimaryCloudKit;
- (_Bool)isCloudKit;
- (_Bool)isCalDav;
- (_Bool)isCloudBased;

@end


@interface REMAccountsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* class methods */
+ (id)accountsFromAccountStorages:(id)storages store:(id)store;

/* instance methods */
- (id)fetchAccountWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)fetchActiveCloudKitAccountObjectIDsWithFetchOption:(long long)option error:(id *)error;
- (id)fetchAccountsWithExternalIdentifiers:(id)identifiers error:(id *)error;
- (id)fetchAccountWithObjectID:(id)id error:(id *)error;
- (id)fetchPrimaryActiveCloudKitAccountREMObjectIDWithError:(id *)error;
- (id)fetchPrimaryActiveCloudKitAccountWithError:(id *)error;
- (id)fetchAccountsWithObjectIDs:(id)ids error:(id *)error;
- (id)initWithStore:(id)store;
- (id)fetchAllAccountsForDumpingWithError:(id *)error;
- (id)fetchAllAccountsWithError:(id *)error;
- (id)accountsFromStorages:(id)storages;
- (id)fetchAllAccountsForAccountManagementWithError:(id *)error;

@end


@interface REMStoreInvocationValueStorage : NSObject <NSSecureCoding, NSCopying>

@property (retain, nonatomic) NSMutableDictionary *valueStorage;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (void)storeProperty:(id)property forKey:(id)key;
- (id)storedPropertyForKey:(id)key;

@end


@interface REMStoreInvocationResult : REMStoreInvocationValueStorage

@end


@interface REMAccountsDataViewInvocationREMObjectIDOnlyResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithAccountIDs:(id)ids;
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithStorages:(id)storages;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMStoreInvocation : REMStoreInvocationValueStorage

/* instance methods */
- (id)name;

@end


@interface REMAccountsDataViewInvocation_fetchActiveCloudKitAccountObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) long long fetchOption;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithFetchOption:(long long)option;
- (id)name;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountsDataViewInvocation_fetchAll : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) long long purpose;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)initWithPurpose:(long long)purpose;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountsDataViewInvocation_fetchByExternalIdentifier : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *externalIdentifiers;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithExternalIdentifiers:(id)identifiers;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountsDataViewInvocation_fetchByObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAccountsDataViewInvocation_fetchPrimaryActiveCloudKitAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) _Bool fetchREMObjectIDOnly;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)name;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithFetchREMObjectIDOnly:(_Bool)idonly;

@end


@interface REMAlarm : NSObject <REMObjectIDProviding, NSSecureCoding>

@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMAlarmTrigger *trigger;
@property (retain, nonatomic) NSDate *acknowledgedDate;
@property (retain, nonatomic) NSString *alarmUID;
@property (retain, nonatomic) NSString *originalAlarmUID;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (_Bool)isOriginal;
- (_Bool)isContentEqual:(id)equal;
- (id)initWithAlarm:(id)alarm objectID:(id)id;
- (id)initWithTrigger:(id)trigger;
- (id)initWithTrigger:(id)trigger objectID:(id)id;
- (_Bool)isAcknowledged;
- (_Bool)isSnooze;

@end


@interface REMAlarmTrigger : NSObject <REMObjectIDProviding, NSSecureCoding>

@property (retain, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) _Bool isTemporal;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)_deepCopy;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id;
- (_Bool)isContentEqual:(id)equal;
- (id)initWithAlarmTrigger:(id)trigger objectID:(id)id;

@end


@interface REMAlarmContactTrigger : REMAlarmTrigger <NSSecureCoding>

@property (readonly, nonatomic) REMContactRepresentation *contactRepresentation;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithContactRepresentation:(id)representation;
- (id)initWithObjectID:(id)id contactRepresentation:(id)representation;
- (_Bool)isTemporal;

@end


@interface REMAlarmDateTrigger : REMAlarmTrigger <NSSecureCoding>

@property (copy, nonatomic) NSDateComponents *dateComponents;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)initWithDateComponents:(id)components;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id dateComponents:(id)components;
- (_Bool)isTemporal;

@end


@interface REMAlarmDueDateDeltaAlertTrigger : REMAlarmTrigger <NSSecureCoding>

@property (readonly, nonatomic) REMDueDateDeltaInterval *dueDateDelta;
@property (readonly, nonatomic) NSDate *acknowledgedDate;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithDueDateDelta:(id)delta acknowledgedDate:(id)date;
- (id)initWithObjectID:(id)id dueDateDelta:(id)delta acknowledgedDate:(id)date;
- (_Bool)isTemporal;

@end


@interface REMAlarmLocationTrigger : REMAlarmTrigger <NSSecureCoding>

@property (copy, nonatomic) REMStructuredLocation *structuredLocation;
@property (nonatomic) long long proximity;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithStructuredLocation:(id)location proximity:(long long)proximity;
- (_Bool)isContentEqual:(id)equal;
- (id)initWithObjectID:(id)id structuredLocation:(id)location proximity:(long long)proximity;
- (_Bool)isTemporal;

@end


@interface REMAlarmTimeIntervalTrigger : REMAlarmTrigger <NSSecureCoding>

@property (nonatomic) double timeInterval;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithTimeInterval:(double)interval;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id timeInterval:(double)interval;
- (_Bool)isTemporal;

@end


@interface REMAlarmVehicleTrigger : REMAlarmTrigger

@property (nonatomic) long long event;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithEvent:(long long)event;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id event:(long long)event;
- (_Bool)isTemporal;

@end


@interface REMAppStoreDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchAppStoreCloudConfigurationPropertiesWithError:(id *)error;
- (id)fetchCreatedOrCompletedRemindersCountFromDate:(id)date toDate:(id)date error:(id *)error;

@end


@interface REMAppStoreDataViewConfigurationsInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) unsigned long long createdOrCompletedRemindersCountThreshold;
@property (readonly, nonatomic) unsigned long long numberOfForegroundsThreshold;
@property (readonly, nonatomic) double timeIntervalOfInterest;
@property (readonly, nonatomic) double timeIntervalSinceInitialForeground;
@property (readonly, nonatomic) double timeIntervalSinceLastPrompt;
@property (readonly, nonatomic) double timeIntervalSinceLastFetch;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithCreatedOrCompletedRemindersCountThreshold:(unsigned long long)threshold numberOfForegroundsThreshold:(unsigned long long)threshold timeIntervalOfInterest:(double)interest timeIntervalSinceInitialForeground:(double)foreground timeIntervalSinceLastPrompt:(double)prompt timeIntervalSinceLastFetch:(double)fetch;

@end


@interface REMAppStoreDataViewInvocation_fetchCreatedOrCompletedRemindersCount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSDate *fromDate;
@property (readonly, nonatomic) NSDate *toDate;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithFromDate:(id)date toDate:(id)date;

@end


@interface REMAppStoreDataViewInvocation_fetchICCloudConfigurationProperties : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAppleAccountUtilities : NSObject

@property (retain, nonatomic) ACAccountStore *accountStore;
@property (retain, nonatomic) NSMutableDictionary *unsafeUntilSystemReady_parentICloudACAccountIdentifierMap;
@property (nonatomic) _Bool cachedICloudACAccountsAreValid;
@property (retain, nonatomic) ACAccount *_debug_primaryICloudACAccount;
@property (retain, nonatomic) ACAccount *_debug_fullICloudACAccount;
@property (readonly) ACAccount *unsafeUntilSystemReady_primaryICloudACAccount;
@property (readonly) NSArray *unsafeUntilSystemReady_allICloudACAccounts;

/* class methods */
+ (id)sharedInstance;
+ (id)accountDescriptionWithACAccount:(id)acaccount;

/* instance methods */
- (void)accountStoreDidChange:(id)change;
- (void)performBlockInPersonaContextForAccountIdentifier:(id)identifier block:(id /* block */)block;
- (id)unsafeUntilSystemReady_icloudACAccountMatchingAccountIdentifier:(id)identifier;
- (id)currentPersonaUserPersonaUniqueString;
- (void)invalidateICloudACAccounts;
- (id)accessQueue;
- (void)_invalidateCachedICloudACAccounts;
- (id)initForObservingAccountStoreChanges:(_Bool)changes;
- (void)_updateCachedICloudACAccounts;
- (id)_cachedDisplayICloudACAccountWithIdentifier:(id)identifier;
- (void)_setNonPrimaryICloudACAccount:(id)acaccount;
- (id)init;
- (void)saveDidChooseToMigrate:(_Bool)migrate didFinishMigration:(_Bool)migration toACAccount:(id)acaccount inStore:(id)store completionHandler:(id /* block */)handler;
- (id)unsafeUntilSystemReady_allCloudKitRemindersEnabledICloudACAccounts;
- (void)_setPrimaryICloudACAccount:(id)acaccount;
- (void)dealloc;
- (id)unsafeUntilSystemReady_displayedHostnameOfICloudACAccountWithAccountIdentifier:(id)identifier;
- (_Bool)isCurrentPersonaDataSeparated;
- (id)unsafeUntilSystemReady_iCloudAccountCalDavServiceWithAccountID:(id)id;

@end


@interface REMAssignment : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableFetchableModel, REMDAChangedModelObjectResult, NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (copy, nonatomic) NSDate *assignedDate;
@property (nonatomic) _Bool _debug_cdAssigneeLinked;
@property (nonatomic) _Bool _debug_cdOriginatorLinked;
@property (readonly, nonatomic) long long status;
@property (readonly, nonatomic) REMObjectID *assigneeID;
@property (readonly, nonatomic) REMObjectID *originatorID;
@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (_Bool)supportsSecureCoding;
+ (id)nullifiedOriginatorAssignmentWithObjectID:(id)id accountID:(id)id reminderID:(id)id assigneeID:(id)id status:(long long)status assignedDate:(id)date;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (_Bool)isChangeTrackableFetchableModel;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (double)orderValueWithAssignedDate:(id)date objectIdentifier:(id)identifier;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id assigneeID:(id)id originatorID:(id)id status:(long long)status;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id assigneeID:(id)id originatorID:(id)id status:(long long)status assignedDate:(id)date;
- (_Bool)isEqualToAssignment:(id)assignment;
- (_Bool)isOriginatorNullified;
- (double)orderValue;

@end


@interface REMAssignmentsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSSet *assignments;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithAssignments:(id)assignments;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAssignmentsDataViewInvocation_fetchByObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;
@property (nonatomic) _Bool allowConcealedObjects;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMAttachment : NSObject <NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, nonatomic) NSString *uti;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)_deepCopy;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithAttachment:(id)attachment objectID:(id)id accountID:(id)id reminderID:(id)id;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id UTI:(id)uti;

@end


@interface REMAutoCategorizationActivity : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSDictionary *reminderIDsByListID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)activityByMergingWithActivity:(id)activity;
- (id)activityBySubtractingActivity:(id)activity;
- (id)initWithListID:(id)id reminderIDs:(id)ids;
- (id)initWithReminderIDsByListID:(id)id;
- (id)reminderIDsForListID:(id)id;

@end


@interface REMAuxiliaryChangeInfoFetchResult : NSObject

@property (nonatomic) Class typedKlass;
@property (retain, nonatomic) NSMutableDictionary *changeObjectForAuxiliaryChangeInfoMap;
@property (readonly, nonatomic) NSArray *auxiliaryChangeInfos;

/* class methods */
+ (id)auxiliaryChangeInfoFetchResultOfType:(Class)type;

/* instance methods */
- (id)auxiliaryChangeInfoFromData:(id)data withObjectID:(id)id fromChangeObject:(id)object error:(id *)error;
- (id)changeObjectForAuxiliaryChangeInfo:(id)info;
- (id)initWithAuxiliaryChangeInfoType:(Class)type;

@end


@interface REMAuxiliaryChangeInfoType : NSObject <REMAuxiliaryChangeInfoObject>

@property (retain, nonatomic) REMObjectID *remObjectID;
@property (retain, nonatomic) NSDictionary *storage;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)resolveInstanceMethod:(SEL)method;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (id)initWithREMObjectID:(id)id;

@end


@interface REMAuxiliaryReminderChangeDeleteInfo : REMAuxiliaryChangeInfoType <REMAuxiliaryReminderChangeInfo>

@property (readonly, nonatomic) NSString *reminderIdentifier;
@property (readonly, nonatomic) NSString *oldListIdentifier;
@property (readonly, nonatomic) NSString *oldExternalIdentifier;

/* class methods */
+ (id)cdEntityName;

@end


@interface REMAuxiliaryReminderChangeMoveInfo : REMAuxiliaryChangeInfoType <REMAuxiliaryReminderChangeInfo>

@property (readonly, nonatomic) NSString *reminderIdentifier;
@property (readonly, nonatomic) NSString *oldListIdentifier;
@property (readonly, nonatomic) NSString *oldExternalIdentifier;

/* class methods */
+ (id)cdEntityName;

@end


@interface REMBaseSection : NSObject <REMObjectIDProviding, REMSupportedVersionProviding>

@property (readonly, nonatomic) REMStore *store;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentID;
@property (copy, nonatomic) REMBaseSectionStorage *storage;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (_Bool)respondsToSelector:(SEL)selector;
- (id)description;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)forwardingTargetForSelector:(SEL)selector;
- (unsigned long long)hash;
- (id)initWithStore:(id)store accountCapabilities:(id)capabilities storage:(id)storage;

@end


@interface REMBaseSectionChangeItem : NSObject <REMSupportedVersionProviding, REMSupportedVersionUpdating, REMConflictResolving, REMSaveRequestTrackedValue>

@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (retain, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (retain, nonatomic) REMBaseSectionStorage *storage;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *parentID;
@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)keysToObserve;

/* instance methods */
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities observeInitialValues:(_Bool)values;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (id)shallowCopyWithSaveRequest:(id)request;

@end


@interface REMBaseSectionStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentID;
@property (copy, nonatomic) NSString *displayName;
@property (retain, nonatomic) NSDate *creationDate;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)storeGeneration;
- (id)debugDescription;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)description;
- (_Bool)isUnsupported;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id parentID:(id)id displayName:(id)name;

@end


@interface REMBundleLookupObject : NSObject

@end


@interface REMCRMergeableOrderedSet : NSObject <NSCopying, NSSecureCoding>

@property (retain, nonatomic) REMReplicaIDSource *replicaIDSource;
@property (retain, nonatomic) CRDocument *document;
@property (readonly, nonatomic) NSMutableArray *undos;
@property (readonly, nonatomic) NSOrderedSet *orderedSet;
@property (readonly, nonatomic) unsigned long long count;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)serializedData;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)objectAtIndex:(unsigned long long)index;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (unsigned long long)indexOfEqualObject:(id)object;
- (id)initWithReplicaIDSource:(id)idsource document:(id)document;
- (id)initWithReplicaIDSource:(id)idsource document:(id)document undos:(id)undos;
- (id)initWithReplicaIDSource:(id)idsource orderedSet:(id)set;
- (id)initWithReplicaIDSource:(id)idsource serializedData:(id)data error:(id *)error;
- (id)mergedOrderedSetWithOrderedSet:(id)set error:(id *)error;
- (id)mutableOrderedSet;

@end


@interface REMCRMergeableStringDocument : NSObject <REMTTHashtagHosting, NSCopying, NSSecureCoding>

@property (retain, nonatomic) REMReplicaIDSource *replicaIDSource;
@property (retain, nonatomic) TTMergeableStringVersionedDocument *document;
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) NSAttributedString *attributedString;
@property (readonly, nonatomic) TTMergeableAttributedString *mergeableString;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)documentFromSerializedData:(id)data replicaIDSource:(id)idsource forKey:(id)key ofObjectID:(id)id;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)serializedData;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)mutableDocument;
- (id)initWithReplicaIDSource:(id)idsource string:(id)string;
- (void)enumerateHashtagInRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (id)hashtagAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)initWithReplicaIDSource:(id)idsource attributedString:(id)string;
- (id)initWithReplicaIDSource:(id)idsource document:(id)document;
- (id)initWithReplicaIDSource:(id)idsource serializedData:(id)data error:(id *)error;
- (id)mergedWithDocument:(id)document error:(id *)error;

@end


@interface REMCRMutableAttributedString : NSMutableAttributedString

@property (retain, nonatomic) NSMutableAttributedString *backingStore;
@property (weak, nonatomic) id <REMCRMutableAttributedStringEditObserver> editObserver;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)allowedAttributesForModel;
+ (id)nonEditableAttributes;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)setAttributes:(id)attributes range:(struct _NSRange)range;
- (Class)classForCoder;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (id)attributesAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)description;
- (id)string;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithBackingStore:(id)store;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (void)reportDidEdit:(long long)edit range:(struct _NSRange)range changeInLength:(long long)length;

@end


@interface REMCRReminderIDList : NSObject <CRUndoDelegate, REMObjectIDProviding>

@property (readonly, nonatomic) NSUUID *replica;
@property (retain, nonatomic) CRDocument *document;
@property (retain, nonatomic) REMObjectID *remObjectID;
@property (weak, nonatomic) NSObject<REMCRReminderIDListDelegate> *delegate;
@property (readonly, nonatomic) NSMutableOrderedSet *reminderIDsProxy;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)listFromSerializedData:(id)data replica:(id)replica;

/* instance methods */
- (void)mergeWith:(id)with;
- (id)init;
- (void)addReminder:(id)reminder;
- (id)copyForReplica:(id)replica;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (id)_orderedSet;
- (unsigned long long)countOfReminderIDs;
- (unsigned long long)indexInReminderIDsOfObject:(id)object;
- (id)initWithDocument:(id)document objectID:(id)id;
- (void)insertObject:(id)object inReminderIDsAtIndex:(unsigned long long)index;
- (id)objectInReminderIDsAtIndex:(unsigned long long)index;
- (void)removeObjectFromReminderIDsAtIndex:(unsigned long long)index;
- (_Bool)wantsUndoCommands;

@end


@interface REMCRUndo : NSObject

@property (readonly, nonatomic) NSArray *undoBlocks;

/* instance methods */
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithUndoBlocks:(id)blocks;

@end


@interface REMCalDAVNotification : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableModel, REMExternalSyncMetadataWritableProviding, NSSecureCoding, NSCopying, REMObjectIDProviding, REMExternalSyncMetadataProviding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) NSString *uuidString;
@property (retain, nonatomic) NSURL *hostURL;
@property (readonly, nonatomic) REMObjectID *listID;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (_Bool)supportsSecureCoding;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)shouldUseExternalIdentifierAsDeletionKey;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initCalDAVNotificationWithObjectID:(id)id accountID:(id)id listID:(id)id uuidString:(id)string hostURL:(id)url externalIdentifier:(id)identifier externalModificationTag:(id)tag;

@end


@interface REMChangeObject : NSObject <NSCopying, NSSecureCoding, REMChangeCoalesceable>

@property (readonly, weak, nonatomic) REMChangeTransaction *transaction;
@property (readonly, nonatomic) long long changeID;
@property (readonly, nonatomic) REMObjectID *changedObjectID;
@property (readonly, nonatomic) long long changeType;
@property (readonly, nonatomic) REMChangeTombstone *tombstone;
@property (readonly, nonatomic) NSSet *updatedProperties;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)coalescedChanges;
- (id)copyForCoalescing;
- (_Bool)isCoalesced;

@end


@interface REMChangeSet : NSObject <NSCopying, NSSecureCoding>

@property (retain, nonatomic) NSError *error;
@property (nonatomic) _Bool isTruncated;
@property (retain, nonatomic) NSArray *inserts;
@property (retain, nonatomic) NSArray *updates;
@property (retain, nonatomic) NSArray *deletes;
@property (retain, nonatomic) NSArray *filterByTransactionAuthorStrings;
@property (nonatomic) _Bool filterByTransactionAuthorsIsExclusion;
@property (retain, nonatomic) NSArray *filteredTransactions;
@property (readonly, nonatomic) NSArray *transactions;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)errorChangeSetWithError:(id)error;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)applyFilterByTransactionAuthors:(id)authors isExclusion:(_Bool)exclusion;
- (_Bool)enumerateChanges:(long long)changes forModelsOfClass:(Class)_class withBlock:(id /* block */)block;
- (_Bool)_filterAndFlattenAndConsolidateChanges;
- (id)initWithError:(id)error;
- (id)description;
- (id)initWithChangeTransactions:(id)transactions;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (_Bool)consolidateAndFilterChangesWithTransactionAuthors:(id)authors isExclusion:(_Bool)exclusion;
- (id)lastChangeTokenForAccountID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMChangeToken : NSObject <NSCopying, NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)compareToken:(id)token error:(id *)error;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMChangeTombstone : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSUUID *objectIdentifier;
@property (readonly, nonatomic) NSUUID *remObjectIdentifier;
@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSNumber *daIsEventOnlyContainer;
@property (readonly, nonatomic) NSUUID *shareeOwningListIdentifier;
@property (readonly, nonatomic) NSString *shareeDisplayName;
@property (readonly, nonatomic) NSString *shareeAddress;
@property (readonly, nonatomic) NSUUID *assignmentOwningReminderIdentifier;
@property (readonly, nonatomic) NSString *hashtagName;
@property (readonly, nonatomic) NSUUID *hashtagReminderIdentifier;
@property (readonly, nonatomic) NSUUID *hashtagLabelUUIDForChangeTracking;
@property (readonly, nonatomic) NSUUID *syncActivityUUIDForChangeTracking;
@property (readonly, nonatomic) NSUUID *dueDateDeltaAlertReminderIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMChangeTracking : NSObject

@property (readonly, nonatomic) NSSet *transactionAuthorKeysToExclude;
@property (readonly, nonatomic) id <REMChangeTrackingClientIdentifying> changeTrackingClientID;
@property (readonly, nonatomic) id <REMDaemonController> daemonController;
@property (retain, nonatomic) NSArray *entityNames;
@property (nonatomic) unsigned long long transactionFetchLimit;

/* class methods */
+ (id)internalTransactionAuthorKeysToExclude;
+ (id)defaultTransactionAuthorKeysToExclude;
+ (id)lastTransactionTimestampWithManagedObjectContext:(id)context affectedStores:(id)stores;
+ (id)entityNamesToIncludeFromTrackingWithOptionProvider:(Class)provider;

/* instance methods */
- (id)currentChangeTokenForAccountTypes:(long long)types error:(id *)error;
- (id)currentChangeTokenWithError:(id *)error;
- (id)fetchHistoryAfterToken:(id)token error:(id *)error;
- (id)earliestChangeTokenWithError:(id *)error;
- (id)persistenceStoreIDForAccountID:(id)id error:(id *)error;
- (void)saveTrackingState:(id)state error:(id *)error;
- (id)initWithClientID:(id)id daemonController:(id)controller transactionAuthorKeysToExclude:(id)exclude;
- (id)initWithClientID:(id)id daemonController:(id)controller;
- (void)_performChangeTrackingWithReason:(id)reason block:(id /* block */)block xpcErrorHandler:(id /* block */)handler;
- (id)currentChangeTokenForAllAccountsWithError:(id *)error;
- (id)fetchHistoryAfterDate:(id)date error:(id *)error;
- (void)deleteHistoryBeforeDate:(id)date error:(id *)error;
- (id)fetchAuxiliaryChangeInfosOfType:(Class)type withChangeObject:(id)object error:(id *)error;
- (void)deleteHistoryBeforeToken:(id)token error:(id *)error;
- (id)getTrackingStateWithError:(id *)error;

@end


@interface REMChangeTrackingState : NSObject <NSCopying, NSSecureCoding>

@property (retain, nonatomic) NSDate *lastConsumedDate;
@property (retain, nonatomic) REMChangeToken *lastConsumedChangeToken;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMChangeTransaction : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSArray *changes;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *storeID;
@property (readonly, nonatomic) NSString *author;
@property (readonly, nonatomic) REMChangeToken *token;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMChangedKeysObserver : NSObject

@property (retain, nonatomic) NSArray *keysToObserve;
@property (retain, nonatomic) NSMutableSet *mutableChangedKeys;
@property (readonly, nonatomic) NSObject *target;
@property (readonly, nonatomic) NSSet *changedKeys;

/* instance methods */
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)initWithTarget:(id)target keysToObserve:(id)observe includeInitial:(_Bool)initial;
- (void)keyDidChange:(id)change;

@end


@interface REMClockElementList : NSObject

@property (copy, nonatomic) NSArray *elements;

/* class methods */
+ (long long)compareList:(id)list toList:(id)list;
+ (_Bool)list:(id)list isCompatibleToList:(id)list;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeIntoEntryArchive:(void *)archive;
- (id)initWithCRVectorTimestampElements:(id)elements;
- (id)initWithEntryArchive:(const void *)archive;
- (id)initWithTTVectorTimestampElements:(id)elements;

@end


@interface REMCloudContainer : NSObject

/* class methods */
+ (id)newCloudContainerWithPublicCloudDatabase;
+ (_Bool)isSandboxEnvironment;
+ (void)_writeLogCreatingCKContainerWithAccountIdentifier:(id)identifier personaIdentifier:(id)identifier;
+ (id)_newCloudContainerForAccountIdentifier:(id)identifier;
+ (id)newCloudContainerForAccountID:(id)id;
+ (id)newCloudContainerForAccount:(id)account;

@end


@interface REMColor : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSString *daSymbolicColorName;
@property (readonly, nonatomic) NSString *daHexString;
@property (readonly, nonatomic) NSString *ckSymbolicColorName;
@property (readonly, nonatomic) unsigned long long colorRGBSpace;
@property (readonly, nonatomic) double blue;
@property (readonly, nonatomic) double red;
@property (readonly, nonatomic) double green;
@property (readonly, nonatomic) double alpha;

/* class methods */
+ (id)lightGrayColor;
+ (id)whiteColor;
+ (id)cyanColor;
+ (_Bool)supportsSecureCoding;
+ (id)blackColor;
+ (id)yellowColor;
+ (id)orangeColor;
+ (id)blueColor;
+ (id)colorWithHexString:(id)string;
+ (id)grayColor;
+ (id)magentaColor;
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
+ (id)purpleColor;
+ (id)brownColor;
+ (id)clearColor;
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha targetRGBSpace:(unsigned long long)rgbspace;
+ (id)greenColor;
+ (id)redColor;
+ (id)colorWithDictionaryData:(id)data error:(id *)error;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha colorSpace:(unsigned long long)space;
- (id)archivedDictionaryDataWithError:(id *)error;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha colorSpace:(unsigned long long)space daSymbolicColorName:(id)name daHexString:(id)string ckSymbolicColorName:(id)name;
- (id)hexStringWithAlpha;
- (id)description;
- (id)initWithWhite:(double)white alpha:(double)alpha;
- (id)hexString;
- (id)initWithCKSymbolicColorName:(id)name hexString:(id)string;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithDASymbolicColorName:(id)name daHexString:(id)string ckSymbolicColorName:(id)name;
- (id)initWithHexString:(id)string;
- (unsigned long long)hash;
- (id)initWithDASymbolicColorName:(id)name daHexString:(id)string;
- (id)initWithCoder:(id)coder;

@end


@interface REMContactRepresentation : NSObject <NSSecureCoding>

@property (copy, nonatomic) NSArray *phones;
@property (copy, nonatomic) NSArray *emails;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)representationFromData:(id)data;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)archivedData;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithPhones:(id)phones emails:(id)emails;
- (_Bool)matchesContactRepresentation:(id)representation;

@end


@interface REMDAAssignmentTombstone : NSObject <REMDAChangedIdentifierResult>

@property (retain, nonatomic) NSUUID *objectIdentifier;
@property (retain, nonatomic) NSUUID *owningReminderIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */

@end


@interface REMDAChangeTrackingHelper : NSObject

@property (retain, nonatomic) REMChangeSet *changeSet;
@property (retain, nonatomic) REMChangeToken *sinceToken;
@property (retain, nonatomic) REMChangeToken *upToToken;
@property (retain, nonatomic) REMStore *remStore;
@property (retain, nonatomic) REMChangeTracking *changeTracking;
@property (retain, nonatomic) REMObjectID *cached_remAccountObjectID;
@property (retain, nonatomic) NSMutableDictionary *cached_insertedModelObjectResultsByModelClassName;
@property (retain, nonatomic) NSMutableDictionary *cached_updatedModelObjectResultsByModelClassName;
@property (retain, nonatomic) REMChangeToken *cached_currentChangeToken;
@property (retain, nonatomic) REMChangeTrackingState *cached_currentTrackingState;
@property (retain, nonatomic) REMChangeSet *_debug_mockChangeSet;
@property (retain, nonatomic) NSArray *entityNames;
@property (retain, nonatomic) NSString *clientName;
@property (readonly, nonatomic) id <REMDAAccountProviding> account;

/* class methods */
+ (_Bool)shouldIgnoreChangeOfModelClassProperties:(Class)properties withChangeObject:(id)object;

/* instance methods */
- (id)_fetchModelObjectsOfClass:(Class)_class withObjectIDs:(id)ids;
- (id)currentChangeTokenWithError:(id *)error;
- (id)_changedModelObjectsOfClass:(Class)_class ofChangeTypes:(long long)types shouldOutputFetchedModels:(_Bool)models;
- (id)initWithREMDAAccount:(id)remdaaccount clientName:(id)name withREMStore:(id)remstore;
- (id)_cachedModeObjectResultsForModelClass:(Class)_class changeType:(long long)type;
- (id)_debug_currentChangeTokenWithError:(id *)error;
- (id)fetchChangesSinceLastConsumed;
- (void)_handleIsConcealedUpdatesInChange:(id)change ofModelClass:(Class)_class forClientID:(id)id concealedHandler:(id /* block */)handler unconcealedHandler:(id /* block */)handler;
- (long long)_changeTypeMaskFromChangeType:(long long)type;
- (void)_setCachedModeObjectResults:(id)results forModelClass:(Class)_class changeType:(long long)type;
- (void)clearCachedModelObjectResultsForModelClass:(Class)_class;
- (id)initWithREMDAAccount:(id)remdaaccount clientName:(id)name withREMStore:(id)remstore entityNames:(id)names;
- (id)_rem_accountObjectID;
- (_Bool)compareCurrentChangeTokenToLastConsumedWithResult:(long long *)result error:(id *)error;
- (id)changedModelObjectsOfModelClass:(Class)_class ofChangeType:(long long)type;
- (id)fetchAndInitializeChangeTrackingStateIfNeeded;
- (void)markChangesConsumed;
- (id)_rem_changeTracking:(id)tracking;
- (id)changedIdentifiersOfModelClass:(Class)_class ofChangeType:(long long)type;
- (void)_debug_resetCaches;
- (void)markChangesConsumed:(_Bool)consumed;
- (id)_fetchModelObjectOfClass:(Class)_class withObjectID:(id)id includeConcealedObjects:(_Bool)objects;
- (void)_debug_setMockChangeSet:(id)set;

@end


@interface REMDAHashtagTombstone : NSObject <REMDAChangedIdentifierResult>

@property (retain, nonatomic) NSUUID *objectIdentifier;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSUUID *reminderIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */

@end


@interface REMDAShareeTombstone : NSObject <REMDAChangedIdentifierResult>

@property (retain, nonatomic) NSUUID *objectIdentifier;
@property (retain, nonatomic) NSUUID *owningListIdentifier;
@property (retain, nonatomic) NSString *displayName;
@property (retain, nonatomic) NSString *address;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */

@end


@interface REMUserDefaults : NSObject

@property (readonly, nonatomic) NSString *suiteName;
@property (readonly, nonatomic) NSMutableDictionary *observers;
@property (nonatomic) _Bool showRemindersAsOverdue_cached;
@property (readonly, nonatomic) NSUserDefaults *userDefaults;

/* class methods */
+ (id)daemonUserDefaults;
+ (id)appGroupUserDefaults;

/* instance methods */
- (id)_addObserverForKey:(id)key block:(id /* block */)block;
- (id)_startObservingValuesForKey:(id)key block:(id /* block */)block;
- (id)_startStreamingValuesForKey:(id)key block:(id /* block */)block;
- (void)_removeObserver:(id)observer;
- (id)initWithSuiteName:(id)name containerURL:(id)url;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;

@end


@interface REMDaemonUserDefaults : REMUserDefaults

@property (readonly, nonatomic) _Bool newAppShouldTakeoverEKReminderNotifications;
@property (readonly, nonatomic) _Bool dataaccessDaemonStopSyncingReminders;
@property (readonly, nonatomic) _Bool siriShouldRouteIntentsToNewRemindersApp;
@property (nonatomic) _Bool databaseMigrationTestModeEnabled;
@property (nonatomic) _Bool isDatabaseMigrated;
@property (nonatomic) _Bool databaseMigrationTimedOut;
@property (copy, nonatomic) NSString *lastDatabaseMigrationSystemBuildVersion;
@property (retain, nonatomic) NSNumber *cloudKitMigrationMaxNumInvocations;
@property (retain, nonatomic) NSNumber *cloudKitMigrationMaxNumFailures;
@property (retain, nonatomic) NSNumber *cloudKitMigrationDelayAfterError;
@property (retain, nonatomic) NSNumber *cloudKitMigrationObserverPollingInterval;
@property (retain, nonatomic) NSNumber *cloudKitMigrationSimulatedError;
@property (retain, nonatomic) NSNumber *cloudKitResultsLimitPerSyncOperation;
@property (nonatomic) _Bool cloudKitMigrationDisableCleanUp;
@property (retain, nonatomic) NSString *acAccountIdentifierToMergeLocalDataIntoSyncData;
@property (retain, nonatomic) NSArray *acAccountIdentifiersToMigrateInactivatedCalDavData;
@property (retain, nonatomic) NSDate *cloudKitMergeLocalLastDateMaxRetryReached;
@property (retain, nonatomic) NSString *cloudKitMergeLocalLastBuildVersionMaxRetryReached;
@property (retain, nonatomic) NSDate *cloudKitSchemaCatchUpSyncLastSuccessDate;
@property (retain, nonatomic) NSString *cloudKitSchemaCatchUpSyncLastSuccessBuildVersion;
@property (retain, nonatomic) NSNumber *cloudKitSchemaCatchUpSyncSchedulingState;
@property (retain, nonatomic) NSDate *cloudKitSchemaCatchUpSyncLastScheduledDate;
@property (nonatomic) _Bool debugForceSupportCloudKitSchemaCatchUpSyncBackgroundScheduling;
@property (retain, nonatomic) NSNumber *cloudKitMaxNumAlarmIDsInReminderCKRecordDebugOverride;
@property (retain, nonatomic) NSNumber *debugSimulatedCKErrorCode;
@property (copy, nonatomic) NSNumber *spotlightIndexVersion;
@property (copy, nonatomic) NSDate *nextScheduledAlarmDate;
@property (copy, nonatomic) NSDate *lastPresentAlarmDate;
@property (nonatomic) _Bool timeZoneOverrideEnabled;
@property (copy, nonatomic) NSString *timeZoneOverride;
@property (copy, nonatomic) NSData *lastSuggestedAttributesAutoTrainingToken;
@property (copy, nonatomic) NSDate *lastSuggestedAttributesAutoTrainingExecutionDate;
@property (copy, nonatomic) NSDate *lastSyncPoll;
@property (copy, nonatomic) NSDate *lastCloudConfigurationDownload;
@property (copy, nonatomic) NSDate *staledFileAttachmentCleanupLastExecutionDate;
@property (nonatomic) _Bool staledFileAttachmentCleanupContainerDeemedClean;
@property (nonatomic) _Bool extraneousAlarmsCollectorContainerDeemedClean;
@property (copy, nonatomic) NSDate *lastExtraneousAlarmsCollectorExecutionDate;
@property (copy, nonatomic) NSDate *imageDeduplicationLastExecutionDate;
@property (copy, nonatomic) NSArray *imageDeduplicationLegacyAttachmentsMarkedForDeletion;
@property (copy, nonatomic) NSDate *savedImageDeduplicationLastExecutionDate;
@property (copy, nonatomic) NSArray *savedImageDeduplicationLegacyAttachmentsMarkedForDeletion;
@property (copy, nonatomic) NSDate *suggestConversionToGroceryListLastExecutionDate;
@property (copy, nonatomic) NSDate *analyticsActivityLastExecutionDate;
@property (copy, nonatomic) NSDate *batchDeleteExpiredRemindersLastExecutionDate;
@property (copy, nonatomic) NSData *userInteractionsData;
@property (nonatomic) _Bool simulateMAIDAccount;
@property (nonatomic) _Bool showRemindersAsOverdue;
@property (nonatomic) _Bool treatRemindersAsNotOverdue;
@property (nonatomic) _Bool enableWelcomeScreen;
@property (nonatomic) _Bool forceShowWelcomeScreen;
@property (nonatomic) _Bool forceShowWhatsNewScreen;
@property (nonatomic) _Bool forceShowAppStoreRatingPrompt;
@property (nonatomic) _Bool resetShowSuggestGroceries;
@property (nonatomic) _Bool enableInAppDebugMenu;
@property (readonly, nonatomic) _Bool enableAutoGenerateCKPersonIDSalt;
@property (nonatomic) _Bool enableHashingUserIdentifiablesWithPersonIDSalt;
@property (retain, nonatomic) REMObjectID *preferredDefaultListID;
@property (retain, nonatomic) NSURL *preferredDefaultListObjectIDUrl;
@property (copy, nonatomic) NSArray *preferredLocalizations;
@property (retain, nonatomic) NSDateComponents *todayNotificationFireTime;
@property (nonatomic) _Bool disableAlarmEngineDataSourcePrefetching;
@property (nonatomic) _Bool enableAssignmentNotifications;
@property (nonatomic) _Bool enableAutoCompleteReminders;
@property (nonatomic) _Bool showUrgentRemindersCompleteButton;
@property (copy, nonatomic) NSDictionary *suggestedAttributesTrainingOverrides;
@property (copy, nonatomic) NSDictionary *suggestedAttributesHarvestingOverrides;
@property (copy, nonatomic) NSDictionary *muteNotificationForSharedList;
@property (copy, nonatomic) NSDictionary *hideEmptySectionsForGroceryList;
@property (copy, nonatomic) NSData *accountsListCategorizedCountsCache;
@property (copy, nonatomic) NSData *hashtagLabelsInCustomSmartListFilterCache;
@property (nonatomic) _Bool debugSimulateSqliteFull;
@property (retain, nonatomic) NSNumber *tipKitCachedCountOfUncompletedReminders;
@property (retain, nonatomic) NSNumber *tipKitCachedCountOfLists;
@property (retain, nonatomic) NSNumber *tipKitCachedCountOfListsWithCustomBadge;
@property (retain, nonatomic) NSNumber *tipKitCachedCountOfCustomSmartLists;
@property (retain, nonatomic) NSNumber *tipKitCachedCountOfHashtags;
@property (copy, nonatomic) NSDate *lastViewedNotificationsPermissionWarmingSheetDate;
@property (copy, nonatomic) NSDate *lastDismissedNotificationsPermissionInlineRequestDate;
@property (nonatomic) _Bool groceryTipDismissed;
@property (nonatomic) _Bool hasCreatedGroceryList;
@property (nonatomic) _Bool hasViewedContactsAccessAlertForLocation;
@property (nonatomic) _Bool hasViewedContactsAccessAlertForMessaging;
@property (nonatomic) _Bool hasViewedContactsAccessAlertForCalDAVSharing;
@property (nonatomic) _Bool didShowReminderDeletePrivacyWarning;
@property (nonatomic) _Bool hasSeenGroceryFeedbackSurvey;
@property (nonatomic) _Bool enableGroceryFeedbackSurvey;
@property (retain, nonatomic) NSNumber *remCurrentRuntimeVersionDebuggingOverride;
@property (nonatomic) _Bool forceEligibleForAutoCloudKitMigration;
@property (nonatomic) _Bool forceBasicAAAccountEligibleForCloudKitReminders;
@property (retain, nonatomic) NSDictionary *dataSeparationAppDocumentsURLDebugOverride;
@property (copy, nonatomic) NSDate *lastDataSeparationMigrationDate;
@property (copy, nonatomic) NSDictionary *syncActivityNotificationEngine_accountSignInTime;
@property (nonatomic) _Bool sharedListActivityNotifications_demoMode;
@property (nonatomic) _Bool shouldIncludeRemindersDueTodayInBadgeCount;
@property (nonatomic) _Bool isSpotlightQueryLoggingEnabled;
@property (nonatomic) _Bool excludeExistingSectionsForAutoCategorizationEnabled;
@property (copy, nonatomic) NSString *trialAssetsDirectoryDebugOverride;
@property (copy, nonatomic) NSDate *automaticSecondaryGroceryLocalesLastModifiedDate;
@property (copy, nonatomic) NSArray *automaticSecondaryGroceryLocales;
@property (copy, nonatomic) NSDate *lastViewedUrgentAlarmMeDevicePermissionWarmingSheetDate;
@property (copy, nonatomic) NSDate *lastViewedUrgentAlarmNonMeDevicePermissionWarmingSheetDate;

/* class methods */
+ (id)defaultValues;
+ (id)todayNotificationFireTimeFromStorageNumber:(id)number;
+ (id)storageNumberForTodayNotificationTime:(id)time;

/* instance methods */
- (id)initWithSuiteName:(id)name containerURL:(id)url;
- (id)observeTodayNotificationFireTimeWithBlock:(id /* block */)block;
- (_Bool)hideEmptySectionsForGroceryList:(id)list;
- (id)observeShowRemindersAsOverdueWithBlock:(id /* block */)block;
- (void)ppt_handleRestore;
- (id)streamTodayNotificationFireTime:(id /* block */)time;
- (id)observePreferredDefaultListIDWithBlock:(id /* block */)block;
- (unsigned long long)muteNotificationOptionsForSharedList:(id)list;
- (void)deletePreferredDefaultListID;
- (id)observeTimeZoneOverrideEnabledWithBlock:(id /* block */)block;
- (void)deletePreferredDefaultListObjectIDUrl;
- (void)ppt_handleInstall;
- (void)setMuteNotificationOptions:(unsigned long long)options forSharedList:(id)list;
- (id)_pptPreferredDefaultListIDKey;
- (void)setCoreBehaviorTrainingParameters:(id)parameters;
- (id)observeTimeZoneOverrideWithBlock:(id /* block */)block;
- (id)observeShowUrgentRemindersCompleteButtonWithBlock:(id /* block */)block;
- (id)observeShouldIncludeRemindersDueTodayInBadgeCountWithBlock:(id /* block */)block;
- (_Bool)showRemindersAsOverdueWithShouldBypassCache:(_Bool)cache;
- (id)observeEnableAssignmentNotificationsWithBlock:(id /* block */)block;
- (id)streamShouldIncludeRemindersDueTodayInBadgeCount:(id /* block */)count;
- (id)observeEnableAutoCompleteRemindersWithBlock:(id /* block */)block;
- (void)removeHideEmptySectionsForGroceryList:(id)list;
- (id)observeTreatRemindersAsNotOverdueWithBlock:(id /* block */)block;
- (void)setBestKForKNN:(id)knn;
- (void)removeMuteNotificationOptionsForSharedList:(id)list;
- (void)setHideEmptySections:(_Bool)sections forGroceryList:(id)list;

@end


@interface REMDataAccessBehaviorManager : NSObject

@property (retain, nonatomic) REMXPCDaemonController *daemonController;

/* instance methods */
- (id)_debugPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (_Bool)isBabySitterEnabled;
- (void)_setBoolValue:(_Bool)value forBehaviorKey:(id)key;
- (void)enableBabySitter;
- (id)initWithDaemonController:(id)controller;
- (void)disableDataAccess;
- (long long)_getIntegerForKey:(id)key withDefaultValue:(long long)value;
- (void)_setIntegerValue:(long long)value forBehaviorKey:(id)key;
- (void)enableDataAccess;
- (id)init;
- (long long)changeTrackingBehaviors;
- (_Bool)_getBoolForKey:(id)key withDefaultValue:(_Bool)value;
- (id)fetchStatusReportsWithError:(id *)error;
- (void)unapplyChangeTrackingBehavior:(long long)behavior;
- (_Bool)isDataAccessEnabled;
- (void)applyChangeTrackingBehavior:(long long)behavior;
- (void)_crashDaemonWithMessage:(id)message;
- (void)disableBabySitter;

@end


@interface REMDatabaseMigrationAccountInfo : NSObject

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) long long type;

/* instance methods */
- (_Bool)isCloudKit;
- (id)initWithAccountType:(long long)type identifier:(id)identifier name:(id)name;

@end


@interface REMDatabaseMigrationContext : NSObject

@property (nonatomic) _Bool isDatabaseMigrated;
@property (retain, nonatomic) REMStoreContainerToken *containerToken;
@property (retain, nonatomic) REMStore *cachedStore;
@property (retain, nonatomic) NSDate *migrationStartDate;
@property (nonatomic) _Bool hasPerformedEnsureAccountsExist;
@property (retain, nonatomic) NSString *lastReportedErrorIdentifier;
@property (nonatomic) unsigned long long lastReportedErrorStage;
@property (retain, nonatomic) NSError *lastReportedError;
@property (readonly, nonatomic) _Bool shouldDeleteMigratedData;

/* instance methods */
- (id)remStore;
- (void)reportMigrationWillBegin;
- (void)reportMigrationErrorWithIdentifier:(id)identifier atStage:(unsigned long long)stage error:(id)error objectLocator:(id)locator;
- (_Bool)ensureAccountsExist:(id *)exist;
- (void)reportMigrationDidFinishWithSuccess:(_Bool)success;
- (id)init;
- (_Bool)ensureAccountsExistWithMigrationAccountInfos:(id)infos error:(id *)error;
- (void)destroySandboxContainerIfNecessary;
- (void)dealloc;
- (_Bool)_cleanLocalDatabases:(id *)databases;
- (void)_diagnosticReportWithStage:(unsigned long long)stage failureIdentifier:(id)identifier error:(id)error;
- (id)_migrationAccountInfosFromDEPRECATEDInfoDictionaryList:(id)list;
- (_Bool)ensureAccountsExist:(id)exist error:(id *)error;
- (void)setShouldDataAccessStopSyncingReminders:(_Bool)reminders;
- (void)_postMigrationLocalAccountCleanup;
- (id)initWithSandboxDatabaseEnabled:(_Bool)enabled;

@end


@interface REMDispatchQueue : NSObject

/* class methods */
+ (id)storeQueue;

@end


@interface REMDisplayDate : NSObject <NSCopying, NSSecureCoding>

@property (readonly, copy, nonatomic) NSDate *date;
@property (readonly, nonatomic) _Bool allDay;
@property (readonly, nonatomic) NSTimeZone *timeZone;
@property (readonly, nonatomic) long long floatingDateSecondsFromGMT;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)isAllDay;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)dateByAdjustingFloatingDateForDefaultTimeZone;
- (id)dateByAdjustingFloatingDateForTimeZone:(id)zone;
- (id)dateComponentsRepresentation;
- (id)initWithDate:(id)date allDay:(_Bool)day timeZone:(id)zone floatingDateSecondsFromGMT:(long long)gmt;
- (id)initWithDueDateComponents:(id)components alarms:(id)alarms;
- (id)initWithFloatingDateComponents:(id)components nonFloatingDateComponents:(id)components;

@end


@interface REMDisplayDateUtils : NSObject

@property (nonatomic) _Bool isCacheSet;
@property (nonatomic) _Bool hasAlarmDateComponents;
@property (retain, nonatomic) NSDateComponents *dueDateComponents;
@property (retain, nonatomic) NSDateComponents *floatingDateComponents;
@property (retain, nonatomic) NSDateComponents *nonFloatingDateComponents;
@property (weak, nonatomic) id <REMDisplayDateUtilsDelegate> delegete;

/* class methods */
+ (id)_displayDateWithDueDateComponents:(id)components alarms:(id)alarms hasAlarmDateComponents:(_Bool)components floatingDateComponents:(id)components nonFloatingDateComponents:(id)components displayDateUtils:(id)utils;
+ (id)displayDateWithDueDateComponents:(id)components alarms:(id)alarms;

/* instance methods */
- (id)displayDateWithDueDateComponents:(id)components alarms:(id)alarms;
- (id)updateDisplayDateWithDueDateComponents:(id)components alarm:(id)alarm alarmsProviding:(id)providing;

@end


@interface REMDisplayNameUtils : NSObject

/* class methods */
+ (id)displayNameFromListName:(id)name isPlaceholder:(_Bool)placeholder;
+ (id)displayNameFromAccountName:(id)name;

@end


@interface REMDistributedEvaluationCollectionOptions : NSObject <NSSecureCoding>

@property (nonatomic) _Bool includeListNames;
@property (nonatomic) _Bool includeReminderTitles;
@property (nonatomic) _Bool includeListNameFuzzedEmbeddings;
@property (nonatomic) _Bool includeReminderTitleFuzzedEmbeddings;
@property (nonatomic) _Bool includeSystemLanguage;
@property (nonatomic) _Bool includeSystemTimezone;
@property (nonatomic) _Bool includeAccountType;
@property (nonatomic) _Bool includeListGroupInfo;
@property (nonatomic) _Bool includeReminderTitleSaltedHash;
@property (nonatomic) _Bool includeDates;
@property (nonatomic) _Bool includeDayOfWeek;
@property (nonatomic) _Bool includeRecurrenceInfo;
@property (nonatomic) _Bool includeLocationInfo;
@property (nonatomic) _Bool includeAttachmentUTIs;
@property (nonatomic) _Bool includeRemindMeWhenMessagingInfo;
@property (nonatomic) _Bool includeAlarmDates;
@property (nonatomic) _Bool includeSubtaskInfo;
@property (nonatomic) _Bool includeUserActivityInfo;
@property (nonatomic) _Bool includeIsFlagged;
@property (nonatomic) _Bool includePriority;
@property (nonatomic) _Bool relevantWordTagsIncludeOtherWord;
@property (nonatomic) _Bool includeReminderTitleCategoryFilteredStopWords;
@property (nonatomic) _Bool includeReminderTitleCategoryUniversalGrammar;
@property (nonatomic) _Bool includeReminderTitleCategorySentence2Vec;
@property (nonatomic) double reminderTitleCategoryDistanceTolerance;
@property (retain, nonatomic) NSURL *reminderTitleCategoryEmbeddingURL;
@property (nonatomic) unsigned long long dateResolutionInSeconds;
@property (nonatomic) unsigned long long creationDateWithinDays;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)_attachmentURLFromFilenameWithKey:(id)key inJSONRepresentation:(id)jsonrepresentation attachmentURLs:(id)urls error:(id *)error;
+ (id)optionsFromJSONRepresentation:(id)jsonrepresentation attachmentURLs:(id)urls error:(id *)error;
+ (id)optionsWithDefaultValues;
+ (id)optionsWithEverythingOff;

/* instance methods */
- (id)description;
- (id)_init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMDueDateDeltaAlert : NSObject <NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly, nonatomic) NSUUID *identifier;
@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMDueDateDeltaInterval *dueDateDelta;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) NSDate *acknowledgedDate;
@property (readonly, nonatomic) long long minimumSupportedAppVersion;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (_Bool)isContentEqual:(id)equal;
- (id)initWithIdentifier:(id)identifier reminderID:(id)id accountID:(id)id dueDateDelta:(id)delta creationDate:(id)date acknowledgedDate:(id)date minimumSupportedAppVersion:(long long)version;

@end


@interface REMDueDateDeltaAlertChangeItem : NSObject

@property (retain, nonatomic) REMReminderDueDateDeltaAlertContextChangeItem *reminderDueDateDeltaAlertContextChangeItem;
@property (retain, nonatomic) REMDueDateDeltaAlert *dueDateDeltaAlert;

/* instance methods */
- (id)setAcknowledgedDate:(id)date;
- (id)_setMinimumSupportedAppVersion:(long long)version;
- (id)initWithReminderDueDateDeltaAlertContextChangeItem:(id)item dueDateDeltaAlert:(id)alert;
- (id)setDueDateDelta:(id)delta;

@end


@interface REMDueDateDeltaInterval : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long unit;
@property (readonly, nonatomic) long long count;
@property (readonly, nonatomic) _Bool isEmpty;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)inverted;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)addedTo:(id)to;
- (id)initWithUnit:(long long)unit count:(long long)count;
- (id)initWithUnitInteger:(long long)integer count:(long long)count;

@end


@interface REMEnableObjectiveCpp : NSObject

@end


@interface REMError : NSObject

/* class methods */
+ (id)validationErrorRemoveAccountBeingActivated:(id)activated;
+ (id)validationErrorRemoveAccountBeingInserted:(id)inserted;
+ (id)noSuchUserDefinedSectionForReminderWithObjectID:(id)id;
+ (_Bool)catchObjCException:(id /* block */)cexception error:(id *)error;
+ (id)throttledErrorWithRemainingTimeInterval:(double)interval;
+ (id)invalidParameterErrorWithDescription:(id)description;
+ (_Bool)_isCoreDataError:(id)error;
+ (_Bool)isNoSuchObjectError:(id)error forObjectID:(id)id;
+ (id)constraintConflictWithIdentifier:(id)identifier constraint:(id)constraint;
+ (id)validationErrorUndeleteHashtagFromAnotherReminder:(id)reminder expectedReminderID:(id)id;
+ (id)unexpectedNilPropertyWithClass:(Class)_class property:(id)property;
+ (id)_errorWithCode:(long long)code userInfo:(id)info error:(id)error path:(id)path URL:(id)url description:(id)description;
+ (id)noSuchObjectErrorWithObjectID:(id)id;
+ (id)_errorSanitizedForXPCFromError:(id)error;
+ (id)validationErrorListHasNoAccount:(id)account;
+ (id)validationErrorMoveReminderFromList:(id)list toList:(id)list inAccount:(id)account;
+ (id)tooManyLoadedStoresError;
+ (id)unexpectedNilPropertyWithObjectID:(id)id property:(id)property;
+ (id)errorFromErrors:(id)errors;
+ (id)babySatErrorWithOperationName:(id)name;
+ (id)noMatchFoundErrorWithDebugDescription:(id)description;
+ (id)errorSanitizedForXPCFromError:(id)error;
+ (id)notSupportedErrorWithDebugDescription:(id)description;
+ (id)mismatchedObjectIDWithObjectID:(id)id expected:(Class)expected;
+ (id)nullifiedRelationshipErrorWithRelationshipName:(id)name;
+ (id)accountStoreMissingError:(id)error;
+ (id)_errorWithCode:(long long)code underlyingError:(id)error;
+ (id)noPrimaryActiveCloudKitAccountError;
+ (id)sqliteErrorWithCode:(long long)code format:(id)format;
+ (id)internetNotReachableError;
+ (id)validationErrorSubtaskAndParentNotOnSameList:(id)list parentReminderID:(id)id;
+ (id)internalErrorWithDebugDescription:(id)description;
+ (id)validationErrorDifferentZoneObjectID:(id)id zoneOwnerName:(id)name parentObjectID:(id)id parentZoneOwnerName:(id)name;
+ (id)sqliteErrorWithCode:(long long)code path:(id)path format:(id)format;
+ (id)notSupportedError;
+ (id)cancelledError;
+ (id)validationErrorMoveAcrossAccount:(id)account;
+ (id)unauthorizedErrorWithMissingEntitlement:(id)entitlement;
+ (id)unauthorizedErrorWithMissingEntitlement:(id)entitlement requestedAccessLevel:(id)level currentAccesslevel:(id)accesslevel;
+ (id)retryLaterErrorWithInterval:(double)interval;
+ (id)validationErrorNotCloudKitAccount:(id)account;
+ (id)saveErrorWithCoreDataError:(id)error;
+ (id)noSuchObjectErrorWithDACalendarItemUniqueIdentifier:(id)identifier;
+ (id)noSuchSmartListErrorWithSmartListType:(id)type;
+ (id)xpcPerformerUnavailableErrorWithDescription:(id)description;
+ (id)validationErrorNestedSubtask:(id)subtask parentReminderID:(id)id;
+ (id)validationErrorMoveFromAccount:(id)account toAccount:(id)account objectID:(id)id;
+ (id)unexpectedError;
+ (id)noSuchObjectErrorWithExternalIdentifier:(id)identifier;

@end


@interface REMEventKitBridgingDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchListsWithError:(id *)error;
- (id)fetchCompletedRemindersWithCompletionDateFrom:(id)from to:(id)to withListIDs:(id)ids error:(id *)error;
- (id)fetchIncompleteRemindersWithDueDateFrom:(id)from to:(id)to withListIDs:(id)ids error:(id *)error;
- (id)fetchRemindersWithListIDs:(id)ids error:(id *)error;

@end


@interface REMEventKitBridgingDataViewInvocation_fetchCompletedRemindersWithCompletionDate : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *listIDs;
@property (readonly, nonatomic) NSDate *startDate;
@property (readonly, nonatomic) NSDate *endDate;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListIDs:(id)ids startDate:(id)date endDate:(id)date;

@end


@interface REMEventKitBridgingDataViewInvocation_fetchIncompleteRemindersWithDueDate : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *listIDs;
@property (readonly, nonatomic) NSDate *startDate;
@property (readonly, nonatomic) NSDate *endDate;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListIDs:(id)ids startDate:(id)date endDate:(id)date;

@end


@interface REMEventKitBridgingDataViewInvocation_fetchLists : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMEventKitBridgingDataViewInvocation_fetchReminders : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *listIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListIDs:(id)ids;

@end


@interface REMExporting : NSObject

/* class methods */
+ (id)exportICSCalendarFromReminders:(id)reminders;
+ (id)_icsCalendarItemsFromReminders:(id)reminders exportingOption:(long long)option;
+ (_Bool)_updateICSComponentWithReminder:(id)reminder icsCalendarItem:(id)item;
+ (id)exportICSCalendarFromReminders:(id)reminders exportingOption:(long long)option;
+ (id)icsTodoFromReminder:(id)reminder;
+ (id)icsTodoFromReminder:(id)reminder exportingOption:(long long)option;

@end


@interface REMExternalSyncMetadataUtils : NSObject

/* class methods */
+ (id)decodeExternalIdentifierForMarkedForDeletionObject:(id)object;
+ (id)encodeExternalIdentifierForMarkedForDeletionObject:(id)object;
+ (_Bool)shouldUseExternalIdentifierAsDeletionKeyWithAccountType:(long long)type;

@end


@interface REMFamilyChecklistDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchFamilyGroceryListEligibilityForFamilyChecklistWithLocale:(id)locale error:(id *)error;
- (id)fetchSharedGroceryListsWithCommonSharees:(id)sharees error:(id *)error;

@end


@interface REMFamilyChecklistDataViewInvocation_fetchFamilyGroceryListEligibility : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSString *localeIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithLocaleIdentifier:(id)identifier;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMFamilyChecklistDataViewInvocation_fetchSharedGroceryLists : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *commonSharees;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithCommonSharees:(id)sharees;

@end


@interface REMFamilyChecklistFamilyGroceryListEligibility : NSObject <NSSecureCoding>

@property (readonly, nonatomic) _Bool isEligible;
@property (readonly, nonatomic) long long ineligibilityReasons;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithIsEligible:(_Bool)eligible ineligibilityReasons:(long long)reasons;

@end


@interface REMFamilyChecklistFamilyGroceryListEligibilityInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) REMFamilyChecklistFamilyGroceryListEligibility *familyGroceryListEligibility;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithFamilyGroceryListEligibility:(id)eligibility;

@end


@interface REMFamilyChecklistSharedGroceryList : NSObject <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listID;
@property (readonly, nonatomic) NSSet *participants;
@property (retain, nonatomic) NSURL *URL;
@property (retain, nonatomic) NSItemProvider *itemProvider;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListID:(id)id participants:(id)participants;

@end


@interface REMFamilyChecklistSharedGroceryListInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *sharedGroceryListsWithCommonSharees;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithSharedGroceryLists:(id)lists;

@end


@interface REMFetchMetadata : NSObject <NSSecureCoding, NSCopying>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMFetchRequest : NSObject <NSSecureCoding>

@property (retain, nonatomic) _REMFetchExecutor *fetchExecutor;
@property (retain, nonatomic) REMFetchResultToken *fetchResultToken;
@property (nonatomic) long long type;
@property (nonatomic) unsigned long long fetchLimit;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)copyWithType:(long long)type;
- (id)countOnlyFetchRequest;
- (id)fetchRequestWithFetchResultToken:(id)token;
- (id)initWithFetchExecutor:(id)executor;
- (id)metadataFetchRequest;
- (id)objectIDsOnlyFetchRequest;
- (id)storagesAndParentFetchRequest;
- (id)storagesOnlyFetchRequest;

@end


@interface REMFetchResult : NSObject <NSSecureCoding>

@property (nonatomic) long long type;
@property (readonly, nonatomic) long long count;
@property (readonly, nonatomic) NSArray *requestedObjectIDs;
@property (readonly, nonatomic) NSArray *fetchedAccountStorages;
@property (readonly, nonatomic) NSArray *fetchedListStorages;
@property (readonly, nonatomic) NSArray *fetchedReminderStorages;
@property (readonly, nonatomic) REMFetchMetadata *metadata;
@property (retain, nonatomic) REMFetchResultToken *fetchResultToken;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithType:(long long)type;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCount:(long long)count;
- (id)initWithCoder:(id)coder;
- (id)initWithMetadata:(id)metadata;
- (id)initWithAccountStorages:(id)storages;
- (id)initWithAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages requestedObjectIDs:(id)ids metadata:(id)metadata;
- (id)initWithListStorages:(id)storages;
- (id)initWithReminderStorages:(id)storages;
- (id)initWithRequestedObjectIDs:(id)ids;

@end


@interface REMFetchResultToken : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSDictionary *persistentHistoryTokens;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)fetchResultTokenFromDataRepresentation:(id)representation error:(id *)error;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)dataRepresentationWithError:(id *)error;
- (id)initWithPersistentHistoryTokens:(id)tokens;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMFileAttachment : REMAttachment

@property (nonatomic) unsigned long long fileSize;
@property (retain, nonatomic) NSURL *fileURL;
@property (nonatomic) _Bool isTemporaryFileURL;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)createTemporaryFileURLWithUTI:(id)uti;
+ (id)createTemporaryFileWithData:(id)data UTI:(id)uti;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)dealloc;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id UTI:(id)uti fileSize:(unsigned long long)size fileURL:(id)url data:(id)data;

@end


@interface REMFindMyDeviceInformation : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSString *deviceName;
@property (readonly, nonatomic) _Bool isMeDevice;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithDeviceName:(id)name isMeDevice:(_Bool)device;

@end


@interface REMGroceryClassifierResult : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) _Bool containsGroceryItem;
@property (readonly, nonatomic) double confidenceScore;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithContainsGroceryItem:(_Bool)item confidenceScore:(double)score;

@end


@interface REMGrocerySuggestedSection : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) long long labelIndex;
@property (readonly, nonatomic) NSString *sectionCanonicalName;
@property (readonly, nonatomic) float confidenceScore;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithLabelIndex:(long long)index sectionCanonicalName:(id)name confidenceScore:(float)score;

@end


@interface REMGrocerySuggestions : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDictionary *suggestedSectionsByReminderTitle;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithSuggestedSectionsByReminderTitle:(id)title;

@end


@interface REMHashtag : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableFetchableModel, REMDAChangedModelObjectResult, NSSecureCoding, NSCopying, REMObjectIDProviding, REMHashtagProtocol>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (_Bool)supportsSecureCoding;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (_Bool)isChangeTrackableFetchableModel;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)objectIdentifier;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id type:(long long)type name:(id)name;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id type:(long long)type name:(id)name creationDate:(id)date;
- (_Bool)isEqualToHashtag:(id)hashtag;

@end


@interface REMHashtagLabel : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *canonicalName;
@property (readonly, nonatomic) NSDate *firstOccurrenceCreationDate;
@property (readonly, nonatomic) NSDate *recencyDate;
@property (readonly, nonatomic) NSUUID *uuidForChangeTracking;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (id)initWithName:(id)name;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithName:(id)name canonicalName:(id)name firstOccurrenceCreationDate:(id)date recencyDate:(id)date uuidForChangeTracking:(id)tracking;
- (_Bool)isEqualToHashtagLabel:(id)label;

@end


@interface REMHashtagsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSSet *hashtags;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithHashtags:(id)hashtags;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagsDataViewInvocation_fetchByObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;
@property (nonatomic) _Bool allowConcealedObjects;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMICloudIsOffDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchHasAnyDirtyCloudObjectInAccount:(id)account error:(id *)error;
- (id)fetchICloudIsOffCloudConfigurationPropertiesWithError:(id *)error;

@end


@interface REMICloudIsOffDataViewConfigurationsInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) double timeIntervalSinceLastPrompt;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithTimeIntervalSinceLastPrompt:(double)prompt;

@end


@interface REMICloudIsOffDataViewFetchHasAnyCKDirtyObjectInAccountInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSNumber *hasAnyDirtyCloudObject;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithHasAnyDirtyCloudObject:(id)object;

@end


@interface REMICloudIsOffDataViewInvocation_fetchHasAnyDirtyCloudObjectInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithAccountObjectID:(id)id;

@end


@interface REMICloudIsOffDataViewInvocation_fetchICCloudConfigurationProperties : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMImageAttachment : REMFileAttachment

@property (nonatomic) unsigned long long width;
@property (nonatomic) unsigned long long height;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id UTI:(id)uti fileSize:(unsigned long long)size fileURL:(id)url data:(id)data width:(unsigned long long)width height:(unsigned long long)height;

@end


@interface REMList : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableFetchableModel, REMDAChangedModelObjectResult, REMObjectIDProviding, REMExternalSyncMetadataProviding, REMSupportedVersionProviding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (readonly, nonatomic) _Bool shouldCategorizeGroceryItems;
@property (readonly, nonatomic) _Bool shouldSuggestConversionToGroceryList;
@property (readonly, nonatomic) _Bool shouldSupportGroceryShoppingSession;
@property (readonly, nonatomic) NSString *groceryLocaleID;
@property (readonly, nonatomic) _Bool shouldAutoCategorizeItems;
@property (readonly, nonatomic) REMObjectID *parentAccountID;
@property (readonly, nonatomic) NSDictionary *reminderIDsOrderingHints;
@property (readonly, nonatomic) NSSet *reminderIDsToUndelete;
@property (readonly, nonatomic) NSSet *childListIDsToUndelete;
@property (readonly, nonatomic) NSSet *childSmartListIDsToUndelete;
@property (readonly, nonatomic) NSSet *sectionIDsToUndelete;
@property (readonly, nonatomic) _Bool remindersICSDisplayOrderChanged;
@property (readonly, nonatomic) NSArray *calDAVNotifications;
@property (readonly, nonatomic) NSArray *sharees;
@property (readonly, nonatomic) REMObjectID *sharedOwnerID;
@property (readonly, nonatomic) NSDate *pinnedDate;
@property (readonly, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (readonly, nonatomic) _Bool isOriginOfExistingTemplate;
@property (readonly, nonatomic) NSString *currentUserShareParticipantID;
@property (readonly, nonatomic) REMListSectionContext *sectionContext;
@property (readonly, nonatomic) _Bool isAutoCategorizationSupportedInCurrentAppVersion;
@property (readonly, nonatomic) _Bool isSuggestedRemindersSupportedInCurrentAppVersion;
@property (readonly, nonatomic) REMListGroceryContext *groceryContext;
@property (copy, nonatomic) REMListStorage *storage;
@property (readonly, nonatomic) NSOrderedSet *reminderIDsOrdering;
@property (readonly, nonatomic) NSOrderedSet *reminderIDsMergeableOrdering;
@property (readonly, nonatomic) NSData *reminderIDsMergeableOrderingData;
@property (readonly, nonatomic) _Bool isGroup;
@property (retain, nonatomic) REMList *parentList;
@property (readonly, nonatomic) NSString *badgeEmblem;
@property (readonly, nonatomic) _Bool isPinned;
@property (readonly, nonatomic) _Bool showingLargeAttachments;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMObjectID *parentListID;
@property (readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) NSString *sharedOwnerName;
@property (readonly, nonatomic) NSString *sharedOwnerAddress;
@property (readonly, nonatomic) long long sharingStatus;
@property (readonly, nonatomic) _Bool canBeShared;
@property (readonly, nonatomic) _Bool canBeIncludedInGroup;
@property (readonly, nonatomic) _Bool isShared;
@property (readonly, nonatomic) _Bool isOwnedByMe;
@property (readonly, nonatomic) _Bool isSharedToMe;
@property (readonly, copy, nonatomic) NSDate *lastUserAccessDate;
@property (readonly, nonatomic) NSString *daExternalIdentificationTag;
@property (readonly, nonatomic) NSDictionary *daBulkRequests;
@property (readonly, nonatomic) long long daDisplayOrder;
@property (readonly, nonatomic) _Bool daIsEventOnlyContainer;
@property (readonly, nonatomic) _Bool daIsReadOnly;
@property (readonly, nonatomic) _Bool daIsImmutable;
@property (readonly, nonatomic) _Bool daIsNotificationsCollection;
@property (readonly, nonatomic) REMListCalDAVNotificationContext *calDAVNotificationContext;
@property (readonly, nonatomic) REMListShareeContext *shareeContext;
@property (nonatomic) _Bool isPlaceholder;
@property (readonly, nonatomic) REMStore *store;
@property (readonly, nonatomic) REMAccount *account;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) REMColor *color;
@property (readonly, nonatomic) NSString *sortingStyle;
@property (readonly, nonatomic) REMListAppearanceContext *appearanceContext;
@property (readonly, nonatomic) REMListSublistContext *sublistContext;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSString *externalModificationTag;
@property (readonly, nonatomic) NSString *daSyncToken;
@property (readonly, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (_Bool)isChangeTrackableFetchableModel;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (_Bool)isSharedWithShareeCount:(unsigned long long)count sharingStatus:(long long)status;
+ (_Bool)isOwnedByMeWithSharingStatus:(long long)status;
+ (id)fetchRequestWithPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id)siriFoundInAppsListID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;
+ (id)localAccountDefaultListID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)respondsToSelector:(SEL)selector;
- (id)fetchRemindersCountWithError:(id *)error;
- (id)fetchRemindersWithExternalIdentifiers:(id)identifiers error:(id *)error;
- (id)fetchReminderWithExternalIdentifier:(id)identifier error:(id *)error;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (_Bool)shouldUseExternalIdentifierAsDeletionKey;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)ekColor;
- (id)sharingStatusText;
- (id)forwardingTargetForSelector:(SEL)selector;
- (void)hack_overrideReminderIDsOrderingWithOrderedObjectIDs:(id)ids;
- (id)fetchRemindersAndSubtasksWithError:(id *)error;
- (id)fetchRemindersWithError:(id *)error;
- (id)formattedSharedOwnerName;
- (id)initWithStore:(id)store account:(id)account storage:(id)storage;
- (id)optionalObjectID;

@end


@interface REMListAppearanceContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) REMListBadge *badge;
@property (readonly, nonatomic) NSString *badgeEmblem;

/* instance methods */
- (_Bool)showingLargeAttachments;
- (id)initWithList:(id)list;

@end


@interface REMListAppearanceContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (copy, nonatomic) REMListBadge *badge;
@property (copy, nonatomic) NSString *badgeEmblem;

/* instance methods */
- (_Bool)showingLargeAttachments;
- (void)setShowingLargeAttachments:(_Bool)attachments;
- (id)initWithListChangeItem:(id)item;

@end


@interface REMListBadge : NSObject

@property (copy, nonatomic) NSString *emblem;
@property (copy, nonatomic) NSString *emoji;
@property (readonly, copy, nonatomic) NSString *rawValue;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithRawValue:(id)value;
- (id)initWithEmblem:(id)emblem;
- (id)_emojiFromRawString:(id)string;
- (_Bool)_isJSONString:(id)jsonstring;
- (_Bool)_isSingleCharacterEmoji:(id)emoji;
- (id)initWithEmoji:(id)emoji;

@end


@interface REMListCalDAVNotificationContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) NSArray *calDAVNotifications;

/* instance methods */
- (id)initWithList:(id)list;

@end


@interface REMListCalDAVNotificationContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (readonly, nonatomic) NSArray *calDAVNotifications;

/* instance methods */
- (id)addCalDAVNotificationWithUUIDString:(id)uuidstring hostURL:(id)url externalIdentifier:(id)identifier externalModificationTag:(id)tag;
- (void)removeCalDAVNotication:(id)davnotication;
- (void)updateCalDAVNotification:(id)davnotification withBlock:(id /* block */)block;
- (void)_addCalDAVNotification:(id)davnotification;
- (void)clearCalDAVNotifications;
- (id)initWithListChangeItem:(id)item;

@end


@interface REMListChangeItem : NSObject <REMConflictResolving, REMSaveRequestTrackedValue, REMMergeableOrderingNode, REMExternalSyncMetadataWritableProviding, REMSupportedVersionProviding, REMSupportedVersionUpdating>

@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (nonatomic) _Bool shouldCategorizeGroceryItems;
@property (readonly, nonatomic) _Bool shouldSuggestConversionToGroceryList;
@property (readonly, nonatomic) _Bool shouldSupportGroceryShoppingSession;
@property (copy, nonatomic) NSString *groceryLocaleID;
@property (retain, nonatomic) NSArray *unsavedReminderIDsForCategorization;
@property (nonatomic) _Bool shouldAutoCategorizeItems;
@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) REMObjectID *parentListID;
@property (retain, nonatomic) REMObjectID *templateID;
@property (readonly, nonatomic) NSData *reminderIDsMergeableOrderingData;
@property (readonly, nonatomic) NSOrderedSet *reminderIDsMergeableOrdering;
@property (retain, nonatomic) NSString *badgeEmblem;
@property (nonatomic) _Bool showingLargeAttachments;
@property (copy, nonatomic) NSDate *pinnedDate;
@property (readonly, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (retain, nonatomic) NSDictionary *reminderIDsOrderingHints;
@property (retain, nonatomic) NSSet *reminderIDsToUndelete;
@property (retain, nonatomic) NSSet *childListIDsToUndelete;
@property (retain, nonatomic) NSSet *childSmartListIDsToUndelete;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (retain, nonatomic) NSArray *calDAVNotifications;
@property (retain, nonatomic) NSArray *sharees;
@property (retain, nonatomic) REMObjectID *sharedOwnerID;
@property (readonly, nonatomic) _Bool isPlaceholder;
@property (readonly, nonatomic) _Bool isAutoCategorizationSupportedInCurrentAppVersion;
@property (readonly, nonatomic) _Bool isSuggestedRemindersSupportedInCurrentAppVersion;
@property (nonatomic) _Bool remindersICSDisplayOrderChanged;
@property (readonly, nonatomic) REMListSectionContextChangeItem *sectionsContextChangeItem;
@property (readonly, nonatomic) REMListGroceryContextChangeItem *groceryContextChangeItem;
@property (readonly, nonatomic) REMListGenerativeAutoCategorizationContextChangeItem *generativeAutoCategorizationContextChangeItem;
@property (readonly, nonatomic) REMAccount *parentAccount;
@property (readonly, copy, nonatomic) REMListStorage *storage;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, nonatomic) _Bool isGroup;
@property (nonatomic) _Bool isPinned;
@property (copy, nonatomic) NSString *sharedOwnerName;
@property (copy, nonatomic) NSString *sharedOwnerAddress;
@property (nonatomic) long long sharingStatus;
@property (readonly, nonatomic) _Bool isShared;
@property (readonly, nonatomic) _Bool isSharedToMe;
@property (readonly, nonatomic) _Bool isOwnedByMe;
@property (readonly, nonatomic) _Bool canBeIncludedInGroup;
@property (readonly, nonatomic) NSString *currentUserShareParticipantID;
@property (copy, nonatomic) NSDate *lastUserAccessDate;
@property (retain, nonatomic) NSString *daExternalIdentificationTag;
@property (retain, nonatomic) NSDictionary *daBulkRequests;
@property (nonatomic) long long daDisplayOrder;
@property (nonatomic) _Bool daIsEventOnlyContainer;
@property (nonatomic) _Bool daIsReadOnly;
@property (nonatomic) _Bool daIsImmutable;
@property (nonatomic) _Bool daIsNotificationsCollection;
@property (readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) REMListCalDAVNotificationContextChangeItem *calDAVNotificationContext;
@property (readonly, nonatomic) REMListShareeContextChangeItem *shareeContext;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (copy, nonatomic) NSString *sortingStyle;
@property (readonly, nonatomic) REMListAppearanceContextChangeItem *appearanceContext;
@property (readonly, nonatomic) REMListSublistContextChangeItem *sublistContext;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentOwnerID;
@property (retain, nonatomic) REMObjectID *parentSubContainerID;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (void)initialize;
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)ekColor;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (void)removeFromParent;
- (void)addReminderChangeItem:(id)item;
- (void)_editReminderIDsOrderingUsingBlock:(id /* block */)block;
- (void)_lowLevelAddReminderChangeItemToOrdering:(id)ordering atIndexOfSibling:(id)sibling isAfter:(_Bool)after withParent:(id)parent;
- (_Bool)_lowLevelAddReminderIDToOrdering:(id)ordering relativeToSiblingID:(id)id isAfter:(_Bool)after;
- (void)_lowLevelApplyUndoToOrdering:(id)ordering;
- (void)_reassignReminderChangeItem:(id)item withParentReminderChangeItem:(id)item;
- (id)_testingOnly_listShareeContextChangeItem;
- (void)_testingOnly_setReminderIDsMergeableOrder:(id)order;
- (void)autoCategorizeRemindersWithReminderIDs:(id)ids;
- (void)copyListDataFrom:(id)from;
- (id)initWithObjectID:(id)id name:(id)name insertIntoAccountChangeItem:(id)item;
- (id)initWithObjectID:(id)id name:(id)name insertIntoAccountChangeItem:(id)item isGroup:(_Bool)group;
- (id)initWithObjectID:(id)id name:(id)name insertIntoAccountChangeItem:(id)item isGroup:(_Bool)group withParentList:(id)list;
- (id)initWithObjectID:(id)id name:(id)name insertIntoListSublistContextChangeItem:(id)item;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities observeInitialValues:(_Bool)values;
- (void)insertReminderChangeItem:(id)item adjacentToReminderChangeItem:(id)item isAfter:(_Bool)after withParentReminderChangeItem:(id)item;
- (void)insertReminderChangeItem:(id)item afterReminderChangeItem:(id)item;
- (void)insertReminderChangeItem:(id)item beforeReminderChangeItem:(id)item;
- (_Bool)isSubContainer;
- (void)lowLevelAddReminderIDToOrdering:(id)ordering withParentReminderChangeItem:(id)item;
- (id)lowLevelRemoveReminderIDFromOrdering:(id)ordering;
- (_Bool)optimisticallyInsertReminderIDToOrderingForReminderChangeItemBeingSaved:(id)saved;
- (id)removeFromAccountAllowingUndo;
- (id)removeFromParentAllowingUndo;
- (void)removeFromParentWithAccountChangeItem:(id)item;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (id)shallowCopyWithSaveRequest:(id)request;
- (void)undeleteReminderWithID:(id)id usingUndo:(id)undo;
- (void)undeleteRemindersWithoutUndoWithIDs:(id)ids;
- (void)undeleteRemindersWithoutUndoWithIDs:(id)ids isCalDAV:(_Bool)dav;

@end


@interface _REMFetchExecutor : NSObject <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)metadataFromFetchResult:(id)result inStore:(id)store error:(id *)error;
- (id)resultsFromFetchResult:(id)result inStore:(id)store error:(id *)error;

@end


@interface REMListFetchExecutor : _REMFetchExecutor

@property (retain, nonatomic) REMListPredicateDescriptor *predicateDescriptor;
@property (retain, nonatomic) NSArray *sortDescriptors;
@property (readonly, nonatomic) unsigned long long options;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors options:(unsigned long long)options;
- (id)resultsFromFetchResult:(id)result inAccount:(id)account error:(id *)error;
- (id)resultsFromFetchResult:(id)result inParentList:(id)list error:(id *)error;
- (id)resultsFromFetchResult:(id)result inStore:(id)store error:(id *)error;

@end


@interface REMListFetchMetadata : REMFetchMetadata

@property (readonly, nonatomic) NSDictionary *incompleteReminderCounts;
@property (readonly, nonatomic) long long scheduledCount;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithIncompleteReminderCounts:(id)counts scheduledCount:(long long)count;

@end


@interface REMListGenerativeAutoCategorizationContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) _Bool shouldAutoCategorizeItems;

/* instance methods */
- (id)initWithList:(id)list;

@end


@interface REMListGenerativeAutoCategorizationContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (nonatomic) _Bool shouldAutoCategorizeItemsIntoGenerativeSections;
@property (readonly, nonatomic) NSArray *unsavedReminderIDsForCategorization;

/* instance methods */
- (void)autoCategorizeRemindersWithReminderIDs:(id)ids;
- (id)initWithListChangeItem:(id)item;

@end


@interface REMListGroceryContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) _Bool shouldCategorizeGroceryItems;
@property (readonly, nonatomic) _Bool shouldSuggestConversionToGroceryList;
@property (readonly, nonatomic) _Bool shouldSupportGroceryShoppingSession;
@property (readonly, nonatomic) NSString *groceryLocaleID;

/* instance methods */
- (id)initWithList:(id)list;

@end


@interface REMListGroceryContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (nonatomic) _Bool shouldCategorizeGroceryItems;
@property (readonly, nonatomic) _Bool shouldSuggestConversionToGroceryList;
@property (readonly, nonatomic) _Bool shouldSupportGroceryShoppingSession;
@property (copy, nonatomic) NSString *groceryLocaleID;
@property (readonly, nonatomic) NSArray *unsavedReminderIDsForCategorization;

/* instance methods */
- (void)autoCategorizeRemindersWithReminderIDs:(id)ids;
- (id)initWithListChangeItem:(id)item;

@end


@interface REMListPredicateDescriptor : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long type;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentListID;
@property (retain, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)predicateDescriptorForAllLists;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithType:(long long)type;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListSection : REMBaseSection

@property (readonly, nonatomic) REMList *list;
@property (readonly, nonatomic) NSString *canonicalName;
@property (retain, nonatomic) REMObjectID *listID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)initWithStore:(id)store list:(id)list storage:(id)storage;

@end


@interface REMListSectionChangeItem : REMBaseSectionChangeItem

@property (retain, nonatomic) REMObjectID *listID;
@property (copy, nonatomic) NSString *canonicalName;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)keysToObserve;

/* instance methods */
- (void)removeFromList;
- (id)initWithObjectID:(id)id displayName:(id)name insertIntoListChangeItem:(id)item;

@end


@interface REMListSectionContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) _Bool hasSections;

/* instance methods */
- (id)initWithList:(id)list;

@end


@interface REMListSectionContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;

/* instance methods */
- (id)initWithListChangeItem:(id)item;
- (void)undeleteSectionWithID:(id)id;

@end


@interface REMListSectionStorage : REMBaseSectionStorage

@property (retain, nonatomic) REMObjectID *listID;
@property (retain, nonatomic) NSString *canonicalName;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)cdKeyToStorageKeyMap;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id listID:(id)id displayName:(id)name;

@end


@interface REMListSectionsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)fetchListSectionsCountWithListObjectID:(id)id error:(id *)error;
- (id)initWithStore:(id)store;
- (id)fetchListSectionsWithListObjectID:(id)id error:(id *)error;
- (id)fetchListSectionsWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchPredefinedListSectionsWithObjectIDs:(id)ids listObjectID:(id)id error:(id *)error;
- (id)fetchPredefinedListSectionWithObjectID:(id)id listObjectID:(id)id error:(id *)error;
- (id)fetchListSectionWithObjectID:(id)id error:(id *)error;
- (id)fetchListSectionWithReminderID:(id)id error:(id *)error;
- (id)fetchListSectionsInList:(id)list error:(id *)error;
- (id)listSectionsFromAccountStorages:(id)storages listStorages:(id)storages listSectionStorages:(id)storages store:(id)store;

@end


@interface REMListSectionsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountStorages;
@property (readonly, nonatomic) NSArray *listStorages;
@property (readonly, nonatomic) NSArray *listSectionStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithAccountStorages:(id)storages listStorages:(id)storages listSectionStorages:(id)storages;

@end


@interface REMListSectionsDataViewInvocation_fetchByObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListSectionsDataViewInvocation_fetchByReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *reminderID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithReminderID:(id)id;

@end


@interface REMListSectionsDataViewInvocation_fetchListSectionsCountInList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentListObjectID:(id)id;

@end


@interface REMListSectionsDataViewInvocation_fetchListSectionsInList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentListObjectID:(id)id;

@end


@interface REMListSectionsDataViewInvocation_fetchPredefinedListSectionsInList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;
@property (readonly, nonatomic) REMObjectID *listObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectIDs:(id)ids parentListObjectID:(id)id;

@end


@interface REMListShareeContext : NSObject

@property (retain, nonatomic) REMList *list;
@property (readonly, nonatomic) NSArray *sharees;
@property (readonly, nonatomic) REMSharee *sharedOwner;

/* instance methods */
- (id)initWithList:(id)list;
- (id)shareesExcludingOwner;

@end


@interface REMListShareeContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;
@property (readonly, nonatomic) NSArray *sharees;

/* instance methods */
- (void)addSharee:(id)sharee;
- (void)removeSharee:(id)sharee;
- (void)removeAllSharees;
- (id)addShareeWithDisplayName:(id)name firstName:(id)name lastName:(id)name address:(id)address status:(long long)status accessLevel:(long long)level;
- (id)addShareeWithDisplayName:(id)name firstName:(id)name middleName:(id)name lastName:(id)name namePrefix:(id)prefix nameSuffix:(id)suffix nickname:(id)nickname address:(id)address status:(long long)status accessLevel:(long long)level;
- (id)addShareeWithPersonNameComponents:(id)components address:(id)address status:(long long)status accessLevel:(long long)level;
- (id)initWithListChangeItem:(id)item;

@end


@interface REMListSortDescriptor : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) _Bool ascending;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)sortDescriptorSortingByNameAscending:(_Bool)ascending;
+ (id)sortDescriptorSortingByOrderingInAccountAscending:(_Bool)ascending;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithType:(long long)type ascending:(_Bool)ascending;

@end


@interface REMListStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMExternalSyncMetadataWritableProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *objectID;
@property (nonatomic) _Bool isGroup;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (retain, nonatomic) NSString *badgeEmblem;
@property (nonatomic) _Bool shouldCategorizeGroceryItems;
@property (nonatomic) _Bool shouldSuggestConversionToGroceryList;
@property (nonatomic) _Bool shouldSupportGroceryShoppingSession;
@property (retain, nonatomic) NSString *groceryLocaleID;
@property (retain, nonatomic) NSArray *unsavedReminderIDsForCategorization;
@property (nonatomic) _Bool shouldAutoCategorizeItems;
@property (copy, nonatomic) NSString *sortingStyle;
@property (copy, nonatomic) NSDate *pinnedDate;
@property (retain, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (nonatomic) _Bool showingLargeAttachments;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) REMObjectID *parentListID;
@property (readonly, nonatomic) NSString *displayName;
@property (retain, nonatomic) NSOrderedSet *reminderIDsMergeableOrdering;
@property (retain, nonatomic) NSData *reminderIDsMergeableOrderingData;
@property (retain, nonatomic) NSDictionary *reminderIDsOrderingHints;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (retain, nonatomic) NSSet *reminderIDsToUndelete;
@property (retain, nonatomic) NSSet *childListIDsToUndelete;
@property (retain, nonatomic) NSSet *childSmartListIDsToUndelete;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (nonatomic) _Bool remindersICSDisplayOrderChanged;
@property (retain, nonatomic) REMObjectID *templateID;
@property (copy, nonatomic) NSString *sharedOwnerName;
@property (copy, nonatomic) NSString *sharedOwnerAddress;
@property (nonatomic) long long sharingStatus;
@property (retain, nonatomic) NSArray *sharees;
@property (retain, nonatomic) REMObjectID *sharedOwnerID;
@property (copy, nonatomic) NSDate *lastUserAccessDate;
@property (retain, nonatomic) NSArray *calDAVNotifications;
@property (retain, nonatomic) NSString *daExternalIdentificationTag;
@property (retain, nonatomic) NSDictionary *daBulkRequests;
@property (nonatomic) long long daDisplayOrder;
@property (nonatomic) _Bool daIsEventOnlyContainer;
@property (nonatomic) _Bool daIsReadOnly;
@property (nonatomic) _Bool daIsImmutable;
@property (nonatomic) _Bool daIsNotificationsCollection;
@property (nonatomic) _Bool isPlaceholder;
@property (copy, nonatomic) NSString *currentUserShareParticipantID;
@property (nonatomic) _Bool isAutoCategorizationSupportedInCurrentAppVersion;
@property (nonatomic) _Bool isSuggestedRemindersSupportedInCurrentAppVersion;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)reminderIDUUIDStringsJSONDataFromReminderIDsMergeableOrdering:(id)ordering error:(id *)error;
+ (_Bool)_forceDisableFullRemindersSorting;
+ (void)set_forceDisableFullRemindersSorting:(_Bool)sorting;
+ (id)reminderIDsMergeableOrderingFromReminderIDUUIDStringsJSONData:(id)jsondata error:(id *)error;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectID:(id)id accountID:(id)id name:(id)name isGroup:(_Bool)group reminderIDsMergeableOrderingData:(id)data;
- (unsigned long long)storeGeneration;
- (id)debugDescription;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)initWithObjectID:(id)id accountID:(id)id name:(id)name;
- (id)description;
- (_Bool)isUnsupported;
- (id)ekColor;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)hasDeserializedReminderIDsMergeableOrdering;
- (id)initWithObjectID:(id)id accountID:(id)id name:(id)name isGroup:(_Bool)group reminderIDsMergeableOrdering:(id)ordering;
- (id)optionalObjectID;
- (id)initWithCoder:(id)coder;

@end


@interface REMListSublistContext : NSObject

@property (retain, nonatomic) REMList *list;

/* instance methods */
- (id)fetchCustomSmartListsWithError:(id *)error;
- (id)fetchListsWithError:(id *)error;
- (id)initWithList:(id)list;

@end


@interface REMListSublistContextChangeItem : NSObject

@property (retain, nonatomic) REMListChangeItem *listChangeItem;

/* instance methods */
- (void)addListChangeItem:(id)item;
- (id)_accountChangeItem;
- (void)_insertMergeableOrderingNode:(id)node adjacentToMergeableOrderingNode:(id)node isAfter:(_Bool)after;
- (void)addMergeableOrderingNode:(id)node;
- (void)addSmartListChangeItem:(id)item;
- (id)initWithListChangeItem:(id)item;
- (void)insertListChangeItem:(id)item afterListChangeItem:(id)item;
- (void)insertListChangeItem:(id)item beforeListChangeItem:(id)item;
- (void)insertMergeableOrderingNode:(id)node afterMergeableOrderingNode:(id)node;
- (void)insertMergeableOrderingNode:(id)node beforeMergeableOrderingNode:(id)node;
- (void)insertSmartListChangeItem:(id)item afterSmartListChangeItem:(id)item;
- (void)insertSmartListChangeItem:(id)item beforeSmartListChangeItem:(id)item;
- (void)undeleteChildListWithID:(id)id usingUndo:(id)undo;
- (void)undeleteChildSmartListWithID:(id)id usingUndo:(id)undo;

@end


@interface REMListsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* class methods */
+ (id)listsFromAccountStorages:(id)storages listStorages:(id)storages store:(id)store requestedListIDs:(id)ids;
+ (id)listsFromAccounts:(id)accounts listStorages:(id)storages store:(id)store;
+ (id)listsFromAccountStorages:(id)storages listStorages:(id)storages store:(id)store requestedExternalIdentifiers:(id)identifiers;
+ (id)listsFromAccountStorages:(id)storages listStorages:(id)storages store:(id)store;

/* instance methods */
- (id)fetchListsWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchAllListsWithExternalIdentifier:(id)identifier inAccount:(id)account error:(id *)error;
- (id)initWithStore:(id)store;
- (id)fetchDefaultListRequiringCloudKitWithAccountID:(id)id error:(id *)error;
- (id)fetchListsWithExternalIdentifiers:(id)identifiers inAccount:(id)account error:(id *)error;
- (id)fetchListsInAccount:(id)account error:(id *)error;
- (id)debugFetchPhantomListsWithError:(id *)error;
- (id)fetchListsIncludingSpecialContainersInAccount:(id)account error:(id *)error;
- (id)fetchEligibleDefaultListsWithError:(id *)error;
- (id)fetchListsIncludingSpecialContainersWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchListWithObjectID:(id)id error:(id *)error;
- (id)fetchMostRelevantGroceryCapableListWithError:(id *)error;
- (id)fetchGroceryListsWithRequiringOneOrMoreIncompleteReminders:(_Bool)reminders error:(id *)error;
- (id)fetchListIncludingSpecialContainerWithObjectID:(id)id error:(id *)error;
- (id)fetchDefaultListWithError:(id *)error;
- (id)fetchListsAndSublistsInAccount:(id)account error:(id *)error;
- (id)fetchListsInGroup:(id)group error:(id *)error;
- (id)fetchAllGroceryCapableListsWithError:(id *)error;
- (id)fetchListIncludingConcealedWithObjectID:(id)id includeMarkedForDeletionOnly:(_Bool)only error:(id *)error;
- (id)fetchListRepresentationOfTemplateWithObjectID:(id)id error:(id *)error;
- (id)fetchListIncludingSpecialContainerWithExternalIdentifier:(id)identifier inAccount:(id)account error:(id *)error;

@end


@interface REMListsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountStorages;
@property (readonly, nonatomic) NSArray *listStorages;
@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithAccountStorages:(id)storages listStorages:(id)storages objectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_changeTrackingFetchByObjectIDIncludingConcealed : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;
@property (nonatomic) _Bool includeMarkedForDeletionOnly;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_dataAccessFetchByExternalIdentifier : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *externalIdentifiers;
@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithExternalIdentifiers:(id)identifiers accountObjectID:(id)id;

@end


@interface REMListsDataViewInvocation_dataAccessFetchByObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_dataAccessFetchListsInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithParentAccountObjectID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_debugFetchPhantomLists : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchAllGroceryCapableLists : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchByObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchByTemplateObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *templateObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithTemplateObjectID:(id)id;

@end


@interface REMListsDataViewInvocation_fetchDefaultList : REMStoreInvocation <NSSecureCoding>

@property (nonatomic) _Bool debug_useInMemoryPreferredDefaultListStorage;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithDebugUseInMemoryPreferredDefaultListStorage:(_Bool)storage;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchDefaultListRequiringCloudKit : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;
@property (nonatomic) _Bool debug_useInMemoryPreferredDefaultListStorage;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithAccountObjectID:(id)id debugUseInMemoryPreferredDefaultListStorage:(_Bool)storage;

@end


@interface REMListsDataViewInvocation_fetchGroceryListsWithRequiringOneOrMoreIncompleteReminders : REMStoreInvocation <NSSecureCoding>

@property (nonatomic) _Bool requiringOneOrMoreIncompleteReminders;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithRequiringOneOrMoreIncompleteReminders:(_Bool)reminders;

@end


@interface REMListsDataViewInvocation_fetchListsAndSublistsInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithParentAccountObjectID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchListsInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithParentAccountObjectID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchListsInGroup : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *groupObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentGroupObjectID:(id)id;

@end


@interface REMListsDataViewInvocation_fetchMostRelevantGroceryCapableList : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_fetchUserSelectableDefaultLists : REMStoreInvocation <NSSecureCoding>

@property (nonatomic) _Bool debug_useInMemoryPreferredDefaultListStorage;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithDebugUseInMemoryPreferredDefaultListStorage:(_Bool)storage;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMListsDataViewInvocation_userActivityFetchByExternalIdentifier : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithExternalIdentifier:(id)identifier accountObjectID:(id)id;

@end


@interface REMLog : NSObject

/* class methods */
+ (id)xpc;
+ (id)crdt;
+ (id)search;
+ (id)widget;
+ (id)templates;
+ (id)appIntents;
+ (id)timelineEngine;
+ (id)intelligentGrocery;
+ (id)analytics;
+ (id)account;
+ (id)notification;
+ (id)operationQueue;
+ (id)suggestedAttributes;
+ (id)housekeepingingActivityScheduler;
+ (id)intelligentReminderExtraction;
+ (id)userAction;
+ (id)cloudkit;
+ (id)alarmEngine;
+ (id)dataAccess;
+ (id)scripting;
+ (id)magicCompose;
+ (id)autoCategorization;
+ (id)ppt;
+ (id)siriKit;
+ (id)changeTracking;
+ (id)suggestedAttributesAutoTrainer;
+ (id)editor;
+ (id)ui;
+ (id)inlineTagAutoConvertEngine;
+ (id)accountPlugin;
+ (id)urgentAlarm;
+ (id)cloudkitCollaboration;
+ (id)applicationShortcut;
+ (id)utility;
+ (id)migration;

@end


@interface REMLogStore : NSObject

/* class methods */
+ (id)xpc;
+ (id)search;
+ (id)stagedLightweightCoreDataMigration;
+ (id)read;
+ (id)container;
+ (id)OVERSIZED;
+ (id)write;
+ (id)utility;

@end


@interface REMManualOrdering : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) short listType;
@property (readonly, nonatomic) NSString *listID;
@property (readonly, nonatomic) NSArray *topLevelElementIDs;
@property (readonly, nonatomic) NSDictionary *secondaryLevelElementIDsByTopLevelElementID;
@property (readonly, nonatomic) REMObjectID *uncommitedElementsAccountID;
@property (readonly, nonatomic) NSDate *modifiedDate;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)remObjectID;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id listType:(short)type listID:(id)id modifiedDate:(id)date;
- (id)initWithObjectID:(id)id listType:(short)type listID:(id)id topLevelElementIDs:(id)ids secondaryLevelElementIDsByTopLevelElementID:(id)id uncommitedElementsAccountID:(id)id modifiedDate:(id)date;

@end


@interface REMMembership : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSUUID *memberIdentifier;
@property (readonly, nonatomic) NSUUID *groupIdentifier;
@property (readonly, nonatomic) _Bool isObsolete;
@property (readonly, nonatomic) NSDate *modifiedOn;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithMemberIdentifier:(id)identifier groupIdentifier:(id)identifier isObsolete:(_Bool)obsolete modifiedOn:(id)on;

@end


@interface REMMemberships : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDictionary *membershipByMemberIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)excludingObsoleteAndModifiedEarlierThan:(id)than;
- (id)groupIdentifierOfMemberWithIdentifier:(id)identifier;
- (id)initWithMembershipByMemberIdentifier:(id)identifier;
- (id)initWithMemberships:(id)memberships;
- (id)mergingWith:(id)with mergePolicy:(unsigned long long)policy;

@end


@interface REMMigrationResult : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSString *state;
@property (readonly, nonatomic) _Bool isObserver;
@property (readonly, nonatomic) double timeElapsed;
@property (readonly, nonatomic) unsigned long long listsMigrated;
@property (readonly, nonatomic) unsigned long long remindersMigrated;
@property (readonly, nonatomic) NSString *log;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithState:(id)state IsObserver:(_Bool)observer timeElapsed:(double)elapsed listsMigrated:(unsigned long long)migrated remindersMigrated:(unsigned long long)migrated log:(id)log;

@end


@interface REMMutableCRMergeableOrderedSet : NSObject <REMReplicaIDHelperOwner, CRUndoDelegate>

@property (retain, nonatomic) REMReplicaIDSource *replicaIDSource;
@property (retain, nonatomic) CRDocument *document;
@property (retain, nonatomic) REMReplicaIDHelper *replicaIDHelper;
@property (readonly, nonatomic) NSMutableArray *undos;
@property (retain, nonatomic) REMMutableCRUndo *currentUndo;
@property (retain, nonatomic) id <REMReplicaManagerProviding> replicaManagerProvider;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)undo;
- (id)addObject:(id)object;
- (id)removeObjectAtIndex:(unsigned long long)index;
- (id)insertObject:(id)object atIndex:(unsigned long long)index;
- (void)undo:(id)undo;
- (void)addUndoCommandsForObject:(id)object block:(id /* block */)block;
- (id)documentToEdit;
- (id)immutableOrderedSet;
- (id)initWithReplicaIDSource:(id)idsource immutableDocumentToEdit:(id)edit undos:(id)undos;
- (id)moveObjectFromIndex:(unsigned long long)index toIndex:(unsigned long long)index;
- (void)replicaIDHelperDidAcquireReplicaUUID:(id)uuid;
- (_Bool)wantsUndoCommands;

@end


@interface REMMutableCRMergeableStringDocument : NSObject <REMTTHashtagHosting, REMReplicaIDHelperOwner>

@property (retain, nonatomic) REMReplicaIDSource *replicaIDSource;
@property (retain, nonatomic) TTMergeableStringVersionedDocument *document;
@property (retain, nonatomic) REMReplicaIDHelper *replicaIDHelper;
@property (retain, nonatomic) id <REMReplicaManagerProviding> replicaManagerProvider;
@property (readonly, nonatomic) TTMergeableAttributedString *mergeableString;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void)_test_insertString:(id)string atIndex:(unsigned long long)index;
- (void)addHashtag:(id)hashtag range:(struct _NSRange)range;
- (void)enumerateHashtagInRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (id)hashtagAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)immutableDocument;
- (id)initWithReplicaIDSource:(id)idsource;
- (id)initWithReplicaIDSource:(id)idsource immutableDocumentToEdit:(id)edit;
- (void)removeHashtagInRange:(struct _NSRange)range;
- (void)replicaIDHelperDidAcquireReplicaUUID:(id)uuid;
- (id)wipeAndReplaceWithString:(id)string;

@end


@interface REMMutableCRUndo : NSObject

@property (readonly, nonatomic) NSMutableArray *undoBlocks;

/* instance methods */
- (id)init;
- (id)immutableCopy;
- (void)addUndoBlock:(id /* block */)block;

@end


@interface REMMutableCalDAVNotification : REMCalDAVNotification <REMExternalSyncMetadataWritableProviding>

@property (retain, nonatomic) NSString *uuidString;
@property (retain, nonatomic) NSURL *hostURL;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;

@end


@interface REMNSPersistentHistoryChange : REMChangeObject

@property (retain) _REMNSPersistentHistoryChangeStorage *storage;
@property (readonly) NSManagedObjectID *persistentHistoryChangeObjectID;
@property (retain) REMObjectID *cachedChangedREMObjectID;
@property (weak, nonatomic) REMChangeTransaction *internal_ChangeTransaction;
@property (nonatomic) _Bool isCoalesced;
@property (retain, nonatomic) NSArray *coalescedChanges;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)shortStringForChangeType:(long long)type;
+ (id)stringForChangeType:(long long)type;

/* instance methods */
- (long long)changeType;
- (_Bool)isEqual:(id)equal;
- (id)initWithStorage:(id)storage;
- (id)tombstone;
- (id)transaction;
- (id)description;
- (long long)changeID;
- (id)updatedProperties;
- (void)encodeWithCoder:(id)coder;
- (id)changedObjectID;
- (id)initWithCoder:(id)coder;
- (id)changedManagedObjectID;
- (id)copyForCoalescing;
- (id)initWithPersistentHistoryChange:(id)change;
- (void)resolveObjectIDWithUUID:(id)uuid entityName:(id)name;

@end


@interface REMNSPersistentHistoryChangeTombstone : REMChangeTombstone

@property (retain) NSDictionary *persistentHistoryChangeTombstone;
@property (readonly) NSUUID *uuidForChangeTracking;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)daIsEventOnlyContainer;
- (_Bool)isEqual:(id)equal;
- (id)objectIdentifier;
- (id)initWithDictionary:(id)dictionary;
- (void)encodeWithCoder:(id)coder;
- (id)externalIdentifier;
- (id)initWithCoder:(id)coder;
- (id)shareeDisplayName;
- (id)assignmentOwningReminderIdentifier;
- (id)dueDateDeltaAlertReminderIdentifier;
- (id)hashtagLabelUUIDForChangeTracking;
- (id)hashtagName;
- (id)hashtagReminderIdentifier;
- (id)remObjectIdentifier;
- (id)shareeAddress;
- (id)shareeOwningListIdentifier;
- (id)syncActivityUUIDForChangeTracking;

@end


@interface REMNSPersistentHistoryToken : REMChangeToken

@property (readonly, nonatomic) NSPersistentHistoryToken *token;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)compareToken:(id)token error:(id *)error;
- (id)initWithPersistentHistoryToken:(id)token;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMNSPersistentHistoryTransaction : REMChangeTransaction

@property (retain) _REMNSPersistentHistoryTransactionStorage *storage;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)author;
- (_Bool)isEqual:(id)equal;
- (id)initWithStorage:(id)storage;
- (id)changes;
- (id)timestamp;
- (id)storeID;
- (id)accountID;
- (id)description;
- (id)token;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (void)_resolveAccountID:(id)id;

@end


@interface REMObjectID : NSObject <REMCRMergeableDataType, REMDAChangedIdentifierResult, NSCopying, NSSecureCoding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) NSUUID *uuid;
@property (readonly, nonatomic) NSString *entityName;
@property (readonly, nonatomic) NSString *stringRepresentation;
@property (readonly, nonatomic) NSURL *urlRepresentation;

/* class methods */
+ (void)initialize;
+ (_Bool)supportsSecureCoding;
+ (void)rem_registerClassAtCRCoderIfNeeded;
+ (id)objectIDWithUUID:(id)uuid entityName:(id)name;
+ (id)objectIDWithURL:(id)url;

/* instance methods */
- (void)setDocument:(id)document;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (id)redactedDescription;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (id)initWithUUID:(id)uuid entityName:(id)name;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface REMOrderedIdentifierMap : NSObject <NSSecureCoding, NSCopying>

@property (retain, nonatomic) NSArray *orderedIdentifiers;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithOrderedIdentifiers:(id)identifiers;

@end


@interface REMPaths : NSObject

/* class methods */
+ (void)unitTest_setLegacyApplicationDocumentsURL:(id)url;
+ (id)createTemporaryFileDirectoryURLIfNeededWithError:(id *)error;
+ (id)dataSeparationEnabled_applicationDocumentsURL;
+ (id)attributesForGroupContainerDirectory;
+ (id)URLForGroupContainerWithIdentifier:(id)identifier;
+ (_Bool)_legacy_shouldUseCentralizedDataPath;
+ (id)legacy_applicationDocumentsURL;
+ (id)legacy_centralizedDataPath;

@end


@interface REMRadarUtilities : NSObject

/* class methods */
+ (void)createRadarWithTitle:(id)title description:(id)description;
+ (void)promptUserToFileBugWithAlertMessage:(id)message bugTitle:(id)title bugDescription:(id)description;

@end


@interface REMRecurrenceDayOfWeek : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) long long dayOfTheWeek;
@property (readonly, nonatomic) long long weekNumber;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)dayOfWeek:(long long)week weekNumber:(long long)number;
+ (id)dayOfWeek:(long long)week;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)iCalendarDescription;
- (id)description;
- (id)iCalendarValueFromDayOfTheWeek:(long long)week;
- (id)initWithDayOfTheWeek:(long long)week weekNumber:(long long)number;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMRecurrenceEnd : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDate *endDate;
@property (readonly, nonatomic) unsigned long long occurrenceCount;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)recurrenceEndWithEndDate:(id)date;
+ (id)recurrenceEndWithOccurrenceCount:(unsigned long long)count;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithEndDate:(id)date;
- (id)initWithOccurrenceCount:(unsigned long long)count;
- (_Bool)usesEndDate;

@end


@interface REMRecurrenceRule : NSObject <NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, copy, nonatomic) REMRecurrenceEnd *recurrenceEnd;
@property (readonly, nonatomic) long long frequency;
@property (readonly, nonatomic) long long interval;
@property (readonly, nonatomic) long long firstDayOfTheWeek;
@property (readonly, nonatomic) NSArray *daysOfTheWeek;
@property (readonly, nonatomic) NSArray *daysOfTheMonth;
@property (readonly, nonatomic) NSArray *daysOfTheYear;
@property (readonly, nonatomic) NSArray *weeksOfTheYear;
@property (readonly, nonatomic) NSArray *monthsOfTheYear;
@property (readonly, nonatomic) NSArray *setPositions;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)iCalendarValueFromDate:(id)date isDateOnly:(_Bool)only isFloating:(_Bool)floating;
+ (id)iCalendarValueFromRecurrenceType:(long long)type;
+ (id)hourlyRecurrentDueDateToward:(id)toward dueDate:(id)date interval:(long long)interval adjustingStepsBy:(id /* block */)by;
+ (int)_convertREMRecurrenceFrequencyToCalRecurrenceFrequency:(long long)frequency;
+ (id)hourlyRecurrentDueDateAfter:(id)after dueDate:(id)date interval:(long long)interval;
+ (id)hourlyRecurrentDueDateBefore:(id)before dueDate:(id)date interval:(long long)interval;
+ (id)iCalendarValueFromWeekday:(long long)weekday;
+ (id)nextRecurrentDueDateAfter:(id)after dueDate:(id)date timeZone:(id)zone allDay:(_Bool)day recurrenceRules:(id)rules;
+ (id)previousRecurrentDueDateBefore:(id)before dueDate:(id)date timeZone:(id)zone allDay:(_Bool)day recurrenceRules:(id)rules;
+ (id)recurrenceGeneratorConfiguredForDueDate:(id)date timeZone:(id)zone allDay:(_Bool)day recurrenceRule:(id)rule;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)iCalendarDescription;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)stringValueAsDateOnly:(_Bool)only isFloating:(_Bool)floating;
- (id)initRecurrenceRuleWithObjectID:(id)id accountID:(id)id reminderID:(id)id frequency:(long long)frequency interval:(long long)interval firstDayOfTheWeek:(long long)week daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year weeksOfTheYear:(id)year daysOfTheYear:(id)year setPositions:(id)positions end:(id)end;
- (_Bool)isEqualToRecurrenceRule:(id)rule;
- (id)initRecurrenceRuleWithObjectID:(id)id accountID:(id)id reminderID:(id)id frequency:(long long)frequency interval:(long long)interval end:(id)end;
- (id)initWithRecurrenceRule:(id)rule objectID:(id)id accountID:(id)id reminderID:(id)id;
- (id)initWithRecurrenceRule:(id)rule objectID:(id)id end:(id)end;

@end


@interface REMRecurrenceRuleFormatter : NSObject

/* class methods */
+ (id)_andDaysOfWeekString:(id)string;
+ (id)_customDayCombinationDescription:(id)description;
+ (id)_dayOfMonthAsString:(long long)string;
+ (id)_daysOfWeek;
+ (id)_numberedWeekDayString:(id)string;
+ (id)_orDaysOfWeekString:(id)string;
+ (id)_weekDayPositionAsString:(long long)string;
+ (long long)daysTypeForDayArray:(id)array;
+ (id)_readableMonths;
+ (id)_byDayOfWeekOrdinalStrings;
+ (id)_customByDayItemFormatLocalizedString;
+ (id)_localizedOfMonthStringForMonth:(id)month;
+ (id)_readableWeekDays;
+ (id)_stringForByDayOfWeek:(id)week setPositions:(id)positions;
+ (id)_stringForDayOfWeek:(long long)week;
+ (id)_stringForMonthNumber:(long long)number;
+ (id)localizedDescriptionForRepeatType:(long long)type;
+ (id)naturalLanguageDescriptionForFrequency:(long long)frequency interval:(long long)interval daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year weeksOfTheYear:(id)year daysOfTheYear:(id)year setPositions:(id)positions end:(id)end withStartDate:(id)date;
+ (id)naturalLanguageDescriptionForRecurrenceRule:(id)rule withStartDate:(id)date;
+ (long long)repeatTypeForFrequency:(long long)frequency interval:(long long)interval daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year weeksOfTheYear:(id)year daysOfTheYear:(id)year setPositions:(id)positions end:(id)end recurrenceDate:(id)date recurrenceTimeZone:(id)zone getRepeatEnd:(out id *)end;
+ (long long)repeatTypeForRecurrenceRules:(id)rules recurrenceDate:(id)date recurrenceTimeZone:(id)zone getRepeatEnd:(out id *)end;
+ (id)shortNaturalLanguageDescriptionForFrequency:(long long)frequency interval:(long long)interval daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year setPositions:(id)positions date:(id)date timeZone:(id)zone lowercase:(_Bool)lowercase;
+ (id)shortNaturalLanguageDescriptionForRecurrenceRule:(id)rule date:(id)date timeZone:(id)zone lowercase:(_Bool)lowercase;

@end


@interface REMReminder : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableFetchableModel, REMDAChangedModelObjectResult, REMObjectIDProviding, REMExternalSyncMetadataProviding, REMSupportedVersionProviding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (retain, nonatomic) REMObjectID *listID;
@property (readonly, nonatomic) _Bool isUrgentStateEnabledForCurrentUser;
@property (readonly, nonatomic) NSDate *alternativeDisplayDateDate_forCalendar;
@property (readonly, nonatomic) REMReminderDueDateDeltaAlertContext *dueDateDeltaAlertContext;
@property (readonly, nonatomic) NSUUID *batchCreationID;
@property (readonly, nonatomic) REMObjectID *parentReminderID;
@property (retain, nonatomic) REMReminder *parentReminder;
@property (readonly, nonatomic) REMReminderStorage *storage;
@property (readonly, nonatomic) NSData *titleDocumentData;
@property (readonly, nonatomic) REMCRMergeableStringDocument *titleDocument;
@property (readonly, nonatomic) NSString *titleAsString;
@property (readonly, nonatomic) NSData *notesDocumentData;
@property (readonly, nonatomic) REMCRMergeableStringDocument *notesDocument;
@property (readonly, nonatomic) NSString *notesAsString;
@property (readonly, nonatomic) NSArray *attachments;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMContactRepresentation *contactHandles;
@property (readonly, nonatomic) NSSet *subtaskIDsToUndelete;
@property (readonly, nonatomic) NSSet *hashtagIDsToUndelete;
@property (readonly, nonatomic) NSString *timeZone;
@property (readonly, nonatomic) _Bool allDay;
@property (readonly, nonatomic) long long flagged;
@property (readonly, nonatomic) unsigned long long icsDisplayOrder;
@property (readonly, nonatomic) NSURL *icsUrl;
@property (readonly, nonatomic) NSData *importedICSData;
@property (readonly, nonatomic) NSString *daCalendarItemUniqueIdentifier;
@property (readonly, nonatomic) REMUserActivity *userActivity;
@property (readonly, nonatomic) NSData *siriFoundInAppsData;
@property (readonly, nonatomic) long long siriFoundInAppsUserConfirmation;
@property (readonly, nonatomic) NSDate *lastBannerPresentationDate;
@property (readonly, copy, nonatomic) REMDisplayDate *displayDate;
@property (readonly, nonatomic) _Bool isOverdue;
@property (readonly, nonatomic) _Bool isRecurrent;
@property (readonly, nonatomic) NSDateComponents *effectiveDisplayDateComponents_forCalendar;
@property (readonly, copy, nonatomic) NSString *legacyNotificationIdentifier;
@property (readonly, nonatomic) NSString *primaryLocaleInferredFromLastUsedKeyboard;
@property (readonly, nonatomic) NSSet *assignments;
@property (readonly, nonatomic) REMReminderAssignmentContext *assignmentContext;
@property (readonly, nonatomic) NSSet *hashtags;
@property (readonly, nonatomic) REMReminderHashtagContext *hashtagContext;
@property (readonly, nonatomic) REMReminderUrgentAlarmContext *urgentAlarmContext;
@property (readonly, nonatomic) REMStore *store;
@property (readonly, nonatomic) REMAccount *account;
@property (readonly, nonatomic) REMList *list;
@property (readonly, copy, nonatomic) NSAttributedString *title;
@property (readonly, copy, nonatomic) NSAttributedString *notes;
@property (readonly, nonatomic) _Bool completed;
@property (readonly, copy, nonatomic) NSDate *completionDate;
@property (readonly, nonatomic) unsigned long long priority;
@property (readonly, copy, nonatomic) NSDateComponents *startDateComponents;
@property (readonly, copy, nonatomic) NSDateComponents *dueDateComponents;
@property (readonly, copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) NSDate *lastModifiedDate;
@property (readonly, nonatomic) NSArray *recurrenceRules;
@property (readonly, nonatomic) NSArray *alarms;
@property (readonly, nonatomic) REMReminderAttachmentContext *attachmentContext;
@property (readonly, nonatomic) REMReminderSubtaskContext *subtaskContext;
@property (readonly, nonatomic) REMReminderFlaggedContext *flaggedContext;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) NSString *externalIdentifier;
@property (readonly, nonatomic) NSString *externalModificationTag;
@property (readonly, nonatomic) NSString *daSyncToken;
@property (readonly, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (_Bool)isChangeTrackableFetchableModel;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (id)fetchRequestWithPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;
+ (id)fetchRequestForRemindersListID:(id)id;
+ (id)fetchRequestForRemindersListID:(id)id withSortDescriptors:(id)descriptors;
+ (id)fetchRequestForScheduledRemindersWithDueDateOnOrAfter:(id)after;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (_Bool)shouldUseExternalIdentifierAsDeletionKey;
- (id)initWithStore:(id)store storage:(id)storage;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)forwardingTargetForSelector:(SEL)selector;
- (id)initWithStore:(id)store account:(id)account storage:(id)storage;
- (id)optionalObjectID;
- (id)datesDebugDescriptionInTimeZone:(id)zone;
- (id)initWithStore:(id)store list:(id)list storage:(id)storage;
- (_Bool)isSubtask;

@end


@interface REMReminderAssignmentContext : NSObject

@property (weak, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) REMAssignment *currentAssignment;
@property (readonly, nonatomic) NSSet *assignments;

/* instance methods */
- (id)initWithReminder:(id)reminder;

@end


@interface REMReminderAssignmentContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;
@property (retain, nonatomic) NSMutableSet *mutableAssignments;
@property (readonly, nonatomic) REMAssignment *currentAssignment;
@property (readonly, nonatomic) NSSet *assignments;

/* instance methods */
- (void)addAssignment:(id)assignment;
- (id)addAssignmentWithAssignee:(id)assignee originator:(id)originator status:(long long)status;
- (id)addAssignmentWithAssigneeID:(id)id originatorID:(id)id status:(long long)status;
- (id)initWithReminderChangeItem:(id)item;
- (void)removeAllAssignments;
- (void)removeAssignment:(id)assignment;

@end


@interface REMReminderAttachmentContext : NSObject

@property (retain, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) NSArray *attachments;
@property (readonly, nonatomic) NSArray *fileAttachments;
@property (readonly, nonatomic) NSArray *imageAttachments;
@property (readonly, nonatomic) NSArray *urlAttachments;

/* instance methods */
- (id)initWithReminder:(id)reminder;
- (id)attachmentsOfClass:(Class)_class;

@end


@interface REMReminderAttachmentContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;
@property (retain, nonatomic) NSMutableArray *mutableAttachments;
@property (readonly, nonatomic) NSArray *attachments;
@property (readonly, nonatomic) NSArray *fileAttachments;
@property (readonly, nonatomic) NSArray *imageAttachments;
@property (readonly, nonatomic) NSArray *urlAttachments;

/* instance methods */
- (void)removeAllAttachments;
- (void)addAttachment:(id)attachment;
- (void)removeAttachment:(id)attachment;
- (id)addFileAttachmentWithURL:(id)url error:(id *)error;
- (id)addFileAttachmentWithData:(id)data uti:(id)uti;
- (id)addImageAttachmentWithData:(id)data uti:(id)uti width:(unsigned long long)width height:(unsigned long long)height;
- (id)addImageAttachmentWithURL:(id)url width:(unsigned long long)width height:(unsigned long long)height error:(id *)error;
- (id)addURLAttachmentWithURL:(id)url;
- (id)attachmentsOfClass:(Class)_class;
- (id)initWithReminderChangeItem:(id)item;
- (void)insertAttachment:(id)attachment afterAttachment:(id)attachment;
- (void)insertAttachment:(id)attachment beforeAttachment:(id)attachment;
- (id)newObjectIDForFileAttachment;
- (id)newObjectIDForImageAttachment;
- (id)newObjectIDForURLAttachment;
- (void)removeAllAttachmentsWithClass:(Class)_class;
- (void)removeURLAttachments;
- (id)setURLAttachmentWithURL:(id)url;

@end


@interface REMReminderChangeItem : NSObject <REMConflictResolving, REMSaveRequestTrackedValue, REMExternalSyncMetadataWritableProviding, REMSupportedVersionProviding, REMSupportedVersionUpdating>

@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (nonatomic) _Bool isUrgentStateEnabledForCurrentUser;
@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *listID;
@property (retain, nonatomic) NSArray *attachments;
@property (retain, nonatomic) NSArray *recurrenceRules;
@property (retain, nonatomic) NSSet *assignments;
@property (retain, nonatomic) NSSet *hashtags;
@property (retain, nonatomic) NSSet *subtaskIDsToUndelete;
@property (retain, nonatomic) NSSet *hashtagIDsToUndelete;
@property (retain, nonatomic) NSData *titleDocumentData;
@property (retain, nonatomic) NSData *notesDocumentData;
@property (retain, nonatomic) NSString *primaryLocaleInferredFromLastUsedKeyboard;
@property (readonly, nonatomic) NSString *timeZone;
@property (readonly, nonatomic) _Bool allDay;
@property (nonatomic) unsigned long long icsDisplayOrder;
@property (retain, nonatomic) NSData *importedICSData;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (copy, nonatomic) NSDate *lastModifiedDate;
@property (readonly, nonatomic) NSData *dueDateDeltaAlertsData;
@property (retain, nonatomic) NSArray *dueDateDeltaAlertsToUpsert;
@property (retain, nonatomic) NSSet *dueDateDeltaAlertIdentifiersToDelete;
@property (readonly, nonatomic) REMReminderDueDateDeltaAlertContextChangeItem *dueDateDeltaAlertContext;
@property (readonly, nonatomic) REMDueDateDeltaAlert *fetchedCurrentDueDateDeltaAlert;
@property (retain, nonatomic) NSDate *alternativeDisplayDateDate_forCalendar;
@property (retain, nonatomic) NSUUID *batchCreationID;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMReminderStorage *storage;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (retain, nonatomic) REMObjectID *parentReminderID;
@property (retain, nonatomic) REMCRMergeableStringDocument *titleDocument;
@property (copy, nonatomic) NSString *titleAsString;
@property (retain, nonatomic) REMCRMergeableStringDocument *notesDocument;
@property (copy, nonatomic) NSString *notesAsString;
@property (copy, nonatomic) REMContactRepresentation *contactHandles;
@property (nonatomic) long long flagged;
@property (copy, nonatomic) NSString *daCalendarItemUniqueIdentifier;
@property (copy, nonatomic) REMUserActivity *userActivity;
@property (copy, nonatomic) NSData *siriFoundInAppsData;
@property (nonatomic) long long siriFoundInAppsUserConfirmation;
@property (copy, nonatomic) NSDate *lastBannerPresentationDate;
@property (copy, nonatomic) NSDate *creationDate;
@property (readonly, copy, nonatomic) REMDisplayDate *displayDate;
@property (readonly, nonatomic) _Bool isOverdue;
@property (readonly, nonatomic) _Bool isRecurrent;
@property (readonly, nonatomic) NSDateComponents *effectiveDisplayDateComponents_forCalendar;
@property (readonly, copy, nonatomic) NSString *legacyNotificationIdentifier;
@property (copy, nonatomic) NSURL *icsUrl;
@property (readonly, nonatomic) REMReminderAssignmentContextChangeItem *assignmentContext;
@property (readonly, nonatomic) REMReminderHashtagContextChangeItem *hashtagContext;
@property (readonly, nonatomic) REMReminderUrgentAlarmContextChangeItem *urgentAlarmContext;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (readonly, nonatomic) REMListChangeItem *listChangeItem;
@property (copy, nonatomic) NSAttributedString *title;
@property (copy, nonatomic) NSAttributedString *notes;
@property (nonatomic) _Bool completed;
@property (copy, nonatomic) NSDate *completionDate;
@property (nonatomic) unsigned long long priority;
@property (copy, nonatomic) NSDateComponents *startDateComponents;
@property (copy, nonatomic) NSDateComponents *dueDateComponents;
@property (readonly, nonatomic) NSArray *alarms;
@property (readonly, nonatomic) REMReminderAttachmentContextChangeItem *attachmentContext;
@property (readonly, nonatomic) REMReminderSubtaskContextChangeItem *subtaskContext;
@property (readonly, nonatomic) REMReminderFlaggedContextChangeItem *flaggedContext;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (void)initialize;
+ (void)_ensureDueDateDeltaAlertsAreFetchedIfNecessary:(id)necessary;
+ (id)resolutionTokenKeyForChangedKeyInREMReminderChangeItemOfREMCDReminder:(id)remcdreminder;
+ (id)resolutionTokenKeyForChangedKeyInREMReminderChangeItemOfREMCDSavedReminder:(id)reminder;

/* instance methods */
- (void)addAlarm:(id)alarm;
- (void)removeAlarm:(id)alarm;
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (void)removeFromList;
- (id)addAlarmWithTrigger:(id)trigger;
- (void)addRecurrenceRule:(id)rule;
- (id)initWithReminderChangeItem:(id)item insertIntoListChangeItem:(id)item;
- (void)removeAllRecurrenceRules;
- (void)removeRecurrenceRule:(id)rule;
- (void)decrementRecurrenceRuleEndCount;
- (void)removeAllAlarms;
- (id)_cleanupOriginalAlarmsForSnoozing;
- (void)_copyAlarmsInto:(id)into;
- (void)_createSnoozeAlarmWithDateComponents:(id)components;
- (id)_editDocument:(id)document replicaIDSource:(id)idsource newString:(id)string;
- (double)_timeIntervalToAddSinceStartDate:(id)date withNow:(id)now step:(double)step;
- (void)addAlarm:(id)alarm updateDisplayDate:(_Bool)date;
- (id)addRecurrenceRuleWithFrequency:(long long)frequency interval:(long long)interval daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year weeksOfTheYear:(id)year daysOfTheYear:(id)year setPositions:(id)positions end:(id)end;
- (id)addRecurrenceRuleWithFrequency:(long long)frequency interval:(long long)interval end:(id)end;
- (id)addRecurrenceRuleWithFrequency:(long long)frequency interval:(long long)interval firstDayOfTheWeek:(long long)week daysOfTheWeek:(id)week daysOfTheMonth:(id)month monthsOfTheYear:(id)year weeksOfTheYear:(id)year daysOfTheYear:(id)year setPositions:(id)positions end:(id)end;
- (void)advanceForwardDateAlarmsAfterDate:(id)date;
- (void)advanceForwardRecurrenceAfterNow;
- (void)advanceForwardToNextRecurrenceAfterDate:(id)date;
- (_Bool)canSetAlternativeDisplayDateDateForCalendar;
- (void)cleanupDuplicate:(id)duplicate markAsCompleted:(_Bool)completed;
- (void)clearAlternativeDisplayDateDateForCalendarIfInvalid;
- (void)clearAlternativeDisplayDateDateForCalendarWithReason:(id)reason;
- (id)confirmForSiriFoundInAppsAppendingToList:(id)list;
- (void)copyInto:(id)into;
- (id)datesDebugDescriptionInTimeZone:(id)zone;
- (id)dedupedAndFilteredNonSnoozeAlarms:(id)alarms;
- (id)duplicateForRecurrenceUsingReminderID:(id)id;
- (id)initWithObjectID:(id)id title:(id)title insertIntoListChangeItem:(id)item;
- (id)initWithObjectID:(id)id title:(id)title insertIntoParentReminderSubtaskContextChangeItem:(id)item;
- (id)initWithReminderChangeItem:(id)item insertIntoParentReminderSubtaskContextChangeItem:(id)item;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage accountCapabilities:(id)capabilities observeInitialValues:(_Bool)values;
- (void)insertRecurrenceRule:(id)rule afterRecurrenceRule:(id)rule;
- (void)insertRecurrenceRule:(id)rule beforeRecurrenceRule:(id)rule;
- (_Bool)isSubtask;
- (double)nextRecurrentAdvanceAmountForDateComponents:(id)components afterDate:(id)date;
- (id)nextRecurrentDueDateComponentsAfter:(id)after;
- (void)rejectForSiriFoundInApps;
- (void)removeAlarm:(id)alarm updateDisplayDate:(_Bool)date;
- (void)removeAllSnoozeAlarms;
- (id)removeFromListAllowingUndo;
- (void)removeFromParentReminder;
- (id)removeFromParentReminderAllowingUndo;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (void)setAlarms:(id)alarms updateDisplayDate:(_Bool)date;
- (void)setAlternativeDisplayDateDateForCalendarToPreviousRecurrentDateBefore:(id)before recurrenceRules:(id)rules;
- (void)setAlternativeDisplayDateDateForCalendarWithDateComponents:(id)components;
- (void)setAlternativeDisplayDateDateForCalendarWithNormalizedDate:(id)date;
- (void)setDueDateComponentsWithAlarmsIfNeeded:(id)needed;
- (id)shallowCopyWithSaveRequest:(id)request;
- (void)snoozeForever;
- (void)snoozeFromDueDateForFutureIntegralMultipleOfTimeInterval:(double)interval;
- (void)snoozeFromNowForTimeInterval:(double)interval;
- (void)snoozeToDate:(id)date;
- (void)snoozeToNextThirds;
- (void)updateAccountCapabilities:(id)capabilities;
- (void)updateDisplayDate;

@end


@interface REMReminderDueDateDeltaAlertContext : NSObject

@property (retain, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) NSArray *dueDateDeltaAlerts;
@property (readonly, nonatomic) REMDueDateDeltaAlert *fetchedCurrentDueDateDeltaAlert;

/* instance methods */
- (id)initWithReminder:(id)reminder;

@end


@interface REMReminderDueDateDeltaAlertContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;

/* instance methods */
- (void)_addOrUpdateDueDateDeltaAlert:(id)alert;
- (id)addDueDateDeltaAlertWithDueDateDelta:(id)delta;
- (id)addDueDateDeltaAlertWithDueDateDelta:(id)delta identifier:(id)identifier creationDate:(id)date;
- (id)addDueDateDeltaAlertWithDueDateDeltaAlert:(id)alert;
- (void)clearPendingDueDateDeltaAlertUpserts;
- (id)initWithReminderChangeItem:(id)item;
- (void)removeAllFetchedDueDateDeltaAlerts;
- (void)removeDueDateDeltaAlertsWithIdentifiers:(id)identifiers;
- (id)updateDueDateDeltaAlert:(id)alert;

@end


@interface REMReminderExtractionInput : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSString *text;
@property (readonly, nonatomic) NSURL *url;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithInputText:(id)text;
- (id)initWithInputText:(id)text inputURL:(id)url;
- (id)initWithInputURL:(id)url;

@end


@interface REMReminderExtractionOutput : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSArray *suggestedTitles;
@property (readonly, nonatomic) _Bool isClassifiedAsRecipe;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithSuggestedTitles:(id)titles isClassifiedAsRecipe:(_Bool)recipe;

@end


@interface REMReminderFetchExecutor : _REMFetchExecutor

@property (retain, nonatomic) REMReminderPredicateDescriptor *predicateDescriptor;
@property (retain, nonatomic) NSArray *sortDescriptors;
@property (readonly, nonatomic) unsigned long long options;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors options:(unsigned long long)options;
- (id)resultsFromFetchResult:(id)result inList:(id)list error:(id *)error;
- (id)resultsFromFetchResult:(id)result inParentReminder:(id)reminder error:(id *)error;
- (id)resultsFromFetchResult:(id)result inStore:(id)store error:(id *)error;

@end


@interface REMReminderFetchMetadata : REMFetchMetadata

@property (readonly, nonatomic) NSDictionary *subtaskCounts;
@property (readonly, nonatomic) NSArray *dueDateCounts;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithDueDateCounts:(id)counts;
- (id)initWithSubtaskCounts:(id)counts;
- (id)initWithSubtaskCounts:(id)counts dueDateCounts:(id)counts;

@end


@interface REMReminderFetchMetadataDueDateCount : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) NSDate *dueDate;
@property (readonly, nonatomic) long long count;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithDueDate:(id)date count:(long long)count;

@end


@interface REMReminderFetchOptions : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic) _Bool includeConcealed;
@property (nonatomic) _Bool includeDueDateDeltaAlerts;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)defaultFetchOptions;
+ (id)fetchOptionsIncludingConcealed;
+ (id)fetchOptionsIncludingDueDateDeltaAlerts;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (void)copyFromFetchOptions:(id)options;
- (id)fetchOptionsIncludingConcealed;
- (id)fetchOptionsIncludingDueDateDeltaAlerts;
- (id)initWithIncludeConcealed:(_Bool)concealed includeDueDateDeltaAlerts:(_Bool)alerts;

@end


@interface REMReminderFlaggedContext : NSObject

@property (retain, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) long long flagged;

/* instance methods */
- (id)initWithReminder:(id)reminder;

@end


@interface REMReminderFlaggedContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;
@property (nonatomic) long long flagged;

/* instance methods */
- (id)initWithReminderChangeItem:(id)item;

@end


@interface REMReminderHashtagContext : NSObject

@property (weak, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) NSSet *hashtags;

/* instance methods */
- (id)initWithReminder:(id)reminder;

@end


@interface REMReminderHashtagContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;
@property (retain, nonatomic) NSMutableSet *mutableHashtags;
@property (readonly, nonatomic) NSSet *hashtags;

/* instance methods */
- (void)addHashtag:(id)hashtag;
- (id)addHashtagWithType:(long long)type name:(id)name;
- (id)addHashtagWithType:(long long)type name:(id)name creationDate:(id)date;
- (void)cancelUndeleteHashtagWithID:(id)id;
- (id)initWithReminderChangeItem:(id)item;
- (id)nameWithDisallowedCharactersReplaced:(id)replaced;
- (void)removeAllHashtags;
- (void)removeHashtag:(id)hashtag;
- (void)undeleteHashtagWithID:(id)id;

@end


@interface REMReminderPredicateDescriptor : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long type;
@property (retain, nonatomic) REMObjectID *listID;
@property (retain, nonatomic) REMObjectID *parentReminderID;
@property (retain, nonatomic) NSArray *objectIDs;
@property (retain, nonatomic) NSDate *startingDueDate;
@property (retain, nonatomic) NSDate *endingDueDate;
@property (nonatomic) _Bool completed;
@property (retain, nonatomic) NSArray *descriptors;
@property (retain, nonatomic) NSString *text;
@property (nonatomic) long long textMatching;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)andPredicateDescriptorWithDescriptors:(id)descriptors;
+ (id)orPredicateDescriptorWithDescriptors:(id)descriptors;
+ (id)predicateDescriptorForRemindersWithCompleted:(_Bool)completed;
+ (id)predicateDescriptorForRemindersWithDueDateBetween:(id)between and:(id)_and;
+ (id)predicateDescriptorForRemindersWithTitleContains:(id)contains;
+ (id)predicateDescriptorForRemindersWithDisplayDateBetween:(id)between and:(id)_and;
+ (id)predicateDescriptorForRemindersWithDisplayDateOnOrAfter:(id)after;
+ (id)predicateDescriptorForRemindersWithDisplayDateOnOrBefore:(id)before;
+ (id)predicateDescriptorForRemindersWithDueDateOnOrAfter:(id)after;
+ (id)predicateDescriptorForRemindersWithDueDateOnOrBefore:(id)before;
+ (id)predicateDescriptorForRemindersWithListID:(id)id;
+ (id)predicateDescriptorForRemindersWithObjectIDs:(id)ids;
+ (id)predicateDescriptorForRemindersWithParentReminderID:(id)id;
+ (id)predicateDescriptorForRemindersWithTitleBeginsWith:(id)with;
+ (id)predicateDescriptorForRemindersWithTitleEndsWith:(id)with;
+ (id)predicateDescriptorForRemindersWithTitleEquals:(id)equals;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithType:(long long)type;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithReminderPredicateDescriptor:(id)descriptor;

@end


@interface REMReminderSortDescriptor : NSObject <NSSecureCoding>

@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) _Bool ascending;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)sortDescriptorSortingByCreationDateAscending:(_Bool)ascending;
+ (id)sortDescriptorSortingByDueDateAscending:(_Bool)ascending;
+ (id)sortDescriptorSortingByOrderingInListAscending:(_Bool)ascending;
+ (id)sortDescriptorSortingByPriorityAscending:(_Bool)ascending;
+ (id)sortDescriptorSortingByTitleAscending:(_Bool)ascending;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithType:(long long)type ascending:(_Bool)ascending;

@end


@interface REMReminderStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMExternalSyncMetadataWritableProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) NSString *titleAsString;
@property (retain, nonatomic) NSString *notesAsString;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *listID;
@property (retain, nonatomic) REMObjectID *parentReminderID;
@property (retain, nonatomic) NSData *titleDocumentData;
@property (retain, nonatomic) NSData *notesDocumentData;
@property (retain, nonatomic) NSString *primaryLocaleInferredFromLastUsedKeyboard;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (nonatomic) _Bool completed;
@property (copy, nonatomic) NSDate *completionDate;
@property (retain, nonatomic) NSSet *subtaskIDsToUndelete;
@property (retain, nonatomic) NSSet *hashtagIDsToUndelete;
@property (nonatomic) unsigned long long priority;
@property (copy, nonatomic) NSDateComponents *startDateComponents;
@property (copy, nonatomic) NSDateComponents *dueDateComponents;
@property (copy, nonatomic) NSString *timeZone;
@property (nonatomic) _Bool allDay;
@property (copy, nonatomic) NSDate *creationDate;
@property (copy, nonatomic) NSDate *lastModifiedDate;
@property (retain, nonatomic) NSArray *recurrenceRules;
@property (retain, nonatomic) NSArray *attachments;
@property (retain, nonatomic) NSArray *alarms;
@property (retain, nonatomic) REMContactRepresentation *contactHandles;
@property (nonatomic) unsigned long long icsDisplayOrder;
@property (copy, nonatomic) NSURL *icsUrl;
@property (retain, nonatomic) NSData *importedICSData;
@property (copy, nonatomic) NSString *daCalendarItemUniqueIdentifier;
@property (copy, nonatomic) REMUserActivity *userActivity;
@property (retain, nonatomic) NSUUID *batchCreationID;
@property (copy, nonatomic) NSData *siriFoundInAppsData;
@property (nonatomic) long long siriFoundInAppsUserConfirmation;
@property (copy, nonatomic) NSDate *lastBannerPresentationDate;
@property (nonatomic) long long flagged;
@property (readonly, nonatomic) _Bool isOverdue;
@property (readonly, nonatomic) _Bool isRecurrent;
@property (retain, nonatomic) NSSet *assignments;
@property (retain, nonatomic) NSSet *hashtags;
@property (nonatomic) _Bool isUrgentStateEnabledForCurrentUser;
@property (retain, nonatomic) REMTriggersContext *triggersContext;
@property (retain, nonatomic) NSData *dueDateDeltaAlertsData;
@property (retain, nonatomic) NSArray *dueDateDeltaAlertsToUpsert;
@property (retain, nonatomic) NSSet *dueDateDeltaAlertIdentifiersToDelete;
@property (retain, nonatomic) NSDate *alternativeDisplayDateDate_forCalendar;
@property (copy, nonatomic) REMDisplayDate *displayDate;
@property (readonly, copy, nonatomic) NSString *legacyNotificationIdentifier;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (copy, nonatomic) NSString *externalIdentifier;
@property (copy, nonatomic) NSString *externalModificationTag;
@property (copy, nonatomic) NSString *daSyncToken;
@property (copy, nonatomic) NSString *daPushKey;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (_Bool)isDate:(id)date overdueAtReferenceDate:(id)date allDay:(_Bool)day floatingDateSecondsFromGMT:(long long)gmt floatingDateTargetTimeZone:(id)zone showAllDayRemindersAsOverdue:(_Bool)overdue showTimedRemindersAsOverdue:(_Bool)overdue;
+ (id)notesReplicaIDSourceWithAccountID:(id)id reminderID:(id)id;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)titleReplicaIDSourceWithAccountID:(id)id reminderID:(id)id;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)storeGeneration;
- (id)debugDescription;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)description;
- (_Bool)isUnsupported;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (_Bool)isCompleted;
- (id)optionalObjectID;
- (id)initWithCoder:(id)coder;
- (id)currentAssignment;
- (id)datesDebugDescriptionInTimeZone:(id)zone;
- (id)effectiveDisplayDateComponents_forCalendar;
- (id)fetchedDueDateDeltaAlerts;
- (_Bool)hasUnfetchedDueDateDeltaAlerts;
- (id)initWithObjectID:(id)id listID:(id)id accountID:(id)id;
- (id)notesDocument;
- (id)notesReplicaIDSource;
- (void)setAlternativeDisplayDateDateForCalendarWithDateComponents:(id)components;
- (void)setFetchedDueDateDeltaAlerts:(id)alerts;
- (void)setNotesAsStringByCDIngestor:(id)cdingestor;
- (void)setNotesDocument:(id)document;
- (void)setTitleAsStringByCDIngestor:(id)cdingestor;
- (void)setTitleDocument:(id)document;
- (id)titleDocument;
- (id)titleReplicaIDSource;
- (void)updateDisplayDate;

@end


@interface REMReminderSubtaskContext : NSObject

@property (retain, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) REMReminder *parentReminder;

/* instance methods */
- (id)fetchRemindersWithError:(id *)error;
- (id)initWithReminder:(id)reminder;
- (id)fetchObjectIDsOfCompletedSubtasksWithError:(id *)error;
- (id)fetchObjectIDsOfUnsupportedSubtasksWithError:(id *)error;
- (id)fetchRemindersForMovingWithError:(id *)error;
- (id)fetchRemindersForMovingWithFetchOptions:(id)options error:(id *)error;
- (id)fetchRemindersWithFetchOptions:(id)options error:(id *)error;
- (id)fetchSubtasksMarkedForDeletionWithError:(id *)error;
- (long long)fetchSubtasksMasksIncludingConcealedWithError:(id *)error;
- (long long)fetchSubtasksMasksWithError:(id *)error;
- (_Bool)hasSubtasksWithError:(id *)error;

@end


@interface REMReminderSubtaskContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;

/* instance methods */
- (void)addReminderChangeItem:(id)item;
- (id)_listChangeItem;
- (id)initWithReminderChangeItem:(id)item;
- (void)insertReminderChangeItem:(id)item afterReminderChangeItem:(id)item;
- (void)insertReminderChangeItem:(id)item beforeReminderChangeItem:(id)item;
- (void)undeleteSubtaskWithID:(id)id usingUndo:(id)undo;

@end


@interface REMReminderUrgentAlarmContext : NSObject

@property (weak, nonatomic) REMReminder *reminder;
@property (readonly, nonatomic) _Bool isUrgentStateEnabledForCurrentUser;

/* instance methods */
- (id)initWithReminder:(id)reminder;

@end


@interface REMReminderUrgentAlarmContextChangeItem : NSObject

@property (retain, nonatomic) REMReminderChangeItem *reminderChangeItem;
@property (nonatomic) _Bool isUrgentStateEnabledForCurrentUser;

/* instance methods */
- (id)initWithReminderChangeItem:(id)item;

@end


@interface REMRemindersDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* class methods */
+ (id)remindersFromAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages store:(id)store;
+ (id)remindersFromAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages store:(id)store requestedReminderIDs:(id)ids;
+ (id)remindersFromAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages store:(id)store requestedStringIdentifiers:(id)identifiers identifierSelector:(SEL)selector;
+ (id)remindersFromAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages store:(id)store showMarkedForDeleteObjects:(_Bool)objects;

/* instance methods */
- (id)fetchRemindersWithDACalendarItemUniqueIdentifiers:(id)identifiers inList:(id)list error:(id *)error;
- (id)initWithStore:(id)store;
- (id)fetchReminderWithDACalendarItemUniqueIdentifier:(id)identifier inList:(id)list error:(id *)error;
- (id)fetchSubtasksOfParentReminderChangeItem:(id)item subtaskFetchOption:(long long)option reminderFetchOptions:(id)options error:(id *)error;
- (id)fetchRemindersWithExternalIdentifiers:(id)identifiers inList:(id)list error:(id *)error;
- (id)fetchRemindersCountWithListID:(id)id includingCompleted:(_Bool)completed error:(id *)error;
- (id)fetchRemindersCountWithBatchCreationID:(id)id includingCompleted:(_Bool)completed error:(id *)error;
- (id)fetchObjectIDsOfRemindersWithParentReminderID:(id)id includeIncomplete:(_Bool)incomplete includeCompleted:(_Bool)completed isUnsupported:(_Bool)unsupported error:(id *)error;
- (id)fetchRemindersWithBatchCreationID:(id)id includingCompleted:(_Bool)completed error:(id *)error;
- (id)fetchRemindersCountWithParentReminderID:(id)id error:(id *)error;
- (id)fetchReminderWithExternalIdentifier:(id)identifier inList:(id)list error:(id *)error;
- (id)fetchReminderWithMostRecentLastModifiedDateInListID:(id)id error:(id *)error;
- (id)fetchReminderWithObjectID:(id)id fetchOptions:(id)options error:(id *)error;
- (id)fetchRemindersWithParentReminderIDs:(id)ids error:(id *)error;
- (long long)fetchSubtasksMasksWithParentReminderID:(id)id includingConcealed:(_Bool)concealed error:(id *)error;
- (id)fetchRemindersWithObjectIDs:(id)ids fetchOptions:(id)options error:(id *)error;
- (id)fetchSubtasksOfParentReminder:(id)reminder subtaskFetchOption:(long long)option reminderFetchOptions:(id)options error:(id *)error;
- (id)fetchAllRemindersWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)fetchRemindersWithListID:(id)id includingSubtasks:(_Bool)subtasks includingCompleted:(_Bool)completed error:(id *)error;
- (id)fetchRemindersMatchingPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors options:(id)options error:(id *)error;
- (id)fetchRemindersWithParentReminderID:(id)id accountID:(id)id subtaskFetchOption:(long long)option reminderFetchOptions:(id)options error:(id *)error;
- (id)fetchRemindersWithLocationAlarmsIncludingCompleted:(_Bool)completed error:(id *)error;
- (id)fetchRemindersIncludingUnsupportedWithObjectIDs:(id)ids error:(id *)error;

@end


@interface REMRemindersDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountStorages;
@property (readonly, nonatomic) NSArray *listStorages;
@property (readonly, nonatomic) NSArray *reminderStorages;
@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithAccountStorages:(id)storages listStorages:(id)storages reminderStorages:(id)storages objectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersDataViewInvocation_fetchByBatchCreationID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSUUID *batchCreationID;
@property (readonly, nonatomic) _Bool includingCompleted;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithBatchCreationID:(id)id includingCompleted:(_Bool)completed;

@end


@interface REMRemindersDataViewInvocation_fetchByDACalendarItemUniqueIdentifier : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *daCalendarItemUniqueIdentifiers;
@property (readonly, nonatomic) REMObjectID *listObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithDACalendarItemUniqueIdentifiers:(id)identifiers listObjectID:(id)id;

@end


@interface REMRemindersDataViewInvocation_fetchByExternalIdentifier : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *externalIdentifiers;
@property (readonly, nonatomic) REMObjectID *listObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithExternalIdentifiers:(id)identifiers listObjectID:(id)id;

@end


@interface REMRemindersDataViewInvocation_fetchByListID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) _Bool includingSubtasks;
@property (readonly, nonatomic) _Bool includingCompleted;
@property (readonly, nonatomic) REMObjectID *listID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListID:(id)id includingSubtasks:(_Bool)subtasks includingCompleted:(_Bool)completed;

@end


@interface REMRemindersDataViewInvocation_fetchByObjectID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;
@property (readonly, nonatomic) REMReminderFetchOptions *fetchOptions;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectIDs:(id)ids fetchOptions:(id)options;

@end


@interface REMRemindersDataViewInvocation_fetchByParentReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *parentReminderID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) long long subtaskFetchOption;
@property (readonly, nonatomic) REMReminderFetchOptions *reminderFetchOptions;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentReminderID:(id)id accountID:(id)id subtaskFetchOption:(long long)option reminderFetchOptions:(id)options;

@end


@interface REMRemindersDataViewInvocation_fetchByParentReminderIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *parentReminderIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentReminderIDs:(id)ids;

@end


@interface REMRemindersDataViewInvocation_fetchByPredicateDescriptor : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMReminderPredicateDescriptor *predicateDescriptor;
@property (readonly, nonatomic) NSArray *sortDescriptors;
@property (readonly, nonatomic) REMReminderFetchOptions *options;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors options:(id)options;

@end


@interface REMRemindersDataViewInvocation_fetchMostRecentLastModifiedByListID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListID:(id)id;

@end


@interface REMRemindersDataViewInvocation_fetchReminderIDsByParentReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *parentReminderID;
@property (readonly, nonatomic) _Bool includeIncomplete;
@property (readonly, nonatomic) _Bool includeCompleted;
@property (readonly, nonatomic) _Bool isUnsupported;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentReminderID:(id)id includeIncomplete:(_Bool)incomplete includeCompleted:(_Bool)completed isUnsupported:(_Bool)unsupported;

@end


@interface REMRemindersDataViewInvocation_fetchRemindersCountByBatchCreationID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSUUID *batchCreationID;
@property (readonly, nonatomic) _Bool includingCompleted;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithBatchCreationID:(id)id includingCompleted:(_Bool)completed;

@end


@interface REMRemindersDataViewInvocation_fetchRemindersCountByListID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listID;
@property (readonly, nonatomic) _Bool includingCompleted;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListID:(id)id includingCompleted:(_Bool)completed;

@end


@interface REMRemindersDataViewInvocation_fetchRemindersCountByParentReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *parentReminderID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentReminderID:(id)id;

@end


@interface REMRemindersDataViewInvocation_fetchRemindersWithLocationAlarms : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) _Bool includingCompleted;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithIncludingCompleted:(_Bool)completed;

@end


@interface REMRemindersDataViewInvocation_fetchSubtasksMasksByParentReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *parentReminderID;
@property (nonatomic) _Bool includingConcealed;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentReminderID:(id)id includingConcealed:(_Bool)concealed;

@end


@interface REMReplicaEntry : NSObject

@property (nonatomic) unsigned int replicaUUIDIndex;
@property (retain, nonatomic) REMClockElementList *clockElementList;
@property (nonatomic) _Bool inUse;
@property (nonatomic) id <REMReplicaManagerClient> client;

/* instance methods */
- (id)description;
- (void)encodeIntoEntryArchive:(void *)archive;
- (_Bool)hasEqualPersistedPropertiesAs:(id)as;
- (id)initWithEntryArchive:(const void *)archive;
- (id)initWithReplicaUUIDIndex:(unsigned int)uuidindex clockElementList:(id)list inUse:(_Bool)use forClient:(id)client;
- (id)persistenceDescription;

@end


@interface REMReplicaIDHelper : NSObject <REMReplicaManagerClient>

@property (retain, nonatomic) REMReplicaIDSource *replicaIDSource;
@property (weak, nonatomic) id <REMReplicaIDHelperOwner> owner;
@property (retain, nonatomic) NSUUID *acquiredReplicaUUID;
@property (retain, nonatomic) id <REMReplicaManagerProviding> lazilyCachedReplicaManagerProvider;
@property (readonly, nonatomic) REMReplicaManager *replicaManager;
@property (retain, nonatomic) id <REMReplicaClockProviding> replicaClockProvider;
@property (readonly, nonatomic) NSString *crdtID;
@property (readonly, nonatomic) NSUUID *replicaUUID;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)nonEditingReplicaUUID;
+ (id)replicaUUIDForCreation;

/* instance methods */
- (void)dealloc;
- (id)clockElementListForReplicaUUID:(id)uuid;
- (void)didCopy;
- (void)didSerialize;
- (id)initWithReplicaIDSource:(id)idsource owner:(id)owner replicaClockProvider:(id)provider;
- (void)willEdit;

@end


@interface REMReplicaIDSource : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *crdtID;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)crdtIDWithObjectID:(id)id property:(id)property;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithAccountID:(id)id crdtID:(id)id;
- (id)initWithAccountID:(id)id objectID:(id)id property:(id)property;

@end


@interface REMReplicaManager : NSObject

@property (nonatomic) struct os_unfair_lock_s ivarLock;
@property (nonatomic) _Bool isPersistable;
@property (retain, nonatomic) NSMutableOrderedSet *replicaUUIDs;
@property (retain, nonatomic) NSMutableDictionary *replicaEntries;
@property (nonatomic) unsigned long long currentVersion;
@property (nonatomic) unsigned long long maxLastSavedVersion;
@property (nonatomic) _Bool exceededMaxSerializedSize;

/* class methods */
+ (id)unsavedReplicaManagersForAccountIDs:(id)ids;
+ (_Bool)supportsSecureCoding;
+ (void)setReplicaManager:(id)manager forAccountID:(id)id;
+ (_Bool)disablesInMemoryOnlyCheck;
+ (id)replicaManagerForAccountID:(id)id store:(id)store;
+ (id)replicaManagerIfLoadedForAccountID:(id)id;
+ (id)replicaManagerWithSerializedData:(id)data error:(id *)error;
+ (void)setDisablesInMemoryOnlyCheck:(_Bool)check;
+ (_Bool)shouldUseNewInMemoryOnlyReplicaManager;

/* instance methods */
- (void)commonInit;
- (id)description;
- (id)init;
- (_Bool)hasUnsavedChanges;
- (id)initWithArchive:(const void *)archive error:(id *)error;
- (void)didSaveVersion:(unsigned long long)version;
- (id)l_checkoutReplicaUUIDForClient:(id)client;
- (void)addRandomReplicaEntriesWithCount:(long long)count;
- (id)availabilityOfFirstReplicaForCRDTID:(id)crdtid;
- (id)checkoutReplicaUUIDForClient:(id)client;
- (id)clockOfFirstReplicaForCRDTID:(id)crdtid;
- (void)encodeIntoArchive:(void *)archive;
- (_Bool)hasEqualPersistedEntriesAs:(id)as;
- (id)l_replicaEntriesDescriptionForPersistence:(_Bool)persistence;
- (id)l_replicaUUIDsDescription;
- (id)l_serializedDataWithError:(id *)error;
- (_Bool)l_updateVersionOfEntry:(id)entry forClient:(id)client;
- (void)modifyReplicaEntryForClient:(id)client block:(id /* block */)block;
- (void)performLocked:(id /* block */)locked;
- (id)persistenceDescription;
- (unsigned long long)replicaEntryCount;
- (void)returnReplicaForClient:(id)client;
- (id)serializedDataCappedAtMaxSize:(_Bool)size error:(id *)error;
- (void)updateVersionForClient:(id)client;

@end


@interface REMReplicaManagerSerializedData : NSObject <NSSecureCoding>

@property (readonly, nonatomic) _Bool isRepresentingDiscardedReplicaManager;
@property (readonly, nonatomic) NSData *managerData;
@property (readonly, nonatomic) unsigned long long version;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)serializedDataRepresentingDiscardedReplicaManager;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)initWithManagerData:(id)data version:(unsigned long long)version;

@end


@interface REMResolutionToken : NSObject <NSSecureCoding, NSCopying, REMNonceGenerating>

@property (nonatomic) long long counter;
@property (nonatomic) double modificationTime;
@property (retain, nonatomic) NSUUID *replicaID;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)resolutionTokenWithJSONObject:(id)jsonobject;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (void)update;
- (long long)compare:(id)compare;
- (id)description;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (double)generateNonce;
- (id)initWithCounter:(long long)counter modificationTime:(double)time replicaID:(id)id;
- (id)initWithDefaultValue;

@end


@interface REMResolutionTokenMap : NSObject <NSSecureCoding, NSCopying>

@property (retain, nonatomic) NSMutableDictionary *map;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)mapWithData:(id)data;
+ (id)resolutionTokenMapWithJSONData:(id)jsondata keyMap:(id)map;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)init;
- (id)archivedData;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithMap:(id)map;
- (long long)compare:(id)compare forKey:(id)key;
- (id)getTokenForKey:(id)key;
- (long long)compareAndMergeWithMap:(id)map forKey:(id)key;
- (void)forceMergeFromMap:(id)map forKey:(id)key;
- (id)getTokenKeys;
- (void)initTokenWithDefaultValueIfNecessaryForKey:(id)key;
- (_Bool)mergeWithMap:(id)map forKey:(id)key;
- (void)setToken:(id)token forKey:(id)key;
- (void)updateForKey:(id)key;

@end


@interface REMSaveRequest : NSObject

@property (readonly, nonatomic) NSMutableDictionary *trackedTemplateChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedListSectionChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedSmartListSectionChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedTemplateSectionChangeItems;
@property (retain, nonatomic) NSMutableSet *saveRequestChangeEvents;
@property (copy, nonatomic) NSString *author;
@property (nonatomic) _Bool saved;
@property (readonly, nonatomic) NSMutableDictionary *trackedAccountChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedListChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedSmartListChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedReminderChangeItems;
@property (readonly, nonatomic) NSMutableDictionary *trackedAccountCapabilities;
@property (nonatomic) _Bool updateLastModifiedDates;
@property (nonatomic) _Bool saveIsNoopIfNoChangedKeys;
@property (nonatomic) _Bool cloneCompletedRecurrentRemindersAtSave;
@property (nonatomic) _Bool applyCRDTsWithoutMerging;
@property (nonatomic) _Bool syncToCloudKit;
@property (retain, nonatomic) id <REMReplicaManagerProviding> replicaManagerProvider;
@property (weak, nonatomic) id <REMSaveRequestNotifyChangeDelegate> notifyChangeDelegate;
@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (void)_prepareSave:(id /* block */)save;
- (void)_updateTrackedReminderChangeItem:(id)item withObjectID:(id)id;
- (id)updateAccount:(id)account;
- (id)initWithStore:(id)store;
- (id)addTemplateSectionWithDisplayName:(id)name toTemplateSectionContextChangeItem:(id)item templateSectionObjectID:(id)id;
- (void)updateUIDInReminderChangeItem:(id)item fromICSComponent:(id)icscomponent icsCalendar:(id)calendar;
- (id)_iCalendarDataFromICSTodoItem:(id)item icsCalendar:(id)calendar;
- (id)_updateListWithReminderChangeItem:(id)item;
- (id)_trackedTemplateSectionChangeItemForObjectID:(id)id;
- (void)preFetchDueDateDeltaAlertsForCompletedRecurrenceClone;
- (_Bool)updateReminderChangeItem:(id)item fromICSData:(id)icsdata isNew:(_Bool)_new withOptions:(id)options error:(id *)error;
- (id)addReminderWithTitle:(id)title toReminderSubtaskContextChangeItem:(id)item;
- (void)_trackAccountChangeItem:(id)item;
- (void)_trackListSectionChangeItem:(id)item;
- (void)_trackTemplateSectionChangeItem:(id)item;
- (id)addListWithName:(id)name toAccountChangeItem:(id)item listObjectID:(id)id;
- (id)addReminderWithTitle:(id)title toListChangeItem:(id)item;
- (id)addTemplateSectionWithDisplayName:(id)name toTemplateSectionContextChangeItem:(id)item;
- (id)updateSmartListSection:(id)section;
- (id)updateTemplate:(id)_template;
- (void)_willSaveAccountChangeItems:(id)items listChangeItems:(id)items listSectionChangeItems:(id)items smartListChangeItems:(id)items smartListSectionChangeItems:(id)items templateChangeItems:(id)items templateSectionChangeItems:(id)items reminderChangeItems:(id)items;
- (id)_updateAccountWithListChangeItem:(id)item;
- (id)_trackedSmartListChangeItemForObjectID:(id)id;
- (void)performPreSaveActions;
- (id)_addAccountWithType:(long long)type name:(id)name;
- (id)addListSectionWithDisplayName:(id)name toListSectionContextChangeItem:(id)item listSectionObjectID:(id)id;
- (id)_addTestOnlyLocalInternalAccountWithName:(id)name accountObjectID:(id)id;
- (id)addListSectionWithDisplayName:(id)name toListSectionContextChangeItem:(id)item;
- (id)_addTestOnlyNonPrimaryCKAccountWithName:(id)name accountObjectID:(id)id;
- (id)addListWithName:(id)name toAccountChangeItem:(id)item;
- (id)addSmartListSectionWithDisplayName:(id)name toSmartListSectionContextChangeItem:(id)item;
- (id)advanceForwardRecurrenceAfterNowAndAndCreateCompletedCloneWithoutRecurrenceRulesAndSubtasks;
- (id)addSmartListSectionWithDisplayName:(id)name toSmartListSectionContextChangeItem:(id)item smartListSectionObjectID:(id)id;
- (id)_copyReminder:(id)reminder toReminderSubtaskContextChangeItem:(id)item;
- (id)_copyReminderChangeItem:(id)item toListChangeItem:(id)item;
- (void)_populateReminderChangeItem:(id)item withICSTodoItem:(id)item icsCalendar:(id)calendar isNew:(_Bool)_new withOptions:(id)options;
- (id)_trackedListChangeItemForObjectID:(id)id;
- (id)addCustomSmartListWithName:(id)name toListSublistContextChangeItem:(id)item smartListObjectID:(id)id;
- (id)_copyReminder:(id)reminder toListChangeItem:(id)item;
- (id)_addLocalAccountWithName:(id)name;
- (id)addTemplateWithName:(id)name configuration:(id)configuration toAccountChangeItem:(id)item;
- (id)description;
- (id)_addExchangeAccountWithName:(id)name;
- (void)_trackSmartListChangeItem:(id)item;
- (id)updateList:(id)list;
- (void)_trackListChangeItem:(id)item;
- (void)_populateAlarmsInReminderChangeItem:(id)item withICSAlarms:(id)icsalarms icsCalendar:(id)calendar;
- (id)__addAccountWithType:(long long)type name:(id)name accountObjectID:(id)id;
- (id)_trackedTemplateChangeItemForObjectID:(id)id;
- (void)_updateResolutionTokenMapForChangeItem:(id)item;
- (id)importRemindersFromICSData:(id)icsdata insertIntoListChangeItem:(id)item error:(id *)error;
- (void)_populateRecurrencesInReminderChangeItem:(id)item withICSComponent:(id)icscomponent icsCalendar:(id)calendar;
- (void)_updateTrackedAccountChangeItem:(id)item withObjectID:(id)id;
- (id)_trackedListSectionChangeItemForObjectID:(id)id;
- (id)_addLocalAccountWithName:(id)name accountObjectID:(id)id;
- (void)_trackAccountCapabilities:(id)capabilities forObjectID:(id)id;
- (id)_addExchangeAccountWithName:(id)name accountObjectID:(id)id;
- (id)_trackedReminderChangeItemForObjectID:(id)id;
- (id)updateTemplateSection:(id)section;
- (id)_trackedSmartListSectionChangeItemForObjectID:(id)id;
- (void)_trackSmartListSectionChangeItem:(id)item;
- (id)__addAccountWithType:(long long)type name:(id)name;
- (id)addReminderWithTitle:(id)title toListChangeItem:(id)item reminderObjectID:(id)id;
- (_Bool)saveSynchronouslyWithError:(id *)error;
- (id)advanceForwardRecurrenceAndCreateCompletedCloneWithoutRecurrenceRulesAndSubtasksAfterDate:(id /* block */)date;
- (void)saveWithQueue:(id)queue completion:(id /* block */)completion;
- (_Bool)_changeItemsAreAllEmpty;
- (id)addGroupWithName:(id)name toAccountGroupContextChangeItem:(id)item;
- (id)_copyReminderChangeItem:(id)item toReminderSubtaskContextChangeItem:(id)item;
- (id)addListWithName:(id)name toListSublistContextChangeItem:(id)item listObjectID:(id)id;
- (id)addListWithName:(id)name toListSublistContextChangeItem:(id)item;
- (id)_addTestOnlyPrimaryCKAccountWithName:(id)name;
- (void)_trackReminderChangeItem:(id)item;
- (id)addTemplateWithName:(id)name configuration:(id)configuration toAccountChangeItem:(id)item templateObjectID:(id)id;
- (id)addListUsingPublicTemplateWithREMListRepresentation:(id)representation toAccountChangeItem:(id)item;
- (void)notifyChangeDelegateForSaveSuccess:(_Bool)success;
- (id)_updateListStorage:(id)storage accountCapabilities:(id)capabilities;
- (void)_updateTrackedListChangeItem:(id)item withObjectID:(id)id;
- (id)_trackedAccountChangeItemForObjectID:(id)id;
- (id)_addCalDavAccountWithName:(id)name accountObjectID:(id)id;
- (id)_addTestOnlyExtraPrimaryCKAccountWithName:(id)name;
- (id)advanceForwardRecurrenceAfterNowAndCreateIncompleteCloneWithoutRecurrenceRulesAndSubtasks;
- (id)_addTestOnlyNonPrimaryCKAccountWithName:(id)name;
- (id)_trackedAccountCapabilitiesForObjectID:(id)id;
- (void)preFlightActionSaveAndUpdateParentsOfRecurrentSubtasksWithLogPrefix:(id)prefix;
- (void)_updateTrackedSmartListChangeItem:(id)item withObjectID:(id)id;
- (id)updateListSection:(id)section;
- (id)addCustomSmartListWithName:(id)name toAccountChangeItem:(id)item smartListObjectID:(id)id;
- (id)_addTestOnlyLocalInternalAccountWithName:(id)name;
- (id)addReminderWithTitle:(id)title toReminderSubtaskContextChangeItem:(id)item reminderObjectID:(id)id;
- (id)_addCalDavAccountWithName:(id)name;
- (id)addGroupWithName:(id)name toAccountGroupContextChangeItem:(id)item groupObjectID:(id)id;
- (id)updateReminder:(id)reminder;
- (id)updateSmartList:(id)list;
- (id)_addTestOnlyExtraPrimaryCKAccountWithName:(id)name accountObjectID:(id)id;
- (void)_addAlarmsToReminderChangeItem:(id)item withICSAlarm:(id)icsalarm icsCalendar:(id)calendar;
- (id)_addTestOnlyPrimaryCKAccountWithName:(id)name accountObjectID:(id)id;
- (void)_trackTemplateChangeItem:(id)item;
- (void)updateReminderChangeItem:(id)item fromICSTodo:(id)icstodo icsCalendar:(id)calendar isNew:(_Bool)_new withOptions:(id)options;
- (id)_addAccountWithType:(long long)type name:(id)name accountObjectID:(id)id;
- (_Bool)isSaved;
- (id)addListUsingTemplate:(id)_template toAccountChangeItem:(id)item;
- (id)icsDueOrEndDateWithICSCalendarItem:(id)item options:(id)options;

@end


@interface REMSaveRequestTrackedValueContainer : NSObject

@property (weak, nonatomic) id <REMSaveRequestTrackedValue> weakValue;
@property (retain, nonatomic) id <REMSaveRequestTrackedValue> template;

/* instance methods */
- (id)initWithValue:(id)value;
- (id)valueForSaveRequest:(id)request;
- (id)valueWithoutPerformingCopy;

@end


@interface REMSecondaryGroceryLocale : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSLocale *locale;
@property (readonly, nonatomic) _Bool isAutomatic;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithLocale:(id)locale isAutomatic:(_Bool)automatic;

@end


@interface REMSharedEntitySyncActivity : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSString *accountIdentifier;
@property (readonly, nonatomic) NSDate *activityDate;
@property (readonly, nonatomic) long long activityType;
@property (readonly, nonatomic) NSString *authorUserRecordIDString;
@property (readonly, nonatomic) NSString *ckParentCloudObjectEntityName;
@property (readonly, nonatomic) NSString *ckParentCloudObjectIdentifier;
@property (readonly, nonatomic) NSString *ckIdentifier;
@property (readonly, nonatomic) NSString *sharedEntityName;
@property (readonly, nonatomic) NSUUID *uuidForChangeTracking;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (id)activityTypeDescription;
- (id)initWithAccountIdentifier:(id)identifier activityDate:(id)date activityType:(long long)type authorUserRecordIDString:(id)idstring ckParentCloudObjectEntityName:(id)name ckParentCloudObjectIdentifier:(id)identifier ckIdentifier:(id)identifier sharedEntityName:(id)name uuidForChangeTracking:(id)tracking;

@end


@interface REMSharedToMeReminderPlaceholder : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableModel, NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (_Bool)supportsSecureCoding;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)objectIdentifier;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id;
- (_Bool)isEqualToSharedToMeReminderPlaceholder:(id)placeholder;

@end


@interface REMSharee : NSObject <_REMDAChangeTrackableModel, REMDAChangeTrackableModel, NSSecureCoding, NSCopying, REMObjectIDProviding>

@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) NSString *externalIdentifierForMarkedForDeletionObject;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) NSString *firstName;
@property (readonly, nonatomic) NSString *middleName;
@property (readonly, nonatomic) NSString *lastName;
@property (readonly, nonatomic) NSString *namePrefix;
@property (readonly, nonatomic) NSString *nameSuffix;
@property (readonly, nonatomic) NSString *nickname;
@property (readonly, nonatomic) NSPersonNameComponents *personNameComponents;
@property (readonly, nonatomic) NSString *address;
@property (readonly, nonatomic) long long status;
@property (readonly, nonatomic) long long accessLevel;
@property (readonly, nonatomic) REMObjectID *listID;
@property (readonly, nonatomic) REMObjectID *remObjectID;

/* class methods */
+ (_Bool)rem_DA_supportsFetching;
+ (id)objectIDWithUUID:(id)uuid;
+ (id /* block */)rem_DA_fetchByObjectIDsBlock;
+ (_Bool)supportsSecureCoding;
+ (id /* block */)rem_DA_deletedKeyFromConcealedModelObjectBlock;
+ (id)rem_DA_propertiesAffectingIsConcealed;
+ (id /* block */)rem_DA_deletedKeyFromTombstoneBlock;
+ (id)cdEntityName;
+ (_Bool)rem_DA_supportsConcealedObjects;
+ (_Bool)isChangeTrackableModel;
+ (id)newObjectID;
+ (id)nullifiedAssignmentOriginatorID;
+ (id /* block */)rem_DA_fetchByObjectIDBlock;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)formattedName;
- (id)shortName;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (_Bool)isEqualToSharee:(id)sharee;
- (id)initShareeWithObjectID:(id)id accountID:(id)id listID:(id)id displayName:(id)name firstName:(id)name lastName:(id)name address:(id)address status:(long long)status accessLevel:(long long)level;
- (id)formattedNameWithStyle:(long long)style;
- (id)initShareeWithObjectID:(id)id accountID:(id)id listID:(id)id displayName:(id)name firstName:(id)name middleName:(id)name lastName:(id)name namePrefix:(id)prefix nameSuffix:(id)suffix nickname:(id)nickname address:(id)address status:(long long)status accessLevel:(long long)level;
- (id)initShareeWithObjectID:(id)id accountID:(id)id listID:(id)id personNameComponents:(id)components address:(id)address status:(long long)status accessLevel:(long long)level;

@end


@interface REMSignpost : NSObject

/* class methods */
+ (id)sync;
+ (id)database;

@end


@interface REMSiriSearchLimitedDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchRemindersMatchingTitle:(id)title dueAfter:(id)after dueBefore:(id)before isCompleted:(id)completed hasLocation:(id)location location:(id)location error:(id *)error;

@end


@interface REMSiriSearchLimitedDataViewInvocation_fetchReminders : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSDate *dueAfter;
@property (readonly, nonatomic) NSDate *dueBefore;
@property (readonly, nonatomic) NSNumber *completed;
@property (readonly, nonatomic) NSNumber *hasLocation;
@property (readonly, nonatomic) NSString *location;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithTitle:(id)title dueAfter:(id)after dueBefore:(id)before isCompleted:(id)completed hasLocation:(id)location location:(id)location;

@end


@interface REMSmartList : NSObject <REMObjectIDProviding, REMSupportedVersionProviding>

@property (retain, nonatomic) REMAccount *account;
@property (retain, nonatomic) REMList *parentList;
@property (copy, nonatomic) REMSmartListStorage *storage;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMObjectID *parentAccountID;
@property (readonly, nonatomic) REMObjectID *parentListID;
@property (readonly, nonatomic) NSDate *pinnedDate;
@property (readonly, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (readonly, nonatomic) _Bool isOriginOfExistingTemplate;
@property (readonly, nonatomic) NSSet *sectionIDsToUndelete;
@property (readonly, nonatomic) REMSmartListSectionContext *sectionContext;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) REMColor *color;
@property (readonly, nonatomic) NSString *badgeEmblem;
@property (readonly, nonatomic) _Bool isPinned;
@property (readonly, nonatomic) NSData *filterData;
@property (readonly, nonatomic) _Bool showingLargeAttachments;
@property (nonatomic) _Bool isPersisted;
@property (readonly, nonatomic) REMStore *store;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (copy, nonatomic) NSString *smartListType;
@property (readonly, nonatomic) REMSmartListCustomContext *customContext;
@property (readonly, nonatomic) NSString *sortingStyle;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (_Bool)respondsToSelector:(SEL)selector;
- (id)description;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)initWithStore:(id)store storage:(id)storage;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)forwardingTargetForSelector:(SEL)selector;
- (unsigned long long)hash;
- (id)optionalObjectID;
- (id)initWithStore:(id)store account:(id)account parentList:(id)list storage:(id)storage;

@end


@interface REMSmartListChangeItem : NSObject <REMConflictResolving, REMSaveRequestTrackedValue, REMMergeableOrderingNode, REMSupportedVersionProviding, REMSupportedVersionUpdating>

@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (retain, nonatomic) REMObjectID *objectID;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) REMObjectID *parentListID;
@property (retain, nonatomic) REMManualOrdering *manualOrdering;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (retain, nonatomic) NSString *badgeEmblem;
@property (copy, nonatomic) NSDate *pinnedDate;
@property (readonly, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (retain, nonatomic) NSData *filterData;
@property (nonatomic) _Bool showingLargeAttachments;
@property (nonatomic) _Bool isPersisted;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (readonly, nonatomic) REMSmartListSectionContextChangeItem *sectionsContextChangeItem;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, nonatomic) REMAccount *parentAccount;
@property (readonly, copy, nonatomic) REMSmartListStorage *storage;
@property (nonatomic) _Bool isPinned;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (copy, nonatomic) NSString *smartListType;
@property (readonly, nonatomic) REMSmartListCustomContextChangeItem *customContext;
@property (copy, nonatomic) NSString *sortingStyle;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentOwnerID;
@property (retain, nonatomic) REMObjectID *parentSubContainerID;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (void)initialize;
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (void)assertIsCustomSmartListWithAction:(id)action;
- (id)initWithCustomSmartListObjectID:(id)id insertIntoAccountChangeItem:(id)item;
- (id)initWithCustomSmartListObjectID:(id)id insertIntoAccountChangeItem:(id)item withParentListChangeItem:(id)item;
- (id)initWithCustomSmartListObjectID:(id)id insertIntoListSublistContextChangeItem:(id)item;
- (id)initWithSaveRequest:(id)request storage:(id)storage changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage observeInitialValues:(_Bool)values;
- (_Bool)isSubContainer;
- (id)removeFromParentAllowingUndoWithAccountChangeItem:(id)item;
- (void)removeFromParentWithAccountChangeItem:(id)item;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (id)shallowCopyWithSaveRequest:(id)request;
- (void)updateManualOrdering:(id)ordering;

@end


@interface REMSmartListCustomContext : NSObject

@property (retain, nonatomic) REMSmartList *smartlist;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) REMColor *color;
@property (readonly, nonatomic) REMListBadge *badge;
@property (readonly, nonatomic) REMAccount *account;
@property (readonly, nonatomic) REMList *parentList;

/* instance methods */
- (id)initWithSmartList:(id)list account:(id)account parentList:(id)list;

@end


@interface REMSmartListCustomContextChangeItem : NSObject

@property (retain, nonatomic) REMSmartListChangeItem *smartListChangeItem;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) REMColor *color;
@property (copy, nonatomic) REMListBadge *badge;

/* instance methods */
- (id)initWithSmartListChangeItem:(id)item;

@end


@interface REMSmartListSection : REMBaseSection

@property (readonly, nonatomic) REMSmartList *smartList;
@property (retain, nonatomic) REMObjectID *smartListID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)initWithStore:(id)store smartList:(id)list storage:(id)storage;

@end


@interface REMSmartListSectionChangeItem : REMBaseSectionChangeItem

@property (retain, nonatomic) REMObjectID *smartListID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)initWithObjectID:(id)id displayName:(id)name insertIntoSmartListChangeItem:(id)item;
- (void)removeFromSmartList;

@end


@interface REMSmartListSectionContext : NSObject

@property (retain, nonatomic) REMSmartList *smartList;

/* instance methods */
- (id)initWithSmartList:(id)list;

@end


@interface REMSmartListSectionContextChangeItem : NSObject

@property (retain, nonatomic) REMSmartListChangeItem *smartListChangeItem;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;

/* instance methods */
- (id)initWithSmartListChangeItem:(id)item;
- (void)undeleteSectionWithID:(id)id;

@end


@interface REMSmartListSectionStorage : REMBaseSectionStorage

@property (retain, nonatomic) REMObjectID *smartListID;

/* class methods */
+ (id)cdEntityName;

/* instance methods */
- (id)cdKeyToStorageKeyMap;
- (id)initWithObjectID:(id)id accountID:(id)id smartListID:(id)id displayName:(id)name;

@end


@interface REMSmartListSectionsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)fetchSmartListSectionWithObjectID:(id)id error:(id *)error;
- (id)initWithStore:(id)store;
- (id)fetchSmartListSectionsWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchSmartListSectionWithReminderID:(id)id smartListID:(id)id error:(id *)error;
- (id)fetchSmartListSectionsInSmartList:(id)list error:(id *)error;
- (id)smartListSectionsFromAccountStorages:(id)storages smartListStorages:(id)storages groupStorages:(id)storages smartListSectionStorages:(id)storages store:(id)store;

@end


@interface REMSmartListSectionsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *accountStorages;
@property (readonly, nonatomic) NSArray *smartListStorages;
@property (readonly, nonatomic) NSArray *groupStorages;
@property (readonly, nonatomic) NSArray *smartListSectionStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithAccountStorages:(id)storages smartListStorages:(id)storages groupStorages:(id)storages smartListSectionStorages:(id)storages;

@end


@interface REMSmartListSectionsDataViewInvocation_fetchByObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMSmartListSectionsDataViewInvocation_fetchByReminderID : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *reminderID;
@property (readonly, nonatomic) REMObjectID *smartListID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithReminderID:(id)id smartListID:(id)id;

@end


@interface REMSmartListSectionsDataViewInvocation_fetchSmartListSectionsInSmartList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *smartListObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentSmartListObjectID:(id)id;

@end


@interface REMSmartListStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (retain, nonatomic) REMObjectID *objectID;
@property (copy, nonatomic) NSString *smartListType;
@property (retain, nonatomic) REMManualOrdering *manualOrdering;
@property (copy, nonatomic) NSString *sortingStyle;
@property (copy, nonatomic) NSDate *pinnedDate;
@property (retain, nonatomic) NSUUID *mostRecentTargetTemplateIdentifier;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (nonatomic) _Bool showingLargeAttachments;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) REMObjectID *parentListID;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (retain, nonatomic) NSString *badgeEmblem;
@property (retain, nonatomic) NSData *filterData;
@property (nonatomic) _Bool isPersisted;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)storeGeneration;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)initWithObjectID:(id)id accountID:(id)id smartListType:(id)type;
- (id)description;
- (_Bool)isUnsupported;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)optionalObjectID;
- (id)initWithCoder:(id)coder;

@end


@interface REMSmartListsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* class methods */
+ (id)smartListsFromSmartListStorages:(id)storages accountStorages:(id)storages parentListStorages:(id)storages store:(id)store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchCustomSmartListsWithError:(id *)error;
- (id)fetchCustomSmartListWithObjectID:(id)id error:(id *)error;
- (id)fetchCustomSmartListsInAccount:(id)account error:(id *)error;
- (id)fetchCustomSmartListsInGroup:(id)group error:(id *)error;
- (id)fetchNonCustomSmartListWithSmartListType:(id)type createIfNeeded:(_Bool)needed error:(id *)error;

@end


@interface REMSmartListsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *smartListStorages;
@property (readonly, nonatomic) NSDictionary *accountStorages;
@property (readonly, nonatomic) NSDictionary *parentListStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithSmartListStorages:(id)storages accountStorages:(id)storages parentListStorages:(id)storages;
- (id)initWithSmartListStorages:(id)storages;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMSmartListsDataViewInvocation_fetchAllCustomSmartLists : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface REMSmartListsDataViewInvocation_fetchCustomSmartListsInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithParentAccountObjectID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMSmartListsDataViewInvocation_fetchCustomSmartListsInGroup : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *groupObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentGroupObjectID:(id)id;

@end


@interface REMSmartListsDataViewInvocation_fetchSmartList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSString *smartListType;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (nonatomic) _Bool createIfNeeded;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithSmartListType:(id)type objectID:(id)id createIfNeeded:(_Bool)needed;

@end


@interface REMSnoozeTimeUtils : NSObject

/* class methods */
+ (long long)nextThirdsHour:(long long)hour;
+ (long long)nextThirdsHourFromHour:(long long)hour;
+ (long long)nextThirdsHourFromHour:(long long)hour minute:(long long)minute;

@end


@interface REMStore : NSObject <REMClientConnectionsInteractable, REMChangeTrackingProvider>

@property (readonly, nonatomic) _REMInProgressSaveRequestsContainer *l_inProgressSaveRequestsContainer;
@property (readonly, nonatomic) struct os_unfair_lock_s lock;
@property (retain, nonatomic) id <REMDaemonController> daemonController;
@property (readonly, nonatomic) REMStoreContainerToken *storeContainerToken;
@property (nonatomic) unsigned long long mode;
@property (nonatomic) _Bool assertOnMainThreadFetches;
@property (retain, nonatomic) NSNumber *unitTest_forceSupportsAutoCategorizationModels;
@property (retain, nonatomic) REMStore *nonUserInteractiveStore;

/* class methods */
+ (void)initialize;
+ (_Bool)dataaccessDaemonStopSyncingReminders;
+ (void)notifyOfInteractionWithPeople:(id)people;
+ (_Bool)siriShouldRouteIntentsToNewRemindersApp;
+ (_Bool)isEventKitSyncEnabledForReminderKit;
+ (_Bool)notificationsEnabled;
+ (_Bool)_shouldNotifyReminddOfInteractionWithPeople;
+ (id)createIsolatedStoreContainerWithError:(id *)error;
+ (_Bool)destroyIsolatedStoreContainerWithToken:(id)token error:(id *)error;
+ (id)storeDidChangeNotificationName;

/* instance methods */
- (id)executeFetchRequest:(id)request error:(id *)error;
- (id)fetchListsWithObjectIDs:(id)ids error:(id *)error;
- (unsigned long long)countForFetchRequest:(id)request error:(id *)error;
- (id)fetchRemindersWithDACalendarItemUniqueIdentifiers:(id)identifiers inList:(id)list error:(id *)error;
- (id)fetchAccountWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)fetchActiveCloudKitAccountObjectIDsWithFetchOption:(long long)option error:(id *)error;
- (id)fetchListSectionsForListSectionContext:(id)context error:(id *)error;
- (id)fetchAccountsWithExternalIdentifiers:(id)identifiers error:(id *)error;
- (id)fetchAccountWithObjectID:(id)id error:(id *)error;
- (id)fetchPrimaryActiveCloudKitAccountREMObjectIDWithError:(id *)error;
- (id)fetchListSectionsCountWithListObjectID:(id)id error:(id *)error;
- (id)fetchPrimaryActiveCloudKitAccountWithError:(id *)error;
- (id)fetchListIncludingMarkedForDeleteWithObjectID:(id)id error:(id *)error;
- (id)fetchDefaultAccountWithError:(id *)error;
- (id)fetchAccountsWithObjectIDs:(id)ids error:(id *)error;
- (void)test_refreshHashtagLabelsImmediately;
- (id)refreshAccount:(id)account;
- (id)fetchSmartListSectionWithObjectID:(id)id error:(id *)error;
- (id)sharedGroceryListForFamilyChecklistWithCommonParticipants:(id)participants error:(id *)error;
- (void)processNoOpSaveRequest:(id)request queue:(id)queue completion:(id /* block */)completion;
- (_Bool)containsCustomSmartListForTipKitWithError:(id *)error;
- (unsigned long long)storeGeneration;
- (id)fetchReminderWithDACalendarItemUniqueIdentifier:(id)identifier inList:(id)list error:(id *)error;
- (void)rejectCalDAVSharedList:(id)list queue:(id)queue completion:(id /* block */)completion;
- (_Bool)deleteSharedGroceryList:(id)list error:(id *)error;
- (id)fetchRemindersMatchingTitle:(id)title dueAfter:(id)after dueBefore:(id)before isCompleted:(id)completed hasLocation:(id)location location:(id)location error:(id *)error;
- (id)fetchResultByExecutingFetchRequest:(id)request error:(id *)error;
- (id)debugDescription;
- (id)fetchFamilyGroceryListEligibilityForFamilyChecklistWithLocale:(id)locale error:(id *)error;
- (id)fetchTemplateSectionsWithObjectIDs:(id)ids error:(id *)error;
- (void)updateAccountsAndSync:(_Bool)sync completion:(id /* block */)completion;
- (id)fetchIncompleteRemindersCountForNewsRecipeCardWithBatchCreationID:(id)id error:(id *)error;
- (void)requestToUpdateClientConnectionsAsynchronously:(_Bool)asynchronously shouldKeepAlive:(_Bool)alive completion:(id /* block */)completion;
- (id)fetchSmartListSectionsWithObjectIDs:(id)ids error:(id *)error;
- (_Bool)hasActiveCloudKitAccountForTipKitWithError:(id *)error;
- (void)test_initDummyAutoCategorizationWithCategoryByTitle:(id)title;
- (id)fetchAccountsWithError:(id *)error;
- (id)refreshList:(id)list;
- (_Bool)isIntelligentFeaturesSupportedInCurrentAppVersionWithIntelligentFeature:(long long)feature isInternalInstall:(_Bool)install;
- (void)enumerateAllListsWithBlock:(id /* block */)block;
- (id)debugFetchPhantomListsWithError:(id *)error;
- (id)fetchListsForEventKitBridgingWithError:(id *)error;
- (id)test_immediatelyRevokePublicLinkOfTemplateWithTemplateObjectID:(id)id error:(id *)error;
- (void)acceptShareWithMetadata:(id)metadata queue:(id)queue completion:(id /* block */)completion;
- (id)fetchRemindersWithExternalIdentifiers:(id)identifiers inList:(id)list error:(id *)error;
- (id)fetchIncompleteRemindersForEventKitBridgingWithDueDateFrom:(id)from to:(id)to withListIDs:(id)ids error:(id *)error;
- (_Bool)_isUserInteractiveStore;
- (void)addCKShareObserverIfNeededForAccountID:(id)id queue:(id)queue completion:(id /* block */)completion;
- (id)fetchListsIncludingSpecialContainersInAccount:(id)account error:(id *)error;
- (id)fetchAssignmentsWithObjectIDs:(id)ids includeConcealedObjects:(_Bool)objects error:(id *)error;
- (id)fetchCustomSmartListsWithError:(id *)error;
- (_Bool)test_revertImageAttachmentsToUnDeduped:(id)deduped error:(id *)error;
- (id)fetchListSectionsWithListObjectID:(id)id error:(id *)error;
- (id)createShareForListWithID:(id)id appIconData:(id)data error:(id *)error;
- (void)stopShare:(id)share accountID:(id)id queue:(id)queue completion:(id /* block */)completion;
- (id)initWithDaemonController:(id)controller;
- (_Bool)containsListWithCustomBadgeForTipKitWithError:(id *)error;
- (id)fetchEligibleDefaultListsWithError:(id *)error;
- (void)test_handleIncompleteTemplateOperationQueueItemsImmediately;
- (id)provideChangeTrackingForAccountID:(id)id clientName:(id)name transactionAuthorKeysToExclude:(id)exclude;
- (void)_triggerSyncWithReason:(id)reason skipDataAccessSync:(_Bool)sync forcingCloudKitReload:(_Bool)reload discretionary:(_Bool)discretionary bypassThrottler:(_Bool)throttler completion:(id /* block */)completion;
- (void)_respondToCalDAVSharedList:(id)list withResponse:(long long)response queue:(id)queue completion:(id /* block */)completion;
- (id)optimisticallyMaterializeReminderChangeItem:(id)item;
- (void)addParticipantsToSharedGroceryList:(id)list completion:(id /* block */)completion;
- (id)fetchAllListsWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)fetchReplicaManagersForAccountID:(id)id bundleID:(id)id error:(id *)error;
- (id)provideAnonymousChangeTrackingWithTransactionAuthorKeysToExclude:(id)exclude;
- (void)updateAccountWithAccountID:(id)id completion:(id /* block */)completion;
- (void)saveSaveRequest:(id)request accountChangeItems:(id)items listChangeItems:(id)items listSectionChangeItems:(id)items smartListChangeItems:(id)items smartListSectionChangeItems:(id)items templateChangeItems:(id)items templateSectionChangeItems:(id)items reminderChangeItems:(id)items author:(id)author replicaManagerProvider:(id)provider queue:(id)queue completion:(id /* block */)completion;
- (id)refreshReminder:(id)reminder;
- (void)_saveAccountChangeItems:(id)items listChangeItems:(id)items listSectionChangeItems:(id)items smartListChangeItems:(id)items smartListSectionChangeItems:(id)items templateChangeItems:(id)items templateSectionChangeItems:(id)items reminderChangeItems:(id)items author:(id)author replicaManagerProvider:(id)provider synchronously:(_Bool)synchronously syncToCloudKit:(_Bool)kit performer:(id)performer completion:(id /* block */)completion;
- (void)_addChangeItemChangedKeys:(id)keys objectID:(id)id toChangedKeysMap:(id)map;
- (void)test_handleIncompleteGroceryOperationQueueItemsImmediatelyWithTimeout:(double)timeout;
- (id)fetchReminderWithExternalIdentifier:(id)identifier inList:(id)list error:(id *)error;
- (id)fetchListSectionsWithObjectIDs:(id)ids error:(id *)error;
- (id)description;
- (id)init;
- (id)fetchTemplateSectionWithObjectID:(id)id error:(id *)error;
- (id)fetchListWithObjectID:(id)id error:(id *)error;
- (id)fetchListSectionsForListSectionContextChangeItem:(id)item error:(id *)error;
- (id)fetchAccountsForDumpingWithError:(id *)error;
- (void)removeOrphanedAccountsWithCompletion:(id /* block */)completion;
- (void)notifyOfInteractionWithPeople:(id)people force:(_Bool)force completion:(id /* block */)completion;
- (id)fetchCompletedRemindersForEventKitBridgingWithCompletionDateFrom:(id)from to:(id)to withListIDs:(id)ids error:(id *)error;
- (void)triggerCloudKitOnlySyncWithReason:(id)reason discretionary:(_Bool)discretionary completion:(id /* block */)completion;
- (id)fetchReminderWithObjectID:(id)id fetchOptions:(id)options error:(id *)error;
- (_Bool)containsHashtagsForTipKitWithError:(id *)error;
- (void)triggerSyncForDataAccessAccountsWithAccountIDs:(id)ids;
- (id)fetchCreatedOrCompletedRemindersCountForAppStoreFromDate:(id)date toDate:(id)date error:(id *)error;
- (id)fetchPredefinedListSectionsWithObjectIDs:(id)ids listObjectID:(id)id error:(id *)error;
- (id)fetchSmartListSectionsForSmartListSectionContext:(id)context error:(id *)error;
- (id)fetchListIncludingSpecialContainerWithObjectID:(id)id error:(id *)error;
- (id)fetchReminderIncludingConcealedWithObjectID:(id)id error:(id *)error;
- (id)fetchPredefinedListSectionWithObjectID:(id)id listObjectID:(id)id error:(id *)error;
- (unsigned long long)completedRemindersCountForTipKitWithError:(id *)error;
- (id)fetchListIncludingConcealedWithObjectID:(id)id error:(id *)error;
- (id)fetchDefaultListRequiringCloudKitWithError:(id *)error;
- (id)fetchDefaultListWithError:(id *)error;
- (id)fetchReminderIncludingMarkedForDeleteWithObjectID:(id)id error:(id *)error;
- (id)fetchRemindersWithParentReminderIDs:(id)ids error:(id *)error;
- (id)initWithStoreContainerToken:(id)token;
- (id)fetchTemplateWithObjectID:(id)id error:(id *)error;
- (_Bool)everConnectedToCar;
- (void)invalidate;
- (id)fetchReplicaManagerForAccountID:(id)id error:(id *)error;
- (void)anchoredBubbleCloudOverridesWithCompletion:(id /* block */)completion;
- (id)fetchDefaultAccountMatchingCapabilities:(id /* block */)capabilities error:(id *)error;
- (id)fetchRemindersWithObjectIDs:(id)ids fetchOptions:(id)options error:(id *)error;
- (void)requestToMergeSyncDataIntoLocalDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)requestDownloadGroceryModelAssetsFromTrial;
- (id)fetchIncompleteRemindersForNewsRecipeCardWithBatchCreationID:(id)id error:(id *)error;
- (id)fetchMinimumSearchTermLengthByBaseLanguageWithError:(id *)error;
- (id)fetchTemplateSectionsForTemplateSectionContext:(id)context error:(id *)error;
- (void)requestToDeleteLocalDataWithCompletion:(id /* block */)completion;
- (id)fetchListSectionWithObjectID:(id)id error:(id *)error;
- (void)test_setupForManualHashtagLabelRefreshing;
- (id)test_immediatelyCreateOrUpdatePublicLinkOfTemplateWithTemplateObjectID:(id)id configuration:(id)configuration error:(id *)error;
- (id)fetchAllRemindersWithExternalIdentifier:(id)identifier error:(id *)error;
- (id)_xpcSyncStorePerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)fetchRemindersForEventKitBridgingWithListIDs:(id)ids error:(id *)error;
- (id)initUserInteractive:(_Bool)interactive;
- (void)triggerThrottledSyncWithReason:(id)reason discretionary:(_Bool)discretionary completion:(id /* block */)completion;
- (void)updateShare:(id)share accountID:(id)id queue:(id)queue completion:(id /* block */)completion;
- (id)fetchCustomSmartListWithObjectID:(id)id error:(id *)error;
- (id)repairPhantomObjectsWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchReminderWithObjectID:(id)id error:(id *)error;
- (id)fetchRemindersMatchingPredicateDescriptor:(id)descriptor sortDescriptors:(id)descriptors options:(id)options error:(id *)error;
- (void)updateAccountWithAccountID:(id)id restartDA:(_Bool)da completion:(id /* block */)completion;
- (id)provideChangeTrackingForAccountID:(id)id clientName:(id)name;
- (id)MCIsManagedAccountWithObjectID:(id)id error:(id *)error;
- (void)enumerateAllGroupsAndListsWithBlock:(id /* block */)block;
- (id)fetchDefaultListRequiringCloudKitAccountWithAccountID:(id)id error:(id *)error;
- (id)initWithDaemonController:(id)controller storeContainerToken:(id)token;
- (id)fetchSiriFoundInAppsListWithError:(id *)error;
- (id)fetchHashtagsWithObjectIDs:(id)ids includeConcealedObjects:(_Bool)objects error:(id *)error;
- (void)enumerateAllRemindersWithBlock:(id /* block */)block;
- (id)resultFromPerformingInvocation:(id)invocation error:(id *)error;
- (_Bool)saveSaveRequest:(id)request accountChangeItems:(id)items listChangeItems:(id)items listSectionChangeItems:(id)items smartListChangeItems:(id)items smartListSectionChangeItems:(id)items templateChangeItems:(id)items templateSectionChangeItems:(id)items reminderChangeItems:(id)items author:(id)author replicaManagerProvider:(id)provider error:(id *)error;
- (id)compressedDistributedEvaluationDataWithOptions:(id)options error:(id *)error;
- (void)requestToDeleteSyncDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (void)postFamilyAnalyticsPayloadWithOperationId:(id)id operationDetail:(id)detail;
- (id)fetchListRepresentationOfTemplateWithObjectID:(id)id error:(id *)error;
- (void)_incrementStoreGeneration;
- (id)fetchShareForListWithID:(id)id error:(id *)error;
- (id)resultsIndexedByObjectIDFromExecutingFetchRequest:(id)request error:(id *)error;
- (id)fetchRemindersWithObjectIDs:(id)ids error:(id *)error;
- (id)replicaManagerProviderForCalDAVSync;
- (id)fetchAccountsIncludingInactive:(_Bool)inactive error:(id *)error;
- (void)_enumerateAllListsIncludingGroups:(_Bool)groups withBlock:(id /* block */)block;
- (id)resultFromPerformingSwiftInvocation:(id)invocation parametersData:(id)data storages:(id)storages error:(id *)error;
- (id)_withInProgressSaveRequestContainer:(id /* block */)container;
- (void)acceptCalDAVSharedList:(id)list queue:(id)queue completion:(id /* block */)completion;
- (void)test_handleIncompleteAutoCategorizationOperationQueueItemsImmediatelyWithTimeout:(double)timeout;
- (id)fetchRemindersIncludingUnsupportedWithObjectIDs:(id)ids error:(id *)error;
- (void)nukeDatabase;
- (void)requestToMergeLocalDataIntoSyncDataWithAccountIdentifier:(id)identifier completion:(id /* block */)completion;
- (id)createSharedGroceryListWithError:(id *)error;

@end


@interface REMStoreContainerToken : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSUUID *identifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)description;
- (id)initWithIdentifier:(id)identifier;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMStoreSwiftInvocation : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) REMFetchResultToken *fetchResultTokenToDiffAgainst;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMStoreSwiftInvocationResult : NSObject <NSSecureCoding>

@property (readonly, nonatomic) NSData *resultData;
@property (readonly, nonatomic) NSDictionary *resultStorages;
@property (readonly, nonatomic) REMFetchResultToken *latestFetchResultToken;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithResultData:(id)data storages:(id)storages latestFetchResultToken:(id)token;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMStructuredLocation : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSString *locationUID;
@property (copy, nonatomic) NSString *title;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double radius;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *routing;
@property (copy, nonatomic) NSString *referenceFrameString;
@property (copy, nonatomic) NSString *contactLabel;
@property (copy, nonatomic) NSData *mapKitHandle;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (double)minimumRegionMonitoringDistance;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)description;
- (id)displayName;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithTitle:(id)title;
- (id)initWithCoder:(id)coder;
- (id)initWithTitle:(id)title locationUID:(id)uid;
- (_Bool)isContentEqual:(id)equal;
- (id)initWithTitle:(id)title locationUID:(id)uid latitude:(double)latitude longitude:(double)longitude radius:(double)radius address:(id)address routing:(id)routing referenceFrameString:(id)string contactLabel:(id)label mapKitHandle:(id)handle;

@end


@interface REMSuggestedAttributesPerformer : NSObject

@property (retain, nonatomic) NSObject<OS_dispatch_queue> *queue;
@property (retain, nonatomic) REMStore *store;
@property (retain, nonatomic) id <REMXPCSuggestedAttributesPerformer> q_cachedXPCPerformer;

/* instance methods */
- (id)resultFromPerformingSwiftInvocation:(id)invocation parametersData:(id)data storages:(id)storages error:(id *)error;
- (id)initWithQueue:(id)queue store:(id)store;
- (void)preWarmModels;
- (id)q_resolveSuggestedAttributesPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)q_syncSuggestedAttributesPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;

@end


@interface REMSystemUtilities : NSObject

/* class methods */
+ (_Bool)isInternalInstall;
+ (id)systemBuildVersion;
+ (id)systemVersionDictionary;

@end


@interface REMTTHashtag : NSObject

@property (readonly, nonatomic) NSString *objectIdentifier;

/* class methods */
+ (id)attributeName;
+ (id)attributeFromHashtag:(id)hashtag;
+ (_Bool)attributeValue:(id)value hasEqualHashtagObjectIdentifierIn:(id)in;

/* instance methods */
- (id)description;
- (id)initWithObjectIdentifier:(id)identifier;

@end


@interface REMTTParagraphStyle : NSObject

@property (retain, nonatomic) TTParagraphStyle *innerStyle;
@property (readonly, nonatomic) NSObject *attributedValue;
@property (readonly, nonatomic) long long remParagraphStyle;

/* instance methods */
- (id)initWithStyle:(long long)style;
- (id)initWithContents:(id)contents;
- (id)listBulletInAttributedString:(id)string atIndex:(unsigned long long)index;

@end


@interface REMTTStyle : NSObject

/* class methods */
+ (id)attributeNameForStyle:(long long)style;

@end


@interface REMTemplate : NSObject <REMObjectIDProviding, REMSupportedVersionProviding>

@property (copy, nonatomic) REMTemplateStorage *storage;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (readonly, nonatomic) REMObjectID *parentAccountID;
@property (readonly, nonatomic) NSString *badgeEmblem;
@property (readonly, nonatomic) REMStore *store;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) REMColor *color;
@property (readonly, nonatomic) REMListBadge *badge;
@property (readonly, nonatomic) _Bool showingLargeAttachments;
@property (readonly, nonatomic) NSString *sortingStyle;
@property (readonly, nonatomic) NSDate *mostRecentPublicLinkUpdateRequestDate;
@property (readonly, nonatomic) REMTemplatePublicLink *publicLink;
@property (readonly, nonatomic) _Bool isPersisted;
@property (readonly, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (readonly, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMTemplateSectionContext *sectionContext;
@property (readonly, nonatomic) NSSet *sectionIDsToUndelete;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;
+ (id)cdEntityNameForSavedAttachment;
+ (id)cdEntityNameForSavedReminder;
+ (id)newObjectIDForSavedAttachment;
+ (id)newObjectIDForSavedReminder;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (_Bool)respondsToSelector:(SEL)selector;
- (id)description;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)initWithStore:(id)store storage:(id)storage;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)forwardingTargetForSelector:(SEL)selector;
- (unsigned long long)hash;
- (id)optionalObjectID;

@end


@interface REMTemplateChangeItem : NSObject <REMConflictResolving, REMSaveRequestTrackedValue, REMObjectIDProviding, REMSupportedVersionProviding, REMSupportedVersionUpdating>

@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) REMManualOrdering *unsavedManualOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (retain, nonatomic) REMChangedKeysObserver *changedKeysObserver;
@property (retain, nonatomic) REMTemplateConfiguration *configuration;
@property (retain, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) NSString *badgeEmblem;
@property (readonly, nonatomic) REMTemplatePublicLink *publicLink;
@property (readonly, nonatomic) _Bool isPersisted;
@property (readonly, nonatomic) REMSaveRequest *saveRequest;
@property (readonly, nonatomic) REMObjectID *objectID;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (copy, nonatomic) REMListBadge *badge;
@property (nonatomic) _Bool showingLargeAttachments;
@property (copy, nonatomic) NSString *sortingStyle;
@property (readonly, nonatomic) NSDate *mostRecentPublicLinkUpdateRequestDate;
@property (readonly, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (readonly, copy, nonatomic) REMTemplateStorage *storage;
@property (readonly, nonatomic) REMTemplateSectionContextChangeItem *sectionsContextChangeItem;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (void)initialize;
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)respondsToSelector:(SEL)selector;
- (void)setValue:(id)value forUndefinedKey:(id)key;
- (id)valueForUndefinedKey:(id)key;
- (_Bool)isUnsupported;
- (id)changedKeys;
- (id)forwardingTargetForSelector:(SEL)selector;
- (id)initWithObjectID:(id)id name:(id)name configuration:(id)configuration insertIntoAccountChangeItem:(id)item;
- (id)initWithSaveRequest:(id)request storage:(id)storage changedKeysObserver:(id)observer;
- (id)initWithSaveRequest:(id)request storage:(id)storage observeInitialValues:(_Bool)values;
- (void)removeFromParentAccount;
- (id)resolutionTokenKeyForChangedKey:(id)key;
- (id)shallowCopyWithSaveRequest:(id)request;
- (void)updateManualOrdering:(id)ordering;

@end


@interface REMTemplateConfiguration : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *sourceListID;
@property (readonly, nonatomic) _Bool shouldSaveCompleted;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithSourceListID:(id)id shouldSaveCompleted:(_Bool)completed;

@end


@interface REMTemplateContentAttributes : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) long long reminderCount;
@property (readonly, nonatomic) _Bool hasDisplayDate;
@property (readonly, nonatomic) _Bool hasHashtags;
@property (readonly, nonatomic) _Bool hasLocationTriggersOrVehicleEventTriggers;
@property (readonly, nonatomic) _Bool hasImageAttachments;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithReminderCount:(long long)count hasDisplayDate:(_Bool)date hasHashtags:(_Bool)hashtags hasLocationTriggersOrVehicleEventTriggers:(_Bool)triggers hasImageAttachments:(_Bool)attachments;

@end


@interface REMTemplatePublicLink : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSURL *url;
@property (readonly, nonatomic) REMTemplatePublicLinkConfiguration *configuration;
@property (readonly, nonatomic) NSDate *creationDate;
@property (readonly, nonatomic) NSDate *lastModifiedDate;
@property (readonly, nonatomic) NSDate *expirationDate;
@property (readonly, nonatomic) _Bool canBeUpdated;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithURL:(id)url configuration:(id)configuration creationDate:(id)date lastModifiedDate:(id)date expirationDate:(id)date canBeUpdated:(_Bool)updated;

@end


@interface REMTemplatePublicLinkConfiguration : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) _Bool shouldIncludeHashtags;
@property (readonly, nonatomic) _Bool shouldIncludeAlarmTriggersBasedOnDateOrTimeInterval;
@property (readonly, nonatomic) _Bool shouldIncludeAlarmTriggersBasedOnLocationOrVehicle;
@property (readonly, nonatomic) _Bool shouldIncludeContactsHandleData;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithShouldIncludeHashtags:(_Bool)hashtags shouldIncludeAlarmTriggersBasedOnDateOrTimeInterval:(_Bool)interval shouldIncludeAlarmTriggersBasedOnLocationOrVehicle:(_Bool)vehicle;

@end


@interface REMTemplateSection : REMBaseSection

@property (readonly, nonatomic) REMTemplate *parentTemplate;
@property (retain, nonatomic) REMObjectID *parentTemplateID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)initWithStore:(id)store parentTemplate:(id)_template storage:(id)storage;

@end


@interface REMTemplateSectionChangeItem : REMBaseSectionChangeItem

@property (retain, nonatomic) REMObjectID *parentTemplateID;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (id)initWithObjectID:(id)id displayName:(id)name insertIntoTemplateChangeItem:(id)item;
- (void)removeFromParentTemplate;

@end


@interface REMTemplateSectionContext : NSObject

@property (retain, nonatomic) REMTemplate *parentTemplate;

/* instance methods */
- (id)initWithParentTemplate:(id)_template;

@end


@interface REMTemplateSectionContextChangeItem : NSObject

@property (retain, nonatomic) REMTemplateChangeItem *templateChangeItem;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;

/* instance methods */
- (id)initWithTemplateChangeItem:(id)item;
- (void)undeleteSectionWithID:(id)id;

@end


@interface REMTemplateSectionStorage : REMBaseSectionStorage

@property (retain, nonatomic) REMObjectID *parentTemplateID;

/* class methods */
+ (id)cdEntityName;

/* instance methods */
- (id)cdKeyToStorageKeyMap;
- (id)initWithObjectID:(id)id accountID:(id)id parentTemplateID:(id)id displayName:(id)name;

@end


@interface REMTemplateSectionsDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchTemplateSectionsWithObjectIDs:(id)ids error:(id *)error;
- (id)fetchTemplateSectionWithObjectID:(id)id error:(id *)error;
- (id)fetchTemplateSectionsInTemplate:(id)_template error:(id *)error;
- (id)fetchTemplateSectionsWithTemplateObjectID:(id)id error:(id *)error;
- (id)templateSectionsFromTemplateStorages:(id)storages templateSectionStorages:(id)storages store:(id)store;

@end


@interface REMTemplateSectionsDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *templateStorages;
@property (readonly, nonatomic) NSArray *templateSectionStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithTemplateStorages:(id)storages templateSectionStorages:(id)storages;

@end


@interface REMTemplateSectionsDataViewInvocation_fetchByObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSArray *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTemplateSectionsDataViewInvocation_fetchTemplateSectionsInTemplate : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *templateObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithParentTemplateObjectID:(id)id;

@end


@interface REMTemplateStorage : NSObject <NSCopying, NSSecureCoding, REMObjectIDProviding, REMObjectStorageSupportedVersionProviding>

@property (retain, nonatomic) REMAccountCapabilities *accountCapabilities;
@property (retain, nonatomic) REMObjectID *objectID;
@property (readonly, nonatomic) REMObjectID *accountID;
@property (retain, nonatomic) REMObjectID *parentAccountID;
@property (retain, nonatomic) REMTemplateConfiguration *configuration;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) REMColor *color;
@property (copy, nonatomic) NSString *badgeEmblem;
@property (nonatomic) _Bool showingLargeAttachments;
@property (copy, nonatomic) NSString *sortingStyle;
@property (nonatomic) _Bool shouldUpdateSectionsOrdering;
@property (retain, nonatomic) NSArray *unsavedSectionIDsOrdering;
@property (retain, nonatomic) REMManualOrdering *unsavedManualOrdering;
@property (retain, nonatomic) REMMemberships *unsavedMembershipsOfRemindersInSections;
@property (retain, nonatomic) NSSet *sectionIDsToUndelete;
@property (retain, nonatomic) NSDate *mostRecentPublicLinkUpdateRequestDate;
@property (retain, nonatomic) REMTemplatePublicLink *publicLink;
@property (nonatomic) _Bool isPersisted;
@property (retain, nonatomic) REMResolutionTokenMap *resolutionTokenMap;
@property (retain, nonatomic) NSData *resolutionTokenMapData;
@property (readonly, nonatomic) REMObjectID *remObjectID;
@property (readonly, nonatomic) long long minimumSupportedVersion;
@property (readonly, nonatomic) long long effectiveMinimumSupportedVersion;

/* class methods */
+ (id)objectIDWithUUID:(id)uuid;
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;
+ (id)newObjectID;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (unsigned long long)storeGeneration;
- (id)cdKeyToStorageKeyMap;
- (void)setStoreGenerationIfNeeded:(unsigned long long)needed;
- (id)initWithObjectID:(id)id accountID:(id)id name:(id)name;
- (id)description;
- (_Bool)isUnsupported;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)optionalObjectID;
- (id)initWithCoder:(id)coder;

@end


@interface REMTemplatesDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchTemplateWithObjectID:(id)id error:(id *)error;
- (id)fetchTemplatesInAccount:(id)account error:(id *)error;
- (id)fetchTemplatesWithObjectIDs:(id)ids error:(id *)error;
- (id)templatesFromTemplateStorages:(id)storages store:(id)store;

@end


@interface REMTemplatesDataViewInvocationResult : REMStoreInvocationResult <NSSecureCoding>

@property (readonly, nonatomic) NSArray *templateStorages;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithTemplateStorages:(id)storages;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTemplatesDataViewInvocation_fetchByObjectIDs : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) NSSet *objectIDs;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithObjectIDs:(id)ids;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTemplatesDataViewInvocation_fetchTemplatesInAccount : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *accountObjectID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithParentAccountObjectID:(id)id;
- (id)initWithCoder:(id)coder;

@end


@interface REMTextMemberships : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDictionary *memberships;
@property (readonly, nonatomic) NSDate *lastResetDate;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)removing:(id)removing;
- (id)description;
- (void)reset;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)groupIdentifierOfMemberWithIdentifier:(id)identifier;
- (id)initWithMemberships:(id)memberships;
- (id)initWithMemberships:(id)memberships lastResetDate:(id)date;
- (id)mergingWith:(id)with;

@end


@interface REMTimestampedUUID : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSUUID *identifier;
@property (readonly, nonatomic) NSDate *modifiedOn;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithIdentifier:(id)identifier modifiedOn:(id)on;

@end


@interface REMTipKitDataView : NSObject

@property (readonly, nonatomic) REMStore *store;

/* instance methods */
- (id)initWithStore:(id)store;
- (id)fetchCompletedRemindersCountInList:(id)list error:(id *)error;
- (id)fetchCompletedRemindersCountWithError:(id *)error;
- (id)fetchCustomSmartListsCountWithError:(id *)error;
- (id)fetchHashtagsCountWithError:(id *)error;
- (id)fetchListsCountWithError:(id *)error;
- (id)fetchListsWithCustomBadgeCountWithError:(id *)error;
- (id)fetchUncompletedRemindersCountWithError:(id *)error;

@end


@interface REMTipKitDataViewInvocation_fetchCompletedRemindersCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTipKitDataViewInvocation_fetchCompletedRemindersCountInList : REMStoreInvocation <NSSecureCoding>

@property (readonly, nonatomic) REMObjectID *listID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;
- (id)initWithListID:(id)id;

@end


@interface REMTipKitDataViewInvocation_fetchCustomSmartListsCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTipKitDataViewInvocation_fetchHashtagsCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTipKitDataViewInvocation_fetchListsCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTipKitDataViewInvocation_fetchListsWithCustomBadgeCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMTipKitDataViewInvocation_fetchUncompletedRemindersCount : REMStoreInvocation <NSSecureCoding>

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithCoder:(id)coder;

@end


@interface REMURLAttachment : REMAttachment

@property (retain, nonatomic) NSURL *url;
@property (retain, nonatomic) NSData *metadata;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)cdEntityName;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)debugDescription;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)_deepCopy;
- (id)initWithCoder:(id)coder;
- (id)initWithObjectID:(id)id accountID:(id)id reminderID:(id)id url:(id)url metadata:(id)metadata;

@end


@interface REMUrgentPresentationAlarm : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSDictionary *urgentAlarmStateByAccountIdentifier;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithUrgentAlarmStateByAccountIdentifier:(id)identifier;
- (id)initWithUrgentAlarmStates:(id)states;
- (id)mergingWith:(id)with;
- (id)mergingWithState:(id)state;

@end


@interface REMUrgentPresentationAlarmStatePerUser : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) NSString *personIdentifier;
@property (readonly, nonatomic) _Bool isEnabled;
@property (readonly, nonatomic) NSDate *modifiedOn;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (id)initWithPersonIdentifier:(id)identifier isEnabled:(_Bool)enabled modifiedOn:(id)on;

@end


@interface REMUserActivity : NSObject <NSCopying, NSSecureCoding>

@property (readonly, nonatomic) struct os_unfair_lock_s ivarLock;
@property (retain, nonatomic) id l_decodedStorage;
@property (readonly, nonatomic) long long type;
@property (readonly, nonatomic) NSData *storage;
@property (readonly, nonatomic) long long flags;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)stringForFlags:(long long)flags;
+ (id)dataFromUserActivity:(id)activity;
+ (id)stringForActivityType:(long long)type;
+ (id)userActivityWithDictionaryData:(id)data error:(id *)error;
+ (void)userActivityWithUserActivity:(id)activity completion:(id /* block */)completion;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)userActivity;
- (id)debugDescription;
- (id)userActivityData;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)hash;
- (id)initWithUserActivity:(id)activity;
- (id)initWithCoder:(id)coder;
- (id)initWithUniversalLink:(id)link;
- (id)initWithUserActivityData:(id)data;
- (id)universalLink;
- (id)decodeStorageIfNeededWithBlock:(id /* block */)block;
- (id)archivedDictionaryData;
- (id)debugDescriptionDetails;
- (id)initWithSiriIntent:(id)intent;
- (id)initWithType:(long long)type storage:(id)storage flags:(long long)flags;
- (id)siriIntent;
- (id)userActivityWithFlags:(long long)flags;

@end


@interface REMUserDefaultsObserver : NSObject <REMUserDefaultsObserveToken>

@property (retain, nonatomic) REMUserDefaults *userDefaults;
@property (copy, nonatomic) NSString *userDefaultsKey;
@property (copy, nonatomic) id /* block */ block;
@property (nonatomic) _Bool removed;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithUserDefaults:(id)defaults key:(id)key block:(id /* block */)block;
- (void)stopObserving;
- (void)dealloc;

@end


@interface REMXPCChangeTrackingPerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCClientInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCDaemonController : NSObject <REMDaemonController>

@property (nonatomic) struct os_unfair_lock_s ivarLock;
@property (retain, nonatomic) NSMutableDictionary *l_performersByName;
@property (retain, nonatomic) NSString *serviceName;
@property (retain, nonatomic) NSXPCConnection *xpcConnection;
@property (retain, nonatomic) REMStoreContainerToken *storeContainerToken;
@property (weak, nonatomic) id <REMXPCDaemonControllerCloudKitNetworkActivityDelegate> cloudKitNetworkActivityDelegate;
@property (weak, nonatomic) id <REMXPCDaemonControllerAutoCategorizationActivityObserver> autoCategorizationActivityObserver;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)weakSharedInstance;
+ (id)userInteractiveDaemonController;

/* instance methods */
- (void)_asyncResolveAndCachePerformerWithResolver:(id)resolver reason:(id)reason completion:(id /* block */)completion;
- (void)_asyncPerformerWithResolver:(id)resolver reason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (void)asyncSyncInterfacePerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (void)_xpcConnectionDidInterrupt;
- (id)syncSyncInterfacePerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)init;
- (void)asyncDebugPerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (void)asyncStorePerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (id)initWithStoreContainerToken:(id)token userInteractive:(_Bool)interactive;
- (void)_asyncResolvePerformerWithResolver:(id)resolver reason:(id)reason completion:(id /* block */)completion;
- (void)dealloc;
- (id)_resolvePerformerWithResolver:(id)resolver reason:(id)reason errorHandler:(id /* block */)handler;
- (id)_xpcConnectionReconnectingIfNecessary;
- (id)initWithStoreContainerToken:(id)token;
- (void)invalidate;
- (id)_syncPerformerWithResolver:(id)resolver reason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncStorePerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncChangeTrackingPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (id)syncDebugPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;
- (void)_xpcConnectionDidInvalidate;
- (id)syncDebugPerformerWithErrorHandler:(id /* block */)handler;
- (id)_resolveAndCachePerformerWithResolver:(id)resolver reason:(id)reason errorHandler:(id /* block */)handler;
- (void)asyncIndexingPerformerWithReason:(id)reason loadHandler:(id /* block */)handler errorHandler:(id /* block */)handler;
- (id)syncIndexingPerformerWithReason:(id)reason errorHandler:(id /* block */)handler;

@end


@interface REMXPCDaemonControllerExportedObject : NSObject <REMXPCClient>

@property (weak, nonatomic) id <REMXPCDaemonControllerCloudKitNetworkActivityDelegate> cloudKitNetworkActivityDelegate;
@property (weak, nonatomic) id <REMXPCDaemonControllerAutoCategorizationActivityObserver> autoCategorizationActivityObserver;

/* instance methods */
- (void)autoCategorizationActivityDidUpdate:(id)update;
- (void)cloudKitNetworkActivityDidUpdate:(id)update;

@end


@interface REMXPCDaemonControllerPerformerResolver : NSObject

@property (readonly, nonatomic) NSString *name;

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;

@end


@interface REMXPCDaemonControllerPerformerResolver_changeTracking : REMXPCDaemonControllerPerformerResolver

@property (readonly, nonatomic) REMStoreContainerToken *storeContainerToken;

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;
- (id)name;
- (id)initWithStoreContainerToken:(id)token;

@end


@interface REMXPCDaemonControllerPerformerResolver_debug : REMXPCDaemonControllerPerformerResolver

@property (readonly, nonatomic) REMStoreContainerToken *storeContainerToken;

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;
- (id)name;
- (id)initWithStoreContainerToken:(id)token;

@end


@interface REMXPCDaemonControllerPerformerResolver_indexing : REMXPCDaemonControllerPerformerResolver

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;
- (id)name;

@end


@interface REMXPCDaemonControllerPerformerResolver_store : REMXPCDaemonControllerPerformerResolver

@property (readonly, nonatomic) REMStoreContainerToken *storeContainerToken;

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;
- (id)name;
- (id)initWithStoreContainerToken:(id)token;

@end


@interface REMXPCDaemonControllerPerformerResolver_sync : REMXPCDaemonControllerPerformerResolver

/* instance methods */
- (void)resolveWithDaemon:(id)daemon reason:(id)reason completion:(id /* block */)completion;
- (id)name;

@end


@interface REMXPCDaemonInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCDebugPerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCIndexingPerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCStorageClasses : NSObject

/* class methods */
+ (id)remStorageClasses;

@end


@interface REMXPCStorePerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCSuggestedAttributesPerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface REMXPCSyncInterfacePerformerInterface : NSObject

/* class methods */
+ (id)interface;

@end


@interface TTArray : NSObject <CRCoding, TTMergeableStringDelegate, CRDataType>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) TTMergeableAttributedString *contents;
@property (readonly, nonatomic) NSArray *nsArray;
@property (readonly, nonatomic) unsigned long long count;
@property (readonly, nonatomic) NSUUID *replicaUUID;
@property (weak, nonatomic) CRDocument *document;
@property (weak, nonatomic) NSObject<CRUndoDelegate> *delegate;

/* instance methods */
- (id)objectAtIndexedSubscript:(unsigned long long)subscript;
- (_Bool)isEqual:(id)equal;
- (id)tombstone;
- (void)enumerateObjectsUsingBlock:(id /* block */)block;
- (id)initWithCRCoder:(id)crcoder;
- (void)edited:(unsigned long long)edited range:(struct _NSRange)range changeInLength:(long long)length;
- (id)objectAtIndex:(unsigned long long)index;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
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
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id;
- (id)initWithCRCoder:(id)crcoder stringArray:(const void *)array;
- (void)saveToArchive:(void *)archive;
- (id)serializeDataFromArchive:(const void *)archive;
- (id)textAttachmentAtIndex:(unsigned long long)index;
- (_Bool)wantsUndoCommands;

@end


@interface TTVectorMultiTimestamp : NSObject <NSCopying>

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


@interface TTCRVectorMultiTimestamp : TTVectorMultiTimestamp

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCapacity:(unsigned long long)capacity;
- (_Bool)isDocumentShared;

@end


@interface TTVectorTimestamp : NSObject <NSCopying>

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


@interface TTCRVectorTimestamp : TTVectorTimestamp

@property (retain, nonatomic) CRVectorTimestamp *crTimestamp;

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


@interface TTFont : NSObject <NSSecureCoding>

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


@interface TTMergeableString : NSObject <CRDataType>

@property (retain, nonatomic) CRTTCompatibleDocument *document;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) TTVectorMultiTimestamp *timestamp;
@property (nonatomic) _Bool hasLocalChanges;
@property (retain, nonatomic) NSUUID *replicaUUID;
@property (retain, nonatomic) NSMutableAttributedString *attributedString;
@property (readonly, nonatomic) unsigned long long replicaTextClock;
@property (readonly, nonatomic) unsigned long long replicaStyleClock;
@property (weak, nonatomic) NSObject<TTMergeableStringDelegate> *delegate;
@property (readonly, nonatomic) NSHashTable *objectsNeedingUpdatedRanges;

/* class methods */
+ (id)unserialisedReplicaID;

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
- (id)init;
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
- (void)coalesce;
- (id)replicaUUIDForCharacterAtIndex:(unsigned long long)index;
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
- (void)enumerateRangesModifiedAfter:(id)after usingBlock:(id /* block */)block;
- (void)enumerateSubstrings:(id /* block */)substrings;
- (void)generateIdsForLocalChanges;
- (void)generateIdsForLocalChangesSafeForSharedTimestamp:(_Bool)timestamp;
- (unsigned long long)getCharacterIndexForCharID:(struct TopoID)id;
- (void)getCharacterRanges:(void *)ranges forSubstrings:(void *)substrings;
- (void *)getSubstringBeforeTopoID:(struct TopoID)id;
- (void)getSubstrings:(void *)substrings forCharacterRange:(struct _NSRange)range;
- (void)getSubstrings:(void *)substrings forTopoIDRange:(struct TopoIDRange)idrange;
- (void)getSubstrings:(void *)substrings inOrderedSubstrings:(void *)substrings forCharacterRange:(struct _NSRange)range;
- (_Bool)graphIsEqual:(id)equal;
- (id)i_saveDeltasSinceTimestamp:(id)timestamp toArchive:(void *)archive;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id andSharedTimestamp:(id)timestamp;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id withOrderedSubstrings:(void *)substrings;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id withOrderedSubstrings:(void *)substrings timestamp:(id)timestamp;
- (id)initWithData:(id)data andReplicaID:(id)id;
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
- (_Bool)shouldInvalidateCachedSubstringsWithTimestamp:(id)timestamp;
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

@end


@interface TTMergeableUndoString : TTMergeableString

/* instance methods */
- (void)addUndoCommand:(id)command;
- (void)applyUndoCommand:(id)command;
- (void)deleteSubstrings:(void *)substrings withCharacterRanges:(void *)ranges;
- (struct TopoIDRange)insertAttributedString:(id)string after:(void *)after before:(void *)before;
- (void)undeleteSubstrings:(void *)substrings;

@end


@interface TTMergeableAttributedString : TTMergeableUndoString <CRCoding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)allowlistedAttributesForModel;
+ (id)allowlistedAttributesForStyle;
+ (id)allowlistedTypingAttributes;
+ (int)attributeForWritingDirection:(long long)direction;
+ (id)attributesForRun:(const void *)run;
+ (void)saveAttributes:(id)attributes toArchive:(void *)archive;
+ (void)saveAttributesOfString:(id)string toArchive:(void *)archive;
+ (long long)writingDirectionForAttribute:(int)attribute;

/* instance methods */
- (void)setAttributes:(id)attributes range:(struct _NSRange)range;
- (id)initWithCRCoder:(id)crcoder;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)replaceCharactersInRange:(struct _NSRange)range withString:(id)string;
- (id)attributesAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)serialize;
- (void)insertString:(id)string atIndex:(unsigned long long)index;
- (_Bool)attributesEqual:(id)equal to:(id)to modelEqual:(_Bool *)equal;
- (_Bool)attributesEqual:(id)equal toRange:(struct _NSRange)range modelEqual:(_Bool *)equal;
- (void)encodeWithCRCoder:(id)crcoder string:(void *)string;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id withOrderedSubstrings:(void *)substrings timestamp:(id)timestamp;
- (id)initWithCRCoder:(id)crcoder string:(const void *)string;
- (void)saveDeltaSinceTimestamp:(id)timestamp toArchive:(void *)archive;
- (void)saveToArchive:(void *)archive;
- (void)setAttributes:(id)attributes substring:(void *)substring;

@end


@interface TTMergeableStringSelection : NSObject <TTMergeableStringIDTracker>

@property (nonatomic) unsigned long long selectionAffinity;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (void *)selectionRanges;
- (_Bool)isEqual:(id)equal;
- (id)initWithData:(id)data;
- (id)serialize;
- (id)initWithArchive:(const void *)archive;
- (void)updateTopoIDRange:(struct TopoIDRange)idrange toNewRangeID:(struct TopoIDRange)id;
- (_Bool)hasTopoIDsThatCanChange;
- (void)saveToArchive:(void *)archive;

@end


@interface TTMergeableStringUndoAttributeCommand : NSObject <TTMergeableStringUndoCommand>

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


@interface TTMergeableStringUndoEditCommand : NSObject <TTMergeableStringUndoCommand>

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


@interface TTMergeableStringUndoGroup : NSObject <TTMergeableStringUndoCommand>

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


@interface TTVersionedDocument : NSObject

@property (nonatomic) void * documentArchive;
@property (readonly, nonatomic) unsigned long long futureVersionCount;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;
+ (unsigned int)versionedDocumentSerializationVersion;

/* instance methods */
- (id)initWithData:(id)data;
- (id)serialize;
- (void)dealloc;
- (void)loadArchive:(const void *)archive;
- (id)initWithArchive:(const void *)archive;
- (void)loadData:(id)data;
- (void)loadDocumentArchive:(void *)archive;
- (unsigned int)maxDocumentVersion;
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (unsigned long long)mergeWithVersionedDocument:(id)document;
- (void)saveCurrentVersion:(void *)version;
- (void)saveToArchive:(void *)archive;
- (id)serializeCurrentVersion:(unsigned int *)version;

@end


@interface TTMergeableStringVersionedDocument : TTVersionedDocument <REMReplicaClockProviding>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) TTMergeableAttributedString *mergeableString;

/* class methods */
+ (unsigned int)minimumSupportedVersion;
+ (unsigned int)serializationVersion;

/* instance methods */
- (id)clockElementListForReplicaUUID:(id)uuid;
- (id)initWithArchive:(const void *)archive andReplicaID:(id)id;
- (id)initWithData:(id)data andReplicaID:(id)id;
- (id)initWithMergeableString:(id)string;
- (void)mergeVersion:(unsigned int)version fromData:(id)data;
- (unsigned long long)mergeWithStringVersionedDocument:(id)document;
- (id)rem_copyWithReplicaIDForNewEdits:(id)edits;
- (_Bool)rem_isEqual:(id)equal;
- (id)serializeCurrentVersion:(unsigned int *)version;

@end


@interface TTParagraphStyle : NSObject <NSSecureCoding, NSCopying, NSMutableCopying, TTModelAttributeComparable>

@property (nonatomic) unsigned int style;
@property (nonatomic) long long alignment;
@property (nonatomic) long long writingDirection;
@property (nonatomic) unsigned long long indent;
@property (nonatomic) unsigned long long startingItemNumber;
@property (nonatomic) unsigned int hints;
@property (nonatomic) _Bool needsParagraphCleanup;
@property (nonatomic) _Bool needsListCleanup;
@property (readonly, nonatomic) _Bool canIndent;
@property (readonly, nonatomic) _Bool isList;
@property (readonly, nonatomic) _Bool isHeader;
@property (readonly, nonatomic) _Bool uniqueToLine;
@property (readonly, nonatomic) _Bool preferSingleLine;
@property (readonly, nonatomic) _Bool wantsFollowingNewLine;
@property (readonly, nonatomic) NSUUID *trackingUUID;
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

@end


@interface TTMutableParagraphStyle : TTParagraphStyle

@property (nonatomic) unsigned int style;
@property (nonatomic) long long alignment;
@property (nonatomic) long long writingDirection;
@property (nonatomic) unsigned long long indent;
@property (nonatomic) unsigned long long startingItemNumber;
@property (nonatomic) unsigned int hints;
@property (nonatomic) _Bool needsParagraphCleanup;
@property (nonatomic) _Bool needsListCleanup;

/* class methods */
+ (id)paragraphStyleNamed:(unsigned int)named;

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;

@end


@interface TTREMHashtag : NSObject <TTModelAttributeComparable, NSSecureCoding>

@property (copy, nonatomic) NSString *objectIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (_Bool)isHashtag:(id)hashtag equalToModelComparable:(id)comparable;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (_Bool)isEqualToModelComparable:(id)comparable;

@end


@interface TTVectorTimestampElement : NSObject

@property (nonatomic) unsigned long long clock;
@property (nonatomic) unsigned long long subclock;

@end


@interface _REMAppStoreReviewCloudConfigurationStorage : NSObject <REMAppStoreReviewCloudConfiguration>

@property (readonly, nonatomic) unsigned long long appStoreReviewCreatedOrCompletedRemindersCountThreshold;
@property (readonly, nonatomic) unsigned long long appStoreReviewNumberOfForegroundsThreshold;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalOfInterest;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceInitialForeground;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceLastPrompt;
@property (readonly, nonatomic) double appStoreReviewTimeIntervalSinceLastFetch;

/* instance methods */
- (id)initWithCreatedOrCompletedRemindersCountThreshold:(unsigned long long)threshold numberOfForegroundsThreshold:(unsigned long long)threshold timeIntervalOfInterest:(double)interest timeIntervalSinceInitialForeground:(double)foreground timeIntervalSinceLastFetch:(double)fetch timeIntervalSinceLastPrompt:(double)prompt;

@end


@interface _REMChangeTrackingClientID : NSObject <REMChangeTrackingClientIdentifying>

@property (readonly, nonatomic) NSString *clientName;
@property (readonly, nonatomic) NSString *accountIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithClientName:(id)name accountIdentifier:(id)identifier;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface _REMChangeUniversalToken : REMChangeToken

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)universalToken;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (long long)compareToken:(id)token error:(id *)error;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (_Bool)isUniversal;

@end


@interface _REMChangedObjectIDStorage : NSObject <NSCopying, NSSecureCoding, REMChangedObjectIdentifying>

@property (retain, nonatomic) NSUUID *uuid;
@property (retain, nonatomic) NSString *entityName;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)initWithUUID:(id)uuid entityName:(id)name;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;

@end


@interface _REMDACalDAVSyncReplicaManagerProvider : NSObject <REMReplicaManagerProviding>

@property (retain, nonatomic) REMStore *store;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)unsavedReplicaManagersForAccountIDs:(id)ids;
+ (id)replicaManagerForAccountID:(id)id withStore:(id)store;

/* instance methods */
- (id)unsavedReplicaManagersForAccountIDs:(id)ids;
- (id)initWithStore:(id)store;
- (id)replicaManagerForAccountID:(id)id;

@end


@interface _REMDefaultReplicaManagerProvider : NSObject <REMReplicaManagerProviding>

@property (readonly, nonatomic) REMStore *store;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)unsavedReplicaManagersForAccountIDs:(id)ids;
- (_Bool)isEqual:(id)equal;
- (id)initWithStore:(id)store;
- (id)replicaManagerForAccountID:(id)id;

@end


@interface _REMICloudIsOffCloudConfigurationStorage : NSObject <REMICloudIsOffCloudConfiguration>

@property (readonly, nonatomic) double iCloudIsOffTimeIntervalSinceLastPrompt;

/* instance methods */
- (id)initWithTimeIntervalSinceLastPrompt:(double)prompt;

@end


@interface _REMInProgressSaveRequestsContainer : NSObject

@property (retain, nonatomic) NSMutableArray *inProgressSaveRequests;

/* instance methods */
- (id)_latestSaveInProgressReminderForObjectID:(id)id fallbackAccount:(id)account fallbackList:(id)list fallbackParentList:(id)list fallbackParentReminder:(id)reminder saveRequest:(id)request;
- (void)saveRequestSaveDidFinish:(id)finish;
- (id)latestSaveInProgressAccount:(id)account;
- (id)init;
- (id)latestSaveInProgressReminder:(id)reminder;
- (id)_latestSaveInProgressListForObjectID:(id)id fallbackAccount:(id)account fallbackParentList:(id)list saveRequest:(id)request;
- (id)latestSaveInProgressList:(id)list;
- (id)_latestSaveInProgressAccountForObjectID:(id)id saveRequest:(id)request;
- (id)_firstMatchInSaveRequests:(id /* block */)requests;
- (void)saveRequestSaveDidStart:(id)start;
- (id)latestSaveInProgressReminderForReminderChangeItem:(id)item;

@end


@interface _REMNSPersistentHistoryChangeStorage : NSObject <NSSecureCoding>

@property (nonatomic) long long changeID;
@property (copy, nonatomic) _REMChangedObjectIDStorage *changedObjectIDStorage;
@property (nonatomic) long long changeType;
@property (copy, nonatomic) REMNSPersistentHistoryChangeTombstone *tombstone;
@property (copy, nonatomic) NSSet *updatedProperties;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface _REMNSPersistentHistoryTransactionStorage : NSObject <NSSecureCoding>

@property (copy, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSArray *changes;
@property (nonatomic) long long transactionNumber;
@property (copy, nonatomic) NSString *storeID;
@property (copy, nonatomic) NSString *bundleID;
@property (copy, nonatomic) NSString *processID;
@property (copy, nonatomic) NSString *contextName;
@property (copy, nonatomic) NSString *author;
@property (retain, nonatomic) REMNSPersistentHistoryToken *token;
@property (copy, nonatomic) REMObjectID *accountID;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface ACAccount (REM)

/* instance methods */
- (_Bool)rem_didChooseToMigrate;
- (_Bool)rem_didFinishMigration;
- (_Bool)rem_eligibleForAutoCloudKitMigration;
- (_Bool)rem_isEligibleForCloudKitReminders;
- (_Bool)rem_isManagedAppleID;
- (_Bool)rem_isPrimaryAppleAccount;

@end


@interface CKAllowedSharingOptions (ReminderKitAdditions)

/* class methods */
+ (id)rem_remindersAllowedSharingOptions;

@end


@interface ICSDate (ReminderKitAdditions)

/* instance methods */
- (id)rem_dateAsUTC;
- (id)rem_dateWithICSCalendar:(id)icscalendar;

@end


@interface ICSTodo (REMSaveRequestImporting)

/* instance methods */
- (id)rem_nonNilSummary;

@end


@interface NSAttributedString (REMCRMergeableStringDocument_Hashtags)

/* instance methods */
- (void)rem_enumerateHashtagInRange:(struct _NSRange)range options:(unsigned long long)options usingBlock:(id /* block */)block;
- (unsigned long long)rem_fontHintAtIndex:(long long)index effectiveRange:(struct _NSRange *)range;
- (id)rem_hashtagAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range;
- (id)rem_hashtagAtIndex:(unsigned long long)index effectiveRange:(struct _NSRange *)range wantsLongestEffectiveRange:(_Bool)range inRange:(struct _NSRange)range;
- (id)rem_hashtagAtIndex:(unsigned long long)index longestEffectiveRange:(struct _NSRange *)range inRange:(struct _NSRange)range;
- (_Bool)rem_isUnderlinedAtIndex:(long long)index effectiveRange:(struct _NSRange *)range;
- (id)rem_paragraphStyleAtIndex:(long long)index effectiveRange:(struct _NSRange *)range;

@end


@interface NSCharacterSet (TTRAdditions)

/* class methods */
+ (id)emojis;
+ (id)hashtagTokenAllowedCharacters;
+ (id)makeFormatCharacters;
+ (void)subtractOtherPunctuationCharactersFrom:(id)from;

@end


@interface NSData (HexStringAdditions)

/* class methods */
+ (id)dataFromBase64String:(id)string;
+ (id)rem_dataWithHexString:(id)string;
+ (id)rem_dataWithRandomBytesWithLength:(unsigned long long)length;

/* instance methods */
- (id)base64EncodedString;
- (id)TT_gzipDeflate;
- (id)TT_gzipInflate;

@end


@interface NSDate (ReminderKitAdditions)

/* class methods */
+ (id)rem_now;
+ (id)debug_rem_nowOverride;
+ (void)setDebug_rem_nowOverride:(id)override;

@end


@interface NSDateComponents (ReminderKitAdditions)

/* class methods */
+ (id)rem_dateWithDateComponents:(id)components timeZone:(id)zone;
+ (id)rem_dateComponentsWithDate:(id)date timeZone:(id)zone isAllDay:(_Bool)day;
+ (id)rem_dateComponentsWithDateUsingArchivingTimeZone:(id)zone isAllDay:(_Bool)day;
+ (id)rem_dateComponentsWithYear:(long long)year month:(long long)month day:(long long)day hour:(long long)hour minute:(long long)minute second:(long long)second allDay:(_Bool)day timeZone:(id)zone;
+ (id)rem_dateWithDateComponentsUsingArchivingTimeZone:(id)zone;

/* instance methods */
- (id)rem_allDayDateComponents;
- (long long)rem_compare:(id)rem_compare;
- (id)rem_dateComponentsByAddingTimeInterval:(double)interval;
- (id)rem_gregorianEquivalent;
- (_Bool)rem_isAllDayDateComponents;
- (_Bool)rem_isValidDateComponents;
- (_Bool)rem_isWeekendDateComponents;
- (id)rem_stringRepresentation;
- (id)rem_strippingTimeZone;

@end


@interface NSDictionary (REMDistributedEvaluationCollectionOptions)

/* instance methods */
- (_Bool)remdes_boolForKey:(id)key defaultValue:(_Bool)value;
- (double)remdes_doubleForKey:(id)key defaultValue:(double)value;
- (unsigned long long)remdes_nsuintegerForKey:(id)key defaultValue:(unsigned long long)value;

@end


@interface NSError (REMChangeError)

/* class methods */
+ (id)_defaultDescriptionForREMChangeErrorCode:(long long)code;
+ (id)errorWithREMChangeErrorCode:(long long)code;
+ (id)errorWithREMChangeErrorCode:(long long)code debugDescription:(id)description;
+ (id)errorWithREMChangeErrorCode:(long long)code description:(id)description underlyingError:(id)error;
+ (id)errorWithREMChangeErrorCode:(long long)code underlyingError:(id)error;

@end


@interface NSFileManager (radar_107076618)

/* class methods */
+ (id)remcrtt_createTemporaryFileDirectoryURLIfNeeded;

@end


@interface NSISO8601DateFormatter (ReminderKitAdditions)

/* class methods */
+ (id)rem_formatterWithTimeZone:(id)zone;

/* instance methods */
- (id)rem_dateComponentsFromString:(id)string;
- (id)rem_stringFromDateComponents:(id)components;

@end


@interface NSMutableAttributedString (ReminderKitAdditions)

/* instance methods */
- (void)ic_appendAttributedSubstring:(id)substring fromRange:(struct _NSRange)range;
- (void)ic_replaceCharactersInRange:(struct _NSRange)range withAttributedSubstring:(id)substring fromRange:(struct _NSRange)range;
- (void)rem_addHashtag:(id)hashtag range:(struct _NSRange)range;
- (void)rem_addParagraphNamedStyle:(long long)style inRange:(struct _NSRange)range;
- (void)rem_removeHashtagInRange:(struct _NSRange)range;
- (void)rem_removeParagraphNamedStyleFromRange:(struct _NSRange)range;
- (_Bool)rem_replaceTTREMHashtag:(id)ttremhashtag withTTREMHashtag:(id)ttremhashtag;
- (void)rem_setFontHint:(unsigned long long)hint isOn:(_Bool)on inRange:(struct _NSRange)range;
- (void)rem_setUnderline:(_Bool)underline inRange:(struct _NSRange)range;

@end


@interface NSNumber (CRDT_Additions) <CRDataType, CREquatable, CRCoding>

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;

@end


@interface NSObject (REMHumanReadableIdentifier)

/* instance methods */
- (id)rem_humanReadableIdentifier;

@end


@interface NSString (ReminderKitAdditions) <CRDataType, CREquatable, CRCoding, REMDAChangedIdentifierResult>

/* class methods */
+ (void)rem_registerClassAtCRCoderIfNeeded;
+ (_Bool)rem_isFirstString:(id)string equalToSecondString:(id)string;

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (id)rem_removingTel;
- (id)rem_addingMailto;
- (id)rem_addingTel;
- (_Bool)rem_hasMailto;
- (_Bool)rem_hasPrefixCaseInsensitive:(id)insensitive;
- (_Bool)rem_hasTel;
- (id)rem_removingMailto;
- (id)rem_tidyFormattedNameString;

@end


@interface NSTimeZone (ReminderKitAdditions)

/* class methods */
+ (id)remDebugTimeZone_GMT;
+ (id)remDebugTimeZone_LosAngeles;
+ (id)remDebugTimeZone_NewYork;

/* instance methods */
- (_Bool)rem_isEquivalentTo:(id)to;

@end


@interface NSURL (REMPaths_Additions)

/* instance methods */
- (id)rem_URLByAppendingReminderDataContainerPathComponent;

@end


@interface NSUUID (CRDT_Additions) <CRDataType, CREquatable, CRCoding>

/* class methods */
+ (id)CR_zero;
+ (id)CR_UUIDFromStdString:(const void *)string;
+ (id)CR_repeatedCharUUID:(unsigned char)uuid;
+ (id)TTZero;

/* instance methods */
- (void)setDocument:(id)document;
- (id)tombstone;
- (id)initWithCRCoder:(id)crcoder;
- (id)deltaSince:(id)since in:(id)in;
- (void)encodeWithCRCoder:(id)crcoder;
- (void)mergeWith:(id)with;
- (void)realizeLocalChangesIn:(id)in;
- (void)walkGraph:(id /* block */)graph;
- (void *)CR_toStdString;
- (long long)CR_compare:(id)cr_compare;
- (id)CR_shortDescription;
- (long long)TTCompare:(id)ttcompare;
- (id)TTShortDescription;

@end


@interface NSUserDefaults (ReminderKitAdditions)

/* instance methods */
- (id)objectIDForKey:(id)key;
- (void)setObjectID:(id)id forKey:(id)key;

@end


#endif /* ReminderKit_h */
