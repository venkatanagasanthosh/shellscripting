#!/bin/bash

read num 
if (($num % 2 == 0));
then 
	echo "The number is even number "
else 
	echo "The number is odd number"
fi	
