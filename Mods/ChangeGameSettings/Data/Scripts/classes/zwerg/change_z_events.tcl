$start
$replace
		if {$current_age>24*1800-300} {
$with
		if {$current_age>$print:MAX_AGE*1800-300} {
$end

$start
$replace
		if {$current_age>24*1800} {
$with
		if {$current_age>$print:MAX_AGE*1800} {
$end

$start
$replace
		} elseif {$current_age>22*1800} {
$with
		} elseif {$current_age>($print:MAX_AGE - 2)*1800} {
$end
