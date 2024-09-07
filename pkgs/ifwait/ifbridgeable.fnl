(local wlan (require :anoia.wlan))
(local { : assoc } (require :anoia))
(local { : msleep } (require :lualinux))

(fn parse-args [args]
  (match args
    ["-v" & rest]  (assoc (parse-args rest) :verbose true)
    [linkname] {:link linkname}
    _  nil))

(fn run [args poll-fn]
  (let [parameters
        (assert (parse-args args)
                (.. "Usage: ifbridgeable [-v] ifname"))]
    (when parameters.verbose
      (print (.. "ifbridgeable: waiting for "
                 parameters.link " to be bridgeable")))

    (while (not (poll-fn parameters.link))
      (when parameters.verbose
        (print (.. "ifbridgeable: waiting for " parameters.link " to be bridgeable")))
      (msleep 500)
    )
  )
)

(when (not (= (. arg 0) "test"))
  (run arg wlan.is-bridgeable))

{ : run  }
