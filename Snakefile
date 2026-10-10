# Ghost-vs-Monsters---OOP

# The app's own config, loaded before the shared one. It lists every
# library under "libs", so each is copied as it is, without the
# libraries its own Snakefile requires: DMC-Corona-UI requires all of
# DMC-Corona-Library, and the app needs only the ones below.
configfile: "snakemake/snakeconfig.json"

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "Ghost-vs-Monsters---OOP"
	include: "../DMC-Corona-UI/snakemake/Snakefile"

module_config = {
	"name": "Ghost-vs-Monsters---OOP",
	"module": {
		"dir": "",
		"files": [],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library",

			# used by the app
			"dmc-megaphone",
			"dmc-objects",
			"dmc-states-mixin",
			"dmc-utils",
			"DMC-Corona-UI",

			# used by DMC-Corona-UI
			"dmc-events-mixin",
			"dmc-gestures",
			"dmc-kolor",
			"dmc-lifecycle-mixin",
			"dmc-patch",
			"dmc-path",
			"dmc-touchmanager"
		]
	}
}

register( "Ghost-vs-Monsters---OOP", module_config )
