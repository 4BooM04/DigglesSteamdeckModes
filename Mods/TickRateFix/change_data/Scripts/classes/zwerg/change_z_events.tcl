$start
$replace
	proc evt_zwerg_workannounce_proc {} {
		global current_workplace workannounce_log
		if {$current_workplace != 0} {
			prod_assignworker this $current_workplace
			if {$workannounce_log} {log "[get_objname this] confirming prod_assignworker"}
		} else {
			if {$workannounce_log} {log "[get_objname this] denying prod_assignworker"}
		}
	}
$with
	proc evt_zwerg_workannounce_proc {} {
		global current_workplace workannounce_log
		if {$current_workplace != 0} {
			prod_assignworker this $current_workplace
			if {$workannounce_log} {log "[get_objname this] confirming prod_assignworker"}
		} else {
			if {$workannounce_log} {log "[get_objname this] denying prod_assignworker"}
		}
	}

	proc tick_05_proc {} {
		if {[is_dying]} return
		evt_zwerg_attribupdate_proc
		evt_zwerg_workannounce_proc
		action this wait 0.5 {tick_05_proc}
	}
$end

$start
$replace
				add_attrib this atr_Hitpoints -0.05 			;# Lava
$with
				add_attrib this atr_Hitpoints -0.025 			;# Lava
$end

$start
$replace
		if {$is_burning} {
			add_attrib this atr_Hitpoints -0.1
		}
$with
		if {$is_burning} {
			add_attrib this atr_Hitpoints -0.05
		}
$end

$start
$replace
				add_attrib this atr_Hitpoints -0.02			;# Schwefel
$with
				add_attrib this atr_Hitpoints -0.01			;# Schwefel
$end

$start
$replace
					if {$remainingair <= 0} {
						add_attrib this atr_Hitpoints -0.025
						set remainingair 0
					} else {
						set remainingair [expr {$remainingair -1}]
					}
$with
					if {$remainingair <= 0} {
						add_attrib this atr_Hitpoints -0.0125
						set remainingair 0
					} else {
						# Breath-holding is now twice as granular
						set remainingair [expr {$remainingair -0.5}]
					}
$end

$start
$replace
				if {$is_wearing_divingbell  &&  $is_wearing_divingbell_by_usercommand == 0} {
					incr out_of_water_timer
					if {$out_of_water_timer > 7} {
						remove_divingbell 0
					}
				}
$with
				if {$is_wearing_divingbell  &&  $is_wearing_divingbell_by_usercommand == 0} {
					# Increase timer at half speed because ticks are twice as fast
					set out_of_water_timer [expr {$out_of_water_timer + 0.5}]
					if {$out_of_water_timer > 7} {
						remove_divingbell 0
					}
				}
$end

$start
$replace
			fincr tll_fl_hunger [expr {([hmax $at_Nu 0.2] - 0.4) * -0.0006} ]
$with
			fincr tll_fl_hunger [expr {([hmax $at_Nu 0.2] - 0.4) * -0.0003} ]
$end

$start
$replace
			fincr tll_fl_tired [expr {([hmax $at_Al 0.2] - 0.4) * -0.0003} ]
$with
			fincr tll_fl_tired [expr {([hmax $at_Al 0.2] - 0.4) * -0.00015} ]
$end

$start
$replace
			fincr tll_fl_common 0.0002
$with
			fincr tll_fl_common 0.0001
$end

$start
$replace
			fincr tll_fl_common 0.00005
$with
			fincr tll_fl_common 0.000025
$end

$start
$replace
		add_attrib this atr_Hitpoints $sub_Hi
		add_attrib this atr_Nutrition $sub_Nu
		add_attrib this atr_Alertness $sub_Al
		add_attrib this atr_Mood $sub_Mo
$with
		# TICK RATE MOD: Half all computed attribute deltas because we run twice as often
		set sub_Hi [expr {$sub_Hi * 0.5}]
		set sub_Nu [expr {$sub_Nu * 0.5}]
		set sub_Al [expr {$sub_Al * 0.5}]
		set sub_Mo [expr {$sub_Mo * 0.5}]

		add_attrib this atr_Hitpoints $sub_Hi
		add_attrib this atr_Nutrition $sub_Nu
		add_attrib this atr_Alertness $sub_Al
		add_attrib this atr_Mood $sub_Mo
$end
