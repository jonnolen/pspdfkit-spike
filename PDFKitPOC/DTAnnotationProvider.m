//
//  DTAnnotationProvider.m
//  PDFKitPOC
//
//  Created by Jonathan Nolen on 3/1/13.
//  Copyright (c) 2013 Developertown. All rights reserved.
//

#import "DTAnnotationProvider.h"

@interface DTAnnotationProvider()

@property (nonatomic, strong) NSMutableDictionary *annotationsForPageCache;
@property (nonatomic, strong) NSMutableSet *annotations;

@end

@implementation DTAnnotationProvider

@synthesize providerDelegate;
-(id)init{
    if (self = [super init]){
        _annotationsForPageCache = [NSMutableDictionary dictionaryWithCapacity:1];
        _annotations = [NSMutableSet setWithCapacity:50];
    }
    return self;
}
-(BOOL)addAnnotations:(NSArray *)annotations forPage:(NSUInteger)page{
    __block BOOL supportsAllAnnotations = YES;
    [annotations enumerateObjectsUsingBlock:^(PSPDFAnnotation *annotation, NSUInteger indx, BOOL *stop){
        if ((annotation.type & [self supportedTypes]) != annotation.type){
            *stop = YES;
            supportsAllAnnotations = NO;
            return;
        }
    }];
    
    if (!supportsAllAnnotations){
        return NO;
    }
    
    [self.annotations addObjectsFromArray:annotations];
    
    [annotations enumerateObjectsUsingBlock:^(PSPDFAnnotation *annotation, NSUInteger idx, BOOL *stop){
        [self cacheAnnotationToProperPage:annotation];
    }];
    
    return YES;
}

-(void)cacheAnnotationToProperPage:(PSPDFAnnotation *)annotation{
    NSMutableSet *pageAnnotations = [self pageCacheForPage:annotation.page];
    [pageAnnotations addObject:annotation];
}

- ( NSArray *)annotationsForPage:(NSUInteger)page{
    NSMutableSet *annotationsForPage = [self pageCacheForPage:page];
    return [annotationsForPage allObjects];
}

-(NSMutableSet *)pageCacheForPage:(NSUInteger)page{
    NSMutableSet *pageAnnotations = nil;
    @synchronized(self){
        if (self.annotationsForPageCache[@(page)]){
            pageAnnotations = self.annotationsForPageCache[@(page)];
        }
        else{
            pageAnnotations = [NSMutableSet setWithCapacity:1];
    
            [self.annotations enumerateObjectsUsingBlock:^(PSPDFAnnotation *annotation, BOOL *stop){
                if (annotation.page == page){
                    [pageAnnotations addObject:annotation];
                }
            }];
            
            self.annotationsForPageCache[@(page)] = pageAnnotations;
        }
    }
    return pageAnnotations;
}

- (void) didChangeAnnotation:(PSPDFAnnotation *)annotation originalAnnotation:(PSPDFAnnotation *)originalAnnotation keyPaths:(NSArray *)keyPaths options:(NSDictionary *)options{

    if ([self.annotations containsObject:annotation]){
        if ([keyPaths[0] isEqualToString:@"isDeleted"]){
            [self deleteAnnotation:annotation];
        }
        
        annotation.dirty = NO;
    }
 
}

-(void)deleteAnnotation:(PSPDFAnnotation *)annotation{
    if ([self.annotations containsObject:annotation]){
        [self.annotations removeObject:annotation];
        [self.annotationsForPageCache[@(annotation.page)] removeObject:annotation];
    }
}

-(NSDictionary *)dirtyAnnotations{
    return @{};
}

-(BOOL)hasLoadedAnnotationsForPage:(NSUInteger)page{
    return (self.annotationsForPageCache[@(page)] != nil);
}

-(BOOL)saveAnnotationsWithError:(NSError *__autoreleasing *)error{
    return YES;
}

-(PSPDFAnnotationType)supportedTypes{
    return (PSPDFAnnotationTypeHighlight |
            PSPDFAnnotationTypeInk |
            PSPDFAnnotationTypeNote );        
}

@end
