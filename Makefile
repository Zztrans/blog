.PHONY: run
run:
	hugo server -D -p 12345

.PHONY: new
new:
	@echo "Select sub-category:"
	@echo "1: note     (Technical notes, OS, CS)"
	@echo "2: tutorial (ACM, CTF, Walkthroughs)"
	@echo "3: thoughts (Daily life, Musings)"
	@read -p "Choice [1-3]: " choice; \
	dir=""; \
	case $$choice in \
		1) dir="note";; \
		2) dir="tutorial";; \
		3) dir="thoughts";; \
		*) echo "Invalid choice"; exit 1;; \
	esac; \
	read -p "Enter English/Pinyin slug (e.g. my-new-post): " name; \
	hugo new post/$$dir/$$name/index.md

.PHONY: clean
clean:
	@echo "Cleaning site"
	@rm -rf public
