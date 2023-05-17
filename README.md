In this project, implemented is a domain-specific programming language that allows us to specify network topologies and check their connectivity. Production datacenters and commercial networks are composed of myriad hosts, routers, and switches, connected in a complex web of infrastructure. An important but challenging question is simply: which nodes may connect to which others? Even in the modern age, network misconfigurations still account for global internet outage events. To address this, several cloud providers have begun to provide tools for analyzing properties of networks specified via domain-specific configuration languages. For example, AWS’s VPC Reachability Analyzer is a commercial offering that is now used by some cloud system engineers as part of their day-to-day jobs.

In this project, built is a minimal language for expressing network topologies and implement transitive closure, the algorithm for graph reachability. This will allow us to check for connectivity properties of (potentially huge) graphs. The language is loosely inspired by NetKAT.

Networks include various pieces of physical infrastructure: routers, switches, and servers. In this project we will ignore the physical properties of network nodes, and will simply call every entity capable of sending or receiving data a “node.” Nodes are connected by (directed) links. Both nodes and links are specified as commands, each command residing on a unique line of the input file format. Syntactically, the two specification commands are (a) the NODE <name> command, which specifies the existence of a node named <name> and (b) the LINK <from> <to> command, which establishes a (directed) link from node <from> to node <to>. For convenience, we assume all nodes are specified before any occurrences of LINK commands
  
Transitive closure consists of a series of steps applied in an iterative fashion, until no more answers are possible. In other words, the algorithm is defined in terms of its behavior at each “time step.”

The transitive closure (of links) at time 0 is simply the set of extensionally-specified (input) links.

To construct the transitive closure at time n+1, look at the transitive closure at time n. For any pair of links in that graph, (x,y) and (y,z), such that the intermediate node y is matching, draw a (possibly new) link between x and z, (x,z).

Repeat this process until no new links are found. I.e., until the transitive closure at some time n is equal to the transitive closure at time n+1

This process necessarily terminates, as long as you are careful to ensure elements are not added twice (which will be easy using the correct datastructures, namely sets and hashes). This is because there are a finite number of nodes, and so the “worst-case” scenario would be that every node was connected to every other (as it is in the above graph). At each step of the process, we add more information to (monotonically) increase our knowledge base (of transitive links). At some point we will either (a) not add any new links or (b) add all possible links, at which point no more links may be added and we terminate.

A generalized version of this reasoning gives us the Knaster-Tarski fixed-point theorem and the Klenne fixed-point theorem.
