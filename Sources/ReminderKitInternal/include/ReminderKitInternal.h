// Normalized full dump import surface for ReminderKitInternal.

// Source: local ipsw class-dump output; normalized for Swift/Clang import.

#ifndef ReminderKitInternal_h

#define ReminderKitInternal_h



#import <Foundation/Foundation.h>

@import ReminderKit;

@import Intents;

@import CoreML;





struct _NSRange;



@class ACAccount, ConfigurationIntent, ConfigurationIntentResponse, ConfigurationList, ConfigurationListResolutionResult, DispatchQueue, INIntent, INIntentResponse, INObject, INObjectResolutionResult, REMAccount, REMAccount_Codable;

@class REMAccountsListDataView_Invocation, REMColor, REMColor_Codable, REMComplicationDataViewFetchModelInvocation, REMComplicationDataViewFetchModelInvocationResult, REMDueDateDeltaInterval, REMDueDateDeltaInterval_Codable, REMFetchResultToken, REMFetchResultToken_Codable, REMGroceryDataView_SecondaryGroceryLocaleInvocation, REMHashtagLabel, REMHashtagLabelDataView_AllHashtagLabelsDetailedInvocation;

@class REMHashtagLabelDataView_AllHashtagLabelsInvocation, REMHashtagLabelDataView_HashtagIDsWithHashtagLabelNamesInvocation, REMHashtagLabelDataView_HashtagLabelsReferencedByCustomSmartListFiltersInvocation, REMHashtagLabelDataView_ReminderIDsIncludeExcludeOperationInvocation, REMHashtagLabelDetailed_Codable, REMHashtagLabel_Codable, REMList, REMListPickerDataView_FlaggedInvocation, REMListStableSortingDataView_Invocation, REMList_Codable, REMNLQueryParser, REMOVSChecker;

@class REMObjectID, REMObjectID_Codable, REMPermanentlyHiddenDataView_PermanentlyHiddenInvocation, REMPrivacyPermissionsDataView_IncompleteRemindersCountWithDueDateInvocation, REMPrivacyPermissionsDataView_IncompleteRemindersCountWithLocationInvocation, REMPrivacyPermissionsDataView_IncompleteRemindersCountWithUrgentAlarmInvocation, REMRegulatoryLogger, REMReminder, REMReminderDetailDataView_CheckUpdateInvocation, REMReminderFetchOptions, REMReminderFetchOptions_Codable, REMReminderPredicateDescriptor;

@class REMReminderPredicateDescriptor_Codable, REMReminder_Codable, REMRemindersInCalendarDataView_Invocation, REMRemindersListBatchDeleteInvocation_CountInvocation, REMRemindersListBatchDeleteInvocation_DeleteInvocation, REMRemindersListBatchDeleteInvocation_OldestCompletionDateInvocation, REMRemindersListDataView_AllInvocation, REMRemindersListDataView_AllSectionsInvocation, REMRemindersListDataView_AppIntentsSectionsInvocation, REMRemindersListDataView_AssignedInvocation, REMRemindersListDataView_CompletedByDateBucketsInvocation, REMRemindersListDataView_CustomSmartListInvocation;

@class REMRemindersListDataView_CustomSmartListSectionsInvocation, REMRemindersListDataView_DEBUG_AssignedCountInvocation, REMRemindersListDataView_DEBUG_PhantomRemindersInvocation, REMRemindersListDataView_FlaggedInvocation, REMRemindersListDataView_GroupInvocation, REMRemindersListDataView_GroupSectionsInvocation, REMRemindersListDataView_ListInvocation, REMRemindersListDataView_ListSectionsInvocation, REMRemindersListDataView_PublicTemplateInvocation, REMRemindersListDataView_RecentlyDeletedInvocation, REMRemindersListDataView_ScheduledByDateBucketsInvocation, REMRemindersListDataView_ScheduledByDayInvocation;

@class REMRemindersListDataView_ScheduledFlatInvocation, REMRemindersListDataView_SearchFlatInvocation, REMRemindersListDataView_SearchInvocation, REMRemindersListDataView_SiriFoundInAppsInvocation, REMRemindersListDataView_TaggedInvocation, REMRemindersListDataView_TemplateInvocation, REMRemindersListDataView_TemplateSectionsInvocation, REMRemindersListDataView_TodayGroupInvocation, REMRemindersListDataView_TodayNotificationInvocation, REMRemindersListDataView_TodaySectionOrderingInvocation, REMRemindersListDataView_UrgentAlarmInvocation, REMSharedEntitySyncActivity;

@class REMSharedEntitySyncActivity_Codable, REMSiriSearchDataView_ListsByCriteriaInvocation, REMSiriSearchDataView_RemindersByCriteriaInvocation, REMSmartList, REMSmartList_Codable, REMStoreInvocation, REMStoreInvocationResult, REMStoreSwiftInvocation, REMStructuredLocation, REMStructuredLocation_Codable, REMSuggestedAttributesHarvester_FeedbackInvocation, REMSuggestedAttributesHarvester_Invocation;

@class REMSuggestedAttributesHarvester_MentionsExtractionInvocation, REMSuggestedAttributesHarvester_PostSuggestionAnalyticsInvocation, REMSuggestedAttributesHarvester_RecordSuggestionInvocation, REMSuggestedAttributesTrainer, REMTemplate, REMTemplateConfiguration, REMTemplateConfiguration_Codable, REMTemplatePublicLinkConfiguration, REMTemplatePublicLinkConfiguration_Codable, REMTemplate_Codable, RMDARC4RandomSource, RMDMersenneTwisterRandomSource;

@class RMDRandomSource, RMDSystemArc4RandomSource, TTRNLTextSlotParser, TTRNLTextStructuredEvent, TTRNLTextStructuredEventLocation, TTRNLTextStructuredEventRecurrentEvent, _TtC19ReminderKitInternal10PointCloud, _TtC19ReminderKitInternal10UnfairLock, _TtC19ReminderKitInternal12REMPCASolver, _TtC19ReminderKitInternal13MockACAccount, _TtC19ReminderKitInternal14BasicTokenizer, _TtC19ReminderKitInternal14REMTrialClient;

@class _TtC19ReminderKitInternal15KMeansAutoTuner, _TtC19ReminderKitInternal15MersenneTwister, _TtC19ReminderKitInternal16RDIDispatchQueue, _TtC19ReminderKitInternal16REMBertTokenizer, _TtC19ReminderKitInternal16REMSuggestedList, _TtC19ReminderKitInternal16REMWidgetRefresh, _TtC19ReminderKitInternal18REMAlarmKitManager, _TtC19ReminderKitInternal18REMGroceryDataView, _TtC19ReminderKitInternal18REMGroceryLanguage, _TtC19ReminderKitInternal18WordpieceTokenizer, _TtC19ReminderKitInternal19ClassificationLabel, _TtC19ReminderKitInternal19REMAnalyticsManager;

@class _TtC19ReminderKitInternal19REMContactsProvider, _TtC19ReminderKitInternal19REMSuggestedContact, _TtC19ReminderKitInternal19REMSuggestedWeekDay, _TtC19ReminderKitInternal19URLQueryItemDecoder, _TtC19ReminderKitInternal19URLQueryItemEncoder, _TtC19ReminderKitInternal20RDIntentClusterModel, _TtC19ReminderKitInternal20REMGroceryDummyModel, _TtC19ReminderKitInternal20REMSuggestedLocation, _TtC19ReminderKitInternal21REMBertTextClassifier, _TtC19ReminderKitInternal21REMListPickerDataView, _TtC19ReminderKitInternal21REMNLQueryParserUtils, _TtC19ReminderKitInternal21REMShortTimeFormatter;

@class _TtC19ReminderKitInternal21REMSiriSearchDataView, _TtC19ReminderKitInternal21REMTestStorePopulator, _TtC19ReminderKitInternal22PromiseDisposableToken, _TtC19ReminderKitInternal22REMAnchoredBubbleModel, _TtC19ReminderKitInternal22REMRegExTextClassifier, _TtC19ReminderKitInternal22REMkNNByTitleEmbedding, _TtC19ReminderKitInternal23REMAccountsListDataView, _TtC19ReminderKitInternal23REMComplicationDataView, _TtC19ReminderKitInternal23REMHashtagLabelDataView, _TtC19ReminderKitInternal23REMLinearAlgebraDataRef, _TtC19ReminderKitInternal24REMMutableManualOrdering, _TtC19ReminderKitInternal24REMStoreObjectsContainer;

@class _TtC19ReminderKitInternal25REMFilteredTitleEmbedding, _TtC19ReminderKitInternal25REMReminderDetailDataView, _TtC19ReminderKitInternal26REMBertTextClassifierInput, _TtC19ReminderKitInternal26REMStoreInvocationKeySpace, _TtC19ReminderKitInternal26REMSuggestedAttributeInput, _TtC19ReminderKitInternal28REMListStableSortingDataView, _TtC19ReminderKitInternal28REMPermanentlyHiddenDataView, _TtC19ReminderKitInternal29REMPrivacyPermissionsDataView, _TtC19ReminderKitInternal29REMSentence2VecTitleEmbedding, _TtC19ReminderKitInternal29REMSuggestedAttributesElector, _TtC19ReminderKitInternal30REMRemindersInCalendarDataView, _TtC19ReminderKitInternal30REMStoppedAlarmActivityManager;

@class _TtC19ReminderKitInternal31REMSuggestedAttributesHarvester, _TtC19ReminderKitInternal33REMUniversalGrammarTitleEmbedding, _TtC19ReminderKitInternal34REMCustomSmartListFilterDescriptor, _TtC19ReminderKitInternal35REMModelsAvailabilityManagerWrapper, _TtC19ReminderKitInternal37REMRemindersListBatchDeleteInvocation, _TtC19ReminderKitInternal38REMGenerativeModelsAvailabilityManager, _TtC19ReminderKitInternal38REMSuggestedAttributesFeatureExtractor, _TtC19ReminderKitInternal39REMSuggestedAttributeReminderDataSource, _TtC19ReminderKitInternal6KMeans, _TtC19ReminderKitInternal8RDVector, _TtC19ReminderKitInternal9Analytics, _TtC19ReminderKitInternal9MutexLock;

@class _TtC19ReminderKitInternalP33_255C7DF2D224A241D5942E95740EB31736UniversalLinkAppIconBundleIDResolver, _TtC19ReminderKitInternalP33_313B365B2A704FA0A78155DE61C5B33510QueryItems, _TtC19ReminderKitInternalP33_313B365B2A704FA0A78155DE61C5B33515InternalDecoder, _TtC19ReminderKitInternalP33_524A0B41D11BBD41890C06F9E7BF420611LookupClass, _TtC19ReminderKitInternalP33_5F7D22EC3CAFE1E43A670F609018406B20DefaultDumpFormatter, _TtC19ReminderKitInternalP33_8A505856BCBA7C801180EE3645A2D00935REMGenerativeModelsAvailabilityInfo, _TtC19ReminderKitInternalP33_BCDA9BEAAF9519B32B6DBABA4FDACDFF17TemporaryOverride, _TtC19ReminderKitInternalP33_BCDA9BEAAF9519B32B6DBABA4FDACDFF25ExternalTemporaryOverride, _TtC19ReminderKitInternalP33_F8096D6C8A98A78E7FC1F653291D8AD315InternalEncoder, _TtCE19ReminderKitInternalV10Foundation3URLP33_C4CF88CCEEBFE10B546F9B83C3AB9A6B23SecurityScopedURLHolder, _TtCV19ReminderKitInternal25UrgentAlarmCompleteIntentP33_E6CD1A297CE4D25376421304554ED9F515EditedObjectIDs;

@protocol CNKeyDescriptor, ConfigurationIntentHandling, OS_os_activity, REMNullableObjectIDProviding, REMObjectIDIdentifiable, REMObjectIDProviding, RMDRandom;



@protocol CNKeyDescriptor <NSObject, NSSecureCoding, NSCopying>

@required

@optional

@end


@protocol ConfigurationIntentHandling <NSObject>

@required

/* required instance methods */
- (void)provideListOptionsCollectionForConfiguration:(id)configuration searchTerm:(id)term withCompletion:(id /* block */)completion;

@optional

/* optional instance methods */
- (void)handleConfiguration:(id)configuration completion:(id /* block */)completion;
- (void)confirmConfiguration:(id)configuration completion:(id /* block */)completion;
- (id)defaultListForConfiguration:(id)configuration;
- (void)provideListOptionsForConfiguration:(id)configuration withCompletion:(id /* block */)completion;

@end


@protocol OS_os_activity <NSObject>

@required

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


@protocol REMObjectIDIdentifiable

@required

@property (readonly, nonatomic) REMObjectID *remObjectID;

@optional

@end


@protocol REMObjectIDProviding <REMNullableObjectIDProviding>

@required

@property (readonly, nonatomic) REMObjectID *remObjectID;

@optional

@end


@protocol RMDRandom

@required

/* required instance methods */
- (unsigned long long)nextIntWithUpperBound:(unsigned long long)bound;
- (long long)nextInt;
- (_Bool)nextBool;
- (float)nextUniform;

@optional

@end


@interface ConfigurationIntent : INIntent // (Swift)

@property (nonatomic, retain) ConfigurationList *list;

/* instance methods */
- (id)init;
- (id)initWithDomain:(id)domain verb:(id)verb parametersByName:(id)name;
- (id)initWithIdentifier:(id)identifier backingStore:(id)store;
- (id)initWithCoder:(id)coder;

@end


@interface ConfigurationIntentResponse : INIntentResponse // (Swift)

@property (nonatomic, copy) NSString *list;
@property (nonatomic) long long code;

/* instance methods */
- (id)init;
- (id)initWithBackingStore:(id)store;
- (id)initWithCoder:(id)coder;
- (id)initWithCode:(long long)code userActivity:(id)activity;
- (id)initWithPropertiesByName:(id)name;

@end


@interface ConfigurationList : INObject // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithIdentifier:(id)identifier displayString:(id)string pronunciationHint:(id)hint;
- (id)initWithCoder:(id)coder;

@end


@interface ConfigurationListResolutionResult : INObjectResolutionResult // (Swift)

/* class methods */
+ (id)confirmationRequiredWithObjectToConfirm:(id)confirm;
+ (id)disambiguationWithObjectsToDisambiguate:(id)disambiguate;
+ (id)successWithResolvedObject:(id)object;
+ (id)confirmationRequiredWithConfigurationListToConfirm:(id)confirm;
+ (id)disambiguationWithConfigurationListsToDisambiguate:(id)disambiguate;
+ (id)successWithResolvedConfigurationList:(id)list;

/* instance methods */
- (id)initWithJSONDictionary:(id)jsondictionary forIntent:(id)intent;

@end


@interface REMAccount_Codable : REMAccount // (Swift)

/* instance methods */
- (id)initWithStore:(id)store storage:(id)storage;

@end


@interface REMAccountsListDataView_Invocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMColor_Codable : REMColor // (Swift)

/* instance methods */
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha colorSpace:(unsigned long long)space;
- (id)initWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha colorSpace:(unsigned long long)space daSymbolicColorName:(id)name daHexString:(id)string ckSymbolicColorName:(id)name;
- (id)init;
- (id)initWithCKSymbolicColorName:(id)name hexString:(id)string;
- (id)initWithHexString:(id)string;
- (id)initWithDASymbolicColorName:(id)name daHexString:(id)string;
- (id)initWithCoder:(id)coder;

@end


@interface REMComplicationDataViewFetchModelInvocation : REMStoreInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMComplicationDataViewFetchModelInvocationResult : REMStoreInvocationResult

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMDueDateDeltaInterval_Codable : REMDueDateDeltaInterval // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)init;
- (id)initWithCoder:(id)coder;
- (id)initWithUnit:(long long)unit count:(long long)count;
- (id)initWithUnitInteger:(long long)integer count:(long long)count;

@end


@interface REMFetchResultToken_Codable : REMFetchResultToken // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithPersistentHistoryTokens:(id)tokens;
- (id)initWithCoder:(id)coder;

@end


@interface REMGroceryDataView_SecondaryGroceryLocaleInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDataView_AllHashtagLabelsDetailedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDataView_AllHashtagLabelsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDataView_HashtagIDsWithHashtagLabelNamesInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDataView_HashtagLabelsReferencedByCustomSmartListFiltersInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDataView_ReminderIDsIncludeExcludeOperationInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMHashtagLabelDetailed_Codable : REMHashtagLabel // (Swift)

/* instance methods */
- (id)initWithName:(id)name;
- (id)initWithCoder:(id)coder;
- (id)initWithName:(id)name canonicalName:(id)name firstOccurrenceCreationDate:(id)date recencyDate:(id)date uuidForChangeTracking:(id)tracking;

@end


@interface REMHashtagLabel_Codable : REMHashtagLabel // (Swift)

/* instance methods */
- (id)initWithName:(id)name;
- (id)initWithCoder:(id)coder;
- (id)initWithName:(id)name canonicalName:(id)name firstOccurrenceCreationDate:(id)date recencyDate:(id)date uuidForChangeTracking:(id)tracking;

@end


@interface REMListPickerDataView_FlaggedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMListStableSortingDataView_Invocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMList_Codable : REMList // (Swift)

/* instance methods */
- (id)initWithStore:(id)store account:(id)account storage:(id)storage;

@end


@interface REMNLQueryParser : NSObject

@property (readonly, nonatomic) NSLocale *locale;
@property (readonly, nonatomic) NSDate *referenceDate;

/* instance methods */
- (id)parseString:(id)string;
- (id)initWithLocale:(id)locale referenceDate:(id)date referenceTimeZone:(id)zone forTesting:(_Bool)testing;
- (id)parserManagerTestOptions;

@end


@interface REMOVSChecker : NSObject

/* class methods */
+ (unsigned int)_lexiconTokenForToken:(id)token inLexicon:(struct _LXLexicon *)lexicon;
+ (_Bool)profanityInTokens:(id)tokens forLocaleIdentifier:(id)identifier;

@end


@interface REMObjectID_Codable : REMObjectID // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithUUID:(id)uuid entityName:(id)name;
- (id)initWithCoder:(id)coder;

@end


@interface REMPermanentlyHiddenDataView_PermanentlyHiddenInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMPrivacyPermissionsDataView_IncompleteRemindersCountWithDueDateInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMPrivacyPermissionsDataView_IncompleteRemindersCountWithLocationInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMPrivacyPermissionsDataView_IncompleteRemindersCountWithUrgentAlarmInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRegulatoryLogger : NSObject

/* class methods */
+ (void)attachmentAddedForType:(long long)type;
+ (void)attachmentAddedForUTType:(id)uttype;

@end


@interface REMReminderDetailDataView_CheckUpdateInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMReminderFetchOptions_Codable : REMReminderFetchOptions // (Swift)

/* instance methods */
- (id)init;
- (id)initWithCoder:(id)coder;
- (id)initWithIncludeConcealed:(_Bool)concealed includeDueDateDeltaAlerts:(_Bool)alerts;

@end


@interface REMReminderPredicateDescriptor_Codable : REMReminderPredicateDescriptor // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithType:(long long)type;
- (id)initWithCoder:(id)coder;
- (id)initWithReminderPredicateDescriptor:(id)descriptor;

@end


@interface REMReminder_Codable : REMReminder // (Swift)

/* instance methods */
- (id)initWithStore:(id)store storage:(id)storage;
- (id)initWithStore:(id)store account:(id)account storage:(id)storage;
- (id)initWithStore:(id)store list:(id)list storage:(id)storage;

@end


@interface REMRemindersInCalendarDataView_Invocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListBatchDeleteInvocation_CountInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListBatchDeleteInvocation_DeleteInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListBatchDeleteInvocation_OldestCompletionDateInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_AllInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_AllSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_AppIntentsSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_AssignedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_CompletedByDateBucketsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_CustomSmartListInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_CustomSmartListSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_DEBUG_AssignedCountInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_DEBUG_PhantomRemindersInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_FlaggedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_GroupInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_GroupSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_ListInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_ListSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_PublicTemplateInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_RecentlyDeletedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_ScheduledByDateBucketsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_ScheduledByDayInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_ScheduledFlatInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_SearchFlatInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_SearchInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_SiriFoundInAppsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TaggedInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TemplateInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TemplateSectionsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TodayGroupInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TodayNotificationInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_TodaySectionOrderingInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMRemindersListDataView_UrgentAlarmInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMSharedEntitySyncActivity_Codable : REMSharedEntitySyncActivity // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithAccountIdentifier:(id)identifier activityDate:(id)date activityType:(long long)type authorUserRecordIDString:(id)idstring ckParentCloudObjectEntityName:(id)name ckParentCloudObjectIdentifier:(id)identifier ckIdentifier:(id)identifier sharedEntityName:(id)name uuidForChangeTracking:(id)tracking;

@end


@interface REMSiriSearchDataView_ListsByCriteriaInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMSiriSearchDataView_RemindersByCriteriaInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (id)initWithCoder:(id)coder;

@end


@interface REMSmartList_Codable : REMSmartList // (Swift)

/* instance methods */
- (id)initWithStore:(id)store storage:(id)storage;
- (id)initWithStore:(id)store account:(id)account parentList:(id)list storage:(id)storage;

@end


@interface REMStructuredLocation_Codable : REMStructuredLocation // (Swift)

/* instance methods */
- (id)init;
- (id)initWithTitle:(id)title;
- (id)initWithCoder:(id)coder;
- (id)initWithTitle:(id)title locationUID:(id)uid;
- (id)initWithTitle:(id)title locationUID:(id)uid latitude:(double)latitude longitude:(double)longitude radius:(double)radius address:(id)address routing:(id)routing referenceFrameString:(id)string contactLabel:(id)label mapKitHandle:(id)handle;

@end


@interface REMSuggestedAttributesHarvester_FeedbackInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMSuggestedAttributesHarvester_Invocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMSuggestedAttributesHarvester_MentionsExtractionInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMSuggestedAttributesHarvester_PostSuggestionAnalyticsInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMSuggestedAttributesHarvester_RecordSuggestionInvocation : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMSuggestedAttributesTrainer : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)dealloc;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface REMTemplateConfiguration_Codable : REMTemplateConfiguration // (Swift)

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithSourceListID:(id)id shouldSaveCompleted:(_Bool)completed;

@end


@interface REMTemplatePublicLinkConfiguration_Codable : REMTemplatePublicLinkConfiguration // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithCoder:(id)coder;
- (id)initWithShouldIncludeHashtags:(_Bool)hashtags shouldIncludeAlarmTriggersBasedOnDateOrTimeInterval:(_Bool)interval shouldIncludeAlarmTriggersBasedOnLocationOrVehicle:(_Bool)vehicle;

@end


@interface REMTemplate_Codable : REMTemplate // (Swift)

/* instance methods */
- (id)initWithStore:(id)store storage:(id)storage;

@end


@interface RMDRandomSource : NSObject <RMDRandom, NSSecureCoding, NSCopying>

/* class methods */
+ (_Bool)supportsSecureCoding;
+ (id)sharedRandom;
+ (id)systemRandom;

/* instance methods */
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (unsigned long long)nextIntWithUpperBound:(unsigned long long)bound;
- (id)arrayByShufflingObjectsInArray:(id)array;
- (long long)nextInt;
- (_Bool)nextBool;
- (float)nextUniform;

@end


@interface RMDARC4RandomSource : RMDRandomSource

@property (copy, nonatomic) NSData *seed;

/* instance methods */
- (id)initWithSeed:(id)seed;
- (id)init;
- (void)dealloc;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (unsigned long long)nextIntWithUpperBound:(unsigned long long)bound;
- (long long)nextInt;
- (void)dropValuesWithCount:(unsigned long long)count;
- (unsigned long long)nextBits:(int)bits;
- (_Bool)nextBool;
- (float)nextUniform;

@end


@interface RMDMersenneTwisterRandomSource : RMDRandomSource

@property (nonatomic) unsigned long long seed;

/* instance methods */
- (id)initWithSeed:(unsigned long long)seed;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithCoder:(id)coder;
- (unsigned long long)nextIntWithUpperBound:(unsigned long long)bound;
- (long long)nextInt;
- (unsigned long long)nextBits:(int)bits;
- (_Bool)nextBool;
- (float)nextUniform;

@end


@interface RMDSystemArc4RandomSource : RMDRandomSource

/* instance methods */
- (id)copyWithZone:(struct _NSZone *)zone;
- (unsigned long long)nextIntWithUpperBound:(unsigned long long)bound;
- (long long)nextInt;

@end


@interface TTRNLTextSlotParser : NSObject

@property (retain, nonatomic) NSLocale *locale;
@property (nonatomic) void * parser;

/* instance methods */
- (void)dealloc;
- (id)initWithLocale:(id)locale now:(id)now;
- (id)parseString:(id)string referenceTimeZone:(id)zone;

@end


@interface TTRNLTextStructuredEvent : NSObject

@property (nonatomic) void * structuredEvent;
@property (readonly, nonatomic) TTRNLTextStructuredEventRecurrentEvent *recurrentEvent;
@property (readonly, nonatomic) NSArray *locations;

/* instance methods */
- (void)dealloc;
- (id)initWithStructuredEvent:(void *)event;

@end


@interface TTRNLTextStructuredEventLocation : NSObject

@property (nonatomic) struct _NSRange range;
@property (nonatomic) long long locationType;
@property (nonatomic) long long proximity;

/* instance methods */
- (id)description;
- (id)initWithRange:(struct _NSRange)range locationType:(long long)type proximity:(long long)proximity;

@end


@interface TTRNLTextStructuredEventRecurrentEvent : NSObject

@property (nonatomic) struct _NSRange range;
@property (retain, nonatomic) NSDate *startDate;
@property (retain, nonatomic) NSDate *endDate;
@property (nonatomic) _Bool isAllDay;
@property (copy, nonatomic) NSDictionary *frequency;
@property (copy, nonatomic) NSDateComponents *startDateComponents;
@property (copy, nonatomic) NSDateComponents *endDateComponents;
@property (copy, nonatomic) NSDateComponents *frequencyComponents;
@property (readonly, nonatomic) long long hourFrequency;
@property (readonly, nonatomic) long long dayFrequency;
@property (readonly, nonatomic) long long monthFrequency;
@property (readonly, nonatomic) long long weekOfMonthFrequency;
@property (readonly, nonatomic) long long weekDay;
@property (readonly, nonatomic) long long weekdayOrdinal;
@property (readonly, nonatomic) long long weekdayStart;
@property (readonly, nonatomic) long long weekdayEnd;
@property (readonly, nonatomic) long long weekOfYear;
@property (readonly, nonatomic) long long yearFrequency;

/* instance methods */
- (id)description;
- (long long)frequencyForKey:(id)key;
- (id)initWithRange:(struct _NSRange)range startDate:(id)date endDate:(id)date isAllDay:(_Bool)day frequency:(id)frequency;
- (id)initWithRange:(struct _NSRange)range startDate:(id)date endDate:(id)date isAllDay:(_Bool)day startComponents:(id)components endComponents:(id)components frequencyComponents:(id)components;

@end


@interface _TtC19ReminderKitInternal10PointCloud : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal10UnfairLock : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal12REMPCASolver : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal13MockACAccount : ACAccount

@property (nonatomic, readonly) NSString *aa_primaryEmail;
@property (nonatomic, readonly) NSString *aa_altDSID;
@property (nonatomic, readonly) NSArray *childAccounts;
@property (nonatomic, retain) NSMutableSet *enabledDataclasses;

/* instance methods */
- (_Bool)isEnabledForDataclass:(id)dataclass;
- (id)initWithAccountType:(id)type;
- (void)setEnabled:(_Bool)enabled forDataclass:(id)dataclass;
- (id)initWithCoder:(id)coder;
- (id)childAccountsWithAccountTypeIdentifier:(id)identifier;

@end


@interface _TtC19ReminderKitInternal14BasicTokenizer : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal14REMTrialClient : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal15KMeansAutoTuner : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal15MersenneTwister : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal16RDIDispatchQueue : NSObject // (Swift)

/* instance methods */
- (id)init;

@end


@interface _TtC19ReminderKitInternal16REMBertTokenizer : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal19ClassificationLabel : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal16REMSuggestedList : _TtC19ReminderKitInternal19ClassificationLabel // (Swift)

@end


@interface _TtC19ReminderKitInternal16REMWidgetRefresh : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal18REMAlarmKitManager : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal18REMGroceryDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal18REMGroceryLanguage : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal18WordpieceTokenizer : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal19REMAnalyticsManager : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal19REMContactsProvider : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal19REMSuggestedContact : _TtC19ReminderKitInternal19ClassificationLabel

@end


@interface _TtC19ReminderKitInternal19REMSuggestedWeekDay : _TtC19ReminderKitInternal19ClassificationLabel // (Swift)

@end


@interface _TtC19ReminderKitInternal19URLQueryItemDecoder : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal19URLQueryItemEncoder : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal20RDIntentClusterModel : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal20REMGroceryDummyModel : NSObject

/* class methods */
+ (_Bool)isGrocerySupportedForLocaleWithIdentifier:(id)identifier;

/* instance methods */
- (id)init;

@end


@interface _TtC19ReminderKitInternal20REMSuggestedLocation : _TtC19ReminderKitInternal19ClassificationLabel // (Swift)

@end


@interface _TtC19ReminderKitInternal21REMBertTextClassifier : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal21REMListPickerDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal21REMNLQueryParserUtils : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal21REMShortTimeFormatter : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal21REMSiriSearchDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal21REMTestStorePopulator : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal22PromiseDisposableToken : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal22REMAnchoredBubbleModel : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal22REMRegExTextClassifier : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal22REMkNNByTitleEmbedding : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal23REMAccountsListDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal23REMComplicationDataView : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal23REMHashtagLabelDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal23REMLinearAlgebraDataRef : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal24REMMutableManualOrdering : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal24REMStoreObjectsContainer : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal25REMFilteredTitleEmbedding : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal25REMReminderDetailDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal26REMBertTextClassifierInput : _TtCs12_SwiftObject <MLFeatureProvider>

@property (nonatomic, readonly) NSSet *featureNames;

/* instance methods */
- (id)featureValueForName:(id)name;

@end


@interface _TtC19ReminderKitInternal26REMStoreInvocationKeySpace : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal26REMSuggestedAttributeInput : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal28REMListStableSortingDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal28REMPermanentlyHiddenDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal29REMPrivacyPermissionsDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal29REMSentence2VecTitleEmbedding : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal29REMSuggestedAttributesElector : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal30REMRemindersInCalendarDataView : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal30REMStoppedAlarmActivityManager : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal31REMSuggestedAttributesHarvester : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal33REMUniversalGrammarTitleEmbedding : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal34REMCustomSmartListFilterDescriptor : NSObject <NSSecureCoding>

@property (nonatomic, readonly) NSString *description;

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)init;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC19ReminderKitInternal35REMModelsAvailabilityManagerWrapper : NSObject // (Swift)

/* class methods */
+ (_Bool)supportsAutoCategorizationGenerativeModels;

/* instance methods */
- (id)init;

@end


@interface _TtC19ReminderKitInternal37REMRemindersListBatchDeleteInvocation : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternal38REMGenerativeModelsAvailabilityManager : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal38REMSuggestedAttributesFeatureExtractor : REMStoreSwiftInvocation // (Swift)

/* class methods */
+ (_Bool)supportsSecureCoding;

/* instance methods */
- (id)initWithFetchResultTokenToDiffAgainst:(id)against;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;

@end


@interface _TtC19ReminderKitInternal39REMSuggestedAttributeReminderDataSource : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal6KMeans : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal8RDVector : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternal9Analytics : NSObject // (Swift)

/* class methods */
+ (void)postEventWithName:(id)name payload:(id)payload error:(id)error performAutoBugCaptureOnError:(_Bool)error;

/* instance methods */
- (id)init;

@end


@interface _TtC19ReminderKitInternal9MutexLock : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternalP33_255C7DF2D224A241D5942E95740EB31736UniversalLinkAppIconBundleIDResolver : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternalP33_313B365B2A704FA0A78155DE61C5B33510QueryItems : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternalP33_313B365B2A704FA0A78155DE61C5B33515InternalDecoder : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternalP33_524A0B41D11BBD41890C06F9E7BF420611LookupClass : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternalP33_5F7D22EC3CAFE1E43A670F609018406B20DefaultDumpFormatter : _TtCs12_SwiftObject // (Swift)

@end


@interface _TtC19ReminderKitInternalP33_8A505856BCBA7C801180EE3645A2D00935REMGenerativeModelsAvailabilityInfo : _TtCs12_SwiftObject

@end


@interface _TtC19ReminderKitInternalP33_BCDA9BEAAF9519B32B6DBABA4FDACDFF17TemporaryOverride : NSObject

/* instance methods */
- (id)init;
- (void)dealloc;

@end


@interface _TtC19ReminderKitInternalP33_BCDA9BEAAF9519B32B6DBABA4FDACDFF25ExternalTemporaryOverride : NSObject

/* instance methods */
- (id)init;
- (void)dealloc;

@end


@interface _TtC19ReminderKitInternalP33_F8096D6C8A98A78E7FC1F653291D8AD315InternalEncoder : _TtCs12_SwiftObject

@end


@interface _TtCE19ReminderKitInternalV10Foundation3URLP33_C4CF88CCEEBFE10B546F9B83C3AB9A6B23SecurityScopedURLHolder : _TtCs12_SwiftObject

@end


@interface _TtCV19ReminderKitInternal25UrgentAlarmCompleteIntentP33_E6CD1A297CE4D25376421304554ED9F515EditedObjectIDs : _TtCs12_SwiftObject

@end


@interface NSArray (RMD)

/* instance methods */
- (id)shuffledArray;
- (id)shuffledArrayWithRandomSource:(id)source;

@end


@interface NSDateInterval (ReminderKitInternal)

/* class methods */
+ (double)rem1Month30Days;
+ (double)rem1Day;
+ (double)rem1Hour;
+ (double)rem1Minute;
+ (double)rem1Second;
+ (double)rem1Week;
+ (double)rem1Year;
+ (double)remNotificationFireDateGracePeriod;
+ (double)remUrgentAlarmFireDateGracePeriod;

@end


@interface NSFileManager (ReminderKitInternal)

/* instance methods */
- (_Bool)rem_createDirectoryIfNecessaryAtURL:(id)url error:(id *)error;
- (id)rem_createProtectedTemporaryDirectoryIfNeededWithError:(id *)error;
- (_Bool)rem_fileExistsAtURL:(id)url;
- (_Bool)rem_fileExistsAtURL:(id)url isDirectory:(_Bool *)directory;
- (_Bool)rem_isEmptyDirectoryAtURL:(id)url skipsHiddenFiles:(_Bool)files;

@end


@interface REMPaths (ReminderKitInternal)

/* class methods */
+ (id)_legacy_mlModelURL;
+ (id)_legacy_temporaryMLModelURL;
+ (id)mlModelURL;

@end


@interface REMStore (ReminderKitInternal)

/* instance methods */
- (void)clearAutoCategorizationLocalCorrectionsOfListsOwnedByCurrentUserWithCompletionHandler:(id /* block */)handler;

@end


#endif /* ReminderKitInternal_h */
