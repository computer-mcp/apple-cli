// Normalized full dump import surface for NotesHTML.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesHTML_h

#define NotesHTML_h



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





struct CGSize;

struct _NSRange;

struct _opaque_pthread_rwlock_t;

struct sasl_callback;

struct sasl_interact;

struct sasl_secret;



@class ACAccount, ACAccountCredential, CSSearchableItemAttributeSet, EWSExchangeServiceBinding, ICBaseSearchIndexerDataSource, ICHTMLSearchIndexerDataSource, ICManagedObjectContextUpdater, ICNFIMAPAccountProxy, ICNFIMAPAggregateClientOperation, ICNFIMAPAggregateFetchUIDOperation, ICNFIMAPAggregateGetQuotaRootOperation, ICNFIMAPAggregateStatusOperation;

@class ICNFIMAPAttachmentsDownload, ICNFIMAPBadResponse, ICNFIMAPBasicResponse, ICNFIMAPBodyFetchResult, ICNFIMAPBodyHeaderFetchResult, ICNFIMAPBodySectionFetchResult, ICNFIMAPBodyStructureFetchResult, ICNFIMAPBodyTextFetchResult, ICNFIMAPByeResponse, ICNFIMAPCapabilityResponse, ICNFIMAPClientAppendOperation, ICNFIMAPClientAuthenticateOperation;

@class ICNFIMAPClientCapabilityOperation, ICNFIMAPClientCheckOperation, ICNFIMAPClientCloseOperation, ICNFIMAPClientCreateOperation, ICNFIMAPClientData, ICNFIMAPClientDeleteOperation, ICNFIMAPClientDoneOperation, ICNFIMAPClientExamineOperation, ICNFIMAPClientExpungeOperation, ICNFIMAPClientFetchBodyDataItem, ICNFIMAPClientFetchChangedSinceDataItem, ICNFIMAPClientFetchDataItem;

@class ICNFIMAPClientFetchOperation, ICNFIMAPClientFetchUIDOperation, ICNFIMAPClientGetQuotaOperation, ICNFIMAPClientGetQuotaRootOperation, ICNFIMAPClientIDOperation, ICNFIMAPClientIdleOperation, ICNFIMAPClientLSubOperation, ICNFIMAPClientListOperation, ICNFIMAPClientLoginOperation, ICNFIMAPClientLogoutOperation, ICNFIMAPClientMailboxOperation, ICNFIMAPClientNamespaceOperation;

@class ICNFIMAPClientNoopOperation, ICNFIMAPClientOperation, ICNFIMAPClientOperationQueue, ICNFIMAPClientRenameOperation, ICNFIMAPClientSelectOperation, ICNFIMAPClientStartTLSOperation, ICNFIMAPClientStatusOperation, ICNFIMAPClientSubscribeOperation, ICNFIMAPClientSuspendOperation, ICNFIMAPClientUIDCopyOperation, ICNFIMAPClientUIDExpungeOperation, ICNFIMAPClientUIDOperation;

@class ICNFIMAPClientUIDSearchOperation, ICNFIMAPClientUIDStoreOperation, ICNFIMAPClientUnselectOperation, ICNFIMAPClientUnsubscribeOperation, ICNFIMAPCommandPipeline, ICNFIMAPCompoundDownload, ICNFIMAPConnection, ICNFIMAPConnectionPool, ICNFIMAPContinuationResponse, ICNFIMAPDownload, ICNFIMAPDownloadCache, ICNFIMAPEnvelopeFetchResult;

@class ICNFIMAPExistsResponse, ICNFIMAPExpungeResponse, ICNFIMAPFetchResponse, ICNFIMAPFetchResult, ICNFIMAPFlagsFetchResult, ICNFIMAPFlagsResponse, ICNFIMAPFramework, ICNFIMAPGateway, ICNFIMAPGmailLabelsFetchResult, ICNFIMAPIDResponse, ICNFIMAPInternalDateFetchResult, ICNFIMAPInternalFetchResponse;

@class ICNFIMAPInternalUidFlagsResponse, ICNFIMAPLSubResponse, ICNFIMAPListResponse, ICNFIMAPMailbox, ICNFIMAPMailboxProxy, ICNFIMAPMailboxSyncEngine, ICNFIMAPMessage, ICNFIMAPMessageDetails, ICNFIMAPMessageDownload, ICNFIMAPMessageProxy, ICNFIMAPMessageWithCache, ICNFIMAPMimeConverter;

@class ICNFIMAPModificationSequenceFetchResult, ICNFIMAPNamespace, ICNFIMAPNamespaceExtension, ICNFIMAPNamespaceResponse, ICNFIMAPNoResponse, ICNFIMAPNumericResponse, ICNFIMAPOKResponse, ICNFIMAPOtherResponse, ICNFIMAPParseContext, ICNFIMAPPreauthResponse, ICNFIMAPQuotaResponse, ICNFIMAPQuotaRoot;

@class ICNFIMAPQuotaRootResponse, ICNFIMAPRFC822SizeFetchResult, ICNFIMAPRecentResponse, ICNFIMAPResponse, ICNFIMAPSearchResponse, ICNFIMAPSimpleDownload, ICNFIMAPSingleClientOperation, ICNFIMAPStatusResponse, ICNFIMAPUidFetchResult, ICNFMCAccountProxy, ICNFMCActivityMonitor, ICNFMCAddressManager;

@class ICNFMCApopAuthScheme, ICNFMCAppleTokenAuthScheme, ICNFMCArchiveFileWrapper, ICNFMCAttachment, ICNFMCAttachmentWrappingTextAttachment, ICNFMCAuthScheme, ICNFMCByteSet, ICNFMCCIDURLProtocol, ICNFMCConnection, ICNFMCConnectionBasedAccountProxy, ICNFMCCramMD5AuthScheme, ICNFMCDataScanner;

@class ICNFMCDateFormatterFactory, ICNFMCDateParser, ICNFMCError, ICNFMCExternalAuthScheme, ICNFMCFileTypeInfo, ICNFMCGssapiAuthScheme, ICNFMCISPAccountSettingsManager, ICNFMCImageJunkMetadata, ICNFMCInvocationQueue, ICNFMCJunkRecorder, ICNFMCKeychainManager, ICNFMCLargeAttachmentFileWrapper;

@class ICNFMCMailCoreFramework, ICNFMCMailboxProxy, ICNFMCManagedObjectContextManager, ICNFMCManagedObjectProxy, ICNFMCMemoryDataSource, ICNFMCMessage, ICNFMCMessageBody, ICNFMCMessageGenerator, ICNFMCMessageHeaders, ICNFMCMimeBody, ICNFMCMimeCharset, ICNFMCMimeConverter;

@class ICNFMCMimeDataEncoding, ICNFMCMimeDecodeContext, ICNFMCMimeHeaderScanContext, ICNFMCMimePart, ICNFMCMimeTextAttachment, ICNFMCMonitoredInvocation, ICNFMCMutableByteSet, ICNFMCMutableMessageHeaders, ICNFMCNetworkController, ICNFMCNtlmAuthScheme, ICNFMCOutgoingMessage, ICNFMCParsedMessage;

@class ICNFMCPlaceholderArchiveFileWrapper, ICNFMCPlaceholderFileWrapper, ICNFMCPlainAuthScheme, ICNFMCPriorityInvocation, ICNFMCQOSInvocation, ICNFMCQuotaUsage, ICNFMCRemoteMessage, ICNFMCRemotePlaceholderFileWrapper, ICNFMCResultTaskOperation, ICNFMCSAXHTMLParsing, ICNFMCSaslClient, ICNFMCSharedPreferencesController;

@class ICNFMCSocket, ICNFMCStringRenderContext, ICNFMCSubdata, ICNFMCSubjectParser, ICNFMCTaskOperation, ICNFMCThrowingInvocationOperation, ICNFMCURLMatch, ICNFMCURLifier, ICNFMCWorkerThread, ICNotesHTMLMarker, ICURLSecureUnarchiveFromDataTransformer, ICUUIDSecureUnarchiveFromDataTransformer;

@class NFAccount, NFAosImapAccountProxy, NFAttachment, NFCrossProcessChangeCoordinator, NFEWSAccount, NFEWSAccountProxy, NFEWSFolder, NFEWSFolderProxy, NFEWSNote, NFFolder, NFFolderAction, NFIMAPAccount;

@class NFIMAPAccountProxy, NFIMAPFolder, NFIMAPFolderProxy, NFIMAPNote, NFInsertFolderAction, NFInsertNoteAction, NFLocalAccount, NFLocalToEWSPusher, NFLocalToIMAPPusher, NFLocalToRemotePusher, NFMoveFolderAction, NFMoveNoteAction;

@class NFNote, NFNoteAction, NFNoteBody, NFOfflineAction, NFOfflineActionManager, NFOfflineCoordinator, NFPersistenceManager, NFTrashFolder, NFUpdateFolderAction, NFUpdateNoteAction, NSColor, NSFont;

@class NSImage, NSManagedObject, NSManagedObjectContext, NSManagedObjectID, NSPersistentStoreCoordinator, NSTextAttachment, NSURLProtocol, NotesFramework, StationeryCompositeImage, WebArchive, _ICNFFormatFlowedWriter, _ICNFIMAPClientSimulatedSelectOperation;

@class _ICNFIMAPConnectionEnumerator, _ICNFIMAPFetchUnit, _ICNFIMAPLibraryIDDetails, _ICNFIMAPManagedObjectIDDetails, _ICNFMCActivityMonitorMultiTarget, _ICNFMCConnectionAttempt, _ICNFMCISPLocalAccountSettingsManager, _ICNFMCISPOnlineAccountSettingsManager, _ICNFMCInvocationOperation, _ICNFMCMemoryMessage, _ICNFMCMimeEnrichedReader, _ICNFMCMimeEnrichedReaderCommandStackEntry;

@class _ICNFMCMimeEnrichedState, _ICNFMCMimeEnrichedWriter, _ICNFMCMimeEnrichedWriterCommandStackEntry, _ICNFMCMimePartEnumerator, _ICNFMCOutgoingMessageBody, _ICNFNonBoostingLock, _ICNFUIDsBatch;

@protocol ICFolderObject, ICNFIMAPAccount, ICNFIMAPFetchResponseHandler, ICNFIMAPMailboxDelegate, ICNFIMAPMessage, ICNFIMAPMessageDataSource, ICNFIMAPPersistedAccount, ICNFIMAPPersistedMailbox, ICNFIMAPPersistedMessage, ICNFIMAPPersistedMessage__CD, ICNFMCAccount, ICNFMCAccountProxyManager;

@protocol ICNFMCActivityTarget, ICNFMCChanging, ICNFMCConnectionLogging, ICNFMCMailAccount, ICNFMCMailbox, ICNFMCMessageDataSource, ICNFMCMessageSortingInterface, ICNFMCPersistedAccount, ICNFMCPersistedConnectionBasedAccount, ICNFMCPersistedMessage, ICNFMCPersistentIDFetching, ICNFMCRemoteStoreAccount;

@protocol ICNoteVisibilityTesting, ICSearchIndexable, ICSearchIndexableNote, NFAccountProxy, NFLocalToRemotePusherProtocol, OS_dispatch_source;



@protocol ICNFIMAPAccount <ICNFMCRemoteStoreAccount>

@required

@property _Bool recoveringFromConnectionLoss;
@property _Bool useIDLEIfAvailable;
@property long long gmailCapabilitiesSupport;
@property (copy) NSDictionary *serverID;
@property unsigned int readBufferSize;
@property (readonly) _Bool allowsPartialDownloads;
@property (readonly) _Bool shouldMoveDeletedMessagesToTrash;

/* required instance methods */
- (id)IMAPMailboxForMailboxName:(id)name createIfNeeded:(_Bool)needed;
- (_Bool)handleResponseCodeFromResponse:(id)response;
- (id)quotaRootForName:(id)name createIfNeeded:(_Bool)needed;
- (id)serverPathPrefix;
- (void)backgroundFetchCompleted;
- (void)recoverFromConnectionLoss;
- (void)sendAccountNeedsCheckingNotification;
- (void)setServerPathPrefix:(id)prefix permanently:(_Bool)permanently;

@optional

@property (readonly, copy, nonatomic) NSArray *additionalHeaderFields;

/* optional instance methods */
- (id)gmailLabelWithName:(id)name;
- (void)detectAllMailWithGateway:(id)gateway;
- (void)filterMailboxList:(id)list forMailbox:(id)mailbox options:(long long)options;

@end


@protocol ICNFIMAPFetchResponseHandler <NSObject>

@required

/* required instance methods */
- (_Bool)handleResponse:(id)response forOperation:(id)operation;

@optional

@end


@protocol ICNFIMAPMailboxDelegate <NSObject>

@required

/* required instance methods */
- (unsigned long long)computedHighestModificationSequenceForMailbox:(id)mailbox;
- (unsigned long long)allegedHighestModificationSequenceForMailbox:(id)mailbox;
- (void)updateComputedHighestModificationSequence:(unsigned long long)sequence forMailbox:(id)mailbox;
- (void)processResponsesFromMailbox:(id)mailbox;
- (void)updateCountFromMailbox:(id)mailbox fromIDLE:(_Bool)idle;
- (void)updateSelectedGatewayFromMailbox:(id)mailbox;
- (void)updateUidValidityFromMailbox:(id)mailbox;

@optional

@end


@protocol ICNFIMAPMessage <NSObject>

@required

@property (nonatomic) unsigned int uid;
@property (readonly, copy, nonatomic) NSString *messageID;
@property _Bool isPartial;
@property _Bool partsHaveBeenCached;
@property _Bool hasTemporaryUid;
@property (readonly) struct { unsigned int x0:27; unsigned int x1:1; unsigned int x2:1; unsigned int x3:1; unsigned int x4:1; unsigned int x5:1; } remoteFlags;
@property (readonly) unsigned long long messageSize;
@property (readonly, copy) NSString *subject;
@property (readonly, copy) NSDate *dateReceived;
@property (readonly, copy, nonatomic) NSString *mailboxName;

@optional

@end


@protocol ICNFIMAPMessageDataSource <ICNFMCMessageDataSource>

@required

@property (readonly, nonatomic) signed char persistentIDType;
@property (readonly, nonatomic) id <ICNFIMAPAccount> account;
@property (readonly, copy) NSString *mailboxName;
@property (readonly, nonatomic) _Bool isInbox;
@property (readonly, nonatomic) _Bool isAllMailMailbox;
@property (readonly, nonatomic) unsigned long long totalCountOfMessages;
@property (readonly, nonatomic) ICNFIMAPCommandPipeline *fetchPipeline;
@property (readonly, nonatomic) ICNFIMAPDownloadCache *downloadCache;
@property (readonly, nonatomic) _Bool messagesAreBeingAdded;
@property (readonly, nonatomic) unsigned int maximumRemoteID;
@property (nonatomic) unsigned int uidNextStatus;
@property (nonatomic) unsigned long long allegedHighestModificationSequence;

/* required instance methods */
- (_Bool)hasValidCacheFileForMessage:(id)message;
- (id)copyIncompleteMessages;
- (void)setComputedHighestModificationSequence:(unsigned long long)sequence;
- (void)addMessages:(id)messages;
- (id)async_setFlagsFromDictionary:(id)dictionary forMessages:(id)messages updatingServer:(_Bool)server;
- (id)cacheDirectoryContents;
- (void)compactMessagesFromSyncEngine:(id)engine;
- (id)copyMessagesWithTemporaryUids;
- (id)fetchAndCacheBodyDataForMessages:(id)messages;
- (id)getDetailsForMessagesWithRemoteIDs:(id)ids;
- (_Bool)hasCacheFileForMessage:(id)message directoryContents:(id)contents;
- (_Bool)hasCacheFileForMessage:(id)message part:(id)part directoryContents:(id)contents;
- (_Bool)messageHasBeenDeleted:(id)deleted;
- (id)messagesBeingAdded;
- (id)newDictionaryForLocalFlags:(unsigned int)flags serverFlags:(unsigned int)flags existingDictionary:(id)dictionary;
- (void)removeAllLocalMessages;
- (void)setUidValidityStatus:(unsigned int)status;
- (void)syncEngineDidFinish;
- (void)syncEngineDidStart;
- (void)syncEngineDidSynchronizeMessageList;
- (unsigned int)uidValidityStatus;

@optional

/* optional instance methods */
- (id)async_setGmailLabelsFromDictionary:(id)dictionary forMessages:(id)messages updatingServer:(_Bool)server;
- (id)messageWithDefaultLoadOptionsAndManagedObjectID:(id)id;
- (id)messageWithDefaultLoadOptionsAndRowID:(long long)id;
- (id)messagesWithManagedObjectIDs:(id)ids;
- (id)messagesWithRowIDs:(id)ids;
- (id)recentFlagChangesForManagedObjectID:(id)id;
- (id)recentFlagChangesForRowID:(id)id;

@end


@protocol ICNFIMAPPersistedAccount <ICNFMCPersistedConnectionBasedAccount>

@required

@property (readonly, nonatomic) NSManagedObject<ICNFIMAPPersistedMailbox> *defaultMailbox;
@property (readonly, nonatomic) NSManagedObject<ICNFIMAPPersistedMailbox> *inbox;
@property (nonatomic) long long gmailCapabilitiesSupport;
@property (copy, nonatomic) NSString *serverPathPrefix;
@property (readonly, copy, nonatomic) NSSet *mailboxes;

/* required instance methods */
- (void)addMailboxes:(id)mailboxes;
- (id)newMailboxWithName:(id)name serverName:(id)name parent:(id)parent;
- (id)objectIDOfMailboxWithServerName:(id)name;

@optional

@end


@protocol ICNFIMAPPersistedMailbox <NSObject>

@required

@property (retain, nonatomic) NSManagedObject<ICNFIMAPPersistedAccount> *account;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NSManagedObject<ICNFIMAPPersistedMailbox> *parent;
@property (copy, nonatomic) NSSet *persistedMessages;
@property (retain, nonatomic) NSNumber *imapAllegedHighestModificationSequence;
@property (retain, nonatomic) NSNumber *imapComputedHighestModificationSequence;
@property (retain, nonatomic) NSNumber *imapUIDNext;
@property (retain, nonatomic) NSNumber *imapUIDValidity;
@property (copy, nonatomic) NSString *imapServerName;
@property (readonly, nonatomic) _Bool isRootMailbox;

/* required instance methods */
- (id)compactDescription;
- (unsigned long long)totalCountOfMessages;
- (id)newMessage;
- (unsigned int)maximumIMAPUID;
- (void)addChildMailboxes:(id)mailboxes;
- (void)addChildMailboxesObject:(id)object;
- (void)addPersistedMessages:(id)messages;
- (void)addPersistedMessagesObject:(id)object;
- (id)cacheDirectoryContentsExcludingObjectIDs:(id)ids;
- (id)copyIncompleteMessagesIncludingObjectIDs:(id)ids;
- (id)getDetailsForMessagesWithIMAPUIDs:(id)imapuids;
- (id)messageWithUniqueID:(id)id;
- (id)messagesWithObjectIDs:(id)ids;
- (void)removeChildMailboxes:(id)mailboxes;
- (void)removeChildMailboxesObject:(id)object;
- (void)removePersistedMessages:(id)messages;
- (void)removePersistedMessagesObject:(id)object;

@optional

@end


@protocol ICNFIMAPPersistedMessage <ICNFMCChanging>

@required

@property (readonly, nonatomic) signed char persistentIDType;
@property (copy) NSString *remoteID;

/* required instance methods */
- (void)setData:(id)data isPartial:(_Bool)partial;
- (void)appendData:(id)data part:(id)part;

@optional

@property (readonly, nonatomic) long long libraryID;
@property (readonly, nonatomic) NSManagedObjectID *managedObjectID;

@end


@protocol ICNFIMAPPersistedMessage__CD <ICNFMCPersistedMessage>

@required

@property (retain, nonatomic) NSNumber *imapUID;
@property (retain, nonatomic) NSUUID *universallyUniqueID;
@property (retain, nonatomic) NSDate *dateEdited;
@property (nonatomic) long long mimeDataSize;
@property (retain, nonatomic) NSManagedObject<ICNFIMAPPersistedMailbox> *mailbox;

/* required instance methods */
- (id)compactDescription;

@optional

@end


@protocol ICNFMCAccount <NSObject>

@required

@property (readonly, copy) NSString *accountTypeString;
@property (readonly, copy) NSString *identifier;
@property (copy) NSString *displayName;
@property (readonly, copy, nonatomic) NSString *saslProfileName;
@property _Bool configureDynamically;
@property _Bool allowInsecureAuthentication;
@property (copy) NSString *canonicalEmailAddress;
@property (copy) NSString *hostname;
@property long long portNumber;
@property (readonly, copy, nonatomic) NSArray *standardPorts;
@property (readonly, copy, nonatomic) NSArray *standardSSLPorts;
@property long long securityLayerType;
@property (retain) ICNFMCAuthScheme *preferredAuthScheme;
@property (copy) NSString *username;
@property (copy) NSString *password;
@property (copy) NSString *sessionPassword;
@property (readonly, copy) NSString *applePersonID;
@property (readonly, copy) NSString *appleAuthenticationToken;
@property (readonly, copy) NSString *machineID;
@property (readonly, copy) NSString *oneTimePassword;
@property (readonly, copy) NSString *clientInfo;
@property (readonly, copy) NSString *oauthToken;
@property (readonly, nonatomic) _Bool requiresAuthentication;
@property _Bool shouldUseAuthentication;
@property _Bool usesSSL;
@property (readonly) NSURL *subscriptionURL;
@property (readonly, copy) NSString *subscriptionURLLabel;

/* class methods */
+ (id)accountTypeString;
+ (void)saveAccountInfoToDefaults;

/* required instance methods */
- (_Bool)autodiscoverSettings:(id *)settings;
- (void)setTLSIdentity:(struct __SecIdentity *)tlsidentity;
- (struct __SecIdentity *)copyTLSIdentity;
- (id)authenticatedConnection;
- (_Bool)canAuthenticateWithScheme:(id)scheme;
- (_Bool)connectAndAuthenticate:(id)authenticate;
- (id)newConnectedConnectionDiscoveringBestSettings:(_Bool)settings withConnectTimeout:(double)timeout readWriteTimeout:(double)timeout;
- (void)respondToHostBecomingReachable;
- (void)updateFromSuccessfulConnectionPortNumber:(long long)number securityLayerType:(long long)type;
- (_Bool)shouldRetryConnectionWithoutCertificateCheckingAfterError:(id)error host:(id)host didPromptUser:(_Bool *)user;

@optional

@property (copy) NSString *externalHostname;

@end


@protocol ICNFMCActivityTarget <NSObject>

@required

@optional

/* optional instance methods */
- (id)displayName;
- (_Bool)isSmartMailbox;

@end


@protocol ICNFMCChanging <NSObject>

@required

/* required instance methods */
- (void)beginChanging;
- (_Bool)endChanging:(_Bool)changing immediately:(_Bool)immediately;

@optional

@end


@protocol ICNFMCConnectionLogging <NSObject>

@required

/* required instance methods */
- (void)logData:(id)data;
- (void)logString:(id)string;
- (void)flushLog;
- (void)logBytes:(void *)bytes length:(unsigned long long)length;
- (void)logData:(id)data range:(struct _NSRange)range;

@optional

@end


@protocol ICNFMCMailAccount <ICNFMCAccount>

@required

@property (readonly, nonatomic) NSOperationQueue *remoteTaskQueue;
@property (readonly, nonatomic) NSOperationQueue *remoteFetchQueue;

/* required instance methods */
- (void)incrementCountOfNewUnreadMessagesReceivedInInbox:(unsigned long long)inbox;
- (void)incrementTotalCountOfMessagesReceived:(unsigned long long)received;
- (void)newUnreadMessagesHaveBeenReceivedInInbox;

@optional

@end


@protocol ICNFMCMailbox <NSCopying, NSObject>

@required

@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, copy, nonatomic) NSString *displayNameWithoutPII;
@property (readonly, copy, nonatomic) NSString *extendedDisplayName;
@property (readonly, copy, nonatomic) NSString *URLString;
@property (readonly) unsigned long long unseenCount;
@property (readonly) _Bool unseenCountIsKnown;

/* required instance methods */
- (void)setUserInfoObject:(id)object forKey:(id)key;
- (void)setUserInfoBool:(_Bool)_bool forKey:(id)key;
- (_Bool)userInfoBoolForKey:(id)key;
- (id)userInfoObjectForKey:(id)key;

@optional

@end


@protocol ICNFMCMessageDataSource <ICNFMCActivityTarget, NSCopying>

@required

@property (readonly) _Bool isReadOnly;
@property (readonly, nonatomic) _Bool supportsSnippets;
@property (readonly, nonatomic) _Bool canCompact;
@property (readonly, nonatomic) id <ICNFMCMailAccount> account;
@property (readonly, nonatomic) id <ICNFMCMailbox> mailbox;

/* required instance methods */
- (void)doCompact;
- (void)saveSnippetsForMessages:(id)messages;
- (id)async_setFlagsFromDictionary:(id)dictionary forMessages:(id)messages;
- (void)invalidateMessage:(id)message;
- (void)deleteMessages:(id)messages moveToTrash:(_Bool)trash;
- (id)messageForMessageID:(id)id;
- (id)attachmentsDirectoryForMessage:(id)message;
- (id)bodyDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)flushAllCaches;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)messageFlagsDidChange:(id)change flags:(id)flags;
- (void)setColor:(id)color highlightTextOnly:(_Bool)only forMessages:(id)messages;
- (void)setNumberOfAttachments:(unsigned int)attachments isSigned:(_Bool)_signed isEncrypted:(_Bool)encrypted forMessage:(id)message;
- (id)snippetsForMessages:(id)messages;
- (id)uniquedString:(id)string;
- (id)async_setFlagWithKey:(id)key state:(_Bool)state forMessages:(id)messages;
- (id)async_setJunkMailLevel:(long long)level forMessages:(id)messages trainJunkMailDatabase:(_Bool)database userRecorded:(_Bool)recorded;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags allowPartial:(_Bool)partial;
- (id)dataForMimePart:(id)part;
- (id)fullBodyDataForMessage:(id)message;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available fetchIfNotAvailable:(_Bool)available;
- (_Bool)hasCachedDataForMimePart:(id)part;
- (id)headerDataForMessage:(id)message;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)headersForMessage:(id)message;
- (id)headersForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)routeMessages:(id)messages fetchingBodies:(_Bool)bodies messagesNeedingBodies:(id)bodies;
- (void)sendResponseType:(signed char)type forMeetingMessage:(id)message;
- (void)undeleteMessages:(id)messages;
- (id)undeleteMessages:(id)messages movedToStore:(id)store newMessageIDs:(id)ids;

@optional

/* optional instance methods */
- (id)async_deleteMessages:(id)messages moveToTrash:(_Bool)trash;
- (id)async_setGmailLabelsFromDictionary:(id)dictionary forMessages:(id)messages;

@end


@protocol ICNFMCMessageSortingInterface <NSObject>

@required

@property (readonly, nonatomic) int colorForSort;
@property (readonly) double dateLastViewedAsTimeIntervalSince1970;
@property (readonly, nonatomic) unsigned int messageFlags;
@property (readonly, nonatomic) unsigned long long messageSize;
@property (readonly, nonatomic) unsigned long long numberOfAttachments;
@property (readonly, copy) NSString *subject;
@property (readonly) unsigned long long subjectPrefixLength;
@property (readonly, copy) NSArray *to;
@property (readonly) double dateReceivedAsTimeIntervalSince1970;
@property (readonly) double dateSentAsTimeIntervalSince1970;
@property (readonly, nonatomic) id <ICNFMCMailbox> mailbox;

@optional

@end


@protocol ICNFMCPersistedAccount <NSObject>

@required

@property (readonly, copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *accountDescription;
@property (copy, nonatomic) NSString *canonicalEmailAddress;
@property (copy, nonatomic) NSString *username;
@property (nonatomic) _Bool allowInsecureAuthentication;
@property (retain, nonatomic) ACAccountCredential *credential;
@property (nonatomic) _Bool enabled;

@optional

@end


@protocol ICNFMCPersistedConnectionBasedAccount <ICNFMCPersistedAccount>

@required

@property (copy, nonatomic) NSString *hostname;
@property (nonatomic) long long port;
@property (nonatomic) long long securityLayerType;
@property (copy, nonatomic) NSData *tlsCertificate;
@property (copy, nonatomic) NSString *authenticationSchemeName;
@property (readonly, nonatomic) ACAccount *acAccount;

@optional

@end


@protocol ICNFMCPersistedMessage <NSObject>

@required

@property (retain, nonatomic) NSDate *dateCreated;
@property (retain, nonatomic) NSDate *dateSent;
@property (retain, nonatomic) NSDate *dateReceived;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *messageID;
@property (copy, nonatomic) NSSet *references;
@property (nonatomic) _Bool unread;
@property (copy, nonatomic) NSString *bodyHTML;
@property (copy, nonatomic) NSSet *attachments;

/* required instance methods */
- (id)createAttachmentWithName:(id)name;
- (id)attachmentWithContentID:(id)id;
- (void)addPersistedAttachement:(id)attachement;

@optional

/* optional instance methods */
- (id)newReference;

@end


@protocol ICNFMCPersistentIDFetching <NSObject>

@required

/* class methods */
+ (id)fetchedMessageWithRowID:(long long)id;

/* required instance methods */
- (long long)libraryID;

@optional

@end


@protocol ICNFMCRemoteStoreAccount <ICNFMCMailAccount>

@required

/* required instance methods */
- (long long)cachePolicy;
- (_Bool)shouldCacheAttachmentsForMessageWithDateReceived:(id)received;
- (void)presentOverQuotaAlert;
- (void)setCachePolicy:(long long)policy permanently:(_Bool)permanently;

@optional

@end


@protocol ICNoteVisibilityTesting <NSObject>

@required

/* required instance methods */
- (id)predicateForSearchableAttachments;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (id)predicateForSearchableNotes;

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


@protocol NFAccountProxy <NSObject>

@required

@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *parentACAccountIdentifier;

/* required instance methods */
- (_Bool)hasNotes;
- (id)parentACAccount;

@optional

@end


@protocol NFLocalToRemotePusherProtocol <NSObject>

@required

/* class methods */
+ (const char *)logCategory;

/* required instance methods */
- (_Bool)addFolderToRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)addNoteToRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteFolderFromRemote:(id)remote fromParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteNoteFromRemoteWithID:(id)id fromFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveFolderOnRemote:(id)remote toParent:(id)parent originalParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveNoteOnRemote:(id)remote toFolder:(id)folder originalFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateFolderOnRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateNoteOnRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;

@optional

@end


@interface ICHTMLSearchIndexerDataSource : ICBaseSearchIndexerDataSource

/* instance methods */
- (id)persistentStoreCoordinator;
- (id)allIndexableObjectIDsInReversedReindexingOrderWithContext:(id)context;
- (_Bool)isFolderWithServerShareChanged:(id)changed;
- (id)dataSourceIdentifier;
- (void)contextWillSave:(id)save;
- (unsigned long long)indexingPriority;
- (id)addNotesFromSubtree:(id)subtree;
- (id)newManagedObjectContext;

@end


@interface ICNFMCManagedObjectProxy : NSObject <ICNFMCChanging>

@property (readonly) NSManagedObjectID *objectID;
@property _Bool isChanging;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)init;
- (void)dealloc;
- (id)initWithManagedObject:(id)object;
- (void)beginChanging;
- (_Bool)endChanging:(_Bool)changing immediately:(_Bool)immediately;
- (void)_handleObjectDeletion:(id)deletion;
- (id)proxiedValueForKey:(id)key;
- (void)setProxiedValue:(id)value forKey:(id)key;

@end


@interface ICNFMCAccountProxy : ICNFMCManagedObjectProxy

@property (readonly, copy) NSString *identifier;
@property long long accountState;
@property (readonly) _Bool isSyncing;
@property _Bool enabled;
@property (copy) NSString *displayName;
@property (copy) NSString *canonicalEmailAddress;
@property (copy) NSString *username;
@property _Bool allowInsecureAuthentication;
@property (retain) NSError *webAuthenticationError;
@property (copy) NSString *certificateHostname;
@property (retain) NSError *certificateError;
@property (readonly, nonatomic) NSOperationQueue *remoteTaskQueue;
@property (readonly, nonatomic) NSOperationQueue *remoteFetchQueue;
@property (readonly, nonatomic) ICNFMCMailboxProxy *defaultHighPriorityMailbox;

/* class methods */
+ (id)keyPathsForValuesAffectingIsSyncing;

/* instance methods */
- (void)invalidate;
- (id)initWithManagedObject:(id)object;
- (void)syncStarted;
- (void)setHighPriorityMailbox:(id)mailbox;
- (void)syncFinished;

@end


@interface ICNFMCConnectionBasedAccountProxy : ICNFMCAccountProxy <ICNFMCAccount>

@property (copy) NSString *primitiveSessionPassword;
@property (readonly, copy) NSString *accountTypeString;
@property (readonly, copy) NSString *identifier;
@property (copy) NSString *displayName;
@property (readonly, copy, nonatomic) NSString *saslProfileName;
@property _Bool configureDynamically;
@property _Bool allowInsecureAuthentication;
@property (copy) NSString *canonicalEmailAddress;
@property (copy) NSString *hostname;
@property long long portNumber;
@property (readonly, copy, nonatomic) NSArray *standardPorts;
@property (readonly, copy, nonatomic) NSArray *standardSSLPorts;
@property long long securityLayerType;
@property (retain) ICNFMCAuthScheme *preferredAuthScheme;
@property (copy) NSString *username;
@property (copy) NSString *password;
@property (copy) NSString *sessionPassword;
@property (readonly, copy) NSString *applePersonID;
@property (readonly, copy) NSString *appleAuthenticationToken;
@property (readonly, copy) NSString *machineID;
@property (readonly, copy) NSString *oneTimePassword;
@property (readonly, copy) NSString *clientInfo;
@property (readonly, copy) NSString *oauthToken;
@property (readonly, nonatomic) _Bool requiresAuthentication;
@property _Bool shouldUseAuthentication;
@property _Bool usesSSL;
@property (readonly) NSURL *subscriptionURL;
@property (readonly, copy) NSString *subscriptionURLLabel;
@property (copy) NSString *externalHostname;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)accountTypeString;
+ (void)saveAccountInfoToDefaults;

/* instance methods */
- (id)initWithManagedObject:(id)object;
- (id)acAccount;
- (_Bool)autodiscoverSettings:(id *)settings;
- (void)setTLSIdentity:(struct __SecIdentity *)tlsidentity;
- (struct __SecIdentity *)copyTLSIdentity;
- (id)authenticatedConnection;
- (_Bool)canAuthenticateWithScheme:(id)scheme;
- (_Bool)connectAndAuthenticate:(id)authenticate;
- (id)newConnectedConnectionDiscoveringBestSettings:(_Bool)settings withConnectTimeout:(double)timeout readWriteTimeout:(double)timeout;
- (void)respondToHostBecomingReachable;
- (void)updateFromSuccessfulConnectionPortNumber:(long long)number securityLayerType:(long long)type;
- (_Bool)isServerReachable;
- (_Bool)shouldRetryConnectionWithoutCertificateCheckingAfterError:(id)error host:(id)host didPromptUser:(_Bool *)user;

@end


@interface ICNFIMAPAccountProxy : ICNFMCConnectionBasedAccountProxy <ICNFIMAPAccount>

@property (copy) NSString *separatorCharacter;
@property (retain) ICNFIMAPGateway *offlineRecoveryGateway;
@property (retain) NSData *tlsCertificate;
@property (readonly, nonatomic) unsigned long long maximumConnectionCount;
@property (readonly, nonatomic) ICNFIMAPMailboxProxy *defaultHighPriorityMailbox;
@property (readonly, nonatomic) _Bool useDefaultMailboxAsMailboxHierarchyRoot;
@property (readonly, copy, nonatomic) NSArray *allMailboxProxies;
@property _Bool recoveringFromConnectionLoss;
@property _Bool useIDLEIfAvailable;
@property long long gmailCapabilitiesSupport;
@property (copy) NSDictionary *serverID;
@property unsigned int readBufferSize;
@property (readonly) _Bool allowsPartialDownloads;
@property (readonly) _Bool shouldMoveDeletedMessagesToTrash;
@property (readonly, copy, nonatomic) NSArray *additionalHeaderFields;
@property (readonly, nonatomic) NSOperationQueue *remoteTaskQueue;
@property (readonly, nonatomic) NSOperationQueue *remoteFetchQueue;
@property (readonly, copy) NSString *accountTypeString;
@property (readonly, copy) NSString *identifier;
@property (copy) NSString *displayName;
@property (readonly, copy, nonatomic) NSString *saslProfileName;
@property _Bool configureDynamically;
@property _Bool allowInsecureAuthentication;
@property (copy) NSString *canonicalEmailAddress;
@property (copy) NSString *hostname;
@property long long portNumber;
@property (readonly, copy, nonatomic) NSArray *standardPorts;
@property (readonly, copy, nonatomic) NSArray *standardSSLPorts;
@property long long securityLayerType;
@property (retain) ICNFMCAuthScheme *preferredAuthScheme;
@property (copy) NSString *username;
@property (copy) NSString *password;
@property (copy) NSString *sessionPassword;
@property (readonly, copy) NSString *applePersonID;
@property (readonly, copy) NSString *appleAuthenticationToken;
@property (readonly, copy) NSString *machineID;
@property (readonly, copy) NSString *oneTimePassword;
@property (readonly, copy) NSString *clientInfo;
@property (readonly, copy) NSString *oauthToken;
@property (readonly, nonatomic) _Bool requiresAuthentication;
@property _Bool shouldUseAuthentication;
@property _Bool usesSSL;
@property (readonly) NSURL *subscriptionURL;
@property (readonly, copy) NSString *subscriptionURLLabel;
@property (copy) NSString *externalHostname;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)accountTypeString;

/* instance methods */
- (long long)cachePolicy;
- (void)dealloc;
- (void)invalidate;
- (id)initWithManagedObject:(id)object;
- (void)setAccountState:(long long)state;
- (id)IMAPMailboxForMailboxName:(id)name createIfNeeded:(_Bool)needed;
- (_Bool)handleResponseCodeFromResponse:(id)response;
- (id)authenticatedConnection;
- (_Bool)connectAndAuthenticate:(id)authenticate;
- (id)newConnectedConnectionDiscoveringBestSettings:(_Bool)settings withConnectTimeout:(double)timeout readWriteTimeout:(double)timeout;
- (id)quotaRootForName:(id)name createIfNeeded:(_Bool)needed;
- (void)respondToHostBecomingReachable;
- (id)serverPathPrefix;
- (_Bool)shouldCacheAttachmentsForMessageWithDateReceived:(id)received;
- (void)updateAllMailboxContentsFromServer;
- (void)updateMailboxListFromServer;
- (id)_separatorCharacterWithGateway:(id)gateway;
- (void)_updateDefaultMailboxServerName;
- (_Bool)renameMailbox:(id)mailbox newParentMailbox:(id)mailbox;
- (void)_addSubmailboxes:(id)submailboxes toParent:(id)parent localMailboxes:(id)mailboxes serverMailboxes:(id)mailboxes placeholderMailboxes:(id)mailboxes;
- (id)_imapMailboxForMailboxProxy:(id)proxy;
- (_Bool)_recoverFromConnectionlessStateHighPriority:(_Bool)priority;
- (id)_serverNameComponentForMailboxName:(id)name;
- (id)_serverNameForMailbox:(id)mailbox parentMailbox:(id)mailbox separatorCharacter:(id)character;
- (_Bool)addMailboxToServer:(id)server parentMailbox:(id)mailbox;
- (void)backgroundFetchCompleted;
- (id)checkOutExistingGatewayForMailbox:(id)mailbox;
- (id)checkOutGatewayForMailbox:(id)mailbox highPriority:(_Bool)priority needsCheckIn:(_Bool *)in;
- (void)deleteMailboxFromPersistence:(id)persistence;
- (_Bool)deleteMailboxFromServer:(id)server;
- (void)incrementCountOfNewUnreadMessagesReceivedInInbox:(unsigned long long)inbox;
- (void)incrementTotalCountOfMessagesReceived:(unsigned long long)received;
- (void *)keychainProtocol;
- (id)mailboxProxyForMailbox:(id)mailbox;
- (id)newMailboxProxyWithMailbox:(id)mailbox;
- (void)newUnreadMessagesHaveBeenReceivedInInbox;
- (void)playOfflineActions;
- (long long)portNumberForKeychain;
- (void)presentOverQuotaAlert;
- (void)recoverFromConnectionLoss;
- (void)sendAccountNeedsCheckingNotification;
- (void)setCachePolicy:(long long)policy permanently:(_Bool)permanently;
- (void)setHighPriorityMailbox:(id)mailbox;
- (void)setServerPathPrefix:(id)prefix permanently:(_Bool)permanently;
- (_Bool)shouldAddMailboxToPersistence:(id)persistence withParent:(id)parent;

@end


@interface ICNFIMAPClientOperation : NSOperation

@property (readonly, copy) NSString *commandTypeString;
@property (readonly) _Bool alwaysAllowToComplete;
@property (readonly) _Bool completedSuccessfully;
@property (readonly) _Bool shouldSendAgainOnError;
@property (readonly) long long minRequiredConnectionState;
@property (readonly) long long maxAllowedConnectionState;
@property (readonly) long long composition;
@property (readonly) _Bool isWaitingToStart;
@property (readonly, copy) NSString *activityString;
@property (readonly, copy) NSString *detailsString;
@property (readonly, copy, nonatomic) NSString *shallowDescription;
@property (readonly, copy, nonatomic) NSMutableString *simpleDescriptionString;
@property (retain) ICNFIMAPGateway *gateway;
@property long long completionState;

/* class methods */
+ (id)IMAPNeedsLiteralCharacterSet;
+ (id)_IMAPNeedsQuoteCharacterSet;
+ (id)newIMAPQuotedString:(id)string;
+ (id)newIMAPStringForMailboxName:(id)name;

/* instance methods */
- (void)main;
- (id)description;
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)increasePriority;
- (void)operationDidFinish;
- (void)cleanupAfterCompletion;
- (_Bool)executeOnConnection:(id)connection;

@end


@interface ICNFIMAPAggregateClientOperation : ICNFIMAPClientOperation

@property (readonly, copy, nonatomic) NSArray *operations;

/* instance methods */
- (long long)composition;
- (id)init;
- (id)initWithOperations:(id)operations;
- (void)setGateway:(id)gateway;
- (void)cleanupAfterCompletion;

@end


@interface ICNFIMAPAggregateFetchUIDOperation : ICNFIMAPAggregateClientOperation

@property unsigned int expectedSize;

/* instance methods */
- (id)activityString;
- (id)initWithOperations:(id)operations;
- (void)cleanupAfterCompletion;
- (id)commandTypeString;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)initWithOperations:(id)operations expectedSize:(unsigned int)size;

@end


@interface ICNFIMAPAggregateGetQuotaRootOperation : ICNFIMAPAggregateClientOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPAggregateStatusOperation : ICNFIMAPAggregateClientOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPDownload : NSObject

@property (readonly, nonatomic) unsigned int uid;
@property (readonly, nonatomic) unsigned int bytesFetched;
@property (readonly, copy) NSData *data;
@property (copy) ICNFMCError *error;
@property (readonly) unsigned long long countOfPendingFetchResults;

/* instance methods */
- (id)description;
- (id)init;
- (void)addCommandsToPipeline:(id)pipeline withCache:(id)cache;
- (void)addPendingFetchResultsObject:(id)object;
- (id)createCopy;
- (void)handleFetchResult:(id)result;
- (id)initWithUid:(unsigned int)uid;
- (id)objectInPendingFetchResultsAtIndex:(unsigned long long)index;
- (void)processResults;
- (void)removeObjectFromPendingFetchResultsAtIndex:(unsigned long long)index;
- (void)sortPendingFetchResultsUsingFunction:(void * /* function */)function context:(void *)context;

@end


@interface ICNFIMAPCompoundDownload : ICNFIMAPDownload

@property (readonly, copy) NSArray *subdownloads;
@property (readonly) unsigned long long countOfSubdownloads;

/* instance methods */
- (_Bool)isComplete;
- (id)error;
- (id)description;
- (unsigned int)bytesFetched;
- (void)addSubdownload:(id)subdownload;
- (void)addCommandsToPipeline:(id)pipeline withCache:(id)cache;
- (id)createCopy;
- (unsigned int)expectedLength;
- (id)objectInSubdownloadsAtIndex:(unsigned long long)index;
- (void)processResults;
- (void)removeObjectFromSubdownloadsAtIndex:(unsigned long long)index;
- (void)removeSubdownload:(id)subdownload;

@end


@interface ICNFIMAPAttachmentsDownload : ICNFIMAPCompoundDownload

@property (retain) id <ICNFIMAPMessage> message;

/* instance methods */
- (id)createCopy;
- (id)initWithIMAPMessage:(id)imapmessage;
- (void)saveCompletedDownloads;

@end


@interface ICNFIMAPResponse : NSObject

@property (nonatomic) _Bool wasHandled;
@property (copy, nonatomic) NSString *tag;
@property (retain, nonatomic) ICNFMCError *error;
@property (readonly, nonatomic) _Bool isUntagged;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;
+ (id)newIMAPResponseWithConnection:(id)connection error:(id *)error;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPBasicResponse : ICNFIMAPResponse

@property (nonatomic) long long responseCode;
@property (retain, nonatomic) id responseInfo;
@property (copy, nonatomic) NSData *userData;
@property (readonly, copy, nonatomic) NSString *userString;

/* instance methods */
- (id)debugDescription;
- (id)description;
- (const char *)_responseName;

@end


@interface ICNFIMAPBadResponse : ICNFIMAPBasicResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPFetchResult : NSObject

@property (readonly, nonatomic) _Bool needsLineEndingConversion;

@end


@interface ICNFIMAPBodyFetchResult : ICNFIMAPFetchResult

@property (readonly, copy, nonatomic) NSString *section;
@property (retain, nonatomic) NSData *fetchData;
@property (nonatomic) unsigned int startOffset;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPBodyHeaderFetchResult : ICNFIMAPBodyFetchResult

/* instance methods */
- (id)section;
- (_Bool)needsLineEndingConversion;

@end


@interface ICNFIMAPBodySectionFetchResult : ICNFIMAPBodyFetchResult

@property (copy, nonatomic) NSString *section;

/* instance methods */

@end


@interface ICNFIMAPBodyStructureFetchResult : ICNFIMAPFetchResult

@property (copy, nonatomic) NSArray *bodyStructure;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPBodyTextFetchResult : ICNFIMAPBodyFetchResult

/* instance methods */
- (id)section;

@end


@interface ICNFIMAPByeResponse : ICNFIMAPBasicResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPCapabilityResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSArray *capabilities;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPSingleClientOperation : ICNFIMAPClientOperation

@property (retain) NSMutableArray *untaggedResponses;
@property (readonly) _Bool handlesAllUntaggedResponses;
@property (retain) ICNFMCError *error;
@property unsigned long long sequenceNumber;
@property unsigned long long sessionNumber;
@property (readonly, copy) NSString *tag;
@property _Bool isComplete;
@property (readonly, copy) NSString *debugCommandString;

/* instance methods */
- (long long)composition;
- (void)cleanupAfterCompletion;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)newCommandString;

@end


@interface ICNFIMAPClientMailboxOperation : ICNFIMAPSingleClientOperation

@property (copy) NSString *mailboxName;
@property (copy) NSString *mailboxArgumentName;

/* instance methods */
- (id)init;
- (id)initWithMailboxName:(id)name;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (_Bool)shouldSendAgainOnError;
- (id)simpleDescriptionString;
- (id)debugCommandString;

@end


@interface ICNFIMAPClientAppendOperation : ICNFIMAPClientMailboxOperation

@property (readonly, nonatomic) NSData *data;
@property (retain) NSDate *dateReceived;
@property (copy) NSArray *serverFlags;
@property (copy) NSDictionary *messageInfo;
@property (retain) ICNFMCActivityMonitor *progressMonitor;
@property _Bool shouldTryCreate;

/* instance methods */
- (id)activityString;
- (id)initWithMailboxName:(id)name;
- (id)commandTypeString;
- (id)detailsString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name flags:(id)flags dateReceived:(id)received data:(id)data;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (_Bool)shouldSendAgainOnError;
- (id)debugCommandString;

@end


@interface ICNFIMAPClientAuthenticateOperation : ICNFIMAPSingleClientOperation

@property (readonly, nonatomic) ICNFMCSaslClient *saslClient;
@property _Bool includeInitialResponse;

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (_Bool)handlesAllUntaggedResponses;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)debugCommandString;
- (id)initWithSaslClient:(id)client;

@end


@interface ICNFIMAPClientCapabilityOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientCheckOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientUnselectOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPClientCloseOperation : ICNFIMAPClientUnselectOperation

/* instance methods */
- (id)activityString;
- (_Bool)alwaysAllowToComplete;
- (id)commandTypeString;

@end


@interface ICNFIMAPClientCreateOperation : ICNFIMAPClientMailboxOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;

@end


@interface ICNFIMAPClientData : NSObject

@property (retain) NSMutableData *data;
@property (retain) NSMutableString *commandString;
@property (retain) ICNFIMAPClientData *nextData;
@property struct _NSRange dontLogRange;
@property _Bool isFrozen;

/* instance methods */
- (void)freeze;
- (id)initWithData:(id)data;
- (id)init;
- (void)addDataArgument:(id)argument literalPlus:(_Bool)plus;
- (void)addStringArgument:(id)argument;
- (id)initWithStringWaitingForArguments:(id)arguments;

@end


@interface ICNFIMAPClientDeleteOperation : ICNFIMAPClientMailboxOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;

@end


@interface ICNFIMAPClientDoneOperation : ICNFIMAPSingleClientOperation

@property (retain) NSDate *resetDate;

/* instance methods */
- (id)activityString;
- (_Bool)isReady;
- (void)setSequenceNumber:(unsigned long long)number;
- (id)init;
- (void)cancel;
- (_Bool)alwaysAllowToComplete;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (_Bool)setShouldQueueIdleWhenFinished:(_Bool)finished;
- (_Bool)updateReadiness;
- (_Bool)_shouldQueueIdleNow;
- (void)setResetDateEarlierThanNow;
- (_Bool)shouldQueueIdleWhenFinished;

@end


@interface ICNFIMAPClientSelectOperation : ICNFIMAPClientMailboxOperation

@property (retain) ICNFIMAPMailbox *imapMailbox;
@property _Bool useCondStore;
@property _Bool delayed;
@property (readonly) _Bool readOnly;

/* class methods */
+ (_Bool)automaticallyNotifiesObserversOfDelayed;

/* instance methods */
- (id)activityString;
- (_Bool)isReady;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (_Bool)handlesAllUntaggedResponses;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;

@end


@interface ICNFIMAPClientExamineOperation : ICNFIMAPClientSelectOperation

/* instance methods */
- (_Bool)readOnly;
- (id)activityString;
- (id)commandTypeString;

@end


@interface ICNFIMAPClientExpungeOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientFetchDataItem : NSObject

@property (copy, nonatomic) NSString *commandString;

/* class methods */
+ (id)UIDDataItem;
+ (id)bodyStructureDataItem;
+ (id)flagsDataItem;
+ (id)gmailLabelsDataItem;
+ (id)internalDateDataItem;
+ (id)modificationSequenceDataItem;
+ (id)sizeDataItem;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (unsigned long long)hash;

@end


@interface ICNFIMAPClientFetchBodyDataItem : ICNFIMAPClientFetchDataItem

@property (readonly) struct _NSRange dataRange;
@property (readonly) long long textSectionSpecifier;
@property (readonly) _Bool isHeader;
@property (readonly, copy) NSString *partSectionSpecifier;

/* class methods */
+ (id)newSectionSpecifierFromPart:(id)part text:(long long)text;

/* instance methods */
- (id)init;
- (void)_finalizeCommandStringWithHeaderFieldNames:(id)names peek:(_Bool)peek;
- (id)initWithHeaderFieldNames:(id)names;
- (id)initWithPartSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier dataRange:(struct _NSRange)range;
- (id)initWithPartSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier peek:(_Bool)peek headerFieldNames:(id)names dataRange:(struct _NSRange)range;

@end


@interface ICNFIMAPClientFetchChangedSinceDataItem : ICNFIMAPClientFetchDataItem

/* instance methods */
- (id)init;
- (id)initWithModificationSequenceNumber:(unsigned long long)number;

@end


@interface ICNFIMAPClientFetchOperation : ICNFIMAPSingleClientOperation

@property (copy) NSIndexSet *messageNumbers;
@property (retain) NSMutableArray *dataItems;
@property (retain) id <ICNFIMAPFetchResponseHandler> responseHandler;
@property struct { unsigned long long x0; unsigned long long x1; } range;

/* class methods */
+ (id)_headersToFetch;
+ (id)_fetchDataItemsForMessageSkeletonsWithHeaders:(id)headers;

/* instance methods */
- (id)activityString;
- (id)initWithRange:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)init;
- (_Bool)_isLegalRange:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)_newMessageSetCommandString;
- (struct _NSRange)_nsRangeForIMAPRange:(struct { unsigned long long x0; unsigned long long x1; })imaprange;
- (void)addDataItem:(id)item;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMessageNumbers:(id)numbers;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)_fetchDataItemsForMessageSkeletonsWithAdditionalHeaderFields:(id)fields;
- (void)_imapClientFetchOperationCommonInitWithMessageNumbers:(id)numbers;
- (void)addMessageSkeletonDataItemsWithAdditionalHeaderFields:(id)fields;
- (void)addMessageUidsAndFlagsDataItemsWithAdditionalHeaderFields:(id)fields;

@end


@interface ICNFIMAPClientFetchUIDOperation : ICNFIMAPClientFetchOperation

/* instance methods */
- (_Bool)_isLegalRange:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)commandTypeString;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientGetQuotaOperation : ICNFIMAPSingleClientOperation

@property (readonly, copy, nonatomic) NSString *quotaRoot;

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (id)initWithQuotaRoot:(id)root;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientGetQuotaRootOperation : ICNFIMAPClientMailboxOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientIDOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;

@end


@interface ICNFIMAPClientIdleOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPClientListOperation : ICNFIMAPSingleClientOperation

@property (copy) NSString *mailboxName;
@property (copy) NSString *referenceName;
@property long long options;
@property (copy) NSDictionary *listing;
@property (copy) NSString *separator;

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name options:(long long)options;
- (id)initWithMailboxName:(id)name referenceName:(id)name options:(long long)options;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientLSubOperation : ICNFIMAPClientListOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;

@end


@interface ICNFIMAPClientLoginOperation : ICNFIMAPSingleClientOperation

@property (readonly, copy, nonatomic) NSString *username;
@property (readonly, copy, nonatomic) NSString *password;
@property (readonly, copy, nonatomic) NSString *quotedUsername;

/* instance methods */
- (id)activityString;
- (id)init;
- (id)initWithUsername:(id)username password:(id)password;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (_Bool)handlesAllUntaggedResponses;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)debugCommandString;

@end


@interface ICNFIMAPClientLogoutOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (_Bool)alwaysAllowToComplete;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPClientNamespaceOperation : ICNFIMAPSingleClientOperation

@property (retain, nonatomic) id <ICNFIMAPAccount> account;
@property (copy, nonatomic) NSString *separatorChar;
@property (copy, nonatomic) NSArray *privateNamespaces;
@property (copy, nonatomic) NSArray *publicNamespaces;
@property (copy, nonatomic) NSArray *sharedNamespaces;

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithAccount:(id)account separatorChar:(id)_char;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;
- (_Bool)shouldSendAgainOnError;

@end


@interface ICNFIMAPClientNoopOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPClientOperationQueue : NSOperationQueue

@property (readonly, nonatomic) _Bool isIdle;
@property (retain) ICNFIMAPClientDoneOperation *doneOperation;
@property (retain) ICNFIMAPClientSelectOperation *selectOperation;
@property (readonly, copy, nonatomic) NSString *selectedMailboxName;
@property (retain) ICNFIMAPClientSuspendOperation *suspendOperation;
@property (retain, nonatomic) NSRecursiveLock *addOperationLock;
@property (copy) NSString *activityName;
@property (readonly) ICNFMCActivityMonitor *activityMonitor;
@property (retain) ICNFIMAPGateway *gateway;

/* instance methods */
- (id)description;
- (id)init;
- (void)dealloc;
- (void)activityDidFinish:(id)finish;
- (void)_clearActivityFinishTimer;
- (void)_postDelayedActivityFinished;
- (void)_setupDependeciesOnDone;
- (void)activityDidStart:(id)start;
- (_Bool)addClientOperation:(id)operation outUpdatedOperation:(id *)operation;
- (void)changeSelectDependenciesTo:(id)to;
- (void)clearDoneWithOperation:(id)operation;
- (void)finishIdling;
- (id)newSelectOperationForResumingIfNeeded;
- (_Bool)refreshDoneWithGateway:(id)gateway operation:(id)operation;
- (void)refreshIdle;
- (void)setDoneToReady;
- (_Bool)setupDependenciesOnSuspendCreatingIfNeeded;
- (_Bool)shouldAllowIdleToExecute:(id)execute;
- (void)suspendIfNeededAndClear:(_Bool)clear;
- (_Bool)waitUntilOperationIsFinished:(id)finished;

@end


@interface ICNFIMAPClientRenameOperation : ICNFIMAPClientMailboxOperation

@property (copy) NSString *nameForNewMailbox;
@property (copy) NSString *nameForNewMailboxArgument;

/* instance methods */
- (id)activityString;
- (id)initWithMailboxName:(id)name;
- (id)commandTypeString;
- (id)detailsString;
- (id)initWithMailboxName:(id)name newMailboxName:(id)name;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)debugCommandString;

@end


@interface ICNFIMAPClientStartTLSOperation : ICNFIMAPSingleClientOperation

/* instance methods */
- (id)activityString;
- (id)init;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (long long)maxAllowedConnectionState;
- (long long)minRequiredConnectionState;

@end


@interface ICNFIMAPClientStatusOperation : ICNFIMAPClientMailboxOperation

@property unsigned long long dataItems;
@property (copy) NSDictionary *statusEntries;

/* instance methods */
- (id)activityString;
- (id)initWithMailboxName:(id)name;
- (id)_newStringForDataItems;
- (void)addDataItem:(unsigned long long)item;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name dataItems:(unsigned long long)items;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;

@end


@interface ICNFIMAPClientSubscribeOperation : ICNFIMAPClientMailboxOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;

@end


@interface ICNFIMAPClientSuspendOperation : ICNFIMAPClientOperation

@property _Bool shouldExecuteSynchronously;

/* instance methods */
- (id)init;
- (_Bool)alwaysAllowToComplete;
- (id)commandTypeString;
- (long long)maxAllowedConnectionState;

@end


@interface ICNFIMAPClientUIDOperation : ICNFIMAPClientMailboxOperation

@property (copy) NSIndexSet *UIDs;
@property struct { unsigned long long x0; unsigned long long x1; } range;

/* class methods */
+ (id)newMessageSetForIndexSet:(id)set;
+ (id)newMessageSetForRange:(struct { unsigned long long x0; unsigned long long x1; })range;
+ (id)newMessageSetForNumbers:(id)numbers range:(struct _NSRange)range;

/* instance methods */
- (id)initWithMailboxName:(id)name;
- (id)initWithMailboxName:(id)name UIDs:(id)uids;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range;
- (long long)minRequiredConnectionState;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;

@end


@interface ICNFIMAPClientUIDCopyOperation : ICNFIMAPClientUIDOperation

@property (copy) NSString *destinationMailboxName;
@property (copy) NSString *destinationMailboxArgumentName;
@property (copy) NSDictionary *messageInfo;
@property _Bool shouldTryCreate;

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (id)detailsString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name UIDs:(id)uids;
- (id)initWithMailboxName:(id)name UIDs:(id)uids destinationMailboxName:(id)name;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;

@end


@interface ICNFIMAPClientUIDExpungeOperation : ICNFIMAPClientUIDOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;

@end


@interface ICNFIMAPClientUIDSearchOperation : ICNFIMAPClientUIDOperation

@property (copy) NSArray *terms;
@property (retain) NSMutableIndexSet *matchingUIDs;

/* instance methods */
- (id)activityString;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name UIDs:(id)uids;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)_newArgumentForSearchTerm:(id)term isLiteral:(_Bool *)literal;
- (id)debugCommandString;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range terms:(id)terms;

@end


@interface ICNFIMAPClientUIDStoreOperation : ICNFIMAPClientUIDOperation

@property (readonly) _Bool forGmailLabels;
@property _Bool add;
@property (readonly, copy) NSArray *serverFlags;
@property (readonly, copy) NSArray *gmailLabels;

/* instance methods */
- (id)activityString;
- (void)_imapClientUIDStoreCommonInitForGmailLabels:(_Bool)labels add:(_Bool)add flagsOrGmailLabels:(id)labels;
- (id)commandTypeString;
- (_Bool)executeOnConnection:(id)connection;
- (id)initWithMailboxName:(id)name UIDs:(id)uids;
- (id)initWithMailboxName:(id)name UIDs:(id)uids add:(_Bool)add flags:(id)flags;
- (id)initWithMailboxName:(id)name UIDs:(id)uids add:(_Bool)add gmailLabels:(id)labels;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range add:(_Bool)add flags:(id)flags;
- (id)newCommandDataForLiteralPlus:(_Bool)plus;
- (id)initWithMailboxName:(id)name range:(struct { unsigned long long x0; unsigned long long x1; })range add:(_Bool)add gmailLabels:(id)labels;

@end


@interface ICNFIMAPClientUnsubscribeOperation : ICNFIMAPClientMailboxOperation

/* instance methods */
- (id)activityString;
- (id)commandTypeString;

@end


@interface ICNFIMAPCommandPipeline : NSObject

@property (nonatomic) unsigned int chunkSize;
@property (nonatomic) unsigned int expectedSize;
@property (nonatomic) _Bool isSending;
@property (readonly, nonatomic) _Bool isFull;
@property (retain, nonatomic) NSMutableArray *fetchUnits;
@property (readonly, nonatomic) id imapCommandPipelineLock;

/* instance methods */
- (id)description;
- (id)init;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)_removeFetchUnitMatchingResponse:(id)response;
- (void)addFetchCommandForUid:(unsigned int)uid fetchItem:(id)item expectedLength:(unsigned int)length;
- (id)_newOperationsAssigningResponseHandler:(id)handler;
- (id)failureResponsesFromSendingCommandsWithGateway:(id)gateway responseHandler:(id)handler highPriority:(_Bool)priority;

@end


@interface ICNFMCConnection : NSObject <ICNFMCConnectionLogging>

@property (nonatomic) void * buffer;
@property (nonatomic) long long bufferRemainingBytes;
@property (nonatomic) unsigned long long bufferStart;
@property (nonatomic) unsigned long long bufferLength;
@property (retain, nonatomic) NSData *logHeader;
@property (retain, nonatomic) ICNFMCSaslClient *saslClient;
@property (retain) NSFileHandle *logFile;
@property (retain, nonatomic) ICNFMCSocket *socket;
@property (readonly, nonatomic) _Bool hasBytesAvailable;
@property (readonly, nonatomic) _Bool supportsPlainTextSchemes;
@property (nonatomic) double connectTimeout;
@property (nonatomic) double readWriteTimeout;
@property (weak) id <ICNFMCAccount> account;
@property _Bool isBackground;
@property (readonly, nonatomic) _Bool isExpensive;
@property (readonly, nonatomic) unsigned int cipherKeyLength;
@property (readonly, copy, nonatomic) NSArray *authenticationMechanisms;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;
+ (_Bool)_defaultsToBackground;
+ (id)loggingDelegate;
+ (id)logActivityOnHosts;
+ (id)logActivityOnPorts;
+ (_Bool)logActivityToFile;
+ (_Bool)logAllSocketActivity;
+ (void)setLogActivityOnHosts:(id)hosts;
+ (void)setLogActivityOnPorts:(id)ports;
+ (void)setLogActivityToFile:(_Bool)file;
+ (void)setLogAllSocketActivity:(_Bool)activity;
+ (void)setLoggingDelegate:(id)delegate;
+ (_Bool)shouldLogActivityForHost:(id)host port:(long long)port;

/* instance methods */
- (void)disconnect;
- (void)quit;
- (id)init;
- (_Bool)_completeConnectionWithResult:(_Bool)result;
- (_Bool)authenticate;
- (void)dealloc;
- (_Bool)connectDiscoveringBestSettings:(_Bool)settings;
- (_Bool)_startTLS;
- (void)_setupConnection;
- (void)logData:(id)data;
- (void)logString:(id)string;
- (_Bool)_fillBuffer:(id *)buffer;
- (void)flushLog;
- (id)_authenticateWithNonPlainTextSchemes;
- (id)_authenticateWithPlainTextSchemes;
- (_Bool)_readLineIntoData:(id)data error:(id *)error;
- (_Bool)_writeData:(id)data dontLogBytesInRange:(struct _NSRange)range error:(id *)error;
- (void)discoverAccountSettings;
- (_Bool)isValidAllowNetworking:(_Bool)networking;
- (_Bool)_readBytesIntoData:(id)data desiredLength:(long long)length error:(id *)error;
- (_Bool)_authenticateWithAuthenticationMechanisms:(id)mechanisms allowPlainText:(_Bool)text;
- (_Bool)_isSSLError:(id)sslerror;
- (void)_logEventWithPrefix:(const char *)prefix bytes:(const void *)bytes length:(unsigned long long)length maskStartIndex:(unsigned long long)index maskLength:(unsigned long long)length;
- (void)_logToFileDidChange:(id)change;
- (void)_loggingDidChange:(id)change;
- (id)_newConnectionAttemptsConfigureDynamically:(_Bool)dynamically;
- (long long)_readBytesFromSocketIntoBuffer:(void *)buffer amount:(unsigned long long)amount requireAllBytes:(_Bool)bytes error:(id *)error;
- (void)_resetLogHeaderWithPort:(long long)port;
- (void)_setupReadErrorForMonitor;
- (void)_setupWriteErrorForMonitor;
- (void)logBytes:(void *)bytes length:(unsigned long long)length;
- (void)logData:(id)data range:(struct _NSRange)range;
- (_Bool)_authenticateWithSaslClient:(id)client;
- (void)_setupConnectionErrorForMonitorWithPort:(long long)port usingSSL:(_Bool)ssl;
- (void)_setupSSLErrorForMonitorWithHostname:(id)hostname;
- (void)_setupSocketWithSecurityLayer:(long long)layer;
- (_Bool)_shouldKeepTryingAfterAuthenticationFailure:(id *)failure;

@end


@interface ICNFIMAPConnection : ICNFMCConnection

@property _Bool sentID;
@property (weak) id <ICNFIMAPAccount> account;
@property (retain) ICNFIMAPGateway *gateway;
@property (retain, nonatomic) ICNFIMAPMailbox *selectedIMAPMailbox;
@property (nonatomic) _Bool isValidating;
@property _Bool canStartIdle;
@property (readonly, nonatomic) _Bool isIdle;
@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, nonatomic) long long connectionState;
@property (readonly, nonatomic) long long currentConnectionState;
@property (readonly, nonatomic) _Bool isDisconnected;
@property (readonly, nonatomic) _Bool shouldExecuteOperationsImmediately;
@property (readonly, copy) NSArray *capabilities;
@property (copy) NSString *separatorChar;
@property (nonatomic) unsigned int readBufferSize;

/* class methods */
+ (void)initialize;
+ (_Bool)automaticallyNotifiesObserversForKey:(id)key;
+ (id)capabilityNameForCapability:(unsigned long long)capability;
+ (_Bool)_defaultsToBackground;
+ (void)_setReadSizeParameters;
+ (id)keyPathsForValuesAffecting_gateway;
+ (unsigned int)minimumFetchChunkSize;

/* instance methods */
- (void)disconnect;
- (id)debugDescription;
- (id)authenticationMechanisms;
- (void)quit;
- (id)description;
- (id)init;
- (_Bool)_completeConnectionWithResult:(_Bool)result;
- (_Bool)authenticate;
- (void)dealloc;
- (void)_transitionToState:(long long)state;
- (_Bool)_startTLS;
- (void)_setupConnection;
- (_Bool)supportsCapability:(unsigned long long)capability;
- (_Bool)_reconnect;
- (id)_authenticateWithPlainTextSchemes;
- (id)_gateway;
- (_Bool)_readLineIntoData:(id)data error:(id *)error;
- (_Bool)_writeData:(id)data dontLogBytesInRange:(struct _NSRange)range error:(id *)error;
- (void)discoverAccountSettings;
- (_Bool)isValidAllowNetworking:(_Bool)networking;
- (_Bool)sendIDIfNeeded;
- (_Bool)supportsPlainTextSchemes;
- (void)_addToCapabilities:(id)capabilities;
- (void)_clearCapabilities;
- (id)_copyNextTaggedOrContinuationResponseForCommand:(id)command;
- (id)_copyNextTaggedOrContinuationResponseForCommand:(id)command exists:(unsigned long long *)exists receivedExists:(_Bool *)exists;
- (void)_fetchCapabilitiesIfNeeded;
- (void)_fetchSeparatorCharIfNeeded;
- (void)_handleBytesAvailable;
- (_Bool)_isTemporaryError:(id)error;
- (_Bool)_readBytesIntoData:(id)data desiredLength:(long long)length error:(id *)error;
- (_Bool)_readDataWithRemainingByteCount:(long long)count intoData:(id)data error:(id *)error;
- (_Bool)_sendCommand:(id)command response:(id *)response;
- (void)_socketDiedError:(id *)error;
- (void)_transitionToState:(long long)state selectedMailbox:(id)mailbox readOnly:(_Bool)only;
- (void)disconnectAndNotify:(_Bool)notify;
- (_Bool)executeAggregateStatus:(id)status;
- (_Bool)executeAppend:(id)append;
- (_Bool)executeAuthenticate:(id)authenticate;
- (_Bool)executeCapability:(id)capability;
- (_Bool)executeDone:(id)done;
- (_Bool)executeFetch:(id)fetch;
- (_Bool)executeID:(id)id;
- (_Bool)executeIdle:(id)idle;
- (_Bool)executeListOrLSub:(id)lsub;
- (_Bool)executeLogin:(id)login;
- (_Bool)executeLogout:(id)logout;
- (_Bool)executeNamespace:(id)_namespace;
- (_Bool)executeNoop:(id)noop;
- (_Bool)executeStartTLS:(id)tls;
- (_Bool)executeStatus:(id)status;
- (_Bool)executeUIDExpunge:(id)uidexpunge;
- (_Bool)executeUIDStore:(id)uidstore;
- (_Bool)executeUnselect:(id)unselect;
- (id)mailboxNameIfSelected:(_Bool)selected;
- (id)separatorCharIfAvailable;
- (_Bool)startIdle;
- (_Bool)executeUIDCopy:(id)uidcopy;
- (id)initWithPendingGateway:(_Bool)gateway account:(id)account;
- (_Bool)_authenticateWithSaslClient:(id)client;
- (id)_copyNextServerResponse:(id *)response;
- (_Bool)_correctMailboxIsSelectedForOperation:(id)operation;
- (id)_errorForResponse:(id)response operation:(id)operation;
- (id)_getErrorFromFailedAuthenticationResponse:(id)response forOperation:(id)operation usingSASL:(_Bool)sasl;
- (_Bool)_isFetchResponseValid:(id)valid;
- (_Bool)_recordMailboxResponse:(id)response forOperation:(id)operation;
- (_Bool)_recordMailboxResponse:(id)response forOperation:(id)operation exists:(unsigned long long *)exists fromIDLE:(_Bool)idle;
- (void)_recordResponse:(id)response forOperation:(id)operation;
- (_Bool)_recordUntaggedResponse:(id)response forOperation:(id)operation;
- (_Bool)_recordUntaggedResponse:(id)response forOperation:(id)operation exists:(unsigned long long *)exists receivedExists:(_Bool *)exists fromIDLE:(_Bool)idle;
- (id)_responseFromSendingOperation:(id)operation receivedExists:(_Bool *)exists;
- (id)_responseFromSendingOperation:(id)operation tryCreate:(_Bool *)create receivedExists:(_Bool *)exists;
- (void)_setError:(id)error forCommand:(id)command;
- (void)_setSelectedMailbox:(id)mailbox;
- (id)_stateStringIncludingPII:(_Bool)pii;
- (_Bool)_tryToStartValidating;
- (_Bool)executeClientOperation:(id)operation;
- (_Bool)executeSelectOperation:(id)operation;
- (_Bool)executeSubscribeOperation:(id)operation;
- (_Bool)executeUIDSearch:(id)uidsearch;
- (_Bool)needsSelectForMailboxName:(id)name gateway:(id)gateway;
- (_Bool)prepareAndExecuteOperation:(id)operation outWrongState:(_Bool *)state;
- (void)resetTimingHistory;
- (void)setReadBufferSizeFromElapsedTime:(double)time bytesRead:(unsigned int)read;
- (void)updateCanStartIdle:(_Bool)idle;
- (double)updatedRecentAverageWithNewValue:(double)value;

@end


@interface ICNFIMAPConnectionPool : NSObject

@property unsigned long long maximumConnectionCount;
@property (readonly) unsigned long long connectionCount;
@property (readonly, copy) NSArray *connections;
@property (copy) NSString *defaultIdleMailboxName;

/* class methods */
+ (void)initialize;

/* instance methods */
- (id)description;
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)removeInvalidConnections;
- (void)resetMaximumConnectionCount;
- (void)updateConnectionsShouldUseIdle:(id)idle;
- (id)_suspendGatewayOfConnection:(id)connection mailbox:(id)mailbox forMailbox:(id)mailbox resumingGateway:(id)gateway;
- (id)_anyConnectionFromDictionary:(id)dictionary selectedOnly:(_Bool)only mailbox:(id *)mailbox;
- (id)_checkOutNewGatewayWithConnection:(id)connection forMailbox:(id)mailbox;
- (id)_closeAllConnectionsAndCompact:(_Bool)compact inDictionary:(id)dictionary;
- (_Bool)_connectionIsContained:(id)contained forMailbox:(id)mailbox inDictionary:(id)dictionary;
- (id)_gatewayToCheckOutConnection:(id)connection defaultGateway:(id)gateway mailboxName:(id)name newGateway:(_Bool *)gateway;
- (id)_keyForMailboxName:(id)name;
- (void)_makeConnectionAvailable:(id)available;
- (id)_newGatewayForConnection:(id)connection mailboxName:(id)name;
- (void)_removeAllConnectionsInDictionary:(id)dictionary;
- (_Bool)_removeConnection:(id)connection fromDictionary:(id)dictionary;
- (void)_removeDisconnectedConnection:(id)connection shouldRecover:(id)recover;
- (void)_removeInvalidConnectionsInDictionary:(id)dictionary;
- (void)_removeSuspendedGateway:(id)gateway;
- (void)_sealSuspendedGateways;
- (void)_setConnection:(id)connection forMailbox:(id)mailbox clear:(_Bool)clear inDictionary:(id)dictionary;
- (id)_suspendFirstIdleConnectionForMailbox:(id)mailbox resumingGateway:(id)gateway totalSecondsWaited:(double *)waited mightBeSuccessful:(_Bool *)successful;
- (id)_suspendFirstIdleConnectionInIdleConnections:(id)connections forMailbox:(id)mailbox resumingGateway:(id)gateway;
- (void)_suspendGateway:(id)gateway allowNetworking:(_Bool)networking;
- (id)_suspendedGatewayForMailbox:(id)mailbox;
- (id)_suspendedGatewayWithWorkRequireSelected:(_Bool)selected;
- (_Bool)_validateAndCheckOutGateway:(id)gateway forMailbox:(id)mailbox allowReconnect:(_Bool)reconnect newGateway:(_Bool)gateway;
- (_Bool)checkInConnection:(id)connection forGateway:(id)gateway;
- (void)checkInNewConnection:(id)connection;
- (id)checkOutGatewayForExistingConnectionToMailbox:(id)mailbox;
- (id)checkOutGatewayForMailbox:(id)mailbox;
- (id)checkOutGatewayForMailbox:(id)mailbox newConnection:(id)connection highPriority:(_Bool)priority waitIndefinitely:(_Bool)indefinitely;
- (id)checkOutNewGatewayWithConnection:(id)connection;
- (void)closeAllConnectionsAndCompact:(_Bool)compact;
- (void)mailboxWithServerName:(id)name wasRenamed:(id)renamed;
- (void)sealGatewayShutIfNoChanceOfResuming:(id)resuming;
- (_Bool)suspendGateway:(id)gateway withOperation:(id)operation;
- (_Bool)tryToResumeGateway:(id)gateway;
- (_Bool)yieldGateway:(id)gateway;

@end


@interface ICNFIMAPContinuationResponse : ICNFIMAPBasicResponse

/* instance methods */
- (const char *)_responseName;
- (_Bool)isUntagged;

@end


@interface ICNFIMAPDownloadCache : NSObject <ICNFIMAPFetchResponseHandler>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (struct _NSRange)_findRangeOrInsertionPointForDownloadsWithUid:(unsigned int)uid;
- (id)_getDownloadForUid:(unsigned int)uid partSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier length:(unsigned int)length estimatedLength:(unsigned int)length;
- (void)_lockedAddDownload:(id)download atIndex:(unsigned long long)index forUid:(unsigned int)uid;
- (void)_lockedUpdateDownloadsInRange:(struct _NSRange)range fetchResults:(id)results error:(id)error;
- (void)addCommandsForDownload:(id)download toPipeline:(id)pipeline;
- (void)addDownload:(id)download forUid:(unsigned int)uid;
- (void)cleanUpDownloadsForUid:(unsigned int)uid;
- (id)downloadForMessage:(id)message;
- (id)downloadForUid:(unsigned int)uid partSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier expectedLength:(unsigned int)length;
- (id)downloadForUid:(unsigned int)uid partSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier length:(unsigned int)length;
- (void)handleFetchResponse:(id)response forUid:(unsigned int)uid;
- (void)handleFetchResponses:(id)responses;
- (void)processResultsForUid:(unsigned int)uid;
- (_Bool)handleResponse:(id)response forOperation:(id)operation;

@end


@interface ICNFIMAPEnvelopeFetchResult : ICNFIMAPFetchResult

@property (copy, nonatomic) NSArray *envelope;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPNumericResponse : ICNFIMAPResponse

@property (nonatomic) unsigned long long number;

/* instance methods */
- (id)description;
- (const char *)_responseName;

@end


@interface ICNFIMAPExistsResponse : ICNFIMAPNumericResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPExpungeResponse : ICNFIMAPNumericResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPFetchResponse : ICNFIMAPNumericResponse

@property (nonatomic) _Bool isValid;
@property (copy, nonatomic) NSArray *fetchResults;
@property (readonly, nonatomic) ICNFIMAPEnvelopeFetchResult *envelopeFetchResult;
@property (readonly, nonatomic) ICNFIMAPInternalDateFetchResult *internalDateFetchResult;
@property (readonly, nonatomic) ICNFIMAPRFC822SizeFetchResult *rfc822SizeFetchResult;
@property (readonly, nonatomic) ICNFIMAPBodyStructureFetchResult *bodyStructureFetchResult;
@property (readonly, nonatomic) ICNFIMAPUidFetchResult *uidFetchResult;
@property (readonly, nonatomic) ICNFIMAPFlagsFetchResult *flagsFetchResult;
@property (readonly, nonatomic) ICNFIMAPModificationSequenceFetchResult *modificationSequenceFetchResult;
@property (readonly, nonatomic) ICNFIMAPGmailLabelsFetchResult *gmailLabelsFetchResult;
@property (readonly, nonatomic) ICNFIMAPBodyTextFetchResult *bodyTextFetchResult;
@property (readonly, nonatomic) ICNFIMAPBodyHeaderFetchResult *bodyHeaderFetchResult;
@property (readonly, nonatomic) ICNFIMAPBodySectionFetchResult *bodySectionFetchResult;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)_fetchResultOfClass:(Class)_class;
- (const char *)_responseName;

@end


@interface ICNFIMAPFlagsFetchResult : ICNFIMAPFetchResult

@property (copy, nonatomic) NSArray *flagsArray;
@property (readonly, nonatomic) unsigned int messageFlags;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPFlagsResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSSet *flags;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPFramework : NSObject

/* class methods */
+ (void)setUserAgent:(id)agent;
+ (id)userAgent;
+ (id)bundle;
+ (_Bool)logsIMAPErrors;
+ (void)setLogsIMAPErrors:(_Bool)imaperrors;

@end


@interface ICNFIMAPGateway : NSObject

@property (retain) ICNFIMAPConnection *primitiveConnection;
@property (weak) ICNFIMAPConnectionPool *connectionPool;
@property (retain) ICNFIMAPConnection *connection;
@property (retain) ICNFIMAPClientOperationQueue *operationQueue;
@property _Bool primaryClientAllowsYielding;
@property (readonly) _Bool hasClients;
@property _Bool canYield;
@property (readonly) _Bool okToYield;
@property (readonly, nonatomic) _Bool isDeserted;
@property _Bool remainedDeserted;
@property _Bool needsSelect;
@property _Bool isSealedShut;
@property (readonly, copy, nonatomic) NSString *mailboxName;
@property (readonly, nonatomic) _Bool isExpensive;

/* class methods */
+ (void)initialize;
+ (double)IMAPIdleRefreshDelay;
+ (id)sharedKeySetForMessageInfo;
+ (void)_addIdleGateway:(id)gateway;
+ (void)_checkIdleGateways;
+ (void)_removeIdleGateway:(id)gateway;

/* instance methods */
- (void)checkIn;
- (void)suspend;
- (id)debugDescription;
- (void)close;
- (void)noop;
- (id)init;
- (void)dealloc;
- (_Bool)supportsCapability:(unsigned long long)capability;
- (void)waitUntilAllOperationsAreFinished;
- (_Bool)check:(id *)check;
- (void)yield;
- (_Bool)expunge;
- (void)unselect;
- (void)logout;
- (_Bool)deleteMailbox:(id)mailbox;
- (_Bool)createMailbox:(id)mailbox;
- (void)fetchQuotaRootNamesForMailboxes:(id)mailboxes;
- (_Bool)listingForMailbox:(id)mailbox options:(long long)options listingInfo:(id)info;
- (_Bool)renameMailbox:(id)mailbox toMailbox:(id)mailbox;
- (_Bool)subscribeMailbox:(id)mailbox;
- (_Bool)subscribedListingForMailbox:(id)mailbox options:(long long)options listingInfo:(id)info;
- (_Bool)unsubscribeMailbox:(id)mailbox;
- (void)closeAndLogout;
- (void)fetchTotalSizeAndMessageCount;
- (_Bool)getQuotaForRootName:(id)name;
- (id)mailboxNameIfSelected:(_Bool)selected;
- (_Bool)startIdle;
- (void)_waitForDelayedSelectOperation:(id)operation;
- (_Bool)appendData:(id)data toMailboxNamed:(id)named flags:(id)flags dateReceived:(id)received messageInfo:(id)info error:(id *)error;
- (_Bool)examineMailbox:(id)mailbox;
- (void)fetchFlagsForMaxRecentMessages:(unsigned long long)messages;
- (_Bool)storeGmailLabels:(id)labels state:(_Bool)state forUids:(id)uids;
- (_Bool)_addSelectOperationForMailbox:(id)mailbox class:(Class)_class;
- (void)_allowClientOperationThrough:(id)through;
- (void)_checkInForOperation:(id)operation;
- (unsigned long long)_clientCount;
- (_Bool)_completeSelectOperation:(id)operation;
- (void)_executeSuspend:(id)suspend;
- (_Bool)_expunge:(_Bool)_expunge orStoreFlags:(id)flags orStoreGmailLabels:(id)labels state:(_Bool)state forUids:(id)uids;
- (_Bool)_expungeUids:(id)uids mailboxName:(id)name;
- (void)_finishQueueIdlingAndSuspend:(_Bool)suspend;
- (void)_setError:(id *)error fromOperation:(id)operation;
- (void)_setErrorFromOperation:(id)operation overwriteExistingError:(_Bool)error;
- (_Bool)_storeFlags:(id)flags state:(_Bool)state forUids:(id)uids mailboxName:(id)name;
- (_Bool)_storeGmailLabels:(id)labels state:(_Bool)state forUids:(id)uids mailboxName:(id)name;
- (void)_tryToCheckInConnectionAndTryToIdle:(_Bool)idle;
- (_Bool)addClientOperation:(id)operation toQueueAndWaitUntilFinished:(_Bool)finished;
- (void)allowClientOperationThrough:(id)through;
- (void)checkInAsynchronously;
- (_Bool)checkOut;
- (void)configureForMailboxName:(id)name;
- (_Bool)copyUids:(id)uids toMailboxNamed:(id)named messageInfo:(id)info error:(id *)error;
- (_Bool)deleteMessagesOlderThanNumberOfDays:(long long)days settingFlags:(id)flags;
- (_Bool)expungeUids:(id)uids;
- (void)fetchAllFlags;
- (void)fetchStatusForMailboxes:(id)mailboxes dataItems:(unsigned long long)items;
- (id)initWithIMAPConnection:(id)imapconnection mailbox:(id)mailbox pool:(id)pool;
- (id)namespacesWithSeparatorChar:(id)_char;
- (void)operationQueueDidIdle;
- (void)refreshDone:(_Bool)done withOperation:(id)operation;
- (void)refreshIdle;
- (void)restoreSavedQualityOfService;
- (void)resumeWithConnection:(id)connection reselect:(_Bool)reselect;
- (_Bool)saveCurrentQualityOfServiceAndBoostTo:(long long)to;
- (void)sealShutAndCompact:(_Bool)compact allowNetworking:(_Bool)networking;
- (id)searchUidRange:(struct { unsigned long long x0; unsigned long long x1; })range forNewMessageIDs:(id)ids;
- (id)searchUidRange:(struct { unsigned long long x0; unsigned long long x1; })range forTerms:(id)terms;
- (unsigned int)searchedUidNextForMessageNumber:(unsigned long long)number;
- (_Bool)selectMailbox:(id)mailbox;
- (void)setServerPathPrefixOnAccount:(id)account withSeparatorChar:(id)_char;
- (id)statusForMailbox:(id)mailbox dataItems:(unsigned long long)items;
- (_Bool)storeFlags:(id)flags state:(_Bool)state forUids:(id)uids;
- (_Bool)synchronouslyExecuteDoneWithSequence:(unsigned long long)sequence session:(unsigned long long)session;
- (_Bool)synchronouslyExecuteSelect:(id)select;
- (void)waitUntilClientOperationIsFinished:(id)finished;

@end


@interface ICNFIMAPGmailLabelsFetchResult : ICNFIMAPFetchResult

@property (copy, nonatomic) NSSet *gmailLabels;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPIDResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSDictionary *serverID;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPInternalDateFetchResult : ICNFIMAPFetchResult

@property (copy, nonatomic) NSString *internalDate;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPInternalFetchResponse : ICNFIMAPFetchResponse

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPInternalUidFlagsResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSIndexSet *uids;
@property (retain, nonatomic) ICNFIMAPFlagsFetchResult *flagsFetchResult;
@property (nonatomic) signed char flagChangeType;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPListResponse : ICNFIMAPResponse

@property (nonatomic) unsigned long long mailboxAttributes;
@property (copy, nonatomic) NSString *separator;
@property (copy, nonatomic) NSString *mailboxName;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;
- (id)_newStringForMailboxAttributes;
- (const char *)_responseName;
- (unsigned long long)mailboxAttributesFromSet:(id)set;

@end


@interface ICNFIMAPLSubResponse : ICNFIMAPListResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPMailbox : NSObject

@property (retain) id <ICNFMCMailbox> mailbox;
@property (nonatomic) unsigned int permanentFlags;
@property (copy) NSString *referenceName;
@property _Bool readOnly;
@property _Bool uidNotSticky;
@property (retain) ICNFIMAPGateway *selectedGateway;
@property (retain) NSArray *quotaRoots;
@property unsigned long long exists;
@property struct { long long x0; unsigned long long x1; } quotaUsage;
@property unsigned int uidNext;
@property unsigned int uidValidity;
@property unsigned int unseenCount;
@property unsigned long long computedHighestModificationSequence;
@property unsigned long long allegedHighestModificationSequence;
@property _Bool supportsModificationSequences;
@property (retain, nonatomic) NSMutableArray *unprocessedResponses;
@property _Bool hasNewResponses;

/* class methods */
+ (_Bool)automaticallyNotifiesObserversOfAllegedHighestModificationSequence;
+ (_Bool)automaticallyNotifiesObserversOfExists;
+ (_Bool)automaticallyNotifiesObserversOfQuotaUsage;

/* instance methods */
- (void)setDelegate:(id)delegate;
- (id)description;
- (id)init;
- (void)dealloc;
- (void)addResponse:(id)response;
- (id)initWithMailboxName:(id)name;
- (void)clearDelegate:(id)delegate;
- (void)setTotalSize:(unsigned long long)size forQuotaMessageCount:(long long)count;
- (void)setExists:(unsigned long long)exists fromIDLE:(_Bool)idle;
- (id)removeResponse;

@end


@interface ICNFMCMailboxProxy : ICNFMCManagedObjectProxy

@end


@interface ICNFIMAPMailboxProxy : ICNFMCMailboxProxy <ICNFIMAPMailboxDelegate, ICNFIMAPMessageDataSource, ICNFMCMailbox>

@property _Bool doingHasMessages;
@property (weak) ICNFIMAPAccountProxy *accountProxy;
@property (weak) ICNFIMAPMailbox *imapMailbox;
@property (copy) NSString *name;
@property (copy) NSString *serverName;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) signed char persistentIDType;
@property (readonly, nonatomic) id <ICNFIMAPAccount> account;
@property (readonly, copy) NSString *mailboxName;
@property (readonly, nonatomic) _Bool isInbox;
@property (readonly, nonatomic) _Bool isAllMailMailbox;
@property (readonly, nonatomic) unsigned long long totalCountOfMessages;
@property (readonly, nonatomic) ICNFIMAPCommandPipeline *fetchPipeline;
@property (readonly, nonatomic) ICNFIMAPDownloadCache *downloadCache;
@property (readonly, nonatomic) _Bool messagesAreBeingAdded;
@property (readonly, nonatomic) unsigned int maximumRemoteID;
@property (nonatomic) unsigned int uidNextStatus;
@property (nonatomic) unsigned long long allegedHighestModificationSequence;
@property (readonly) _Bool isReadOnly;
@property (readonly, nonatomic) _Bool supportsSnippets;
@property (readonly, nonatomic) _Bool canCompact;
@property (readonly, nonatomic) id <ICNFMCMailbox> mailbox;
@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, copy, nonatomic) NSString *displayNameWithoutPII;
@property (readonly, copy, nonatomic) NSString *extendedDisplayName;
@property (readonly, copy, nonatomic) NSString *URLString;
@property (readonly) unsigned long long unseenCount;
@property (readonly) _Bool unseenCountIsKnown;

/* instance methods */
- (unsigned long long)computedHighestModificationSequenceForMailbox:(id)mailbox;
- (void)setUserInfoObject:(id)object forKey:(id)key;
- (void)doCompact;
- (void)saveSnippetsForMessages:(id)messages;
- (id)async_setFlagsFromDictionary:(id)dictionary forMessages:(id)messages;
- (_Bool)hasValidCacheFileForMessage:(id)message;
- (id)copyIncompleteMessages;
- (void)dealloc;
- (void)invalidateMessage:(id)message;
- (unsigned long long)allegedHighestModificationSequenceForMailbox:(id)mailbox;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)invalidate;
- (void)deleteMessages:(id)messages moveToTrash:(_Bool)trash;
- (void)updateComputedHighestModificationSequence:(unsigned long long)sequence forMailbox:(id)mailbox;
- (void)setComputedHighestModificationSequence:(unsigned long long)sequence;
- (id)messageForMessageID:(id)id;
- (id)initWithManagedObject:(id)object;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (void)updateFromServer;
- (void)addMessages:(id)messages;
- (id)attachmentsDirectoryForMessage:(id)message;
- (id)bodyDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)flushAllCaches;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available;
- (_Bool)hasMessages;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)messageFlagsDidChange:(id)change flags:(id)flags;
- (void)setColor:(id)color highlightTextOnly:(_Bool)only forMessages:(id)messages;
- (void)setNumberOfAttachments:(unsigned int)attachments isSigned:(_Bool)_signed isEncrypted:(_Bool)encrypted forMessage:(id)message;
- (void)setUserInfoBool:(_Bool)_bool forKey:(id)key;
- (id)snippetsForMessages:(id)messages;
- (id)uniquedString:(id)string;
- (_Bool)userInfoBoolForKey:(id)key;
- (id)userInfoObjectForKey:(id)key;
- (unsigned int)_permanentFlags;
- (void)resetSyncEngine;
- (id)_copyMailboxSyncEngineCreateIfNecessary:(_Bool)necessary setupGatewayIfNecessary:(_Bool)necessary;
- (void)_messageDidSetBody:(id)body;
- (_Bool)addMessageToServer:(id)server withMessageType:(signed char)type;
- (id)async_setFlagWithKey:(id)key state:(_Bool)state forMessages:(id)messages;
- (id)async_setFlagsFromDictionary:(id)dictionary forMessages:(id)messages updatingServer:(_Bool)server;
- (id)async_setJunkMailLevel:(long long)level forMessages:(id)messages trainJunkMailDatabase:(_Bool)database userRecorded:(_Bool)recorded;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags allowPartial:(_Bool)partial;
- (id)cacheDirectoryContents;
- (void)compactMessagesFromSyncEngine:(id)engine;
- (id)copyMessagesWithTemporaryUids;
- (id)dataForMimePart:(id)part;
- (void)deleteMessageFromPersistence:(id)persistence;
- (_Bool)deleteMessageFromServer:(unsigned int)server;
- (id)fetchAndCacheBodyDataForMessages:(id)messages;
- (id)fullBodyDataForMessage:(id)message;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available fetchIfNotAvailable:(_Bool)available;
- (id)getDetailsForMessagesWithRemoteIDs:(id)ids;
- (_Bool)hasCacheFileForMessage:(id)message directoryContents:(id)contents;
- (_Bool)hasCacheFileForMessage:(id)message part:(id)part directoryContents:(id)contents;
- (_Bool)hasCachedDataForMimePart:(id)part;
- (id)headerDataForMessage:(id)message;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)headersForMessage:(id)message;
- (id)headersForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (_Bool)isMessageDeletedFromPersistence:(id)persistence;
- (void)mailboxWithServerName:(id)name wasRenamed:(id)renamed;
- (_Bool)messageHasBeenDeleted:(id)deleted;
- (_Bool)messageShouldBePersisted:(id)persisted;
- (id)messageWithDefaultLoadOptionsAndManagedObjectID:(id)id;
- (id)messagesBeingAdded;
- (id)messagesForMessageIDHeader:(id)idheader;
- (id)messagesWithManagedObjectIDs:(id)ids;
- (id)newDictionaryForLocalFlags:(unsigned int)flags serverFlags:(unsigned int)flags existingDictionary:(id)dictionary;
- (void)processResponsesFromMailbox:(id)mailbox;
- (id)recentFlagChangesForManagedObjectID:(id)id;
- (void)removeAllLocalMessages;
- (id)routeMessages:(id)messages fetchingBodies:(_Bool)bodies messagesNeedingBodies:(id)bodies;
- (void)sendResponseType:(signed char)type forMeetingMessage:(id)message;
- (_Bool)setPreferredEncoding:(unsigned long long)encoding forMessage:(id)message;
- (void)setUidValidityStatus:(unsigned int)status;
- (void)syncEngineDidFinish;
- (void)syncEngineDidStart;
- (void)syncEngineDidSynchronizeMessageList;
- (_Bool)synchronouslySetPreferredEncoding:(unsigned long long)encoding forMessages:(id)messages;
- (unsigned int)uidValidityStatus;
- (void)undeleteMessages:(id)messages;
- (id)undeleteMessages:(id)messages movedToStore:(id)store newMessageIDs:(id)ids;
- (void)updateCountFromMailbox:(id)mailbox fromIDLE:(_Bool)idle;
- (void)updateSelectedGatewayFromMailbox:(id)mailbox;
- (void)updateUidValidityFromMailbox:(id)mailbox;

@end


@interface ICNFIMAPMailboxSyncEngine : NSObject <ICNFIMAPFetchResponseHandler, ICNFMCActivityTarget>

@property _Bool messageListIsSynchronized;
@property unsigned long long numberOfMessagesOnServer;
@property unsigned long long computedHighestModificationSequence;
@property unsigned int uidNext;
@property _Bool connectionSupportsUIDPLUS;
@property _Bool forceSyncOfAllMessages;
@property (readonly, copy, nonatomic) id /* block */ compareByUid;
@property (readonly, copy) NSArray *messagesBeingAdded;
@property (readonly, copy, nonatomic) NSString *stateStringForDiagnostics;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;

/* instance methods */
- (void)unlock;
- (id)initWithDataSource:(id)source;
- (void)lock;
- (id)init;
- (void)reset;
- (_Bool)isReset;
- (void)dealloc;
- (void)setUidValidity:(unsigned int)validity;
- (void)invalidateDataSource;
- (id)_gmailLabelsForNames:(id)names;
- (id)_copyDataSource;
- (void)_addDetails:(id)details forMessageNumber:(unsigned long long)number;
- (void)_addItem:(id)item toAuxiliaryList:(unsigned long long)list;
- (_Bool)_cacheAttachmentsWithMonitor:(id)monitor;
- (_Bool)_cacheMessagesWithMonitor:(id)monitor;
- (long long)_cachePolicyForAccount:(id)account;
- (id)_checkOutGateway;
- (id)_copyIMAPMailbox;
- (signed char)_dataSourcePersistentIDType;
- (void)_discardSyncProgressSoFar;
- (void)_doUidStoreUpdate:(id)update;
- (_Bool)_fetchUidsFlagsAndLabelsWithMonitor:(id)monitor;
- (id)_getAuxiliaryListForType:(unsigned long long)type;
- (id)_getKnownMessageDetailsForNumber:(unsigned long long)number;
- (id)_getKnownMessageDetailsForUid:(unsigned int)uid;
- (_Bool)_getNewMessageSkeletonsWithMonitor:(id)monitor messagesFromOpen:(id *)open;
- (id)_getObjectWithSameUidAsObject:(id)object inArray:(id)array insertIndex:(unsigned long long *)index;
- (void)_goWithMessages:(id)messages;
- (void)_goWithMessagesIfNeeded:(id)needed;
- (_Bool)_handleFailedFetchResponseForOperation:(id)operation;
- (void)_handleFetchResponse:(id)response withMonitor:(id)monitor message:(id *)message flagsChanges:(id *)changes labels:(id *)labels;
- (_Bool)_handleInvitationMessagesWithMonitor:(id)monitor;
- (void)_handleMessagesWereAddedToPersistence:(id)persistence withMonitor:(id)monitor;
- (void)_handleNewUIDsAddedToServer:(id)server;
- (_Bool)_handleRoutedUidsWithMonitor:(id)monitor;
- (_Bool)_hasPendingChanges;
- (void)_mergeItems:(id)items intoAuxiliaryList:(unsigned long long)list;
- (id)_newOperationFromUIDsNeedingSkeletons:(unsigned long long)skeletons;
- (void)_notifyBackgroundFetchCompletedWithLogMessage:(id)message;
- (id)_persistedMessageForDetails:(id)details;
- (_Bool)_placeholderDetailsExist;
- (void)_processAttachmentNames;
- (_Bool)_processResponsesWithMonitor:(id)monitor;
- (void)_pushFlags:(id)flags forPersistentIDs:(id)ids toDataSource:(id)source withMonitor:(id)monitor;
- (void)_pushFlags:(id)flags toDataSource:(id)source withMonitor:(id)monitor;
- (void)_pushLabels:(id)labels toDataSource:(id)source withMonitor:(id)monitor;
- (_Bool)_recoverFromErrorInDownload:(id)download uid:(unsigned int)uid cacheList:(id)list atIndex:(unsigned long long)index downloadCache:(id)cache;
- (void)_removeMessagesOrDetailsFromDataSource:(id)source;
- (void)_removeUidFromAuxiliaryLists:(id)lists;
- (void)_resetClearingGateway:(_Bool)gateway clearingDataSource:(_Bool)source;
- (void)_resizeMessageDetails;
- (void)_setAttachmentNamesForMessage:(id)message;
- (void)_setAuxiliaryList:(id)list forType:(unsigned long long)type;
- (_Bool)_setGateway:(id)gateway;
- (void)_setupFakeResponseToOperation:(id)operation messageNumber:(unsigned long long)number;
- (void)_setupForNewIMAPMailbox:(id)imapmailbox andGateway:(id)gateway;
- (_Bool)_shouldContinueSyncingWithGateway;
- (_Bool)_shouldContinueSyncingWithMonitor:(id)monitor;
- (void)_startNewThreadIfNeeded;
- (_Bool)_syncChangedMessagesOnly;
- (_Bool)_syncWithDataSourceWithMonitor:(id)monitor messagesFromOpen:(id)open;
- (void)_updateCountOfMessagesOnServerIfNecessary;
- (void)_updateFlagChanges:(id *)changes withDetails:(id)details previousFlags:(unsigned int)flags;
- (void)_updatePendingChangesWithMonitor:(id)monitor;
- (void)boostActiveOperationsTo:(long long)to;
- (_Bool)handleResponse:(id)response forOperation:(id)operation;
- (void)messagesWereAddedToDataSource:(id)source;
- (void)newUIDsWereAddedToServer:(id)server;
- (void)requestCheckingNewMail;
- (void)responsesWereAddedToIMAPMailbox:(id)imapmailbox;
- (void)runSynchronouslyWithMessages:(id)messages;
- (void)setAutomaticallyStartsBackgroundThread:(_Bool)thread;
- (void)setGatewayFromIMAPMailbox:(id)imapmailbox;
- (id)suffixArrayOfArray:(id)array ofLength:(unsigned long long)length fullLength:(unsigned long long *)length;
- (void)uidsWereCompactedFromDataSource:(id)source;
- (void)updateCountOfMessagesOnServerFromIMAPMailbox:(id)imapmailbox fromIDLE:(_Bool)idle;

@end


@interface ICNFMCMessage : NSObject <ICNFMCMessageSortingInterface, NSCopying>

@property signed char primitiveMessageType;
@property double primitiveDateSentInterval;
@property double primitiveDateReceivedInterval;
@property double primitiveDateLastViewedInterval;
@property (readonly, copy, nonatomic) NSString *path;
@property (readonly, nonatomic) id <ICNFMCMailAccount> account;
@property (readonly, nonatomic) _Bool dataSourceShouldBeSet;
@property signed char type;
@property (readonly) ICNFMCMessageHeaders *headers;
@property (readonly, nonatomic) ICNFMCMessageHeaders *headersIfAvailable;
@property (readonly) NSData *headerData;
@property (readonly, nonatomic) ICNFMCMessageBody *messageBody;
@property (readonly, copy, nonatomic) NSData *bodyData;
@property (readonly, nonatomic) ICNFMCMessageBody *messageBodyForIndexing;
@property (readonly, nonatomic) ICNFMCMessageBody *messageBodyIfAvailable;
@property (readonly, nonatomic) _Bool isMessageContentLocallyAvailable;
@property (readonly, nonatomic) _Bool isPartialMessageBodyAvailable;
@property (readonly, nonatomic) _Bool hasCalculatedNumberOfAttachments;
@property (readonly, nonatomic) _Bool hasAttachments;
@property (readonly, nonatomic) _Bool supportsSnippets;
@property (readonly, nonatomic) _Bool shouldImmediatelyCalculateSnippets;
@property (readonly, copy, nonatomic) NSAttributedString *attributedString;
@property (readonly, copy, nonatomic) NSString *stringForJunk;
@property (readonly, copy, nonatomic) NSString *stringForIndexing;
@property (readonly, copy, nonatomic) NSString *stringForBodyContent;
@property (readonly, copy, nonatomic) NSString *remoteMailboxURLString;
@property (readonly, copy, nonatomic) NSString *originalMailboxURLString;
@property (readonly, copy, nonatomic) NSString *persistentID;
@property (readonly, copy) NSString *remoteID;
@property (readonly, copy, nonatomic) NSString *messageID;
@property (readonly, nonatomic) unsigned int uid;
@property (copy) NSUUID *documentID;
@property _Bool markedForOverwrite;
@property (readonly, copy) NSData *messageIDHeaderDigest;
@property (copy) NSData *inReplyToHeaderDigest;
@property (readonly, copy, nonatomic) NSString *URLString;
@property (readonly, copy, nonatomic) NSString *URLStringIfAvailable;
@property (readonly, nonatomic) _Bool isEditable;
@property (readonly, nonatomic) _Bool isMessageMeeting;
@property (copy) NSColor *color;
@property _Bool colorHasBeenEvaluated;
@property (readonly, nonatomic) int colorIntValue;
@property (readonly, nonatomic) long long junkMailLevel;
@property (readonly, nonatomic) long long priority;
@property (readonly) struct { unsigned int x0:1; unsigned int x1:1; unsigned int x2:8; unsigned int x3:8; unsigned int x4:8; unsigned int x5:1; unsigned int x6:2; unsigned int x7:1; unsigned int x8:2; } moreMessageFlags;
@property (readonly, nonatomic) _Bool isReply;
@property (readonly, copy) NSArray *references;
@property double dateReceivedAsTimeIntervalSince1970;
@property (readonly) NSDate *dateReceived;
@property double dateSentAsTimeIntervalSince1970;
@property (readonly) NSDate *dateSent;
@property double dateLastViewedAsTimeIntervalSince1970;
@property (readonly) NSDate *dateLastViewed;
@property (copy) NSString *subject;
@property unsigned long long subjectPrefixLength;
@property (readonly, copy) NSString *subjectIfAvailable;
@property (readonly, copy, nonatomic) NSString *subjectNotIncludingReAndFwdPrefix;
@property (copy) NSString *sender;
@property (readonly, copy) NSString *senderIfAvailable;
@property (copy) NSArray *to;
@property (retain) NSSet *gmailLabels;
@property signed char recipientType;
@property (readonly, nonatomic) _Bool isThread;
@property (readonly, nonatomic) NSURL *imageArchiveURL;
@property (readonly, copy, nonatomic) NSDictionary *remoteAttachments;
@property (readonly, nonatomic) int colorForSort;
@property (readonly, nonatomic) unsigned int messageFlags;
@property (readonly, nonatomic) unsigned long long messageSize;
@property (readonly, nonatomic) unsigned long long numberOfAttachments;
@property (readonly, nonatomic) id <ICNFMCMailbox> mailbox;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;
+ (long long)displayablePriorityForPriority:(long long)priority;
+ (id)forwardedMessagePrefixWithSpacer:(_Bool)spacer;
+ (_Bool)isMessageURLString:(id)urlstring;
+ (id)messageWithRFC822Data:(id)data sanitizeData:(_Bool)data;
+ (long long)validatePriority:(long long)priority;
+ (signed char)_messageTypeForMessageTypeKey:(id)key;
+ (id)messageTypeKeyForMessageType:(signed char)type;
+ (id)replyPrefixWithSpacer:(_Bool)spacer;
+ (id)unreadMessagesFromMessages:(id)messages;
+ (_Bool)allMessages:(id)messages areSameType:(signed char)type;
+ (_Bool)colorIsSetInMoreFlags:(struct { unsigned int x0:1; unsigned int x1:1; unsigned int x2:8; unsigned int x3:8; unsigned int x4:8; unsigned int x5:1; unsigned int x6:2; unsigned int x7:1; unsigned int x8:2; })flags;
+ (id)descriptionForType:(signed char)type plural:(_Bool)plural;
+ (id)messageWithRFC822Data:(id)data;
+ (id)sharedKeySetForSpotlightAttributes;
+ (unsigned char)subjectPrefixLengthUnknown;

/* instance methods */
- (void)setDataSource:(id)source;
- (id)init;
- (id)dataSource;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)addGmailLabels:(id)labels;
- (void)_setDateReceivedFromHeaders:(id)headers;
- (id)bodyDataFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (id)headerDataFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)loadCachedHeaderValuesFromHeaders:(id)headers type:(signed char)type;
- (id)primitiveDataSource;
- (id)rawSourceFromHeaders:(id)headers body:(id)body;
- (void)removeGmailLabels:(id)labels;
- (void)setColor:(id)color hasBeenEvaluated:(_Bool)evaluated flags:(unsigned int)flags mask:(unsigned int)mask;
- (void)setMessageFlags:(unsigned int)flags mask:(unsigned int)mask;
- (void)setPrimitiveColor:(id)color;
- (void)setPrimitiveColor:(id)color hasBeenEvaluated:(_Bool)evaluated flags:(unsigned int)flags mask:(unsigned int)mask;
- (void)setPrimitiveColorHasBeenEvaluated:(_Bool)evaluated;
- (void)setPrimitiveMessageFlags:(unsigned int)flags mask:(unsigned int)mask;
- (void)_setDateSentFromHeaders:(id)headers;
- (void)setNumberOfAttachments:(unsigned int)attachments isSigned:(_Bool)_signed isEncrypted:(_Bool)encrypted;
- (void)setPriorityFromHeaders:(id)headers;
- (void)forceSetAttachmentInfoFromBody:(id)body;
- (id)_URLFetchIfNotAvailable:(_Bool)available;
- (void)_cacheHeaderDataIfPossible:(id)possible;
- (void)_cacheHeadersIfPossible:(id)possible;
- (void)_cacheMessageBodyDataIfPossible:(id)possible;
- (void)_cacheMessageBodyIfPossible:(id)possible;
- (void)_calculateAttachmentInfoFromBody:(id)body;
- (id)_newDateFromDateHeaderInHeaders:(id)headers;
- (id)_newDateFromHeader:(id)header inHeaders:(id)headers;
- (id)_newDateFromReceivedHeadersInHeaders:(id)headers;
- (id)attachmentNamesIfAvailable;
- (void)cacheBodyAndHeader;
- (id)cachedHeaderData;
- (id)cachedHeaders;
- (id)cachedMessageBody;
- (id)cachedMessageBodyData;
- (_Bool)calculateAttachmentInfoFromBody:(id)body numberOfAttachments:(unsigned int *)attachments isSigned:(_Bool *)_signed isEncrypted:(_Bool *)encrypted;
- (_Bool)calculateAttachmentInfoFromBody:(id)body numberOfAttachments:(unsigned int *)attachments isSigned:(_Bool *)_signed isEncrypted:(_Bool *)encrypted force:(_Bool)force;
- (id)dataForMimePart:(id)part;
- (_Bool)hasCachedDataForMimePart:(id)part;
- (id)messageBodyFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (id)messageBodyIfAvailableUpdatingFlags:(_Bool)flags;
- (id)messageBodyUpdatingFlags:(_Bool)flags;
- (id)messageDataIncludingFromSpace:(_Bool)space;
- (id)messageDataIncludingFromSpace:(_Bool)space newDocumentID:(id)id;
- (id)rawInReplyToHeaderDigest;
- (id)rawMessageIDHeaderDigest;
- (void)renderBody:(id)body;
- (void)renderHeaders:(id)headers;
- (void)renderString:(id)string;
- (void)setAttachmentFilenames:(id)filenames;
- (void)setAttachmentInfoFromBody:(id)body;
- (void)setAttachmentInfoFromBody:(id)body forced:(_Bool)forced;
- (void)setMessageInfo:(id)info subjectPrefixLength:(unsigned char)length to:(id)to sender:(id)sender type:(signed char)type dateReceivedTimeIntervalSince1970:(double)since1970 dateSentTimeIntervalSince1970:(double)since1970 messageIDHeaderDigest:(id)digest inReplyToHeaderDigest:(id)digest dateLastViewedTimeIntervalSince1970:(double)since1970;
- (void)setMessageInfoFromMessage:(id)message;
- (id)spotlightAttributesIncludingText:(_Bool)text includingAdditionalAttributesForCoreSpotlight:(_Bool)spotlight;
- (id)stringForIndexingUpdatingBodyFlags:(_Bool)flags;
- (id)stringForJunk:(id)junk;
- (id)stringValueRenderMode:(long long)mode updateBodyFlags:(_Bool)flags junkRecorder:(id)recorder bodyOnly:(_Bool)only;
- (void)uncacheBodyAndHeader;
- (void)unlockedSetInReplyToHeaderDigest:(id)digest;
- (void)unlockedSetMessageIDHeaderDigest:(id)digest;

@end


@interface ICNFMCRemoteMessage : ICNFMCMessage

@property (nonatomic) struct { unsigned int x0:27; unsigned int x1:1; unsigned int x2:1; unsigned int x3:1; unsigned int x4:1; unsigned int x5:1; } remoteFlags;
@property (nonatomic) _Bool isPartial;
@property (nonatomic) _Bool partsHaveBeenCached;
@property (nonatomic) _Bool hasTemporaryUid;
@property (nonatomic) unsigned long long messageSize;

/* instance methods */
- (id)initWithSize:(unsigned long long)size;

@end


@interface ICNFIMAPMessage : ICNFMCRemoteMessage <ICNFIMAPMessage>

@property (readonly, nonatomic) id <ICNFIMAPAccount> account;
@property (nonatomic) unsigned int uid;
@property (readonly, copy, nonatomic) NSString *messageID;
@property _Bool isPartial;
@property _Bool partsHaveBeenCached;
@property _Bool hasTemporaryUid;
@property (readonly) struct { unsigned int x0:27; unsigned int x1:1; unsigned int x2:1; unsigned int x3:1; unsigned int x4:1; unsigned int x5:1; } remoteFlags;
@property (readonly) unsigned long long messageSize;
@property (readonly, copy) NSString *subject;
@property (readonly, copy) NSDate *dateReceived;
@property (readonly, copy, nonatomic) NSString *mailboxName;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (void)initialize;

/* instance methods */
- (void)setDataSource:(id)source;
- (id)dataSource;
- (id)remoteID;
- (_Bool)isMessageContentLocallyAvailable;
- (id)initWithFlags:(unsigned int)flags size:(unsigned long long)size uid:(unsigned int)uid;
- (id)remoteMailboxURLString;
- (id)originalMailboxURLString;

@end


@interface ICNFIMAPMessageDetails : NSObject

@property (nonatomic) unsigned int messageFlags;
@property (nonatomic) unsigned int uid;
@property (nonatomic) _Bool isInvalid;

/* class methods */
+ (id)newMessageDetailsWithPersistentIDType:(signed char)idtype;
+ (id)searchDetails:(id)details forUid:(unsigned int)uid skippingUid:(unsigned int)uid;

/* instance methods */
- (id)description;
- (id)init;

@end


@interface ICNFIMAPMessageDownload : ICNFIMAPCompoundDownload

@property (retain) ICNFMCMimePart *topLevelPart;
@property (retain) id <ICNFIMAPMessage> message;
@property _Bool allowsPartialDownloads;
@property _Bool writesCacheFile;

/* instance methods */
- (_Bool)isComplete;
- (void)dealloc;
- (id)initWithMessage:(id)message;
- (id)data;
- (void)_addMimeSubdownloadsToPipeline:(id)pipeline withCache:(id)cache;
- (void)addCommandsToPipeline:(id)pipeline withCache:(id)cache;
- (id)createCopy;
- (void)handleFetchResult:(id)result;
- (void)processResults;

@end


@interface ICNFIMAPMessageProxy : ICNFMCManagedObjectProxy <ICNFIMAPMessage, ICNFIMAPPersistedMessage>

@property (nonatomic) unsigned int uid;
@property (readonly, copy, nonatomic) NSString *messageID;
@property _Bool isPartial;
@property _Bool partsHaveBeenCached;
@property _Bool hasTemporaryUid;
@property (readonly) struct { unsigned int x0:27; unsigned int x1:1; unsigned int x2:1; unsigned int x3:1; unsigned int x4:1; unsigned int x5:1; } remoteFlags;
@property (readonly) unsigned long long messageSize;
@property (readonly, copy) NSString *subject;
@property (readonly, copy) NSDate *dateReceived;
@property (readonly, copy, nonatomic) NSString *mailboxName;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (readonly, nonatomic) signed char persistentIDType;
@property (copy) NSString *remoteID;
@property (readonly, nonatomic) long long libraryID;
@property (readonly, nonatomic) NSManagedObjectID *managedObjectID;

/* instance methods */
- (id)initWithManagedObject:(id)object;
- (void)setData:(id)data isPartial:(_Bool)partial;
- (void)appendData:(id)data part:(id)part;

@end


@interface ICNFIMAPMessageWithCache : ICNFIMAPMessage

@property (copy) NSData *messageData;

/* instance methods */
- (id)headers;
- (void)setHeaders:(id)headers;
- (id)headersIfAvailable;
- (_Bool)isMessageContentLocallyAvailable;
- (id)bodyDataFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (id)headerDataFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (id)messageDataIncludingFromSpace:(_Bool)space newDocumentID:(id)id;

@end


@interface ICNFMCMimeConverter : NSObject

/* class methods */
+ (id)headersFromPersistedMessage:(id)message withMessageType:(signed char)type;
+ (id)messageFromPersistedMessage:(id)message withMessageType:(signed char)type;
+ (void)updatePersistedMessage:(id)message fromMessage:(id)message;

@end


@interface ICNFIMAPMimeConverter : ICNFMCMimeConverter

/* class methods */
+ (id)headersFromPersistedMessage:(id)message withMessageType:(signed char)type;
+ (id)messageFromPersistedMessage:(id)message withMessageType:(signed char)type;
+ (void)updatePersistedMessage:(id)message fromMessage:(id)message;

@end


@interface ICNFIMAPModificationSequenceFetchResult : ICNFIMAPFetchResult

@property (nonatomic) unsigned long long modificationSequence;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPNamespace : NSObject

@property (copy, nonatomic) NSString *prefix;
@property (copy, nonatomic) NSString *separator;
@property (copy, nonatomic) NSArray *extensions;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPNamespaceExtension : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSArray *flags;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPNamespaceResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSArray *privateNamespaces;
@property (copy, nonatomic) NSArray *publicNamespaces;
@property (copy, nonatomic) NSArray *sharedNamespaces;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPNoResponse : ICNFIMAPBasicResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPOKResponse : ICNFIMAPBasicResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPOtherResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSString *responseName;
@property (copy, nonatomic) NSArray *parameters;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPParseContext : NSObject

@property (retain, nonatomic) ICNFIMAPConnection *connection;
@property (retain, nonatomic) ICNFIMAPResponse *response;
@property (retain, nonatomic) NSData *data;
@property (nonatomic) _Bool invalid;

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)init;
- (_Bool)_consumeSpaces;
- (void)_createResponseUsingMask:(unsigned long long)mask;
- (void)_createResponseWithoutTag:(_Bool)tag;
- (_Bool)_modificationSequenceValue:(unsigned long long *)value;
- (id)_newArray;
- (id)_newArrayAllowingNulls:(_Bool)nulls;
- (id)_newAsString;
- (id)_newBodyData:(_Bool)data;
- (id)_newBodystructure;
- (id)_newCapabilityArray;
- (id)_newFlagsSet;
- (id)_newIDDictionary;
- (id)_newIMAPAtom:(long long)imapatom;
- (id)_newLiteral;
- (id)_newLiteralStringUsingCaseOption:(long long)option;
- (id)_newMailboxWithSeparatorChar:(id)_char;
- (id)_newMessageSetWithoutStar;
- (id)_newModificationSequenceValue;
- (id)_newNamespace;
- (id)_newNamespaceExtension;
- (id)_newNstring;
- (id)_newNumber;
- (id)_newQuotedStringUsingCaseOption:(long long)option;
- (id)_newStatusAttList;
- (id)_newStringUsingCaseOption:(long long)option;
- (id)_newStringWithSingleQuotedCharacter;
- (_Bool)_number:(unsigned int *)_number;
- (void)_parseBasicResponse;
- (void)_parseCapabilityResponse;
- (void)_parseError:(id)error;
- (void)_parseFetchResponse;
- (void)_parseFlagsResponse;
- (void)_parseIDResponse;
- (void)_parseListResponse;
- (void)_parseNamespaceResponse;
- (void)_parseOtherResponse;
- (void)_parseQuotaResponse;
- (void)_parseQuotaRootResponse;
- (void)_parseSearchResponse;
- (void)_parseStatusResponse;
- (void)_parseWarning:(id)warning;
- (id)initWithConnection:(id)connection data:(id)data;
- (id)parseIntoResponse;

@end


@interface ICNFIMAPPreauthResponse : ICNFIMAPBasicResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPQuotaResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSString *quotaRootName;
@property (copy, nonatomic) NSArray *quotas;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPQuotaRoot : NSObject

@property (copy) NSString *name;
@property (retain) ICNFMCQuotaUsage *usage;

/* instance methods */
- (id)description;
- (id)init;
- (id)initWithName:(id)name;
- (void)setUsageFromResponse:(id)response;

@end


@interface ICNFIMAPQuotaRootResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSString *mailboxName;
@property (copy, nonatomic) NSArray *quotaRootNames;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPRFC822SizeFetchResult : ICNFIMAPFetchResult

@property (nonatomic) unsigned int messageSize;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPRecentResponse : ICNFIMAPNumericResponse

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (const char *)_responseName;

@end


@interface ICNFIMAPSearchResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSArray *searchResults;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)debugDescription;
- (id)description;

@end


@interface ICNFIMAPSimpleDownload : ICNFIMAPDownload

@property (readonly, nonatomic) unsigned int expectedLength;
@property (nonatomic) _Bool isComplete;
@property (retain) NSString *partSectionSpecifier;
@property long long textSectionSpecifier;

/* instance methods */
- (void)setError:(id)error;
- (id)error;
- (id)description;
- (id)data;
- (unsigned int)bytesFetched;
- (void)addCommandsToPipeline:(id)pipeline withCache:(id)cache;
- (id)createCopy;
- (void)handleFetchResult:(id)result;
- (id)initWithUid:(unsigned int)uid;
- (id)initWithUid:(unsigned int)uid partSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier estimatedLength:(unsigned int)length;
- (id)initWithUid:(unsigned int)uid partSectionSpecifier:(id)specifier textSectionSpecifier:(long long)specifier length:(unsigned int)length;
- (void)processResults;

@end


@interface ICNFIMAPStatusResponse : ICNFIMAPResponse

@property (copy, nonatomic) NSString *mailboxName;
@property (copy, nonatomic) NSDictionary *statusEntries;

/* class methods */
+ (_Bool)handlesResponseWithName:(const char *)name ofLength:(unsigned long long)length;

/* instance methods */
- (id)description;

@end


@interface ICNFIMAPUidFetchResult : ICNFIMAPFetchResult

@property (nonatomic) unsigned int uid;

/* instance methods */
- (id)description;

@end


@interface ICNFMCActivityMonitor : NSObject <NSMachPortDelegate>

@property (copy) NSMachPort *cancelPort;
@property (nonatomic) _Bool canBeCancelled;
@property (nonatomic) _Bool shouldCancel;
@property (retain) NSInvocation *cancelInvocation;
@property (retain) id <ICNFMCActivityTarget> activityTarget;
@property long long activityType;
@property (nonatomic) unsigned char priority;
@property (copy) NSString *itemDescription;
@property (copy) NSString *taskName;
@property (copy) NSString *statusMessage;
@property (readonly, copy) NSString *taskDescriptionString;
@property (readonly, nonatomic) _Bool isActive;
@property (nonatomic) _Bool isProgressing;
@property (nonatomic) unsigned long long itemsDone;
@property (nonatomic) unsigned long long itemsTotal;
@property (nonatomic) double itemValue;
@property (nonatomic) double itemMinValue;
@property (nonatomic) double itemMaxValue;
@property (nonatomic) double doneValue;
@property double percentDone;
@property (readonly, nonatomic) double unifiedFractionDone;
@property (retain) ICNFMCError *error;
@property _Bool shouldPromptUserOnTermination;
@property (readonly, copy, nonatomic) NSArray *activityTargets;
@property (readonly, nonatomic) int changeCount;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)currentMonitor;
+ (_Bool)automaticallyNotifiesObserversOfCanBeCancelled;
+ (_Bool)automaticallyNotifiesObserversOfIsProgressing;
+ (_Bool)automaticallyNotifiesObserversOfPercentDone;
+ (_Bool)automaticallyNotifiesObserversOfStatusMessage;
+ (id)currentMonitorIfExists;
+ (double)determinateProgress;
+ (void)setCurrentMonitor:(id)monitor;

/* instance methods */
- (void)setDelegate:(id)delegate;
- (void)setItem:(id)item;
- (void)_didChange;
- (id)init;
- (void)dealloc;
- (void)cancel;
- (void)handlePortMessage:(id)message;
- (long long)acquireExclusiveAccessKey;
- (void)incrementItemValue:(double)value;
- (void)incrementItemsDone:(unsigned long long)done;
- (void)incrementItemsTotal:(unsigned long long)total;
- (void)relinquishExclusiveAccessKey:(long long)key;
- (void)setItemFudgeFactor:(unsigned long long)factor;
- (void)setItemIndeterminateValue;
- (void)setPercentDone:(double)done withKey:(long long)key;
- (void)setStatusMessage:(id)message percentDone:(double)done;
- (void)setStatusMessage:(id)message percentDone:(double)done withKey:(long long)key;
- (void)setStatusMessage:(id)message withKey:(long long)key;
- (void)updateDoneValue;
- (id)activityDescription;
- (void)addActivityTarget:(id)target;
- (void)addSubMonitor:(id)monitor;
- (void)beginProgressFor:(long long)_for;
- (void)markCompleted:(_Bool)completed;
- (void)postActivityFinished;
- (void)postActivityStarting;
- (void)removeActivityTarget:(id)target;
- (void)removeSubMonitor:(id)monitor;
- (void)resetActivityType;
- (void)resetItemValue;
- (void)setPrimaryTarget:(id)target;

@end


@interface ICNFMCAddressManager : NSObject

/* class methods */
+ (id)myEmailAddress;

@end


@interface ICNFMCAuthScheme : NSObject

@property (readonly, copy) NSSet *supportedSaslMechanisms;
@property (readonly, nonatomic) _Bool requiresUsername;
@property (readonly, nonatomic) _Bool requiresPassword;

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)knownSchemes;
+ (id)schemeWithName:(id)name;
+ (id)schemeWithApplescriptScheme:(unsigned int)scheme;
+ (id)schemeWithAccountInfo:(id)info;

@end


@interface ICNFMCApopAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)apopAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;

@end


@interface ICNFMCAppleTokenAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)appleTokenAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (_Bool)requiresPassword;
- (_Bool)requiresUsername;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCArchiveFileWrapper : NSFileWrapper

@property (retain, nonatomic) NSData *archiveData;
@property (nonatomic) long long archiveType;
@property (readonly, nonatomic) NSFileWrapper *realFileWrapper;

/* instance methods */
- (_Bool)isDirectory;
- (id)initWithURL:(id)url options:(unsigned long long)options error:(id *)error;
- (id)serializedRepresentation;
- (id)initWithSerializedRepresentation:(id)representation;
- (void)encodeWithCoder:(id)coder;
- (_Bool)isSymbolicLink;
- (_Bool)isRegularFile;
- (id)initWithCoder:(id)coder;
- (id)addFileWrapper:(id)wrapper;
- (id)addRegularFileWithContents:(id)contents preferredFilename:(id)filename;
- (id)fileWrappers;
- (id)initDirectoryWithFileWrappers:(id)wrappers;
- (id)initRegularFileWithContents:(id)contents;
- (id)initSymbolicLinkWithDestinationURL:(id)url;
- (id)keyForFileWrapper:(id)wrapper;
- (id)preferredFilename;
- (void)removeFileWrapper:(id)wrapper;
- (_Bool)writeToURL:(id)url options:(unsigned long long)options originalContentsURL:(id)url error:(id *)error;
- (unsigned long long)approximateSize;
- (id)initWithData:(id)data archiveType:(long long)type;
- (void)_archiveFileWrapperCommonInit;
- (void)getCompressedData:(id *)data archiveType:(long long *)type;
- (id)initWithURL:(id)url options:(unsigned long long)options compressionLevel:(long long)level error:(id *)error;

@end


@interface ICNFMCAttachment : NSObject <NSURLSessionDownloadDelegate>

@property (nonatomic) unsigned long long approximateSize;
@property (retain, nonatomic) NSData *currentData;
@property (nonatomic) struct CGSize resizedImageSize;
@property (retain, nonatomic) NSBlockOperation *fileReadingOperation;
@property (retain, nonatomic) NSFileWrapper *fileWrapper;
@property (nonatomic) unsigned short finderFlags;
@property (nonatomic) _Bool hasResourceForkData;
@property (retain, nonatomic) NSImage *iconImage;
@property (nonatomic) long long imageByteCountFromHeaders;
@property (nonatomic) struct CGSize imageSizeFromHeaders;
@property (retain, nonatomic) ICNFMCMimeBody *mimeBody;
@property (retain, nonatomic) NSData *originalData;
@property (copy, nonatomic) NSString *originalFilename;
@property (retain, nonatomic) StationeryCompositeImage *stationeryCompositeImage;
@property (readonly, nonatomic) NSPort *downloadPort;
@property (readonly, nonatomic) ICNFMCAttachment *attachmentWithCurrentData;
@property (nonatomic) _Bool isAutoArchiveAttachment;
@property (readonly, nonatomic) _Bool isRemotelyAccessed;
@property (readonly, copy, nonatomic) NSString *remoteAccessMimeType;
@property (readonly, nonatomic) _Bool hasPendingBackgroundRead;
@property (readonly, nonatomic) _Bool isDataDownloaded;
@property (retain, nonatomic) NSProgress *downloadProgress;
@property (retain, nonatomic) NSDate *downloadURLExpiration;
@property (retain, nonatomic) NSError *downloadError;
@property (copy, nonatomic) NSString *cloudKitRecordName;
@property (nonatomic) _Bool isMailDropImageArchive;
@property (nonatomic) _Bool isMailDropImageThumbnail;
@property (nonatomic) _Bool isMailDropIndividualImage;
@property (retain, nonatomic) NSURL *remoteURL;
@property (retain, nonatomic) NSURL *downloadURL;
@property (retain, nonatomic) NSURL *downloadDirectory;
@property (copy, nonatomic) NSString *savedPath;
@property (retain, nonatomic) NSString *filenameForSaving;
@property (copy, nonatomic) NSString *filename;
@property (readonly, copy, nonatomic) NSString *filenameWithoutHiddenExtension;
@property (retain, nonatomic) NSNumber *filePermissions;
@property (retain, nonatomic) NSNumber *fileSize;
@property (readonly, nonatomic) _Bool isFullSize;
@property (retain, nonatomic) ICNFMCMimePart *mimePart;
@property (copy, nonatomic) NSString *messageID;
@property (copy, nonatomic) NSString *contentID;
@property (nonatomic) _Bool isUnreferencedAttachment;
@property (readonly, copy, nonatomic) NSString *typeIdentifier;
@property (copy, nonatomic) NSString *mimeType;
@property (nonatomic) unsigned int type;
@property (nonatomic) unsigned int creator;
@property (copy, nonatomic) NSString *extension;
@property (nonatomic) _Bool shouldHideExtension;
@property (copy, nonatomic) NSString *mailSpecialHandlingType;
@property (nonatomic) _Bool isPartOfStationery;
@property (readonly, nonatomic) _Bool isStationeryCompositeImage;
@property (copy, nonatomic) NSArray *whereFroms;
@property (copy, nonatomic) NSDictionary *quarantineProperties;
@property (readonly, nonatomic) _Bool couldConfuseWindowsClients;
@property (readonly, nonatomic) _Bool isVideoOrAudio;
@property (readonly, nonatomic) _Bool isPDF;
@property (nonatomic) _Bool isCalendarInvitation;
@property (readonly, nonatomic) _Bool isImage;
@property (readonly, nonatomic) _Bool isScalable;
@property (readonly, nonatomic) _Bool isDirectory;
@property (readonly, copy, nonatomic) NSString *symbolicLinkDestinationForFileWrapper;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)_backgroundFileReadingQueue;
+ (_Bool)automaticallyNotifiesObserversOfOriginalData;

/* instance methods */
- (void)URLSession:(id)urlsession downloadTask:(id)task didFinishDownloadingToURL:(id)url;
- (id)initWithData:(id)data;
- (void)URLSession:(id)urlsession task:(id)task didCompleteWithError:(id)error;
- (id)init;
- (void)dealloc;
- (void)URLSession:(id)urlsession downloadTask:(id)task didWriteData:(long long)data totalBytesWritten:(long long)written totalBytesExpectedToWrite:(long long)write;
- (id)initWithFileURL:(id)url;
- (id)initWithFileWrapper:(id)wrapper;
- (_Bool)_isExpired;
- (id)_privateImageMetadataDescriptors;
- (id)_freshFileWrapper;
- (void)_mcAttachmentCommonInit;
- (void)_setupFileWrapper:(id)wrapper;
- (id)appleDoubleDataWithFilename:(const char *)filename length:(unsigned long long)length;
- (id)appleSingleDataWithFilename:(const char *)filename length:(unsigned long long)length;
- (void)discardIconImage;
- (id)initWithMailInternalData:(id)data;
- (id)initWithRemoteURL:(id)url;
- (void)isImage:(_Bool *)image isPDF:(_Bool *)pdf bestMimeType:(id *)type;
- (void)revertToOriginalData;
- (void)setFileNameForResizedImage:(id)image;
- (void)_configureWithMimePart;
- (id)_dataWithCleanedImageMetadata;
- (void)_downloadFinished;
- (void)_finishedCoordinatedFileReadingWithURL:(id)url;
- (_Bool)_hasPrivateImageMetadata;
- (void)_setCurrentDataIfNil:(id)value;
- (void)_takeInfoFromMessageAttachment:(id)attachment saveOriginalData:(_Bool)data cleanImageMetadata:(_Bool)metadata;
- (unsigned long long)approximateSizeOfWrapper;
- (id)beginBackgroundFileReading;
- (_Bool)createEmptyAttachmentAtPath:(id)path;
- (id)dataForFetchLevel:(long long)level;
- (id)fileWrapperForFetchLevel:(long long)level;
- (id)getCompressedDataAndArchiveType:(long long *)type error:(id *)error;
- (id)initWithHeaderURL:(id)url;
- (id)initWithStationeryCompositeImage:(id)image;
- (void)setDataForResizedImage:(id)image;
- (void)setFromHeadersImageSize:(struct CGSize)size byteCount:(long long)count;
- (void)setSizeForResizedImage:(struct CGSize)image;
- (void)takeNewDataFromPath:(id)path;

@end


@interface ICNFMCAttachmentWrappingTextAttachment : NSTextAttachment

@property (readonly, nonatomic) ICNFMCAttachment *messageAttachment;

/* instance methods */
- (id)initWithFileWrapper:(id)wrapper;
- (id)initWithAttachment:(id)attachment;

@end


@interface ICNFMCByteSet : NSObject <NSCopying, NSMutableCopying>

/* class methods */
+ (id)asciiWhitespaceSet;
+ (id)ASCIIByteSet;
+ (id)nonASCIIByteSet;

/* instance methods */
- (id)initWithBytes:(const void *)bytes length:(unsigned long long)length;
- (id)initWithCString:(const char *)cstring;
- (id)initWithRange:(struct _NSRange)range;
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (_Bool)byteIsMember:(unsigned char)member;

@end


@interface ICNFMCCIDURLProtocol : NSURLProtocol

/* class methods */
+ (_Bool)canInitWithRequest:(id)request;
+ (id)canonicalRequestForRequest:(id)request;
+ (_Bool)requestIsCacheEquivalent:(id)equivalent toRequest:(id)request;
+ (void)registerDataProvider:(id)provider;
+ (void)unregisterDataProvider:(id)provider;

/* instance methods */
- (void)startLoading;
- (void)stopLoading;

@end


@interface ICNFMCCramMD5AuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)cramMd5AuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCDataScanner : NSObject

@property (readonly, nonatomic) NSData *data;
@property (nonatomic) unsigned long long scanLocation;
@property (readonly, nonatomic) _Bool isAtEnd;

/* class methods */
+ (id)scannerWithData:(id)data;

/* instance methods */
- (id)initWithData:(id)data;
- (id)init;
- (_Bool)scanInteger:(long long *)integer;
- (_Bool)scanUpToCString:(const char *)cstring intoData:(id *)data;
- (_Bool)_scanUpToBytes:(const void *)bytes length:(unsigned long long)length intoData:(id *)data;
- (_Bool)_scanBytes:(const void *)bytes length:(unsigned long long)length intoData:(id *)data;
- (_Bool)scanByte:(char *)byte;
- (_Bool)scanBytesFromSet:(id)set intoData:(id *)data;
- (_Bool)scanCString:(const char *)cstring intoData:(id *)data;
- (_Bool)scanData:(id)data intoData:(id *)data;
- (_Bool)scanUpToBytesFromSet:(id)set intoData:(id *)data;
- (_Bool)scanUpToData:(id)data intoData:(id *)data;

@end


@interface ICNFMCDateFormatterFactory : NSObject

/* class methods */
+ (id)newInternetMessageDateFormatter;
+ (id)newCommonInternetMessageDateFormatters;
+ (id)newIMAPDateFormatter;
+ (id)newUncommonInternetMessageDateFormatters;

@end


@interface ICNFMCDateParser : NSObject

/* class methods */
+ (id)dateFromInternetMessageDateString:(id)string;
+ (id)dateFromIMAPDateString:(id)string;
+ (id)_commonDateFormatters;
+ (id)_dateFromString:(id)string imapFirst:(_Bool)first;
+ (id)_dateStringByStrippingCommentsFromString:(id)string;
+ (id)_fallbackDateFormaters;
+ (id)_imapDateFormatter;

@end


@interface ICNFMCError : NSError <NSAlertDelegate>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)errorWithDomain:(id)domain code:(long long)code localizedDescription:(id)description;
+ (id)errorWithException:(id)exception;
+ (id)messageTraceableStringForError:(id)error;
+ (id)errorWithDomain:(id)domain code:(long long)code localizedDescription:(id)description title:(id)title helpTag:(id)tag userInfo:(id)info;

/* instance methods */
- (void)setLocalizedDescription:(id)description;
- (void)setUserInfoObject:(id)object forKey:(id)key;
- (id)initWithError:(id)error;
- (id)userInfo;
- (id)localizedDescription;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)helpAnchor;
- (void)setShortDescription:(id)description;
- (_Bool)alertShowHelp:(id)help;
- (id)ic_moreInfo;
- (id)ic_shortDescription;
- (void)setHelpTag:(id)tag;
- (void)setMoreInfo:(id)info;
- (void)useGenericDescription:(id)description;

@end


@interface ICNFMCExternalAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)externalAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (_Bool)requiresPassword;
- (_Bool)requiresUsername;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCFileTypeInfo : NSObject

@property (copy, nonatomic) NSString *mimeType;
@property (copy, nonatomic) NSString *pathExtension;
@property (nonatomic) unsigned int osType;
@property (readonly, copy, nonatomic) NSArray *pedigree;

/* instance methods */
- (id)description;
- (_Bool)getTypeInfoForDesiredFields:(unsigned long long)fields;
- (void)_getTypeInfoFromFallbackFields:(unsigned long long *)fields;
- (void)_getTypeInfoBasedOnFields:(unsigned long long *)fields inputClass:(struct __CFString *)_class inputValue:(struct __CFString *)value;

@end


@interface ICNFMCGssapiAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)gssApiAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (_Bool)requiresPassword;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCISPAccountSettingsManager : NSObject

/* class methods */
+ (void)initialize;
+ (id)_accountInformationStringForKey:(id)key localizedKey:(id)key domain:(id)domain;
+ (id)_alwaysPersistedKeys;
+ (_Bool)ispAccountInformationAvailableForDomain:(id)domain;
+ (id)ispBrandNameForDomain:(id)domain;
+ (id)ispSubscriptionURLForDomain:(id)domain;
+ (id)ispSubscriptionURLLabelForDomain:(id)domain;
+ (id)ispSupportURLForDomain:(id)domain;
+ (id)ispSupportURLLabelForDomain:(id)domain;
+ (id)locallyInstalledSettings;
+ (id)onlineDatabaseSettings;

/* instance methods */
- (void)emptyCache;
- (void)dealloc;
- (id)_deliveryAccountsSettingsForDomain:(id)domain fetchIfNecessary:(_Bool)necessary;
- (_Bool)_getAccountIsReceivingAccount:(_Bool *)account isDeliveryAccount:(_Bool *)account fromAccountSettings:(id)settings;
- (void)_loadISPAccountsIfNecessary;
- (void)_loadISPPlist:(id)ispplist bundle:(id)bundle path:(id)path;
- (void)_loadISPPlistsAtPath:(id)path;
- (_Bool)_persistISPPlist:(id)ispplist;
- (id)_persistanceFolderName;
- (id)_persistantAccountSettings:(id)settings;
- (id)_persistantISPAccountSettings:(id)settings;
- (id)_receivingAccountSettingsForDomain:(id)domain fetchIfNecessary:(_Bool)necessary;
- (_Bool)_shouldVerifyLoadedISPPlist;
- (void)_unloadISPAccounts;
- (id)deliveryAccountsSettingsForDomain:(id)domain;
- (id)receivingAccountSettingsForDomain:(id)domain;

@end


@interface ICNFMCImageJunkMetadata : NSObject

@property (nonatomic) long long type;
@property (nonatomic) struct CGSize size;
@property (nonatomic) unsigned long long frameCount;
@property (nonatomic) unsigned long long pixelCount;
@property (nonatomic) unsigned long long byteCount;
@property (nonatomic) double density;
@property (nonatomic) _Bool isAnimated;
@property (readonly, nonatomic) long long sizeCategory;
@property (readonly, nonatomic) long long densityCategory;

/* class methods */
+ (id)lsmMarkerForImageDensityCategory:(long long)category;
+ (id)lsmMarkerForImageSizeCategory:(long long)category;
+ (id)stringForImageType:(long long)type;

/* instance methods */
- (id)description;
- (id)init;
- (id)initWithImage:(id)image name:(id)name type:(long long)type;
- (void)computeDensity;

@end


@interface ICNFMCInvocationQueue : NSOperationQueue

@property (readonly, nonatomic) NSOperationQueue *secondaryQueue;

/* class methods */
+ (_Bool)didCancelAllMonitoredItems;
+ (void)cancelAllMonitoredItems;

/* instance methods */
- (id)operations;
- (unsigned long long)operationCount;
- (void)cancelAllOperations;
- (id)init;
- (void)dealloc;
- (void)observeValueForKeyPath:(id)path ofObject:(id)object change:(id)change context:(void *)context;
- (id)initWithMaxConcurrentOperationCount:(long long)count;
- (void)waitUntilAllOperationsAreFinished;
- (void)addInvocation:(id)invocation;
- (void)runInvocationOnQueueSynchronously:(id)synchronously;
- (id)_newOperationWithInvocation:(id)invocation;
- (id)initWithSecondaryQueue:(_Bool)queue;

@end


@interface ICNFMCJunkRecorder : NSObject

@property _Bool isShort;
@property _Bool isSigned;
@property unsigned long long imageCount;
@property unsigned long long characterCount;
@property double imageToTextRatio;
@property double lsmScore;
@property (readonly, copy) NSDictionary *imageInfos;

/* instance methods */
- (id)description;
- (id)init;
- (void)setImageJunkInfo:(id)info forKey:(id)key;

@end


@interface ICNFMCKeychainManager : NSObject

/* class methods */
+ (void)initialize;
+ (struct __SecCertificate *)copyEncryptionCertificateForAddress:(id)address;
+ (struct __SecPolicy *)createSMIMEPolicyForAddress:(id)address keyUsage:(void *)usage;
+ (id)sessionTrustedCertificatesForHost:(id)host;
+ (void)setSessionTrustedCertificates:(id)certificates forHost:(id)host;
+ (id)_copyTlsClientIdentities;
+ (_Bool)canEncryptMessagesToAddress:(id)address;
+ (_Bool)canEncryptMessagesToAddresses:(id)addresses sender:(id)sender;
+ (_Bool)canSignMessagesFromAddress:(id)address;
+ (_Bool)configureTLSCertificatesPopUp:(id)up usingPersistentReference:(_Bool)reference withOldIdentity:(id)identity newIdentity:(id *)identity;
+ (struct __SecIdentity *)copySigningIdentityForAddress:(id)address;
+ (id)passwordForHost:(id)host username:(id)username port:(long long)port protocol:(void *)protocol;
+ (id)passwordForServiceName:(id)name accountName:(id)name;
+ (void)removePasswordForHost:(id)host username:(id)username port:(long long)port protocol:(void *)protocol;
+ (void)removePasswordForServiceName:(id)name accountName:(id)name;
+ (void)setPassword:(id)password forServiceName:(id)name accountName:(id)name;

@end


@interface ICNFMCLargeAttachmentFileWrapper : NSFileWrapper

@property (retain, nonatomic) NSURL *fileToCopy;
@property (nonatomic) unsigned long long approximateSize;

/* class methods */
+ (id)ic_fileWrapperWithDictionaryRepresentation:(id)representation;
+ (id)fileWrapperWithURL:(id)url andContentID:(id)id;
+ (id)localAttachmentFilesDirectory;

/* instance methods */
- (id)symbolicLinkDestinationURL;
- (id)ic_archivedDataWithPartNumber:(id)number;
- (_Bool)isALargeAttachment;

@end


@interface ICNFMCMailCoreFramework : NSObject

/* class methods */
+ (void)setUserAgent:(id)agent;
+ (id)userAgent;
+ (id)bundle;
+ (_Bool)isRunningInMail;
+ (_Bool)isRunningInSpotlightImporter;
+ (void)setRunningInSpotlightImporter:(_Bool)importer;
+ (int)uniqueIDForMessageURL;

@end


@interface ICNFMCManagedObjectContextManager : NSObject

@property (readonly, weak, nonatomic) NSManagedObjectContext *context;

/* class methods */
+ (void)attachContextManagerWithOptions:(unsigned long long)options toContext:(id)context;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)_contextDidSave:(id)save;
- (id)initWithOptions:(unsigned long long)options context:(id)context;

@end


@interface ICNFMCMemoryDataSource : NSObject <ICNFMCMessageDataSource>

@property (readonly, nonatomic) NSData *data;
@property (readonly, copy, nonatomic) NSData *separator;
@property (readonly, nonatomic) ICNFMCMessage *message;
@property (readonly) _Bool isReadOnly;
@property (readonly, nonatomic) _Bool supportsSnippets;
@property (readonly, nonatomic) _Bool canCompact;
@property (readonly, nonatomic) id <ICNFMCMailAccount> account;
@property (readonly, nonatomic) id <ICNFMCMailbox> mailbox;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithData:(id)data;
- (void)doCompact;
- (void)saveSnippetsForMessages:(id)messages;
- (id)async_setFlagsFromDictionary:(id)dictionary forMessages:(id)messages;
- (id)init;
- (void)invalidateMessage:(id)message;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)deleteMessages:(id)messages moveToTrash:(_Bool)trash;
- (id)messageForMessageID:(id)id;
- (id)attachmentsDirectoryForMessage:(id)message;
- (id)bodyDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)flushAllCaches;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)messageFlagsDidChange:(id)change flags:(id)flags;
- (void)setColor:(id)color highlightTextOnly:(_Bool)only forMessages:(id)messages;
- (void)setNumberOfAttachments:(unsigned int)attachments isSigned:(_Bool)_signed isEncrypted:(_Bool)encrypted forMessage:(id)message;
- (id)snippetsForMessages:(id)messages;
- (id)uniquedString:(id)string;
- (id)async_setFlagWithKey:(id)key state:(_Bool)state forMessages:(id)messages;
- (id)async_setJunkMailLevel:(long long)level forMessages:(id)messages trainJunkMailDatabase:(_Bool)database userRecorded:(_Bool)recorded;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags;
- (id)bodyForMessage:(id)message fetchIfNotAvailable:(_Bool)available updateFlags:(_Bool)flags allowPartial:(_Bool)partial;
- (id)dataForMimePart:(id)part;
- (id)fullBodyDataForMessage:(id)message;
- (id)fullBodyDataForMessage:(id)message andHeaderDataIfReadilyAvailable:(id *)available fetchIfNotAvailable:(_Bool)available;
- (_Bool)hasCachedDataForMimePart:(id)part;
- (id)headerDataForMessage:(id)message;
- (id)headerDataForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)headersForMessage:(id)message;
- (id)headersForMessage:(id)message fetchIfNotAvailable:(_Bool)available;
- (id)routeMessages:(id)messages fetchingBodies:(_Bool)bodies messagesNeedingBodies:(id)bodies;
- (void)sendResponseType:(signed char)type forMeetingMessage:(id)message;
- (void)undeleteMessages:(id)messages;
- (id)undeleteMessages:(id)messages movedToStore:(id)store newMessageIDs:(id)ids;

@end


@interface ICNFMCMessageBody : NSObject

@property long long messageID;
@property (weak) ICNFMCMessage *message;
@property (readonly, copy, nonatomic) NSAttributedString *attributedString;
@property _Bool hideCalendarMimePart;
@property (readonly, nonatomic) _Bool isHTML;
@property (readonly, nonatomic) ICNFMCMimePart *textHtmlPart;
@property (readonly, nonatomic) WebArchive *webArchive;
@property (readonly, nonatomic) _Bool isRich;
@property (readonly, copy, nonatomic) NSArray *attachments;
@property (readonly, copy, nonatomic) NSArray *attachmentFilenames;

/* instance methods */
- (id)init;
- (id)attachmentsWithContext:(id)context;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (unsigned int)numberOfAttachmentsWithFilenames:(id)filenames isSigned:(_Bool *)_signed encrypted:(_Bool *)encrypted numberOfTNEFAttachments:(unsigned int *)tnefattachments;
- (void)renderString:(id)string;

@end


@interface ICNFMCMessageGenerator : NSObject

@property (nonatomic) unsigned long long preferredEncoding;
@property (nonatomic) unsigned long long encodingHint;
@property (nonatomic) _Bool createsMimeAlternatives;
@property (nonatomic) _Bool createsPlainTextOnly;
@property (nonatomic) _Bool alwaysCreatesRichText;
@property (nonatomic) _Bool allows8BitMimeParts;
@property (nonatomic) _Bool allowsBinaryMimeParts;
@property (nonatomic) _Bool allowsAppleDoubleAttachments;
@property (nonatomic) _Bool signsOutput;
@property (nonatomic) _Bool encryptsOutput;

/* class methods */
+ (id)domainHintForResentIDFromHeaders:(id)headers hasResentFromHeaders:(_Bool *)headers;

/* instance methods */
- (id)init;
- (id)newMessageWithBodyData:(id)data headers:(id)headers;
- (_Bool)appendDataForMimePart:(id)part toData:(id)data withPartData:(id)data;
- (id)newMessageWithHtmlString:(id)string plainTextAlternative:(id)alternative otherHtmlStringsAndAttachments:(id)attachments headers:(id)headers;
- (id)_newPartForAttachment:(id)attachment partData:(id)data;
- (_Bool)_encodeDataForMimePart:(id)part withPartData:(id)data;
- (id)_hfsFilenameDataWithFilename:(id)filename partData:(id)data;
- (id)_newDataForMimePart:(id)part withPartData:(id)data;
- (id)_newMimePartWithAttributedString:(id)string partData:(id)data outputRich:(_Bool)rich;
- (id)_newMimePartWithWebResource:(id)resource partData:(id)data seenURLStrings:(id)urlstrings;
- (id)_newPartAndDataForString:(id)string charset:(id)charset subtype:(id)subtype partData:(id)data;
- (id)_newPartForDirectoryAttachment:(id)attachment partData:(id)data;
- (id)_newPlainTextPartWithAttributedString:(id)string partData:(id)data;
- (id)_newRFC2047NameParameterDataForMimePart:(id)part;
- (void)_recursivelyAddSubresourcesFromArchive:(id)archive toArray:(id)array;
- (void)_setMimeTypeFromAttachment:(id)attachment onMimePart:(id)part filename:(id *)filename;
- (void)setShouldMarkNonresizableAttachmentData:(_Bool)data;
- (void)_appendHeadersForMimePart:(id)part toHeaders:(id)headers;
- (id)_newOutgoingMessage;
- (id)_newOutgoingMessageFromTopLevelMimePart:(id)part topLevelHeaders:(id)headers withPartData:(id)data;
- (id)_newPartForStationeryCompositeImage:(id)image partData:(id)data;
- (unsigned long long)_preferredEncodingUsingHintIfNecessary;
- (id)newMessageWithHtmlString:(id)string attachments:(id)attachments headers:(id)headers;
- (void)setShouldConvertCompositeImages:(_Bool)images;

@end


@interface ICNFMCMessageHeaders : NSObject <NSCopying, NSMutableCopying>

@property (readonly, nonatomic) unsigned long long encodingHint;
@property (readonly, copy, nonatomic) NSData *headerData;
@property (readonly, copy, nonatomic) NSArray *allHeaderKeys;
@property (readonly, copy, nonatomic) NSString *mailVersion;
@property (readonly, nonatomic) _Bool messageIsFromMicrosoft;
@property (readonly, copy, nonatomic) NSAttributedString *attributedString;
@property (readonly, copy, nonatomic) NSAttributedString *attributedStringForAllHeaders;

/* class methods */
+ (void)initialize;
+ (_Bool)isAddressHeaderKey:(id)key;
+ (_Bool)isMessageIDHeaderKey:(id)key;
+ (id)basicHeaderKeys;
+ (id)headerKeysFromLocalizedHeaders:(id)headers;
+ (_Bool)_customHeadersEnabled;
+ (id)_localizedHeadersForKeys;
+ (id)customDisplayedHeaders;
+ (id)customHeadersIgnoringDisabledState;
+ (id)englishHeadersFromLocalizedHeaders:(id)headers;
+ (_Bool)isHumanReadableHeaderKey:(id)key;
+ (id)localizedHeaderForKey:(id)key;
+ (id)localizedHeaders;
+ (id)localizedHeadersFromEnglishHeaders:(id)headers;
+ (void)setCustomDisplayedHeaders:(id)headers;

/* instance methods */
- (id)description;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (id)firstHeaderForKey:(id)key;
- (id)headersForKey:(id)key;
- (id)firstMessageIDForKey:(id)key;
- (id)messageIDListForKey:(id)key;
- (id)addressListForKey:(id)key;
- (void)appendHeaderData:(id)data recipients:(id)recipients;
- (void)appendHeaderData:(id)data recipients:(id)recipients recipientsByHeaderKey:(id)key expandGroups:(_Bool)groups includeComment:(_Bool)comment;
- (id)firstAddressForKey:(id)key;
- (_Bool)hasHeaderForKey:(id)key;
- (id)initWithHeaderData:(id)data encodingHint:(unsigned long long)hint;
- (id)_sender;
- (id)_headersForKey:(id)key;
- (id)_htmlHeaderKey:(id)key useBold:(_Bool)bold useGray:(_Bool)gray;
- (id)_attributedStringForHeaders:(id)headers;
- (id)_capitalizedKeyForKey:(id)key;
- (id)_firstAddressForKey:(id)key sender:(id)sender;
- (id)_firstMessageIDForKey:(id)key sender:(id)sender;
- (id)_headersToDisplayFromHeaderKeys:(id)keys;
- (id)_htmlValueWithKey:(id)key value:(id)value useBold:(_Bool)bold;
- (id)_newDecodedAddressFromDataInRange:(struct _NSRange)range sender:(id)sender consumedLength:(unsigned long long *)length;
- (id)_newDecodedMessageIDFromDataInRange:(struct _NSRange)range sender:(id)sender consumedLength:(unsigned long long *)length;
- (id)_newHeaderValueForKey:(id)key offset:(unsigned long long *)offset;
- (void)_resetSender;
- (void)_setCapitalizedKey:(id)key forKey:(id)key;
- (id)htmlStringUseBold:(_Bool)bold useGray:(_Bool)gray;
- (void)_appendAddressList:(id)list toData:(id)data;
- (id)encodedHeadersIncludingFromSpace:(_Bool)space;
- (id)headersDictionaryForMessageType:(signed char)type;

@end


@interface ICNFMCMimeBody : ICNFMCMessageBody

@property (retain, nonatomic) ICNFMCMimePart *topLevelPart;
@property (readonly, nonatomic) ICNFMCMimePart *preferredBodyPart;
@property (retain) NSData *bodyData;
@property (readonly, nonatomic) ICNFMCParsedMessage *parsedMessage;
@property (readonly, copy, nonatomic) NSString *mimeType;
@property (readonly, copy, nonatomic) NSString *mimeSubtype;
@property (readonly, nonatomic) _Bool isMultipartRelated;
@property (readonly, nonatomic) _Bool isTextPlain;
@property (readonly, nonatomic) NSEnumerator *attachmentPartsEnumerator;
@property (readonly, nonatomic) _Bool hasAttachments;

/* class methods */
+ (void)initialize;
+ (id)versionString;
+ (id)newMimeBoundary;

/* instance methods */
- (id)attachments;
- (id)attributedString;
- (void)flushCachedData;
- (id)webArchive;
- (_Bool)isRich;
- (_Bool)isHTML;
- (id)partWithNumber:(id)number;
- (void)renderStringForJunk:(id)junk renderPart:(id)part;
- (_Bool)_isPossiblySignedOrEncrypted;
- (id)allPartsEnumerator;
- (id)attachmentFilenames;
- (id)attachmentsWithContext:(id)context;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (id)dataForMimePart:(id)part;
- (void)decodeIfNecessary;
- (void)decodeIfNecessaryWithContext:(id)context;
- (unsigned int)numberOfAttachmentsWithFilenames:(id)filenames isSigned:(_Bool *)_signed encrypted:(_Bool *)encrypted numberOfTNEFAttachments:(unsigned int *)tnefattachments;
- (id)parsedMessageWithContext:(id)context;
- (void)renderString:(id)string;
- (id)textHtmlPart;

@end


@interface ICNFMCMimeCharset : NSObject

@property (readonly) unsigned long long encoding;
@property (readonly, copy, nonatomic) NSString *charsetName;
@property (readonly, copy, nonatomic) NSString *displayName;
@property (readonly, nonatomic) _Bool useBase64InHeaders;
@property (readonly, nonatomic) _Bool canBeUsedForOutgoingMessages;

/* class methods */
+ (id)charsetForEncoding:(unsigned long long)encoding;
+ (id)preferredMimeCharset;
+ (id)allMimeCharsets;
+ (unsigned long long)encodingVariantForEncoding:(unsigned long long)encoding address:(id)address;
+ (id)encodingVariantsForRecipients:(id)recipients;

/* instance methods */
- (id)description;
- (id)init;
- (id)initWithCFEncoding:(unsigned int)cfencoding;

@end


@interface ICNFMCMimeDataEncoding : NSObject

/* class methods */
+ (id)sharedKeySetForEncodingOptions;

@end


@interface ICNFMCMimeDecodeContext : NSObject

@property (nonatomic) _Bool decodeTextPartsOnly;
@property (nonatomic) _Bool shouldSkipUpdatingMessageFlags;

@end


@interface ICNFMCMimeHeaderScanContext : NSObject

@property (nonatomic) const char * current;
@property (nonatomic) const char * end;
@property (nonatomic) unsigned long long encodingHint;
@property (retain, nonatomic) NSMutableData *dataBuf;
@property (retain, nonatomic) ICNFMCMimePart *mimePart;

/* instance methods */
- (id)debugDescription;
- (id)description;

@end


@interface ICNFMCMimePart : NSObject <NSURLDownloadDelegate>

@property (nonatomic) _Bool isMimeEncrypted;
@property (nonatomic) _Bool isMimeSigned;
@property (retain, nonatomic) ICNFMCMessageBody *decryptedMessageBody;
@property (retain, nonatomic) ICNFMCMessage *decryptedMessage;
@property (retain, nonatomic) id <ICNFMCMessageDataSource> decryptedMessageDataSource;
@property (retain, nonatomic) ICNFMCMimeBody *mimeBody;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *subtype;
@property (copy, nonatomic) NSString *contentTransferEncoding;
@property (readonly, copy, nonatomic) NSString *contentIDURLString;
@property (readonly, copy, nonatomic) NSArray *bodyParameterKeys;
@property (copy, nonatomic) NSString *disposition;
@property (readonly, copy, nonatomic) NSArray *dispositionParameterKeys;
@property (copy, nonatomic) NSString *contentDescription;
@property (copy, nonatomic) NSString *contentID;
@property (copy, nonatomic) NSString *contentLocation;
@property (copy, nonatomic) NSArray *languages;
@property (copy, nonatomic) NSArray *subparts;
@property (readonly, nonatomic) unsigned long long approximateRawSize;
@property (readonly, nonatomic) unsigned long long approximateDecodedSize;
@property (readonly, nonatomic) _Bool hasCachedDataInStore;
@property (nonatomic) struct _NSRange range;
@property (readonly, copy, nonatomic) NSData *bodyData;
@property (readonly, copy, nonatomic) NSString *bodyString;
@property (readonly, nonatomic) unsigned long long formatFlowedOptions;
@property (readonly, copy, nonatomic) NSString *bodyConvertedFromFlowedText;
@property (readonly, nonatomic) ICNFMCParsedMessage *parsedMessage;
@property (readonly, copy, nonatomic) NSData *signedData;
@property (readonly, nonatomic) _Bool usesKnownSignatureProtocol;
@property (readonly, copy, nonatomic) NSString *partNumber;
@property (readonly, nonatomic) ICNFMCMimePart *parentPart;
@property (readonly, nonatomic) ICNFMCMimePart *firstChildPart;
@property (readonly, nonatomic) ICNFMCMimePart *nextSiblingPart;
@property (readonly, nonatomic) ICNFMCMimePart *startPart;
@property (readonly, nonatomic) ICNFMCMimePart *bestAlternative;
@property (readonly, nonatomic) unsigned int macTypeCode;
@property (readonly, nonatomic) unsigned int macCreatorCode;
@property (readonly, nonatomic) unsigned int numberOfAttachments;
@property (readonly, copy, nonatomic) NSArray *attachments;
@property (readonly, copy, nonatomic) NSString *attachmentFilename;
@property (readonly, copy, nonatomic) NSArray *attachmentFilenames;
@property (readonly, nonatomic) NSFileWrapper *fileWrapper;
@property (readonly, nonatomic) ICNFMCFileTypeInfo *typeInfo;
@property (readonly, nonatomic) ICNFMCMimePart *textHtmlPart;
@property (readonly, copy, nonatomic) WebArchive *webArchive;
@property (readonly, nonatomic) _Bool isRich;
@property (readonly, nonatomic) _Bool isHTML;
@property (readonly, nonatomic) _Bool isReadableText;
@property (readonly, nonatomic) _Bool isAttachment;
@property (readonly, nonatomic) _Bool isCalendar;
@property (readonly, nonatomic) _Bool isMessageExternalBodyWithURL;
@property (readonly, nonatomic) _Bool isStationeryImage;
@property (readonly, nonatomic) _Bool isAutoArchivePart;
@property (readonly, nonatomic) _Bool isImage;
@property (readonly, nonatomic) _Bool isSigned;
@property (readonly, nonatomic) _Bool isEncrypted;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (_Bool)mimeParameterIsHumanReadable:(id)readable;

/* instance methods */
- (id)attributedString;
- (long long)typeCode;
- (id)init;
- (void)dealloc;
- (id)decode;
- (void)download:(id)download didFailWithError:(id)error;
- (void)download:(id)download didReceiveDataOfLength:(unsigned long long)length;
- (void)download:(id)download didReceiveResponse:(id)response;
- (void)downloadDidFinish:(id)finish;
- (_Bool)isType:(id)type subtype:(id)subtype;
- (id)bodyParameterForKey:(id)key;
- (_Bool)parseIMAPPropertyList:(id)list;
- (_Bool)_isIWorkArchive;
- (void)setDispositionParameter:(id)parameter forKey:(id)key;
- (void)verifySignature;
- (int)_addDataConvertingLineEndingsFromUnixToNetwork:(id)network toCMSEncoder:(struct _CMSEncoder *)cmsencoder;
- (void)_appendToDescription:(id)description withIndent:(unsigned long long)indent;
- (id)_archiveForData:(id)data URL:(id)url MIMEType:(id)mimetype textEncodingName:(id)name frameName:(id)name;
- (id)_archiveForData:(id)data URL:(id)url MIMEType:(id)mimetype textEncodingName:(id)name frameName:(id)name subresources:(id)subresources subframeArchives:(id)archives;
- (id)_archiveForFileWrapper:(id)wrapper URL:(id)url;
- (id)_archiveForMultipartRelated;
- (id)_archiveForString:(id)string URL:(id)url needsPlainTextBodyClass:(_Bool)_class;
- (id)_attachmentFilenameWithHiddenExtension:(_Bool *)extension;
- (id)_chosenAlternativePartOrParts:(id *)parts;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)archive;
- (id)_createFileWrapper;
- (unsigned long long)_getHFSAttachmentEncodingHint;
- (id)_getSomeCharsetFromPartTree;
- (struct _CMSDecoder *)_newCMSDecoderWithMimePart:(id)part error:(id *)error;
- (id)_partThatIsAttachment;
- (void)_setMessageSigners:(id)signers andSigningError:(id)error;
- (void)_setupDictionary:(id *)dictionary fromArray:(id)array;
- (id)_verifySignatureWithCMSDecoder:(struct _CMSDecoder *)cmsdecoder againstSender:(id)sender signingError:(id *)error;
- (void)addSubpart:(id)subpart;
- (id)dispositionParameterForKey:(id)key;
- (id)htmlStringForMimePart:(id)part attachment:(id)attachment;
- (void)setBodyParameter:(id)parameter forKey:(id)key;
- (_Bool)shouldConsiderInlineOverridingExchangeServer;
- (id)decodeMessageRfc822WithContext:(id)context;
- (void)clearCachedDecryptedMessageBody;
- (id)subpartAtIndex:(long long)index;
- (id)_fullMimeTypeEvenInsideAppleDouble;
- (void)_getAttachmentsAndAddToCount:(unsigned int *)count isSigned:(_Bool *)_signed isEncrypted:(_Bool *)encrypted attachments:(id)attachments attachmentsName:(id)name numberOfTNEFAttachments:(unsigned int *)tnefattachments;
- (id)_getMessageAttachment:(long long)attachment;
- (id)_getMessageAttachment:(long long)attachment context:(id)context;
- (id)_newAttachment;
- (void)_parseHeadersWithEncodingHint:(unsigned long long)hint headerData:(id)data bodyData:(id)data hasVisualEncoding:(_Bool *)encoding;
- (void)_parseSubpartsWithEncodingHint:(unsigned long long)hint messageBodyData:(id)data hasVisualEncoding:(_Bool *)encoding;
- (id)_parseUUEncodedPartsWithEncodingHint:(unsigned long long)hint bodyData:(id)data range:(struct _NSRange)range;
- (id)_remoteFileWrapper;
- (void)clearSubparts;
- (void)configureFileWrapper:(id)wrapper;
- (id)copyMessageSigners;
- (id)copySignerLabels;
- (id)decodeApplicationApple_msg_composite_imageWithContext:(id)context;
- (id)decodeApplicationApplefileWithContext:(id)context;
- (id)decodeApplicationMac_binhex40WithContext:(id)context;
- (id)decodeApplicationOctet_streamWithContext:(id)context;
- (id)decodeApplicationPkcs7_mimeWithContext:(id)context;
- (id)decodeApplicationSmilWithContext:(id)context;
- (id)decodeApplicationZipWithContext:(id)context;
- (id)decodeMessageDelivery_statusWithContext:(id)context;
- (id)decodeMessageExternal_bodyWithContext:(id)context;
- (id)decodeMessagePartialWithContext:(id)context;
- (id)decodeMultipartAlternativeWithContext:(id)context;
- (id)decodeMultipartAppledoubleWithContext:(id)context;
- (id)decodeMultipartFolderWithContext:(id)context;
- (id)decodeMultipartRelatedWithContext:(id)context;
- (id)decodeMultipartSignedWithContext:(id)context;
- (id)decodeMultipartWithContext:(id)context;
- (id)decodeTextCalendarWithContext:(id)context;
- (id)decodeTextEnrichedWithContext:(id)context;
- (id)decodeTextHtmlWithContext:(id)context;
- (id)decodeTextPlainWithContext:(id)context;
- (id)decodeTextRichtextWithContext:(id)context;
- (id)decodeTextRtfWithContext:(id)context;
- (id)decodeTextWithContext:(id)context;
- (id)decodeWithContext:(id)context;
- (id)decodedContent;
- (id)decodedContentWithContext:(id)context;
- (id)decryptedMessageBodyIsEncrypted:(_Bool *)encrypted isSigned:(_Bool *)_signed error:(id *)error;
- (void)getNumberOfAttachments:(unsigned int *)attachments filenames:(id)filenames numberOfTNEFAttachments:(unsigned int *)tnefattachments isSigned:(_Bool *)_signed isEncrypted:(_Bool *)encrypted;
- (void)htmlString:(id *)string createWebResource:(id *)resource forFileWrapper:(id)wrapper partNumber:(id)number;
- (_Bool)isTypeCode:(long long)code subtypeCode:(long long)code;
- (void)markAsStationeryImage;
- (_Bool)needsSignatureVerification:(id *)verification;
- (id)newEncryptedPartWithData:(id)data recipients:(id)recipients encryptedData:(id *)data;
- (id)newSignedPartWithData:(id)data sender:(id)sender signatureData:(id *)data;
- (_Bool)parseMimeBody;
- (_Bool)parseMimeBodyFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (id)parsedMessageWithContext:(id)context;
- (void)renderString:(id)string;
- (void)setDecryptedMessageBody:(id)body isEncrypted:(_Bool)encrypted isSigned:(_Bool)_signed error:(id)error;
- (long long)subtypeCode;
- (id)textPart;

@end


@interface ICNFMCMimeTextAttachment : NSTextAttachment

@property (retain, nonatomic) ICNFMCMimePart *mimePart;
@property (readonly, nonatomic) NSFileWrapper *fileWrapperForcingDownload;

/* class methods */
+ (id)attachmentWithInternalAppleAttachmentData:(id)data mimeBody:(id)body;

/* instance methods */
- (id)initWithFileWrapper:(id)wrapper;
- (id)initWithMimePart:(id)part;
- (id)fileWrapperForcingDownloadEvenIfExternalBody:(_Bool)body;
- (unsigned long long)ic_approximateSize;
- (_Bool)ic_isPlaceholder;
- (id)initWithMimePart:(id)part andFileWrapper:(id)wrapper;

@end


@interface ICNFMCQOSInvocation : NSInvocation

@property (retain) NSNumber *requestedQualityOfService;

/* instance methods */
- (void)dealloc;

@end


@interface ICNFMCMonitoredInvocation : ICNFMCQOSInvocation

@property (retain, nonatomic) ICNFMCActivityMonitor *monitor;
@property id <ICNFMCActivityTarget> target;

/* class methods */
+ (id)invocationWithSelector:(SEL)selector target:(id)target taskName:(id)name priority:(unsigned char)priority canBeCancelled:(_Bool)cancelled;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 taskName:(id)name priority:(unsigned char)priority canBeCancelled:(_Bool)cancelled;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object:(id)object taskName:(id)name priority:(unsigned char)priority canBeCancelled:(_Bool)cancelled;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 object4:(id)object4 taskName:(id)name priority:(unsigned char)priority canBeCancelled:(_Bool)cancelled;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 taskName:(id)name priority:(unsigned char)priority canBeCancelled:(_Bool)cancelled;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 object4:(id)object4;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object:(id)object;

/* instance methods */
- (void)invoke;
- (void)invokeWithTarget:(id)target;
- (void)setShouldPromptUserOnTermination;
- (unsigned char)ic_priority;

@end


@interface ICNFMCMutableByteSet : ICNFMCByteSet

/* instance methods */
- (void)invert;
- (id)copyWithZone:(struct _NSZone *)zone;
- (void)addBytesInRange:(struct _NSRange)range;
- (void)removeBytesInRange:(struct _NSRange)range;

@end


@interface ICNFMCMutableMessageHeaders : ICNFMCMessageHeaders

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)mutableCopyWithZone:(struct _NSZone *)zone;
- (id)firstHeaderForKey:(id)key;
- (id)allHeaderKeys;
- (id)messageIDListForKey:(id)key;
- (void)setHeader:(id)header forKey:(id)key;
- (id)addressListForKey:(id)key;
- (_Bool)hasHeaderForKey:(id)key;
- (void)removeHeaderForKey:(id)key;
- (void)setAddressList:(id)list forKey:(id)key;
- (void)setMessageIDList:(id)idlist forKey:(id)key;
- (id)_headersForKey:(id)key;
- (void)_appendAddedHeaderKey:(id)key value:(id)value toData:(id)data;
- (void)_appendHeaderKey:(id)key value:(id)value toData:(id)data;
- (id)_firstAddressForKey:(id)key sender:(id)sender;
- (id)_firstMessageIDForKey:(id)key sender:(id)sender;
- (void)addFromSpaceIfMissing;
- (id)encodedHeadersIncludingFromSpace:(_Bool)space;

@end


@interface ICNFMCNetworkController : NSObject

@property (readonly, copy) NSString *domainName;

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)sharedInstance;
+ (long long)networkStatus;
+ (_Bool)domain:(id)domain isSubdomainOfDomain:(id)domain;
+ (id)encodeAddressForIDNA:(id)idna encodingHint:(unsigned long long)hint;
+ (id)applyIDNAToHostname:(id)hostname encode:(_Bool)encode;
+ (_Bool)hostnameIsFullyQualified:(id)qualified;
+ (id)baseDomainsForDomains:(id)domains;
+ (id)filteredDomainNamesFromHost:(id)host;
+ (id)filteredIPAddressesFromHost:(id)host;
+ (id)getHostUUIDString;
+ (id)subnetForIPAddress:(id)ipaddress;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)startWatchingReachabilityForAccount:(id)account;
- (void)stopWatchingReachabilityForAccount:(id)account;
- (void)_queueNetworkChangeNotification;
- (void)_clearDomainName;
- (struct __SCNetworkReachability *)_newNetworkReachabilityReferenceForHostname:(id)hostname;
- (void)_postNetworkChangeNotification;
- (id)_watchedAccounts;
- (_Bool)isHostReachable:(id)reachable needToEstablishInternetConnection:(_Bool *)connection;

@end


@interface ICNFMCNtlmAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)ntlmAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCOutgoingMessage : ICNFMCMessage

@property (retain, nonatomic) ICNFMCMutableMessageHeaders *mutableHeaders;
@property (copy, nonatomic) NSString *remoteID;
@property (retain, nonatomic) NSData *rawData;
@property (retain, nonatomic) _ICNFMCOutgoingMessageBody *messageBody;
@property (retain, nonatomic) NSString *existingRemoteID;

/* instance methods */
- (id)headers;
- (id)init;
- (id)bodyData;
- (id)dataSource;
- (void)dealloc;
- (unsigned long long)messageSize;
- (id)headersIfAvailable;
- (id)bodyDataFetchIfNotAvailable:(_Bool)available allowPartial:(_Bool)partial;
- (void)setLocalAttachmentsSize:(unsigned long long)size;
- (id)messageBodyIfAvailable;
- (id)messageDataIncludingFromSpace:(_Bool)space;
- (id)messageDataIncludingFromSpace:(_Bool)space newDocumentID:(id)id;

@end


@interface ICNFMCParsedMessage : NSObject <NSXMLParserDelegate>

@property (copy, nonatomic) NSString *html;
@property (readonly, copy, nonatomic) NSAttributedString *attributedString;
@property (copy, nonatomic) NSString *mimeType;
@property (retain, nonatomic) NSURL *baseURL;
@property (copy, nonatomic) NSDictionary *attachmentsByURL;
@property (copy, nonatomic) NSArray *stationeryBackgroundImageURLs;
@property (nonatomic) _Bool isPlainText;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)parsedMessageWithWebArchive:(id)archive archiveIsMailInternal:(_Bool)internal;

/* instance methods */
- (id)init;
- (id)initWithWebArchive:(id)archive archiveIsMailInternal:(_Bool)internal;
- (void)_addWebArchiveDataToArray:(id)array;
- (void)addAttachment:(id)attachment forURL:(id)url;
- (id)initWithWebArchive:(id)archive;
- (void)setBaseURLFromHtml;

@end


@interface ICNFMCPlaceholderArchiveFileWrapper : ICNFMCArchiveFileWrapper

@property (readonly, nonatomic) _Bool isPlaceholder;

@end


@interface ICNFMCPlaceholderFileWrapper : NSFileWrapper

/* instance methods */
- (_Bool)isPlaceholder;
- (_Bool)isRemotelyAccessed;

@end


@interface ICNFMCPlainAuthScheme : ICNFMCAuthScheme

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)plainAuthScheme;

/* instance methods */
- (id)name;
- (void)dealloc;
- (id)humanReadableName;
- (unsigned int)applescriptScheme;
- (id)supportedSaslMechanisms;

@end


@interface ICNFMCPriorityInvocation : ICNFMCQOSInvocation

@property unsigned char priority;

/* class methods */
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 priority:(unsigned char)priority;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object:(id)object priority:(unsigned char)priority;
+ (id)invocationWithSelector:(SEL)selector target:(id)target priority:(unsigned char)priority;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 priority:(unsigned char)priority;
+ (id)invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 object4:(id)object4 priority:(unsigned char)priority;

@end


@interface ICNFMCQuotaUsage : NSObject

@property (nonatomic) struct { long long x0; unsigned long long x1; } current;
@property (nonatomic) struct { long long x0; unsigned long long x1; } maximum;

/* instance methods */
- (_Bool)isEqual:(id)equal;
- (id)description;
- (unsigned long long)hash;
- (void)decrementCurrentBy:(struct { long long x0; unsigned long long x1; })by;
- (void)incrementCurrentBy:(struct { long long x0; unsigned long long x1; })by;

@end


@interface ICNFMCRemotePlaceholderFileWrapper : ICNFMCPlaceholderFileWrapper

@property (readonly, nonatomic) NSURL *URL;

/* instance methods */
- (id)initWithURL:(id)url;
- (id)initWithURL:(id)url options:(unsigned long long)options error:(id *)error;
- (id)initWithSerializedRepresentation:(id)representation;
- (id)initWithCoder:(id)coder;
- (id)initDirectoryWithFileWrappers:(id)wrappers;
- (id)initRegularFileWithContents:(id)contents;
- (id)initSymbolicLinkWithDestinationURL:(id)url;
- (id)symbolicLinkDestinationURL;
- (unsigned long long)approximateSize;
- (_Bool)isRemotelyAccessed;
- (id)remoteAccessMimeType;

@end


@interface ICNFMCTaskOperation : NSBlockOperation

@property (retain) ICNFMCActivityMonitor *parentMonitor;
@property (retain) ICNFMCActivityMonitor *monitor;

/* class methods */
+ (void)setTaskDescription:(const char *)description;

/* instance methods */
- (void)main;
- (void)dealloc;
- (void)cancel;
- (void)setParentMonitor:(id)monitor taskName:(id)name;
- (id)setTaskName:(id)name priority:(unsigned char)priority canCancel:(_Bool)cancel;

@end


@interface ICNFMCResultTaskOperation : ICNFMCTaskOperation

@property (retain, nonatomic) id result;

/* instance methods */

@end


@interface ICNFMCSAXHTMLParsing : NSObject

/* instance methods */
- (id)initWithEncoding:(unsigned long long)encoding;

@end


@interface ICNFMCSaslClient : NSObject

@property (copy, nonatomic) NSString *selectedMechanismName;
@property (nonatomic) long long saslStatus;
@property (retain, nonatomic) NSError *saslError;
@property (nonatomic) unsigned int encryptionBufferSize;
@property (copy, nonatomic) NSArray *mechanismNames;
@property (readonly, nonatomic) struct sasl_callback * callbacks;
@property (readonly, nonatomic) struct sasl_conn * saslConnection;
@property (nonatomic) _Bool mechanismUsesPlainText;
@property (nonatomic) _Bool lastResponseIncludesCredential;
@property (weak, nonatomic) id <ICNFMCAccount> account;
@property (nonatomic) _Bool excludeAuthorizationName;
@property (readonly, nonatomic) _Bool lastResponseIncludesPlainTextCredential;
@property (readonly, copy, nonatomic) NSData *serverErrorResponse;

/* class methods */
+ (id)keyPathsForValuesAffectingLastResponseIncludesPlainTextCredential;

/* instance methods */
- (id)description;
- (id)init;
- (void)dealloc;
- (void)_clearAuthenticationCallbackBuffers;
- (void)_handleGenericError:(int)error description:(id)description;
- (void)_handleNeedsUserInteraction:(struct sasl_interact *)interaction;
- (void)_handleStartFailure:(int)failure;
- (_Bool)_logGenericError:(int)error saslConnection:(struct sasl_conn *)connection description:(id)description error:(id *)error;
- (void)_retrieveEncryptionBufferSize;
- (id)newDecryptedDataForBytes:(const char *)bytes length:(unsigned int)length;
- (id)newEncryptedDataForBytes:(const char *)bytes length:(unsigned int)length;
- (id)responseForServerData:(id)data;
- (id)initWithMechanismNames:(id)names account:(id)account externalSecurityLayer:(unsigned int)layer allowPlainText:(_Bool)text;
- (id)startAndReturnInitialResponse:(_Bool)response;

@end


@interface ICNFMCSharedPreferencesController : NSObject

@property (retain, nonatomic) NSUserDefaults *sharedMailUserDefaults;
@property _Bool shouldExpandGroups;
@property _Bool disableRemoteContent;

/* class methods */
+ (id)allocWithZone:(struct _NSZone *)zone;
+ (id)sharedInstance;

/* instance methods */
- (id)init;
- (void)dealloc;
- (void)_postPreferencesDidChangeNotifications;
- (void)_preferencesChangedExternally:(id)externally;

@end


@interface ICNFMCSocket : NSObject <NSStreamDelegate>

@property (readonly, nonatomic) NSPort *wakeupPort;
@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (copy) id /* block */ bytesAvailableHandler;
@property _Bool scheduledForBytesToArrive;
@property (readonly) unsigned long long identifier;
@property long long activityType;
@property (nonatomic) double connectTimeout;
@property (nonatomic) double readWriteTimeout;
@property (readonly, nonatomic) _Bool isExpensive;
@property (readonly, copy, nonatomic) NSString *securityLevel;
@property (readonly, nonatomic) unsigned int cipherKeyLength;
@property (readonly, nonatomic) _Bool isReadable;
@property (readonly, nonatomic) _Bool isWritable;
@property (readonly, nonatomic) _Bool isValid;
@property (readonly, copy, nonatomic) NSString *remoteHostname;
@property (readonly, nonatomic) long long remotePortNumber;
@property (readonly, copy, nonatomic) NSData *sourceIPAddress;
@property (readonly, copy, nonatomic) NSString *sourceHostname;
@property (copy) NSArray *trustedCertificates;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (_Bool)setUsesSSL:(_Bool)ssl;
- (void)setClientIdentity:(struct __SecIdentity *)identity;
- (void)close;
- (void)stream:(id)stream handleEvent:(unsigned long long)event;
- (id)init;
- (void)dealloc;
- (struct __SecTrust *)serverTrust;
- (void)registerForBytesToArriveWithHandler:(id /* block */)handler;
- (void)unregisterForBytesToArrive;
- (void)_cancelLookupForHost:(struct __CFHost *)host infoType:(id)type;
- (void)_handleReadWriteErrorOnStream:(id)stream timedOut:(_Bool)out logDetails:(id)details error:(id *)error;
- (void)_scheduleInputStreamInMainRunLoopIfNecessary;
- (_Bool)_setSSLStreamProperties:(_Bool)properties;
- (_Bool)_setupStreamsWithHostname:(id)hostname port:(long long)port needToEstablishInternetConnection:(_Bool *)connection useSSL:(_Bool *)ssl isBackground:(_Bool)background error:(id *)error;
- (void)_unscheduleInputStreamFromMainRunLoopIfNecessary;
- (id)_waitForSecurityLayerNegotiationStreamsAreScheduled:(_Bool)scheduled;
- (_Bool)connectToHost:(id)host withPort:(long long)port isBackground:(_Bool)background;
- (long long)readBytes:(void *)bytes maxLength:(unsigned long long)length error:(id *)error;
- (long long)writeBytes:(const void *)bytes maxLength:(unsigned long long)length error:(id *)error;

@end


@interface ICNFMCStringRenderContext : NSObject

@property long long mode;
@property (readonly, nonatomic) NSMutableString *buffer;
@property (retain, nonatomic) NSSet *URLs;
@property (retain, nonatomic) NSSet *imageURLs;
@property (nonatomic) unsigned long long imageCount;
@property (nonatomic) unsigned long long characterCount;
@property (nonatomic) _Bool updateBodyFlags;
@property (retain, nonatomic) ICNFMCJunkRecorder *junkRecorder;

/* instance methods */
- (id)init;
- (id)initForMode:(long long)mode;
- (id)renderString;

@end


@interface ICNFMCSubdata : NSData

@property (nonatomic) struct _NSRange subrange;
@property (retain, nonatomic) NSData *parentData;

/* instance methods */
- (id)initWithContentsOfFile:(id)file;
- (id)initWithBytes:(const void *)bytes length:(unsigned long long)length;
- (id)initWithContentsOfURL:(id)url;
- (const void *)bytes;
- (id)initWithBytesNoCopy:(void *)copy length:(unsigned long long)length freeWhenDone:(_Bool)done;
- (id)initWithData:(id)data;
- (unsigned long long)length;
- (id)initWithContentsOfURL:(id)url options:(unsigned long long)options error:(id *)error;
- (id)initWithContentsOfFile:(id)file options:(unsigned long long)options error:(id *)error;
- (id)initWithBytesNoCopy:(void *)copy length:(unsigned long long)length;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)zone;
- (id)initWithContentsOfMappedFile:(id)file;
- (id)initWithCoder:(id)coder;
- (id)initWithParent:(id)parent range:(struct _NSRange)range;

@end


@interface ICNFMCSubjectParser : NSObject

/* class methods */
+ (_Bool)subjectHasReplyPrefix:(id)prefix;
+ (unsigned long long)effectivePrefixLengthForSubject:(id)subject replyOnly:(_Bool)only;

@end


@interface ICNFMCThrowingInvocationOperation : NSInvocationOperation

@property (weak) id target;

/* instance methods */
- (id)initWithInvocation:(id)invocation;
- (id)initWithTarget:(id)target selector:(SEL)selector object:(id)object;
- (void)main;
- (void)dealloc;

@end


@interface ICNFMCURLMatch : NSObject

@property (copy, nonatomic) NSString *url;
@property (nonatomic) struct _NSRange range;

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)init;
- (id)initWithRange:(struct _NSRange)range url:(id)url;

@end


@interface ICNFMCURLifier : NSObject

/* class methods */
+ (id)urlMatchesForString:(id)string;

@end


@interface ICNFMCWorkerThread : NSObject

/* class methods */
+ (void)initialize;
+ (void)addInvocationToQueue:(id)queue;
+ (void)runInvocationOnQueueSynchronously:(id)synchronously;

@end


@interface ICNotesHTMLMarker : NSObject

@end


@interface ICURLSecureUnarchiveFromDataTransformer : NSSecureUnarchiveFromDataTransformer

/* class methods */
+ (id)allowedTopLevelClasses;

@end


@interface ICUUIDSecureUnarchiveFromDataTransformer : NSSecureUnarchiveFromDataTransformer

/* class methods */
+ (id)allowedTopLevelClasses;

@end


@interface NFAccount : NSManagedObject <ICSearchIndexable, ICNoteVisibilityTesting, ICNFMCPersistedAccount>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (retain, nonatomic) ACAccount *internalParentACAccount;
@property (nonatomic) _Bool allowInsecureAuthentication;
@property (nonatomic) _Bool didChooseToMigrate;
@property (copy, nonatomic) NSString *emailAddress;
@property (nonatomic) _Bool enabled;
@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *parentACAccountIdentifier;
@property (retain, nonatomic) NFFolder *rootFolder;
@property (retain, nonatomic) NFTrashFolder *trashFolder;
@property (readonly, weak, nonatomic) NFFolder *defaultFolder;
@property (readonly, weak, nonatomic) NSArray *allFolders;
@property (readonly, nonatomic) long long accountClassPriority;
@property (readonly, nonatomic) _Bool isAolAccount;
@property (readonly, nonatomic) _Bool isICloudAccount;
@property (readonly, nonatomic) _Bool isYahooAccount;
@property (readonly, copy, nonatomic) NSString *internetAccountsUID;
@property (readonly, nonatomic) ACAccount *parentACAccount;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *accountDescription;
@property (copy, nonatomic) NSString *canonicalEmailAddress;
@property (copy, nonatomic) NSString *username;
@property (retain, nonatomic) ACAccountCredential *credential;

/* class methods */
+ (id)sharedAccountStore;
+ (void)setDefaultAccount:(id)account;
+ (id)accountWithEmailAddress:(id)address inManagedObjectContext:(id)context;
+ (id)accountWithParentACAccountIdentifier:(id)identifier inManagedObjectContext:(id)context;
+ (id)allEnabledAccountsWithContext:(id)context;
+ (id)defaultAccountWithContext:(id)context;
+ (id)_initialDefaultAccountWithContext:(id)context;
+ (id)accountWithInternetAccountsUID:(id)uid inManagedObjectContext:(id)context;
+ (id)allAccountsWithContext:(id)context;
+ (id)findAccountForParentACAccount:(id)acaccount inManagedObjectContext:(id)context;
+ (id)keyPathsForValuesAffectingAccountDescription;
+ (id)keyPathsForValuesAffectingDefaultFolder;
+ (id)keyPathsForValuesAffectingParentACAccount;
+ (id)resetDefaultAccount:(id)account;

/* instance methods */
- (id)predicateForSearchableAttachments;
- (_Bool)supportsVisibilityTestingType:(long long)type;
- (void)dealloc;
- (void)awakeFromInsert;
- (void)awakeFromFetch;
- (id)predicateForSearchableNotes;
- (_Bool)hasNotes;
- (id)dataForTypeIdentifier:(id)identifier;
- (id)ic_accessibilityIdentifier;
- (void)accountsFrameworkDidChange:(id)change;
- (id)createDefaultFolderInContext:(id)context;
- (id)folderEntityName;
- (_Bool)participatesInInternetAccounts;

@end


@interface NFIMAPAccountProxy : ICNFIMAPAccountProxy <NFAccountProxy>

@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *parentACAccountIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)initWithManagedObject:(id)object;
- (_Bool)hasNotes;
- (id)parentACAccount;
- (_Bool)renameMailbox:(id)mailbox newParentMailbox:(id)mailbox;
- (void)deleteMailboxFromPersistence:(id)persistence;
- (_Bool)deleteMailboxFromServer:(id)server;
- (id)mailboxProxyForMailbox:(id)mailbox;
- (unsigned long long)maximumConnectionCount;
- (id)newMailboxProxyWithMailbox:(id)mailbox;
- (void)playOfflineActions;
- (_Bool)shouldAddMailboxToPersistence:(id)persistence withParent:(id)parent;
- (_Bool)useDefaultMailboxAsMailboxHierarchyRoot;

@end


@interface NFAosImapAccountProxy : NFIMAPAccountProxy

/* instance methods */
- (id)password;
- (id)machineID;
- (id)clientInfo;
- (id)description;
- (id)oneTimePassword;
- (void)setPassword:(id)password;
- (id)appleAuthenticationToken;
- (id)applePersonID;
- (id)_anisetteData;
- (_Bool)canAuthenticateWithScheme:(id)scheme;
- (void)setSessionPassword:(id)password;
- (_Bool)shouldRetryConnectionWithoutCertificateCheckingAfterError:(id)error host:(id)host didPromptUser:(_Bool *)user;

@end


@interface NFAttachment : NSManagedObject

@property (retain, nonatomic) NSString *primitiveContentID;
@property (copy, nonatomic) NSString *contentID;
@property (retain, nonatomic) NSURL *fileURL;
@property (retain, nonatomic) NFNote *note;
@property (readonly, weak) NSURL *cidURL;
@property (readonly, weak) NSString *filename;
@property (readonly, weak) NSString *mimeType;
@property (readonly, weak) NSImage *icon;

/* class methods */
+ (id)keyPathsForValuesAffectingIcon;
+ (id)attachmentWithContentID:(id)id inNote:(id)note context:(id)context;
+ (id)keyPathsForValuesAffectingCidURL;
+ (id)keyPathsForValuesAffectingFilename;

/* instance methods */
- (id)compactDescription;
- (void)awakeFromInsert;
- (void)prepareForDeletion;
- (id)initWithFilename:(id)filename insertIntoManagedObjectContext:(id)context;
- (_Bool)validateFileURL:(inout id *)url error:(out id *)error;

@end


@interface NFCrossProcessChangeCoordinator : NSObject

@property (retain, nonatomic) NSPersistentStoreCoordinator *sourceCoordinator;
@property (retain, nonatomic) NSManagedObjectContext *destinationContext;
@property (retain, nonatomic) ICManagedObjectContextUpdater *contextUpdater;

/* instance methods */
- (void)postCrossProcessNotificationName:(id)name;
- (id)initWithSourceCoordinator:(id)coordinator destinationContext:(id)context;
- (void)registerForCrossProcessNotificationName:(id)name block:(id /* block */)block;
- (void)dealloc;
- (void)_contextDidSave:(id)save;
- (void)_distributedNotificationReceived:(id)received;

@end


@interface NFEWSAccount : NFAccount

@property (retain, nonatomic) NFEWSFolder *rootFolder;
@property (readonly, weak, nonatomic) NFEWSFolder *defaultFolder;
@property (retain, nonatomic) NSURL *externalURL;
@property (retain, nonatomic) NSURL *internalURL;
@property (retain, nonatomic) NSURL *lastUsedAutodiscoverURL;
@property (copy, nonatomic) NSString *folderHierarchySyncState;

/* class methods */
+ (id)accountWithEmailAddress:(id)address context:(id)context;
+ (id)accountWithRootFolderID:(id)id context:(id)context;
+ (id)accountWithUsername:(id)username internalURL:(id)url context:(id)context;
+ (id)createAccountWithEmailAddress:(id)address context:(id)context;

/* instance methods */
- (long long)accountClassPriority;
- (id)createDefaultFolderInContext:(id)context;
- (id)folderEntityName;
- (_Bool)participatesInInternetAccounts;
- (_Bool)validateRootFolder:(inout id *)folder error:(out id *)error;

@end


@interface NFEWSAccountProxy : ICNFMCAccountProxy <NFAccountProxy>

@property (nonatomic) _Bool useExternalURL;
@property (retain, nonatomic) NSString *folderHierarchySyncState;
@property (readonly) EWSExchangeServiceBinding *exchangeServiceBinding;
@property (retain) NSURL *internalURL;
@property (retain) NSURL *externalURL;
@property (retain) NSURL *lastUsedAutodiscoverURL;
@property (copy) NSString *rootFolderId;
@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *parentACAccountIdentifier;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)_extendedFieldsForEWSNoteType;
+ (id)_newExtendedFieldTypeForPropertyId:(long long)id;

/* instance methods */
- (void)dealloc;
- (id)initWithManagedObject:(id)object;
- (id)_sendMessage:(id)message;
- (_Bool)hasNotes;
- (void)updateAllMailboxContentsFromServer;
- (void)updateMailboxListFromServer;
- (id)parentACAccount;
- (void)_autodiscoverSettings;
- (id)_connectAndAuthenticate;
- (void)_createOrUpdateFolder:(id)folder deletedItemsFolderId:(id)id;
- (id)_deleteFolder:(id)folder;
- (id)_fetchDistinguishedFolderInfo:(id)info error:(id *)error errorCode:(long long *)code;
- (id)_fetchFolderInfoForId:(id)id error:(id *)error;
- (id)_newEWSCreateFolderForFolder:(id)folder inParent:(id)parent;
- (id)_newEWSCreateItemForNote:(id)note inFolder:(id)folder;
- (id)_newEWSDeleteFolderWithFolderId:(id)id;
- (id)_newEWSDeleteItemForNoteWithRemoteID:(id)id;
- (id)_newEWSMoveFolderForFolder:(id)folder toParent:(id)parent;
- (id)_newEWSMoveItemForNote:(id)note toFolder:(id)folder;
- (id)_newEWSSetItemFieldForBody:(id)body;
- (id)_newEWSSetItemFieldForSubject:(id)subject;
- (id)_newEWSUpdateFolderForFolder:(id)folder;
- (id)_newEWSUpdateItemForNote:(id)note;
- (_Bool)_processCreateFolderResponse:(id)response forFolder:(id)folder responseCode:(long long *)code;
- (_Bool)_processCreateItemResponse:(id)response forNote:(id)note responseCode:(long long *)code;
- (_Bool)_processDeleteFolderResponse:(id)response forFolderId:(id)id responseCode:(long long *)code;
- (_Bool)_processDeleteItemResponse:(id)response responseCode:(long long *)code;
- (_Bool)_processMoveFolderResponse:(id)response forFolder:(id)folder responseCode:(long long *)code;
- (_Bool)_processMoveItemResponse:(id)response forNote:(id)note responseCode:(long long *)code;
- (_Bool)_processUpdateFolderResponse:(id)response forFolder:(id)folder responseCode:(long long *)code;
- (_Bool)_processUpdateItemResponse:(id)response forNote:(id)note responseCode:(long long *)code;
- (id)_syncFolderHierarchyRequestWithSyncState:(id)state;
- (_Bool)addFolderToRemote:(id)remote inParent:(id)parent responseCode:(long long *)code;
- (_Bool)addNoteToRemote:(id)remote inFolder:(id)folder responseCode:(long long *)code;
- (_Bool)deleteFolderFromRemoteWithId:(id)id responseCode:(long long *)code;
- (_Bool)deleteNoteFromRemoteWithID:(id)id responseCode:(long long *)code;
- (_Bool)isServerReachable;
- (id)mailboxProxyForMailbox:(id)mailbox;
- (_Bool)moveFolderOnRemote:(id)remote toParent:(id)parent responseCode:(long long *)code;
- (_Bool)moveNoteOnRemote:(id)remote toFolder:(id)folder responseCode:(long long *)code;
- (void)recreateExchangeServiceBinding;
- (_Bool)responseCodeIsFatal:(long long)fatal;
- (_Bool)updateFolderOnRemote:(id)remote responseCode:(long long *)code;
- (_Bool)updateNoteOnRemote:(id)remote responseCode:(long long *)code;

@end


@interface NFFolder : NSManagedObject

@property (retain, nonatomic) NFAccount *primitiveAccount;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NFAccount *account;
@property (copy, nonatomic) NSSet *folders;
@property (copy, nonatomic) NSSet *notes;
@property (retain, nonatomic) NFFolder *parent;
@property (readonly, copy, nonatomic) NSArray *ancestors;
@property (readonly) _Bool isRemote;

/* class methods */
+ (Class)noteClass;

/* instance methods */
- (id)compactDescription;
- (long long)depth;
- (_Bool)validateName:(inout id *)name error:(out id *)error;
- (id)newNote;
- (id)ic_accessibilityIdentifier;
- (_Bool)isDeletedOrInTrash;
- (void)moveToTrash;
- (void)addNotesForChildFoldersToArray:(id)array;
- (_Bool)_isSiblingWithSameNameAllowed:(id)allowed;
- (_Bool)_siblingIsAllowedWithName:(id)name parent:(id)parent;
- (_Bool)containsNoteWithAttachment;
- (id)defaultNameForNewSubfolderWithName:(id)name;
- (id)newSubfolderWithName:(id)name;
- (id)notesIncludingChildFolders;
- (id)subfolderWithName:(id)name;
- (void)takeValuesFromFolder:(id)folder;
- (_Bool)validateParent:(inout id *)parent error:(out id *)error;

@end


@interface NFEWSFolder : NFFolder

@property (retain, nonatomic) NFEWSFolder *parent;
@property (copy, nonatomic) NSString *changeKey;
@property (copy, nonatomic) NSString *folderId;
@property (nonatomic) _Bool isDistinguished;
@property (copy, nonatomic) NSString *syncState;
@property (nonatomic) _Bool isUnknownType;

/* class methods */
+ (id)createFolderWithFolderId:(id)id context:(id)context;
+ (id)folderWithFolderId:(id)id context:(id)context;
+ (Class)noteClass;

/* instance methods */
- (_Bool)isRemote;
- (_Bool)validateValue:(inout id *)value forKey:(id)key error:(out id *)error;
- (id)newNote;
- (id)createNote;
- (id)newSubfolderWithName:(id)name;
- (id)subfolderWithName:(id)name;
- (void)trimFolderTreeWithParent:(id)parent;
- (_Bool)validateAccount:(inout id *)account error:(out id *)error;

@end


@interface NFEWSFolderProxy : ICNFMCMailboxProxy

@property (weak) NFEWSAccountProxy *account;
@property (readonly, weak) NSString *folderId;

/* instance methods */
- (id)initWithManagedObject:(id)object;
- (void)updateFromServer;
- (_Bool)hasNotes;
- (id)_createOrUpdateItemsWithItemIds:(id)ids;
- (void)_deleteItemIdStrings:(id)strings;
- (id)_getItemsRequestWithIds:(id)ids;
- (id)_htmlFromPlainText:(id)text;
- (id)_syncFolderItemsRequestWithSyncState:(id)state maxChanges:(long long)changes;
- (void)_updateNote:(id)note withEWSItem:(id)ewsitem;

@end


@interface NFNote : NSManagedObject <ICSearchIndexableNote, ICNFMCPersistedMessage>

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
@property (readonly) CSSearchableItemAttributeSet *searchableItemViewAttributeSet;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;
@property (retain, nonatomic) NSDate *primitiveDateCreated;
@property (retain, nonatomic) NSDate *primitiveDateEdited;
@property (retain, nonatomic) NSString *primitiveTitle;
@property (retain, nonatomic) NFNoteBody *primitiveBody;
@property (retain, nonatomic) NSDate *dateCreated;
@property (retain, nonatomic) NSDate *dateEdited;
@property (readonly, copy, nonatomic) NSString *identifierString;
@property (copy, nonatomic) NSString *remoteID;
@property (copy, nonatomic) NSSet *attachments;
@property (retain, nonatomic) NFNoteBody *body;
@property (readonly) _Bool isRemote;
@property (readonly) _Bool isBlankNewNote;
@property (readonly, nonatomic) _Bool isDuplicatable;
@property (retain, nonatomic) NSDate *dateSent;
@property (retain, nonatomic) NSDate *dateReceived;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *messageID;
@property (copy, nonatomic) NSSet *references;
@property (nonatomic) _Bool unread;
@property (copy, nonatomic) NSString *bodyHTML;

/* class methods */
+ (_Bool)supportsAttachments;
+ (_Bool)containsUnduplicatableNotes:(id)notes;
+ (id)keyPathsForValuesAffectingCreationDate;
+ (id)keyPathsForValuesAffectingModificationDate;
+ (id)noteTypeForActivity;

/* instance methods */
- (id)compactDescription;
- (void)awakeFromInsert;
- (id)noteAsPlainText;
- (id)createAttachmentWithName:(id)name;
- (id)dataForTypeIdentifier:(id)identifier;
- (void)moveToTrash;
- (id)attachmentWithContentID:(id)id;
- (id)activityDictionary;
- (void)addPersistedAttachement:(id)attachement;
- (void)takeValuesFromNote:(id)note;

@end


@interface NFEWSNote : NFNote

@property (retain, nonatomic) NFEWSFolder *folder;
@property (copy, nonatomic) NSString *changeKey;

/* class methods */
+ (_Bool)supportsAttachments;
+ (id)notesWithItemIdStrings:(id)strings context:(id)context;
+ (id)createNoteWithItemIdString:(id)string context:(id)context;
+ (id)noteWithTitle:(id)title hash:(id)hash context:(id)context;

/* instance methods */
- (_Bool)isRemote;
- (id)identifier;
- (id)createAttachmentWithName:(id)name;
- (id)_calculateHashForNoteBody;
- (id)_sha1Hash:(id)hash;
- (id)_simplifiedStringFromString:(id)string isXML:(_Bool)xml;
- (id)activityDictionary;
- (_Bool)bodyMatchesHash:(id)hash;
- (_Bool)validateFolder:(inout id *)folder error:(out id *)error;

@end


@interface NFOfflineAction : NSManagedObject

@property (nonatomic) long long sequenceNumber;
@property (retain, nonatomic) NFAccount *account;

/* class methods */
+ (_Bool)pendingOfflineActionsExist;

/* instance methods */
- (id)compactDescription;
- (void)awakeFromInsert;

@end


@interface NFFolderAction : NFOfflineAction

@property (retain, nonatomic) NFFolder *folder;
@property (retain, nonatomic) NFFolder *parent;

/* instance methods */
- (id)compactDescription;

@end


@interface NFIMAPAccount : NFAccount <ICNFIMAPPersistedAccount>

@property (readonly, nonatomic) ACAccount *imapACAccount;
@property (retain, nonatomic) NFIMAPFolder *rootFolder;
@property (readonly, weak, nonatomic) NFIMAPFolder *defaultFolder;
@property (readonly, nonatomic) NFIMAPFolder *defaultMailbox;
@property (copy, nonatomic) NSString *authentication;
@property (readonly, nonatomic) NSManagedObject<ICNFIMAPPersistedMailbox> *inbox;
@property (nonatomic) long long gmailCapabilitiesSupport;
@property (copy, nonatomic) NSString *serverPathPrefix;
@property (readonly, copy, nonatomic) NSSet *mailboxes;
@property (copy, nonatomic) NSString *hostname;
@property (nonatomic) long long port;
@property (nonatomic) long long securityLayerType;
@property (copy, nonatomic) NSData *tlsCertificate;
@property (copy, nonatomic) NSString *authenticationSchemeName;
@property (readonly, nonatomic) ACAccount *acAccount;
@property (readonly, copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *accountDescription;
@property (copy, nonatomic) NSString *canonicalEmailAddress;
@property (copy, nonatomic) NSString *username;
@property (nonatomic) _Bool allowInsecureAuthentication;
@property (retain, nonatomic) ACAccountCredential *credential;
@property (nonatomic) _Bool enabled;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)accountWithEmailAddress:(id)address context:(id)context;
+ (id)accountWithUsername:(id)username hostname:(id)hostname context:(id)context;
+ (id)createAccountWithEmailAddress:(id)address context:(id)context;
+ (id)keyPathsForValuesAffectingIsICloudAccount;

/* instance methods */
- (_Bool)usesSSL;
- (_Bool)isYahooAccount;
- (id)password;
- (void)setPassword:(id)password;
- (_Bool)isICloudAccount;
- (long long)accountClassPriority;
- (void)accountsFrameworkDidChange:(id)change;
- (void)addMailboxes:(id)mailboxes;
- (id)createDefaultFolderInContext:(id)context;
- (id)folderEntityName;
- (id)folderWithServerName:(id)name;
- (_Bool)isAolAccount;
- (id)newMailboxWithName:(id)name serverName:(id)name parent:(id)parent;
- (id)objectIDOfMailboxWithServerName:(id)name;
- (_Bool)participatesInInternetAccounts;
- (_Bool)validateRootFolder:(inout id *)folder error:(out id *)error;

@end


@interface NFIMAPFolder : NFFolder <ICNFIMAPPersistedMailbox>

@property (retain, nonatomic) NFIMAPFolder *parent;
@property (retain, nonatomic) NSNumber *allegedHighestModificationSequence;
@property (retain, nonatomic) NSNumber *computedHighestModificationSequence;
@property (copy, nonatomic) NSString *serverName;
@property (retain, nonatomic) NSNumber *uidValidity;
@property (retain, nonatomic) NSNumber *uidNext;
@property (retain, nonatomic) NSManagedObject<ICNFIMAPPersistedAccount> *account;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSSet *persistedMessages;
@property (retain, nonatomic) NSNumber *imapAllegedHighestModificationSequence;
@property (retain, nonatomic) NSNumber *imapComputedHighestModificationSequence;
@property (retain, nonatomic) NSNumber *imapUIDNext;
@property (retain, nonatomic) NSNumber *imapUIDValidity;
@property (copy, nonatomic) NSString *imapServerName;
@property (readonly, nonatomic) _Bool isRootMailbox;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)createFolderWithName:(id)name parentFolder:(id)folder context:(id)context;
+ (id)folderWithName:(id)name parentFolder:(id)folder context:(id)context;
+ (Class)noteClass;

/* instance methods */
- (_Bool)isRemote;
- (unsigned long long)totalCountOfMessages;
- (id)newMessage;
- (_Bool)validateValue:(inout id *)value forKey:(id)key error:(out id *)error;
- (unsigned int)maximumIMAPUID;
- (id)newNote;
- (_Bool)_isSiblingWithSameNameAllowed:(id)allowed;
- (void)addChildMailboxes:(id)mailboxes;
- (void)addChildMailboxesObject:(id)object;
- (void)addPersistedMessages:(id)messages;
- (void)addPersistedMessagesObject:(id)object;
- (id)cacheDirectoryContentsExcludingObjectIDs:(id)ids;
- (id)copyIncompleteMessagesIncludingObjectIDs:(id)ids;
- (id)getDetailsForMessagesWithIMAPUIDs:(id)imapuids;
- (id)messageWithUniqueID:(id)id;
- (id)messagesWithObjectIDs:(id)ids;
- (id)newSubfolderWithName:(id)name;
- (id)newSubfolderWithName:(id)name serverName:(id)name;
- (void)removeChildMailboxes:(id)mailboxes;
- (void)removeChildMailboxesObject:(id)object;
- (void)removePersistedMessages:(id)messages;
- (void)removePersistedMessagesObject:(id)object;
- (id)subfolderWithName:(id)name;
- (_Bool)validateAccount:(inout id *)account error:(out id *)error;

@end


@interface NFIMAPFolderProxy : ICNFIMAPMailboxProxy

@property (weak) NFIMAPAccountProxy *account;

/* instance methods */
- (id)mailbox;
- (id)initWithManagedObject:(id)object;
- (_Bool)addMessageToServer:(id)server withMessageType:(signed char)type;
- (void)deleteMessageFromPersistence:(id)persistence;
- (void)failedToRenameMailboxWithServerName:(id)name oldName:(id)name;
- (_Bool)isMessageDeletedFromPersistence:(id)persistence;
- (_Bool)messageShouldBePersisted:(id)persisted;

@end


@interface NFIMAPNote : NFNote <ICNFIMAPPersistedMessage__CD>

@property (retain, nonatomic) NSUUID *primitiveUniversallyUniqueID;
@property (retain, nonatomic) NFIMAPFolder *folder;
@property (nonatomic) long long mimeDataSize;
@property (retain, nonatomic) NSUUID *universallyUniqueID;
@property (retain, nonatomic) NFIMAPFolder *mailbox;
@property (retain, nonatomic) NSNumber *imapUID;
@property (retain, nonatomic) NSDate *dateEdited;
@property (retain, nonatomic) NSDate *dateCreated;
@property (retain, nonatomic) NSDate *dateSent;
@property (retain, nonatomic) NSDate *dateReceived;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *messageID;
@property (copy, nonatomic) NSSet *references;
@property (nonatomic) _Bool unread;
@property (copy, nonatomic) NSString *bodyHTML;
@property (copy, nonatomic) NSSet *attachments;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (id)noteTypeForActivity;
+ (id)notesWithUniqueID:(id)id context:(id)context;

/* instance methods */
- (_Bool)isRemote;
- (id)identifier;
- (void)awakeFromInsert;
- (id)activityDictionary;
- (_Bool)validateFolder:(inout id *)folder error:(out id *)error;

@end


@interface NFInsertFolderAction : NFFolderAction

@end


@interface NFNoteAction : NFOfflineAction

@property (retain, nonatomic) NFNote *note;
@property (retain, nonatomic) NFFolder *folder;

/* instance methods */
- (id)compactDescription;

@end


@interface NFInsertNoteAction : NFNoteAction

@end


@interface NFLocalAccount : NFAccount

@property (nonatomic) _Bool migrationOffered;

/* class methods */
+ (id)existingLocalAccountForContext:(id)context;
+ (id)localAccountWithContext:(id)context;

/* instance methods */
- (_Bool)updateAvailability;
- (void)awakeFromInsert;
- (void)awakeFromFetch;
- (long long)accountClassPriority;
- (id)recoveredItemsFolder;

@end


@interface NFLocalToEWSPusher : NSObject <NFLocalToRemotePusherProtocol>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (const char *)logCategory;

/* instance methods */
- (_Bool)_addFolderToRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy responseCode:(long long *)code;
- (_Bool)_addNoteToRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy responseCode:(long long *)code;
- (_Bool)_deleteNoteFromRemoteWithId:(id)id accountProxy:(id)proxy responseCode:(long long *)code;
- (_Bool)addFolderToRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)addNoteToRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteFolderFromRemote:(id)remote fromParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteNoteFromRemoteWithID:(id)id fromFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveFolderOnRemote:(id)remote toParent:(id)parent originalParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveNoteOnRemote:(id)remote toFolder:(id)folder originalFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateFolderOnRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateNoteOnRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;

@end


@interface NFLocalToIMAPPusher : NSObject <NFLocalToRemotePusherProtocol>

@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* class methods */
+ (const char *)logCategory;

/* instance methods */
- (_Bool)_deleteFolderHierarchyFromRemote:(id)remote accountProxy:(id)proxy;
- (_Bool)_deleteNoteFromRemoteWithID:(id)id folder:(id)folder;
- (_Bool)addFolderToRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)addNoteToRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteFolderFromRemote:(id)remote fromParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)deleteNoteFromRemoteWithID:(id)id fromFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveFolderOnRemote:(id)remote toParent:(id)parent originalParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)moveNoteOnRemote:(id)remote toFolder:(id)folder originalFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateFolderOnRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
- (_Bool)updateNoteOnRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;

@end


@interface NFLocalToRemotePusher : NSObject

/* class methods */
+ (id)_exchangePusher;
+ (id)_imapPusher;
+ (id)_remotePusherForAccountProxy:(id)proxy;
+ (id)_remotePusherForRemoteObject:(id)object;
+ (_Bool)addFolderToRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)addNoteToRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)deleteFolderFromRemote:(id)remote fromParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)deleteNoteFromRemoteWithID:(id)id fromFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)moveFolderOnRemote:(id)remote toParent:(id)parent originalParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)moveNoteOnRemote:(id)remote toFolder:(id)folder originalFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)updateFolderOnRemote:(id)remote inParent:(id)parent accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;
+ (_Bool)updateNoteOnRemote:(id)remote inFolder:(id)folder accountProxy:(id)proxy errorIsFatal:(_Bool *)fatal;

@end


@interface NFMoveFolderAction : NFFolderAction

@property (retain, nonatomic) NFFolder *originalParent;

/* instance methods */
- (id)compactDescription;

@end


@interface NFMoveNoteAction : NFNoteAction

@property (retain, nonatomic) NFFolder *originalFolder;

/* instance methods */
- (id)compactDescription;

@end


@interface NFNoteBody : NSManagedObject

@property (copy, nonatomic) NSString *htmlString;
@property (retain, nonatomic) NFNote *note;

@end


@interface NFOfflineActionManager : NSObject

/* class methods */
+ (void)executeOfflineActionsForAccount:(id)account;
+ (void)_copyFolderContentsToRecoveredItemsFolder:(id)folder;
+ (void)_copyNoteToRecoveredItemsFolder:(id)folder;
+ (_Bool)_executeActionForAccount:(id)account action:(id)action outError:(long long *)error;
+ (_Bool)_executeInsertFolderAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (_Bool)_executeInsertNoteAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (_Bool)_executeMoveFolderAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (_Bool)_executeMoveNoteAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (_Bool)_executeUpdateFolderAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (_Bool)_executeUpdateNoteAction:(id)action forAccount:(id)account outError:(long long *)error;
+ (void)_recoverFromInvalidAction:(id)action;

@end


@interface NFOfflineCoordinator : NSObject

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSMutableSet *accountsWithActions;
@property (retain, nonatomic) id <ICNFMCAccountProxyManager> accountProxyManager;

/* instance methods */
- (void)dealloc;
- (void)_contextDidSave:(id)save;
- (id)initWithContext:(id)context accountProxyManager:(id)manager;
- (void)_addInsertedNoteToOfflineQueue:(id)queue;
- (void)_addInsertedFolderToOfflineQueue:(id)queue;
- (void)_addMovedFolderToOfflineQueue:(id)queue originalParent:(id)parent;
- (void)_addMovedNoteToOfflineQueue:(id)queue originalFolder:(id)folder;
- (void)_addUpdatedFolderToOfflineQueue:(id)queue;
- (void)_addUpdatedNoteToOfflineQueue:(id)queue;
- (void)_contextWillSave:(id)save;
- (void)_executeOfflineActions;

@end


@interface NFPersistenceManager : NSObject

/* class methods */
+ (id)managedObjectContext;
+ (id)managedObjectModel;
+ (id)persistentStoreCoordinator;
+ (id)persistentStoreCoordinatorName;
+ (_Bool)isAppSandboxed;
+ (_Bool)_backupExistingStore:(id)store withCoordinator:(id)coordinator error:(id *)error;
+ (id)_storeURLForVersion:(unsigned long long)version inDataDirectory:(id)directory;
+ (id)_validStoreURLInDataDirectory:(id)directory movingOldStoreIfNeeded:(_Bool)needed withCoordinator:(id)coordinator error:(id *)error;
+ (void)addPersistentStoreIfNeeded;
+ (_Bool)isRunningInNotes;
+ (id)notesContainerLibraryURL;
+ (id)persistentStoreCoordinatorAddPersistentStoreIfNecessary:(_Bool)necessary;
+ (void)setNotesContainerLibraryURL:(id)url;
+ (void)setStoreCoordinatorIsReadOnly:(_Bool)only;
+ (_Bool)storeCoordinatorIsReadOnly;

@end


@interface NFTrashFolder : NFFolder

@property (retain, nonatomic) NFAccount *trashAccount;

/* instance methods */
- (void)awakeFromInsert;
- (void)emptyContents;
- (_Bool)validateParent:(inout id *)parent error:(out id *)error;

@end


@interface NFUpdateFolderAction : NFFolderAction

@end


@interface NFUpdateNoteAction : NFNoteAction

@end


@interface NotesFramework : NSObject

/* class methods */
+ (id)bundle;

@end


@interface _ICNFFormatFlowedWriter : NSObject

@property (readonly, copy, nonatomic) NSAttributedString *inputAttributedString;
@property (readonly, nonatomic) unsigned long long encoding;
@property (copy, nonatomic) NSString *inputString;
@property (nonatomic) _Bool addedTrailingSpaces;
@property (nonatomic) unsigned long long quoteLevel;
@property (nonatomic) struct _NSRange paragraphRange;
@property (readonly, copy, nonatomic) NSString *outputString;
@property (readonly, copy, nonatomic) NSString *quotedString;

/* instance methods */
- (id)init;
- (unsigned long long)_findLineBreakInRange:(struct _NSRange)range maxCharWidthCount:(unsigned long long)count endIsURL:(_Bool)url;
- (void)_outputQuotedParagraph;
- (id)initWithAttributedString:(id)string encoding:(unsigned long long)encoding;

@end


@interface _ICNFIMAPClientSimulatedSelectOperation : ICNFIMAPClientSelectOperation

/* class methods */
+ (void)initialize;
+ (id)newWithMailboxName:(id)name;

/* instance methods */
- (void)main;

@end


@interface _ICNFIMAPConnectionEnumerator : NSEnumerator

@property (retain, nonatomic) id lastObjectKey;

/* instance methods */
- (id)nextObject;
- (id)init;
- (id)initWithConnectionDictionary:(id)dictionary;

@end


@interface _ICNFIMAPFetchUnit : NSObject

@property (nonatomic) unsigned int uid;
@property (retain, nonatomic) ICNFIMAPClientFetchDataItem *fetchItem;
@property (retain, nonatomic) ICNFIMAPFetchResult *expectedFetchResult;
@property (nonatomic) unsigned int expectedLength;

/* instance methods */
- (id)description;
- (void)_setupExpectedFetchResult;
- (_Bool)matchesFetchResponse:(id)response;
- (id)newFailedFetchResponse;

@end


@interface _ICNFIMAPLibraryIDDetails : ICNFIMAPMessageDetails

/* instance methods */
- (long long)libraryID;
- (void)setLibraryID:(long long)id;
- (id)description;
- (signed char)persistentIDType;

@end


@interface _ICNFIMAPManagedObjectIDDetails : ICNFIMAPMessageDetails

/* instance methods */
- (id)description;
- (id)managedObjectID;
- (void)setManagedObjectID:(id)id;
- (signed char)persistentIDType;

@end


@interface _ICNFMCActivityMonitorMultiTarget : NSObject <ICNFMCActivityTarget>

@property (retain, nonatomic) id <ICNFMCActivityTarget> primaryTarget;
@property (readonly, copy, nonatomic) NSArray *allTargets;
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *debugDescription;

/* instance methods */
- (id)displayName;
- (_Bool)addActivityTarget:(id)target;
- (_Bool)removeActivityTarget:(id)target;

@end


@interface _ICNFMCConnectionAttempt : NSObject

@property (nonatomic) long long securityLayer;
@property (nonatomic) long long port;

/* instance methods */
- (id)description;

@end


@interface _ICNFMCISPLocalAccountSettingsManager : ICNFMCISPAccountSettingsManager

/* instance methods */
- (id)_persistanceFolderName;

@end


@interface _ICNFMCISPOnlineAccountSettingsManager : ICNFMCISPAccountSettingsManager

@property (readonly, copy, nonatomic) NSString *ispAccountsXQuery;

/* instance methods */
- (void)emptyCache;
- (id)init;
- (id)_deliveryAccountsSettingsForDomain:(id)domain fetchIfNecessary:(_Bool)necessary;
- (id)_fetchISPDataForDomain:(id)domain;
- (void)_finalizeISPAccountsSettings:(id)settings;
- (id)_ispPlistForDomain:(id)domain;
- (id)_ispPlistFromXMLDocument:(id)xmldocument;
- (id)_persistanceFolderName;
- (id)_receivingAccountSettingsForDomain:(id)domain fetchIfNecessary:(_Bool)necessary;
- (_Bool)_shouldVerifyLoadedISPPlist;

@end


@interface _ICNFMCInvocationOperation : ICNFMCThrowingInvocationOperation

/* instance methods */
- (void)main;

@end


@interface _ICNFMCMemoryMessage : ICNFMCMessage

/* instance methods */
- (void)setDataSource:(id)source;
- (id)initWithStore:(id)store;
- (id)init;
- (id)dataSource;
- (_Bool)isCompacted;
- (id)primitiveDataSource;
- (id)messageDataIncludingFromSpace:(_Bool)space newDocumentID:(id)id;

@end


@interface _ICNFMCMimeEnrichedReader : NSObject

/* instance methods */
- (id)debugDescription;
- (id)description;
- (id)init;
- (id)currentFont;
- (id)punctuationSet;
- (id)copyCommand;
- (void)appendStringToBuffer:(id)buffer;
- (void)beginCommand:(id)command;
- (void)closeUpQuoting;
- (void)convertEnrichedString:(id)string intoOutputString:(id)string;
- (void)convertEnrichedString:(id)string intoPlainOutputString:(id)string;
- (void)convertRichTextString:(id)string intoOutputString:(id)string;
- (id)copyNextTokenWithDelimiters:(id)delimiters;
- (void)endCommand:(id)command;
- (void)fixConsecutiveSpaces:(id)spaces;
- (void)handleNoParameterCommand:(const struct { id x0; _Bool x1; _Bool x2; _Bool x3; signed char x4; } *)command;
- (void)nowWouldBeAGoodTimeToAppendToTheAttributedString;
- (id)parenthesesSet;
- (void)parseParameterString:(id)string;
- (long long)readTokenInto:(id *)into;
- (void)resetStateWithString:(id)string outputString:(id)string;
- (void)setupFontStackEntry:(id)entry;

@end


@interface _ICNFMCMimeEnrichedReaderCommandStackEntry : NSObject

@property (nonatomic) const struct { id x0; _Bool x1; _Bool x2; _Bool x3; signed char x4; } * commandTableEntry;
@property (retain, nonatomic) id parameter;

/* instance methods */

@end


@interface _ICNFMCMimeEnrichedState : NSObject

@property (nonatomic) unsigned char excerptLevel;
@property (nonatomic) long long alignment;
@property (nonatomic) _Bool bold;
@property (nonatomic) _Bool italic;
@property (nonatomic) _Bool fixed;
@property (nonatomic) _Bool underline;
@property (nonatomic) short fontDelta;
@property (copy, nonatomic) NSString *fontFamily;
@property (retain, nonatomic) NSColor *color;

/* instance methods */

@end


@interface _ICNFMCMimeEnrichedWriter : NSObject

/* instance methods */
- (id)debugDescription;
- (void)pushStackEntry:(id)entry;
- (void)appendTextFromRange:(struct _NSRange)range toString:(id)string;
- (id)convertAttributedString:(id)string;
- (void)popStackEntry;
- (void)pushEntryForCommand:(id)command withParameter:(id)parameter output:(id)output;
- (void)setState:(id)state fromAttributes:(id)attributes;
- (void)setState:(id)state fromStackEntry:(id)entry;
- (void)updateOutput:(id)output forAttributes:(id)attributes range:(struct _NSRange)range;

@end


@interface _ICNFMCMimeEnrichedWriterCommandStackEntry : NSObject

@property (weak, nonatomic) NSString *command;
@property (nonatomic) unsigned long long attrStringIndex;
@property (retain, nonatomic) id parameter;
@property (retain, nonatomic) _ICNFMCMimeEnrichedWriterCommandStackEntry *parent;

/* instance methods */
- (id)init;

@end


@interface _ICNFMCMimePartEnumerator : NSEnumerator

@property (readonly, nonatomic) _Bool onlyAttachments;
@property (nonatomic) _Bool isFirstIteration;
@property (retain, nonatomic) ICNFMCMimePart *currentPart;

/* instance methods */
- (id)nextObject;
- (id)init;
- (id)initWithMimeBody:(id)body onlyAttachments:(_Bool)attachments;

@end


@interface _ICNFMCOutgoingMessageBody : ICNFMCMessageBody

@property (retain, nonatomic) NSMutableData *rawData;
@property (weak) ICNFMCOutgoingMessage *message;

/* instance methods */
- (id)init;

@end


@interface _ICNFNonBoostingLock : NSObject <NSLocking>

/* instance methods */
- (void)unlock;
- (void)lock;
- (id)init;
- (void)dealloc;

@end


@interface _ICNFUIDsBatch : NSObject

@property (retain, nonatomic) NSMutableIndexSet *uids;
@property (nonatomic) unsigned int expectedLength;

/* instance methods */
- (id)description;
- (id)init;

@end


@interface NSAttributedString (ICNFMCFormatFlowedSupport)

/* class methods */
+ (id)ic_boldGrayHeaderAttributes;
+ (id)ic_fixedPitchAttributes;
+ (id)ic_headerAttributes;
+ (double)ic_headerFontSize;

/* instance methods */
- (id)ic_enrichedString;
- (void)ic_getQuotedString:(id *)string encoding:(unsigned long long)encoding;

@end


@interface NSCharacterSet (ICNFMCMailCoreAdditions)

/* class methods */
+ (id)ic_unsafeDomainNameCharacterSet;

@end


@interface NSColor (ICNFMCMailCoreAdditions)

/* class methods */
+ (id)scriptingRGBColorWithDescriptor:(id)descriptor;
+ (id)ic_colorForIdentifier:(id)identifier;
+ (id)ic_colorForQuoteLevel:(unsigned long long)level;
+ (id)ic_colorPlist;
+ (id)ic_colorWithIntValue:(int)value;
+ (id)ic_defaultQuotingColors;
+ (id)ic_identifierForColor:(id)color;
+ (id)ic_quotingColorList;

/* instance methods */
- (id)scriptingRGBColorDescriptor;
- (int)ic_intValue;

@end


@interface NSData (ICNFMCMimeDataEncoding)

/* class methods */
+ (id)ic_dataByConvertingLineEndingsFromNetworkToUnix:(id)unix;
+ (id)ic_dataByConvertingLineEndingsFromUnixToNetwork:(id)network;
+ (unsigned long long)ic_quotedPrintableLengthOfHeaderBytes:(const char *)bytes length:(unsigned long long)length;

/* instance methods */
- (id)ic_MD5Digest;
- (id)ic_decodeQuotedPrintableForText:(_Bool)text;
- (id)ic_encodeQuotedPrintableForText:(_Bool)text allowCancel:(_Bool)cancel;
- (struct _NSRange)ic_rangeOfCString:(const char *)cstring;
- (struct _NSRange)ic_rangeOfCString:(const char *)cstring options:(unsigned long long)options;
- (struct _NSRange)ic_rangeOfCString:(const char *)cstring options:(unsigned long long)options range:(struct _NSRange)range;
- (struct _NSRange)ic_rangeOfRFC822HeaderData;
- (id)ic_uudecodedDataIntoFile:(id *)file mode:(unsigned int *)mode;
- (id)ic_wrapperForAppleFileDataWithFileEncodingHint:(unsigned long long)hint;
- (id)ic_wrapperForBinHex40DataWithFileEncodingHint:(unsigned long long)hint;

@end


@interface NSDate (ICNFMCMailCoreAdditions)

/* instance methods */
- (id)ic_descriptionInBSDMailboxFormat;

@end


@interface NSError (ICNFMCMailCoreAdditions)

/* instance methods */
- (_Bool)ic_isAuthenticationError;
- (_Bool)ic_isSSLCertificateError;
- (id)ic_moreInfo;
- (id)ic_shortDescription;
- (_Bool)shouldBeReportedToUser;

@end


@interface NSFileManager (ICNFMCMailCoreAdditions)

/* instance methods */
- (long long)ic_fileSizeAtPath:(id)path traverseLink:(_Bool)link;
- (id)ic_URLForNonContainerizedHomeDirectory;
- (id)ic_createUniqueDirectoryAtPath:(id)path withIntermediateDirectories:(_Bool)directories attributes:(id)attributes error:(id *)error;

@end


@interface NSFileWrapper (ICNFMCMailCoreAdditions)

/* class methods */
+ (id)ic_fileWrapperWithDictionaryRepresentation:(id)representation;

/* instance methods */
- (_Bool)isPlaceholder;
- (id)messageID;
- (id)contentID;
- (unsigned int)creator;
- (unsigned int)type;
- (struct CGSize)imageSize;
- (id)mimeType;
- (void)setType:(unsigned int)type;
- (void)setMessageID:(id)id;
- (void)setMimeType:(id)type;
- (void)setCreator:(unsigned int)creator;
- (id)stringForIndexing;
- (void)setContentID:(id)id;
- (unsigned long long)approximateSize;
- (_Bool)isRemotelyAccessed;
- (void)setWhereFroms:(id)froms;
- (id)preferredFilenameWithoutHiddenExtension;
- (id)filePermissions;
- (void)setFinderFlags:(unsigned short)flags;
- (void)_isImageFile:(_Bool *)file isPDF:(_Bool *)pdf bestMimeType:(id *)type;
- (id)bestMimeType;
- (unsigned short)finderFlags;
- (unsigned long long)imageBytes;
- (_Bool)isImageFile;
- (void)isImageFile:(_Bool *)file isPDF:(_Bool *)pdf;
- (id)resourceForkData;
- (void)setFilePermissions:(id)permissions;
- (void)setResourceForkData:(id)data;
- (void)setShouldHideExtension:(_Bool)extension;
- (_Bool)shouldHideExtension;
- (id)whereFroms;
- (id)ic_archivedData;
- (_Bool)_writeFinderInfoToPath:(id)path includeDirectoryContents:(_Bool)contents;
- (_Bool)createEmptyAttachmentAtPath:(id)path;
- (_Bool)emptyAttachmentExists;
- (id)emptyAttachmentPath;
- (id)ic_appleDoubleDataWithFilename:(const char *)filename length:(unsigned long long)length;
- (id)ic_appleSingleDataWithFilename:(const char *)filename length:(unsigned long long)length;
- (id)ic_archivedDataWithPartNumber:(id)number;
- (id)ic_dictionaryRepresentation;
- (_Bool)ic_isCalendarInvitation;
- (_Bool)isALargeAttachment;
- (id)mailSpecialHandlingType;
- (id)quarantineProperties;
- (void)removeEmptyAttachment;
- (void)setIc_isCalendarInvitation:(_Bool)invitation;
- (void)setImageSize:(struct CGSize)size imageBytes:(unsigned long long)bytes;
- (void)setMailSpecialHandlingType:(id)type;
- (void)setQuarantineProperties:(id)properties;

@end


@interface NSImage (ICNFMCMailCoreAdditions)

/* instance methods */
- (unsigned long long)ic_frameCount;
- (_Bool)ic_isAnimated;

@end


@interface NSInvocation (ICNFMCMailCoreAdditions)

/* class methods */
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object1:(id)object1 object2:(id)object2 object3:(id)object3 object4:(id)object4;
+ (id)ic_invocationWithSelector:(SEL)selector target:(id)target object:(id)object;

/* instance methods */
- (id)ic_debugDescription;
- (unsigned char)ic_priority;
- (id)ic_requestedQualityOfService;

@end


@interface NSMutableArray (ICNFMCConvenience)

/* instance methods */
- (_Bool)ic_addObjectIfAbsentAccordingToEquals:(id)equals;

@end


@interface NSMutableData (ICNFMCRFC2231Support)

/* instance methods */
- (void)ic_appendCString:(const char *)cstring;
- (void)ic_appendQuotedPrintableDataForHeaderBytes:(const char *)bytes length:(unsigned long long)length;
- (void)ic_appendRFC2231CompliantValue:(id)value forKey:(id)key withEncodingHint:(unsigned long long)hint;
- (void)ic_convertNetworkLineEndingsToUnix;

@end


@interface NSMutableDictionary (ICNFMCRFC2231Support)

/* instance methods */
- (void)ic_addObject:(id)object forKey:(id)key;
- (void)ic_fixupRFC2231ValuesWithSender:(id)sender fromWindows:(_Bool)windows;

@end


@interface NSMutableSet (ICNFMCMailCoreAdditions)

/* instance methods */
- (void)ic_removeNonNilObject:(id)object;
- (id)ic_uniquedObject:(id)object;

@end


@interface NSObject (MCNSObjectAdditions)

/* instance methods */
- (void)ic_safeRemoveObserver:(id)observer forKeyPath:(id)path;

@end


@interface NSRunLoop (ICNFMCMailCoreAdditions)

/* class methods */
+ (void)ic_flushQueuedEvents;
+ (_Bool)ic_flushQueuedEventsAddingSource:(_Bool)source;

@end


@interface NSScanner (ICNFMCMailCoreAdditions)

/* instance methods */
- (id)ic_nextTokenWithPunctuation:(id)punctuation;
- (_Bool)ic_scanUpAndOverString:(id)string;

@end


@interface NSString (ICNFMCRFC2047Support)

/* class methods */
+ (id)ic_contentIDStringFromCidUrl:(id)url;
+ (id)ic_htmlStringFromMimeEnrichedString:(id)string;
+ (id)ic_htmlStringFromMimeRichTextString:(id)string;
+ (id)ic_messageIDStringWithDomainHint:(id)hint;
+ (id)ic_stringFromMimeEnrichedString:(id)string;

/* instance methods */
- (_Bool)ic_isEqualToStringIgnoringCase:(id)_case;
- (id)ic_MD5Digest;
- (id)ic_bestMimeCharsetUsingHint:(unsigned long long)hint;
- (long long)ic_caseInsensitiveCompareExcludingXDash:(id)xdash;
- (id)ic_convertFromFlowedText:(unsigned long long)text;
- (id)ic_decodeMimeHeaderValueWithCharsetHint:(id)hint detectOtherEncodings:(_Bool)encodings fromWindows:(_Bool)windows;
- (id)ic_encodedHeaderDataWithEncodingHint:(unsigned long long)hint;
- (id)ic_encodedHeaderDataWithEncodingHint:(unsigned long long)hint encodingUsed:(unsigned long long *)used;
- (id)ic_encodedMessageID;
- (_Bool)ic_isCalendarInvitation;
- (id)ic_messageIDSubstring;
- (id)ic_newStringByApplyingBodyClassName:(id)name;
- (id)ic_stringByApplyingBodyClassName:(id)name;
- (id)ic_stringByLocalizingReOrFwdPrefix;
- (id)ic_stringByRemovingCharactersInSet:(id)set;
- (id)ic_stringByReplacingNonBreakingSpacesWithString:(id)string;
- (id)ic_stringByReplacingString:(id)string withString:(id)string;
- (id)ic_stringSuitableForHTML;
- (id)ic_urlStringByIncrementingCompositeVersionNumber;

@end


@interface NSTextAttachment (ICNFMCMimeSupport)

/* instance methods */
- (unsigned long long)ic_approximateSize;
- (_Bool)ic_isPlaceholder;
- (id)ic_mimePart;

@end


#endif /* NotesHTML_h */
