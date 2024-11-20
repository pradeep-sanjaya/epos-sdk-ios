#import <Foundation/Foundation.h>
#import "EposPurchaseItems.h"

@interface EposPurchaseItemList : NSObject
{
    NSMutableArray* items_;

    EposPurchaseItems* item1_;
    EposPurchaseItems* item2_;
    EposPurchaseItems* item3_;
    EposPurchaseItems* item4_;
    EposPurchaseItems* item5_;
    EposPurchaseItems* item6_;
    EposPurchaseItems* item7_;
    EposPurchaseItems* item8_;
    EposPurchaseItems* item9_;
    EposPurchaseItems* item10_;
}
- (void)clearItemCount;
- (void)incrementItemCount:(NSString*)itemCode;
- (NSString*)createItemData:(NSString*)itemCode;
- (NSString*)createTotalAmountData;
- (NSString*)createTransactionData;
- (NSString*)createReceiptData;
@end
