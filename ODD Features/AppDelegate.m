//
//  AppDelegate.m
//  ODD Features
//
//  Created by Yuxin Wang on 2018/8/6.
//  Copyright © 2018 Yuxin Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "MMCDevices.h"
#import "FeatureData.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property NSArray* devices;
@property NSArray* features;
@property NSArray* featureDetails;
@property NSString* status;

@property NSMutableDictionary* cachedFeatures;
@property NSMutableDictionary* cachedFeatureDetails;

@property (weak) IBOutlet NSArrayController *deviceArrayController;
@property (weak) IBOutlet NSArrayController *featureArrayController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.deviceArrayController addObserver:self forKeyPath:@"self.selectedObjects" options:NSKeyValueObservingOptionNew context:nil];
    [self.featureArrayController addObserver:self forKeyPath:@"self.selectedObjects" options:NSKeyValueObservingOptionNew context:nil];

    [self refreshDevices:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)refreshDevices:(id)sender {
    self.cachedFeatures = [NSMutableDictionary dictionaryWithCapacity:8];
    self.devices = [MMCDevices devices];
}

- (IBAction)refreshFeatures:(id)sender {
    [self updateFeaturesWithCache:NO];
}

- (IBAction)runAACSAuth:(id)sender {
    NSArray* devs = [self.deviceArrayController selectedObjects];
    if (devs.count == 0) return;
    uint64_t node = [devs[0][@"id"] unsignedLongLongValue];
    if (!node) return;

    BOOL __block isBD = NO, isAACS = NO;
    [self updateFeaturesWithCache:NO];
    [self.features enumerateObjectsUsingBlock:^(NSDictionary *feature, NSUInteger idx, BOOL *stop) {
        if ([feature[@"current"] isEqual: @"Yes"]) {
            switch ([feature[@"id"] integerValue]) {
                case 0x40:
                    isBD = YES;
                    break;
                case 0x10D:
                    isAACS = YES;
                    break;
                default:
                    break;
            }
        }
    }];

    NSString* name = [MMCDevices getMediaBSDName:node];

    if (!isBD || !isAACS || !name) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please insert an AACS protected\nBlu-ray disc.";
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }

    NSAlert *aacsPanel = [[NSAlert alloc] init];
    aacsPanel.messageText = [NSString stringWithFormat:@"Running AACS Authentication on “%@“", name];
    aacsPanel.informativeText = @"Please wait...";
    [aacsPanel addButtonWithTitle:@"Done"].enabled = NO;

    [aacsPanel beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];

    @try {
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;

        NSTask *task = [[NSTask alloc] init];
        task.launchPath = [[NSBundle mainBundle] pathForResource:@"aacs-auth" ofType:@""];
        NSMutableArray* args = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aacs-auth" ofType:@"plist"]];
        [args addObject:name];
        task.arguments = args;
        task.standardOutput = pipe;
        task.standardError = pipe;
        task.terminationHandler = ^(NSTask* task) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                NSData *data = [file readDataToEndOfFile];
                [file closeFile];

                if (task.terminationStatus) {
                    aacsPanel.messageText = [NSString stringWithFormat:@"AACS Authentication Failed on “%@“", name];
                } else {
                    aacsPanel.messageText = [NSString stringWithFormat:@"AACS Authentication Succeded on “%@“", name];
                }
                NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                aacsPanel.informativeText = output;
                aacsPanel.buttons[0].enabled = YES;
                [aacsPanel layout];
            });
        };

        [task launch];

    } @catch (NSException *e) {
        aacsPanel.informativeText = [NSString stringWithFormat:@"An unexpected exception occurred.\n\n%@\n%@", e.name, e.reason];
        aacsPanel.buttons[0].enabled = YES;
        [aacsPanel layout];
    }
}

- (IBAction)deviceOpenTray:(id)sender {
    NSArray* devs = [self.deviceArrayController selectedObjects];
    if (devs.count == 0) return;
    uint64_t node = [devs[0][@"id"] unsignedLongLongValue];
    if (!node) return;
    [MMCDevices openTray:node];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.deviceArrayController) {
        [self updateFeaturesWithCache:YES];
    } else if (object == self.featureArrayController) {
        [self updateFeatureDetails];
    }
}

- (void)updateFeaturesWithCache:(BOOL)useCache {
    if (!self.devices.count) {
        self.status = @"No optical disk drives were found.";
        return;
    }

    NSArray* devs = [self.deviceArrayController selectedObjects];
    if (devs.count == 0) {
        self.status = @"";
        return;
    }

    uint64_t node = [devs[0][@"id"] unsignedLongLongValue];
    if (!node) return;

    NSDictionary* cached;
    if (useCache) {
        cached = self.cachedFeatures[@(node)];
    }

    if (!cached) {
        NSArray* confs = [MMCDevices getConfiguration:node];
        NSMutableArray *feats = [NSMutableArray arrayWithCapacity:confs.count];
        for (NSData* data in confs) {
            NSDictionary* dict = [FeatureData parseHeader:data];
            if (dict) {
                [feats addObject:dict];
            }
        }
        cached = @{@"features": feats, @"date":NSDate.date};
        self.cachedFeatures[@(node)] = cached;
    }
    if (self.features != cached[@"features"]) {
        NSNumber* selectedNumber;
        NSArray* selected = self.featureArrayController.selectedObjects;
        if (selected.count) {
            selectedNumber = selected[0][@"id"];
        }

        self.cachedFeatureDetails = [NSMutableDictionary dictionaryWithCapacity:self.features.count];
        self.features = cached[@"features"];

        if (selectedNumber) {
            for (NSDictionary* d in self.features) {
                if (d[@"id"] == selectedNumber) {
                    [self.featureArrayController setSelectedObjects:@[d]];
                    break;
                }
            }
        }
    }
    NSString* vendorName = [self.deviceArrayController valueForKeyPath:@"selectedObjects.raw.Device Characteristics.Vendor Name"][0];
    NSString* productName = [self.deviceArrayController valueForKeyPath:@"selectedObjects.raw.Device Characteristics.Product Name"][0];
    NSString* name = [NSString stringWithFormat:@"%@ %@", vendorName, productName];
    name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* date = [dateFormatter stringFromDate:cached[@"date"]];
    self.status = [NSString stringWithFormat:@"%@. Updated on %@.", name, date];
}

- (void)updateFeatureDetails {
    NSArray* feats = [self.featureArrayController selectedObjects];
    if (feats.count == 0) {
        return;
    }
    id num = feats[0][@"id"];

    NSArray* details = self.cachedFeatureDetails[num];
    if (!details) {
        details = [FeatureData parse:feats[0][@"raw"]];
        if (!details) details = @[@{@"key":@"Error", @"value":@"An issue occurred during data parsing."}];
        self.cachedFeatureDetails[num] = details;
    }

    if (self.featureDetails != details) {
        self.featureDetails = details;
    }
}

@end
