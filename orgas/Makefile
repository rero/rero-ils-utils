all: organisations.svg


graph.dot: gen.sh
	bash gen.sh graph.dot


organisations.svg: graph.dot
	dot -Tsvg graph.dot -o organisations.svg

clean:
	rm -f organisations.svg graph.dot
