//
//  ViewController.m
//  Core NFC Example
//
//  The MIT License (MIT)
//
//  Copyright © 2017 Zhi-Wei Cai. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "ViewController.h"

@import CoreNFC;

@interface ViewController () <NFCNDEFReaderSessionDelegate>

@property (nonatomic, strong)   NFCNDEFReaderSession *session;
@property (nonatomic, strong)   NFCNDEFReaderSession *alert;

@property (nonatomic, weak)     IBOutlet UIButton *scanButton;
@property (nonatomic, weak)     IBOutlet UITextView *logView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scanButton.layer.cornerRadius = 4.f;
    _scanButton.layer.borderWidth  = 1.f;
    _scanButton.layer.borderColor  = _scanButton.currentTitleColor.CGColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [_session invalidateSession];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error
{
    NSLog(@"Error: %@", [error debugDescription]);
    
    if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
        // User cancellation.
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _logView.text = [NSString stringWithFormat:@"[%@] Error: %@ (%ld)\n%@",
                         [NSDate date],
                         [error localizedDescription],
                         error.code,
                         _logView.text];
    });
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages
{
    NSMutableData *data = [NSMutableData new];
    
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            if (payload.payload) {
                NSLog(@"Payload: %@", payload.payload);
                [data appendData:payload.payload];
            }
        }
    }
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _logView.text = [NSString stringWithFormat:@"[%@] Payload: %@ (%@)\n%@",
                         [NSDate date],
                         data,
                         dataString,
                         _logView.text];
    });
}

#pragma mark - Methods

- (void)beginSession
{
    _session
    = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                               queue:dispatch_queue_create(NULL,
                                                                           DISPATCH_QUEUE_CONCURRENT)
                            invalidateAfterFirstRead:NO];
    [_session beginSession];
}

#pragma mark - IBActions

- (IBAction)scan:(id)sender
{
    [self beginSession];
}

- (IBAction)clear:(id)sender
{
    _logView.text = @"";
}

@end
