$start
$replace
		timer_event this evt_timer0 -repeat 1 -interval 1 -userid 1 -attime 3
		timer_event this evt_zwerg_attribupdate -repeat -1 -interval 1 -userid 2
		timer_event this evt_zwerg_workannounce -repeat -1 -interval 1 -userid 3
$with
		timer_event this evt_timer0 -repeat 1 -interval 1 -userid 1 -attime 3
		# TICK RATE FIX: Replaced 1s timers with a 0.5s recursive action loop
		action this wait 0.5 {tick_05_proc}
$end
