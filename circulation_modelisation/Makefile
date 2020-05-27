NAME=rero_circulation_modelisation
STATE=loan_states

circulation: ${NAME}.svg ${NAME}.png ${STATE}.svg ${STATE}.png

${NAME}.svg: circulation.dot
	dot -Tsvg circulation.dot -o $@

${NAME}.png: circulation.dot
	dot -Tpng circulation.dot -o $@

${STATE}.svg: states.dot
	dot -Tsvg states.dot -o $@

${STATE}.png: states.dot
	dot -Tpng states.dot -o $@

clean:
	rm -f *.svg *.png
