//
//  InputScoreListHoleInterfaceController.swift
//  YourGolfWatch WatchKit Extension
//
//  Created by vfa on 2/7/23.
//

import WatchKit
import Foundation
import WatchConnectivity


class InputScoreListHoleInterfaceController: WKInterfaceController {
   
    @IBOutlet weak var totalPuttLabel: WKInterfaceLabel!
    @IBOutlet weak var totalStrokeLabel: WKInterfaceLabel!
    @IBOutlet weak var clubNameLabel: WKInterfaceLabel!
    @IBOutlet weak var saveButton: WKInterfaceButton!
    @IBOutlet weak var uploadButton: WKInterfaceButton!
    @IBOutlet weak var holeListTableView: WKInterfaceTable!
    var selectedHole = 0
    var holeTotal = 9
    var dataFromIphone: NSDictionary?
    var holesPar: NSDictionary?
    var club: NSDictionary?
    var totalStroke = 0
    var totalPutt = 0
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if(context==nil){
            dataFromIphone = ExtraDefine.USER_DEFAULT.dictionary(forKey:"round_data") as? NSDictionary
        } else {
            dataFromIphone = NSDictionary.init(dictionary: context as? NSDictionary ?? NSDictionary.init())
            ExtraDefine.USER_DEFAULT.set(dataFromIphone, forKey: "round_data")
            ExtraDefine.USER_DEFAULT.set(1, forKey: "firstLoad")
        }
        setUp()
        
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        setUpTableView()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
// MARK: - set up
    private func setUpTableView(){
        totalStroke = 0
        totalPutt = 0
        holesPar = dataFromIphone?["par"] as? NSDictionary
        holeTotal = holesPar?.count ?? 0
        holeListTableView.setNumberOfRows(holeTotal, withRowType: "HoleListTableRow")
        if(holeTotal>0){
            for i in 1...holeTotal{
                if let rowController = holeListTableView.rowController(at: i-1) as? HoleListTableRowController{
                    let index = String(format: "%d", i)
                    rowController.holeNumberLabel.setText(String(format: "%d%@", i,"H"))
                    rowController.parLabel.setText(String(format: "Par%@", holesPar?[index] as! CVarArg))
                    let holeScore = ExtraDefine.USER_DEFAULT.object(forKey: String(format: "Hole %d", i-1)) as? NSDictionary
                    var tempStroke = 0
                    var tempPutt = 0
                    if(holeScore != nil){
                        tempStroke = holeScore?.object(forKey: "shot") as! Int
                        tempPutt = holeScore?.object(forKey: "putt") as! Int
                    }
                    rowController.strokeLabel.setText(String(format: "%d", tempStroke))
                    rowController.pushLabel.setText(String(format: "%d", tempPutt))
                    
                    totalStroke += tempStroke
                    totalPutt += tempPutt
                }
            }
        }
        totalStrokeLabel.setText(String(format: "%d", totalStroke))
        totalPuttLabel.setText(String(format: "%d", totalPutt))
    }
    
    func setUp(){
        saveButton.setTitle(NSLocalizedString("input_score_list_save_title", comment: ""))
        uploadButton.setTitle(NSLocalizedString("input_score_list_upload_title", comment: ""))
        club = dataFromIphone?["club"] as? NSDictionary
        clubNameLabel.setText(club?["club_name"] as? String)
        
    }
    
    
// MARK: - table
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        selectedHole = rowIndex
        self.pushController(withName: "InputScoreInterface", context: self)
    }
    
   
 // MARK: - action
    
    @IBAction func saveButtonPressed() {
        
        let message = prepareDataToSend()
        if(ExtraDefine.SESSION.isReachable){
            ExtraDefine.SESSION.sendMessage(message as! [String : Any], replyHandler: {(reply) in
                if(reply["save_temp"] as! String == "ok"){
                    let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){}
                    self.presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_success", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
                } else {
                    let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){}
                    self.presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_fail", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
                }
            })
        } else {
            let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){}
            self.presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_fail", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
        }
       
       
    }
    @IBAction func uploadButtonPressed() {
        let message = prepareDataToSend()
        message.setObject("upload", forKey: "isUpLoad" as NSCopying)
        if(ExtraDefine.SESSION.isReachable){
            ExtraDefine.SESSION.sendMessage(message as! [String : Any], replyHandler: {(reply) in
                if(reply["upload"] as! String == "ok"){
                    let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){
                        ExtraDefine.USER_DEFAULT.set(0, forKey: "firstLoad")
                        let rootControllerIdentifier = "TopInterfaceController"
                        WKInterfaceController.reloadRootControllers(withNames: [rootControllerIdentifier], contexts: nil)
                        self.popToRootController()
                        Functions.resetDataUserDefault()
                    }
                    self.presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_success", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
                } else {
                    let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){
                    }
                    self.presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_fail", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
                }
            })
        } else {
            let action = WKAlertAction(title: "OK", style: WKAlertActionStyle.default){
            }
                presentAlert(withTitle: nil, message: NSLocalizedString("input_score_list_save_fail", comment: ""), preferredStyle: WKAlertControllerStyle.alert, actions:[action])
        }
    }
    
    
    func prepareDataToSend() -> NSMutableDictionary{
        let data = NSMutableDictionary.init()
        data.setObject(ExtraDefine.USER_DEFAULT.object(forKey: "round_data") ?? NSDictionary.init(), forKey: "round_data" as NSCopying)
        if(holeTotal>0){
            for i in 1...holeTotal{
                data.setObject(ExtraDefine.USER_DEFAULT.object(forKey: String(format: "Hole %d", i-1)) ?? NSDictionary.init(), forKey: String(format: "Hole %d", i-1) as NSCopying)
            }
        }
        return data
    }
}

