all:
	docker build -t zmk .
	docker run --rm -v $(PWD)/firmware:/app/firmware -v $(PWD)/config:/app/config:ro zmk
