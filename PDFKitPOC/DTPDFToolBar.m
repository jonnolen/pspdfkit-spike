//
//  DTPDFToolBar.m
//  PDFKitPOC
//
//  Created by Jonathan Nolen on 1/21/13.
//  Copyright (c) 2013 Developertown. All rights reserved.
//

#import "DTPDFToolbar.h"
@interface DTPDFToolbar()<PSPDFAnnotationToolbarDelegate>

@property (nonatomic, strong) PSPDFAnnotationToolbar *toolbar;

@property (nonatomic, weak) IBOutlet UIButton *highlightButton;
@property (nonatomic, weak) IBOutlet UIButton *textButton;
@property (nonatomic, weak) IBOutlet UIButton *stickyNoteButton;

@end

@implementation DTPDFToolbar

-(void)awakeFromNib{
    [super awakeFromNib];
    
    NSArray *buttons = @[self.highlightButton, self.textButton, self.stickyNoteButton];
    
    for (UIButton *b in buttons){
        b.imageView.contentMode = UIViewContentModeScaleAspectFit;
        b.imageEdgeInsets = UIEdgeInsetsMake(10.0,10.0,10.0,10.0);
    }
    
}

-(void)setPdfController:(PSPDFViewController *)pdfController{
    _pdfController = pdfController;
    self.toolbar = [[PSPDFAnnotationToolbar alloc] initWithPDFController:pdfController];
    self.toolbar.delegate = self;
}

- (void)annotationToolbar:(PSPDFAnnotationToolbar *)annotationToolbar didChangeMode:(PSPDFAnnotationToolbarMode)newMode{
    NSLog(@"PSPDFAnnnotationToolbarMode mode changed: %d", newMode);
    [self.highlightButton setSelected:(newMode == PSPDFAnnotationToolbarHighlight)];
    [self.textButton setSelected:(newMode == PSPDFAnnotationToolbarFreeText)];
    [self.stickyNoteButton setSelected:(newMode == PSPDFAnnotationToolbarNote)];
}

- (IBAction)highlightButtonPressed:(id)sender{
    [self.toolbar highlightButtonPressed:sender];
}
- (IBAction)textButtonPressed:(id)sender{
    [self.toolbar freeTextButtonPressed:sender];
}
- (IBAction)stickyNoteButtonPressed:(id)sender{
    [self.toolbar noteButtonPressed:sender];
}

@end
