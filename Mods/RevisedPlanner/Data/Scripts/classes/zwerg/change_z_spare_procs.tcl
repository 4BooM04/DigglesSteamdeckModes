$start
$replace
proc sparetime_searchrange {} {
	global stt_maxsearch_range
	if {![get_prodautoschedule this]} {return [expr {$stt_maxsearch_range*0.05}]} {return $stt_maxsearch_range}
}
$with
proc sparetime_searchrange {} {
	global stt_maxsearch_range
	set range $stt_maxsearch_range
	if {![get_prodautoschedule this]} {set range [expr {$range*0.05}]}
	# PRIORITY FIX: Search range is inverse-proportionate to nutrition
	set dmm_nutr [get_attrib this atr_Nutrition]
	if {$dmm_nutr < 0.1} {set dmm_nutr 0.1}
	set dmm_factor [expr {1.0 / $dmm_nutr}]
	if {$dmm_factor > $print:ST_SEARCH_FACTOR_MAX} {set dmm_factor $print:ST_SEARCH_FACTOR_MAX} ;# Configurable cap
	return [expr {$range * $dmm_factor}]
}
$end

$start
$replace
proc sparetime_eat_check {} {
	global sparetime_eatclasses stt_maxsearch_range
	set max_search_range [sparetime_searchrange]
	set half_search_range [expr {$max_search_range*0.5}]
	set bbox "-$max_search_range -$half_search_range -15 $max_search_range $half_search_range 15"
	foreach objref [inv_list this] {
		if {-1!=[lsearch $sparetime_eatclasses [get_objclass $objref]]} {return 1}
	}
	if {[inv_check this 1]==0} {return 0}
	set objreflist [obj_query this "-class \{$sparetime_eatclasses\} -boundingbox \{$bbox\} -visibility own -owner \{own -1\} -limit 10 -flagpos visible -flagneg \{contained locked\} -water 0 -limit 1"]
	if { $objreflist != 0 } {
		return 1
		foreach objref $objreflist {
			if {abs([get_posx this]-[get_posx $objref])+abs([get_posy this]-[get_posy $objref])*2.0>$max_search_range} {continue}
		//	log "found ground eatitem: $objref"
			return 1
		}
	}
	set objreflist [obj_query this "-class \{$sparetime_eatclasses\} -boundingbox \{$bbox\} -visibility own -owner \{own -1\} -limit 10 -flagpos \{visible instore\} -flagneg locked -water 0 -limit 1"]
	if { $objreflist != 0 } {
		return 1
		foreach objref $objreflist {
			if {abs([get_posx this]-[get_posx $objref])+abs([get_posy this]-[get_posy $objref])*2.0>$max_search_range} {continue}
		//	log "found lager eatitem: $objref"
			return 1
		}
	}
//	log "[get_objname this]: sparetime_eat_check failed"
	return 0
}
$with
proc sparetime_eat_check {} {
	global sparetime_eatclasses stt_maxsearch_range
	set max_search_range [sparetime_searchrange]
	set half_search_range [expr {$max_search_range*0.5}]
	set bbox "-$max_search_range -$half_search_range -15 $max_search_range $half_search_range 15"
	foreach objref [inv_list this] {
		if {-1!=[lsearch $sparetime_eatclasses [get_objclass $objref]]} {return 1}
	}
	if {[inv_check this 1]==0} {return 0}
	
	# Kitchen check
	set placelist [sparetime this queryrect eat -$max_search_range -$half_search_range $max_search_range $half_search_range]
	foreach place $placelist {
		if {[get_prod_pack $place]} {continue}
		set free_idx [prod_guest guestfree $place]
		if {$free_idx == -1} {continue}
		
		# PRIORITY FIX: If I'm not that hungry, and it's the last seat, leave it for someone else
		if {[get_attrib this atr_Nutrition] > $print:ST_HUNGER_THRESHOLD && $free_idx == 0} {
			# Kitchens often only have 1 slot (index 0). 
			# If index 0 is the only free one, skipping it leaves it open.
			continue
		}
		
		set offer [call_method $place get_eat_objects $sparetime_eatclasses]
		if {[lcount $offer 0] == [llength $offer]} {continue}
		return 1
	}

	set objreflist [obj_query this "-class \{$sparetime_eatclasses\} -boundingbox \{$bbox\} -visibility own -owner \{own -1\} -limit 10 -flagpos visible -flagneg \{contained locked\} -water 0 -limit 1"]
	if { $objreflist != 0 } { return 1 }
	set objreflist [obj_query this "-class \{$sparetime_eatclasses\} -boundingbox \{$bbox\} -visibility own -owner \{own -1\} -limit 10 -flagpos \{visible instore\} -flagneg locked -water 0 -limit 1"]
	if { $objreflist != 0 } { return 1 }
	return 0
}
$end

$start
$replace
proc sparetime_ill_start {} {
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 40 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	set found 0
$with
proc sparetime_ill_start {} {
	if {[set hosp_list [obj_query this "-class Krankenhaus -range $print:ST_HOSPITAL_RANGE -owner own -flagneg boxed"]]==0} {
		return 0
	}
	set found 0
$end

$start
$replace
proc sparetime_ill_check {} {
	global sparetime_current_place sparetime_current_place_ref
	if {$sparetime_current_place=="Krankenhaus"} {return 1}
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 40 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	foreach hospital $hosp_list {
$with
proc sparetime_ill_check {} {
	global sparetime_current_place sparetime_current_place_ref is_old
	if {$is_old == 3} {return 0}
	if {$sparetime_current_place=="Krankenhaus"} {return 1}
	if {[set hosp_list [obj_query this "-class Krankenhaus -range $print:ST_HOSPITAL_RANGE -owner own -flagneg boxed"]]==0} {
		return 0
	}
	foreach hospital $hosp_list {
$end
