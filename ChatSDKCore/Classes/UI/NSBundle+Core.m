//
//  NSBundle+ChatCore.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 12/07/2017.
//
//

#import "NSBundle+Core.h"
#import <ChatSDK/Core.h>

#define bLocalizableFile @"ChatSDKLocalizable"

@implementation NSBundle(Core)

+ (NSBundle *)coreBundle {
    //.return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bBundleName ofType:@"bundle"]];
    return [NSBundle bundleWithName:bCoreBundleName];
}

+ (NSString *)localizationFileForLang:(NSString *)lang {
    NSString * filename = [[bLocalizableFile stringByAppendingString:@"."] stringByAppendingString:lang];
    if ([[self coreBundle] pathForResource:filename ofType:@"strings"]) {
        return filename;
    }
    return nil;
}

+ (NSString *)bestLocalizationFileForLang:(NSString *)lang {
    NSString * exact = [self localizationFileForLang:lang];
    if (exact) return exact;
    lang = [[lang componentsSeparatedByString:@"-"] firstObject];
    NSString * general = [self localizationFileForLang:lang];
    if (general) return general;
    return bLocalizableFile;
}

+ (NSString *)t:(NSString *)string {
    NSString * lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString * localizableFile = [self bestLocalizationFileForLang:lang];
    if (!localizableFile) return string;
    
    NSString * localized = NSLocalizedStringFromTableInBundle(string, localizableFile, [self coreBundle], @"");
    if (![localized isEqualToString:string]) return localized;

    return NSLocalizedStringFromTableInBundle(string, bLocalizableFile, [self coreBundle], @"");
}

+(NSString *) textForMessage: (id<PMessage>) message {
    NSString * text;
    if (message.type.intValue == bMessageTypeImage) {
        if (message.senderIsMe) {
            return @"You sent a photo"; // [NSString stringWithFormat:@"You: %@", text];
        } else {
            return @"Sent a photo";
        }
//        text = [self t:bImageMessage];
    } else if(message.type.intValue == bMessageTypeLocation) {
        return [self t:bLocationMessage];
    } else if(message.type.intValue == bMessageTypeAudio) {
        return [self t:bAudioMessage];
    } else if(message.type.intValue == bMessageTypeVideo) {
        return [self t:bVideoMessage];
    } else if(message.type.intValue == bMessageTypeSticker) {
        return [self t:bStickerMessage];
    } else if(message.type.intValue == bMessageTypeFile) {
        return [self t:bFileMessage];
    } else {
        if (message.senderIsMe) {
            return [NSString stringWithFormat:@"You: %@", message.text];
        } else {
            return message.text;
        }
    }
}

@end
