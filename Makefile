
.PHONY: run
run:
	hugo server -D -p 12345

.PHONY: clean
clean:
	@echo "Cleaning site"
	@rm -rf public
