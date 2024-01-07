%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::ext::pq::PriorityQueue

type Component = {
    name: String,
    wires: Array<String>
}

type Node = {
    name: String,
    wires: Array<Edge>
}
type Edge = Array<String>
type Step = {
    from: String,
    to: String
}

type Graph = {
    nodes: Array<Node>,
    edges: Array<Edge>
}

fun load(filename: String): Array<String> = 
    lines(readUrl("classpath://$(filename)", "text/plain")) as Array<String>

fun loadComponents(filename: String): Graph = do {
    var wiringDiagram = load(filename) map (line) -> do {
        var tokens = line splitBy ": "
        ---
        {
            name: tokens[0],
            wires: tokens[1] splitBy " "
        }        
    }
    var edges = wiringDiagram flatMap (componentInfo) ->
        componentInfo.wires map (otherSide) -> [componentInfo.name, otherSide] orderBy $
    var nodes = (flatten(edges) distinctBy $) // have to get all components, even if they only appear in wires
        map (c) -> {
            name: c,
            wires: edges filter (edge) -> edge contains c
        }
    ---
    {nodes: nodes, edges: edges}
}

type PathIdea = {
    path: Array<Step>,
    distance: Number,
}

fun nextSteps(node: Node): Array<Step> =
    node.wires map (wire) -> {
        from: node.name, 
        to: if (wire[0] == node.name) wire[1] else wire[0]
    }

fun toEdge(s: Step): Edge =
    [s.from, s.to] orderBy $

fun shortestPath(graph: Graph, source: String, destination: String): Array<Step> = do {
    var pq: PriorityQueue<PathIdea> = init((node: PathIdea) -> node.distance)
    var startNode = graph.nodes firstWith ($.name == source)
    ---
    if (startNode == null) []
    else do {
        var startQ = nextSteps(startNode) reduce (step: Step, pq = pq) ->
            (pq insert {
                path: [step],
                distance: 1
            })
        ---
        findShortestPath(graph, destination, startQ, [])
    }
}

fun findShortestPath(graph: Graph, destination: String, pq: PriorityQueue<PathIdea>, visited: Array<Edge>): Array<Step> = do {
    var thisIdea = log(next(pq))
    var nextQ = deleteNext(pq)
    ---
    if (thisIdea == null) [] // there was no path
    else if (thisIdea.path[-1].to == destination) thisIdea.path // we made it
    else if (sizeOf(visited) > 10000) log("early exit, visited too big", [])
    else do {
        var thisStep = thisIdea.path[-1]
        var thisNode = graph.nodes firstWith (n) -> n.name == thisStep.to
        ---
        if (thisNode == null) log("corrupt data: step $(thisStep.from)-$(thisStep.to)", [])
        else do {
            var choices = nextSteps(thisNode) 
                filter (s) -> (! (visited contains toEdge(s))) // don't recheck visited edges
            var nextStepsQ = choices reduce (step: Step, pq = nextQ) -> // put all the next steps into the queue
                    (pq insert {
                        path: thisIdea.path << step,
                        distance: thisIdea.distance + 1
                    })
            ---
            findShortestPath(graph, destination, nextStepsQ, visited << toEdge(thisStep))
        }
    }
}