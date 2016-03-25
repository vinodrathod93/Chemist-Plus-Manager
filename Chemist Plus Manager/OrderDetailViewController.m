//
//  OrderDetailViewController.m
//  Chemist Plus Manager
//
//  Created by adverto on 09/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "OrderDetailViewController.h"

@interface OrderDetailViewController ()
{
    
}
@property (nonatomic, strong) UIAlertController *cancelActionSheet;
@property (nonatomic, strong) UIAlertController *confirmActionSheet;

@property (nonatomic, strong) UIAlertView *otherReasonAlertView;
@property (nonatomic, strong) UIAlertView *successAlertView;

@end

NSString * const CONFIRMATION_WEBSERVICE_URL = @"http://neediator.in/vendor/vendorWS.asmx/Order_approved";
NSString * const CANCELLATION_WEBSERVICE_URL = @"http://neediator.in/vendor/vendorWS.asmx/Order_disapproved";

#define SUCCESSFULL_ID 1
#define FAKE_PHOTO_ID 2
#define OUT_OF_STOCK_ID 3
#define OTHER_REASON_ID 4

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"ViewDidLoad");
    self.view.backgroundColor = [UIColor whiteColor];
    self.customerName.text = self.customerNameString;
    self.phoneNumber.text = self.phoneNumberString;
    self.address.text = self.addressString;
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    
    [self loadActivityIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"%@",self.imageString);
        NSURL *url = [NSURL URLWithString:self.imageString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.prescriptionImage.image = [UIImage imageWithData:imageData];
        });
        
    });
}

-(void)loadActivityIndicator {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (IBAction)confirmPressed:(id)sender {
    [self showConfirmOptions];
}

- (IBAction)cancelPressed:(id)sender {
    [self showCancelOptions];
}

-(void)alertOnOtherReasonAction {
    self.otherReasonAlertView = [[UIAlertView alloc]initWithTitle:@"Other Reason" message:@" " delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [self.otherReasonAlertView setDelegate:self];
    [self.otherReasonAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [self.otherReasonAlertView addButtonWithTitle:@"Send"];
    [self.otherReasonAlertView addButtonWithTitle:@"Dismiss"];
    [self.otherReasonAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:self.otherReasonAlertView]) {
        if (buttonIndex == 0) {
            NSLog(@"Reason send");
            NSString *reasonString = [[alertView textFieldAtIndex:0] text];
            NSLog(@"%@",reasonString);
            
            [self sendTheCancellationStatusWithReasonID:OTHER_REASON_ID andReason:reasonString];
            
        } else
            NSLog(@"Not send");
    } else if ([alertView isEqual:self.successAlertView]) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}

-(void)showCancelOptions {
    self.cancelActionSheet = [UIAlertController alertControllerWithTitle:@"Select the Cancelling Reason" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                              
    UIAlertAction *fakePhoto = [UIAlertAction actionWithTitle:@"Fake Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Fake Photo");
        [self sendTheCancellationStatusWithReasonID:FAKE_PHOTO_ID andReason:@"Fake Photo"];
    }];
                              
                              UIAlertAction *outOfStock = [UIAlertAction actionWithTitle:@"Out of Stock" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Out of Stock");
        [self sendTheCancellationStatusWithReasonID:OUT_OF_STOCK_ID andReason:@"Out of Stock"];
    }];
                              
                              UIAlertAction *otherReason = [UIAlertAction actionWithTitle:@"Other Reason" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Other Reason");
        [self alertOnOtherReasonAction];
    }];
                              
                              UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.cancelActionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [self.cancelActionSheet addAction:fakePhoto];
    [self.cancelActionSheet addAction:outOfStock];
    [self.cancelActionSheet addAction:otherReason];
    [self.cancelActionSheet addAction:cancelAction];
    
    
    [self presentViewController:self.cancelActionSheet animated:YES completion:nil];
}

-(void)showConfirmOptions {
    self.confirmActionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure to Confirm the Selected Order" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes Confirm it." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Confirmed");
        [self sendTheConfirmationStatus];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.confirmActionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.confirmActionSheet addAction:confirmAction];
    [self.confirmActionSheet addAction:cancelAction];
    
    [self presentViewController:self.confirmActionSheet animated:YES completion:nil];
}


-(void)sendTheConfirmationStatus {
    NSString *sendDataString = [[NSString alloc] initWithFormat:@"id=%@",self.orderIDString];
    NSData *data = [NSData dataWithBytes:[sendDataString UTF8String] length:[sendDataString length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:CONFIRMATION_WEBSERVICE_URL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sendDataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *approvedArray = dictionary[@"approved"];
        
        NSLog(@"%@", approvedArray);
        NSString *message;
        
        if (approvedArray != nil && approvedArray.count != 0) {
            message = @"Order has been Successfully Confirmed";
        } else
            message = @"Order Could not be confirmed. Please Try again Later.";
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertOnActionPressed:message];
        });
    }];
    
    [task resume];
}


-(void)sendTheCancellationStatusWithReasonID:(int)reasonID andReason:(NSString *)reasonString {
    NSString *sendDataString = [[NSString alloc]initWithFormat:@"id=%@&reason=%@",self.orderIDString, reasonString];
    NSData *data = [NSData dataWithBytes:[sendDataString UTF8String] length:[sendDataString length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:CANCELLATION_WEBSERVICE_URL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sendDataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertOnActionPressed:responseString];
        });
    }];
    
    [task resume];
}

-(void)alertOnActionPressed:(NSString *)message {
    self.successAlertView = [[UIAlertView alloc]initWithTitle:@"Success" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [self.successAlertView show];
}

@end
