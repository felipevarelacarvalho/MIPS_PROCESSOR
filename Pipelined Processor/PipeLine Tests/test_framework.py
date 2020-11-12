import argparse
import re
import os
import traceback
import datetime
import hashlib
from scripts import dump_compare, mars, modelsim

def main():
	'''
	Main method for the test framework
	'''
	# Algorithm:
	# 1) parse arguments
	# 2) vaidate what we can
	# 3) run MARS sim
	# 4) compile student vhdl
	# 5) generate hex with MARS
	# 6) sim student vhdl
	# 7) compare output

	os.makedirs('temp',exist_ok=True)

	# 1) parse arguments
	options = parse_args()

	# 2) vaidate what we can
	missing_file = check_project_files_exist()
	if missing_file:
		print(f'\nCould not find {missing_file}')
		print('program is exiting\n')
		exit()

	if not modelsim.is_installed():
		print('\nModelsim does not seem to be installed in the expected location: C:/Program Files/modeltech64_2020.2/win64/')
		print('program is exiting\n')
		exit()

	if not check_vhdl_present():
		print('\nOops! It doesn\'t look like you\'ve copied your processor into ModelSimWork/src/')
		return

	warn_tb_checksum()

	# 3) run MARS sim
	print('')
	options['asm-path'] = mars.run_sim(asm_file=options['asm-path'])

	# 4) compile student vhdl
	if options['compile']:
		compile_success = modelsim.compile()
		if not compile_success:
			return
	else:
		print('Skipping compilation\n')

	# 5) generate hex with MARS
	mars.generate_hex(options['asm-path'] )
	
	# 6) sim student vhdl
	sim_success = modelsim.sim(timeout=options['sim-timeout'], deep_debug=options['deep_debug'])
	if not sim_success:
		return

	# 7) compare output
	compare_dumps(options)

def check_vhdl_present():
	'''
	Checks if there are any VHDL files present in the src folder other than the provided
	top-level design. prints a warning if there is a file without the .vhd extension

	Returns True if other files exist
	'''
	
	# get a list of all the file names in the dir
	with os.scandir(path='ModelSimWork/src/') as scan:
		src_dir = [f.name for f in scan if f.is_file()]

	# print a warning if there is at least 1 non .vhdd file
	non_vhd = next((f for f in src_dir if not f.endswith('.vhd')),None)
	if non_vhd:
		print('** Warining: your source directory contains a file without the .vhd extension **')
		print(f'** {non_vhd} and other files without the .vhd extension (including .vhdl) will be ignored **')

	expected = {'tb_SimplifiedMIPSProcessor.vhd','mem.vhd','MIPS_Processor.vhd'}

	# return True if at least 1 new .vhd file exists
	is_student_vhd = lambda f: f.endswith('.vhd') and f not in expected
	return any((True for x in src_dir if is_student_vhd(x)))

def parse_args():
	'''
	Parse commnd line arguments into a dictionary, and return that dictionary.

	The returned dictionary has the following keys and types:
	- 'asm-path': str
	- 'max-mismatches': int > 0 
	- 'compile': bool
	'''
	parser = argparse.ArgumentParser()
	parser.add_argument('--asm-file', help='Relative path to assembly file to simulate using unix style paths.')
	parser.add_argument('--max-mismatches', type=check_max_mismatches ,default=3, help='Number of incorrect instructions to print before the program claims failure, default=3')
	parser.add_argument('--nocompile', action='store_true', help='flag used to disable compilation in order to save time')
	parser.add_argument('--sim-timeout',type=check_sim_timeout, default=30, help='change the ammount of time before simulation is forcefully stopped')
	parser.add_argument('--deep-debug', action='store_true', help='flag used to automatically open vsim.wlf in modelsim after simulation')
	args = parser.parse_args()

	options = {
		'asm-path': args.asm_file,
		'max-mismatches': args.max_mismatches,
		'compile': not args.nocompile,
		'sim-timeout': args.sim_timeout,
        'deep_debug': args.deep_debug
	}

	return options

def check_sim_timeout(v):
	ivalue = int(v)
	if ivalue <= 0:
		raise argparse.ArgumentTypeError('--sim-timeout should be a positive integer')
	return ivalue

def check_max_mismatches(v):
	ivalue = int(v)
	if ivalue <= 0:
		raise argparse.ArgumentTypeError('--max-mismatches should be a positive integer')
	return ivalue

def check_project_files_exist():
	'''
	Returns None if all required files exist, otherwise returns path to missing file
	'''
	expected_files = [
		'ModelSimWork/src/tb_SimplifiedMIPSProcessor.vhd',
		'MARsWork/Mars_CPRE381_v1.jar'
	]
	for path in expected_files:
		if not os.path.isfile(path):
			return path

	return None

expected_tb_checksum = b'r\xe1\xe4c(\x1d\x98\x18\xea\x81,\x17\x01Q\xb3\xb2\x1a'
tb_loc = 'ModelSimWork/src/tb_SimplifiedMIPSProcessor.vhd'

def warn_tb_checksum():
	''' 
	Prints a warning if tb_SimplifiedMIPSProcessor has been modified according to a md5 checksum 
	Assumes file exists.
	'''
	expected = b'\xe1\xe4c(\x1d\x98\x18\xea\x81,\x17\x01Q\xb3\xb2\x1a'

	with open('ModelSimWork/src/tb_SimplifiedMIPSProcessor.vhd','rb') as f:
		observed = hashlib.md5(f.read()).digest()

	if observed != expected:
		print(f'** Warning: It looks like ModelSimWork/src/tb_SimplifiedMIPSProcessor.vhd has been modified. It will be graded using the version from the release **\n{observed}\n{expected}')

def compare_dumps(options):
	'''
	Compares dumps ans prints the results to the console
	'''

	student_dump = 'temp/modelsim_dump.out'
	mars_dump = 'temp/mars_dump.out'

	# use user mismatches if the option was specified
	mismatches = options['max-mismatches']
	if not mismatches:
		mismatches = 3

	dump_compare.compare(student_dump,mars_dump,max_mismatches=mismatches)

def log_exception():
	''' Writes the last exception thrown to the error log file'''
	
	with open('temp/errors.log','a') as f:
		f.write(f'\nException caught at {datetime.datetime.now()}:\n')
		traceback.print_exc(file=f)

if __name__ == '__main__':
	try:
		main()
	except KeyboardInterrupt: #exit gracefully since this is common
		exit(1)
	except Exception:
		log_exception()
		print('Program exited with unexpected exception.')
		print('Please post to the Project Testing Framework discussion, and attach temp/errors.log')
		