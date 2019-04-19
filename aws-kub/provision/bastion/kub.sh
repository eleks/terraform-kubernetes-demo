#!/bin/bash

#set -o verbose
#set -o errexit

CMD=$1
shift 1

if [ "$CMD" = "bash" ]; then
	kubectl exec $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $1) -it bash
elif [ "$CMD" = "tail" ]; then
	kubectl logs -f $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $1)
elif [ "$CMD" = "logs" ]; then
	kubectl logs $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $1)
elif [ "$CMD" = "pods" ]; then
	kubectl get pods $*
else
	echo "kub <command> <target>"
	echo "--------------------------------------------------------------------------------------"
	echo "  COMMANDS:"
	echo "    bash <pod-name-part>        starts bash for the first matching pod"
	echo "    tail <pod-name-part>        starts log collection 'logs -f' for first matching pod"
	echo "    logs <pod-name-part>        shows log for specified pod"
	echo "    pods                        shows pod list. you could use standard kubectl options"
	echo "--------------------------------------------------------------------------------------"
	echo "  EXAMPLE:"
	echo "    kub bash bpm                starts bash for the pod with name matching 'bpm'"

fi
