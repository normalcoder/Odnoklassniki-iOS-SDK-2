//
//  MainViewController.m
//  APITestApp
//
//  Created by Build Macintosh on 17.08.12.
//  Copyright (c) 2012 SIA Forticom. All rights reserved.
//

#import "MainViewController.h"

static NSString * appID = @"App ID";
static NSString * appSecret = @"App Secret";
static NSString * appKey = @"App key";


@interface MainViewController ()
- (void)onLoginButTouch:(id)sender;

- (void)onLogoutButTouch:(id)sender;
@end

@implementation MainViewController
@synthesize api = _api;
@synthesize lbl = _lbl;
@synthesize logoutButton = _logoutButton;
@synthesize loginButton = _loginButton;
@synthesize avatar = _avatar;


- (void)viewDidLoad
{
	[super viewDidLoad];

	self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
	self.loginButton.frame = CGRectMake(10, 10, 80, 40);
	[self.loginButton addTarget:self action:@selector(onLoginButTouch:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.loginButton];

	self.logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
	_logoutButton.frame = CGRectMake(120, 10, 80, 40);
	_logoutButton.backgroundColor = [UIColor clearColor];
	[_logoutButton addTarget:self action:@selector(onLogoutButTouch:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_logoutButton];
	self.logoutButton.hidden = !self.api.isSessionValid;
	self.loginButton.hidden = self.api.isSessionValid;

	self.lbl = [[[UILabel alloc] initWithFrame:CGRectMake(10, 110, 300, 80)] autorelease];
	self.lbl.numberOfLines = 4;
	[self.view addSubview:self.lbl];

	self.avatar = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 50, 50)] autorelease];
	[self.view addSubview:self.avatar];

	/**
	* init Odnoklassniki API
	*/
	self.api = [[[Odnoklassniki alloc] initWithAppId:appID andAppSecret:appSecret andAppKey:appKey andDelegate:self] autorelease];
	//if session is still valid
	if(self.api.isSessionValid)
		[self okDidLogin];
}

-(void)onLoginButTouch:(id)sender{
	[self.api authorize:[NSArray arrayWithObjects:@"VALUABLE ACCESS", @"SET STATUS", nil]];
}

-(void)onLogoutButTouch:(id)sender{
	[self.api logout];
}

/*** Odnoklassniki Delegate methods ***/
-(void)okDidLogin {
	self.logoutButton.hidden = !self.api.isSessionValid;
	self.loginButton.hidden = self.api.isSessionValid;
	OKRequest *newRequest = [Odnoklassniki requestWithMethodName:@"users.getCurrentUser"
													   andParams:nil
												   andHttpMethod:@"GET"
													 andDelegate:self];
	[newRequest load];
}

-(void)okDidNotLogin:(BOOL)canceled {
	self.lbl.text = [NSString stringWithFormat:@"Did not login! Canceled = %@", canceled ? @"YES" : @"NO"];
}

-(void)okDidNotLoginWithError:(NSError *)error {
	NSLog(@"login error = %@", error.userInfo);
}

-(void)okDidExtendToken:(NSString *)accessToken {
	[self okDidLogin];
}

-(void)okDidNotExtendToken:(NSError *)error {
	self.lbl.text = @"Error: did not extend token!!";
}

-(void)okDidLogout {
	self.logoutButton.hidden = !self.api.isSessionValid;
	self.loginButton.hidden = self.api.isSessionValid;
	self.lbl.text = @"";
	self.avatar.image = nil;
}

/*** Request delegate ***/
-(void)request:(OKRequest *)request didLoad:(id)result {
	self.lbl.text = [NSString stringWithFormat:@"Name: %@, Surname: %@", [result valueForKey:@"first_name"], [result valueForKey:@"last_name"]];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURL *url = [NSURL URLWithString:[result valueForKey:@"pic_1"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
		dispatch_sync(dispatch_get_main_queue(), ^{
			self.avatar.image = img;
		});//end block
	});

}

-(void)request:(OKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Request failed with error = %@", error);
}

- (void)dealloc {
	[_api release];
	[_lbl release];
	[_logoutButton release];
	[_loginButton release];
	[_avatar release];
	[super dealloc];
}

@end
