//
//  DTPDFToolBar.h
//  PDFKitPOC
//
//  Created by Jonathan Nolen on 1/21/13.
//  Copyright (c) 2013 Developertown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PSPDFKit/PSPDFKit.h>

@interface DTPDFToolbar : UIView

@property (nonatomic, weak) PSPDFViewController *pdfController;

- (IBAction)highlightButtonPressed:(id)sender;

@end
