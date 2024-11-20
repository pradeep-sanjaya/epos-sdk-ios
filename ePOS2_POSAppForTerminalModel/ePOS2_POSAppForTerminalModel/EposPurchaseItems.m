#import "EposPurchaseItems.h"

@implementation EposPurchaseItems
- (id)init
{
    self = [super init];

    return self;
}

- (id)initItem:(NSString*)itemCode itemName:(NSString*)itemName itemValue:(float)itemValue
{
    self = [super init];
    if(self != nil) {
        if(itemCode != nil) {
            _itemCode = itemCode;
        }
        if(itemName != nil) {
            _itemName = itemName;
        }
        _itemValue = itemValue;
        _itemCount = 0;
    }
    
    return self;
}

- (void)setItemCode:(NSString *)itemCode
{
    if(itemCode != nil) {
        _itemCode = itemCode;
    }
}

- (NSString*)getItemCode
{
    return _itemCode;
}


- (void)setItemName:(NSString *)itemName
{
    if(itemName != nil) {
        _itemName = itemName;
    }
}

- (NSString*)getItemName
{
    return _itemName;
}


- (void)setItemValue:(float)itemValue
{
    _itemValue = itemValue;
}

- (float)getItemValue
{
    return _itemValue;
}

- (void)setItemCount:(int)itemCount
{
    _itemCount = itemCount;
}

- (int)getItemCount
{
    return _itemCount;
}
@end
