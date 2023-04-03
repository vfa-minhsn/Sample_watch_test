//
//  InputScoreInterfaceController.swift
//  YourGolfWatch WatchKit Extension
//
//  Created by vfa on 2/3/23.
//

import WatchKit
import Foundation
import WatchConnectivity


class InputScoreInterfaceController: WKInterfaceController {

    @IBOutlet weak var holeNumLabel: WKInterfaceLabel!
    @IBOutlet weak var strokeHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var strokeValueLabel: WKInterfaceLabel!
    @IBOutlet weak var pushHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var pushValueLabel: WKInterfaceLabel!
    @IBOutlet weak var detailInputHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var obHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var obValueLabel: WKInterfaceLabel!
    @IBOutlet weak var waterHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var waterValueLabel: WKInterfaceLabel!
    @IBOutlet weak var guardBunkerHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var backButton: WKInterfaceButton!
    @IBOutlet weak var detailInputGroup: WKInterfaceGroup!
    @IBOutlet weak var closeOpenDetailImage: WKInterfaceImage!
    @IBOutlet weak var guardBunkerImage: WKInterfaceImage!
    var isShowDetail = false;
    weak var parentDelegate: InputScoreListHoleInterfaceController?
    var currentHoleIndex:Int = 1
    var currentStroke = 0
    var currentPutt = 0
    var currentOb = 0
    var currentWater = 0
    var currentGuardBunker = false
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let presentingVC = context as? InputScoreListHoleInterfaceController {
            parentDelegate = presentingVC
          }
        currentHoleIndex = parentDelegate?.selectedHole ?? 0
        refreshScoreInput()
        setUpLanguage()
        self.showDetailInput(isShow: isShowDetail)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Action
    
    @IBAction func closeOpenDetailPressed() {
        if(isShowDetail == true) {
            closeOpenDetailImage.setImageNamed("input_score_minus")
        } else{
            closeOpenDetailImage.setImageNamed("input_score_plus")
        }
        showDetailInput(isShow: isShowDetail)
    }
    @IBAction func guardBunkerOnPressed() {
        guardBunkerImage.setImageNamed("input_score_detail_on")
        currentGuardBunker = true
        updateHoleInfo()
    }
    @IBAction func guardBunkerOffPressed() {
        guardBunkerImage.setImageNamed("input_score_detail_off")
        currentGuardBunker = false
        updateHoleInfo()
    }
    @IBAction func backButtonPressed() {
        parentDelegate?.holeListTableView.scrollToRow(at: currentHoleIndex)
        self.pop()
    }
    
    @IBAction func previousButtonPressed() {
        if(currentHoleIndex+1 == 1) {
            return
        } else {
           currentHoleIndex -= 1
           refreshScoreInput()
        }
            
    }
    @IBAction func nextButtonPressed() {
        if(currentHoleIndex+1 == parentDelegate?.holeTotal) {
            return
        } else {
           currentHoleIndex += 1
           refreshScoreInput()
        }
    }
    
    @IBAction func strokePlusPressed() {
        if(currentStroke == 15){
            return
        } else {
            currentStroke += 1
            strokeValueLabel.setText(String(format: "%d", currentStroke))
            updateHoleInfo()
        }
    }
    @IBAction func strokeMinusPressed() {
        if(currentStroke == 0){
            return
        }else if(currentStroke == currentPutt){
            currentStroke -= 1
            strokeValueLabel.setText(String(format: "%d", currentStroke))
            currentPutt -= 1
            pushValueLabel.setText(String(format: "%d", currentPutt))
            updateHoleInfo()
        } else {
            currentStroke -= 1
            strokeValueLabel.setText(String(format: "%d", currentStroke))
            updateHoleInfo()
        }
    }
    @IBAction func puttPlusPressed() {
        if(currentPutt == 15 || currentPutt == currentStroke){
            return
        } else {
            currentPutt += 1
            pushValueLabel.setText(String(format: "%d", currentPutt))
            updateHoleInfo()
        }
    }
    @IBAction func puttMinusPressed() {
        if(currentPutt == 0){
            return
        } else {
            currentPutt -= 1
            pushValueLabel.setText(String(format: "%d", currentPutt))
            updateHoleInfo()
        }
    }
    @IBAction func obPlusPressed() {
        if(currentOb == 5){
            return
        } else {
            currentOb += 1
            obValueLabel.setText(String(format: "%d", currentOb))
            updateHoleInfo()
        }
    }
    @IBAction func obMinusPressed() {
        if(currentOb == 0){
            return
        } else {
            currentOb -= 1
            obValueLabel.setText(String(format: "%d", currentOb))
            updateHoleInfo()
        }
    }
    @IBAction func waterPlusPressed() {
        if(currentWater == 5){
            return
        } else {
            currentWater += 1
            waterValueLabel.setText(String(format: "%d", currentWater))
            updateHoleInfo()
        }
    }
    @IBAction func waterMinusPressed() {
        if(currentWater == 0){
            return
        } else {
            currentWater -= 1
            waterValueLabel.setText(String(format: "%d", currentWater))
            updateHoleInfo()
        }
    }
    
    // MARK: - Set up
    
    func showDetailInput(isShow: Bool) {
        detailInputGroup.setHidden(!isShow)
        isShowDetail = !isShowDetail
    }
    
    func refreshScoreInput(){
        let holeScore = ExtraDefine.USER_DEFAULT.object(forKey: String(format: "Hole %d", currentHoleIndex)) as? NSDictionary
        if(holeScore != nil){
            currentStroke = holeScore?.object(forKey: "shot") as! Int
            currentPutt = holeScore?.object(forKey: "putt") as! Int
            currentOb = holeScore?.object(forKey: "ob") as! Int
            currentWater = holeScore?.object(forKey: "water") as! Int
            currentGuardBunker = holeScore?.object(forKey: "guardBunker") as! Bool
        } else {
            currentStroke = 0
            currentPutt = 0
            currentOb = 0
            currentWater = 0
            currentGuardBunker = false
        }
        holeNumLabel.setText(String(format: "%d%@", currentHoleIndex + 1,"H"))
        strokeValueLabel.setText(String(format: "%d", currentStroke))
        pushValueLabel.setText(String(format: "%d", currentPutt))
        obValueLabel.setText(String(format: "%d", currentOb))
        waterValueLabel.setText(String(format: "%d", currentWater))
        if(currentGuardBunker == true){
            guardBunkerImage.setImageNamed("input_score_detail_on")
        } else {
            guardBunkerImage.setImageNamed("input_score_detail_off")
        }
    }
    
    func setUpLanguage(){
        detailInputHeaderLabel.setText(NSLocalizedString("input_score_detail_input_header", comment: ""))
        waterHeaderLabel.setText(NSLocalizedString("input_score_water_header", comment: ""))
        guardBunkerHeaderLabel.setText(NSLocalizedString("input_score_guard_bunker_header", comment: ""))
        backButton.setTitle(NSLocalizedString("input_score_back_button_title", comment: ""))
    }
    
    func updateHoleInfo(){
        let score = NSMutableDictionary.init()
        score.setObject(currentStroke, forKey: "shot" as NSCopying)
        score.setObject(currentPutt, forKey: "putt" as NSCopying)
        score.setObject(currentOb, forKey: "ob" as NSCopying)
        score.setObject(currentWater, forKey: "water" as NSCopying)
        score.setObject(currentGuardBunker, forKey: "guardBunker" as NSCopying)
        
        ExtraDefine.USER_DEFAULT.set(score, forKey: String(format: "Hole %d", currentHoleIndex))
    }

}
