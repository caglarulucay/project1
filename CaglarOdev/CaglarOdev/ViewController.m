//
//  ViewController.m
//  CaglarOdev
//
.
//

#import "ViewController.h"
#import "BLE.h"

@interface ViewController () <BLEDelegate>

@property (nonatomic, strong) BLE *bleShield;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *activateButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[self bleShield] activePeripheral])
    {
        if([[self bleShield] activePeripheral].state == CBPeripheralStateConnected)
        {
            [[[self bleShield] CM] cancelPeripheralConnection:[[self bleShield] activePeripheral]];
            return;
        }
    }
    
    if ([[self bleShield] peripherals])
    {
        [[self bleShield] setPeripherals:nil];
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:YES];
}

-(void) connectionTimer:(NSTimer *)timer
{
    
    if([[[self bleShield] peripherals] count] > 0)
    {
        for (int i = 0; i < [[[self bleShield] peripherals] count]; ++i)
        {
            CBPeripheral *peripheral = [[[self bleShield] peripherals] objectAtIndex:i];
            if (peripheral.identifier.UUIDString != NULL && [peripheral.identifier.UUIDString isEqualToString:@"A1A31244-BC03-429D-221F-173CE176DF9C"])
            {
                [[self bleShield] connectPeripheral:peripheral];
                [timer invalidate];
            }
        }
    }
    [[self bleShield] findBLEPeripherals:3];

}


-(void) bleDidConnect
{
    NSLog(@"Connected");
    [[self spinner] setHidden:YES];
    [[self activateButton] setHidden:NO];
}

-(void) bleDidDisconnect
{
    NSLog(@"Disconnected");
    [[self spinner] setHidden:NO];
    [[self activateButton] setHidden:YES];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    NSLog(@"update rssi");
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    NSLog(@"receive data");
}

- (IBAction)feedCat:(id)sender
{
    NSString* str = @"feedcat";
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [[self bleShield] write:data];
}

-(BLE *)bleShield
{
    if (_bleShield == nil)
    {
        _bleShield = [[BLE alloc] init];
        [_bleShield controlSetup];
        [_bleShield setDelegate:self];
    }

    return _bleShield;
}

@end
