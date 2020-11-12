import subprocess
import os
import re
import shutil
import time

# used to see if output may have timed out but outputted correctly (meaning no halt signal)
expected_firstline = re.compile(r'In clock cycle: (?P<cycle>[0-9]+)')

def compile():
	'''
	Compiles everything in ModelSimWork/src/ into work
	assumes directory is present. Open's notepad with any compile errors

	Returns True if compilation succeeded
	'''

	print('starting compilation...')

	# Remove the work before compilation to ensure a blank slate and prevent potential issues.
	# If work is not removed, and the last run was terminated unexpectedly, compilation errors
	# will occour
	try:
		shutil.rmtree('ModelsimWork/work') # delete a non empty directory
	except FileNotFoundError as e:
		pass # It is fine if the directory already doesn't exist
	except Exception as e:
		print('Could not successfully delete work folder, perhaps it is open in another program?')
		return False

	# Create work folder for compiled work
	try:
		subprocess.check_output( # use check_output to suppress any output
			['C:\\Program Files\\modeltech64_2020.2\\win64\\vlib.exe','ModelSimWork/work']) 
	except:
		print("could not successfully create work folder")
		return False

	try:
		with open('temp/vcom_compile.log','w') as f:
			exit_code = subprocess.call(
				['C:\\Program Files\\modeltech64_2020.2\\win64\\vcom.exe','-2008','-work','ModelSimWork/work','ModelSimWork/src/*.vhd'],
				stdout=f,
				timeout=60
			)
	except subprocess.TimeoutExpired:
		print('Compilation timed out.\n')
		subprocess.Popen(['Notepad','temp/vcom_compile.log'])
		return False

	if(exit_code != 0):
		print('could not compile successfully, got exit code {}'.format(exit_code))
		
		# Use Popen to start notepad in a non-blocking manner with the compile error
		subprocess.Popen(['Notepad','temp/vcom_compile.log'])
		return False

	print('Successfully compiled vhdl\n')
	return True

def sim(timeout=30, deep_debug=False):
	'''
	Simulates testbench. All work should be compiled before this method is called
	Returns True if the simulation was successful, otherwise False
	'''

	print('Starting VHDL Simulation...')
	
	try:

		do_file = 'modelsim_framework.do'
		if(deep_debug):
			do_file = 'modelsim_framework2.do';


		# C:\Program Files\modeltech64_2020.2\win64\vsim.exe -c -novopt tb_SimplifiedMIPSProcessor -do modelsim_fremawork.do
		with open('temp/vsim.log','w') as sim_log:
			exit_code = subprocess.call(
				['C:\\Program Files\\modeltech64_2020.2\\win64\\vsim.exe','-c','tb_SimplifiedMIPSProcessor','-do',do_file],
				stdout=sim_log,
				stderr=sim_log,
				cwd='ModelSimWork/', #Run this process in a different directory for work folder
				timeout=timeout # If the do file doesn't reach the 'quit' we need to manually kill the process
			)

		# check if process exited with error.
		if(exit_code != 0):
			print(f'could not simulate successfully, got exit code {exit_code}')

			# Use Popen to start notepad in a non-blocking manner with the sim error
			subprocess.Popen(['Notepad','temp/vsim.log'])
			return False

	except subprocess.TimeoutExpired:

		if timeout_is_nohalt():
			print('** Warning: Simulation timed out, but produced some valid output, most likely the halt signal is incorrect or the application contains an infinite loop **')
		else:
			busy_move('ModelSimWork/dump.out','temp/modelsim_dump.out',missingok=True)
			busy_move('ModelSimWork/vsim.wlf', 'temp/vsim.wlf', missingok=True)

			# close the simulation with a failure since the simulation didn't produce a valid output
			print('Simulation timed out (if you think this was a mistake you can increase the time to more than 30 seconds explicitly via --sim-timeout)\n')
			subprocess.Popen(['Notepad','temp/vsim.log'])
			
			return False

	# busy_move instead of shutil.move because in the case where the sim timed-out, but produced output
	# there is usually a permission error, but we can retry until it works. (or a timeout is reached)
	busy_move('ModelSimWork/dump.out','temp/modelsim_dump.out',missingok=False)
	busy_move('ModelSimWork/vsim.wlf', 'temp/vsim.wlf',missingok=False)

	print('Successfully simulated program!\n')

	if(deep_debug):
		subprocess.Popen(['C:\\Program Files\\modeltech64_2020.2\\win64\\\\vsim.exe','-view','temp/vsim.wlf'])



	return True


def timeout_is_nohalt():
	'''
	Opens dump file to check if file is formatted correctly despite process timing out.
	This would indicate that no halt signal was implemented, but simulation was correct otherwise.

	Retuns False if halt didn't cause the time out
		, True if it may have times out because of halt
	'''
	if not os.path.isfile('ModelSimWork/dump.out'):
		return False

	with open('ModelSimWork/dump.out') as f:
		firstline = f.readline()
	
	return expected_firstline.match(firstline)

def busy_move(src,dest,timeout=5,missingok=False):
	'''
	Sometimes when modelsim is timed out it still holds some file resources, preventing the files
	from being deleted or moved. This is just shutil.move wrapped so that it busy-waits by retrying
	until the resource is released.
	'''
	s = time.time()
	while True:
		try:
			shutil.move(src,dest)
			return
		except FileNotFoundError as e:
			if not missingok: 
				raise e # re-raise if user did not allow file to not exist
		except PermissionError as e:
			if time.time() - s > timeout:
				raise e  # stop trying if we have reached the timeout
		
def is_installed():
	'''
	Returns True if modelsim is installed on the computer in the expected location
	'''

	# This only checks the existance of the win64 directory with the executables we want
	return os.path.isdir('C:/Program Files/modeltech64_2020.2/win64')
