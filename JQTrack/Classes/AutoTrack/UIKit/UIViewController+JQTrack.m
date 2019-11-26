//
//  UIViewController+JQTrack.m
//  JQTrack
//
//  Created by jqoo on 2019/1/4.
//

#import "UIViewController+JQTrack.h"
#import "JQTUtil.h"

@implementation UIViewController (JQTrack)

JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_pageId, setBfs_pageId, COPY_NONATOMIC, NSString *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_url_stored, setBfs_url, COPY_NONATOMIC, NSString *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_refPage, setBfs_refPage, COPY_NONATOMIC, NSString *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_refSpm, setBfs_refSpm, COPY_NONATOMIC, NSString *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_scm, setBfs_scm, COPY_NONATOMIC, NSString *)
JQT_SYNTH_DYNAMIC_PROPERTY_OBJECT(bfs_attributes, setBfs_attributes, COPY_NONATOMIC, NSDictionary *)

- (NSString *)bfs_url {
    return [self bfs_url_stored] ?: NSStringFromClass([self class]);
}

- (NSString *)bfs_refererForNextPage {
    NSString *pageId = self.bfs_pageId;
    if ([pageId length] > 0) {
        return pageId;
    }
    return self.bfs_url;
}

@end
