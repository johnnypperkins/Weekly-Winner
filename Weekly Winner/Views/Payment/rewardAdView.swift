import SwiftUI
import GoogleMobileAds
import UIKit

final class Rewarded: NSObject, GADFullScreenContentDelegate {
    
    var rewardedAd: GADRewardedAd?
    
    var rewardFunction: (() -> Void)? = nil
    
    override init() {
        super.init()
        LoadRewarded()
    }
    
    func LoadRewarded(){
        let request = GADRequest()
          GADRewardedAd.load(withAdUnitID: "ca-app-pub-9148656115654064/6749251263" as! String,
                                  request: request, completionHandler: { (ad, error) in
                                    if let error = error {
                                      print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                                      return
                                    }
                                    self.rewardedAd = ad
                                    self.rewardedAd?.fullScreenContentDelegate = self
                                  }
          )
    }
    
    func showAd(rewardFunction: @escaping () -> Void){
        let root = UIApplication.shared.windows.first?.rootViewController
        if let ad = rewardedAd {
              ad.present(fromRootViewController: root!,
                       userDidEarnRewardHandler: {
                            let reward = ad.adReward
                            rewardFunction()
                       }
              )
          } else {
            print("Ad wasn't ready")
          }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rf = rewardFunction {
            rf()
        }
    }
}

struct RewardAdView:View{
    var rewardAd:Rewarded

    init(){
        self.rewardAd = Rewarded()
    }

var body : some View{
    Button {
        self.rewardAd.showAd(rewardFunction: {
          print("Give Reward")
        })
    } label: {
            Text("My Button")
    }
 
}
         }
