$start
$replace
		// Flucht ?
		if { [fight_escape] == 1 } {
			fight_exit "escape"
			return
		}
$with
		// Auto-Heal ?
		if { [get_objclass this] == "Zwerg" && [get_attrib this atr_Hitpoints] < $print:AUTO_HEAL_THRESHOLD } {
			set dmm_potion 0
			set dmm_items [inv_list this]
			foreach dmm_class_search {Grosser_Heiltrank Heiltrank Kleiner_Heiltrank} {
				foreach dmm_item $dmm_items {
					if {[get_objclass $dmm_item] == $dmm_class_search} {
						set dmm_potion $dmm_item
						break
					}
				}
				if {$dmm_potion != 0} break
			}
			if { $dmm_potion != 0 } {
				log "[get_objname this] auto-healing with [get_objclass $dmm_potion]"
				drinkpotion $dmm_potion
				return
			}
		}

		// Flucht ?
		if { [fight_escape] == 1 } {
			fight_exit "escape"
			return
		}
$end
