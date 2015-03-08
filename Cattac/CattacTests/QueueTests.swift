/*
    The Queue data structure tests
*/

import XCTest

class QueueTests: XCTestCase {
    
    func testEnqueue() {
        var queue = Queue<String>()
        
        queue.enqueue("1")
        
        XCTAssertEqual(queue.toArray(), ["1"], "The item is not enqueued correctly!")
        
        queue.enqueue("2")
        
        XCTAssertEqual(queue.toArray(), ["1", "2"], "The second item is not being enqueued correctly!")
        
        queue.enqueue("3")
        
        XCTAssertEqual(queue.toArray(), ["1", "2", "3"], "The item beyond the first item is not being enqueued correctly!")
        
        queue.enqueue("2")
        
        XCTAssertEqual(queue.toArray(), ["1", "2", "3", "2"], "A duplicate item is not being enqueued correctly!")
        
        queue.enqueue("4")
        queue.enqueue("4")
        
        XCTAssertEqual(queue.toArray(), ["1", "2", "3", "2", "4", "4"], "Sequential duplicate items is not being enqueued correctly!")
        
        queue.dequeue()
        queue.enqueue("4")
        
        XCTAssertEqual(queue.toArray(), ["2", "3", "2", "4", "4", "4"], "Item enqueued after using dequeue is not being enqueued correctly!")
        
        queue.peek()
        queue.enqueue("5")
        
        XCTAssertEqual(queue.toArray(), ["2", "3", "2", "4", "4", "4", "5"], "Item enqueued after using peek is not being enqueued correctly!")
        
        queue.removeAll()
        queue.enqueue("6")
        
        XCTAssertEqual(queue.toArray(), ["6"], "Item enqueued after emptying the queue is not being enqueued correctly!")
    }
    
    func testDequeue() {
        var queue = Queue<String>()
        var dequeuedItem: String?
        
        queue.enqueue("1")
        dequeuedItem = queue.dequeue()
        
        XCTAssertEqual(dequeuedItem!, "1", "The first item is not dequeued correctly!")
        
        queue.enqueue("2")
        queue.enqueue("3")
        dequeuedItem = queue.dequeue()
        
        XCTAssertEqual(dequeuedItem!, "2", "The second item is not being dequeued correctly with 2 items!")
        
        queue.dequeue()
        
        XCTAssertNil(queue.dequeue(), "Nil was not returned when trying to dequeue an empty queue!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.peek()
        
        dequeuedItem = queue.dequeue()
        
        XCTAssertEqual(dequeuedItem!, "1", "A wrong item was dequeued after peeking!")
        
        queue.enqueue("4")
        queue.enqueue("4")
        queue.removeAll()
        
        XCTAssertNil(queue.dequeue(), "Nil was not returned after dequeing a queue that was emptied with removeAll!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.enqueue("3")
        queue.toArray()
        
        XCTAssertEqual(queue.dequeue()!, "1", "A wrong item was returned after dequeuing a queue that had been toArray-ed!")
    }
    
    func testPeek() {
        var queue = Queue<String>()
        
        XCTAssertNil(queue.peek(), "The queue did not 'peek' a nil at initialisation!")
        
        queue.enqueue("1")
        
        XCTAssertEqual(queue.peek()!, "1", "The queue did not peek correctly with 1 item!")
        
        queue.enqueue("2")
        
        XCTAssertEqual(queue.peek()!, "1", "The queue did not peek correctly with 2 items!")
        
        queue.dequeue()
        
        XCTAssertEqual(queue.peek()!, "2", "The queue did not peek correctly with 1 item after being dequeued!")
        
        queue.enqueue("3")
        queue.enqueue("4")
        queue.dequeue()
        
        XCTAssertEqual(queue.peek()!, "3", "The queue did not peek correctly with 2 items after being dequeued!")
        
        queue.peek()
        
        XCTAssertEqual(queue.peek()!, "3", "The queue did not peek correctly after being peeked at twice sequentially!")
        
        queue.removeAll()
        
        XCTAssertNil(queue.peek(), "The queue did not 'peek' a nil after being emptied!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.enqueue("3")
        queue.toArray()
        
        XCTAssertEqual(queue.peek()!, "1", "The queue did not peek correctly after being toArray-ed!")
    }
    
    func testCount() {
        var queue = Queue<String>()
        
        XCTAssertEqual(queue.count, 0, "The queue's length is not correct at initialisation!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.enqueue("3")
        
        XCTAssertEqual(queue.count, 3, "The queue's length is not correct!")
        
        queue.peek()
        
        XCTAssertEqual(queue.count, 3, "The queue's length is not correct after a peek!")
        
        queue.dequeue()
        
        XCTAssertEqual(queue.count, 2, "The queue's length is not correct after a dequeue!")
        
        queue.toArray()
        
        XCTAssertEqual(queue.count, 2, "The queue's length is not correct after conversion to an array!")
        
        queue.removeAll()
        
        XCTAssertEqual(queue.count, 0, "The queue's length is not correct after being emptied!")
    }
    
    func testIsEmpty() {
        var queue = Queue<String>()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue's emptiness is not being checked correctly at initial empty state!")
        
        queue.enqueue("0")
        
        XCTAssertEqual(queue.isEmpty, false, "The queue's emptiness is not being checked correctly after enqueueing an item!")
        
        queue.dequeue()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue's emptiness is not being checked correctly after a dequeue and being empty!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.dequeue()
        
        XCTAssertEqual(queue.isEmpty, false, "The queue's emptiness is not being checked correctly after a dequeue and not being empty!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.enqueue("3")
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue's emptiness is not being checked correctly after being emptied")
    }
    
    func testRemoveAll() {
        var queue = Queue<String>()
        
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied while being empty at initialisation!")
        
        queue.enqueue("1")
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied while having 1 item!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied while having 2 items!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.dequeue()
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied after being dequeued!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.peek()
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied after being peeked!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.toArray()
        queue.removeAll()
        
        XCTAssertEqual(queue.isEmpty, true, "The queue is not empty after being emptied after being toArray-ed!")
    }
    
    func testToArray() {
        var queue = Queue<String>()
        
        XCTAssertEqual(queue.toArray(), [], "The queue is not being converted to an array correctly at initial empty state!")
        
        queue.enqueue("1")
        
        XCTAssertEqual(queue.toArray(), ["1"], "The queue is not converted to an array correctly after an enqueue!")
        
        queue.enqueue("2")
        queue.enqueue("3")
        
        XCTAssertEqual(queue.toArray(), ["1", "2", "3"], "The queue is not converted to an array correctly after 3 enqueues!")
        
        queue.peek()
        
        XCTAssertEqual(queue.toArray(), ["1", "2", "3"], "The queue is not converted to an array correctly after a peek!")
        
        queue.dequeue()
        
        XCTAssertEqual(queue.toArray(), ["2", "3"], "The queue is not converted to an array correctly after a dequeue and being empty!")
        
        queue.enqueue("1")
        queue.enqueue("2")
        queue.dequeue()
        
        XCTAssertEqual(queue.toArray(), ["3", "1" ,"2"], "The queue is not converted to an array correctly after a dequeue and not being empty!")
        
        queue.removeAll()
        
        XCTAssertEqual(queue.toArray(), [], "The queue is not converted to an array correctly after being emptied!")
    }
}