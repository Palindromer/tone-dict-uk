(let ((dict #h(equal)))
  (dolines (line "tone-dict-uk-manual.tsv")
    (with (((word val &rest rest) (split #\Tab line))
           (val (read-from-string val)))
      (cond ((minusp val)
             (:= (? dict word) val))
            ((plusp val)
             (:= (? dict word) val)))))
  (dolines (line "tone-dict-uk-auto.tsv")
    (with (((word val &rest rest) (split #\Tab line))
           (val (read-from-string val)))
      (cond ((< 0.9 val)
             (:= (? dict word) 2))
            ((< 0.5 val)
             (:= (? dict word) 1))
            ((> 0.05 val)
             (:= (? dict word) -2))
            ((> 0.1 val)
             (:= (? dict word) -1)))))
  (with-out-file (out "tone-dict-uk.tsv")
    (dolist (pair (sort (ht->pairs dict) 'uk-string< :key 'lt))
      (with-pair (w v) pair
        (format out "~A~C~A~%" w #\Tab v)))))

(defun uk-char< (c1 c2)
  (apply '< (mapcar ^(case %
                       (#\і (+ (char-code #\з) 0.5))
                       (#\ї (+ (char-code #\з) 0.75))
                       (#\є (+ (char-code #\д) 0.5))
                       (#\ґ (+ (char-code #\г) 0.5))
                       (otherwise (char-code %)))
                    (list c1 c2))))

(defun uk-string< (s1 s2)
  (let ((pos (mismatch s1 s2)))
    (cond ((= pos (length s1) (length s2)) nil)
          ((= pos (length s1)) t)
          ((= pos (length s2)) nil)
          (t (uk-char< (char s1 pos) (char s2 pos))))))
