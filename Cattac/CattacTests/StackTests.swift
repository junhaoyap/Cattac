/*
    The Stack data structure tests
*/

import XCTest

class StackTests : XCTestCase {
    
    func testPush() {
        var stack = Stack<Int>()
        
        stack.push(1)
        
        XCTAssertEqual(stack.toArray(), [1], "The 1st item is not pushed correctly!")
        
        stack.push(2)
        
        XCTAssertEqual(stack.toArray(), [2, 1], "The 2nd item is not pushed correctly!")
        
        stack.push(3)
        
        XCTAssertEqual(stack.toArray(), [3, 2, 1], "The 2rd item is not pushed correctly!")
        
        stack.push(2)
        
        XCTAssertEqual(stack.toArray(), [2, 3, 2, 1], "A duplicated item is not pushed correctly!")
        
        stack.push(4)
        stack.push(4)
        
        XCTAssertEqual(stack.toArray(), [4, 4, 2, 3, 2, 1], "Sequentially pushing duplicated items are not pushed correctly!")
        
        stack.pop()
        stack.push(7)
        
        XCTAssertEqual(stack.toArray(), [7, 4, 2, 3, 2, 1], "The item that is pushed after popping is not being pushed correctly!")
        
        stack.peek()
        stack.push(8)
        
        XCTAssertEqual(stack.toArray(), [8, 7, 4, 2, 3, 2, 1], "The item that is pushed after peeking is not being pushed correctly!")
        
        stack.removeAll()
        stack.push(1)
        
        XCTAssertEqual(stack.toArray(), [1], "The item that is pushed after being emptied is not being pushed correctly!")
        
        stack.toArray()
        stack.push(2)
        
        XCTAssertEqual(stack.toArray(), [2, 1], "The item that is pushed after being toArray-ed is not being pushed correctly!")
    }
    
    func testPop() {
        var stack = Stack<Int>()
        var poppedItem: Int?
        
        stack.push(1)
        poppedItem = stack.pop()
        
        XCTAssertEqual(poppedItem!, 1, "The first item is not popped correctly!")
        
        stack.push(2)
        stack.push(3)
        poppedItem = stack.pop()
        
        XCTAssertEqual(poppedItem!, 3, "The second item is not popped correctly with 2 items!")
        
        stack.pop()
        
        XCTAssertNil(stack.pop(), "Nil was not returned when trying to pop an empty stack!")
        
        stack.push(1)
        stack.push(2)
        stack.peek()
        poppedItem = stack.pop()
        
        XCTAssertEqual(poppedItem!, 2, "The second item is not popped correctly after peeking!")
        
        stack.push(4)
        stack.push(4)
        stack.removeAll()
        
        XCTAssertNil(stack.pop(), "Nil was not returned after popping a stack that was emptied with removeAll!")
        
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.toArray()
        poppedItem = stack.pop()
        
        XCTAssertEqual(poppedItem!, 3, "The item that was popped is not correct after the stack has been toArray-ed")
    }
    
    func testPeek() {
        var stack = Stack<Int>()
        
        XCTAssertNil(stack.peek(), "The stack did not 'peek' a nil at initialisation!")
        
        stack.push(1)
        
        XCTAssertEqual(stack.peek()!, 1, "The stack did not peek correctly with 1 item!")
        
        stack.push(2)
        
        XCTAssertEqual(stack.peek()!, 2, "The stack did not peek correctly with 2 items!")
        
        stack.pop()
        
        XCTAssertEqual(stack.peek()!, 1, "The stack did not peek correctly with 1 item after being popped!")
        
        stack.push(3)
        stack.push(4)
        stack.pop()
        
        XCTAssertEqual(stack.peek()!, 3, "The stack did not peek correctly with 2 items after being popped!")
        
        stack.peek()
        
        XCTAssertEqual(stack.peek()!, 3, "The stack did not peek correctly after being peeked at 2 times sequentially!")
        
        stack.removeAll()
        
        XCTAssertNil(stack.peek(), "The stack did not 'peek' a nil after being emptied!")
        
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.toArray()
        
        XCTAssertEqual(stack.peek()!, 3, "The stack did not peek correctly after being toArray-ed!")
    }
    
    func testCount() {
        var stack = Stack<Int>()
        
        XCTAssertEqual(stack.count, 0, "The stack's length is not correct at initialisation!")
        
        stack.push(1)
        
        XCTAssertEqual(stack.count, 1, "The stack's length is not correct after pushing 1 item!")
        
        stack.push(2)
        stack.push(3)
        
        XCTAssertEqual(stack.count, 3, "The stack's length is not correct after pushing 2 more items!")
        
        stack.pop()
        
        XCTAssertEqual(stack.count, 2, "The stack's length is not correct after popping 1 item!")
        
        stack.push(3)
        stack.pop()
        stack.pop()
        
        XCTAssertEqual(stack.count, 1, "The stack's length is not correct after popping 2 items!")
        
        stack.peek()
        
        XCTAssertEqual(stack.count, 1, "The stack's length is not correct after peeking!")
        
        stack.push(2)
        stack.removeAll()
        
        XCTAssertEqual(stack.count, 0, "The stack's length is not correct after being emptied!")
        
        stack.push(1)
        stack.push(2)
        stack.toArray()
        
        XCTAssertEqual(stack.count, 2, "The stack's length is not correct after being toArray-ed!")
    }
    
    func testIsEmpty() {
        var stack = Stack<Int>()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack's emptiness is not being checked correctly at initialisation!")
        
        stack.push(1)
        
        XCTAssertEqual(stack.isEmpty, false, "The stack's emptiness is not being checked correctly after pushing an item and having only 1 item!")
        
        stack.push(2)
        
        XCTAssertEqual(stack.isEmpty, false, "The stack's emptiness is not being checked correctly after pushing an item and having 2 items!")
        
        stack.pop()
        
        XCTAssertEqual(stack.isEmpty, false, "The stack's emptiness is not being checked correctly after popping an item and having at least an item!")
        
        stack.pop()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack's emptiness is not being checked correctly after popping an item and being empty!")
        
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.peek()
        
        XCTAssertEqual(stack.isEmpty, false, "The stack's emptiness is not being checked correctly after peeking!")
        
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack's emptiness is not being checked correctly after being emptied!")
        
        stack.push(1)
        stack.push(2)
        stack.toArray()
        
        XCTAssertEqual(stack.isEmpty, false, "The stack's emptiness is not  being checked correctly after being toArray-ed!")
    }
    
    func testRemoveAll() {
        var stack = Stack<Int>()
        
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied while being empty at initialisation!")
        
        stack.push(1)
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied while having 1 item!")
        
        stack.push(1)
        stack.push(2)
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied while having 2 items!")
        
        stack.push(1)
        stack.push(2)
        stack.pop()
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied after being popped!")
        
        stack.push(1)
        stack.push(2)
        stack.peek()
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied after being peeked!")
        
        stack.push(1)
        stack.push(2)
        stack.toArray()
        stack.removeAll()
        
        XCTAssertEqual(stack.isEmpty, true, "The stack is not empty after being emptied after being toArray-ed!")
    }
    
    func testToArray() {
        var stack = Stack<Int>()
        
        XCTAssertEqual(stack.toArray(), [], "The stack is not being converted to an array correctly at initial empty state!")
        
        stack.push(1)
        
        XCTAssertEqual(stack.toArray(), [1], "The stack is not being converted to an array correctly after having 1 item being pushed!")
        
        stack.push(2)
        
        XCTAssertEqual(stack.toArray(), [2, 1], "The stack is not being converted to an array correctly after having more than 1 item being pushed!")
        
        stack.pop()
        
        XCTAssertEqual(stack.toArray(), [1], "The stack is not being converted to an array correctly after being popped!")
        
        stack.peek()
        
        XCTAssertEqual(stack.toArray(), [1], "The stack is not being converted to an array correctly after being peeked at!")
        
        stack.push(2)
        stack.removeAll()
        
        XCTAssertEqual(stack.toArray(), [], "The stack is not being converted to an array correctly after being emptied!")
        
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.toArray()
        
        XCTAssertEqual(stack.toArray(), [3, 2, 1], "The stack is not being converted to an array correctly after being toArray-ed twice sequentially!")
    }
}