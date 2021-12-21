(ns main)

(defn dicesum [dice]
  (+ (* 3 dice) 6))

(defn nextpos [current jump]
  (loop [next (+ current jump)]
    (if (<= next 10)
      next
      (recur (- next 10)))))

(defn part1 [pos1 pos2]
  (loop [p1 pos1
         p2 pos2
         dice 0
         score1 0
         score2 0
         turn true]
    (when (>= score1 1000)
      (println "Day 21, part1: " (* score2 dice)))
    (when (>= score2 1000)
      (println "Day 21, part1: " (* score1 dice)))
    (when (and (< score1 1000) (< score2 1000))
      (let [newPos1 (if (true? turn) (nextpos p1 (dicesum dice)) p1)
            newPos2 (if (true? (not turn)) (nextpos p2 (dicesum dice)) p2)]
        (recur newPos1
               newPos2
               (+ dice 3)
               (if (true? turn) (+ score1 newPos1) score1)
               (if (true? (not turn)) (+ score2 newPos2) score2)
               (not turn))))))



(defn next-turn [turn]
  (mod (inc turn) 6))

(defn get-score [pos add-to-pos score turn only-in-turn]
  (if (= turn only-in-turn)
    (+ score (nextpos pos add-to-pos))
    score))

(def final-map (atom {}))

(defn part2-worker [p1 p2 score1 score2 turn]
  (if (>= score1 21)
    [1 0]
    (if (>= score2 21)
      [0 1]
      ; from 0 to 2 it is player 1 turn, from 3 to 5 it is player2 turn
      (if (< turn 3)
        ; player 1
        (do (when (not (contains? @final-map [p1 p2 score1 score2 turn]))
              (swap! final-map assoc [p1 p2 score1 score2 turn] 
                     (map +
                          ; split at every possible die roll
                          (part2-worker (nextpos p1 1) p2
                                       (get-score p1 1 score1 turn 2) score2
                                       (next-turn turn))
                          (part2-worker (nextpos p1 2) p2
                                       (get-score p1 2 score1 turn 2) score2
                                       (next-turn turn))
                          (part2-worker (nextpos p1 3) p2
                                       (get-score p1 3 score1 turn 2) score2
                                       (next-turn turn)))))
            (get @final-map [p1 p2 score1 score2 turn]))
        ; player 2
        (do (when (not (contains? @final-map [p1 p2 score1 score2 turn]))
              (swap! final-map assoc [p1 p2 score1 score2 turn] 
                     (map +
                          (part2-worker p1 (nextpos p2 1)
                                       score1 (get-score p2 1 score2 turn 5)
                                       (next-turn turn))
                          (part2-worker p1 (nextpos p2 2)
                                       score1 (get-score p2 2 score2 turn 5)
                                       (next-turn turn))
                          (part2-worker p1 (nextpos p2 3)
                                       score1 (get-score p2 3 score2 turn 5)
                                       (next-turn turn)))))
            (get @final-map [p1 p2 score1 score2 turn]))))))

(defn part2 [pos1 pos2]
  (println "Day 21, part2: " (apply max (part2-worker pos1 pos2 0 0 0))))

(defn run [opts]
  (let [player1 (read-line)
        player2 (read-line)
        p1 (Integer/parseInt (subs player1 (- (count player1) 1)))
        p2 (Integer/parseInt (subs player2 (- (count player2) 1)))]
    (part1 p1 p2)
    (part2 p1 p2)))
