(define (problem family-2)
  (:domain family-domain)
  (:objects p1 p2 p3 p4)
  (:init (female p1) (male p2) (not-yet-born p3) (not-yet-born p4))
  (:goal (and (is-uncle-or-aunt-of p3 p3) (male p3))))

