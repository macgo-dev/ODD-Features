//
//  MMCDevices.m
//  ODD Features
//
//  Created by Yuxin Wang on 2018/8/7.
//  Copyright © 2018 Yuxin Wang. All rights reserved.
//

#import "MMCDevices.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/scsi/SCSITaskLib.h>

@implementation MMCDevices

+ (NSArray<NSDictionary*>*)devices {
    CFMutableDictionaryRef matchingDict = IOServiceMatching("IOCDBlockStorageDevice");
    if (!matchingDict) {
        return nil;
    }

    io_iterator_t deviceIterator;
    io_service_t service;
    kern_return_t rc;

    rc = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &deviceIterator);
    if (kIOReturnSuccess != rc) {
        return nil;
    }

    NSMutableArray *devs = [NSMutableArray arrayWithCapacity:4];

    while (0 != (service = IOIteratorNext (deviceIterator))) {

        CFMutableDictionaryRef properties = nil;
        if (kIOReturnSuccess == IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0)) {
            NSDictionary* dict = (__bridge_transfer NSDictionary*)properties;
            uint64_t entryID = 0;
            if (kIOReturnSuccess == IORegistryEntryGetRegistryEntryID(service, &entryID)) {
                [devs addObject:@{@"id":@(entryID),
                                  @"raw":dict
                                  }];
            }
        }

        IOObjectRelease(service);
    }

    IOObjectRelease(deviceIterator);

    return devs;
}

static kern_return_t runWithMMC(uint64_t entryID, kern_return_t (^callback)(MMCDeviceInterface**)) {
    CFMutableDictionaryRef matchingDict = IORegistryEntryIDMatching(entryID);
    if (!matchingDict) {
        return kIOReturnNoMemory;
    }

    io_iterator_t deviceIterator;
    kern_return_t rc;

    rc = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &deviceIterator);
    if (kIOReturnSuccess != rc) {
        return rc;
    }

    io_service_t service = IOIteratorNext(deviceIterator);
    IOObjectRelease(deviceIterator);

    if (!service) {
        return kIOReturnNoDevice;
    }

    IOCFPlugInInterface **plugInInterface = NULL;
    MMCDeviceInterface **mmcInterface = NULL;
    SInt32 score;

    rc = IOCreatePlugInInterfaceForService (service, kIOMMCDeviceUserClientTypeID,
                                            kIOCFPlugInInterfaceID, &plugInInterface,
                                            &score);
    if (kIOReturnSuccess == rc && plugInInterface) {
        rc = (*plugInInterface)->QueryInterface(plugInInterface,
                                                CFUUIDGetUUIDBytes(kIOMMCDeviceInterfaceID),
                                                (LPVOID)&mmcInterface);
        if (kIOReturnSuccess == rc && mmcInterface) {
            rc = callback(mmcInterface);
            (*mmcInterface)->Release(mmcInterface);
        }
        IODestroyPlugInInterface(plugInInterface);
    }

    IOObjectRelease(service);
    return rc;
}

+ (NSArray<NSData*>*)getConfiguration:(uint64_t)entryID {
    NSArray * __block ret = nil;

    runWithMMC(entryID, ^(MMCDeviceInterface** mmcInterface){
        NSMutableArray* confs = [NSMutableArray arrayWithCapacity:1];
        int feature = 0;
        kern_return_t rc = kIOReturnSuccess;
        while (YES) {
            const int size = 0xFFFF;
            NSMutableData* buffer = [NSMutableData  dataWithLength:size];
            uint8_t* ptr = buffer.mutableBytes;

            SCSITaskStatus status;
            SCSI_Sense_Data sense;
            rc = (*mmcInterface)->GetConfiguration(mmcInterface, 0, feature,
                                                                 ptr, size,
                                                                 &status, &sense);
            if (kIOReturnSuccess != rc) {
                break;
            }

            uint32_t len = CFSwapInt32BigToHost(*(uint32_t*)ptr);
            int offset = 8;
            while (offset - 4 < len) {
                if (offset + 4 >= size) {
                    break;
                }
                int add = ptr[offset + 3] + 4;
                if (offset + add >= size) {
                    break;
                }
                [confs addObject:[buffer subdataWithRange:NSMakeRange(offset, add)]];
                offset += add;
            }
            if (offset - 4 >= len) {
                break;
            }
            if (!confs.count) {
                break;
            }
            NSData* last = confs.lastObject;
            feature = (int)CFSwapInt16BigToHost(*(uint16_t*)last.bytes) + 1;
            if (feature > 0xFFFF) {
                break;
            }
        }
        ret = confs;
        return rc;
    });

    return ret;
}

+ (BOOL)openTray:(uint64_t)entryID {
    BOOL __block ret = NO;
    runWithMMC(entryID, ^(MMCDeviceInterface** mmcInterface){
        kern_return_t rc = (*mmcInterface)->SetTrayState(mmcInterface, kMMCDeviceTrayOpen);
        if (kIOReturnSuccess == rc) {
            ret = YES;
        }
        return rc;
    });
    return ret;
}

+ (NSString*)getMediaBSDName:(uint64_t)entryID {
    CFMutableDictionaryRef matchingDict = IORegistryEntryIDMatching(entryID);
    if (!matchingDict) {
        return nil;
    }

    io_iterator_t deviceIterator;
    kern_return_t rc;

    rc = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &deviceIterator);
    if (kIOReturnSuccess != rc) {
        return nil;
    }

    io_service_t service = IOIteratorNext(deviceIterator);
    IOObjectRelease(deviceIterator);

    if (!service) {
        return nil;
    }

    NSString *name = nil;

    CFStringRef n = IORegistryEntrySearchCFProperty(service, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively);
    name = (__bridge_transfer NSString*)n;

    IOObjectRelease(service);
    return name;
}
@end
