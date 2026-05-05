.PHONY: run
run:
	hugo server -D -p 12345

.PHONY: new
new:
	@echo "Select sub-category:"
	@echo "1: note     (Technical notes, OS, CS)"
	@echo "2: tutorial (ACM, CTF, Walkthroughs)"
	@echo "3: thoughts (Daily life, Musings)"
	@read -p "Choice [1-3] (default 3): " choice; \
	choice=$${choice:-3}; \
	dir=""; \
	case $$choice in \
		1) dir="note";; \
		2) dir="tutorial";; \
		3) dir="thoughts";; \
		*) echo "Invalid choice"; exit 1;; \
	esac; \
	default_name=$$(date +%Y%m); \
	read -p "Enter English/Pinyin slug (default $$default_name): " name; \
	name=$${name:-$$default_name}; \
	filepath="content/post/$$dir/$$name/index.md"; \
	hugo new "post/$$dir/$$name/index.md"; \
	code "$$filepath"

.PHONY: clean
clean:
	@echo "Cleaning site"
	@rm -rf public
