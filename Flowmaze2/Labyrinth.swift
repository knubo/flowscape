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
    
    let imageView:UIImageView = UIImageView();
    
    var board: [[Bool]] = []
    var mazeRowSize = 0, mazeColSize = 0, level = 4
    
    var drawPoints:Set = Set<CGPoint>()
    
    let timeBetweenDraw:CFTimeInterval = 0.01
    
    var tick:Int = 0
    
    @objc func updateTimer() {
        tick = tick + 1
        
        gameLoop()
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
         Timer.scheduledTimer(timeInterval: timeBetweenDraw, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.addSubview(imageView)
        
        makeMaze()
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
        
        while(!board[row][mazeColSize / 2]) {
            board[row][mazeColSize / 2] = true
            row = row + 1
        }
        
        row = mazeRowSize - 1;
        while(!board[row][mazeColSize / 2]) {
            board[row][mazeColSize / 2] = true
            row = row - 1
        }
    }
    
    func createMaze() {
        
        let rs = GKMersenneTwisterRandomSource()
        rs.seed = UInt64(level)
        
        for _ in 0..<mazeRowSize {
            var row: [Bool] = []
            for _ in 0..<mazeColSize {
                row.append(false);
            }
            board.append(row)
        }
        
        let randomRow = rs.nextInt(upperBound: mazeRowSize-1)
        let randomCol = rs.nextInt(upperBound: mazeColSize-1)
        
        fillMaze(rs: rs, row: randomRow + 1, col: randomCol + 1)
        addEntryAndExitToMaze()
    }
    
    fileprivate func makeMaze() {
        
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
        
        let boxSize = 25
        var marginTop = 0
        var marginLeft = 0
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
        
        createMaze()
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.draw(in:imageView.bounds)
        
        for x in 0..<mazeColSize {
            for y in 0..<mazeRowSize {
                
                if(board[y][x]) {
                    continue;
                }
                context?.setFillColor(UIColor.green.cgColor)
                context?.fill(CGRect(x: (x * boxSize) + marginLeft, y: (y * boxSize) + marginTop, width: boxSize, height: boxSize ))
                
            }
        }

        context?.setFillColor(UIColor.clear.cgColor)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.addRect(CGRect(x: marginLeft, y: marginTop, width: boxSize*mazeColSize, height: (boxSize*mazeRowSize) - 1 ))
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let startX = marginLeft + ((mazeColSize / 2) * boxSize) + boxSize / 2
        let startY = marginTop + boxSize / 2
        
        drawPoints.insert( CGPoint(x:startX, y:startY) );
    }
    
    
    fileprivate func fillMaze() {
        let checkCoords = [(1,0),(0,1),(-1,0),(0,-1)]
        
        var newPoints:Set = Set<CGPoint>();
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.draw(in:imageView.bounds)
        
        context?.setFillColor(UIColor.blue.cgColor)
        
        for point in drawPoints {
            let x = Int(point.x)
            let y = Int(point.y)
            
            context?.fill(CGRect(x: x, y: y, width: 1, height: 1 ))
            
            for (p1,p2) in checkCoords {
                let c = colorOfPoint(y: y + p1, x: x + p2)
                
                if(c[0] == 255 && c[1] == 255 && c[2] == 255) {
                    newPoints.insert ( CGPoint(x:x+p2, y:y+p1) )
                }
            }
        }
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        drawPoints = newPoints
    }
    
    func gameLoop() {
        fillMaze()
        
        if(drawPoints.count < 50) {
            fillMaze()
            fillMaze()
            fillMaze()
        }
        if(drawPoints.count < 100) {
            fillMaze()
            fillMaze()
        }
       
        
        
        NSLog("%d %d", tick, drawPoints.count)
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

extension UIView {
    
    func colorOfPoint(y:Int, x:Int) -> [CUnsignedChar] {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -CGFloat(x), y: -CGFloat(y))
        
        self.layer.render(in: context!)
        
        return pixel;
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

