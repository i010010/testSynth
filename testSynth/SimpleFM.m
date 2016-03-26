#import "SimpleFM.h"


@implementation SimpleFM

@synthesize carrierFreq;
@synthesize harmonicityRatio;
@synthesize modulatorIndex;

static OSStatus renderCallback(void*                       inRefCon,
                               AudioUnitRenderActionFlags* ioActionFlags,
                               const AudioTimeStamp*       inTimeStamp,
                               UInt32                      inBusNumber,
                               UInt32                      inNumberFrames,
                               AudioBufferList*            ioData){
    //SineWaveDefにキャストする
    FMInfo *def = (FMInfo*)inRefCon;
    
    Float64 sampleRate = def->sampleRate;
    double carrierFreq = def->carrierFreq;
    double harmonicityRatio = def->harmonicityRatio;
    double modulatorIndex = def->modulatorIndex;
    
    double phase = def->phase;
    double modulatorPhase = def->modulatorPhase;
    
    //キャリア周波数 * C:M比 = モジュレーター周波数
    double modulatorFreq = carrierFreq * harmonicityRatio;
    double modfreq = modulatorFreq * 2.0 * M_PI / sampleRate;
    //モジュレーター周波数 * 変調指数 A = M x I
    double modulatorAmp = modulatorIndex * modulatorFreq;
        
    AudioUnitSampleType *output = ioData->mBuffers[0].mData;
    
    for(int i = 0; i< inNumberFrames; i++){
		//先にモジュレーターの波形を計算
        double modWave = sin(modulatorPhase);
		//キャリアの周波数を計算
        double freq = (carrierFreq + (modWave * modulatorAmp)) * 2.0 * M_PI / sampleRate;
		//キャリアの波形を計算
        float wave = sin(phase);
        AudioUnitSampleType sample = wave * (1 << kAudioUnitSampleFractionBits);
        *output++ = sample;
        
        phase = phase + freq;
        modulatorPhase = modulatorPhase + modfreq;
    }
    
    def->phase = phase;
    def->modulatorPhase = modulatorPhase;
    return noErr;
}

- (id)init{
    self = [super init];
    if (self != nil)[self prepareAudioUnit];
    return self;
}


-(void)setCarrierFreq:(double)carrierFreq{
    fmInfo.carrierFreq = carrierFreq;
}

-(void)setHarmonicityRatio:(double)harmonicityRatio{
    fmInfo.harmonicityRatio = harmonicityRatio;
}

-(void)setModulatorIndex:(double)modulatorIndex{
    fmInfo.modulatorIndex = modulatorIndex;
}


-(double)carrierFreq{
    return fmInfo.carrierFreq;
}

-(double)harmonicityRatio{
    return fmInfo.harmonicityRatio;
}

-(double)modulatorIndex{
    return fmInfo.modulatorIndex;
}

- (void)prepareAudioUnit{
    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &cd);
    AudioComponentInstanceNew(component, &audioUnit);
    
    AudioUnitInitialize(audioUnit);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = &fmInfo;
    
    AudioUnitSetProperty(audioUnit, 
                         kAudioUnitProperty_SetRenderCallback, 
                         kAudioUnitScope_Input,
                         0,
                         &callbackStruct,
                         sizeof(AURenderCallbackStruct));
        
    AudioStreamBasicDescription audioFormat = AUCanonicalASBD(44100.0, 1);
    
    AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &audioFormat,
                         sizeof(audioFormat));
    
    fmInfo.sampleRate = 44100.0;
    fmInfo.phase = 0.0;
    fmInfo.modulatorPhase = 0.0;
    
    fmInfo.carrierFreq = 800;
    fmInfo.harmonicityRatio = 0.25;
    fmInfo.modulatorIndex = 5.0;
}

-(void)play{
    if(!isPlaying)AudioOutputUnitStart(audioUnit);
    isPlaying = YES;
}

-(void)stop{
    if(isPlaying)AudioOutputUnitStop(audioUnit);
    isPlaying = NO;
}

-(void)dealloc{
    [self stop];
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);

}


@end