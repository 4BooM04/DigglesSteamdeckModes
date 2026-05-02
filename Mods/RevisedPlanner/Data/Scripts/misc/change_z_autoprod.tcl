$start
$replace
        proc autoprod_rate_task {task num_gnomes num_kettensaege num_hammer num_strahl num_reithamster num_hoverboard max_inv num_injured} {
        global blacklist_digpos blacklist_digtime blacklist_items blacklist_item_time
        for {set idx [expr {[llength $blacklist_digtime]-1}]} {$idx >= 0} {incr idx -1} {
            set list_item [lindex $blacklist_digtime $idx]
            if {[gettime] - [lindex $list_item 0] > 3*150} {
                #log "blacklisting of digging at ([lindex $blacklist_digpos $idx]) expired"
                lrem blacklist_digpos  $idx
                lrem blacklist_digtime $idx
            }
        }
        for {set idx [expr {[llength $blacklist_item_time]-1}]} {$idx >= 0} {incr idx -1} {
            if {[gettime] - [lindex $blacklist_item_time $idx] > 150} {
                #log "blacklisting of item [lindex $blacklist_items $idx] expired"
                lrem blacklist_items     $idx
                lrem blacklist_item_time $idx
            }
        }
$with
    proc autoprod_rate_task {task num_gnomes num_kettensaege num_hammer num_strahl num_reithamster num_hoverboard max_inv num_injured} {
        global blacklist_digpos blacklist_digtime blacklist_items blacklist_item_time
        for {set idx [expr {[llength $blacklist_digtime]-1}]} {$idx >= 0} {incr idx -1} {
            set list_item [lindex $blacklist_digtime $idx]
            if {[gettime] - [lindex $list_item 0] > $print:WORK_BLACKLIST_DIG} {
                lrem blacklist_digpos  $idx
                lrem blacklist_digtime $idx
            }
        }
        for {set idx [expr {[llength $blacklist_item_time]-1}]} {$idx >= 0} {incr idx -1} {
            if {[gettime] - [lindex $blacklist_item_time $idx] > $print:WORK_BLACKLIST_ITEM} {
                lrem blacklist_items     $idx
                lrem blacklist_item_time $idx
            }
        }
$end

$start
$replace
                set inv_overload [expr {ceil(double($request_size)/$inv_space)-1}]
                append score -$inv_overload*1000
                if {$inv_overload != 0} {log "X:   -$inv_overload * 1000 due to lack of inventory space ($inv_space)" 0}
$with
                set inv_overload [expr {ceil(double($request_size)/$inv_space)-1}]
                append score [expr {-$inv_overload * $print:WORK_INV_OVERLOAD_PENALTY}]
$end

$start
$replace
                if {!$i_am_preferred} {
                    append score -1000
                }
$with
                if {!$i_am_preferred} {
                    append score -$print:WORK_PREFERENCE_PENALTY
                }
$end
