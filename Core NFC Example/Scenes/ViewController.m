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

@property (nonatomic, strong) NFCNDEFReaderSession *session;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [_session invalidateSession];
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error
{
    NSLog(@"Error: %@", [error debugDescription]);
    
    switch (error.code) {
        case NFCReaderSessionInvalidationErrorUserCanceled:
        case NFCReaderSessionInvalidationErrorSessionTimeout:
            // Do not display alert when error was caused by:
            // - User cancellation
            // - Timeout
            return;
        default:
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:[NSString stringWithFormat:@"%@ (%ld)",
                                                                            [error localizedDescription],
                                                                            error.code]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Restart"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action){
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self beginSession];
                                                              });
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
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
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Payload"
                                                                   message:[NSString stringWithFormat:@"%@", data] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Scan another Tag"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self beginSession];
                                                              });
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

#pragma mark - Methods

- (void)beginSession
{
    _session
    = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                               queue:dispatch_queue_create(NULL,
                                                                           DISPATCH_QUEUE_CONCURRENT)
                            invalidateAfterFirstRead:YES];
    [_session beginSession];
}

#pragma mark - IBActions

- (IBAction)scan:(id)sender
{
    [self beginSession];
}

@end
