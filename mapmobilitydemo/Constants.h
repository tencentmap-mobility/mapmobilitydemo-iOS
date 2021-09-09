//
//  Constants.h
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2019/1/15.
//  Copyright © 2019年 tencent. All rights reserved.
//

#define kMapKey @"" // 需要填写地图的key
#define kSynchroKey @""  // 需要填写司乘同显的Key
#define kSynchroSecretKey @""  // 需要填写司乘同显Key对应的secretKey，不是签名校验方式则不用填写


#define kMobilityKey @"" // 需要填写webServiceKey
#define kMobilitySecretKey @"" // 需要填写webServiceSecretKey

#define kSynchroDriverOrderID           @""
#define kSynchroPassenger1OrderID       @""
#define kSynchroPassenger2OrderID       @""

#define kSynchroDriverID                @""
#define kSynchroPassenger1ID            @""
#define kSynchroPassenger2ID            @""

#define kSynchroDriverStart             CLLocationCoordinate2DMake(39.938962,116.375685)
#define kSynchroDriverEnd               CLLocationCoordinate2DMake(39.911975,116.351395)

#define kSynchroPassenger1Start         CLLocationCoordinate2DMake(39.940080, 116.355257)
#define kSynchroPassenger1End           CLLocationCoordinate2DMake(39.923890, 116.344700)

#define kSynchroPassenger2Start         CLLocationCoordinate2DMake(39.932446, 116.363153)
#define kSynchroPassenger2End           CLLocationCoordinate2DMake(39.923297, 116.360407)

#define kLocationFormat(coord) [NSString stringWithFormat:@"%.6f,%.6f", coord.longitude, coord.latitude];


// 快车订单
#define kSynchroKCDriverAccountID    @"kc_driver_ios_mol_000001"

#define kSynchroKCOrder1ID            @"kc_ios_mol_000006"
#define kSynchroKCPassenger1AccountID @"kc_passenger_ios_mol_000001"
#define kSynchroKCPassenger1Start         CLLocationCoordinate2DMake(39.988955, 116.410266)
#define kSynchroKCPassenger1End           CLLocationCoordinate2DMake(40.113174, 116.658524)

// 接力单订单，请同步订单状态为接驾
#define kSynchroKCOrder2ID            @"kc_ios_mol_000007"
#define kSynchroKCPassenger2AccountID @"kc_passenger_ios_mol_000002"
#define kSynchroKCPassenger2Start         CLLocationCoordinate2DMake(40.149619, 116.662102)
#define kSynchroKCPassenger2End           CLLocationCoordinate2DMake(40.129771, 116.641374)
