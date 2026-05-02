$start
$after
call scripts/misc/animclassinit.tcl


$put


proc get_civ_state {owner} {
	//get gnome list
	set gnomes [obj_query 0 -class Zwerg -owner $owner -cloaked 1]
	if {$gnomes==0} {set gnomes {}}
	//calculate sum of all exp of all gnomes
	set exp_sum 0
	foreach gnome $gnomes {
		set gnome_exp 0
		foreach attribut [get_expattrib] {
			fincr gnome_exp [get_attrib $gnome $attribut]
		}
		
		//scaling [0, MIN_EXP] with weight 1 and [MIN_EXP, MAX_EXP] with weight 1
		if {$gnome_exp > $print:MIN_EXP} {
			fincr exp_sum 1.0
			set gnome_exp [expr {$gnome_exp-$print:MIN_EXP.0}]
			//MAX_EXP scaling
			fincr exp_sum [expr {$gnome_exp/($print:MAX_EXP.0-$print:MIN_EXP.0)}]
		} else {
			//MIN_EXP scaling
			fincr exp_sum [expr {$gnome_exp/$print:MIN_EXP.0}]
		}
	}
	//population scaling
	set exp_sum [expr {(22.0/$print:POP_SOLL.0*$exp_sum)}]
	
	return [expr {($exp_sum+[gamestats numbuiltprodclasses $owner])*0.01}]
}

$end
