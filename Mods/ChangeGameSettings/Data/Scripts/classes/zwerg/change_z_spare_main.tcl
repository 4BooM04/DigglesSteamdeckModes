$start
$replace
	proc sparetime_get_popsoll {civ} {
		if {$civ<0.15} {
			return [expr {7.0+$civ*20.0}]
		} elseif {$civ<0.4} {
			return [expr {5.2+$civ*32.0}]
		} else {
			return [hmin [expr {10.0+$civ*20.0}] 22.0]
		}
	}
$with
	proc sparetime_get_popsoll {civ} {
		set populationFactor [expr {$print:POP_SOLL.0/22.0}]
		if {$civ<0.15} {
			return [expr {$populationFactor*(7.0+$civ*20.0)}]
		} elseif {$civ<0.4} {
			return [expr {$populationFactor*(5.2+$civ*32.0)}]
		} else {
			return [expr {$populationFactor*([hmin [expr {10.0+$civ*20.0}] 22.0])}]
		}
	}
$end


$start
$replace
		set civ_state [expr {([gamestats attribsum $own expsum]+[gamestats numbuiltprodclasses $own])*0.01}]
$with
		set civ_state [get_civ_state $own]
$end
