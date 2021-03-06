#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "iPhoneCoreAudio.h"


typedef struct FMInfo {
    double carrierFreq; //キャリア周波数
    double harmonicityRatio; //C:M比
    double modulatorIndex; //変調指数
	double phase; //キャリアの位相
    double modulatorPhase;//モジュレーターの位相
    Float64 sampleRate;
}FMInfo;


@interface SimpleFM : NSObject {
    FMInfo fmInfo;    
    AudioUnit audioUnit;
    BOOL isPlaying;
}

@property double carrierFreq;
@property double harmonicityRatio;
@property double modulatorIndex;

-(void)play;
-(void)stop;
-(void)prepareAudioUnit;
@end