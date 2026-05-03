$start
$replace
					if {$rnd>$val} {
						if {$reprod_log} {log "Bad attribs: ($val) [get_objname this] returns false ($rnd)----- $reprod_sexratio"}
						return false
					} else {
$with
					# EMERGENCY POPULATION FIX: If population is low, boost fertility
					set own [get_owner this]
					set popist [expr {[gamestats numgnomes $own]+[gamestats numbabies $own]+[gamestats numpregnant $own]}]
					if {$popist < $print:ST_MIN_POPULATION} {
						set val [expr {$val * $print:ST_FERTILITY_BOOST}]
					}
					if {$rnd>$val} {
						if {$reprod_log} {log "Bad attribs: ($val) [get_objname this] returns false ($rnd)----- $reprod_sexratio"}
						return false
					} else {
$end
