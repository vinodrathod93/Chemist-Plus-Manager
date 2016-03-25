//
//  VendorLoginViewController.m
//  Neediator Partner
//
//  Created by adverto on 22/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "VendorLoginViewController.h"
#import "NSString+Validation.h"
#import "Vendor.h"


#define kSignInURL @"http://neediator.in/NeediatorWS.asmx/vendorcheckLogin"

@interface VendorLoginViewController ()


@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

typedef void(^completion)(BOOL finished);

@implementation VendorLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.usernameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}

- (IBAction)loginPressed:(id)sender {
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Error" message:errorMessage];
    } else {
        
        [self submitSigninDataWithCompletion:^(BOOL finished) {
            if (finished) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    NSLog(@"Logged In");
                    
                }];
                
            } else
                NSLog(@"Could not login");
        }];
        
        
    }
    
}


-(NSString *)validateForm {
    NSString *errorMessage;
    
    if (![self.usernameTF.text isValidVendorID]) {
        errorMessage = @"Enter valid vendor username";
    } else if (![self.passwordTF.text isValidPassword]) {
        errorMessage = @"Enter valid password";
    }
    
    return errorMessage;
}

-(void)submitSigninDataWithCompletion:(completion)isLoggedIn {
    
    NSURL *url = [NSURL URLWithString:kSignInURL];
    NSString *user_data = [NSString stringWithFormat:@"username=%@&password=%@",self.usernameTF.text, self.passwordTF.text];
    NSData *post_data = [NSData dataWithBytes:[user_data UTF8String] length:[user_data length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = post_data;
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *jsonError;
                
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                [self hideHUD];
                
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if ([[json valueForKey:@"isError"] boolValue] == true) {
                        NSString *error = [json valueForKey:@"errors"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                        isLoggedIn(NO);
                        
                    } else if (url_response.statusCode == 200) {
                        NSLog(@"JSON %@",json);
                        
                        NSArray *login     = [json valueForKey:@"signin"];
                        NSDictionary *data = [login lastObject];
                        
                        Vendor *vendor              = [[Vendor alloc]init];
                        vendor.vendorID             = [data valueForKey:@"id"];
                        vendor.email              = [data valueForKey:@"username"];
                        vendor.addresses          = [data objectForKey:@"addresslist"];
                        
                        [vendor save];
                        
                        isLoggedIn(YES);
                    }
                }
                
                
            });
        } else {
            [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    [self showHUD];
    
    
}



-(void)showHUD {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    
    
    [self.activityIndicator startAnimating];
}

-(void)hideHUD {
    [self.activityIndicator stopAnimating];
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHUD];
        UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [failed_alert show];
    });
}



@end
