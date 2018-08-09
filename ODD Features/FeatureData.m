//
//  FeatureData.m
//  ODD Features
//
//  Created by Yuxin Wang on 2018/8/8.
//  Copyright © 2018 Yuxin Wang. All rights reserved.
//

#import "FeatureData.h"

static NSString* kFeatureNameTable[] = {
    [0x0000] = @"Profile List",
    [0x0001] = @"Core",
    [0x0002] = @"Morphing",
    [0x0003] = @"Removable Medium",
    [0x0004] = @"Write Protect",
    [0x0010] = @"Random Readable",
    [0x001D] = @"MultiRead",
    [0x001E] = @"CD Read",
    [0x001F] = @"DVD Read",
    [0x0020] = @"Random Writable",
    [0x0021] = @"Incremental Streaming Writable",
    [0x0022] = @"Sector Erasable",
    [0x0023] = @"Formattable",
    [0x0024] = @"Hardware Defect Management",
    [0x0025] = @"Write Once",
    [0x0026] = @"Restricted Overwrite",
    [0x0027] = @"CD-RW CAV Write",
    [0x0028] = @"MRW",
    [0x0029] = @"Enhanced Defect Reporting",
    [0x002A] = @"DVD+RW",
    [0x002B] = @"DVD+R",
    [0x002C] = @"Rigid Restricted Overwrite",
    [0x002D] = @"CD Track-at-Once",
    [0x002E] = @"CD Mastering",
    [0x002F] = @"DVD-R/-RW Write",
    [0x0030] = @"DDCD Read",
    [0x0031] = @"DDCD-R Write",
    [0x0032] = @"DDCD-RW Write",
    [0x0033] = @"Layer Jump recording",
    [0x0034] = @"LJ Rigid Restricted Overwrite",
    [0x0035] = @"Stop Long Operation",
    [0x0037] = @"CD-RW Media Write Support",
    [0x0038] = @"BD-R Pseudo Overwrite",
    [0x003A] = @"DVD+RW Dual Layer",
    [0x003B] = @"DVD+R Dual Layer",
    [0x0040] = @"BD Read",
    [0x0041] = @"BD Write",
    [0x0042] = @"TSR",
    [0x0050] = @"HD DVD Read",
    [0x0051] = @"HD DVD Write",
    [0x0052] = @"HD DVD-RW Fragment Recording",
    [0x0080] = @"Hybrid disc",
    [0x0100] = @"Power Management",
    [0x0101] = @"S.M.A.R.T.",
    [0x0102] = @"Embedded Changer",
    [0x0103] = @"CD Audio analog play",
    [0x0104] = @"Microcode Upgrade",
    [0x0105] = @"Timeout",
    [0x0106] = @"DVD CSS",
    [0x0107] = @"Real-Time Streaming",
    [0x0108] = @"Logical unit Serial Number",
    [0x0109] = @"Media Serial Number",
    [0x010A] = @"Disc Control Blocks",
    [0x010B] = @"DVD CPRM",
    [0x010C] = @"Firmware Information",
    [0x010D] = @"AACS",
    [0x010E] = @"DVD CSS Managed recording",
    [0x010F] = @"AACS2",
    [0x0110] = @"VCPS",
    [0x0113] = @"SecurDisc",
    [0x0142] = @"OSSC Feature"
};

static NSString* getFeatureName(uint16_t feature) {
    if (feature < (sizeof(kFeatureNameTable)/sizeof(kFeatureNameTable[0]))) {
        NSString* name = kFeatureNameTable[feature];
        if (name)
            return name;
    }
    if (feature >= 0xFF00 && feature <= 0xFFFF)
        return @"Vendor Unique";
    return @"Reserved";
}

static NSString* kProfileNameTable[] = {
    [0x0001] = @"Non-removable disk",
    [0x0002] = @"Removable disk",
    [0x0003] = @"MO Erasable",
    [0x0004] = @"MO Write Once",
    [0x0005] = @"AS-MO",
    [0x0008] = @"CD-ROM",
    [0x0009] = @"CD-R",
    [0x000A] = @"CD-RW",
    [0x0010] = @"DVD-ROM",
    [0x0011] = @"DVD-R Sequential recording",
    [0x0012] = @"DVD-RAM",
    [0x0013] = @"DVD-RW Restricted Overwrite",
    [0x0014] = @"DVD-RW Sequential recording",
    [0x0015] = @"DVD-R Dual Layer Sequential recording",
    [0x0016] = @"DVD-R Dual Layer Jump recording",
    [0x0017] = @"DVD-RW Dual Layer",
    [0x0018] = @"DVD-Download disc recording",
    [0x001A] = @"DVD+RW",
    [0x001B] = @"DVD+R",
    [0x0020] = @"DDCD-ROM",
    [0x0021] = @"DDCD-R",
    [0x0022] = @"DDCD-RW",
    [0x002A] = @"DVD+RW Dual Layer",
    [0x002B] = @"DVD+R Double Layer",
    [0x0040] = @"BD-ROM",
    [0x0041] = @"BD-R Sequential Recording Mode (SRM)",
    [0x0042] = @"BD-R Random Recording Mode (RRM)",
    [0x0043] = @"BD-RE",
    [0x0050] = @"HD DVD-ROM",
    [0x0051] = @"HD DVD-R",
    [0x0052] = @"HD DVD-RAM",
    [0x0053] = @"HD DVD-RW",
    [0x0058] = @"HD DVD-R Dual Layer",
    [0x005A] = @"HD DVD-RW Dual Layer",
};

static NSString* getProfileName(uint16_t profile) {
    if (profile < (sizeof(kProfileNameTable)/sizeof(kProfileNameTable[0]))) {
        NSString* name = kProfileNameTable[profile];
        if (name)
            return name;
    }
    if (profile == 0xFFFF) {
        return @"Logical units Not Conforming to a Standard Profile";
    }
    return @"Reserved";
}

static NSString* getBe32Repr(const uint8_t* b) {
    return [NSString stringWithFormat:@"%02X%02X%02X%02Xh", b[0], b[1], b[2], b[3]];
}

static NSString* getBe24Repr(const uint8_t* b) {
    return [NSString stringWithFormat:@"%02X%02X%02Xh", b[0], b[1], b[2]];
}

static NSString* getBe16Repr(const uint8_t* b) {
    return [NSString stringWithFormat:@"%02X%02Xh", b[0], b[1]];
}

static NSString* getU32Repr(uint32_t u) {
    return [NSString stringWithFormat:@"%08Xh", u];
}

static NSString* getU16Repr(uint16_t u) {
    return [NSString stringWithFormat:@"%04Xh", u];
}

static NSString* getU8Repr(uint8_t u) {
    return [NSString stringWithFormat:@"%02Xh", u];
}

static NSString* getU4Repr(uint8_t u) {
    return [NSString stringWithFormat:@"%Xh", u];
}

static NSString* getFlagRepr(BOOL b) {
    return b ? @"Yes" : @"No";
}

static NSString* getStringRepr(const uint8_t* p, NSUInteger s) {
    NSMutableData *data = [NSMutableData dataWithBytes:p length:s];
    uint8_t* buffer = data.mutableBytes;
    for (int i = 0; i < s; i++) {
        uint8_t ch = buffer[i];
        if (ch < 0x20 || ch > 0x7E) {
            buffer[i] = '?';
        }
    }
    NSString* str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

#define CheckSize(s)  if (size < (s) + 4) return nil;

static NSArray* parseFeature0000(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    NSUInteger len = size - 4;
    ptr += 4;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:len / 4];
    for (int i = 0; i < len; i += 4) {
        uint16_t profile = CFSwapInt16BigToHost(*(uint16_t*)&ptr[i]);
        NSString *number = [NSString stringWithFormat:@"Profile %04Xh", profile];
        NSString *name = getProfileName(profile);
        bool actived = ptr[i + 2] & 1;
        if (actived) {
            name = [name stringByAppendingString:@" (Active)"];
        }
        [array addObject:@{@"key":number,  @"value":name}];
    }
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* s1 = obj1[@"key"];
        NSString* s2 = obj2[@"key"];
        return [s1 compare:s2];
    }];
    return array;
}

static NSArray* parseFeature0001(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    uint32_t intf = CFSwapInt32BigToHost(*(uint32_t*)&ptr[4]);
    NSString* pis = getU32Repr(intf);
    static NSString* pisNameTable[9] = {
        @"Unspecified",
        @"SCSI Family",
        @"ATAPI",
        @"IEEE 1394-1995 Family",
        @"IEEE 1394a",
        @"Fibre Channel",
        @"IEEE 1394b",
        @"Serial ATAPI",
        @"USB"
    };
    if (intf < sizeof(pisNameTable)/sizeof(pisNameTable[0])) {
        pis = [pis stringByAppendingFormat:@" (%@)", pisNameTable[intf]];
    }
    return @[@{@"key":@"Physical Interface Standard",       @"value":pis},
             @{@"key":@"INQ2",                              @"value":getFlagRepr(ptr[8] & 2)},
             @{@"key":@"DBEvent",                           @"value":getFlagRepr(ptr[8] & 1)}];
}

static NSArray* parseFeature0002(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"OCEvent",                           @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Async",                             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0003(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    static NSString* loadingTypeTable[8] = {
        @"Caddy/Slot type loading mechanism",
        @"Tray type loading mechanism",
        @"Pop-up type loading mechanism",
        @"Reserved",
        @"Embedded changer with individually changeable discs",
        @"Embedded changer using a Magazine mechanism",
        @"Reserved",
        @"Reserved"
    };
    uint8_t loadingType = (ptr[4] >> 5) & 0x7;
    NSString* name = [NSString stringWithFormat:@"%i (%@)", loadingType, loadingTypeTable[loadingType]];
    return @[@{@"key":@"Loading Mechanism Type",            @"value":name},
             @{@"key":@"Load",                              @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"Eject",                             @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Prevent Jumper",                    @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"DBML",                              @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Lock",                              @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0004(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Disc Write Protect PAC (DWP)",      @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Write Inhibit DCB (WDCB)",          @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"Supports PWP (SPWP)",               @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Supports SWPP (SSWPP)",             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0010(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    return @[@{@"key":@"Logical Block Size",                @"value":getBe32Repr(&ptr[4])},
             @{@"key":@"Blocking",                          @"value":getBe16Repr(&ptr[8])},
             @{@"key":@"Page Present",                      @"value":getFlagRepr(ptr[10] & 1)}];
}

static NSArray* parseFeature001D(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature001E(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"DAP",                               @"value":getFlagRepr(ptr[4] & 0x80)},
             @{@"key":@"C2",                                @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"CD-Text",                           @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature001F(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"DVD Multi Version 1.1 (MULTI110)",  @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"DVD-RW Dual Layer (Dual-RW)",       @"value":getFlagRepr(ptr[6] & 2)},
             @{@"key":@"DVD-R Dual Layer (Dual-R)",         @"value":getFlagRepr(ptr[6] & 1)}];
}

static NSArray* parseFeature0020(const uint8_t* ptr, NSUInteger size) {
    CheckSize(0xC);
    return @[@{@"key":@"Last LBA",                          @"value":getBe32Repr(&ptr[4])},
             @{@"key":@"Logical Block Size",                @"value":getBe32Repr(&ptr[8])},
             @{@"key":@"Blocking",                          @"value":getBe16Repr(&ptr[12])},
             @{@"key":@"Page Present",                      @"value":getFlagRepr(ptr[14] & 1)}];
}

static NSArray* parseFeature0021(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Data Block Type Supported",         @"value":getBe16Repr(&ptr[4])},
             @{@"key":@"TRIO",                              @"value":getFlagRepr(ptr[6] & 4)},
             @{@"key":@"ARSV",                              @"value":getFlagRepr(ptr[6] & 2)},
             @{@"key":@"BUF",                               @"value":getFlagRepr(ptr[6] & 1)},
             @{@"key":@"Number of Link Sizes",              @"value":getU8Repr(ptr[7])},
             @{@"key":@"Link Sizes",                        @"value":[NSData dataWithBytes:&ptr[8] length:MIN(size - 8, ptr[7])]}];
}

static NSArray* parseFeature0022(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0023(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    return @[@{@"key":@"RENoSA (BD-RE)",                    @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Expand (BD-RE)",                    @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"QCert (BD-RE)",                     @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Cert (BD-RE)",                      @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"FRF (DVD-RW DL)",                   @"value":getFlagRepr(ptr[5] & 0x80)},
             @{@"key":@"RRM (BD-R)",                        @"value":getFlagRepr(ptr[8] & 1)}];
}

static NSArray* parseFeature0024(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"SSA", @"value":getFlagRepr(ptr[4] & 0x80)}];
}

static NSArray* parseFeature0025(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    return @[@{@"key":@"Logical Block Size",                @"value":getBe32Repr(&ptr[4])},
             @{@"key":@"Blocking",                          @"value":getBe16Repr(&ptr[8])},
             @{@"key":@"Page Present",                      @"value":getFlagRepr(ptr[10] & 1)}];
}

static NSArray* parseFeature0026(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0027(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0028(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"DVD+ Write",                        @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"DVD+ Read",                         @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"CD Write",                          @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0029(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"DRT-DM",                            @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Number of DBI cache zones",         @"value":getU8Repr(ptr[5])},
             @{@"key":@"Number of entries",                 @"value":getBe16Repr(&ptr[6])}];
}

static NSArray* parseFeature002A(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Write",                             @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Quick Start",                       @"value":getFlagRepr(ptr[5] & 2)},
             @{@"key":@"Close Only",                        @"value":getFlagRepr(ptr[5] & 1)}];
}

static NSArray* parseFeature002B(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Write",                             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature002C(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Defect Status Data Generate (DSDG)",@"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Defect Status Data Read (DSDR)",    @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"Intermediate",                      @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Blank",                             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature002D(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Buffer Underrun Free (BUF)",        @"value":getFlagRepr(ptr[4] & 0x40)},
             @{@"key":@"R-W Raw",                           @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"R-W Pack",                          @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Test Write",                        @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"CD-RW",                             @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"R-W Subcode",                       @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Data Block Type Supported",         @"value":getBe16Repr(&ptr[6])}];
}

static NSArray* parseFeature002E(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Buffer Underrun Free (BUF)",        @"value":getFlagRepr(ptr[4] & 0x40)},
             @{@"key":@"Session-at-Once (SAO)",             @"value":getFlagRepr(ptr[4] & 0x20)},
             @{@"key":@"Raw Multisession (Raw MS)",         @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"Raw",                               @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Test Write",                        @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"CD-RW",                             @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"R-W",                               @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Maximum Cue Sheet Length",          @"value":getBe24Repr(&ptr[5])}];
}

static NSArray* parseFeature002F(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Buffer Underrun Free (BUF)",        @"value":getFlagRepr(ptr[4] & 0x40)},
             @{@"key":@"RDL",                               @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Test Write",                        @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"DVD-RW SL",                         @"value":getFlagRepr(ptr[4] & 2)}];
}

static NSArray* parseFeature0030(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0031(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Test Write",                        @"value":getFlagRepr(ptr[4] & 4)}];
}

static NSArray* parseFeature0032(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Intermediate",                      @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Blank",                             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0033(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Number of Link Sizes",              @"value":getU8Repr(ptr[7])},
             @{@"key":@"Link Sizes",                        @"value":[NSData dataWithBytes:&ptr[8] length:MIN(size - 8, ptr[7])]}];
}

static NSArray* parseFeature0034(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Close Layer Jump Block (CLJB)",     @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Buffer Block size",                 @"value":getU8Repr(ptr[7])}];
}

static NSArray* parseFeature0035(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0037(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"CD-RW media sub-type support",      @"value":getU8Repr(ptr[4])}];
}

static NSArray* parseFeature0038(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature003A(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Write",                             @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Quick Start",                       @"value":getFlagRepr(ptr[5] & 2)},
             @{@"key":@"Close Only",                        @"value":getFlagRepr(ptr[5] & 1)}];
}

static NSArray* parseFeature003B(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Write",                             @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0040(const uint8_t* ptr, NSUInteger size) {
    CheckSize(0x1C);
    return @[@{@"key":@"BCA",                               @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"BD-RE3",                            @"value":getFlagRepr(ptr[9] & 8)},
             @{@"key":@"BD-RE2",                            @"value":getFlagRepr(ptr[9] & 4)},
             @{@"key":@"BD-RE1",                            @"value":getFlagRepr(ptr[9] & 2)},
             @{@"key":@"BD-R2",                             @"value":getFlagRepr(ptr[17] & 4)},
             @{@"key":@"BD-R1",                             @"value":getFlagRepr(ptr[17] & 2)},
             @{@"key":@"BD-ROM2",                           @"value":getFlagRepr(ptr[25] & 4)},
             @{@"key":@"BD-ROM1",                           @"value":getFlagRepr(ptr[25] & 2)}];
}

static NSArray* parseFeature0041(const uint8_t* ptr, NSUInteger size) {
    CheckSize(0x14);
    return @[@{@"key":@"SVNR",                              @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"BD-RE3",                            @"value":getFlagRepr(ptr[9] & 8)},
             @{@"key":@"BD-RE2",                            @"value":getFlagRepr(ptr[9] & 4)},
             @{@"key":@"BD-RE1",                            @"value":getFlagRepr(ptr[9] & 2)},
             @{@"key":@"BD-R2",                             @"value":getFlagRepr(ptr[17] & 4)},
             @{@"key":@"BD-R1",                             @"value":getFlagRepr(ptr[17] & 2)}];
}

static NSArray* parseFeature0042(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0050(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    return @[@{@"key":@"HD DVD-R SL",                       @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"HD DVD-R DL",                       @"value":getFlagRepr(ptr[5] & 1)},
             @{@"key":@"HD DVD-RAM",                        @"value":getFlagRepr(ptr[6] & 1)},
             @{@"key":@"HD DVD-RW SL",                      @"value":getFlagRepr(ptr[8] & 1)},
             @{@"key":@"HD DVD-RW DL",                      @"value":getFlagRepr(ptr[9] & 1)}];
}

static NSArray* parseFeature0051(const uint8_t* ptr, NSUInteger size) {
    CheckSize(8);
    return @[@{@"key":@"HD DVD-R SL",                       @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"HD DVD-R DL",                       @"value":getFlagRepr(ptr[5] & 1)},
             @{@"key":@"HD DVD-RAM",                        @"value":getFlagRepr(ptr[6] & 1)},
             @{@"key":@"HD DVD-RW SL",                      @"value":getFlagRepr(ptr[8] & 1)},
             @{@"key":@"HD DVD-RW DL",                      @"value":getFlagRepr(ptr[9] & 1)}];
}

static NSArray* parseFeature0052(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Background Padding (BGP)",          @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0080(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Reset Immunity (RI)",               @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0100(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"ZPready state support (ZPS)",       @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0101(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Page Present (PP)",                 @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0102(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Side Change Capable (SCC)",         @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"Supports Disc Present (SDP)",       @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"Highest Slot Number",               @"value":getU4Repr(ptr[7] & 0x1F)}];
}

static NSArray* parseFeature0103(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Scan",                              @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"Separate Channel Mute (SCM)",       @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Separate Volume (SV)",              @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Number of Volume Levels",           @"value":getBe16Repr(&ptr[6])}];
}

static NSArray* parseFeature0104(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"M5",                                @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0105(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Group3",                            @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Unit Length",                       @"value":getBe16Repr(&ptr[6])}];
}

static NSArray* parseFeature0106(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"BLTC",                              @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"CSS Version",                       @"value":getU8Repr(ptr[7])}];
}

static NSArray* parseFeature0107(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Set Minimum Performance bit (SMP)", @"value":getFlagRepr(ptr[4] & 0x20)},
             @{@"key":@"Read Buffer Capacity Block (RBCB)", @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"Set CD Speed (SCS)",                @"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"Mode Page 2A (MP2A)",               @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"Write Speed Performance Descriptor (WSPD)",
               @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"Streaming Writing (SW)",            @"value":getFlagRepr(ptr[4] & 1)}];
}

static NSArray* parseFeature0108(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4); // At least 4 bytes (with padding)
    return @[@{@"key":@"Serial Number",    @"value":getStringRepr(ptr + 4, size - 4)}];
}

static NSArray* parseFeature0109(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature010A(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    NSUInteger len = ( size - 4 ) / 4;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
    for (int i = 0; i < len; i ++) {
        NSString *number = [NSString stringWithFormat:@"Supported DCB entry %i", i];
        [array addObject:@{@"key":number,  @"value":getBe32Repr(&ptr[i * 4 + 4])}];
    }
    return array;
}

static NSArray* parseFeature010B(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"CPRM Version",                      @"value":getU8Repr(ptr[7])}];
}

static NSArray* parseFeature010C(const uint8_t* ptr, NSUInteger size) {
    CheckSize(0x10);
    return @[@{@"key":@"Firmware Compilation Date",         @"value":getStringRepr(ptr + 4, 14)}];
}

static NSArray* parseFeature010D(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Read Drive Certificate (RDC)",      @"value":getFlagRepr(ptr[4] & 0x10)},
             @{@"key":@"Read Media Key Block of CPRM (RMC)",@"value":getFlagRepr(ptr[4] & 8)},
             @{@"key":@"WBE",                               @"value":getFlagRepr(ptr[4] & 4)},
             @{@"key":@"BEC",                               @"value":getFlagRepr(ptr[4] & 2)},
             @{@"key":@"BNG",                               @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Block Count for Binding Nonce",     @"value":getU8Repr(ptr[5])},
             @{@"key":@"Number of AGIDs",                   @"value":getU4Repr(ptr[6] & 0xF)},
             @{@"key":@"AACS Version",                      @"value":getU8Repr(ptr[7])}];
}

static NSArray* parseFeature010E(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"Maximum number of Scramble Extent information entries", @"value":getU8Repr(ptr[4])}];
}

static NSArray* parseFeature010F(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    return @[@{@"key":@"BNG",                               @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Block Count for Binding Nonce",     @"value":getU8Repr(ptr[5])},
             @{@"key":@"Number of AGIDs",                   @"value":getU4Repr(ptr[6] & 0xF)},
             @{@"key":@"AACS Version",                      @"value":getU8Repr(ptr[7])}];
}

static NSArray* parseFeature0110(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0113(const uint8_t* ptr, NSUInteger size) {
    return nil;
}

static NSArray* parseFeature0142(const uint8_t* ptr, NSUInteger size) {
    CheckSize(4);
    NSUInteger len = MIN(size - 6, ptr[5]) / 2;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
    for (int i = 0; i < len; i ++) {
        [array addObject:getBe16Repr(&ptr[i * 2 + 6])];
    }
    return @[@{@"key":@"PSAU",                              @"value":getFlagRepr(ptr[4] & 0x80)},
             @{@"key":@"LOSPB",                             @"value":getFlagRepr(ptr[4] & 0x40)},
             @{@"key":@"Mandatory Encryption (ME)",         @"value":getFlagRepr(ptr[4] & 1)},
             @{@"key":@"Number of Profiles",                @"value":getU8Repr(ptr[5])},
             @{@"key":@"Profiles",                          @"value":[array componentsJoinedByString:@","]}];
}

typedef NSArray* (*FeatureParser)(const uint8_t* ptr, NSUInteger size);
static FeatureParser kFeatureParserTable[] = {
    [0x0000] = parseFeature0000,
    [0x0001] = parseFeature0001,
    [0x0002] = parseFeature0002,
    [0x0003] = parseFeature0003,
    [0x0004] = parseFeature0004,
    [0x0010] = parseFeature0010,
    [0x001D] = parseFeature001D,
    [0x001E] = parseFeature001E,
    [0x001F] = parseFeature001F,
    [0x0020] = parseFeature0020,
    [0x0021] = parseFeature0021,
    [0x0022] = parseFeature0022,
    [0x0023] = parseFeature0023,
    [0x0024] = parseFeature0024,
    [0x0025] = parseFeature0025,
    [0x0026] = parseFeature0026,
    [0x0027] = parseFeature0027,
    [0x0028] = parseFeature0028,
    [0x0029] = parseFeature0029,
    [0x002A] = parseFeature002A,
    [0x002B] = parseFeature002B,
    [0x002C] = parseFeature002C,
    [0x002D] = parseFeature002D,
    [0x002E] = parseFeature002E,
    [0x002F] = parseFeature002F,
    [0x0030] = parseFeature0030,
    [0x0031] = parseFeature0031,
    [0x0032] = parseFeature0032,
    [0x0033] = parseFeature0033,
    [0x0034] = parseFeature0034,
    [0x0035] = parseFeature0035,
    [0x0037] = parseFeature0037,
    [0x0038] = parseFeature0038,
    [0x003A] = parseFeature003A,
    [0x003B] = parseFeature003B,
    [0x0040] = parseFeature0040,
    [0x0041] = parseFeature0041,
    [0x0042] = parseFeature0042,
    [0x0050] = parseFeature0050,
    [0x0051] = parseFeature0051,
    [0x0052] = parseFeature0052,
    [0x0080] = parseFeature0080,
    [0x0100] = parseFeature0100,
    [0x0101] = parseFeature0101,
    [0x0102] = parseFeature0102,
    [0x0103] = parseFeature0103,
    [0x0104] = parseFeature0104,
    [0x0105] = parseFeature0105,
    [0x0106] = parseFeature0106,
    [0x0107] = parseFeature0107,
    [0x0108] = parseFeature0108,
    [0x0109] = parseFeature0109,
    [0x010A] = parseFeature010A,
    [0x010B] = parseFeature010B,
    [0x010C] = parseFeature010C,
    [0x010D] = parseFeature010D,
    [0x010E] = parseFeature010E,
    [0x010F] = parseFeature010F,
    [0x0110] = parseFeature0110,
    [0x0113] = parseFeature0113,
    [0x0142] = parseFeature0142,
};

@implementation FeatureData

+ (NSDictionary*)parseHeader:(NSData*)data {
    NSUInteger size = data.length;
    if (size < 4)
        return nil;
    const uint8_t* ptr = data.bytes;
    uint16_t feature = CFSwapInt16BigToHost(*(uint16_t*)ptr);
    uint8_t flags = ptr[2];
    return @{@"id":         @(feature),
             @"code":       getU16Repr(feature),
             @"name":       getFeatureName(feature),
             @"version":    getU4Repr((flags >> 2) & 0xF),
             @"persistent": getFlagRepr(flags & 2),
             @"current":    getFlagRepr(flags & 1),
             @"raw":        data,
             };
}

+ (NSArray<NSDictionary*>*)parse:(NSData*)data {
    NSUInteger size = data.length;
    if (size < 4)
        return nil;
    const uint8_t* ptr = data.bytes;
    uint16_t feature = CFSwapInt16BigToHost(*(uint16_t*)ptr);
    uint8_t flags = ptr[2];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    [array addObject:@{@"key":@"Feature Code",      @"value":getU16Repr(feature)}];
    [array addObject:@{@"key":@"Feature Name",      @"value":getFeatureName(feature)}];
    [array addObject:@{@"key":@"Feature Version",   @"value":getU4Repr((flags >> 2) & 0xF)}];
    [array addObject:@{@"key":@"Persistent",        @"value":getFlagRepr(flags & 2)}];
    [array addObject:@{@"key":@"Currently Active",  @"value":getFlagRepr(flags & 1)}];
    [array addObject:@{@"key":@"Additional Length", @"value":getU8Repr(ptr[3])}];
    if (feature < (sizeof(kFeatureParserTable)/sizeof(kFeatureParserTable[0]))) {
        FeatureParser parser = kFeatureParserTable[feature];
        if (parser) {
            NSArray* a = parser(ptr, size);
            if (a) {
                [array addObjectsFromArray:a];
            }
        }
    }
    [array addObject:@{@"key":@"Raw Data",  @"value":data}];
    return array;
}

@end
