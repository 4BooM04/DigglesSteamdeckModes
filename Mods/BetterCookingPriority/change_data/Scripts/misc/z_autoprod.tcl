$start
$before
                # special case: hospital
$put
                # special case: food production & supply chain
                set is_food_related 0
                if {[get_class_category $items] == "food"} {
                    set is_food_related 1
                } elseif {[lsearch {Feuerstelle Mittelalterkueche Industriekueche Luxuskueche Farm} [get_objclass $place]] >= 0} {
                    set is_food_related 1
                } elseif {$type == "carry"} {
                    set destination [lindex $task 4]
                    if {[lsearch {Feuerstelle Mittelalterkueche Industriekueche Luxuskueche Farm} [get_objclass $destination]] >= 0} {
                        set is_food_related 1
                    }
                }

                if {$is_food_related} {
                    append score +$print:FOOD_BASE_PRIORITY
                    
                    set dmm_nutrition [get_attrib this atr_Nutrition]
                    
                    # LOGIC REFINEMENT:
                    # Healthy gnomes should work IN the kitchen.
                    # Hungry gnomes should carry stuff TO the kitchen (ending up near food).
                    
                    if {$type == "carry"} {
                        # Carrying tasks: Higher bonus for HUNGRIER gnomes (lower nutrition)
                        set dmm_hunger_bonus [expr {(1.0 - $dmm_nutrition) * $print:CARRY_HUNGER_BONUS}]
                        append score +$dmm_hunger_bonus
                    } else {
                        # Production/Cooking tasks: Higher bonus for HEALTHIER gnomes
                        set dmm_health_bonus [expr {$dmm_nutrition * $print:PROD_HEALTH_BONUS}]
                        append score +$dmm_health_bonus
                    }
                    
                    # Dynamic escalation: if gnomes are starving, kitchen becomes TOP priority
                    global dmm_hunger_time dmm_colony_starving
                    set dmm_now [gettime]
                    if {![info exists dmm_hunger_time] || $dmm_now != $dmm_hunger_time} {
                        set dmm_hunger_time $dmm_now
                        set dmm_colony_starving 0
                        set dmm_my_owner [get_owner this]
                        foreach dmm_g [obj_query 0 -owner $dmm_my_owner -class Zwerg] {
                            if {[get_attrib $dmm_g atr_Nutrition] < $print:STARVATION_THRESHOLD} {
                                set dmm_colony_starving 1
                                break
                            }
                        }
                    }
                    if {$dmm_colony_starving} {
                        append score +$print:STARVATION_ESCALATION
                    }
                }

$end
