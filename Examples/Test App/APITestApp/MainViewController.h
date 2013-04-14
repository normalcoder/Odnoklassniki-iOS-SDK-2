//
//  MainViewController.h
//  APITestApp
//
//  Created by Build Macintosh on 17.08.12.
//  Copyright (c) 2012 SIA Forticom. All rights reserved.
//

#import "Odnoklassniki.h"

@interface MainViewController : UIViewController<OKSessionDelegate, OKRequestDelegate>{
	Odnoklassniki *_api;
	UILabel *_lbl;

	UIButton *_logoutButton;
	UIButton *_loginButton;

	UIImageView *_avatar;
}
@property(nonatomic, retain) Odnoklassniki *api;
@property(nonatomic, retain) UILabel *lbl;
@property(nonatomic, retain) UIButton *logoutButton;
@property(nonatomic, retain) UIButton *loginButton;
@property(nonatomic, retain) UIImageView *avatar;


@property(nonatomic, retain) OKRequest *newRequest;
@end
