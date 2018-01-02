//
//  Labyrinth.swift
//  FlowMaze
//
//  Created by Knut Erik Borgen on 17.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import UIKit
import GameKit

class Labyrinth: UIImageView {
    let colorWall = UIColor(red:0.25, green:0.25, blue:0.26, alpha:1.0).cgColor
    let colorFill = UIColor(red:0.53, green:0.75, blue:0.92, alpha:1.0).cgColor
    // UIColor(red:0.28, green:0.55, blue:0.78, alpha:1.0).cgColor (darker blue)
    let colorBackground = UIColor.white.cgColor
    
    let imageView:UIImageView = UIImageView();
    
    var board: [[Bool]] = []
    
    let boxSize = 25
    var marginTop = 0, marginLeft = 0
    var mazeRowSize = 0, mazeColSize = 0, level = HighScores.sharedInstance.getLastCompletedLevel() + 1
    
    var mode = GameMode.PLAYING
    
    var drawPoints:Set = Set<CGPoint>()
    var gameActions:[GameAction] = []
    
    let timeBetweenDraw:CFTimeInterval = 0.02
    
    var tick:Int = 0
    
    var timer:Timer? = nil
    
    var menuScaledHeight:Int?
    var menuDrawPoint:CGRect?
    
    var badThings: [EnemyBasis] = []
    
    @objc func updateTimer() {
        tick = tick + 1
        
        gameLoop()
        setNeedsDisplay()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func activateTimer() {
        if(timer != nil && (timer?.isValid)!) {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: timeBetweenDraw, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        activateTimer()
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.addSubview(imageView)
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let bounds = imageView.bounds
        var height:CGFloat = CGFloat(0), width:CGFloat = CGFloat(0)
        
        if #available(iOS 11.0, *) {
            height = bounds.size.height - safeAreaInsets.bottom - safeAreaInsets.top
        } else {
            height = bounds.size.height
        }
        if #available(iOS 11.0, *) {
            width = bounds.size.width - safeAreaInsets.left - safeAreaInsets.right
        } else {
            width = bounds.size.width
        }
        
        mazeColSize = Int(floor(width / 25)) - 1
        mazeRowSize = Int(floor(height / 25)) - 1
        
        if #available(iOS 11.0, *) {
            marginLeft =  Int(safeAreaInsets.left)
        } else {
            marginLeft = 0
        }
        
        if #available(iOS 11.0, *) {
            marginTop = (Int(height) - mazeRowSize * boxSize) / 2 + Int(safeAreaInsets.top)
        } else {
            marginTop = (Int(height) - mazeRowSize * boxSize) / 2
        }
        
        makeMaze()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pauseGame(notification:)), name: Notification.Name("pauseGame"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartGame(notification:)), name: Notification.Name("restartGame"), object: nil)
    }
    
    @objc func pauseGame(notification: Notification) {
        stopTimer()
        
    }
    
    @objc func restartGame(notification: Notification) {
        activateTimer()
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: self.imageView)
        
        if(mode != GameMode.PLAYING) {
            menuClick(point:point);
            return
        }
        
        let cellX = (Int(point.x) - marginLeft) / boxSize
        let cellY = (Int(point.y) - marginTop) / boxSize
        
        board[cellY][cellX] = !board[cellY][cellX]
        
        gameActions.append(GameAction(x:cellX, y:cellY, tick:tick, cellValue:board[cellY][cellX] ))
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.draw(in:imageView.bounds)
        
        context?.setFillColor(board[cellY][cellX] ? UIColor.white.cgColor : colorWall)
        context?.fill(CGRect(x: (cellX * boxSize) + marginLeft, y: (cellY * boxSize) + marginTop, width: boxSize, height: boxSize ))
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    func menuClick(point:CGPoint) {
        let scale = 363.0 / Double(menuScaledHeight!) 
        
        let relativeY = Int(Double(point.y - menuDrawPoint!.origin.y) * scale)

        if(relativeY > 226 && relativeY < 292) {
            NotificationCenter.default.post(name: Notification.Name("goToMenu"), object: nil)
        }
        
        if( relativeY > 138 && relativeY < 191) {
            if(mode == GameMode.HIGHSCORE || mode == GameMode.SUCCESS) {
                level = level + 1
            }
            
            startGame()
        }
        
        NSLog("relativeY %d", relativeY)
        
    }
    
    func fillMaze(rs:GKMersenneTwisterRandomSource, row:Int, col:Int) {
        
        if(col  == 0 || col == mazeColSize - 1 || row == 0 || row == mazeRowSize - 1) {
            return;
        }
        
        board[row][col] = true
        
        let checkOrder = [ NextCell(x:-1,y:0), NextCell(x:1,y:0), NextCell(x:0,y:-1), NextCell(x:0,y:1)].shuffled(rs:rs)
        
        for cell in checkOrder {
            
            if(col + cell.x == 0 || col+cell.x == mazeColSize - 1 || row + cell.y == 0 || row + cell.y == mazeRowSize - 1) {
                continue;
            }
            
            let checkCells = cell.cellsNeedsToBeFree()
            
            var continueToNextCell = true
            
            for (checkX, checkY) in checkCells {
                if(col + checkX < 0 || col + checkX > mazeColSize || row + checkY < 0 || row + checkY > mazeRowSize) {
                    continueToNextCell = false
                    break
                }
                
                if(board[row+checkY][col+checkX]) {
                    continueToNextCell = false
                    break
                }
            }
            
            if(continueToNextCell) {
                fillMaze(rs:rs, row: row + cell.y, col:col + cell.x)
            }
            
        }
        
    }
    
    func addEntryAndExitToMaze() {
        var row:Int = 0;
        
        while(row < mazeRowSize && !board[row][mazeColSize / 2]) {
            board[row][mazeColSize / 2] = true
            row = row + 1
        }
        
        row = mazeRowSize - 1;
        while(row > 0 && !board[row][mazeColSize / 2]) {
            board[row][mazeColSize / 2] = true
            row = row - 1
        }
    }
    
    func createMaze() {
        
        let rs = GKMersenneTwisterRandomSource()
        rs.seed = UInt64(level)
        board = []
        
        
        for _ in 0..<mazeRowSize {
            var row: [Bool] = []
            for _ in 0..<mazeColSize {
                row.append(false);
            }
            board.append(row)
        }
        
        let randomRow = rs.nextInt(upperBound: mazeRowSize-4)
        let randomCol = rs.nextInt(upperBound: mazeColSize-4)
        
        fillMaze(rs: rs, row: randomRow + 2, col: randomCol + 2)
        addEntryAndExitToMaze()
        
        badThings.removeAll()
        LevelInfo.sharedInstance.addBadThings(parent:self, rs:rs)
    }

  
    
    func boxAt(p:Point) -> CGRect {
        return boxAt(p.x, p.y)
    }
    
    func boxAt(_ x: Int, _ y: Int) -> CGRect {
        return CGRect(x: (x * boxSize) + marginLeft, y: (y * boxSize) + marginTop, width: boxSize, height: boxSize )
    }
    
    fileprivate func makeMaze() {
        
        createMaze()
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(imageView.bounds)
        
        for x in 0..<mazeColSize {
            for y in 0..<mazeRowSize {
                
                if(board[y][x]) {
                    continue;
                }
                context?.setFillColor(colorWall)
                context?.fill(boxAt(x, y))
                
            }
        }
        
        context?.setFillColor(UIColor.clear.cgColor)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.addRect(CGRect(x: marginLeft, y: marginTop, width: boxSize*mazeColSize, height: (boxSize*mazeRowSize) - 1 ))
        
        context?.strokePath()
        
        /* End point */
        context?.setFillColor(UIColor.yellow.cgColor)
        context?.fill(CGRect(x: marginLeft + boxSize*(mazeColSize) / 2 + (boxSize / 2) - 2,
                             y: marginTop + boxSize * mazeRowSize - 4,
                             width: 4,
                             height: 4))
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let startX = marginLeft + ((mazeColSize / 2) * boxSize) + boxSize / 2
        let startY = marginTop + boxSize / 2
        
        drawPoints.insert( CGPoint(x:startX, y:startY) );
        
    }
    
    
    
    fileprivate func fillMaze(context:CGContext) {
        let checkCoords = [(1,0),(0,1),(-1,0),(0,-1)]
        
        var newPoints:Set = Set<CGPoint>();
     
        context.setFillColor(colorFill)
        
        findNewPoints(context, checkCoords, &newPoints)
        
        context.strokePath()
        
      
        
        drawPoints = newPoints
    }
    
    func colorIsWhite(_ c: [CUnsignedChar]) -> Bool {
        return c[0] == 255 && c[1] == 255 && c[2] == 255
    }
    
    func colorIsYellow(_ c: [CUnsignedChar]) -> Bool {
        return c[0] == 255 && c[1] == 255 && c[2] == 0
    }
    
    
    fileprivate func findNewPoints(_ context: CGContext?, _ checkCoords: [(Int, Int)], _ newPoints: inout Set<CGPoint>) {
        
        if(drawPoints.count == 0) {
            mode = GameMode.GAME_OVER
            showMenu()
            return
        }
        
        for point in drawPoints {
            let x = Int(point.x)
            let y = Int(point.y)
            
            context?.fill(CGRect(x: x, y: y, width: 1, height: 1 ))
            
            for (p1,p2) in checkCoords {
                if(outOfBounds(y: y+p1, x: x+p2)) {
                    continue
                }
                let c = self.imageView.image!.getPixelColor(y: y + p1, x: x + p2)
                
                if(colorIsYellow(c)) {
                    let highScore = HighScores.sharedInstance.postScore(score:GameScore(actions:gameActions, endTick:tick, level:level))
                    mode = highScore ? GameMode.HIGHSCORE : GameMode.SUCCESS
                    showMenu()
                    return
                }
                
                if(colorIsWhite(c)) {
                    newPoints.insert ( CGPoint(x:x+p2, y:y+p1) )
                }
            }
        }
    }
    
    func outOfBounds(y:Int, x:Int) -> Bool {
        return y <= marginTop || y >= marginTop + mazeRowSize * boxSize
            || x <= marginLeft || x >= marginLeft + mazeColSize * boxSize
    }
    
    func outOfBoundsCells(y:Int, x:Int) -> Bool {
        return (x < 0) || (y < 0) || (x >= mazeColSize) || (y >= mazeRowSize)
    }
    
    func startGame() {
      
        drawPoints.removeAll()
        tick = 0
        gameActions.removeAll()
        makeMaze()
        mode = GameMode.PLAYING
    }
    
    func gameLoop() {
        if mode != GameMode.PLAYING {
            return
        }
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()!
        imageView.image?.draw(in:imageView.bounds)
        
        for b in badThings {
            b.tick(context:context)
        }
        
        fillMaze(context:context)
        
        if(drawPoints.count < 50) {
            fillMaze(context:context)
            fillMaze(context:context)
        }
        

        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
      //  NSLog("%d %d", tick, drawPoints.count)
    }
    
    func showMenu() {
        
        var topImage: UIImage?
        
        switch(mode) {
        case .GAME_OVER:
            topImage = UIImage(named: "GameOver.png")!
            break
        case .SUCCESS:
            topImage = UIImage(named: "Success.png")!
            break
        case .HIGHSCORE:
            topImage = UIImage(named: "Highscore.png")!
            break
        default:
            break
        }
        
        if(topImage != nil) {
            
            topImage = topImage!.resized(toWidth: imageView.bounds.width)!

            menuScaledHeight = Int(topImage!.size.height)
            menuDrawPoint = CGRect(origin: CGPoint(x:0, y:imageView.bounds.height / 2 - topImage!.size.height / 2), size: topImage!.size)
            
            topImage?.draw(in: menuDrawPoint!)
        }
    }

  
    
}



struct NextCell {
    var x = 0
    var y = 0
    
    func cellsNeedsToBeFree() -> [(Int,Int)] {
        if(x == -1 && y == 0) {
            return  [(-1,-1), (-2,0), (-1,1)]
        }
        if(x == 1 && y == 0) {
            return [(1,-1), (2,0), (1,1)]
        }
        if(x == 0 && y == -1) {
            return [(0,-2), (-1,-1), (1,-1)]
        }
        return [(0,2), (-1,1), (1,1)]
    }
}

enum GameMode {
    case GAME_OVER, PLAYING, HIGHSCORE, SUCCESS
    
}

extension UIImage {
    func getPixelColor(y:Int, x:Int) -> [CUnsignedChar] {
        
        guard let cgImage = cgImage, let pixelData = cgImage.dataProvider?.data else { return [] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        
        let pixelInfo: Int = ((cgImage.bytesPerRow * y) + (x * bytesPerPixel))
        
        
        return [data[pixelInfo+2], data[pixelInfo+1], data[pixelInfo], data[pixelInfo+3]]
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension CGColor {
    func getColorArray() -> [CUnsignedChar] {
        
        UIGraphicsBeginImageContext(CGSize(width:1, height:1))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(self)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1 ))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!.getPixelColor(y:0,x:0)
    }

}

extension MutableCollection {
    mutating func shuffle(rs:GKMersenneTwisterRandomSource) {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(rs.nextInt(upperBound:numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    func shuffled(rs:GKMersenneTwisterRandomSource) -> [Element] {
        var result = Array(self)
        result.shuffle(rs:rs)
        return result
    }
}

extension CGPoint: Hashable {
    public var hashValue: Int {
        return self.x.hashValue << MemoryLayout<CGFloat>.size ^ self.y.hashValue
    }
}

// Hashable requires Equatable, so define the equality function for CGPoints.
public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.equalTo(rhs)
}

struct Point:Hashable {
    var x:Int=0
    var y:Int=0
    
    func move(direction:Point) -> Point {
        return Point(x: x+direction.x, y: y+direction.y)
    }
    
    func inverse() -> Point {
        return Point(x: -x, y: -y)
    }
    
    public var hashValue: Int {
        return self.x.hashValue << MemoryLayout<Int>.size ^ self.y.hashValue
    }
    
    static func == (lhs: Point, rhs: Point) -> Bool {
          return lhs.x == rhs.x && lhs.y == rhs.y
    }
}


