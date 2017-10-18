//
//  TWICHangoutManager.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 20/04/2017.
//
//

#import <Foundation/Foundation.h>


static NSString *HangoutOptionsKey = @"options";
static NSString *HangoutRulesKey = @"rules";

static NSString *HangoutOptionRecord                = @"record";
static NSString *HangoutOptionNbUserAutoRecord      = @"nb_user_autorecord";

static NSString *HangoutActionAutoPublishCamera     = @"autoPublishCamera";
static NSString *HangoutActionAutoPublishMicrophone = @"autoPublishMicrophone";
static NSString *HangoutActionArchive               = @"archive";
static NSString *HangoutActionRaiseHand             = @"raiseHand";
static NSString *HangoutActionPublish               = @"publish";
static NSString *HangoutActionAskDevice             = @"askDevice";
static NSString *HangoutActionAskScreen             = @"askScreen";
static NSString *HangoutActionForceMute             = @"forceMute";
static NSString *HangoutActionForceUnpusblish       = @"forceUnpublish";
static NSString *HangoutActionKick                  = @"kick";

static NSString *HangoutRolesKey                    = @"roles";

@interface TWICHangoutManager : NSObject
+ (TWICHangoutManager *)sharedInstance;

@property (nonatomic, strong) NSDictionary *hangoutData;

-(void)configureHangoutDataWithCompletionBlock:(void(^)())completionBlock
                                  failureBlock:(void (^)(NSError *error))failureBlock;
-(BOOL)canUser:(NSDictionary *)user doAction:(NSString *)actionName;
-(id)optionForKey:(NSString *)optionKey;
@end

/*
 {
 "autoPublishCamera":[{"roles":["academic","instructor"]}],
 "autoPublishMicrophone":false,
 "archive":[{"roles":["admin","super_admin","academic","instructor"]}],
 "raiseHand":[{"roles":["student"]}],
 "publish":[{"roles":["admin","super_admin","academic","instructor"]}],
 "askDevice":[{"roles":["admin","super_admin","academic","instructor"]}],
 "askScreen":[{"roles":["admin","super_admin","academic","instructor"]}],
 "forceMute":[{"roles":["admin","super_admin","academic","instructor"]}],
 "forceUnpublish":[{"roles":["admin","super_admin","academic","instructor"]}],
 "kick":[{"roles":["admin","super_admin","academic"]}]}
*/

/*
 - kick => permet de savoir si l'user a le droit de kick,
 - askDevice => permet de savoir si l'utilisateur à le droit de demander à un autre qu'il partage micro OU camera
 - askScreen => permet de savoir si l'utilisateur à le droit de demander à un autre qu'il partage son écran.
 
 - archive => permet de savoir si l'utilisateur à le droit de lancer/stopper l'enregistrement du hangout
 - raiseHand => permet de savoir si l'utilisateur a le droit de demander le partage de sa camera/micro
 - publish => permet de savoir si l'utilisateur à le droit de publier sa camera/son micro
 - autoPublishCamera => permet de savoir si l'utilisateur doit automatiquement publier sa camera.
 - autoPublishMicrophone => permet de savoir si l'utilisateur doit automatiquement publier son micro.
 - forceMute => Permet de savoir si l'utilisateur peut mute un autre.
 - forceUnpublish => permet de savoir si l'utilisateur peut forcer un autre à couper sa camera/micro/partage d'écran.
 PS: A noter que si l'utilisateur n'a pas le droit "publish" et que autoPublishCamera OU autoPublishMicrophone est 'ok', la camera ou le micro de l'utilisateur sont publiés au lancement du hangout.
 PS2: les droits "askDevice" et "askScreen" sont également ceux qui autorise un user à accepter / refuser la demande de partage d'un autre utilisateur
*/

/*
 direct message => pas de droit ( tout le monde a le droit de chatter )
 request for camera => askDevice
 request for micro => askDevice
 request for screen => askScreen
 kick => kick
*/
