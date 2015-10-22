/*
    The Edge data structure tests
*/

import XCTest

class EdgeTests: XCTestCase {
    
    func testConstruct() {
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        XCTAssertEqual(edge.getSource(), node1, "Edge's source is not constructed properly")
        XCTAssertEqual(edge.getDestination(), node2, "Edge's desitination is not constructed properly")
        XCTAssertEqual(edge.getWeight(), 2.0, "Edge's weight is not constructed properly")
    }
    
    func testReverse_swapSourceAndDestinationWithSameWeight() {
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 3.0)
        
        let reversedEdge = edge.reverse()
        
        XCTAssertEqual(reversedEdge.getSource(), node2, "Reversed edge's source is not correct")
        XCTAssertEqual(reversedEdge.getDestination(), node1, "Reversed edges's destination is not correct")
        XCTAssertEqual(reversedEdge.getWeight(), 3.0, "Reversed edges's weight is not correct")
    }
    
    func testReverse_twiceReversedEdge_sameEdge() {
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 3.0)
        
        let twiceReversedEdge = edge.reverse().reverse()
        
        XCTAssertEqual(twiceReversedEdge, edge, "Twiced-reversed edge should be same as the original edge")
    }
    
    func testEqual_sameSourceSameDestinationSameWeight_isEqual() {
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 5.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 5.0)
        
        XCTAssertEqual(edge1, edge2, "Edges with same source, destination and weight should be equal")
    }
    
    func testEqual_differentWeight_isNotEqual() {
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 5.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 10.0)
        
        XCTAssertNotEqual(edge1, edge2, "Edges with different weights should not be equal")
    }
    
    // MARK: Examples
    
    // There is currently no way to test assertion in Swift. This test
    // should give assertion error. Disable it after checking.
    func DISABLE_testRepInvariant_nonNegativeWeight() {
    }
}