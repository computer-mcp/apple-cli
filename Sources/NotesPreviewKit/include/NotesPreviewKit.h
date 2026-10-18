// Normalized full dump import surface for NotesPreviewKit.

// Source: local dyld shared cache via ipsw class-dump; normalized for Swift/Clang import.

#ifndef NotesPreviewKit_h

#define NotesPreviewKit_h



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

@import NotesShared;





struct CGSize;



@class ICThumbnailKey, NPNotePreviewProvider, NPNotePreviewProviderInternal, _TtC15NotesPreviewKit23PersistedThumbnailCache, _TtC15NotesPreviewKit25WidgetNotePreviewProvider;



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


@interface NPNotePreviewProvider : NSObject

@property (retain, nonatomic) NPNotePreviewProviderInternal *notePreviewProvider;

/* class methods */
+ (id)shared;

/* instance methods */
- (id)previewForUserActivity:(id)activity error:(id *)error;
- (id)initWithNotePreviewProvider:(id)provider;

@end


@interface NPNotePreviewProviderInternal : NSObject

/* class methods */
+ (id)shared;

/* instance methods */
- (id)init;
- (id)previewForUserActivity:(id)activity error:(id *)error;

@end


@interface _TtC15NotesPreviewKit23PersistedThumbnailCache : _TtCs12_SwiftObject

@end


@interface _TtC15NotesPreviewKit25WidgetNotePreviewProvider : _TtCs12_SwiftObject

@end


#endif /* NotesPreviewKit_h */
