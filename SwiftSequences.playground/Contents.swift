//: Playground - noun: a place where people can play

import UIKit

typealias Block = (Void -> Void)?
typealias BlockWithCompletionBlock = (Block -> Void)?

func doSmth(logic: BlockWithCompletionBlock) {
    logic <^> { print("completion handler") }
}

infix operator <^> { associativity left }
func <^>(f1: BlockWithCompletionBlock, f2: Block) {
    if let f1 = f1 {
        f1(f2)
    }
    else {
        f2?()
    }
}

doSmth { completionHandler in
    print("logic #1")
    completionHandler?()
}

doSmth { completionHandler in
    print("logic #2")
    completionHandler?()
}

/////////////////////////

infix operator <+> { associativity left }

indirect enum BlockBox {
    case InnerBox(Block, BlockBox)
    case Logic(Block)
    
    func invoke() {
        switch self {
            case .InnerBox(let block, let blockBox):
                block?()
                blockBox.invoke()
            case .Logic(let block):
                block?()
        }
    }
}

func <+>(block1: Block, block2: Block) -> BlockBox {
    return BlockBox.InnerBox(block1, BlockBox.Logic(block2))
}

func <+>(block1: Block, blockBox: BlockBox) -> BlockBox {
    return BlockBox.InnerBox(block1, blockBox)
}


func <+>(blockBox: BlockBox, block: Block) -> BlockBox {
    switch blockBox {
        case .InnerBox(let block0, let blockBox0):
            return block0 <+> (blockBox0 <+> block)
        case .Logic(let block0):
            return block0 <+> block
    }
}

func <+>(blockBox1: BlockBox, blockBox2: BlockBox) -> BlockBox {
    switch blockBox1 {
        case .InnerBox(let block, let blockBox):
            return block <+> (blockBox <+> blockBox2)
        case .Logic(let block):
            return block <+> blockBox2
    }
}

let sequence1 = { print("step #1") } <+> { print("step #2") } <+> { print("step #3") }
let sequence2 = { print("step #4") } <+> { print("step #5") } <+> { print("step #6") }
let sequence3 = sequence1 <+> sequence2
let sequence4 = { print("step #0") } <+> sequence3
sequence4.invoke()
