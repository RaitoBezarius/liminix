(local { : database } (require :devout))
(local { : view } (require :fennel))
(import-macros { : expect= } :anoia.assert)

(var failed false)
(fn fail [d msg] (set failed true) (print :FAIL d (.. "\n" msg)))

(macro example [description & body]
  (if (. body 1)
      `(let [(ok?# err#) (xpcall (fn [] ,body) debug.traceback)]
         (if ok?#
             (print :PASS ,description)
             (fail ,description err#)))
      `(print :PENDING ,description)))

(example
 "given an empty database, searching it finds no entries"
 (let [db (database)]
   (expect= (db:find {:partname "boot"}) [])))

(local sda-uevent
       "add@/devices/pci0000:00/0000:00:13.0/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/block/sda\0ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:13.0/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/block/sda
SUBSYSTEM=block
MAJOR=8
MINOR=0
DEVNAME=sda
DEVTYPE=disk
DISKSEQ=2
SEQNUM=1527")

(local sdb1-insert
       "add@/devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/host1/target1:0:0/1:0:0:0/block/sdb/sdb1\0ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/host1/target1:0:0/1:0:0:0/block/sdb/sdb1
SUBSYSTEM=block
DEVNAME=/dev/sdb1
DEVTYPE=partition
DISKSEQ=33
PARTN=1
SEQNUM=82381
MAJOR=8
MINOR=17")

(local sdb1-remove
       "remove@/devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/host1/target1:0:0/1:0:0:0/block/sdb/sdb1\0ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/host1/target1:0:0/1:0:0:0/block/sdb/sdb1
SUBSYSTEM=block
DEVNAME=/dev/sdb1
DEVTYPE=partition
DISKSEQ=33
PARTN=1
SEQNUM=82386
MAJOR=8
MINOR=17")


(example
 "when I add a device, I can find it"
 (let [db (database)]
   (db:add sda-uevent)
   (let [[m & more] (db:find {:devname "sda"})]
     (expect= m.devname "sda")
     (expect= m.major "8")
     (expect= more []))))

(example
 "when I add a device, I cannot find it with wrong terms"
 (let [db (database)]
   (db:add sda-uevent)
   (expect= (db:find {:devname "sdb"}) [])))

(example
 "when I add a device, I can retrieve it by path"
 (let [db (database)]
   (db:add sda-uevent)
   (let [m (db:at-path "/devices/pci0000:00/0000:00:13.0/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/block/sda")]
     (expect= m.devname "sda")
     (expect= m.major "8"))))

(example
 "when I add and then remove a device, I cannot retrieve it by path"
 (let [db (database)]
   (db:add sdb1-insert)
   (db:add sdb1-remove)
   (expect= (db:at-path "/devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/host1/target1:0:0/1:0:0:0/block/sdb/sdb1") nil)))

(example
 "when I add and then remove a device, I cannot find it"
 (let [db (database)]
   (db:add sdb1-insert)
   (db:add sda-uevent)
   (db:add sdb1-remove)
   (expect= (db:find {:devname "/dev/sdb1"}) [])))

(example
 "when I search on multiple terms it uses all of them"
 (let [db (database)]
   (db:add sda-uevent)
   (expect= (# (db:find {:devname "sda" :devtype "disk"})) 1)
   (expect= (# (db:find {:devname "sda" :devtype "dosk"})) 0)))


;;; tests for indices

(example "when I add a device with $attributes major minor foo bar baz,
 it is added to indices for foo bar baz but not major minor")

(example "a removed device can no longer be found by looking in any index")

(example "when I query with multiple attributes, the search is performed using the most specific attribute"
         ;; (= the attribute whose
         ;;   value at this key has fewest elements)
         )

;;; tests for subscriptions

(example
 "I can subscribe to some search terms and be notified of matching events"
 (var received [])
 (let [db (database)
       subscriber (fn [e] (table.insert received e))]
   (db:subscribe :me subscriber {:devname "/dev/sdb1"})
   (db:add sdb1-insert)
   (db:add sda-uevent)
   (db:add sdb1-remove)
   (expect= (# received) 2)))

(example
 "I can unsubscribe after subscribing"
 (var received [])
 (let [db (database)
       subscriber (fn [e] (table.insert received e))]
   (db:subscribe :me subscriber {:devname "/dev/sdb1"})
   (db:unsubscribe :me)
   (db:add sdb1-insert)
   (db:add sda-uevent)
   (db:add sdb1-remove)
   (expect= (# received) 0)))

(if failed (os.exit 1) (print "OK"))
