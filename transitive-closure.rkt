#lang racket
;; Luke Bonenberger-- Transitive Closure
(provide (all-defined-out))


(define x
  (hash "main-server" (set "switch" "backup-srv" "db-server")
        "switch" (set "main-server" "db-server" "backup-srv")
        "backup-srv" (set "main-server" "db-server" "switch")
        "db-server" (set "main-server" "switch" "backup-srv")))

;; return a list of nodes pointed to by `from` in `graph`
(define (nodes-to graph from)
  (set->list (hash-ref graph from)))

;;
;; CIS352-- Network Connectivity
;; 

;; To see the demo, invoke using:
;;     racket connectivity.rkt <input-file>.net
;;     racket connectivity.rkt <input-file>.net "CONNECTED <from> <to>"

;; Lines are pared into an intermediate representation satisfying the
;; line? predicate.
(define (line? l)
  (match l
    [`(node ,(? string? node-name)) #t]
    [`(link ,(? string? from-node) ,(? string? to-node)) #t]
    [_ #f]))

;; The input format is a list of line?s
(define (input-format? lst)
  (and (list? lst)
       (andmap line? lst)))

;; A graph? is a hash table whose keys are strings and whose values
;; are sets of strings.
(define (graph? gr) (and (hash? gr)
                         (immutable? gr)
                         (andmap string? (hash-keys gr))
                         (andmap (lambda (key) (andmap string? (set->list (hash-ref gr key))))
                                 (hash-keys gr))))

;; Parse a line of text input. Lines will have the following format:
;;     NODE <node-name>
;;     LINK <node-name> <node-name>
;; 
;; Hint: use string-split and match, make sure to produce something
;; that adheres to `line?`.
(define/contract (parse-line l)
  (-> string? line?)
  ;; pieces is a list of strings
  (define pieces (string-split l)) ;; split input string l into a list of substrings
  (match pieces ;; matches the pieces variable against different patterns
    [(list "NODE" name) `(node ,name)] ;; matches the pieces list against a list containing the strings "NODE" and a variable name. If pieces matches this pattern- it returns a list with the symbol node and the var name.
    [(list "LINK" from to) `(link ,from ,to)] ;; matches the pieces list against a list containing the string "LINK", a variable from, and a variable to. If pieces matches this pattern, it returns a list containing the symbol link, the variable from, and the variable to.
    [_ `(invalid-input "")])) ;; matches any other pieces list that does not match the previous patterns. If pieces matches this pattern- it returns a list containing the symbol invalid-input and an empty string. _ is the placeholder for any value that is not explicitly matched in the pattern.

;; starter code
;; read a file by mapping over its lines  
(define/contract (read-file f)
  (-> string? input-format?)
  (map parse-line (file->lines f)))

;; Input is a list of line? commands. Write a recursive function which
;; builds up a hash.
;;
;; - If it's a `node` command, add a link from a node to itself.
;; - If it's a `link` command, add a directional link as specified.
;;
;; Hint: use (hash), (set n), hash-set, set-add, hash-ref, and similar.
(define/contract (build-init-graph input)
  (-> input-format? graph?)
(define (h l hash-table)
(if (null? l)
    hash-table
    (match (car l)
      [`(node ,n) (h (cdr l) (hash-set hash-table n (set n)))]
      [`(link ,n1 ,n2) (h (cdr l) (hash-set hash-table n1 (set-add (hash-ref hash-table n1 (set)) n2)))])))
  (h input (hash)))
    

;; Check whether or not there is a forward line from n0 to n1 in
;; graph.
;; 
;; Hint: use set-member? and hash-ref
(define (forward-link? graph n0 n1)
  (set-member? (hash-ref graph n0) n1)) ;; checks if n1 is a member of the set of nodes that are reachable from n0 in the graph. It uses hash-ref to look up the set of reachable nodes for n0 in the graph. It then passes this set to set-member? along w/ n1, which will return #t if n1 is in the set and #f otherwise.

;; TODO
;; Add a directed link (from,to) to the graph graph, return the new graph with 
;; the additional link.
;;
;; Hint: use hash-set, hash-ref, and set-add.
(define (add-link graph from to)
  ;; retrieves the set of outgoing links
  ;; empty set is used as a default value if no outgoing link
  ;; adds to node to the set using set-add
  ;; create a new graph by updating the outgoing links of the from node with the new set of outgoing links
  (let* ((outgoing (hash-ref graph from (set)))
         (new-outgoing (set-add outgoing to))
         (new-graph (hash-set graph from new-outgoing)))
    new-graph))
;; add another argument (set)

;; Perform the transitive closure of the graph. This is the most challenging 
;; operation in the project, so we recommend putting it off until the end.
;; 
;; To perform the transitive closure of the graph, iteratively add links
;; whenever you find a matching (x,y) and (y,z). This can be done in one of 
;; two broad ways: (a) chaotic iteration or (b) semi-naive evaluation. 
;; Read the project description for more details and hints at a solution.
;; 
;; My solution uses `foldl`, `hash-keys`, `set->list`, `hash-ref`, and 
;; `add-link`. It is always possible to use a recursive helper function instead
;; of a foldl, but it makes the code much easier to understand in my opinion.
(define (transitive-closure graph)
  (define (helper graph) ;; Helper function named helper that takes graph as an input parameter
    (foldl (lambda (x acc) ;; foldl to iterate over each node x in graph, along with the accumulated value acc
             (foldl (lambda (y acc) ;; foldl to iterate over each node y that is reachable from node x, along with the accumulated value acc
                        (foldl (lambda (z acc) ;; foldl to iterate over each node z that is reachable from node y, along with the accumulated value acc
                                 (add-link acc x z)) ;; add a link from node x to node z in the accumulated value acc
                               acc ;; return final acc value
                               (set->list (hash-ref graph y))))
                    acc
                    (set->list (hash-ref graph x))))
           graph
           (hash-keys graph)))
  (define (iterator graph) ;; Calls the helper function with graph as an input parameter, and assigns the result to new-graph
    (let ((new-graph (helper graph)))
      (if (equal? new-graph graph) ;; If new-graph is equal to graph, returns graph
          graph
          (iterator new-graph)))) ;; Otherwise- recursively calls the iterator function with new-graph as an input parameter
;; iterator function with graph as an input parameter and returns the result
  (iterator graph))

;; Print a DB
(define (print-db db)
  (for ([key (sort (hash-keys db) string<?)])
    (displayln (format "Key ~a:" key))
    (displayln (string-append "    " (string-join (sort (set->list (hash-ref db key)) string<?) ", ")))))

(define (demo file query)
  (define ir (read-file file))
  (define initial-db (build-init-graph ir))
  (displayln "The input is:")
  (print-db initial-db)
  (displayln "Now running transitive closure...")
  (define final-db (transitive-closure initial-db))
  (displayln "Transitive closure:")
  (print-db final-db)
  (unless (equal? query "")
    (match (string-split query)
      [`("CONNECTED" ,n0 ,n1)
        (if (forward-link? final-db n0 n1)
          (displayln "CONNECTED")
          (displayln "DISCONNECTED"))])))

(match-define (cons file query)
  (command-line
   #:program "connectivity.rkt"
   #:args ([filename ""]  [query ""])
   (cons filename query)))

;; if called with a single argument, this racket program will execute
;; the demo.
(if (not (equal? file "")) (demo file query) (void))
