//
//  HighScores.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 30.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//
// "levels" : [1,2,3,4,5,6,...]
// "level" : ["me"]
// level+"_moves_me" -> ["x:10,y:10,tick:10,cell:true", "x:15,y:40,tick:2000,cell:false"]
// level+"_tick_me" -> tick
// level+"_when_me" -> Date
//
// Store lowest tick.

import Foundation
import GameKit

class HighScores {
    static let sharedInstance = HighScores()
    let ME_CONST = "me"
    
    fileprivate func highscoreDefaults() -> UserDefaults {
        return UserDefaults(suiteName: "group.flowmaze.knubo.no")!
    }
    
    func increaseGameCount() {
        let defaults = highscoreDefaults()
        let playCount = defaults.integer(forKey:"playCount")
        defaults.set(playCount + 1, forKey:"playCount")
        
    }
    
    func postScore(score:GameScore, rs:GKMersenneTwisterRandomSource) -> Bool {
        let defaults = highscoreDefaults()
        
        defaults.set(score.boardSize!.x, forKey:"board_size_x")
        defaults.set(score.boardSize!.y, forKey:"board_size_y")
        

        let maxLevel =  defaults.integer(forKey:"max_successful_level")
        if(score.level > maxLevel) {
            defaults.set(score.level, forKey:"max_successful_level")
        }
        
        var levels = defaults.stringArray(forKey:"levels") ?? [String]()
        
        if(!levels.contains(String(score.level))) {
            levels.append(String(score.level))
            defaults.set(levels, forKey:"levels")
        }
        
        var who = defaults.stringArray(forKey:String(score.level)) ?? [String]()
        if(!who.contains(ME_CONST)) {
            who.append(ME_CONST)
            defaults.set(who, forKey:String(score.level))
        }
        
        let tick = defaults.integer(forKey: String(score.level) + "_tick_"+ME_CONST)
        
        if(tick != 0 && tick < score.endTick) {
            return false
        }
        
        defaults.set(score.endTick, forKey: String(score.level) + "_tick_"+ME_CONST)
        defaults.set(Date().description, forKey:String(score.level)+"_when_"+ME_CONST)
        defaults.set(score.describeActions(), forKey:String(score.level)+"moves_"+ME_CONST)
      
        var s:String = ""
        for _ in 1...40 {
            s = s + String(rs.nextInt(upperBound:9))
        }
        
        defaults.set(s, forKey: String(score.level)+"checksum_"+ME_CONST)
        
        return true
    }
    
    func getPlayCount() -> Int {
        let defaults = highscoreDefaults()
        
        return defaults.integer(forKey:"playCount")
    }
    
    func getLastCompletedLevel() -> Int {
        let defaults = highscoreDefaults()

        return defaults.integer(forKey:"max_successful_level")
    }
    
    func setDimensions(width:Int, height:Int) {
        let defaults = highscoreDefaults()

        defaults.set(width, forKey:"pixel_width")
        defaults.set(height, forKey:"pixel_height")
    }
    
    func getDimensions() -> Point {
        let defaults = highscoreDefaults()

        return Point(x:defaults.integer(forKey:"pixel_width"), y:defaults.integer(forKey:"pixel_height"))
    }
    
    func getMyName() -> String {
        let defaults = highscoreDefaults()
        
        let name = defaults.string(forKey: "share_name")
        
        if(name != nil) {
            return name!
        }
        
        return "Player 1"
    }
    
    func setMyName(name:String) {
        let defaults = highscoreDefaults()

        defaults.set(name, forKey:"share_name")
    }
    
    
    func getQRCode(level:Int) -> String {
        let defaults = highscoreDefaults()
        
        let score = getFullScore(l:level, who:ME_CONST)
        
        let jsonObject: [String: String] = [
            "pw": defaults.string(forKey:"pixel_width")!,
            "ph":defaults.string(forKey:"pixel_height")!,
            "bx":defaults.string(forKey:"board_size_x")!,
            "by":defaults.string(forKey:"board_size_y")!,
            "tk":String(score.endTick),
            "ll":String(score.level),
            "wn":score.when,
            "ms":score.describeActions(),
            "cs": defaults.string(forKey:String(level)+"checksum_"+ME_CONST)!,
            "sn": getMyName()
            ]
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(jsonObject)
            return String(data: data, encoding: .utf8)!
        } catch {
            return ""
        }
    }
    
    func scores() -> [GameScore] {
        let defaults = highscoreDefaults()

        let levels = defaults.stringArray(forKey:"levels") ?? [String]()

        let boardSize:Point = Point(x:defaults.integer(forKey:"board_size_x"),y:defaults.integer(forKey:"board_size_y"))
        
        var scores:[GameScore] = []
        
        for l in levels {
            let who = defaults.stringArray(forKey:l) ?? [String]()
            
            for w in who {
                let tick = defaults.integer(forKey: l + "_tick_" + w)

                scores.append(GameScore(actions:[], endTick:tick, level:Int(l)!, boardSize:boardSize, myScore:w == ME_CONST, who:w))
            }
        }
        
        return scores
    }
    
    func getFullScore(l:Int, who:String) -> GameScore {
        let level = String(l)
        let defaults = highscoreDefaults()

        let tick = defaults.integer(forKey: level + "_tick_"+who)
        let when:String = defaults.string(forKey: level+"_when_"+who)!
        let moves = defaults.string(forKey: level+"moves_"+who)
        
        let boardSize:Point = Point(x:defaults.integer(forKey:"board_size_x"),y:defaults.integer(forKey:"board_size_y"))

        let elements = moves!.split(separator:",")
        
        
        var actions:[GameAction] = []
        
        
        var i:Int = 0
        while i < elements.count {
            let x = String(elements[i])
            let y = String(elements[i+1])
            let tick = String(elements[i+2])
            let cellValue = String(elements[i+3]) == "1" ? true : false
            
            actions.append(GameAction(x:Int(x)!,
                                      y:Int(y)!,
                                      tick:Int(tick)!,
                                      cellValue:cellValue))
            i = i + 4
        }
        
        
        return GameScore(actions: actions, endTick: tick, level: l, when:when, boardSize:boardSize, myScore:who == ME_CONST	, who:who)
    }
    
}

struct GameAction {
    var x = 0, y = 0, tick = 0
    var cellValue = false
    
    func info() -> String {
        return String(format:"%d,%d,%d,%d", x, y, tick, cellValue ? 1 : 0)
    }
}

struct GameScore {
    var actions:[GameAction]
    var endTick = 0
    var level = 0
    var when:String = ""
    var boardSize:Point? = nil
    var myScore:Bool
    var who:String
    
    init(actions:[GameAction], endTick:Int, level:Int, boardSize:Point, myScore:Bool, who:String) {
        self.actions = actions
        self.endTick = endTick
        self.level = level
        self.boardSize = boardSize
        self.myScore = myScore
        self.who = who
    }
    
    init(actions:[GameAction], endTick:Int, level:Int, when:String, boardSize:Point, myScore:Bool, who:String) {
        self.actions = actions
        self.endTick = endTick
        self.level = level
        self.when = when
        self.boardSize = boardSize
        self.myScore = myScore
        self.who = who
    }
    
    func describeActions() -> String {
        return actions.map {g in g.info()}.joined(separator:",")
    }
}
