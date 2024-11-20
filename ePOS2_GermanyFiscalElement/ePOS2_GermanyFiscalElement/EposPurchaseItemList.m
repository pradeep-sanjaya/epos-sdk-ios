#import <Foundation/Foundation.h>
#import "EposPurchaseItemList.h"

@implementation EposPurchaseItemList

- (id)init
{
    self = [super init];
    if(self != nil) {
        item1_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item1Code", nil) itemName:NSLocalizedString(@"item1Name", nil) itemValue:7.90];
        item2_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item2Code", nil) itemName:NSLocalizedString(@"item2Name", nil) itemValue:9.39];
        item3_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item3Code", nil) itemName:NSLocalizedString(@"item3Name", nil) itemValue:8.06];
        item4_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item4Code", nil) itemName:NSLocalizedString(@"item4Name", nil) itemValue:10.95];
        item5_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item5Code", nil) itemName:NSLocalizedString(@"item5Name", nil) itemValue:8.21];
        item6_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item6Code", nil) itemName:NSLocalizedString(@"item6Name", nil) itemValue:20.34];
        item7_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item7Code", nil) itemName:NSLocalizedString(@"item7Name", nil) itemValue:16.19];
        item8_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item8Code", nil) itemName:NSLocalizedString(@"item8Name", nil) itemValue:21.91];
        item9_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item9Code", nil) itemName:NSLocalizedString(@"item9Name", nil) itemValue:16.35];
        item10_ = [[EposPurchaseItems alloc] initItem:NSLocalizedString(@"item10Code", nil) itemName:NSLocalizedString(@"item10Name", nil) itemValue:23.47];

        [self createItemList];
    }
    return self;
}

- (void)dealloc
{
    [self deleteItemList];

    item1_ = nil;
    item2_ = nil;
    item3_ = nil;
    item4_ = nil;
    item5_ = nil;
    item6_ = nil;
    item7_ = nil;
    item8_ = nil;
    item9_ = nil;
    item10_ = nil;
}

- (void)createItemList
{
    items_ = [NSMutableArray array];
    if(items_ != nil) {
        [items_ addObject:item1_];
        [items_ addObject:item2_];
        [items_ addObject:item3_];
        [items_ addObject:item4_];
        [items_ addObject:item5_];
        [items_ addObject:item6_];
        [items_ addObject:item7_];
        [items_ addObject:item8_];
        [items_ addObject:item9_];
        [items_ addObject:item10_];
    }
}

- (void)deleteItemList
{
    if(items_ != nil) {
        [items_ removeAllObjects];
        items_ = nil;
    }
}


- (NSInteger)getItemsCount
{
    if(items_ != nil) {
        return [items_ count];
    } else {
        return 0;
    }
}

- (int)getItemIndex:(NSString*)itemCode
{
    if(items_ == nil || itemCode == nil) {
        return -1;
    }

    int index = 0;
    EposPurchaseItems* item = nil;
    NSString* tmpItemCode = nil;
    for(int i=0; i<[self getItemsCount]; i++) {
        item = [items_ objectAtIndex:i];
        if(item == nil) {
            return -1;
        }

        tmpItemCode = [item getItemCode];
        if([tmpItemCode isEqualToString:itemCode]) {
            index = i;
            break;
        }
    }

    return index;
}

- (EposPurchaseItems*)getItem:(int)index
{
    if(items_ == nil) {
        return nil;
    }

    return [items_ objectAtIndex:index];
}

- (NSString*)getItemName:(NSString*)itemCode
{
    if(itemCode == nil) {
        return nil;
    }

    int index = [self getItemIndex:itemCode];
    EposPurchaseItems* item = [self getItem:index];

    return [item getItemName];
}

- (int)getItemValue:(NSString*)itemCode
{
    if(itemCode == nil) {
        return 0;
    }

    int index = [self getItemIndex:itemCode];
    EposPurchaseItems* item = [self getItem:index];
    
    return [item getItemValue];
}

- (void)clearItemCount
{
    if(items_ == nil) {
        return;
    }

    EposPurchaseItems* item = nil;
    for(int i = 0; i < [self getItemsCount]; i++) {
        item = [self getItem:i];
        [item setItemCount:0];
    }
}

- (void)incrementItemCount:(NSString*)itemCode
{
    if(itemCode == nil) {
        return;
    }

    int index = [self getItemIndex:itemCode];
    EposPurchaseItems* item = [self getItem:index];

    int tmpItemCount = [item getItemCount];
    tmpItemCount++;
    [item setItemCount:tmpItemCount];
}


- (NSString*)createItemData:(NSString*)itemCode
{
    if(itemCode == nil) {
        return nil;
    }

    int index = [self getItemIndex:itemCode];
    EposPurchaseItems* item = [self getItem:index];

    NSString* itemName = [item getItemName];
    NSString* itemValue = [NSString stringWithFormat:@"  €%0.2f\n", [item getItemValue]];
    NSString* itemData = [itemName stringByAppendingString:itemValue];
    
    return itemData;
}

- (NSString*)createTotalAmountData
{
    if(items_ == nil) {
        return nil;
    }

    EposPurchaseItems* item = nil;
    float totalAmount = 0;
    float tmpValue = 0;
    int tmpCount = 0;
    for(int i = 0; i < [self getItemsCount]; i++) {
        item = [self getItem:i];
        tmpCount = [item getItemCount];
        if(tmpCount > 0) {
            tmpValue = [item getItemValue];
            totalAmount += (tmpValue * tmpCount);
        }
    }

    return [NSString stringWithFormat:@"%0.2f", totalAmount];
}

- (NSString*)createTransactionData
{
    if(items_ == nil) {
        return nil;
    }

    EposPurchaseItems* item = nil;
    NSString* data = @"";
    NSString* itemCode = nil;
    NSString* itemName = nil;
    float itemValue = 0;
    int itemCount = 0;
    for(int i = 0; i < [self getItemsCount]; i++) {
        item = [self getItem:i];
        itemCode = [item getItemCode];
        if(itemCode == nil) {
            return nil;
        }
        itemName = [item getItemName];
        if(itemName == nil) {
            return nil;
        }
        itemValue = [item getItemValue];
        itemCount = [item getItemCount];
        data = [data stringByAppendingString:[NSString stringWithFormat:@"[%@,%@,%0.2f,%d]", itemCode, itemName, itemValue, itemCount]];
    }

    return data;
}

- (NSString*)createReceiptData
{
    if(items_ == nil) {
        return nil;
    }

    EposPurchaseItems* item = nil;
    NSString* data = @"";
    NSString* itemCode = nil;
    NSString* itemName = nil;
    float itemValue = 0;
    int itemCount = 0;

    for(int i = 0; i < [self getItemsCount]; i++) {
        item = [self getItem:i];
        itemCount = [item getItemCount];
        if(itemCount > 0) {
            itemCode = [item getItemCode];
            if(itemCode == nil) {
                return nil;
            }
            itemName = [item getItemName];
            if(itemName == nil) {
                return nil;
            }
            itemValue = ([item getItemValue] * itemCount);
            data = [data stringByAppendingString:[NSString stringWithFormat:@" %@ %@       %d €%0.2f\n", itemCode, itemName, itemCount, itemValue]];
        }
    }

    return data;
}


@end

