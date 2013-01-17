//
//  DTViewController.m
//  PDFKitPOC
//
//  Created by Jonathan Nolen on 10/22/12.
//  Copyright (c) 2012 Developertown. All rights reserved.
//

#import "DTViewController.h"
#import <PSPDFKit/PSPDFKit.h>

@interface DTViewController ()

@end

@implementation DTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

-(void)viewDidAppear:(BOOL)animated{

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *documentURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"PDF32000_2008.pdf"];
        
        PSPDFDocument *doc = [PSPDFDocument PDFDocumentWithURL:documentURL];
        
        PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:doc];
        pdfController.pageMode = PSPDFPageModeSingle;
        pdfController.pageTransition = PSPDFPageScrollContinuousTransition;
        pdfController.pageScrolling = PSPDFScrollDirectionVertical;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pdfController];
        [self presentViewController:navController animated:YES completion:nil];
    });
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
