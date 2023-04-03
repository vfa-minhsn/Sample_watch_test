//
//  Functions.swift
//  YourGolfWatch WatchKit Extension
//
//  Created by vfa on 3/8/23.
//

import Foundation

class Functions{
    static func resetDataUserDefault (){
      let data = ExtraDefine.USER_DEFAULT.dictionary(forKey:"round_data") as? NSDictionary
      let  holesPar = data?["par"] as? NSDictionary
      let  holeTotal = holesPar?.count ?? 0
        if(holeTotal > 0){
            for i in 1...holeTotal{
                ExtraDefine.USER_DEFAULT.removeObject(forKey: String(format: "Hole %d", i-1))
            }
        }
      ExtraDefine.USER_DEFAULT.removeObject(forKey: "round_data")
    }
    
}
