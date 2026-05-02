$start
$replace
			} else {
				set sparetime_emergencies [lsort -index 1 [list "eat $at_Nu" "slp $at_Al" "fun $at_Fun"]]
			}
$with
			} else {
				set eat_prio $at_Nu
				# PRIORITY FIX: If nutrition > threshold, deprioritize eating (make it look less urgent)
				if {$at_Nu > $print:ST_HUNGER_THRESHOLD} {
					set eat_prio [expr {$at_Nu + 0.5}]
				}
				set sparetime_emergencies [lsort -index 1 [list "eat $eat_prio" "slp $at_Al" "fun $at_Fun"]]
			}
$end

$start
$replace
			if {$maxstriker>$cstriker} {set work_strike 1} {set work_strike 0}
		}
		set civ_state [hmax $civ_state 0.05]
		set spt_fun_needs [hmax [expr {int($civ_state*10)}] 2]
		set imode 1
		foreach mode {place home sex prtn} {
			set timedist [expr {$ctime-[subst \$spt_last_$mode]}]
$with
			if {$maxstriker>$cstriker} {set work_strike 1} {set work_strike 0}
		}
		set civ_state [hmax $civ_state 0.05]
		set spt_fun_needs [hmin [hmax [expr {int($civ_state*10)}] 2] $print:ST_MAX_FUN_NEEDS]
		set imode 1
		foreach mode {place home sex prtn} {
			set timedist [expr {$ctime-[subst \$spt_last_$mode]}]
$end

$start
$replace
	proc sparetime_place_variety {} {
		global funloss_placevariety spt_favplaces sparetime_recent_fun
		set val [expr {(10-[llength $sparetime_recent_fun])*0.01+0.2}]
		set places {pub tht dsc fit bwl}
		foreach item [concat $places $spt_favplaces] {
			set cnt [lcount $sparetime_recent_fun $item]
			if {$cnt} {
				fincr val [expr {(15-$cnt)*0.008}]
			}
		}
		set funloss_placevariety $val
	}
$with
	proc sparetime_place_variety {} {
		global funloss_placevariety spt_favplaces sparetime_recent_fun
		set gnome_age [calc_age]
		if {$gnome_age < 1800*$print:ST_VARIETY_AGE} {
			# Gnome is younger than threshold -> don't judge place variety yet
			set val [expr $::civ_state + 0.05]
		} else {
			set val [expr {(10-[llength $sparetime_recent_fun])*0.01+0.2}]
			set places {pub tht dsc fit bwl}
			foreach item [concat $places $spt_favplaces] {
				set cnt [lcount $sparetime_recent_fun $item]
				if {$cnt} {
					fincr val [expr {(15-$cnt)*0.008}]
				}	
			}
		}
		set funloss_placevariety $val
	}
$end

$start
$replace
		global tll_fl_funstations
		set sumloss 0.0
		set moodfactor 0.003
		if {$civ_state>$funloss_eatvariety} {
			set moodloss [expr {$civ_state-$funloss_eatvariety}]
			sparetime_talkissue_entry "eat" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatvariety $moodloss
			fincr sumloss $moodloss
		}
$with
		global tll_fl_funstations
		set sumloss 0.0
		set moodfactor $print:ST_MOOD_SENSITIVITY
		global birthtime
		set gnome_age [expr {[gettime]-$birthtime}]
		if {$gnome_age < 1800*$print:ST_VARIETY_AGE} {
			# Gnome is too young, can't judge quality yet
			set default_qual [expr {$civ_state + 0.05}]
			set funloss_eatquality  $default_qual
			set funloss_slpquality  $default_qual
			set funloss_homequality $default_qual
			set funloss_bthquality  $default_qual
		}
		set civ_require [hmin $civ_state [expr {[llength $::sparetime_eatclasses]*0.1}]]
		if {$civ_require>$funloss_eatvariety} {
			set moodloss [expr {$civ_state-$funloss_eatvariety}]
			sparetime_talkissue_entry "eat" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatvariety $moodloss
			fincr sumloss $moodloss
		}
$end
