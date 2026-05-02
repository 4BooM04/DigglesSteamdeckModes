$start
$replace
set phase_timer 170
$with
set phase_timer $print:GROWING_TIME
$end

$start
$replace
set plzstarttimer 200
$with
set plzstarttimer $print:SPAWN_TIME
$end

$start
$replace
				if { $agephase == 1 } { set hatcnt 1; set woodcnt 0 }
				if { $agephase == 2 } { set hatcnt 1; set woodcnt 1 }
				if { $agephase == 3 } { set hatcnt 2; set woodcnt 1 }
$with
				if { $agephase == 1 } { set hatcnt $print:HAT_PHASE_1; set woodcnt $print:WOOD_PHASE_1 }
				if { $agephase == 2 } { set hatcnt $print:HAT_PHASE_2; set woodcnt $print:WOOD_PHASE_2 }
				if { $agephase == 3 } { set hatcnt $print:HAT_PHASE_3; set woodcnt $print:WOOD_PHASE_3 }
$end