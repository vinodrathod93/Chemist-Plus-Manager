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
    NSString *chemistID;
}
@property (nonatomic, strong) UIActionSheet *cancelActionSheet;
@property (nonatomic, strong) UIActionSheet *confirmActionSheet;

@property (nonatomic, strong) UIAlertView *otherReasonAlertView;
@property (nonatomic, strong) UIAlertView *successAlertView;

@end

NSString * const CONFIRMATION_WEBSERVICE_URL = @"http://chemistplus.in/chemist_order_confirmation.php";
NSString * const CANCELLATION_WEBSERVICE_URL = @"http://chemistplus.in/chemist_cancel_order.php";

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
    
    
    chemistID = [[NSString alloc]initWithFormat:@"12345"];
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
    self.cancelActionSheet = [[UIActionSheet alloc] init];
    [self.cancelActionSheet setDelegate:self];
    [self.cancelActionSheet setTitle:@"Select the Cancelling Reason"];
    [self.cancelActionSheet addButtonWithTitle:@"Fake Photo"];
    [self.cancelActionSheet addButtonWithTitle:@"Out of Stock"];
    [self.cancelActionSheet setDestructiveButtonIndex:[self.cancelActionSheet addButtonWithTitle:@"Other Reason"]];
    
    [self.cancelActionSheet setCancelButtonIndex:[self.cancelActionSheet addButtonWithTitle:@"Dismiss"]];
    
    [self.cancelActionSheet showInView:self.view];
}

-(void)showConfirmOptions {
    self.confirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to Confirm the Selected Order" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Yes Confirm it.", nil];
    
    [self.confirmActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:self.confirmActionSheet]) {
        if (buttonIndex == 0) {
            NSLog(@"Confirmed");
            [self sendTheConfirmationStatus];
        }
    } else if ([actionSheet isEqual:self.cancelActionSheet]) {
        if (buttonIndex == 0) {
            NSLog(@"Fake Photo");
            [self sendTheCancellationStatusWithReasonID:FAKE_PHOTO_ID andReason:@"Fake Photo"];
            
        } else if (buttonIndex == 1) {
            NSLog(@"Out of Stock");
            [self sendTheCancellationStatusWithReasonID:OUT_OF_STOCK_ID andReason:@"Out of Stock"];
        } else if (buttonIndex == 2) {
            NSLog(@"Other Reason");
            [self alertOnOtherReasonAction];
        }
    }
}

-(void)sendTheConfirmationStatus {
    NSString *sendDataString = [[NSString alloc] initWithFormat:@"order_id=%@&chemist_id=%@",self.orderIDString,chemistID];
    NSData *data = [NSData dataWithBytes:[sendDataString UTF8String] length:[sendDataString length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:CONFIRMATION_WEBSERVICE_URL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[sendDataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *message;
        
        if ([responseString isEqualToString:@"1"]) {
            message = @"Order has been Successfully Confirmed";
        } else if ([responseString isEqualToString:@"0"]) {
            message = @"Order Could not be confirmed. Please Try again Later.";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertOnActionPressed:message];
        });
    }];
    
    [task resume];
}


-(void)sendTheCancellationStatusWithReasonID:(int)reasonID andReason:(NSString *)reasonString {
    NSString *sendDataString = [[NSString alloc]initWithFormat:@"order_id=%@&chemist_id=%@&reason_id=%d&reason_string=%@",self.orderIDString, chemistID, reasonID, reasonString];
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
