#import <Foundation/Foundation.h>

@interface EposPurchaseItems : NSObject

@property(assign, nonatomic) NSString* itemCode;
@property(assign, nonatomic) NSString* itemName;
@property(assign, nonatomic) float itemValue;
@property(assign, nonatomic) int itemCount;

- (id)initItem:(NSString*)itemCode itemName:(NSString*)itemName itemValue:(float)itemValue;

- (void)setItemCode:(NSString *)itemCode;
- (NSString*)getItemCode;

- (void)setItemName:(NSString *)itemName;
- (NSString*)getItemName;

- (void)setItemValue:(float)itemValue;
- (float)getItemValue;

- (void)setItemCount:(int)itemCount;
- (int)getItemCount;
@end
