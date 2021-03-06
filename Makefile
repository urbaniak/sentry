VERSION = 2.0.0
GLOBAL_CSS = src/sentry/static/styles/global.css
GLOBAL_CSS_MIN = src/sentry/static/styles/global.min.css
BOOTSTRAP_JS = src/sentry/static/scripts/bootstrap.js
BOOTSTRAP_JS_MIN = src/sentry/static/scripts/bootstrap.min.js
GLOBAL_JS = src/sentry/static/scripts/global.js
GLOBAL_JS_MIN = src/sentry/static/scripts/global.min.js
BOOTSTRAP_LESS = src/sentry.less
LESS_COMPRESSOR ?= `which lessc`
UGLIFY_JS ?= `which uglifyjs`
WATCHR ?= `which watchr`

build: static locale

#
# Compile language files
#

locale:
	cd src/sentry && sentry makemessages -l en
	cd src/sentry && sentry compilemessages

#
# Build less files
#

static:
	@lessc ${BOOTSTRAP_LESS} > ${GLOBAL_CSS};
	@lessc ${BOOTSTRAP_LESS} > ${GLOBAL_CSS_MIN} --compress;
	@cat src/sentry/static/scripts/sentry.core.js src/sentry/static/scripts/sentry.realtime.js src/sentry/static/scripts/sentry.charts.js src/sentry/static/scripts/sentry.notifications.js src/sentry/static/scripts/sentry.stream.js > ${GLOBAL_JS};
	@cat src/bootstrap/js/bootstrap-alert.js src/bootstrap/js/bootstrap-dropdown.js src/bootstrap/js/bootstrap-tooltip.js src/bootstrap/js/bootstrap-tab.js src/bootstrap/js/bootstrap-buttons.js src/bootstrap/js/bootstrap-modal.js src/sentry/static/scripts/bootstrap-datepicker.js > ${BOOTSTRAP_JS};
	@uglifyjs -nc ${GLOBAL_JS} > ${GLOBAL_JS_MIN};
	@uglifyjs -nc ${BOOTSTRAP_JS} > ${BOOTSTRAP_JS_MIN};
	@echo "Static assets successfully built! - `date`";

#
# Watch less files
#

watch:
	@echo "Watching less files..."; \
	make static; \
	watchr -e "watch('src/bootstrap/.*\.less') { system 'make static' }"

test:
	cd src && flake8 --exclude=migrations --ignore=E501,E225,E121,E123,E124,E125,E127,E128 --exit-zero sentry || exit 1
	python setup.py test

coverage:
	cd src && coverage run --include=sentry/* setup.py test && \
	coverage html --omit=*/migrations/* -d cover


.PHONY: build watch