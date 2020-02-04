//
//  NSDate+Additions.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 15/09/2016.
//
//

#import "NSDate+Additions.h"

#import <ChatSDK/Core.h>

@implementation NSDate (Additions)

-(NSString *) threadTimeAgo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:self.timeFormat];
    
    NSString * time = [formatter stringFromDate:self];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:[NSDate date]
                                                  toDate:self
                                                 options:0];

    if (self.isToday) { // when the date/time is within 24hrs
        int seconds = abs([components second]);
        int minutes = abs([components minute]);
        int hours = abs([components hour]);

        if (hours >= 1) { // hours
            return [NSString stringWithFormat:@"%dh %@", hours, [NSBundle t: bAgo]];
        } else if (minutes >= 1) {
            return [NSString stringWithFormat:@"%dm %@", minutes, [NSBundle t: bAgo]];
        } else {
            return [NSString stringWithFormat:@"%ds %@", seconds, [NSBundle t: bAgo]];
        }
    } else {
        // We check if the last date was in the last few days
        // Then check if it was exactly yesterday
        if ([self daysAgo] < 3 && today.day == otherDay.day + 1) {
            time = [NSBundle t: bYesterday];
        } else if (self.daysAgo > 1 && self.daysAgo < 7) {
            int days = abs([components day]);
            time = [NSString stringWithFormat:@"%dd %@", days, [NSBundle t: bAgo]];
        } else { // if (self.daysAgo >= 7) {
            if (otherDay.year == today.year) {
                [formatter setDateFormat:@"MMM dd"];
            } else {
                [formatter setDateFormat:@"MMM dd, yyyy"];
            }

            time = [formatter stringFromDate:self];
        }
    }

    return time;
}

-(NSString *) timeFormat {
    return BChatSDK.config.timeFormat;
}

-(NSString *) messageTimeAt {
//    if (self.daysAgo < 1) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:self.timeFormat];
        return [formatter stringFromDate:self];
//    }
//    else {
//        return [self timeAgoWithFormatString:b_at_];
//    }
}

-(NSString *) lastSeenTimeAgo {
    return [self timeAgoWithFormatString:bLastSeen_at_];
}

-(NSString *) dateAgo {
    NSString * day = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    if (self.isToday) {
        day = [NSBundle t: bToday];
    } else if (self.isYesterday) {
        day = [NSBundle t: bYesterday];
    } /* else if (self.daysAgo < 7) {
        [formatter setDateFormat:@"EEE"];
        day = [formatter stringFromDate:self];
    } */ else {
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];

        if (otherDay.year == today.year) {
            [formatter setDateFormat:@"MMM dd"];
        } else {
            [formatter setDateFormat:@"MMM dd, yyyy"];
        }

        day = [formatter stringFromDate:self];
    }
    
    return day;
}

-(BOOL) isDateWithOffset: (int) days to: (NSDate *) date {
    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
//                                     fromDate:self];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setDay:days];
    NSDate * offset = [cal dateByAddingComponents:comps toDate:self options:0];
    return date.day == offset.day && date.month == offset.month && date.year == offset.year;
}

-(BOOL) isNextDay: (NSDate *) date {
    return [self isDateWithOffset:-1 to:date];
}

-(BOOL) isPreviousDay: (NSDate *) date {
    return [self isDateWithOffset:1 to:date];
}

-(NSString *) timeAgoWithFormatString: (NSString *) formatString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:self.timeFormat];
    
    NSString * time = [formatter stringFromDate:self];
    NSString * day = [self dateAgo];
    return [NSString stringWithFormat:[NSBundle t:formatString], day, time];
}

@end

