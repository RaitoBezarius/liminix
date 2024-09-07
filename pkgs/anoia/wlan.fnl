(local { : nl80211 } (require :iwinfo))

(fn is-bridgeable [ifname]
  (let [mode (nl80211.mode ifname)]
    (or (= mode "Master") (= mode "Master (VLAN)"))
))

{ : is-bridgeable }
