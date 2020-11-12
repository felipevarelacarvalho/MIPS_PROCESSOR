from scripts.quartus import build, parse_timings, generate_project as gp
import os
import shutil
import subprocess
import datetime
import traceback

def main():

    # create temp directory if it doesn't exist
    os.makedirs('temp',exist_ok=True)
    
    # # exit if quartus is not installed in the expected location
    # if not os.path.isdir('C:/altera/intelFPGA/18.0/quartus/bin64'):
    #     print(r'Quartus is not installed in the expected location: C:\altera\intelFPGA\18.0\quartus\bin64\quartus_fit')
    #     print('If you are in the TLA, You can use the computers by the soldering irons, or the lab across the hallway')
    #     exit(1)

    # list vhd files to include in the quartus project
    vhd_list = gp.find_vhd_files(dir='ModelSimWork/src')
    if vhd_list == []:
        print('no vhd files were found')
        exit(1)

    # create quartus directory if it doesn't exist, if another process is using
    # The directory we need to exit
    try: 
        shutil.rmtree('QuartusWork')
    except FileNotFoundError:
        pass
    except Exception as e: 
        print("Could not delete QuartusWork",e)
        exit(1)
    os.makedirs('QuartusWork')

    gp.write_qsf(vhd_list,dir='QuartusWork')
    gp.write_qpf(dir='QuartusWork')
    gp.write_sdc(dir='QuartusWork')

    build_success = build.build_all()
    if not build_success:
        exit(1)

    parse_success = parse_timings.parse_timings()
    if not parse_success:
        exit(1)

    # Use Popen to start notepad in a non-blocking manner
    subprocess.Popen(['Notepad','temp/timing.txt'])

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
		
        