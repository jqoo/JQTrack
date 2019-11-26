//
//  JQTAutoTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <Foundation/Foundation.h>
#import "JQTEventMeta+AutoTrack.h"

@protocol JQTAutoTrackDelegate <NSObject>

- (void)trackEvent:(JQTEventMeta *)event type:(JQTEventType)type sender:(id)sender position:(NSInteger)position;

- (void)trackEvents:(NSArray<JQTEventMeta *> *)events forType:(JQTEventType)eventType;

@end

@interface JQTAutoTrack : NSObject

@property (class, nonatomic, readonly) id<JQTAutoTrackDelegate> delegate;

+ (void)setupWithDelegate:(id<JQTAutoTrackDelegate>)delegate;

+ (void)enableViewDebug:(BOOL)enable;

@end
