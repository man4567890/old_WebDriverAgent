/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "FBIntegrationTestCase.h"
#import "FBApplication.h"
#import "FBTestMacros.h"
#import "FBMacros.h"
#import "FBSession.h"
#import "FBXCodeCompatibility.h"
#import "XCUIElement+FBTyping.h"
#import "FBAlert.h"
#import "XCUIApplication+FBAlert.h"


@interface FBSafariAlertIntegrationTests : FBIntegrationTestCase
@property (nonatomic) FBSession *session;
@property (nonatomic) XCUIApplication *safariApp;
@end


static NSString *const SAFARI_BUNDLE_ID = @"com.apple.mobilesafari";

@implementation FBSafariAlertIntegrationTests

- (void)setUp
{
  [super setUp];
  self.session = [FBSession initWithApplication:FBApplication.fb_activeApplication];
  [self.session launchApplicationWithBundleId:SAFARI_BUNDLE_ID
                      shouldWaitForQuiescence:nil
                                    arguments:nil
                                  environment:nil];
  self.safariApp = self.session.activeApplication;
}

- (void)tearDown
{
  [self.session terminateApplicationWithBundleId:SAFARI_BUNDLE_ID];
}

- (void)disabled_testCanHandleSafariInputPrompt
{
  XCUIElement *urlInput = [[self.safariApp descendantsMatchingType:XCUIElementTypeTextField] matchingIdentifier:@"URL"].firstMatch;
  if (!urlInput.exists) {
    [[[self.safariApp descendantsMatchingType:XCUIElementTypeButton] matchingIdentifier:@"URL"].firstMatch tap];
  }
  XCTAssertTrue([urlInput fb_typeText:@"https://www.seleniumeasy.com/test/javascript-alert-box-demo.html"
                          shouldClear:YES
                                error:nil]);
  [[[self.safariApp descendantsMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Go"].firstMatch tap];
  XCUIElement *clickMeButton = [[self.safariApp descendantsMatchingType:XCUIElementTypeButton]
                                matchingPredicate:[NSPredicate predicateWithFormat:@"label == 'Click for Prompt Box'"]].firstMatch;
  XCTAssertTrue([clickMeButton waitForExistenceWithTimeout:15.0]);
  [clickMeButton tap];
  FBAlert *alert = [FBAlert alertWithApplication:self.safariApp];
  FBAssertWaitTillBecomesTrue([alert.text isEqualToString:@"Please enter your name"]);
  NSArray *buttonLabels = alert.buttonLabels;
  XCTAssertEqualObjects(buttonLabels.firstObject, @"Cancel");
  XCTAssertNotNil([self.safariApp fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButton[@label='Cancel' and @visible='true']"
                                       shouldReturnAfterFirstMatch:YES].firstObject);
  XCTAssertEqualObjects(buttonLabels.lastObject, @"OK");
  XCTAssertTrue([alert typeText:@"yolo" error:nil]);
  XCTAssertTrue([alert acceptWithError:nil]);
}

@end
