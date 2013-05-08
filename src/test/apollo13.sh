<<<<<<< HEAD
#!/bin/sh

=======
#! /bin/bash
>>>>>>> Main logic and several fix
LOG=/tmp/inspector-test.log
while true
do
	echo "JFK: \"We are going to the moon!\"" >> $LOG
	sleep 3
	echo "Launching Apollo 13 ..." >> $LOG
	sleep 3
	echo "Reaching Earth orbit" >> $LOG
	sleep 3
	echo "Everything is okay" >> $LOG
	sleep 3
	echo "On my way to the Moon" >> $LOG
	sleep 3
	echo "Camera rolling ... nice views" >> $LOG
	sleep 3
	echo "Error: Houston, We have Got a Problem" >> $LOG
	sleep 3
	echo "Error: We have had a MAIN B BUS UNDERVOLT" >> $LOG
	sleep 3
	echo "Error: Starting to go ahead and button up the tunnel again" >> $LOG
	sleep 3
	echo "Error: RESTART and a PGNCS light. RESET on a PGNCS, RESET" >> $LOG
	sleep 3
	echo "On the way home back to Earth" >> $LOG
	sleep 3
	echo "Parachutes opened and the Command Module splashed down into the South Pacific" >> $LOG
	sleep 3
	echo "Lovell: \"A successful failure!\"" >> $LOG
	sleep 10
done
