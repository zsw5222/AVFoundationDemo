//
//  SpeechVoiceController.m
//  TodayDemo
//
//  Created by jalon on 2019/11/26.
//  Copyright © 2019 ore. All rights reserved.
//

#import "SpeechVoiceController.h"
#import <AVFoundation/AVFoundation.h>

@interface SpeechVoiceController ()<AVSpeechSynthesizerDelegate>

@property(nonatomic,strong)AVSpeechSynthesizer *synthesizer;
@property(nonatomic,strong)NSArray* stringArr;
@property(nonatomic,strong)NSArray* voiceArr;

@end

@implementation SpeechVoiceController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    self.synthesizer.delegate = self;
    AVSpeechSynthesisVoice *v1 = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    AVSpeechSynthesisVoice *v2 = [AVSpeechSynthesisVoice voiceWithLanguage:@"fr-CA"];
    self.voiceArr = @[v1,v2];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self beginConversation];
}
- (NSArray *)stringArr{
    if (_stringArr == nil) {
        _stringArr = @[@"hello world",@"jack is a dog",@"tom is a cat"];
    }
    return _stringArr;
}
- (void)beginConversation{
    for (int i = 0; i<self.stringArr.count; i++) {
        AVSpeechUtterance* ult = [AVSpeechUtterance speechUtteranceWithString:self.stringArr[i]];
        //音调
        ult.pitchMultiplier = 1;
        ult.rate = 0.5;
//        ult.volume = 1;
        ult.postUtteranceDelay = 0.1;
        ult.voice = [self.voiceArr objectAtIndex:i%2];
        [self.synthesizer speakUtterance:ult];
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"开始speaching--");
}

@end
