#import <UIKit/UIKit.h>
#import "SimpleFM.h"
@interface ViewController : UIViewController {
    SimpleFM *simpleFM;
    IBOutlet UITextField *carrierFreqField;
    IBOutlet UITextField *modulatorFreqField;
    IBOutlet UITextField *modulatorAmpField;
    
    IBOutlet UISlider *carrierFreqSlider;
    IBOutlet UISlider *modulatorFreqSlider;
    IBOutlet UISlider *modulatorAmpSlider;
}

-(IBAction)carrierFreqAction:(UISlider*)sender;
-(IBAction)modulatorFreqAction:(UISlider*)sender;
-(IBAction)modulatorAmpAction:(UISlider*)sender;

-(void)updateAllValues;

-(IBAction)play:(id)sender;
-(IBAction)stop:(id)sender;
@end