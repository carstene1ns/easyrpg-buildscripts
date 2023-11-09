#!/usr/bin/env python3

import os, sys
from configparser import ConfigParser, ExtendedInterpolation

script_dir = os.path.dirname(os.path.abspath(__file__))

# Allow to interpolate section names
class MyExtendedInterpolation(ExtendedInterpolation):
	def before_get(self, parser, section, option, value, defaults):
		defaults.maps.append({'section': section})
		return super().before_get(parser, section, option, value, defaults)

# which .ini keys are present and how they are named in .sh file
LEGACY_MAP = {
	"url" : "URL",
	"directory" : "DIR",
	"files" : "FILES",
	"arguments" : "ARGS",
}
ini_file = "packages.ini"
shell_file = "packages.sh"

if __name__ == '__main__':
	cp = ConfigParser(interpolation=MyExtendedInterpolation())

	try:
		with open(f"{script_dir}/{ini_file}", 'r') as f:
			cp.read_file(f)
	except EnvironmentError:
		print(f"Error reading '{ini_file}' file!")
		sys.exit(1)

	original_stdout = sys.stdout

	try:
		with open(f"{script_dir}/{shell_file}", 'w') as f:
			sys.stdout = f
			print("#!/bin/bash\n")
			print("##### GENERATED FILE, DO NOT EDIT! ####")
			print("# edit packages.ini and run ini2sh.py #")
			print("#######################################\n\n")

			# copy all ini sections
			for section in cp.sections():
				#print(f"#lib={section}")
				#version = cp.get(section, "version")
				#print(f"#ver={version}")
				prefix = str(section).upper() + '_'
				for option in cp[section]:
					if option == "comment":
						value = cp.get(section, option)
						print(f'# {value}')
					if option not in LEGACY_MAP or not cp.get(section, option):
						continue
					param = LEGACY_MAP[str(option).lower()]
					value = cp.get(section, option)
					print(f'{prefix}{param}={value}')
				print("")
			sys.stdout = original_stdout
	except EnvironmentError:
		print(f"Error writing '{shell_file}' file!")
		sys.exit(1)

	print("Done.")
