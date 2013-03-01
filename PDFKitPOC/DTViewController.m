//
//  DTViewController.m
//  PDFKitPOC
//
//  Created by Jonathan Nolen on 10/22/12.
//  Copyright (c) 2012 Developertown. All rights reserved.
//

#import "DTViewController.h"
#import <PSPDFKit/PSPDFKit.h>
#import "DTPDFToolBar.h"
#import "DTAnnotationProvider.h"

@interface DTViewController ()<PSPDFViewControllerDelegate>
@property (nonatomic, strong) PSPDFViewController *pdfController;
@property (nonatomic, strong) IBOutlet DTPDFToolbar *toolbar;
@property (nonatomic, strong) DTAnnotationProvider *customAnnotationProvider;
@end

@implementation DTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pdfController = [self loadPdfController];
    [self configureToolbar];
}

-(PSPDFViewController *)loadPdfController{
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *documentURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"pdf-iso3200.pdf"];
    PSPDFDocument *doc = [PSPDFDocument PDFDocumentWithURL:documentURL];

    self.customAnnotationProvider = [DTAnnotationProvider new];
    
    [doc setDidCreateDocumentProviderBlock:^(PSPDFDocumentProvider *docProvider){
        NSLog(@"DID CREATE DOC PROVIDER: %@",docProvider.fileURL);

        docProvider.annotationParser.annotationProviders = @[self.customAnnotationProvider, docProvider.annotationParser.fileAnnotationProvider];
    }];
    return [[PSPDFViewController alloc] initWithDocument:doc];
}
-(void)configureToolbar{
    self.toolbar.pdfController = self.pdfController;
    CGRect toolBarframe = self.toolbar.frame;
    toolBarframe.origin = CGPointZero;
    toolBarframe.size = CGSizeMake(self.pdfController.view.bounds.size.width, 44.0);
    
    NSLog(@"toolbar frame set to: %@", NSStringFromCGRect(toolBarframe));
    self.toolbar.frame = toolBarframe;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.backgroundColor = [UIColor colorWithWhite:.09 alpha:.9];
    [self.toolbar removeFromSuperview];
    
    UIButton *pause = [[UIButton alloc] initWithFrame:CGRectMake(toolBarframe.size.width - 100, 0, 100, toolBarframe.size.height)];
    [pause addTarget:self action:@selector(pauseToDebug:) forControlEvents:UIControlEventTouchUpInside];
    [pause setTitle:@"debug!" forState:UIControlStateNormal];
    [self.toolbar addSubview:pause];
    
    UIButton *print = [[UIButton alloc] initWithFrame:CGRectOffset(pause.frame, -100, 0)];
    [print addTarget:self action:@selector(printAnnotationsForCurrentPage:) forControlEvents:UIControlEventTouchUpInside];
    [print setTitle:@"print!" forState:UIControlStateNormal];
    [self.toolbar addSubview:print];
    
    [self.pdfController.HUDView addSubview:self.toolbar];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    self.pdfController = nil;
}

-(void)setPdfController:(PSPDFViewController *)pdfController{
    if (_pdfController){
        [_pdfController willMoveToParentViewController:nil];
        [_pdfController.view removeFromSuperview];
        [_pdfController removeFromParentViewController];
    }
    
    _pdfController = pdfController;
    
    if (_pdfController){
        [self addChildViewController:_pdfController];
        _pdfController.view.frame = self.view.bounds;
        [self.view addSubview:_pdfController.view];
        [_pdfController didMoveToParentViewController:self];
        _pdfController.delegate = self;
        _pdfController.pageMode = PSPDFPageModeSingle;
        _pdfController.pageTransition = PSPDFPageScrollContinuousTransition;
        _pdfController.scrollDirection = PSPDFScrollDirectionVertical;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// Return NO to stop the HUD change event.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowHUD:(BOOL)animated{
    NSLog(@"shouldShowHUD");
    return YES;
}

/// HUD will be displayed.
- (void)pdfViewController:(PSPDFViewController *)pdfController willShowHUD:(BOOL)animated{
    NSLog(@"willShowHUD");

}
/// HUD was displayed (called after the animation finishes)
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowHUD:(BOOL)animated{
    NSLog(@"didShowHUD");
}

/// Return NO to stop the HUD change event.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldHideHUD:(BOOL)animated{
    NSLog(@"shouldHideHUD");
    return YES;
}

/// HUD will be hidden.
- (void)pdfViewController:(PSPDFViewController *)pdfController willHideHUD:(BOOL)animated{
    NSLog(@"willHideHUD");

}
/// HUD was hidden (called after the animation finishes)
- (void)pdfViewController:(PSPDFViewController *)pdfController didHideHUD:(BOOL)animated{
    NSLog(@"didHideHUD");
}

-(void)pdfViewController:(PSPDFViewController *)pdfController didDisplayDocument:(PSPDFDocument *)document{
    NSLog(@"Annotation path: %@", document.annotationParser.fileAnnotationProvider.annotationsPath);
}

-(void)pauseToDebug:(id)sender{

}
-(void)printAnnotationsForCurrentPage:(id)sender{

    NSArray *currentCustomAnnotations = [self.customAnnotationProvider annotationsForPage:self.pdfController.page];
    NSArray *currentFileProviderAnnotations = [self.pdfController.document.annotationParser.fileAnnotationProvider annotationsForPage:self.pdfController.page];
    
    NSLog(@"Custom Annotations For Current Page: %d\nFile Annotation Provider Annotations For Current Page: %d", currentCustomAnnotations.count, currentFileProviderAnnotations.count);
    
    
    void(^annotationEnumeratorBlock)(PSPDFAnnotation *annotation, NSUInteger idx, BOOL *stop) = ^(PSPDFAnnotation *annotation, NSUInteger idx, BOOL *stop){
        id representation = [annotation externalRepresentationInFormat:PSPDFModelJSONFormat];
        
        NSLog(@"%@ - %@", [representation class], representation);
    };
    
    NSLog(@"custom annotations");
    [currentCustomAnnotations enumerateObjectsUsingBlock:annotationEnumeratorBlock];
    
    NSLog(@"file provider annotations");
    [currentFileProviderAnnotations enumerateObjectsUsingBlock:annotationEnumeratorBlock];
}

-(void)loadAnnotations:(id)sender{
    NSLog(@"loading annotations.");
    [self.pdfController.document.annotationParser.fileAnnotationProvider tryLoadAnnotationsFromFileWithError:nil];
}

+(NSString *)Documents{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}
@end
