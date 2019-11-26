//
//  JQTEventMeta+AutoTrack.h
//  JQTrack
//
//  Created by jqoo on 2019/7/9.
//

#import <Foundation/Foundation.h>
#import "JQTDefines.h"
#import "JQTEventMeta.h"

@interface JQTEventMeta (AutoTrack)

- (void)trackForType:(JQTEventType)eventType sender:(id)sender;
- (void)trackForType:(JQTEventType)eventType sender:(id)sender index:(NSInteger)index;

+ (void)trackEvents:(NSArray<JQTEventMeta *> *)events forType:(JQTEventType)eventType;

@end
