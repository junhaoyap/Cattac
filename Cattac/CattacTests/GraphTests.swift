/*
    The Graph data structure tests
*/

import XCTest

class GraphTests: XCTestCase {
    
    func testAddNodeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        testDirectedGraph.addNode(node1)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Nodes are not being added to a directed unweighted graph properly!")
    }
    
    func testRemoveNodeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.removeNode(node1)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), false, "Nodes are not being removed from a directed unweighted graph properly!")
    }
    
    func testContainsNodeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), false, "Nodes are not being checked in a directed unweighted graph properly!")
    }
    
    func testAddEdgeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being added to a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsNode(node2), true, "Edges are not being added to a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), true, "Edges are not being added to a directed unweighted graph properly!")
    }
    
    func testAddLoopEdgeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        let edge = Edge(source: node1, destination: node1)
        
        testDirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being added to a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), true, "Edges are not being added to a directed unweighted graph properly!")
    }
    
    func testRemoveEdgeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsNode(node2), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), true, "Edges are not being removed from a directed unweighted graph properly!")
        
        testDirectedGraph.removeEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsNode(node2), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), false, "Edges are not being removed from a directed unweighted graph properly!")
    }
    
    func testRemoveLoopEdgeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        let edge = Edge(source: node1, destination: node1)
        
        testDirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), true, "Edges are not being removed from a directed unweighted graph properly!")
        
        testDirectedGraph.removeEdge(edge)
        
        XCTAssertEqual(testDirectedGraph.containsNode(node1), true, "Edges are not being removed from a directed unweighted graph properly!")
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), false, "Edges are not being removed from a directed unweighted graph properly!")
    }
    
    func testContainsEdgeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        XCTAssertEqual(testDirectedGraph.containsEdge(edge), false, "Edges are not being checked in a directed unweighted graph properly!")
    }
    
    func testEdgesFromNodeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.addNode(node2)
        
        XCTAssertEqual(testDirectedGraph.edgesFromNode(node1, toNode: node2), [Edge<String>](), "Edges outwards from a node are not being checked in a directed unweighted graph properly!")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge)
        
        XCTAssertEqual(testDirectedGraph.edgesFromNode(node1, toNode: node2), edgeListToBeReturned, "Edges outwards from a node are not being checked in a directed unweighted graph properly!")
    }
    
    func testAdjacentNodesFromNodeDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.addNode(node2)
        
        XCTAssertEqual(testDirectedGraph.adjacentNodesFromNode(node1), [Node<String>](), "Adjacents nodes from a node are not being checked in a directed unweighted graph properly!")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        
        XCTAssertEqual(testDirectedGraph.adjacentNodesFromNode(node1), nodeListToBeReturned, "Adjacents nodes from a node are not being checked in a directed unweighted graph properly!")
    }
    
    func testVarNodesDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        XCTAssertEqual(testDirectedGraph.nodes, [Node<String>](), "Nodes are not being read from a directed unweighted graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        nodeListToBeReturned.append(node1)
        
        XCTAssertEqual(testDirectedGraph.nodes, nodeListToBeReturned, "Nodes are not being read from a directed unweighted graph properly!")
    }
    
    func testVarEdgesDirectedUnweightedGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        XCTAssertEqual(testDirectedGraph.edges, [Edge<String>](), "Edges are not being read from a directed unweighted graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testDirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge)
        
        XCTAssertEqual(testDirectedGraph.edges, edgeListToBeReturned, "Edges are not being read from a directed unweighted graph properly!")
    }
    
    func testAddNodeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        testUndirectedGraph.addNode(node1)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Nodes are not being added to an undirected weighted graph properly!")
    }
    
    func testRemoveNodeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        testUndirectedGraph.addNode(node1)
        testUndirectedGraph.removeNode(node1)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), false, "Nodes are not being removed from an undirected weighted graph properly!")
    }
    
    func testContainsNodeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), false, "Nodes are not being checked in an undirected weighted graph properly!")
    }
    
    func testAddEdgeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being added to an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsNode(node2), true, "Edges are not being added to an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), true, "Edges are not being added to an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), true, "Edges are not being added to an undirected weighted graph properly!")
    }
    
    func testAddLoopEdgeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        let edge = Edge(source: node1, destination: node1, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being added to an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), true, "Edges are not being added to an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), true, "Edges are not being added to an undirected weighted graph properly!")
    }
    
    func testRemoveEdgeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsNode(node2), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), true, "Edges are not being removed from an undirected weighted graph properly!")
        
        testUndirectedGraph.removeEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsNode(node2), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), false, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), false, "Edges are not being removed from an undirected weighted graph properly!")
    }
    
    func testRemoveLoopEdgeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        let edge = Edge(source: node1, destination: node1, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), true, "Edges are not being removed from an undirected weighted graph properly!")
        
        testUndirectedGraph.removeEdge(edge)
        
        XCTAssertEqual(testUndirectedGraph.containsNode(node1), true, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), false, "Edges are not being removed from an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge.reverse()), false, "Edges are not being removed from an undirected weighted graph properly!")
    }
    
    func testContainsEdgeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        XCTAssertEqual(testUndirectedGraph.containsEdge(edge), false, "Edges are not being checked in an undirected weighted graph properly!")
    }
    
    func testEdgesFromNodeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testUndirectedGraph.addNode(node1)
        testUndirectedGraph.addNode(node2)
        
        XCTAssertEqual(testUndirectedGraph.edgesFromNode(node1, toNode: node2), [Edge<String>](), "Edges outwards from a node are not being checked in an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.edgesFromNode(node2, toNode: node1), [Edge<String>](), "Edges outwards from a node are not being checked in an undirected weighted graph properly!")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned1 = [Edge<String>]()
        var edgeListToBeReturned2 = [Edge<String>]()
        
        edgeListToBeReturned1.append(edge)
        edgeListToBeReturned2.append(edge.reverse())
        
        XCTAssertEqual(testUndirectedGraph.edgesFromNode(node1, toNode: node2), edgeListToBeReturned1, "Edges outwards from a node are not being checked in an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.edgesFromNode(node2, toNode: node1), edgeListToBeReturned2, "Edges outwards from a node are not being checked in an undirected weighted graph properly!")
    }
    
    func testAdjacentNodesFromNodeUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testUndirectedGraph.addNode(node1)
        testUndirectedGraph.addNode(node2)
        
        XCTAssertEqual(testUndirectedGraph.adjacentNodesFromNode(node1), [Node<String>](), "Adjacents nodes from a node are not being checked in an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.adjacentNodesFromNode(node2), [Node<String>](), "Adjacents nodes from a node are not being checked in an undirected weighted graph properly!")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        var nodeListToBeReturned1 = [Node<String>]()
        var nodeListToBeReturned2 = [Node<String>]()
        
        nodeListToBeReturned1.append(node2)
        nodeListToBeReturned2.append(node1)
        
        XCTAssertEqual(testUndirectedGraph.adjacentNodesFromNode(node1), nodeListToBeReturned1, "Adjacents nodes from a node are not being checked in an undirected weighted graph properly!")
        XCTAssertEqual(testUndirectedGraph.adjacentNodesFromNode(node2), nodeListToBeReturned2, "Adjacents nodes from a node are not being checked in an undirected weighted graph properly!")
    }
    
    func testVarNodesUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        XCTAssertEqual(testUndirectedGraph.nodes, [Node<String>](), "Nodes are not being read from an undirected weighted graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        nodeListToBeReturned.append(node1)
        
        XCTAssertEqual(testUndirectedGraph.nodes, nodeListToBeReturned, "Nodes are not being read from an undirected weighted graph properly!")
    }
    
    func testVarEdgesUndirectedWeightedGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        XCTAssertEqual(testUndirectedGraph.edges, [Edge<String>](), "Edges are not being read from an undirected weighted graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 2.0)
        
        testUndirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge)
        edgeListToBeReturned.append(edge.reverse())
        
        XCTAssertEqual(testUndirectedGraph.edges, edgeListToBeReturned, "Edges are not being read from an undirected weighted graph properly!")
    }
    
    func testAddNodeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        testSimpleGraph.addNode(node1)
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), true, "Nodes are not being added to a simple graph properly!")
    }
    
    func testRemoveNodeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        testSimpleGraph.addNode(node1)
        testSimpleGraph.removeNode(node1)
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), false, "Nodes are not being removed from a simple graph properly!")
    }
    
    func testContainsNodeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), false, "Nodes are not being checked in a simple graph properly!")
    }
    
    func testAddEdgeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), true, "Edges are not being added to a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsNode(node2), true, "Edges are not being added to a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge), true, "Edges are not being added to a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge.reverse()), true, "Edges are not being added to a simple graph properly!")
    }
    
    func DISABLED_testAddLoopEdgeSimpleGraph() {
        //  doesn't exist in simple graphs, disabled
    }
    
    func testRemoveEdgeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), true, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsNode(node2), true, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge), true, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge.reverse()), true, "Edges are not being removed from a simple graph properly!")
        
        testSimpleGraph.removeEdge(edge)
        
        XCTAssertEqual(testSimpleGraph.containsNode(node1), true, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsNode(node2), true, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge), false, "Edges are not being removed from a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.containsEdge(edge.reverse()), false, "Edges are not being removed from a simple graph properly!")
    }
    
    func DISABLED_testRemoveLoopEdgeSimpleGraph() {
        //  doesn't exist in simple graphs, disabled
    }
    
    func testContainsEdgeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        XCTAssertEqual(testSimpleGraph.containsEdge(edge), false, "Edges are not being checked in a simple graph properly!")
    }
    
    func testEdgesFromNodeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testSimpleGraph.addNode(node1)
        testSimpleGraph.addNode(node2)
        
        XCTAssertEqual(testSimpleGraph.edgesFromNode(node1, toNode: node2), [Edge<String>](), "Edges outwards from a node are not being checked in a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.edgesFromNode(node2, toNode: node1), [Edge<String>](), "Edges outwards from a node are not being checked in a simple graph properly!")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        var edgeListToBeReturned1 = [Edge<String>]()
        var edgeListToBeReturned2 = [Edge<String>]()
        
        edgeListToBeReturned1.append(edge)
        edgeListToBeReturned2.append(edge.reverse())
        
        XCTAssertEqual(testSimpleGraph.edgesFromNode(node1, toNode: node2), edgeListToBeReturned1, "Edges outwards from a node are not being checked in a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.edgesFromNode(node2, toNode: node1), edgeListToBeReturned2, "Edges outwards from a node are not being checked in a simple graph properly!")
    }
    
    func testAdjacentNodesFromNodeSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testSimpleGraph.addNode(node1)
        testSimpleGraph.addNode(node2)
        
        XCTAssertEqual(testSimpleGraph.adjacentNodesFromNode(node1), [Node<String>](), "Adjacents nodes from a node are not being checked in a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.adjacentNodesFromNode(node2), [Node<String>](), "Adjacents nodes from a node are not being checked in a simple graph properly!")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        var nodeListToBeReturned1 = [Node<String>]()
        var nodeListToBeReturned2 = [Node<String>]()
        
        nodeListToBeReturned1.append(node2)
        nodeListToBeReturned2.append(node1)
        
        XCTAssertEqual(testSimpleGraph.adjacentNodesFromNode(node1), nodeListToBeReturned1, "Adjacents nodes from a node are not being checked in a simple graph properly!")
        XCTAssertEqual(testSimpleGraph.adjacentNodesFromNode(node2), nodeListToBeReturned2, "Adjacents nodes from a node are not being checked in a simple graph properly!")
    }
    
    func testVarNodesSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        XCTAssertEqual(testSimpleGraph.nodes, [Node<String>](), "Nodes are not being read from an undirected weighted graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        nodeListToBeReturned.append(node1)
        
        XCTAssertEqual(testSimpleGraph.nodes, nodeListToBeReturned, "Nodes are not being read from an undirected weighted graph properly!")
    }
    
    func testVarEdgesSimpleGraph() {
        let testSimpleGraph = Graph<String>(isDirected: false)
        
        XCTAssertEqual(testSimpleGraph.edges, [Edge<String>](), "Edges are not being read from a simple graph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testSimpleGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge.reverse())
        edgeListToBeReturned.append(edge)
        
        XCTAssertEqual(testSimpleGraph.edges, edgeListToBeReturned, "Edges are not being read from a simple graph properly!")
    }
    
    func testAddNodeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        testDirectedMultiGraph.addNode(node1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Nodes are not being added to a directed weighted multigraph properly!")
    }
    
    func testRemoveNodeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        testDirectedMultiGraph.addNode(node1)
        testDirectedMultiGraph.removeNode(node1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), false, "Nodes are not being removed from a directed weighted multigraph properly!")
    }
    
    func testContainsNodeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), false, "Nodes are not being checked in a directed weighted multigraph properly!")
    }
    
    func testAddEdgeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node2), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), true, "Edges are not being added to a directed weighted multigraph properly!")
        
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node2), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being added to a directed weighted multigraph properly!")
    }
    
    func testAddLoopEdgeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        let edge1 = Edge(source: node1, destination: node1, weight: 3.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), true, "Edges are not being added to a directed weighted multigraph properly!")
        
        let edge2 = Edge(source: node1, destination: node1, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being added to a directed weighted multigraph properly!")
    }
    
    func testRemoveEdgeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node2), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node2), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being added to a directed weighted multigraph properly!")
        
        testDirectedMultiGraph.removeEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node2), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), false, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being added to a directed weighted multigraph properly!")
    }
    
    func testRemoveLoopEdgeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        
        let edge1 = Edge(source: node1, destination: node1, weight: 3.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        
        let edge2 = Edge(source: node1, destination: node1, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being added to a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being added to a directed weighted multigraph properly!")
        
        testDirectedMultiGraph.removeEdge(edge1)
        
        XCTAssertEqual(testDirectedMultiGraph.containsNode(node1), true, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), false, "Edges are not being removed from a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), true, "Edges are not being removed from a directed weighted multigraph properly!")
    }
    
    func testContainsEdgeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge1), false, "Edges are not being checked in a directed weighted multigraph properly!")
        XCTAssertEqual(testDirectedMultiGraph.containsEdge(edge2), false, "Edges are not being checked in a directed weighted multigraph properly!")
    }
    
    func testEdgesFromNodeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testDirectedMultiGraph.addNode(node1)
        testDirectedMultiGraph.addNode(node2)
        
        XCTAssertEqual(testDirectedMultiGraph.edgesFromNode(node1, toNode: node2), [Edge<String>](), "Edges outwards from a node are not being checked in a directed weighted multigraph properly!")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        testDirectedMultiGraph.addEdge(edge2)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.edgesFromNode(node1, toNode: node2), edgeListToBeReturned, "Edges outwards from a node are not being checked in a directed weighted multigraph properly!")
    }
    
    func testAdjacentNodesFromNodeDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testDirectedMultiGraph.addNode(node1)
        testDirectedMultiGraph.addNode(node2)
        
        XCTAssertEqual(testDirectedMultiGraph.adjacentNodesFromNode(node1), [Node<String>](), "Adjacents nodes from a node are not being checked in a directed weighted multigraph properly!")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        testDirectedMultiGraph.addEdge(edge2)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        
        XCTAssertEqual(testDirectedMultiGraph.adjacentNodesFromNode(node1), nodeListToBeReturned, "Adjacents nodes from a node are not being checked in a directed weighted multigraph properly!")
    }
    
    func testVarNodesDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        XCTAssertEqual(testDirectedMultiGraph.nodes, [Node<String>](), "Nodes are not being read from a directed weighted multigraph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        testDirectedMultiGraph.addEdge(edge2)
        
        var nodeListToBeReturned = [Node<String>]()
        
        nodeListToBeReturned.append(node2)
        nodeListToBeReturned.append(node1)
        
        XCTAssertEqual(testDirectedMultiGraph.nodes, nodeListToBeReturned, "Nodes are not being read from a directed weighted multigraph properly!")
    }
    
    func testVarEdgesDirectedWeightedMultiGraph() {
        let testDirectedMultiGraph = Graph<String>(isDirected: true)
        
        XCTAssertEqual(testDirectedMultiGraph.edges, [Edge<String>](), "Edges are not being read from a directed weighted multigraph properly!")
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 3.0)
        let edge2 = Edge(source: node1, destination: node2, weight: 4.0)
        
        testDirectedMultiGraph.addEdge(edge1)
        testDirectedMultiGraph.addEdge(edge2)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        
        XCTAssertEqual(testDirectedMultiGraph.edges, edgeListToBeReturned, "Edges are not being read from a directed weighted multigraph properly!")
    }
    
    func testShortestPathDirectedGraphVerySimpleGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2, weight: 3.0)
        
        testDirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph that is very simple, just A to B!")
    }
    
    func testShortestPathDirectedCyclicGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 6.0)
        let edge2 = Edge(source: node2, destination: node3, weight: 3.0)
        let edge3 = Edge(source: node3, destination: node1, weight: 9.0)
        
        testDirectedGraph.addEdge(edge1)
        testDirectedGraph.addEdge(edge2)
        testDirectedGraph.addEdge(edge3)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node3), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph that is cylical!")
    }
    
    func testShortestPathDirectedGraphWithSelfPointers() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 6.0)
        let edge2 = Edge(source: node2, destination: node3, weight: 3.0)
        let edge3 = Edge(source: node3, destination: node1, weight: 10.0)
        let edge4 = Edge(source: node1, destination: node1, weight: 2.0)
        let edge5 = Edge(source: node2, destination: node2, weight: 1.0)
        let edge6 = Edge(source: node3, destination: node3, weight: 7.0)
        
        testDirectedGraph.addEdge(edge1)
        testDirectedGraph.addEdge(edge2)
        testDirectedGraph.addEdge(edge3)
        testDirectedGraph.addEdge(edge4)
        testDirectedGraph.addEdge(edge5)
        testDirectedGraph.addEdge(edge6)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node3), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph that has self-cycles!")
    }
    
    func testShortestPathDirectedSampleGraphFromAssignment() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        let node4 = Node("D")
        let node5 = Node("E")
        let node6 = Node("F")
        let node7 = Node("G")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.addNode(node2)
        testDirectedGraph.addNode(node3)
        testDirectedGraph.addNode(node4)
        testDirectedGraph.addNode(node5)
        testDirectedGraph.addNode(node6)
        testDirectedGraph.addNode(node7)
        
        let edge1 = Edge(source: node1, destination: node2, weight: 13.0)
        let edge2 = Edge(source: node1, destination: node3, weight: 2.0)
        let edge3 = Edge(source: node1, destination: node5, weight: 1.0)
        let edge4 = Edge(source: node2, destination: node4, weight: 1.0)
        let edge5 = Edge(source: node3, destination: node7, weight: 7.0)
        let edge6 = Edge(source: node5, destination: node6, weight: 3.0)
        let edge7 = Edge(source: node6, destination: node2, weight: 2.0)
        
        testDirectedGraph.addEdge(edge1)
        testDirectedGraph.addEdge(edge2)
        testDirectedGraph.addEdge(edge3)
        testDirectedGraph.addEdge(edge4)
        testDirectedGraph.addEdge(edge5)
        testDirectedGraph.addEdge(edge6)
        testDirectedGraph.addEdge(edge7)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge3)
        edgeListToBeReturned.append(edge6)
        edgeListToBeReturned.append(edge7)
        edgeListToBeReturned.append(edge4)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node4), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph, a sample graph constructed!")
    }
    
    func testShortestPathDirectedSampleGraphFromCLRS() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("S")
        let node2 = Node("T")
        let node3 = Node("X")
        let node4 = Node("Y")
        let node5 = Node("Z")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.addNode(node2)
        testDirectedGraph.addNode(node3)
        testDirectedGraph.addNode(node4)
        testDirectedGraph.addNode(node5)
        
        let edge1 = Edge(source: node1, destination: node2, weight: 10.0)
        let edge2 = Edge(source: node1, destination: node4, weight: 5.0)
        let edge3 = Edge(source: node2, destination: node3, weight: 1.0)
        let edge4 = Edge(source: node2, destination: node4, weight: 2.0)
        let edge5 = Edge(source: node3, destination: node5, weight: 4.0)
        let edge6 = Edge(source: node4, destination: node2, weight: 3.0)
        let edge7 = Edge(source: node4, destination: node3, weight: 9.0)
        let edge8 = Edge(source: node4, destination: node5, weight: 2.0)
        let edge9 = Edge(source: node5, destination: node1, weight: 7.0)
        let edge10 = Edge(source: node5, destination: node3, weight: 6.0)
        
        testDirectedGraph.addEdge(edge1)
        testDirectedGraph.addEdge(edge2)
        testDirectedGraph.addEdge(edge3)
        testDirectedGraph.addEdge(edge4)
        testDirectedGraph.addEdge(edge5)
        testDirectedGraph.addEdge(edge6)
        testDirectedGraph.addEdge(edge7)
        testDirectedGraph.addEdge(edge8)
        testDirectedGraph.addEdge(edge9)
        testDirectedGraph.addEdge(edge10)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge2)
        edgeListToBeReturned.append(edge6)
        edgeListToBeReturned.append(edge3)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node3), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph, a sample graph copied from CLRS!")
    }
    
    func testShortestPathDirectedLinkedListGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        let node4 = Node("D")
        let node5 = Node("E")
        
        let edge1 = Edge(source: node1, destination: node2, weight: 2.0)
        let edge2 = Edge(source: node2, destination: node3, weight: 2.0)
        let edge3 = Edge(source: node3, destination: node4, weight: 3.0)
        let edge4 = Edge(source: node4, destination: node5, weight: 1.0)
        
        testDirectedGraph.addEdge(edge1)
        testDirectedGraph.addEdge(edge2)
        testDirectedGraph.addEdge(edge3)
        testDirectedGraph.addEdge(edge4)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        edgeListToBeReturned.append(edge3)
        edgeListToBeReturned.append(edge4)
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node5), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph that resembles a linked list!")
    }
    
    func testShortestPathDirectedEmptyGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edgeListToBeReturned = [Edge<String>]()
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph that is empty, i.e. has no nodes in it!")
    }
    
    func testShortestPathDirectedNoPathGraph() {
        let testDirectedGraph = Graph<String>(isDirected: true)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testDirectedGraph.addNode(node1)
        testDirectedGraph.addNode(node2)
        
        let edgeListToBeReturned = [Edge<String>]()
        
        XCTAssertEqual(testDirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a directed weighted graph without a path!")
    }
    
    func testShortestPathUndirectedUnweightedGraphVerySimpleGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edge = Edge(source: node1, destination: node2)
        
        testUndirectedGraph.addEdge(edge)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge)
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph that is very simple, just A to B!")
    }
    
    func testShortestPathUndirectedUnweightedCyclicGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        
        let edge1 = Edge(source: node1, destination: node2)
        let edge2 = Edge(source: node2, destination: node3)
        let edge3 = Edge(source: node3, destination: node1)
        
        testUndirectedGraph.addEdge(edge1)
        testUndirectedGraph.addEdge(edge2)
        testUndirectedGraph.addEdge(edge3)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge3.reverse())
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node3), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph that is cylical!")
    }
    
    func testShortestPathUndirectedUnweightedSampleGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        let node4 = Node("D")
        let node5 = Node("E")
        let node6 = Node("F")
        let node7 = Node("G")
        
        testUndirectedGraph.addNode(node1)
        testUndirectedGraph.addNode(node2)
        testUndirectedGraph.addNode(node3)
        testUndirectedGraph.addNode(node4)
        testUndirectedGraph.addNode(node5)
        testUndirectedGraph.addNode(node6)
        testUndirectedGraph.addNode(node7)
        
        let edge1 = Edge(source: node1, destination: node2)
        let edge2 = Edge(source: node1, destination: node3)
        let edge3 = Edge(source: node1, destination: node5)
        let edge4 = Edge(source: node2, destination: node4)
        let edge5 = Edge(source: node3, destination: node7)
        let edge6 = Edge(source: node5, destination: node6)
        let edge7 = Edge(source: node6, destination: node2)
        
        testUndirectedGraph.addEdge(edge1)
        testUndirectedGraph.addEdge(edge2)
        testUndirectedGraph.addEdge(edge3)
        testUndirectedGraph.addEdge(edge4)
        testUndirectedGraph.addEdge(edge5)
        testUndirectedGraph.addEdge(edge6)
        testUndirectedGraph.addEdge(edge7)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge4)
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node4), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph, a sample graph constructed!")
    }
    
    func testShortestPathUndirectedUnweightedLinkedListGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        let node3 = Node("C")
        let node4 = Node("D")
        let node5 = Node("E")
        
        let edge1 = Edge(source: node1, destination: node2)
        let edge2 = Edge(source: node2, destination: node3)
        let edge3 = Edge(source: node3, destination: node4)
        let edge4 = Edge(source: node4, destination: node5)
        
        testUndirectedGraph.addEdge(edge1)
        testUndirectedGraph.addEdge(edge2)
        testUndirectedGraph.addEdge(edge3)
        testUndirectedGraph.addEdge(edge4)
        
        var edgeListToBeReturned = [Edge<String>]()
        
        edgeListToBeReturned.append(edge1)
        edgeListToBeReturned.append(edge2)
        edgeListToBeReturned.append(edge3)
        edgeListToBeReturned.append(edge4)
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node5), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph that resembles a linked list!")
    }
    
    func testShortestPathUndirectedUnweightedEmptyGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        let edgeListToBeReturned = [Edge<String>]()
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph that is empty, i.e. has no nodes in it!")
    }
    
    func testShortestPathUndirectedNoPathGraph() {
        let testUndirectedGraph = Graph<String>(isDirected: false)
        
        let node1 = Node("A")
        let node2 = Node("B")
        
        testUndirectedGraph.addNode(node1)
        testUndirectedGraph.addNode(node2)
        
        let edgeListToBeReturned = [Edge<String>]()
        
        XCTAssertEqual(testUndirectedGraph.shortestPathFromNode(node1, toNode: node2), edgeListToBeReturned, "Shortest path is not being found correctly on a undirected unweighted graph without a path!")
    }
    
    func DISABLED_testShortestPathMultiGraph() {
        //  not supported, Disabled
    }
}