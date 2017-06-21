#!/bin/bash
input=""
for f in recipes/*.png; do
	input+=","$f
done
echo ${input:1}

ktech ${input:1} --atlas ../mod_client/images/dsmmo_recipes.xml
