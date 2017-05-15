set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)            Mac/802_11                   ;# MAC type
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		1000; # X dimension of the topography
set opt(y)		1000;		# Y dimension of the topography
set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)		101		;# number of nodes
set opt(seed)		0.0
set opt(stop)		100	;# simulation time
set opt(tr)		pro.tr	;# trace file
set opt(nam)		pro.nam	;# animation file
set opt(agent)          CORR-OLSR
set opt(energymodel)    EnergyModel     ;
set opt(radiomodel)    	RadioModel     ;
set opt(initialenergy)   100  ;# Initial energy in Joules
set opt(usepsm)		1		;# use power saving mode
set opt(usespan)	1		;# use span election
set opt(spanopt)	1		;# use psm optimization
set t [expr $opt(stop)/2]
set t0 0.0 
set t1 [expr $t/6]
set t2 [expr $t/5]
set t3 [expr $t/2]
set t4 [expr $t-1]
set t5 [expr $t+0.0] 
set t6 [expr $t+$t1]
set t7 [expr $t+$t2]
set t8 [expr $t+$t3]
set t9 [expr $t+$t4]


# ======================================================================

set AgentTrace			ON
set RouterTrace			ON
set MacTrace		        ON

LL set delay_			0
LL set mindelay_		25us
LL set maxdelay_		50us

Agent/CBR set sport_		0
Agent/CBR set dport_		0
# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2.0e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0
source mac
# the above parameters result in a nominal range of 250m
set nominal_range 250.0
set configured_range -1.0
set configured_raw_bitrate -1.0

# ======================================================================



set ns_		[new Simulator]
set topo	[new Topography]
set tracefd	[open $opt(tr) w]
set namtrace    [open $opt(nam) w]
set prop	[new $opt(prop)]
#$ns_ use-newtrace
$topo load_flatgrid $opt(x) $opt(y)
#ns-random 1.0
source rp
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 1000 1000

#
# Create god
#
set god_ [create-god $opt(nn)]


#global node setting

        $ns_ node-config -adhocRouting $opt(agent)  \
			 -llType $opt(ll) \
			 -macType $opt(mac) \
			 -ifqType $opt(ifq) \
			 -ifqLen $opt(ifqlen) \
			 -antType $opt(ant) \
			 -propType $opt(prop) \
			 -phyType $opt(netif) \
			 -channelType $opt(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -energyModel $opt(energymodel) \
			 -idlePower 1.0 \
			 -rxPower 1.0 \
			 -txPower 1.0 \
          		 -sleepPower 0.001 \
          		 -transitionPower 0.2 \
          		 -transitionTime 0.005 \
			 -initialEnergy $opt(initialenergy)


	
	$ns_ set WirelessNewTrace_ ON
set AgentTrace			ON
set RouterTrace		ON
set MacTrace			ON
set node_(0) [$ns_ node]
	$node_(0) set X_ 100
	$node_(0) set Y_ 110
	$node_(0) set Z_ 0
$ns_ initial_node_pos $node_(0) 30;
$ns_ at 0.1001 "$node_(0) add-mark m2 maroon circle"

set node_(1) [$ns_ node]
	$node_(1) set X_ 950
	$node_(1) set Y_ 890
	$node_(1) set Z_ 0
$ns_ initial_node_pos $node_(1) 30;
$ns_ at 0.1001 "$node_(1) add-mark m2 maroon circle"

	for {set i 2} {$i < 100 } {incr i} {
		set node_($i) [$ns_ node]	

set xval [ expr {$opt(x) * rand()} ]
set yval [ expr {$opt(y) * rand()} ]
	$node_($i) set X_ $xval
	$node_($i) set Y_ $yval
	$node_($i) set Z_ 0
$ns_ initial_node_pos $node_($i) 20;
$ns_ at 0.000 "$node_($i) setdest $xval $yval 1.5"
#$node_($i) random-motion 0		;# disable random motion

}


	########################################
proc neighbor_node { tn } {
set nn [open node_neighbor.tr w]
#puts $nn "node \t\tneighbor_node \t\tx-position \t\ty-position \t\tdistance"
global ns_ node_
for  {set i 1} { $i <= $tn } {incr i } {
set x1 [$node_($i) set X_]
set y1 [$node_($i) set Y_]
for {set j 1 } {$j <= $tn} {incr j} {
set x2 [$node_($j) set X_]
set y2 [$node_($j) set Y_]
set distans [expr sqrt(pow([expr $x1 - $x2] ,2)+pow( [ expr $y2 - $y1],2))]
if { $i != $j && $distans < 200} { puts $nn "$i \t\t\t\t$j \t\t\t\t[expr int($x1)] \t\t\t\t[expr int($y1)] \t\t\t\t$distans" 
}
}
}
close $nn
}
for {set j 1} { $j < 2} { incr j } { $ns_ at $j "neighbor_node 99" }

############################################################################
set tcp2 [new Agent/TCP]
$tcp2 set fid_ 1
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp2
$ns_ attach-agent $node_(1) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at 0.15 "$ftp2 start"
#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < 50 } {incr i} {
    $ns_ at $opt(stop) "$node_($i) reset";
}
$ns_ at $opt(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."
$ns_ run
